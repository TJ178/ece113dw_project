module adc_sampler(clk, sample_clk, sample_out, new_sample_out);
	input 			clk;
	input				sample_clk;
	output logic [11:0] 	sample_out;
	output logic			new_sample_out;
	
	wire [11:0] adc_out;
	
	// Intel University program ADC Controller IP
	//adc adc(clk, adc_out);
	adc_dummy #(
		.SAMPLES_FILEPATH("samples.mem")
	) adc(clk, adc_out);
	
	// sample at slower clock speed
	always_ff @ (posedge sample_clk) begin
		sample_out <= adc_out;
	end
	
	
	// pulse new_sample_out when a new sample is taken
	logic last = 1'b0;
	always_ff @ (posedge clk) begin
		if(!last & sample_clk) begin
			last <= sample_clk;
			new_sample_out <= 1'b1;
		end else begin
			last <= sample_clk;
			new_sample_out <= 1'b0;
		end
	end
	
	
endmodule