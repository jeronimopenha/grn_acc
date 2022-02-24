from veriloggen import *
from math import log2, ceil
from grn2dot.grn2dot import Grn2dot

from hw.utils import initialize_regs


class GrnComponents:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        self.cache = {}

    def create_memory(self):
        name = 'memory'
        if name in self.cache.keys():
            return self.cache[name]

        m = Module(name)
        init_file = m.Parameter('init_file', 'mem_file.txt')
        data_width = m.Parameter('data_width', 32)
        addr_width = m.Parameter('addr_width', 8)

        clk = m.Input('clk')

        we = m.Input('we')
        re = m.Input('re')

        raddr = m.Input('raddr', addr_width)
        waddr = m.Input('waddr', addr_width)
        din = m.Input('din', data_width)
        dout = m.OutputReg('dout', data_width)

        m.EmbeddedCode('(* ramstyle = "AUTO, no_rw_check" *) reg  [data_width-1:0] mem[0:2**addr_width-1];')
        m.EmbeddedCode('/*')
        mem = m.Reg('mem', data_width, Power(2, addr_width))
        m.EmbeddedCode('*/')

        m.Always(Posedge(clk))(
            If(we)(
                mem[waddr](din)
            ),
            If(re)(
                dout(mem[raddr])
            )
        )
        m.EmbeddedCode('//synthesis translate_off')

        i = m.Integer('i')
        m.Initial(
            dout(0),
            For(i(0), i < Power(2, addr_width), i.inc())(
                mem[i](0)
            ),
            Systask('readmemh', init_file, mem)
        )
        m.EmbeddedCode('//synthesis translate_on')
        self.cache[name] = m
        return m

    def create_fifo(self):
        name = 'fifo'
        if name in self.cache.keys():
            return self.cache[name]
        m = Module(name)
        FIFO_WIDTH = m.Parameter('FIFO_WIDTH', 32)
        FIFO_DEPTH_BITS = m.Parameter('FIFO_DEPTH_BITS', 8)
        FIFO_ALMOSTFULL_THRESHOLD = m.Parameter('FIFO_ALMOSTFULL_THRESHOLD', Power(2, FIFO_DEPTH_BITS) - 4)
        FIFO_ALMOSTEMPTY_THRESHOLD = m.Parameter('FIFO_ALMOSTEMPTY_THRESHOLD', 4)

        clk = m.Input('clk')
        rst = m.Input('rst')
        write_enable = m.Input('write_enable')
        input_data = m.Input('input_data', FIFO_WIDTH)
        output_read_enable = m.Input('output_read_enable')
        output_valid = m.OutputReg('output_valid')
        output_data = m.OutputReg('output_data', FIFO_WIDTH)
        empty = m.OutputReg('empty')
        almostempty = m.OutputReg('almostempty')
        full = m.OutputReg('full')
        almostfull = m.OutputReg('almostfull')
        data_count = m.OutputReg('data_count', FIFO_DEPTH_BITS + 1)

        read_pointer = m.Reg('read_pointer', FIFO_DEPTH_BITS)
        write_pointer = m.Reg('write_pointer', FIFO_DEPTH_BITS)
        m.EmbeddedCode('(* ramstyle = "AUTO, no_rw_check" *) reg  [FIFO_WIDTH-1:0] mem[0:2**FIFO_DEPTH_BITS-1];')
        m.EmbeddedCode("/*")
        mem = m.Reg('mem', FIFO_WIDTH, Power(2, FIFO_DEPTH_BITS))
        m.EmbeddedCode("*/")

        m.Always(Posedge(clk))(
            If(rst)(
                empty(1),
                almostempty(1),
                full(0),
                almostfull(0),
                read_pointer(0),
                write_pointer(0),
                data_count(0)
            ).Else(
                Case(Cat(write_enable, output_read_enable))(
                    When(3)(
                        read_pointer(read_pointer + 1),
                        write_pointer(write_pointer + 1),
                    ),
                    When(2)(
                        If(~full)(
                            write_pointer(write_pointer + 1),
                            data_count(data_count + 1),
                            empty(0),
                            If(data_count == (FIFO_ALMOSTEMPTY_THRESHOLD - 1))(
                                almostempty(0)
                            ),
                            If(data_count == Power(2, FIFO_DEPTH_BITS) - 1)(
                                full(1)
                            ),
                            If(data_count == (FIFO_ALMOSTFULL_THRESHOLD - 1))(
                                almostfull(1)
                            )
                        )

                    ),
                    When(1)(
                        If(~empty)(
                            read_pointer(read_pointer + 1),
                            data_count(data_count - 1),
                            full(0),
                            If(data_count == FIFO_ALMOSTFULL_THRESHOLD)(
                                almostfull(0)
                            ),
                            If(data_count == 1)(
                                empty(1)
                            ),
                            If(data_count == FIFO_ALMOSTEMPTY_THRESHOLD)(
                                almostempty(1)
                            )

                        )
                    ),
                )
            )
        )
        m.Always(Posedge(clk))(
            If(rst)(
                output_valid(0)
            ).Else(
                output_valid(0),
                If(write_enable == 1)(
                    mem[write_pointer](input_data)
                ),
                If(output_read_enable == 1)(
                    output_data(mem[read_pointer]),
                    output_valid(1)
                )
            )
        )
        self.cache[name] = m
        return m

    def create_grn_core(self, grn_content: Grn2dot, bus_width):
        name = 'grn_naive_core'
        if name in self.cache.keys():
            return self.cache[name]
        m = Module(name)

        core_id = m.Parameter('core_id', 0, 16)

        # Basic Inputs - Begin ----------------------------------------------------------------------------------------
        clk = m.Input('clk')
        rst = m.Input('rst')
        start = m.Input('start')
        done = m.OutputReg('done')
        # Basic Input - End -------------------------------------------------------------------------------------------

        # Configuration inputs - Begin --------------------------------------------------------------------------------
        # The grn core naive configuration consists in two buses with the initial state and the final state to be
        # searched
        initial_state = m.Input('initial_state', grn_content.get_num_nodes())
        final_state = m.Input('final_state', grn_content.get_num_nodes())
        # Configuration Inputs - End ----------------------------------------------------------------------------------

        # Output data Control interface - Begin -----------------------------------------------------------------------
        # The naive kernel output data is the FIFO data output that contains all the data found
        output_read_enable = m.Input('output_read_enable')
        output_valid = m.Output('output_valid')
        output_data = m.Output('output_data', bus_width)
        output_available = m.Output('output_available')
        output_almost_empty = m.Output('output_almost_empty')
        # Output data Control interface - End -------------------------------------------------------------------------

        m.EmbeddedCode(
            "// The grn core naive configuration consists in two buses with the initial state and the final ")
        m.EmbeddedCode("// state to be searched.")

        # Fifo wires and regs
        m.EmbeddedCode("//Fifo wires and regs")
        fifo_write_enable = m.Reg('fifo_write_enable')
        fifo_input_data = m.Reg('fifo_input_data', bus_width)
        fifo_almost_full = m.Wire('fifo_almost_full')
        fifo_empty = m.Wire('fifo_empty')

        # Wires and regs to be used in control and execution of the grn naive
        m.EmbeddedCode("\n// Wires and regs to be used in control and execution of the grn naive")
        actual_state_s1 = m.Reg('actual_state_s1', grn_content.get_num_nodes())
        next_state_s1 = m.Wire('next_state_s1', grn_content.get_num_nodes())
        actual_state_s2 = m.Reg('actual_state_s2', grn_content.get_num_nodes())
        next_state_s2 = m.Wire('next_state_s2', grn_content.get_num_nodes())
        exec_state = m.Reg('exec_state', grn_content.get_num_nodes())
        flag_pulse = m.Reg('flag_pulse')
        flag_first_it = m.Reg('flag_first_it')
        transient_counter = m.Reg('transient_counter', 16)
        period_counter = m.Reg('period_counter', 16)

        bits_width = grn_content.get_num_nodes() + 16 + 16 + 16
        data_write_width = ceil(bits_width / bus_width) * bus_width
        bits_to_add = data_write_width - bits_width
        qty_data = data_write_width // bus_width
        data_to_write = m.Reg('data_to_write', data_write_width)
        write_counter = m.Reg('write_counter', ceil(log2(qty_data)) + 1)
        perf_counter = m.Reg('perf_counter', 32)
        perf_flag = m.Reg('perf_flag')
        m.EmbeddedCode("")

        # State machine to control the grn algorithm execution
        m.EmbeddedCode("//State machine to control the grn algorithm execution")
        fsm_naive = m.Reg('fsm_naive', 3)
        fsm_naive_set = m.Localparam('fsm_naive_set', 0)
        fsm_naive_init = m.Localparam('fsm_naive_init', 1)
        fsm_naive_transient_finder = m.Localparam('fsm_naive_transient_finder', 2)
        fsm_naive_period_finder = m.Localparam('fsm_naive_period_finder', 3)
        fsm_naive_prepare_to_write = m.Localparam('fsm_naive_prepare_to_write', 4)
        fsm_naive_write = m.Localparam('fsm_naive_write', 5)
        fsm_naive_verify = m.Localparam('fsm_naive_verify', 6)
        fsm_naive_done = m.Localparam('fsm_naive_done', 7)

        m.Always(Posedge(clk))(
            If(rst)(
                fifo_write_enable(0),
                perf_counter(0),
                perf_flag(0),
                done(0),
                fsm_naive(fsm_naive_set),
            ).Elif(start)(
                fifo_write_enable(0),
                Case(fsm_naive)(
                    When(fsm_naive_set)(
                        exec_state(initial_state),
                        fsm_naive(fsm_naive_init),
                    ),
                    When(fsm_naive_init)(
                        actual_state_s1(exec_state),
                        actual_state_s2(exec_state),
                        transient_counter(0),
                        period_counter(0),
                        flag_first_it(1),
                        flag_pulse(0),
                        fsm_naive(fsm_naive_transient_finder),
                    ),
                    When(fsm_naive_transient_finder)(
                        flag_first_it(0),
                        If(AndList((actual_state_s1 == actual_state_s2), ~flag_first_it, ~flag_pulse))(
                            flag_first_it(1),
                            fsm_naive(fsm_naive_period_finder),
                        ).Else(
                            actual_state_s2(next_state_s2),
                            If(flag_pulse)(
                                transient_counter.inc(),
                                flag_pulse(0),
                            ).Else(
                                flag_pulse(1),
                                actual_state_s1(next_state_s1),
                            ),
                        ),
                    ),
                    When(fsm_naive_period_finder)(
                        flag_first_it(0),
                        If(AndList((actual_state_s1 == actual_state_s2), ~flag_first_it))(
                            period_counter.dec(),
                            fsm_naive(fsm_naive_prepare_to_write)
                        ).Else(
                            actual_state_s2(next_state_s2),
                            period_counter.inc(),
                        ),
                    ),
                    When(fsm_naive_prepare_to_write)(
                        data_to_write(
                            Cat(
                                Int(0, (bits_to_add), 2),
                                actual_state_s1,
                                core_id,
                                transient_counter,
                                period_counter
                            )
                            if bits_to_add > 0
                            else
                            Cat(
                                actual_state_s1,
                                core_id,
                                transient_counter,
                                period_counter
                            )
                        ),
                        fsm_naive(fsm_naive_write),
                        write_counter(0),
                    ),
                    When(fsm_naive_write)(
                        If(write_counter == int(qty_data - 1))(
                            fsm_naive(fsm_naive_verify)
                        ),
                        If(~fifo_almost_full)(
                            write_counter.inc(),
                            fifo_write_enable(1),
                            data_to_write(Cat(Int(0, bus_width, 2), data_to_write[bus_width:data_to_write.width])),
                            fifo_input_data(data_to_write[0:bus_width]),
                        ).Else(
                            perf_counter.inc()
                        )
                    ),
                    When(fsm_naive_verify)(
                        If(exec_state == final_state)(
                            fsm_naive(fsm_naive_done),
                        ).Else(
                            exec_state.inc(),
                            fsm_naive(fsm_naive_init)
                        )
                    ),
                    When(fsm_naive_done)(
                        If(perf_flag)(
                            done(fifo_empty)
                        ).Else(
                            data_to_write(
                                Cat(
                                    Int(0, (bits_to_add), 2),
                                    Int(0, grn_content.get_num_nodes(), 2),
                                    Cat(Int(1, 1, 2), core_id[0:core_id.width - 1]),
                                    perf_counter
                                )
                                if bits_to_add > 0
                                else
                                Cat(
                                    Int(0, grn_content.get_num_nodes(), 2),
                                    Cat(Int(1, 1, 2), core_id[0:core_id.width - 1]),
                                    perf_counter
                                )
                            ),
                            fsm_naive(fsm_naive_write),
                            write_counter(0),
                            perf_flag(1),
                        )
                    )
                )
            )
        )

        # Output data fifo instantiation
        m.EmbeddedCode("//Output data fifo instantiation")

        output_available.assign(~fifo_empty)

        fifo = self.create_fifo()
        con = [('clk', clk), ('rst', rst), ('write_enable', fifo_write_enable), ('input_data', fifo_input_data),
               ('output_read_enable', output_read_enable), ('output_valid', output_valid), ('output_data', output_data),
               ('empty', fifo_empty), ('almostempty', output_almost_empty), ('almostfull', fifo_almost_full)]
        par = [('FIFO_WIDTH', bus_width), ('FIFO_DEPTH_BITS', ceil(log2(8 * qty_data)))]
        m.Instance(fifo, 'grn_naive_core_output_fifo', par, con)

        # Here are the GRN equations to be used in the core execution are created
        m.EmbeddedCode("\n// Here are the GRN equations to be used in the core execution are created")
        equations = grn_content.get_equations_dict()
        nodes = grn_content.get_nodes_vector()
        nodes_assign_dict = {}
        nodes_assign_dict_counter = 0
        assign_string = ""
        for node in equations:
            equations[node] = equations[node].replace('||', ' || ')
            equations[node] = equations[node].replace('&&', ' && ')
            equations[node] = equations[node].replace('!', ' ! ')
            equations[node] = equations[node].replace('(', ' ( ')
            equations[node] = equations[node].replace(')', ' ) ')
            equations[node] = " " + equations[node] + " "
            for n in nodes:
                n = " " + n + " "
                if not n in nodes_assign_dict:
                    nodes_assign_dict[n] = str(nodes_assign_dict_counter)
                    nodes_assign_dict_counter = nodes_assign_dict_counter + 1
                if n in equations[node]:
                    equations[node] = equations[node].replace(n, 'actual_state_s1[' + nodes_assign_dict[n] + ']')
            assign_string = assign_string + "assign next_state_s1[" + nodes_assign_dict[" " + node + " "] + "] = " + \
                            equations[node] + ";\n"
        # For S1 pointer
        m.EmbeddedCode("// For S1 pointer")
        m.EmbeddedCode(assign_string)
        # For S2 pointer
        m.EmbeddedCode("// For S2 pointer")
        assign_string = assign_string.replace("actual_state_s1", "actual_state_s2")
        assign_string = assign_string.replace("next_state_s1", "next_state_s2")
        m.EmbeddedCode(assign_string)

        initialize_regs(m)
        self.cache[name] = m
        return m

    def create_grn_pe(self, grn_content, bus_width):
        name = 'grn_naive_pe'
        if name in self.cache.keys():
            return self.cache[name]
        m = Module(name)

        pe_id = m.Parameter('pe_id', 0, 16)
        rr_wait = m.Parameter('rr_wait', 0, 8)

        # Basic Inputs - Begin ----------------------------------------------------------------------------------------
        clk = m.Input('clk')
        rst = m.Input('rst')
        # Basic Input - End -------------------------------------------------------------------------------------------

        # PE configuration signals
        config_input_valid = m.Input('config_input_valid')
        config_input = m.Input('config_input', 8)
        config_output_valid = m.OutputReg('config_output_valid')
        config_output = m.OutputReg('config_output', 8)
        # --------------------------------------------------------------------------------------------------------------

        # bypass data Control interface - Begin -----------------------------------------------------------------------
        # The naive kernel output data is the FIFO data output that contains all the data found
        pe_bypass_read_enable = m.OutputReg('pe_bypass_read_enable')
        pe_bypass_valid = m.Input('pe_bypass_valid')
        pe_bypass_data = m.Input('pe_bypass_data', bus_width)
        pe_bypass_available = m.Input('pe_bypass_available')
        pe_bypass_almost_empty = m.Input('pe_bypass_almost_empty')
        # Output data Control interface - End -------------------------------------------------------------------------

        # Output data Control interface - Begin -----------------------------------------------------------------------
        # The naive kernel output data is the FIFO data output that contains all the data found
        pe_output_read_enable = m.Input('pe_output_read_enable')
        pe_output_valid = m.Output('pe_output_valid')
        pe_output_data = m.Output('pe_output_data', bus_width)
        pe_output_available = m.Output('pe_output_available')
        pe_output_almost_empty = m.Output('pe_output_almost_empty')
        # Output data Control interface - End -------------------------------------------------------------------------

        # configuration wires and regs begin ---------------------------------------------------------------------------
        m.EmbeddedCode('\n//configuration wires and regs - begin')
        is_configured = m.Reg('is_configured')
        pe_init_conf = m.Wire('pe_init_conf', ceil(grn_content.get_num_nodes() / 8) * 8)
        pe_end_conf = m.Wire('pe_end_conf', ceil(grn_content.get_num_nodes() / 8) * 8)
        pe_data_conf = m.Reg('pe_data_conf', pe_init_conf.width + pe_end_conf.width)
        pe_init_conf.assign(pe_data_conf[0:pe_init_conf.width])
        pe_end_conf.assign(pe_data_conf[pe_init_conf.width:pe_init_conf.width + pe_end_conf.width])
        config_counter = m.Reg('config_counter', ceil(log2((pe_init_conf.width + pe_end_conf.width) // 8)) + 1)
        m.EmbeddedCode('//configuration wires and regs - end\n')
        # configuration wires and regs end -----------------------------------------------------------------------------
        # regs and wires to control the grn core
        m.EmbeddedCode("// regs and wires to control the grn core")

        # regs and wires to control the grn core
        m.EmbeddedCode("// regs and wires to control the grn core")
        start_grn = m.Reg('start_grn')
        grn_done = m.Wire('grn_done')
        grn_initial_state = m.Wire('grn_initial_state', grn_content.get_num_nodes())
        grn_final_state = m.Wire('grn_final_state', grn_content.get_num_nodes())
        grn_output_read_enable = m.Reg('grn_output_read_enable')
        grn_output_valid = m.Wire('grn_output_valid')
        grn_output_data = m.Wire('grn_output_data', bus_width)
        grn_output_available = m.Wire('grn_output_available')
        grn_output_almost_empty = m.Wire('grn_output_almost_empty')

        fsm_pe_jo = m.Reg('fsm_pe_jo', 3)
        fsm_pe_jo_look_grn = m.Localparam('fsm_pe_jo_look_grn', 0)
        fsm_pe_jo_rd_grn = m.Localparam('fsm_pe_jo_rd_grn', 1)
        fsm_pe_jo_look_pe = m.Localparam('fsm_pe_jo_look_pe', 2)
        fsm_pe_jo_rd_pe = m.Localparam('fsm_pe_jo_rd_pe', 3)
        fsm_pe_jo_only_pe = m.Localparam('fsm_pe_jo_only_pe', 4)

        data_write_width = ceil((grn_content.get_num_nodes() + 16 + 16 + 16) / bus_width) * bus_width
        qty_data_write = data_write_width // bus_width
        wr_counter = m.Reg('wr_counter', ceil(log2(qty_data_write)) + 1)
        rd_counter = m.Reg('rd_counter', ceil(log2(qty_data_write)) + 1)
        rr_wait_counter = m.Reg('rr_wait_counter', rr_wait.width + 1)

        # Fifo out wires and regs
        m.EmbeddedCode("\n//Fifo out wires and regs")
        fifo_out_write_enable = m.Reg('fifo_out_write_enable')
        fifo_out_input_data = m.Reg('fifo_out_input_data', bus_width)
        fifo_out_empty = m.Wire('fifo_out_empty')
        fifo_out_almost_full = m.Wire('fifo_out_almost_full')
        flag_read = m.Reg('flag_read')

        # configuration sector -----------------------------------------------------------------------------------------
        m.EmbeddedCode('\n//configuration sector - begin')

        # PE configuration machine
        m.Always(Posedge(clk))(
            If(rst)(
                is_configured(0),
                config_output_valid(0),
                config_counter(0)
            ).Else(
                If(~is_configured)(
                    If(config_input_valid)(
                        config_counter.inc(),
                        If(config_counter == ((pe_init_conf.width + pe_end_conf.width) // 8) - 1)(
                            is_configured(1)
                        ),
                        pe_data_conf(Cat(config_input, pe_data_conf[8:pe_data_conf.width]))
                    ),
                ).Else(
                    config_output_valid(config_input_valid),
                    config_output(config_input),
                ),
            ),
        )
        m.EmbeddedCode('//configuration sector - end')
        # configuration sector - end -----------------------------------------------------------------------------------

        # execution sector - begin -------------------------------------------------------------------------------------
        m.EmbeddedCode("\n//execution sector - begin")
        m.Always(Posedge(clk))(
            If(rst)(
                start_grn(0),
                grn_output_read_enable(0),
                pe_bypass_read_enable(0),
                fifo_out_write_enable(0),
                fsm_pe_jo(fsm_pe_jo_look_grn),
            ).Elif(is_configured)(
                start_grn(1),
                grn_output_read_enable(0),
                pe_bypass_read_enable(0),
                fifo_out_write_enable(0),
                Case(fsm_pe_jo)(
                    When(fsm_pe_jo_look_grn)(
                        If(grn_output_available)(
                            wr_counter(0),
                            rd_counter(1),
                            grn_output_read_enable(1),
                            fsm_pe_jo(fsm_pe_jo_rd_grn),
                        ).Else(
                            fsm_pe_jo(fsm_pe_jo_look_pe),
                        )
                    ),
                    When(fsm_pe_jo_rd_grn)(
                        If(rd_counter < qty_data_write)(
                            If(~fifo_out_almost_full)(
                                If(grn_output_available)(
                                    grn_output_read_enable(1),
                                    rd_counter.inc(),
                                ),
                            ),
                        ),
                        If(grn_output_valid)(
                            If(wr_counter == qty_data_write - 1)(
                                fsm_pe_jo(fsm_pe_jo_look_pe)
                            ),
                            fifo_out_input_data(grn_output_data),
                            fifo_out_write_enable(1),
                            wr_counter.inc(),
                        ),
                    ),
                    When(fsm_pe_jo_look_pe)(
                        If(pe_bypass_available)(
                            wr_counter(0),
                            rd_counter(1),
                            flag_read(0),
                            pe_bypass_read_enable(1),
                            If(~grn_done)(
                                rr_wait_counter(0),
                                fsm_pe_jo(fsm_pe_jo_rd_pe),
                            ).Else(
                                fsm_pe_jo(fsm_pe_jo_only_pe),
                            ),

                        ).Else(
                            fsm_pe_jo(fsm_pe_jo_look_grn),
                        ),
                    ),
                    When(fsm_pe_jo_rd_pe)(
                        If(rd_counter < qty_data_write)(
                            If(~fifo_out_almost_full)(
                                If(~pe_bypass_almost_empty)(
                                    pe_bypass_read_enable(1),
                                    rd_counter.inc(),
                                ).Elif(pe_bypass_available)(
                                    If(flag_read)(
                                        pe_bypass_read_enable(1),
                                        rd_counter.inc(),
                                    ),
                                    flag_read(~flag_read),
                                ),
                            ),
                        ),
                        If(pe_bypass_valid)(
                            fifo_out_input_data(pe_bypass_data),
                            fifo_out_write_enable(1),
                            If(wr_counter == qty_data_write - 1)(
                                If(rr_wait_counter == rr_wait - 1)(
                                    fsm_pe_jo(fsm_pe_jo_look_grn),
                                ).Elif(pe_bypass_available)(
                                    rr_wait_counter.inc(),
                                ).Else(
                                    fsm_pe_jo(fsm_pe_jo_look_grn),
                                ),
                                wr_counter(0),
                                rd_counter(0),
                            ).Else(
                                wr_counter.inc(),
                            ),
                        ),
                    ),
                    When(fsm_pe_jo_only_pe)(
                        If(~fifo_out_almost_full)(
                            If(~pe_bypass_almost_empty)(
                                pe_bypass_read_enable(1),
                            ).Elif(pe_bypass_available)(
                                If(flag_read)(
                                    pe_bypass_read_enable(1),
                                ),
                                flag_read(~flag_read),
                            ),
                        ),
                        If(pe_bypass_valid)(
                            fifo_out_input_data(pe_bypass_data),
                            fifo_out_write_enable(1),
                        ),
                    ),
                )
            )
        )
        # execution sector - end ---------------------------------------------------------------------------------------

        # Grn core instantiation
        m.EmbeddedCode("// Grn core instantiation")
        grn_initial_state.assign(pe_init_conf[0:grn_initial_state.width])
        grn_final_state.assign(pe_end_conf[0:grn_final_state.width])
        par = [('core_id', pe_id)]
        con = [('clk', clk), ('rst', rst), ('start', start_grn), ('done', grn_done),
               ('initial_state', grn_initial_state), ('final_state', grn_final_state),
               ('output_read_enable', grn_output_read_enable), ('output_valid', grn_output_valid),
               ('output_data', grn_output_data), ('output_available', grn_output_available),
               ('output_almost_empty', grn_output_almost_empty)]

        grn = self.create_grn_core(grn_content, bus_width)
        m.Instance(grn, grn.name, par, con)

        pe_output_available.assign(~fifo_out_empty)
        fifo = self.create_fifo()
        con = [('clk', clk), ('rst', rst), ('write_enable', fifo_out_write_enable),
               ('input_data', fifo_out_input_data),
               ('output_read_enable', pe_output_read_enable), ('output_valid', pe_output_valid),
               ('output_data', pe_output_data), ('empty', fifo_out_empty),
               ('almostempty', pe_output_almost_empty), ('almostfull', fifo_out_almost_full)]
        par = [('FIFO_WIDTH', bus_width), ('FIFO_DEPTH_BITS', ceil(log2(8 * qty_data_write)))]
        m.Instance(fifo, 'pe_naive_fifo_out', par, con)

        initialize_regs(m)
        self.cache[name] = m
        return m

    def create_fecth_data(self, input_data_width, output_data_width):
        name = 'fecth_data_%d_%d' % (input_data_width, output_data_width)
        if name in self.cache.keys():
            return self.cache[name]
        m = Module(name)

        clk = m.Input('clk')
        start = m.Input('start')
        rst = m.Input('rst')

        request_read = m.OutputReg('request_read')
        data_valid = m.Input('data_valid')
        read_data = m.Input('read_data', input_data_width)

        pop_data = m.Input('pop_data')
        available_pop = m.OutputReg('available_pop')
        data_out = m.Output('data_out', output_data_width)

        NUM = input_data_width // output_data_width

        fsm_read = m.Reg('fsm_read', 1)
        fsm_control = m.Reg('fsm_control', 1)
        data = m.Reg('data', input_data_width)
        buffer = m.Reg('buffer', input_data_width)
        count = m.Reg('count', NUM)
        has_buffer = m.Reg('has_buffer')
        buffer_read = m.Reg('buffer_read')
        en = m.Reg('en')

        m.EmbeddedCode('')
        data_out.assign(data[0:output_data_width])

        m.Always(Posedge(clk))(
            If(rst)(
                en(Int(0, 1, 2))
            ).Else(
                en(Mux(en, en, start))
            )
        )

        m.Always(Posedge(clk))(
            If(rst)(
                fsm_read(0),
                request_read(0),
                has_buffer(0)
            ).Else(
                request_read(0),
                Case(fsm_read)(
                    When(0)(
                        If(en & data_valid)(
                            buffer(read_data),
                            request_read(1),
                            has_buffer(1),
                            fsm_read(1)
                        )
                    ),
                    When(1)(
                        If(buffer_read)(
                            has_buffer(0),
                            fsm_read(0)
                        )
                    )
                )
            )
        )

        m.Always(Posedge(clk))(
            If(rst)(
                fsm_control(0),
                available_pop(0),
                count(0),
                buffer_read(0)
            ).Else(
                buffer_read(0),
                Case(fsm_control)(
                    When(0)(
                        If(has_buffer)(
                            data(buffer),
                            count(1),
                            buffer_read(1),
                            available_pop(1),
                            fsm_control(1)
                        )
                    ),
                    When(1)(
                        If(pop_data & ~count[NUM - 1])(
                            count(count << 1),
                            data(data[output_data_width:])
                        ),
                        If(pop_data & count[NUM - 1] & has_buffer)(
                            count(1),
                            data(buffer),
                            buffer_read(1)
                        ),
                        If(count[NUM - 1] & pop_data & ~has_buffer)(
                            count(count << 1),
                            data(data[output_data_width:]),
                            available_pop(0),
                            fsm_control(0)
                        )
                    )
                )
            )
        )

        initialize_regs(m)

        self.cache[name] = m
        return m
