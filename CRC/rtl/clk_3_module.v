//////////////////////////////////////////////////
//
// Module Name: clk_3_module.v
// 
// Author	  : Jamie Jhang
//
// Description: output result in clk3 clock domain
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module clk_3_module (
	// Input signals
	clk_3,
	rst_n,
	clk2_out,
	clk2_flag,
	// Output signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input 			  clk_3;	
input 			  rst_n;

input 	   [59:0] clk2_out;
input 			  clk2_flag;

output reg 		  out_valid;
output reg [59:0] out; 		

//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
wire sync_clk2_lvl;
wire sync_clk2_pls;

// 2-ff synchronizer
cdc_sync2 i_cdc_sync2_clk3 (
	.clk  (clk_3),
	.rst_n(rst_n),
	.d    (clk2_flag),
	.q    (sync_clk2_lvl)
);

// pulse generator
plsgen i_plsgen_clk3 (
	.clk  (clk_3),
	.rst_n(rst_n),
	.d    (sync_clk2_lvl),
	.pls  (sync_clk2_pls)
);


always @(posedge clk_3 or negedge rst_n) begin
  if(!rst_n) 			 out_valid <= 1'b0;
  else if(sync_clk2_pls) out_valid <= 1'b1;
  else 					 out_valid <= 1'b0;
end


always @(posedge clk_3 or negedge rst_n) begin
  if(!rst_n) 			 out <= 60'd0;
  else if(sync_clk2_pls) out <= clk2_out;
  else 					 out <= 60'd0;
end


endmodule