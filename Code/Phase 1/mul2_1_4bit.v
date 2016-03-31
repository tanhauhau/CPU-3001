`include "define.v"

module mul2_1_4bit(
		in0, 
		in1,
		select,
		out);
		
	input[3:0] in0,in1;
	input select;
	output[3:0] out;
	
	assign out = (select == 0) ? in0 : in1;
	
endmodule
