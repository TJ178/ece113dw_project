module convolution #(
	parameter K_SIZE = 8,
	parameter INPUT_SIZE = 128,
	parameter OUTPUT_SIZE = 128,
	parameter BIT_WIDTH = 16,
	parameter RAM_DEPTH = 16,
	parameter KERNEL_FILEPATH = ""
)
(
	input clk,
	input rst,
	input start,
	input [BIT_WIDTH-1:0] 							data_rd,
	output logic [$clog2(RAM_DEPTH)-1:0] addr_rd,
	output logic [BIT_WIDTH-1:0] 							data_wr,
	output logic [$clog2(RAM_DEPTH)-1:0] addr_wr,
	output logic wren,
	output logic done
);

localparam ZERO_PADDING


single_port_rom
#(
	.DATA_WIDTH(SAMPLE_BITS),
	.ADDR_WIDTH($clog2(KERNEL_SIZE)),
	.INIT_FILEPATH(KERNEL_FILEPATH)
) kernel_rom (
	.addr(kernel_rom_addr),
	.clk(clk),
	.q(kernel_out)
);


endmodule