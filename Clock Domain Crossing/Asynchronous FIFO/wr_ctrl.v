//////////////////////////////////////////////////
//
// Module Name: wr_ctrl
// 
// Author	  : Jamie Jhang
//
// Description: Write control logic
//
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

// Write control logic
module wr_ctrl #( parameter pADDR_WIDTH = 4
                )
(
  input  wire                   wr_clk,
  input  wire                   wr_rst_n,
  input  wire                   wr_push,
  input  wire [pADDR_WIDTH:0]   rd_ptr,
  output wire [pADDR_WIDTH-1:0] wr_addr,
  output wire [pADDR_WIDTH:0]   wr_ptr,
  output wire                   wr_full
);


// write pointer need extra bit for full signal
reg  [pADDR_WIDTH:0] wr_bin;
reg  [pADDR_WIDTH:0] wr_gray;
reg                  wr_full_reg;

wire [pADDR_WIDTH:0] wr_bin_nxt;
wire [pADDR_WIDTH:0] wr_gray_nxt;
wire                 wr_full_val;


// write pointer
// bin 0111  gray 0100
// wr_bin_nxt = 0111
// wr_bin_nxt >> 1 = 011
// wr_gray_next = 0111 ^ 011; 
// gray code pointer 
assign wr_bin_nxt  = wr_bin + (wr_push && !wr_full);
assign wr_gray_nxt = wr_bin_nxt ^ (wr_bin_nxt >> 1);
assign wr_full_val = (wr_gray_nxt == {~rd_ptr[pADDR_WIDTH:pADDR_WIDTH-1], rd_ptr[pADDR_WIDTH-2:0]});


// for address
always @(posedge wr_clk or negedge wr_rst_n) begin
  if(!wr_rst_n) wr_bin <= {(pADDR_WIDTH+1){1'b0}};
  else          wr_bin <= wr_bin_nxt;
end

// for pointer
always @(posedge wr_clk or negedge wr_rst_n) begin
  if(!wr_rst_n) wr_gray <= {(pADDR_WIDTH+1){1'b0}};
  else          wr_gray <= wr_gray_nxt;
end
								   
always @(posedge wr_clk or negedge wr_rst_n) begin
  if(!wr_rst_n) wr_full_reg <= 1'b0;
  else          wr_full_reg <= wr_full_val;
end


assign wr_addr = wr_bin[pADDR_WIDTH-1:0];
assign wr_ptr  = wr_gray;
assign wr_full = wr_full_reg;


endmodule



