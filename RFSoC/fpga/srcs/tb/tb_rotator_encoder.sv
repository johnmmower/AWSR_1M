
`timescale 1 ns / 1 ps

`define	CLKF 215040000
`define	BAUD 115200
`define PAUSE 1e-6
`define AZIMUTH1 16'h0123
`define AZIMUTH2 16'h5678
`define AZIMUTH3 16'habcd

module tb_rotator_encoder;

   reg clk = 0;
   reg rst = 0;
   reg rx = 1;

   wire [15:0] azimuth;
      
   task do_reset;
      wait(clk == 1);
      rst = 1;
      wait(clk == 0);
      wait(clk == 1);
      rst = 0;
   endtask
   
   task rx_word(input [7:0] rxbyte);
      rx = 0;
      #(1.0/`BAUD/1e-9);
      for (int i=0; i<8; i++) begin
	 rx = rxbyte[i];
	 #(1.0/`BAUD/1e-9);
      end
      rx = 1;
      #(1.0/`BAUD/1e-9);
      #(`PAUSE/1e-9);
   endtask

   task do_rx(input [15:0] az);
      reg [7:0] mem [0:6];
      // RPM PSI position encoding & cksum
      mem[0] = 8'h80;
      mem[1] = {4'b0, az[1:0], 2'b0};
      mem[2] = {1'b0, az[15:9]};
      mem[3] = {1'b0, az[8:2]};
      mem[4] = 8'h00;
      mem[5] = 8'h00;
      mem[6] = 8'h00;
      for (int i=0; i<6; i++) begin:cksum
	 mem[6] = mem[6] + mem[i];
      end
      mem[6] = mem[6] & 8'h7F;
      for (int i=0; i<7; i++) begin:rxing
	 rx_word(mem[i]);
      end      
   endtask
      
   initial forever #(1.0/`CLKF/2.0/1e-9) clk = ~clk;

   initial begin
      #100;
      do_reset;
      #100;
      do_rx(`AZIMUTH1);
      do_rx(`AZIMUTH2);
      do_rx(`AZIMUTH3);
      #100;
      $finish();
   end

   rotator_encoder #(.CLKF(`CLKF))
   re_inst
     (
      .clk        (clk        ),
      .srst       (rst        ),
      .rx         (rx         ),
      .azimuth    (azimuth    )
      );
   
endmodule
   
