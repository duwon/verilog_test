-makelib ies/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/processing_system7_bfm_v2_0_5 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/2527/hdl/processing_system7_bfm_v2_0_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_ps/ip/design_ps_processing_system7_0_0/sim/design_ps_processing_system7_0_0.v" \
  "../../../bd/design_ps/hdl/design_ps.v" \
-endlib
-makelib ies/blk_mem_gen_v8_3_4 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/59b0/simulation/blk_mem_gen_v8_3.v" \
-endlib
-makelib ies/axi_bram_ctrl_v4_0_9 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/d95a/hdl/axi_bram_ctrl_v4_0_rfs.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_ps/ip/design_ps_axi_bram_ctrl_0_0/sim/design_ps_axi_bram_ctrl_0_0.vhd" \
-endlib
-makelib ies/lib_cdc_v1_0_2 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/52cb/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib ies/proc_sys_reset_v5_0_10 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/04b4/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_ps/ip/design_ps_rst_ps7_0_50M_0/sim/design_ps_rst_ps7_0_50M_0.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_ps/ip/design_ps_axi_bram_ctrl_0_bram_0/sim/design_ps_axi_bram_ctrl_0_bram_0.v" \
-endlib
-makelib ies/generic_baseblocks_v2_1_0 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/7ee0/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib ies/fifo_generator_v13_1_2 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/a807/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib ies/fifo_generator_v13_1_2 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/a807/hdl/fifo_generator_v13_1_rfs.vhd" \
-endlib
-makelib ies/fifo_generator_v13_1_2 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/a807/hdl/fifo_generator_v13_1_rfs.v" \
-endlib
-makelib ies/axi_data_fifo_v2_1_9 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/10b8/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib ies/axi_infrastructure_v1_1_0 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/7e3a/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib ies/axi_register_slice_v2_1_10 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/7efe/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib ies/axi_protocol_converter_v2_1_10 \
  "../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/4a8b/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_ps/ip/design_ps_auto_pc_0/sim/design_ps_auto_pc_0.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

