`define CLKF 215040000

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
   output 	vout10_v_n,
   output 	vout10_v_p,
   output 	vout13_v_n,
   output 	vout13_v_p,
   
   output [7:0] status,
   
   input 	pmod1_3         // pps
   );

   assign status[7:4] = 0;
      
   wire   ref_clk;
   wire   ref_rst; /////////////////////////
   wire   sys_clk;
   reg 	  sys_clk_s;

   wire   adc0_clk;
   wire   dac0_clk;
   wire   dac1_clk;

   wire   pps_os;
   
   wire        a_reg_clk;
   wire        a_reg_rstn;
   wire [1023:0] a_reg_from_ps;
   wire [1023:0] a_reg_to_ps;
   wire [31:0] 	 a_nextsec;

   // tmp
   reg [12:0] dac_0_addr;
   always @(posedge ref_clk)
       dac_0_addr <= dac_0_addr + 'b1;
   // END: tmp
   
   always @(posedge ref_clk)
       sys_clk_s <= sys_clk;

   control control_inst
     (
      .reg_clk    (a_reg_clk    ),
      .reg_rstn   (a_reg_rstn   ),
      .reg_from_ps(a_reg_from_ps),
      .reg_to_ps  (a_reg_to_ps  ),
      .nextsec    (a_nextsec    )
      );
      
   debounce debounce_pps
     (
      .clk(ref_clk),
      .in (pmod1_3),
      .re (pps_os )
      );
   
   timebase timebase_inst  
     (
      .clk        (ref_clk    ),
      .a_nextsec  (a_nextsec  ),
      .pps        (pps_os     ),
      .tic        (),
      .sec_l      (),
      .ppstime_l  (),
      .l_valid    ()
   );
   
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
   
   pps #(.FREQ(`CLKF)) pps_215_04_inst
     (
      .clk(ref_clk  ),
      .pps(status[0])
      );

   pps #(.FREQ(`CLKF/16)) pps_adc_13_44_inst
     (
      .clk(adc0_clk ),
      .pps(status[1])
      );
   
   pps #(.FREQ(`CLKF/16)) pps_dac0_13_44_inst
     (
      .clk(dac0_clk ),
      .pps(status[2])
      );
   
   pps #(.FREQ(`CLKF/16)) pps_dac1_13_44_inst
     (
      .clk(dac1_clk ),
      .pps(status[3])
      );  

   rotator_encoder #(.CLKF(`CLKF)) rotator_encoder_inst
     (
      .clk        (ref_clk),
      .srst       (ref_rst),
      .rx         (1'b0   ), //////////// connect
      .azimuth    ()
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
      .vout13_v_n      (vout13_v_n      ),
      .vout13_v_p      (vout13_v_p      ),
       
      .dac_0_addr      (dac_0_addr      ),   
      .adc_0           (),
      .adc_1           (),
      .user_sysref_adc (sys_clk_s       ),
      .ref_clk         (ref_clk         ),
      .ref_rstn        (1'b1),
      .RX_0_tdata      (128'd0),
      .RX_0_tvalid     (1'b0),
      .RX_0_tready     (),
      .RX_1_tdata      (128'd0),
      .RX_1_tvalid     (1'b0),
      .RX_1_tready     (),
   
      .clk_adc0_13M44  (adc0_clk        ),
      .clk_dac0_13M44  (dac0_clk        ),
      .clk_dac1_13M44  (dac1_clk        ),
      
      .reg_clk         (a_reg_clk       ),
      .reg_rstn        (a_reg_rstn      ),
      .regs_out        (a_reg_from_ps   ),
      .regs_in         (a_reg_to_ps     )
      );

endmodule


