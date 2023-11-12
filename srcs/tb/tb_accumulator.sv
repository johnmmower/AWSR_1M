
`timescale 1 ns / 1 ps

`define CLKF 215040000

module tb_accumulator;

   reg clk = 0;
   reg rst = 0;
   reg trig;
   reg trig_int;
   reg signed [15:0] data = -1024;

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
      do_trig(1);
      #100;
      do_trig(0);
   end

   always @(negedge clk)
     data <= data + 'b1;
      
   acc_mem_accumulator #(.DEPTH(10)) uut
     (
      .clk(clk),
      .trig(trig),
      .trig_int(trig_int),
      .din(data)


      );
         
endmodule

   
