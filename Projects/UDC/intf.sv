interface updown(input clk);
  logic [7:0] c_out;
  logic dir_o,err_o,ec_o;
  wire [7:0] d_in;
  logic A0_i,A1_i,reset_i, ncs, nwr, nrd, start_i;
  
  clocking cd_driver@(posedge clk);
    input   c_out;
    input   dir_o,err_o,ec_o;
    output  A0_i, A1_i,reset_i,ncs,nwr,nrd,start_i;
	 //input d_in;
    output d_in;
  endclocking
  
  clocking cd_monitor@(posedge clk);
    input  c_out,dir_o,err_o,ec_o,A0_i,A1_i,reset_i,ncs,nwr,nrd,start_i;
	 input  d_in;
	 
  endclocking
endinterface

