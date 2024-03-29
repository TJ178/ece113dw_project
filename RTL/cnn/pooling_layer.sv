module pooling_layer #(
	parameter INPUT_X = 128,
	parameter INPUT_Y = 128,
	parameter POOL_SIZE = 3,
	parameter STRIDE = 3,
	parameter BIT_WIDTH = 16,
	parameter NUM_RAM_SPLITS = 2
)
(
	input 													clk,
	input 													rst,
	input 													start,
	input  [(BIT_WIDTH * NUM_RAM_SPLITS)-1:0] 	data_rd,
	output [$clog2(INPUT_X)-1:0]					 	addr_rd,
	output [BIT_WIDTH-1:0] 								data_wr,
	output [$clog2(INPUT_X)-1:0] 						addr_wr,
	output [NUM_RAM_SPLITS-1:0] 						wren,
	output 													done
);


localparam OUT_X = INPUT_X / STRIDE;
localparam OUT_Y = INPUT_Y / STRIDE;
localparam OUT_SIZE = OUT_X * OUT_Y;


// KERNEL SUBMODULE
logic [POOL_SIZE * POOL_SIZE * BIT_WIDTH -1:0] kernel_in;
logic [BIT_WIDTH-1:0] kernel_out;

maxpool_kernel #(
	.SIZE(POOL_SIZE),
	.BIT_WIDTH(BIT_WIDTH)
)k(
	.in(kernel_in),
	.out(kernel_out)
);


// SHIFT REGISTERS
logic [(BIT_WIDTH * POOL_SIZE)-1:0] shift_in_d, shift_in;
logic [POOL_SIZE-1:0] shift_en_d, shift_en;

genvar  i;
generate 
	for(i = 0; i < POOL_SIZE; i = i + 1) begin : GEN_SHIFT_REG
		shift_reg #(
			.SIZE(POOL_SIZE * BIT_WIDTH),
			.SHIFT_AMT(BIT_WIDTH)
		) shift (
			.clk(clk),
			.rst(rst),
			.in(shift_in[BIT_WIDTH * i +: BIT_WIDTH]),
			.out(kernel_in[BIT_WIDTH*POOL_SIZE * i +: BIT_WIDTH*POOL_SIZE]),
			.shift_en(shift_en[i])
		);
	end
endgenerate


// FSM
localparam RST = 0;
localparam INIT = 1;
localparam RUN = 2;
localparam DONE = 3;

logic [1:0] state, state_d;
logic done_d;

logic [$clog2(OUT_X)-1:0] x, x_d;
logic [$clog2(OUT_Y)-1:0] y, y_d;
logic [$clog2(INPUT_X)-1:0] addr_rd_d;
logic [$clog2(INPUT_X)-1:0] addr_wr_d;
logic wren_d;
logic [BIT_WIDTH-1:0] data_wr_d;


logic [$clog2(POOL_SIZE)-1:0] init_counter, init_counter_d;
logic [$clog2(NUM_RAM_SPLITS-POOL_SIZE)-1:0] split_offset, split_offset_d;


always_ff @ (posedge clk) begin
	if(rst) begin
		state <= 'b0;
		addr_rd <= 'b0;
		addr_wr <= 'b0;
		data_wr <= 'b0;
		wren 	<= 'b0;
		x <= 'b0;
		y <= 'b0;
		split_offset <= 'b0;
		init_counter <= 'b0;
		shift_en <= 'b0;
		shift_in <= 'b0;
		done <= 'b0;
	end else begin
		state <= state_d;
		addr_rd <= addr_rd_d;
		addr_wr <= addr_wr_d;
		data_wr <= data_wr_d;
		wren <= wren_d;
		x <= x_d;
		y <= y_d;
		split_offset <= split_offset_d;
		init_counter <= init_counter_d;
		shift_en <= shift_en_d;
		shift_in <= shift_in_d;
		done <= done_d;
	end
end


always_comb begin
	state_d = state;
	wren_d = 0;
	addr_wr_d = addr_wr;
	addr_rd_d = addr_rd;
	
	case(state)
		RST: begin
			x_d = 'b0;
			y_d = 'b0;
			addr_rd_d = 'b0;
			addr_wr_d = 'b0;
			data_wr_d = 'b0;
			wren_d = 'b0;
			done_d = 'b0;
		end
		
		// Read for start of first line
		INIT: begin
			init_counter_d = init_counter + 1;
			if(init_counter+1 == POOL_SIZE) begin
				init_counter_d = 'b0;
				state_d = RUN;
			end else begin
				state_d = INIT;
			end
			addr_rd_d = addr_rd + 1;
			shift_in_d = data_rd[ (POOL_SIZE * BIT_WIDTH) * split_offset +: (POOL_SIZE * BIT_WIDTH)];
			shift_en_d = {POOL_SIZE{1'b1}};
		end 
		
		RUN: begin
			// stage swap cases:
		
			// increment counters
			if(x+STRIDE >= OUT_X) begin
				state_d = INIT;
				split_offset_d = split_offset + 1;
				x_d = 0;
				if(y+STRIDE >= OUT_Y) begin
					state_d = DONE;
					done_d = 1'b1;
				end else begin
					y_d = y + STRIDE;
				end
			end else begin
				x_d = x + STRIDE;
				y_d = y;
			end
			
			addr_rd_d = addr_rd + STRIDE;
			shift_in_d = data_rd[ (POOL_SIZE * BIT_WIDTH) * split_offset +: (POOL_SIZE * BIT_WIDTH)];
			shift_en_d = {POOL_SIZE{1'b1}};
		end
		
		DONE: begin
			done_d = 'b1;
		end
		
	endcase
end

endmodule