
`timescale 1 ns / 1 ps

`define CLKF 215040000

`define PI   3.1416

`define SIG  -70.0
`define SNR  -10.0

`define DEPTH 4096
`define SAMPS 2048
`define COUNT 16

module tb_accumulator;

   reg clk = 0;
   reg rst = 0;
   reg trig=0;
   reg trig_int=0;
   reg signed [15:0] dataI;
   reg signed [15:0] dataQ;
   wire signed [15:0] accI;
   wire signed [15:0] accQ;
   wire 	      acc_vld;

   real 	      tm = 0;
   real 	      I, Q;
   int 		      seed = 1;
   int 		      randint;
   real 	      randreal;

   localparam tone = real'(`CLKF) / 64.0;
   localparam dbfs = 20.0 * $log10(2**15);
   localparam mags = 10**((dbfs+`SIG)/20.0);
   localparam magn = mags / 10**(`SNR/20.0);
   localparam dlys = 2.0 * real'(`DEPTH) / real'(`CLKF) / 1e-9;
   localparam [15:0] shift = $clog2(`COUNT);
   localparam [15:0] samps = `SAMPS;
      
   wire signed [15:0] usedI;
   wire signed [15:0] usedQ;
   wire 	      used_vld;

   integer     i;

   integer     fid;
   string      fname;
   
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

   task do_trig(input i);
      wait(clk == 0);
      trig = 1;
      if (i)
	trig_int = 1;
      wait(clk == 1);
      wait(clk == 0);
      trig = 0;
      trig_int = 0;
   endtask      
   
   initial forever #(1.0/`CLKF/2.0/1e-9) clk = ~clk;

   initial begin
      trig = 0;
      trig_int = 0;
      #100;
      do_reset;
      #100;

      for (i=0; i<`COUNT; i=i+1) begin
	 
	 $sformat(fname, "raw_%02d.dat", i);
	 fid = $fopen(fname, "w");
	 
	 if (i==0)
	   do_trig(1);
	 else
	   do_trig(0);
	 #(dlys);

	 $fclose(fid);
	 
      end

      fid = $fopen("int.dat", "w");
	 
      do_trig(1);
      #(dlys);

      $fclose(fid);
            
      $finish;

   end 

   always @(posedge clk)
     if (i < `COUNT) begin
	if (used_vld)
	  $fwrite(fid, "%d, %d\n", usedI, usedQ);
     end
     else if (i == `COUNT) begin
	if (acc_vld)
	  $fwrite(fid, "%d, %d\n", accI, accQ);
     end

   accumulator #(.DEPTH(`DEPTH), .SIM(1)) uut
     (
      .clk(clk),
      .rst(rst),
      .trig(trig),
      .trig_int(trig_int),
      .shift(shift),
      .samps(samps),
      .din_I(dataI),
      .din_Q(dataQ),
      .dout_I(accI),
      .dout_Q(accQ),
      .dout_vld(acc_vld),
      .mon_I(usedI),
      .mon_Q(usedQ),
      .mon_vld(used_vld)
      );

endmodule

   
