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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_nios2_custom_instr_master_bfm/altera_nios2_custom_instr_master_bfm.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_nios2_custom_instr_master_bfm
// =head1 SYNOPSIS
// NiosII Custom Instruction Master BFM
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This is a Bus Functional Model (BFM) for a NiosII Custom Instruction Master.
//-----------------------------------------------------------------------------
`timescale 1ns / 1ns

module altera_nios2_custom_instr_master_bfm (
   clk,
   reset,
   
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
   input                            clk;
   input                            reset;
   
   output                           ci_clk;
   output                           ci_reset;
   output                           ci_clk_en;
   
   // =head2 NiosII Custom Instruction Interface
   output [WORD_WIDTH-1: 0]         ci_dataa;
   output [WORD_WIDTH-1: 0]         ci_datab;
   input  [WORD_WIDTH-1: 0]         ci_result;
   
   output                           ci_start;
   input                            ci_done;
   
   output [EXT_WIDTH-1: 0]          ci_n;
   
   output [ADDR_WIDTH-1: 0]         ci_a;
   output [ADDR_WIDTH-1: 0]         ci_b;
   output [ADDR_WIDTH-1: 0]         ci_c;
   output                           ci_readra;
   output                           ci_readrb;
   output                           ci_writerc;
   // =cut
   
   // synthesis translate_off
   import verbosity_pkg::*;
   import avalon_utilities_pkg::*;
   
   typedef logic [WORD_WIDTH-1: 0]  ci_data_t;
   typedef logic [EXT_WIDTH-1: 0]   ci_n_t;
   typedef logic [ADDR_WIDTH-1: 0]  ci_addr_t;
   
   logic                            ci_clk;
   logic                            ci_reset;
   logic                            ci_clk_en;
   
   ci_data_t                        ci_dataa;
   ci_data_t                        ci_datab;
   
   logic                            ci_start;
   logic                            ci_done;
   
   ci_n_t                           ci_n;
   
   ci_addr_t                        ci_a;
   ci_addr_t                        ci_b;
   ci_addr_t                        ci_c;
   logic                            ci_readra;
   logic                            ci_readrb;
   logic                            ci_writerc;
   
   typedef enum {
      COMBINATORIAL,
      FIXED,
      VARIABLE
   } mode_t;
   
   typedef enum {
      NO_ERROR,
      NO_START
   } error_inject_t;
   
   //--------------------------------------------------------------------------
   // Private Types and Variables
   //--------------------------------------------------------------------------
   typedef struct packed {
       ci_data_t                    dataa;
       ci_data_t                    datab;
       ci_n_t                       n;
       ci_addr_t                    a;
       ci_addr_t                    b;
       ci_addr_t                    c;
       logic                        readra;
       logic                        readrb;
       logic                        writerc;
       ci_data_t                    idle;
       error_inject_t               err_inject;
   } Instruction_t;
   
   typedef struct packed {
       ci_data_t                    value;
       ci_data_t                    delay;
   } Result_t;
   
   // Combinatorial driven
   mode_t         mode                       = COMBINATORIAL;
   
   Instruction_t  instruction_queue[$];
   Result_t       result_queue[$];
   
   Instruction_t  client_instruction         = 'x;
   Instruction_t  phy_instruction            = 'x;
   Instruction_t  reset_instruction          = 'x;

   Result_t       client_result              = 'x;
   Result_t       phy_result                 = 'x;
   
   int            instruction_queue_size     = 0;
   int            max_instruction_queue_size = 256;
   int            min_instruction_queue_size = 2;
   
   int            result_queue_size          = 0;
   int            max_result_queue_size      = 256;
   int            min_result_queue_size      = 2;
   
   bit            loaded_new_instruction     = 0;
   bit            bfm_is_busy                = 0;
   bit            instruction_done           = 0;
   bit            client_ci_clk_en           = 1;
   ci_data_t      idle_ctr                   = 0;
   error_inject_t err_object                 = NO_ERROR;
   error_inject_t err_injected               = NO_ERROR;
   int            instruction_timeout        = 1000;
   int            result_timeout             = 1000;
   int            clock_enable_timeout       = 1000;
   int            instruction_timeout_ctr    = 0;
   int            result_timeout_ctr         = 0;
   int            clock_enable_timeout_ctr   = 0;
   
   // Synchronously driven
   int            clock_ctr;
   int            instruction_ctr;
   bit            instruction_on_intf;
   bit            instruction_start;
   int            instruction_delay;
   bit            local_ci_clk_en;
   
   IdleOutputValue_t idle_output_config      = UNKNOWN;
   
   //--------------------------------------------------------------------------
   // Private Methods
   //--------------------------------------------------------------------------
   
   function automatic void __hello();
      // Introduction Message to console
      $sformat(message, "%m: - Hello from altera_nios2_custom_instr_master_bfm");
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
   //  interface (API). In this case the application program is the test bench
   //  which instantiates and controls and queries state in this BFM component.
   //  Test programs must only use these public access methods and events to
   //  communicate with this BFM component. The API and the module pins
   //  are the only interfaces in this component that are guaranteed to be
   //  stable. The API will be maintained for the life of the product.
   //  While we cannot prevent a test program from directly accessing local
   //  tasks, functions, or data private to the BFM, there is no guarantee that
   //  these will be present in the future. In fact, it is best for the user
   //  to assume that the underlying implementation of this component can
   //  and will change.
   // =cut
   //--------------------------------------------------------------------------
   event signal_fatal_error; // public
   // Event to indicate a fatal error. It terminates simulation
   
   event signal_instruction_start; // public
   // Event to indicate that an instruction is to be driven out
   
   event signal_result_received; // public
   // Event to indicate that a result has been received
   
   event signal_unexpected_result_received; // public
   // Event to indicate that a result has been received without an instruction ,
   //  result is not pushed into the queue however
   
   event signal_instructions_completed; // public
   // Event to indicate that all the instruction in the BFM has been executed
   
   event signal_max_instruction_queue_size; // public
   // Event to indicate that the pending instruction queue size
   //  is above the maximum threshold
   
   event signal_min_instruction_queue_size; // public
   // Event to indicate that the pending instruction queue size
   //  is below the minimum threshold
   
   event signal_max_result_queue_size; // public
   // Event to indicate that the pending result queue size
   //  is above the maximum threshold
   
   event signal_min_result_queue_size; // public
   // Event to indicate that the pending result queue size
   //  is below the minimum threshold
   
   // =cut
   event signal_clock;
   
   event signal_ci_clk_en_changed;
   
   function automatic string get_version(); // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1"
      string ret_version = "13.1";
      return ret_version;
   endfunction
   
   function automatic void set_ci_clk_en( // public
      bit enable
   );
      // Set the ci_clk_en synchronously with the clock
      $sformat(message, "%m: called set_ci_clk_en - %h", enable);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_MULTI_CYCLE == 1) begin
         client_ci_clk_en = enable;
         ->signal_ci_clk_en_changed;
      end else begin
         client_ci_clk_en = 1;
         $sformat(
            message,
            "%m: called set_ci_clk_en when USE_MULTI_CYCLE is %0d",
            USE_MULTI_CYCLE
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void insert_instruction( // public
      ci_data_t   dataa    = 'x,
      ci_data_t   datab    = 'x,
      ci_n_t      n        = 'x,
      ci_addr_t   a        = 'x,
      ci_addr_t   b        = 'x,
      ci_addr_t   c        = 'x,
      logic       readra   = 1,
      logic       readrb   = 1,
      logic       writerc  = 1,
      ci_data_t   idle     = 0,
      int         err_inj  = 0
   );
      // A simplified API to set and push instruction
      $sformat(message, "%m: called insert_instruction");
      print(VERBOSITY_DEBUG, message);
      
      if (NUM_OPERANDS > 0) begin
         set_instruction_dataa(dataa);
      end
      if (NUM_OPERANDS > 1) begin
         set_instruction_datab(datab);
      end
      if (USE_EXTENSION == 1) begin
         set_instruction_n(n);
      end
      if (USE_READRA == 1) begin
         set_instruction_a(a);
         set_instruction_readra(readra);
      end
      if (USE_READRB == 1) begin
         set_instruction_b(b);
         set_instruction_readrb(readrb);
      end
      if (USE_WRITERC == 1) begin
         set_instruction_c(c);
         set_instruction_writerc(writerc);
      end
      if (mode == FIXED || mode == VARIABLE) begin
         set_instruction_idle(idle);
      end
      if (mode == FIXED || mode == VARIABLE) begin
         set_instruction_err_inject(err_inj);
      end
      
      push_instruction();
      
   endfunction
   
   function automatic void retrive_result( // public
      output ci_data_t   value,
      output ci_data_t   delay
   );
      // A simplified API to pop and get result
      $sformat(message, "%m: called retrive_result");
      print(VERBOSITY_DEBUG, message);
      
      pop_result();
      
      if (USE_RESULT == 1) begin
         value = get_result_value();
         delay = get_result_delay();
      end
      
   endfunction
   
   function automatic void set_instruction_dataa( // public
      ci_data_t data
   );
      // Set the instruction dataa operand value
      $sformat(message, "%m: called set_instruction_dataa - %h", data);
      print(VERBOSITY_DEBUG, message);
      
      if (NUM_OPERANDS > 0) begin
         client_instruction.dataa = data;
      end else begin
         client_instruction.dataa = reset_instruction.dataa;
         $sformat(
            message,
            "%m: called set_instruction_dataa when NUM_OPERANDS is %0d",
            NUM_OPERANDS
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_datab( // public
      ci_data_t data
   );
      // Set the instruction datab operand value
      $sformat(message, "%m: called set_instruction_datab - %h", data);
      print(VERBOSITY_DEBUG, message);
      
      if (NUM_OPERANDS > 1) begin
         client_instruction.datab = data;
      end else begin
         client_instruction.datab = reset_instruction.datab;
         $sformat(
            message,
            "%m: called set_instruction_datab when NUM_OPERANDS is %0d",
            NUM_OPERANDS
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_n( // public
      ci_n_t code
   );
      // Set the instruction extended opcode value n
      $sformat(message, "%m: called set_instruction_n - %h", code);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_EXTENSION == 1) begin
         client_instruction.n = code;
      end else begin
         client_instruction.n = reset_instruction.n;
         $sformat(
            message,
            "%m: called set_instruction_n when USE_EXTENSION is %0d",
            USE_EXTENSION
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_a( // public
      ci_addr_t address
   );
      // Set the instruction register file address a value
      $sformat(message, "%m: called set_instruction_a - %h", address);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_READRA == 1) begin
         client_instruction.a = address;
      end else begin
         client_instruction.a = reset_instruction.a;
         $sformat(
            message,
            "%m: called set_instruction_a when USE_READRA is %0d",
            USE_READRA
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_b( // public
      ci_addr_t address
   );
      // Set the instruction register file address b value
      $sformat(message, "%m: called set_instruction_b - %h", address);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_READRB == 1) begin
         client_instruction.b = address;
      end else begin
         client_instruction.b = reset_instruction.b;
         $sformat(
            message,
            "%m: called set_instruction_a when USE_READRB is %0d",
            USE_READRB
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_c( // public
      ci_addr_t address
   );
      // Set the instruction register file address c value
      $sformat(message, "%m: called set_instruction_c - %h", address);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_WRITERC == 1) begin
         client_instruction.c = address;
      end else begin
         client_instruction.c = reset_instruction.c;
         $sformat(
            message,
            "%m: called set_instruction_a when USE_WRITERC is %0d",
            USE_WRITERC
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_readra( // public
      logic enable
   );
      // Set the instruction register file read a value
      $sformat(message, "%m: called set_instruction_readra - %h", enable);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_READRA == 1) begin
         client_instruction.readra = enable;
      end else begin
         client_instruction.readra = reset_instruction.readra;
         $sformat(
            message,
            "%m: called set_instruction_readra when USE_READRA is %0d",
            USE_READRA
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_readrb( // public
      logic enable
   );
      // Set the instruction register file read b value
      $sformat(message, "%m: called set_instruction_readrb - %h", enable);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_READRB == 1) begin
         client_instruction.readrb = enable;
      end else begin
         client_instruction.readrb = reset_instruction.readrb;
         $sformat(
            message,
            "%m: called set_instruction_readrb when USE_READRB is %0d",
            USE_READRB
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_writerc( // public
      logic enable
   );
      // Set the instruction register file write c value
      $sformat(message, "%m: called set_instruction_writerc - %h", enable);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_WRITERC == 1) begin
         client_instruction.writerc = enable;
      end else begin
         client_instruction.writerc = reset_instruction.writerc;
         $sformat(
            message,
            "%m: called set_instruction_writerc when USE_WRITERC is %0d",
            USE_WRITERC
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_idle( // public
      ci_data_t idle
   );
      // Set the instruction idle value
      $sformat(message, "%m: called set_instruction_idle - %0d", idle);
      print(VERBOSITY_DEBUG, message);
      
      if (mode == FIXED || mode == VARIABLE) begin
         client_instruction.idle = idle;
      end else begin
         client_instruction.idle = reset_instruction.idle;
         $sformat(
            message,
            "%m: called set_instruction_idle when mode is %0s",
            mode.name
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_instruction_err_inject( // public
      int err_inj = 0
   );
      // Set the instruction to be executed in pre-defined error
      $sformat(message, "%m: called set_instruction_err_inject - %0d", err_inj);
      print(VERBOSITY_DEBUG, message);
      
      if (mode == FIXED || mode == VARIABLE) begin
         if (err_inj >= err_object.first() && 
             err_inj <= err_object.last()) begin
            $cast(err_object, err_inj);
            client_instruction.err_inject = err_object;
         end else begin
            client_instruction.err_inject = reset_instruction.err_inject;
            $sformat(
               message,
               "%m: called set_instruction_err_inject out of range: %0d",
               err_inj);
            print(VERBOSITY_WARNING, message);
         end
      end else begin
         client_instruction.err_inject = reset_instruction.err_inject;
         $sformat(
            message,
            "%m: called set_instruction_err_inject when mode is %0s",
            mode.name
         );
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic ci_data_t get_result_value(); // public
      // Return the instruction result
      $sformat(message, "%m: called get_result_value - %0d",
               client_result.value);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_RESULT == 1) begin
         return client_result.value;
      end else begin
         $sformat(
            message,
            "%m: called get_result_value when USE_RESULT is %0d",
            USE_RESULT
         );
         print(VERBOSITY_WARNING, message);
         return 'x;
      end
   endfunction
   
   function automatic ci_data_t get_result_delay(); // public
      // Return the result delay
      $sformat(message, "%m: called get_result_delay - %0d",
               client_result.delay);
      print(VERBOSITY_DEBUG, message);
      
      if (USE_RESULT == 1) begin
         return client_result.delay;
      end else begin
         $sformat(
            message,
            "%m: called get_result_delay when USE_RESULT is %0d",
            USE_RESULT
         );
         print(VERBOSITY_WARNING, message);
         return 0;
      end
   endfunction
   
   function automatic void push_instruction(); // public
      // Push a new instruction into the queue.
      //  The BFM will drive the appropriate signals on the instruction
      //  interface according to its descriptor field values.
      
      $sformat(message, "%m: called push_instruction");
      print(VERBOSITY_DEBUG, message);
      
      if (reset) begin
         $sformat(message, "%m: Illegal command while reset asserted");
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
      instruction_queue.push_back(client_instruction);
   endfunction
   
   function automatic void pop_result(); // public
      // Pop the result instruction from the queue before querying contents
      string message;
      
      $sformat(message, "%m: called pop_result - queue depth %0d",
               result_queue.size());
      print(VERBOSITY_DEBUG, message);
      
      if (result_queue.size <= 0) begin
         $sformat(message, "%m: There's no result to be popped");
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
      client_result = result_queue.pop_front();
   endfunction
   
   function automatic void set_max_instruction_queue_size( // public
      int size
   );
      // Set the instruction maximum queue size threshold.
      //  The public event signal_max_instruction_queue_size
      //  will fire when the threshold is exceeded.
      max_instruction_queue_size = size;
   endfunction
   
   function automatic void set_min_instruction_queue_size( // public
      int size
   );
      // Set the instruction minimum queue size threshold.
      //  The public event signal_min_instruction_queue_size
      //  will fire when the queue level is below this threshold.
      min_instruction_queue_size = size;
   endfunction
   
   function automatic void set_max_result_queue_size( // public
      int size
   );
      // Set the result maximum queue size threshold.
      //  The public event signal_max_result_queue_size
      //  will fire when the threshold is exceeded.
      max_result_queue_size = size;
   endfunction
   
   function automatic void set_min_result_queue_size( // public
      int size
   );
      // Set the result minimum queue size threshold.
      //  The public event signal_min_result_queue_size
      //  will fire when the queue level is below this threshold.
      min_result_queue_size = size;
   endfunction
   
   function automatic int get_instruction_queue_size(); // public
      // Return the number of instructions in the queue.
      $sformat(message, "%m: called get_instruction_queue_size");
      print(VERBOSITY_DEBUG, message);
      return instruction_queue.size();
   endfunction
   
   function automatic int get_result_queue_size(); // public
      // Return the number of results in the queue.
      $sformat(message, "%m: called get_result_queue_size");
      print(VERBOSITY_DEBUG, message);
      return result_queue.size();
   endfunction
   
   function automatic void set_instruction_timeout( // public
      int timeout = 1000
   );
      // Set timeout value for instruction. Set to 0 to never timeout.
      instruction_timeout = timeout;
   endfunction
   
   function automatic void set_result_timeout( // public
      int timeout = 1000
   );
      // Set timeout value for result. Set to 0 to never timeout.
      result_timeout = timeout;
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
      __setup_reset_instruction();
   endtask
   
   function automatic IdleOutputValue_t get_idle_state_output_configuration(); // public
      // Get the configuration of output signal value during interface idle
      
      return idle_output_config;
   endfunction
   
   // =cut
   
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
      __setup_reset_instruction();
   endtask
   
   task __setup_reset_instruction();
      // Init reset instruction
      reset_instruction.readra  = 1;
      reset_instruction.readrb  = 1;
      reset_instruction.writerc = 1;
      reset_instruction.idle    = 0;
      
      case (idle_output_config)
         LOW: begin
            reset_instruction.dataa   = '0;
            reset_instruction.datab   = '0;
            reset_instruction.n       = '0;
            reset_instruction.a       = '0;
            reset_instruction.b       = '0;
            reset_instruction.c       = '0;
         end
         HIGH: begin
            reset_instruction.dataa   = '1;
            reset_instruction.datab   = '1;
            reset_instruction.n       = '1;
            reset_instruction.a       = '1;
            reset_instruction.b       = '1;
            reset_instruction.c       = '1;
         end
         RANDOM: begin
            reset_instruction.dataa   = $random;
            reset_instruction.datab   = $random;
            reset_instruction.n       = $random;
            reset_instruction.a       = $random;
            reset_instruction.b       = $random;
            reset_instruction.c       = $random;
         end
         UNKNOWN: begin
            reset_instruction.dataa   = 'x;
            reset_instruction.datab   = 'x;
            reset_instruction.n       = 'x;
            reset_instruction.a       = 'x;
            reset_instruction.b       = 'x;
            reset_instruction.c       = 'x;
         end
         default: begin
            reset_instruction.dataa   = 'x;
            reset_instruction.datab   = 'x;
            reset_instruction.n       = 'x;
            reset_instruction.a       = 'x;
            reset_instruction.b       = 'x;
            reset_instruction.c       = 'x;
         end
      endcase
   endtask
   
   task __load_instruction();
      // Load instruction onto the internal instruction struct
      phy_instruction         = instruction_queue.pop_front();
      
      loaded_new_instruction  = 1;
      bfm_is_busy             = 1;
      idle_ctr                = phy_instruction.idle;
   endtask
   
   task __drive_instruction();
      // Task to drive the loaded instruction onto
      //  the interface
      ci_dataa             <= phy_instruction.dataa;
      ci_datab             <= phy_instruction.datab;
      ci_n                 <= phy_instruction.n;
      ci_a                 <= phy_instruction.a;
      ci_b                 <= phy_instruction.b;
      ci_c                 <= phy_instruction.c;
      ci_readra            <= phy_instruction.readra;
      ci_readrb            <= phy_instruction.readrb;
      ci_writerc           <= phy_instruction.writerc;
      
      
      // Drive instruction counter
      if (loaded_new_instruction == 0) begin
         instruction_start    <= 0;
         instruction_on_intf  <= 1;
      end else begin
         if (phy_instruction.err_inject == NO_START) begin
            instruction_start    <= 0;
            instruction_on_intf  <= 0;
         end else begin
            instruction_start    <= 1;
            instruction_on_intf  <= 1;
         end
         instruction_ctr <= instruction_ctr + 1;
         -> signal_instruction_start;
      end
      
      // Unset this, since the transaction has been driven out
      loaded_new_instruction  = 0;
   endtask
   
   task __drive_idle();
      // Task to drive idle
      ci_dataa             <= reset_instruction.dataa;
      ci_datab             <= reset_instruction.datab;
      ci_n                 <= reset_instruction.n;
      ci_a                 <= reset_instruction.a;
      ci_b                 <= reset_instruction.b;
      ci_c                 <= reset_instruction.c;
      ci_readra            <= reset_instruction.readra;
      ci_readrb            <= reset_instruction.readrb;
      ci_writerc           <= reset_instruction.writerc;
      instruction_start    <= 0;
      instruction_on_intf  <= 0;
      
      // Drive instruction counter
      if (idle_ctr > 0) begin
         idle_ctr = idle_ctr - 1;
      end
      
   endtask
   
   //=cut
   
   initial begin
      __hello();
      __init_bfm();
   end
   
   // Output clk and reset
   assign ci_clk = clk;
   assign ci_reset = reset;
   
   // Drive ci_start signal
   assign ci_start = 
      (mode == FIXED || mode == VARIABLE) ?
      instruction_start : 0;
   
   // Trigger queue threshold event for instruction queue
   always @(posedge ci_clk) begin
      if (instruction_queue.size() > max_instruction_queue_size) begin
         ->signal_max_instruction_queue_size;
      end else if (instruction_queue.size() < min_instruction_queue_size) begin
         ->signal_min_instruction_queue_size;
      end
   end
   
   // Trigger queue threshold event for result queue
   always @(posedge ci_clk) begin
      if (result_queue.size() > max_result_queue_size) begin
         ->signal_max_result_queue_size;
      end else if (result_queue.size() < min_result_queue_size) begin
         ->signal_min_result_queue_size;
      end
   end
   
   // Abort simulation on fatal error
   always @(signal_fatal_error) __abort_simulation();
   
   // Synchronously changing the ci_clk_en.
   //  Need local_ci_clk_en to prevent direct usage of output port ci_clk_en
   always @(posedge clk or posedge reset or signal_ci_clk_en_changed) begin
      if (reset == 1) begin
         client_ci_clk_en  <= 1;
         local_ci_clk_en   <= 1;
      end else begin
         if (USE_MULTI_CYCLE == 0) begin
            local_ci_clk_en   <= 1;
         end else begin
            fork 
               begin
                  wait (signal_clock.triggered);
                  local_ci_clk_en   <= client_ci_clk_en;
               end
            join_none
         end
      end
   end
   
   assign ci_clk_en = local_ci_clk_en;
   
   // Calculate the fixed latency from when an instruction begins
   // Always check for done first, to cater for combinatorial mode
   always @(posedge clk or posedge reset) begin
      if (reset == 1) begin
         instruction_delay <= 1;
      end else begin
         if (local_ci_clk_en == 1) begin
            if (instruction_done == 1) begin
               instruction_delay <= 1;
            end else begin
               if (instruction_start == 1) begin
                  instruction_delay <= 2;
               end else begin
                  if (instruction_delay > 1) begin
                     instruction_delay <= instruction_delay + 1;
                  end
               end
            end
         end
      end
   end
   
   // Determine if an instruction was done
   always @(*) begin
      if (mode == COMBINATORIAL) begin
         instruction_done = instruction_start;
      end else begin
         if (instruction_on_intf == 0) begin
            instruction_done = 0;
         end else begin
            if (mode == VARIABLE) begin
               instruction_done = 
                  (instruction_start == 0) ?
                  ci_done : 0;
            end else begin
               instruction_done = 
                  (instruction_delay == FIXED_LENGTH) ?
                  1 : 0;
            end
         end
      end
   end
   
   // For clock counter and ci_clk_en purpose
   always @(posedge clk or posedge reset) begin
      if (reset == 1) begin
         clock_ctr <= 0;
      end else begin
         if (local_ci_clk_en == 1) begin
            clock_ctr <= clock_ctr + 1;
         end else begin
            clock_ctr <= clock_ctr;
         end
         ->signal_clock;
      end
   end
   
   // Load and drive instruction onto the interface
   always @(posedge clk or posedge reset) begin
      if (reset == 1) begin
         __drive_idle();
         instruction_ctr         <= 0;
         client_instruction      = reset_instruction;
         phy_instruction         = reset_instruction;
         instruction_queue       = {};
         loaded_new_instruction  = 0;
         bfm_is_busy             = 0;
      end else begin
      
         // If clock is enabled, execute 
         if (local_ci_clk_en == 1) begin
            
            // Check if the previous instruction has finished
            if (USE_MULTI_CYCLE == 0) begin
               if (instruction_on_intf == 1 && instruction_done == 1) begin
                  bfm_is_busy = 0;
               end
            end else begin
               if (instruction_start == 0 &&
                   instruction_on_intf == 1 &&
                   instruction_done == 1) begin
                  bfm_is_busy = 0;
               end
            end
            
            // If previous instruction is done
            //  or simluation has just started,
            //  load new instruction from the queue
            if (bfm_is_busy == 0) begin
               if (instruction_queue.size() > 0) begin
                  __load_instruction();
                  bfm_is_busy = 1;
               end else begin
                  ->signal_instructions_completed;
                  bfm_is_busy = 0;
               end
            end
            
            // Drive instruction if there is any
            if (bfm_is_busy == 0) begin
               __drive_idle();
            end else begin
               if (idle_ctr == 0) begin
                  __drive_instruction();
                  if (phy_instruction.err_inject == NO_START) begin
                     bfm_is_busy = 0;
                  end 
               end else begin
                  __drive_idle();
               end
            end
            
         end
      end
   end
   
   // Monitor the interface
   always @(posedge clk or posedge reset) begin
      if (reset) begin
         client_result  = 'x;
         phy_result     = 'x;
         result_queue   = {};
      end begin
         // Check whether we are in an instruction cycle,
         //  if yes then sample
         if (local_ci_clk_en == 1) begin
            if (mode == COMBINATORIAL) begin
               if (instruction_done == 1) begin
                  phy_result.value = ci_result;
                  phy_result.delay = instruction_delay;
                  result_queue.push_back(phy_result);
                  ->signal_result_received;
               end
            end else begin
               if (instruction_done == 1) begin
                  if (instruction_on_intf == 1) begin
                     if (instruction_start == 0) begin
                        phy_result.value = ci_result;
                        phy_result.delay = instruction_delay;
                        result_queue.push_back(phy_result);
                        ->signal_result_received;
                     end else begin
                        ->signal_unexpected_result_received;
                     end
                  end else begin
                     ->signal_unexpected_result_received;
                  end
               end
            end
         end
      end
   end
   
   // Timeout
   always @(posedge clk or posedge reset) begin
      if (reset == 1) begin
         instruction_timeout_ctr    = 0;
         result_timeout_ctr         = 0;
         clock_enable_timeout_ctr   = 0;
      end else begin
         if (local_ci_clk_en == 1) begin
            clock_enable_timeout_ctr = 0;
            
            // Timeout for instruction
            if (instruction_start == 1) begin
               instruction_timeout_ctr = 0;
            end else begin
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
            
            // Timeout for result, different from instruction as result
            //  need at least one cycle to return for multi-cycle mode
            if (mode == VARIABLE) begin
               if (instruction_on_intf == 1) begin
                  if (instruction_done == 1) begin
                     result_timeout_ctr = 0;
                  end else begin
                     result_timeout_ctr++;
                     if (  result_timeout > 0 &&
                           result_timeout_ctr > result_timeout) begin
                        $sformat(
                           message,
                           "%m: result stalled for at least %0d cycles",
                           result_timeout_ctr
                        );
                        print(VERBOSITY_ERROR, message);
                        ->signal_fatal_error;
                     end
                  end
               end else begin
                  result_timeout_ctr = 0;
               end
            end
            
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
   
// synthesis translate_on

endmodule

// =head1 SEE ALSO
// altera_nios2_comb_instr_slave_bfm/
// =cut
