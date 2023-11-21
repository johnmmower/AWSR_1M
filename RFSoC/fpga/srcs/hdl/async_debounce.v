
module async_debounce #(parameter BITS=8)
  (
   input      clk,
   input      adin,
   output reg dout,
   output reg oneshot
   );

   (* MARK_ASYNC = "TRUE" *)
   reg adin_t1, adin_t2;
   reg dout_t1;
   reg [BITS-1:0] buffer;
   
   always @(posedge clk) begin
      adin_t1 <= adin;
      adin_t2 <= adin_t1;

      buffer <= { buffer[BITS-2:0], adin_t2 };
      dout <= |buffer;
      dout_t1 <= dout;
      oneshot <= dout && ~dout_t1;
   end
   
endmodule

   
