Running Legacy Testbench PCI Compiler README File
=================================================
 PCI Compiler Legacy Simulation example design requires update for each
 release. To run this example designs simulation against the latest 
 installation, all associated files needed for simulation needs to be 
 generated. This will ensure that the simulation netlist will always reflect 
 the latest PCI Compiler installation in the system.

 Affected Directory:
 -------------------
 verilog/pci_mt32
 verilog/pci_mt64
 verilog/pci_t32
 verilog/pci_t64
 vhdl/pci_mt32
 vhdl/pci_mt64 
 vhdl/pci_t32
 vhdl/pci_t64

Updating the design for Simulation:
-----------------------------------

1. Create a new Quartus project 
2. Open the Megawizard Plug-in Manager and select "Edit an existing 
   custom megafunction variation"
3. Browse to directory pci_top and select pci_top.vhd or pci_top.v
4. If prompted, select the latest PCI Compiler installation under
   "Megafunction Name"
5. In the PCI Compiler Megacore page, select "Set up simulation"
6. Tick "Generate Simulation Model" and select "OK"
7. Select "Generate". A promt will appear notyfing that a few files will be
   overwritten. Select OK.


