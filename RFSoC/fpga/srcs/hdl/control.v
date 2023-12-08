
`define CONTROL_REG_OFF           0   // RW 0x00 

`define RUNSTART_BIT  0
`define RUNTX_BIT     1
`define USEPA_BIT     2
`define RUNRX_CH0_BIT 3
`define RUNRX_CH1_BIT 4


`define STATUS_REG_OFF            1   // RO 0x04

`define BUF_ERR_CH0_BIT 0
`define TRG_ERR_CH0_BIT 1
`define BUF_ERR_CH1_BIT 2
`define TRG_ERR_CH1_BIT 3


`define NEXTSEC_REG_OFF           2   // WO 0x08
`define TXDELAYM1_REG_OFF         3   // WO 0x0C
`define TXONM1_REG_OFF            4   // WO 0x10
`define PRFCNTM1_REG_OFF          5   // WO 0x14
`define INTCNTM1_ANTSEQ_REG_OFF   6   // WO 0x18  < intcntm1, 8'b0, antseq >
`define AZI_REG_OFF               7   // WO 0x1C  < hghazi, lowazi > 
`define CFG_REG_OFF               8   // WO 0x20  < 16'b0, cfg > 
`define SAMPSM1_SAMPS_CH0_REG_OFF 9   // WO 0x24  < sampsm1, samps > 
`define SHIFT_CH0_REG_OFF         10  // WO 0x28  < 16'b0, shift > 
`define DELAYM1_CH0_REG_OFF       11  // WO 0x2C
`define SAMPSM1_SAMPS_CH1_REG_OFF 12  // WO 0x30  < sampsm1, samps > 
`define SHIFT_CH1_REG_OFF         13  // WO 0x34  < 16'b0, shift > 
`define DELAYM1_CH1_REG_OFF       14  // WO 0x38

`define CH1_CH0_MAXLEN_REG_OFF    15  // RO 0x3C  < ch1_len, ch0_len >

`define BUILDTIME_REG_OFF         16  // RO 0x40  

`include "system.vh"

module control
  (
   input 	   reg_clk,
   input 	   reg_rstn,

   input [1023:0]  reg_from_ps,
   output [1023:0] reg_to_ps,

   output [31:0]   nextsec,
   
   output 	   runtx,
   output 	   usepa,
   output 	   runrx_ch0,
   output 	   runrx_ch1,

   output [31:0]   txdelaym1,
   output [31:0]   txonm1,
   output [31:0]   prfcntm1,
   output [31:0]   intcntm1,
   output [15:0]   lowazi,
   output [15:0]   hghazi,
   output [7:0]    antseq,
   output [15:0]   cfg,
   output [15:0]   samps_ch0,
   output [15:0]   sampsm1_ch0,
   output [15:0]   shift_ch0,
   output [31:0]   delaym1_ch0,
   input 	   buf_error_ch0,
   input 	   trg_error_ch0,
   output [15:0]   samps_ch1,
   output [15:0]   sampsm1_ch1,
   output [15:0]   shift_ch1,
   output [31:0]   delaym1_ch1,
   input 	   buf_error_ch1,
   input 	   trg_error_ch1,
   
   output 	   arst   
   );

   
   wire [31:0] 	   control = reg_from_ps[`CONTROL_REG_OFF*32 +: 32];
   assign arst = ~control[`RUNSTART_BIT] || ~reg_rstn;  // hold at zero until ready
   assign runtx = control[`RUNTX_BIT];
   assign usepa = control[`USEPA_BIT];
   assign runrx_ch0 = control[`RUNRX_CH0_BIT];
   assign runrx_ch1 = control[`RUNRX_CH1_BIT];
   assign reg_to_ps[`CONTROL_REG_OFF*32 +: 32] = control;

      
   wire [31:0] 	   status;
   assign status[`BUF_ERR_CH0_BIT] = buf_error_ch0;
   assign status[`TRG_ERR_CH0_BIT] = trg_error_ch0;
   assign status[`BUF_ERR_CH1_BIT] = buf_error_ch1;
   assign status[`TRG_ERR_CH1_BIT] = trg_error_ch1;
   assign reg_to_ps[`STATUS_REG_OFF*32 +: 32] = status;
   
   
   assign nextsec = reg_from_ps[`NEXTSEC_REG_OFF*32 +: 32];
   assign txdelaym1 = reg_from_ps[`TXDELAYM1_REG_OFF*32 +: 32];
   assign txonm1 = reg_from_ps[`TXONM1_REG_OFF*32 +: 32];
   assign prfcntm1 = reg_from_ps[`PRFCNTM1_REG_OFF*32 +: 32];
   assign intcntm1 = reg_from_ps[`INTCNTM1_ANTSEQ_REG_OFF*32+16 +: 16];
   assign antseq = reg_from_ps[`INTCNTM1_ANTSEQ_REG_OFF*32 +: 8];
   assign lowazi = reg_from_ps[`AZI_REG_OFF*32 +: 16];
   assign hghazi = reg_from_ps[`AZI_REG_OFF*32+16 +: 16];
   assign cfg = reg_from_ps[`CFG_REG_OFF*32 +: 16];
   assign samps_ch0 = reg_from_ps[`SAMPSM1_SAMPS_CH0_REG_OFF*32 +: 16];
   assign sampsm1_ch0 = reg_from_ps[`SAMPSM1_SAMPS_CH0_REG_OFF*32+16 +: 16];
   assign shift_ch0 = reg_from_ps[`SHIFT_CH0_REG_OFF*32 +: 16];
   assign delaym1_ch0 = reg_from_ps[`DELAYM1_CH0_REG_OFF*32 +: 32];
   assign samps_ch1 = reg_from_ps[`SAMPSM1_SAMPS_CH1_REG_OFF*32 +: 16];
   assign sampsm1_ch1 = reg_from_ps[`SAMPSM1_SAMPS_CH1_REG_OFF*32+16 +: 16];
   assign shift_ch1 = reg_from_ps[`SHIFT_CH1_REG_OFF*32 +: 16];
   assign delaym1_ch1 = reg_from_ps[`DELAYM1_CH1_REG_OFF*32 +: 32];

   
   localparam [15:0] ch0_len = `CH0_SIZE;
   localparam [15:0] ch1_len = `CH1_SIZE;
   assign reg_to_ps[`CH1_CH0_MAXLEN_REG_OFF*32 +: 32] = {ch1_len, ch0_len};

   
   wire [31:0] 	   buildtime;
   USR_ACCESSE2 USR_ACCESSE2_inst 
     (
      .CFGCLK   (         ),
      .DATA     (buildtime),
      .DATAVALID(         )
      );
   assign reg_to_ps[`BUILDTIME_REG_OFF*32 +: 32] = buildtime;

      
endmodule

