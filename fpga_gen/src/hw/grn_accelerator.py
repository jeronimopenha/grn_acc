from veriloggen import *
from hw.grn_aws import GrnAws
from hw.utils import initialize_regs


class GrnAccelerator:
    def __init__(self, grn_content, pe_type, blocks, threads, total_eq_bits, bus_width):
        # constants
        self.acc_num_in = blocks
        self.acc_num_out = blocks
        self.pe_type = pe_type

        self.grn_content = grn_content
        self.blocks = blocks
        self.threads = threads
        self.bus_width = bus_width
        self.total_eq_bits = total_eq_bits

        self.acc_data_in_width = bus_width
        self.acc_data_out_width = bus_width
        self.axi_bus_data_width = self.acc_data_in_width

    def get_num_in(self):
        return self.acc_num_in

    def get_num_out(self):
        return self.acc_num_out

    def get(self):
        return self.__create_grn_accelerator()

    def __create_grn_accelerator(self):
        grn_aws = GrnAws()

        m = Module('grn_acc')
        clk = m.Input('clk')
        rst = m.Input('rst')
        start = m.Input('start')
        acc_user_done_rd_data = m.Input('acc_user_done_rd_data', self.acc_num_in)
        acc_user_done_wr_data = m.Input('acc_user_done_wr_data', self.acc_num_out)

        acc_user_request_read = m.Output('acc_user_request_read', self.acc_num_in)
        acc_user_read_data_valid = m.Input('acc_user_read_data_valid', self.acc_num_in)
        acc_user_read_data = m.Input('acc_user_read_data', self.axi_bus_data_width * self.acc_num_in)

        acc_user_available_write = m.Input('acc_user_available_write', self.acc_num_out)
        acc_user_request_write = m.Output('acc_user_request_write', self.acc_num_out)
        acc_user_write_data = m.Output('acc_user_write_data', self.axi_bus_data_width * self.acc_num_out)

        acc_user_done = m.Output('acc_user_done')

        start_reg = m.Reg('start_reg')
        grn_aws_done = m.Wire('grn_aws_done', self.get_num_in())

        acc_user_done.assign(Uand(grn_aws_done))

        m.Always(Posedge(clk))(
            If(rst)(
                start_reg(0)
            ).Else(
                start_reg(Or(start_reg, start))
            )
        )
        if self.blocks < 1:
            raise ValueError("The blocks value can't be lower than 1")
        grn_aws = grn_aws.get(self.grn_content, self.pe_type, self.threads, self.total_eq_bits, self.bus_width)
        for i in range(self.blocks):
            par = []
            con = [
                ('clk', clk),
                ('rst', rst),
                ('start', start_reg),
                ('grn_aws_done_rd_data', acc_user_done_rd_data[i]),
                ('grn_aws_done_wr_data', acc_user_done_wr_data[i]),
                ('grn_aws_request_read', acc_user_request_read[i]),
                ('grn_aws_read_data_valid', acc_user_read_data_valid[i]),
                ('grn_aws_read_data', acc_user_read_data[i * self.acc_data_in_width:(i + 1) * self.acc_data_in_width]),
                ('grn_aws_available_write', acc_user_available_write[i]),
                ('grn_aws_request_write', acc_user_request_write[i]),
                ('grn_aws_write_data',
                 acc_user_write_data[i * self.acc_data_out_width:(i + 1) * self.acc_data_out_width]),
                ('grn_aws_done', grn_aws_done[i])]
            m.Instance(grn_aws, grn_aws.name + "_" + str(i), par, con)

        initialize_regs(m)

        return m
