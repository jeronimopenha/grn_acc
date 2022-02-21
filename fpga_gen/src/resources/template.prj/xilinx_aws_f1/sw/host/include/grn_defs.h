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
    unsigned char init_state[STATE_SIZE_WORDS * BUS_WIDTH_BYTES];
    unsigned char end_state[STATE_SIZE_WORDS * BUS_WIDTH_BYTES];
}grn_conf_t;


typedef struct grn_data_out_t{
    unsigned short period;
    unsigned short transient;
    unsigned short core_id;
    unsigned char b_state[OUTPUT_DATA_BYTES - 2 - 2 - 2];
}grn_data_out_t;

#endif //GRN_DEFS_H
