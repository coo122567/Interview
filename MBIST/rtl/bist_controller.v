//////////////////////////////////////////////////
//
// Module Name: bist_controller
// 
// Author	  : Jamie Jhang
//
// Description: Controller
//
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps
 
module bist_controller (
  // Clock & reset
  input  wire     			  bist_clk,
  input  wire     			  bist_rst_n,

  // Bist start signal
  input  wire		 	      bist_start,


  // Address control signals
  input  wire                 max_addr_done,
  input  wire                 min_addr_done,
  output wire      			  addr_clr_en,
  output wire      			  addr_up_en,
  output wire      			  addr_dn_en,

  // Pattern control signals
  output wire              	  pat_sel,

  // Memory control signals
  output wire      			  bist_cs,
  output wire      			  bist_we,
  output wire     			  bist_done
);

// state
reg  [2:0] state;
reg  [2:0] nxt_state;

// temp
wire       bist_cs_tmp;
wire       bist_we_tmp;
wire 	   bist_done_tmp;

// reg
reg 	   bist_cs_reg;
reg        bist_we_reg;
reg 	   bist_done_reg;


// state  
localparam IDLE    = 3'd0;
localparam WR_0_UP = 3'd1;
localparam RD_0_UP = 3'd2;
localparam WR_1_UP = 3'd3;
localparam RD_1_DN = 3'd4;
localparam WR_0_DN = 3'd5;
localparam RD_0_DN = 3'd6;
localparam FINISH  = 3'd7;

//------------------------------------------------------------------------------------------------
// March algo. waveform 
// March X: {up direction(w0); up direction(r0, w1); down direction(r1, w0); down direction(r0)}
// example: up direction(r0, w1)
// Synchronous SRAM
// clk          |   |   |   |   |   |   |   |   |  ...... |   |   |   |   |   |   |   |   |   |
// rst_n        ````\____________________________  ...... _____________________________________
// cs           ________/````````````````````````  ...... ````````````````````````\____________
// we           ____________/```\___/```\___/```\  ...... ____/```\_______/```\________________
// state        ________< R | W | R | W | R | W >  ...... < R | W | R | W | R | W >____________
// addr         ________< 0 | 0 | 1 | 1 | 2 | 2 >  ...... < 13| 13| 14| 14| 15| 15>____________
// din          ____________< 1-----| 1-----| 1->  ...... <---| 1-----| 1-----| 1->____________
// dout         ____________< 0-----| 0-----| 0->  ...... <---| 0-----| 0---- | 0->____________
// test_done    _________________________________  ...... ________________________|````````````
// pass_or_fail `````````````````````````````````  ...... `````````````````````````````````````
//------------------------------------------------------------------------------------------------


// current state
always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) state <= IDLE;
  else 	   		  state <= nxt_state;
end


// next state
always @(*) begin
  case(state)
    IDLE:    nxt_state = bist_start? WR_0_UP:IDLE;
    WR_0_UP: nxt_state = max_addr_done? RD_0_UP:WR_0_UP;
    RD_0_UP: nxt_state = WR_1_UP;
    WR_1_UP: nxt_state = max_addr_done? RD_1_DN:RD_0_UP;	  
    RD_1_DN: nxt_state = WR_0_DN;
    WR_0_DN: nxt_state = min_addr_done? RD_0_DN:RD_1_DN;
    RD_0_DN: nxt_state = min_addr_done? FINISH:RD_0_DN;
    FINISH:  nxt_state = !bist_start? IDLE:FINISH;
    default: nxt_state = IDLE;
  endcase
end

// BIST address
assign addr_clr_en = (state == IDLE);
assign addr_up_en  = (state == WR_0_UP) || ((state == WR_1_UP) && !max_addr_done);
assign addr_dn_en  = (state == WR_0_DN) || ((state == RD_0_DN) && !min_addr_done);

// BIST pattern
assign pat_sel = (state == WR_1_UP || state == RD_1_DN);


// BIST chip select
assign bist_cs_tmp = ((state == IDLE) || (state == FINISH))? 1'b0:1'b1;
	
always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) bist_cs_reg <= 1'd0;
  else 			  bist_cs_reg <= bist_cs_tmp;
end


// BIST write enable
assign bist_we_tmp = ((state == WR_0_UP) || (state == WR_1_UP) || (state == WR_0_DN));	

always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) bist_we_reg <= 1'd0;
  else 			  bist_we_reg <= bist_we_tmp;
end


// BIST done 
assign bist_done_tmp = (state == FINISH);

always @(posedge bist_clk or negedge bist_rst_n) begin
  if(!bist_rst_n) bist_done_reg <= 1'd0;
  else 			  bist_done_reg <= bist_done_tmp;
end


assign bist_cs   = bist_cs_reg;
assign bist_we   = bist_we_reg;
assign bist_done = bist_done_reg;


endmodule