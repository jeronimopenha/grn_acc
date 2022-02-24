//
// Created by lucas on 11/08/2021.
//

#ifndef GRN_DEFS_H
#define GRN_DEFS_H

#include <cmath>
#include <algorithm>

#include <acc_config.h>

#define print(x) std::cout << (x) << std::endl

    
typedef struct grn_conf_t{
    unsigned char init_state[STATE_SIZE_WORDS];
    unsigned char end_state[STATE_SIZE_WORDS];
}grn_conf_t;

typedef struct grn_perf_t{
    unsigned int perf;
    unsigned short core_id;
    unsigned char empty[OUTPUT_DATA_BYTES - 2 - 2 - 2];    
}grn_perf_t;

typedef struct grn_data_out_t{
    unsigned short period;
    unsigned short transient;
    unsigned short core_id;
    unsigned char b_state[OUTPUT_DATA_BYTES - 2 - 2 - 2];
}grn_data_out_t;

#endif //GRN_DEFS_H
