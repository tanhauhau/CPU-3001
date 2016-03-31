module IFID(input rst, clk,
	
			input [15:0] PC_Plus1,
			input [15:0]Inst,
	
			input exec,
	
			/* stalls - edited by lihau 10/4 */
			//for hazard detection
			input stall,
	
			output reg [15:0]InstReg, 
			output reg[15:0]PC_Plus1Reg,
 
			output reg execout,
			output reg stallreg);

    reg [15:0] pc_temp_reg;
    reg [15:0] inst_temp_reg;
    
    always@(posedge clk) 
    begin 
        if(rst) 
        begin 
           inst_temp_reg <= 0; 
           PC_Plus1Reg <=0;
           pc_temp_reg <= 0; 
           execout <= 0;
           stallreg <= 0;
        end else begin
        	if(!stall)begin
			   PC_Plus1Reg <= PC_Plus1; 
 			   pc_temp_reg <= PC_Plus1;
 			   inst_temp_reg <= Inst;
			   InstReg = Inst;
			   execout <= exec;
		   end else begin
		    	// stalls - edited by lihau 10/4
		       InstReg <= inst_temp_reg; 
			   PC_Plus1Reg <= pc_temp_reg;
		   end
		   stallreg <= stall;
        end
    end 
endmodule 
