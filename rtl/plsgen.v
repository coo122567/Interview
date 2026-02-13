//////////////////////////////////////////////////
//
// Module Name: plsgen
// 
// Author	  : Jamie Jhang
//
// Description: pulse generator
//
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module plsgen (
  input  wire clk,
  input  wire rst_n,
  input  wire d,
  output wire pls
);

reg q;


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) q <= 1'b0;
  else 		  q <= d;
end

assign pls = q ^ d;


endmodule