`include "define.v"

module HazardUnit(
	input rst,
	input [3:0] id_rdata1, id_rdata2,
	
	input [15:0] instruction,	//opcode of instruction in decode stage
	input id_exe,
	input id_pc_load,
	
	//ar type instruction:
	//ADD, SUB, AND, OR, SLL, SRL, SRA, RL, LHB, LLB
	//mem type instruction:
	//LW
	
	input ex_ar_inst,  	//execute stage is ar type instruction
	input ex_mem_inst,	//execute stage is mem type instruction
	input mem_ar_inst,	//mem stage is ar type instruction
	input mem_mem_inst,	//mem stage is mem type instruction
	
	input [3:0] ex_waddr,	//execute stage write address
	input [3:0] mem_waddr,	//mem stage write address
	
	//stall
	input inst_ready, data_ready, ready, data_read,
	
	output reg ar, mem,		//
	
	output reg exe_to_dec1, exe_to_dec2, //exe to decode data out
	output reg mem_to_dec1, mem_to_dec2,	//mem to decode data out
	output reg mem_to_exe1, mem_to_exe2, 	//mem to exe alu data in
	
	output flush,
	output inst_stall,
	output data_stall,
	output reg exec_stall
	);

	wire type1, type2;

	wire [3:0] opcode = instruction[15:12];

	//instruction 0000 is noop, shoudn't output anything if is noop
	wire noop = instruction[15] | instruction[14] | instruction[13] | instruction[12] | 
              instruction[11] | instruction[10] | instruction[9] | instruction[8] | 
              instruction[7] | instruction[6] | instruction[5] | instruction[4] | 
              instruction[3] | instruction[2] | instruction[1] | instruction[0] ;
	
	//JR
	
	assign type1 = (opcode == `ADD) || (opcode == `SUB) || (opcode == `AND) || 
					(opcode == `OR) || (opcode == `SW);
	assign type2 = (opcode == `SLL) || (opcode == `SRL) || (opcode == `SRA) || 
				(opcode == `RL) || (opcode == `LW) || (opcode == `LHB) || 
				(opcode == `LLB);
	assign type3 = (opcode == `JR) || (opcode == `EXEC);
	
	//by lihau 10/4
	//hazard detection and forwarding
	//haven't tested
	
	reg reading;
	
	always @*
	begin
		if(rst || ~noop)begin
			exe_to_dec1 = 0;
			exe_to_dec2 = 0;
			mem_to_dec1 = 0;
			mem_to_dec2 = 0;
			mem_to_exe1 = 0;
			mem_to_exe2 = 0;
			ar = 0;
			mem = 0;
			exec_stall = 0;
			if(rst)
				reading = 0;
		end else begin
			//default = 0, no forwarding
			exe_to_dec1 = 0;
			exe_to_dec2 = 0;
			mem_to_dec1 = 0;
			mem_to_dec2 = 0;
			mem_to_exe1 = 0;
			mem_to_exe2 = 0;
			exec_stall = 0;
			
			if(data_read)
				reading = 1;
			
			if(reading && data_ready) begin
				reading = 0;
			end
			
			//no flush, no stall		
			if(ex_ar_inst)begin
				//if execute stage is ar type instruction
				if(type1) begin 	//[7:4] Rs
					if(id_rdata1 == ex_waddr)
						exe_to_dec1 = 1;
					if(id_rdata2 == ex_waddr)
						exe_to_dec2 = 1;
				end else if(type2) begin
					if(id_rdata1 == ex_waddr)
						exe_to_dec1 = 1;
				end else if(type3) begin
					if(id_rdata2 == ex_waddr)
						exe_to_dec2 = 1;
				end
			end else if(ex_mem_inst)begin
				//LW in execute stage
				if(type1) begin 	//[7:4] Rs
					if(id_rdata1 == ex_waddr)
						mem_to_exe1 = 1;
					if(id_rdata2 == ex_waddr)
						mem_to_exe2 = 1;				
				end else if(type2) begin
					if(id_rdata1 == ex_waddr)
						mem_to_exe1 = 1;
				end else if(type3) begin
					if(id_rdata2 == ex_waddr)
						exec_stall = 1;
				end
			end
					
			if(mem_mem_inst || mem_ar_inst)begin
				if(type1) begin 	//[7:4] Rs
					if(id_rdata1 == mem_waddr)
						mem_to_dec1 = 1;
					if(id_rdata2 == mem_waddr)
						mem_to_dec2 = 1;
				end else if(type2) begin					
					if(id_rdata1 == mem_waddr)
						mem_to_dec1 = 1;
				end else if(type3) begin
					if(id_rdata2 == mem_waddr)
						mem_to_dec2 = 1;
				end
			end
			
			ar = (opcode == `ADD) || (opcode == `SUB) || (opcode == `AND) || (opcode == `OR) || 
				(opcode == `SLL) || (opcode == `SRL) || (opcode == `SRA) || (opcode == `RL) || 
				(opcode == `LHB) || (opcode == `LLB);
				
 		   mem = (opcode == `LW);
 		   
		end
	end
  
  	assign flush = id_exe | id_pc_load;

	assign inst_stall = ~inst_ready;
	assign data_stall = ~data_ready & data_read;

endmodule