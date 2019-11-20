// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.3 (win64) Build 1682563 Mon Oct 10 19:07:27 MDT 2016
// Date        : Tue Nov 19 23:23:37 2019
// Host        : DUWON-HOME running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/duwon/Documents/GitHub/Zybo/Zybo.srcs/sources_1/ip/blk_mem_1b_1k/blk_mem_1b_1k_stub.v
// Design      : blk_mem_1b_1k
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_4,Vivado 2016.3" *)
module blk_mem_1b_1k(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[9:0],dina[7:0],clkb,enb,addrb[9:0],doutb[7:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [7:0]dina;
  input clkb;
  input enb;
  input [9:0]addrb;
  output [7:0]doutb;
endmodule
