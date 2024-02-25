module hamming#(
	parameter SAMPLE_BITS = 12,
	parameter WINDOW_SIZE = 128,
	parameter WINDOW_BITS = 9,
	parameter WINDOW_FRAC_BITS = 8,
	parameter WINDOW_FILEPATH = ""
)(
	input 						 clk,
	input 						 rst, 
	input  [SAMPLE_BITS-1:0] in,
	output logic [SAMPLE_BITS-1:0] out [0:WINDOW_SIZE-1],
	output 						 valid
);


logic [$clog2(WINDOW_SIZE)-1:0] current_sample_cnt = 'b0;
logic [WINDOW_BITS-1:0] rom_out;
logic [SAMPLE_BITS-1:0] sample_buff;

single_port_rom
#(
	.DATA_WIDTH(WINDOW_BITS),
	.ADDR_WIDTH($clog2(WINDOW_SIZE)),
	.INIT_FILEPATH(WINDOW_FILEPATH)
) rom (
	.addr(current_sample_cnt),
	.clk(clk),
	.q(rom_out)
);

assign valid = current_sample_cnt == 'b0;

logic [SAMPLE_BITS+WINDOW_BITS-1:0] product;
assign product = (sample_buff * rom_out);

always_ff @ (posedge clk) begin
	if(rst) begin
		sample_buff <= 'b0;
		out[0:WINDOW_SIZE-1] <= '{default: '0};
		current_sample_cnt <= 'b0;
	end else begin
		sample_buff <= in;
		
		// fixed point math w/ 11 frac bits
		out[current_sample_cnt] <= product >> (WINDOW_FRAC_BITS);
		current_sample_cnt <= current_sample_cnt + 1;
	end
end

endmodule