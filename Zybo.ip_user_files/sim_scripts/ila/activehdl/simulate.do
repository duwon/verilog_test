onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ila -pli "C:/Xilinx/Vivado/2016.3/lib/win64.o/libxil_vsim.dll" -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ila xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ila.udo}

run -all

endsim

quit -force
