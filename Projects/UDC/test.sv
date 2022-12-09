class test;
	environment h_env;
	virtual updown h_vintf;

	function new(virtual updown h_vintf);
		this.h_vintf = h_vintf;
		h_env = new(h_vintf);
	endfunction

	task run();
			h_env.run();
	endtask
endclass
