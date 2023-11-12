
module acc_ram #(parameter ABITS=8, parameter DBITS=32)
   (
    input 		   clk,
    input [ABITS-1:0] 	   waddr,
    input 		   wen,
    input [ABITS-1:0] 	   raddr,
    input [DBITS-1:0] 	   wdata,
    output reg [DBITS-1:0] rdata
    );
   
   reg [DBITS-1:0] mem [(2**ABITS)-1:0];
   reg [DBITS-1:0] stage;

   // sim init, impl dnc
   integer i;
   initial begin
      for (i=0; i<(2**ABITS); i=i+1) 
	mem[i] = i;
   end

   always @(posedge clk) begin
      stage <= mem[raddr];
      rdata <= stage;

      if (wen)
	mem[waddr] <= wdata;
   end
      
endmodule
   
module acc_mem_accumulator #(parameter DEPTH=1024)
   (
    input 	  clk,
    input 	  trig,
    input 	  trig_int,
    input [15:0]  din,
    output [31:0] dout,
    output 	  vld // count agnostic
    );
   
   localparam BITS = $clog2(DEPTH);
   
   reg init;
   reg wen = 0;  // no reset
   reg vldl = 0; // no reset
   reg vldl_t1, vldl_t2;
   reg trig_t1;

   reg trig_s;
   reg trig_int_s;
   reg trig_s_t1, trig_s_t2, trig_s_t3, trig_s_t4;
      
   reg [BITS-1:0] waddr;
   reg [BITS-1:0] raddr;
   
   wire [31:0] 	   rdata;

   reg signed [31:0] wdata;
   reg signed [31:0] dinexp;
   reg signed [31:0] addend;
   
   assign dout = rdata;
   assign vld = vldl_t2; 
   
   always @(posedge clk) begin

      trig_t1 <= trig;
      if (trig && ~trig_t1) begin
	 trig_s <= 1;
	 if (trig_int)
	   trig_int_s <= 1;
      end 
      else begin
	 trig_s <= 0;
	 trig_int_s <= 0;
      end

      trig_s_t1 <= trig_s;
      trig_s_t2 <= trig_s_t1;
      trig_s_t3 <= trig_s_t2;
      trig_s_t4 <= trig_s_t3;
   
      vldl_t1 <= vldl;
      vldl_t2 <= vldl_t1;
      
      // sign extend input
      dinexp <= { {16{din[15]}}, din };

      if (trig_s)
	vldl <= 1;
      else if (raddr == (DEPTH-1))
	vldl <= 0;
            
      // at trig event, read out memory
      if (trig_s)
	raddr <= 0;
      else
	raddr <= raddr + 'b1;

      // write logic     
      if (trig_s_t4)
        wen <= 1;
      else if (waddr == (DEPTH-1))
	wen <= 0;
            
      // delay write
      if (trig_s_t4) 
	waddr <= 0;
      else
	waddr <= waddr + 'b1;
            
      // is this first run?
      if (trig_s)
	if (trig_int_s)
	  init <= 1;
	else
	  init <= 0;

      // addend based on init
      if (init)
	addend <= 0;
      else
	addend <= rdata;
   
      // signed addition
      wdata <= dinexp + addend;
            
   end

   acc_ram #(.ABITS(BITS))
   acc_ram_inst
     (
      .clk  (clk  ),
      .waddr(waddr),
      .wen  (wen  ),
      .raddr(raddr),
      .wdata(wdata),
      .rdata(rdata)
      );
          
endmodule

module accumulator
  (
   input clk,
   input 
