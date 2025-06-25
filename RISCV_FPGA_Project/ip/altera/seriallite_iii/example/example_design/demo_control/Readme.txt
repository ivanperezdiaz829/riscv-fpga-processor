README for Downloading the Two Lane Loopback Example Design onto the Board

Basic Download Instructions
1. Compile the Seriallite III Design to generate the SOF file.
2. Download seriallite_iii_streaming_demo.sof onto the board.
3. Change into the ../demo_control/software and run the batch_script.sh
      -the batch_script.sh will generate and download demo_control.c program 
   with NIOS II
4. A terminal will open with a set of commands to test two lane loopback for
   the Seriallite Streaming Source and Sink.


Alternatively, Descriptive Download Instructions
1. Compile the Seriallite III Example Design to generate the seriallite_streaming_demo.sof file 
   under the /demo/ directory.
2. Change into the ../demo_control/software and run the batch_script.sh:
   >./batch_script.sh
   This will generate a demo_control.elf file that will later be downloaded onto the FPGA board under 
   the /app/ directory. 
3. Open Quartus and launch Qsys by going to: Tools > Qsys
4. In Qsys, launch a Nios II command shell under: Tools > Nios Command Shell [gcc4]
5. Download the seriallite_streaming_demo.sof file under the /demo/ directory onto the FPGA board by:
     a. Using Programmer in Quartus
     b. In the Nios Command Shell, change into the /demo/ directory. Specify the cable number of
        the USB cable by substituting it for $CABLE_NUMBER:
        >nios2-configure-sof $CABLE_NUMBER seriallite_streaming_demo.sof

6. Download the demo_control.elf file onto the board while still in the /demo/ directory. In the            Nios Command Shell specify the cable number of the USB cable by substituting for $CABLE_NUMBER:
   > nios2-download -g -r $CABLE_NUMBER ../demo_control/software/app/demo_control.elf

7. To start an a terminal connection with the board, type the following command into the Nios       
   Command Shell (using the same cable number from step 5b and 6):
   >nios2-terminal $CABLE_NUMBER
   
8. The terminal should now display an interactive session for the Seriallite III Loopback Example
    Design. 