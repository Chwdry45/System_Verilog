`include "dut.v"
module tb1;
	

	wire [7:0]cout;
	wire dir,err,ec;
	wire [7:0] din;
	reg [7:0] din_tb;
	reg clk=0,reset=1;
	reg ncs=1,nrd=1,nwr=1,a0=0,a1=0, start=0;

	reg [7:0]checker_cout, checker_PLR=0, checker_ULR=0, checker_LLR=0, checker_CCR=0;
	reg checker_dir=0, checker_ec=0, checker_err=0;
	wire [7:0] checker_din;
	reg [7:0] checker_din_temp;
	reg [2:0] checker_start=0;
	reg checker_start_flag=0;
	reg checker_PASS;

		
	assign din = (nwr==1) ? 8'bz : din_tb;
	//UP_DOWN_COUNTER DUT(cout,dir,err,ec, din, a0,a1,clk,reset,ncs,nwr,nrd,start);
	UP_DOWN_COUNTER DUT_INST ( din, ncs, nrd, nwr, a0, a1, clk, start, reset, cout, err, dir, ec ) ;


	always #5 clk = ~clk;
	initial #100000 $finish;
	

	assign checker_din = (nwr==1) ? ((nrd==1)? 8'hz:checker_din_temp): din_tb;
	initial fork
		inputs;
		checker;
		comparision;
	join	

	initial #15 reset=0;
	task inputs;
		begin
			repeat(1)
			begin
				@(negedge clk) begin
			    	stimulus(5,15,1,1); $display("llr<plr<ulr");
					wait(checker_ec==1||checker_err==1)@(negedge clk) stimulus(1,2,1,5);$display("plr=llr plr<ulr");
				  	wait(checker_ec==1||checker_err==1)@(negedge clk)stimulus(10,10,1,2);$display("plr=ulr>llr");
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(9,9,9,5); $display("plr=llr=ulr");
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(255,255,255,1); 
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(100,101,99,2);
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(101,101,99,2);
				   wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(101,101,100,2);	
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(99,101,99,2);
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(100,101,100,2);
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(0,0,0,255);
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(3,5,1,2);
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(1,2,3,4);
					wait(checker_ec==1||checker_err==1)	@(negedge clk) stimulus(9,9,9,255);
				end
			end
		end
	endtask
	task stimulus(input reg[7:0] plr_tb,ulr_tb,llr_tb,ccr_tb);
  	begin
		@(negedge clk)reset=1; ncs=0; nwr=0; nrd=1; start=0;checker_ec=0;checker_start_flag=0;
		@(negedge clk) reset=0; ncs=0; nwr=0; nrd=1; a1=0; a0=0; din_tb=plr_tb;
		@(negedge clk) a1=0; a0=1; din_tb=ulr_tb;
		@(negedge clk) a1=1; a0=0; din_tb=llr_tb;
		@(negedge clk) a1=1; a0=1; din_tb=ccr_tb;
		@(negedge clk) ncs=0; nwr=1; nrd=0; a1=0; a0=0;
		@(negedge clk) a1=0; a0=1;
		@(negedge clk) a1=1; a0=0;
		@(negedge clk) a1=1; a0=1;
		@(negedge clk) nrd=1;
		@(negedge clk) start=1;
		@(negedge clk) start=0;
	end
	endtask//
/*	*/	

//*/
	
	//---------------------------------------------------//
	//--------------------- TASKS -----------------------//
	//---------------------------------------------------//
	
	//--------------------- WRITE -----------------------//
	task WRITE;
	begin
		if(nwr==0) begin //nwr validating
			if(a1==0) begin 
				if(a0==0) checker_PLR = checker_din; //PLR loading
				else checker_ULR = checker_din; // ULR loading
			end
			else begin
				if(a0==0) checker_LLR = checker_din; //LLR loading
				else checker_CCR = checker_din;// CCR loading
			end
		end
		//error condition validation 
		if(checker_PLR>checker_ULR) checker_err = 1;//error PLR>ULR
		else if(checker_PLR<checker_LLR) checker_err=1;//error PLR<ULR
		else checker_err=0;// no error
	end
	endtask


	//--------------------- READ -----------------------//
	task READ;
		if(nrd==0) begin// nrd validationg
			if(a1==0) begin
				if(a0==0) checker_din_temp = checker_PLR ;
				else checker_din_temp = checker_ULR;
			end
			else begin
				if(a0==0) checker_din_temp = checker_LLR;
				else checker_din_temp = checker_CCR;
			end
		end
		else checker_din_temp = 8'b0;
	endtask

	//--------------------- START -----------------------//
	task START;
		begin
			checker_start = {checker_start[1],checker_start[0],start};
			if(checker_start==3'b010 && checker_CCR!=0 && checker_err ==0) begin
				checker_start_flag=1;
				DIRECTION;
				COUNT;
			end
		end
	endtask

	wire [1:0] dir_conditions;
	assign  dir_conditions={checker_PLR==checker_ULR,checker_PLR==checker_LLR};


	
	//--------------------- COUNTER ---------------------//
	reg [8:0] cycles;
	task COUNT;
		begin
			
			if(checker_start == 2 && checker_start_flag==1) begin
				checker_cout = checker_PLR;//cycles=cycles-1;
			end
			else begin
				case({dir_conditions[1:0]==3,checker_dir})
		  			2'b00: checker_cout = checker_cout - 1;
					2'b01: checker_cout = checker_cout + 1;
					2'b10: checker_cout = checker_cout;
					2'b11: checker_cout = checker_cout;
					default: checker_cout = checker_cout;
				endcase
			end
			if(checker_cout==checker_PLR) cycles=cycles-1;
			if(cycles==0 && checker_start_flag==1) begin checker_ec=1; checker_start_flag=0;end
			else checker_ec=0;
		end
	endtask

	//--------------------- DIRECTION --------------------//
	task DIRECTION;
		begin
			if(checker_ec==1) begin
				checker_dir=1'b0;
			end
			else if(checker_start == 2 && checker_start_flag==1) begin
				checker_dir=dir_conditions[1]?(dir_conditions[0]?1'b0:0):1;
			end
		  	else begin
				case(checker_dir)
		  			1'b0:begin 
						if(checker_cout == checker_LLR)
		  					if(checker_cout==checker_ULR) checker_dir=0;
							else checker_dir = 1;
						else checker_dir=0;
						end
					1'b1:begin
						if(checker_cout == checker_ULR)
		  					if(checker_cout==checker_LLR) checker_dir=0;
							else checker_dir = 0;
						else checker_dir=1;
						end
				endcase
			
			end
		end
	endtask


	task CYCLES_COUNT;
	begin
		if(checker_CCR==0) cycles=0;
		else if(dir_conditions[1]==1) 
		  if(dir_conditions[0]==1) cycles = checker_CCR;
		  else cycles = checker_CCR+1;
		else
			if(dir_conditions[0]==1) cycles = checker_CCR+1;
			else cycles = 2*checker_CCR+1;
	end
	endtask

	//---------------------------------------------------//
	//--------------------- CHECKER ---------------------//
	//---------------------------------------------------//
	task checker;
	forever@(posedge clk) begin
		if(ncs==0) begin
			if(reset==0) begin
				fork
					if(checker_start_flag==0) begin
						//fork
							checker_ec=0;
							checker_cout=0;
							START;
							if(checker_start_flag==0)WRITE;
							if(checker_start_flag==0)CYCLES_COUNT;
						//join
					end
					else begin
						fork
							checker_start=0;
							COUNT;
							DIRECTION;
						join
					end
					READ;
					//if(checker_CCR!=0 && checker_err ==0 && checker_start_flag==0) START;
				join
			end
			else begin
				checker_PLR = 0;checker_ULR = 255;checker_LLR = 0;checker_CCR = 0;
				checker_dir = 1'b0; checker_err = 0; checker_ec=0; checker_start_flag=0;
				cycles=0;checker_cout=0; 
				checker_start={checker_start[1],checker_start[0],1'b0};
			end
		end
		else begin
			checker_start={checker_start[1],checker_start[0],1'b0};
			checker_start_flag=0;
			checker_cout=0;
			checker_dir=1'b0;
			checker_ec=0;
		end
	end
	endtask
	//---------------------------------------------------//
	//------------------ COMPARISION --------------------//
	//---------------------------------------------------//
	task comparision;
	begin
	forever@(negedge clk) begin
		if(checker_cout==cout /*&& checker_dir==dir*/ && checker_ec == ec && checker_err == err) begin 
		checker_PASS = 1;
		$display("cout--> %d %d, dir--> %d %d, din--> %d %d, err--> %d %d, ec--> %d %d \t PASS" ,checker_cout, cout,  checker_dir,dir,checker_din,din,checker_err,err,checker_ec, ec);
		end
		else begin checker_PASS=0;
		$display("cout--> %d %d, dir--> %d %d, din--> %d %d, err--> %d %d, ec--> %d %d \t XXXX--->FAIL" ,checker_cout, cout,  checker_dir,dir,checker_din,din,checker_err,err,checker_ec, ec);end
	end
	end
	endtask


endmodule



