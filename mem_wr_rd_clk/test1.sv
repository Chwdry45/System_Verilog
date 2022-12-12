class test;

	environment1 h_env1;
	environment2 h_env2;
	virtual memory h_vintf;
	function new(virtual memory h_vintf);
		this.h_vintf = h_vintf;
		h_env1 = new(h_vintf);
		h_env2 = new(h_vintf);
	endfunction

	task run();
	fork
		h_env1.run();
		h_env2.run();
	join
	endtask

endclass
