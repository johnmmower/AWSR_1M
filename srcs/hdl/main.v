

module main
  (
   input 	ref_n,
   input 	ref_p,
   input 	sys_n,
   input 	sys_p,
   
   input 	adc0_clk_clk_n,
   input 	adc0_clk_clk_p,
   input 	dac0_clk_clk_n,
   input 	dac0_clk_clk_p,
   input 	dac1_clk_clk_n,
   input 	dac1_clk_clk_p,
   
   input 	sysref_in_diff_n,
   input 	sysref_in_diff_p,
   
   input 	vin0_01_v_n,
   input 	vin0_01_v_p,
   input 	vin0_23_v_n,
   input 	vin0_23_v_p,
   
   output 	vout00_v_n,
   output 	vout00_v_p,
   output   vout10_v_n,
   output   vout10_v_p,
   //output   vout12_v_n,
   //output   vout12_v_p,
   output   vout13_v_n,
   output   vout13_v_p,
   
   output [7:0] status
   );

   assign status[7:4] = 0;
      
   wire   ref_clk;
   wire   sys_clk;
   wire   adc0_clk;
   wire   dac0_clk;
   wire   dac1_clk;
   
   reg [13:0] dac_0_addr;
   always @(posedge ref_clk)
       dac_0_addr <= dac_0_addr + 'b1;
   
   //
   (* MARK_DEBUG = "TRUE" *)
   reg   sys_clk_t1;
   always @(posedge ref_clk)
       sys_clk_t1 <= sys_clk;
   //
   
   IBUFDS ref_ibufds_inst
     (
      .O (ref_clk),
      .I (ref_p  ),
      .IB(ref_n  )
      );
   
   IBUFDS sys_ibufds_inst
     (
      .O (sys_clk),
      .I (sys_p  ),
      .IB(sys_n  )
      );
   
   pps #(.FREQ(215040000)) pps_215_04_inst
     (
      .clk(ref_clk  ),
      .pps(status[0])
      );

   pps #(.FREQ(13440000)) pps_adc_13_44_inst
     (
      .clk(adc0_clk ),
      .pps(status[1])
      );
   
   pps #(.FREQ(13440000)) pps_dac0_13_44_inst
     (
      .clk(dac0_clk ),
      .pps(status[2])
      );
   
   pps #(.FREQ(13440000)) pps_dac1_13_44_inst
     (
      .clk(dac1_clk ),
      .pps(status[3])
      );
   
  
      
   design_main design_main_inst
     (
      .adc0_clk_clk_n  (adc0_clk_clk_n  ),
      .adc0_clk_clk_p  (adc0_clk_clk_p  ),
      .dac0_clk_clk_n  (dac0_clk_clk_n  ),
      .dac0_clk_clk_p  (dac0_clk_clk_p  ),
      .dac1_clk_clk_n  (dac1_clk_clk_n  ),
      .dac1_clk_clk_p  (dac1_clk_clk_p  ),
      
      .sysref_in_diff_n(sysref_in_diff_n),
      .sysref_in_diff_p(sysref_in_diff_p),
      
      .vin0_01_v_n     (vin0_01_v_n     ),
      .vin0_01_v_p     (vin0_01_v_p     ),
      .vin0_23_v_n     (vin0_23_v_n     ),
      .vin0_23_v_p     (vin0_23_v_p     ),
      .vout00_v_n      (vout00_v_n      ),
      .vout00_v_p      (vout00_v_p      ),
      .vout10_v_n      (vout10_v_n      ),
      .vout10_v_p      (vout10_v_p      ),
      //.vout12_v_n      (vout12_v_n      ),
      //.vout12_v_p      (vout12_v_p      ),
      .vout13_v_n      (vout13_v_n      ),
      .vout13_v_p      (vout13_v_p      ),
       
      .dac_0_addr      (dac_0_addr      ),   
      .adc_0           (),
      .adc_1           (),
      .user_sysref_adc (sys_clk_t1      ),
      .ref_clk         (ref_clk         ),
      .ref_rstn        (1'b1),
      .RX_0_tdata      (32'd0),
      .RX_0_tvalid     (1'b0),
      .RX_0_tready     (),
   
      .clk_adc0_13M44  (adc0_clk        ),
      .clk_dac0_13M44  (dac0_clk        ),
      .clk_dac1_13M44  (dac1_clk        ),
      
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
