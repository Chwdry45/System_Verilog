/*
 *UP_DOWN_COUNTER  dut(.c_out(h_intf.c_out),.dir_o(h_intf.dir_o),.err_o(h_intf.err_o),.ec_o(h_intf.ec_o),.d_in(h_intf.d_in),.A0_i(h_intf.A0_i),.A1_i(h_intf.A1_i),.reset_i(h_intf.reset_i),.ncs(h_intf.ncs),.nwr(h_intf.nwr),.nrd(h_intf.nrd),.clock_i(h_intf.clock_i),.start_i(h_intf.start_i));
 */
//`timescale 1ns/1ps
module UP_DOWN_COUNTER ( d_in, ncs, nrd, nwr, A0_i, A1_i, clock_i, start_i, reset_i, c_out, err_o, dir_o, ec_o ) ;
//input and output signals
inout wire [7:0]d_in ;
input wire ncs ;
input wire nrd ;
input wire nwr ;
input wire A0_i ;
input wire A1_i ;
input wire clock_i ;
input wire start_i ;
input wire reset_i ;
output reg [7:0]c_out ;
output reg dir_o ;
output reg err_o ;
output reg ec_o ;
// internal registers and wires
reg [7:0]PLR ;
reg [7:0]ULR ;
reg [7:0]LLR ;
reg [7:0]CCR ;
reg [7:0]dataout ;
reg [7:0]cycle_count ;
reg posedge_start ;
reg stop_downcount ;
reg stop_upcount;
reg start_upcount ;
reg stop_load_plr ;
//wire [7:0]data ;
assign d_in = (!nrd && !ncs && nwr ) ? dataout : 8'hz ;  // read operation   
always @(*)
   begin
     if (nrd == 1'b0 && nwr == 1'b0 && ncs == 1'b0) 
         dataout <= 8'h0 ;
     else if ( A0_i == 1'b0 && A1_i == 1'b0 && nrd == 1'b0 && ncs == 1'b0 && nwr)
          dataout <= PLR ;
     else if ( A0_i == 1'b1 && A1_i == 1'b0 && nrd == 1'b0 && ncs == 1'b0 && nwr)
          dataout <= ULR  ;
     else if ( A0_i == 1'b0 && A1_i == 1'b1 && nrd == 1'b0 && ncs == 1'b0 && nwr)
          dataout <= LLR;
     else if ( A0_i == 1'b1 && A1_i == 1'b1 && nrd == 1'b0 && ncs == 1'b0 && nwr)
          dataout <= CCR ;
     else
         dataout <= 8'h0 ;
   end
// posedge_start signal is generated after detecting the start_i pulse 
always @ (posedge clock_i)        
   begin
     if (reset_i)
         posedge_start <= 1'b0 ;
     else
       begin
         if ( nwr == 1'b0 && nrd == 1'b0 )
             posedge_start <= 1'b0 ;
         else if ( start_i == 1'b1 )
             posedge_start <= 1'b1 ;  
         else if ( cycle_count == 8'b0 )
             posedge_start <= 1'b0 ;
         else if ( PLR < LLR || PLR > ULR )
             posedge_start <= 1'b0 ;
         else
             posedge_start <= posedge_start ;
       end
   end
always @ (posedge clock_i)   // Loading PLR //      
   begin
      if (reset_i) 
          PLR <= 8'h0 ;
      else if ( !nwr && !ncs && !A0_i && !A1_i && !posedge_start && nrd)
          PLR <= d_in ;
      else 
          PLR <= PLR ;
   end
always @ (posedge clock_i) // Loading ULR //  
   begin
      if (reset_i) 
          ULR <= 8'hff ;
      else if ( !nwr && !ncs && A0_i && !A1_i && !posedge_start && nrd)
          ULR <= d_in ;
      else 
          ULR <= ULR ;
   end
always @ (posedge clock_i)  // Loading LLR //  
   begin
      if (reset_i) 
          LLR <= 8'h0 ;
      else if ( !nwr && !ncs && !A0_i && A1_i && !posedge_start && nrd)
          LLR <= d_in ;
      else 
          LLR <= LLR ;
   end
always @ (posedge clock_i) // Loading CCR //  
   begin
      if (reset_i) 
          CCR <= 8'h0 ;
      else if ( !nwr && !ncs  && A0_i && A1_i && !posedge_start && nrd)
          CCR <= d_in ;
      else 
          CCR <= CCR ;
   end
always @ (posedge clock_i) // error signal generation
   begin
      if (reset_i)
          err_o <= 1'b0 ;
      else if ( start_i && (PLR < LLR || PLR > ULR) )
          err_o <= 1'b1 ;
      else if (start_i && PLR >= LLR && PLR <= ULR)
          err_o <= 1'b0 ;
      else 
          err_o <= err_o ;
   end
always @ (posedge clock_i) // end of count signal generation
   begin
      if (reset_i)
           ec_o <= 1'b0 ;
      else if(!ncs&&!nwr&&!nrd&&start_i)
   	   ec_o<= ec_o;
      else if ( posedge_start && (PLR < LLR || PLR > ULR))
          ec_o <= 1'd0 ;
      else if ( cycle_count == 8'd0 && !start_i && posedge_start && ( nwr | nrd))
           ec_o <= 1'b1 ;
      else if ( start_i && !posedge_start )
           ec_o <= 1'b0 ;
      else 
           ec_o <= ec_o ;
   end
always @ (posedge clock_i) // generation of updown count signal c_out
   begin
      if (reset_i)
          c_out <= 8'h0 ;
      else if ( start_i && (PLR < LLR || PLR > ULR))
          c_out <= 8'd0 ;
      else if (start_i && stop_load_plr == 1'b0 && ( nwr | nrd ))
          c_out <= PLR ;
      else if ( (PLR == ULR) && (PLR == LLR) && cycle_count != 8'h0 && posedge_start)
            c_out <= c_out ;
      else if ( posedge_start && (PLR > LLR) && (PLR < ULR) && (c_out < ULR) && cycle_count != 8'h0 && stop_upcount == 1'b0 && start_upcount == 1'b0 && (PLR >= (LLR + 8'h02)) && (PLR <= (ULR - 8'h02)) )
          c_out <= c_out + 8'h01 ;
      else if ( posedge_start  && (PLR > LLR) && (PLR < ULR) && ( c_out > LLR ) && stop_downcount == 1'b0 && cycle_count != 8'h0  && (PLR >= (LLR + 8'h02)) && (PLR <= (ULR - 8'h02)))
          c_out <= c_out - 8'h01 ;
      else if ( posedge_start &&  (PLR > LLR) && (PLR < ULR) && (c_out < PLR) && cycle_count != 8'h0  && (PLR >= (LLR + 8'h02)) && (PLR <= (ULR - 8'h02)))
          c_out <= c_out + 8'h01 ;
      else if ( posedge_start && (PLR > LLR) && (PLR < ULR) && (c_out < ULR) && cycle_count != 8'h0 && stop_upcount == 1'b0 && (PLR == (LLR + 8'h01)) && (PLR == (ULR - 8'h01)) )
          c_out <= c_out + 8'h01 ;
      else if ( posedge_start && (PLR > LLR) && (PLR < ULR) && ( c_out > LLR ) && stop_downcount == 1'b0 && cycle_count != 8'h0  && (PLR == (LLR + 8'h01)) && (PLR == (ULR - 8'h01)))
          c_out <= c_out - 8'h01 ;
      else if ( posedge_start && (PLR > LLR) && (PLR < ULR) && (c_out < PLR) && cycle_count != 8'h0  && (PLR == (LLR + 8'h01)) && (PLR == (ULR - 8'h01)))
          c_out <= c_out + 8'h01 ;
      else if ( posedge_start && (PLR == LLR) && (PLR < ULR) && (c_out < ULR) && cycle_count != 8'h0 && !(stop_upcount) && ( ULR >= PLR + 8'h02)) 
          c_out <= c_out + 8'h01 ;
      else if ( posedge_start  && (PLR == LLR) && (PLR < ULR) && (c_out < ULR) && cycle_count != 8'h0 && ( PLR == ULR - 8'h01)) 
          c_out <= c_out + 8'h01 ;
      else if ( posedge_start  && (PLR == LLR) && (PLR < ULR) && (c_out > LLR) && cycle_count != 8'h0 )
          c_out <= c_out - 8'h01 ;
      else if ( posedge_start && (PLR == ULR) && (PLR > LLR) && (c_out > LLR) && cycle_count != 8'h0 && !(stop_downcount) && ( LLR <= PLR - 8'h02) ) 
          c_out <= c_out - 8'h01 ;
      else if ( posedge_start && (PLR == ULR) && (PLR > LLR) && (c_out > LLR) && cycle_count != 8'h0 && ( LLR == PLR - 8'h01) ) 
          c_out <= c_out - 8'h01 ;
      else if ( posedge_start && (PLR == ULR) && (PLR > LLR) && (c_out < ULR) && cycle_count != 8'h0 )
          c_out <= c_out + 8'h01 ;
      else 
          c_out <= c_out ;
   end
always @ (posedge clock_i) // stop_load_plr is used to not to load the c_out with PLR again, after the cycle is done
   begin
     if ( reset_i )
         stop_load_plr <= 1'b0 ;
     else if ( start_i )
         stop_load_plr <= 1'b1 ;
     else if ( ec_o == 1'b1 || (nwr == 1'b0 && posedge_start != 1'b1) || err_o == 1'b1)
         stop_load_plr <= 1'b0 ;
    else 
        stop_load_plr <= stop_load_plr ;
   end
always @ (posedge clock_i)  // cycle count to count the number of cycles 
   begin
      if (reset_i)
           cycle_count <= 8'h0 ;
      else if (start_i && stop_load_plr == 1'b0)
           cycle_count <= CCR ;
      else if ( (PLR == ULR) && (PLR == LLR) && cycle_count != 8'h0 && posedge_start)
           cycle_count <= cycle_count - 8'h01;
      else if ( PLR >= (LLR + 8'h02) && PLR <= (ULR - 8'h02) )
        begin
          if ((c_out == (PLR - 8'h01)) && cycle_count != 8'h0 && stop_downcount == 1'b1)
              cycle_count <= cycle_count - 8'h01;
        end
      else if ( (PLR == ( LLR + 8'h01 )) && ( PLR == ( ULR - 8'h01)) )
        begin
          if ( c_out == LLR && cycle_count != 8'h0 && stop_upcount == 1'b1 )
              cycle_count <= cycle_count - 8'h01 ;
        end
      else if ( (PLR == LLR) && (PLR <= ULR - 8'h02 ) && cycle_count != 8'h0 && stop_upcount == 1'b1 && c_out== (PLR + 8'h01) ) 
           cycle_count <= cycle_count - 8'h01 ;
      else if ( (PLR == LLR) && (PLR == ULR - 8'h01 ) && cycle_count != 8'h0 && c_out == ULR ) 
           cycle_count <= cycle_count - 8'h01 ;
      else if ( (PLR == ULR) && (PLR >= LLR + 8'h02 ) && cycle_count != 8'h0 && stop_downcount == 1'b1 && c_out== (PLR - 8'h01) ) 
           cycle_count <= cycle_count - 8'h01 ;
      else if ( (PLR == ULR) && (PLR == LLR + 8'h01 ) && cycle_count != 8'h0 && c_out == LLR ) 
           cycle_count <= cycle_count - 8'h01 ;
      else 
           cycle_count <= cycle_count ;
   end
always @ (posedge clock_i)  //direction signal 
   begin
      if (reset_i || CCR == 8'd0)
           dir_o <= 1'b0 ;
      else if ( (PLR == ULR) && (PLR == LLR) && cycle_count != 8'h0 && posedge_start)
           dir_o <= dir_o ;
      else if ( ((PLR == LLR) && (ULR == PLR + 8'h01)) && c_out < ULR && posedge_start && cycle_count != 8'h0)
           dir_o <= 1'b1 ;
      else if ( ((PLR == LLR) && (ULR == PLR + 8'h01)) && c_out > LLR && posedge_start)
           dir_o <= 1'b0 ;
      else if ( c_out > LLR && (PLR == ULR) && (LLR == PLR - 8'h01) && posedge_start && cycle_count != 8'h0)
           dir_o <= 1'b0 ;
      else if ( c_out < ULR && (PLR == ULR) && (LLR == PLR - 8'h01) && posedge_start)
           dir_o <= 1'b1 ;
      else if (start_i && !posedge_start && (PLR != ULR) && (PLR >= LLR) && (PLR <= ULR))
           dir_o <= 1'b1 ;
      else if ( posedge_start && (PLR >= LLR) && (PLR <= ULR) && (c_out < ULR) && !stop_upcount && !start_upcount && cycle_count != 8'h0 )
           dir_o <= 1'b1 ;
      else if ( posedge_start && (PLR >= LLR) && (PLR <= ULR) && ( c_out > LLR ) && !stop_downcount && cycle_count != 8'h0)
           dir_o <= 1'b0 ;
      else if ( posedge_start && (PLR >= LLR) && (PLR <= ULR) && (c_out < PLR) && cycle_count != 8'h0)
           dir_o <= 1'b1 ;
      else 
           dir_o <= dir_o ;
   end
always @ (posedge clock_i)  // start_upcount is a signal used to start_i the upcount of the c_out signal
   begin
     if (reset_i)
         start_upcount <= 1'b0 ;
     else if ( PLR >= (LLR + 8'h02) && PLR <= (ULR - 8'h02) )
       begin
         if ((c_out == LLR) && posedge_start )
             start_upcount <= 1'b1 ;
         else if ((c_out == (PLR - 8'h01)) && posedge_start)
             start_upcount <= 1'b0 ;
         else 
             start_upcount <= start_upcount ;
       end
    else if ( (PLR == ( LLR + 8'h01 )) && ( PLR == ( ULR - 8'h01)) )
      begin
        if ((c_out == PLR) && posedge_start )
            start_upcount <= 1'b0 ;
        else if ((c_out == LLR) && posedge_start)
            start_upcount <= 1'b1 ;
         else 
             start_upcount <= start_upcount ;
     end
     else 
         start_upcount <= start_upcount ;
   end
always @ (posedge clock_i)  // stop_upcount signal is used to stop the upcount of the signal when done
   begin
     if (reset_i)
         stop_upcount <= 1'b0 ;
     else if ( PLR == LLR && PLR < ULR && c_out == PLR + 8'h01 && PLR == ULR - 8'h02 )
         stop_upcount <= 1'b0 ;
    // else if ( (PLR == LLR) && ( PLR < ULR) &&  c_out == PLR + 8'h01 && stop_downcount )
        // stop_upcount <= 1'b0 ;
     else if ((c_out == ULR) && posedge_start )
         stop_upcount <= 1'b1 ;
     else if (c_out == LLR && posedge_start)
         stop_upcount <= 1'b0 ;
     else if (ec_o ) 
         stop_upcount <= 1'b0 ;
     else 
         stop_upcount <= stop_upcount ;
   end
always @ (posedge clock_i)  // stop_downcount is a signal which is used to stop the downcount of the c_out
   begin
     if (reset_i)
         stop_downcount <= 1'b0 ;
     else if ( (PLR == LLR) && ( PLR < ULR) )
       begin
         //if ( c_out == PLR + 8'h02 && stop_upcount)
         //  stop_downcount <= 1'b1 ;
	//	$display("am i usefull in this loop");
        // else
           stop_downcount <= 1'b0 ;
       end
     else if ( PLR == ULR && LLR < PLR && posedge_start && c_out == PLR - 8'h01 && stop_upcount == 1'b0)
         stop_downcount <= 1'b0 ;
     else if ((c_out == LLR) && posedge_start )
         stop_downcount <= 1'b1 ;
     else if (posedge_start && c_out == PLR)
         stop_downcount <= 1'b0 ;
     else if (ec_o ) 
         stop_downcount <= 1'b0 ;
     else 
         stop_downcount <= stop_downcount ;
   end
endmodule


