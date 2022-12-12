
class scoreboard2;

	mailbox h_mbx1 = new();
	mailbox h_mbx2 = new();
	transaction h_trans1,h_trans2;
	function new(mailbox h_mbx1,h_mbx2);
		this.h_mbx1 = h_mbx1;
		this.h_mbx2 = h_mbx2;
	endfunction

	task run();
	begin
		forever
		begin
		//#1
			h_trans1 = new();
			h_trans2 = new();
			h_mbx1.get(h_trans1);
			h_mbx2.get(h_trans2);

			if(h_trans1.data_out == h_trans2.data_out)
		//	$display($time,"PASS \t tb_data_out=%d \t dut_data_out=%d \t tb_data_in=%d \t dut_data_in=%d \t tb_addr=%d \t dut_addr=%d \t tb_rst = %d \t dut_rst = %d \t tb_wr_rd = %d \t dut_wr_rd = %d",h_trans1.data_out,h_trans2.data_out,h_trans1.data_in,h_trans2.data_in,h_trans1.addr,h_trans2.addr,h_trans1.rst,h_trans2.rst,h_trans1.wr_rd,h_trans2.wr_rd);
		  $display("pass rd h_trans1 = %p \n h_trans2 = %p",h_trans1 , h_trans2);
			else
		//	$display($time,"FAIL \t tb_data_out=%d \t dut_data_out=%d \t tb_data_in=%d \t dut_data_in=%d \t tb_addr=%d \t dut_addr=%d \t tb_rst = %d \t dut_rst = %d \t tb_wr_rd = %d \t dut_wr_rd = %d",h_trans1.data_out,h_trans2.data_out,h_trans1.data_in,h_trans2.data_in,h_trans1.addr,h_trans2.addr,h_trans1.rst,h_trans2.rst,h_trans1.wr_rd,h_trans2.wr_rd);
		  $display("fail rd h_trans1 = %p \n h_trans2 = %p",h_trans1 , h_trans2);

		end
	end
	endtask

endclass

