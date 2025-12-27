//////////////////////////////////////////////////
//
// Module Name: rst_sync2
// 
// Author	  : Jamie Jhang
//
// Description: reset synchronier
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module rst_sync2 (
	clk,
	rst_async,
	rst_sync    
);

input  clk;
input  rst_async;
output rst_sync;

reg rff0;
reg rff1; 


always @(posedge clk or negedge rst_async) begin
  if (!rst_async) {rff1, rff0} <= 2'b00;
  else 		      {rff1, rff0} <= {rff0, 1'b1};
end

assign rst_sync = rff1;

endmodule
