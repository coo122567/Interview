`timescale 1ns/1ps

`define CYCLE1 14.1
`define CYCLE2 2.5
`define CYCLE3 2.7


module pattern(
	clk_1,
	clk_2,
	clk_3,
	rst_n,
	in_valid,
	mode,
	CRC,
	message,
	out_valid,
	out
);

//================================================================
// Port Declarations
//================================================================
output reg 			clk_1;
output reg			clk_2;
output reg 			clk_3;
output reg 			rst_n;
output reg 			in_valid;
output reg 			mode;
output reg 	[59:0] 	message;
output reg 			CRC;

input 				out_valid;
input		[59:0] 	out;


//================================================================
// Clock Generation
//================================================================
// Clock 1 (for input)
initial begin 
  clk_1 = 0;
  forever #(`CYCLE1 / 2.0) clk_1 = ~clk_1;
end

// Clock 2 (for CRC calculation)
initial begin
  clk_2 = 0; 
  forever #(`CYCLE2 / 2.0) clk_2 = ~clk_2;
end

// Clock 3 (for output)
initial begin
  clk_3 = 0;
  forever #(`CYCLE3 / 2.0) clk_3 = ~clk_3;
end


//================================================================
// Parameter Declarations
//================================================================
integer total_latency;  
integer latency;  				
integer total_pat;   		// total pattern 
integer pat_idx;      		// pattern index
integer i;

reg 	   inject_err;
reg [59:0] msg; 
reg [59:0] out_gold;
reg [59:0] cal_msg; 
reg [59:0] golden;
reg [59:0] message_reg;
reg 	   mode_reg;
reg 	   CRC_reg;



localparam [8:0] CRC8_POLY = 9'b1_0011_0001; // x^8 + x^5 + x^4 + 1
localparam [5:0] CRC5_POLY = 6'b10_1011;     // x^5 + x^3 + x + 1

    

//================================================================
// main test sequence 
//================================================================
initial begin

  total_pat = 100;
  total_latency = 0;	
	

  // initial	
  in_valid      = 1'b0;
  message       = {60{1'bx}};
  mode          = 1'bx;		
  CRC           = 1'bx;
  rst_n     	  = 1'b1;

  // reset sequence
  rst_seq;
  
  @(negedge clk_1);

  $display("--------------------------------------------------------------------");
  $display("                  Starting random pattern testing!                  ");
  $display("--------------------------------------------------------------------");
	
  for (pat_idx = 0; pat_idx < total_pat; pat_idx = pat_idx + 1) begin
		
    // generate input and golden answer
    gen_input; 
		
	// measure latency
	wait_out_valid;
		
	// check output against golden
	check_ans;
	
	// check single-cycle output 
	check_out_valid_cycle; 
	
	
	//$display("\033[0;34mPass\033[m | Pattern %4d | Message %03h_%04h_%04h_%04h | \033[0;32mLatency %3d\033[m", pat_idx, message_reg[59:48], message_reg[47:32], message_reg[31:16], message_reg[15:0], latency);
	$display("\033[0;34mPass\033[m | Pattern %4d | mode=%0d CRC=%0d | Message %03h_%04h_%04h_%04h | \033[0;32mLatency %3d\033[m", pat_idx, mode_reg, CRC_reg, message_reg[59:48], message_reg[47:32], message_reg[31:16], message_reg[15:0], latency);
	
	@(negedge clk_1);

  end
	
  // Final pass message
  pass_msg; 

end


//================================================================
// task
//================================================================
task rst_seq; 
  begin
  	@(negedge clk_1);
	rst_n = 1'b0;
	
    repeat(2) @(negedge clk_2);
	#(`CYCLE2/4.0);
	rst_n = 1'b1;
	
	repeat(3) @(negedge clk_1);
	repeat(3) @(negedge clk_2);
    repeat(3) @(negedge clk_3);
  end
endtask



task gen_input; 
  begin 
	in_valid 	= 1'b1;
	mode	 	= $urandom_range(1, 0);
	CRC		 	= $urandom_range(1, 0);
	inject_err  = $urandom_range(1, 0); // use only when mode = 1
	

	// build msg 
	if(CRC == 1'b0) begin
	  // CRC-8: [51:0] data, [7:0] CRC
	  msg[59:52] = 8'b0;
	  for(i = 0; i < 52; i = i + 1) begin
		msg[i] = $urandom_range(1, 0);
	  end
	  cal_msg = {msg[51:0], 8'b0};  // this for calculate golden answer 		  
	end else begin
	  msg[59:55] = 5'b0;
	  for(i = 0; i < 55; i = i + 1) begin
			msg[i] = $urandom_range(1, 0);
	  end	
	  cal_msg = {msg[54:0], 5'b0};  // this for calculate golden answer 
	end
	
	// golden answer in mode 0
	if(CRC == 1'b0) begin														
		for(i = 59; i >= 8; i = i - 1)begin
			if(cal_msg[i]) cal_msg[i-:9] = (cal_msg[i-:9] ^ CRC8_POLY);			
			else		   cal_msg[i-:9] =  cal_msg[i-:9];					   
		end
		golden = {msg[51:0], cal_msg[7:0]};
	end else begin
		for(i = 59; i >= 5; i = i - 1)begin
			if(cal_msg[i]) cal_msg[i-:6] = (cal_msg[i-:6] ^ CRC5_POLY);
			else 		   cal_msg[i-:6] =  cal_msg[i-:6];
		end
		golden = {msg[54:0], cal_msg[4:0]};
	end

	// message
	if(mode == 1'b0) 	message = msg;
	else begin
	  if(inject_err) begin
		if(CRC == 1'b0) message = {golden[59:8], ~golden[7:0]};
		else 			message = {golden[59:5], ~golden[4:0]};
	  end else 			message = golden;
	end
	
	message_reg    = message;
	mode_reg       = mode;
	CRC_reg        = CRC;

	
	// golden answer
	if(mode == 1'b0)   out_gold = golden;
	else begin
		if(inject_err) out_gold = {60{1'b1}};
		else 		   out_gold = {60{1'b0}};
	end
	
    @(negedge clk_1);

	
	in_valid = 1'b0;
	message  = {60{1'bx}};
	mode     = 1'bx;		
	CRC      = 1'bx;		
  end
endtask



// compute latency in clk3
task wait_out_valid; 
  begin
    latency = 0;
	@(posedge clk_3);
	while(out_valid !== 1'b1) begin
	
	  if(latency >= 400) begin
		$display("--------------------------------------------------------------------");
		$display(" Pattern [%d] :  The execution latency are over 400 cycles of clk_3.", pat_idx);
		$display("--------------------------------------------------------------------");
        repeat(3) @(posedge clk_3);

		$finish;
	  end
	  
	  latency = latency + 1;
      @(posedge clk_3);
    end

	total_latency = total_latency + latency;
  end 
endtask


// check output & golden
task check_ans; 
  begin 	
	if(out !== out_gold) fail_msg;
  end 
endtask



// fail
task fail_msg; 
  begin 
	$display ("--------------------------------------------------------------------");
	$display ("                       Fail!  output is wrong !                     ");
	$display ("         Pattern = [%d] | Golden ans = %h  | Your ans = %h          ", pat_idx, out_gold, out);
	$display ("--------------------------------------------------------------------");
	repeat(3) @(negedge clk_3);
	$finish;
  end 
endtask



// check output remain only one cycle
task check_out_valid_cycle; 
  begin 
    @(negedge clk_3);
    if((out_valid !== 1'b0) || (out !== 60'h0))
      begin
		$display("--------------------------------------------------------------------");
	    $display(" Pattern [%4d] : out_valid/out should remain high for only 1 clk_3 cycle!", pat_idx);
	    $display("--------------------------------------------------------------------");
	    $finish;
      end
  end 
endtask



// pass
task pass_msg;
  begin
	$display("--------------------------------------------------------------------");
	$display("                         Congratulations!                           ");
	$display("              All %4d patterns passed successfully!                 ", total_pat);
	$display("                    Total Latency : %6d cycles                      ", total_latency);
	$display("--------------------------------------------------------------------");
	repeat(3) @(negedge clk_3);
	$finish;
  end
endtask

endmodule
