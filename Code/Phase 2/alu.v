//Modified ALU module with set of flag
`include "define.v"

module alu(
   rst, 
   update,
   a,   //1st operand
   b,   //2nd operand
   op,   //3-bit operation //modified 4 bit
   imm,   //4-bit immediate operand for shift/rotate
   out,   //output
   flag
   );

   parameter DSIZE = 16;
   
   input [DSIZE-1:0] a, b;
   //input [2:0] op;
   input [3:0] op;//modified 4 bit
   input [3:0] imm;
   input rst;
   input update;
   output reg [DSIZE-1:0] out;
   output reg [2:0] flag;	
   //flag[0] = Negative
   //flag[1] = Overflow
   //flag[2] = Zero
	// The V flag is set by the ADD and SUB instruction
	// The N flag is set if and only if the result of the ADD and SUB instruction is negative
	
	reg [15:0] temp;
	
always @* begin
	if (rst) 
		begin
			flag = 3'b000;
			out = 0;
		end
	else begin
		flag = 3'b000;
	   case(op)
		   `ADD:begin 
				out = a + b;
				//update flag
				if (update) begin//set the V flag
					flag[2] = (out == 0);
					//a and b same sign, out different sign
					if(a[15] == b[15] && a[15] != out[15])
					//if (((a > 16'b0) && (b > 16'b0) && (out < 16'b0)) || ((a < 16'b0) && (b < 16'b0) && (out > 16'b0)))
						flag[1] = 1'b1;
					else begin
						flag[1] = 1'b0; 
						flag[0]= out[15];//set N flag
					end						
				end
			end
		   `SUB:begin
				out = a - b;
				//update flag
				if (update) begin//set the V flag
					flag[2] = (out == 0);
					//a -ve, b +ve, out +ve,
					//a +ve, b -ve, out -ve
					
					if(a[15] != b[15] && b[15] == out[15])
					//if (((a < 16'b0) && (b > 16'b0) && (out > 16'b0)) || ((a > 16'b0) && (b < 16'b0) && (out < 16'b0)))
						flag[1] = 1'b1;
					else begin
						flag[0]= out[15];	
					end
				end
			end
		   `AND:begin
				out = a & b;
				if (update) begin
				flag[1] = 1'b0;  
				flag[2]=(out==0)?1'b1:1'b0;//set Z flag
				end
			end
		   `OR: begin
				out = a | b;
				if (update) begin
				flag[1] = 1'b0;
				flag[2]=(out==0)?1'b1:1'b0;//set Z flag
				end
			end
		   `SLL:begin
				out = a << imm;
			end
		   `SRL:begin
				out = a >> imm;
			end
		   `SRA:begin
				out = $signed(a) >>> imm;
			end
		   `RL: begin
				out = (a << imm)| ( a >> (DSIZE - imm));
			end
		   `LHB:begin
				temp = a&16'h00ff;
				out = temp|(b<<4'b1000);
			end
		   `LLB: begin
				temp = a&16'hff00;
				out = temp|b;
			end
		   default: out = 16'b0; 
	   endcase
	end
	
	// The Z flag is set if and only if the output of the operation is zero.
	// if(op == `ADD || op == `SUB || op == `AND || op == `OR) begin
		// flag[2] = (out == 0);
	// end
	
end
endmodule
   
       

   
