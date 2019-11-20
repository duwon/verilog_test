onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "C:/Xilinx/Vivado/2016.3/lib/win64.o/libxil_vsim.dll" -L xil_defaultlib -L xpm -L blk_mem_gen_v8_3_4 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.blk_mem_1b_1k xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {blk_mem_1b_1k.udo}

run -all

quit -force
