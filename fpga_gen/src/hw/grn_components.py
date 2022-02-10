from veriloggen import *
from math import log2, ceil
from grn2dot.grn2dot import Grn2dot

from src.hw.utils import initialize_regs


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
        FIFO_ALMOSTEMPTY_THRESHOLD = m.Parameter('FIFO_ALMOSTEMPTY_THRESHOLD', 2)

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
                empty(Int(1, 1, 2)),
                almostempty(Int(1, 1, 2)),
                full(Int(0, 1, 2)),
                almostfull(Int(0, 1, 2)),
                read_pointer(0),
                write_pointer(0),
                data_count(0)
            ).Else(
                Case(Cat(write_enable, output_read_enable))(
                    When(Int(3, 2, 2))(
                        read_pointer(read_pointer + 1),
                        write_pointer(write_pointer + 1),
                    ),
                    When(Int(2, 2, 2))(
                        If(~full)(
                            write_pointer(write_pointer + 1),
                            data_count(data_count + 1),
                            empty(Int(0, 1, 2)),
                            If(data_count == (FIFO_ALMOSTEMPTY_THRESHOLD - 1))(
                                almostempty(Int(0, 1, 2))
                            ),
                            If(data_count == Power(2, FIFO_DEPTH_BITS) - 1)(
                                full(Int(1, 1, 2))
                            ),
                            If(data_count == (FIFO_ALMOSTFULL_THRESHOLD - 1))(
                                almostfull(Int(1, 1, 2))
                            )
                        )

                    ),
                    When(Int(1, 2, 2))(
                        If(~empty)(
                            read_pointer(read_pointer + 1),
                            data_count(data_count - 1),
                            full(Int(0, 1, 2)),
                            If(data_count == FIFO_ALMOSTFULL_THRESHOLD)(
                                almostfull(Int(0, 1, 2))
                            ),
                            If(data_count == 1)(
                                empty(Int(1, 1, 2))
                            ),
                            If(data_count == FIFO_ALMOSTEMPTY_THRESHOLD)(
                                almostempty(Int(1, 1, 2))
                            )

                        )
                    ),
                )
            )
        )
        m.Always(Posedge(clk))(
            If(rst)(
                output_valid(Int(0, 1, 2))
            ).Else(
                output_valid(Int(0, 1, 2)),
                If(write_enable == Int(1, 1, 2))(
                    mem[write_pointer](input_data)
                ),
                If(output_read_enable == Int(1, 1, 2))(
                    output_data(mem[read_pointer]),
                    output_valid(Int(1, 1, 2))
                )
            )
        )
        self.cache[name] = m
        return m

    def create_grn_naive_core(self, grn_content, default_bus_width=32):
        nodes = grn_content.get_nodes_vector()
        equations = grn_content.get_equations_dict()

        name = 'grn_naive_core'
        if name in self.cache.keys():
            return self.cache[name]
        m = Module(name)

        # Basic Inputs - Begin ----------------------------------------------------------------------------------------
        clk = m.Input('clk')
        rst = m.Input('rst')
        start = m.Input('start')
        # Basic Input - End -------------------------------------------------------------------------------------------

        # Configuration inputs - Begin --------------------------------------------------------------------------------
        # The grn core naive configuration consists in two buses with the initial state and the final state to be
        # searched
        initial_state = m.Input('initial_state', len(nodes))
        final_state = m.Input('final_state', len(nodes))
        # Configuration Inputs - End ----------------------------------------------------------------------------------

        # Output data Control interface - Begin -----------------------------------------------------------------------
        # The naive kernel output data is the FIFO data output that contains all the data found
        output_read_enable = m.Input('output_read_enable')
        output_valid = m.Output('output_valid')
        output_data = m.Output('output_data', default_bus_width)
        output_available = m.Output('output_available')
        # Output data Control interface - End -------------------------------------------------------------------------
        m.EmbeddedCode(
            "// The grn core naive configuration consists in two buses with the initial state and the final ")
        m.EmbeddedCode("// state to be searched.")
        m.EmbeddedCode("//The naive kernel output data is the FIFO data output that contains all the data found.\n")

        # Fifo wires and regs
        m.EmbeddedCode("//Fifo wires and regs")
        fifo_write_enable = m.Reg('fifo_write_enable')
        fifo_input_data = m.Reg('fifo_input_data', default_bus_width)
        fifo_full = m.Wire('fifo_full')
        fifo_empty = m.Wire('fifo_empty')

        # Wires and regs to be used in control and execution of the grn naive
        m.EmbeddedCode("\n// Wires and regs to be used in control and execution of the grn naive")
        actual_state_s1 = m.Reg('actual_state_s1', len(nodes))
        next_state_s1 = m.Wire('next_state_s1', len(nodes))
        actual_state_s2 = m.Reg('actual_state_s2', len(nodes))
        next_state_s2 = m.Wire('next_state_s2', len(nodes))
        exec_state = m.Reg('exec_state', len(nodes))
        flag_pulse = m.Reg('flag_pulse')
        flag_first_it = m.Reg('flag_first_it')
        transient_counter = m.Reg('transient_counter', 32)
        period_counter = m.Reg('period_counter', 32)
        bits = (ceil(len(nodes) / 32) * 32 * 2) + 32 + 32
        add_bit_states = ceil(len(nodes) / 32) * 32 - initial_state.width
        data_write_width = bits
        qty_data = data_write_width // 32
        data_to_write = m.Reg('data_to_write', data_write_width)
        write_counter = m.Reg('write_counter', ceil(log2(qty_data)))
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
                                Int(0, (add_bit_states), 2),
                                exec_state,
                                Int(0, (add_bit_states), 2),
                                actual_state_s1,
                                transient_counter,
                                period_counter
                            )
                            if add_bit_states > 0
                            else
                            Cat(
                                exec_state,
                                actual_state_s1,
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
                        If(~fifo_full)(
                            write_counter.inc(),
                            fifo_write_enable(1),
                            data_to_write(Cat(Int(0, 32, 2), data_to_write[32:data_to_write.width])),
                            fifo_input_data(data_to_write[0:default_bus_width]),
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
               ('empty', fifo_empty), ('almostfull', fifo_full)]
        par = [('FIFO_WIDTH', default_bus_width), ('FIFO_DEPTH_BITS', ceil(log2(3 * qty_data)))]
        m.Instance(fifo, 'grn_naive_core_output_fifo', par, con)

        # Here are the GRN equations to be used in the core execution are created
        m.EmbeddedCode("\n// Here are the GRN equations to be used in the core execution are created")
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
        m.EmbeddedCode("// For S2 pointer")
        assign_string = assign_string.replace("actual_state_s1", "actual_state_s2")
        assign_string = assign_string.replace("next_state_s1", "next_state_s2")
        m.EmbeddedCode(assign_string)

        initialize_regs(m)
        self.cache[name] = m
        return m

    def create_grn_naive_pe(self, grn_content, default_bus_width=32):
        nodes = grn_content.get_nodes_vector()

        name = 'grn_naive_pe'
        if name in self.cache.keys():
            return self.cache[name]
        m = Module(name)

        # Basic Inputs - Begin ----------------------------------------------------------------------------------------
        clk = m.Input('clk')
        rst = m.Input('rst')
        # Basic Input - End -------------------------------------------------------------------------------------------

        # PE configuration signals
        config_input_done = m.Input('config_input_done')
        config_input_valid = m.Input('config_input_valid')
        config_input = m.Input('config_input', default_bus_width)
        config_output_done = m.OutputReg('config_output_done')
        config_output_valid = m.OutputReg('config_output_valid')
        config_output = m.OutputReg('config_output', default_bus_width)
        # --------------------------------------------------------------------------------------------------------------

        # bypass data Control interface - Begin -----------------------------------------------------------------------
        # The naive kernel output data is the FIFO data output that contains all the data found
        pe_bypass_read_enable = m.OutputReg('pe_bypass_read_enable')
        pe_bypass_valid = m.Input('pe_bypass_valid')
        pe_bypass_data = m.Input('pe_bypass_data', default_bus_width)
        pe_bypass_available = m.Input('pe_bypass_available')
        # Output data Control interface - End -------------------------------------------------------------------------

        # Output data Control interface - Begin -----------------------------------------------------------------------
        # The naive kernel output data is the FIFO data output that contains all the data found
        pe_output_read_enable = m.Input('pe_output_read_enable')
        pe_output_valid = m.Output('pe_output_valid')
        pe_output_data = m.Output('pe_output_data', default_bus_width)
        pe_output_available = m.Output('pe_output_available')
        # Output data Control interface - End -------------------------------------------------------------------------

        # configuration wires and regs begin ---------------------------------------------------------------------------
        m.EmbeddedCode('\n//configuration wires and regs - begin')
        is_configured = m.Reg('is_configured')
        pe_init_conf = m.Wire('pe_init_conf', ceil(len(nodes) / default_bus_width) * default_bus_width)
        pe_end_conf = m.Wire('pe_end_conf', ceil(len(nodes) / default_bus_width) * default_bus_width)
        pe_data_conf = m.Reg('pe_data_conf', pe_init_conf.width + pe_end_conf.width)
        pe_init_conf.assign(pe_data_conf[0:pe_init_conf.width])
        pe_end_conf.assign(pe_data_conf[pe_init_conf.width:pe_init_conf.width + pe_end_conf.width])
        config_counter = m.Reg('config_counter', int(ceil(log2(((pe_init_conf.width + pe_end_conf.width) // 32)))))
        # config_forward = m.Wire('config_forward', default_bus_width)
        m.EmbeddedCode('//configuration wires and regs - end\n')
        # configuration wires and regs end -----------------------------------------------------------------------------

        # regs and wires to control the grn core
        m.EmbeddedCode("// regs and wires to control the grn core")
        start_grn = m.Reg('start_grn')
        grn_initial_state = m.Wire('grn_initial_state', len(nodes))
        grn_final_state = m.Wire('grn_final_state', len(nodes))
        grn_output_read_enable = m.Reg('grn_output_read_enable')
        grn_output_valid = m.Wire('grn_output_valid')
        grn_output_data = m.Wire('grn_output_data', default_bus_width)
        grn_output_available = m.Wire('grn_output_available')
        fsm_pe_jo = m.Reg('fsm_pe_jo', 3)
        fsm_pe_jo_look_grn = m.Localparam('fsm_pe_jo_look_grn', 0)
        fsm_pe_jo_rd_grn = m.Localparam('fsm_pe_jo_rd_grn', 1)
        fsm_pe_jo_wr_grn = m.Localparam('fsm_pe_jo_wr_grn', 2)
        fsm_pe_jo_look_pe = m.Localparam('fsm_pe_jo_look_pe', 3)
        fsm_pe_jo_rd_pe = m.Localparam('fsm_pe_jo_rd_pe', 4)
        fsm_pe_jo_wr_pe = m.Localparam('fsm_pe_jo_wr_pe', 5)

        bits = (len(nodes) * 2) + 32 + 32
        data_write_width = ceil(bits / 32) * 32
        qty_data = data_write_width / 32
        rd_wr_counter = m.Reg('rd_wr_counter', ceil(log2(data_write_width / 32)))

        # Fifo out wires and regs
        m.EmbeddedCode("\n//Fifo out wires and regs")

        fifo_out_write_enable = m.Reg('fifo_out_write_enable')
        fifo_out_input_data = m.Reg('fifo_out_input_data', default_bus_width)
        fifo_out_empty = m.Wire('fifo_out_empty')
        fifo_out_full = m.Wire('fifo_out_full')

        # configuration sector -----------------------------------------------------------------------------------------
        m.EmbeddedCode('\n//configuration sector - begin')
        # if pe_init_conf.width > default_bus_width:
        #    config_forward.assign(pe_end_conf[0:pe_end_conf.width - default_bus_width])
        # else:
        #    config_forward.assign(pe_end_conf)

        # PE configuration machine
        m.Always(Posedge(clk))(
            config_output_valid(0),
            config_output_done(config_input_done),
            If(rst)(
                is_configured(0),
                config_counter(0)
            ).Else(
                If(config_input_valid)(
                    config_counter.inc(),  # ((pe_init_conf.width + pe_end_conf.width) // 32)
                    If(config_counter == ((pe_init_conf.width + pe_end_conf.width) // 32) - 1)(
                        is_configured(1)
                    ),
                    If(~is_configured)(
                        pe_data_conf(Cat(config_input, pe_data_conf[default_bus_width:pe_data_conf.width]))
                    ).Else(
                        config_output_valid(config_input_valid),
                        config_output(config_input),
                    )
                )
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
                fifo_out_write_enable(0),
                pe_bypass_read_enable(0),
                fsm_pe_jo(fsm_pe_jo_look_grn),
            ).Elif(is_configured)(
                start_grn(1),
                grn_output_read_enable(0),
                fifo_out_write_enable(0),
                pe_bypass_read_enable(0),
                Case(fsm_pe_jo)(
                    When(fsm_pe_jo_look_grn)(
                        fsm_pe_jo(fsm_pe_jo_look_pe),
                        If(grn_output_available)(
                            rd_wr_counter(0),
                            fsm_pe_jo(fsm_pe_jo_rd_grn),
                        )
                    ),
                    When(fsm_pe_jo_rd_grn)(
                        If(Uand(Cat(grn_output_available, ~fifo_out_full)))(
                            grn_output_read_enable(1),
                            fsm_pe_jo(fsm_pe_jo_wr_grn)
                        )
                    ),
                    When(fsm_pe_jo_wr_grn)(
                        If(grn_output_valid)(
                            fsm_pe_jo(fsm_pe_jo_rd_grn),
                            If(rd_wr_counter == int(qty_data - 1))(
                                fsm_pe_jo(fsm_pe_jo_look_pe)
                            ),
                            fifo_out_input_data(grn_output_data),
                            rd_wr_counter.inc(),
                            fifo_out_write_enable(1),
                        ),
                    ),
                    When(fsm_pe_jo_look_pe)(
                        fsm_pe_jo(fsm_pe_jo_look_grn),
                        If(pe_bypass_available)(
                            rd_wr_counter(0),
                            fsm_pe_jo(fsm_pe_jo_rd_pe),
                        )
                    ),
                    When(fsm_pe_jo_rd_pe)(
                        If(Uand(Cat(pe_bypass_available, ~fifo_out_full)))(
                            pe_bypass_read_enable(1),
                            fsm_pe_jo(fsm_pe_jo_wr_pe)
                        )
                    ),
                    When(fsm_pe_jo_wr_pe)(
                        If(pe_bypass_valid)(
                            fsm_pe_jo(fsm_pe_jo_rd_pe),
                            If(rd_wr_counter == int(qty_data - 1))(
                                fsm_pe_jo(fsm_pe_jo_look_grn)
                            ),
                            fifo_out_input_data(pe_bypass_data),
                            fifo_out_write_enable(1),
                            rd_wr_counter.inc(),
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

        con = [('clk', clk), ('rst', rst), ('start', start_grn), ('initial_state', grn_initial_state),
               ('final_state', grn_final_state), ('output_read_enable', grn_output_read_enable),
               ('output_valid', grn_output_valid), ('output_data', grn_output_data),
               ('output_available', grn_output_available)]
        par = []
        grn = self.create_grn_naive_core(grn_content)
        m.Instance(grn, 'grn_naive_core', par, con)

        pe_output_available.assign(~fifo_out_empty)

        fifo = self.create_fifo()
        con = [('clk', clk), ('rst', rst), ('write_enable', fifo_out_write_enable), ('input_data', fifo_out_input_data),
               ('output_read_enable', pe_output_read_enable), ('output_valid', pe_output_valid),
               ('output_data', pe_output_data), ('empty', fifo_out_empty), ('almostfull', fifo_out_full)]
        par = [('FIFO_WIDTH', default_bus_width), ('FIFO_DEPTH_BITS', ceil(log2(3 * qty_data)))]
        m.Instance(fifo, 'pe_naive_fifo_out', par, con)

        initialize_regs(m)
        self.cache[name] = m
        return m

    def create_grn_mem_core(self, grn_content, default_bus_width=32):
        grn_mem_spec = grn_content.get_grn_mem_specifications()

        name = 'grn_mem_core'
        if name in self.cache.keys():
            return self.cache[name]
        m = Module(name)

        # Basic Inputs - Begin ----------------------------------------------------------------------------------------
        clk = m.Input('clk')
        rst = m.Input('rst')
        start = m.Input('start')
        # Basic Input - End -------------------------------------------------------------------------------------------

        # Configuration inputs - Begin --------------------------------------------------------------------------------
        # The grn mem core configuration consists in two buses with the initial state and the final state to be
        # searched and the content of a 1 bit memory for each equation
        initial_state = m.Input('initial_state', grn_content.get_num_nodes())
        final_state = m.Input('final_state', grn_content.get_num_nodes())
        eq_bits = 0
        for g in grn_mem_spec:
            eq_bits = eq_bits + int(pow(2, len(g[2])))
        equations_config = m.Input('equations_config', eq_bits)
        # Configuration Inputs - End ----------------------------------------------------------------------------------

        # Output data Control interface - Begin -----------------------------------------------------------------------
        # The mem kernel output data is the FIFO data output that contains all the data found
        output_read_enable = m.Input('output_read_enable')
        output_valid = m.Output('output_valid')
        output_data = m.Output('output_data', default_bus_width)
        output_available = m.Output('output_available')
        # Output data Control interface - End -------------------------------------------------------------------------
        m.EmbeddedCode(
            "// The grn mem core configuration consists in two buses with the initial state and the final state to be")
        m.EmbeddedCode("// searched and the content of a 1 bit memory for each equation.")
        m.EmbeddedCode("// The mem kernel output data is the FIFO data output that contains all the data found.")

        # Fifo wires and regs
        m.EmbeddedCode("\n//Fifo wires and regs")
        fifo_write_enable = m.Reg('fifo_write_enable')
        fifo_input_data = m.Reg('fifo_input_data', default_bus_width)
        fifo_full = m.Wire('fifo_full')
        fifo_empty = m.Wire('fifo_empty')

        # Wires and regs to be used in control and execution of the grn mem
        m.EmbeddedCode("\n// Wires and regs to be used in control and execution of the grn mem")
        actual_state_s1 = m.Reg('actual_state_s1', grn_content.get_num_nodes())
        next_state_s1 = m.Wire('next_state_s1', grn_content.get_num_nodes())
        actual_state_s2 = m.Reg('actual_state_s2', grn_content.get_num_nodes())
        next_state_s2 = m.Wire('next_state_s2', grn_content.get_num_nodes())
        exec_state = m.Reg('exec_state', grn_content.get_num_nodes())
        flag_pulse = m.Reg('flag_pulse')
        flag_first_it = m.Reg('flag_first_it')
        transient_counter = m.Reg('transient_counter', 32)
        period_counter = m.Reg('period_counter', 32)
        bits = (ceil(grn_content.get_num_nodes() / 32) * 32 * 2) + 32 + 32
        add_bit_states = ceil(grn_content.get_num_nodes() / 32) * 32 - initial_state.width
        data_write_width = bits
        qty_data = data_write_width // 32
        data_to_write = m.Reg('data_to_write', data_write_width)
        write_counter = m.Reg('write_counter', ceil(log2(data_write_width / 32)))

        # Here are the GRN eq_wires to be used in the core execution are created
        m.EmbeddedCode("\n// Here are the GRN eq_wires to be used in the core execution are created")

        eq_wires = []
        for node in grn_content.get_nodes_vector():
            for g in grn_mem_spec:
                if g[0] == node:
                    eq_wires.append(m.Wire("eq_" + node.replace(' ', ''), pow(2, len(g[2]))))
                    break
        # assign each bus in the correct place of configuration memory
        last_idx = 0
        for eq in eq_wires:
            eq.assign(equations_config[last_idx:last_idx + eq.width])
            last_idx = last_idx + eq.width

        # State machine to control the grn algorithm execution
        m.EmbeddedCode("\n// State machine to control the grn algorithm execution")
        fsm_mem = m.Reg('fsm_mem', 3)
        fsm_mem_set = m.Localparam('fsm_mem_set', 0)
        fsm_mem_init = m.Localparam('fsm_mem_init', 1)
        fsm_mem_transient_finder = m.Localparam('fsm_mem_transient_finder', 2)
        fsm_mem_period_finder = m.Localparam('fsm_mem_period_finder', 3)
        fsm_mem_prepare_to_write = m.Localparam('fsm_mem_prepare_to_write', 4)
        fsm_mem_write = m.Localparam('fsm_mem_write', 5)
        fsm_mem_verify = m.Localparam('fsm_mem_verify', 6)
        fsm_mem_done = m.Localparam('fsm_mem_done', 7)

        m.Always(Posedge(clk))(
            If(rst)(
                fifo_write_enable(0),
                fsm_mem(fsm_mem_set),
            ).Elif(start)(
                fifo_write_enable(0),
                Case(fsm_mem)(
                    When(fsm_mem_set)(
                        exec_state(initial_state),
                        fsm_mem(fsm_mem_init),
                    ),
                    When(fsm_mem_init)(
                        actual_state_s1(exec_state),
                        actual_state_s2(exec_state),
                        transient_counter(0),
                        period_counter(0),
                        flag_first_it(1),
                        flag_pulse(0),
                        fsm_mem(fsm_mem_transient_finder),
                    ),
                    When(fsm_mem_transient_finder)(
                        flag_first_it(0),
                        If(AndList((actual_state_s1 == actual_state_s2), ~flag_first_it, ~flag_pulse))(
                            flag_first_it(1),
                            fsm_mem(fsm_mem_period_finder),
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
                    When(fsm_mem_period_finder)(
                        flag_first_it(0),
                        If(AndList((actual_state_s1 == actual_state_s2), ~flag_first_it))(
                            period_counter.dec(),
                            fsm_mem(fsm_mem_prepare_to_write)
                        ).Else(
                            actual_state_s2(next_state_s2),
                            period_counter.inc(),
                        ),
                    ),
                    When(fsm_mem_prepare_to_write)(
                        data_to_write(
                            Cat(
                                Int(0, (add_bit_states), 2),
                                exec_state,
                                Int(0, (add_bit_states), 2),
                                actual_state_s1,
                                transient_counter,
                                period_counter
                            )
                            if add_bit_states > 0
                            else
                            Cat(
                                exec_state,
                                actual_state_s1,
                                transient_counter,
                                period_counter
                            )
                        ),
                        fsm_mem(fsm_mem_write),
                        write_counter(0),
                    ),
                    When(fsm_mem_write)(
                        If(write_counter == int(qty_data - 1))(
                            fsm_mem(fsm_mem_verify)
                        ),
                        If(~fifo_full)(
                            write_counter.inc(),
                            fifo_write_enable(1),
                            data_to_write(Cat(Int(0, 32, 2), data_to_write[32:data_to_write.width])),
                            fifo_input_data(data_to_write[0:default_bus_width]),
                        )
                    ),
                    When(fsm_mem_verify)(
                        If(exec_state == final_state)(
                            fsm_mem(fsm_mem_done),
                        ).Else(
                            exec_state.inc(),
                            fsm_mem(fsm_mem_init)
                        )
                    ),
                    When(fsm_mem_done)(
                    )
                )
            )
        )

        # Assigns to define each bit is used on each equation memory
        m.EmbeddedCode("\n// Assigns to define each bit is used on each equation memory")
        for i in range(next_state_s1.width):
            assign_string = 'assign ' + next_state_s1.name + '[' + str(i) + '] = ' + eq_wires[i].name + '[{'
            for idx in grn_mem_spec[i][2]:
                assign_string = assign_string + 'actual_state_s1[' + str(idx) + '],'
            assign_string = assign_string[0:(len(assign_string) - 1)]
            assign_string = assign_string + '}];'
            m.EmbeddedCode(assign_string)
            m.EmbeddedCode(assign_string.replace('_s1', '_s2'))

        # Output data fifo instantiation
        m.EmbeddedCode("\n//Output data fifo instantiation")

        output_available.assign(~fifo_empty)

        fifo = self.create_fifo()
        con = [('clk', clk), ('rst', rst), ('write_enable', fifo_write_enable), ('input_data', fifo_input_data),
               ('output_read_enable', output_read_enable), ('output_valid', output_valid), ('output_data', output_data),
               ('empty', fifo_empty), ('almostfull', fifo_full)]
        par = [('FIFO_WIDTH', default_bus_width), ('FIFO_DEPTH_BITS', ceil(log2(3 * qty_data)))]
        m.Instance(fifo, 'grn_mem_core_output_fifo', par, con)

        initialize_regs(m)
        self.cache[name] = m
        return m

    def create_grn_mem_pe(self, grn_content: Grn2dot, default_bus_width=32):

        name = 'grn_mem_pe'
        if name in self.cache.keys():
            return self.cache[name]
        m = Module(name)

        # Basic Inputs - Begin ----------------------------------------------------------------------------------------
        clk = m.Input('clk')
        rst = m.Input('rst')
        # Basic Input - End -------------------------------------------------------------------------------------------

        # PE configuration signals
        config_input_done = m.Input('config_input_done')
        config_input_valid = m.Input('config_input_valid')
        config_input = m.Input('config_input', default_bus_width)
        config_output_done = m.OutputReg('config_output_done')
        config_output_valid = m.OutputReg('config_output_valid')
        config_output = m.OutputReg('config_output', default_bus_width)
        # --------------------------------------------------------------------------------------------------------------

        # bypass data Control interface - Begin -----------------------------------------------------------------------
        # The mem kernel output data is the FIFO data output that contains all the data found
        pe_bypass_read_enable = m.OutputReg('pe_bypass_read_enable')
        pe_bypass_valid = m.Input('pe_bypass_valid')
        pe_bypass_data = m.Input('pe_bypass_data', default_bus_width)
        pe_bypass_available = m.Input('pe_bypass_available')
        # Output data Control interface - End -------------------------------------------------------------------------

        # Output data Control interface - Begin -----------------------------------------------------------------------
        # The mem kernel output data is the FIFO data output that contains all the data found
        pe_output_read_enable = m.Input('pe_output_read_enable')
        pe_output_valid = m.Output('pe_output_valid')
        pe_output_data = m.Output('pe_output_data', default_bus_width)
        pe_output_available = m.Output('pe_output_available')
        # Output data Control interface - End -------------------------------------------------------------------------

        # configuration wires and regs begin ---------------------------------------------------------------------------
        m.EmbeddedCode('\n//configuration wires and regs - begin')
        is_configured = m.Reg('is_configured')
        grn_mem_spec = grn_content.get_grn_mem_specifications()
        eq_bits = 0
        for g in grn_mem_spec:
            eq_bits = eq_bits + int(pow(2, len(g[2])))
        pe_init_conf = m.Wire('pe_init_conf', ceil(grn_content.get_num_nodes() / default_bus_width) * default_bus_width)
        pe_end_conf = m.Wire('pe_end_conf', ceil(grn_content.get_num_nodes() / default_bus_width) * default_bus_width)
        pe_data_conf = m.Reg('pe_data_conf', pe_init_conf.width + pe_end_conf.width)
        config_counter = m.Reg('config_counter', ceil(log2((pe_init_conf.width + pe_end_conf.width) / 32)))
        pe_eq_conf = m.Reg('pe_eq_conf', ceil(eq_bits / default_bus_width) * default_bus_width)
        config_eq_counter = m.Reg('config_eq_counter', ceil(log2(pe_eq_conf.width / 32)))
        pe_init_conf.assign(pe_data_conf[0:pe_init_conf.width])
        pe_end_conf.assign(pe_data_conf[pe_init_conf.width:pe_init_conf.width * 2])

        m.EmbeddedCode('//configuration wires and regs - end\n')
        # configuration wires and regs end -----------------------------------------------------------------------------

        # regs and wires to control the grn core
        m.EmbeddedCode("// regs and wires to control the grn core")
        start_grn = m.Reg('start_grn')
        grn_initial_state = m.Wire('grn_initial_state', grn_content.get_num_nodes())
        grn_final_state = m.Wire('grn_final_state', grn_content.get_num_nodes())
        grn_equations_config = m.Wire('grn_equations_config', eq_bits)
        grn_output_read_enable = m.Reg('grn_output_read_enable')
        grn_output_valid = m.Wire('grn_output_valid')
        grn_output_data = m.Wire('grn_output_data', default_bus_width)
        grn_output_available = m.Wire('grn_output_available')
        fsm_pe_jo = m.Reg('fsm_pe_jo', 3)
        fsm_pe_jo_look_grn = m.Localparam('fsm_pe_jo_look_grn', 0)
        fsm_pe_jo_rd_grn = m.Localparam('fsm_pe_jo_rd_grn', 1)
        fsm_pe_jo_wr_grn = m.Localparam('fsm_pe_jo_wr_grn', 2)
        fsm_pe_jo_look_pe = m.Localparam('fsm_pe_jo_look_pe', 3)
        fsm_pe_jo_rd_pe = m.Localparam('fsm_pe_jo_rd_pe', 4)
        fsm_pe_jo_wr_pe = m.Localparam('fsm_pe_jo_wr_pe', 5)

        wr_bits = (ceil(grn_content.get_num_nodes() / 32) * 32 * 2) + 32 + 32
        data_write_width = wr_bits
        qty_data = data_write_width // 32
        rd_wr_counter = m.Reg('rd_wr_counter', ceil(log2(qty_data)))

        # Fifo out wires and regs
        m.EmbeddedCode("\n//Fifo out wires and regs")

        fifo_out_write_enable = m.Reg('fifo_out_write_enable')
        fifo_out_input_data = m.Reg('fifo_out_input_data', default_bus_width)
        fifo_out_empty = m.Wire('fifo_out_empty')
        fifo_out_full = m.Wire('fifo_out_full')

        # configuration sector -----------------------------------------------------------------------------------------
        m.EmbeddedCode('\n//configuration sector - begin')
        fsm_config = m.Reg('fsm_config', 2)
        fsm_config_mem_config = m.Localparam('fsm_config_mem_config', 0)
        fsm_config_other = m.Localparam('fsm_config_other', 1)
        fsm_config_done = m.Localparam('fsm_config_done', 2)

        # PE configuration machine
        m.Always(Posedge(clk))(
            config_output_valid(0),
            config_output(config_input),
            config_output_done(config_input_done),
            If(rst)(
                is_configured(0),
                config_counter(0),
                config_eq_counter(0),
                fsm_config(fsm_config_mem_config),
            ).Else(
                Case(fsm_config)(
                    When(fsm_config_mem_config)(
                        If(config_input_valid)(
                            config_eq_counter.inc(),
                            If(config_eq_counter == (pe_eq_conf.width // 32) - 1)(
                                fsm_config(fsm_config_other),
                            ),
                            pe_eq_conf(Cat(config_input, pe_eq_conf[default_bus_width:pe_eq_conf.width])),
                            config_output_valid(config_input_valid),
                        ),
                    ),
                    When(fsm_config_other)(
                        If(config_input_valid)(
                            config_counter.inc(),
                            If(config_counter == ((pe_init_conf.width + pe_end_conf.width) // 32) - 1)(
                                is_configured(1),
                                fsm_config(fsm_config_done),
                            ),
                            pe_data_conf(Cat(config_input, pe_data_conf[default_bus_width:pe_data_conf.width]))
                        ),
                    ),
                    When(fsm_config_done)(
                        config_output_valid(config_input_valid),
                    ),
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
                fifo_out_write_enable(0),
                pe_bypass_read_enable(0),
                fsm_pe_jo(fsm_pe_jo_look_grn),
            ).Elif(is_configured)(
                start_grn(1),
                grn_output_read_enable(0),
                fifo_out_write_enable(0),
                pe_bypass_read_enable(0),
                Case(fsm_pe_jo)(
                    When(fsm_pe_jo_look_grn)(
                        fsm_pe_jo(fsm_pe_jo_look_pe),
                        If(grn_output_available)(
                            rd_wr_counter(0),
                            fsm_pe_jo(fsm_pe_jo_rd_grn),
                        )
                    ),
                    When(fsm_pe_jo_rd_grn)(
                        If(Uand(Cat(grn_output_available, ~fifo_out_full)))(
                            grn_output_read_enable(1),
                            fsm_pe_jo(fsm_pe_jo_wr_grn)
                        )
                    ),
                    When(fsm_pe_jo_wr_grn)(
                        If(grn_output_valid)(
                            fsm_pe_jo(fsm_pe_jo_rd_grn),
                            If(rd_wr_counter == int(qty_data - 1))(
                                fsm_pe_jo(fsm_pe_jo_look_pe)
                            ),
                            fifo_out_input_data(grn_output_data),
                            rd_wr_counter.inc(),
                            fifo_out_write_enable(1),
                        ),
                    ),
                    When(fsm_pe_jo_look_pe)(
                        fsm_pe_jo(fsm_pe_jo_look_grn),
                        If(pe_bypass_available)(
                            rd_wr_counter(0),
                            fsm_pe_jo(fsm_pe_jo_rd_pe),
                        )
                    ),
                    When(fsm_pe_jo_rd_pe)(
                        If(Uand(Cat(pe_bypass_available, ~fifo_out_full)))(
                            pe_bypass_read_enable(1),
                            fsm_pe_jo(fsm_pe_jo_wr_pe)
                        )
                    ),
                    When(fsm_pe_jo_wr_pe)(
                        If(pe_bypass_valid)(
                            fsm_pe_jo(fsm_pe_jo_rd_pe),
                            If(rd_wr_counter == int(qty_data - 1))(
                                fsm_pe_jo(fsm_pe_jo_look_grn)
                            ),
                            fifo_out_input_data(pe_bypass_data),
                            fifo_out_write_enable(1),
                            rd_wr_counter.inc(),
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
        grn_equations_config.assign(pe_eq_conf[0:grn_equations_config.width])

        con = [('clk', clk), ('rst', rst), ('start', start_grn), ('initial_state', grn_initial_state),
               ('final_state', grn_final_state), ('equations_config', grn_equations_config),
               ('output_read_enable', grn_output_read_enable), ('output_valid', grn_output_valid),
               ('output_data', grn_output_data), ('output_available', grn_output_available)]
        par = []
        grn = self.create_grn_mem_core(grn_content)
        m.Instance(grn, 'grn_mem_core', par, con)

        pe_output_available.assign(~fifo_out_empty)

        fifo = self.create_fifo()
        con = [('clk', clk), ('rst', rst), ('write_enable', fifo_out_write_enable), ('input_data', fifo_out_input_data),
               ('output_read_enable', pe_output_read_enable), ('output_valid', pe_output_valid),
               ('output_data', pe_output_data), ('empty', fifo_out_empty), ('almostfull', fifo_out_full)]
        par = [('FIFO_WIDTH', default_bus_width), ('FIFO_DEPTH_BITS', ceil(log2(3 * qty_data)))]
        m.Instance(fifo, 'pe_mem_fifo_out', par, con)

        initialize_regs(m)
        self.cache[name] = m
        return m

grn_content = Grn2dot("../../../../grn_benchmarks/Benchmark_70.txt")
grn = GrnComponents()
grn.create_grn_mem_pe(grn_content).to_verilog("../test_benches/grn_mem_pe_70.v")
# grn.create_grn_mem_pe(grn_content).to_verilog("../test_benches/grn_mem_pe_70.v")
# grn.create_grn_mem_pe(grn_content).to_verilog("../test_benches/grn_mem_pe.v")
