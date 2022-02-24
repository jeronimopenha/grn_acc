import argparse
import traceback
from veriloggen import *
from math import ceil

from hw.create_acc_axi_interface import AccAXIInterface
from hw.grn_accelerator import GrnAccelerator
from hw.utils import commands_getoutput
from grn2dot.grn2dot import Grn2dot

p = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if not p in sys.path:
    sys.path.insert(0, p)


def write_file(name, string):
    with open(name, 'w') as fp:
        fp.write(string)
        fp.close()


def create_args():
    parser = argparse.ArgumentParser('create_project -h')
    parser.add_argument('-b', '--blocks', help='Number of blocks', type=int, default=1)
    parser.add_argument('-t', '--threads', help='Number of threads per block', type=int, default=1)
    parser.add_argument('-w', '--width', help='Default communication bus width', type=int, default=64)
    parser.add_argument('-n', '--name', help='Project name', type=str, default='a.prj')
    parser.add_argument('-o', '--output', help='Project location', type=str, default='.')
    parser.add_argument('-g', '--grn', help='GRN description file', type=str)

    return parser.parse_args()


def create_project(grn_root, grn_file, blocks, threads, name, output_path, bus_width):
    grn_content = Grn2dot(grn_file)
    bits_width = grn_content.get_num_nodes() + 16 + 16 + 16
    grnacc = GrnAccelerator(grn_content, blocks, threads, bus_width)
    acc_axi = AccAXIInterface(grnacc)

    template_path = grn_root + '/resources/template.prj'
    cmd = 'cp -r %s  %s/%s' % (template_path, output_path, name)
    commands_getoutput(cmd)

    hw_path = '%s/%s/xilinx_aws_f1/hw/' % (output_path, name)
    sw_path = '%s/%s/xilinx_aws_f1/sw/' % (output_path, name)

    m = acc_axi.create_kernel_top(name)
    m.to_verilog(hw_path + 'src/%s.v' % name)

    acc_config = '#define NUM_CHANNELS (%d)\n' % grnacc.blocks
    acc_config += '#define NUM_THREADS (%d)\n' % grnacc.threads
    acc_config += '#define NUM_NOS (%d)\n' % grnacc.nodes_qty
    acc_config += '#define STATE_SIZE_WORDS (%d)\n' % ceil(grnacc.nodes_qty / 8)
    acc_config += '#define BUS_WIDTH_BYTES (%d)\n' % (grnacc.bus_width // 8)
    acc_config += '#define OUTPUT_DATA_BYTES (%d)\n' % (ceil(bits_width / bus_width) * bus_width // 8)
    acc_config += '#define ACC_DATA_BYTES (%d)\n' % (grnacc.axi_bus_data_width // 8)

    num_axis_str = 'NUM_M_AXIS=%d' % grnacc.get_num_in()
    conn_str = acc_axi.get_connectivity_config(name)

    write_file(hw_path + 'simulate/num_m_axis.mk', num_axis_str)
    write_file(hw_path + 'synthesis/num_m_axis.mk', num_axis_str)
    write_file(sw_path + 'host/prj_name', name)
    write_file(sw_path + 'host/include/acc_config.h', acc_config)
    write_file(hw_path + 'simulate/prj_name', name)
    write_file(hw_path + 'synthesis/prj_name', name)
    write_file(hw_path + 'simulate/vitis_config.txt', conn_str)
    write_file(hw_path + 'synthesis/vitis_config.txt', conn_str)


def main():
    args = create_args()
    running_path = os.getcwd()
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    grn_root = os.getcwd()

    if args.output == '.':
        args.output = running_path

    if args.grn:
        args.grn = running_path + '/' + args.grn
        create_project(grn_root, args.grn, args.blocks, args.threads, args.name, args.output, args.width)
        print('Project successfully created in %s/%s' % (args.output, args.name))
    else:
        msg = 'Missing parameters. Run create_project -h to see all parameters needed'
        raise Exception(msg)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)
        traceback.print_exc()
