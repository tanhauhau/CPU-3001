`include "define.v"
module memory( clk, rst, cs, wen, addr, data_in, fileid, data_out);

parameter ASIZE=16;
parameter DSIZE=16;
parameter STATE=2;//2**STATE >= LATENCY
parameter LATENCY=3;

  input clk;
  input rst;
  input cs;
  input wen;
  input [ASIZE-1:0] addr;      // address input
  input [DSIZE-1:0] data_in;          // data input
  input [3:0] fileid;
  output [DSIZE-1:0] data_out;    // data output

  reg [DSIZE-1:0] memory [0:2**ASIZE-1];
  reg [8*`MAX_LINE_LENGTH:0] line; /* Line of text read from file */

integer fin, i, c, r;
reg [ASIZE-1:0] t_addr;
reg [DSIZE-1:0] t_data;

reg [ASIZE-1:0] addr_pipe [0:LATENCY-1];
reg wen_pipe [0:LATENCY-1];
reg [DSIZE-1:0] data_pipe [0:LATENCY-1];

reg [STATE:0] cur_state;
reg [STATE:0] next_state;

assign data_out = (cur_state == 0) ? memory[addr_pipe[LATENCY-1]]: 0;


  always @(posedge clk)
    begin
      if(rst)
        begin
	   case(fileid)
		0: fin = $fopen("mem_test0.txt", "r");
		1: fin = $fopen("mem_test1.txt", "r");
		2: fin = $fopen("mem_test2.txt", "r");
		3: fin = $fopen("mem_test3.txt", "r");
	   endcase
	$write("Opening Fileid %d\n", fileid);
     //First, initialize everything to 0
     for (i = 0; i < 2 ** ASIZE; i = i + 1)
        begin
           memory[i] = 16'h0000;
        end
        //Now read in the input file
        while(!$feof(fin))
           begin
              c = $fgetc(fin);
              // check for comment
              if (c == "/" | c == "#" | c == "%")
                  r = $fgets(line, fin);
              else
                 begin
                    // Push the character back to the file then read the next time
                    r = $ungetc(c, fin);
                    r = $fscanf(fin, "%h %h",t_addr, t_data);
                    memory[t_addr]=t_data;
                    $write("%0dns: Write %h to addr %h\n",$time, t_data, t_addr);
                 end
            end
            $fclose(fin);

	   for(i=0; i< LATENCY; i = i+1) begin
		addr_pipe[i] <= 0;
		wen_pipe[i] <= 1;
		data_pipe[i] <= 0;
	   end
	end
      else
        begin
	for(i=LATENCY-1; i > 0; i = i-1) begin
		addr_pipe[i] <= addr_pipe[i-1];
		wen_pipe[i] <= wen_pipe[i-1];
		data_pipe[i] <= data_pipe[i-1];
	end
	addr_pipe[0] <= addr;
	wen_pipe[0] <= wen;
	data_pipe[0] <= data_in;
	end
    end

 always@(posedge clk) begin
   if(rst) 
	begin
		cur_state <= 0;
	end
    else
	begin
		cur_state <= next_state;
		if((cur_state == 0) && (wen_pipe[LATENCY-1] == 0)) begin
			memory[addr_pipe[LATENCY-1]]=data_pipe[LATENCY-1];
		end
		
	end
end

   always@(*) begin
	if(cur_state == 0) begin
		if(cs == 1) 
			next_state <= LATENCY-1;
		else
			next_state <= 0;
	end
	else begin
		next_state <= cur_state - 1;	
	end
   end

endmodule
