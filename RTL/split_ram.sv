module split_ram #(
	parameter NUM_RAMS = 8,
	parameter RAM_DEPTH = 256,
	parameter RAM_WIDTH = 16
)(
	input clk,
	input rst,
	input [RAM_WIDTH-1:0] 			data_wr,
	input [NUM_RAMS-1:0]  			data_layer_wren,	//enable 
	input [$clog2(RAM_DEPTH)-1:0] addr,
	
	output logic [NUM_RAMS * RAM_WIDTH-1:0] data_rd
);

genvar i;
generate begin
	for (i = 0; i < NUM_RAMS; i = i + 1) begin : rams
		single_port_ram #(
			.DATA_WIDTH(RAM_WIDTH),
			.ADDR_WIDTH($clog2(RAM_DEPTH))
		) ram (
			.data(data_wr),
			.addr(addr),
			.we(data_layer_wren[i]),
			.q(data_rd[RAM_WIDTH * i +: RAM_WIDTH])
		)
	end
endgenerate


endmodule