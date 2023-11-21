
module acc_ram #(parameter ABITS=8, parameter DBITS=32, parameter SIM=0)
   (
    input 		   clk,
    input [ABITS-1:0] 	   waddr,
    input 		   wen,
    input [ABITS-1:0] 	   raddr,
    input [DBITS-1:0] 	   wdata,
    output reg [DBITS-1:0] rdata
    );
   
   reg [DBITS-1:0] 	   mem [(2**ABITS)-1:0];
   reg [DBITS-1:0] 	   stage;

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

// has bias in "round"
module acc_mux
  (
   input 	     clk,
   input [31:0]      din,
   input [15:0]      shift,
   input 	     vld_in,
   input 	     lst_in,
   output reg [15:0] dout,
   output reg 	     vld_out,
   output reg 	     lst_out
   );

   reg [15:0] 	     muxa;
   reg [15:0] 	     muxb;
   reg 		     vld_in_t1;
   reg 		     lst_in_t1;
   
   always @(posedge clk) begin

      vld_in_t1 <= vld_in;
      vld_out <= vld_in_t1;
      
      lst_in_t1 <= lst_in;
      lst_out <= lst_in_t1;
      
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
	default : muxb <= din[15:0];
      endcase 
      
      if (|shift[7:0])
	dout <= muxa;
      else
	dout <= muxb;
   end
   
endmodule


module acc_mem #(parameter DEPTH=1024, parameter SIM=0)
   (
    input 	      clk,
    input 	      rst,
   
    input 	      trig,
    input 	      trig_strt,
    input 	      trig_last,
    
    input [15:0]      sampsm1,
   
    input [15:0]      din,
    output reg [31:0] dout,
    output reg 	      vld,
    output reg 	      lst
    );

   localparam BITS = $clog2(DEPTH);

   reg trig_t1, trig_t2, trig_t3, trig_t4;
   reg wen;
   reg init;
   reg endr;
   
   reg [BITS-1:0] waddr;
   reg [BITS-1:0] raddr;
   
   wire signed [31:0] rdata;
   reg signed [31:0]  wdata;
   reg signed [31:0]  dinexp;
   reg signed [31:0]  addend;
   
   always @(posedge clk) begin

      trig_t1 <= trig;
      trig_t2 <= trig_t1;
      trig_t3 <= trig_t2;
      trig_t4 <= trig_t3;
      
      dinexp <= { {16{din[15]}}, din };

      if (trig)
	raddr <= 0;
      else
	raddr <= raddr + 'b1;

      if (trig_t4)
	waddr <= 0;
      else
	waddr <= waddr + 'b1;

      if (rst)
	wen <= 0;
      else
	if (trig_t4)
	  wen <= 1;
	else if ((waddr == (DEPTH-1)) || (waddr == sampsm1))
	  wen <= 0;
            
      if (trig)
	init <= trig_strt;

      if (trig)
	endr <= trig_last;
      
      if (init)
	addend <= 0;
      else
	addend <= rdata;
   
      if (init)
	addend <= 0;
      else
	addend <= rdata;
   
      wdata <= dinexp + addend;

      dout <= wdata;

      if (endr)
	vld <= wen;
      else
	vld <= 0;

      if ((waddr == (DEPTH-1)) || (waddr == sampsm1))      
	lst <= wen;
      else
	lst <= 0;
      
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
   

module accumulator #(parameter DEPTH=1024, parameter SIM=0)
   (
    input 	      clk,
    input 	      rst,
   
    input 	      trig,      // ---\
    input 	      trig_strt, // ------ one-shot
    input 	      trig_last, // ---/

    input [15:0]      shift,     // latched at trig
    input [15:0]      sampsm1,   // latched at trig
   
    input [15:0]      din_I,
    input [15:0]      din_Q,

    output reg [15:0] dout_I,
    output reg [15:0] dout_Q,
    output reg 	      dout_vld,
    output reg 	      dout_lst
    );


   // accumulate
   wire [31:0] acc_I;
   wire [31:0] acc_Q;
   wire        acc_vld;
   wire        acc_lst;
   
   acc_mem #(.DEPTH(DEPTH), .SIM(SIM))
   acc_mem_inst_I
     (
      .clk      (clk      ),
      .rst      (rst      ),
      .trig     (trig     ),
      .trig_strt(trig_strt),
      .trig_last(trig_last),
      .sampsm1  (sampsm1  ),
      .din      (din_I    ),
      .dout     (acc_I    ),
      .vld      (acc_vld  ),
      .lst      (acc_lst  )
      );
   
   acc_mem #(.DEPTH(DEPTH), .SIM(SIM))
   acc_mem_inst_Q
     (
      .clk      (clk      ),
      .rst      (rst      ),
      .trig     (trig     ),
      .trig_strt(trig_strt),
      .trig_last(trig_last),
      .sampsm1  (sampsm1  ),
      .din      (din_Q    ),
      .dout     (acc_Q    ),
      .vld      (         ),
      .lst      (         )
      );

   // shift
   wire [15:0] shft_I;
   wire [15:0] shft_Q;
   wire        shft_vld;
   wire        shft_lst;
   
   acc_mux acc_mux_inst_I
     (
      .clk    (clk     ),
      .din    (acc_I   ),
      .shift  (shift   ),
      .vld_in (acc_vld ),
      .lst_in (acc_lst ),
      .dout   (shft_I  ),
      .vld_out(shft_vld),
      .lst_out(shft_lst)
      );
   
   acc_mux acc_mux_inst_Q
     (
      .clk    (clk     ),
      .din    (acc_Q   ),
      .shift  (shift   ),
      .vld_in (acc_vld ),
      .lst_in (acc_lst ),
      .dout   (shft_Q  ),
      .vld_out(        ),
      .lst_out(        )
      );

   always @(posedge clk) begin
      dout_I <= shft_I;
      dout_Q <= shft_Q;
      dout_vld <= shft_vld;
      dout_lst <= shft_lst;
   end
   
endmodule

