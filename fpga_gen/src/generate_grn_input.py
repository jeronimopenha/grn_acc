import argparse
import os
import traceback

from grn2dot.grn2dot import Grn2dot

from hw.utils import generate_eq_mem_config, generate_grn_config, to_bytes_string_list, state


def create_args():
    parser = argparse.ArgumentParser('create_grn_input -h')
    parser.add_argument('-g', '--grn', help='GRN description file', type=str)
    parser.add_argument('-s', '--states', help='Number of states', type=str)
    parser.add_argument('-b', '--blocks', help='Number of copies', type=int, default=1)
    parser.add_argument('-t', '--threads', help='Number of threads per block', type=int, default=1)
    parser.add_argument('-w', '--width', help='Default communication bus width', type=int, default=64)
    parser.add_argument('-o', '--output', help='Output file', type=str, default='.')

    return parser.parse_args()


def create_output(grn_file, copies_qty, states, bus_width, output):
    grn_content = Grn2dot(grn_file)
    eq_conf_string = generate_eq_mem_config(grn_content)
    conf = generate_grn_config(grn_content, copies_qty, states, bus_width)

    with open(output + '.csv', 'w') as f:
        for c in range(len(conf)):
            f.write("%d,%s,%s,%d\n" % (conf[c][0], conf[c][1], conf[c][2], conf[c][3]))
        f.close()
    with open(output + "_mem.csv", 'w') as f:
        bytes_list = to_bytes_string_list(eq_conf_string)
        wr_str = ""
        for b in bytes_list:
            wr_str = state(int(b, 2), 2) + wr_str
        f.write("%s\n" % wr_str)
        f.close()


def main():
    args = create_args()
    running_path = os.getcwd()

    if args.output == '.':
        args.output = running_path

    if args.grn and args.states:
        create_output(args.grn, (args.blocks * args.threads), args.states, args.width, args.output)
    else:
        msg = 'Missing parameters. Run create_grn_input -h to see all parameters needed'
        raise Exception(msg)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)
        traceback.print_exc()
