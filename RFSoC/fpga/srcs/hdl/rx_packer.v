
`define SYNC 16'hA5A5

module rx_packer #(parameter DEPTH=1024, parameter SIM=0)
  (
   input 	clk,

   input 	run,      // state reset at rising edge
   input 	trig_int, // rx int trig one-shot
   input        trig,     // rx trig one-shot

   input [31:0] sec,      // epoch
   input [31:0] tic,      // free run tic
   input [1:0]  ant,      // current antenna

   // p vals are assumed static at run rising edge
   input [15:0] pcfg,     // data tag
   input [15:0] psamps,   // number of samples, always psamps & 0xFFFC
   input [15:0] pshift,   // number of bits to trim
   input        pnoint,   // no integration (trig_int always == trig)
   
   input [15:0] rx_I,
   input [15:0] rx_Q,

   output reg [127:0] tdata,
   output reg         tvalid,
   output reg         tlast
   );

   wire rst = ~run;

   wire accum_vld;
   wire mon_vld;
   reg 	accum_vld_t1;
   reg 	mon_vld_t1;
   
   wire [15:0] accum_I;
   wire [15:0] accum_Q;
   wire [15:0] mon_I;
   wire [15:0] mon_Q;

   reg [127:0] bufdat;
   reg [3:0]   bufvld;
   reg [3:0]   buflst;
         
   wire [15:0] samps = psamps & 16'hFFFC;

   always @(posedge clk) begin

      accum_vld_t1 <= accum_vld;
      mon_vld_t1 <= mon_vld;

      if (pnoint)
	bufdat <= {bufdat[95:0], mon_Q, mon_I};
      else
	bufdat <= {bufdat[95:0], accum_Q, accum_I};

      if ((pnoint && mon_vld) || (~pnoint && accum_vld))
	if (&bufvld)
	  bufvld <= 4'b0001;
	else
	  bufvld <= {bufvld[2:0], pnoint ? mon_vld : accum_vld};
      else
	bufvld <= 0;
      
      if (pnoint)
	buflst <= {buflst[2:0], ~mon_vld && mon_vld_t1};
      else
	buflst <= {buflst[2:0], ~accum_vld && accum_vld_t1};
            
      if (trig && trig_int)
	tdata <= {`SYNC, pcfg,
                  sec,
                  tic,
                  6'b000000, ant, 8'h0, samps};
      else 
	tdata <= bufdat;

      tvalid <= (trig && trig_int) || &bufvld;
      
      tlast <= |buflst;
      
   end
   
   accumulator #(.DEPTH(DEPTH), .SIM(SIM))
   accumulator_inst
     (
      .clk     (clk      ),
      .rst     (rst      ),
      .trig    (trig     ),
      .trig_int(trig_int ),
      .shift   (pshift   ),
      .samps   (samps    ),
      .din_I   (rx_I     ),
      .din_Q   (rx_Q     ),
      .dout_I  (accum_I  ),
      .dout_Q  (accum_Q  ),
      .dout_vld(accum_vld),
      .mon_I   (mon_I    ),
      .mon_Q   (mon_Q    ),
      .mon_vld (mon_vld  )
      );
      
endmodule
