//////////////////////////////////////////////////
//
// Module Name: fifo_mem
// 
// Author	  : Jamie Jhang
//
// Description: Memory
//
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

module fifo_mem #( parameter pADDR_WIDTH = 4,
				   parameter pDATA_WIDTH = 8
				 )   
(
  // write side
  input  wire                   wr_clk,
  input  wire                   wr_en,
  input  wire [pADDR_WIDTH-1:0] wr_addr,
  input  wire [pDATA_WIDTH-1:0] wr_data, 
  
  // read side 
  input  wire                   rd_clk,
  input  wire                   rd_en,
  input  wire [pADDR_WIDTH-1:0] rd_addr,
  output wire [pDATA_WIDTH-1:0] rd_data
);

localparam pDEPTH = 1 << pADDR_WIDTH;

reg [pDATA_WIDTH-1:0] mem [0:pDEPTH-1];

reg [pDATA_WIDTH-1:0] rd_data_reg;


// write 
always @(posedge wr_clk) begin
  if(wr_en) mem[wr_addr] <= wr_data;
  else      mem[wr_addr] <= mem[wr_addr];
end


// read
always @(posedge rd_clk) begin
  if(rd_en) rd_data_reg <= mem[rd_addr];
  else      rd_data_reg <= rd_data_reg;
end

assign rd_data = rd_data_reg;


endmodule






