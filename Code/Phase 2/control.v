`include "define.v"

module control(
				rst,
				inst,
				opcode, //instruction,
				cond, 	//branch condition
				flag, 	//zero, overflow, negative
				//muxout, //
				exec_in,
				stall, 
				aluop, 	//to alu
				alusrc1,	//set to 1 when need pc as input, 
				alusrc2, //4_1 mux
				regdst1, //set to be 1 when LLB, LHB
				regdst2, //control the raddr2,
						//set to 0 to select [3:0] for arithmetic instruction
						//set to 1 to select [11:8] for SW, JR
				memtoreg, //set to 0 for selecting ALU result,
						  //set to 1 for memory data, eg. LW
				regwrite, //set 1 to R-type, LW, LLB, LHB
				memread,	//set 1 to LW
				memwrite,	//active low!!! set to one at beginning
				branch,		//set 1 to B-instruction, depending on the condition code
							// and the flag
//				jal, 		//set 1 for JAL and JR
				jr, 		//set 1 for jr
				r15enable, //set 1 for JAL, EXEC 
				pc_load,
				flag_update,
				exe,
				memory
				); 
   input rst;
   input [15:0] inst;
   input [3:0] opcode;
//   input [3:0] opcode; 
   input [2:0] cond;
   input [2:0] flag;
   input exec_in;
   input stall;
//   output reg [10:0] muxout; 
   output reg [3:0] aluop;
   output reg [1:0] alusrc2; //rdata2,[3:0],[7:0],[11:0]
   output reg alusrc1, regdst1, regdst2, memtoreg, regwrite, memwrite,  jr, r15enable, pc_load, flag_update , branch;
   output reg exe;
   output reg memread;
   output reg memory;
   //jal,
   	
   	reg noop;
   	
//   	reg branch;
	
	reg nreg, oreg, zreg;
	
   	wire n = noop ? nreg : flag[0];
   	wire o = noop ? oreg : flag[1];
   	wire z = noop ? zreg : flag[2];
   	
	always @* begin
	if(rst) begin
		noop = 0;
		alusrc1=0;
		alusrc2=0;
		regdst1=0;
		regdst2=0;
		memtoreg=0;
		regwrite=0;
		memwrite=0; //active low!!! remember to set to one before getting memory!!
		branch=0;
		//jal=0; 
		jr=0; 
		r15enable=0;
		aluop=0; 
		pc_load=0;
		flag_update=0;
		exe = 0;
		memread = 0;
		
		
		nreg = 0;
		oreg = 0;
		zreg = 0;
		
		memory = 0;
		end 
	else begin
		noop = inst == 0;
		if(~noop) begin
			nreg = n;
			oreg = o;
			zreg = z;
		end
			

//		if(~noop) begin
			alusrc1=0;
			alusrc2=0;
			regdst1=0;
			regdst2=0;
			memtoreg=0;
			regwrite=0;
			memwrite=0;//active low!!! set to one at beginning
			branch=0;
			//jal=0; 
			jr=0; 
			r15enable=0;
			aluop=0; 
			pc_load=0;
			flag_update=0;
			exe = 0;
			memread = 0;
			memory = 0;
		if (!opcode[3]) //R-type
		begin
			 flag_update = 1;//ONLY R-TYPE may update the flag
			 regwrite = 1;
			 aluop = opcode;
			 alusrc1 = 0;
			 alusrc2 = 0;
		 end
		 else begin  
		 case(opcode)
			   `LW:begin
				 alusrc2 = 2'b01;			 
				 memtoreg = 1;
				 memread = 1;
				 regwrite = 1;
				 aluop = `ADD;
				 memory = 1;
			   end
			   `SW:begin
				 regdst2 = 1;//set to 1 to select [11:8] for SW, JR
				 alusrc2 = 2'b01;
				 memwrite = 1;
				 aluop = `ADD;
				 memory = 1;
			   end
			   `LHB:begin
				 aluop = `LHB;
				 regwrite = 1;
				 regdst1 = 1;
				 alusrc2 = 2'b10;
			   end
			   `LLB:begin
				 aluop = `LLB;
				 regwrite = 1;
				 regdst1 = 1;
				 alusrc2 = 2'b10;
			   end
			   `BR:begin
			   
// 				wire n = flag[0];
// 				wire o = flag[1];
//				wire z = flag[2];
				
				 case (cond)
				 `EQ : branch = (z)? 1 : 0; 
				 `NE : branch = (z)? 0 : 1;
				 `GT : branch = ((z || n))? 0 : 1;
				 `LT : branch = (n)? 1 : 0;
				 `GEQ: branch = (z|| !(z || n))? 1 : 0;
				 `LEQ: branch = (z || n)? 1 : 0;
				 `O  : branch = (o)? 1 : 0;
				 `T  : branch = 1;
				 default: branch = 0;
			   endcase
				 if (branch) begin
					// aluop = `ADD;
					// alusrc1 = 1;//use pc as an operand
					// alusrc2 = 2'b10;
		//			pc_load = !exec_register;
					pc_load = !exec_in;
					jr = 0;
				 end
			   end
			   `JAL:begin
					// aluop = `ADD;
					//jal = 1;
					r15enable = 1;
					// alusrc1 = 1;//use pc as an operand
					// alusrc2 = 2'b11;
		//			pc_load = !exec_register;
					pc_load = !exec_in;
					branch = 0;
					jr = 0;
			   end
			   `JR:begin
					jr = 1;
		//			pc_load = !exec_register;
					pc_load = !exec_in;
					regdst2 = 1;
			   end
			   `EXEC:begin
					exe = stall? 0 : 1;
					jr = 1;
		//			pc_load = !exec_register;
					pc_load = !exec_in;
					regdst2 = 1;
					r15enable = 1;
			   end
			 endcase
		//	 if (exec_register = 1)
		//	 exec_register = exe;
		 
		end
		end
	end
//	end
endmodule

