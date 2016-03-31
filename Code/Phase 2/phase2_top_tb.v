`include "phase2_top.v"
`timescale 1ns / 10ps

module phase2_top_tb;

reg clk;
reg rst;
phase2_top phase1_top_tb(
	.clk(clk),
	.rst(rst)
);

// generate the clk
always #5 clk = ~clk;

initial
begin
	rst = 0;
	clk = 0;
	#20 rst = 1;
	#20 rst = 0;
	#7
#3000	$finish;
end

endmodule
