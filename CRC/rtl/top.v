//////////////////////////////////////////////////
//
// Module Name: top
// 
// Author	  : Jamie Jhang
//
// Description: top includes rst_sync.v & crc.v
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module top #( parameter pSTAGES     = 2, // No. of flip flops
              parameter pDATA_WIDTH = 60  
 		    )
(
  // Input signals
  input  wire  	                clk_1,
  input  wire		            clk_2,
  input  wire		            clk_3,
  input  wire		            rst_n,

  input  wire		            in_valid,
  input  wire		            mode,
  input  wire		            CRC,
  input  wire [pDATA_WIDTH-1:0] message,
  
  // Output signals	
  output wire                   out_valid,
  output wire [pDATA_WIDTH-1:0] out
);
	
//---------------------------------------------------------------------
// Instantiate 
//---------------------------------------------------------------------	

wire 		           clk1_flag;
wire 		           clk1_mode;
wire 		           clk1_CRC;
wire [pDATA_WIDTH-1:0] clk1_message;

wire 		           clk2_flag;
wire [pDATA_WIDTH-1:0] clk2_out;

wire                   clk2_pls;
wire                   clk3_pls;

wire 		           rst_n_clk1;
wire 		           rst_n_clk2;
wire 		           rst_n_clk3;


rst_sync #( .pSTAGES(pSTAGES)
          )
i_rst_sync_clk1 (
  // Input signals
  .clk	   	(clk_1),
  .rst_async(rst_n),
  // Output signals	
  .rst_sync (rst_n_clk1)
);

clk_1_module #( .pDATA_WIDTH(pDATA_WIDTH)
 		      )
i_clk_1_module (
  // Input signals
  .clk_1	   (clk_1),
  .rst_n	   (rst_n_clk1),
  .in_valid	   (in_valid),
  .mode		   (mode),
  .CRC		   (CRC),
  .message	   (message),
  // Output signals
  .clk1_flag   (clk1_flag),
  .clk1_CRC	   (clk1_CRC),
  .clk1_mode   (clk1_mode),
  .clk1_message(clk1_message)
);


pulse_sync #( .pSTAGES(pSTAGES)
            )
i_pulse_sync_clk1 (
  // Input signals
  .src_clk  (clk_1),
  .src_rst_n(rst_n_clk1),
  .src_pls  (clk1_flag),
  .dst_clk  (clk_2),
  .dst_rst_n(rst_n_clk2),
  // Output signals
  .dst_pls  (clk2_pls)
);


rst_sync #( .pSTAGES(pSTAGES)
          )
i_rst_sync_clk2 (
  // Input signals
  .clk	   	(clk_2),
  .rst_async(rst_n),
  // Output signals
  .rst_sync	(rst_n_clk2)
);


clk_2_module #( .pDATA_WIDTH(pDATA_WIDTH)
 		      ) 
i_clk_2_module (
  // Input signals
  .clk_2	   (clk_2),
  .rst_n	   (rst_n_clk2),
  .clk1_flag   (clk2_pls),
  .clk1_mode   (clk1_mode),
  .clk1_CRC	   (clk1_CRC),
  .clk1_message(clk1_message),
  // Output signals
  .clk2_flag   (clk2_flag),
  .clk2_out	   (clk2_out)
);

pulse_sync #( .pSTAGES(pSTAGES)
            )
i_pulse_sync_clk2 (
  // Input signals
  .src_clk  (clk_2),
  .src_rst_n(rst_n_clk2),
  .src_pls  (clk2_flag),
  .dst_clk  (clk_3),
  .dst_rst_n(rst_n_clk3),
  // Output signals
  .dst_pls  (clk3_pls)
);

rst_sync #( .pSTAGES(pSTAGES)
          )
i_rst_sync_clk3 (
  // Input signals
  .clk	   	(clk_3),
  .rst_async(rst_n),
  // Output signals
  .rst_sync (rst_n_clk3)
);

clk_3_module #( .pDATA_WIDTH(pDATA_WIDTH)
 		      )
i_clk_3_module (			
  // Input signals
  .clk_3    (clk_3),
  .rst_n	(rst_n_clk3),
  .clk2_flag(clk3_pls),
  .clk2_out	(clk2_out),
  // Output signals
  .out_valid(out_valid),
  .out		(out)
);



endmodule
