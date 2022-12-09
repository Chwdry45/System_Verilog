class out_mon;
	transaction h_trans;
	virtual updown h_vintf;
	mailbox h_mbx;

	function new(virtual updown h_vintf,mailbox h_mbx);
		this.h_mbx = h_mbx;
		this.h_vintf = h_vintf;
	endfunction

	task run();
	forever begin
		@(h_vintf.cd_monitor)

		h_trans = new();
			h_trans.A1_i = h_vintf.cd_monitor.A1_i;
			h_trans.A0_i = h_vintf.cd_monitor.A0_i;
			h_trans.ncs = h_vintf.cd_monitor.ncs;
			h_trans.nwr = h_vintf.cd_monitor.nwr;
			h_trans.nrd = h_vintf.cd_monitor.nrd;
			h_trans.start_i = h_vintf.cd_monitor.start_i;
			h_trans.d_in = h_vintf.cd_monitor.d_in;
			h_trans.c_out = h_vintf.cd_monitor.c_out;
			h_trans.err_o = h_vintf.cd_monitor.err_o;
			h_trans.ec_o = h_vintf.cd_monitor.ec_o;
			h_trans.dir_o = h_vintf.cd_monitor.dir_o;
			h_mbx.put(h_trans);
	end
	endtask
endclass


