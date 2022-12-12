
class driv2;
	transaction h_trans;
	mailbox h_mbx;
	virtual memory h_vintf;
	function new(virtual memory h_vintf,mailbox h_mbx);
		this.h_vintf = h_vintf;
		this.h_mbx = h_mbx;
	endfunction


	task run();
		h_vintf.cb_driver2.rst <= 0;
		@(h_vintf.cb_driver2) h_vintf.cb_driver2.rst <= 1;
		@(h_vintf.cb_driver2) h_vintf.cb_driver2.rst <= 0;
		forever
			begin
				@(h_vintf.cb_driver2)
	  		  h_trans = new();
			  h_mbx.get(h_trans);
				h_vintf.cb_driver2.data_in <= h_trans.data_in;
				h_vintf.cb_driver2.addr <= h_trans.addr;
				h_vintf.cb_driver2.wr_rd <= h_trans.wr_rd;
			end
	endtask
endclass


