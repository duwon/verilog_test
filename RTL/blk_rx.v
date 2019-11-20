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
	input					clk				,
	input					i_uart_rx		,
	input		[3:0]		i_btn			,
	output					o_uart_tx		,
	output	reg				o_led			,
	output		[39:0]		o_probe
);

    reg 	[7:0]			r_Rx_Byte 			= 	'd0	;
	reg		[9:0]			r_Rx_Cnt			= 	'd0	;
	reg		[2:0]			r_Rx_DV_delay		=	'd0	;
    wire					w_Rx_DV;
    wire 	[7:0]			w_Rx_Byte;

	reg						r_rx_mem_w_done		=	'd0	;
	reg						r_rx_mem_en	;
	reg						r_rx_mem_w_en		= 	'd0	;	
	wire	[9:0]			w_rx_mem_w_addr		= 	'd0	;
	wire	[7:0]			w_rx_mem_w_data				;

	wire					w_rx_mem_r_en				;
	wire	[9:0]			w_rx_mem_r_addr				;
	wire	[7:0]			w_rx_mem_r_data				;

	reg		[9:0]			r_rx_mem_r_addr		=	'd0	;


	assign 	w_rx_mem_w_addr	=	r_Rx_Cnt - 1;
	assign	w_rx_mem_w_data	=	r_Rx_Byte;
	assign 	r_rx_mem_r_en	= 	r_rx_mem_w_done ;
	assign	w_rx_mem_r_addr	= 	r_rx_mem_r_addr;
	assign 	w_rx_mem_r_en	=	r_rx_mem_en;

	
    always @ (posedge clk)  begin
		r_Rx_DV_delay[0] <= w_Rx_DV;
		r_Rx_DV_delay[1] <= r_Rx_DV_delay[0];
		r_Rx_DV_delay[2] <= r_Rx_DV_delay[1];

		if(w_Rx_DV == 1) begin
			o_led 			<= 	~o_led;
			r_Rx_Byte 		<= 	w_Rx_Byte;
			r_rx_mem_en		<=	'd1;
			r_rx_mem_w_en	<= 	'd1;
		end

		if(r_Rx_Cnt == 'd10) begin
			r_Rx_Cnt 		<=	'd0;
		end

		if(r_Rx_DV_delay[2]) begin
			r_rx_mem_en		<=	'd0;
			r_rx_mem_w_en	<= 	'd0;
			r_rx_mem_w_done	<=	'd1;
			r_rx_mem_waddr	<= 	r_rx_mem_waddr + 'd1;
		end
		else
			r_rx_mem_w_done <=	'd0;
    end

	uart_rx 			uart_rx_0 
	(
	.i_Clock    				(clk				),
	.i_Rx_Serial				(i_uart_rx			),
	.o_Rx_DV    				(w_Rx_DV			),
	.o_Rx_Byte  				(w_Rx_Byte			)
	);

//////////////////////////////////////////////////////////////////////////////////
// TX test
//////////////////////////////////////////////////////////////////////////////////
    reg 		[7:0]   	r_Tx_Byte   		= 'd0	;
    reg 		        	r_Tx_DV     		= 'b1	;
    reg 				  	r_Tx_Done   		= 'd0	;    
    wire		        	w_Tx_Done					;
	wire					w_Tx_Active					;
	
	reg		[7:0]			r_tx_data[0:10]				;

	always @ (posedge clk)  begin
		if(r_rx_mem_w_done) begin
			r_rx_mem_r_addr	<=	r_rx_mem_r_addr + 'd1;

		end

		if(r_rx_mem_r_addr == 10) begin
			r_rx_mem_r_addr	<=	'd0;
			
		end
	end

    uart_tx 			uart_tx_1
    (
	.i_Clock    				(clk				),
	.i_Tx_DV    				(r_Tx_DV			),
	.i_Tx_Byte  				(r_Tx_Byte			),
	.o_Tx_Serial				(o_uart_tx			),
	.o_Tx_Done  				(w_Tx_Done			),
	.o_Tx_Active				(w_Tx_Active		)
    );	

	blk_mem_1b_1k	blk_mem_rx
	(
	.clka 						(clk				),
	.ena 						(r_rx_mem_en		),
	.wea 						(r_rx_mem_w_en		),
	.addra						(r_rx_mem_waddr		),
	.dina 						(w_rx_mem_w_data	),
	.clkb						(clk				),
	.enb						(r_rx_mem_r_en		),
	.addrb						(w_rx_mem_r_addr	),
	.doutb						(w_rx_mem_r_data	)
	);


	assign	o_probe[0]		=	i_uart_rx;
	assign	o_probe[1]		=	r_rx_mem_en;
	assign	o_probe[2]		=	w_Rx_DV;
	assign	o_probe[12:3]	=	r_rx_mem_waddr;
	assign	o_probe[20:13]	=	w_rx_mem_w_data;
	assign	o_probe[21]		=	r_rx_mem_w_en;
	assign	o_probe[31:22]	=	w_rx_mem_r_addr;
	assign	o_probe[39:32]	=	w_Rx_Byte;

endmodule // 