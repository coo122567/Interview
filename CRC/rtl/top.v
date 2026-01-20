//////////////////////////////////////////////////
//
// Module Name: top
// 
// Author	  : Jamie Jhang
//
// Description: top includes rst_sync.v & crc.v
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module top #( parameter pSTAGES = 2  // No. of flip flops
 		    )
(
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
	output wire [59:0] out
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

wire        clk2_pls;
wire        clk3_pls;

wire 		rst_n_clk1;
wire 		rst_n_clk2;
wire 		rst_n_clk3;


rst_sync #( .pSTAGES(pSTAGES)
          )
i_rst_sync_clk1 (
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


pulse_sync #( .pSTAGES(pSTAGES)
            )
i_pulse_sync_clk1 (
	.a_clk  (clk_1),
	.b_clk  (clk_2),
	.a_rst_n(rst_n_clk1),
	.b_rst_n(rst_n_clk2),
	.a_pls  (clk1_flag),
	.b_pls  (clk2_pls)
);

rst_sync #( .pSTAGES(pSTAGES)
          )
i_rst_sync_clk2 (
	// Input signals
	.clk	   			(clk_2),
	.rst_async 			(rst_n),
	// Output signals
	.rst_sync  			(rst_n_clk2)
);

clk_2_module #( .pSTAGES(pSTAGES)
              )   
i_clk_2_module (
	// Input signals
	.clk_2				(clk_2),
	.rst_n				(rst_n_clk2),
	.clk1_message		(clk1_message),
	.clk1_CRC			(clk1_CRC),
	.clk1_mode			(clk1_mode),
	.clk1_flag			(clk2_pls),
	// Output signals
	.clk2_out			(clk2_out),
	.clk2_flag			(clk2_flag)
);

pulse_sync #( .pSTAGES(pSTAGES)
            )
i_pulse_sync_clk2 (
	// Input signals
	.a_clk  (clk_2),
	.b_clk  (clk_3),
	.a_rst_n(rst_n_clk2),
	.b_rst_n(rst_n_clk3),
	.a_pls  (clk2_flag),
	// Output signals
	.b_pls  (clk3_pls)
);

rst_sync #( .pSTAGES(pSTAGES)
          )
i_rst_sync_clk3 (
	// Input signals
	.clk	   			(clk_3),
	.rst_async 			(rst_n),
	// Output signals
	.rst_sync  			(rst_n_clk3)
);

clk_3_module #( .pSTAGES(pSTAGES)
              )
i_clk_3_module (			
	// Input signals
	.clk_3				(clk_3),
	.rst_n				(rst_n_clk3),
	.clk2_out			(clk2_out),
	.clk2_flag			(clk3_pls),
	// Output signals
	.out_valid			(out_valid),
	.out				(out)
);



endmodule
