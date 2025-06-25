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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_nios2_custom_instr_slave_bfm/altera_nios2_custom_instr_slave_bfm.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_nios2_custom_instr_slave_bfm
// =head1 SYNOPSIS
// NiosII Custom Instruction Slave BFM
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This is a Bus Functional Model (BFM) for a NiosII Custom Instruction Slave.
//-----------------------------------------------------------------------------
`timescale 1ns / 1ns

module altera_nios2_custom_instr_slave_bfm (
   ci_clk,
   ci_reset,

   ci_clk_en,
   
   ci_dataa,
   ci_datab,
   ci_result,
   ci_start,
   ci_done,
   ci_n,
   ci_a,
   ci_b,
   ci_c,
   ci_readra,
   ci_readrb,
   ci_writerc
);

   // =head1 PARAMETERS
   // =head2 Basic Parameters
   parameter NUM_OPERANDS     = 2;  // Number of operands
   parameter USE_RESULT       = 1;  // Using result
   
   // =head2 Multi-cycle Parameter
   parameter USE_MULTI_CYCLE  = 0;  // Combinatorial (0) or multi cycle (1)
   parameter FIXED_LENGTH     = 2;  // Fixed length value
   parameter USE_START        = 1;  // Using start
   parameter USE_DONE         = 0;  // Using variable-length mode
   
   // =head2 Extension Parameter
   parameter USE_EXTENSION    = 0;  // Using extension or port n
   parameter EXT_WIDTH        = 8;  // Width of port n
   
   // =head2 Register File Parameters
   parameter USE_READRA       = 0;  // Using register a
   parameter USE_READRB       = 0;  // Using register b
   parameter USE_WRITERC      = 0;  // Using register c
   parameter VHDL_ID          = 0;  // VHDL BFM ID number
   
   localparam WORD_WIDTH      = 32;
   localparam ADDR_WIDTH      = 5;
   
   // =head1 PINS
   // =head2 Clock Interface
   input                            ci_clk;
   input                            ci_reset;
   input                            ci_clk_en;
   
   // =head2 NiosII Custom Instruction Interface
   input  [WORD_WIDTH-1: 0]         ci_dataa;
   input  [WORD_WIDTH-1: 0]         ci_datab;
   output [WORD_WIDTH-1: 0]         ci_result;
   
   input                            ci_start;
   output                           ci_done;
   
   input  [EXT_WIDTH-1: 0]          ci_n;
   
   input  [ADDR_WIDTH-1: 0]         ci_a;
   input  [ADDR_WIDTH-1: 0]         ci_b;
   input  [ADDR_WIDTH-1: 0]         ci_c;
   input                            ci_readra;
   input                            ci_readrb;
   input                            ci_writerc;
   // =cut
   
   // synthesis translate_off
   import verbosity_pkg::*;
   import avalon_utilities_pkg::*;
   
   typedef logic [WORD_WIDTH-1: 0]  ci_data_t;
   typedef logic [EXT_WIDTH-1: 0]   ci_n_t;
   typedef logic [ADDR_WIDTH-1: 0]  ci_addr_t;
   
   ci_data_t                        ci_result;
   
   typedef enum {
      COMBINATORIAL,
      FIXED,
      VARIABLE
   } mode_t;
   
   typedef enum {
      NO_ERROR,
      FORCE_DONE,
      NO_DONE
   } error_inject_t;
   
   //--------------------------------------------------------------------------
   // Private Types and Variables
   //--------------------------------------------------------------------------
   typedef struct packed {
      ci_data_t                     dataa;
      ci_data_t                     datab;
      ci_n_t                        n;
      ci_addr_t                     a;
      ci_addr_t                     b;
      ci_addr_t                     c;
      logic                         readra;
      logic                         readrb;
      logic                         writerc;
      ci_data_t                     idle;
   } Instruction_t;
   
   typedef struct packed {
      ci_data_t                    value;
      ci_data_t                    delay;
      error_inject_t               err_inject;
   } Result_t;
   
   // Combinatorial driven
   mode_t         mode                       = COMBINATORIAL;
   
   Instruction_t  phy_instruction            = 'x;
   Instruction_t  prev_instruction           = 'x;
   
   Result_t       client_result              = 'x;
   Result_t       reset_result               = 'x;
   
   bit            executing_result           = 0;
   int            result_delay               = 0;
   bit            result_ready               = 0;
   bit            new_instruction_received   = 0;
   bit            instruction_changed        = 0;
   bit            interface_is_unknown       = 0;
   ci_data_t      prepared_result            = 0;
   error_inject_t err_object                 = NO_ERROR;
   error_inject_t err_injected               = NO_ERROR;
   int            instruction_timeout        = 1000;
   int            clock_enable_timeout       = 1000;
   int            instruction_timeout_ctr    = 0;
   int            clock_enable_timeout_ctr   = 0;
   
   
   // Synchronously driven
   int            clock_ctr;
   logic          result_clk;
   bit            local_instr_ci_clk_en;
   bit            local_result_ci_clk_en;
   bit            instruction_start;
   bit            processing_instruction;
   bit            result_request;
   bit            result_done;
   ci_data_t      idle_ctr;
   
   IdleOutputValue_t idle_output_config      = UNKNOWN;
   
   //--------------------------------------------------------------------------
   // Private Methods
   //--------------------------------------------------------------------------
   
   function automatic void __hello();
      // Introduction Message to console
      $sformat(message, "%m: - Hello from altera_nios2_custom_instr_slave_bfm");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);
      
      $sformat(message, "%m: -   NUM_OPERANDS      = %0d", NUM_OPERANDS);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_RESULT        = %0d", USE_RESULT);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_MULTI_CYCLE   = %0d", USE_MULTI_CYCLE);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   FIXED_LENGTH      = %0d", FIXED_LENGTH);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_START         = %0d", USE_START);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_DONE          = %0d", USE_DONE);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_EXTENSION     = %0d", USE_EXTENSION);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   EXT_WIDTH         = %0d", EXT_WIDTH);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_READRA        = %0d", USE_READRA);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_READRB        = %0d", USE_READRB);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_WRITERC       = %0d", USE_WRITERC);
      print(VERBOSITY_INFO, message);
      
      print_divider(VERBOSITY_INFO);
   endfunction
   
   function automatic void __abort_simulation();
      string message;
      $sformat(message, "%m: Abort the simulation due to fatal error.");
      print(VERBOSITY_FAILURE, message);
      $stop;
   endfunction
   
   //--------------------------------------------------------------------------
   // =head1 Public Methods API
   // =pod
   // This section describes the public methods in the application programming
   // interface (API). In this case the application program is the test bench
   // which instantiates and controls and queries state in this BFM component.
   // Test programs must only use these public access methods and events to
   // communicate with this BFM component. The API and the module pins
   // are the only interfaces in this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product.
   // While we cannot prevent a test program from directly accessing local
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can
   // and will change.
   // =cut
   //--------------------------------------------------------------------------
   event signal_fatal_error; // public
   // Event to indicate a fatal error. It terminates simulation.
   
   event signal_known_instruction_received; // public
   // Event to indicate that a change occurred on the instruction interface
   //  and there's no unknown value
   
   event signal_unknown_instruction_received; // public
   // Event to indicate that a change occurred on the instruction interface
   //  and there is unknown value
   
   event signal_instruction_inconsistent; // public
   // Event to indicate that an instruction changed while the previous
   //  instruction has not finished
   
   event signal_result_driven; // public
   // Event to indicate the result is to be driven out from the slave
   
   event signal_result_done; // public
   // Event to indicate the result is accepted by the master
   
   event signal_instruction_unchanged;
   // Event to indicate an instruction sampled on the interface has not 
   //  changed from previous instruction
   
   function automatic string get_version(); // public
   // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1"
      string ret_version = "13.1";
      return ret_version;
   endfunction
   
   function automatic bit get_ci_clk_en(); // public
      // Get the instruction register file address b value
      bit enable;
      enable = local_instr_ci_clk_en;
      
      return enable;
   endfunction
   
   function automatic void retrieve_instruction( // public
      output ci_data_t   dataa  ,
      output ci_data_t   datab  ,
      output ci_n_t      n      ,
      output ci_addr_t   a      ,
      output ci_addr_t   b      ,
      output ci_addr_t   c      ,
      output logic       readra ,
      output logic       readrb ,
      output logic       writerc,
      output ci_data_t   idle
   );
      // A simplified API to get instruction
      $sformat(message, "%m: called retrieve_instruction");
      print(VERBOSITY_DEBUG, message);
      
      if (NUM_OPERANDS > 0) begin
         dataa = get_instruction_dataa();
      end else begin
         dataa = 'x;
      end
      if (NUM_OPERANDS > 1) begin
         datab = get_instruction_datab();
      end else begin
         datab = 'x;
      end
      if (USE_EXTENSION == 1) begin
         n = get_instruction_n();
      end else begin
         datab = 'x;
      end
      if (USE_READRA == 1) begin
         a = get_instruction_a();
         readra = get_instruction_readra();
      end else begin
         a = 'x;
         readra = 1;
      end
      if (USE_READRB == 1) begin
         b = get_instruction_b();
         readrb = get_instruction_readrb();
      end else begin
         b = 'x;
         readrb = 1;
      end
      if (USE_WRITERC == 1) begin
         c = get_instruction_c();
         writerc = get_instruction_writerc();
      end else begin
         c = 'x;
         writerc = 1;
      end
      if (mode == FIXED || mode == VARIABLE) begin
         idle = get_instruction_idle();
      end else begin
         idle = 0;
      end
      
   endfunction
   
   function automatic void insert_result( // public
      ci_data_t   value = 0,
      ci_data_t   delay = 2,
      int         err_inj = 0
   );
      // A simplified API to set result
      $sformat(message, "%m: called retrive_result");
      print(VERBOSITY_DEBUG, message);
      
      if (USE_RESULT == 1) begin
         set_result_value(value);
         if (mode == VARIABLE) begin
            set_result_delay(delay);
            set_result_err_inject(err_inj);
         end
      end
      
   endfunction
   
   function automatic ci_data_t get_instruction_dataa(); // public
      // Get the instruction dataa operand value
      ci_data_t data;
      data = phy_instruction.dataa;
      $sformat(message, "%m: called get_instruction_dataa - %h", data);
      print(VERBOSITY_DEBUG, message);

      if (NUM_OPERANDS > 0) begin
         return data;
      end else begin
         $sformat(
            message,
            "%m: Custom instruction has %0d operands.",
            NUM_OPERANDS
         );
         print(VERBOSITY_WARNING, message);
         return 'x;
      end
   endfunction
   
   function automatic ci_data_t get_instruction_datab(); // public
      // Get the instruction datab operand value
      ci_data_t data;
      data = phy_instruction.datab;
      $sformat(message, "%m: called get_instruction_datab - %h", data);
      print(VERBOSITY_DEBUG, message);
      
      if (NUM_OPERANDS > 1) begin
         return data;
      end else begin
         $sformat(
            message,
            "%m: Custom instruction has %0d operands.",
            NUM_OPERANDS
         );
         print(VERBOSITY_WARNING, message);
         return 'x;
      end
   endfunction
   
   function automatic ci_n_t get_instruction_n(); // public
      // Get the instruction extended opcode value n
      ci_n_t code;
      code = phy_instruction.n;
      $sformat(message, "%m: called get_instruction_n - %h", code);
      print(VERBOSITY_DEBUG, message);
      if (USE_EXTENSION == 1) begin
         return code;
      end else begin
         $sformat(
            message,
            "%m: called get_instruction_n when USE_EXTENSION is %0d",
            USE_EXTENSION
         );
         print(VERBOSITY_WARNING, message);
         return 'x;
      end
   endfunction
   
   function automatic ci_addr_t get_instruction_a(); // public
      // Get the instruction register file address a value
      ci_addr_t address;
      address = phy_instruction.a;
      $sformat(message, "%m: called get_instruction_a - %h", address);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_READRA == 1) begin
         return address;
      end else begin
         $sformat(
            message,
            "%m: called get_instruction_a when USE_READRA is %0d",
            USE_READRA
         );
         print(VERBOSITY_WARNING, message);
         return 'x;
      end
   endfunction
   
   function automatic ci_addr_t get_instruction_b(); // public
      // Get the instruction register file address b value
      ci_addr_t address;
      address = phy_instruction.b;
      $sformat(message, "%m: called get_instruction_b - %h", address);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_READRB == 1) begin
         return address;
      end else begin
         $sformat(
            message,
            "%m: called get_instruction_b when USE_READRB is %0d",
            USE_READRB
         );
         print(VERBOSITY_WARNING, message);
         return 'x;
      end
   endfunction
   
   function automatic ci_addr_t get_instruction_c(); // public
      // Get the instruction register file address c value
      ci_addr_t address;
      address = phy_instruction.c;
      $sformat(message, "%m: called get_instruction_c - %h", address);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_WRITERC == 1) begin
         return address;
      end else begin
         $sformat(
            message,
            "%m: called get_instruction_c when USE_WRITERC is %0d",
            USE_WRITERC
         );
         print(VERBOSITY_WARNING, message);
         return 'x;
      end
   endfunction
   
   function automatic logic get_instruction_readra(); // public
      // Get the instruction register file read a value
      logic enable;
      enable = phy_instruction.readra;
      $sformat(message, "%m: called get_instruction_readra - %h", enable);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_READRA == 1) begin
         return enable;
      end else begin
         $sformat(
            message,
            "%m: called get_instruction_readra when USE_READRA is %0d",
            USE_READRA
         );
         print(VERBOSITY_WARNING, message);
         return 1;
      end
   endfunction
   
   function automatic logic get_instruction_readrb(); // public
      // Get the instruction register file read b value
      logic enable;
      enable = phy_instruction.readrb;
      $sformat(message, "%m: called get_instruction_readrb - %h", enable);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_READRB == 1) begin
         return enable;
      end else begin
         $sformat(
            message,
            "%m: called get_instruction_readrb when USE_READRB is %0d",
            USE_READRB
         );
         print(VERBOSITY_WARNING, message);
         return 1;
      end
   endfunction
   
   function automatic logic get_instruction_writerc(); // public
      // Get the instruction register file write c value
      logic enable;
      enable = phy_instruction.writerc;
      $sformat(message, "%m: called get_instruction_writerc - %h", enable);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_WRITERC == 1) begin
         return enable;
      end else begin
         $sformat(
            message,
            "%m: called get_instruction_writerc when USE_WRITERC is %0d",
            USE_WRITERC
         );
         print(VERBOSITY_WARNING, message);
         return 1;
      end
   endfunction
   
   function automatic ci_data_t get_instruction_idle(); // public
      // Get the pre-instruction idle value
      ci_data_t idle;
      idle = phy_instruction.idle;
      $sformat(message, "%m: called get_instruction_idle - %h", idle);
      print(VERBOSITY_DEBUG, message);
      
      if (mode == FIXED || mode == VARIABLE) begin
         return idle;
      end else begin
         $sformat(
            message,
            "%m: called get_instruction_idle when start port is disabled"
         );
         print(VERBOSITY_WARNING, message);
         return 0;
      end
   endfunction
   
   function automatic void set_result_value( // public
      ci_data_t value
   );
      // Set the instruction result
      $sformat(message, "%m: called set_result_value - %0d", value);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_RESULT == 1) begin
         client_result.value = value;
      end else begin
         client_result.value = 'x;
         $sformat(
            message,
            "%m: called set_result_delay when USE_RESULT is %0d",
            USE_RESULT);
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_result_delay( // public
      ci_data_t delay
   );
      // Set the instruction result delay
      $sformat(message, "%m: called set_result_delay - %0d", delay);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_RESULT == 1 && USE_MULTI_CYCLE == 1) begin
         client_result.delay = delay;
         
         if (mode == FIXED && delay != FIXED_LENGTH) begin
            client_result.delay = FIXED_LENGTH;
            $sformat(
               message,
               "%m: called set_result_delay %0d with FIXED_LENGTH %0d",
               delay,
               FIXED_LENGTH);
            print(VERBOSITY_WARNING, message);
         end
         
         if (mode == VARIABLE && delay < 2) begin
            client_result.delay = 2;
            $sformat(
               message,
               "%m: called set_result_delay %0d: default to 2",
               delay);
            print(VERBOSITY_WARNING, message);
         end
      end else begin
         client_result.delay = 2;
         $sformat(
            message,
            "%m: called set_result_delay when USE_MULTI_CYCLE is %0d",
            USE_MULTI_CYCLE);
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_result_err_inject( // public
      int err_inj = 0
   );
      // Set the instruction result to be executed in pre-defined error
      $sformat(message, "%m: called set_result_err_inject - %0d", err_inj);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_RESULT == 1 && mode == VARIABLE) begin
         if (err_inj >= err_object.first() && 
             err_inj <= err_object.last()) begin
            $cast(err_object, err_inj);
            client_result.err_inject = err_object;
         end else begin
            client_result.err_inject = NO_ERROR;
            $sformat(
               message,
               "%m: called set_result_err_inject out of range: %0d",
               err_inj);
            print(VERBOSITY_WARNING, message);
         end
      end else begin
         client_result.err_inject = NO_ERROR;
         $sformat(
            message,
            "%m: called set_result_err_inject for non-variable-length");
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_timeout( // public
      int timeout = 1000
   );
      // Set timeout value for instruction. Set to 0 to never timeout.
      instruction_timeout = timeout;
   endfunction
   
   function automatic void set_clock_enable_timeout( // public
      int timeout = 1000
   );
      // Set timeout value for clock enable. Set to 0 to never timeout.
      clock_enable_timeout = timeout;
   endfunction
   
   task automatic set_idle_state_output_configuration( // public
      // Set the configuration of output signal value during interface idle
      IdleOutputValue_t idle_config
   );
      idle_output_config = idle_config;
      __setup_reset_result();
   endtask
   
   function automatic IdleOutputValue_t get_idle_state_output_configuration(); // public
      // Get the configuration of output signal value during interface idle
      
      return idle_output_config;
   endfunction
   
   //=cut
   
   task __setup_reset_result();
      reset_result.delay      = (USE_MULTI_CYCLE == 1) ? 2 : 1;
      reset_result.err_inject = NO_ERROR;
      
      case (idle_output_config)
         LOW: begin
            reset_result.value      = '0;
         end
         HIGH: begin
            reset_result.value      = '1;
         end
         RANDOM: begin
            reset_result.value      = $random;
         end
         UNKNOWN: begin
            reset_result.value      = 'x;
         end
         default: begin
            reset_result.value      = 'x;
         end
      endcase
   endtask
   
   task __init_bfm();
      // Determine operation mode
      if (USE_MULTI_CYCLE == 0) begin
         mode = COMBINATORIAL;
      end else begin
         if (USE_DONE == 0) begin
            mode = FIXED;
         end else begin
            mode = VARIABLE;
         end
      end
      
      __setup_reset_result();
   endtask
   
   task __get_instruction();
      // Get instruction to the internal instruction
      if (NUM_OPERANDS > 0) begin
         prev_instruction.dataa     = phy_instruction.dataa;
         phy_instruction.dataa      = ci_dataa;
      end
      if (NUM_OPERANDS > 1) begin
         prev_instruction.datab     = phy_instruction.datab;
         phy_instruction.datab      = ci_datab;
      end
      if (USE_EXTENSION == 1) begin
         prev_instruction.n         = phy_instruction.n;
         phy_instruction.n          = ci_n;
      end
      if (USE_READRA == 1) begin
         prev_instruction.a         = phy_instruction.a;
         prev_instruction.readra    = phy_instruction.readra;
         phy_instruction.a          = ci_a;
         phy_instruction.readra     = ci_readra;
      end
      if (USE_READRB == 1) begin
         prev_instruction.b         = phy_instruction.b;
         prev_instruction.readrb    = phy_instruction.readrb;
         phy_instruction.b          = ci_b;
         phy_instruction.readrb     = ci_readrb;
      end
      if (USE_WRITERC == 1) begin
         prev_instruction.c         = phy_instruction.c;
         prev_instruction.writerc   = phy_instruction.writerc;
         phy_instruction.c          = ci_c;
         phy_instruction.writerc    = ci_writerc;
      end
      if (mode == FIXED || mode == VARIABLE) begin
         prev_instruction.idle      = phy_instruction.idle;
         phy_instruction.idle       = idle_ctr;
      end
      
   endtask
   
   function automatic void __received_instruction_event();
      // Trigger event based on received instruction
      interface_is_unknown = 0;
      instruction_changed = 0;
      
      if (NUM_OPERANDS > 0) begin
         if ($isunknown(ci_dataa)) begin
            interface_is_unknown = 1;
         end
         if (prev_instruction.dataa !== ci_dataa) begin
            instruction_changed = 1;
         end
      end
      
      if (NUM_OPERANDS > 1) begin
         if ($isunknown(ci_datab)) begin
            interface_is_unknown = 1;
         end
         if (prev_instruction.datab !== ci_datab) begin
            instruction_changed = 1;
         end
      end
      
      if (USE_EXTENSION) begin
         if ($isunknown(ci_n)) begin
            interface_is_unknown = 1;
         end
         if (prev_instruction.n !== ci_n) begin
            instruction_changed = 1;
         end
      end
      
      if (USE_READRA) begin
         if ($isunknown(ci_a)) begin
            interface_is_unknown = 1;
         end
         if ($isunknown(ci_readra)) begin
            interface_is_unknown = 1;
         end
         if (prev_instruction.a !== ci_a) begin
            instruction_changed = 1;
         end
         if (prev_instruction.readra !== ci_readra) begin
            instruction_changed = 1;
         end
      end
      
      if (USE_READRB) begin
         if ($isunknown(ci_b)) begin
            interface_is_unknown = 1;
         end
         if ($isunknown(ci_readrb)) begin
            interface_is_unknown = 1;
         end
         if (prev_instruction.b !== ci_b) begin
            instruction_changed = 1;
         end
         if (prev_instruction.readrb !== ci_readrb) begin
            instruction_changed = 1;
         end
      end
      
      if (USE_WRITERC) begin
         if ($isunknown(ci_c)) begin
            interface_is_unknown = 1;
         end
         if ($isunknown(ci_writerc)) begin
            interface_is_unknown = 1;
         end
         if (prev_instruction.c !== ci_c) begin
            instruction_changed = 1;
         end
         if (prev_instruction.writerc !== ci_writerc) begin
            instruction_changed = 1;
         end
      end
      
      if (mode == FIXED || mode == VARIABLE) begin
         if (instruction_start == 0) begin
            new_instruction_received = 0;
         end else begin
            new_instruction_received = 1;
            if (interface_is_unknown == 0) begin
               -> signal_known_instruction_received;
            end else begin
               -> signal_unknown_instruction_received;
            end
         end
         if (instruction_changed == 0) begin
            -> signal_instruction_unchanged;
         end else begin
            if (processing_instruction == 1) begin
               -> signal_instruction_inconsistent;
            end
         end
      end else begin
         if (processing_instruction == 0) begin
            new_instruction_received = 1;
            if (interface_is_unknown == 0) begin
               -> signal_known_instruction_received;
            end else begin
               -> signal_unknown_instruction_received;
            end
            if (instruction_changed == 0) begin
               -> signal_instruction_unchanged;
            end
         end else begin
            if (instruction_changed == 0) begin
               new_instruction_received = 0;
               -> signal_instruction_unchanged;
            end else begin
               new_instruction_received = 1;
               -> signal_instruction_inconsistent;
               if (interface_is_unknown == 0) begin
                  -> signal_known_instruction_received;
               end else begin
                  -> signal_unknown_instruction_received;
               end
            end
         end
      end
      
   endfunction
   
   function automatic void __prepare_result();
      // Load the result to be executed
      prepared_result = client_result.value;
      err_injected = client_result.err_inject;
      
      case (client_result.err_inject)
         NO_ERROR:   begin
                        if (mode == COMBINATORIAL) begin
                           result_delay = 1;
                        end else if (mode == FIXED) begin
                           result_delay = FIXED_LENGTH - 2;
                        end else begin
                           result_delay = client_result.delay - 2;
                        end 
                     end
         FORCE_DONE: begin
                        result_delay = 0;
                     end
         NO_DONE:    begin
                        result_delay = client_result.delay - 2;
                     end
      endcase
      
      if (result_delay <= 0) begin
         result_ready = 1;
      end else begin
         result_ready = 0;
      end
   endfunction
   
   task __drive_idle();
      // Drive idle on the result bus
      ci_result <= reset_result.value;
      
      if (result_delay > 0) begin
         result_delay   = result_delay - 1;
         if (result_delay == 0) begin
            result_ready = 1;
         end else begin
            result_ready = 0;
         end
      end else begin
         result_delay   = 0;
         result_ready   = 0;
      end
      
      result_done <= 0;
   endtask
   
   task __drive_result();
      // Drive result on the result bus
      ci_result   <= prepared_result;
      
      result_done <= 1;
      
      // Reset control variables
      result_delay = 0;
      result_ready = 0;
      
      // Indicating that a result has been driven out
      -> signal_result_driven;
   endtask
   
   //=cut
   
   initial begin
      __hello();
      __init_bfm();
   end
   
   always @(signal_fatal_error) __abort_simulation();
   
   // Need local variable to prevent direct usage of input port
   // Sampling ci_clk_en
   assign local_instr_ci_clk_en = (USE_MULTI_CYCLE == 1) ? ci_clk_en : 1 ;
   
   // Sampling start
   assign instruction_start = 
      (mode == FIXED || mode == VARIABLE) ?
      ci_start : 1;
   
   // Driving ci_done signal
   assign ci_done = 
      (mode == VARIABLE) ?
      (err_injected == NO_DONE ? 0 : result_done) :
      0;
   
   // Calculating idle cycles pre-instruction
   always @(posedge ci_clk or posedge ci_reset) begin
      if (mode == FIXED || mode == VARIABLE) begin
         if (ci_reset == 1) begin
            idle_ctr <= 0;
         end else begin
            if (local_instr_ci_clk_en == 1) begin
               // Interesting case when a violation happens
               //  where start and done happens at the same cycle,
               //  start will take precedence
               if (processing_instruction == 1 && result_done == 1) begin
                  if (instruction_start == 1) begin
                     idle_ctr <= idle_ctr + 1;
                  end else begin
                     idle_ctr <= 0;
                  end
               end else begin
                  // Keep on counting regardless of start status
                  //  to cater for a new start overriding the previous one
                  idle_ctr <= idle_ctr + 1;
               end
            end
         end
      end else begin
         idle_ctr = 0;
      end
   end
   
   // Delaying clock for the driving result
   always @(ci_clk) begin
      #1;
      result_clk <= ci_clk;
   end
   
   // Delaying clock enable for result as well
   always @(posedge result_clk) begin
      local_result_ci_clk_en <= local_instr_ci_clk_en;
   end
   
   generate 
      if (USE_MULTI_CYCLE) begin

         // For clock counter
         always @(posedge ci_clk or posedge ci_reset) begin
            if (ci_reset == 1) begin
               clock_ctr <= 0;
            end else begin
               if (local_instr_ci_clk_en == 1) begin
                  clock_ctr <= clock_ctr + 1;
               end
            end
         end
         
         // Determine if an instruction has been received
         always @(posedge ci_clk or posedge ci_reset) begin
            if (ci_reset == 1) begin
               result_request          <= 0;
               processing_instruction  <= 0;
               phy_instruction         = 'x;
            end else begin
               if (local_instr_ci_clk_en == 1) begin
                  
                  if (result_done == 1) begin
                     processing_instruction <= 0;
                     -> signal_result_done;
                  end
                  
                  __get_instruction();
                  __received_instruction_event();
                  
                  if (new_instruction_received == 1) begin
                     processing_instruction  <= 1;
                     result_request          <= 1;
                  end else begin
                     result_request          <= 0;
                  end
               end
            end
         end
         
         // Drive result out onto the interface
         always @(posedge result_clk or posedge ci_reset) begin
            if (ci_reset == 1) begin
               result_done       <= 0;
               ci_result         <= reset_result.value;
               client_result     = reset_result;
               result_delay      = 0;
               result_ready      = 0;
               executing_result  = 0;
            end else begin
               if (local_result_ci_clk_en == 1) begin
                  case (client_result.err_inject)
                     NO_ERROR:   begin
                                    if (result_request == 1) begin
                                       __prepare_result();
                                       executing_result = 1;
                                    end
                                    if (executing_result == 0) begin
                                       __drive_idle();
                                    end else begin
                                       if (result_ready == 0) begin
                                          __drive_idle();
                                       end else begin
                                          __drive_result();
                                          executing_result = 0;
                                       end
                                    end
                                 end
                     FORCE_DONE: begin
                                    __prepare_result();
                                    __drive_result();
                                    
                                    // Overriding previously loaded result
                                    executing_result = 0;
                                    
                                    // Force result only lasts a cycle
                                    client_result.err_inject = NO_ERROR;
                                 end
                     NO_DONE:    begin
                                    if (  result_request == 1 || 
                                          executing_result == 0) begin
                                       __prepare_result();
                                       executing_result = 1;
                                    end
                                    
                                    if (result_ready == 0) begin
                                       __drive_idle();
                                    end else begin
                                       __drive_result();
                                       executing_result = 0;
                                    
                                       // Force result only lasts a cycle
                                       client_result.err_inject = NO_ERROR;
                                    end
                                 end
                  endcase
                  
               end
            end
         end

         // Timeout
         always @(posedge ci_clk or posedge ci_reset) begin
            if (ci_reset == 1) begin
               instruction_timeout_ctr    = 0;
               clock_enable_timeout_ctr   = 0;
            end else begin
               if (local_instr_ci_clk_en == 1) begin
                  clock_enable_timeout_ctr = 0;
                  
                  // Timeout for instruction
                  if (instruction_start == 1) begin
                     instruction_timeout_ctr = 0;
                  end else begin
                     if (processing_instruction == 0) begin
                        instruction_timeout_ctr++;
                        if (  instruction_timeout > 0 &&
                              instruction_timeout_ctr >= instruction_timeout) begin
                           $sformat(
                              message,
                              "%m: instruction stalled for at least %0d cycles",
                              instruction_timeout_ctr
                           );
                           print(VERBOSITY_ERROR, message);
                           ->signal_fatal_error;
                        end
                     end
                  end
                  
                  // No result timeout for the slave BFM always execute a result
                  //  and it does not care how long that result would be
                  
               end else begin
                  // Timeout for clock enable
                  clock_enable_timeout_ctr++;
                  if (  clock_enable_timeout > 0 &&
                        clock_enable_timeout_ctr >= clock_enable_timeout) begin
                     $sformat(
                        message,
                        "%m: clock disabled for at least %0d cycles",
                        clock_enable_timeout_ctr
                     );
                     print(VERBOSITY_ERROR, message);
                     ->signal_fatal_error;
                  end
               end
            end
         end
         
      end else begin
         
         // For getting combinatorial custom instruction
         // Use sensitivity list to use the common function
         always @(
            ci_dataa or ci_datab or 
            ci_n or ci_a or ci_b or ci_c or 
            ci_readra or ci_readrb or ci_writerc) begin
            __get_instruction();
            __received_instruction_event();
         end
         
         // Drive out the result
         always @(client_result.value) begin
            ci_result = client_result.value;
         end
         
      end
   
   endgenerate
// synthesis translate_on

endmodule

// =head1 SEE ALSO
// altera_nios2_comb_instr_master_bfm/
// =cut
