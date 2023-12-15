
module trigger
  (
   input 	    clk,
   input 	    rst,            // run is opposite
   
   input [15:0]     azimuth,        // current antenna position
   
   input [31:0]     prfcntm1,       // prf dwell counter
   input [15:0]     intcntm1,       // integration counter
   input [15:0]     lowazi,         // blanking start \__ note swap for blank over zero
   input [15:0]     hghazi,         // blanking stop  /   equality means no blank
   input [7:0]      antseq,         // antenna switch sequence

   output     [1:0] antenna,        // set current antenna, jumps before rx start
   output reg       tx_trig,        // one-shot tx
   output reg       rx_trig,        // one-shot rx
   output reg       rx_trig_strt,   // one-shot rx start
   output reg       rx_trig_last    // one-shot rx stop 
   );

   wire run = ~rst;
   reg 	run_t1, run_t2, run_t3;
      
   reg 	      dwell_trig;
   reg 	      dwell_trig_t1;
   reg 	      dwell_trig_t2;
   reg 	      dwell_trig_t3;
   reg 	      dwell_trig_t4;
   reg 	      dwell_trig_t5;
   reg [31:0] dwell_cntr;

   reg [15:0] int_cntr;

   reg 	      was_last;
   reg [15:0] azimuth_ant;
   reg        has_blank;
   reg 	      azi_swap;
   reg 	      azi_g_low;
   reg 	      azi_g_hgh;
   reg 	      azi_l_low;
   reg 	      azi_l_hgh;
   reg 	      blanking;
   reg 	      blanked;
   reg 	      rx_trig_m1;
   reg 	      rx_trig_strt_m1;
   reg 	      rx_trig_last_m1;

   reg [7:0]  antseqs;
      
   assign antenna = antseqs[1:0];
      
   always @(posedge clk) begin

      run_t1 <= run;
      run_t2 <= run_t1;
      run_t3 <= run_t2;
            
      dwell_trig_t1 <= dwell_trig;
      dwell_trig_t2 <= dwell_trig_t1;
      dwell_trig_t3 <= dwell_trig_t2;
      dwell_trig_t4 <= dwell_trig_t3;
      dwell_trig_t5 <= dwell_trig_t4;

      rx_trig <= rx_trig_m1;
      rx_trig_strt <= rx_trig_strt_m1;
      rx_trig_last <= rx_trig_last_m1;
      
      // antennas and blanking
      case (antenna) 
	2'b00: azimuth_ant <= azimuth;
	2'b01: azimuth_ant <= azimuth + 16'h4000;
	2'b10: azimuth_ant <= azimuth + 16'h8000;
	2'b11: azimuth_ant <= azimuth + 16'hC000;
      endcase; 

      azi_g_hgh <= azimuth_ant > hghazi;
      azi_l_low <= azimuth_ant < lowazi;
      azi_g_low <= azimuth_ant > lowazi;
      azi_l_hgh <= azimuth_ant < hghazi;
 
      if (has_blank)
	if (~azi_swap)
	  blanking <= azi_g_low && azi_l_hgh;
	else
	  blanking <= ~(azi_l_low && azi_g_hgh);
      else
	blanking <= 0;

      if (rst)
	blanked <= 0;
      else
	if (dwell_trig_t4 && ~|int_cntr)
	  blanked <= blanking;
      
      // count down
      if (run_t2 && (~run_t3 || dwell_cntr >= prfcntm1))
	dwell_cntr <= 0;
      else
	dwell_cntr <= dwell_cntr + 'b1;

      if (run_t2 && dwell_cntr == 0)
	dwell_trig <= 1;
      else
	dwell_trig <= 0;

      // transmit?
      if (dwell_trig_t5 && ~blanked)
	tx_trig <= 1;
      else
	tx_trig <= 0;

      // receive?
      if (dwell_trig_t4)
	rx_trig_m1 <= 1;
      else
	rx_trig_m1 <= 0;

      if (dwell_trig_t4 && ~|int_cntr)
	rx_trig_strt_m1 <= 1;
      else 
	rx_trig_strt_m1 <= 0;

      if (rst)
	was_last <= 0;
      else
	if (dwell_trig_t4)
	  if (int_cntr >= intcntm1)
	    was_last <= 1;
	  else
	    was_last <= 0;
            
      if (dwell_trig_t4 && int_cntr >= intcntm1)
	rx_trig_last_m1 <= 1;
      else
	rx_trig_last_m1 <= 0;
            
      if (rst)
	int_cntr <= 0;
      else
	if (dwell_trig_t4)
	  if (int_cntr >= intcntm1)
	    int_cntr <= 0;
	  else
	    int_cntr <= int_cntr + 'b1;
      
      // antenna
      if (run && ~run_t1)
	antseqs <= { antseq[5:0], antseq[7:6] }; 
      else if (dwell_trig && was_last)
	antseqs <= { antseqs[1:0], antseqs[7:2] };
      
   end
      
endmodule

