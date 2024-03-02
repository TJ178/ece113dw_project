// preemphasis speech filter
// doesn't do anything right now

module preemphasis #(
	parameter SAMPLE_BITS = 12
)(
	input 								 clk,
	input 								 rst,
	input 		 [SAMPLE_BITS-1:0] in,
	output logic [SAMPLE_BITS-1:0] out,
	output logic						 valid
);
	
	always_ff @ (posedge clk) begin
		out <= in;
		valid <= 1'b1;
	end


endmodule