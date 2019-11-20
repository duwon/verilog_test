`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/14 15:58:55
// Design Name: 
// Module Name: blk_rx
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

module blk_tx(
	input					clk			,
	input		[3:0]		i_btn		,
	output					i_uart_tx	,
	output	reg				o_led
);

    reg 		[7:0]   	r_Tx_Byte   		= 'd0	;
    reg 		        	r_Tx_DV     		= 'b1	;
    reg 				  	r_Tx_Done   		= 'd0	;    
    wire		        	w_Tx_Done					;
	wire					w_Tx_Active					;

    reg 		[12:0]  	r_Serial_Cnt 		= 'd0	;


    always @ (posedge clk) begin
		r_Tx_Done	 	<= 	w_Tx_Done;
		
		if(w_Tx_Done & ~r_Tx_Done) begin
			r_Tx_Byte 		<= 	r_Tx_Byte + 1'b1;
			r_Tx_DV 		<= 	1'b1;
			r_Serial_Cnt 	<= 	r_Serial_Cnt + 1'b1;             
		end

		if(w_Tx_Active)
			r_Tx_DV 		<= 	1'b0;

		if(r_Serial_Cnt == 'd1152) begin
			o_led			<=	~o_led;
			r_Serial_Cnt	<= 	'd0;
		end
		else
			o_led			<=	o_led;
	end


    uart_tx 				uart_tx_0
    (
	.i_Clock    				(clk				),
	.i_Tx_DV    				(r_Tx_DV			),
	.i_Tx_Byte  				(r_Tx_Byte			),
	.o_Tx_Serial				(uart_tx			),
	.o_Tx_Done  				(w_Tx_Done			),
	.o_Tx_Active				(w_Tx_Active		)
    );

endmodule // 