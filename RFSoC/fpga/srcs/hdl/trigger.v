
module trigger
  (
   input 	    clk,

   input [15:0]     azimuth,       // current antenna position
   
   // a* vals latched at rst falling edge
   input 	    arst,          // run is opposite

   input 	    aruntx,        // use transmitter
   input 	    arunrx,        // use receiver
   input [31:0]     aprfcnt,       // prf dwell counter
   input [15:0]     aintcnta,      // integration counter cha
   input [15:0]     aintcntb,      // integration counter chb
   input [15:0]     alowazi,       // blanking start \__ note swap for blank over zero
   input [15:0]     ahghazi,       // blanking stop  /   equality means no blank
   input [7:0]      aantseq,       // antenna switch sequence

   output reg       ltch_var,      // "time to latch the variables" pun on 
                                   // cousin Tommy's "time to make the donuts"

   output reg [1:0] antenna,       // set current antenna, jumps on rx int ch.A
   output reg       tx_trig,       // one-shot tx
   output reg       rx_trig,       // one-shot rx
   output reg       rx_trig_int_a, // one-shot rx int. start a
   output reg       rx_trig_int_b, // one-shot rx int. start b
   );

   (* ASYNC_REG = "TRUE" *)
   reg arst_t1, arst_t2;
   reg [7:0] rst_buf;
   reg 	     rst_m1;
   reg 	     rst;
   wire      run = ~rst;
   reg 	     run_t1;
   
   reg 	      runtx;
   reg 	      runrx;
   reg [31:0] prfcnt;
   reg [15:0] intcnta;
   reg [15:0] intcntb;
   reg [15:0] lowazi;
   reg [15:0] hghazi;
   reg [7:0]  antseq;

   reg 	      dwell_trig;
   reg [31:0] dwell_cntr;

   reg [15:0] int_cntr_a;
   reg [15:0] int_cntr_b;

   reg [15:0] azimuth_ant;
   reg        has_blank;
   reg 	      azi_swap;
   reg 	      azi_g_low;
   reg 	      azi_g_hgh;
   reg 	      azi_l_low;
   reg 	      azi_l_hgh;
   reg 	      blanking;
   
   always @(posedge clk) begin

      // rst cdc and run/latch
      arst_t1 <= arst;
      arst_t2 <= arst_t1;
      rst_buf <= {rst_buf[6:0], arst_t2};
      rst_m1 <= |rst_buf;
      rst <= rst_m1;
      run_t1 <= run;

      // signal for local and 
      // upper latch of variables
      if (rst && ~rst_m1)
	ltch_var <= 1;
      else
	ltch_var <= 0;

      // set run but clear if rst
      if (rst) begin
	 runtx <= 0;
	 runrx <= 0;
      end
      else if (ltch_var) begin
	 runtx <= aruntx;
	 runrx <= arunrx;
      end

      // set variables from async 
      if (ltch_var) begin
	 prfcnt <= aprfcnt;
	 intcnta <= aintcnta;
	 intcntb <= aintcntb;
	 lowazi <= alowazi;
	 hghazi <= ahghazi;
	 antseq <= aaantseq;
      end

      // count down
      if (run && (~run_t1 || dwell_cnt == prfcnt))
	dwell_cnt <= 1;
      else
	dwell_cnt <= dwell_cnt + 'b1;

      if (run && dwell_cnt == 1)
	dwell_trig <= 1;
      else
	dwell_trig <= 0;

      // SHIT
      // antenna set on int chA
      if (rst && ~rst_m1)
	ant_used <= 
      
      if (rst && ~rst_m1)
	antenna <= 0;
      else if (dwell_trig && (intcnta <= 1 || int_cntr_a == intcnta))
	antenna <= antenna + 'b1;
   
      // timing.....! delay dwll_trig??????
      // needs antenna active...!
      // blanking region predetermine
      case (antenna)
	2'b00 : azimuth_ant <= azimuth;
	2'b01 : azimuth_ant <= azimuth + 
      
      has_blank <= lowazi != hghazi;
      azi_swap <= lowazi > hghazi;
      azi_g_hgh <= azimuth > hghazi;
      azi_l_low <= azimuth < lowazi;
      azi_g_low <= azimuth > lowazi;
      azi_l_hgh <= azimuth < hghazi;
	//END SHIT

	
      if (has_blank)
	if (~azi_swap)
	  blanking <= azi_g_low && azi_l_hgh;
	else
	  blanking <= azi_l_low || azi_g_hgh;
      else
	blanking <= 0;
            
      // transmit?
      if (runtx && && dwell_trig && ~blanking)
	tx_trig <= 1;
      else
	tx_trig <= 0;

      // receive?
      if (runrx && && dwell_trig && ~blanking)
	rx_trig <= 1;
      else
	rx_trig <= 0;

      if (runrx && dwell_trig && ~blanking && (intcnta <= 1 || int_cntr_a == intcnta))
	rx_trig_int_a <= 1;
      else 
	rx_trig_int_a <= 0;
	
      if (runrx && dwell_trig && ~blanking && (intcntb <= 1 || int_cntr_b == intcntb))
	rx_trig_int_b <= 1;
      else 
	rx_trig_int_b <= 0;
	      
   end
   
endmodule

   
