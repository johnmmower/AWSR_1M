
`timescale 1 ns / 1 ps

`define CLKF 215040000

`define PI   3.1416

`define SIG  -70.0
`define SNR  -10.0

`define DEPTH 64
`define SAMPS 16
`define COUNT 1
`define DELAY 16

module tb_rx_packer;

   reg clk = 0;
   reg rst = 0;
   reg trig=0;
   reg trig_strt=0;
   reg trig_last=0;
   reg signed [15:0] dataI;
   reg signed [15:0] dataQ;

   real 	      tm = 0;
   real 	      I, Q;
   int 		      seed = 1;
   int 		      randint;
   real 	      randreal;

   reg run = 0;
   reg [31:0] tic = 0;
   reg [1:0]  ant = 2'b11;
   
   wire [127:0] tdata;
   wire 	tvalid;
   wire 	tlast;
   reg 		tready = 1;
   wire 	buf_error;
   wire 	trg_error;
      
   localparam tone = real'(`CLKF) / 64.0;
   localparam dbfs = 20.0 * $log10(2**15);
   localparam mags = 10**((dbfs+`SIG)/20.0);
   localparam magn = mags / 10**(`SNR/20.0);
   localparam dlys = 2.0 * real'(`DEPTH) / real'(`CLKF) / 1e-9;
   localparam [15:0] shift = $clog2(`COUNT);
   localparam [15:0] samps = `SAMPS;
   localparam [15:0] sampsm1 = `SAMPS - 1;
   localparam [31:0] delaym1 = `DELAY - 1;
      
   integer     i;

   always @(posedge clk)
     tic <= tic + 1;
      
   always @(posedge clk)
      if (trig)
	tm <= 0;
      else
	tm <= tm + 1.0/`CLKF;
   
   always @(negedge clk) begin
   
      randint = $dist_normal(seed, 0, 100 * magn);
      randreal = real'(randint) / 100.0;
      
      I = mags * $cos(2*`PI*tone*tm) + randreal;

      randint = $dist_normal(seed, 0, 100 * magn);
      randreal = real'(randint) / 100.0;
      
      Q = mags * $sin(2*`PI*tone*tm) + randreal;

      dataI = $rtoi(I);
      dataQ = $rtoi(Q);
   end
   
   task do_reset;
      wait(clk == 0);
      rst = 1;
      wait(clk == 1);
      wait(clk == 0);
      rst = 0;
   endtask

   task do_trig(input [1:0] i);
      wait(clk == 0);
      trig = 1;
      if (i[0])
	trig_strt = 1;
      if (i[1])
	trig_last = 1;
      wait(clk == 1);
      wait(clk == 0);
      trig = 0;
      trig_strt = 0;
      trig_last = 0;
   endtask      
   
   initial forever #(1.0/`CLKF/2.0/1e-9) clk = ~clk;

   initial begin
      #100;
      do_reset;
      #100;
      run = 1;
      #100;
      
      for (i=0; i<`COUNT; i=i+1) begin
	 
	 if (i==0)
	   if (`COUNT <= 1)
	     do_trig(2'b11);
	   else
	     do_trig(2'b01);
	 else if (i==(`COUNT-1))
	   do_trig(2'b10);
	 else
	   do_trig(2'b00);
	 
	 #(dlys);

      end

      $finish;

   end 

   rx_packer #(.DEPTH(`DEPTH), .SIM(1)) uut
     (
      .clk(clk),
      .run(run),
      .trig_strt(trig_strt),
      .trig_last(trig_last),
      .trig(trig),
      .sec(32'hDEADBEEF),
      .tic(tic),
      .ant(ant),
      .pcfg(16'hBABE),
      .psampsm1(sampsm1),
      .pshift(shift),
      .psamps(samps),
      .pdelaym1(delaym1),
      .rx_I(dataI),
      .rx_Q(dataQ),
      .tdata(tdata),
      .tready(tready),
      .tvalid(tvalid),
      .tlast(tlast),
      .buf_error(buf_error),
      .trg_error(trg_error)
      );
         
endmodule

   
