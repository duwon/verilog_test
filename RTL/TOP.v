`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/14 15:58:55
// Design Name: 
// Module Name: TOP
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


module TOP(
    inout       [14:0]      DDR_addr,
    inout       [2:0]       DDR_ba,
    inout                   DDR_cas_n,
    inout                   DDR_ck_n,
    inout                   DDR_ck_p,
    inout                   DDR_cke,
    inout                   DDR_cs_n,
    inout       [3:0]       DDR_dm,
    inout       [31:0]      DDR_dq,
    inout       [3:0]       DDR_dqs_n,
    inout       [3:0]       DDR_dqs_p,
    inout                   DDR_odt,
    inout                   DDR_ras_n,
    inout                   DDR_reset_n,
    inout                   DDR_we_n,
    inout                   FIXED_IO_ddr_vrn,
    inout                   FIXED_IO_ddr_vrp,
    inout       [53:0]      FIXED_IO_mio,
    inout                   FIXED_IO_ps_clk,
    inout                   FIXED_IO_ps_porb,
    inout                   FIXED_IO_ps_srstb,

    input                   clk_125mhz,
    output                  uart_tx,
    input                   uart_rx,
    input       [3:0]       btn,
    input       [3:0]       sw,
    output      [3:0]       led
    );
    

    reg 				   	r_clk_led 			= 'd0	;
	reg    		[26:0]  	r_clk_cnt			= 'd0	;    

	wire					clk							;
	wire					clk_ps_50mhz				;

	wire		[3:0]		w_led						;
    wire                    reset                       ;

    wire                    w_rx_mem_en	                ;
    wire                    w_rx_mem_wen                ;	
    wire        [9:0]       w_rx_mem_waddr              ;	
    wire        [7:0]       w_rx_mem_wdata              ;	
    wire                    w_rx_mem_ren                ;	
    wire        [9:0]       w_rx_mem_raddr              ;	
    wire        [7:0]       w_rx_mem_rdata              ;
	wire					w_rx_mem_wdone				;
	wire		[9:0]		w_rx_mem_byte				;

    wire                    w_tx_mem_en	                ;
    wire                    w_tx_mem_wen                ;	
    wire        [9:0]       w_tx_mem_waddr              ;	
    wire        [7:0]       w_tx_mem_wdata              ;	
    wire                    w_tx_mem_ren                ;	
    wire        [9:0]       w_tx_mem_raddr              ;	
    wire        [7:0]       w_tx_mem_rdata              ;
	wire					w_tx_mem_wdone				;
	wire		[9:0]		w_tx_mem_byte				;

	assign	clk			=	clk_125mhz;
    assign  reset       =   ~btn[0];
    assign 	led[3:0] 	= 	{btn[3], r_clk_led, w_led[1:0]};
	
	always @ (posedge clk) begin
	   r_clk_cnt 		<= 	r_clk_cnt + 'd1;
	   
	   if(r_clk_cnt == 'd125000000) begin
			r_clk_cnt		<= 	'd0;
			r_clk_led		<=	~r_clk_led;
	   end
	end


	blk_tx				blk_tx
	(
	.i_clk					(clk				),
	.i_reset				(reset              ),
	.i_btn					(btn				),
	.o_uart_tx				(uart_tx			),
	.o_led					(w_led[0]			),

	.r_rx_mem_ren			(w_rx_mem_ren		),
	.r_rx_mem_raddr			(w_rx_mem_raddr		),
	.i_rx_mem_rdata			(w_rx_mem_rdata		),
	.i_rx_mem_wdone			(w_rx_mem_wdone		),
	.i_rx_mem_byte			(w_rx_mem_byte		),

	.r_tx_mem_ren			(w_tx_mem_ren		),
	.r_tx_mem_raddr			(w_tx_mem_raddr		),
	.i_tx_mem_rdata			(w_tx_mem_rdata		),
	.i_tx_mem_wdone			(w_tx_mem_wdone		),
	.i_tx_mem_byte			(w_tx_mem_byte		),

	.o_probe				(probe_blk_tx		)
	);

	blk_rx				blk_rx
	(
	.i_clk					(clk	    		),
    .i_reset				(reset              ),
	.i_uart_rx				(uart_rx			),
	.i_btn					(btn				),
	.o_led					(w_led[1]			),
	.o_rx_mem_en			(w_rx_mem_en		),	
	.o_rx_mem_wen			(w_rx_mem_wen		),	
	.o_rx_mem_waddr			(w_rx_mem_waddr		),
	.o_rx_mem_wdata			(w_rx_mem_wdata		),
	.o_rx_mem_wdone			(w_rx_mem_wdone		),
	.o_rx_mem_byte			(w_rx_mem_byte		),
	
	.o_tx_mem_en			(w_tx_mem_en		),
	.o_tx_mem_wen			(w_tx_mem_wen		),
	.o_tx_mem_waddr			(w_tx_mem_waddr		),
	.o_tx_mem_wdata			(w_tx_mem_wdata		),
	.o_tx_mem_wdone			(w_tx_mem_wdone		),
	.o_tx_mem_byte			(w_tx_mem_byte		),

	.o_probe				(probe_blk_rx		)
	);

	blk_mem_1b_1k		blk_mem_rx
	(
	.clka 					(clk				),
	.ena 					(w_rx_mem_en		),
	.wea 					(w_rx_mem_wen		),
	.addra					(w_rx_mem_waddr		),
	.dina 					(w_rx_mem_wdata		),
	.clkb					(clk				),
	.enb					(w_rx_mem_ren		),
	.addrb					(w_rx_mem_raddr		),
	.doutb					(w_rx_mem_rdata		)
	);

	blk_mem_1b_1k		blk_mem_tx
	(
	.clka 					(clk				),
	.ena 					(w_tx_mem_en		),
	.wea 					(w_tx_mem_wen		),
	.addra					(w_tx_mem_waddr		),
	.dina 					(w_tx_mem_wdata		),
	.clkb					(clk				),
	.enb					(w_tx_mem_ren		),
	.addrb					(w_tx_mem_raddr		),
	.doutb					(w_tx_mem_rdata		)
	);

    design_ps_wrapper 	ps_top
    (
    .DDR_addr         		(DDR_addr           ),
    .DDR_ba           		(DDR_ba             ), 
    .DDR_cas_n        		(DDR_cas_n          ),
    .DDR_ck_n         		(DDR_ck_n           ),
    .DDR_ck_p         		(DDR_ck_p           ),
    .DDR_cke          		(DDR_cke            ),
    .DDR_cs_n         		(DDR_cs_n           ),
    .DDR_dm           		(DDR_dm             ), 
    .DDR_dq           		(DDR_dq             ), 
    .DDR_dqs_n        		(DDR_dqs_n          ),
    .DDR_dqs_p        		(DDR_dqs_p          ),
    .DDR_odt          		(DDR_odt            ),
    .DDR_ras_n        		(DDR_ras_n          ),
    .DDR_reset_n      		(DDR_reset_n        ),
    .DDR_we_n         		(DDR_we_n           ),
    .FIXED_IO_ddr_vrn 		(FIXED_IO_ddr_vrn   ),
    .FIXED_IO_ddr_vrp 		(FIXED_IO_ddr_vrp   ),
    .FIXED_IO_mio     		(FIXED_IO_mio       ),
    .FIXED_IO_ps_clk  		(FIXED_IO_ps_clk    ),
    .FIXED_IO_ps_porb 		(FIXED_IO_ps_porb   ),
    .FIXED_IO_ps_srstb		(FIXED_IO_ps_srstb  ),
    .clk_ps_50mhz			(clk_ps_50mhz		)
    );

	clk_wiz_0			clk_wiz
	(
	.clk_out1				(clk_20mhz			),
	.clk_out2				(clk_10mhz			),
	.clk_in1				(clk_125mhz			)
	);	
    

	wire		[39:0]		probe_blk_rx;
	wire		[39:0]		probe_blk_tx;
	wire		[49:0]		probe_top;

	assign probe_top[0]			=	uart_rx						;
	assign probe_top[1]			=	w_rx_mem_en	                ;
	assign probe_top[2]			=	w_rx_mem_wen                ;	
	assign probe_top[3]			=	w_rx_mem_ren                ;	
	assign probe_top[4]			=	w_rx_mem_wdone				;
	assign probe_top[12:5]		=	w_tx_mem_wdata              ;	
	assign probe_top[20:13]		=	w_tx_mem_waddr              ;	
	assign probe_top[28:21]		=	w_tx_mem_raddr              ;	
	assign probe_top[36:29]		=	w_tx_mem_rdata              ;
	assign probe_top[44:37]		=	w_tx_mem_byte				;
    assign probe_top[45]		=	w_tx_mem_en	                ;
    assign probe_top[46]		=	w_tx_mem_wen                ;	
    assign probe_top[47]		=	w_tx_mem_ren                ;	
	assign probe_top[48]		=	w_tx_mem_wdone				;
	assign probe_top[49]		=	uart_tx						;

    ila 				ila
	(
    .clk                    (clk				),
    .probe0                 (probe_blk_rx		),	//40
    .probe1                 (probe_blk_tx		),	//40
	.probe2					(probe_top			)	//50
    );

endmodule