//////////////////////////////////////////////////
//
// Module Name: cdc_sync2
// Author	  : Jamie Jhang
//
// Description: 2-FF CDC synchronizer
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module cdc_sync2 (
	clk,
	rst_n,
	d,
	q
);

input  clk;
input  rst_n;
input  d;
output q;

reg q0;
reg q1; // 1st stage ff output


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) {q1, q0} <= 2'b00;
  else 		  {q1, q0} <= {q0, d};
end

assign q = q1;

endmodule

