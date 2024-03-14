module maxpool_kernel #(
	parameter SIZE = 3,
	parameter BIT_WIDTH = 12
)
(
input 	[BIT_WIDTH-1:0] in 	[0:SIZE*SIZE-1],
output 	[BIT_WIDTH-1:0]	out
);

logic [BIT_WIDTH-1:0] max;

always_comb begin
	max = in[0];
	for (int i = 1; i < SIZE*SIZE; i = i + 1) begin
		if(max > in[i]) begin
			max = in[i];
		end
	end
	out = max;
end


endmodule