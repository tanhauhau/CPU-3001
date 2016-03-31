`include "define.v"

module mul3_1_16bit(
		in0, 
		in1,
		in2,
		select,
		out);
		
	input[15:0] in0, in1, in2;
	input [1:0] select;
	output[15:0] out;
	
	assign out = (select == 2'b00) ? in0 : 
 					((select == 2'b01) ? in1 :  
							in2);
	
endmodule
