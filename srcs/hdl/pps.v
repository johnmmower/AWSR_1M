
module pps #(parameter FREQ = 125000000)
   (
    input      clk,
    output reg pps
    );

   reg [$clog2(FREQ)-1:0] cntr;

   always @(posedge clk) begin
      if (cntr < (FREQ - 1))
	cntr <= cntr + 'b1;
      else
	cntr <= 0;

      if (cntr < (FREQ / 10 - 1))
	pps <= 1;
      else
	pps <= 0;
   end

endmodule


   
