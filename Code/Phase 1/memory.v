`include "define.v"

module memory( clk, rst, wen, addr, data_in, fileid, data_out);

parameter ASIZE=16;
parameter DSIZE=16;

  input clk;
  input rst;
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

reg [ASIZE-1:0] addr_r;

assign data_out = memory[addr_r];

  always @(posedge clk)
    begin
      if(rst)
        begin
	   addr_r <=0;
  	   case(fileid)
	        0: fin = $fopen("imem_test0.txt","r");
        	1: fin = $fopen("imem_test1.txt","r");
	        2: fin = $fopen("imem_test2.txt","r");
        	3: fin = $fopen("imem_test3.txt","r");
	        4: fin = $fopen("imem_test4.txt","r");
        	5: fin = $fopen("imem_test5.txt","r");
	        6: fin = $fopen("imem_test6.txt","r");
        	7: fin = $fopen("imem_test7.txt","r");
	        8: fin = $fopen("dmem_test0.txt","r");
        	9: fin = $fopen("dmem_test1.txt","r");
	        10: fin = $fopen("dmem_test2.txt","r");
        	11: fin = $fopen("dmem_test3.txt","r");
	        12: fin = $fopen("dmem_test4.txt","r");
        	13: fin = $fopen("dmem_test5.txt","r");
	        14: fin = $fopen("dmem_test6.txt","r");
	        15: fin = $fopen("dmem_test7.txt","r");
	  endcase
	  $write("Opening Fileid %d\n", fileid);
	  //First, initialize everything to 0
	  for (i = 0; i < 2 ** ASIZE; i = i + 1)
	        begin
        	   memory[i] = 16'h0000;
	        end
          //Now read in the input file
	  while(!$feof(fin)) begin
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
                 end
            end
            $fclose(fin);
	end
      else
        begin
	  addr_r <= addr;
          if (!wen)
            begin            // active-low write enable
              memory[addr] <= data_in;
            end
	end
    end

endmodule