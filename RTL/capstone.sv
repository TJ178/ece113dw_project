// Toplevel module for keyword spotter

module capstone(clk, rst, ledOut);
	input clk;
	input rst;
	output ledOut;
	
	
	// 8khz clock generator
	wire adc_clk;
	
	clkgen gen(clk, adc_clk);
	
	// adc sampler
	wire [11:0] adc_out;
	wire adc_out_new;
	
	adc_sampler sampler(clk, adc_clk, adc_out, adc_out_new);
	
	// preemphasis filter
	wire preemph_valid;
	wire [11:0] preemph_out;
	
	preemphasis preemph(clk, rst, adc_out, preemph_out, preemph_valid);
	
	// hamming filter
	wire [12-1:0] hamming_out [0:128-1];
	wire hamming_valid;
	
	hamming #(
		.WINDOW_FILEPATH("window.mem")
	) h (
		.clk(clk),
		.rst(rst),
		.in(preemph_out),
		.out(hamming_out),
		.valid(hamming_valid)
	);
	
	assign ledOut = hamming_valid;
	
	
endmodule