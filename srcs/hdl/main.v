

module main
  (
   input 	ref_n,
   input 	ref_p,
   input 	sys_n,
   input 	sys_p,
   
   output [7:0] status,

   input 	adc0_clk_clk_n,
   input 	adc0_clk_clk_p,
   input 	dac1_clk_clk_n,
   input 	dac1_clk_clk_p,
   input 	sysref_in_diff_n,
   input 	sysref_in_diff_p,
   input 	vin0_01_v_n,
   input 	vin0_01_v_p,
   input 	vin0_23_v_n,
   input 	vin0_23_v_p,
   output 	vout13_v_n,
   output 	vout13_v_p
   );

   assign status[7:1] = 0;
      
   wire   ref_clk;
   
   IBUFDS ref_ibufds_inst
     (
      .O (ref_clk),
      .I (ref_p  ),
      .IB(ref_n  )
      );

   pps #(.FREQ(192000000)) pps_192_inst
     (
      .clk(ref_clk  ),
      .pps(status[0])
      );
      
   design_main design_main_inst
     (
      .adc0_clk_clk_n  (adc0_clk_clk_n  ),
      .adc0_clk_clk_p  (adc0_clk_clk_p  ),
      .dac1_clk_clk_n  (dac1_clk_clk_n  ),
      .dac1_clk_clk_p  (dac1_clk_clk_p  ),
      .sysref_in_diff_n(sysref_in_diff_n),
      .sysref_in_diff_p(sysref_in_diff_p),
      .vin0_01_v_n     (vin0_01_v_n     ),
      .vin0_01_v_p     (vin0_01_v_p     ),
      .vin0_23_v_n     (vin0_23_v_n     ),
      .vin0_23_v_p     (vin0_23_v_p     ),
      .vout13_v_n      (vout13_v_n      ),
      .vout13_v_p      (vout13_v_p      ),
      
      .dac_0_addr      (14'd0),   
      .adc_0           (),
      .adc_1           (),
      .ref_clk         (ref_clk         ),
      .ref_rstn        (1'b1),
      .RX_0_tdata      (32'd0),
      .RX_0_tvalid     (1'b0),
      .RX_0_tready     (),
      
      .reg_clk         (),
      .reg_rstn        (),
      .regs_out        (),
      .regs_in         (1024'd0)
      );

endmodule

   


/*
    wire   xclk;
   wire   xrst;
   (* MARK_DEBUG = "TRUE" *)
   wire   trig;
   (* MARK_DEBUG = "TRUE" *)
   wire [31:0] adc_0;
   (* MARK_DEBUG = "TRUE" *)
   wire [13:0] dac_0_addr;
   wire [31:0] rx_0_tdata;
   wire        rx_0_tvalid = 0; // duh
   wire [15:0] rxsmps;
   wire [13:0] txsmps;
      
   wire        reg_clk;
   wire        reg_rstn;
   wire [1023:0] regs_out;
   wire [1023:0] regs_in;
     
   (* MARK_DEBUG = "TRUE" *) wire paen;
    
   control control_inst
     (
      .reg_clk     (reg_clk ),
      .reg_rstn    (reg_rstn),
      .regs_from_ps(regs_out),
      .regs_to_ps  (regs_in ),
      .clk         (xclk    ),
      .rxsmps      (rxsmps  ),
      .txsmps      (txsmps  ),
      .rst         (xrst    ),
      .trig        (trig    )
      );

   tx_ctrl tx_ctrl_inst
     (
      .clk    (xclk      ),
      .rst    (xrst      ),
      .trig   (trig      ),
      .txsmps (txsmps    ),
      .tx_addr(dac_0_addr),
      .pa_en  (paen      )
      );
      

*/
