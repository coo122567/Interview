//////////////////////////////////////////////////
//
// Module Name: bist_buf
// 
// Author	  : Jamie Jhang
//
// Description: bist
//
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

module bist_buf #( parameter pDATA_WIDTH = 2
			     )
(
	input  wire     			  bist_clk,
	input  wire     			  bist_rst_n,

	input  wire      			  bist_cs,
	input  wire      			  bist_we,
	input  wire [pDATA_WIDTH-1:0] bist_pat,

	output wire     			  buf_cs,
	output wire      			  buf_we,
	output wire [pDATA_WIDTH-1:0] buf_pat
);

reg                   cs_buf_1;
reg                   we_buf_1;
reg [pDATA_WIDTH-1:0] pat_buf_1;

// buffer
always @(posedge bist_clk or negedge bist_rst_n) begin
	if(!bist_rst_n) cs_buf_1 <= 1'd0;
	else 	        cs_buf_1 <= bist_cs;
end

always @(posedge bist_clk or negedge bist_rst_n) begin
	if(!bist_rst_n) we_buf_1 <= 1'd0;
	else 	        we_buf_1 <= bist_we;
end

always @(posedge bist_clk or negedge bist_rst_n) begin
	if(!bist_rst_n) pat_buf_1 <= 2'd0;
	else 	        pat_buf_1 <= bist_pat;
end


assign buf_cs  = cs_buf_1;
assign buf_we  = we_buf_1;
assign buf_pat = pat_buf_1;



endmodule