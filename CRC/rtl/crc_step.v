// crc module
module crc_step (
	sel,  
	bit_in,
	rem_in,
	rem_out
);

input            sel;   
input        	 bit_in;
input  	   [8:0] rem_in;
output reg [8:0] rem_out;
  
  
always @(*) begin
  if (sel) begin
	// CRC-5 
	rem_out[0] = bit_in;
	rem_out[1] = rem_in[0] ^ rem_in[5];
	rem_out[2] = rem_in[1] ^ rem_in[5];
	rem_out[3] = rem_in[2];
    rem_out[4] = rem_in[3] ^ rem_in[5];
	rem_out[5] = rem_in[4];
	rem_out[6] = 1'b0;
	rem_out[7] = 1'b0;
	rem_out[8] = 1'b0;
  end else begin
	// CRC-8 
    rem_out[0] = bit_in;
    rem_out[1] = rem_in[0] ^ rem_in[8];
    rem_out[2] = rem_in[1];
    rem_out[3] = rem_in[2];
    rem_out[4] = rem_in[3];
    rem_out[5] = rem_in[4] ^ rem_in[8];
    rem_out[6] = rem_in[5] ^ rem_in[8];
    rem_out[7] = rem_in[6];
    rem_out[8] = rem_in[7];
  end
end
  
endmodule
