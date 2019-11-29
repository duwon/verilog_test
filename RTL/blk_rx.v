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
	output	reg	[9:0]		o_rx_mem_byte	,

	output	reg				o_tx_mem_en		,
	output	reg				o_tx_mem_wen	,	
	output	reg	[9:0]		o_tx_mem_waddr	,
	output	reg	[7:0]		o_tx_mem_wdata	,
	output	reg				o_tx_mem_wdone	,
	output	reg	[9:0]		o_tx_mem_byte	,

	output	reg	[31:0]		o_bram_addr		,
	output	reg	[31:0]		o_bram_din		,
	output	reg				o_bram_en		,
	output	reg	[3:0]		o_bram_we		,

	output		[39:0]		o_probe
);

    wire					w_rx_dv;
    wire 	[7:0]			w_rx_byte;


	reg			[7:0]		r_message[0:100];
	reg			[9:0]		r_msg_addr		=	0;
	reg			[9:0]		r_msg_len		=	0;
	reg			[7:0]		r_msg_chksum	=	0;
	reg			[1:0]		r_msg_state		=	0;

	parameter s_MSG_IDLE	= 'b00;
	parameter s_MSG_FAIL 	= 'b01;
	parameter s_MSG_OK 		= 'b10;
	parameter s_MSG_END 	= 'b11;

	always @(negedge i_reset or posedge i_clk) begin
		if(!i_reset) begin
			o_led				<=	0;
			r_msg_addr			<=	0;
			r_msg_len			<=	0;	
		end
		else begin
			if(w_rx_dv) begin
				r_message[r_msg_addr]	<=	w_rx_byte;
				r_msg_addr				<=	r_msg_addr + 1;

				if((r_msg_addr < 2) || (r_msg_addr < (r_msg_len-2)))
					r_msg_chksum		<=	r_msg_chksum ^ w_rx_byte;

				case (r_msg_addr)
					0: begin
						if(w_rx_byte != 'h30)
							r_msg_state		<=	s_MSG_FAIL;
					end
					1: begin
						if(w_rx_byte != 'h31)
							r_msg_state		<=	s_MSG_FAIL;
					end
					2: begin
						r_msg_len			<=	w_rx_byte;
					end
					(r_msg_len-2): begin
						if(r_msg_chksum != w_rx_byte)
							r_msg_state		<=	s_MSG_FAIL;
					end
					(r_msg_len-1): begin
						if(w_rx_byte != 'h32)
							r_msg_state		<=	s_MSG_FAIL;
						else
							r_msg_state		<=	s_MSG_OK;					
					end
				endcase
			end

			case (r_msg_state)
				s_MSG_FAIL : begin
					r_msg_state				<=	s_MSG_END;
				end
				s_MSG_OK : begin
					o_led					<=	~o_led;
					r_msg_state				<=	s_MSG_END;				
				end
				s_MSG_END : begin
					r_msg_addr				<=	0;
					r_msg_len				<=	0;
					r_msg_chksum			<=	0;
					r_msg_state				<=	s_MSG_IDLE;
				end
			endcase
	
		end
	end
/*
	assign	o_probe[0]		=	i_reset			;
	assign	o_probe[1]		=	i_uart_rx		;
	assign	o_probe[2]		=	o_led			;
	assign	o_probe[3]		=	w_rx_dv			;
	assign	o_probe[11:4]	=	w_rx_byte		;
	assign	o_probe[19:12]	=	r_msg_addr		;
	assign	o_probe[27:20]	=	r_msg_len		;
	assign	o_probe[28]		=	r_msg_start		;
	assign	o_probe[29]		=	r_msg_fail		;
	assign	o_probe[37:30]	=	r_msg_chksum	;
	assign	o_probe[38]		=	r_msg_ok		;
*/

//////////////////////////////////////////////////////////////////////////////////
// RX test - write msg ok data to memory
//////////////////////////////////////////////////////////////////////////////////	
	reg		[9:0]			r_rx_cnt			=	'd0	;
	reg		[9:0]			r_rx_len			=	'd0	;
	reg		[1:0]			r_rx_write_start	=	'd0	;

    always @ (negedge i_reset or posedge i_clk)  begin
		if(!i_reset) begin
			o_rx_mem_waddr 	<=	'd0;
			r_rx_cnt		<=	0;
		end
		else begin	
			r_rx_write_start[1]		<=	r_rx_write_start[0];

			if(r_msg_state == s_MSG_OK) begin
				r_rx_len			<=	r_msg_addr;
				o_rx_mem_wdata		<= 	r_message[0];
				o_rx_mem_waddr		<=	0;
				r_rx_cnt			<=	0;
				o_rx_mem_en			<=	1;
				o_rx_mem_wen		<= 	1;
				r_rx_write_start[0]	<=	1;
			end

			if(r_rx_write_start[1]) begin

				if(o_rx_mem_waddr == r_rx_len) begin
					o_rx_mem_byte		<= 	r_rx_len;
					o_rx_mem_wdone		<=	1;
					o_rx_mem_waddr		<= 	0;
					r_rx_write_start	<=	0;
					r_rx_len			<=	0;
					o_rx_mem_wdata		<=	0;
					r_rx_cnt			<=	0;
					o_rx_mem_en			<=	0;
					o_rx_mem_wen		<= 	0;
				end
				else begin
					o_rx_mem_wdata	<= 	r_message[r_rx_cnt];
					o_rx_mem_waddr	<= 	r_rx_cnt;
					r_rx_cnt		<= 	r_rx_cnt + 1;				
				end
			end
			else
				o_rx_mem_wdone		<=	0;

		end
    end
/*
	assign	o_probe[0]		=	o_rx_mem_en		; 	//i_reset		;
	assign	o_probe[1]		=	i_uart_rx		;
	assign	o_probe[2]		=	o_rx_mem_wdone	;	//o_led			;
	assign	o_probe[3]		=	w_rx_dv			;
	assign	o_probe[11:4]	=	w_rx_byte		;
	assign	o_probe[19:12]	=	r_msg_addr		;
	assign	o_probe[27:20]	=	o_rx_mem_waddr	;	//r_msg_len		;
	assign	o_probe[28]		=	o_rx_mem_wen	;	//r_msg_start	;
	assign	o_probe[37:30]	=	o_rx_mem_wdata	;	//r_msg_chksum	;
	assign	o_probe[39:38]	=	r_msg_state		;
*/
//////////////////////////////////////////////////////////////////////////////////
// RX test - write msg fail data to memory
//////////////////////////////////////////////////////////////////////////////////	
	reg		[9:0]			r_tx_cnt			=	'd0	;
	reg		[9:0]			r_tx_len			=	'd0	;
	reg		[1:0]			r_tx_write_start	=	'd0	;

    always @ (negedge i_reset or posedge i_clk)  begin
		if(!i_reset) begin
			o_tx_mem_waddr 	<=	'd0;
			r_tx_cnt		<=	0;
		end
		else begin	
			r_tx_write_start[1]		<=	r_tx_write_start[0];

			if(r_msg_state == s_MSG_FAIL) begin
				r_tx_len			<=	r_msg_addr;
				o_tx_mem_wdata		<= 	r_message[0];
				o_tx_mem_waddr		<=	0;
				r_tx_cnt			<=	0;
				o_tx_mem_en			<=	1;
				o_tx_mem_wen		<= 	1;
				r_tx_write_start[0]	<=	1;
			end

			if(r_tx_write_start[1]) begin

				if(o_tx_mem_waddr == r_tx_len) begin
					o_tx_mem_byte		<= 	r_tx_len;
					o_tx_mem_wdone		<=	1;
					o_tx_mem_waddr		<= 	0;
					r_tx_write_start	<=	0;
					r_tx_len			<=	0;
					o_tx_mem_wdata		<=	0;
					r_tx_cnt			<=	0;
					o_tx_mem_en			<=	0;
					o_tx_mem_wen		<= 	0;
				end
				else begin
					o_tx_mem_wdata	<= 	r_message[r_tx_cnt];
					o_tx_mem_waddr	<= 	r_tx_cnt;
					r_tx_cnt		<= 	r_tx_cnt + 1;				
				end
			end
			else
				o_tx_mem_wdone		<=	0;

		end
    end


	reg		[9:0]			r_bram_cnt			=	'd0	;
	reg		[9:0]			r_bram_len			=	'd0	;
	reg		[1:0]			r_bram_write_start	=	'd0	;

    always @ (negedge i_reset or posedge i_clk)  begin
		if(!i_reset) begin
		end
		else begin	
			r_bram_write_start[1]		<=	r_bram_write_start[0];

			if(r_msg_state == s_MSG_OK) begin
				r_bram_len			<=	r_msg_addr;
				o_bram_din			<= 	{r_message[3],r_message[2],r_message[1],r_message[0]};
				o_bram_addr			<=	0;
				r_bram_cnt			<=	0;
				o_bram_en			<=	1;
				o_bram_we			<= 	'b1111;
				r_bram_write_start[0]	<=	1;
			end

			if(r_bram_write_start[1]) begin

				if(r_bram_cnt > r_bram_len) begin
					o_bram_din			<= 	0;
					r_bram_write_start	<=	0;
					r_bram_len			<=	0;
					o_bram_din			<=	0;
					r_bram_cnt			<=	0;
					o_bram_en			<=	0;
					o_bram_we			<= 	0;
				end
				else begin
					o_bram_din		<= 	{r_message[r_bram_cnt+3],r_message[r_bram_cnt+2],r_message[r_bram_cnt+1],r_message[r_bram_cnt]};
					o_bram_addr		<= 	r_bram_cnt;
					r_bram_cnt		<= 	r_bram_cnt + 4;				
				end
			end

		end
	end








	assign	o_probe[0]		=	i_reset		; 	//i_reset		;
	assign	o_probe[1]		=	i_uart_rx		;
	assign	o_probe[2]		=	o_tx_mem_wdone	;	//o_led			;
	assign	o_probe[3]		=	w_rx_dv			;
	assign	o_probe[11:4]	=	w_rx_byte		;
	assign	o_probe[19:12]	=	r_msg_addr		;
	assign	o_probe[27:20]	=	r_msg_len	;	//r_msg_len		;
	//assign	o_probe[28]		=	
	assign	o_probe[37:30]	=	r_msg_chksum	;	//r_msg_chksum	;
	assign	o_probe[39:38]	=	r_msg_state		;

	uart_rx 			uart_rx_0 
	(
	.i_Clock    				(i_clk				),
	.i_Rx_Serial				(i_uart_rx			),
	.o_Rx_DV    				(w_rx_dv			),
	.o_Rx_Byte  				(w_rx_byte			)
	);




endmodule // 