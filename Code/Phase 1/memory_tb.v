// This file is the testbench for D_memory.v

module memory_tb;
parameter ASIZE=16;
parameter DSIZE=16;
reg clk;
reg rst;
reg wen;
reg [ASIZE-1:0] address;
reg [DSIZE-1:0] data_in;
wire [DSIZE-1:0] data_out;
reg [3:0] fileid;

`define TEST_LIMIT 100

memory d0 (
  .clk(clk),
  .rst(rst),
  .wen(wen),
  .addr(address),
  .data_in(data_in),
  .data_out(data_out),
  .fileid(fileid)
);

integer i;

initial begin
   fileid = 0; clk = 0;   rst = 0; wen = 1; data_in=16'hFFFF; address = 0;
#10 rst = 1;
#10 rst = 0;
   for(i = 0; i< 2 ** ASIZE; i=i+1) begin
	$write("%0dns: Data[%h] = ",$time,address);
	#10 address = address + 1;
	$write("%h\n", data_out);
	if(data_out == 0) begin
		i=2**ASIZE;
	end
    end
   fileid = 8; address = 0; // change to another input file
#10 rst = 1;
#10 rst = 0;
   for(i = 0; i< 2 ** ASIZE; i=i+1) begin
        $write("%0dns: Data[%h] = ",$time,address);
        #10 address = address + 1;
        $write("%h\n", data_out);
        if(data_out == 0) begin
                i=2**ASIZE;
        end
    end
    address = 0;
    wen = 0; 
    for (i = 0; i < 2 ** ASIZE; i = i + 1)
        begin
           $write("%0dns: Data[%h] = ",$time,address);
           #10 address = address + 1;
               data_in = data_in - 1;
           $write("%h\n", data_out);
           if(address == `TEST_LIMIT) begin
                i=2**ASIZE;
           end 
        end
#100 $finish;
end

// generate the clk
always #5 clk = ~clk;

endmodule // end of testbench module
