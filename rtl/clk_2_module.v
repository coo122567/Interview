//////////////////////////////////////////////////
//
// Module Name: clk_2_module.v
// 
// Author	  : Jamie Jhang
//
// Description: CRC compute in clk2 clock domain
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module clk_2_module #( parameter pDATA_WIDTH = 60  
 		             )
(
  input  wire		            clk_2,	
  input  wire		            rst_n,

  input  wire		            clk1_flag,
  input  wire [pDATA_WIDTH-1:0] clk1_message,
  input  wire		            clk1_mode,
  input  wire		            clk1_CRC,

  output wire		            clk2_flag,
  output wire [pDATA_WIDTH-1:0] clk2_out

);

		


//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
reg  [pDATA_WIDTH-1:0] clk2_out_reg;
reg  [5:0]             cnt;
reg  [pDATA_WIDTH-1:0] dividend;
reg  [8:0]             remainder;

reg 	               shift_en;
reg  	               done_en;

reg  [pDATA_WIDTH-1:0] clk2_message;
reg 	               start_crc;

reg 	               clk2_CRC;
reg 	               clk2_mode;

wire [8:0]             next_remainder;
wire [5:0]	           cnt_target;
wire 		           last_iter;

wire [8:0]             rem_1;
wire [8:0]             rem_2;
wire                   bit_in_0;
wire	               bit_in_1;
wire 	               last_crc5;

localparam CNT_CRC5    = 6'd55; // 0 ~ 54
localparam CNT_CRC8    = 6'd52; // 0 ~ 51
localparam CNT_CRC5_U2 = 6'd28;  
localparam CNT_CRC8_U2 = 6'd26;  



// sync crc
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		 clk2_CRC <= 1'b0;
  else if(clk1_flag) clk2_CRC <= clk1_CRC;
  else 				 clk2_CRC <= clk2_CRC;
end

// sync mode
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		 clk2_mode <= 1'b0;
  else if(clk1_flag) clk2_mode <= clk1_mode;
  else 				 clk2_mode <= clk2_mode;
end

// sync message
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		 clk2_message <= {pDATA_WIDTH{1'b0}};
  else if(clk1_flag) clk2_message <= clk1_message;
  else 				 clk2_message <= clk2_message;
end



// clk2 in_valid
always @(posedge clk_2 or negedge rst_n) begin
  if (!rst_n) start_crc <= 1'b0;
  else 		  start_crc <= clk1_flag;
end



// count crc intermediate
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 			cnt <= 6'd0;
  else if(start_crc) 	cnt <= 6'd0;
  else if(shift_en) 	cnt <= cnt + 6'd1;
  else 					cnt <= cnt;
end


// last cnt
assign cnt_target  = clk2_CRC? (CNT_CRC5_U2-1) : (CNT_CRC8_U2-1);
assign last_iter   = shift_en && (cnt == cnt_target);


// done
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		 done_en <= 1'b0;
  else if(start_crc) done_en <= 1'b0;
  else       		 done_en <= last_iter;
end


// shift_en
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		 shift_en <= 1'b0;
  else if(start_crc) shift_en <= 1'b1;
  else if(last_iter) shift_en <= 1'b0;
  else 				 shift_en <= shift_en;
end 



//---------------------------------------------------------------------
// Dividend
// mode = 1: check CRC
// mode = 0: generate CRC
// CRC  = 0: CRC-8
// CRC  = 1: CRC-5
//---------------------------------------------------------------------
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 				dividend <= {pDATA_WIDTH{1'b0}};
  else begin
	  if(start_crc) begin
		if(clk2_mode) 	  	dividend <= clk2_message; 
		else begin
		  if(clk2_CRC) 		dividend <= {clk2_message[54:0], 5'd0};
		  else 				dividend <= {clk2_message[51:0], 8'd0};
		end
	  end else if(shift_en) dividend <= {dividend[57:0], 2'b0}; 
	  else 		 			dividend <= dividend;
  end
end


// crc5 last step
assign last_crc5 = clk2_CRC && (cnt == cnt_target);

assign bit_in_0 = clk2_CRC ? dividend[53] : dividend[50];
assign bit_in_1 = last_crc5 ? 1'b0 : (clk2_CRC ? dividend[52] : dividend[49]);

crc_step i_crc_step_0 (
  .sel    (clk2_CRC),
  .bit_in (bit_in_0),
  .rem_in (remainder),
  .rem_out(rem_1)
);

crc_step i_crc_step_1 (
  .sel    (clk2_CRC),
  .bit_in (bit_in_1),
  .rem_in (rem_1),
  .rem_out(rem_2)
);


assign next_remainder = last_crc5 ? rem_1 : rem_2;



// calculate crc remainder
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 			  remainder <= 9'd0;  
  else begin
    if(start_crc) begin
	  if(clk2_mode)  	  remainder <= clk2_CRC ? {3'd0, clk2_message[59:54]} : clk2_message[59:51];
	  else 				  remainder <= clk2_CRC ? {3'd0, clk2_message[54:49]} : clk2_message[51:43];
	end else if(shift_en) remainder <= next_remainder;
	else 			      remainder <= remainder;				
  end
end



// out 
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		  clk2_out_reg <= {pDATA_WIDTH{1'b0}};
  else begin
    if(done_en) begin
      if(clk2_mode) begin
	    if(clk2_CRC)  clk2_out_reg <= (|remainder[5:1])? {pDATA_WIDTH{1'b1}} : {pDATA_WIDTH{1'b0}}; 
		else  		  clk2_out_reg <= (|remainder[8:1])? {pDATA_WIDTH{1'b1}} : {pDATA_WIDTH{1'b0}}; // |remainder means remainder != 0;
	  end else begin
        if(clk2_CRC)  clk2_out_reg <= {clk2_message[54:0], remainder[5:1]};
		else 		  clk2_out_reg <= {clk2_message[51:0], remainder[8:1]};
	  end
    end else 		  clk2_out_reg <= clk2_out_reg;
  end
end

assign clk2_out  = clk2_out_reg;
assign clk2_flag = done_en;


endmodule   





/*

//////////////////////////////////////////////////
//
// Module Name: clk_2_module.v
// 
// Author	  : Jamie Jhang
//
// Description: CRC compute in clk2 clock domain
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module clk_2_module (
	// Input signals
	clk_2,
	rst_n,
	clk1_message,
	clk1_CRC,
	clk1_mode,
	clk1_flag,
	// Output signals
	clk2_out,
	clk2_flag
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input 			  clk_2;	
input 			  rst_n;

input 	   [59:0] clk1_message;
input 			  clk1_CRC;
input 			  clk1_mode;
input 			  clk1_flag;

output reg [59:0] clk2_out;
output 			  clk2_flag;


//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
reg  [5:0]  cnt;
reg  [59:0] dividend;
reg  [8:0]  remainder;

reg 	    shift_en;
reg  	    done_en;

wire 	    sync_lvl;
wire 	    sync_pls;

reg  [59:0] clk2_message;
reg 	    start_crc;

reg 	    clk2_CRC;
reg 	    clk2_mode;

wire [8:0]  next_remainder;
wire [5:0]	cnt_target;
wire 		last_iter;
wire  	    bit_in_0;
wire [8:0]  rem_1;

localparam CNT_CRC5 = 6'd55;
localparam CNT_CRC8 = 6'd52;


// 2-ff synchronizer
cdc_sync i_cdc_sync_clk2 (
	.clk  (clk_2),
	.rst_n(rst_n),
	.d    (clk1_flag),
	.q    (sync_lvl)
);


// pulse generator
plsgen i_plsgen_clk2 (
	.clk  (clk_2),
	.rst_n(rst_n),
	.d    (sync_lvl),
	.pls  (sync_pls)
);




// sync crc
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		clk2_CRC <= 1'b0;
  else if(sync_pls) clk2_CRC <= clk1_CRC;
  else 				clk2_CRC <= clk2_CRC;
end

// sync mode
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		clk2_mode <= 1'b0;
  else if(sync_pls) clk2_mode <= clk1_mode;
  else 				clk2_mode <= clk2_mode;
end

// sync message
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		clk2_message <= 60'd0;
  else if(sync_pls) clk2_message <= clk1_message;
  else 				clk2_message <= clk2_message;
end



// clk2 in_valid
always @(posedge clk_2 or negedge rst_n) begin
  if (!rst_n) start_crc <= 1'b0;
  else 		  start_crc <= sync_pls;
end


// count crc intermediate
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 			cnt <= 6'd0;
  else if(start_crc) 	cnt <= 6'd0;
  else if(shift_en) 	cnt <= cnt + 6'd1;
  else 					cnt <= cnt;
end

// last cnt
assign cnt_target  = clk2_CRC? (CNT_CRC5-1) : (CNT_CRC8-1);
assign last_iter   = shift_en && (cnt == cnt_target);

// done
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		 done_en <= 1'b0;
  else if(start_crc) done_en <= 1'b0;
  else       		 done_en <= last_iter;
end



// shift_en
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		 shift_en <= 1'b0;
  else if(start_crc) shift_en <= 1'b1;
  else if(last_iter) shift_en <= 1'b0;
  else 				 shift_en <= shift_en;
end 



//---------------------------------------------------------------------
// Dividend
// mode = 1: check CRC
// mode = 0: generate CRC
// CRC  = 0: CRC-8
// CRC  = 1: CRC-5
//---------------------------------------------------------------------
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 				dividend <= 60'd0;
  else begin
	  if(start_crc) begin
		if(clk2_mode) 	  	dividend <= clk2_message; 
		else begin
		  if(clk2_CRC) 		dividend <= {clk2_message[54:0], 5'd0};
		  else 				dividend <= {clk2_message[51:0], 8'd0};
		end
	  end else if(shift_en) dividend <= {dividend[58:0], 1'b0}; 
	  else 		 			dividend <= dividend;
  end
end

assign bit_in_0 = clk2_CRC ? dividend[53] : dividend[50];


crc_step i_crc_step_0 (
	.sel(clk2_CRC),
	 .bit_in(bit_in_0),
	 .rem_in(remainder),
	 .rem_out(rem_1)
);

assign next_remainder = rem_1;


// calculate crc remainder
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 			  remainder <= 9'd0;  
  else begin
    if(start_crc) begin
	  if(clk2_mode)  	  remainder <= clk2_CRC ? {3'd0, clk2_message[59:54]} : clk2_message[59:51];
	  else 				  remainder <= clk2_CRC ? {3'd0, clk2_message[54:49]} : clk2_message[51:43];
	end else if(shift_en) remainder <= next_remainder;
	else 			      remainder <= remainder;				
  end
end


// out 
always @(posedge clk_2 or negedge rst_n) begin
  if(!rst_n) 		  clk2_out <= 60'd0;
  else begin
    if(done_en) begin
      if(clk2_mode) begin
	    if(clk2_CRC)  clk2_out <= (|remainder[5:1])? {60{1'b1}} : {60{1'b0}}; 
		else  		  clk2_out <= (|remainder[8:1])? {60{1'b1}} : {60{1'b0}}; // |remainder means remainder != 0;
	  end else begin
        if(clk2_CRC)  clk2_out <= {clk2_message[54:0], remainder[5:1]};
		else 		  clk2_out <= {clk2_message[51:0], remainder[8:1]};
	  end
    end else 		  clk2_out <= clk2_out;
  end
end


// toggle ff
toggleff i_toggleff_clk2 (
	.clk  (clk_2),
	.rst_n(rst_n),
	.d    (done_en),
	.lvl  (clk2_flag)
);


endmodule   

*/