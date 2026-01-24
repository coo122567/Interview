//////////////////////////////////////////////////
//
// Module Name: rst_sync
// 
// Author	  : Jamie Jhang
//
// Description: reset synchronier
//
//
//////////////////////////////////////////////////


module rst_sync #( parameter pSTAGES = 2  // No. of flip flops
 				 )
(
  input  wire clk,         
  input  wire rst_async, // Asynchronous Reset
  output wire rst_sync   // Synchronous Reset               
);

reg [pSTAGES-1:0] sync_ff;

// Synchronous logic
always @(posedge clk or negedge rst_async) begin
  if(!rst_async) sync_ff <= {pSTAGES{1'b0}};
  else           sync_ff <= {sync_ff[pSTAGES-2:0], 1'b1};
end

// Synchronous signal
assign rst_sync = sync_ff[pSTAGES-1];


endmodule