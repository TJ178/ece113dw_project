module mel_spectrum_fifo #(
	parameter NUM_COEFF = 40,
	parameter BIT_WIDTH = 16
)(
	input clk,
	input mel_valid,
	input [0:39][15:0] mel_data,
	output logic mel_ready,
	output logic content [0:255][0:39][15:0]
);

always_ff @ (posedge clk) begin
	if(mel_valid) begin
		mel_ready <= 1'b1;
		content[0:254] <= content[1:255];
		content[255] <= mel_data;
	end else begin
		mel_ready <= 1'b0;
	end
end


endmodule