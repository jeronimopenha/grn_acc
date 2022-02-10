from veriloggen import *
from grn2dot.grn2dot import Grn2dot
from grn_components import GrnComponents
from src.hw.utils import initialize_regs
from math import ceil, log2, pow, floor


class GrnAws:

    def get(self, grn_content: Grn2dot, pe_type=0, copies_qty=1, default_bus_width=32):
        self.grn_content = grn_content
        self.pe_type = pe_type
        self.nodes = self.grn_content.get_nodes_vector()
        self.functions = self.grn_content.get_equations_dict()
        self.copies_qty = copies_qty
        self.default_bus_width = default_bus_width
        self.grnComponents = GrnComponents()
        return self.__create_grn_aws()

    def __create_grn_aws(self):
        if self.copies_qty < 1: raise ValueError("The copies value can't be lower than 1")
        name = 'grn_aws_%d' % self.copies_qty
        grn_components = self.grnComponents

        m = Module(name)

        # interface I/O interface - Begin ------------------------------------------------------------------------------
        clk = m.Input('clk')
        rst = m.Input('rst')
        start = m.Input('start')

        grn_aws_done_rd_data = m.Input('grn_aws_done_rd_data')
        grn_aws_done_wr_data = m.Input('grn_aws_done_wr_data')

        grn_aws_request_read = m.OutputReg('grn_aws_request_read')
        grn_aws_read_data_valid = m.Input('grn_aws_read_data_valid')
        grn_aws_read_data = m.Input('grn_aws_read_data', self.default_bus_width)

        grn_aws_available_write = m.Input('grn_aws_available_write')
        grn_aws_request_write = m.Output('grn_aws_request_write')
        grn_aws_write_data = m.Output('grn_aws_write_data', self.default_bus_width)

        # TODO
        grn_aws_done = m.Output('grn_aws_done')
        # interface I/O interface - End --------------------------------------------------------------------------------

        # grn pe instantiation regs and wires - Begin ------------------------------------------------------------
        m.EmbeddedCode('\n// grn pe instantiation regs and wires - Begin')
        grn_pe_config_output_done = m.Wire('grn_pe_config_output_done', self.copies_qty)
        grn_pe_config_output_valid = m.Wire('grn_pe_config_output_valid', self.copies_qty)
        grn_pe_config_output = m.Wire('grn_pe_config_output', self.default_bus_width * self.copies_qty)
        grn_pe_output_read_enable = m.Wire('grn_pe_output_read_enable', self.copies_qty)
        grn_pe_output_valid = m.Wire('grn_pe_output_valid', self.copies_qty)
        grn_pe_output_data = m.Wire('grn_pe_output_data', self.default_bus_width * self.copies_qty)
        grn_pe_output_available = m.Wire('grn_pe_output_available', self.copies_qty)
        m.EmbeddedCode('// grn pe instantiation regs and wires - end')
        # grn pe instantiation regs and wires - end --------------------------------------------------

        # Config wires and regs - Begin --------------------------------------------------------------------------------
        m.EmbeddedCode('\n//Config wires and regs - Begin')
        fsm_sd_idle = m.Localparam('fsm_sd_idle', 0, 2)
        fsm_sd_send_data = m.Localparam('fsm_sd_send_data', 1, 2)
        fsm_sd_done = m.Localparam('fsm_sd_done', 2, 2)
        fsm_sd = m.Reg('fms_cs', 2)
        config_valid = m.Reg('config_valid')
        config_data = m.Reg('config_data', self.default_bus_width)
        config_done = m.Reg('config_done')
        flag = m.Reg('flag')
        m.EmbeddedCode('//Config wires and regs - End')
        # Config wires and regs - End ----------------------------------------------------------------------------------

        # Data Reading - Begin -----------------------------------------------------------------------------------------
        m.EmbeddedCode('\n//Data Reading - Begin')
        m.Always(Posedge(clk))(
            If(rst)(
                grn_aws_request_read(0),
                config_valid(0),
                fsm_sd(fsm_sd_idle),
                config_done(0),
                flag(0)
            ).Elif(start)(
                config_valid(0),
                grn_aws_request_read(0),
                flag(0),
                Case(fsm_sd)(
                    When(fsm_sd_idle)(
                        If(grn_aws_read_data_valid)(
                            grn_aws_request_read(1),
                            flag(1),
                            fsm_sd(fsm_sd_send_data)
                        ).Elif(grn_aws_done_rd_data)(
                            fsm_sd(fsm_sd_done)
                        )
                    ),
                    When(fsm_sd_send_data)(
                        If(grn_aws_read_data_valid | flag)(
                            config_data(grn_aws_read_data),
                            config_valid(1),
                            grn_aws_request_read(1),
                        ).Elif(grn_aws_done_rd_data)(
                            fsm_sd(fsm_sd_done)
                        ).Else(
                            fsm_sd(fsm_sd_idle)
                        )
                    ),
                    When(fsm_sd_done)(
                        config_done(1)
                    )
                )
            )
        )
        m.EmbeddedCode('//Data Reading - End')
        # Data Reading - End -------------------------------------------------------------------------------------------

        # Data Consumer - Begin ----------------------------------------------------------------------------------------
        m.EmbeddedCode('\n//Data Consumer - Begin')
        bits = (ceil(self.grn_content.get_num_nodes() / self.default_bus_width) * self.default_bus_width * 2) + 32 + 32
        qty_data = bits // 32
        data = m.Reg('data', self.default_bus_width)
        consume_rd_enable = m.Reg('consume_rd_enable')
        consume_rd_available = m.Wire('consume_rd_available')
        consume_rd_valid = m.Wire('consume_rd_valid')
        consume_rd_data = m.Wire('consume_rd_data', self.default_bus_width)

        fsm_consume_data = m.Reg('fsm_consume_data', 2)
        fsm_consume_data_rq_rd = m.Localparam('fsm_consume_data_rq_rd', 0)
        fsm_consume_data_rd = m.Localparam('fsm_consume_data_rd', 1)
        fsm_consume_data_wr = m.Localparam('fsm_consume_data_wr', 2)

        m.Always(Posedge(clk))(
            If(rst)(
                consume_rd_enable(0),
                grn_aws_request_write(0),
                fsm_consume_data(fsm_consume_data_rq_rd),
            ).Else(
                consume_rd_enable(0),
                Case(fsm_consume_data)(
                    When(fsm_consume_data_rq_rd)(
                        If(consume_rd_available)(
                            consume_rd_enable(1),
                            fsm_consume_data(fsm_consume_data_rd)
                        )
                    ),
                    When(fsm_consume_data_rd)(
                        If(consume_rd_valid)(
                            grn_aws_request_write(1),
                            data(consume_rd_data),
                            fsm_consume_data(fsm_consume_data_wr),
                        )
                    ),
                    When(fsm_consume_data_wr)(
                        If(grn_aws_available_write)(
                            grn_aws_request_write(0),
                            fsm_consume_data(fsm_consume_data_rq_rd),
                        ),
                    ),
                ),
            )
        )
        m.EmbeddedCode('//Data Consumer - Begin')
        # Data Consumer - End ------------------------------------------------------------------------------------------

        # PE modules instantiation - Begin -----------------------------------------------------------------------------
        m.EmbeddedCode('\n//Assigns to the last PE')
        grn_pe_output_valid[self.copies_qty-1].assign(0)
        grn_pe_output_data[self.copies_qty-1].assign(0)
        grn_pe_output_available[self.copies_qty-1].assign(0)

        m.EmbeddedCode('\n//PE modules instantiation - Begin')
        if self.pe_type == 0:
            grn_pe = GrnComponents().create_grn_naive_pe(self.grn_content)
        elif self.pe_type == 1:
            grn_pe = GrnComponents().create_grn_mem_pe(self.grn_content)
        else:
            grn_pe = GrnComponents().create_grn_naive_pe(self.grn_content)

        par = []
        for i in range(self.copies_qty):
            con = [('clk', clk), ('rst', rst)]
            if i == 0:
                con.append(('config_input_done', config_done))
                con.append(('config_input_valid', config_valid))
                con.append(('config_input', config_data))

                con.append(('config_output_done', grn_pe_config_output_done[i]))
                con.append(('config_output_valid', grn_pe_config_output_valid[i]))
                con.append(('config_output', grn_pe_config_output[i]))

                con.append(('pe_bypass_read_enable', grn_pe_output_read_enable[i]))
                con.append(('pe_bypass_valid', grn_pe_output_valid[i]))
                con.append(('pe_bypass_data', grn_pe_output_data[i]))
                con.append(('pe_bypass_available', grn_pe_output_available[i]))

                con.append(('pe_output_read_enable', consume_rd_enable))
                con.append(('pe_output_valid', consume_rd_valid))
                con.append(('pe_output_data', consume_rd_data))
                con.append(('pe_output_available', consume_rd_available))
            else:
                con.append(('config_input_done', grn_pe_config_output_done[i - 1]))
                con.append(('config_input_valid', grn_pe_output_valid[i - 1]))
                con.append(('config_input', grn_pe_config_output[i - 1]))

                con.append(('config_output_done', grn_pe_config_output_done[i]))
                con.append(('config_output_valid', grn_pe_config_output_valid[i]))
                con.append(('config_output', grn_pe_config_output[i]))

                con.append(('pe_bypass_read_enable', grn_pe_output_read_enable[i]))
                con.append(('pe_bypass_valid', grn_pe_output_valid[i]))
                con.append(('pe_bypass_data', grn_pe_output_data[i]))
                con.append(('pe_bypass_available', grn_pe_output_available[i]))

                con.append(('pe_output_read_enable', grn_pe_output_read_enable[i - 1]))
                con.append(('pe_output_valid', grn_pe_output_valid[i - 1]))
                con.append(('pe_output_data', grn_pe_output_data[i - 1]))
                con.append(('pe_output_available', grn_pe_output_available[i - 1]))
            m.Instance(grn_pe, grn_pe.name + "_" + str(i), par, con)

        m.EmbeddedCode('//PE modules instantiation - End')
        # PE modules instantiation - End -------------------------------------------------------------------------------

        # Simulation - Begin -------------------------------------------------------------------------------------------
        initialize_regs(m)
        # Simulation - End ---------------------------------------------------------------------------------------------
        return m


grn_content = Grn2dot("../../../../grn_benchmarks/Benchmark_5.txt")
grn = GrnAws()
g = grn.get(grn_content, copies_qty=2)
g.to_verilog("../test_benches/" + g.name + ".v")
