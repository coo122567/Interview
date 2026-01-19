//////////////////////////////////////////////////
//
// Module Name: toggleff
// 
// Author	  : Jamie Jhang
//
// Description: toggle flip flop
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module toggleff (
	input  wire clk,
	input  wire rst_n,
	input  wire d,   // pulse signal
	output wire lvl // level signal
);

reg tmp_lvl;
wire q;


assign q = d ^ tmp_lvl;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) tmp_lvl <= 1'b0;
  else 		  tmp_lvl <= q;
end

assign lvl = tmp_lvl;

endmodule