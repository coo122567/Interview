//////////////////////////////////////////////////
//
// Module Name: top
// 
// Author	  : Jamie Jhang
//
// Description: GCC (Gravity/Geometric Center Calculator)
//   				- Maintain a 6-point sliding window of (Xi, Yi, Wi).
//   				- Compute weighted center (Xc, Yc) by:
//        				Xc = round( sum(Xi*Wi) / sum(Wi) )
//        				Yc = round( sum(Yi*Wi) / sum(Wi) )
//   				- After window is full, replace the "farthest" point from current center
//                    (with tie-break rules) by the newest incoming point.
//
// Notes: This design is fully combinational for distance evaluation & compare,
//     	  and sequential for buffering / counters / outputs.
//          - READY_ is asserted high normally; goes low to indicate output valid.
//
//////////////////////////////////////////////////
`timescale 1ns/1ps


module top (
  input  wire       CLK,
  input  wire       RESET_,
  input  wire [7:0] Xi,
  input  wire [7:0] Yi,
  input  wire [3:0] Wi,

  output wire       READY_,
  output wire [7:0] Xc,
  output wire [7:0] Yc
);

//---------------------------------------------------------------------
// REGISTER / WIRE DECLARATION
//---------------------------------------------------------------------
// cnt:
//   0~5  : filling stage (collect 6 points)
//   >=6  : steady stage  (each cycle: compute center + replace one farthest point)
reg  [2:0]  cnt;

// check output when !READY_ 
reg  	    reg_READY_;

// Output registers
reg  [7:0]  Xc_reg;
reg  [7:0]  Yc_reg;


// --------------------------------------------------------------------
// 6-entry buffers (sliding window)
//   Xi_buf_k, Yi_buf_k, Wi_buf_k : store k-th point in window
//   XiWi_buf_k, YiWi_buf_k       : store products to reduce re-multiply cost
// --------------------------------------------------------------------
reg  [7:0]  Xi_buf_1;
reg  [7:0]  Xi_buf_2;
reg  [7:0]  Xi_buf_3;
reg  [7:0]  Xi_buf_4;
reg  [7:0]  Xi_buf_5;
reg  [7:0]  Xi_buf_6;

reg  [7:0]  Yi_buf_1;
reg  [7:0]  Yi_buf_2;
reg  [7:0]  Yi_buf_3;
reg  [7:0]  Yi_buf_4;
reg  [7:0]  Yi_buf_5;
reg  [7:0]  Yi_buf_6;

reg  [3:0]  Wi_buf_1;
reg  [3:0]  Wi_buf_2;
reg  [3:0]  Wi_buf_3;
reg  [3:0]  Wi_buf_4;
reg  [3:0]  Wi_buf_5;
reg  [3:0]  Wi_buf_6;

reg  [11:0] XiWi_buf_1;
reg  [11:0] XiWi_buf_2;
reg  [11:0] XiWi_buf_3;
reg  [11:0] XiWi_buf_4;
reg  [11:0] XiWi_buf_5;
reg  [11:0] XiWi_buf_6;

reg  [11:0] YiWi_buf_1;
reg  [11:0] YiWi_buf_2;
reg  [11:0] YiWi_buf_3;
reg  [11:0] YiWi_buf_4;
reg  [11:0] YiWi_buf_5;
reg  [11:0] YiWi_buf_6;

// Current input products(multiplier)
wire [11:0] XiWi;
wire [11:0] YiWi;


// --------------------------------------------------------------------
// Distance calculation (each point -> distance to current center)
// --------------------------------------------------------------------
wire [7:0]  x_distance_1;
wire [7:0]  x_distance_2;
wire [7:0]  x_distance_3;
wire [7:0]  x_distance_4;
wire [7:0]  x_distance_5;
wire [7:0]  x_distance_6;

wire [7:0]  y_distance_1;
wire [7:0]  y_distance_2;
wire [7:0]  y_distance_3;
wire [7:0]  y_distance_4;
wire [7:0]  y_distance_5;
wire [7:0]  y_distance_6;

wire [15:0] x_distance_square_1;
wire [15:0] x_distance_square_2;
wire [15:0] x_distance_square_3;
wire [15:0] x_distance_square_4;
wire [15:0] x_distance_square_5;
wire [15:0] x_distance_square_6;

wire [15:0] y_distance_square_1;
wire [15:0] y_distance_square_2;
wire [15:0] y_distance_square_3;
wire [15:0] y_distance_square_4;
wire [15:0] y_distance_square_5;
wire [15:0] y_distance_square_6;

// distance_k = dx^2 + dy^2 
wire [16:0] distance_1;
wire [16:0] distance_2;
wire [16:0] distance_3;
wire [16:0] distance_4;
wire [16:0] distance_5;
wire [16:0] distance_6;

// Wi_sum  : sum of 6 weights 
// XiWi_sum/YiWi_sum : sum of 6 products
wire [6:0]  Wi_sum;
wire [14:0] XiWi_sum;
wire [14:0] YiWi_sum;

// For rounding: add (Wi_sum/2) before division
wire [6:0]  Wi_sum_div2;

// Rounded center outputs
wire [7:0]  Xc_round;
wire [7:0]  Yc_round;

// Control
wire 	    done_en;
wire        hold_en;


// --------------------------------------------------------------------
// Comparator for selecting the "farthest" point to replace
// cmp_key = {distance, ~Xi, ~Yi, ~Wi}  (bigger = farther; tie->smaller Xi/Yi/Wi wins)
// --------------------------------------------------------------------
wire [36:0] cmp_key_1;
wire [36:0] cmp_key_2;
wire [36:0] cmp_key_3;
wire [36:0] cmp_key_4;
wire [36:0] cmp_key_5;
wire [36:0] cmp_key_6;

wire        sel_12;
wire        sel_34;
wire        sel_56;
wire        sel_1234;
wire        sel_123456;

wire [36:0] win_key_12;
wire [36:0] win_key_34;
wire [36:0] win_key_56;
wire [36:0] win_key_1234;

wire [2:0]  win_idx_12;
wire [2:0]  win_idx_34;
wire [2:0]  win_idx_56;
wire [2:0]  win_idx_1234;

// replace_idx:
//   Index (1~6) of the point in window that should be replaced by the newest input.
wire [2:0]  replace_idx;


//---------------------------------------------------------------------
// Multiplier
//---------------------------------------------------------------------
assign XiWi = Xi * Wi;
assign YiWi = Yi * Wi;



//---------------------------------------------------------------------
// Sliding window buffers
//---------------------------------------------------------------------
// Behavior:
//   - Filling stage (cnt < 6):
//       Shift data forward each cycle: buf1<=in, buf2<=buf1, ..., buf6<=buf5
//   - Steady stage (cnt >= 6):
//       Only update the entry indicated by replace_idx with newest input;
//       other entries hold their previous values.
//

//---------------------------------------------------------------------
// buffer #1
//---------------------------------------------------------------------
// buffer #1 for Xi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Xi_buf_1 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Xi_buf_1 <= Xi;       // fill: shift-in window
	else begin
	  if(replace_idx == 3'd1) Xi_buf_1 <= Xi;       // steady: replace if selected
	  else 					  Xi_buf_1 <= Xi_buf_1; // hold
	end	
  end
end

// buffer #1 for Yi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Yi_buf_1 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Yi_buf_1 <= Yi;
	else begin
	  if(replace_idx == 3'd1) Yi_buf_1 <= Yi;
	  else 					  Yi_buf_1 <= Yi_buf_1;
	end	
  end
end

// buffer #1 for Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Wi_buf_1 <= 4'd0;
  else begin
	if(cnt < 3'd6) 			  Wi_buf_1 <= Wi;
	else begin
	  if(replace_idx == 3'd1) Wi_buf_1 <= Wi;
	  else 					  Wi_buf_1 <= Wi_buf_1;
	end	
  end
end

// buffer #1 for Xi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  XiWi_buf_1 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  XiWi_buf_1 <= XiWi;
	else begin
	  if(replace_idx == 3'd1) XiWi_buf_1 <= XiWi;
	  else 					  XiWi_buf_1 <= XiWi_buf_1;
	end	
  end
end

// buffer #1 for Yi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  YiWi_buf_1 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  YiWi_buf_1 <= YiWi;
	else begin
	  if(replace_idx == 3'd1) YiWi_buf_1 <= YiWi;
	  else 					  YiWi_buf_1 <= YiWi_buf_1;
	end	
  end
end


//---------------------------------------------------------------------
// buffer #2
//---------------------------------------------------------------------
// buffer #2 for Xi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Xi_buf_2 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Xi_buf_2 <= Xi_buf_1;
	else begin
	  if(replace_idx == 3'd2) Xi_buf_2 <= Xi;
	  else 					  Xi_buf_2 <= Xi_buf_2;
	end	
  end
end

// buffer #2 for Yi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Yi_buf_2 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Yi_buf_2 <= Yi_buf_1;
	else begin
	  if(replace_idx == 3'd2) Yi_buf_2 <= Yi;
	  else 					  Yi_buf_2 <= Yi_buf_2;
	end	
  end
end

// buffer #2 for Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Wi_buf_2 <= 4'd0;
  else begin
	if(cnt < 3'd6) 			  Wi_buf_2 <= Wi_buf_1;
	else begin
	  if(replace_idx == 3'd2) Wi_buf_2 <= Wi;
	  else 					  Wi_buf_2 <= Wi_buf_2;
	end	
  end
end

// buffer #2 for Xi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  XiWi_buf_2 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  XiWi_buf_2 <= XiWi_buf_1;
	else begin
	  if(replace_idx == 3'd2) XiWi_buf_2 <= XiWi;
	  else 					  XiWi_buf_2 <= XiWi_buf_2;
	end	
  end
end

// buffer #2 for Yi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  YiWi_buf_2 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  YiWi_buf_2 <= YiWi_buf_1;
	else begin
	  if(replace_idx == 3'd2) YiWi_buf_2 <= YiWi;
	  else 					  YiWi_buf_2 <= YiWi_buf_2;
	end	
  end
end


//---------------------------------------------------------------------
// buffer #3
//---------------------------------------------------------------------
// buffer #3 for Xi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Xi_buf_3 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Xi_buf_3 <= Xi_buf_2;
	else begin
	  if(replace_idx == 3'd3) Xi_buf_3 <= Xi;
	  else 					  Xi_buf_3 <= Xi_buf_3;
	end	
  end
end

// buffer #3 for Yi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Yi_buf_3 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Yi_buf_3 <= Yi_buf_2;
	else begin
	  if(replace_idx == 3'd3) Yi_buf_3 <= Yi;
	  else 					  Yi_buf_3 <= Yi_buf_3;
	end	
  end
end

// buffer #3 for Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Wi_buf_3 <= 4'd0;
  else begin
	if(cnt < 3'd6) 			  Wi_buf_3 <= Wi_buf_2;
	else begin
	  if(replace_idx == 3'd3) Wi_buf_3 <= Wi;
	  else 					  Wi_buf_3 <= Wi_buf_3;
	end	
  end
end

// buffer #3 for Xi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  XiWi_buf_3 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  XiWi_buf_3 <= XiWi_buf_2;
	else begin
	  if(replace_idx == 3'd3) XiWi_buf_3 <= XiWi;
	  else 					  XiWi_buf_3 <= XiWi_buf_3;
	end	
  end
end

// buffer #3 for Yi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  YiWi_buf_3 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  YiWi_buf_3 <= YiWi_buf_2;
	else begin
	  if(replace_idx == 3'd3) YiWi_buf_3 <= YiWi;
	  else 					  YiWi_buf_3 <= YiWi_buf_3;
	end	
  end
end


//---------------------------------------------------------------------
// buffer #4
//---------------------------------------------------------------------
// buffer #4 for Xi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Xi_buf_4 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Xi_buf_4 <= Xi_buf_3;
	else begin
	  if(replace_idx == 3'd4) Xi_buf_4 <= Xi;
	  else 					  Xi_buf_4 <= Xi_buf_4;
	end	
  end
end

// buffer #4 for Yi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Yi_buf_4 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Yi_buf_4 <= Yi_buf_3;
	else begin
	  if(replace_idx == 3'd4) Yi_buf_4 <= Yi;
	  else 					  Yi_buf_4 <= Yi_buf_4;
	end	
  end
end

// buffer #4 for Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Wi_buf_4 <= 4'd0;
  else begin
	if(cnt < 3'd6) 			  Wi_buf_4 <= Wi_buf_3;
	else begin
	  if(replace_idx == 3'd4) Wi_buf_4 <= Wi;
	  else 					  Wi_buf_4 <= Wi_buf_4;
	end	
  end
end

// buffer #4 for Xi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  XiWi_buf_4 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  XiWi_buf_4 <= XiWi_buf_3;
	else begin
	  if(replace_idx == 3'd4) XiWi_buf_4 <= XiWi;
	  else 					  XiWi_buf_4 <= XiWi_buf_4;
	end	
  end
end

// buffer #4 for Yi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  YiWi_buf_4 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  YiWi_buf_4 <= YiWi_buf_3;
	else begin
	  if(replace_idx == 3'd4) YiWi_buf_4 <= YiWi;
	  else 					  YiWi_buf_4 <= YiWi_buf_4;
	end	
  end
end



//---------------------------------------------------------------------
// buffer #5
//---------------------------------------------------------------------
// buffer #5 for Xi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Xi_buf_5 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Xi_buf_5 <= Xi_buf_4;
	else begin
	  if(replace_idx == 3'd5) Xi_buf_5 <= Xi;
	  else 					  Xi_buf_5 <= Xi_buf_5;
	end	
  end
end

// buffer #5 for Yi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Yi_buf_5 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Yi_buf_5 <= Yi_buf_4;
	else begin
	  if(replace_idx == 3'd5) Yi_buf_5 <= Yi;
	  else 					  Yi_buf_5 <= Yi_buf_5;
	end	
  end
end

// buffer #5 for Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Wi_buf_5 <= 4'd0;
  else begin
	if(cnt < 3'd6) 			  Wi_buf_5 <= Wi_buf_4;
	else begin
	  if(replace_idx == 3'd5) Wi_buf_5 <= Wi;
	  else 					  Wi_buf_5 <= Wi_buf_5;
	end	
  end
end

// buffer #5 for Xi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  XiWi_buf_5 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  XiWi_buf_5 <= XiWi_buf_4;
	else begin
	  if(replace_idx == 3'd5) XiWi_buf_5 <= XiWi;
	  else 					  XiWi_buf_5 <= XiWi_buf_5;
	end	
  end
end

// buffer #5 for Yi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  YiWi_buf_5 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  YiWi_buf_5 <= YiWi_buf_4;
	else begin
  	  if(replace_idx == 3'd5) YiWi_buf_5 <= YiWi;
	  else 					  YiWi_buf_5 <= YiWi_buf_5;
	end	
  end
end

//---------------------------------------------------------------------
// buffer #6
//---------------------------------------------------------------------
// buffer #6 for Xi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Xi_buf_6 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Xi_buf_6 <= Xi_buf_5;
	else begin
	  if(replace_idx == 3'd6) Xi_buf_6 <= Xi;
	  else 					  Xi_buf_6 <= Xi_buf_6;
	end	
  end
end

// buffer #6 for Yi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Yi_buf_6 <= 8'd0;
  else begin
	if(cnt < 3'd6) 			  Yi_buf_6 <= Yi_buf_5;
	else begin
	  if(replace_idx == 3'd6) Yi_buf_6 <= Yi;
	  else 					  Yi_buf_6 <= Yi_buf_6;
	end	
  end
end

// buffer #6 for Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  Wi_buf_6 <= 4'd0;
  else begin
	if(cnt < 3'd6) 			  Wi_buf_6 <= Wi_buf_5;
	else begin
	  if(replace_idx == 3'd6) Wi_buf_6 <= Wi;
	  else 					  Wi_buf_6 <= Wi_buf_6;
	end	
  end
end

// buffer #6 for Xi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 			      XiWi_buf_6 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  XiWi_buf_6 <= XiWi_buf_5;
	else begin
	  if(replace_idx == 3'd6) XiWi_buf_6 <= XiWi;
	  else 					  XiWi_buf_6 <= XiWi_buf_6;
	end	
  end
end

// buffer #6 for Yi*Wi
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 				  YiWi_buf_6 <= 12'd0;
  else begin
	if(cnt < 3'd6) 			  YiWi_buf_6 <= YiWi_buf_5;
	else begin
	  if(replace_idx == 3'd6) YiWi_buf_6 <= YiWi;
	  else 					  YiWi_buf_6 <= YiWi_buf_6;
	end	
  end
end



//---------------------------------------------------------------------
// Weighted Sum Calculation
//---------------------------------------------------------------------
// Compute sums over the 6 buffered points
assign Wi_sum 	= (Wi_buf_1 + Wi_buf_2 + Wi_buf_3 + Wi_buf_4 + Wi_buf_5 + Wi_buf_6);
assign YiWi_sum = (YiWi_buf_1 + YiWi_buf_2 + YiWi_buf_3 + YiWi_buf_4 + YiWi_buf_5 + YiWi_buf_6);
assign XiWi_sum = (XiWi_buf_1 + XiWi_buf_2 + XiWi_buf_3 + XiWi_buf_4 + XiWi_buf_5 + XiWi_buf_6);	



//---------------------------------------------------------------------
// Divider + Rounding
//---------------------------------------------------------------------
// Xc_round = XiWi_sum / Wi_sum  & round up
// Yc_round = YiWi_sum / Wi_sum  & round up
// Wi_sum_div2 has 7-bits
// (XiWi_sum + Wi_sum_div2) has 16-bits
// Rounding logic: adding half of divisor (Wi_sum/2) before division implements round-to-nearest.
assign Wi_sum_div2  = {1'b0, Wi_sum[6:1]};

assign Xc_round = (XiWi_sum + Wi_sum_div2) / Wi_sum;
assign Yc_round = (YiWi_sum + Wi_sum_div2) / Wi_sum;



//---------------------------------------------------------------------
// control signals 
//---------------------------------------------------------------------
// counter
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_)   cnt <= 3'd0;
  else begin
	if(hold_en) cnt <= cnt;
	else 		cnt <= cnt + 3'd1;
  end
end

// done
assign done_en = (cnt >= 3'd1);

// stall
assign hold_en = (cnt == 3'd6);


//---------------------------------------------------------------------
// Output
//---------------------------------------------------------------------
// Xc
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_)   Xc_reg <= 8'd0;
  else begin
	if(done_en) Xc_reg <= Xc_round;
	else   		Xc_reg <= 8'd0;
  end
end

// Yc
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_)   Yc_reg <= 8'd0;
  else begin
	if(done_en) Yc_reg <= Yc_round;
	else  	    Yc_reg <= 8'd0;
  end
end

// READY_ == 0 means output valid (active-low valid)
always @(posedge CLK or negedge RESET_) begin
  if(!RESET_) 	reg_READY_ <= 1'b1;
  else begin
	if(done_en) reg_READY_ <= 1'b0;
	else 		reg_READY_ <= 1'b1;
  end
end


assign Xc     = Xc_reg;
assign Yc     = Yc_reg;
assign READY_ = reg_READY_;


//---------------------------------------------------------------------
// Distance Engine
//---------------------------------------------------------------------
// Compute squared distance from each buffered point to current center (Xc_round, Yc_round)
// distance = (|Xc-Xi|^2) + (|Yc-Yi|^2)

// absolute value
assign x_distance_1 = (Xc_round >= Xi_buf_1)? (Xc_round - Xi_buf_1) : (Xi_buf_1 - Xc_round);
assign y_distance_1 = (Yc_round >= Yi_buf_1)? (Yc_round - Yi_buf_1) : (Yi_buf_1 - Yc_round);

assign x_distance_2 = (Xc_round >= Xi_buf_2)? (Xc_round - Xi_buf_2) : (Xi_buf_2 - Xc_round);
assign y_distance_2 = (Yc_round >= Yi_buf_2)? (Yc_round - Yi_buf_2) : (Yi_buf_2 - Yc_round);

assign x_distance_3 = (Xc_round >= Xi_buf_3)? (Xc_round - Xi_buf_3) : (Xi_buf_3 - Xc_round);
assign y_distance_3 = (Yc_round >= Yi_buf_3)? (Yc_round - Yi_buf_3) : (Yi_buf_3 - Yc_round);

assign x_distance_4 = (Xc_round >= Xi_buf_4)? (Xc_round - Xi_buf_4) : (Xi_buf_4 - Xc_round);
assign y_distance_4 = (Yc_round >= Yi_buf_4)? (Yc_round - Yi_buf_4) : (Yi_buf_4 - Yc_round);

assign x_distance_5 = (Xc_round >= Xi_buf_5)? (Xc_round - Xi_buf_5) : (Xi_buf_5 - Xc_round);
assign y_distance_5 = (Yc_round >= Yi_buf_5)? (Yc_round - Yi_buf_5) : (Yi_buf_5 - Yc_round);

assign x_distance_6 = (Xc_round >= Xi_buf_6)? (Xc_round - Xi_buf_6) : (Xi_buf_6 - Xc_round);
assign y_distance_6 = (Yc_round >= Yi_buf_6)? (Yc_round - Yi_buf_6) : (Yi_buf_6 - Yc_round);


// x/y direction distance square 
// x/y distance square for point 1
assign x_distance_square_1 = x_distance_1 * x_distance_1;
assign y_distance_square_1 = y_distance_1 * y_distance_1;

// x/y distance square for point 2
assign x_distance_square_2 = x_distance_2 * x_distance_2;
assign y_distance_square_2 = y_distance_2 * y_distance_2;

// x/y distance square for point 3
assign x_distance_square_3 = x_distance_3 * x_distance_3;
assign y_distance_square_3 = y_distance_3 * y_distance_3;

// x/y distance square for point 4
assign x_distance_square_4 = x_distance_4 * x_distance_4;
assign y_distance_square_4 = y_distance_4 * y_distance_4;

// x/y distance square for point 5
assign x_distance_square_5 = x_distance_5 * x_distance_5;
assign y_distance_square_5 = y_distance_5 * y_distance_5;

// x/y distance square for point 6
assign x_distance_square_6 = x_distance_6 * x_distance_6;
assign y_distance_square_6 = y_distance_6 * y_distance_6;

// distance
assign distance_1 = x_distance_square_1 + y_distance_square_1;
assign distance_2 = x_distance_square_2 + y_distance_square_2;
assign distance_3 = x_distance_square_3 + y_distance_square_3;
assign distance_4 = x_distance_square_4 + y_distance_square_4;
assign distance_5 = x_distance_square_5 + y_distance_square_5;
assign distance_6 = x_distance_square_6 + y_distance_square_6;



//---------------------------------------------------------------------
// Comparator - select farthest point to replace
//---------------------------------------------------------------------
// Farthest selector - priority: distance -> Xi -> Yi -> Wi
// Priority rule for replacement (largest wins):
//   1. Larger distance wins
//   2. If equal distance: smaller Xi wins
//   3. If equal Xi      : smaller Yi wins
//   4. If equal Yi      : smaller Wi wins
//
// distance has 17 bits 
// Xi has 8 bits
// Yi has 8 bits
// Wi has 4 bits
// cmp_key width = 17 + 8 + 8 + 4 = 37 bits
//
// Use cmp_key = {distance, ~Xi, ~Yi, ~Wi}
// Higher value means: 1. Farthest distance 2. Smaller Xi 3. Smaller Yi 4. Smaller Wi
assign cmp_key_1 = {distance_1, ~Xi_buf_1, ~Yi_buf_1, ~Wi_buf_1};
assign cmp_key_2 = {distance_2, ~Xi_buf_2, ~Yi_buf_2, ~Wi_buf_2};
assign cmp_key_3 = {distance_3, ~Xi_buf_3, ~Yi_buf_3, ~Wi_buf_3};
assign cmp_key_4 = {distance_4, ~Xi_buf_4, ~Yi_buf_4, ~Wi_buf_4};
assign cmp_key_5 = {distance_5, ~Xi_buf_5, ~Yi_buf_5, ~Wi_buf_5};
assign cmp_key_6 = {distance_6, ~Xi_buf_6, ~Yi_buf_6, ~Wi_buf_6};


// compare point 1 vs. point 2
assign sel_12     = (cmp_key_1 >= cmp_key_2);
assign win_key_12 = sel_12? cmp_key_1 : cmp_key_2;
assign win_idx_12 = sel_12? 3'd1 : 3'd2;

// compare point 3 vs. point 4
assign sel_34     = (cmp_key_3 >= cmp_key_4);
assign win_key_34 = sel_34? cmp_key_3 : cmp_key_4;
assign win_idx_34 = sel_34? 3'd3 : 3'd4;

// compare point 5 vs. point 6
assign sel_56     = (cmp_key_5 >= cmp_key_6);
assign win_key_56 = sel_56? cmp_key_5 : cmp_key_6;
assign win_idx_56 = sel_56? 3'd5 : 3'd6;

// compare (winner of point 1 & 2) vs. (winner of point 3 & 4)
assign sel_1234     = (win_key_12 >= win_key_34);
assign win_key_1234 = sel_1234? win_key_12 : win_key_34;
assign win_idx_1234 = sel_1234? win_idx_12 : win_idx_34;

// compare (winner of point 1~4) vs. (winner of point 5 & 6)
// Winner of (1~6) => final replacement index
assign sel_123456   = (win_key_1234 >= win_key_56);
assign replace_idx  = sel_123456? win_idx_1234 : win_idx_56;


endmodule











































/*
// Baseline 
//////////////////////////////////////////////////
//
// Module Name: top
// 
// Author	  : Jamie Jhang
//
// Description: GCC (Gravity/Geometric Center Calculator)
//   				- Maintain a 6-point sliding window of (Xi, Yi, Wi).
//   				- Compute weighted center (Xc, Yc) by:
//        				Xc = round( sum(Xi*Wi) / sum(Wi) )
//        				Yc = round( sum(Yi*Wi) / sum(Wi) )
//   				- After window is full, replace the "farthest" point from current center
//                    (with tie-break rules) by the newest incoming point.
//
// Notes: This design is fully combinational for distance evaluation & compare,
//     	  and sequential for buffering / counters / outputs.
//          - READY_ is asserted high normally; goes low to indicate output valid.
//
//////////////////////////////////////////////////
`timescale 1ns/1ps
 
module top (
	CLK,
	RESET_,
	Xi,
	Yi,
	Wi,
	READY_,
	Xc,
	Yc
);


//---------------------------------------------------------------------
// INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input        CLK;
input        RESET_;
input  [7:0] Xi;
input  [7:0] Yi;
input  [3:0] Wi;

output       READY_;
output [7:0] Xc; 
output [7:0] Yc;


//---------------------------------------------------------------------
// REGISTER / WIRE DECLARATION
//---------------------------------------------------------------------
// cnt:
//   0~5  : filling stage (collect 6 points)
//   >=6  : steady stage  (each cycle: compute center + replace one farthest point)
reg  [2:0]  cnt;

// check output when !READY_ 
reg  	    READY_;

// Output registers
reg  [7:0]  Xc;
reg  [7:0]  Yc;


// --------------------------------------------------------------------
// 6-entry buffers (sliding window)
//   Xi_buf_k, Yi_buf_k, Wi_buf_k : store k-th point in window
//   XiWi_buf_k, YiWi_buf_k       : store products to reduce re-multiply cost
// --------------------------------------------------------------------
reg  [7:0]  Xi_buf_1;
reg  [7:0]  Xi_buf_2;
reg  [7:0]  Xi_buf_3;
reg  [7:0]  Xi_buf_4;
reg  [7:0]  Xi_buf_5;
reg  [7:0]  Xi_buf_6;

reg  [7:0]  Yi_buf_1;
reg  [7:0]  Yi_buf_2;
reg  [7:0]  Yi_buf_3;
reg  [7:0]  Yi_buf_4;
reg  [7:0]  Yi_buf_5;
reg  [7:0]  Yi_buf_6;

reg  [3:0]  Wi_buf_1;
reg  [3:0]  Wi_buf_2;
reg  [3:0]  Wi_buf_3;
reg  [3:0]  Wi_buf_4;
reg  [3:0]  Wi_buf_5;
reg  [3:0]  Wi_buf_6;





// --------------------------------------------------------------------
// Distance calculation (each point -> distance to current center)
// --------------------------------------------------------------------
wire [7:0]  x_distance_1;
wire [7:0]  x_distance_2;
wire [7:0]  x_distance_3;
wire [7:0]  x_distance_4;
wire [7:0]  x_distance_5;
wire [7:0]  x_distance_6;

wire [7:0]  y_distance_1;
wire [7:0]  y_distance_2;
wire [7:0]  y_distance_3;
wire [7:0]  y_distance_4;
wire [7:0]  y_distance_5;
wire [7:0]  y_distance_6;

wire [15:0] x_distance_square_1;
wire [15:0] x_distance_square_2;
wire [15:0] x_distance_square_3;
wire [15:0] x_distance_square_4;
wire [15:0] x_distance_square_5;
wire [15:0] x_distance_square_6;

wire [15:0] y_distance_square_1;
wire [15:0] y_distance_square_2;
wire [15:0] y_distance_square_3;
wire [15:0] y_distance_square_4;
wire [15:0] y_distance_square_5;
wire [15:0] y_distance_square_6;

// distance_k = dx^2 + dy^2 
wire [16:0] distance_1;
wire [16:0] distance_2;
wire [16:0] distance_3;
wire [16:0] distance_4;
wire [16:0] distance_5;
wire [16:0] distance_6;

// Wi_sum  : sum of 6 weights 
// XiWi_sum/YiWi_sum : sum of 6 products
wire [6:0]  Wi_sum;
wire [14:0] XiWi_sum;
wire [14:0] YiWi_sum;

// For rounding: add (Wi_sum/2) before division
wire [6:0]  Wi_sum_div2;

// Rounded center outputs
wire [7:0]  Xc_round;
wire [7:0]  Yc_round;

// Control
wire 	    done_en;
wire        hold_en;


// --------------------------------------------------------------------
// Comparator for selecting the "farthest" point to replace
// cmp_key = {distance, ~Xi, ~Yi, ~Wi}  (bigger = farther; tie->smaller Xi/Yi/Wi wins)
// --------------------------------------------------------------------
wire [36:0] cmp_key_1;
wire [36:0] cmp_key_2;
wire [36:0] cmp_key_3;
wire [36:0] cmp_key_4;
wire [36:0] cmp_key_5;
wire [36:0] cmp_key_6;

wire        sel_12;
wire        sel_34;
wire        sel_56;
wire        sel_1234;
wire        sel_123456;

wire [36:0] win_key_12;
wire [36:0] win_key_34;
wire [36:0] win_key_56;
wire [36:0] win_key_1234;

wire [2:0]  win_idx_12;
wire [2:0]  win_idx_34;
wire [2:0]  win_idx_56;
wire [2:0]  win_idx_1234;

// replace_idx:
//   Index (1~6) of the point in window that should be replaced by the newest input.
wire [2:0]  replace_idx;





//---------------------------------------------------------------------
// Sliding window buffers
//---------------------------------------------------------------------
// Behavior:
//   - Filling stage (cnt < 6):
//       Shift data forward each cycle: buf1<=in, buf2<=buf1, ..., buf6<=buf5
//   - Steady stage (cnt >= 6):
//       Only update the entry indicated by replace_idx with newest input;
//       other entries hold their previous values.
//
//
//
//---------------------------------------------------------------------
// buffer #1
//---------------------------------------------------------------------
// buffer #1 for Xi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Xi_buf_1 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Xi_buf_1 <= Xi;       // fill: shift-in window
		else begin
			if(replace_idx == 3'd1) Xi_buf_1 <= Xi;       // steady: replace if selected
			else 					Xi_buf_1 <= Xi_buf_1; // hold
		end	
	end
end

// buffer #1 for Yi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Yi_buf_1 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Yi_buf_1 <= Yi;
		else begin
			if(replace_idx == 3'd1) Yi_buf_1 <= Yi;
			else 					Yi_buf_1 <= Yi_buf_1;
		end	
	end
end

// buffer #1 for Wi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Wi_buf_1 <= 4'd0;
	else begin
		if(cnt < 3'd6) 				Wi_buf_1 <= Wi;
		else begin
			if(replace_idx == 3'd1) Wi_buf_1 <= Wi;
			else 					Wi_buf_1 <= Wi_buf_1;
		end	
	end
end



//---------------------------------------------------------------------
// buffer #2
//---------------------------------------------------------------------
// buffer #2 for Xi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Xi_buf_2 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Xi_buf_2 <= Xi_buf_1;
		else begin
			if(replace_idx == 3'd2) Xi_buf_2 <= Xi;
			else 					Xi_buf_2 <= Xi_buf_2;
		end	
	end
end

// buffer #2 for Yi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Yi_buf_2 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Yi_buf_2 <= Yi_buf_1;
		else begin
			if(replace_idx == 3'd2) Yi_buf_2 <= Yi;
			else 					Yi_buf_2 <= Yi_buf_2;
		end	
	end
end

// buffer #2 for Wi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Wi_buf_2 <= 4'd0;
	else begin
		if(cnt < 3'd6) 				Wi_buf_2 <= Wi_buf_1;
		else begin
			if(replace_idx == 3'd2) Wi_buf_2 <= Wi;
			else 					Wi_buf_2 <= Wi_buf_2;
		end	
	end
end



//---------------------------------------------------------------------
// buffer #3
//---------------------------------------------------------------------
// buffer #3 for Xi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Xi_buf_3 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Xi_buf_3 <= Xi_buf_2;
		else begin
			if(replace_idx == 3'd3) Xi_buf_3 <= Xi;
			else 					Xi_buf_3 <= Xi_buf_3;
		end	
	end
end

// buffer #3 for Yi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Yi_buf_3 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Yi_buf_3 <= Yi_buf_2;
		else begin
			if(replace_idx == 3'd3) Yi_buf_3 <= Yi;
			else 					Yi_buf_3 <= Yi_buf_3;
		end	
	end
end

// buffer #3 for Wi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Wi_buf_3 <= 4'd0;
	else begin
		if(cnt < 3'd6) 				Wi_buf_3 <= Wi_buf_2;
		else begin
			if(replace_idx == 3'd3) Wi_buf_3 <= Wi;
			else 					Wi_buf_3 <= Wi_buf_3;
		end	
	end
end




//---------------------------------------------------------------------
// buffer #4
//---------------------------------------------------------------------
// buffer #4 for Xi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Xi_buf_4 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Xi_buf_4 <= Xi_buf_3;
		else begin
			if(replace_idx == 3'd4) Xi_buf_4 <= Xi;
			else 					Xi_buf_4 <= Xi_buf_4;
		end	
	end
end

// buffer #4 for Yi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Yi_buf_4 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Yi_buf_4 <= Yi_buf_3;
		else begin
			if(replace_idx == 3'd4) Yi_buf_4 <= Yi;
			else 					Yi_buf_4 <= Yi_buf_4;
		end	
	end
end

// buffer #4 for Wi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Wi_buf_4 <= 4'd0;
	else begin
		if(cnt < 3'd6) 				Wi_buf_4 <= Wi_buf_3;
		else begin
			if(replace_idx == 3'd4) Wi_buf_4 <= Wi;
			else 					Wi_buf_4 <= Wi_buf_4;
		end	
	end
end





//---------------------------------------------------------------------
// buffer #5
//---------------------------------------------------------------------
// buffer #5 for Xi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Xi_buf_5 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Xi_buf_5 <= Xi_buf_4;
		else begin
			if(replace_idx == 3'd5) Xi_buf_5 <= Xi;
			else 					Xi_buf_5 <= Xi_buf_5;
		end	
	end
end

// buffer #5 for Yi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Yi_buf_5 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Yi_buf_5 <= Yi_buf_4;
		else begin
			if(replace_idx == 3'd5) Yi_buf_5 <= Yi;
			else 					Yi_buf_5 <= Yi_buf_5;
		end	
	end
end

// buffer #5 for Wi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Wi_buf_5 <= 4'd0;
	else begin
		if(cnt < 3'd6) 				Wi_buf_5 <= Wi_buf_4;
		else begin
			if(replace_idx == 3'd5) Wi_buf_5 <= Wi;
			else 					Wi_buf_5 <= Wi_buf_5;
		end	
	end
end



//---------------------------------------------------------------------
// buffer #6
//---------------------------------------------------------------------
// buffer #6 for Xi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Xi_buf_6 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Xi_buf_6 <= Xi_buf_5;
		else begin
			if(replace_idx == 3'd6) Xi_buf_6 <= Xi;
			else 					Xi_buf_6 <= Xi_buf_6;
		end	
	end
end

// buffer #6 for Yi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Yi_buf_6 <= 8'd0;
	else begin
		if(cnt < 3'd6) 				Yi_buf_6 <= Yi_buf_5;
		else begin
			if(replace_idx == 3'd6) Yi_buf_6 <= Yi;
			else 					Yi_buf_6 <= Yi_buf_6;
		end	
	end
end

// buffer #6 for Wi
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 					Wi_buf_6 <= 4'd0;
	else begin
		if(cnt < 3'd6) 				Wi_buf_6 <= Wi_buf_5;
		else begin
			if(replace_idx == 3'd6) Wi_buf_6 <= Wi;
			else 					Wi_buf_6 <= Wi_buf_6;
		end	
	end
end





//---------------------------------------------------------------------
// Baseline-A: recompute products every cycle (naive)
//---------------------------------------------------------------------
wire [11:0] XiWi_1, XiWi_2, XiWi_3, XiWi_4, XiWi_5, XiWi_6;
wire [11:0] YiWi_1, YiWi_2, YiWi_3, YiWi_4, YiWi_5, YiWi_6;

assign XiWi_1 = Xi_buf_1 * Wi_buf_1;
assign XiWi_2 = Xi_buf_2 * Wi_buf_2;
assign XiWi_3 = Xi_buf_3 * Wi_buf_3;
assign XiWi_4 = Xi_buf_4 * Wi_buf_4;
assign XiWi_5 = Xi_buf_5 * Wi_buf_5;
assign XiWi_6 = Xi_buf_6 * Wi_buf_6;

assign YiWi_1 = Yi_buf_1 * Wi_buf_1;
assign YiWi_2 = Yi_buf_2 * Wi_buf_2;
assign YiWi_3 = Yi_buf_3 * Wi_buf_3;
assign YiWi_4 = Yi_buf_4 * Wi_buf_4;
assign YiWi_5 = Yi_buf_5 * Wi_buf_5;
assign YiWi_6 = Yi_buf_6 * Wi_buf_6;

// Weighted sums
assign Wi_sum   = (Wi_buf_1 + Wi_buf_2 + Wi_buf_3 + Wi_buf_4 + Wi_buf_5 + Wi_buf_6);
assign XiWi_sum = (XiWi_1 + XiWi_2 + XiWi_3 + XiWi_4 + XiWi_5 + XiWi_6);
assign YiWi_sum = (YiWi_1 + YiWi_2 + YiWi_3 + YiWi_4 + YiWi_5 + YiWi_6);


//---------------------------------------------------------------------
// Divider + Rounding
//---------------------------------------------------------------------
// Xc_round = XiWi_sum / Wi_sum  & round up
// Yc_round = YiWi_sum / Wi_sum  & round up
// Wi_sum_div2 has 7-bits
// (XiWi_sum + Wi_sum_div2) has 16-bits
// Rounding logic: adding half of divisor (Wi_sum/2) before division implements round-to-nearest.
assign Wi_sum_div2  = {1'b0, Wi_sum[6:1]};

assign Xc_round = (XiWi_sum + Wi_sum_div2) / Wi_sum;
assign Yc_round = (YiWi_sum + Wi_sum_div2) / Wi_sum;



//---------------------------------------------------------------------
// control signals 
//---------------------------------------------------------------------
// counter
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_)     cnt <= 3'd0;
	else begin
		if(hold_en) cnt <= cnt;
		else 		cnt <= cnt + 3'd1;
	end
end

// done
assign done_en = (cnt >= 3'd1);

// stall
assign hold_en = (cnt == 3'd6);


//---------------------------------------------------------------------
// Output
//---------------------------------------------------------------------
// Xc
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_)     Xc <= 8'd0;
	else begin
		if(done_en) Xc <= Xc_round;
		else   		Xc <= 8'd0;
	end
end

// Yc
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_)     Yc <= 8'd0;
	else begin
		if(done_en) Yc <= Yc_round;
		else  	    Yc <= 8'd0;
	end
end

// READY_ == 0 means output valid (active-low valid)
always @(posedge CLK or negedge RESET_) begin
	if(!RESET_) 	READY_ <= 1'b1;
	else begin
		if(done_en) READY_ <= 1'b0;
		else 		READY_ <= 1'b1;
	end
end



//---------------------------------------------------------------------
// Distance Engine
//---------------------------------------------------------------------
// Compute squared distance from each buffered point to current center (Xc_round, Yc_round)
// distance = (|Xc-Xi|^2) + (|Yc-Yi|^2)

// absolute value
assign x_distance_1 = (Xc_round >= Xi_buf_1)? (Xc_round - Xi_buf_1) : (Xi_buf_1 - Xc_round);
assign y_distance_1 = (Yc_round >= Yi_buf_1)? (Yc_round - Yi_buf_1) : (Yi_buf_1 - Yc_round);

assign x_distance_2 = (Xc_round >= Xi_buf_2)? (Xc_round - Xi_buf_2) : (Xi_buf_2 - Xc_round);
assign y_distance_2 = (Yc_round >= Yi_buf_2)? (Yc_round - Yi_buf_2) : (Yi_buf_2 - Yc_round);

assign x_distance_3 = (Xc_round >= Xi_buf_3)? (Xc_round - Xi_buf_3) : (Xi_buf_3 - Xc_round);
assign y_distance_3 = (Yc_round >= Yi_buf_3)? (Yc_round - Yi_buf_3) : (Yi_buf_3 - Yc_round);

assign x_distance_4 = (Xc_round >= Xi_buf_4)? (Xc_round - Xi_buf_4) : (Xi_buf_4 - Xc_round);
assign y_distance_4 = (Yc_round >= Yi_buf_4)? (Yc_round - Yi_buf_4) : (Yi_buf_4 - Yc_round);

assign x_distance_5 = (Xc_round >= Xi_buf_5)? (Xc_round - Xi_buf_5) : (Xi_buf_5 - Xc_round);
assign y_distance_5 = (Yc_round >= Yi_buf_5)? (Yc_round - Yi_buf_5) : (Yi_buf_5 - Yc_round);

assign x_distance_6 = (Xc_round >= Xi_buf_6)? (Xc_round - Xi_buf_6) : (Xi_buf_6 - Xc_round);
assign y_distance_6 = (Yc_round >= Yi_buf_6)? (Yc_round - Yi_buf_6) : (Yi_buf_6 - Yc_round);


// x/y direction distance square 
// x/y distance square for point 1
assign x_distance_square_1 = x_distance_1 * x_distance_1;
assign y_distance_square_1 = y_distance_1 * y_distance_1;

// x/y distance square for point 2
assign x_distance_square_2 = x_distance_2 * x_distance_2;
assign y_distance_square_2 = y_distance_2 * y_distance_2;

// x/y distance square for point 3
assign x_distance_square_3 = x_distance_3 * x_distance_3;
assign y_distance_square_3 = y_distance_3 * y_distance_3;

// x/y distance square for point 4
assign x_distance_square_4 = x_distance_4 * x_distance_4;
assign y_distance_square_4 = y_distance_4 * y_distance_4;

// x/y distance square for point 5
assign x_distance_square_5 = x_distance_5 * x_distance_5;
assign y_distance_square_5 = y_distance_5 * y_distance_5;

// x/y distance square for point 6
assign x_distance_square_6 = x_distance_6 * x_distance_6;
assign y_distance_square_6 = y_distance_6 * y_distance_6;

// distance
assign distance_1 = x_distance_square_1 + y_distance_square_1;
assign distance_2 = x_distance_square_2 + y_distance_square_2;
assign distance_3 = x_distance_square_3 + y_distance_square_3;
assign distance_4 = x_distance_square_4 + y_distance_square_4;
assign distance_5 = x_distance_square_5 + y_distance_square_5;
assign distance_6 = x_distance_square_6 + y_distance_square_6;



//---------------------------------------------------------------------
// Comparator - select farthest point to replace
//---------------------------------------------------------------------
// Farthest selector - priority: distance -> Xi -> Yi -> Wi
// Priority rule for replacement (largest wins):
//   1. Larger distance wins
//   2. If equal distance: smaller Xi wins
//   3. If equal Xi      : smaller Yi wins
//   4. If equal Yi      : smaller Wi wins
//
// distance has 17 bits 
// Xi has 8 bits
// Yi has 8 bits
// Wi has 4 bits
// cmp_key width = 17 + 8 + 8 + 4 = 37 bits
//
// Use cmp_key = {distance, ~Xi, ~Yi, ~Wi}
// Higher value means: 1. Farthest distance 2. Smaller Xi 3. Smaller Yi 4. Smaller Wi
assign cmp_key_1 = {distance_1, ~Xi_buf_1, ~Yi_buf_1, ~Wi_buf_1};
assign cmp_key_2 = {distance_2, ~Xi_buf_2, ~Yi_buf_2, ~Wi_buf_2};
assign cmp_key_3 = {distance_3, ~Xi_buf_3, ~Yi_buf_3, ~Wi_buf_3};
assign cmp_key_4 = {distance_4, ~Xi_buf_4, ~Yi_buf_4, ~Wi_buf_4};
assign cmp_key_5 = {distance_5, ~Xi_buf_5, ~Yi_buf_5, ~Wi_buf_5};
assign cmp_key_6 = {distance_6, ~Xi_buf_6, ~Yi_buf_6, ~Wi_buf_6};


// compare point 1 vs. point 2
assign sel_12     = (cmp_key_1 >= cmp_key_2);
assign win_key_12 = sel_12? cmp_key_1 : cmp_key_2;
assign win_idx_12 = sel_12? 3'd1 : 3'd2;

// compare point 3 vs. point 4
assign sel_34     = (cmp_key_3 >= cmp_key_4);
assign win_key_34 = sel_34? cmp_key_3 : cmp_key_4;
assign win_idx_34 = sel_34? 3'd3 : 3'd4;

// compare point 5 vs. point 6
assign sel_56     = (cmp_key_5 >= cmp_key_6);
assign win_key_56 = sel_56? cmp_key_5 : cmp_key_6;
assign win_idx_56 = sel_56? 3'd5 : 3'd6;

// compare (winner of point 1 & 2) vs. (winner of point 3 & 4)
assign sel_1234     = (win_key_12 >= win_key_34);
assign win_key_1234 = sel_1234? win_key_12 : win_key_34;
assign win_idx_1234 = sel_1234? win_idx_12 : win_idx_34;

// compare (winner of point 1~4) vs. (winner of point 5 & 6)
// Winner of (1~6) => final replacement index
assign sel_123456   = (win_key_1234 >= win_key_56);
assign replace_idx  = sel_123456? win_idx_1234 : win_idx_56;


endmodule
*/