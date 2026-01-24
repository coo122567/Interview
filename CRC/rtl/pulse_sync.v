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
  input  wire src_clk,       // Source Clock Domain
  input  wire src_rst_n,     // Reset from Source Clock Domain
  input  wire src_pls,       // Sending Pulse
  
  input  wire dst_clk,       // Destination Clock Domain
  input  wire dst_rst_n,     // Reset from Destination Clock Domain
  output wire dst_pls        // Synchronized Pulse 
);



wire src_lvl;
wire dst_lvl;


//---------------------------------------------------
// Instantiate
//--------------------------------------------------
// Toggle Flop Circuit
toggleff i_toggleff (
  .clk  (src_clk),
  .rst_n(src_rst_n),
  .d    (src_pls),   // Pulse signal
  .lvl  (src_lvl)    // Level signal
);


// Double Flip Flop Synchronizer
cdc_sync #( .pSTAGES(pSTAGES)
	      )
i_cdc_sync (
  .clk  (dst_clk),
  .rst_n(dst_rst_n),
  .d    (src_lvl),
  .q    (dst_lvl)
);


// Level signal -> pulse signal
plsgen i_plsgen (
  .clk  (dst_clk),
  .rst_n(dst_rst_n),
  .d    (dst_lvl),
  .pls  (dst_pls)
);


endmodule