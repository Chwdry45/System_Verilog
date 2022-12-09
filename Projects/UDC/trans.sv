class transaction;
byte c_out;
bit reset_i;
bit dir_o,err_o,ec_o;
rand bit [7:0]d_in;
randc bit A0_i,A1_i ;
rand bit nwr, nrd;
rand bit ncs = 0;
rand bit start_i;
 
  
 /* constraint task1{ if({A1_i,A0_i} == 2'b00) d_in inside{10};
                   else if({A1_i,A0_i} == 2'b01) d_in inside{15};
                   else if({A1_i,A0_i} == 2'b10) d_in inside{5};
                   else if({A1_i,A0_i} == 2'b11) d_in inside{5};
  					};

  
  /*constraint task2 { if({A1_i,A0_i} == 2'b10)  d_in inside{10};
					else if({A1_i,A0_i} == 2'b01) d_in inside{10};
                    else if({A1_i,A0_i} == 2'b00) d_in inside{10};
					else d_in inside{5};

	};*/
	constraint task1{ soft ncs == 0;
			  				soft nrd == 1;
							soft nwr == 1;
							soft start_i == 0;
							soft A0_i == A0_i;
							soft A1_i == A1_i;
							soft d_in == d_in;
	}

endclass

