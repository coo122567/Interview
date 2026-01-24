//////////////////////////////////////////////////
//
// Module Name: bist_pat_gen
// 
// Author	  : Jamie Jhang
//
// Description: Pattern Generator
//
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

module bist_pat_gen #(parameter pDATA_WIDTH = 2) (
  input  wire                   bist_clk,
  input  wire                   bist_rst_n,
  input  wire                   pat_sel,
  output wire [pDATA_WIDTH-1:0] bist_pat
);

reg [pDATA_WIDTH-1:0] bist_pat_reg;

always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) bist_pat_reg <= {pDATA_WIDTH{1'b0}};
  else            bist_pat_reg <= pat_sel ? {pDATA_WIDTH{1'b1}} : {pDATA_WIDTH{1'b0}};
end

assign bist_pat = bist_pat_reg;

endmodule