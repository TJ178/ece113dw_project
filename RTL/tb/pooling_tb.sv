module pooling_tb();

logic clk, rst;

localparam NUM_RAMS = 7;
localparam RAM_DEPTH = 256;
localparam RAM_WIDTH = 16;

localparam POOLA_INPUT_X = 256;
localparam POOLA_INPUT_Y = 40;
localparam POOLA_SIZE = 7;

localparam ROM_FILE = {"pooling_rom0.mem", "pooling_rom1.mem", "pooling_rom2.mem", "pooling_rom3mem", "pooling_rom4.mem", "pooling_rom5.mem", "pooling_rom6.mem", "pooling_rom7.mem"};


split_rom #(
	.NUM_RAMS(NUM_RAMS),
	.RAM_DEPTH(RAM_DEPTH),
	.RAM_WIDTH(RAM_WIDTH),
	.INIT_FILEPATH('{default:""})
)rom(
	.clk(clk),
	.rst(rst),
	.data_wr(),
	.data_layer_wren(),
	.addr(rom_addr),
	.data_rd(rom_data_rd)
);

split_ram #(
	.NUM_RAMS(NUM_RAMS),
	.RAM_DEPTH(RAM_DEPTH),
	.RAM_WIDTH(RAM_WIDTH)
)ram(
	.clk(clk),
	.rst(rst),
	.data_wr(ram_data_wr),
	.data_layer_wren(ram_wren),
	.addr(ram_addr),
	.data_rd(ram_rd)
);

logic [RAM_WIDTH * NUM_RAMS-1:0] pool_data_wr;
logic [$clog2(RAM_DEPTH)-1:0] pool_addr_rd, pool_addr_wr;
logic pool_start, pool_we, pool_done;

pooling_layer #(
	.INPUT_X(POOLA_INPUT_X),
	.INPUT_Y(POOLA_INPUT_Y),
	.POOL_SIZE(POOLA_SIZE),
	.STRIDE(POOLA_SIZE),
	.BIT_WIDTH(RAM_WIDTH),
	.NUM_RAM_SPLITS(NUM_RAMS)
)
poolA
(
	.clk(clk),
	.rst(rst),
	.start(pool_start),
	.data_rd(rom_data_rd),
	.addr_rd(rom_addr),
	.addr_wr(ram_addr),
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