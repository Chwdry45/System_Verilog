/*`include "gen.sv"
`include "driver.sv"
`include "inp_mon.sv"
`include "out_mon.sv"
`include "scoreboard.sv"*/
class environment;

	virtual updown h_vintf;
	generation h_gen;
	driver h_driver;
	input_monitor h_inpm;
	out_mon h_opm;
	scoreboard h_scb;
	mailbox h_mbx_gen,h_mbx1,h_mbx2;

	function new(virtual updown h_vintf);
		this.h_vintf = h_vintf;
		h_mbx_gen = new();
		h_mbx1 = new();
		h_mbx2 = new();
		h_gen = new(h_mbx_gen);
		h_driver = new(h_vintf , h_mbx_gen);
		h_inpm = new(h_vintf , h_mbx1);
		h_opm = new(h_vintf,h_mbx2);
		h_scb = new(h_mbx1,h_mbx2);
	endfunction


/*	task run();
	fork
		begin
			h_gen.run(10,15,5,10);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(15,15,15,10);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(100,100,100,10);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(1,2,0,10);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(3,5,1,7);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(7,7,5,10);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(7,9,7,10);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(0,9,7,10);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(7,9,7,0);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);
		
			$display("9umjv980regk,");
			repeat(2) @(h_vintf.cd_monitor);
			$display("9umjv980regk,");
			h_gen.start_err(10,255,7,10);   //extended start
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);
		end
		h_driver.run();
		h_inpm.run();
		h_opm.run();
		h_scb.run();
	join
	endtask*/


 	task run();
	fork
		begin
			h_gen.run(10,15,5,10);//ulr>plr>llr
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(15,15,15,10); //plr = ulr =llr
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(100,100,100,10);
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(1,2,0,10); //ulr>plr>llr
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(3,5,1,7); //ulr>plr>llr
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(7,7,5,10); // p = u p >l
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(7,9,7,10); // p=l <u 2diff
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(8,9,7,10); // 1diff
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(7,9,7,0);  //ccr = 0
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);

			repeat(2) @(h_vintf.cd_monitor);
			h_gen.start_err(10,12,7,5);   //extended start
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);



			repeat(2) @(h_vintf.cd_monitor);
			h_gen.run(7,9,10,5); //error condition



			repeat(5) @(h_vintf.cd_monitor);
			h_gen.run(7,9,5,4); // 2diff
			wait(h_vintf.cd_monitor.ec_o == 0);
			wait(h_vintf.cd_monitor.ec_o == 1);
		end
		h_driver.run();
		h_inpm.run();
		h_opm.run();
		h_scb.run();
	join
	endtask



endclass




