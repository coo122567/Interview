//////////////////////////////////////////////////
//
// Module Name: sram
// 
// Author	  : Jamie Jhang
//
// Description: 
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

module memory #( parameter pADDR_WIDTH = 4,
                 parameter pDATA_WIDTH = 2
			   )
(
	input  wire 			   	  clk,
	input  wire 				  cs,   // chip select
	input  wire 				  we,   // write enable
	input  wire [pADDR_WIDTH-1:0] addr,
	input  wire [pDATA_WIDTH-1:0] din,
	output wire [pDATA_WIDTH-1:0] dout
);

reg [pDATA_WIDTH-1:0]    	dout_reg;

// Memory
reg [pDATA_WIDTH-1:0] mem [0:(1<<pADDR_WIDTH)-1];   // 2 bits, 16 words   


always @(posedge clk) begin
	if(cs) begin
		if(we)  mem[addr] <= din;  		   // write
		else    dout_reg  <= mem[addr];    // read
	end else begin
				mem[addr] <= mem[addr];
				dout_reg  <= dout_reg;
	end
end

assign dout = dout_reg;
	
/*
// inject a  stuck-at-1 falut to bit #2 of the SRAM word #5
always @(*) begin
	if(addr == 4'd5) mem[addr] = 2'b10;
	else             mem[addr] = mem[addr];
end
*/

endmodule







