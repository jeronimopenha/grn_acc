from veriloggen import *
from hw.grn_components import GrnComponents
from hw.utils import initialize_regs
from math import ceil

p = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if not p in sys.path:
    sys.path.insert(0, p)


class GrnAws:

    def get(self, grn_content, pe_type, threads, total_eq_bits, bus_width):
        self.grn_content = grn_content
        self.pe_type = pe_type
        self.threads = threads
        self.total_eq_bits = total_eq_bits
        self.bus_width = bus_width
        self.grn_components = GrnComponents()
        return self.__create_grn_aws()

    def __create_grn_aws(self):
        name = 'grn_aws_%d' % self.threads

        m = Module(name)

        grn_aws_pe_init_id = m.Parameter('grn_aws_pe_init_id', 0, 16)

        # interface I/O interface - Begin ------------------------------------------------------------------------------
        clk = m.Input('clk')
        rst = m.Input('rst')
        start = m.Input('start')

        grn_aws_done_rd_data = m.Input('grn_aws_done_rd_data')
        grn_aws_done_wr_data = m.Input('grn_aws_done_wr_data')

        grn_aws_request_read = m.OutputReg('grn_aws_request_read')
        grn_aws_read_data_valid = m.Input('grn_aws_read_data_valid')
        grn_aws_read_data = m.Input('grn_aws_read_data', self.bus_width)

        grn_aws_available_write = m.Input('grn_aws_available_write')
        grn_aws_request_write = m.OutputReg('grn_aws_request_write')
        grn_aws_write_data = m.OutputReg('grn_aws_write_data', self.bus_width)

        grn_aws_done = m.Output('grn_aws_done')
        # interface I/O interface - End --------------------------------------------------------------------------------

        grn_aws_done.assign(Uand(Cat(grn_aws_done_wr_data, grn_aws_done_rd_data)))

        # grn pe instantiation regs and wires - Begin ------------------------------------------------------------
        m.EmbeddedCode('\n// grn pe instantiation regs and wires - Begin')
        grn_pe_config_output_done = m.Wire('grn_pe_config_output_done', self.threads)
        grn_pe_config_output_valid = m.Wire('grn_pe_config_output_valid', self.threads)
        grn_pe_config_output = m.Wire('grn_pe_config_output', self.bus_width, self.threads)
        grn_pe_output_read_enable = m.Wire('grn_pe_output_read_enable', self.threads)
        grn_pe_output_valid = m.Wire('grn_pe_output_valid', self.threads)
        grn_pe_output_data = m.Wire('grn_pe_output_data', self.bus_width, self.threads)
        grn_pe_output_available = m.Wire('grn_pe_output_available', self.threads)
        m.EmbeddedCode('// grn pe instantiation regs and wires - end')
        # grn pe instantiation regs and wires - end --------------------------------------------------

        # Config wires and regs - Begin --------------------------------------------------------------------------------
        m.EmbeddedCode('\n//Config wires and regs - Begin')
        fsm_sd_idle = m.Localparam('fsm_sd_idle', 0, 2)
        fsm_sd_send_data = m.Localparam('fsm_sd_send_data', 1, 2)
        fsm_sd_done = m.Localparam('fsm_sd_done', 2, 2)
        fsm_sd = m.Reg('fms_cs', 2)
        config_valid = m.Reg('config_valid')
        config_data = m.Reg('config_data', self.bus_width)
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
        consume_rd_enable = m.Reg('consume_rd_enable')
        consume_rd_available = m.Wire('consume_rd_available')
        consume_rd_valid = m.Wire('consume_rd_valid')
        consume_rd_data = m.Wire('consume_rd_data', self.bus_width)

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
                grn_aws_request_write(0),
                Case(fsm_consume_data)(
                    When(fsm_consume_data_rq_rd)(
                        If(consume_rd_available)(
                            consume_rd_enable(1),
                            fsm_consume_data(fsm_consume_data_rd)
                        )
                    ),
                    When(fsm_consume_data_rd)(
                        If(consume_rd_valid)(
                            grn_aws_write_data(consume_rd_data),
                            fsm_consume_data(fsm_consume_data_wr),
                        )
                    ),
                    When(fsm_consume_data_wr)(
                        If(grn_aws_available_write)(
                            grn_aws_request_write(1),
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
        grn_pe_output_valid[self.threads - 1].assign(0)
        grn_pe_output_data[self.threads - 1].assign(0)
        grn_pe_output_available[self.threads - 1].assign(0)

        m.EmbeddedCode('\n//PE modules instantiation - Begin')
        grn_pe = self.grn_components.create_grn_pe(self.pe_type, self.grn_content, self.total_eq_bits, self.bus_width)

        if self.threads < 1:
            raise ValueError("The threads value can't be lower than 1")
        for i in range(self.threads):
            par = [('pe_id', grn_aws_pe_init_id + i)]
            con = [('clk', clk), ('rst', rst)]
            if i == 0:
                con.append(('config_input_done', config_done))
                con.append(('config_input_valid', config_valid))
                con.append(('config_input', config_data))

                con.append(('pe_output_read_enable', consume_rd_enable))
                con.append(('pe_output_valid', consume_rd_valid))
                con.append(('pe_output_data', consume_rd_data))
                con.append(('pe_output_available', consume_rd_available))
            else:
                con.append(('config_input_done', grn_pe_config_output_done[i - 1]))
                con.append(('config_input_valid', grn_pe_config_output_valid[i - 1]))
                con.append(('config_input', grn_pe_config_output[i - 1]))

                con.append(('pe_output_read_enable', grn_pe_output_read_enable[i - 1]))
                con.append(('pe_output_valid', grn_pe_output_valid[i - 1]))
                con.append(('pe_output_data', grn_pe_output_data[i - 1]))
                con.append(('pe_output_available', grn_pe_output_available[i - 1]))

            con.append(('config_output_done', grn_pe_config_output_done[i]))
            con.append(('config_output_valid', grn_pe_config_output_valid[i]))
            con.append(('config_output', grn_pe_config_output[i]))

            con.append(('pe_bypass_read_enable', grn_pe_output_read_enable[i]))
            con.append(('pe_bypass_valid', grn_pe_output_valid[i]))
            con.append(('pe_bypass_data', grn_pe_output_data[i]))
            con.append(('pe_bypass_available', grn_pe_output_available[i]))

            m.Instance(grn_pe, grn_pe.name + "_" + str(i), par, con)

        m.EmbeddedCode('//PE modules instantiation - End')
        # PE modules instantiation - End -------------------------------------------------------------------------------

        # Simulation - Begin -------------------------------------------------------------------------------------------
        initialize_regs(m)
        # Simulation - End ---------------------------------------------------------------------------------------------
        return m
