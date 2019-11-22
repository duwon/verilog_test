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

    reg 	[7:0]			r_rx_byte 			= 	'd0	;
	reg		[9:0]			r_Rx_Cnt			= 	'd0	;
	reg		[2:0]			r_Rx_DV_delay		=	'd0	;
    wire					w_Rx_DV;
    wire 	[7:0]			w_Rx_Byte;

	reg						r_rx_mem_w_done		=	'd0	;
	reg						r_rx_mem_en	;
	reg						r_rx_mem_w_en		= 	'd0	;	
	reg		[9:0]			r_rx_mem_waddr		= 	'd0	;

	reg						r_rx_mem_ren				;
	wire	[9:0]			w_rx_mem_raddr				;
	wire	[7:0]			w_rx_mem_rdata				;

	reg		[9:0]			r_rx_mem_raddr		=	'd0	;


//////////////////////////////////////////////////////////////////////////////////
// RX test - write memory
//////////////////////////////////////////////////////////////////////////////////	
    always @ (posedge clk)  begin
		r_Rx_DV_delay[0] <= w_Rx_DV;
		r_Rx_DV_delay[1] <= r_Rx_DV_delay[0];
		r_Rx_DV_delay[2] <= r_Rx_DV_delay[1];

		if(w_Rx_DV == 1) begin
			o_led 			<= 	~o_led;
			r_rx_byte 		<= 	w_Rx_Byte;
			r_rx_mem_en		<=	'd1;
			r_rx_mem_w_en	<= 	'd1;
		end

		if(r_Rx_DV_delay[2]) begin
			r_rx_mem_en		<=	'd0;
			r_rx_mem_w_en	<= 	'd0;
			r_rx_mem_waddr	<= 	r_rx_mem_waddr + 'd1;
			r_Rx_Cnt		<=	r_Rx_Cnt + 'd1;
		end
			
		if(r_Rx_Cnt == 'd10) begin
			r_Rx_Cnt 		<=	'd0;
			r_rx_mem_w_done	<=	'd1;
			r_rx_mem_waddr	<= 	'd0;
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
// TX test - send uart
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
			r_tx_addr 	<=	'd0;
		end
		else begin
			case (r_tx_state)
				s_TX_START	: begin
					if(r_rx_mem_rdatacnt == 'd9)
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
						if(r_tx_addr == 10)
							r_tx_state		<=	s_TX_CLEAR;
						else 
							r_tx_state		<= 	s_TX_SEND;
					end
					else
						r_tx_state		<=  s_TX_NEXT;
				end

				s_TX_CLEAR	: begin
					r_tx_addr		<=	'd0;
					r_tx_state		<=  s_TX_START;
				end
            endcase
		end
	end

//////////////////////////////////////////////////////////////////////////////////
// TX test - read memory
//////////////////////////////////////////////////////////////////////////////////
	
	reg		[7:0]			r_tx_data[0:10]					;
	reg						r_rx_mem_delay			=	'd0	;
	reg		[3:0]			r_rx_mem_rdatacnt 		=	'd0	;

	always @(negedge reset or posedge clk) begin
		if(!reset) begin
			r_rx_mem_ren		<=	'd0;
			r_rx_mem_raddr		<=	'd0;
			r_rx_mem_delay		<=	'd0;		
		end
		else begin
			if(r_rx_mem_w_done) begin
				r_rx_mem_ren			<= 	'd1;
			end
			else if (r_rx_mem_ren) begin
				if(r_rx_mem_raddr == 'd9)
					r_rx_mem_raddr 			<=	'd9;
				else
					r_rx_mem_raddr			<= r_rx_mem_raddr + 'd1;
			end

			if(r_rx_mem_raddr == 'd1) begin
				r_rx_mem_delay			<=	'd1;
			end
			else if (r_rx_mem_delay)begin
				r_tx_data[r_rx_mem_rdatacnt]	<= w_rx_mem_rdata;
				r_rx_mem_rdatacnt				<= r_rx_mem_rdatacnt + 'd1;
			end

			if(r_rx_mem_rdatacnt == 'd9) begin
				r_rx_mem_rdatacnt 	<=	'd0;
				r_rx_mem_delay			<=	'd0;
				r_rx_mem_ren			<=	'd0;
				r_rx_mem_raddr			<=	'd0;
			end
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
	.dina 						(r_rx_byte			),
	.clkb						(clk				),
	.enb						(r_rx_mem_ren		),
	.addrb						(r_rx_mem_raddr		),
	.doutb						(w_rx_mem_rdata		)
	);

	assign	o_probe[7:0]	=	w_rx_mem_rdata;		
	assign	o_probe[11:8]	=	r_rx_mem_raddr[3:0];
	assign	o_probe[13:12]	=	r_Rx_DV_delay;
	assign	o_probe[14]		=	reset;
	assign	o_probe[15]		=	r_rx_mem_ren;
	assign	o_probe[23:16]	=	w_Rx_Byte;
	assign	o_probe[24]		=	r_rx_mem_w_done	;
	assign	o_probe[25]		=	r_rx_mem_en	;
	assign	o_probe[26]		=	r_rx_mem_w_en;
	assign	o_probe[27]		=	i_uart_rx;
	assign	o_probe[28]		=	o_uart_tx;
	//assign	o_probe[30:29]	=	r_mem_state;
	assign	o_probe[31]		=	r_tx_state[0];
	assign	o_probe[39:32]	=	r_tx_data[0];


endmodule // 