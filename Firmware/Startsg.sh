#!/bin/bash
export MATLAB=/usr/local/matlabR2009a
export XILINX=/opt/Xilinx/11.1/ISE
export XILINX_EDK=/opt/Xilinx/11.1/EDK
export PLATFORM=lin64
export XILINX_DSP=/opt/Xilinx/11.1/DSP_Tools/${PLATFORM}
export BEE2_XPS_LIB_PATH=/home/sean/bwrc/xps_lib
export MLIB_ROOT=/home/sean/bwrc
export PATH=${XILINX}/bin/${PLATFORM}:${XILINX_EDK}/bin/${PLATFORM}:${PATH}
export LD_LIBRARY_PATH=${XILINX}/bin/${PLATFORM}:${XILINX}/lib/${PLATFORM}:${XILINX_DSP}/sysgen/lib:${LD_LIBRARY_PATH}
export LMC_HOME=${XILINX}/smartmodel/${PLATFORM}/installed_lin
export PATH=${LMC_HOME}/bin:${XILINX_DSP}/common/bin:${PATH}
export INSTALLMLLOC=/usr/local/hdl/matlab
export TEMP=/tmp/
export TMP=/tmp/
$MATLAB/bin/matlab

