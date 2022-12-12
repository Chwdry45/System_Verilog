interface memory(input clk_wr , clk_rd);
logic rst;
logic wr_rd;
logic [7:0]data_in;
logic [7:0]data_out;
logic [5:0]addr;

logic [7:0]mem[63:0];

clocking cb_driver1@(posedge clk_wr);
	output #0 rst;
	output #0 wr_rd;
	output #0 data_in;
	output #0 addr;
	input #1 data_out;
endclocking

clocking cb_driver2@(posedge clk_rd);
	output #0 rst;
	output #0 wr_rd;
	output #0 data_in;
	output #0 addr;
	input #1 data_out;
endclocking


clocking cb_monitor1@(posedge clk_wr);
	input #0 rst;
	input #0 wr_rd;
	input #0 data_in;
	input #0 addr;
	input #0 data_out;
	input #0 mem;
endclocking


clocking cb_monitor2@(posedge clk_rd);
	input #0 rst;
	input #0 wr_rd;
	input #0 data_in;
	input #0 addr;
	input #0 data_out;
	input #0 mem;
endclocking
endinterface
