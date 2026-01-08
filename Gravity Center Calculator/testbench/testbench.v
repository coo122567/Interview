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

`define CYCLE 33.00     
`define END_CYCLE 1000000 
// test pattern
`define INFILE "./testbench/IN.DAT"  

module testbench();

//================================================================
// Parameter Declarations
//================================================================
reg 	   CLK;
reg        RESET_;
reg  [7:0] Xi;
reg  [7:0] Yi;
reg  [3:0] Wi;
wire [7:0] Xc;
wire [7:0] Yc;
wire 	   READY_;



integer i;
integer out_f;
integer err;
integer pattern_num;

reg 	    ready;
reg [39:0]  N_PAT;
reg [39:0]  data_base [0:20000];
reg [39:0]  data_tmp;
reg [39:0]  data_tmp1;
reg [22:0]  cycle;

parameter INPUT_DATA = `INFILE;



//================================================================
// Instantiate design
//================================================================
top i_top (
	.CLK(CLK),
	.RESET_(RESET_),
	.Xi(Xi),
	.Yi(Yi),
	.Wi(Wi),
	.READY_(READY_),
	.Xc(Xc),
	.Yc(Yc)
);




//================================================================
// Clock Generation
//================================================================
initial begin
  forever #(`CYCLE / 2.0) CLK = ~CLK;
end


initial	$readmemh( INPUT_DATA,  data_base);


initial begin
   CLK 		   = 1'b1;
   RESET_      = 1'b1;
   err 		   = 0;
   pattern_num = 1; 
   ready 	   = 1'b0; 
   cycle       = 0;
end


initial begin
   out_f = $fopen("OUT.DAT");
   if (out_f == 0) begin
        $display("Output file open error !");
        $finish;
   end
end


always@(posedge CLK) begin
	cycle = cycle + 1;
	if(cycle > `END_CYCLE) begin
		$display("---------------------------------------------------");
		$display("-- Failed waiting READY_ signal, Simulation STOP --");
		$display("---------------------------------------------------");
		$fclose(out_f);
		$finish;
	end
end




initial begin
   @(negedge CLK)          RESET_ = 1'b0;
   $display ("\n******START to VERIFY GCC OPERATION ******\n");
   @(negedge CLK)          RESET_ = 1'b1;
   N_PAT = data_base[0] ; 
   for (i = 1; i <= N_PAT; i = i + 1) begin
      #(`CYCLE*0.25)  data_tmp = data_base[i] ;
            Xi = data_tmp[39:32];
            Yi = data_tmp[31:24];
            Wi = data_tmp[19:16];
      @(negedge CLK);
   end 
end  

 		
always @(posedge CLK) begin
   if (!READY_) begin
     data_tmp1 = data_base[pattern_num]; 
       $fdisplay(out_f,"%h_%h",Xc, Yc); 
     if ((Xc !== data_tmp1[15:8]) || (Yc !== data_tmp1[7:0])) begin
         $display("ERROR at %d:output (%h, %h) != expect (%h, %h)", pattern_num, Xc, Yc, data_tmp1[15:8], data_tmp1[7:0]);
       err = err + 1 ;   
     end
       pattern_num = pattern_num + 1 ; 
   end
   if (pattern_num == N_PAT)
    ready = 1 ;
end  

initial begin
      @(posedge ready)
      $display("---------------------------------------------");
      if (err == 0)
         $display("All data have been generated successfully!");
      else 
         $display("There are %d errors!", err);
      $display("---------------------------------------------");
      $finish;
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