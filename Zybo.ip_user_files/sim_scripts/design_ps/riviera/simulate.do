onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+design_ps -pli "C:/Xilinx/Vivado/2016.3/lib/win64.o/libxil_vsim.dll" -L xil_defaultlib -L xpm -L processing_system7_bfm_v2_0_5 -L blk_mem_gen_v8_3_4 -L axi_bram_ctrl_v4_0_9 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_10 -L generic_baseblocks_v2_1_0 -L fifo_generator_v13_1_2 -L axi_data_fifo_v2_1_9 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_10 -L axi_protocol_converter_v2_1_10 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.design_ps xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {design_ps.udo}

run -all

endsim

quit -force
