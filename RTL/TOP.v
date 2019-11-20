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


	assign	clk			=	clk_125mhz;

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
	.clk					(clk				),
	.i_btn					(btn				),
	//.i_uart_tx				(uart_tx			),
	.o_led					(w_led[0]			)
	);

	blk_rx				blk_rx
	(
	.clk					(clk				),
	.i_uart_rx				(uart_rx			),
	.o_uart_tx				(uart_tx			),
	.i_btn					(btn				),
	.o_led					(w_led[1]			),

	.o_probe				(probe_blk_rx		)
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
    

	wire	[39:0]			probe_blk_rx;


    ila 				ila(
    .clk                    (clk				),
    .probe0                 (probe_blk_rx		), //40
    .probe1                 (clk_10mhz			)  //1
    );

endmodule