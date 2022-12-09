module tb;
  	bit clk;
  always #2 clk++;

  updown h_intf(clk);
  test h_test;



  UP_DOWN_COUNTER  dut(.c_out(h_intf.c_out),.dir_o(h_intf.dir_o),.err_o(h_intf.err_o),.ec_o(h_intf.ec_o),.d_in(h_intf.d_in),.A0_i(h_intf.A0_i),.A1_i(h_intf.A1_i),.reset_i(h_intf.reset_i),.ncs(h_intf.ncs),.nwr(h_intf.nwr),.nrd(h_intf.nrd),.clock_i(h_intf.clk),.start_i(h_intf.start_i));


  initial begin
    h_test = new(h_intf);
    h_test.run;
  end

  initial begin
    #3500; $finish(2);
  end

endmodule

