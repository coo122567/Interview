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


module clk_3_module #( parameter pDATA_WIDTH = 60  
 		             )
(
  input  wire		            clk_3,
  input  wire		            rst_n,

  input  wire		            clk2_flag,
  input  wire [pDATA_WIDTH-1:0] clk2_out,

  output wire 	                out_valid,
  output wire [pDATA_WIDTH-1:0] out
);


//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
reg 	              out_valid_reg;
reg [pDATA_WIDTH-1:0] out_reg; 		



always @(posedge clk_3 or negedge rst_n) begin
  if(!rst_n) 	     out_valid_reg <= 1'b0;
  else if(clk2_flag) out_valid_reg <= 1'b1;
  else 				 out_valid_reg <= 1'b0;
end

always @(posedge clk_3 or negedge rst_n) begin
  if(!rst_n) 	     out_reg <= {pDATA_WIDTH{1'b0}};
  else if(clk2_flag) out_reg <= clk2_out;
  else 				 out_reg <= {pDATA_WIDTH{1'b0}};
end

assign out_valid = out_valid_reg;
assign out       = out_reg;

endmodule