`include "define.v"
`include "memory.v"

module memory_top #(parameter ASIZE=16, DSIZE=16, LATENCY=3)
				 	(input clk, rst,
					input [ASIZE-1:0] iaddr, //instruction address
					input [ASIZE-1:0] daddr, //data address
					input read,	//active high signal when LW
					input wen, 	//active low signal when SW
					input [DSIZE-1:0] data_in,	//data input
					input [3:0] file_id,
					output [DSIZE-1:0] data_out,	//data output
					output reg instruction_ready,	//active high when instruction is ready
					output reg data_ready,	//active high when data is ready
					output reg ready //active high when either data or instruction is ready
					);
	
	//read address pipe
	reg [ASIZE-1:0] addr_pipe [0:LATENCY-1];
	
	reg [ASIZE-1:0] previous_instruction;
	reg [ASIZE-1:0] previous_data;
	
	reg memory_wen;
	wire [DSIZE-1:0] memory_data_out;
	wire [DSIZE-1:0] memory_data_in;
	wire [ASIZE-1:0] memory_address;
	
	wire new_instruction;
	wire new_data;
	reg [ASIZE-1:0] new_address;
	reg [ASIZE-1:0] daddr_reg;
	
	assign new_instruction = ~instruction_ready;
	assign new_data = ~data_ready && (daddr != previous_data);
	
	assign memory_data_in = data_in;
	assign memory_address = new_address;
	
	memory m0 ( .clk(clk),
				.rst(rst),
				.cs(rst),
				.wen(memory_wen),
				.addr(memory_address),
				.data_in(memory_data_in),
				.fileid(file_id),
				.data_out(memory_data_out));
	
	integer i;
	reg read_reg;
	
	always @(posedge clk)
    begin 
		if (rst) begin
			previous_instruction <= 0;
			previous_data <= 0;
			for(i=LATENCY-1; i >= 0; i = i-1) begin
				addr_pipe[i] <= 0;
			end
			new_address <= 0;
			read_reg <= 0;
			daddr_reg <= 0;
		end else begin
			if(read) begin
				read_reg <= 1;
				daddr_reg <= daddr;
			end
			
			if(data_ready)	read_reg = 0;
			
			if((read_reg | ~wen) & new_data)begin
				previous_data <= new_address;
			end else begin
				previous_instruction <= new_address;
			end
			
			for(i=LATENCY-1; i > 0; i = i-1) begin
				addr_pipe[i] <= addr_pipe[i-1];
			end
			addr_pipe[0] <= new_address;
		end
    end
    
    always @* begin
    	memory_wen = 1;
    	// going to write or read
		if((read_reg | ~wen) & new_data)begin
			new_address = daddr;
			memory_wen = wen;
		end else begin
			if(!instruction_ready) begin
				new_address = iaddr;
				if(!read_reg)begin
					for(i=LATENCY-1; i>= 0; i=i-1) begin
						if(iaddr == addr_pipe[i]) begin
							new_address = previous_instruction + 1'b1;
						end
					end
				end
			end else begin
				new_address = previous_instruction + 1'b1;
			end
		end
		
		if(rst)begin
			//ready
			instruction_ready = 1;
			data_ready = 1;
			ready = 1;
		end else begin
			//ready
			instruction_ready = (addr_pipe[LATENCY-1] == iaddr) & ~read_reg;
			data_ready = read_reg && (addr_pipe[LATENCY-1] == daddr_reg);
			ready = (data_ready | instruction_ready);
			
		end
    end
	
    assign data_out = ready ? memory_data_out : 16'b0;
endmodule
