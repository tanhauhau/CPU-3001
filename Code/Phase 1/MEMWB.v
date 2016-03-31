module MEMWB(input clk, rst,
		   input [22:0] wb,

		   input [15:0] aluout,
//		   input [15:0] memout,
			
			/* stalls - edited by lihau 10/4 */
			//hazard - lihau 11/4
			input [3:0] hazardaddr,
			input hazard_ar,
			input hazard_mem, 

		   output reg [15:0] r15,
		   output reg r15en,
		   output reg [3:0] waddr,
		   output reg wen,
		   output reg memtoreg,

		   output reg [15:0] aluoutreg,
//		   output reg [15:0] memoutreg,
		   
		   	//hazard - lihau 11/4
			output reg [3:0] hazardaddrreg,
			output reg hazard_arreg, 
			output reg hazard_memreg
		   );

    always@(posedge clk) 
    begin 
    	if(rst)begin
			r15 <= 0;
			r15en <= 0;
			waddr <= 0;

			wen <= 0;
			memtoreg <= 0;
			aluoutreg <= 0;
//			memoutreg <= 0;
			//exec 11/4
//			execreg <= 0;
			
			//hazard - lihau 11/4
			hazardaddrreg <= 0;
			hazard_arreg <= 0;
			hazard_memreg <= 0;
    	end
    	else begin
//    		if(!stall) begin
				// r15 <= wb[38:23];
				// r15en <= wb[22];
				// waddr <= wb[21:18];
				// wdata <= wb[17:2];
				r15 <= wb[22:7];
				r15en <= wb[6];
				waddr <= wb[5:2];
				wen <= wb[1];
				memtoreg <= wb[0];

//				memoutreg <= memout;
				aluoutreg <= aluout;
/*			end else begin
				r15 <= r15;
				r15en <= r15en;
				waddr <= waddr;
				wen <= wen;
				memtoreg <= memtoreg;

				aluoutreg <= aluoutreg;
			end*/
//			execreg <= exec;
			
			//hazard - lihau 11/4
			hazardaddrreg <= hazardaddr;
			hazard_arreg <= hazard_ar;
			hazard_memreg <= hazard_mem;
    	end
    end 
endmodule
