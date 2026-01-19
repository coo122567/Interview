//////////////////////////////////////////////////
//
// Module Name: bist_cmp
// 
// Author	  : Jamie Jhang
//
// Description: comparator
//
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

module bist_cmp #( parameter pDATA_WIDTH = 2
				 )
(
    input  wire                   bist_clk,
	input  wire                   bist_rst_n,
	input  wire                   bist_cs,
	input  wire                   bist_we,
	input  wire [pDATA_WIDTH-1:0] bist_pat,
	input  wire [pDATA_WIDTH-1:0] bist_resp,
	output wire  				  pass_or_fail
);

reg pass_or_fail_reg;


always @(posedge bist_clk or negedge bist_rst_n) begin
	if(!bist_rst_n) pass_or_fail_reg <= 1'b1;
	else            pass_or_fail_reg <= (bist_cs && (!bist_we))? (bist_pat == bist_resp):1'b1;
end


assign pass_or_fail = pass_or_fail_reg;

endmodule