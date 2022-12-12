class out1;
	virtual memory h_vintf;
	transaction h_trans;
	mailbox h_mbx;
function new(virtual memory h_vintf,mailbox h_mbx);
		this.h_vintf = h_vintf;
		this.h_mbx = h_mbx;
	endfunction


	task run;
	forever begin
		@(h_vintf.cb_monitor1)
		  h_trans = new();
		  h_trans.rst = h_vintf.cb_monitor1.rst;
		  h_trans.wr_rd = h_vintf.cb_monitor1.wr_rd;
		  h_trans.data_in = h_vintf.cb_monitor1.data_in;
		  h_trans.addr = h_vintf.cb_monitor1.addr;
		 // h_trans.data_out = h_vintf.cb_monitor.data_out;
		  case({h_trans.rst,h_trans.wr_rd})
		  		2'b10 : h_trans.data_out = h_vintf.cb_monitor1.mem[h_vintf.cb_monitor1.addr];
				//2'b11 : h_trans.mem[h_trans.addr] =  h_vintf.cb_monitor1.data_in;
		//		default : h_trans.data_out = 0;
		  endcase
		  h_mbx.put(h_trans);
	end
	endtask
endclass




