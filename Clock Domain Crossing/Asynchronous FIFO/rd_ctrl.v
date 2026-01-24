//////////////////////////////////////////////////
//
// Module Name: rd_ctrl
// 
// Author	  : Jamie Jhang
//
// Description: Read control logic
//
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

// Read control logic
module rd_ctrl #( parameter pADDR_WIDTH = 4
                )
( 
  input  wire                   rd_clk,
  input  wire                   rd_rst_n,
  input  wire                   rd_pop,
  input  wire [pADDR_WIDTH:0]   wr_ptr,
  output wire [pADDR_WIDTH-1:0] rd_addr,
  output wire [pADDR_WIDTH:0]   rd_ptr,
  output wire                   rd_empty
);

// read pointer need extra bit for empty decide
wire [pADDR_WIDTH:0] rd_bin_nxt;
wire [pADDR_WIDTH:0] rd_gray_nxt;
wire                 rd_empty_val;

reg  [pADDR_WIDTH:0] rd_bin;
reg  [pADDR_WIDTH:0] rd_gray;
reg                  rd_empty_reg;

// read pointer
assign rd_bin_nxt   = rd_bin + (rd_pop && !rd_empty);
assign rd_gray_nxt  = rd_bin_nxt ^ (rd_bin_nxt >> 1);
assign rd_empty_val = (rd_gray_nxt == wr_ptr);


// for address
always @(posedge rd_clk or negedge rd_rst_n) begin
  if(!rd_rst_n) rd_bin <= {(pADDR_WIDTH+1){1'b0}};
  else          rd_bin <= rd_bin_nxt;
end

// for pointer
always @(posedge rd_clk or negedge rd_rst_n) begin
  if(!rd_rst_n) rd_gray <= {(pADDR_WIDTH+1){1'b0}};
  else          rd_gray <= rd_gray_nxt;
end

always @(posedge rd_clk or negedge rd_rst_n) begin
  if(!rd_rst_n) rd_empty_reg <= 1'b0;
  else          rd_empty_reg <= rd_empty_val;
end


assign rd_addr  = rd_bin[pADDR_WIDTH-1:0];
assign rd_ptr   = rd_gray;
assign rd_empty = rd_empty_reg;

endmodule



