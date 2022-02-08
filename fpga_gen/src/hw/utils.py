from veriloggen import *
from math import ceil
from grn2dot.grn2dot import Grn2dot

def state(val,size):
    return format(val,"0%dx"%size)

def generate_grn_mem_config(grn_content: Grn2dot, default_bus_width=32):
    num_nos = grn_content.get_num_nodes()
    num_states = 1 << num_nos
    num_copies = 1
    num_states = min(2 ** num_nos, num_states)

    l = int(ceil(num_nos / 32) * 4) * 2

    state_per_copie = int(num_states / num_copies)
    state_rest = int(num_states % num_copies)
    init = 0
    states = [(0, 0, 0) for _ in range(num_copies)]

    for c in range(num_copies):
        if state_rest > 0:
            states[c] = (init, init + state_per_copie, state_per_copie + 1)
            init += state_per_copie + 1
            state_rest -= 1
        else:
            states[c] = (init, init + state_per_copie - 1, state_per_copie)
            init += state_per_copie

    for c in range(num_copies):
        i, e, s = states[c]
        print("%d,%s,%s,%d\n" % (c, state(c, l), state(num_states, l), s))

    '''
    config_string = ""
    init_state = ""
    end_state = ""
    eq_bits = 0
    for g in grn_content.get_grn_mem_specifications():
        eq_bits = eq_bits + int(pow(2, len(g[2])))
    total_eq_bits = (ceil(eq_bits / default_bus_width) * default_bus_width)

    for i in range(grn_content.get_nodes_vector()):


    #config_bits = (ceil(grn_content.get_num_nodes() / default_bus_width) * default_bus_width * 2) + (
                ceil(eq_bits / default_bus_width) * default_bus_width)
    '''


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
