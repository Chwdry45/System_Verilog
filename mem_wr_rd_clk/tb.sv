module tb;

	bit clk_wr;
	bit clk_rd;
	always #3 clk_wr++;
	always #5 clk_rd++;

	memory h_intf(clk_wr,clk_rd);

	test h_test;

	memory_design dut(.data_in(h_intf.data_in),.data_out(h_intf.data_out),.rst(h_intf.rst),.clk_wr(h_intf.clk_wr),.addr(h_intf.addr),.wr_rd(h_intf.wr_rd),.clk_rd(h_intf.clk_rd));

	initial
	begin
		h_test = new(h_intf);
		h_test.run();
	end

	initial
	begin
		#500;
		$finish;
	end

endmodule


