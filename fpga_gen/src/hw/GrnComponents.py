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
        output_data_read_enable = m.Input('output_data_read_enable')
        output_data_valid = m.OutputReg('output_data_valid')
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
                Case(Cat(write_enable, output_data_read_enable))(
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
                output_data_valid(Int(0, 1, 2))
            ).Else(
                output_data_valid(Int(0, 1, 2)),
                If(write_enable == Int(1, 1, 2))(
                    mem[write_pointer](input_data)
                ),
                If(output_data_read_enable == Int(1, 1, 2))(
                    output_data(mem[read_pointer]),
                    output_data_valid(Int(1, 1, 2))
                )
            )
        )

        return m

    def create_grn_core_naive(self, grn_content, default_bus_width=32):
        nodes = grn_content.get_nodes_vector()
        equations = grn_content.get_equations_dict()

        name = 'grn_core_naive'
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
        output_data_valid = m.Output('output_data_valid')
        output_data = m.Output('output_data')
        output_data_available = m.Output('output_data_available')
        # Output data Control interface - End -------------------------------------------------------------------------
        m.EmbeddedCode(
            "// The grn core naive configuration consists in two buses with the initial state and the final ")
        m.EmbeddedCode("// state to be searched.")
        m.EmbeddedCode("//The naive kernel output data is the FIFO data output that contains all the data found.\n")

        # Wires and regs to be used in control and execution of the grn naive
        m.EmbeddedCode("// Wires and regs to be used in control and execution of the grn naive")
        actual_state_s1 = m.Reg('actual_state_s1', len(nodes))
        next_state_s1 = m.Wire('next_state_s1', len(nodes))
        actual_state_s2 = m.Reg('actual_state_s2', len(nodes))
        next_state_s2 = m.Wire('next_state_s2', len(nodes))
        exec_state = m.Reg('exec_state', len(nodes))
        m.EmbeddedCode("")

        # In here the GRN equations to be used in the core execution are created
        m.EmbeddedCode("// In here the GRN equations to be used in the core execution are created")

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

        # State machine to control the grn algorithm execution
        m.EmbeddedCode("//State machine to control the grn algorithm execution")
        fsm_naive = m.Reg('fsm_naive', 3)
        fsm_naive_set = m.Localparam('fsm_naive_set', 0)
        fsm_naive_init = m.Localparam('fsm_naive_init', 1)
        fsm_naive_transient_finder = m.Localparam('fsm_naive_transient_finder', 2)
        fsm_naive_period_finder = m.Localparam('fsm_naive_period_finder', 3)
        fsm_naive_wait_init_write = m.Localparam('fsm_naive_wait_init_write', 4)
        fsm_naive_verify = m.Localparam('fsm_naive_verify', 5)
        fsm_naive_done = m.Localparam('fsm_naive_done', 6)

        flag_pulse = m.Reg('flag_pulse')
        flag_first_it = m.Reg('flag_first_it')
        transient_counter = m.Reg('transient_counter', 32)
        period_counter = m.Reg('period_counter', 32)

        m.Always(Posedge(clk))(
            If(rst)(
                fsm_naive(fsm_naive_set),
            ).Elif(start)(
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
                            fsm_naive(fsm_naive_wait_init_write)
                        ).Else(
                            actual_state_s2(next_state_s2),
                            period_counter.inc(),
                        ),
                    ),
                    When(fsm_naive_wait_init_write)(

                    ),
                    When(fsm_naive_verify)(

                    ),
                    When(fsm_naive_done)(

                    )
                )
            )
        )

        bits = (len(nodes) * 2) + 32 + 32
        data_write_width = ceil(bits / 32) * 32
        next_exec = m.Reg('next_exec')
        data_to_write = m.Reg('data_to_write', data_write_width)
        write_counter = m.Reg('write_counter', log2(data_write_width/32))

        # State machine to control the data generation from the core
        m.EmbeddedCode("State machine to control the data generation from the core")
        fsm_fifo_writer = m.Reg('fsm_fifo_writer', 3)
        fsm_fifo_writer_wait_data = m.Localparam('fsm_fifo_writer_wait_data',0)
        fsm_fifo_writer_write = m.Localparam('fsm_fifo_writer_write',1)

        m.Always(Posedge(clk))(
            If(rst)(
                fsm_fifo_writer(fsm_fifo_writer_wait_data),
            ).Else(
                Case(fsm_fifo_writer)(
                    When(fsm_fifo_writer_wait_data)(
                        If(fsm_naive == fsm_naive_wait_init_write)(
                            data_to_write(
                                Cat(exec_state, actual_state_s1, transient_counter, period_counter)
                                if bits == data_write_width else
                                Cat(Int(0,(data_write_width - bits),2),exec_state, actual_state_s1, transient_counter,
                                    period_counter)),
                            fsm_fifo_writer(fsm_fifo_writer_write),
                        )
                    ),
                    When(fsm_fifo_writer_write)(

                    )
                )
            )
        )

        '''
        
        write_enable = m.Input('write_enable')
        input_data = m.Input('input_data', FIFO_WIDTH)
        full = m.OutputReg('full')
        '''

        initialize_regs(m)
        self.cache[name] = m
        return m


grn_content = Grn2dot("../../../../grn_benchmarks/Benchmark_5.txt")
grn = GrnComponents()
grn.create_grn_core_naive(grn_content).to_verilog("../grn_naive.v")
