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
	input					i_clk			,
	input					i_reset			,
	input		[3:0]		i_btn			,
	output					o_uart_tx		,
	output	reg				o_led			,

	output	reg				r_rx_mem_ren	,
	output 	reg	[9:0]		r_rx_mem_raddr	,
	input		[7:0]		i_rx_mem_rdata	,
	input					i_rx_mem_wdone	,
	input		[9:0]		i_rx_mem_byte	,

	output	reg				r_tx_mem_ren	,
	output 	reg	[9:0]		r_tx_mem_raddr	,
	input		[7:0]		i_tx_mem_rdata	,
	input					i_tx_mem_wdone	,
	input		[9:0]		i_tx_mem_byte	,

	output		[39:0]		o_probe
);



//////////////////////////////////////////////////////////////////////////////////
// TX test - send uart
//////////////////////////////////////////////////////////////////////////////////
	reg			[1:0]		r_tx_state		=	'd0	;
	reg			[7:0]		r_tx_byte		=	'd0 ;
	reg						r_tx_dv			=	'd0 ;
	reg			[9:0]		r_tx_addr		=	'd0 ;
	reg			[7:0]		r_tx_data[0:10]			;
	reg			[9:0]		r_uart_tx_len	=	'd0	;

	wire					w_tx_done;
	wire					w_tx_active;


	always @(negedge i_reset or posedge i_clk) begin
		if(!i_reset) begin
			r_uart_tx_len 	<=	'd0;
		end
		else begin
			if(i_rx_mem_wdone)
				r_uart_tx_len	<=	i_rx_mem_byte;
			else if(i_tx_mem_wdone)
				r_uart_tx_len	<=	i_tx_mem_byte;
		end
	end

	parameter s_TX_START 	= 2'b00;
	parameter s_TX_SEND		= 2'b01;
	parameter s_TX_NEXT		= 2'b10;
	parameter s_TX_CLEAR	= 2'b11;

	always @(negedge i_reset or posedge i_clk) begin
		if(!i_reset) begin
			r_tx_addr 	<=	'd0;
		end
		else begin
			case (r_tx_state)
				s_TX_START	: begin
					if(r_rx_mem_rdone || r_tx_mem_rdone) begin
						r_tx_state		<=	s_TX_SEND;
					end
					else
						r_tx_state		<=	s_TX_START;
				end

				s_TX_SEND	: begin
					r_tx_byte 		<= 	r_tx_data[r_tx_addr];
					r_tx_addr		<=	r_tx_addr + 1;
					r_tx_dv			<=  'd1;
					r_tx_state		<=  s_TX_NEXT;
				end

				s_TX_NEXT	: begin
					r_tx_dv			<=	'd0;
					if( w_tx_done) begin
						if(r_tx_addr == r_uart_tx_len )
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
// TX test - read rx memory
//////////////////////////////////////////////////////////////////////////////////
	reg						r_rx_mem_delay			=	'd0	;
	reg			[3:0]		r_rx_mem_rdatacnt 		=	'd0	;
	reg						r_rx_mem_rdone			=	'd0	;
	//reg			[9:0]		r_rx_len				=	'd0	;

	always @(negedge i_reset or posedge i_clk) begin
		if(!i_reset) begin
			r_rx_mem_ren		<=	'd0;
			r_rx_mem_raddr		<=	'd0;
			r_rx_mem_delay		<=	'd0;	
		end
		else begin
			if(i_rx_mem_wdone) begin
				r_rx_mem_ren			<= 	'd1;
				//r_rx_len				<=	i_rx_mem_byte;
			end
			else if (r_rx_mem_ren) begin
				if(r_rx_mem_raddr == r_uart_tx_len)
					r_rx_mem_raddr 			<=	r_uart_tx_len;
				else
					r_rx_mem_raddr			<= r_rx_mem_raddr + 'd1;
			end

			if(r_rx_mem_raddr == 'd1) begin
				r_rx_mem_delay			<=	'd1;
			end

			if (r_rx_mem_delay)begin
				//r_tx_data[r_rx_mem_rdatacnt]	<= i_rx_mem_rdata;
				r_rx_mem_rdatacnt				<= r_rx_mem_rdatacnt + 'd1;

				if( r_rx_mem_rdatacnt == r_uart_tx_len ) begin
					r_rx_mem_rdatacnt 		<=	'd0;
					r_rx_mem_delay			<=	'd0;
					r_rx_mem_ren			<=	'd0;
					r_rx_mem_raddr			<=	'd0;
					r_rx_mem_rdone			<=	1;
				end
			end

			if(r_rx_mem_rdone)
				r_rx_mem_rdone	<=	0;
		end
	end

	always @(negedge i_reset or posedge i_clk) begin
		if(!i_reset) begin	
		end
		else begin
			if(r_rx_mem_delay)
				r_tx_data[r_rx_mem_rdatacnt]	<= i_rx_mem_rdata;
			else if(r_tx_mem_delay)
				r_tx_data[r_tx_mem_rdatacnt]	<= i_tx_mem_rdata;
		end
	end
//////////////////////////////////////////////////////////////////////////////////
// TX test - read tx memory
//////////////////////////////////////////////////////////////////////////////////
	reg						r_tx_mem_delay			=	'd0	;
	reg			[3:0]		r_tx_mem_rdatacnt 		=	'd0	;
	reg						r_tx_mem_rdone			=	'd0	;
	//reg			[9:0]		r_tx_len				=	'd0	;

	always @(negedge i_reset or posedge i_clk) begin
		if(!i_reset) begin
			r_tx_mem_ren		<=	'd0;
			r_tx_mem_raddr		<=	'd0;
			r_tx_mem_delay		<=	'd0;	
		end
		else begin
			if(i_tx_mem_wdone) begin
				r_tx_mem_ren			<= 	'd1;
				//r_uart_tx_len				<=	i_rx_mem_byte;
			end
			else if (r_tx_mem_ren) begin
				if(r_tx_mem_raddr == r_uart_tx_len)
					r_tx_mem_raddr 			<=	r_uart_tx_len;
				else
					r_tx_mem_raddr			<= r_tx_mem_raddr + 'd1;
			end

			if(r_tx_mem_raddr == 'd1) begin
				r_tx_mem_delay			<=	'd1;
			end
			
			if(r_tx_mem_delay) begin
				//r_tx_data[r_tx_mem_rdatacnt]	<= i_tx_mem_rdata;
				r_tx_mem_rdatacnt				<= r_tx_mem_rdatacnt + 'd1;
			

				if(r_tx_mem_delay && (r_tx_mem_rdatacnt == r_uart_tx_len)) begin
					r_tx_mem_rdatacnt 		<=	'd0;
					r_tx_mem_delay			<=	'd0;
					r_tx_mem_ren			<=	'd0;
					r_tx_mem_raddr			<=	'd0;
					r_tx_mem_rdone			<=	1;
				end
			end

			if(r_tx_mem_rdone)
				r_tx_mem_rdone	<=	0;
		end
	end

//////////////////////////////////////////////////////////////////////////////////
// TX test - Send initial value at startup
//////////////////////////////////////////////////////////////////////////////////
    reg 				  	r_tx_done   	= 	'd0	;    
    reg 		[12:0]  	r_serial_cnt 	= 	'd0	;
	reg						r_tx_init_en	=	'd1	;
	reg						r_tx_init_dv	=	'd0	;
	reg			[7:0]		r_tx_init_byte	=	'd33	;

    always @ (negedge i_reset or posedge i_clk) begin
		if(!i_reset) begin
    		r_serial_cnt 	<= 	'd0	;
			r_tx_init_en	<=	'd1	;
			r_tx_init_dv	<=	'd0	;
			r_tx_init_byte	<=	'd33	;
		end
		else begin
			r_tx_done	 	<= 	w_tx_done;
			
			if(r_tx_init_en)
				r_tx_init_dv 		<= 	1'b1;

			if(w_tx_done & ~r_tx_done) begin
				r_tx_init_byte 		<= 	(r_serial_cnt % 107) + 20;
				r_tx_init_dv 		<= 	1'b1;
				r_serial_cnt 		<= 	r_serial_cnt + 1'b1;             
			end

			if(w_tx_active)
				r_tx_init_dv 		<= 	1'b0;

			if(r_serial_cnt == 'd4000) begin
				o_led				<=	~o_led;
				r_serial_cnt		<= 	'd0;
				r_tx_init_en		<=	'd0;
			end
			else
				o_led				<=	o_led;
		end
	end

	wire					w_tx_dv		;
	wire	[7:0]			w_tx_byte	;
	assign	w_tx_dv			=	r_tx_init_en ? r_tx_init_dv : r_tx_dv;
	assign	w_tx_byte		=	r_tx_init_en ? r_tx_init_byte : r_tx_byte;

    uart_tx 				uart_tx_0
    (
	.i_Clock    				(i_clk				),
	.i_Tx_DV    				(w_tx_dv			),
	.i_Tx_Byte  				(w_tx_byte			),
	.o_Tx_Serial				(o_uart_tx			),
	.o_Tx_Done  				(w_tx_done			),
	.o_Tx_Active				(w_tx_active		)
    );



	assign	o_probe[7:0]	=	i_tx_mem_byte;		
	assign	o_probe[8]		=	w_tx_dv;
	assign	o_probe[9]		=	o_uart_tx;
	assign	o_probe[10]		=	w_tx_done;
	assign	o_probe[11]		=	w_tx_active;
	assign	o_probe[12]		=	r_tx_init_en;
	assign	o_probe[16:13]	=	r_serial_cnt;
	assign	o_probe[32:31]	=	r_tx_state;
	assign	o_probe[36:33]	=	r_tx_addr;
	assign	o_probe[21:18]	=	r_tx_mem_rdatacnt;
	assign	o_probe[17]		=	r_rx_mem_rdone;
	assign	o_probe[37]		=	r_tx_mem_rdone;
	assign	o_probe[29:22]	=	r_rx_mem_rdatacnt;
	assign	o_probe[30]		=	i_tx_mem_wdone;
	assign	o_probe[39:38]	=	r_rx_mem_rdatacnt;



endmodule // 