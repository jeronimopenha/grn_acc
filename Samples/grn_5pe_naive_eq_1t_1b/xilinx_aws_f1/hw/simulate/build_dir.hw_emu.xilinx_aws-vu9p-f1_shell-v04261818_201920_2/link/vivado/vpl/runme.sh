#!/bin/sh

# 
# vpl(TM)
# runme.sh: a vpl-generated Runs Script for UNIX
# Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/tools/Xilinx/Vitis/2020.2/bin:/tools/Xilinx/Vitis/2020.2/bin:/tools/Xilinx/Vitis/2020.2/bin
else
  PATH=/tools/Xilinx/Vitis/2020.2/bin:/tools/Xilinx/Vitis/2020.2/bin:/tools/Xilinx/Vitis/2020.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/jeronimocosta/Documentos/GIT/grn_CCPE_2022/grn_5pe_naive_eq_1t_1b/xilinx_aws_f1/hw/simulate/build_dir.hw_emu.xilinx_aws-vu9p-f1_shell-v04261818_201920_2/link/vivado/vpl'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .create_project.begin.rst
EAStep vivado -log vivado.log -applog -m64 -messageDb vivado.pb -mode batch -source vpl.tcl -notrace


