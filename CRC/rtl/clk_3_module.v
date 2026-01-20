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


module clk_3_module #( parameter pSTAGES = 2  // No. of flip flops
 		             )
(
	input  wire		   clk_3,
	input  wire		   rst_n,

	input  wire	[59:0] clk2_out,
	input  wire		   clk2_flag,

	output wire 	   out_valid,
	output wire [59:0] out
);


//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
reg 	   out_valid_reg;
reg [59:0] out_reg; 		



always @(posedge clk_3 or negedge rst_n) begin
  if(!rst_n) 	     out_valid_reg <= 1'b0;
  else if(clk2_flag) out_valid_reg <= 1'b1;
  else 				 out_valid_reg <= 1'b0;
end

assign out_valid = out_valid_reg;

always @(posedge clk_3 or negedge rst_n) begin
  if(!rst_n) 	     out_reg <= 60'd0;
  else if(clk2_flag) out_reg <= clk2_out;
  else 				 out_reg <= 60'd0;
end

assign out = out_reg;

endmodule