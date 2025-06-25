Avalon-ST Video Verification IP Suite
-------------------------------------

This verification area provides the Avalon-ST Video verification class library,
together with two example tests.  One test reads and writes frames of video to
a DUT, and the other tests the DUT by generating constrained random video packets.


class_library
-------------
The class library itself.


dut
---
An example DUT (Device under Test) - in this case an RGB to greyscale converter.


example_constrained_random
--------------------------
A constrained random test, as described in the documentation.  To run the test the
following resources (or equivalent) must be present :

quartus, questasim (or other simulator which supports systemverilog)

The test can then be run by following the instructions given in the VIP User Guide
release for 11.1.


example_video_files 
--------------------------
A video file read/write test, as described in the documentation.  To run the test the
following resources (or equivalent) must be present :

quartus, questasim (or other simulator which supports systemverilog)

The test can then be run by following the instructions given in the VIP User Guide
release for 11.1.


testbench
---------
The example testbench comprises a source BFM, DUT, and a sink BFM.


--
Copyright Altera 2011
