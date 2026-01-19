//////////////////////////////////////////////////
//
// Module Name: mode_mux
// 
// Author	  : Jamie Jhang
//
// Description: function / bist mode mux
//
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

module mode_mux # ( parameter pADDR_WIDTH = 4,
                    parameter pDATA_WIDTH = 2
				  )
(
	input  wire                   func_cs,
	input  wire	                  func_we,  
	input  wire [pADDR_WIDTH-1:0] func_addr, 
	input  wire [pDATA_WIDTH-1:0] func_din,
	
	input  wire		              mode,

	input  wire		              bist_cs,   
	input  wire	 	              bist_we,   
	input  wire [pADDR_WIDTH-1:0] bist_addr, 
	input  wire [pDATA_WIDTH-1:0] bist_pat, 

	output wire	                  mem_cs,  
	output wire	                  mem_we,   
	output wire [pADDR_WIDTH-1:0] mem_addr, 
	output wire [pDATA_WIDTH-1:0] mem_din
);


assign mem_cs   = mode ? bist_cs   : func_cs;
assign mem_we   = mode ? bist_we   : func_we;
assign mem_addr = mode ? bist_addr : func_addr;
assign mem_din  = mode ? bist_pat  : func_din;


endmodule