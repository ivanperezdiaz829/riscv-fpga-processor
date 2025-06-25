
PCI Compiler v7.1 sopc_builder_example_readme.txt
====================================================

This readme file includes information on how to compile and simulate 
the SOPC Builder example project in Quartus II software.  

To successfully compile and simulate the project you will need

	o  Quartus(R) II v7.1 Software or higher
	o  Modelsim(R)-Altera v6.1g or higher


Steps
=====
1) Open the project file 'chip_top.qpf' in Quartus II software

2) Open SOPC Builder
   In the Quartus II software 'Tools' menu select 'SOPC Builder...'
 
   Note: For Solaris and Linux Operating system, follow these steps
   i)  Choose SOPC Builder Setup (File menu)
   ii) Add <path>/pci_compiler/lib/sopc_builder to the 
       Component/Kit Library Search Path box

3) Generate the SOPC Builder system
   In SOPC Builder click the 'Generate' button, and then exit back to Quartus
   when generation is complete.

   
   
   Note: The project shipped in sopc_builder_example directory has PCI Constraints
   	 specified in .qsf(quartus setting file). Hence it is not required to reapply
   	 PCI constraints.


4) To Simulate the project perform the following steps:
	
	Note: The PCI testbench mstr_tranx located at pci_sim/verilog/mt32 directory
	      has the command specifed in the USER COMMAND section that will exercise
	      target transaction to on-chip memory and DMA transactions to transfer data
	      from PCI testbench trgt_tranx to on-chip memory and vice-versa.
	
	a) Start the Modelsim-Altera simulator.
	
	b) in the simulator change your working directory to 
	   <path>/pci_compiler/sopc_builder_example/chip_top_sim
	   
	c) Run the script, type the following command in the simulator
	   command prompt
	   >source setup_sim.do
	   
	d) To compile all the files and load the design, type the following
	   command in the simulator command prompt
	   >s

	e) To see all the signals in the wave window, type the following command
	   in the simulator command prompt
	   >do wave_presets.do
	   
	f) To simulate the desing, type the following command
	   in the simulator command prompt
	   >run -all
	   	   
	   

7) To Compile the project in Quaruts II software perform the following steps

       a) Choose "Start Compilation"(processing menu) in the Quartus II software
       
       b) After compilation, expand the Timing Analyzer folder in the compilation
          report by clicking the +symbol next to the folder name. Note the values 
          of Clock Setup , tsu, th and tco report sections.


Contacting Altera
=================

Although we have made every effort to ensure that this version of the 
PCI Compiler v7.1 works correctly, there might be problems that we have not encountered. 
If you have a question or problem that is not answered by the information provided in this 
readme file or the user guide, please contact your Altera(R) Field Applications Engineer.

If you have additional questions that are not answered in the documentation
provided with this function, please contact Altera through your local sales
representative or any of the following sources:

Technical Support:	        800 800-EPLD (3753)(USA & Canada)
                                7:00 a.m. to 5:00 p.m. Pacific Time
                                +1 408-544-8767 (Internationally)
                                7:00 a.m. to 5:00 p.m. (GMT -8:00) Pacific Time
Product literature:             www.altera.com
Altera literature services:     lit_req@altera.com
Non-technical customer service: 800-767-3753 (USA & Canada)
                                7:00 a.m. to 5:00 p.m. Pacific Time
                                + 1 408-544-7000 (Internationally)
			        7:00 a.m. to 5:00 p.m. (GMT -8:00) Pacific Time
FTP site:                       ftp.altera.com

Copyright (C) 2006 Altera Corporation. All rights reserved.



