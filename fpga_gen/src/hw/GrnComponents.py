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

    def create_fifo(self):
        m = Module('fifo')
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
        mem = m.Reg('mem', FIFO_WIDTH, Power(2, FIFO_DEPTH_BITS))

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
        bits = (len(nodes) * 2) + 32 + 32
        data_write_width = ceil(bits / 32) * 32
        qty_data = data_write_width / 32
        data_to_write = m.Reg('data_to_write', data_write_width)
        write_counter = m.Reg('write_counter', ceil(log2(data_write_width / 32)))
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
                            Cat(exec_state, actual_state_s1, transient_counter,
                                period_counter) if bits == data_write_width else Cat(
                                Int(0, (data_write_width - bits), 2), exec_state, actual_state_s1, transient_counter,
                                period_counter)),
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
               ('empty', fifo_empty), ('full', fifo_full)]
        par = [('FIFO_WIDTH', default_bus_width), ('FIFO_DEPTH_BITS', ceil(log2(3 * qty_data)))]
        m.Instance(fifo, fifo.name, par, con)

        # Here are the GRN equations to be used in the core execution are created
        m.EmbeddedCode("\n// Here are the GRN equations to be used in the core execution are created")
        nodes_assign_dict = {}
        nodes_assign_dict_counter = 0
        assign_string = ""
        for node in equations:
            equations[node] = equations[node].replace('||', ' || ')
            equations[node] = equations[node].replace('&&', ' && ')
            equations[node] = equations[node].replace('~', ' ~')
            for n in nodes:
                if not n in nodes_assign_dict:
                    nodes_assign_dict[n] = str(nodes_assign_dict_counter)
                    nodes_assign_dict_counter = nodes_assign_dict_counter + 1
                if n in equations[node]:
                    equations[node] = equations[node].replace(n, 'actual_state_s1[' + nodes_assign_dict[n] + ']')
            assign_string = assign_string + "assign next_state_s1[" + nodes_assign_dict[node] + "] = " + equations[
                node] + ";\n"

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
        start = m.Input('start')
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
        pe_init_conf = m.Reg('pe_init_conf', ceil(len(nodes) / default_bus_width) * default_bus_width)
        pe_end_conf = m.Reg('pe_end_conf', ceil(len(nodes) / default_bus_width) * default_bus_width)
        config_counter = m.Reg('config_counter', ceil(log2(ceil(len(nodes) / default_bus_width))) * 2 if ceil(
            log2(ceil(len(nodes) / default_bus_width))) > 0 else 1)
        config_forward = m.Wire('config_forward', default_bus_width)
        m.EmbeddedCode('//configuration wires and regs - end\n')
        # configuration wires and regs end -----------------------------------------------------------------------------

        # regs and wires to control the grn core
        m.EmbeddedCode("// regs and wires to control the grn core")
        start_grn = m.Reg('start_grn')
        grn_done = m.Wire('grn_done')
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
        if pe_init_conf.width > default_bus_width:
            config_forward.assign(pe_end_conf[0:pe_end_conf.width - default_bus_width])
        else:
            config_forward.assign(pe_end_conf)

        # PE configuration machine
        m.Always(Posedge(clk))(
            config_output_valid(0),
            config_output_done(config_input_done),
            If(rst)(
                is_configured(0),
                config_counter(0)
            ).Else(
                If(config_input_valid)(
                    config_counter.inc(),
                    If(config_counter == (ceil(len(nodes) / default_bus_width) * 2) - 1)(
                        is_configured(1)
                    ),
                    If(~is_configured)(
                        pe_end_conf(
                            Cat(config_input, pe_end_conf[pe_end_conf.width - default_bus_width:pe_end_conf.width])
                            if pe_end_conf.width > default_bus_width else config_input),
                        pe_init_conf(
                            Cat(config_forward, pe_init_conf[pe_init_conf.width - default_bus_width:pe_init_conf.width])
                            if pe_init_conf.width > default_bus_width else config_forward),
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
                        If(rd_wr_counter == int(qty_data - 1))(
                            fsm_pe_jo(fsm_pe_jo_look_pe)
                        ),
                        fifo_out_input_data(grn_output_data),
                        fifo_out_write_enable(1),
                        rd_wr_counter.inc(),
                        fsm_pe_jo(fsm_pe_jo_rd_grn)
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
                        If(rd_wr_counter == int(qty_data - 1))(
                            fsm_pe_jo(fsm_pe_jo_look_grn)
                        ),
                        fifo_out_input_data(grn_output_data),
                        fifo_out_write_enable(1),
                        rd_wr_counter.inc(),
                        fsm_pe_jo(fsm_pe_jo_rd_pe)
                    ),
                )
            )
        )

        # execution sector - end ---------------------------------------------------------------------------------------

        # Grn core instantiation
        m.EmbeddedCode("// Grn core instantiation")
        grn_initial_state.assign(pe_init_conf[0:grn_initial_state.width])
        grn_final_state.assign(pe_init_conf[0:grn_final_state.width])

        con = [('clk', clk), ('rst', rst), ('start', start_grn), ('initial_state', grn_initial_state),
               ('final_state', grn_final_state), ('output_read_enable', grn_output_read_enable),
               ('output_valid', grn_output_valid), ('output_data', grn_output_data),
               ('output_available', grn_output_available)]
        par = []
        grn = self.create_grn_naive_core(grn_content)
        m.Instance(grn, grn.name, par, con)

        fifo = self.create_fifo()
        con = [('clk', clk), ('rst', rst), ('write_enable', fifo_out_write_enable), ('input_data', fifo_out_input_data),
               ('output_read_enable', pe_output_read_enable), ('output_valid', pe_output_valid),
               ('output_data', pe_output_data), ('empty', fifo_out_empty), ('full', fifo_out_full)]
        par = [('FIFO_WIDTH', default_bus_width), ('FIFO_DEPTH_BITS', ceil(log2(3 * qty_data)))]
        m.Instance(fifo, fifo.name, par, con)

        initialize_regs(m)
        self.cache[name] = m
        return m


grn_content = Grn2dot("../../../../grn_benchmarks/Benchmark_5.txt")
grn = GrnComponents()
grn.create_grn_naive_pe(grn_content).to_verilog("../grn_naive.v")
