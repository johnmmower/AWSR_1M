
module debounce_sync
  (
   input      clk,
   input      in,
   output reg out
   );

   (* MARK_ASYNC = "TRUE" *)
   reg in_t1, in_t2;
   
   always @(posedge clk) begin
      in_t1 <= in;
      in_t2 <= in_t1;
      out <= in_t2;
   end
      
endmodule


module debounce
  #(
    parameter CNT = 16
    )
   (
    input      clk,
    input      in,
    output reg re
    );

   localparam BITS = $clog2(CNT);

   reg [BITS-1:0] cntr;
      
   wire in_f;
   reg 	in_f_t1;

   always @(posedge clk) begin
      in_f_t1 <= in_f;
      
      if (in_f && ~in_f_t1 && ~|cntr) 
	re <= 1;
      else
	re <= 0;
      
      if (|cntr)
	cntr <= cntr + 'b1;
      else if (in_f && ~in_f_t1)
	cntr <= 'b1;
   end

   debounce_sync ds_inst
     (
      .clk(clk ),
      .in (in  ),
      .out(in_f)
      );
      
endmodule

   
   
