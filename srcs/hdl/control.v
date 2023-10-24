
`define NEXTSEC_REG_OFF 2

`define SCRATCH_REG_OFF 31

module control
  (
   input 	   reg_clk,
   input 	   reg_rstn,
   input [1023:0]  reg_from_ps,
   output [1023:0] reg_to_ps,

   output [31:0]   nextsec
   );
   
   assign nextsec = reg_from_ps[`NEXTSEC_REG_OFF*32 +: 32];

   assign reg_to_ps[`SCRATCH_REG_OFF +: 32] = reg_from_ps[`SCRATCH_REG_OFF +: 32];
   
endmodule

   
