import json
import argparse


def create_args():
    parser = argparse.ArgumentParser('create_report -h')
    parser.add_argument('-j', '--json', help='Kernel util synthed JSON file', type=str)
    parser.add_argument('-t', '--timing_report', help='Timing summary file', type=str)

    return parser.parse_args()


def get_data(json_file):
    with open(json_file, "r") as f:
        rpt = json.load(f)
        f.close()

    user_budget = rpt['user_budget']['actual_resources']
    supply_resources = rpt['user_budget']['supply_resources']

    return user_budget, supply_resources


def getFmax(timing_report):
    wns = 0.0
    with open(timing_report, 'r') as f:
        while (True):
            line = f.readline(30)
            if 'Design Timing Summary' in line:
                for _ in range(5):
                    next(f)
                wns = float(f.readline().strip().split(' ')[0])
                break
        f.close()

    fmax = (1.0 / (4.0 - wns)) * 1000.0

    return 250, fmax


def create_report(resources_report, timing_report):
    user_budget, supply_resources = get_data(resources_report)
    tc, fmax = getFmax(timing_report)
    arch_name = resources_report.split('/')[1]

    print(arch_name)

    head = 'ARCH, LUT, %, REG, %, LUTAsMem, %, BRAM, %, URAM, %, DSP, %, Target clock(MHz), Fmax(MHz)\n'
    values = '%s, %d, %f, %d, %f, %d, %f, %d, %f, %d, %f, %d, %f, %d, %f\n'
    with open('report.csv', 'r+') as fp:
        has_head = False
        if 'ARCH' not in fp.readline(5):
            fp.write(head)

        LUT = int(user_budget['LUT'])
        LUTP = 100.0 * (LUT / int(supply_resources['LUT']))

        REG = int(user_budget['REG'])
        REGP = 100.0 * (REG / int(supply_resources['REG']))

        LUTAsMem = int(user_budget['LUTAsMem'])
        LUTAsMemP = 100.0 * (LUTAsMem / int(supply_resources['LUTAsMem']))

        BRAM = int(user_budget['BRAM'])
        BRAMP = 100.0 * (BRAM / int(supply_resources['BRAM']))

        URAM = int(user_budget['URAM'])
        URAMP = 100.0 * (URAM / int(supply_resources['URAM']))

        DSP = int(user_budget['DSP'])
        DSPP = 100.0 * (DSP / int(supply_resources['DSP']))

        fp.write(values % (
        arch_name, LUT, LUTP, REG, REGP, LUTAsMem, LUTAsMemP, BRAM, BRAMP, URAM, URAMP, DSP, DSPP, tc, fmax))

        fp.close()


def main():
    args = create_args()
    create_report(args.json, args.timing_report)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)