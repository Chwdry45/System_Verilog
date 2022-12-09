class generation;
	transaction h_trans;
	mailbox h_mbx;

	function new(mailbox h_mbx);
		this.h_mbx = h_mbx;
	endfunction
bit [7:0]plr,llr,ulr,ccr;
	/*task run();
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
      h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b001; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans.A0_i.rand_mode(0);
			h_trans.A1_i.rand_mode(0);
			h_trans.d_in.rand_mode(0);
			h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b011; start_i == 0;});
			h_mbx.put(h_trans);
			h_trans = new();B
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b011; start_i == 1;});
			h_mbx.put(h_trans);
      		h_trans = new();
      assert(h_trans.randomize() with {{ncs,nwr,nrd}== 3'b011; start_i == 0;});
			h_mbx.put(h_trans);
			//wait(h_trans.ec_o == 1);
			//$display("=============================================================================================================================================================================================");
	endtask*/
	/*task run();
		stimulus(5,6,4,12);
		
	
	endtask*/


	task run12(bit [7:0] plr,ulr,llr,ccr);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 0 ; A0_i == 0 ; {ncs,nwr,nrd} == 3'b001; d_in == plr; });
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 0 ; A0_i == 1 ; {ncs,nwr,nrd} == 3'b001; d_in == ulr ;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 1 ; A0_i == 0 ; {ncs,nwr,nrd} == 3'b001; d_in == llr;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 1 ; A0_i == 1 ; {ncs,nwr,nrd} == 3'b001; d_in == ccr;});
		h_mbx.put(h_trans);
	/*	h_trans.A1_i.rand_mode(0);
		h_trans.A0_i.rand_mode(0);
		h_trans.d_in.rand_mode(0);*/
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 0;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 1;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 0;});
		h_mbx.put(h_trans);
	endtask


task run(bit [7:0] plr,ulr,llr,ccr);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 0 ; A0_i == 0 ; {ncs,nwr,nrd} == 3'b001; d_in == plr;  });
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 0 ; A0_i == 1 ; {ncs,nwr,nrd} == 3'b001; d_in == ulr ;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 1 ; A0_i == 0 ; {ncs,nwr,nrd} == 3'b001; d_in == llr;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 1 ; A0_i == 1 ; {ncs,nwr,nrd} == 3'b001; d_in == ccr;});
		h_mbx.put(h_trans);
	/*	h_trans.A1_i.rand_mode(0);
		h_trans.A0_i.rand_mode(0);
		h_trans.d_in.rand_mode(0);*/
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 0;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 1;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 0;});
		h_mbx.put(h_trans);
	endtask





	task start_err(bit [7:0] plr,ulr,llr,ccr);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 0 ; A0_i == 0 ; {ncs,nwr,nrd} == 3'b001; d_in == plr; });
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 0 ; A0_i == 1 ; {ncs,nwr,nrd} == 3'b001; d_in == ulr ;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 1 ; A0_i == 0 ; {ncs,nwr,nrd} == 3'b001; d_in == llr;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {A1_i == 1 ; A0_i == 1 ; {ncs,nwr,nrd} == 3'b001; d_in == ccr;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 0;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 1;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 1;});
		h_mbx.put(h_trans);
		h_trans = new();
		assert(h_trans.randomize() with {start_i == 0;});
		h_mbx.put(h_trans);
	endtask
endclass
