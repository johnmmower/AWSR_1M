
module acc_ram #(parameter ABITS=8, parameter DBITS=32, parameter SIM=0)
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

   generate
      if (SIM != 0) begin
	 integer i;
	 initial begin
	    for (i=0; i<(2**ABITS); i=i+1) 
	      mem[i] = 0;
	 end
      end
   endgenerate
   
   always @(posedge clk) begin
      stage <= mem[raddr];
      rdata <= stage;

      if (wen)
	mem[waddr] <= wdata;
   end
      
endmodule

   
module acc_mem #(parameter DEPTH=1024, parameter SIM=0)
   (
    input 	      clk,
    input 	      rst,
    input 	      trig,
    input 	      trig_int,
    input [15:0]      sampsm1,
    input [15:0]      din,
    output [31:0]     dout,
    output 	      vld,
    output reg [15:0] mon_data,
    output reg 	      mon_vld
    );
   
   localparam BITS = $clog2(DEPTH);

   reg init;
   reg wen = 0;  // no reset
   reg vldl = 0; // no reset
   reg vldl_t1, vldl_t2;
   reg rst_cght = 0;
   
   reg trig_t1, trig_t2, trig_t3, trig_t4;
      
   reg [BITS-1:0] waddr;
   reg [BITS-1:0] raddr;
         
   wire [31:0] 	   rdata;

   reg signed [31:0] wdata;
   reg signed [31:0] dinexp;
   reg signed [31:0] addend;

   // for sim monitor
   reg [15:0] 	     din_t1;
   reg [15:0] 	     din_t2;
   //reg [15:0] 	     mon_data;
   //reg 		     mon_vld;
      
   assign dout = rdata;
   assign vld = vldl_t2; 
   
   always @(posedge clk) begin

      din_t1 <= din;
      din_t2 <= din_t1;
      mon_data <= din_t2;
      mon_vld <= wen;
            
      trig_t1 <= trig;
      trig_t2 <= trig_t1;
      trig_t3 <= trig_t2;
      trig_t4 <= trig_t3;
   
      vldl_t1 <= vldl;
      vldl_t2 <= vldl_t1;

      if (rst)
	rst_cght <= 1;
      else if (trig && trig_int)
	rst_cght <= 0;
            
      // sign extend input
      dinexp <= { {16{din[15]}}, din };

      if (trig && trig_int && ~rst_cght)
	vldl <= 1;
      else if ((raddr == (DEPTH-1)) || (raddr == sampsm1))
	vldl <= 0;
            
      // at trig event, read out memory
      if (trig)
	raddr <= 0;
      else
	raddr <= raddr + 'b1;

      // write logic     
      if (trig_t4)
        wen <= 1;
      else if ((waddr == (DEPTH-1)) || (waddr == sampsm1))
	wen <= 0;
            
      // delay write
      if (trig_t4) 
	waddr <= 0;
      else
	waddr <= waddr + 'b1;
            
      // is this first run?
      if (trig)
	if (trig_int)
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

   acc_ram #(.ABITS(BITS), .SIM(SIM))
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

// has bias in round
module acc_mux
  (
   input 	     clk,
   input [31:0]      din,
   input [15:0]      shift,
   input 	     vld_in,
   output reg [15:0] dout,
   output reg 	     vld_out
   );

   reg [15:0] muxa;
   reg [15:0] muxb;
   reg 	      vld_in_t1;
         
   always @(posedge clk) begin

      vld_in_t1 <= vld_in;
      vld_out <= vld_in_t1;
      
      case (shift[7:0])
	8'h01 : muxa <= din[16:1];
	8'h02 : muxa <= din[17:2];
	8'h04 : muxa <= din[18:3];
	8'h08 : muxa <= din[19:4];
	8'h10 : muxa <= din[20:5];
	8'h20 : muxa <= din[21:6];
	8'h40 : muxa <= din[22:7];
	8'h80 : muxa <= din[23:8];
	default : muxa <= din[15:0];
      endcase

      case (shift[15:8])
	8'h01 : muxb <= din[24:9];
	8'h02 : muxb <= din[25:10];
	8'h04 : muxb <= din[26:11];
	8'h08 : muxb <= din[27:12];
	8'h10 : muxb <= din[28:13];
	8'h20 : muxb <= din[29:14];
	8'h40 : muxb <= din[30:15];
	8'h80 : muxb <= din[31:16];
	default : muxb <= 16'hFFFF;
      endcase 
      
      if (|shift[7:0])
	dout <= muxa;
      else
	dout <= muxb;
   end
      
endmodule
   
   
module accumulator #(parameter DEPTH=1024, parameter SIM=0)
  (
   input 	     clk,
   input 	     rst,
   
   input 	     trig,
   input 	     trig_int,

   input [15:0]      shift, // one-hot or zero @trig_int
   input [15:0]      samps, // depth @trig_int
   
   input [15:0]      din_I,
   input [15:0]      din_Q,

   output reg [15:0] dout_I,
   output reg [15:0] dout_Q,
   output reg 	     dout_vld,
   output [15:0]     mon_I, // no accum w/delay
   output [15:0]     mon_Q,
   output 	     mon_vld
 );

   // ensure one-shot trigger
   reg trig_t1;
   reg trig_s;
   reg trig_int_s;

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
   end

   // snag parameter
   reg [15:0] shift_l;
   reg [15:0] samps_m1_l;
   
   always @(posedge clk) 
     if (trig_int) begin
	shift_l <= shift;
	samps_m1_l <= samps - 'b1;
     end

   // accumulate
   wire [31:0] acc_I;
   wire [31:0] acc_Q;
   wire        acc_vld;
      
   acc_mem #(.DEPTH(DEPTH), .SIM(SIM))
   acc_mem_inst_I
     (
      .clk     (clk       ),
      .rst     (rst       ),
      .trig    (trig_s    ),
      .trig_int(trig_int_s),
      .sampsm1 (samps_m1_l),
      .din     (din_I     ),
      .dout    (acc_I     ),
      .vld     (acc_vld   ),
      .mon_data(mon_I     ),
      .mon_vld (mon_vld   )
      );
   
   acc_mem #(.DEPTH(DEPTH), .SIM(SIM))
   acc_mem_inst_Q
     (
      .clk     (clk       ),
      .rst     (rst       ),
      .trig    (trig_s    ),
      .trig_int(trig_int_s),
      .sampsm1 (samps_m1_l),
      .din     (din_Q     ),
      .dout    (acc_Q     ),
      .vld     (          ),
      .mon_data(mon_Q     ),
      .mon_vld (          )
      );

   // shift
   wire [15:0] shft_I;
   wire [15:0] shft_Q;
   wire        shft_vld;

   acc_mux acc_mux_inst_I
     (
      .clk    (clk     ),
      .din    (acc_I   ),
      .shift  (shift_l ),
      .vld_in (acc_vld ),
      .dout   (shft_I  ),
      .vld_out(shft_vld)
      );
   
   acc_mux acc_mux_inst_Q
     (
      .clk    (clk     ),
      .din    (acc_Q   ),
      .shift  (shift_l ),
      .vld_in (acc_vld ),
      .dout   (shft_Q  ),
      .vld_out(        )
      );

   // register outputs
   always @(posedge clk) begin
      dout_I <= shft_I;
      dout_Q <= shft_Q;
      dout_vld <= shft_vld;
   end      
      
endmodule 

