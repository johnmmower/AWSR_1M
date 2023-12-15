
`timescale 1 ns / 1 ps

`define CLKF 215040000

module tb_tx_main;

   reg clk = 0;
   reg rst = 1;
   reg trig = 0;

   wire [12:0] addr;
   wire        paen;

   reg 	       pusepa = 1;
   reg [31:0]  pdelaym1 = 107;
   reg [31:0]  ponm1    = 344;
   
   initial forever #(1.0/`CLKF/2.0/1e-9) clk = ~clk;

   initial begin
      #(100.0/`CLKF/1e-9);
      rst = 0;
      #(100.0/`CLKF/1e-9);
      trig = 1;
      #(1.0/`CLKF/1e-9);
      trig = 0;
   end
   
   tx_main uut
     (
      .clk(clk),
      .rst(rst),
      .trig(trig),
      .addr(addr),
      .paen(paen),
      .pusepa(pusepa),
      .pdelaym1(pdelaym1),
      .ponm1(ponm1)
      );
   
endmodule

   
