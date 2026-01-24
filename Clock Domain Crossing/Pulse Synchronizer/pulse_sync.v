//////////////////////////////////////////////////
//
// Module Name: pulse_sync
// 
// Author	  : Jamie Jhang
//
// Description: pulse Synchronizer
//
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module pulse_sync #( parameter pSTAGES = 2
                   )
(
  input  wire    a_clk,       // Sending Clock Domain
  input  wire    b_clk,       // Receiving Clock Domain
  input  wire    a_rst_n,     // Reset from Sending Clock Domain
  input  wire    b_rst_n,     // Reset from Receiving Clock Domain
  input  wire    a_pls,       // Sending Pulse
  output wire    b_pls        // Synchronized Pulse 
);



wire a_lvl;
wire b_lvl;


//---------------------------------------------------
// Instantiate
//--------------------------------------------------
// Toggle Flop Circuit
toggleff i_toggleff (
	.clk  (a_clk),
	.rst_n(a_rst_n),
	.d    (a_pls),   // pulse signal
	.lvl  (a_lvl)    // level signal
);


// Double Flop Bit Synchronizer
cdc_sync #( .pSTAGES(pSTAGES)
	      )
i_cdc_sync (
	.clk  (b_clk),
	.rst_n(b_rst_n),
	.d    (a_lvl),
	.q    (b_lvl)
);


// Level signal -> pulse signal
plsgen i_plsgen (
	.clk  (b_clk),
	.rst_n(b_rst_n),
	.d    (b_lvl),
	.pls  (b_pls)
);


endmodule