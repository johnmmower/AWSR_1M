
`include "system.vh"

module main
  (
   output 	 C0_DDR4_act_n,
   output [16:0] C0_DDR4_adr,
   output [1:0]  C0_DDR4_ba,
   output [0:0]  C0_DDR4_bg,
   output [0:0]  C0_DDR4_ck_c,
   output [0:0]  C0_DDR4_ck_t,
   output [0:0]  C0_DDR4_cke,
   output [0:0]  C0_DDR4_cs_n,
   inout [7:0] 	 C0_DDR4_dm_n,
   inout [63:0]  C0_DDR4_dq,
   inout [7:0] 	 C0_DDR4_dqs_c,
   inout [7:0] 	 C0_DDR4_dqs_t,
   output [0:0]  C0_DDR4_odt,
   output 	 C0_DDR4_reset_n,
   input 	 C0_SYS_CLK_clk_n,
   input 	 C0_SYS_CLK_clk_p,

   input 	 ref_n,
   input 	 ref_p,
   input 	 sys_n,
   input 	 sys_p,
   
   input 	 adc0_clk_clk_n,
   input 	 adc0_clk_clk_p,
   input 	 dac0_clk_clk_n,
   input 	 dac0_clk_clk_p,
   input 	 dac1_clk_clk_n,
   input 	 dac1_clk_clk_p,
   
   input 	 sysref_in_diff_n,
   input 	 sysref_in_diff_p,
   
   input 	 vin0_01_v_n,
   input 	 vin0_01_v_p,
   input 	 vin0_23_v_n,
   input 	 vin0_23_v_p,
   
   output 	 vout00_v_n,
   output 	 vout00_v_p,
   output 	 vout10_v_n,
   output 	 vout10_v_p,
   output 	 vout13_v_n,
   output 	 vout13_v_p,
   
   output [7:0]  status,
   
   output 	 pmod1_3         // paen monitor
   );

   assign status[7:4] = 0;
      
   wire   ref_clk;
   wire   ref_rst; 
   wire   sys_clk;
   reg 	  sys_clk_s;

   wire   adc0_clk;
   wire   dac0_clk;
   wire   dac1_clk;

   wire   a_freeze_cal_0;
   wire   a_freeze_cal_1;
     
   wire        a_reg_clk;
   wire        a_reg_rstn;
   wire [1023:0] a_reg_from_ps;
   wire [1023:0] a_reg_to_ps;
   wire [31:0] 	 a_nextsec;
   wire 	 arst;
   wire 	 ausepa;
   wire 	 aruntx;
   wire 	 arunrx_ch0;
   wire 	 arunrx_ch1;
   wire 	 areset_fifo;
   wire [31:0] 	 atxdelaym1;
   wire [31:0] 	 atxonm1;
   wire [31:0] 	 aprfcntm1;
   wire [15:0] 	 aintcntm1;
   wire [15:0] 	 alowazi;
   wire [15:0] 	 ahghazi;
   wire [7:0] 	 aantseq;
   wire [15:0] 	 acfg;
   wire [15:0] 	 asamps_ch0;
   wire [15:0] 	 asampsm1_ch0;
   wire [15:0] 	 ashift_ch0;
   wire [31:0] 	 adelaym1_ch0;
   wire [15:0] 	 asamps_ch1;
   wire [15:0] 	 asampsm1_ch1;
   wire [15:0] 	 ashift_ch1;
   wire [31:0] 	 adelaym1_ch1;

   wire [31:0] 	 tic;
   wire [31:0] 	 sec;
   wire [`DAC_BITS-1:0] dac_0_addr;
   wire 	 reset_fifo;
   
   wire [127:0]  tdata_ch0;
   wire 	 tready_ch0;
   wire 	 tvalid_ch0;
   wire 	 tlast_ch0;
   wire 	 buf_error_ch0;
   wire 	 trg_error_ch0;
   wire [15:0] 	 adc0_I;
   wire [15:0] 	 adc0_Q;

   wire [127:0]  tdata_ch1;
   wire 	 tready_ch1;
   wire 	 tvalid_ch1;
   wire 	 tlast_ch1;
   wire 	 buf_error_ch1;
   wire 	 trg_error_ch1;
      
   wire [1:0] 	 antenna;
   (* MARK_DEBUG = "TRUE" *)
   wire 	 paen;
   wire 	 pps_os;
   wire [15:0] 	 azimuth;

   assign pmod1_3 = paen;
      
   always @(posedge ref_clk)
       sys_clk_s <= sys_clk;

   proc proc_inst
     (
      .arst         (arst         ),
      .ausepa       (ausepa       ),
      .aruntx       (aruntx       ),
      .arunrx_ch0   (arunrx_ch0   ),
      .arunrx_ch1   (arunrx_ch1   ),
      .atxdelaym1   (atxdelaym1   ),
      .atxonm1      (atxonm1      ),
      .aprfcntm1    (aprfcntm1    ),
      .aintcntm1    (aintcntm1    ),
      .alowazi      (alowazi      ),
      .ahghazi      (ahghazi      ),
      .aantseq      (aantseq      ),
      .acfg         (acfg         ),
      .asamps_ch0   (asamps_ch0   ),
      .asampsm1_ch0 (asampsm1_ch0 ),
      .ashift_ch0   (ashift_ch0   ),
      .adelaym1_ch0 (adelaym1_ch0 ),
      .asamps_ch1   (asamps_ch1   ),
      .asampsm1_ch1 (asampsm1_ch1 ),
      .ashift_ch1   (ashift_ch1   ),
      .adelaym1_ch1 (adelaym1_ch1 ),
      .clk          (ref_clk      ),
      .rst          (ref_rst      ),
      .sec          (sec          ),
      .tic          (tic          ),
      .azimuth      (azimuth      ),
      .antenna      (antenna      ),
      .dac_addr     (dac_0_addr   ),
      .paen         (paen         ),
      .rx_I_ch0     (adc0_I       ),
      .rx_Q_ch0     (adc0_Q       ),
      .tdata_ch0    (tdata_ch0    ),
      .tready_ch0   (tready_ch0   ),
      .tvalid_ch0   (tvalid_ch0   ),
      .tlast_ch0    (tlast_ch0    ),
      .buf_error_ch0(buf_error_ch0),
      .trg_error_ch0(trg_error_ch0),
      .rx_I_ch1     (adc1_I       ),
      .rx_Q_ch1     (adc1_Q       ),
      .tdata_ch1    (tdata_ch1    ),
      .tready_ch1   (tready_ch1   ),
      .tvalid_ch1   (tvalid_ch1   ),
      .tlast_ch1    (tlast_ch1    ),
      .buf_error_ch1(buf_error_ch1),
      .trg_error_ch1(trg_error_ch1)
      );

   control control_inst
     (
      .reg_clk      (a_reg_clk     ),
      .reg_rstn     (a_reg_rstn    ),
      .reg_from_ps  (a_reg_from_ps ),
      .reg_to_ps    (a_reg_to_ps   ),
      .nextsec      (a_nextsec     ),
      .runtx        (aruntx        ),
      .usepa        (ausepa        ),
      .runrx_ch0    (arunrx_ch0    ),
      .runrx_ch1    (arunrx_ch1    ),
      .reset_fifo   (areset_fifo   ),
      .txdelaym1    (atxdelaym1    ),
      .txonm1       (atxonm1       ),
      .prfcntm1     (aprfcntm1     ),
      .intcntm1     (aintcntm1     ),
      .lowazi       (alowazi       ),
      .hghazi       (ahghazi       ),
      .antseq       (aantseq       ),
      .cfg          (acfg          ),
      .samps_ch0    (asamps_ch0    ),
      .sampsm1_ch0  (asampsm1_ch0  ),
      .shift_ch0    (ashift_ch0    ),
      .delaym1_ch0  (adelaym1_ch0  ),
      .buf_error_ch0(buf_error_ch0 ),
      .trg_error_ch0(trg_error_ch0 ),
      .samps_ch1    (asamps_ch1    ),
      .sampsm1_ch1  (asampsm1_ch1  ),
      .shift_ch1    (ashift_ch1    ),
      .delaym1_ch1  (adelaym1_ch1  ),
      .buf_error_ch1(buf_error_ch1 ),
      .trg_error_ch1(trg_error_ch1 ),
      .arst         (arst          ),
      .freeze_cal_0 (a_freeze_cal_0),
      .freeze_cal_1 (a_freeze_cal_1)
      );

   async_debounce async_rst_fifo_inst
     (
      .clk    (ref_clk    ),
      .adin   (areset_fifo),
      .dout   (reset_fifo ),
      .oneshot()
      );   
      
   debounce debounce_pps
     (
      .clk(ref_clk),
      .in (1'b0),
      .re (pps_os )
      );
   
   timebase timebase_inst  
     (
      .clk        (ref_clk    ),
      .a_nextsec  (a_nextsec  ),
      .pps        (pps_os     ),
      .tic        (tic        ),
      .sec_l      (sec        ),
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
      .azimuth    (azimuth)
      );
         
   design_main design_main_inst
     (
      .C0_DDR4_act_n   (C0_DDR4_act_n   ),
      .C0_DDR4_adr     (C0_DDR4_adr     ),
      .C0_DDR4_ba      (C0_DDR4_ba      ),
      .C0_DDR4_bg      (C0_DDR4_bg      ),
      .C0_DDR4_ck_c    (C0_DDR4_ck_c    ),
      .C0_DDR4_ck_t    (C0_DDR4_ck_t    ),
      .C0_DDR4_cke     (C0_DDR4_cke     ),
      .C0_DDR4_cs_n    (C0_DDR4_cs_n    ),
      .C0_DDR4_dm_n    (C0_DDR4_dm_n    ),
      .C0_DDR4_dq      (C0_DDR4_dq      ),
      .C0_DDR4_dqs_c   (C0_DDR4_dqs_c   ),
      .C0_DDR4_dqs_t   (C0_DDR4_dqs_t   ),
      .C0_DDR4_odt     (C0_DDR4_odt     ),
      .C0_DDR4_reset_n (C0_DDR4_reset_n ),
      .C0_SYS_CLK_clk_n(C0_SYS_CLK_clk_n),
      .C0_SYS_CLK_clk_p(C0_SYS_CLK_clk_p),

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
      .adc0_I          (adc0_I          ),
      .adc0_Q          (adc0_Q          ),  
      .adc1_I          (adc1_I          ),
      .adc1_Q          (adc1_Q          ),

      .user_sysref_adc (sys_clk_s       ),
      .ref_clk         (ref_clk         ),
      .ref_rstn        (~reset_fifo     ),
      
      .RX_0_tdata      (tdata_ch0       ),
      .RX_0_tready     (tready_ch0      ),
      .RX_0_tvalid     (tvalid_ch0      ),
      .RX_0_tlast      (tlast_ch0       ),
      
      .RX_1_tdata      (tdata_ch1       ),
      .RX_1_tready     (tready_ch1      ),
      .RX_1_tvalid     (tvalid_ch1      ),
      .RX_1_tlast      (tlast_ch1       ),
   
      .clk_adc0_13M44  (adc0_clk        ),
      .clk_dac0_13M44  (dac0_clk        ),
      .clk_dac1_13M44  (dac1_clk        ),
      
      .reg_clk         (a_reg_clk       ),
      .reg_rstn        (a_reg_rstn      ),
      .regs_out        (a_reg_from_ps   ),
      .regs_in         (a_reg_to_ps     ),

      .freeze_cal_0    (a_freeze_cal_0  ),
      .freeze_cal_1    (a_freeze_cal_1  )
      );

endmodule


