//////////////////////////////////////////////////
//
// Module Name: cdc_sync
// 
// Author	  : Jamie Jhang
//
// Description: Double flip flops
//
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module cdc_sync #( parameter pSTAGES = 2  // No. of flip flops
 				 )
(
  input  wire clk,         
  input  wire rst_n,       
  input  wire d,           
  output wire q         
);

reg [pSTAGES-1:0] sync_ff;


// Synchronous logic
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) sync_ff <= {pSTAGES{1'b0}};
  else       sync_ff <= {sync_ff[pSTAGES-2:0], d};
end

// Synchronous signal
assign q = sync_ff[pSTAGES-1];


endmodule