vlib work
vlib msim

vlib msim/processing_system7_bfm_v2_0_5
vlib msim/xil_defaultlib

vmap processing_system7_bfm_v2_0_5 msim/processing_system7_bfm_v2_0_5
vmap xil_defaultlib msim/xil_defaultlib

vlog -work processing_system7_bfm_v2_0_5 -64 -incr "+incdir+../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/2527/hdl" "+incdir+../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/2527/hdl" \
"../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/2527/hdl/processing_system7_bfm_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/2527/hdl" "+incdir+../../../../Zybo.srcs/sources_1/bd/design_ps/ipshared/2527/hdl" \
"../../../bd/design_ps/ip/design_ps_processing_system7_0_0/sim/design_ps_processing_system7_0_0.v" \
"../../../bd/design_ps/hdl/design_ps.v" \

vlog -work xil_defaultlib "glbl.v"
