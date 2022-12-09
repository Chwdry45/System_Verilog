class input_monitor;
	mailbox h_mbox;
	transaction h_trans;
	virtual updown h_vintf;
	reg [7:0] plr,llr,ulr,ccr,din_temp,cout;
	bit [2:0] start;
	reg start_F,dir,ec,err;
	bit [8:0] flag_EC;
	//static bit [1:0] dir_cond = {plr==ulr,plr==llr};

  function new(virtual updown h_vintf,mailbox h_mbox);
		this.h_mbox = h_mbox;
		this.h_vintf = h_vintf;
	endfunction

	task write_tx;
		begin
			if(h_trans.nwr==0 && h_trans.nrd == 1) begin
				case({h_trans.A1_i,h_trans.A0_i})
					2'b00 : plr = h_trans.d_in;
					2'b01 :	ulr = h_trans.d_in;
					2'b10 : llr = h_trans.d_in;
					2'b11 :	ccr = h_trans.d_in;
				endcase
			end
          if(plr>ulr || plr < llr ) begin err=1;
            $display("plr = %d,ulr = %d ,llr = %d ccr = %d",plr,ulr,llr,ccr); end
			else begin err=0;
              $display("plr = %d,ulr = %d ,llr = %d ccr = %d",plr,ulr,llr,ccr); end
		end
	endtask

	task read_tx;
		begin
			if(h_trans.nrd==0 && h_trans.nwr == 1) begin
				case({h_trans.A1_i,h_trans.A0_i})
					2'b00 : din_temp = plr;
					2'b01 :	din_temp = ulr;
					2'b10 : din_temp = llr;
					2'b11 :	din_temp = ccr;
				endcase
				
			end
			else din_temp = 0;
		end
	endtask

	task start_block;
		begin
			start = {start[1],start[0],h_trans.start_i};
          if(start==3'b010 && ccr!=0 && err == 0) begin
				start_F=1;
				dir_block;
				count_block;
			end
		end
	endtask

	//static bit [1:0] dir_cond = {plr==ulr,plr==llr};
	task count_block;
		begin
			if(start==2 && start_F==1) begin
				cout = plr;
			end
			else begin
              //$display("dir_con = %d,dir = %d",dir_cond,dir);
				//case({dir_cond[1:0]==3,dir})
				case({plr == ulr , plr == llr ,dir})
					3'b000 , 3'b010 ,	3'b100: cout = cout-1;
					3'b001 , 3'b011 , 3'b101: begin cout = cout+1;
														$display("*****************INPUT MON*************************");
														end
					default: cout = cout;
				endcase
			end
			if(cout==plr) flag_EC=flag_EC-1;
			if(flag_EC==0 && start_F==1) begin
				ec = 1;
				start_F=0;
			end
			else ec=0;
		end
	endtask

	//static bit [1:0] dir_cond = {plr==ulr,plr==llr};
	task dir_block;
		begin
			if(ec==1) begin dir=1'bz; end
			else if(start==2 && start_F ==1) begin
				dir = (plr == ulr)?((plr == llr)?1'bz:0):1;
				end
			else begin
				case(dir)
					1'b0: begin
						if(cout == llr)
							if(cout == ulr) dir=0;
							else dir=1;
						else dir=0;
					end
					1'b1:begin
						if(cout == ulr)
							if(cout == llr) dir=0;
							else dir=0;
						else dir=1;
					end
				endcase
			end
		end
	endtask

	//static bit [1:0] dir_cond = {plr==ulr,plr==llr};
	task CC;
		begin
			if(ccr==0) flag_EC = 0;
			else if(plr == ulr)
				if(plr == llr) flag_EC = ccr;
				else flag_EC = ccr+1;
			else
				if(plr == llr) flag_EC = ccr+1;
				else flag_EC = 2*ccr+1;
		end
	endtask


	task run();
		begin
          forever@(h_vintf.cd_monitor) begin
				h_trans = new();
				h_trans.A0_i = h_vintf.cd_monitor.A0_i;
				h_trans.A1_i = h_vintf.cd_monitor.A1_i;
				h_trans.nwr = h_vintf.cd_monitor.nwr;
				h_trans.nrd = h_vintf.cd_monitor.nrd;
				h_trans.start_i = h_vintf.cd_monitor.start_i;
				h_trans.reset_i = h_vintf.cd_monitor.reset_i;
				h_trans.ncs = h_vintf.cd_monitor.ncs;
				h_trans.d_in = h_vintf.cd_monitor.d_in;

				if(h_trans.ncs==0) begin
					if(h_trans.reset_i==0) begin
						//fork
							if(start_F == 0) begin
								ec =0;
								cout=0;
								start_block;
                              if(start_F==0)write_tx;
                              if(start_F==0)CC;
							end
							else begin
								fork
									start=0;
									count_block;
									dir_block;
								join
							end
							read_tx;
						//join
					end
					else begin
						plr = 0;ulr =8'hff;llr=0;ccr=0;
						start = {start[1],start[0],1'b0};
						start_F =0;
						h_trans.c_out = 0;
						h_trans.dir_o = 1'bz;
						h_trans.err_o = 0;
						h_trans.ec_o = 0;
						flag_EC =0;
					end
				end
				else begin
					start = {start[1],start[0],1'b0};
					start_F =0;
					h_trans.c_out = 0;
					h_trans.dir_o = 1'bz;
					h_trans.err_o = 0;
					h_trans.ec_o = 0;
				end

				h_trans.c_out = cout;
				h_trans.dir_o = dir;
				h_trans.ec_o = ec;
				h_trans.err_o = err;

				h_mbox.put(h_trans);
            $display("start_F = %d",start_F);
			end
		end
	endtask

endclass












