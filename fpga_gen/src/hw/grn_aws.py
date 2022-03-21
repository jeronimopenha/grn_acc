from veriloggen import *
from hw.grn_components import GrnComponents
from hw.utils import initialize_regs

p = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if not p in sys.path:
    sys.path.insert(0, p)


class GrnAws:

    def get(self, grn_content, threads, bus_width):
        self.grn_content = grn_content
        self.threads = threads
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

        grn_aws_request_read = m.Output('grn_aws_request_read')
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
        grn_pe_config_output_valid = m.Wire('grn_pe_config_output_valid', self.threads)
        grn_pe_config_output = m.Wire('grn_pe_config_output', 8, self.threads)
        grn_pe_output_read_enable = m.Wire('grn_pe_output_read_enable', self.threads)
        grn_pe_output_valid = m.Wire('grn_pe_output_valid', self.threads)
        grn_pe_output_data = m.Wire('grn_pe_output_data', self.bus_width, self.threads)
        grn_pe_output_available = m.Wire('grn_pe_output_available', self.threads)
        grn_pe_output_almost_empty = m.Wire('grn_pe_output_almost_empty', self.threads)
        m.EmbeddedCode('// grn pe instantiation regs and wires - end')
        # grn pe instantiation regs and wires - end --------------------------------------------------

        # Config wires and regs - Begin --------------------------------------------------------------------------------
        m.EmbeddedCode('\n//Config wires and regs - Begin')
        pop_data = m.Reg('pop_data')
        available_pop = m.Wire('available_pop')
        data_out = m.Wire('data_out', 8)
        config_valid = m.Reg('config_valid')
        config_data = m.Reg('config_data', 8)

        fsm_sd = m.Reg('fms_sd', 2)
        fsm_sd_idle = m.Localparam('fsm_sd_idle', 0, 2)
        fsm_sd_send_data = m.Localparam('fsm_sd_send_data', 1, 2)
        flag = m.Reg('flag')
        m.EmbeddedCode('//Config wires and regs - End')
        # Config wires and regs - End ----------------------------------------------------------------------------------

        # Data Reading - Begin -----------------------------------------------------------------------------------------
        m.EmbeddedCode('\n//Data Reading - Begin')
        m.Always(Posedge(clk))(
            If(rst)(
                pop_data(0),
                config_valid(0),
                fsm_sd(fsm_sd_idle),
                flag(0)
            ).Elif(start)(
                config_valid(0),
                pop_data(0),
                flag(0),
                Case(fsm_sd)(
                    When(fsm_sd_idle)(
                        If(available_pop)(
                            pop_data(1),
                            flag(1),
                            fsm_sd(fsm_sd_send_data)
                        )
                    ),
                    When(fsm_sd_send_data)(
                        If(available_pop | flag)(
                            config_data(data_out),
                            config_valid(1),
                            pop_data(1),
                        ).Else(
                            fsm_sd(fsm_sd_idle)
                        )
                    ),
                )
            )
        )

        '''
        # Data Reading - Begin -----------------------------------------------------------------------------------------
        m.EmbeddedCode('\n//Data Reading - Begin')
        m.Always(Posedge(clk))(
            If(rst)(
                pop_data(0),
                config_valid(0),
            ).Elif(start)(
                config_valid(0),
                pop_data(0),
                If(available_pop)(
                    config_data(data_out),
                    config_valid(1),
                    pop_data(1),
                )
            )
        )
        '''
        m.EmbeddedCode('//Data Reading - End')
        # Data Reading - End -------------------------------------------------------------------------------------------

        # Data Consumer - Begin ----------------------------------------------------------------------------------------
        m.EmbeddedCode('\n//Data Consumer - Begin')
        consume_rd_enable = m.Reg('consume_rd_enable')
        consume_rd_available = m.Wire('consume_rd_available')
        consume_rd_almost_empty = m.Wire('consume_rd_almost_empty')
        consume_rd_valid = m.Wire('consume_rd_valid')
        consume_rd_data = m.Wire('consume_rd_data', self.bus_width)
        fsm_consume = m.Reg('fsm_consume', 2)
        fsm_consume_consume = m.Localparam('fsm_consume_consume', 0)
        fsm_consume_going_stall = m.Localparam('fsm_consume_going_stall', 1)
        fsm_consume_stalled = m.Localparam('fsm_consume_stalled', 2)
        flag_read = m.Reg('flag_read')
        flag_buffer = m.Reg('flag_buffer')

        data_read_counter = m.Reg("data_read_counter", 32)
        data_write_counter = m.Reg("data_write_counter", 32)

        m.Always(Posedge(clk))(
            If(rst)(
                data_write_counter(0)
            ).Elif(grn_aws_request_write)(
                data_write_counter.inc(),
            ),
        )

        m.Always(Posedge(clk))(
            If(rst)(
                data_read_counter(0)
            ).Elif(consume_rd_valid)(
                data_read_counter.inc(),
            ),
        )

        m.Always(Posedge(clk))(
            If(rst)(
                consume_rd_enable(0),
                flag_read(0),
                grn_aws_request_write(0),
                fsm_consume(fsm_consume_consume)
            ).Else(
                consume_rd_enable(0),
                grn_aws_request_write(0),
                Case(fsm_consume)(
                    When(fsm_consume_consume)(
                        If(grn_aws_available_write)(
                            If(~consume_rd_almost_empty)(
                                consume_rd_enable(1),
                            ).Elif(consume_rd_available)(
                                If(flag_read)(
                                    consume_rd_enable(1),
                                ),
                                flag_read(~flag_read),
                            ),
                        ),
                        If(consume_rd_valid)(
                            grn_aws_write_data(consume_rd_data),
                            If(grn_aws_available_write)(
                                grn_aws_request_write(1),
                            ).Else(
                                fsm_consume(fsm_consume_going_stall)
                            ),
                        ),
                    ),
                    When(fsm_consume_going_stall)(
                        If(consume_rd_valid)(
                            flag_buffer(1)
                        ).Else(
                            flag_buffer(0)
                        ),
                        fsm_consume(fsm_consume_stalled)
                    ),
                    When(fsm_consume_stalled)(
                        If(grn_aws_available_write)(
                            If(flag_buffer)(
                                grn_aws_write_data(consume_rd_data),
                                flag_buffer(0),
                            ).Else(
                                fsm_consume(fsm_consume_consume),
                            ),
                            grn_aws_request_write(1),
                        ),
                    ),
                )
            )
        )
        m.EmbeddedCode('//Data Consumer - Begin')
        # Data Consumer - End ------------------------------------------------------------------------------------------
        fetch_data = self.grn_components.create_fecth_data(self.bus_width, 8)
        par = []
        con = [('clk', clk), ('rst', rst), ('start', start), ('request_read', grn_aws_request_read),
               ('data_valid', grn_aws_read_data_valid), ('read_data', grn_aws_read_data), ('pop_data', pop_data),
               ('available_pop', available_pop), ('data_out', data_out)]
        m.EmbeddedCode("(* keep_hierarchy = \"yes\" *)")
        m.Instance(fetch_data, fetch_data.name, par, con)

        # PE modules instantiation - Begin -----------------------------------------------------------------------------
        m.EmbeddedCode('\n//Assigns to the last PE')
        grn_pe_output_valid[self.threads - 1].assign(0)
        grn_pe_output_data[self.threads - 1].assign(0)
        grn_pe_output_available[self.threads - 1].assign(0)
        grn_pe_output_almost_empty[self.threads - 1].assign(1)

        m.EmbeddedCode('\n//PE modules instantiation - Begin')
        grn_pe = self.grn_components.create_grn_pe(self.grn_content, self.bus_width)

        if self.threads < 1:
            raise ValueError("The threads value can't be lower than 1")
        for i in range(self.threads):
            par = [('pe_id', grn_aws_pe_init_id + i), ('rr_wait', self.threads - 1 - i)]
            con = [('clk', clk), ('rst', rst)]
            if i == 0:
                con.append(('config_input_valid', config_valid))
                con.append(('config_input', config_data))

                con.append(('pe_output_read_enable', consume_rd_enable))
                con.append(('pe_output_valid', consume_rd_valid))
                con.append(('pe_output_data', consume_rd_data))
                con.append(('pe_output_available', consume_rd_available))
                con.append(('pe_output_almost_empty', consume_rd_almost_empty))
            else:
                con.append(('config_input_valid', grn_pe_config_output_valid[i - 1]))
                con.append(('config_input', grn_pe_config_output[i - 1]))

                con.append(('pe_output_read_enable', grn_pe_output_read_enable[i - 1]))
                con.append(('pe_output_valid', grn_pe_output_valid[i - 1]))
                con.append(('pe_output_data', grn_pe_output_data[i - 1]))
                con.append(('pe_output_available', grn_pe_output_available[i - 1]))
                con.append(('pe_output_almost_empty', grn_pe_output_almost_empty[i - 1]))

            con.append(('config_output_valid', grn_pe_config_output_valid[i]))
            con.append(('config_output', grn_pe_config_output[i]))

            con.append(('pe_bypass_read_enable', grn_pe_output_read_enable[i]))
            con.append(('pe_bypass_valid', grn_pe_output_valid[i]))
            con.append(('pe_bypass_data', grn_pe_output_data[i]))
            con.append(('pe_bypass_available', grn_pe_output_available[i]))
            con.append(('pe_bypass_almost_empty', grn_pe_output_almost_empty[i]))
            m.EmbeddedCode("(* keep_hierarchy = \"yes\" *)")
            m.Instance(grn_pe, grn_pe.name + "_" + str(i), par, con)

        m.EmbeddedCode('//PE modules instantiation - End')
        # PE modules instantiation - End -------------------------------------------------------------------------------

        # Simulation - Begin -------------------------------------------------------------------------------------------
        initialize_regs(m)
        # Simulation - End ---------------------------------------------------------------------------------------------
        return m
