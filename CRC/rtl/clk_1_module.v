//////////////////////////////////////////////////
//
// Module Name: clk_1_module.v
// 
// Author	  : Jamie Jhang
//
// Description: input pattern in clk1 clock domain
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module clk_1_module (
	// Input signals
	clk_1,
	rst_n,
	in_valid,
	message,
	mode,
	CRC,
	// Output signals
	clk1_message,
	clk1_CRC,
	clk1_mode,
	clk1_flag
);


//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input 			  clk_1; 
input 			  rst_n;

input 			  in_valid;
input 	   [59:0] message;
input 			  mode;
input 			  CRC;

output reg [59:0] clk1_message;
output reg 		  clk1_CRC;
output reg 		  clk1_mode;
output 			  clk1_flag;


//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
always @(posedge clk_1 or negedge rst_n) begin
  if(!rst_n) 		clk1_CRC <= 1'b0;
  else if(in_valid) clk1_CRC <= CRC;
  else 				clk1_CRC <= clk1_CRC;
end

always @(posedge clk_1 or negedge rst_n) begin
  if(!rst_n) 		clk1_mode <= 1'b0;
  else if(in_valid) clk1_mode <= mode;
  else 				clk1_mode <= clk1_mode;
end

always @(posedge clk_1 or negedge rst_n) begin
  if(!rst_n) 		clk1_message <= 60'd0;
  else if(in_valid) clk1_message <= message;
  else 				clk1_message <= clk1_message;
end


// toggle ff
toggleff i_toggleff_clk1 (
	.clk  (clk_1),
	.rst_n(rst_n),
	.d    (in_valid),
	.lvl  (clk1_flag)
);


endmodule