import multiprocessing.connection

from veriloggen import *
from grn_components import GrnComponents
from grn2dot.grn2dot import Grn2dot
from math import pow, ceil, log2, floor
from src.hw.utils import initialize_regs, generate_grn_mem_config

p = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
if not p in sys.path:
    sys.path.insert(0, p)


class TestBenches:

    def __init__(self, grn_arch_file, default_bus_width=32):
        self.grn_arch_file = grn_arch_file
        self.default_bus_width = default_bus_width
        self.grn_content = Grn2dot(grn_arch_file)

    def create_grn_naive_pe_test_bench_hw(self):
        # TEST BENCH MODULE --------------------------------------------------------------------------------------------
        tb = Module('test_bench_grn_naive_pe')

        tb.EmbeddedCode('\n//Standar I/O signals - Begin')
        tb_clk = tb.Reg('tb_clk')
        tb_rst = tb.Reg('tb_rst')
        tb.EmbeddedCode('//Standar I/O signals - End')

        # grn naive pe instantiation regs and wires - Begin ------------------------------------------------------------
        tb.EmbeddedCode('\n// grn naive pe instantiation regs and wires - Begin')
        grn_pe_naive_config_input_done = tb.Reg('grn_pe_naive_config_input_done')
        grn_pe_naive_config_input_valid = tb.Reg('grn_pe_naive_config_input_valid')
        grn_pe_naive_config_input = tb.Reg('grn_pe_naive_config_input', self.default_bus_width)
        grn_pe_naive_config_output_done = tb.Wire('grn_pe_naive_config_output_done')
        grn_pe_naive_config_output_valid = tb.Wire('grn_pe_naive_config_output_valid')
        grn_pe_naive_config_output = tb.Wire('grn_pe_naive_config_output', self.default_bus_width)

        grn_pe_naive_pe_bypass_read_enable = tb.Wire('grn_pe_naive_pe_bypass_read_enable')
        grn_pe_naive_pe_bypass_valid = tb.Wire('grn_pe_naive_pe_bypass_valid')
        grn_pe_naive_pe_bypass_data = tb.Wire('grn_pe_naive_pe_bypass_data', self.default_bus_width)
        grn_pe_naive_pe_bypass_available = tb.Wire('grn_pe_naive_pe_bypass_available')

        grn_pe_naive_pe_output_read_enable = tb.Reg('grn_pe_naive_pe_output_read_enable')
        grn_pe_naive_pe_output_valid = tb.Wire('grn_pe_naive_pe_output_valid')
        grn_pe_naive_pe_output_data = tb.Wire('grn_pe_naive_pe_output_data', self.default_bus_width)
        grn_pe_naive_pe_output_available = tb.Wire('grn_pe_naive_pe_output_available')
        tb.EmbeddedCode('// grn naive pe instantiation regs and wires - end')
        # grn naive pe instantiation regs and wires - end --------------------------------------------------

        # not used connections in this and that need to be assign to some place testbench:
        tb.EmbeddedCode("\n// not used connections in this and that need to be assign to some place testbench")
        grn_pe_naive_pe_bypass_valid.assign(0)
        grn_pe_naive_pe_bypass_data.assign(0)
        grn_pe_naive_pe_bypass_available.assign(0)

        # Config Rom configuration regs and wires - Begin --------------------------------------------------------------
        tb.EmbeddedCode('\n//Config Rom configuration regs and wires - Begin')
        bits_grn = len(self.grn_content.get_nodes_vector())
        qty_conf = ceil(bits_grn / self.default_bus_width) * 2
        configs = []
        configs.append(0)
        configs.append(floor(pow(2, bits_grn)) - 1)
        config_counter = tb.Reg('config_counter', ceil(log2(qty_conf)) + 1)
        config_rom = tb.Wire('config_rom', self.default_bus_width, qty_conf)
        tb.EmbeddedCode('//Config Rom configuration regs and wires - End')
        # Config Rom configuration regs and wires - End ----------------------------------------------------------------

        # Data Producer regs and wires - Begin -------------------------------------------------------------------------
        tb.EmbeddedCode('\n//Data Producer regs and wires - Begin')
        fsm_produce_data = tb.Reg('fsm_produce_data', 2)
        fsm_produce = tb.Localparam('fsm_produce', 0)
        fsm_done = tb.Localparam('fsm_done', 1)
        tb.EmbeddedCode('\n//Data Producer regs and wires - End')
        # Data Producer regs and wires - End ---------------------------------------------------------------------------

        # Data Producer - Begin ----------------------------------------------------------------------------------------
        tb.EmbeddedCode('\n//Data Producer - Begin')
        tb.Always(Posedge(tb_clk))(
            If(tb_rst)(
                config_counter(0),
                grn_pe_naive_config_input_done(0),
                grn_pe_naive_config_input_valid(0),
                grn_pe_naive_config_input(0),
                fsm_produce_data(fsm_produce),
            ).Else(
                grn_pe_naive_config_input_valid(0),
                Case(fsm_produce_data)(
                    When(fsm_produce)(
                        grn_pe_naive_config_input_valid(1),
                        grn_pe_naive_config_input(config_rom[config_counter]),
                        config_counter.inc(),
                        If(config_counter == qty_conf)(
                            grn_pe_naive_config_input_valid(0),
                            fsm_produce_data(fsm_done)
                        )
                    ),
                    When(fsm_done)(
                        grn_pe_naive_config_input_done(1),
                    ),
                )
            )
        )
        tb.EmbeddedCode('//Data Producer - End')
        # Data Producer - End ------------------------------------------------------------------------------------------

        # Data Consumer - Begin ----------------------------------------------------------------------------------------
        tb.EmbeddedCode('\n//Data Consumer - Begin')
        bits = (len(self.grn_content.get_nodes_vector()) * 2) + 32 + 32
        data_read_width = ceil(bits / 32) * 32
        qty_data = data_read_width / 32
        max_data = tb.Localparam('max_data', floor(pow(2, len(self.grn_content.get_nodes_vector()))))
        rec_data_counter = tb.Reg('rec_data_counter', floor(log2(pow(2, len(self.grn_content.get_nodes_vector())))))
        rd_counter = tb.Reg('rd_counter', ceil(log2(qty_data)))
        data = tb.Reg('data', data_read_width)
        period = tb.Wire('period', 32)
        transient = tb.Wire('transient', 32)
        i_state = tb.Wire('i_state', len(self.grn_content.get_nodes_vector()))
        s_state = tb.Wire('s_state', len(self.grn_content.get_nodes_vector()))
        period.assign(data[0:period.width])
        transient.assign(data[period.width:period.width + transient.width])
        s_state.assign(data[period.width + transient.width:period.width + transient.width + s_state.width])
        i_state.assign(data[
                       period.width + transient.width + s_state.width:period.width + transient.width + s_state.width + i_state.width])

        done = tb.Reg('done')
        fsm_consume_data = tb.Reg('fsm_consume_data', 3)
        fsm_consume_data_wait = tb.Localparam('fsm_consume_data_wait', 0)
        fsm_consume_data_rq_rd = tb.Localparam('fsm_consume_data_rq_rd', 1)
        fsm_consume_data_rd = tb.Localparam('fsm_consume_data_rd', 2)
        fsm_consume_data_show = tb.Localparam('fsm_consume_data_show', 3)
        fsm_consume_data_done = tb.Localparam('fsm_consume_data_done', 4)

        tb.Always(Posedge(tb_clk))(
            If(tb_rst)(
                fsm_consume_data(fsm_consume_data_wait),
                rec_data_counter(0),
                done(0),
                grn_pe_naive_pe_output_read_enable(0),
            ).Else(
                grn_pe_naive_pe_output_read_enable(0),
                Case(fsm_consume_data)(
                    When(fsm_consume_data_wait)(
                        If(grn_pe_naive_pe_output_available)(
                            rd_counter(0),
                            fsm_consume_data(fsm_consume_data_rq_rd),
                        )
                    ),
                    When(fsm_consume_data_rq_rd)(
                        If(grn_pe_naive_pe_output_available)(
                            grn_pe_naive_pe_output_read_enable(1),
                            fsm_consume_data(fsm_consume_data_rd)
                        )
                    ),
                    When(fsm_consume_data_rd)(
                        If(grn_pe_naive_pe_output_valid)(
                            fsm_consume_data(fsm_consume_data_rq_rd),
                            If(rd_counter == int(qty_data - 1))(
                                fsm_consume_data(fsm_consume_data_show)
                            ),
                            rd_counter.inc(),
                            data(Cat(grn_pe_naive_pe_output_data, data[self.default_bus_width:data.width])),
                        )
                    ),
                    When(fsm_consume_data_show)(
                        fsm_consume_data(fsm_consume_data_wait),
                        If(rec_data_counter == max_data - 1)(
                            fsm_consume_data(fsm_consume_data_done),
                        ),
                        Display("i_s: %h s_s: %h t: %h p: %h", i_state, s_state, transient, period),
                        rec_data_counter.inc(),
                    ),
                    When(fsm_consume_data_done)(
                        done(1),
                    ),
                ),
            )
        )
        tb.EmbeddedCode('//Data Consumer - Begin')
        # Data Consumer - End ------------------------------------------------------------------------------------------

        # Config Rom configuration - Begin -----------------------------------------------------------------------------
        tb.EmbeddedCode('\n//Config Rom configuration - Begin')
        config_rom_counter = 0
        for conf in configs:
            for i in range(ceil(bits_grn / self.default_bus_width)):
                config_rom[config_rom_counter].assign(
                    Int(conf, config_rom.width, 10))
                conf = conf >> self.default_bus_width
                config_rom_counter = config_rom_counter + 1
        tb.EmbeddedCode('//Config Rom configuration - End')
        # Config Rom configuration - End -------------------------------------------------------------------------------

        # grn pe naive instantiation - Begin -----------------------------------------------------------------
        grn_pe_naive = GrnComponents().create_grn_naive_pe(self.grn_content)
        con = [('clk', tb_clk), ('rst', tb_rst), ('config_input_done', grn_pe_naive_config_input_done),
               ('config_input_valid', grn_pe_naive_config_input_valid), ('config_input', grn_pe_naive_config_input),
               ('config_output_done', grn_pe_naive_config_output_done),
               ('config_output_valid', grn_pe_naive_config_output_valid), ('config_output', grn_pe_naive_config_output),
               ('pe_bypass_read_enable', grn_pe_naive_pe_bypass_read_enable),
               ('pe_bypass_valid', grn_pe_naive_pe_bypass_valid), ('pe_bypass_data', grn_pe_naive_pe_bypass_data),
               ('pe_bypass_available', grn_pe_naive_pe_bypass_available),
               ('pe_output_read_enable', grn_pe_naive_pe_output_read_enable),
               ('pe_output_valid', grn_pe_naive_pe_output_valid), ('pe_output_data', grn_pe_naive_pe_output_data),
               ('pe_output_available', grn_pe_naive_pe_output_available)]
        par = []
        tb.Instance(grn_pe_naive, grn_pe_naive.name, par, con)
        # grn pe naive instantiation - end -----------------------------------------------------------------

        initialize_regs(tb, {'tb_clk': 0, 'tb_rst': 1, 'tb_start_reg': 0})

        simulation.setup_waveform(tb)

        tb.Initial(
            EmbeddedCode('@(posedge tb_clk);'),
            EmbeddedCode('@(posedge tb_clk);'),
            EmbeddedCode('@(posedge tb_clk);'),
            tb_rst(0),
            Delay(1000000), Finish()
        )
        tb.EmbeddedCode('always #5tb_clk=~tb_clk;')

        tb.Always(Posedge(tb_clk))(
            If(done)(
                # Display('ACC DONE!'),
                Finish()
            )
        )

        tb.EmbeddedCode('\n//Simulation sector - End')
        tb.to_verilog('../test_benches/grn_naive_pe_test_bench_' + str(
            len(self.grn_content.get_nodes_vector())) + '_nodes_' + str(int(pow(2, bits_grn))) + '_states.v')
        sim = simulation.Simulator(tb, sim='iverilog')
        rslt = sim.run()
        print(rslt)

    def create_grn_mem_pe_test_bench_hw(self):
        # TEST BENCH MODULE --------------------------------------------------------------------------------------------
        tb = Module('test_bench_grn_mem_pe')

        tb.EmbeddedCode('\n//Standar I/O signals - Begin')
        tb_clk = tb.Reg('tb_clk')
        tb_rst = tb.Reg('tb_rst')
        tb.EmbeddedCode('//Standar I/O signals - End')

        # grn mem pe instantiation regs and wires - Begin ------------------------------------------------------------
        tb.EmbeddedCode('\n// grn mem pe instantiation regs and wires - Begin')
        grn_pe_mem_config_input_done = tb.Reg('grn_pe_mem_config_input_done')
        grn_pe_mem_config_input_valid = tb.Reg('grn_pe_mem_config_input_valid')
        grn_pe_mem_config_input = tb.Reg('grn_pe_mem_config_input', self.default_bus_width)
        grn_pe_mem_config_output_done = tb.Wire('grn_pe_mem_config_output_done')
        grn_pe_mem_config_output_valid = tb.Wire('grn_pe_mem_config_output_valid')
        grn_pe_mem_config_output = tb.Wire('grn_pe_mem_config_output', self.default_bus_width)

        grn_pe_mem_pe_bypass_read_enable = tb.Wire('grn_pe_mem_pe_bypass_read_enable')
        grn_pe_mem_pe_bypass_valid = tb.Wire('grn_pe_mem_pe_bypass_valid')
        grn_pe_mem_pe_bypass_data = tb.Wire('grn_pe_mem_pe_bypass_data', self.default_bus_width)
        grn_pe_mem_pe_bypass_available = tb.Wire('grn_pe_mem_pe_bypass_available')

        grn_pe_mem_pe_output_read_enable = tb.Reg('grn_pe_mem_pe_output_read_enable')
        grn_pe_mem_pe_output_valid = tb.Wire('grn_pe_mem_pe_output_valid')
        grn_pe_mem_pe_output_data = tb.Wire('grn_pe_mem_pe_output_data', self.default_bus_width)
        grn_pe_mem_pe_output_available = tb.Wire('grn_pe_mem_pe_output_available')
        tb.EmbeddedCode('// grn mem pe instantiation regs and wires - end')
        # grn mem pe instantiation regs and wires - end --------------------------------------------------

        # not used connections in this and that need to be assign to some place testbench:
        tb.EmbeddedCode("\n// not used connections in this and that need to be assign to some place testbench")
        grn_pe_mem_pe_bypass_valid.assign(0)
        grn_pe_mem_pe_bypass_data.assign(0)
        grn_pe_mem_pe_bypass_available.assign(0)

        # Config Rom configuration regs and wires - Begin --------------------------------------------------------------
        tb.EmbeddedCode('\n//Config Rom configuration regs and wires - Begin')
        rom_config = generate_grn_mem_config(self.grn_content)
        qty_conf = len(rom_config)
        config_counter = tb.Reg('config_counter', ceil(log2(qty_conf)) + 1)
        config_rom = tb.Wire('config_rom', self.default_bus_width, qty_conf)
        tb.EmbeddedCode('//Config Rom configuration regs and wires - End')
        # Config Rom configuration regs and wires - End ----------------------------------------------------------------

        # Data Producer regs and wires - Begin -------------------------------------------------------------------------
        tb.EmbeddedCode('\n//Data Producer regs and wires - Begin')
        fsm_produce_data = tb.Reg('fsm_produce_data', 2)
        fsm_produce = tb.Localparam('fsm_produce', 0)
        fsm_done = tb.Localparam('fsm_done', 1)
        tb.EmbeddedCode('\n//Data Producer regs and wires - End')
        # Data Producer regs and wires - End ---------------------------------------------------------------------------

        # Data Producer - Begin ----------------------------------------------------------------------------------------
        tb.EmbeddedCode('\n//Data Producer - Begin')
        tb.Always(Posedge(tb_clk))(
            If(tb_rst)(
                config_counter(0),
                grn_pe_mem_config_input_done(0),
                grn_pe_mem_config_input_valid(0),
                grn_pe_mem_config_input(0),
                fsm_produce_data(fsm_produce),
            ).Else(
                grn_pe_mem_config_input_valid(0),
                Case(fsm_produce_data)(
                    When(fsm_produce)(
                        grn_pe_mem_config_input_valid(1),
                        grn_pe_mem_config_input(config_rom[config_counter]),
                        config_counter.inc(),
                        If(config_counter == qty_conf-1)(
                            fsm_produce_data(fsm_done)
                        )
                    ),
                    When(fsm_done)(
                        grn_pe_mem_config_input_done(1),
                    ),
                )
            )
        )
        tb.EmbeddedCode('//Data Producer - End')
        # Data Producer - End ------------------------------------------------------------------------------------------

        # Data Consumer - Begin ----------------------------------------------------------------------------------------
        tb.EmbeddedCode('\n//Data Consumer - Begin')
        bits = (ceil(self.grn_content.get_num_nodes() / 32) * 32 * 2) + 32 + 32
        data_read_width = bits
        qty_data = data_read_width // 32
        max_data = tb.Localparam('max_data', floor(pow(2, len(self.grn_content.get_nodes_vector()))))
        max_data_counter = tb.Reg('max_data_counter', floor(log2(pow(2, len(self.grn_content.get_nodes_vector())))))
        rd_counter = tb.Reg('rd_counter', ceil(log2(qty_data)))
        data = tb.Reg('data', data_read_width)
        period = tb.Wire('period', 32)
        transient = tb.Wire('transient', 32)
        i_state = tb.Wire('i_state', len(self.grn_content.get_nodes_vector()))
        s_state = tb.Wire('s_state', len(self.grn_content.get_nodes_vector()))
        init_idx = 0
        period.assign(data[init_idx:period.width])
        init_idx = init_idx + period.width
        transient.assign(data[init_idx:init_idx + transient.width])
        init_idx = init_idx + period.width
        s_state.assign(data[init_idx:init_idx + s_state.width])
        add_bit_states = ceil(self.grn_content.get_num_nodes() / 32) * 32 - s_state.width
        init_idx = init_idx + s_state.width + add_bit_states
        i_state.assign(data[init_idx:init_idx + i_state.width])

        done = tb.Reg('done')
        fsm_consume_data = tb.Reg('fsm_consume_data', 3)
        fsm_consume_data_wait = tb.Localparam('fsm_consume_data_wait', 0)
        fsm_consume_data_rq_rd = tb.Localparam('fsm_consume_data_rq_rd', 1)
        fsm_consume_data_rd = tb.Localparam('fsm_consume_data_rd', 2)
        fsm_consume_data_show = tb.Localparam('fsm_consume_data_show', 3)
        fsm_consume_data_done = tb.Localparam('fsm_consume_data_done', 4)

        tb.Always(Posedge(tb_clk))(
            If(tb_rst)(
                fsm_consume_data(fsm_consume_data_wait),
                max_data_counter(0),
                done(0),
                grn_pe_mem_pe_output_read_enable(0),
            ).Else(
                grn_pe_mem_pe_output_read_enable(0),
                Case(fsm_consume_data)(
                    When(fsm_consume_data_wait)(
                        If(grn_pe_mem_pe_output_available)(
                            rd_counter(0),
                            fsm_consume_data(fsm_consume_data_rq_rd),
                        )
                    ),
                    When(fsm_consume_data_rq_rd)(
                        If(grn_pe_mem_pe_output_available)(
                            grn_pe_mem_pe_output_read_enable(1),
                            fsm_consume_data(fsm_consume_data_rd)
                        )
                    ),
                    When(fsm_consume_data_rd)(
                        If(grn_pe_mem_pe_output_valid)(
                            fsm_consume_data(fsm_consume_data_rq_rd),
                            If(rd_counter == int(qty_data - 1))(
                                fsm_consume_data(fsm_consume_data_show)
                            ),
                            rd_counter.inc(),
                            data(Cat(grn_pe_mem_pe_output_data, data[self.default_bus_width:data.width])),
                        )
                    ),
                    When(fsm_consume_data_show)(
                        fsm_consume_data(fsm_consume_data_wait),
                        If(max_data_counter == max_data - 1)(
                            fsm_consume_data(fsm_consume_data_done),
                        ),
                        Display("i_s: %h s_s: %h t: %h p: %h", i_state, s_state, transient, period),
                        max_data_counter.inc(),
                    ),
                    When(fsm_consume_data_done)(
                        done(1),
                    ),
                ),
            )
        )
        tb.EmbeddedCode('//Data Consumer - Begin')
        # Data Consumer - End ------------------------------------------------------------------------------------------

        # Config Rom configuration - Begin -----------------------------------------------------------------------------
        tb.EmbeddedCode('\n//Config Rom configuration - Begin')
        config_rom_counter = 0
        for config in rom_config:
            config_rom[config_rom_counter].assign(Int(int(config, 16), config_rom.width, 10))
            config_rom_counter = config_rom_counter + 1
        tb.EmbeddedCode('//Config Rom configuration - End')
        # Config Rom configuration - End -------------------------------------------------------------------------------

        # grn pe mem instantiation - Begin -----------------------------------------------------------------
        grn_pe_mem = GrnComponents().create_grn_mem_pe(self.grn_content)
        con = [('clk', tb_clk), ('rst', tb_rst), ('config_input_done', grn_pe_mem_config_input_done),
               ('config_input_valid', grn_pe_mem_config_input_valid), ('config_input', grn_pe_mem_config_input),
               ('config_output_done', grn_pe_mem_config_output_done),
               ('config_output_valid', grn_pe_mem_config_output_valid), ('config_output', grn_pe_mem_config_output),
               ('pe_bypass_read_enable', grn_pe_mem_pe_bypass_read_enable),
               ('pe_bypass_valid', grn_pe_mem_pe_bypass_valid), ('pe_bypass_data', grn_pe_mem_pe_bypass_data),
               ('pe_bypass_available', grn_pe_mem_pe_bypass_available),
               ('pe_output_read_enable', grn_pe_mem_pe_output_read_enable),
               ('pe_output_valid', grn_pe_mem_pe_output_valid), ('pe_output_data', grn_pe_mem_pe_output_data),
               ('pe_output_available', grn_pe_mem_pe_output_available)]
        par = []
        tb.Instance(grn_pe_mem, grn_pe_mem.name, par, con)
        # grn pe mem instantiation - end -----------------------------------------------------------------

        initialize_regs(tb, {'tb_clk': 0, 'tb_rst': 1, 'tb_start_reg': 0})

        simulation.setup_waveform(tb)

        tb.Initial(
            EmbeddedCode('@(posedge tb_clk);'),
            EmbeddedCode('@(posedge tb_clk);'),
            EmbeddedCode('@(posedge tb_clk);'),
            tb_rst(0),
            Delay(1000000), Finish()
        )
        tb.EmbeddedCode('always #5tb_clk=~tb_clk;')

        tb.Always(Posedge(tb_clk))(
            If(done)(
                # Display('ACC DONE!'),
                Finish()
            )
        )

        tb.EmbeddedCode('\n//Simulation sector - End')
        tb.to_verilog(
            '../test_benches/grn_mem_pe_test_bench_' + str(self.grn_content.get_num_nodes()) + '_nodes.v')
        sim = simulation.Simulator(tb, sim='iverilog')
        rslt = sim.run()
        print(rslt)


test_benches = TestBenches('../../../../grn_benchmarks/Benchmark_5.txt')
test_benches.create_grn_mem_pe_test_bench_hw()

