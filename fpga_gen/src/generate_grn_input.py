import argparse
import traceback

from hw.utils import *


def create_args():
    parser = argparse.ArgumentParser('create_grn_input -h')
    parser.add_argument('-g', '--grn', help='GRN description file', type=str)
    parser.add_argument('-s', '--number', help='Number of states', type=str)
    parser.add_argument('-c', '--copies', help='Number of copies', type=str)
    parser.add_argument('-p', '--pe_type', help='Type of PE: 0 - naive with equations; 1 - naive with memory', type=str)
    parser.add_argument('-o', '--output', help='Output file', type=str, default='.')

    return parser.parse_args()


def create_output(grn_file, pe_type, num_states, num_copies, output):
    grn_content = Grn2dot(grn_file)
    eq_conf_string = ""
    eq_conf_string = generate_eq_mem_config(grn_content)
    conf = generate_grn_mem_config(grn_content, copies_qty=num_copies, states=num_states)

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

    if args.grn and args.number and args.pe_type and args.copies and args.output:
        create_output(args.grn, args.pe_type, args.number, args.copies, args.output)
    else:
        msg = 'Missing parameters. Run create_grn_input -h to see all parameters needed'
        raise Exception(msg)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)
        traceback.print_exc()
