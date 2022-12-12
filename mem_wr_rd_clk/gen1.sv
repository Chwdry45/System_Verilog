class Generation;
	transaction h_trans;
	mailbox h_mbx;
	function new(mailbox h_mbx);
		this.h_mbx = h_mbx;
	endfunction

	task run;
		repeat(100)
		  begin
				h_trans = new();
				assert(h_trans.randomize());
				h_mbx.put(h_trans);
		  end
	endtask
endclass
