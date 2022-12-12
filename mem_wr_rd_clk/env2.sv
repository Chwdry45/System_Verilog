
class environment2;

	virtual memory h_vintf;
	mailbox h_mbx_gen,h_mbx_tbmo,h_mbx_dutmo;
	Generation h_gen;
	driv2 h_driv2;
	inp2 h_tbmo2;
	out2 h_dutmo2;
	scoreboard2 h_scrbd2;


function new(virtual memory h_vintf);
	this.h_vintf = h_vintf;
	h_mbx_gen = new();
	h_mbx_tbmo = new();
	h_mbx_dutmo = new();
	h_gen = new(h_mbx_gen);
	h_driv2 = new(h_vintf,h_mbx_gen);
	h_tbmo2 = new(h_vintf,h_mbx_tbmo);
	h_dutmo2 = new(h_vintf,h_mbx_dutmo);
	h_scrbd2 = new(h_mbx_tbmo,h_mbx_dutmo);
endfunction


	task run;
		fork
			h_driv2.run;
			h_gen.run;
		   h_tbmo2.run;
			h_scrbd2.run;
			h_dutmo2.run;
		join
	endtask
endclass
