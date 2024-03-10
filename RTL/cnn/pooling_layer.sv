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


localparam OUT_X = INPUT_X / POOL_STRIDE;
localparam OUT_Y = INPUT_Y / POOL_STRIDE;
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
logic [(BIT_WIDTH * POOL_SIZE)-1:0] shift_in;
logic [POOL_SIZE-1:0] shift_en;

genvar  i;
generate begin
	for(i = 0; i < POOL_SIZE; i++) begin : GEN_SHIFT_REG
		shift_reg #(
			.SIZE(POOL_SIZE * BIT_WIDTH),
			.SHIFT_AMT(BIT_WIDTH)
		) shift (
			.clk(clk),
			.rst(rst),
			.in(shift_in[BIT_WIDTH * i +: BIT_WIDTH]),
			.out(kernel_in[BIT_WIDTH*POOL_SIZE * i += BIT_WIDTH*POOL_SIZE]),
			.shift_en(shift_en[i])
		);
	end
endgenerate


// FSM
localparam RST = 0;
localparam READ = 1;
localparam DONE = 2;
localparam INC = 3;

logic [1:0] state, state_d;

logic [$clog2(OUT_X)-1:0] x, x_d;
logic [$clog2(OUT_Y)-1:0] y, y_d;
logic [$clog2(INPUT_X)-1:0] addr_rd_d;
logic [$clog2(INPUT_X)-1:0] addr_wr_d;
logic wren_d;
logic [BIT_WIDTH-1:0] data_wr_d;


logic [$clog2(POOL_SIZE)-1:0] init_counter, init_counter_d;


always_ff @ (posedge clk) begin
	if(rst) begin
		state <= 'b0;
		addr_rd <= 'b0;
		addr_wr <= 'b0;
		data_wr <= 'b0;
		wren 	<= 'b0;
		x <= 'b0;
		y <= 'b0;
		done <= 'b0;
	end else begin
		state <= state_d;
		addr_rd <= addr_rd_d;
		addr_wr <= addr_wr_d;
		data_wr <= data_wr_d;
		wren <= wren_d;
		x <= x_d;
		y <= y_d;
		done <= done_d;
	end
end


always_comb begin
	state_d = state;
	wren_d = 0;
	addr_wr_d = addr_wr;
	addr_rd_d = addr_rd;
	
	case(stage)
		RST: begin
			X_d = 'b0;
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
				state_d = RUN;
			end else begin
				state_d = INIT;
				addr_rd_d = addr_rd + 1;
				shift_in = 
				shift_en = 
			end
		end 
		
		RUN: begin
			
		
			// increment counters
			if(x+STRIDE >= OUT_X) begin
				x_d = 0;
				if(y+STRIDE >= OUT_Y) begin
					state_d = DONE;
					done_d = 1'b1;
				end else begin
					y_d = y + STRIDE;
			end else begin
				x_d = x + STRIDE;
				y_d = y;
			end
		end
		
		DONE: begin
		
		end
		
	endcase
end

endmodule