class inp1;

 virtual memory h_vintf;
 mailbox h_mbx = new();
 transaction h_trans;
 function new(virtual memory h_vintf,mailbox h_mbx);
		this.h_vintf = h_vintf;
		this.h_mbx = h_mbx;
	endfunction



 task run();
	forever begin
		@(h_vintf.cb_monitor1)
		  h_trans = new();
		  h_trans.rst = h_vintf.cb_monitor1.rst;
		  h_trans.wr_rd = h_vintf.cb_monitor1.wr_rd;
		  h_trans.data_in = h_vintf.cb_monitor1.data_in;
		  h_trans.addr = h_vintf.cb_monitor1.addr;
		  h_trans.data_out = h_vintf.cb_monitor1.data_out;
		  h_mbx.put(h_trans);
	end
 endtask


endclass











