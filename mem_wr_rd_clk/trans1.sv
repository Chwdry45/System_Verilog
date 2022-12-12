class transaction;
	bit clk_wr,clk_rd,rst;
	rand bit wr_rd;
	randc bit [5:0]addr;
	rand bit [7:0]data_in;
	bit [7:0]data_out;
	logic [7:0]mem[63:0];

	constraint cnst1{ data_in inside {[0:200]};
			  				}
endclass
