`timescale 1ns/1ns

module capstone_tb();

logic rst = 1'b0;
logic clk = 1'b0;
logic ledOut;

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
end

capstone c(clk, rst, ledOut);

endmodule