//////////////////////////////////////////////////
//
// Module Name: top
// 
// Author	  : Jamie Jhang
//
// Description: top includes rst_sync2.v & crc.v
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module top (
    // Input signals
	input  wire  	   clk_1,
	input  wire		   clk_2,
	input  wire		   clk_3,
	input  wire		   rst_n,

	input  wire		   in_valid,
	input  wire		   CRC,
	input  wire		   mode,
	input  wire [59:0] message,

	output wire        out_valid,
	output wire[59:0]  out
);
	
//---------------------------------------------------------------------
// instantiate 
//---------------------------------------------------------------------	

wire 		clk1_CRC;
wire 		clk1_mode;
wire 		clk1_flag;
wire [59:0] clk1_message;

wire 		clk2_flag;
wire [59:0] clk2_out;

wire 		rst_n_clk1;
wire 		rst_n_clk2;
wire 		rst_n_clk3;


rst_sync2 i_rst_sync2_clk1 (
	// Input signals
	.clk	   			(clk_1),
	.rst_async 			(rst_n),
	// Output signals	
	.rst_sync  			(rst_n_clk1)
);

clk_1_module i_clk_1_module (
	// Input signals
	.clk_1				(clk_1),
	.in_valid			(in_valid),
	.rst_n				(rst_n_clk1),
	.message			(message),
	.mode				(mode),
	.CRC				(CRC),
	// Output signals
	.clk1_message		(clk1_message),
	.clk1_CRC			(clk1_CRC),
	.clk1_mode			(clk1_mode),
	.clk1_flag			(clk1_flag)
);

rst_sync2 i_rst_sync2_clk2 (
	// Input signals
	.clk	   			(clk_2),
	.rst_async 			(rst_n),
	// Output signals
	.rst_sync  			(rst_n_clk2)
);

clk_2_module i_clk_2_module (
	// Input signals
	.clk_2				(clk_2),
	.rst_n				(rst_n_clk2),
	.clk1_message		(clk1_message),
	.clk1_CRC			(clk1_CRC),
	.clk1_mode			(clk1_mode),
	.clk1_flag			(clk1_flag),
	// Output signals
	.clk2_out			(clk2_out),
	.clk2_flag			(clk2_flag)
);


rst_sync2 i_rst_sync2_clk3 (
	// Input signals
	.clk	   			(clk_3),
	.rst_async 			(rst_n),
	// Output signals
	.rst_sync  			(rst_n_clk3)
);

clk_3_module i_clk_3_module (			
	// Input signals
	.clk_3				(clk_3),
	.rst_n				(rst_n_clk3),
	.clk2_out			(clk2_out),
	.clk2_flag			(clk2_flag),
	// Output signals
	.out_valid			(out_valid),
	.out				(out)
);



endmodule
