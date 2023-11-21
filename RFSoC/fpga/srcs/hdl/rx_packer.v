
`define SYNC 16'hA5A5

module rx_packer #(parameter DEPTH=1024, parameter SIM=0)
  (
   input 	      clk,

   input 	      run,       // state reset at rising edge
   input              trig,      // rx trig       ---\
   input 	      trig_strt, // rx start trig ------ one-shot
   input              trig_last, // rx last trig  ---/

   input [31:0]       sec,       // epoch
   input [31:0]       tic,       // free run tic
   input [1:0]        ant,       // current antenna set before trig is relayed

   // p vals are assumed static for triggering period
   input [15:0]       pcfg,      // data tag
   input [15:0]       psamps,    //
   input [15:0]       psampsm1,  // number of samples, always psamps & 0xFFFC - 1
   input [15:0]       pshift,    // number of bits to trim
   input [31:0]       pdelaym1,  // tics to delay to trig -1
   
   input [15:0]       rx_I,
   input [15:0]       rx_Q,

   output reg [127:0] tdata,
   input              tready,
   output reg         tvalid,
   output reg         tlast,
   
   output reg         buf_error,
   output reg         trg_error
   );

   wire rst = ~run;

   wire accum_vld;
   wire accum_lst;
   wire [15:0] accum_I;
   wire [15:0] accum_Q;
   
   reg 	       buflst;
   reg [127:0] bufdat;
   reg [3:0]   bufvld;

   reg 	       running;

   reg 	       trig_cght;
   reg 	       trig_strt_cght;
   reg 	       trig_last_cght;
   reg [31:0]  trig_cntr;
   reg 	       itrig;
   reg 	       itrig_strt;
   reg 	       itrig_last;
   
   always @(posedge clk) begin

      bufdat <= {bufdat[95:0], accum_Q, accum_I};

      if (accum_vld)
	if (&bufvld)
	  bufvld <= 4'b0001;
	else
	  bufvld <= {bufvld[2:0], 1'b1};
      else
	bufvld <= 0;

      buflst <= accum_lst;
   
   end         
      
   always @(posedge clk) begin
      
      if (itrig && itrig_strt)
	tdata <= {`SYNC, pcfg,
                  sec,
                  tic,
                  6'b000000, ant, 8'h0, psamps};
      else 
	tdata <= bufdat;

      tvalid <= (itrig && itrig_strt) || &bufvld;
      
      tlast <= buflst;

      end

   always @(posedge clk) begin
	    
      if (rst)
	running <= 0;
      else
	if (trig)
	  running <= 1;
	else if (tlast)
	  running <= 0;
      
      if (trig)
	trig_cntr <= 0;
      else
	trig_cntr <= trig_cntr + 'b1;
      
      if (trig) begin
	 trig_cght <= 1;
	 trig_strt_cght <= trig_strt;
	 trig_last_cght <= trig_last;
      end
      else if (trig_cntr == pdelaym1) begin
	 trig_cght <= 0;
	 trig_strt_cght <= 0;
	 trig_last_cght <= 0;
      end

      if (running && trig_cght && trig_cntr == pdelaym1) begin
	 itrig <= 1;
	 itrig_strt <= trig_strt_cght;
	 itrig_last <= trig_last_cght;
      end
      else begin
	 itrig <= 0;
	 itrig_strt <= 0;
	 itrig_last <= 0;
      end	
      
      if (rst)
	buf_error <= 0;
      else
	if (tvalid && ~tready)
	  buf_error <= 1;

      if (rst)
	trg_error <= 0;
      else
	if (trig && running)
	  trg_error <= 1;
            
   end
      
   accumulator #(.DEPTH(DEPTH), .SIM(SIM))
   accumulator_inst
     (
      .clk      (clk         ),
      .rst      (rst         ),
      .trig     (itrig       ),
      .trig_strt(itrig_strt  ),
      .trig_last(itrig_last  ),
      .shift    (pshift      ),
      .sampsm1  (psampsm1    ),
      .din_I    (rx_I        ),
      .din_Q    (rx_Q        ),
      .dout_I   (accum_I     ),
      .dout_Q   (accum_Q     ),
      .dout_vld (accum_vld   ),
      .dout_lst (accum_lst   )
      );
      
endmodule 

