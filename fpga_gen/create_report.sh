#!/bin/bash

my_dir=$(pwd)
rm -rf report.csv
touch report.csv

for json in $(find . -iname "kernel_util_synthed.json")
do
   cd $(dirname $json)
   rpt=$(find ../../../../../../reports/ -iname "impl_1_xilinx_aws-vu9p-f1_shell-v04261818_201920_2_bb_locked_timing_summary_routed.rpt")
   rpt=$(readlink -f $rpt)
   cd $my_dir
   python3 create_report.py -j $json -t $rpt

done
