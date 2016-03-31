// This file is the testbench for D_memory.v

module memory_tb;
parameter ASIZE=16;
parameter DSIZE=16;
reg clk;
reg rst;
reg cs;
reg wen;
reg [ASIZE-1:0] address;
reg [DSIZE-1:0] data_in;
reg [3:0] fileid;
wire [DSIZE-1:0] data_out;

`define TEST_LIMIT 20

memory m0 (
  .clk(clk),
  .rst(rst),
  .cs(cs),
  .wen(wen),
  .addr(address),
  .data_in(data_in),
  .fileid(fileid),
  .data_out(data_out)
);

integer i;

// generate the clk
always #5 clk = ~clk;

initial
  begin
    clk = 0; rst = 0; fileid = 0;
    wen = 1; //active low (disabled)
    cs = 0; //active high -- enabled during cycle asking for read or write to register a request
    data_in=16'hFFFF;
    address = 0;
#10 rst = 1;
#10 rst = 0;
    //wait for end of initialization

    //first read at correct rate
    //apply an address, wait 3 cycles, and the data should return
    for (i = 0; i < 20; i = i + 1)
        begin
	   //cs = 1;
	   $write("%0dns: Data[%h] = ",$time,address);
	   #10 cs = 0;
	   #20 address = address + 1;
           $write("%h\n", data_out);
        end
    address = 0;
    wen = 0;
    #50;
    //now write at the correct rate
    //apply an address, wait 3 cycles, and the data is written
    for(i=0; i < `TEST_LIMIT; i = i + 1)
	begin
		//cs = 1;
		$write("%0dns: Write Data %h to Address %h\n",$time, data_in, address);
		#10 cs = 0;
		#20 address = address +1;
		data_in = data_in -1;
	end
     //re-read those addresses at the correct rate
    address = 0;
    wen =1 ;
    #50;
    for (i = 0; i < `TEST_LIMIT; i = i + 1)
        begin
	   cs = 1;
           $write("%0dns: Data[%h] = ",$time,address);
	   #10 cs = 0;
           #20 address = address + 1;
           $write("%h\n", data_out);
        end
    address = 0;
    #50;
    //now, demonstrate that reading at the wrong rate doesn't actually read all of the data
        for (i = 0; i < `TEST_LIMIT; i = i + 1)
        begin
	   cs = 1;
           $write("%0dns: Data[%h] = ",$time,address);
           #10 address = address + 1;
           $write("%h\n", data_out);
        end
    address = 0;
    data_in = 16'h00FF;
    cs = 0;
    //and that writing at the wrong rate doesn't actually write all the data
    #50;
    wen = 0; 
    for (i = 0; i < `TEST_LIMIT; i = i + 1)
        begin
	   cs = 1;
           $write("%0dns: Write Data %h to Address %h\n",$time, data_in, address);
	   #10 address = address + 1;
               data_in = data_in - 1;
        end
     cs = 0;
     #50;
     address = 0;
     wen = 1;
     //and one final reading at the correct rate to see what happened.
    for (i = 0; i < `TEST_LIMIT; i = i + 1)
        begin
	   cs = 1;
           $write("%0dns: Data[%h] = ",$time,address);
	   #10 cs = 0;
           #20 address = address + 1;
           $write("%h\n", data_out);
        end

#100 $finish;
  end

endmodule // end of testbench module
