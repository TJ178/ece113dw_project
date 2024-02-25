// Dummy ADC module for simulation purposes

module adc_dummy #(
	parameter SAMPLES_FILEPATH = "",
	parameter SAMPLE_BITS = 12,
	parameter NUM_SAMPLES = 16000
)
(
	input clk,
	output [SAMPLE_BITS-1:0] adc_out
);

logic [$clog2(NUM_SAMPLES)-1:0] current_sample_cnt = 'b0;

single_port_rom
#(
	.DATA_WIDTH(SAMPLE_BITS),
	.ADDR_WIDTH($clog2(NUM_SAMPLES)),
	.INIT_FILEPATH(SAMPLES_FILEPATH)
) rom (
	.addr(current_sample_cnt),
	.clk(clk),
	.q(adc_out)
);


always_ff @ (posedge clk) begin
	if(current_sample_cnt + 1 > NUM_SAMPLES) begin
		current_sample_cnt <= 'b0;
	end else begin
		current_sample_cnt <= current_sample_cnt + 'b1;
	end
end


endmodule