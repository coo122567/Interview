//////////////////////////////////////////////////
//
// Module Name: async_fifo
// 
// Author	  : Jamie Jhang
//
// Description: Asynchronous FIFO
//
//
//////////////////////////////////////////////////


module async_fifo #( parameter pADDR_WIDTH  = 4,
                     parameter pDATA_WIDTH  = 8,
					 parameter pSTAGES      = 2 
                   )
(
  // Write
  input  wire                   wr_clk,
  input  wire                   wr_rst_n,    
  input  wire                   wr_push, 
  input  wire [pDATA_WIDTH-1:0] wr_data,    	
  
  // Read
  input  wire                   rd_clk,	
  input  wire                   rd_rst_n,      
  input  wire                   rd_pop,  
  output wire [pDATA_WIDTH-1:0] rd_data, 

  // Empty & Full       
  output wire                   wr_full,        
  output wire                   rd_empty          
);


wire [pADDR_WIDTH-1:0] wr_addr;
wire [pADDR_WIDTH-1:0] rd_addr;
wire [pADDR_WIDTH:0]   wr_rd_ptr;
wire [pADDR_WIDTH:0]   rd_wr_ptr;
wire [pADDR_WIDTH:0]   wr_ptr;
wire [pADDR_WIDTH:0]   rd_ptr;

wire                   wr_en;
wire                   rd_en;

assign wr_en = wr_push && (!wr_full);
assign rd_en = rd_pop  && (!rd_empty);




fifo_mem #( .pADDR_WIDTH(pADDR_WIDTH),
		    .pDATA_WIDTH(pDATA_WIDTH)
		  )   
i_fifo_mem (
  .wr_clk (wr_clk),
  .rd_clk (rd_clk),
  .wr_en  (wr_en),
  .rd_en  (rd_en),
  .wr_addr(wr_addr),
  .rd_addr(rd_addr),
  .wr_data(wr_data),
  .rd_data(rd_data)
);


// Write side 
// Double FF
cdc_bus_sync #( .pSTAGES    (pSTAGES),
		        .pDATA_WIDTH((pADDR_WIDTH+1))
 		      )
i_cdc_bus_sync_w2r (
  .clk  (rd_clk),         
  .rst_n(rd_rst_n),       
  .d    (wr_ptr),           
  .q    (rd_wr_ptr)    
);



wr_ctrl #( .pADDR_WIDTH(pADDR_WIDTH)
         )
i_wr_ctrl (
  .wr_clk  (wr_clk),
  .wr_rst_n(wr_rst_n),
  .wr_push (wr_push),
  .rd_ptr  (wr_rd_ptr),
  .wr_addr (wr_addr),
  .wr_ptr  (wr_ptr),
  .wr_full (wr_full)
);


// Write side 
// Double FF
cdc_bus_sync #( .pSTAGES    (pSTAGES),
		        .pDATA_WIDTH((pADDR_WIDTH+1))
 		      )
i_cdc_bus_sync_r2d (
  .clk  (wr_clk),         
  .rst_n(wr_rst_n),       
  .d    (rd_ptr),           
  .q    (wr_rd_ptr)    
);


rd_ctrl #( .pADDR_WIDTH(pADDR_WIDTH)
         )
i_rd_ctrl ( 
  .rd_clk  (rd_clk),
  .rd_rst_n(rd_rst_n),
  .rd_pop  (rd_pop),
  .wr_ptr  (rd_wr_ptr),
  .rd_addr (rd_addr),
  .rd_ptr  (rd_ptr),
  .rd_empty(rd_empty)
);



endmodule



