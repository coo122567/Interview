//////////////////////////////////////////////////
//
// Module Name: top
// 
// Author	  : Jamie Jhang
//
// Description: 
//
// 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module top #( parameter pADDR_WIDTH = 4,
              parameter pDATA_WIDTH = 2
			)
(
// Clock & Reset
  input  wire                   clk,
  input  wire                   rst_n,
  
// BIST start signal
  input  wire                   bist_start,
  
// Memory data out / BIST response
  input  wire [pDATA_WIDTH-1:0] bist_resp,
  
// BIST control signal
  output wire                   bist_cs,
  output wire                   bist_we,
  output wire [pADDR_WIDTH-1:0] bist_addr,
  output wire [pDATA_WIDTH-1:0] bist_pat,

// BIST done
  output wire				    bist_done,

// Memory BIST pass or fail 
  output wire                   pass_or_fail
);

// Instantiate
// Address
wire                   addr_clr_en;
wire                   addr_up_en;
wire                   addr_dn_en;
wire                   max_addr_done;
wire                   min_addr_done;

// Pattern
wire                   pat_sel;

// Buffer
wire                   buf_cs;
wire                   buf_we;
wire [pDATA_WIDTH-1:0] buf_pat;



// Controller 
bist_controller i_bist_controller (
	.bist_clk      (clk),
	.bist_rst_n    (rst_n),
	.bist_start    (bist_start),
	.bist_cs 	   (bist_cs),
	.bist_we 	   (bist_we),
	.bist_done 	   (bist_done),
	.addr_clr_en   (addr_clr_en),
	.addr_up_en    (addr_up_en),
	.addr_dn_en    (addr_dn_en),
	.max_addr_done (max_addr_done),
	.min_addr_done (min_addr_done),
	.pat_sel       (pat_sel)
);


// Address generator
bist_addr_gen # ( .pADDR_WIDTH(pADDR_WIDTH)
				)
i_bist_addr_gen (
	.bist_clk      (clk),
	.bist_rst_n    (rst_n),
	.addr_clr_en   (addr_clr_en),
	.addr_up_en    (addr_up_en),
	.addr_dn_en    (addr_dn_en),
	.bist_addr     (bist_addr),
	.max_addr_done (max_addr_done),
	.min_addr_done (min_addr_done)
);


// Pattern generator
bist_pat_gen # ( .pDATA_WIDTH (pDATA_WIDTH)
               )
i_bist_pat_gen (
	.bist_clk   (clk),
	.bist_rst_n (rst_n),
	.pat_sel    (pat_sel),
	.bist_pat   (bist_pat)
);


// Buffer
bist_buf #( .pDATA_WIDTH(pDATA_WIDTH)
		  )
i_bist_buf (
    .bist_clk   (clk),
	.bist_rst_n (rst_n),
	.bist_cs    (bist_cs),
	.bist_we    (bist_we),
	.bist_pat   (bist_pat),
    .buf_cs     (buf_cs),	
	.buf_we     (buf_we),
	.buf_pat    (buf_pat)
);


// Comparator
bist_cmp #( .pDATA_WIDTH(pDATA_WIDTH)
		  )
i_bist_cmp (
    .bist_clk     (clk),
	.bist_rst_n   (rst_n),
	.bist_cs      (buf_cs),
	.bist_we      (buf_we),
	.bist_pat     (buf_pat),
    .bist_resp    (bist_resp),	
	.pass_or_fail (pass_or_fail)
);



endmodule