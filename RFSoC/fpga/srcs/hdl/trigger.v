
module trigger
  (
   input 	    clk,

   input [15:0]     azimuth,        // current antenna position
   
   // a* vals latched at rst falling edge
   input 	    arst,           // run is opposite

   input 	    aruntx,         // use transmitter
   input 	    arunrx,         // use receiver
   input [31:0]     aprfcntm1,      // prf dwell counter
   input [15:0]     aintcntam1,     // integration counter cha
   input [15:0]     aintcntbm1,     // integration counter chb
   input [15:0]     alowazi,        // blanking start \__ note swap for blank over zero
   input [15:0]     ahghazi,        // blanking stop  /   equality means no blank
   input [7:0]      aantseq,        // antenna switch sequence

   output reg       ltch_var,       // "time to latch the variables" pun on 
                                    // cousin Tommy's "time to make the donuts"

   output     [1:0] antenna,        // set current antenna, jumps before rx start ch.A
   output reg       tx_trig,        // one-shot tx
   output reg       rx_trig,        // one-shot rx
   output reg       rx_trig_strt_a, // one-shot rx start a
   output reg       rx_trig_last_a, // one-shot rx stop a
   output reg       rx_trig_strt_b, // one-shot rx start b
   output reg       rx_trig_last_b  // one-show rx stob b
   );

   wire rst;
   
   wire run = ~rst;
   reg 	run_t1, run_t2;

   reg 	      dwell_trig;
   reg 	      dwell_trig_t1;
   reg [31:0] dwell_cntr;

   reg [15:0] int_cntr_a;
   reg [15:0] int_cntr_b;

   reg 	      runtx;
   reg 	      runrx;
   reg [31:0] prfcntm1;
   reg [15:0] intcntam1;
   reg [15:0] intcntbm1;
   reg [15:0] lowazi;
   reg [15:0] hghazi;
   reg [7:0]  antseq;

   reg 	      blanking = 0;   ///// zero for now

   assign antenna = antseq[1:0];
      
   always @(posedge clk) begin

      run_t1 <= run;
      run_t2 <= run_t1;

      dwell_trig_t1 <= dwell_trig;
         
      // signal for local and 
      // upper latch of variables
      if (run && ~run_t1)
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
	 prfcntm1 <= aprfcntm1;
	 intcntam1 <= aintcntam1;
	 intcntbm1 <= aintcntbm1;
	 lowazi <= alowazi;
	 hghazi <= ahghazi;
      end
      

      // count down
      if (run_t1 && (~run_t2 || dwell_cnt >= prfcntm1))
	dwell_cnt <= 0;
      else
	dwell_cnt <= dwell_cnt + 'b1;

      if (run_t1 && dwell_cnt == 0)
	dwell_trig <= 1;
      else
	dwell_trig <= 0;

      // transmit?
      if (runtx && && dwell_trig_t1 && ~blanking)
	tx_trig <= 1;
      else
	tx_trig <= 0;

      // receive?
      if (runrx && && dwell_trig_t1 && ~blanking)
	rx_trig <= 1;
      else
	rx_trig <= 0;

      if (runrx && dwell_trig_t1 && ~blanking && ~|int_cntr_a)
	rx_trig_strt_a <= 1;
      else 
	rx_trig_strt_a <= 0;

      if (runrx && dwell_trig_t1 && ~blanking && int_cntr_a >= aintcntam1)
	rx_trig_last_a <= 1;
      else
	rx_trig_last_a <= 0;
            
      if (runrx && dwell_trig_t1 && ~blanking && ~|int_cntr_b)
	rx_trig_strt_b <= 1;
      else 
	rx_trig_strt_b <= 0;

      if (runrx && dwell_trig_t1 && ~blanking && int_cntr_b >= aintcntbm1)
	rx_trig_last_b <= 1;
      else
	rx_trig_last_b <= 0;
            
      if (rst)
	int_cntr_a <= 0;
      else
	if (dwell_trig)
	  if (int_cntr_a >= aintcntam1)
	    int_cntr_a <= 0;
	  else
	    int_cntr_a <= int_cntr_a + 'b1;
      
      if (rst)
	int_cntr_b <= 0;
      else
	if (dwell_trig)
	  if (int_cntr_b >= aintcntbm1)
	    int_cntr_b <= 0;
	  else
	    int_cntr_b <= int_cntr_b + 'b1;
      
      // antenna
      if (ltch_var)
	antseq <= { aantseq[5:0], aantseq[7:6] }; // to start valid first
      else if (dwell_trig_t1)
	antseq <= { antseq[1:0], antseq[7:2] };
      
      // blanking
      
   end
      
   async_debounce rstin
     (
      .clk    (clk ),
      .adin   (arst),
      .dout   (rst ),
      .oneshot(    )
      );
   
endmodule


   reg [15:0] azimuth_ant;
   reg        has_blank;
   reg 	      azi_swap;
   reg 	      azi_g_low;
   reg 	      azi_g_hgh;
   reg 	      azi_l_low;
   reg 	      azi_l_hgh;
   reg 	      blanking;
   



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
            
