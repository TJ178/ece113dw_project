module pooling_tb();

logic clk, rst;

localparam NUM_RAMS = 7;
localparam RAM_DEPTH = 256;
localparam RAM_WIDTH = 16;


split_rom #(
	.NUM_RAMS(7),
	.RAM_DEPTH(256),
	.RAM_WIDTH(16),
	.INIT_FILEPATH('{default:""})
)(
	.clk(clk),
	.rst(rst),
	.data_wr(),
	.data_layer_wren(),
	.addr(rom_addr),
	.data_rd(rom_data_rd)
	input [RAM_WIDTH-1:0] 			data_wr,
	input [NUM_RAMS-1:0]  			data_layer_wren,	//enable 
	input [$clog2(RAM_DEPTH)-1:0] addr,
	
	output logic [NUM_RAMS * RAM_WIDTH-1:0] data_rd
);

logic [SAMPLE_BITS * RAM_SPLIT-1:0] pool_data_wr;
logic [$clog2(RAM_DEPTH)-1:0] pool_addr_rd, pool_addr_wr;
logic pool_start, pool_we, pool_done;

pooling_layer #(
	.INPUT_X(POOLA_INPUT_X),
	.INPUT_Y(POOLA_INPUT_Y),
	.POOL_SIZE(POOLA_SIZE),
	.STRIDE(POOLA_SIZE),
	.BIT_WIDTH(SAMPLE_BITS),
	.NUM_RAM_SPLITS(RAM_SPLIT)
)
poolA
(
	.clk(clk),
	.rst(rst),
	.start(pool_start),
	.data_rd(rom_data_rd),
	.addr_rd(rom_addr),
	.addr_wr(ram_addr_wr),
	.wren(ram_wren),
	.done(pool_done)
);



always begin
	#1;
	clk = ~clk;
end

initial begin
	rst = 1'b0;
	#5;
	rst = 1'b1;
	#5;
	rst = 1'b0;
	
	while(~pool_done) begin
		#1;
	end
	
	$stop;
end

endmodule