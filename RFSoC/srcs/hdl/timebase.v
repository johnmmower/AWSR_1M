
module timebase
  (
   input 	     clk,
   input [31:0]      a_nextsec,
   input 	     pps,
   output reg [31:0] tic,
   output reg [31:0] sec_l,
   output reg [63:0] ppstime_l,
   output reg 	     l_valid
   );

   reg 		     pps_t1;
   
   always @(posedge clk) begin
      pps_t1 <= pps;
      
      tic <= tic + 'b1;

      if (pps && !pps_t1) 
	ppstime_l <= {a_nextsec, tic};

      if (pps && !pps_t1)
	sec_l <= a_nextsec;
      
      if (pps && !pps_t1)
	l_valid <= 1;
      else
	l_valid <= 0;
   end	 

endmodule

   
