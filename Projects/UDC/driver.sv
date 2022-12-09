class driver;
	transaction h_trans;
	mailbox h_mbx;
	virtual updown h_vintf;
	function new(virtual updown h_vintf,mailbox h_mbx);
		this.h_vintf = h_vintf;
		this.h_mbx = h_mbx;
	endfunction
//	static reg [7:0]din;
	task run();
	h_vintf.cd_driver.reset_i <= 0;
	@(h_vintf.cd_driver) h_vintf.cd_driver.reset_i <= 1;
	@(h_vintf.cd_driver) h_vintf.cd_driver.reset_i <= 0;

		forever begin
		@(h_vintf.cd_driver)
			h_trans = new();
			h_mbx.get(h_trans);
			h_vintf.cd_driver.A1_i <= h_trans.A1_i;
			h_vintf.cd_driver.A0_i <= h_trans.A0_i;
			h_vintf.cd_driver.ncs <= h_trans.ncs;
			h_vintf.cd_driver.nwr <= h_trans.nwr;
			h_vintf.cd_driver.nrd <= h_trans.nrd;
			h_vintf.cd_driver.start_i <= h_trans.start_i;
			h_vintf.cd_driver.d_in <=  (h_trans.nwr == 0 && h_trans.nrd == 1 && h_trans.ncs == 0)? h_trans.d_in : 8'bz ;

		end
	endtask
endclass


