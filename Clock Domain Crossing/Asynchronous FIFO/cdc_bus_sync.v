//////////////////////////////////////////////////
//
// Module Name: cdc_bus_sync
// 
// Author	  : Jamie Jhang
//
// Description: 
//
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module cdc_bus_sync #( parameter pSTAGES     = 2,  // No. of flip flops
                       parameter pDATA_WIDTH = 5   // DATA WIDTH
 				     )
(
  input  wire                   clk,         
  input  wire                   rst_n,       
  input  wire [pDATA_WIDTH-1:0] d,           
  output wire [pDATA_WIDTH-1:0] q         
);


genvar i;
generate
  for(i = 0; i < pDATA_WIDTH; i = i + 1) begin: loop
	cdc_sync #(.pSTAGES(pSTAGES))
	i_cdc_sync (
		.clk  (clk),
		.rst_n(rst_n),
		.d    (d[i]),
		.q    (q[i])
	);		
  end
endgenerate


endmodule
