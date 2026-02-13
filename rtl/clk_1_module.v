//////////////////////////////////////////////////
//
// Module Name: clk_1_module.v
// 
// Author	  : Jamie Jhang
//
// Description: input pattern in clk1 clock domain
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module clk_1_module #( parameter pDATA_WIDTH = 60  
 		             )
(
  input  wire		            clk_1, 
  input  wire		            rst_n,

  input  wire		            in_valid,
  input  wire		            mode,
  input  wire		            CRC,
  input  wire [pDATA_WIDTH-1:0] message,

  output wire		            clk1_flag,
  output wire 	                clk1_mode,
  output wire 	                clk1_CRC,
  output wire [pDATA_WIDTH-1:0] clk1_message
);



reg 	              clk1_mode_reg;
reg 	              clk1_CRC_reg;
reg [pDATA_WIDTH-1:0] clk1_message_reg;


always @(posedge clk_1 or negedge rst_n) begin
  if(!rst_n) 		clk1_mode_reg <= 1'b0;
  else if(in_valid) clk1_mode_reg <= mode;
  else 				clk1_mode_reg <= clk1_mode_reg;
end

always @(posedge clk_1 or negedge rst_n) begin
  if(!rst_n) 		clk1_CRC_reg <= 1'b0;
  else if(in_valid) clk1_CRC_reg <= CRC;
  else 				clk1_CRC_reg <= clk1_CRC_reg;
end

always @(posedge clk_1 or negedge rst_n) begin
  if(!rst_n) 		clk1_message_reg <= {pDATA_WIDTH{1'b0}};
  else if(in_valid) clk1_message_reg <= message;
  else 				clk1_message_reg <= clk1_message_reg;
end


assign clk1_flag    = in_valid;
assign clk1_mode    = clk1_mode_reg;
assign clk1_CRC     = clk1_CRC_reg;
assign clk1_message = clk1_message_reg;



endmodule