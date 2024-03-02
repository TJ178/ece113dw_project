module cnn
(
	input clk,
	input rst,
	input in,
	input in_valid,
	output out,
	output out_valid,
);

// user changable
localparam SAMPLE_BITS = 16;				// bits per value
localparam RAM_WIDTH_MULTIPLIER = 2;	// how many samples in 1 RAM read
localparam RAM_DEPTH = 16;					// total number of values in RAM

// do not edit
localparam RAM_WIDTH = SAMPLE_BITS*RAM_WIDTH_MULTIPLIER;


// PING PONG RAM

logic [RAM_WIDTH-1:0] ramA_data, ramB_data, ramA_q, ramB_q;
logic [$clog2(RAM_DEPTH)-1:0] ramA_addr, ramB_addr;
logic ramA_we, ramB_we;

single_port_ram 
#(
	.DATA_WIDTH(RAM_WIDTH),
	.ADDR_WIDTH(RAM_DEPTH)
)
ramA
(
	.data(ramA_data),
	.addr(ramA_addr),
	.we(ramA_we),
	.clk(clk),
	.q(ramA_q)
);

single_port_ram 
#(
	.DATA_WIDTH(RAM_WIDTH),
	.ADDR_WIDTH(RAM_DEPTH)
)
ramB
(
	.data(ramB_data),
	.addr(ramB_addr),
	.we(ramB_we),
	.clk(clk),
	.q(ramB_q)
);

// CONVOLUTIONAL LAYERS
logic [RAM_WIDTH-1:0] convA_data_wr;
logic [$clog2(RAM_DEPTH)-1:0] convA_addr_rd, convA_addr_wr;
logic convA_start, convA_we, convA_done;

convolution #(
	.K_SIZE(8),
	.INPUT_SIZE(128),
	.OUTPUT_SIZE(128),
	.BIT_WIDTH (SAMPLE_BITS),
	.RAM_DEPTH(RAM_DEPTH),
	.KERNEL_FILEPATH("")
)
convA
(
	.clk(clk),
	.rst(rst),
	.start(convA_start),
	.data_rd(ramA_q),
	.addr_rd(convA_addr_rd),
	.data_wr(convA_data_wr),
	.addr_wr(convA_addr_wr),
	.wren(convA_we),
	.done(convA_done)
);

logic [RAM_WIDTH-1:0] convB_data_wr;
logic [$clog2(RAM_DEPTH)-1:0] convB_addr_rd, convB_addr_wr;
logic convB_start, convB_we, convB_done;

convolution #(
	.K_SIZE(8),
	.INPUT_SIZE(128),
	.OUTPUT_SIZE(128),
	.BIT_WIDTH (SAMPLE_BITS),
	.RAM_DEPTH(RAM_DEPTH),
	.KERNEL_FILEPATH("")
)
convB
(
	.clk(clk),
	.rst(rst),
	.start(convB_start),
	.data_rd(ramA_q),
	.addr_rd(convB_addr_rd),
	.data_wr(convB_data_wr),
	.addr_wr(convB_addr_wr),
	.wren(convB_we),
	.done(convB_done)
);


// CONTROLLER LOGIC
localparam NUM_STATES = 4;
localparam RST = 0;
localparam CONV_A = 1;
localparam POOL_A = 2;
localparam CONV_B = 3;
localparam POOL_B = 4;
localparam FULLY_CONNECTED = 5;


logic [$clog2(NUM_STATES)-1:0] state, state_d;

always_ff @ (posedge clk) begin
	if(rst) begin
		state <= 'b0;
	end else begin
		state <= state_d;
	end
end

always_comb begin
	state_d = 'b0;
end


endmodule