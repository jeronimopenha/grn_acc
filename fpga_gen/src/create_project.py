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
    parser.add_argument('-g', '--grn', help='GRN description file', type=str)
    parser.add_argument('-b', '--blocks', help='Number of blocks', type=int, default=1)
    parser.add_argument('-t', '--threads', help='Number of threads per block', type=int, default=1)
    parser.add_argument('-p', '--pe_type', help='Type of PE: 0 - naive with equations; 1 - naive with memory', type=int,
                        default=0)
    parser.add_argument('-n', '--name', help='Project name', type=str, default='a.prj')
    parser.add_argument('-w', '--width', help='Default communication bus width', type=int, default=64)
    parser.add_argument('-o', '--output', help='Project location', type=str, default='.')

    return parser.parse_args()


def create_project(grn_root, grn_file, blocks, threads, pe_type, name, output_path, bus_width):
    grn_content = Grn2dot(grn_file)
    eq_bits = 0
    for g in grn_content.get_grn_mem_specifications():
        eq_bits = eq_bits + int(pow(2, len(g[2])))
    total_eq_bits = ceil(eq_bits / bus_width) * bus_width // 8
    eq_bytes = total_eq_bits // 8
    grnacc = GrnAccelerator(grn_content, pe_type, blocks, threads, total_eq_bits, bus_width)
    acc_axi = AccAXIInterface(grnacc)

    template_path = grn_root + '/resources/template.prj'
    cmd = 'cp -r %s  %s/%s' % (template_path, output_path, name)
    commands_getoutput(cmd)

    hw_path = '%s/%s/xilinx_aws_f1/hw/' % (output_path, name)
    sw_path = '%s/%s/xilinx_aws_f1/sw/' % (output_path, name)

    m = acc_axi.create_kernel_top(name)
    m.to_verilog(hw_path + 'src/%s.v' % name)

    acc_config = '#define NUM_CHANNELS (%d)\n' % blocks
    acc_config += '#define NUM_BLOCKS (%d)\n' % blocks
    acc_config += '#define NUM_THREADS (%d)\n' % threads
    acc_config += '#define NUM_NOS (%d)\n' % grnacc.nodes_qty
    acc_config += '#define STATE_SIZE_WORDS (%d)\n' % int(ceil(grnacc.nodes_qty / bus_width))
    acc_config += '#define ACC_DATA_BYTES (%d)\n' % int(grnacc.axi_bus_data_width / 8)
    acc_config += '#define PE_TYPE (%d)\n' % int(pe_type)
    acc_config += '#define MEM_CONF_BYTES (%d)\n' % int(eq_bytes)

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
        create_project(grn_root, args.grn, args.blocks, args.threads, args.pe_type, args.name, args.output, args.width)

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
