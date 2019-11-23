`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/14 15:58:55
// Design Name: 
// Module Name: blk_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module blk_rx(
	input					i_clk			,
	input					i_reset			,
	input					i_uart_rx		,
	input		[3:0]		i_btn			,
	//output					o_uart_tx		,
	output	reg				o_led			,
	output	reg				o_rx_mem_en		,
	output	reg				o_rx_mem_wen	,	
	output	reg	[9:0]		o_rx_mem_waddr	,
	output	reg	[7:0]		o_rx_mem_wdata	,
	output	reg				o_rx_mem_wdone	,


	output		[39:0]		o_probe
);

    reg 	[7:0]			r_rx_byte 			= 	'd0	;
	reg		[9:0]			r_rx_cnt			= 	'd0	;
	reg		[2:0]			r_rx_dv_delay		=	'd0	;
    wire					w_rx_dv;
    wire 	[7:0]			w_rx_byte;

	wire	[9:0]			w_rx_mem_raddr				;



//////////////////////////////////////////////////////////////////////////////////
// RX test - write memory
//////////////////////////////////////////////////////////////////////////////////	
	always @ (posedge i_clk)  begin
		if(w_rx_dv)
			o_led 			<= 	~o_led;
	end

    always @ (negedge i_reset or posedge i_clk)  begin
		if(!i_reset) begin
			o_rx_mem_waddr 	<=	'd0;
		end
		else begin	
			r_rx_dv_delay[0] <= w_rx_dv;
			r_rx_dv_delay[1] <= r_rx_dv_delay[0];
			r_rx_dv_delay[2] <= r_rx_dv_delay[1];

			if(w_rx_dv) begin
				o_rx_mem_wdata	<= 	w_rx_byte;
				o_rx_mem_en		<=	'd1;
				o_rx_mem_wen	<= 	'd1;
			end

			if(r_rx_dv_delay[2]) begin
				o_rx_mem_en		<=	'd0;
				o_rx_mem_wen	<= 	'd0;
				o_rx_mem_waddr	<= 	o_rx_mem_waddr + 'd1;
				r_rx_cnt		<=	r_rx_cnt + 'd1;
			end
				
			if(r_rx_cnt == 'd10) begin
				r_rx_cnt 		<=	'd0;
				o_rx_mem_wdone	<=	'd1;
				o_rx_mem_waddr	<= 	'd0;
			end
			else
				o_rx_mem_wdone <=	'd0;
		end
    end

	uart_rx 			uart_rx_0 
	(
	.i_Clock    				(i_clk				),
	.i_Rx_Serial				(i_uart_rx			),
	.o_Rx_DV    				(w_rx_dv			),
	.o_Rx_Byte  				(w_rx_byte			)
	);

	
	assign	o_probe[13:12]	=	r_rx_dv_delay;
	assign	o_probe[14]		=	i_reset;
	assign	o_probe[23:16]	=	w_rx_byte;
	assign	o_probe[24]		=	o_rx_mem_wdone	;
	assign	o_probe[25]		=	o_rx_mem_en	;
	assign	o_probe[26]		=	o_rx_mem_wen;
	assign	o_probe[27]		=	i_uart_rx;
	assign	o_probe[31:28]	=	o_rx_mem_waddr;
	assign	o_probe[39:32]	=	o_rx_mem_wdata;



endmodule // 