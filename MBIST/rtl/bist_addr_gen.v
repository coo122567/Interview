//////////////////////////////////////////////////
//
// Module Name: bist_addr_gen
// 
// Author	  : Jamie Jhang
//
// Description: Address generator
//
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

module bist_addr_gen #( parameter pADDR_WIDTH = 4
                      ) 
(
  input  wire                   bist_clk,
  input  wire                   bist_rst_n,
  input  wire                   addr_clr_en,
  input  wire                   addr_up_en,
  input  wire                   addr_dn_en,
  output wire [pADDR_WIDTH-1:0] bist_addr,
  output wire                   max_addr_done,
  output wire                   min_addr_done
);

localparam MAX_ADDR = {pADDR_WIDTH{1'b1}};
localparam MIN_ADDR = {pADDR_WIDTH{1'b0}};


reg [pADDR_WIDTH-1:0] addr_cnt_nxt;
reg [pADDR_WIDTH-1:0] addr_cnt;
reg [pADDR_WIDTH-1:0] bist_addr_reg;




assign max_addr_done = (addr_cnt == MAX_ADDR);
assign min_addr_done = (addr_cnt == MIN_ADDR);


always @(*) begin
  if(addr_clr_en)     addr_cnt_nxt = MIN_ADDR;
  else if(addr_up_en) addr_cnt_nxt = max_addr_done ? MIN_ADDR : addr_cnt + 4'd1;
  else if(addr_dn_en) addr_cnt_nxt = min_addr_done ? MAX_ADDR : addr_cnt - 4'd1;
  else                addr_cnt_nxt = addr_cnt;
end

always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) addr_cnt <= MIN_ADDR;
  else            addr_cnt <= addr_cnt_nxt;
end

always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) bist_addr_reg <= MIN_ADDR;
  else            bist_addr_reg <= addr_cnt;
end
	
assign bist_addr = bist_addr_reg;
	
endmodule