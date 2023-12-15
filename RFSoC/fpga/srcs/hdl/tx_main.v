
module tx_main #(parameter ADDRBITS = 13)
  (
   input 		     clk,
   input 		     rst,      // opposite of run

   input 		     trig,     // assumed one-show

   output reg [ADDRBITS-1:0] addr,  
   output reg 		     paen,     // turns on at trigger

   input                     usepa,
   input [31:0] 	     delaym1,  // delay to addr start
   input [31:0] 	     onm1      // delay to paen stop
   );

   reg [31:0] cntr;
   reg [31:0] delaym1;
   reg [31:0] onm1;
   reg 	      usepa;
   reg 	      rst_t1;
   
   always @(posedge clk) begin
   
      rst_t1 <= rst;

      if (~rst && rst_t1) begin
	 delaym1 <= pdelaym1;
	 onm1 <= ponm1;
      end

      if (rst)
	usepa <= 0;
      else if (~rst && rst_t1)
	usepa <= pusepa;

      if (rst)
	cntr <= 32'hFFFF_FFFF;
      else
	if (trig)
	  cntr <= 0;
	else if (cntr < 32'hFFFF_FFFF)
	  cntr <= cntr + 'b1;
      
      if (rst)
	paen <= 0;
      else
	if (trig && usepa)
	  paen <= 1;
	else if (cntr >= onm1)
	  paen <= 0;

      if (rst)
	addr <= 0;
      else if (trig || cntr <= delaym1)
	addr <= 0;
      else if (addr == { ADDRBITS {1'b1} })
	addr <= { ADDRBITS {1'b1} };
      else if (cntr > delaym1)
	addr <= addr + 'b1;
	   
   end

endmodule

   
