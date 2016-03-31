//PC Module
//pc outputs current address + 1, or the branch address
`include "define.v"

module pc(clk, rst, stall, exec, pc_in, pc_out);
    input clk;
	input rst;
	input stall;
	input exec;
    input [15:0] pc_in;
    output [15:0] pc_out;
  	
  	reg [15:0] pc_temp;
  	
  	reg [15:0] pc_out_reg;
  	reg exe, exea;
  	reg [15:0] pc_exec;
  	
	always@(posedge clk) begin
		if (rst) begin
			pc_out_reg <= 16'hffff;
			pc_temp <= 16'hffff;
			exe <= 0;
		end else
		begin
			if(exec) begin
				exe <= 1;
				pc_exec <= pc_in;//------- + 1;
			end
			if(!stall) begin
				if(exe) begin
					pc_out_reg <= pc_exec;
					pc_temp <= pc_exec;
					exe <= 0;
				end else begin
					pc_out_reg <= pc_in;
					pc_temp <= pc_in;
				end
			end else begin
				pc_out_reg <= pc_temp;
			end
		end
	end	
	
	assign pc_out = pc_out_reg;

endmodule
