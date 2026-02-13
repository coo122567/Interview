//////////////////////////////////////////////////
//
// Module Name: crc_step.v
// 
// Author	  : Jamie Jhang
//
// Description: crc step 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module crc_step (
  input  wire       sel, 
  input  wire       bit_in,
  input  wire [8:0] rem_in,
  output wire [8:0] rem_out
);


reg [8:0] rem_out_reg;  
  
always @(*) begin
  if (sel) begin
	// CRC-5 
	rem_out_reg[0] = bit_in;
	rem_out_reg[1] = rem_in[0] ^ rem_in[5];
	rem_out_reg[2] = rem_in[1] ^ rem_in[5];
	rem_out_reg[3] = rem_in[2];
    rem_out_reg[4] = rem_in[3] ^ rem_in[5];
	rem_out_reg[5] = rem_in[4];
	rem_out_reg[6] = 1'b0;
	rem_out_reg[7] = 1'b0;
	rem_out_reg[8] = 1'b0;
  end else begin
	// CRC-8 
    rem_out_reg[0] = bit_in;
    rem_out_reg[1] = rem_in[0] ^ rem_in[8];
    rem_out_reg[2] = rem_in[1];
    rem_out_reg[3] = rem_in[2];
    rem_out_reg[4] = rem_in[3];
    rem_out_reg[5] = rem_in[4] ^ rem_in[8];
    rem_out_reg[6] = rem_in[5] ^ rem_in[8];
    rem_out_reg[7] = rem_in[6];
    rem_out_reg[8] = rem_in[7];
  end
end
 
assign rem_out = rem_out_reg;

endmodule
