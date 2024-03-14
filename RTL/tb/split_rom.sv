module split_rom #(
	parameter NUM_RAMS = 8,
	parameter RAM_DEPTH = 256,
	parameter RAM_WIDTH = 16,
	parameter string INIT_FILEPATH [0:NUM_RAMS-1] = '{default:""}
)(
	input clk,
	input rst,
	input [RAM_WIDTH-1:0] 			data_wr,
	input [NUM_RAMS-1:0]  			data_layer_wren,	//enable 
	input [$clog2(RAM_DEPTH)-1:0] addr,
	
	output logic [NUM_RAMS * RAM_WIDTH-1:0] data_rd
);

genvar i;
generate
	for (i = 0; i < NUM_RAMS; i = i + 1) begin : rams
		single_port_rom #(
			.DATA_WIDTH(RAM_WIDTH),
			.ADDR_WIDTH($clog2(RAM_DEPTH))
			.INIT_FILEPATH=""
		) rom (
			.data(data_wr),
			.addr(addr),
			.q(data_rd[RAM_WIDTH * i +: RAM_WIDTH])
		);
	end
endgenerate


endmodule