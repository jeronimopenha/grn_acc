//
// Created by lucas on 11/08/2021.
//

#ifndef GRN_DEFS_H
#define GRN_DEFS_H

#include <cmath>
#include <algorithm>

#include <acc_config.h>

#define print(x) std::cout << (x) << std::endl

typedef struct mem_conf_t{
    unsigned char mem_conf[MEM_CONF_BYTES];
}mem_conf_t;
    
typedef struct grn_conf_t{
    unsigned char init_state[STATE_SIZE_WORDS * 4];
    unsigned char end_state[STATE_SIZE_WORDS * 4];
}grn_conf_t;


typedef struct grn_data_out_t{
    unsigned int period;
    unsigned int transient;
    unsigned char b_state[STATE_SIZE_WORDS * 4];
    unsigned char i_state[STATE_SIZE_WORDS * 4];
}grn_data_out_t;

#endif //GRN_DEFS_H
