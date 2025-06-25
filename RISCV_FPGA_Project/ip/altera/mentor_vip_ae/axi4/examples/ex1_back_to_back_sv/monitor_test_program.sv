// *****************************************************************************
//
// Copyright 2007-2013 Mentor Graphics Corporation
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
//
// *****************************************************************************

/*

   This is a simple example of an AXI4 monitor to demonstrate the usage of the mgc_axi4_monitor BFM. 
    
*/

import mgc_axi4_pkg::*;

module monitor_test_program #(int AXI4_ADDRESS_WIDTH =   32, 
                              int AXI4_RDATA_WIDTH   = 1024, 
                              int AXI4_WDATA_WIDTH   = 1024, 
                              int AXI4_ID_WIDTH      =   18,
                              int AXI4_USER_WIDTH    =    8,
                              int AXI4_REGION_MAP_SIZE = 16)
(
    mgc_axi4_monitor bfm
);

  initial begin
    bfm.wait_on(AXI4_RESET_0_TO_1);
    bfm.wait_on(AXI4_CLOCK_POSEDGE);

    fork
      process_read;
      process_write;
    join
  end  

  task automatic process_read;
    forever begin
      axi4_transaction read_trans;
    
      read_trans = bfm.create_monitor_transaction();
      read_trans.read_or_write = AXI4_TRANS_READ;
      bfm.get_read_addr_phase(read_trans);

      fork
        automatic axi4_transaction t = read_trans;
        begin
          for(int i = 0; !t.transaction_done; i++)
            bfm.get_read_data_phase(t, i);
          $display("\n=============");
          $display("MONITOR: READ");
          t.print(1);
          $display("=============\n");
        end
      join
      #0;
    end
  endtask

  task automatic process_write;
    forever begin
      axi4_transaction write_trans;
    
      write_trans = bfm.create_monitor_transaction();
      write_trans.read_or_write = AXI4_TRANS_WRITE;
      bfm.get_write_addr_phase(write_trans);

      fork
        automatic axi4_transaction t = write_trans;
        begin
          bit last = 0;
          for(int i = 0; !last; i++)
            bfm.get_write_data_phase(t, i, last);
          bfm.get_write_response_phase(t);
          $display("\n==============");
          $display("MONITOR: WRITE");
          t.print(1);
          $display("==============\n");
        end
      join
      #0;
    end
  endtask

endmodule

