
//`timescale 1ns/1ps
module UP_DOWN_COUNTER ( din, ncs, nrd, nwr, a0, a1, clk, start, reset, cout, err, dir, ec ) ;
//input and output signals
inout wire [7:0]din ;
input wire ncs ;
input wire nrd ;
input wire nwr ;
input wire a0 ;
input wire a1 ;
input wire clk ;
input wire start ;
input wire reset ;
output reg [7:0]cout ;
output reg dir ;
output reg err ;
output reg ec ;
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
assign din = (!nrd && !ncs && nwr ) ? dataout : 8'hz ;  // read operation   
always @(*)
   begin
     if (nrd == 1'b0 && nwr == 1'b0 && ncs == 1'b0) 
         dataout <= 8'h0 ;
     else if ( a0 == 1'b0 && a1 == 1'b0 && nrd == 1'b0 && ncs == 1'b0 && nwr)
          dataout <= PLR ;
     else if ( a0 == 1'b1 && a1 == 1'b0 && nrd == 1'b0 && ncs == 1'b0 && nwr)
          dataout <= ULR  ;
     else if ( a0 == 1'b0 && a1 == 1'b1 && nrd == 1'b0 && ncs == 1'b0 && nwr)
          dataout <= LLR;
     else if ( a0 == 1'b1 && a1 == 1'b1 && nrd == 1'b0 && ncs == 1'b0 && nwr)
          dataout <= CCR ;
     else
         dataout <= 8'h0 ;
   end
// posedge_start signal is generated after detecting the start pulse 
always @ (posedge clk)        
   begin
     if (reset)
         posedge_start <= 1'b0 ;
     else
       begin
         if ( nwr == 1'b0 && nrd == 1'b0 )
             posedge_start <= 1'b0 ;
         else if ( start == 1'b1 )
             posedge_start <= 1'b1 ;  
         else if ( cycle_count == 8'b0 )
             posedge_start <= 1'b0 ;
         else if ( PLR < LLR || PLR > ULR )
             posedge_start <= 1'b0 ;
         else
             posedge_start <= posedge_start ;
       end
   end
always @ (posedge clk)   // Loading PLR //      
   begin
      if (reset) 
          PLR <= 8'h0 ;
      else if ( !nwr && !ncs && !a0 && !a1 && !posedge_start && nrd)
          PLR <= din ;
      else 
          PLR <= PLR ;
   end
always @ (posedge clk) // Loading ULR //  
   begin
      if (reset) 
          ULR <= 8'hff ;
      else if ( !nwr && !ncs && a0 && !a1 && !posedge_start && nrd)
          ULR <= din ;
      else 
          ULR <= ULR ;
   end
always @ (posedge clk)  // Loading LLR //  
   begin
      if (reset) 
          LLR <= 8'h0 ;
      else if ( !nwr && !ncs && !a0 && a1 && !posedge_start && nrd)
          LLR <= din ;
      else 
          LLR <= LLR ;
   end
always @ (posedge clk) // Loading CCR //  
   begin
      if (reset) 
          CCR <= 8'h0 ;
      else if ( !nwr && !ncs  && a0 && a1 && !posedge_start && nrd)
          CCR <= din ;
      else 
          CCR <= CCR ;
   end
always @ (posedge clk) // error signal generation
   begin
      if (reset)
          err <= 1'b0 ;
      else if ( start && (PLR < LLR || PLR > ULR) )
          err <= 1'b1 ;
      else if (start && PLR >= LLR && PLR <= ULR)
          err <= 1'b0 ;
      else 
          err <= err ;
   end
always @ (posedge clk) // end of count signal generation
   begin
      if (reset)
           ec <= 1'b0 ;
      else if(!ncs&&!nwr&&!nrd&&start)
   	   ec<= ec;
      else if ( posedge_start && (PLR < LLR || PLR > ULR))
          ec <= 1'd0 ;
      else if ( cycle_count == 8'd0 && !start && posedge_start && ( nwr | nrd))
           ec <= 1'b1 ;
      else if ( start && !posedge_start )
           ec <= 1'b0 ;
      else 
           ec <= ec ;
   end
always @ (posedge clk) // generation of updown count signal cout
   begin
      if (reset)
          cout <= 8'h0 ;
      else if ( start && (PLR < LLR || PLR > ULR))
          cout <= 8'd0 ;
      else if (start && stop_load_plr == 1'b0 && ( nwr | nrd ))
          cout <= PLR ;
      else if ( (PLR == ULR) && (PLR == LLR) && cycle_count != 8'h0 && posedge_start)
            cout <= cout ;
      else if ( posedge_start && (PLR > LLR) && (PLR < ULR) && (cout < ULR) && cycle_count != 8'h0 && stop_upcount == 1'b0 && start_upcount == 1'b0 && (PLR >= (LLR + 8'h02)) && (PLR <= (ULR - 8'h02)) )
          cout <= cout + 8'h01 ;
      else if ( posedge_start  && (PLR > LLR) && (PLR < ULR) && ( cout > LLR ) && stop_downcount == 1'b0 && cycle_count != 8'h0  && (PLR >= (LLR + 8'h02)) && (PLR <= (ULR - 8'h02)))
          cout <= cout - 8'h01 ;
      else if ( posedge_start &&  (PLR > LLR) && (PLR < ULR) && (cout < PLR) && cycle_count != 8'h0  && (PLR >= (LLR + 8'h02)) && (PLR <= (ULR - 8'h02)))
          cout <= cout + 8'h01 ;
      else if ( posedge_start && (PLR > LLR) && (PLR < ULR) && (cout < ULR) && cycle_count != 8'h0 && stop_upcount == 1'b0 && (PLR == (LLR + 8'h01)) && (PLR == (ULR - 8'h01)) )
          cout <= cout + 8'h01 ;
      else if ( posedge_start && (PLR > LLR) && (PLR < ULR) && ( cout > LLR ) && stop_downcount == 1'b0 && cycle_count != 8'h0  && (PLR == (LLR + 8'h01)) && (PLR == (ULR - 8'h01)))
          cout <= cout - 8'h01 ;
      else if ( posedge_start && (PLR > LLR) && (PLR < ULR) && (cout < PLR) && cycle_count != 8'h0  && (PLR == (LLR + 8'h01)) && (PLR == (ULR - 8'h01)))
          cout <= cout + 8'h01 ;
      else if ( posedge_start && (PLR == LLR) && (PLR < ULR) && (cout < ULR) && cycle_count != 8'h0 && !(stop_upcount) && ( ULR >= PLR + 8'h02)) 
          cout <= cout + 8'h01 ;
      else if ( posedge_start  && (PLR == LLR) && (PLR < ULR) && (cout < ULR) && cycle_count != 8'h0 && ( PLR == ULR - 8'h01)) 
          cout <= cout + 8'h01 ;
      else if ( posedge_start  && (PLR == LLR) && (PLR < ULR) && (cout > LLR) && cycle_count != 8'h0 )
          cout <= cout - 8'h01 ;
      else if ( posedge_start && (PLR == ULR) && (PLR > LLR) && (cout > LLR) && cycle_count != 8'h0 && !(stop_downcount) && ( LLR <= PLR - 8'h02) ) 
          cout <= cout - 8'h01 ;
      else if ( posedge_start && (PLR == ULR) && (PLR > LLR) && (cout > LLR) && cycle_count != 8'h0 && ( LLR == PLR - 8'h01) ) 
          cout <= cout - 8'h01 ;
      else if ( posedge_start && (PLR == ULR) && (PLR > LLR) && (cout < ULR) && cycle_count != 8'h0 )
          cout <= cout + 8'h01 ;
      else 
          cout <= cout ;
   end
always @ (posedge clk) // stop_load_plr is used to not to load the cout with PLR again, after the cycle is done
   begin
     if ( reset )
         stop_load_plr <= 1'b0 ;
     else if ( start )
         stop_load_plr <= 1'b1 ;
     else if ( ec == 1'b1 || (nwr == 1'b0 && posedge_start != 1'b1) || err == 1'b1)
         stop_load_plr <= 1'b0 ;
    else 
        stop_load_plr <= stop_load_plr ;
   end
always @ (posedge clk)  // cycle count to count the number of cycles 
   begin
      if (reset)
           cycle_count <= 8'h0 ;
      else if (start && stop_load_plr == 1'b0)
           cycle_count <= CCR ;
      else if ( (PLR == ULR) && (PLR == LLR) && cycle_count != 8'h0 && posedge_start)
           cycle_count <= cycle_count - 8'h01;
      else if ( PLR >= (LLR + 8'h02) && PLR <= (ULR - 8'h02) )
        begin
          if ((cout == (PLR - 8'h01)) && cycle_count != 8'h0 && stop_downcount == 1'b1)
              cycle_count <= cycle_count - 8'h01;
        end
      else if ( (PLR == ( LLR + 8'h01 )) && ( PLR == ( ULR - 8'h01)) )
        begin
          if ( cout == LLR && cycle_count != 8'h0 && stop_upcount == 1'b1 )
              cycle_count <= cycle_count - 8'h01 ;
        end
      else if ( (PLR == LLR) && (PLR <= ULR - 8'h02 ) && cycle_count != 8'h0 && stop_upcount == 1'b1 && cout== (PLR + 8'h01) ) 
           cycle_count <= cycle_count - 8'h01 ;
      else if ( (PLR == LLR) && (PLR == ULR - 8'h01 ) && cycle_count != 8'h0 && cout == ULR ) 
           cycle_count <= cycle_count - 8'h01 ;
      else if ( (PLR == ULR) && (PLR >= LLR + 8'h02 ) && cycle_count != 8'h0 && stop_downcount == 1'b1 && cout== (PLR - 8'h01) ) 
           cycle_count <= cycle_count - 8'h01 ;
      else if ( (PLR == ULR) && (PLR == LLR + 8'h01 ) && cycle_count != 8'h0 && cout == LLR ) 
           cycle_count <= cycle_count - 8'h01 ;
      else 
           cycle_count <= cycle_count ;
   end
always @ (posedge clk)  //direction signal 
   begin
      if (reset || CCR == 8'd0)
           dir <= 1'b0 ;
      else if ( (PLR == ULR) && (PLR == LLR) && cycle_count != 8'h0 && posedge_start)
           dir <= dir ;
      else if ( ((PLR == LLR) && (ULR == PLR + 8'h01)) && cout < ULR && posedge_start && cycle_count != 8'h0)
           dir <= 1'b1 ;
      else if ( ((PLR == LLR) && (ULR == PLR + 8'h01)) && cout > LLR && posedge_start)
           dir <= 1'b0 ;
      else if ( cout > LLR && (PLR == ULR) && (LLR == PLR - 8'h01) && posedge_start && cycle_count != 8'h0)
           dir <= 1'b0 ;
      else if ( cout < ULR && (PLR == ULR) && (LLR == PLR - 8'h01) && posedge_start)
           dir <= 1'b1 ;
      else if (start && !posedge_start && (PLR != ULR) && (PLR >= LLR) && (PLR <= ULR))
           dir <= 1'b1 ;
      else if ( posedge_start && (PLR >= LLR) && (PLR <= ULR) && (cout < ULR) && !stop_upcount && !start_upcount && cycle_count != 8'h0 )
           dir <= 1'b1 ;
      else if ( posedge_start && (PLR >= LLR) && (PLR <= ULR) && ( cout > LLR ) && !stop_downcount && cycle_count != 8'h0)
           dir <= 1'b0 ;
      else if ( posedge_start && (PLR >= LLR) && (PLR <= ULR) && (cout < PLR) && cycle_count != 8'h0)
           dir <= 1'b1 ;
      else 
           dir <= dir ;
   end
always @ (posedge clk)  // start_upcount is a signal used to start the upcount of the cout signal
   begin
     if (reset)
         start_upcount <= 1'b0 ;
     else if ( PLR >= (LLR + 8'h02) && PLR <= (ULR - 8'h02) )
       begin
         if ((cout == LLR) && posedge_start )
             start_upcount <= 1'b1 ;
         else if ((cout == (PLR - 8'h01)) && posedge_start)
             start_upcount <= 1'b0 ;
         else 
             start_upcount <= start_upcount ;
       end
    else if ( (PLR == ( LLR + 8'h01 )) && ( PLR == ( ULR - 8'h01)) )
      begin
        if ((cout == PLR) && posedge_start )
            start_upcount <= 1'b0 ;
        else if ((cout == LLR) && posedge_start)
            start_upcount <= 1'b1 ;
         else 
             start_upcount <= start_upcount ;
     end
     else 
         start_upcount <= start_upcount ;
   end
always @ (posedge clk)  // stop_upcount signal is used to stop the upcount of the signal when done
   begin
     if (reset)
         stop_upcount <= 1'b0 ;
     else if ( PLR == LLR && PLR < ULR && cout == PLR + 8'h01 && PLR == ULR - 8'h02 )
         stop_upcount <= 1'b0 ;
    // else if ( (PLR == LLR) && ( PLR < ULR) &&  cout == PLR + 8'h01 && stop_downcount )
        // stop_upcount <= 1'b0 ;
     else if ((cout == ULR) && posedge_start )
         stop_upcount <= 1'b1 ;
     else if (cout == LLR && posedge_start)
         stop_upcount <= 1'b0 ;
     else if (ec ) 
         stop_upcount <= 1'b0 ;
     else 
         stop_upcount <= stop_upcount ;
   end
always @ (posedge clk)  // stop_downcount is a signal which is used to stop the downcount of the cout
   begin
     if (reset)
         stop_downcount <= 1'b0 ;
     else if ( (PLR == LLR) && ( PLR < ULR) )
       begin
         //if ( cout == PLR + 8'h02 && stop_upcount)
         //  stop_downcount <= 1'b1 ;
	//	$display("am i usefull in this loop");
        // else
           stop_downcount <= 1'b0 ;
       end
     else if ( PLR == ULR && LLR < PLR && posedge_start && cout == PLR - 8'h01 && stop_upcount == 1'b0)
         stop_downcount <= 1'b0 ;
     else if ((cout == LLR) && posedge_start )
         stop_downcount <= 1'b1 ;
     else if (posedge_start && cout == PLR)
         stop_downcount <= 1'b0 ;
     else if (ec ) 
         stop_downcount <= 1'b0 ;
     else 
         stop_downcount <= stop_downcount ;
   end
endmodule


