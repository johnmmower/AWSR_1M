
`define BAUD 115200

module rotator_encoder #(parameter CLKF = 215040000)
  (
   input 	     clk,
   input 	     srst,
   input 	     rx,
   output reg [15:0] azimuth,
   output reg 	     azimuth_vld
   );

   wire       rx_new;
   wire [7:0] rx_byte;
   reg [7:0]  rx_cksum;
   reg [2:0]  rx_cnt;

   localparam SM_BITS = 16;
   reg [SM_BITS-1:0] rxsm_buf;
   wire rxsm = |rxsm_buf;

   always @(posedge clk)
     rxsm_buf <= {rxsm_buf[SM_BITS-2:0], rx};
   
   always @(posedge clk) 
     if (srst)
       azimuth_vld <= 0;
     else 
       if (rx_new) begin
	  if (rx_byte == 8'h80) begin
	     rx_cksum <= 8'h80;
	     rx_cnt <= 1;
	  end
	  else if (rx_cnt == 1) begin
	     rx_cksum <= rx_cksum + rx_byte;
	     azimuth[1:0] <= rx_byte[3:2];
	     rx_cnt <= 2;
	  end
	  else if (rx_cnt == 2) begin
	     rx_cksum <= rx_cksum + rx_byte;
	     azimuth[15:9] <= rx_byte[6:0];
	     rx_cnt <= 3;
	  end
	  else if (rx_cnt == 3) begin
	     rx_cksum <= rx_cksum + rx_byte;
	     azimuth[8:2] <= rx_byte[6:0];
	     rx_cnt <= 4;
	  end
	  else if (rx_cnt == 4) begin
	     rx_cksum <= rx_cksum + rx_byte;
	     rx_cnt <= 5;
	  end
	  else if (rx_cnt == 5) begin
	     rx_cksum <= rx_cksum + rx_byte;
	     rx_cnt <= 6;
	  end
	  else if (rx_cnt == 6) begin
	     if (rx_cksum[6:0] == rx_byte[6:0])
	       azimuth_vld <= 1;
	     rx_cnt <= 7;
	  end
       end
       else
	 azimuth_vld <= 0;
   
   uart 
     #(.CLOCK_DIVIDE(CLKF/`BAUD/4))
   uart_inst
     (
      .clk            (clk    ),
      .rst            (srst   ),
      .rx             (rxsm   ),
      .tx             (       ),
      .transmit       (1'b0   ),
      .tx_byte        (8'b0   ),
      .received       (rx_new ),
      .rx_byte        (rx_byte),
      .is_receiving   (       ),
      .is_transmitting(       ),
      .recv_error     (       )
      );
   
endmodule

