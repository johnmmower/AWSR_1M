
`timescale 1 ns / 1 ps

`define CLKF 215040000
`define RRPM 30
`define RUDT 300
`define CNT 4
`define PRF  250000  // 10x

`define BLOW 300.0
`define BHGH 270.0

`define PI   3.1416

module getAzimuth
  (
   input 	     clk,
   input 	     rst,
   output reg [15:0] azimuth,
   output reg 	     vld
   );

   localparam dt = 1.0/real'(`CLKF);
   
   real 	     angle;
   real 	     tmer = 0;
   
   real 	     udt = dt * real'(`CLKF) / real'(`RUDT);
   real              fdut;
   
   always @(posedge clk) begin
      if (rst)
	angle = 0.0;
      else begin
	 angle = (angle + 2.0*`PI*`RRPM*dt/60.0);
	 if (angle > (2.0*`PI))
	   angle = angle - 2.0*`PI;
      end

      fdut = tmer - udt * $floor(tmer / udt);
                  
      if (rst)
	vld = 0;
      else
	if (fdut < dt)
	  vld = 1;
	else
	  vld = 0;
      	
      tmer = tmer + dt;
      
      azimuth = int'(2.0**16 * angle);
   end
         
endmodule

module tb_trigger;

   reg clk=0;
   reg arst=1;
   
   localparam [31:0] aprfcntm1 = `CLKF/`PRF - 1;
   localparam [15:0] aintcntm1 = `CNT - 1;
   localparam [7:0] aantseq = 8'b_11_01_10_00;

   localparam [15:0] alowazi = `BLOW * 2.0**16 / 360.0;
   localparam [15:0] ahghazi = `BHGH * 2.0**16 / 360.0;
      
   localparam clkstep = 1.0/`CLKF/2.0/1e-9;
   
   initial forever #(clkstep) clk = ~clk;
   
   initial begin
      #100;
      arst = 0;
   end

   wire [15:0] cwazimuth;
   wire        cwvld;
   reg [15:0]  azimuth;
      
   getAzimuth getAzimuth_inst
     (
      .clk(clk),
      .rst(arst),
      .azimuth(cwazimuth),
      .vld(cwvld)
      );

   always @(posedge clk)
     if (arst)
       azimuth <= 0;
     else
       if (cwvld)
	 azimuth <= cwazimuth;

   wire        ltch_var;
   wire        tx_trig;
   wire        rx_trig;
   wire        rx_trig_strt;
   wire        rx_trig_last;
   wire [1:0]  antenna;
   
   trigger uut
     (
      .clk(clk),
      .azimuth(azimuth),
      .arst(arst),
      .aruntx(1'b1),
      .aprfcntm1(aprfcntm1),
      .aintcntm1(aintcntm1),
      .alowazi(alowazi),
      .ahghazi(ahghazi),
      .aantseq(aantseq),
      .ltch_var(ltch_var),
      .antenna(antenna),
      .tx_trig(tx_trig),
      .rx_trig(rx_trig),
      .rx_trig_strt(rx_trig_strt),
      .rx_trig_last(rx_trig_last)
      );
      
endmodule

   
   
     
