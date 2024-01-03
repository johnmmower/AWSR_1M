
`include "system.vh"

module proc #(parameter SIM = 0)
  (
   input 		  arst,
   
   input 		  aruntx, // run transmitter
   input 		  ausepa, // tx with PA enabled
   input 		  arunrx_ch0, // use rx ch0
   input 		  arunrx_ch1, // use rx ch1
   input [31:0] 	  atxdelaym1, // delay to tx addr start - 1
   input [31:0] 	  atxonm1, // delay to paen stop - 1
   input [31:0] 	  aprfcntm1, // prf dwell counter - 1
   input [15:0] 	  aintcntm1, // integration counter - 1
   input [15:0] 	  alowazi, // blanking start \__ note swap for blank over zero 
   input [15:0] 	  ahghazi, // blanking stop  /   equality means no blank
   input [7:0] 		  aantseq, // antenna switch sequence
   input [15:0] 	  acfg, // data tag, channels tagged internally by ID
   input [15:0] 	  asamps_ch0, // number of samples, always psamps & 0xFFFC 
   input [15:0] 	  asampsm1_ch0, // number of samples, always psamps & 0xFFFC - 1
   input [15:0] 	  ashift_ch0, // number of bits to trim
   input [31:0] 	  adelaym1_ch0, // tics to delay to trig -1
   input [15:0] 	  asamps_ch1, // number of samples, always psamps & 0xFFFC 
   input [15:0] 	  asampsm1_ch1, // number of samples, always psamps & 0xFFFC - 1
   input [15:0] 	  ashift_ch1, // number of bits to trim
   input [31:0] 	  adelaym1_ch1, // tics to delay to trig -1

   input 		  clk,
   output 		  rst,
   
   input [31:0] 	  sec, // current epoch
   input [31:0] 	  tic, // current tic
   input [15:0] 	  azimuth, // current antenna position

   output [1:0] 	  antenna, // set current antenna, jumps before rx start

   output [`DAC_BITS-1:0] dac_addr, // DAC RAM address
   output 		  paen, // turns on at trigger

   input [15:0] 	  rx_I_ch0,
   input [15:0] 	  rx_Q_ch0,
   output [127:0] 	  tdata_ch0,
   input 		  tready_ch0,
   output 		  tvalid_ch0,
   output 		  tlast_ch0,
   output 		  buf_error_ch0,
   output 		  trg_error_ch0,

   input [15:0] 	  rx_I_ch1,
   input [15:0] 	  rx_Q_ch1,
   output [127:0] 	  tdata_ch1,
   input 		  tready_ch1,
   output 		  tvalid_ch1,
   output 		  tlast_ch1,
   output 		  buf_error_ch1,
   output 		  trg_error_ch1
   );

   wire ltch_var;
   wire tx_trig;
   wire rx_trig;
   wire rx_trig_strt;
   wire rx_trig_last;

   wire run;
   reg 	run_t1;
   reg 	runall;
     
   reg 	usepa;
   reg 	runrx_ch0;
   reg 	runrx_ch1;
   reg 	runtx;
   reg [31:0] prfcntm1;
   reg [15:0] intcntm1;
   reg [15:0] lowazi;
   reg [15:0] hghazi;
   reg [7:0]  antseq;
   reg [31:0] txdelaym1;
   reg [31:0] txonm1;
   reg [15:0] cfg;   
   reg [15:0] samps_ch0;
   reg [15:0] sampsm1_ch0;
   reg [15:0] shift_ch0;  
   reg [31:0] delaym1_ch0;
   reg [15:0] samps_ch1;  
   reg [15:0] sampsm1_ch1;
   reg [15:0] shift_ch1;  
   reg [31:0] delaym1_ch1;

   assign rst = ~runall;
   
   always @(posedge clk) begin
      run_t1 <= run;
      runall <= run_t1;
   end
   
   always @(posedge clk)
     if (run && !run_t1) begin
	usepa       <= ausepa;
	runrx_ch0   <= arunrx_ch0;
	runrx_ch1   <= arunrx_ch1;
	runtx       <= aruntx;
	prfcntm1    <= aprfcntm1;
	intcntm1    <= aintcntm1;
	lowazi      <= alowazi;
	hghazi      <= ahghazi;
	antseq      <= aantseq;
	txdelaym1   <= atxdelaym1;
	txonm1      <= atxonm1;
	cfg         <= acfg;
	samps_ch0   <= asamps_ch0;
	sampsm1_ch0 <= asampsm1_ch0;
	shift_ch0   <= ashift_ch0;
	delaym1_ch0 <= adelaym1_ch0;
	samps_ch1   <= asamps_ch1;
	sampsm1_ch1 <= asampsm1_ch1;
	shift_ch1   <= ashift_ch1;
	delaym1_ch1 <= adelaym1_ch1;
     end	
   
   async_debounce async_run_inst
     (
      .clk    (clk  ),
      .adin   (~arst),
      .dout   (run  ),
      .oneshot()
      );   

   rx_packer
     #(.DEPTH(`CH0_SIZE), .SIM(SIM))
   rx_packer_ch0_inst
     (
      .clk      (clk                ),
      .run      (runall && runrx_ch0),
      .trig     (rx_trig            ),
      .trig_strt(rx_trig_strt       ),
      .trig_last(rx_trig_last       ),
      .sec      (sec                ),
      .tic      (tic                ),
      .ant      (antenna            ),
      .cfg      (cfg                ),
      .samps    (samps_ch0          ),
      .sampsm1  (sampsm1_ch0        ),
      .shift    (shift_ch0          ),
      .delaym1  (delaym1_ch0        ),
      .rx_I     (rx_I_ch0           ),
      .rx_Q     (rx_Q_ch0           ),
      .tdata    (tdata_ch0          ),
      .tready   (tready_ch0         ),
      .tvalid   (tvalid_ch0         ),
      .tlast    (tlast_ch0          ),
      .buf_error(buf_error_ch0      ),
      .trg_error(trg_error_ch0      )
      );
   
   rx_packer
     #(.DEPTH(`CH1_SIZE), .ID(1), .SIM(SIM))
   rx_packer_ch1_inst
     (
      .clk      (clk                ),
      .run      (runall && runrx_ch1),
      .trig     (rx_trig            ),
      .trig_strt(rx_trig_strt       ),
      .trig_last(rx_trig_last       ),
      .sec      (sec                ),
      .tic      (tic                ),
      .ant      (antenna            ),
      .cfg      (cfg                ),
      .samps    (samps_ch1          ),
      .sampsm1  (sampsm1_ch1        ),
      .shift    (shift_ch1          ),
      .delaym1  (delam1_ch1         ),
      .rx_I     (rx_I_ch1           ),
      .rx_Q     (rx_Q_ch1           ),
      .tdata    (tdata_ch1          ),
      .tready   (tready_ch1         ),
      .tvalid   (tvalid_ch1         ),
      .tlast    (tlast_ch1          ),
      .buf_error(buf_error_ch1      ),
      .trg_error(trg_error_ch1      )
      );
   
   tx_main #(.ADDRBITS(`DAC_BITS)) tx_main_inst
     (
      .clk     (clk              ),
      .rst     (~runall || ~runtx),
      .trig    (tx_trig          ),
      .addr    (dac_addr         ),
      .paen    (paen             ),
      .usepa   (usepa            ),
      .delaym1 (txdelaym1        ),
      .onm1    (txonm1           )
      );
   
   trigger trigger_inst
     (
      .clk         (clk         ),
      .rst         (~runall     ),
      .azimuth     (azimuth     ),
      .prfcntm1    (prfcntm1    ),
      .intcntm1    (intcntm1    ),
      .lowazi      (lowazi      ),
      .hghazi      (hghazi      ),
      .antseq      (antseq      ),
      .antenna     (antenna     ),
      .tx_trig     (tx_trig     ),
      .rx_trig     (rx_trig     ),
      .rx_trig_strt(rx_trig_strt),
      .rx_trig_last(rx_trig_last)
      );

endmodule
   
