module UP_DOWN_COUNTER(output [7:0] c_out, output dir_o,err_o,ec_o,
					 inout [7:0] d_in, input A0_i,A1_i,
					 input clock_i, reset_i, ncs, nwr, nrd, start_i);

	//---------------------------------------------------//
	//==============Registers required===================//
	//---------------------------------------------------//

	//============ Default registers PLR, ULR, LLR, CCR===============//
	reg [7:0] PRELOAD_REGISTER, UPPER_LIMIT_REGISTER, LOWER_LIMIT_REGISTER, CYCLE_COUNT_REGISTER;
	
	reg [7:0] PLR_next, ULR_next, LLR_next, CCR_next; //next state registers of PLR,LLR,ULR,CCR;

	reg [1:0] start_pulse_count, start_pulse_count_next; //to count start pulse width

	reg direction_reg, direction_next; //for direction

	reg [7:0] c_out_reg, c_out_next; //for counter output

	reg [8:0] cycles_reg, cycles_next; //for counting cycles

	reg ec_o_reg,ec_o_next=0; // to end of count

	reg start_flag=0, start_flag_next=0; //to start the counter

	reg [8:0]total_cycles;

	reg [7:0] temp_din;

	reg err_oo;
	

	//---------------------------------------------------//	
	//=================== FLIP-FLOP =====================//
	//---------------------------------------------------//
	always@(posedge clock_i,ncs) begin
		if(ncs==0) begin
		if(reset_i==1) begin 						//reset conditions of FF's
			PRELOAD_REGISTER <= 8'b0;				//PLR = 0
			UPPER_LIMIT_REGISTER <= 8'hff;	//ULR = 8'hff
			LOWER_LIMIT_REGISTER <= 8'b0;			//LLR = 0
			CYCLE_COUNT_REGISTER <= 8'b0;			//CCR = 0
			start_pulse_count <= 0;	//start pulse count = 0
			direction_reg <= 1'b0;					//direction = 0
			c_out_reg <= 8'b0;						//counter output = 0
			cycles_reg <= 9'b0;						//cycles count = 0
			start_flag <= 1'b0;
			ec_o_reg <= 0;
		end
		else begin 													//FF's created for
			PRELOAD_REGISTER <= PLR_next;						// PLR
			UPPER_LIMIT_REGISTER <= ULR_next;				// ULR
			LOWER_LIMIT_REGISTER <= LLR_next;				// LLR
			CYCLE_COUNT_REGISTER <= CCR_next;				// CCR
			start_pulse_count <= start_pulse_count_next;	// start pulse counting
			direction_reg <= direction_next;					// direction 
			c_out_reg <= c_out_next;							// counter output
			cycles_reg <= cycles_next;							// number of cycles
			start_flag <= start_flag_next;
			ec_o_reg <= ec_o_next;
		end
		end
		else begin
			PRELOAD_REGISTER <= PRELOAD_REGISTER;						// PLR
			UPPER_LIMIT_REGISTER <= UPPER_LIMIT_REGISTER;				// ULR
			LOWER_LIMIT_REGISTER <= LOWER_LIMIT_REGISTER;				// LLR
			CYCLE_COUNT_REGISTER <= CYCLE_COUNT_REGISTER;				// CCR
			start_pulse_count <= start_pulse_count_next;	// start pulse counting
			direction_reg <= 0;					// direction 
			c_out_reg <= 0;							// counter output
			cycles_reg <= 0;							// number of cycles
			start_flag <= 1'b0;
			ec_o_reg <= 0;
		end
	end

	//---------------------------------------------------//
	//============== WRITE & READ enabling ==============//
	//---------------------------------------------------//
	
	reg [3:0] WR_Enable;
	//condition checking to enable either read or write or both or none
	always@(nwr,ncs,nrd) begin
		if(ncs==1) begin WR_Enable = 4'b0000; end		//if ncs is 1 then no read or write operation need to be done
		else begin
			case({nwr,nrd})
		  		2'b00: WR_Enable = 4'b0001; // READ AND WRITE 
				2'b01: WR_Enable = 4'b0010; // WRITE 
				2'b10: WR_Enable = 4'b0100; // READ
				2'b11: WR_Enable = 4'b1000; // NONE
				default : WR_Enable = 4'b0000;
			endcase
		end
	end


	//---------------------------------------------------//
	//========== Register enabling for Writing ==========//
	//---------------------------------------------------//
	reg [3:0] Reg_Enable; // to enable only selected register
	wire write_en = (WR_Enable[1]|WR_Enable[0])&(~start_flag_next);
	always@(*) begin
		if(write_en==1) begin
			case({A1_i,A0_i})
		  		2'b00: Reg_Enable = 4'b0001; // PLR
				2'b01: Reg_Enable = 4'b0010; // ULR 
				2'b10: Reg_Enable = 4'b0100; // LLR
				2'b11: Reg_Enable = 4'b1000; // CCR
				default : Reg_Enable = 4'b0000; //default
			endcase
		end
		else Reg_Enable = 4'b0000; //default
	end

	//---------------------------------------------------//
	//======================== WRITE ====================//
	//---------------------------------------------------//
	always@(*) begin
		PLR_next = PRELOAD_REGISTER;
		ULR_next = UPPER_LIMIT_REGISTER;
		LLR_next = LOWER_LIMIT_REGISTER;
		CCR_next = CYCLE_COUNT_REGISTER;
		
		// PLR loading
		if(Reg_Enable[0] == 1'b1) begin 
			PLR_next = d_in;
		end

		// ULR loading
		if(Reg_Enable[1] == 1'b1) begin 
			ULR_next = d_in;
		end

		// LLR loading
		if(Reg_Enable[2] == 1'b1) begin 
			LLR_next = d_in;
		end

		// CCR loading
		if(Reg_Enable[3] == 1'b1) begin 
			CCR_next = d_in;
		end
	end

	//---------------------------------------------------//
	//====================== READ =======================//
	//---------------------------------------------------//
	assign d_in = (WR_Enable[2])?temp_din:8'hz; //din bidrection code
	always@(posedge clock_i) begin
		if(WR_Enable[2]) begin //enable checking
			case({A1_i,A0_i})
		  		2'b00: temp_din = PRELOAD_REGISTER; // PLR
				2'b01: temp_din = UPPER_LIMIT_REGISTER; // ULR 
				2'b10: temp_din = LOWER_LIMIT_REGISTER; // LLR
				2'b11: temp_din = CYCLE_COUNT_REGISTER; // CCR
				default : temp_din = 8'b0000_0000; //default
			endcase
		end
		else temp_din = 8'b0;
	end

	//---------------------------------------------------//
	//===================== ERROR =======================//
	//---------------------------------------------------//
	// if PLR > ULR or PLR < LLR then error is raised
	always@(*) begin 
		case({(PRELOAD_REGISTER > UPPER_LIMIT_REGISTER),(PRELOAD_REGISTER<LOWER_LIMIT_REGISTER)})
		  2'b00: err_oo = 0;
		  2'b01: err_oo = 1;
		  2'b10: err_oo = 1;
		  2'b11: err_oo = 1;
		  default: err_oo = 1;
		 endcase
	end


	//---------------------------------------------------//
	//===================== START PULSE =================//
	//---------------------------------------------------//
	// if ncs is 1 or start flag raised previously or if error is present or if
	// total cycles required is 0 then start not to be done
	wire start_pulse_count_en = ncs|start_flag_next;//|(CYCLE_COUNT_REGISTER==8'b0);//ACTIVE LOW enable
	always@(*) begin
		if(start_pulse_count_en == 1'b0) begin //checking wheather the start pluse FF is enable or not
			if(start_i) begin //checking for high signal start
				//combinational circuit to check start signal width either matches
				//with one clock pulse or not
				
				start_pulse_count_next[1] = start_pulse_count[0]|start_pulse_count[1];
				start_pulse_count_next[0] = ~start_pulse_count_next[1];

				//count is 1 if start pulse is given for only one clock period
				//count is 2 if start pulse is given for more than one clock period
				//count is 0 if start is not given
			end
			else start_pulse_count_next = 2'b0; // if start is 0 default next value is zero
		end
		else start_pulse_count_next = start_pulse_count;
	end
	
	//start flag is high when start pulse count is 1
	always@(*) begin
		if(start_i== 1'b0 && start_pulse_count == 2'b1 && err_oo == 1'b0 &&(CYCLE_COUNT_REGISTER!=8'b0)) start_flag_next=1'b1;
		else if(/*start_flag==1 &&*/total_cycles == cycles_reg) start_flag_next=1'b0;
		else start_flag_next=start_flag;
	//	if(start_i==1) start_flag_next = (start_pulse_count_next==1)?1:0;			
	end


/*
	always@(*) begin
		if(start_i) begin
			if(start_i==1 && start_flag==1)
				start_flag_next=0;
			else start_flag_next=1;
		end
		else start_flag_next = start_flag; // if start is 0 default next value is zero
	end
	*/
	
	//---------------------------------------------------//
	//===================== DIRECTION ===================//
	//---------------------------------------------------//	
	always@(*)begin
		if(start_flag_next==1'b1) begin// enabling only when start pulse is given correctly
			if(start_flag==1'b0 && start_flag_next==1'b1) begin // initial conditions
				//if PLR and ULR are equal, direction need to be down counting
				if(PRELOAD_REGISTER==UPPER_LIMIT_REGISTER) direction_next=1'b0; 
				// if PLR and LLR are equal, direction need to be up counting
				// else if (PRELOAD_REGISTER==LOWER_LIMIT_REGISTER)direction_next = 1'b1;
				// default condition is up counting
				else direction_next=1'b1;
			end
			else begin
				// direction updation
				if(ec_o_next==0) begin	
				if(direction_reg==1'b1) begin
					//if direction is upcounting value is by default 1, 
					//when counter reaches ULR direction need to change to down counting i.e., 0
					direction_next = (c_out_next==UPPER_LIMIT_REGISTER)? ((c_out_next==LOWER_LIMIT_REGISTER)? direction_reg:1'b0):1'b1;
				end
				else begin
					//if direction is down counting value is by default 0, 
					//when counter reaches LLR direction need to change to up counting i.e., 0
					direction_next = (c_out_next==LOWER_LIMIT_REGISTER)? ((c_out_next==UPPER_LIMIT_REGISTER)?0:1): 1'b0;
				end
				end
			else direction_next=0;
			end
		end
		else direction_next=1'b0; //if start is not given default direction is 0
	end

	//---------------------------------------------------//
	//=================== COUNTER =======================//
	//---------------------------------------------------//
	always@(*) begin
		// counter updation
		if(start_flag_next==1'b1 && err_o ==0) begin
			if(start_flag==1'b0 && start_flag_next==1'b1) begin //initial conditions
			c_out_next = PRELOAD_REGISTER; //PLR vaule is loaded to counter
			end
			else 
			// all data registers are equal then no updation need to be done
			if(PRELOAD_REGISTER==UPPER_LIMIT_REGISTER && PRELOAD_REGISTER==LOWER_LIMIT_REGISTER) begin
				c_out_next = c_out_reg;
			end
			//if all registers are not equal then based on direction the counter updation is done.
			//if direction is 1 counter value is incremented by 1
			//if direction is 0 counter value is decremented by 1
			else begin c_out_next = (direction_reg==1'b1)?c_out_reg + 8'b1:c_out_reg - 8'b1; end
		end
		else c_out_next = 8'b0;//by default counter value is 0
	end

	//---------------------------------------------------//
	//==================== CYCLES =======================//
	//---------------------------------------------------//	
	always@(*) begin
		if(CYCLE_COUNT_REGISTER!=8'b0) begin // if CCR is not 0 i.e., CCR had a particular value 
		// total cycles represents the number of times the Counter out matches with PLR 
			case({PRELOAD_REGISTER==UPPER_LIMIT_REGISTER , PRELOAD_REGISTER==LOWER_LIMIT_REGISTER})
		  		2'b00: total_cycles = 2*CYCLE_COUNT_REGISTER+1;// if PLR!=ULR and PLR!=LLR, condition is 2*CCR;
		  		2'b01: total_cycles = CYCLE_COUNT_REGISTER+1;	// if PLR==LLR condition is CCR
		  		2'b10: total_cycles = CYCLE_COUNT_REGISTER+1;	// if PLR==ULR condition is CCR
		  		2'b11: total_cycles = CYCLE_COUNT_REGISTER;// if PLR==LLR and PLR==ULR condition is CCR-1
				default: total_cycles = 9'b0;
			endcase
		end
		else total_cycles=9'b0;
	end

	always@(*) begin
		//if counter is not started or CCR is zero then by default next state of cycles FF is 0
		if(start_flag_next==1'b0 || CYCLE_COUNT_REGISTER ==8'b0 ||total_cycles == cycles_reg) begin
			cycles_next=9'b0;
		end
		else if(c_out_next == PRELOAD_REGISTER && start_flag_next ==1'b1) begin 
			cycles_next=cycles_reg+1;//if counter is equals to PLR then cycles count is incremented
		end
		else cycles_next = cycles_reg;//above conditions fails them cycles count won't change
	end

	always@(*) begin
		if(total_cycles == cycles_next && start_flag_next==1'b1 ) ec_o_next=1'b1;
		else ec_o_next = 1'b0;
	end


	//---------------------------------------------------//
	//=================== OUTPUT ========================//
	//---------------------------------------------------//
	assign c_out = c_out_reg;
	assign dir_o = direction_reg;
	assign ec_o = ec_o_reg;
	assign err_o = err_oo;
endmodule
