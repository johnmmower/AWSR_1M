
`include "system.vh"

module proc
  (
   input 	  arst,
   
   input 	  aruntx,        // run transmitter
   input 	  ausepa,        // tx with PA enabled
   input 	  arunrx_ch0,    // use rx ch0
   input 	  arunrx_ch1,    // use rx ch1
   input [31:0]   atxdelaym1,    // delay to tx addr start - 1
   input [31:0]   atxonm1,       // delay to paen stop - 1
   input [31:0]   aprfcntm1,     // prf dwell counter - 1
   input [15:0]   aintcntm1,     // integration counter - 1
   input [15:0]   alowazi,       // blanking start \__ note swap for blank over zero 
   input [15:0]   ahghazi,       // blanking stop  /   equality means no blank
   input [7:0] 	  aantseq,       // antenna switch sequence
   input [15:0]   acfg,          // data tag, channels tagged internally by ID
   input [15:0]   asamps_ch0,    // number of samples, always psamps & 0xFFFC 
   input [15:0]   asampsm1_ch0,  // number of samples, always psamps & 0xFFFC - 1
   input [15:0]   ashift_ch0,    // number of bits to trim
   input [31:0]   adelaym1_ch0,  // tics to delay to trig -1
   input [15:0]   asamps_ch1,    // number of samples, always psamps & 0xFFFC 
   input [15:0]   asampsm1_ch1,  // number of samples, always psamps & 0xFFFC - 1
   input [15:0]   ashift_ch1,    // number of bits to trim
   input [31:0]   adelaym1_ch1,  // tics to delay to trig -1

   input 	  clk,
   output 	  rst,
   
   input [31:0]   sec,           // current epoch
   input [31:0]   tic,           // current tic
   input [15:0]   azimuth,       // current antenna position

   output [1:0]   antenna,       // set current antenna, jumps before rx start

   output [12:0]  dac_addr,      // DAC RAM address
   output 	  paen,          // turns on at trigger

   input [15:0]   rx_I_ch0,
   input [15:0]   rx_Q_ch0,
   output [127:0] tdata_ch0,
   input 	  tready_ch0,
   output 	  tvalid_ch0,
   output 	  tlast_ch0,
   output 	  buf_error_ch0,
   output 	  trg_error_ch0,

   input [15:0]   rx_I_ch1,
   input [15:0]   rx_Q_ch1,
   output [127:0] tdata_ch1,
   input 	  tready_ch1,
   output 	  tvalid_ch1,
   output 	  tlast_ch1,
   output 	  buf_error_ch1,
   output 	  trg_error_ch1
   );

   (* MARK_DEBUG = "TRUE" *)
   wire ltch_var;
   (* MARK_DEBUG = "TRUE" *)
   wire rst;
   (* MARK_DEBUG = "TRUE" *)
   wire tx_trig;
   (* MARK_DEBUG = "TRUE" *)
   wire rx_trig;
   (* MARK_DEBUG = "TRUE" *)
   wire rx_trig_strt;
   (* MARK_DEBUG = "TRUE" *)
   wire rx_trig_last;
   
   (* MARK_DEBUG = "TRUE" *)
   reg 	usepa;
   (* MARK_DEBUG = "TRUE" *)
   reg 	runrx_ch0;
   (* MARK_DEBUG = "TRUE" *)
   reg 	runrx_ch1;
   (* MARK_DEBUG = "TRUE" *)
   reg [31:0] txdelaym1;
   (* MARK_DEBUG = "TRUE" *)
   reg [31:0] txonm1;
   (* MARK_DEBUG = "TRUE" *)
   reg [15:0] cfg;   
   (* MARK_DEBUG = "TRUE" *)
   reg [15:0] samps_ch0;
   (* MARK_DEBUG = "TRUE" *)
   reg [15:0] sampsm1_ch0;
   (* MARK_DEBUG = "TRUE" *)
   reg [15:0] shift_ch0;  
   (* MARK_DEBUG = "TRUE" *)
   reg [31:0] delaym1_ch0;
   (* MARK_DEBUG = "TRUE" *)
   reg [15:0] samps_ch1;  
   (* MARK_DEBUG = "TRUE" *)
   reg [15:0] sampsm1_ch1;
   (* MARK_DEBUG = "TRUE" *)
   reg [15:0] shift_ch1;  
   (* MARK_DEBUG = "TRUE" *)
   reg [31:0] delaym1_ch1;

   // "trigger" grabs it's own vars, sends this signal
   // to grab other modules parameters for run
   always @(posedge clk)
     if (ltch_var) begin
	usepa       <= ausepa;
	runrx_ch0   <= arunrx_ch0;
	runrx_ch1   <= arunrx_ch1;
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
   
   rx_packer
     #(.DEPTH(`CH0_SIZE))
   rx_packer_ch0_inst
     (
      .clk      (clk              ),
      .run      (~rst && runrx_ch0),
      .trig     (rx_trig          ),
      .trig_strt(rx_trig_strt     ),
      .trig_last(rx_trig_last     ),
      .sec      (sec              ),
      .tic      (tic              ),
      .ant      (antenna          ),
      .pcfg     (cfg              ),
      .psamps   (samps_ch0        ),
      .psampsm1 (sampsm1_ch0      ),
      .pshift   (shift_ch0        ),
      .pdelaym1 (delam1_ch0       ),
      .rx_I     (rx_I_ch0         ),
      .rx_Q     (rx_Q_ch0         ),
      .tdata    (tdata_ch0        ),
      .tready   (tready_ch0       ),
      .tvalid   (tvalid_ch0       ),
      .tlast    (tlast_ch0        ),
      .buf_error(buf_error_ch0    ),
      .trg_error(trg_error_ch0    )
      );
   
   rx_packer
     #(.DEPTH(`CH1_SIZE), .ID(1))
   rx_packer_ch1_inst
     (
      .clk      (clk              ),
      .run      (~rst && runrx_ch1),
      .trig     (rx_trig          ),
      .trig_strt(rx_trig_strt     ),
      .trig_last(rx_trig_last     ),
      .sec      (sec              ),
      .tic      (tic              ),
      .ant      (antenna          ),
      .pcfg     (cfg              ),
      .psamps   (samps_ch1        ),
      .psampsm1 (sampsm1_ch1      ),
      .pshift   (shift_ch1        ),
      .pdelaym1 (delam1_ch1       ),
      .rx_I     (rx_I_ch1         ),
      .rx_Q     (rx_Q_ch1         ),
      .tdata    (tdata_ch1        ),
      .tready   (tready_ch1       ),
      .tvalid   (tvalid_ch1       ),
      .tlast    (tlast_ch1        ),
      .buf_error(buf_error_ch1    ),
      .trg_error(trg_error_ch1    )
      );
   
   tx_main tx_main_inst
     (
      .clk     (clk      ),
      .rst     (rst      ),
      .trig    (tx_trig  ),
      .addr    (dac_addr ),
      .paen    (paen     ),
      .pusepa  (usepa    ),
      .pdelaym1(txdelaym1),
      .ponm1   (txonm1   )
      );
   
   trigger trigger_inst
     (
      .clk         (clk         ),
      .rst         (rst         ),
      .azimuth     (azimuth     ),
      .aruntx      (aruntx      ),
      .aprfcntm1   (aprfcntm1   ),
      .aintcntm1   (aintcntm1   ),
      .alowazi     (alowazi     ),
      .ahghazi     (ahghazi     ),
      .aantseq     (aantseq     ),
      .ltch_var    (ltch_var    ),
      .antenna     (antenna     ),
      .tx_trig     (tx_trig     ),
      .rx_trig     (rx_trig     ),
      .rx_trig_strt(rx_trig_strt),
      .rx_trig_last(rx_trig_last)
      );

   async_debounce async_rst_inst
     (
      .clk    (clk ),
      .adin   (arst),
      .dout   (rst ),
      .oneshot()
      );   

endmodule
   
