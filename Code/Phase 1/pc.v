//PC Module
//pc outputs current address + 1, or the branch address
`include "define.v"

module pc(clk, rst, pc_in, pc_out);
    input clk;
	input rst;
    input [15:0] pc_in;
    output reg [15:0] pc_out;
  	
	always@(posedge clk) begin
		if (rst)
			pc_out <= 16'hffff;
		else
		begin
			pc_out <= pc_in;
		end
	end	

endmodule
