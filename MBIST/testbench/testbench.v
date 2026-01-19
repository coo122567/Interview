//////////////////////////////////////////////////
//
// Module Name: testbench
// 
// Author	  : Jamie Jhang
//
// Description: 
//
//////////////////////////////////////////////////
`timescale 1ns/1ps

`define CYCLE     10.00     
`define END_CYCLE 1000000 


module testbench();

//================================================================
// Parameter Declarations
//================================================================
reg 	   clk;
reg        rst_n;
reg        mode;

reg        func_cs;
reg        func_we;
reg  [3:0] func_addr;
reg  [1:0] func_din;
wire [1:0] func_dout;

wire       bist_done;
wire       pass_or_fail;

// instantiate
wire       bist_cs;
wire       bist_we;
wire [3:0] bist_addr;
wire [1:0] bist_pat;

wire       mem_cs;
wire       mem_we;
wire [3:0] mem_addr;
wire [1:0] mem_din;
wire [1:0] mem_dout;



// simulation cycle
integer cycle;

assign mem_dout = func_dout;



//================================================================
// Instantiate design
//================================================================
top i_top (
	.clk         (clk),
	.rst_n       (rst_n),
	.bist_start	 (mode),
	.bist_resp   (mem_dout),
	// output signals
	.bist_cs     (bist_cs),
	.bist_we     (bist_we),
	.bist_addr   (bist_addr),
	.bist_pat    (bist_pat),
	.bist_done   (bist_done),
	.pass_or_fail(pass_or_fail)
);


mode_mux i_mode_mux (
    // input signals
	.func_cs   (func_cs),
	.func_we   (func_we),
	.func_addr (func_addr),
	.func_din  (func_din),
	.mode 	   (mode),
	.bist_cs   (bist_cs),
	.bist_we   (bist_we),
	.bist_addr (bist_addr),
	.bist_pat  (bist_pat),
	// output signals
	.mem_cs    (mem_cs),
	.mem_we    (mem_we),
	.mem_addr  (mem_addr),
	.mem_din   (mem_din)
);


// behavioral SRAM model
memory i_memory (
	.clk  (clk),
	.cs   (mem_cs),
	.we   (mem_we),
	.addr (mem_addr),
	.din  (mem_din),
	.dout (mem_dout)
);



//================================================================
// Clock Generation
//================================================================
initial begin
  clk = 1'b0;
  forever #(`CYCLE / 2.0) clk = ~clk;
end


initial begin
	// init
	rst_n     = 1'b0;
	mode      = 1'b0;     // start in function mode
	
	func_cs   = 1'b0;
	func_we   = 1'b0;
	func_addr = 4'd0;
	func_din  = 2'b00;

	cycle = 0;


	repeat (2) @(negedge clk);
	rst_n = 1'b1;
	
    @(posedge clk);
	#(`CYCLE / 4);
	mode = 1'b1;

	wait (bist_done == 1'b1);
	@(posedge clk); 
      $display("------------------------------------------");
	  $display("              BIST DONE                   ");
	  $display("------------------------------------------");
	mode = 1'b0;
	/*  
	if (pass_or_fail == 1'b1) begin
	  $display("------------------------------------------------------");
	  $display("-- BIST PASS                                          --");
	  $display("------------------------------------------------------");
	end else begin
	  $display("------------------------------------------------------");
	  $display("-- BIST FAIL                                          --");
	  $display("------------------------------------------------------");
	end
*/
	repeat (5) @(posedge clk);
	$finish;
end


always @(posedge clk or negedge rst_n) begin
  if (pass_or_fail == 1'b0) begin
      $display("------------------------------------------------------");
      $display(" BIST EARLY FAIL detected! time=%0t cycle=%0d", $time, cycle);
      $display("------------------------------------------------------");
  end
end


// avoid simulation hang
always @(posedge clk) begin
	cycle = cycle + 1;
	if(cycle > `END_CYCLE) begin
		$display("------------------------------------------------------");
		$display("   Failed waiting bist_done signal, Simulation STOP   ");
		$display("------------------------------------------------------");
		$finish;
	end
end



// dump waveform
initial begin
`ifdef RTL
	$fsdbDumpfile("./waveform/top.fsdb"); 
	$fsdbDumpvars(0, "+mda");
`endif
`ifdef GATE
	$fsdbDumpfile("./waveform/top_syn.fsdb"); 
	$fsdbDumpvars(0, "+mda");
	$sdf_annotate("./netlist/top_syn.sdf", i_top);
`endif
end  


endmodule