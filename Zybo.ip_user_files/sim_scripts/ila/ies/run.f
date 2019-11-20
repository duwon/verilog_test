-makelib ies/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../Zybo.srcs/sources_1/ip/ila/sim/ila.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

