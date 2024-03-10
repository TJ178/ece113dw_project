module shift_reg #(
	parameter SIZE = 8,
	parameter SHIFT_AMT = 1
)(
	input 						clk,
	input 						rst,
	input [SHIFT_AMT-1:0] 	in,
	input 						shift_en,
	output [SIZE-1:0] 		out
);

always_ff @ (posedge clk) begin
	if(rst) begin
		out <= 'b0;
	end else if(shift_en) begin
		out <= {out[SIZE-SHIFT_AMT-1:SHIFT_AMT], in};
	end
end


endmodule