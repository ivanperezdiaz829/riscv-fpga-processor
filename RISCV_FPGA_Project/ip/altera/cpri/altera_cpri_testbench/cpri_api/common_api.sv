// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


/* Module COMMON_API
-------------------------
 Supported Task Function:
--------------------------
1) terminate() : end the simulation with a summary of all the transaction in each interface 
*/

`include "../models/cpri_pkg/timescale.sv"

module common_api(
   map_err,
   mii_err,
   hdlc_err,
   cpu_err,
   aux_err
);

// Parameters
parameter map_check_en = 0;
parameter mii_check_en = 0;
parameter hdlc_check_en = 0;

// I/O
input cpu_err,aux_err,mii_err,hdlc_err;
input [47:0] map_err;

//------------------------------------------------------
//                    COMMON TASK 
//DO NOT MODIFIED THE TASK FUNCTION (IF YOU ARE UNSURE)
//------------------------------------------------------
task terminate; 
begin
$display(" Info: ==========================================");
$display(" Info:               TEST SUMMARY                "); 
$display(" Info: ==========================================");
$display(" Details:");
if (cpu_err == 1'b0)
   $display(" CPU          R / W: PASSED, %h", cpu_err); 
else
   $display(" CPU          R / W: FAILED, %h", cpu_err); 

if (aux_err == 1'b0)
   $display(" AUX          Tx/Rx: PASSED, %h", aux_err); 
else
   $display(" AUX          Tx/Rx: FAILED, %h", aux_err); 

if (mii_check_en)
begin
   if (mii_err == 1'b0)
      $display(" MII          Tx/Rx: PASSED, %h", mii_err); 
   else
      $display(" MII          Tx/Rx: FAILED, %h", mii_err); 
end
else
      $display(" MII          Tx/Rx: Disable");

if (hdlc_check_en)
begin
   if (hdlc_err == 1'b0)
      $display(" HDLC         Tx/Rx: PASSED, %h", hdlc_err); 
   else
      $display(" HDLC         Tx/Rx: FAILED, %h", hdlc_err); 
end
else
      $display(" HDLC         Tx/Rx: Disable");

if (map_check_en)
begin
   if (map_err[1] == 1'b0) 
   begin
      //$display(" MAP 0 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[0] == 1'b0)
         $display(" MAP 0        Tx/Rx: PASSED, %h", map_err[0]);
      else
         $display(" MAP 0        Tx/Rx: FAILED, %h", map_err[0]); 
   end

   if (map_err[3] == 1'b0)
   begin
      //$display(" MAP 1 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[2] == 1'b0)
         $display(" MAP 1        Tx/Rx: PASSED, %h", map_err[2]);
      else
         $display(" MAP 1        Tx/Rx: FAILED, %h", map_err[2]); 
      end

 if (map_err[5] == 1'b0)
 begin
      //$display(" MAP 2 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[4] == 1'b0)
         $display(" MAP 2        Tx/Rx: PASSED, %h", map_err[4]);
      else
         $display(" MAP 2        Tx/Rx: FAILED, %h", map_err[4]); 
      end

 if (map_err[7] == 1'b0)
 begin
      //$display(" MAP 3 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[6] == 1'b0)
         $display(" MAP 3        Tx/Rx: PASSED, %h", map_err[6]);
      else
         $display(" MAP 3        Tx/Rx: FAILED, %h", map_err[6]); 
      end

 if (map_err[9] == 1'b0)
 begin
      //$display(" MAP 4 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[8] == 1'b0)
         $display(" MAP 4        Tx/Rx: PASSED, %h", map_err[8]);
      else
         $display(" MAP 4        Tx/Rx: FAILED, %h", map_err[8]); 
      end

 if (map_err[11] == 1'b0)
 begin
      //$display(" MAP 5 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[10] == 1'b0)
         $display(" MAP 5        Tx/Rx: PASSED, %h", map_err[10]);
      else
         $display(" MAP 5        Tx/Rx: FAILED, %h", map_err[10]); 
      end

   if (map_err[13] == 1'b0)
      begin
      //$display(" MAP 6 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[12] == 1'b0)
         $display(" MAP 6        Tx/Rx: PASSED, %h", map_err[12]);
      else
         $display(" MAP 6        Tx/Rx: FAILED, %h", map_err[12]); 
      end

 if (map_err[15] == 1'b0)
 begin
      //$display(" MAP 7 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[14] == 1'b0)
         $display(" MAP 7        Tx/Rx: PASSED, %h", map_err[14]);
      else
         $display(" MAP 7        Tx/Rx: FAILED, %h", map_err[14]); 
      end

 if (map_err[17] == 1'b0)
 begin
      //$display(" MAP 8 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[16] == 1'b0)
         $display(" MAP 8        Tx/Rx: PASSED, %h", map_err[16]);
      else
         $display(" MAP 8        Tx/Rx: FAILED, %h", map_err[16]); 
      end

 if (map_err[19] == 1'b0)
 begin
      //$display(" MAP 9 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[18] == 1'b0)
         $display(" MAP 9       Tx/Rx: PASSED, %h", map_err[18]);
      else
         $display(" MAP 9       Tx/Rx: FAILED, %h", map_err[18]); 
      end

 if (map_err[21] == 1'b0)
 begin
      //$display(" MAP 10 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[20] == 1'b0)
         $display(" MAP 10       Tx/Rx: PASSED, %h", map_err[20]);
      else
         $display(" MAP 10       Tx/Rx: FAILED, %h", map_err[20]); 
      end

 if (map_err[23] == 1'b0)
 begin
      //$display(" MAP 11 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[22] == 1'b0)
         $display(" MAP 11       Tx/Rx: PASSED, %h", map_err[22]);
      else
         $display(" MAP 11       Tx/Rx: FAILED, %h", map_err[22]); 
      end

  if (map_err[25] == 1'b0)
  begin
      //$display(" MAP 12 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[24] == 1'b0)
         $display(" MAP 12       Tx/Rx: PASSED, %h", map_err[24]);
      else
         $display(" MAP 12       Tx/Rx: FAILED, %h", map_err[24]); 
   end

   if (map_err[27] == 1'b0)
   begin
      //$display(" MAP 13 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[26] == 1'b0)
         $display(" MAP 13       Tx/Rx: PASSED, %h", map_err[26]);
      else
         $display(" MAP 13       Tx/Rx: FAILED, %h", map_err[26]); 
      end

 if (map_err[29] == 1'b0)
 begin
      //$display(" MAP 14 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[28] == 1'b0)
         $display(" MAP 14       Tx/Rx: PASSED, %h", map_err[28]);
      else
         $display(" MAP 14       Tx/Rx: FAILED, %h", map_err[28]); 
      end

 if (map_err[31] == 1'b0)
 begin
      //$display(" MAP 15 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[30] == 1'b0)
         $display(" MAP 15       Tx/Rx: PASSED, %h", map_err[30]);
      else
         $display(" MAP 15       Tx/Rx: FAILED, %h", map_err[30]); 
      end

 if (map_err[33] == 1'b0)
 begin
      //$display(" MAP 16 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[32] == 1'b0)
         $display(" MAP 16       Tx/Rx: PASSED, %h", map_err[32]);
      else
         $display(" MAP 16       Tx/Rx: FAILED, %h", map_err[32]); 
      end

 if (map_err[35] == 1'b0)
 begin
      //$display(" MAP 17 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[34] == 1'b0)
         $display(" MAP 17       Tx/Rx: PASSED, %h", map_err[34]);
      else
         $display(" MAP 17       Tx/Rx: FAILED, %h", map_err[34]); 
      end

 if (map_err[37] == 1'b0)
 begin
      //$display(" MAP 18 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[36] == 1'b0)
         $display(" MAP 18       Tx/Rx: PASSED, %h", map_err[36]);
      else
         $display(" MAP 18       Tx/Rx: FAILED, %h", map_err[36]); 
      end

 if (map_err[39] == 1'b0)
 begin
      //$display(" MAP 19 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[38] == 1'b0)
         $display(" MAP 19       Tx/Rx: PASSED, %h", map_err[38]);
      else
         $display(" MAP 19       Tx/Rx: FAILED, %h", map_err[38]); 
      end

 if (map_err[41] == 1'b0)
 begin
     // $display(" MAP 20 Tx/Rx: Disable");
  end
   else
   begin
      if (map_err[40] == 1'b0)
         $display(" MAP 20       Tx/Rx: PASSED, %h", map_err[40]);
      else
         $display(" MAP 20       Tx/Rx: FAILED, %h", map_err[40]); 
      end

 if (map_err[43] == 1'b0)
 begin
      //$display(" MAP 21 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[42] == 1'b0)
         $display(" MAP 21       Tx/Rx: PASSED, %h", map_err[42]);
      else
         $display(" MAP 21       Tx/Rx: FAILED, %h", map_err[42]); 
      end

 if (map_err[45] == 1'b0)
 begin
      //$display(" MAP 22 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[44] == 1'b0)
         $display(" MAP 22       Tx/Rx: PASSED, %h", map_err[44]);
      else
         $display(" MAP 22       Tx/Rx: FAILED, %h", map_err[44]); 
      end

 if (map_err[47] == 1'b0)
 begin
      //$display(" MAP 23 Tx/Rx: Disable");
   end
   else
   begin
      if (map_err[46] == 1'b0)
         $display(" MAP 23       Tx/Rx: PASSED, %h", map_err[46]);
      else
         $display(" MAP 23       Tx/Rx: FAILED, %h", map_err[46]); 
      end

end
else
      $display(" MAP          Tx/Rx: Disable");

if ((cpu_err == 1'b0) && (aux_err == 1'b0) && (mii_err == 1'b0)  &&(hdlc_err == 1'b0) && (map_err[0] == 1'b0) && (map_err[2] == 1'b0) && (map_err[4] == 1'b0) && (map_err[6] == 1'b0) && (map_err[8] == 1'b0) && (map_err[10] == 1'b0) && (map_err[12] == 1'b0) && (map_err[14] == 1'b0) && (map_err[16] == 1'b0) && (map_err[18] == 1'b0) && (map_err[20] == 1'b0) && (map_err[22] == 1'b0) && (map_err[24] == 1'b0) && (map_err[26] == 1'b0) && (map_err[28] == 1'b0) && (map_err[30] == 1'b0) && (map_err[32] == 1'b0) && (map_err[34] == 1'b0) && (map_err[36] == 1'b0) && (map_err[38] == 1'b0) && (map_err[40] == 1'b0) && (map_err[42] == 1'b0) && (map_err[44] == 1'b0) && (map_err[46] == 1'b0))   
begin
   $display(" TESTBENCH_PASSED: No Failures Found. ");
   $display(" Info: =========================================="); 
end
else 
begin 
   $display(" TESTBENCH_FAILED: Failures Found. ");
   $display(" Info: ==========================================");
end

$display("");
$display(" SIMULATION TERMINATION at %d",$time);
$display("");
$display(" ************ END OF CUSTOMER DEMO TB **************");
$finish; 
end 
endtask 

endmodule
