module memory_design(clk_wr,clk_rd,rst,wr_rd,addr,data_in,data_out);
input clk_wr,clk_rd,rst,wr_rd;
input [5:0]addr;
input [7:0]data_in;
output reg [7:0] data_out;
reg [7:0]mem[63:0];


always@(posedge clk_wr)
	begin
		if(rst) begin
			data_out = 0;
			for(int i = 0 ; i< 64 ; i= i +1) mem[i] = 0;
		end
		else begin
			if(wr_rd) begin
				mem[addr] = data_in;data_out=0;
			end
		end
	end


always@(posedge clk_rd)
	begin
		if(rst) begin
			data_out = 0;
			for(int i = 0 ; i< 64 ; i= i +1) mem[i] = 0;
		end
		else begin
			if(!wr_rd) begin
				data_out = mem[addr];
			end
		end
	end


endmodule


