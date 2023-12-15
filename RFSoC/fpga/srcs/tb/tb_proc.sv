
`timescale 1 ns / 1 ps

`define CLKF 215040000

module tb_proc;

   reg clk;

   reg arst;

   reg [31:0] tic;

   wire [1:0] antenna;
   wire [12:0] dac_addr;
   wire        paen;

   input [15:0] rx_I_ch0;
   input [15:0] rx_Q_ch0;
   wire [127:0] tdata_ch0;
   wire 	tvalid_ch0;
   wire 	tlast_ch0;

   initial forever #(1.0/`CLKF/2.0/1e-9) clk = ~clk;

   initial begin
      tic = 0;
      arst = 1;

      #100;
      arst = 0;
      
   end

   always @(posedge clk)
     tic <= tic + 'b1;
   
   proc uut
     (
      .arst(arst),
      .aruntx(1'b1),
      .ausepa(1'b1),
      .arunrx_ch0(1'b1),
      .arunrx_ch1(1'b0),
      .atxdelaym1(32'd128),
      .atxonm1(32'd512),
      .aprfcntm1(32'd4096),
      .aintcntm1(16'd4),
      .alowazi(16'd0),
      .ahghazi(16'd0),
      .aantseq(8'b11100100),
      .acfg(16'hbabe),
      .asamps_ch0(16'd32),
      .asampsm1_ch0(16'd31),
      .ashift_ch0(16'd0),
      .adelaym1_ch0(32'd0),
      .asamps_ch1(16'd0),
      .asampsm1_ch1(16'd0),
      .ashift_ch1(16'd0),
      .adelaym1_ch1(32'd0),
      .clk(clk),
      .rst(),
      .sec(32'hDEADBEEF),
      .tic(tic),
      .azimuth(16'd0),
      .antenna(antenna),
      .dac_addr(dac_addr),
      .paen(paen),
      .rx_I_ch0(rx_I_ch0),
      .rx_Q_ch0(rx_Q_ch0),
      .tdata_ch0(tdata_ch0),
      .tready_ch0(1'b1),
      .tvalid_ch0(tvalid_ch0),
      .tlast_ch0(tlast_ch0),
      .buf_error_ch0(),
      .trg_error_ch0(),
      .rx_I_ch1(rx_I_ch1),
      .rx_Q_ch1(rx_Q_ch1),
      .tdata_ch1(tdata_ch1),
      .tready_ch1(1'b1),
      .tvalid_ch1(tvalid_ch1),
      .tlast_ch1(tlast_ch1),
      .buf_error_ch1(),
      .trg_error_ch1()
      );
   
endmodule

   
