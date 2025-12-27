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
	clk,
	rst_n,
	d,
	lvl
);

input  clk;
input  rst_n;
input  d;   // pulse signal
output lvl; // level signal


reg tmp_lvl;
wire q;


assign q = d ^ tmp_lvl;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) tmp_lvl <= 1'b0;
  else 		  tmp_lvl <= q;
end

assign lvl = tmp_lvl;

endmodule