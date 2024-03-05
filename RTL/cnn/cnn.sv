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
localparam SAMPLE_BITS 						= 16; // bits per value
localparam RAM_WIDTH_MULTIPLIER 			= 2;	// how many samples in 1 RAM read

localparam MEL_SPECTRUM_BANDS 			= 40;
localparam NUM_WINDOWS 						= 0;	//TODO need to calculate

localparam CONVA_KERNEL_FILEPATH 		= "";
localparam CONVA_KERNEL_SIZE 				= 7;

localparam POOLA_SIZE 						= 3;

localparam CONVB_KERNEL_FILEPATH 		= "";
localparam CONVB_KERNEL_SIZE 				= 5;

localparam FULLY_CONNECTED_FILEPATH 	= "";
localparam FULLY_CONNECTED_SIZE 			= 0; 	//TODO NEED TO CALCULATE

// do not edit
localparam CONVA_INPUT_X 					= MEL_SPECTRUM_BANDS;
localparam CONVA_INPUT_Y					= NUM_WINDOWS;

localparam POOLA_INPUT_X					= MEL_SPECTRUM_BANDS;
localparam POOLA_INPUT_Y					= NUM_WINDOWS;

localparam CONVB_INPUT_X 					= POOLA_INPUT_X / POOLA_SIZE;
localparam CONVB_INPUT_Y 					= POOLA_INPUT_Y / POOLA_SIZE;

localparam FULLY_CONNECTED_INPUT_X 		= CONVB_INPUT_X;
localparam FULLY_CONNECTED_INPUT_Y 		= CONVB_INPUT_Y;

localparam RAM_WIDTH 						= SAMPLE_BITS*RAM_WIDTH_MULTIPLIER;
localparam RAM_DEPTH							= CONVA_INPUT_SIZE / RAM_WIDTH_MULTIPLIER;

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

// CONVOLUTION LAYER 1
logic [RAM_WIDTH-1:0] convA_data_wr;
logic [$clog2(RAM_DEPTH)-1:0] convA_addr_rd, convA_addr_wr;
logic convA_start, convA_we, convA_done;

convolution #(
	.K_SIZE(CONVA_KERNEL_SIZE),
	.INPUT_X(CONVA_INPUT_X),
	.INPUT_Y(CONVA_INPUT_Y),
	.BIT_WIDTH (SAMPLE_BITS),
	.RAM_DEPTH(RAM_DEPTH),
	.RAM_WIDTH_MULTIPLIER(RAM_WIDTH_MULTIPLIER),
	.KERNEL_FILEPATH(CONVA_KERNEL_FILEPATH)
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

// POOL LAYER
logic [RAM_WIDTH-1:0] pool_data_wr;
logic [$clog2(RAM_DEPTH)-1:0] pool_addr_rd, pool_addr_wr;
logic pool_start, pool_we, pool_done;

pooling_layer #(
	.INPUT_X(POOLA_INPUT_X),
	.INPUT_Y(POOLA_INPUT_Y),
	.POOL_SIZE(POOLA_SIZE),
	.STRIDE(POOLA_SIZE),
	.BIT_WIDTH(SAMPLE_BITS),
	.RAM_WIDTH_MULTIPLIER(RAM_WIDTH_MULTIPLIER),
)
poolA
(
	.clk(clk),
	.rst(rst),
	.start(pool_start),
	.data_rd(ramB_q),
	.addr_rd(pool_addr_rd),
	.addr_wr(pool_addr_wr),
	.wren(pool_we),
	.done(pool_done)
);


// CONVOLUTION LAYER 2
logic [RAM_WIDTH-1:0] convB_data_wr;
logic [$clog2(RAM_DEPTH)-1:0] convB_addr_rd, convB_addr_wr;
logic convB_start, convB_we, convB_done;

convolution #(
	.K_SIZE(CONVB_KERNEL_SIZE),
	.INPUT_SIZE(CONVB_INPUT_SIZE),
	.BIT_WIDTH (SAMPLE_BITS),
	.RAM_DEPTH(RAM_DEPTH),
	.KERNEL_FILEPATH(CONVB_KERNEL_FILEPATH),
	.RAM_WIDTH_MULTIPLIER(RAM_WIDTH_MULTIPLIER)
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
localparam NUM_STATES = 7;
localparam RST = 0;
localparam CONV_A = 1;
localparam POOL_A = 2;
localparam CONV_B = 3;
localparam FULLY_CONNECTED = 4;
localparam CLASSIFICATION = 5;
localparam DONE = 6;


logic [$clog2(NUM_STATES)-1:0] state, state_d;

always_ff @ (posedge clk) begin
	if(rst) begin
		state <= 'b0;
	end else begin
		state <= state_d;
	end
end

always_comb begin
	case(state)
		RST: begin
		
		end
		default: begin
		
		end
	
	endcase
end


endmodule