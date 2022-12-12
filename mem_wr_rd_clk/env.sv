class environment1;

	virtual memory h_vintf;
	mailbox h_mbx_gen,h_mbx_tbmo,h_mbx_dutmo;
	Generation h_gen;
	driv1 h_driv1;
	inp1 h_tbmo1;
	out1 h_dutmo1;
	scoreboard1 h_scrbd1;


function new(virtual memory h_vintf);
	this.h_vintf = h_vintf;
	h_mbx_gen = new();
	h_mbx_tbmo = new();
	h_mbx_dutmo = new();
	h_gen = new(h_mbx_gen);
	h_driv1 = new(h_vintf,h_mbx_gen);
	h_tbmo1 = new(h_vintf,h_mbx_tbmo);
	h_dutmo1 = new(h_vintf,h_mbx_dutmo);
	h_scrbd1 = new(h_mbx_tbmo,h_mbx_dutmo);
endfunction


	task run;
		fork
			h_driv1.run;
			h_gen.run;
		   h_tbmo1.run;
			h_scrbd1.run;
			h_dutmo1.run;
		join
	endtask
endclass
