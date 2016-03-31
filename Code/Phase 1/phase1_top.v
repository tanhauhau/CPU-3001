`include "define.v"
`include "alu.v"
`include "regfile.v"
//`include "D_memory.v"
//`include "I_memory.v"
`include "pc.v"

`include "mul2_1_4bit.v"
`include "mul3_1_16bit.v"
//`include "hazard_unit.v"
//`include "forwarding_unit.v"

module phase1_top(clk, rst);

//here, you should instantiate and connect your PC, ALU, control, imemory, dmemory
//depending on your group organization, you may use more or fewer sub-modules, but 
//you may not make *any* modifications to the given modules. During the demo, you
//may be asked to download fresh copies of the given files to verify that you dID_
//not make changes to those files in order to get your design working.
    input clk; 
    input rst;
    
    /* IF stage */
    wire [15:0] pc_to_memory;
    wire [15:0] pc_plus_one;
    wire [15:0] memory_to_ifid;
    wire [15:0] pc_in;
    
    /* ID stage */ 
    wire [15:0] ifid_instruction;
    wire [15:0] ifid_instruction_before_flush;
    wire [15:0] rdata1_to_idex;
    wire [15:0] rdata2_to_idex;
    wire [15:0] pc_plus_one_id_stage;
	wire [15:0] id_r15out;
    wire [3:0] mul_to_raddr1, mul_to_raddr2;
	wire [15:0] add_out;
	wire [15:0] add_input_1;
	wire [15:0] add_input_2;
	wire [15:0] jump_out;
	wire [15:0] id_branch_extend;
	wire [15:0] id_jal_extend;
	wire [15:0] jr_mux_out;
	wire id_exec_reg;
	
	wire id_regdst1, id_regdst2;
    //WB
	wire id_regwrite;
	//M
	wire id_memtoreg, id_memwrite;
	wire id_branch, id_jump, id_jr, id_r15enable;
	//EXE
	wire [3:0] id_aluop;
	wire id_alusrc1;
	wire[1:0] id_alusrc2;
	wire id_update;
	
	/* EXE stage */ 
    wire [15:0] exe_rdata1;
    wire [15:0] exe_rdata2;
    
    wire [3:0] exe_aluop;
    wire exe_alusrc1;
    wire exe_update;
    wire exe_jr;
    wire exe_pcload;
    wire [1:0] exe_alusrc2;
    
	wire exe_m;
	wire [22:0] exe_wb;
	
    wire [15:0] pc_plus_one_exe_stage;
    
	wire [3:0] exe_imm;
	wire [15:0] exe_imm_extend;
	wire [2:0] exe_flagout;
	wire [15:0] exe_aluout;
	
	wire [15:0] exe_mux1_out;
	wire [15:0] exe_mux2_out;
	
	wire [7:0] exe_branch;
	wire [15:0] exe_branch_extend;
	wire [11:0] exe_jump;
	wire [15:0] exe_jump_extend;
	wire [15:0] exe_jump_out;
	//wire [15:0] exe_pc_adder_out;
	wire [15:0] exe_pc_plus_1_out;
	//wire [15:0] exe_branch_pc;
	wire exe_exec_reg;
	
	/* MEM stage */ 
//	wire [3:0] mem_m;
	wire [22:0] mem_wb;
	wire [15:0] pc_mem_stage;
	wire mem_write;
	wire [15:0] mem_aluout;
	wire [15:0] mem_writedata;
	wire [15:0] mem_dataout;
	wire [15:0] mem_dataout_to_memwb;
	wire [15:0] mem_dataout_before_flush;
//	wire mem_exec_reg;
	
	/* WB stage */
	wire wb_pcload;
	wire [15:0] wb_r15;
	wire wb_r15en;
	wire [3:0] wb_waddr;
	wire [15:0] wb_wdata;
	wire wb_wen;
	wire wb_mem_to_reg;
	
	wire [15:0] wb_aluout, wb_writedata;
	
	//hazards - lihau 11/4
	wire [3:0] hazard_exe_waddr, hazard_mem_waddr;
	wire hazard_exe_ar, hazard_exe_mem, hazard_mem_ar, hazard_mem_mem;
	
	wire stall_hazard;
	wire flush_instruction;
	wire flush_hazard;
	wire [15:0] stall_instruction;
	wire stallreg;
    
    //data forwarding - edited by lihau 10/4
    wire [15:0] mem_to_dec_out1, mem_to_dec_out2;
	wire [15:0] exe_to_dec_out1, exe_to_dec_out2;
    wire [15:0] mem_to_exe_in1, mem_to_exe_in2;

    wire ar_type, mem_type;
    
    wire exe_to_dec1, exe_to_dec2;
    wire mem_to_dec1, mem_to_dec2;
	wire mem_to_exe1, mem_to_exe2;
	wire mem_to_exe1_sel, mem_to_exe2_sel;
    
    /*----------------------------------------------------------------*/
    /*----------------------------------------------------------------*/    
    
    /* IF stage */
    
//     pc (.clk(clk), .rst(rst), 
//     	.branch_addr(??), 
//     	.branch(??), 
//     	.pc(pc_to_memory));
	//branch pc
	mul2_1_16bit pc_mux( .in0(pc_plus_one), 
			  .in1(jr_mux_out),
			  .select(id_pc_load),
			  .out(jump_out));
	
	mul2_1_16bit exec_mux( .in0(jump_out), 
			  .in1(id_r15out),
			  .select(exe_exec_reg),
			  .out(pc_in));
    	
    pc program_counter(.clk(clk), .rst(rst), 
		.pc_in(pc_in),//pc_in), 
		.pc_out(pc_to_memory));
	

//	always @(posedge clk)begin
		// pc_plus_one <= pc_to_memory + 1'h1;
	// end
    assign pc_plus_one = pc_to_memory + 1'h1;
	
    memory mem(.clk(clk), .rst(rst), .wen(1'b1), 
    		.addr(pc_to_memory), 
    		.data_in(`NULL), 
    		.fileid(0),//?? 
    		.data_out(ifid_instruction_before_flush));
    
    //flush instruction, from hazard unit or from rst
	mul2_1_16bit instuction_flush( 
		  .in0(ifid_instruction_before_flush), 
		  .in1(stall_instruction),
		  .select(flush_instruction || rst || stallreg),
		  .out(ifid_instruction));
    		
    IFID fetch_buffer( .rst(rst), .clk(clk), 
			.stall(stall_hazard),
			.PC_Plus1(pc_plus_one),
			.Inst(ifid_instruction),
			.exec(exe_exec_reg),
			.execout(id_exec_reg),
			.PC_Plus1Reg(pc_plus_one_id_stage),
			.InstReg(stall_instruction),
			.stallreg(stallreg)); 

	/* ID stage */
	control		CU( .rst(rst),
				.opcode(ifid_instruction[15:12]), //opcode
				.cond(ifid_instruction[10:8]), 	//branch condition
				.flag(exe_flagout), 	//zero, overflow, negative
				.exec_in(id_exec_reg),
				.stall(stall_hazard),
				.aluop(id_aluop), 	//to alu
				.alusrc1(id_alusrc1),	//set to 1 when need pc as input, 
				.alusrc2(id_alusrc2), //4_1 mux
				.regdst1(id_regdst1), //set to be 1 when LLB, LHB
				.regdst2(id_regdst2), //control the raddr2,
						//set to 0 to select [3:0] for arithmetic instruction
						//set to 1 to select [11:8] for SW, JR
				.memtoreg(id_memtoreg), //set to 0 for selecting ALU result,
						  //set to 1 for memory data, eg. LW
				.regwrite(id_regwrite), //set 1 to R-type, LW, LLB, LHB
			//	.memread(id_memread),	//set 1 to LW
				.memwrite(id_memwrite),	//set 1 to SW
				.branch(id_branch),		//set 1 to B-instruction, depending on the condition code
							// and the flag
				//.jal(??), 		//set 1 for JAL and JR
				.jr(id_jr), 		//set 1 for jr
				.r15enable(id_r15enable), //set 1 for JAL, EXEC 
				.pc_load(id_pc_load),
				.flag_update(id_update),
				.exe(id_exe));


	/*Change the stage for jump*/			
	assign id_branch_extend = {ifid_instruction[7],ifid_instruction[7],ifid_instruction[7],ifid_instruction[7],ifid_instruction[7],ifid_instruction[7],ifid_instruction[7],ifid_instruction[7], ifid_instruction[7:0]};
	assign id_jal_extend = {ifid_instruction[10],ifid_instruction[10],ifid_instruction[10],ifid_instruction[10],ifid_instruction[10], ifid_instruction[10:0]};
	mul2_1_16bit mux2_1_b_jal(
				.in0(id_jal_extend),
				.in1(id_branch_extend),
				.select(id_branch),
				.out(add_input_1));

	assign add_input_2 = pc_plus_one_id_stage;		   
	assign add_out = add_input_1 + add_input_2;
	
	
	mul2_1_16bit jr_mux( .in0(add_out), 
			  .in1(exe_to_dec_out2),
			  .select(id_jr),
			  .out(jr_mux_out));
			  
	//multiplexer 1
//	ifid_instruction[7:4]
    mul2_1_4bit raddr1_mux(.in0(ifid_instruction[7:4]), 
    			.in1(ifid_instruction[11:8]),
				.select(id_regdst1),
				.out(mul_to_raddr1));
	
	//multiplexer 2
    mul2_1_4bit raddr2_mux(.in0(ifid_instruction[3:0]), 
    			.in1(ifid_instruction[11:8]),
				.select(id_regdst2),
				.out(mul_to_raddr2));
    
    regfile registers( .clk(clk), .rst(rst),
    			.wen(wb_wen),
				.raddr1(mul_to_raddr1), 
				.raddr2(mul_to_raddr2), 
				.waddr(wb_waddr),
				.wdata(wb_wdata),
				.rdata1(rdata1_to_idex),
				.rdata2(rdata2_to_idex),
				.r15(pc_plus_one_id_stage),
				.r15out(id_r15out),	//?
				.r15enable(id_r15enable)
				);
			
	//edited by lihau 10/4
	//dataforwarding from alu, and from memory	
	//this 4 multiplexer can be written into a block 
	//called forwarding unit
	//mem to dec
	mul2_1_16bit mem_forward_rdata1	(
				.in0(rdata1_to_idex), 
				.in1(wb_wdata), //mem out
				.select(mem_to_dec1),
				.out(mem_to_dec_out1));
				
	mul2_1_16bit mem_forward_rdata2	(
				.in0(rdata2_to_idex), 
				.in1(wb_wdata), //mem out
				.select(mem_to_dec2),
				.out(mem_to_dec_out2));

	//exe to dec
	mul2_1_16bit data_forward_rdata1	(
				.in0(mem_to_dec_out1), 
				.in1(exe_aluout), //alu out
				.select(exe_to_dec1),
				.out(exe_to_dec_out1));
				
	mul2_1_16bit data_forward_rdata2	(
				.in0(mem_to_dec_out2), 
				.in1(exe_aluout), //alu out
				.select(exe_to_dec2),
				.out(exe_to_dec_out2));
	
	//mem to exe
	mul2_1_16bit mem_forward_rdata3	(
				.in0(mem_to_exe_in1), 
				.in1(wb_wdata), //mem out
				.select(mem_to_exe1_sel),
				.out(exe_rdata1));
				
	mul2_1_16bit mem_forward_rdata4	(
				.in0(mem_to_exe_in2), 
				.in1(wb_wdata), //mem out
				.select(mem_to_exe2_sel),
				.out(exe_rdata2));

	
	/* EXE stage */
	
	IDEX	decode_buffer(.clk(clk), .rst(rst),
			.wb({id_r15out, id_r15enable, ifid_instruction[11:8], 
			 id_regwrite, id_memtoreg}),
			.m(id_memwrite),
			.exe({id_pc_load, id_jr, id_aluop, id_alusrc1, id_alusrc2, id_update}),
			.pc_plus_1(pc_plus_one_id_stage),
	
/******/	//edited by lihau 10/4 dataforwarding
			.dataa(exe_to_dec_out1),
			.datab(exe_to_dec_out2),
			.exec(id_exe),
    		.jumpaddr(ifid_instruction[11:0]),
    		.imm_value(ifid_instruction[3:0]),
    		.branchaddr(ifid_instruction[7:0]),
    		
			//hazard - lihau 11/4
			.flush(flush_hazard),
			.stall(stall_hazard),
			.hazardaddr(ifid_instruction[11:8]),// ???
			.hazard_ar(ar_type), //set null temporary
			.hazard_mem(mem_type), //set null temporary
    		
    		.forward(mem_to_exe1),
    		.forward1(mem_to_exe2),
    		
			//output declaration    
			.wbreg(exe_wb),
			.mreg(exe_m),
	
			.aluop(exe_aluop),
			.alusrc1(exe_alusrc1),
			.alusrc2(exe_alusrc2),
			.id_update(exe_update),
			.jr(exe_jr),
			.pcload(exe_pcload),
			
			.pc_plus_1_out(exe_pc_plus_1_out),    
			.dataareg(mem_to_exe_in1), 
			.databreg(mem_to_exe_in2),
			.exec_out(exe_exec_reg),
			.jumpaddrreg(exe_jump),
			.imm_valuereg(exe_imm),
			.branchaddrreg(exe_branch),
			
			//hazard 11/4
			.hazardaddrreg(hazard_exe_waddr),
			.hazard_arreg(hazard_exe_ar), 
			.hazard_memreg(hazard_exe_mem),
			
			.flushreg(flush_instruction),
			
			.forwardreg(mem_to_exe1_sel),
			.forwardreg1(mem_to_exe2_sel)
			);
			
		//multiplexer 1 for alu source 1
	// mul2_1_16bit mux2_1_1(
				// .in0(exe_rdata1),
				// .in1(exe_pc_plus_1_out),
				// .select(exe_alusrc1),
				// .out(exe_mux1_out)
			   // );
			   //now alu source 1 is just exe_rdata1
    
	assign exe_imm_extend = {12'b000000000000,exe_imm[3:0]}; //no negative value for LW,SW, so just extend
	assign exe_branch_extend = {exe_branch[7],exe_branch[7],exe_branch[7],exe_branch[7],exe_branch[7],exe_branch[7],exe_branch[7],exe_branch[7],exe_branch[7:0]};
	assign exe_jump_extend = {exe_jump[11],exe_jump[11],exe_jump[11],exe_jump[11],exe_jump[11:0]};//sign extend
	
	//multiplexer 2 for alu source 2				
	mul3_1_16bit mux2_1_2(
			.in0(exe_rdata2), 		//rdata2
			.in1(exe_imm_extend),	//signed extend immediate
			.in2(exe_branch_extend),				//signed extend 7:0
			.select(exe_alusrc2),
			.out(exe_mux2_out)
		   );			
	
				
	alu		ALU(	.rst(rst), 
				.update(exe_update),
				.a(exe_rdata1), 
				.b(exe_mux2_out),
				.op(exe_aluop),   //aluop[2:0] = EXE[4:2]
				.imm(exe_imm),   //4-bit or 16 bit??? lihau: 4-bit
				.out(exe_aluout),   //output
				.flag(exe_flagout)				
			   );
	
	
	
	/* MEM stage */	
	// EXMEM exe_buffer( .clk(clk), .rst(rst),
			// .wb(exe_wb),
			// .m(exe_m),
   
			// .alu_out(exe_aluout),
			// .write_data(exe_rdata2),
   
			// .wbreg(mem_wb),
			// .mem_write(mem_write),
			// .mem_read(mem_read),

			// .alu_outreg(mem_aluout),
			// .write_datareg(mem_writedata));
			

	
	memory d0 ( .clk(clk), .rst(rst),
				.wen(~exe_m),//MemWrite
				.addr(exe_aluout),
				.data_in(exe_rdata2),
				.data_out(mem_dataout_before_flush),
				.fileid(8)//??
			   );
	
	mul2_1_16bit memory_flush	(
				.in0(mem_dataout_before_flush), 
				.in1(16'b0), //mem out
				.select(rst),
				.out(mem_dataout));
	
	/* WB stage */	
	MEMWB mem_buffer( .clk(clk), .rst(rst),
		   .wb(exe_wb),
//		   .memout(mem_dataout_to_memwb),
		   .aluout(exe_aluout),	
		   
		   //hazard - lihau 11/4
			.hazardaddr(hazard_exe_waddr),
			.hazard_mem(hazard_exe_mem),
			.hazard_ar(hazard_exe_ar),
			
//			.exec(exe_exec_reg),
			.r15(wb_r15),
			.r15en(wb_r15en),
			.waddr(wb_waddr),
//			.wdata(wb_data), //no need since there is a aluout reg
			.wen(wb_wen),
			.memtoreg(wb_mem_to_reg),
//			.memoutreg(mem_dataout), 
//			.execreg(mem_exec_reg),
			.aluoutreg(wb_aluout),
			.hazardaddrreg(hazard_mem_waddr),
			.hazard_arreg(hazard_mem_ar),
			.hazard_memreg(hazard_mem_mem));
	
	mul2_1_16bit mem_write_mux( .in0(wb_aluout), 
				  //.in1(wb_writedata),
				  .in1(mem_dataout),
				  .select(wb_mem_to_reg),
				  .out(wb_wdata));
	
	HazardUnit hazard_unit(
		.rst(rst),
		.id_rdata1(mul_to_raddr1), 
		.id_rdata2(mul_to_raddr2),
		.instruction(ifid_instruction),
		
		.id_exe(id_exe),
		.id_pc_load(id_pc_load),
		
		.ex_ar_inst(hazard_exe_ar),
		.ex_mem_inst(hazard_exe_mem),
		.mem_ar_inst(hazard_mem_ar),
		.mem_mem_inst(hazard_mem_mem),
	
		.ex_waddr(hazard_exe_waddr),	
		.mem_waddr(hazard_mem_waddr),	
	
		.ar(ar_type),
		.mem(mem_type),
	
		.exe_to_dec1(exe_to_dec1),
		.exe_to_dec2(exe_to_dec2),
		.mem_to_dec1(mem_to_dec1),
		.mem_to_dec2(mem_to_dec2),
		.mem_to_exe1(mem_to_exe1),
		.mem_to_exe2(mem_to_exe2),
		
		.flush(flush_hazard),
		.stall(stall_hazard));
endmodule
