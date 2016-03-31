`include "define.v"

module mul2_1_16bit(
		in0, 
		in1,
		select,
		out);
		
	input[15:0] in0,in1;
	input select;
	output[15:0] out;
	
	assign out = (select == 0) ? in0 : in1;
	
endmodule