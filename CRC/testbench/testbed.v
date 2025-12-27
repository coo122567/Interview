//////////////////////////////////////////////////
//
// Module Name: TESTBED
// 
// Author	  : Jamie Jhang
//
// Description: connect design & pattern
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module testbed();

wire 		clk_1;
wire 		clk_2;
wire 		clk_3;
wire 		rst_n;

wire 		in_valid;
wire 		mode;
wire 		CRC;
wire [59:0] message;

wire 		out_valid;
wire [59:0] out;	

// dump waveform
initial begin
`ifdef RTL
	$fsdbDumpfile("./waveform/top.fsdb"); 
	$fsdbDumpvars(0, "+mda");
`endif
`ifdef GATE
	$fsdbDumpfile("./waveform/top_syn.fsdb"); 
	$fsdbDumpvars(0, "+mda");
	$sdf_annotate("./netlist/top_syn.sdf", i_top);
`endif
end  



top i_top (			
	// Input signals
	.clk_1    (clk_1),
	.clk_2    (clk_2),
	.clk_3    (clk_3),
	.rst_n    (rst_n),
	.in_valid (in_valid),
	.CRC	  (CRC),
	.mode     (mode),
	.message  (message),
	// Output signals
	.out_valid(out_valid),
	.out	  (out)
);


pattern i_pattern (
	// Output signals
	.clk_1    (clk_1),
	.clk_2    (clk_2),
	.clk_3    (clk_3),
	.rst_n    (rst_n),
	.in_valid (in_valid),
	.mode     (mode),
	.CRC      (CRC),
	.message  (message),
	// Input signals
	.out_valid(out_valid),
	.out      (out)
);

endmodule
