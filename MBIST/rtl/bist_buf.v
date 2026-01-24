//////////////////////////////////////////////////
//
// Module Name: bist_buf
// 
// Author	  : Jamie Jhang
//
// Description: Buffer
//
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

module bist_buf #( parameter pDATA_WIDTH = 2
			     )
(
  input  wire     			    bist_clk,
  input  wire     			    bist_rst_n,
 
  input  wire      			    bist_cs,
  input  wire      			    bist_we,
  input  wire [pDATA_WIDTH-1:0] bist_pat,

  output wire     			    buf_cs,
  output wire      			    buf_we,
  output wire [pDATA_WIDTH-1:0] buf_pat
);

reg                   buf_cs_reg;
reg                   buf_we_reg;
reg [pDATA_WIDTH-1:0] buf_pat_reg;

// buffer
always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) buf_cs_reg <= 1'd0;
  else 	          buf_cs_reg <= bist_cs;
end

always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) buf_we_reg <= 1'd0;
  else 	          buf_we_reg <= bist_we;
end

always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) buf_pat_reg <= {pDATA_WIDTH{1'b0}};
  else 	          buf_pat_reg <= bist_pat;
end


assign buf_cs  = buf_cs_reg;
assign buf_we  = buf_we_reg;
assign buf_pat = buf_pat_reg;



endmodule