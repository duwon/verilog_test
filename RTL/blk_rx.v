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
	input					reset			,
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
	reg		[9:0]			r_rx_mem_waddr		= 	'd0	;
	wire	[7:0]			w_rx_mem_w_data				;

	wire					w_rx_mem_ren				;
	wire	[9:0]			w_rx_mem_raddr				;
	wire	[7:0]			w_rx_mem_rdata				;

	reg		[9:0]			r_rx_mem_raddr		=	'd0	;


	assign 	w_rx_mem_w_addr	=	r_Rx_Cnt - 1;
	assign	w_rx_mem_w_data	=	r_Rx_Byte;
	assign 	r_rx_mem_r_en	= 	r_rx_mem_w_done ;
	assign	w_rx_mem_r_addr	= 	r_rx_mem_raddr;
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
	reg		[1:0]			r_tx_state		=	'd0	;
	reg		[7:0]			r_tx_byte		=	'd0 ;
	reg						r_tx_DV			=	'd0 ;
	reg		[3:0]			r_tx_addr		=	'd0 ;
	integer					copy_index				;

	wire					w_tx_Done;
	wire					w_tx_active;

	parameter s_TX_START 	= 2'b00;
	parameter s_TX_SEND		= 2'b01;
	parameter s_TX_NEXT		= 2'b10;
	parameter s_TX_CLEAR	= 2'b11;

	always @(negedge reset or posedge clk) begin
		if(!reset) begin
		end
		else begin
			case (r_tx_state)
				s_TX_START	: begin
					if(r_mem_state ==s_MEM_CLEAR)
						r_tx_state		<=	s_TX_SEND;
					else
						r_tx_state		<=	s_TX_START;
				end

				s_TX_SEND	: begin
					r_tx_byte 		<= 	r_tx_data[r_tx_addr];
					r_tx_addr		<=	r_tx_addr + 1;
					r_tx_DV			<=  'd1;
					r_tx_state		<=  s_TX_NEXT;
				end

				s_TX_NEXT	: begin
					r_tx_DV			<=	'd0;
					if( w_tx_Done == 1) begin
						if(r_tx_addr == 10) begin
							r_tx_addr		<=	'd0;
							r_tx_state		<=	s_TX_CLEAR;
						end
						else 
							r_tx_state		<= 	s_TX_SEND;
					end
					else
						r_tx_state		<=  s_TX_NEXT;
				end

				s_TX_CLEAR	: begin
					r_tx_state		<=  s_TX_START;
				end
            endcase
		end
	end

	
	reg		[7:0]			r_tx_data[0:10]					;
	reg		[1:0]			r_mem_state			=	'd0		;
	reg						r_rx_mem_ren		=	'd0		;
	parameter s_MEM_START 	= 2'b00;
	parameter s_MEM_READ_S	= 2'b01;
	parameter s_MEM_READ_E	= 2'b10;
	parameter s_MEM_CLEAR	= 2'b11;

	always @(negedge reset or posedge clk) begin
		if(!reset) begin
		end
		else begin
			case (r_mem_state)
				s_MEM_START : begin
					if(r_Rx_Cnt == 'd10) begin
						r_mem_state		<=	s_MEM_READ_S;
						r_rx_mem_ren	<= 'd1;
					end
					else
						r_mem_state		<=	s_MEM_START;
				end

				s_MEM_READ_S : begin
					if(r_rx_mem_raddr == 10)
						r_mem_state		<= 	s_MEM_CLEAR;
					else
						r_mem_state		<= 	s_MEM_READ_E;
				end

				s_MEM_READ_E : begin
					r_rx_mem_raddr					<= r_rx_mem_raddr + 'd1;
					r_tx_data[r_rx_mem_raddr]		<= w_rx_mem_rdata;
					r_mem_state		<= 	s_MEM_READ_S;
				end

				s_MEM_CLEAR : begin
					r_rx_mem_raddr	<= 'd0;
					r_mem_state		<= 	s_MEM_START;
				end
			endcase
		end
	end

    uart_tx 			uart_tx_1
    (
	.i_Clock    				(clk				),
	.i_Tx_DV    				(r_tx_DV			),
	.i_Tx_Byte  				(r_tx_byte			),
	.o_Tx_Serial				(o_uart_tx			),
	.o_Tx_Done  				(w_tx_Done			),
	.o_Tx_Active				(w_tx_active		)
    );	

	blk_mem_1b_1k		blk_mem_rx
	(
	.clka 						(clk				),
	.ena 						(r_rx_mem_en		),
	.wea 						(r_rx_mem_w_en		),
	.addra						(r_rx_mem_waddr		),
	.dina 						(w_rx_mem_w_data	),
	.clkb						(clk				),
	.enb						(r_rx_mem_ren		),
	.addrb						(r_rx_mem_raddr		),
	.doutb						(w_rx_mem_rdata		)
	);


	assign	o_probe[0]		=	o_uart_tx;
	assign	o_probe[1]		=	r_rx_mem_en;
	assign	o_probe[2]		=	w_Rx_DV;
	assign	o_probe[12:3]	=	r_rx_mem_raddr;
	assign	o_probe[20:13]	=	w_rx_mem_rdata;
	assign	o_probe[21]		=	r_rx_mem_ren;
	assign	o_probe[22]		=	r_rx_mem_w_done;
	assign	o_probe[23]		=	w_tx_Done;
	assign	o_probe[25:24]	=	r_tx_state;
	assign	o_probe[27:26]	=	r_mem_state;
	assign	o_probe[39:32]	=	r_tx_data[0];

endmodule // 