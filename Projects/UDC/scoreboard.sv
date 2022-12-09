class scoreboard;
	mailbox h_mbx1;
	mailbox h_mbx2;
	transaction h_trans1;
	transaction h_trans2;

	function new(mailbox h_mbx1,mailbox h_mbx2);
		this.h_mbx1 = h_mbx1;
		this.h_mbx2 = h_mbx2;
	endfunction



	task run();
	forever begin
		h_trans1 = new();
		h_trans2 = new();
		h_mbx2.get(h_trans2);
#2 h_mbx1.get(h_trans1);

		if(h_trans1.c_out == h_trans2.c_out && h_trans1.err_o == h_trans2.err_o && h_trans1.ec_o == h_trans2.ec_o &&h_trans1.dir_o == h_trans2.dir_o)
        //  $display("PASS /t inp_c_out = %d /t out_c_out = %d /t inp_err_o = %d /t out_err_o = %d /t in_ec_o = %d /t out_ec_o = %d /t in_dir_o = %d /t out_dir_o = %d",h_trans1.c_out,h_trans2.c_out,h_trans1.err_o,h_trans2.err_o,h_trans1.ec_o,h_trans2.ec_o,h_trans1.dir_o,h_trans2.dir_o);
		  $display($time,"====PASS===\n ============= input monitor========== \n h_trans1 = %p \n ==========out_mon=========\n h_trans2 = %p" ,h_trans1 , h_trans2);
		else
         // $display("FAIL /t inp_c_out = %d /t out_c_out = %d /t inp_err_o = %d /t out_err_o = %d /t in_ec_o = %d /t out_ec_o = %d /t in_dir_o = %d /t out_dir_o = %d",h_trans1.c_out,h_trans2.c_out,h_trans1.err_o,h_trans2.err_o,h_trans1.ec_o,h_trans2.ec_o,h_trans1.dir_o,h_trans2.dir_o);
		  $display($time,"====FAIL==== \n============= input monitor========== \n h_trans1 = %p \n  ==========out_mon========= \n h_trans2 = %p" ,h_trans1 , h_trans2);

	end
	endtask
endclass




