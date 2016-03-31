// Register File module
`include "define.v"
`timescale 1ns / 1ps

module regfile (
	clk,
	rst,
	wen,
	raddr1, 
	raddr2, 
	waddr, 
	wdata, 

	rdata1,
	rdata2,
	
	//for R15 JAL instructions
	r15,
	r15out,
	r15enable
	);

        parameter DSIZE=16;
        parameter NREG=16;
        localparam RSIZE=4;
input clk;
	input rst;
	input wen;
	input [RSIZE-1:0] raddr1;
	input [RSIZE-1:0] raddr2;
	input [RSIZE-1:0] waddr; 
	input [DSIZE-1:0] wdata; 
	input [DSIZE-1:0] r15;
	input r15enable;

	output [DSIZE-1:0] rdata1;
	output [DSIZE-1:0] rdata2;
	output [DSIZE-1:0] r15out;
	
	reg [DSIZE-1:0] regdata [0:NREG-1];

	always@(posedge clk)
		begin
			if(rst)
			begin
				regdata[0] <=0;
				regdata[1] <=0;
				regdata[2] <=0;
				regdata[3] <=0;
				regdata[4] <=0;
				regdata[5] <=0;
				regdata[6] <=0;
				regdata[7] <=0;
				regdata[8] <=0;
				regdata[9] <=0;
				regdata[10] <=0;
				regdata[11] <=0;
				regdata[12] <=0;
				regdata[13] <=0;
				regdata[14] <=0;
				regdata[15] <=0;
			end
			else
			begin
				//write enable, waddr not 0, and not 15, regdata[waddr] = wdata
				regdata[waddr] <= ((wen == 1) && (waddr != 0) && (waddr != 15)) ? wdata : regdata[waddr];
				//when r15enable, write into regdata[15]
				if(r15enable)
				begin
					regdata[15] <= r15;
				end
			end
		end
	
	assign rdata1 = ((wen) && (waddr == raddr1) && (waddr != 0)) ? wdata : regdata[raddr1];
	assign rdata2 = ((wen) && (waddr == raddr2) && (waddr != 0)) ? wdata : regdata[raddr2];
	assign r15out = regdata[15];
endmodule 
