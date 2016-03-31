module MEMWB(input clk, rst,
		   input [22:0] wb,

		   input [15:0] aluout,
//		   input [15:0] memout,
			
			input memory,
			/* stalls - edited by lihau 10/4 */
			//hazard - lihau 11/4
			input [3:0] hazardaddr,
			input hazard_ar,
			input hazard_mem, 

			input read, input read_ready,
	
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

	reg readreg;
	reg wenreg;
	
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
			
			readreg <= 0;
    	end
    	else begin
    		
    		if(read) begin
    			readreg <= 1;
    			wenreg <= wen;
    			wen <= 1;
    		end
//     		if(!memory) begin
//     			//not accessing memory
// 				r15 <= wb[22:7];
// 				r15en <= wb[6];
// 				waddr <= wb[5:2];
// 				wen <= wb[1];
// 				memtoreg <= wb[0];
// 				aluoutreg <= aluout;
// 				
// 				//hazard - lihau 11/4
// 				hazardaddrreg <= hazardaddr;
// 				hazard_arreg <= hazard_ar;
// 				hazard_memreg <= hazard_mem;
//     		end else 
    		if(readreg && read_ready) begin
    			readreg <= 0;
    			r15 <= wb[22:7];
				r15en <= wb[6];
				waddr <= wb[5:2];
				wen <= wb[1];
				memtoreg <= wb[0];
				aluoutreg <= aluout;
				
				//hazard - lihau 11/4
				hazardaddrreg <= hazardaddr;
				hazard_arreg <= hazard_ar;
				hazard_memreg <= hazard_mem;
    		end else if(readreg)begin
    			r15 <= r15;
    			r15en <= r15en;
    			waddr <= waddr;
    			
    			memtoreg <= memtoreg;
    			aluoutreg <= aluoutreg;

				hazardaddrreg <= hazardaddrreg;
				hazard_arreg <= hazard_arreg;
				hazard_memreg <= hazard_memreg;
    		end else begin
				r15 <= wb[22:7];
				r15en <= wb[6];
				waddr <= wb[5:2];
				wen <= wb[1];
				memtoreg <= wb[0];
				aluoutreg <= aluout;
				
				//hazard - lihau 11/4
				hazardaddrreg <= hazardaddr;
				hazard_arreg <= hazard_ar;
				hazard_memreg <= hazard_mem;
			end
    	end
    end 
    
    always @* begin
    	wen = readreg && read_ready;
    end
endmodule
