from veriloggen import *
from math import ceil, log2
import subprocess
from grn2dot.grn2dot import Grn2dot


def to_bytes_string_list(conf_string):
    list_ret = []
    for i in range(len(conf_string), 0, -8):
        list_ret.append(conf_string[i - 8:i])
    return list_ret


def state(val, size):
    return format(val, "0%dx" % size)


def generate_grn_config(grn_content: Grn2dot, copies_qty, states, bus_width):
    # config states step
    num_nos = grn_content.get_num_nodes()
    num_states = int(eval(states))
    num_copies = int(eval(copies_qty))
    num_states = min(2 ** num_nos, num_states)

    l = int(ceil(num_nos / bus_width) * 4) * 2

    state_per_copy = int(num_states / num_copies)
    state_rest = int(num_states % num_copies)
    init = 0
    states = [(0, 0, 0) for _ in range(num_copies)]

    for c in range(num_copies):
        if state_rest > 0:
            states[c] = (init, init + state_per_copy, state_per_copy + 1)
            init += state_per_copy + 1
            state_rest -= 1
        else:
            states[c] = (init, init + state_per_copy - 1, state_per_copy)
            init += state_per_copy

    conf = []
    for c in range(num_copies):
        i, e, s = states[c]
        conf.append((c, state(i, l), state(e, l), s))
    return conf


def generate_eq_mem_config(grn_content: Grn2dot, bus_width):
    # equation config generation step
    str_mem_conf = ""
    # Finding the true table for each equation
    for g in grn_content.get_grn_mem_specifications():
        eq_bits = int(pow(2, len(g[2])))
        equation = grn_content.get_equations_dict()[g[0]]
        equation = equation.replace('||', 'or')
        equation = equation.replace('&&', 'and')
        equation = equation.replace('!', 'not')
        idx_counter = 0
        for node in grn_content.get_nodes_vector():
            if node in equation:
                for g1 in grn_content.get_grn_mem_specifications():
                    if node == g1[0]:
                        equation = equation.replace(node, ' eq_values[' + str(idx_counter) + '] ')
                        idx_counter = idx_counter + 1
                        break
        eq_values = [False for _ in range(int(log2(eq_bits)))]
        for i in range(eq_bits):
            for j in range(len(eq_values)):
                eq_values[j] = bool((i >> j) & 1)
            eq_ans = eval(equation)
            str_mem_conf = str(int(eq_ans)) + str_mem_conf
    if len(str_mem_conf) % 32 > 0:
        new_str = ""
        for i in range(32 - (len(str_mem_conf) % 32)):
            new_str = new_str + "0"
        str_mem_conf = new_str + str_mem_conf
    return str_mem_conf


def initialize_regs(module, values=None):
    regs = []
    if values is None:
        values = {}
    flag = False
    for r in module.get_vars().items():
        if module.is_reg(r[0]):
            regs.append(r)
            if r[1].dims:
                flag = True

    if len(regs) > 0:
        if flag:
            i = module.Integer('i_initial')
        s = module.Initial()
        for r in regs:
            if values:
                if r[0] in values.keys():
                    value = values[r[0]]
                else:
                    value = 0
            else:
                value = 0
            if r[1].dims:
                genfor = For(i(0), i < r[1].dims[0], i.inc())(
                    r[1][i](value)
                )
                s.add(genfor)
            else:
                s.add(r[1](value))


def commands_getoutput(cmd):
    byte_out = subprocess.check_output(cmd.split())
    str_out = byte_out.decode("utf-8")
    return str_out


def bits(n):
    if n < 2:
        return 1
    else:
        return int(ceil(log2(n)))
