
`include "system.vh"

module cal_freeze
  (
   input 		 ref_clk,
   input [`DAC_BITS-1:0] dac_addr,
   
   input 		 reg_clk,
   input 		 allow_cal_0,
   input 		 allow_cal_1,
   
   output reg 		 freeze_cal_0,
   output reg 		 freeze_cal_1
   );

   localparam [`DAC_BITS-1:0] lowcnt = `CAL_DLY * `CLKF;
   localparam [`DAC_BITS-1:0] hghcnt = {`DAC_BITS{1'b1}} - `CAL_DLY * `CLKF;

   reg dac_valid;

   (* MARK_ASYNC = "TRUE" *) 
   reg vld_m2, vld_m1;

   reg vld;
      
   always @(posedge ref_clk)
     if (dac_addr > lowcnt && dac_addr < hghcnt)
       dac_valid <= 1;
     else
       dac_valid <= 0;

   always @(posedge reg_clk) begin
      vld_m2 <= dac_valid;
      vld_m1 <= vld_m2;
      vld <= vld_m1;

      if (allow_cal_0 && vld)
	freeze_cal_0 <= 0;
      else
	freeze_cal_0 <= 1;

      if (allow_cal_1 && vld)
	freeze_cal_1 <= 0;
      else
	freeze_cal_1 <= 1;

   end

endmodule

   
