// This file is the testbench for D_memory.v

module memory_top_tb;
parameter ASIZE=16;
parameter DSIZE=16;
reg clk;
reg rst;

reg wen, read;
wire ready, inst_ready, data_ready;
reg [ASIZE-1:0] iaddr;
reg [ASIZE-1:0] daddr;
reg [DSIZE-1:0] data_in;
reg [3:0] fileid;
wire [DSIZE-1:0] data_out;

reg [ASIZE-1:0] address;
reg type;

reg [8*999999:0] line; /* Line of text read from file */

integer fin, i, c, r;

`define TEST_LIMIT 20

memory_top m0 (.clk(clk), .rst(rst),
				.iaddr(iaddr), .daddr(daddr),
				.read(read), .wen(wen),
				.data_in(data_in),
				.file_id(fileid),
				.data_out(data_out),
				.ready(ready),
				.instruction_ready(inst_ready),
				.data_ready(data_ready));

// generate the clk
always #5 clk = ~clk;

initial begin
    clk = 0; rst = 0; fileid = 0;
    wen = 1; //active low (disabled)
    read = 0;
    data_in=16'hFFFF;
	iaddr = 0;
	daddr = 0;
	#10 rst = 1;
	#10 rst = 0;
    //wait for end of initialization

    //first read at correct rate
    //apply an address, wait 3 cycles, and the data should return
    fin = $fopen("tb.txt","r");
    while(!$feof(fin)) begin
		c = $fgetc(fin);
		// check for comment
		if (c == "/" | c == "#" | c == "%")
			r = $fgets(line, fin);
		else
		begin
			// Push the character back to the file then read the next time
			r = $ungetc(c, fin);
			#20 r = $fscanf(fin, "%h %b",address, type);
			$write("Reading: %h %b\n", address, type);
			if(type) begin
				daddr = address;
				read = 1;
			end else begin
				iaddr = address;
				read = 0;
			end			
		end
	end
	$fclose(fin);

	#100 $finish;
end

endmodule // end of testbench module
