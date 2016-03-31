module IDEX(input clk, rst,
    input [22:0] wb, 
    input m,
    input [9:0] exe,
    input exec,
    input [15:0] pc_plus_1,
	input memread,
    input [15:0] dataa, datab,
    
    input [11:0] jumpaddr,
    input [3:0] imm_value,
    input [7:0] branchaddr, 
    
    /* stalls - edited by lihau 10/4 */
	input flush,
	input clear,
	input stall,
	
	//hazard - lihau 11/4
	input [3:0] hazardaddr,
	input hazard_ar, hazard_mem,
    
    input forward, forward1,
    
    input [15:0] inst,
    output reg [15:0] instreg,
    
    input memory,
    
    output reg memoryreg,
    
    /*
	output declaration    
    */
    output reg [22:0] wbreg, 
    output reg mreg,

//	split exe to 4 different output, ie. aluop, alusrc1, alusrc2, aluupdate instead of output to exereg	
    output reg [3:0] aluop,
    output reg alusrc1,
    output reg [1:0] alusrc2,
    output reg id_update,
    output reg jr,
    output reg pcload,
    output reg exec_out,
    output reg [15:0] pc_plus_1_out, 
    
    output reg [15:0] dataareg, databreg,
	output reg [11:0] jumpaddrreg,
    output reg [3:0] imm_valuereg,
    output reg [7:0] branchaddrreg,
    
	//hazard - lihau 11/4
	output reg [3:0] hazardaddrreg,
	output reg hazard_arreg, 
	output reg hazard_memreg,
	//added for shared memory
	output reg memread_reg,
	output reg flushreg,
	output reg forwardreg, forwardreg1 
    );

    always@(posedge clk) begin
		if (rst || clear) begin
			wbreg <= 0; 
			mreg <= 0; 

			aluop <= 0;
    		alusrc1 <= 0;
			alusrc2 <= 0;
			id_update <= 0;
			jr <= 0;
			pcload <= 0;
			
			pc_plus_1_out <= 0;//just added
			
			dataareg <= 0; 
			databreg <= 0; 
			exec_out<=0;
			jumpaddrreg <= 0;
			imm_valuereg <= 0; 
			branchaddrreg <= 0;
			
			//hazard - lihau 11/4
			hazardaddrreg <= 0;
			hazard_arreg <= 0;
			hazard_memreg <= 0;
			
			flushreg <= 0;
			
			forwardreg <= 0;
			forwardreg1 <= 0;
			memread_reg <= 0;
			
			instreg <= 0;
			memoryreg <= 0;
		end else begin
			instreg <= inst;
			if(stall)begin
				wbreg <= wbreg; 
				mreg <= mreg; 
				aluop <= aluop;
				alusrc1 <= alusrc1;
				alusrc2 <= alusrc2;
				id_update <= id_update;
				jr <= jr;
				pcload <= pcload;
				pc_plus_1_out <= pc_plus_1_out;
				dataareg <= dataareg; 
				databreg <= databreg; 
				jumpaddrreg <= jumpaddrreg;
				imm_valuereg <= imm_valuereg; 
				branchaddrreg <= branchaddrreg;
				exec_out <= exec_out;
				hazardaddrreg <= hazardaddrreg;
				hazard_arreg <= hazard_arreg;
				hazard_memreg <= hazard_memreg;
				flushreg <= flushreg;
				forwardreg <= forwardreg;		
				forwardreg1 <= forwardreg1;	
				memread_reg <= 0; //memread_reg;
				memoryreg <= memoryreg;
			end else begin
				wbreg <= wb; 
				mreg <= m; 
				
				memoryreg <= memory;
				
		//	split exe to 4 different output, ie. aluop, alusrc1, alusrc2, aluupdate instead of output to exereg	
				aluop <= exe[7:4];
				alusrc1 <= exe[3];
				alusrc2 <= exe[2:1];
				id_update <= exe[0];
				jr <= exe[8];
				pcload <= exe[9];
		
				pc_plus_1_out <= pc_plus_1;
		
				dataareg <= dataa; 
				databreg <= datab; 
		
				jumpaddrreg <= jumpaddr;
				imm_valuereg <= imm_value; 
				branchaddrreg <= branchaddr;
				exec_out <= exec;
		
				//hazard - lihau 11/4
				hazardaddrreg <= hazardaddr;
				hazard_arreg <= hazard_ar;
				hazard_memreg <= hazard_mem;
		
				flushreg <= flush;
		
				forwardreg <= forward;		
				forwardreg1 <= forward1;	
			
				//shared memory - Hongquan 14/4
				memread_reg <= memread;
			end
		end
    end 
endmodule
