//////////////////////////////////////////////////
//
// Module Name: plsgen
// 
// Author	  : Jamie Jhang
//
// Description: pulse generator
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module plsgen (
	clk,
	rst_n,
	d,
	pls
);

input  clk;
input  rst_n;
input  d;
output pls;

reg q;



always @(posedge clk or negedge rst_n) begin
  if (!rst_n) q <= 1'b0;
  else 		  q <= d;
end

assign pls = q ^ d;

endmodule