module pooling_layer #(
	parameter INPUT_SIZE = 128,
	parameter POOL_SIZE = 4,
	parameter STRIDE = 2,
	parameter BIT_WIDTH = 16,
)
(
	input clk,
	input rst,
	input start,
	input [BIT_WIDTH-1:0] 							data_rd,
	output [$clog2(INPUT_SIZE/BIT_WIDTH)-1:0] addr_rd,
	output [BIT_WIDTH-1:0] 							data_wr,
	output [$clog2(INPUT_SIZE/BIT_WIDTH)-1:0] addr_wr,
	output wren,
	output done
);

endmodule