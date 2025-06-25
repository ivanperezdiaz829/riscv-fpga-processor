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


//IP Functional Simulation Model
//VERSION_BEGIN 11.0 cbx_mgl 2011:03:16:10:48:23:SJ cbx_simgen 2011:03:16:10:47:11:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2011 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// You may only use these simulation model output files for simulation
// purposes and expressly not for synthesis or any other purposes (in which
// event Altera disclaims all warranties of any kind).


//synopsys translate_off

//synthesis_resources = lut 420 mux21 152 oper_decoder 6 
`timescale 1 ps / 1 ps
module  altpcierd_rx_ecrc_64
	( 
	clk,
	crcbad,
	crcvalid,
	data,
	datavalid,
	empty,
	endofpacket,
	reset_n,
	startofpacket) /* synthesis synthesis_clearbox=1 */;
	input   clk;
	output   crcbad;
	output   crcvalid;
	input   [63:0]  data;
	input   datavalid;
	input   [2:0]  empty;
	input   endofpacket;
	input   reset_n;
	input   startofpacket;

	reg	nlO000i13;
	reg	nlO000i14;
	reg	nlO000O11;
	reg	nlO000O12;
	reg	nlO001l15;
	reg	nlO001l16;
	reg	nlO00il10;
	reg	nlO00il9;
	reg	nlO00li7;
	reg	nlO00li8;
	reg	nlO00Oi5;
	reg	nlO00Oi6;
	reg	nlO010l27;
	reg	nlO010l28;
	reg	nlO011i31;
	reg	nlO011i32;
	reg	nlO011O29;
	reg	nlO011O30;
	reg	nlO01ii25;
	reg	nlO01ii26;
	reg	nlO01iO23;
	reg	nlO01iO24;
	reg	nlO01ll21;
	reg	nlO01ll22;
	reg	nlO01Oi19;
	reg	nlO01Oi20;
	reg	nlO01OO17;
	reg	nlO01OO18;
	reg	nlO0i0i1;
	reg	nlO0i0i2;
	reg	nlO0i1O3;
	reg	nlO0i1O4;
	reg	nlO100l47;
	reg	nlO100l48;
	reg	nlO100O45;
	reg	nlO100O46;
	reg	nlO11li51;
	reg	nlO11li52;
	reg	nlO11ll49;
	reg	nlO11ll50;
	reg	nlO1O0i43;
	reg	nlO1O0i44;
	reg	nlO1O0O41;
	reg	nlO1O0O42;
	reg	nlO1Oil39;
	reg	nlO1Oil40;
	reg	nlO1Oli37;
	reg	nlO1Oli38;
	reg	nlO1OlO35;
	reg	nlO1OlO36;
	reg	nlO1OOl33;
	reg	nlO1OOl34;
	reg	n01ii;
	reg	n01iO;
	reg	n0lO0i;
	reg	n0lO0l;
	reg	n0lO0O;
	reg	n0lO1O;
	reg	n0lOii;
	reg	n0lOil;
	reg	n0lOiO;
	reg	nlO0i0l;
	reg	nlO0i0O;
	reg	nlO0iii;
	reg	nlO0iil;
	reg	nlO0iiO;
	reg	nlO0ili;
	reg	nlO0ill;
	reg	nlO0ilO;
	reg	nlO0iOi;
	reg	nlO0iOl;
	reg	nlO0iOO;
	reg	nlO0l0i;
	reg	nlO0l0l;
	reg	nlO0l0O;
	reg	nlO0l1i;
	reg	nlO0l1l;
	reg	nlO0l1O;
	reg	nlO0lii;
	reg	nlO0lil;
	reg	nlO0liO;
	reg	nlO0lli;
	reg	nlO0lOl;
	reg	nlO0O0l;
	reg	nlO0O1i;
	reg	nlO0O1O;
	reg	nlO0Oii;
	reg	nlO0OiO;
	reg	nlO0Oll;
	reg	nlO0OOi;
	reg	nlO0OOO;
	reg	nlOi00l;
	reg	nlOi01i;
	reg	nlOi01O;
	reg	nlOi0ii;
	reg	nlOi0iO;
	reg	nlOi0lO;
	reg	nlOi10i;
	reg	nlOi10O;
	reg	nlOi11l;
	reg	nlOi1il;
	reg	nlOi1li;
	reg	nlOi1lO;
	reg	nlOi1Ol;
	reg	nlOiiii;
	reg	nlOiiiO;
	reg	nlOiill;
	reg	nlOiiOi;
	reg	nlOiiOO;
	reg	nlOil0i;
	reg	nlOil0O;
	reg	nlOil1l;
	reg	nlOiliO;
	reg	nlOilll;
	reg	nlOilOi;
	reg	nlOilOO;
	reg	nlOiO0i;
	reg	nlOiO0O;
	reg	nlOiO1l;
	reg	nlOiOil;
	reg	nlOiOll;
	reg	nlOiOOi;
	reg	nlOiOOO;
	reg	nlOl00i;
	reg	nlOl00l;
	reg	nlOl00O;
	reg	nlOl01i;
	reg	nlOl01l;
	reg	nlOl01O;
	reg	nlOl0ii;
	reg	nlOl0il;
	reg	nlOl0iO;
	reg	nlOl0li;
	reg	nlOl0ll;
	reg	nlOl0lO;
	reg	nlOl0Oi;
	reg	nlOl0Ol;
	reg	nlOl0OO;
	reg	nlOl10i;
	reg	nlOl10O;
	reg	nlOl11l;
	reg	nlOl1il;
	reg	nlOl1li;
	reg	nlOl1lO;
	reg	nlOl1Oi;
	reg	nlOl1Ol;
	reg	nlOl1OO;
	reg	nlOli0i;
	reg	nlOli0l;
	reg	nlOli0O;
	reg	nlOli1i;
	reg	nlOli1l;
	reg	nlOli1O;
	reg	nlOliii;
	reg	nlOliil;
	reg	nlOliiO;
	reg	nlOlili;
	reg	nlOlill;
	reg	nlOlilO;
	reg	nlOliOi;
	reg	nlOliOl;
	reg	nlOliOO;
	reg	nlOll0i;
	reg	nlOll0l;
	reg	nlOll0O;
	reg	nlOll1i;
	reg	nlOll1l;
	reg	nlOll1O;
	reg	nlOllii;
	reg	nlOllil;
	reg	nlOlliO;
	reg	nlOllli;
	reg	nlOllll;
	reg	nlOlllO;
	reg	nlOllOi;
	reg	nlOllOl;
	reg	nlOllOO;
	reg	nlOlO0i;
	reg	nlOlO0l;
	reg	nlOlO0O;
	reg	nlOlO1i;
	reg	nlOlO1l;
	reg	nlOlO1O;
	reg	nlOlOii;
	reg	nlOlOil;
	reg	nlOlOiO;
	reg	nlOlOli;
	reg	nlOlOll;
	reg	nlOlOlO;
	reg	nlOlOOi;
	reg	nlOlOOl;
	reg	nlOlOOO;
	reg	nlOO00i;
	reg	nlOO00l;
	reg	nlOO00O;
	reg	nlOO01i;
	reg	nlOO01l;
	reg	nlOO01O;
	reg	nlOO0ii;
	reg	nlOO0il;
	reg	nlOO0iO;
	reg	nlOO0li;
	reg	nlOO0ll;
	reg	nlOO0lO;
	reg	nlOO0Oi;
	reg	nlOO0Ol;
	reg	nlOO0OO;
	reg	nlOO10i;
	reg	nlOO10l;
	reg	nlOO10O;
	reg	nlOO11i;
	reg	nlOO11l;
	reg	nlOO11O;
	reg	nlOO1ii;
	reg	nlOO1il;
	reg	nlOO1iO;
	reg	nlOO1li;
	reg	nlOO1ll;
	reg	nlOO1lO;
	reg	nlOO1Oi;
	reg	nlOO1Ol;
	reg	nlOO1OO;
	reg	nlOOi0i;
	reg	nlOOi0l;
	reg	nlOOi0O;
	reg	nlOOi1i;
	reg	nlOOi1l;
	reg	nlOOi1O;
	reg	nlOOiii;
	reg	nlOOiil;
	reg	nlOOiiO;
	reg	nlOOili;
	reg	nlOOill;
	reg	nlOOilO;
	reg	nlOOiOi;
	reg	nlOOiOl;
	reg	nlOOiOO;
	reg	nlOOl0i;
	reg	nlOOl0l;
	reg	nlOOl0O;
	reg	nlOOl1i;
	reg	nlOOl1l;
	reg	nlOOl1O;
	reg	nlOOlii;
	reg	nlOOlil;
	reg	nlOOliO;
	reg	nlOOlli;
	reg	nlOOlll;
	wire	wire_n01il_CLRN;
	reg	n1l1O;
	reg	nl011i;
	reg	nl100i;
	reg	nl100l;
	reg	nl100O;
	reg	nl101i;
	reg	nl101l;
	reg	nl101O;
	reg	nl10ii;
	reg	nl10il;
	reg	nl10iO;
	reg	nl10li;
	reg	nl10ll;
	reg	nl10lO;
	reg	nl10Oi;
	reg	nl10Ol;
	reg	nl10OO;
	reg	nl11ll;
	reg	nl11lO;
	reg	nl11Oi;
	reg	nl11Ol;
	reg	nl11OO;
	reg	nl1i0i;
	reg	nl1i0l;
	reg	nl1i0O;
	reg	nl1i1i;
	reg	nl1i1l;
	reg	nl1i1O;
	reg	nl1iii;
	reg	nl1iil;
	reg	nl1iiO;
	reg	nl1ili;
	reg	nl1ill;
	reg	nl1ilO;
	reg	nl1iOi;
	reg	nl1iOl;
	reg	nl1iOO;
	reg	nl1l0i;
	reg	nl1l0l;
	reg	nl1l0O;
	reg	nl1l1i;
	reg	nl1l1l;
	reg	nl1l1O;
	reg	nl1lii;
	reg	nl1lil;
	reg	nl1liO;
	reg	nl1lli;
	reg	nl1lll;
	reg	nl1llO;
	reg	nl1lOi;
	reg	nl1lOl;
	reg	nl1lOO;
	reg	nl1O0i;
	reg	nl1O0l;
	reg	nl1O0O;
	reg	nl1O1i;
	reg	nl1O1l;
	reg	nl1O1O;
	reg	nl1Oii;
	reg	nl1Oil;
	reg	nl1OiO;
	reg	nl1Oli;
	reg	nl1Oll;
	reg	nl1OlO;
	reg	nl1OOi;
	reg	nl1OOl;
	reg	nl1OOO;
	wire	wire_n1l1l_CLRN;
	reg	n0lOli;
	reg	n0lOll;
	reg	n0lOlO;
	reg	n0lOOi;
	reg	n0lOOl;
	reg	n0lOOO;
	reg	n0O00i;
	reg	n0O00l;
	reg	n0O00O;
	reg	n0O01i;
	reg	n0O01l;
	reg	n0O01O;
	reg	n0O0ii;
	reg	n0O0il;
	reg	n0O0iO;
	reg	n0O0li;
	reg	n0O0ll;
	reg	n0O0lO;
	reg	n0O0Oi;
	reg	n0O0Ol;
	reg	n0O0OO;
	reg	n0O10i;
	reg	n0O10l;
	reg	n0O10O;
	reg	n0O11i;
	reg	n0O11l;
	reg	n0O11O;
	reg	n0O1ii;
	reg	n0O1il;
	reg	n0O1iO;
	reg	n0O1li;
	reg	n0O1ll;
	reg	n0O1lO;
	reg	n0O1Oi;
	reg	n0O1Ol;
	reg	n0O1OO;
	reg	n0Oi0i;
	reg	n0Oi0l;
	reg	n0Oi0O;
	reg	n0Oi1i;
	reg	n0Oi1l;
	reg	n0Oi1O;
	reg	n0Oiii;
	reg	n0Oiil;
	reg	n0OiiO;
	reg	n0Oili;
	reg	n0Oill;
	reg	n0OilO;
	reg	n0OiOi;
	reg	n0OiOl;
	reg	n0OiOO;
	reg	n0Ol0i;
	reg	n0Ol0l;
	reg	n0Ol0O;
	reg	n0Ol1i;
	reg	n0Ol1l;
	reg	n0Ol1O;
	reg	n0Olii;
	reg	n0Olil;
	reg	n0OliO;
	reg	n0Olli;
	reg	n0Olll;
	reg	n0OllO;
	reg	n0OlOi;
	reg	n0OlOl;
	reg	n0OlOO;
	reg	n0OO0i;
	reg	n0OO0l;
	reg	n0OO0O;
	reg	n0OO1i;
	reg	n0OO1l;
	reg	n0OO1O;
	reg	nl11li;
	reg	nl11iO_clk_prev;
	wire	wire_nl11iO_CLRN;
	wire	wire_nl11iO_PRN;
	reg	n0i0i;
	reg	n0i0l;
	reg	n0i0O;
	reg	n0i1O;
	reg	n0iii;
	reg	n0iil;
	reg	n0iiO;
	reg	n0ili;
	reg	n0ill;
	reg	n0ilO;
	reg	n0iOi;
	reg	n0iOl;
	reg	n0iOO;
	reg	n0l0i;
	reg	n0l0l;
	reg	n0l0O;
	reg	n0l1i;
	reg	n0l1l;
	reg	n0l1O;
	reg	n0lii;
	reg	n0lil;
	reg	n0liO;
	reg	n0lli;
	reg	n0lll;
	reg	n0llO;
	reg	n0lOi;
	reg	n0lOl;
	reg	n0lOO;
	reg	n0O1i;
	reg	n0O1l;
	reg	n0O1O;
	reg	n11i;
	reg	nlOOO_clk_prev;
	wire	wire_nlOOO_CLRN;
	wire	wire_nlOOO_PRN;
	wire	wire_n0O0i_dataout;
	wire	wire_n0O0l_dataout;
	wire	wire_n0O0O_dataout;
	wire	wire_n0Oii_dataout;
	wire	wire_n0Oil_dataout;
	wire	wire_n0OiO_dataout;
	wire	wire_n0Oli_dataout;
	wire	wire_n0Oll_dataout;
	wire	wire_n0OlO_dataout;
	wire	wire_n0OOi_dataout;
	wire	wire_n0OOl_dataout;
	wire	wire_n0OOO_dataout;
	wire	wire_ni00i_dataout;
	wire	wire_ni00l_dataout;
	wire	wire_ni01i_dataout;
	wire	wire_ni01l_dataout;
	wire	wire_ni01O_dataout;
	wire	wire_ni10i_dataout;
	wire	wire_ni10l_dataout;
	wire	wire_ni10O_dataout;
	wire	wire_ni11i_dataout;
	wire	wire_ni11l_dataout;
	wire	wire_ni11O_dataout;
	wire	wire_ni1ii_dataout;
	wire	wire_ni1il_dataout;
	wire	wire_ni1iO_dataout;
	wire	wire_ni1li_dataout;
	wire	wire_ni1ll_dataout;
	wire	wire_ni1lO_dataout;
	wire	wire_ni1Oi_dataout;
	wire	wire_ni1Ol_dataout;
	wire	wire_ni1OO_dataout;
	wire	wire_nl00i_dataout;
	wire	wire_nl00l_dataout;
	wire	wire_nl00O_dataout;
	wire	wire_nl01i_dataout;
	wire	wire_nl01l_dataout;
	wire	wire_nl01O_dataout;
	wire	wire_nl0ii_dataout;
	wire	wire_nl0il_dataout;
	wire	wire_nl0iO_dataout;
	wire	wire_nl0li_dataout;
	wire	wire_nl0ll_dataout;
	wire	wire_nl0lO_dataout;
	wire	wire_nl0Oi_dataout;
	wire	wire_nl0Ol_dataout;
	wire	wire_nl0OO_dataout;
	wire	wire_nl1li_dataout;
	wire	wire_nl1ll_dataout;
	wire	wire_nl1lO_dataout;
	wire	wire_nl1Oi_dataout;
	wire	wire_nl1Ol_dataout;
	wire	wire_nl1OO_dataout;
	wire	wire_nli0i_dataout;
	wire	wire_nli0l_dataout;
	wire	wire_nli0O_dataout;
	wire	wire_nli1i_dataout;
	wire	wire_nli1l_dataout;
	wire	wire_nli1O_dataout;
	wire	wire_nliii_dataout;
	wire	wire_nliil_dataout;
	wire	wire_nliiO_dataout;
	wire	wire_nlili_dataout;
	wire	wire_nlill_dataout;
	wire	wire_nlilO_dataout;
	wire	wire_nliOi_dataout;
	wire	wire_nliOl_dataout;
	wire	wire_nliOO_dataout;
	wire	wire_nll0i_dataout;
	wire	wire_nll0l_dataout;
	wire	wire_nll0O_dataout;
	wire	wire_nll1i_dataout;
	wire	wire_nll1l_dataout;
	wire	wire_nll1O_dataout;
	wire	wire_nllii_dataout;
	wire	wire_nllil_dataout;
	wire	wire_nlliO_dataout;
	wire	wire_nllli_dataout;
	wire	wire_nllll_dataout;
	wire	wire_nlllO_dataout;
	wire	wire_nllOi_dataout;
	wire	wire_nllOl_dataout;
	wire	wire_nllOO_dataout;
	wire	wire_nlO0i_dataout;
	wire	wire_nlO0l_dataout;
	wire	wire_nlO0lll_dataout;
	wire	wire_nlO0llO_dataout;
	wire	wire_nlO0lOi_dataout;
	wire	wire_nlO0lOO_dataout;
	wire	wire_nlO0O_dataout;
	wire	wire_nlO0O0i_dataout;
	wire	wire_nlO0O0O_dataout;
	wire	wire_nlO0O1l_dataout;
	wire	wire_nlO0Oil_dataout;
	wire	wire_nlO0Oli_dataout;
	wire	wire_nlO0OlO_dataout;
	wire	wire_nlO0OOl_dataout;
	wire	wire_nlO1i_dataout;
	wire	wire_nlO1l_dataout;
	wire	wire_nlO1O_dataout;
	wire	wire_nlOi00i_dataout;
	wire	wire_nlOi00O_dataout;
	wire	wire_nlOi01l_dataout;
	wire	wire_nlOi0il_dataout;
	wire	wire_nlOi0li_dataout;
	wire	wire_nlOi0Oi_dataout;
	wire	wire_nlOi0Ol_dataout;
	wire	wire_nlOi0OO_dataout;
	wire	wire_nlOi10l_dataout;
	wire	wire_nlOi11i_dataout;
	wire	wire_nlOi11O_dataout;
	wire	wire_nlOi1ii_dataout;
	wire	wire_nlOi1iO_dataout;
	wire	wire_nlOi1ll_dataout;
	wire	wire_nlOi1Oi_dataout;
	wire	wire_nlOi1OO_dataout;
	wire	wire_nlOii_dataout;
	wire	wire_nlOii0i_dataout;
	wire	wire_nlOii0l_dataout;
	wire	wire_nlOii0O_dataout;
	wire	wire_nlOii1i_dataout;
	wire	wire_nlOii1l_dataout;
	wire	wire_nlOii1O_dataout;
	wire	wire_nlOiiil_dataout;
	wire	wire_nlOiili_dataout;
	wire	wire_nlOiilO_dataout;
	wire	wire_nlOiiOl_dataout;
	wire	wire_nlOil_dataout;
	wire	wire_nlOil0l_dataout;
	wire	wire_nlOil1i_dataout;
	wire	wire_nlOil1O_dataout;
	wire	wire_nlOilil_dataout;
	wire	wire_nlOilli_dataout;
	wire	wire_nlOillO_dataout;
	wire	wire_nlOilOl_dataout;
	wire	wire_nlOiO_dataout;
	wire	wire_nlOiO0l_dataout;
	wire	wire_nlOiO1i_dataout;
	wire	wire_nlOiO1O_dataout;
	wire	wire_nlOiOii_dataout;
	wire	wire_nlOiOli_dataout;
	wire	wire_nlOiOlO_dataout;
	wire	wire_nlOiOOl_dataout;
	wire	wire_nlOl10l_dataout;
	wire	wire_nlOl11i_dataout;
	wire	wire_nlOl11O_dataout;
	wire	wire_nlOl1ii_dataout;
	wire	wire_nlOl1iO_dataout;
	wire	wire_nlOli_dataout;
	wire	wire_nlOll_dataout;
	wire	wire_nlOlO_dataout;
	wire	wire_nlOOi_dataout;
	wire  [3:0]   wire_n001O_o;
	wire  [3:0]   wire_n00ll_o;
	wire  [3:0]   wire_n00Oi_o;
	wire  [7:0]   wire_n0i1l_o;
	wire  [3:0]   wire_nlOiOiO_o;
	wire  [7:0]   wire_nlOl1ll_o;
	wire  nllOO0i;
	wire  nllOO0l;
	wire  nllOO0O;
	wire  nllOO1l;
	wire  nllOO1O;
	wire  nllOOii;
	wire  nllOOil;
	wire  nllOOiO;
	wire  nllOOli;
	wire  nllOOll;
	wire  nllOOlO;
	wire  nllOOOi;
	wire  nllOOOl;
	wire  nllOOOO;
	wire  nlO00lO;
	wire  nlO0i1i;
	wire  nlO100i;
	wire  nlO101i;
	wire  nlO101l;
	wire  nlO101O;
	wire  nlO10ii;
	wire  nlO10il;
	wire  nlO10iO;
	wire  nlO10li;
	wire  nlO10ll;
	wire  nlO10lO;
	wire  nlO10Oi;
	wire  nlO10Ol;
	wire  nlO10OO;
	wire  nlO110i;
	wire  nlO110l;
	wire  nlO110O;
	wire  nlO111i;
	wire  nlO111l;
	wire  nlO111O;
	wire  nlO11ii;
	wire  nlO11il;
	wire  nlO11iO;
	wire  nlO11lO;
	wire  nlO11Oi;
	wire  nlO11Ol;
	wire  nlO11OO;
	wire  nlO1i0i;
	wire  nlO1i0l;
	wire  nlO1i0O;
	wire  nlO1i1i;
	wire  nlO1i1l;
	wire  nlO1i1O;
	wire  nlO1iii;
	wire  nlO1iil;
	wire  nlO1iiO;
	wire  nlO1ili;
	wire  nlO1ill;
	wire  nlO1ilO;
	wire  nlO1iOi;
	wire  nlO1iOl;
	wire  nlO1iOO;
	wire  nlO1l0i;
	wire  nlO1l0l;
	wire  nlO1l0O;
	wire  nlO1l1i;
	wire  nlO1l1l;
	wire  nlO1l1O;
	wire  nlO1lii;
	wire  nlO1lil;
	wire  nlO1liO;
	wire  nlO1lli;
	wire  nlO1lll;
	wire  nlO1llO;
	wire  nlO1lOi;
	wire  nlO1lOl;
	wire  nlO1lOO;
	wire  nlO1O1i;
	wire  nlO1O1l;
	wire  nlO1O1O;

	initial
		nlO000i13 = 0;
	always @ ( posedge clk)
		  nlO000i13 <= nlO000i14;
	event nlO000i13_event;
	initial
		#1 ->nlO000i13_event;
	always @(nlO000i13_event)
		nlO000i13 <= {1{1'b1}};
	initial
		nlO000i14 = 0;
	always @ ( posedge clk)
		  nlO000i14 <= nlO000i13;
	initial
		nlO000O11 = 0;
	always @ ( posedge clk)
		  nlO000O11 <= nlO000O12;
	event nlO000O11_event;
	initial
		#1 ->nlO000O11_event;
	always @(nlO000O11_event)
		nlO000O11 <= {1{1'b1}};
	initial
		nlO000O12 = 0;
	always @ ( posedge clk)
		  nlO000O12 <= nlO000O11;
	initial
		nlO001l15 = 0;
	always @ ( posedge clk)
		  nlO001l15 <= nlO001l16;
	event nlO001l15_event;
	initial
		#1 ->nlO001l15_event;
	always @(nlO001l15_event)
		nlO001l15 <= {1{1'b1}};
	initial
		nlO001l16 = 0;
	always @ ( posedge clk)
		  nlO001l16 <= nlO001l15;
	initial
		nlO00il10 = 0;
	always @ ( posedge clk)
		  nlO00il10 <= nlO00il9;
	initial
		nlO00il9 = 0;
	always @ ( posedge clk)
		  nlO00il9 <= nlO00il10;
	event nlO00il9_event;
	initial
		#1 ->nlO00il9_event;
	always @(nlO00il9_event)
		nlO00il9 <= {1{1'b1}};
	initial
		nlO00li7 = 0;
	always @ ( posedge clk)
		  nlO00li7 <= nlO00li8;
	event nlO00li7_event;
	initial
		#1 ->nlO00li7_event;
	always @(nlO00li7_event)
		nlO00li7 <= {1{1'b1}};
	initial
		nlO00li8 = 0;
	always @ ( posedge clk)
		  nlO00li8 <= nlO00li7;
	initial
		nlO00Oi5 = 0;
	always @ ( posedge clk)
		  nlO00Oi5 <= nlO00Oi6;
	event nlO00Oi5_event;
	initial
		#1 ->nlO00Oi5_event;
	always @(nlO00Oi5_event)
		nlO00Oi5 <= {1{1'b1}};
	initial
		nlO00Oi6 = 0;
	always @ ( posedge clk)
		  nlO00Oi6 <= nlO00Oi5;
	initial
		nlO010l27 = 0;
	always @ ( posedge clk)
		  nlO010l27 <= nlO010l28;
	event nlO010l27_event;
	initial
		#1 ->nlO010l27_event;
	always @(nlO010l27_event)
		nlO010l27 <= {1{1'b1}};
	initial
		nlO010l28 = 0;
	always @ ( posedge clk)
		  nlO010l28 <= nlO010l27;
	initial
		nlO011i31 = 0;
	always @ ( posedge clk)
		  nlO011i31 <= nlO011i32;
	event nlO011i31_event;
	initial
		#1 ->nlO011i31_event;
	always @(nlO011i31_event)
		nlO011i31 <= {1{1'b1}};
	initial
		nlO011i32 = 0;
	always @ ( posedge clk)
		  nlO011i32 <= nlO011i31;
	initial
		nlO011O29 = 0;
	always @ ( posedge clk)
		  nlO011O29 <= nlO011O30;
	event nlO011O29_event;
	initial
		#1 ->nlO011O29_event;
	always @(nlO011O29_event)
		nlO011O29 <= {1{1'b1}};
	initial
		nlO011O30 = 0;
	always @ ( posedge clk)
		  nlO011O30 <= nlO011O29;
	initial
		nlO01ii25 = 0;
	always @ ( posedge clk)
		  nlO01ii25 <= nlO01ii26;
	event nlO01ii25_event;
	initial
		#1 ->nlO01ii25_event;
	always @(nlO01ii25_event)
		nlO01ii25 <= {1{1'b1}};
	initial
		nlO01ii26 = 0;
	always @ ( posedge clk)
		  nlO01ii26 <= nlO01ii25;
	initial
		nlO01iO23 = 0;
	always @ ( posedge clk)
		  nlO01iO23 <= nlO01iO24;
	event nlO01iO23_event;
	initial
		#1 ->nlO01iO23_event;
	always @(nlO01iO23_event)
		nlO01iO23 <= {1{1'b1}};
	initial
		nlO01iO24 = 0;
	always @ ( posedge clk)
		  nlO01iO24 <= nlO01iO23;
	initial
		nlO01ll21 = 0;
	always @ ( posedge clk)
		  nlO01ll21 <= nlO01ll22;
	event nlO01ll21_event;
	initial
		#1 ->nlO01ll21_event;
	always @(nlO01ll21_event)
		nlO01ll21 <= {1{1'b1}};
	initial
		nlO01ll22 = 0;
	always @ ( posedge clk)
		  nlO01ll22 <= nlO01ll21;
	initial
		nlO01Oi19 = 0;
	always @ ( posedge clk)
		  nlO01Oi19 <= nlO01Oi20;
	event nlO01Oi19_event;
	initial
		#1 ->nlO01Oi19_event;
	always @(nlO01Oi19_event)
		nlO01Oi19 <= {1{1'b1}};
	initial
		nlO01Oi20 = 0;
	always @ ( posedge clk)
		  nlO01Oi20 <= nlO01Oi19;
	initial
		nlO01OO17 = 0;
	always @ ( posedge clk)
		  nlO01OO17 <= nlO01OO18;
	event nlO01OO17_event;
	initial
		#1 ->nlO01OO17_event;
	always @(nlO01OO17_event)
		nlO01OO17 <= {1{1'b1}};
	initial
		nlO01OO18 = 0;
	always @ ( posedge clk)
		  nlO01OO18 <= nlO01OO17;
	initial
		nlO0i0i1 = 0;
	always @ ( posedge clk)
		  nlO0i0i1 <= nlO0i0i2;
	event nlO0i0i1_event;
	initial
		#1 ->nlO0i0i1_event;
	always @(nlO0i0i1_event)
		nlO0i0i1 <= {1{1'b1}};
	initial
		nlO0i0i2 = 0;
	always @ ( posedge clk)
		  nlO0i0i2 <= nlO0i0i1;
	initial
		nlO0i1O3 = 0;
	always @ ( posedge clk)
		  nlO0i1O3 <= nlO0i1O4;
	event nlO0i1O3_event;
	initial
		#1 ->nlO0i1O3_event;
	always @(nlO0i1O3_event)
		nlO0i1O3 <= {1{1'b1}};
	initial
		nlO0i1O4 = 0;
	always @ ( posedge clk)
		  nlO0i1O4 <= nlO0i1O3;
	initial
		nlO100l47 = 0;
	always @ ( posedge clk)
		  nlO100l47 <= nlO100l48;
	event nlO100l47_event;
	initial
		#1 ->nlO100l47_event;
	always @(nlO100l47_event)
		nlO100l47 <= {1{1'b1}};
	initial
		nlO100l48 = 0;
	always @ ( posedge clk)
		  nlO100l48 <= nlO100l47;
	initial
		nlO100O45 = 0;
	always @ ( posedge clk)
		  nlO100O45 <= nlO100O46;
	event nlO100O45_event;
	initial
		#1 ->nlO100O45_event;
	always @(nlO100O45_event)
		nlO100O45 <= {1{1'b1}};
	initial
		nlO100O46 = 0;
	always @ ( posedge clk)
		  nlO100O46 <= nlO100O45;
	initial
		nlO11li51 = 0;
	always @ ( posedge clk)
		  nlO11li51 <= nlO11li52;
	event nlO11li51_event;
	initial
		#1 ->nlO11li51_event;
	always @(nlO11li51_event)
		nlO11li51 <= {1{1'b1}};
	initial
		nlO11li52 = 0;
	always @ ( posedge clk)
		  nlO11li52 <= nlO11li51;
	initial
		nlO11ll49 = 0;
	always @ ( posedge clk)
		  nlO11ll49 <= nlO11ll50;
	event nlO11ll49_event;
	initial
		#1 ->nlO11ll49_event;
	always @(nlO11ll49_event)
		nlO11ll49 <= {1{1'b1}};
	initial
		nlO11ll50 = 0;
	always @ ( posedge clk)
		  nlO11ll50 <= nlO11ll49;
	initial
		nlO1O0i43 = 0;
	always @ ( posedge clk)
		  nlO1O0i43 <= nlO1O0i44;
	event nlO1O0i43_event;
	initial
		#1 ->nlO1O0i43_event;
	always @(nlO1O0i43_event)
		nlO1O0i43 <= {1{1'b1}};
	initial
		nlO1O0i44 = 0;
	always @ ( posedge clk)
		  nlO1O0i44 <= nlO1O0i43;
	initial
		nlO1O0O41 = 0;
	always @ ( posedge clk)
		  nlO1O0O41 <= nlO1O0O42;
	event nlO1O0O41_event;
	initial
		#1 ->nlO1O0O41_event;
	always @(nlO1O0O41_event)
		nlO1O0O41 <= {1{1'b1}};
	initial
		nlO1O0O42 = 0;
	always @ ( posedge clk)
		  nlO1O0O42 <= nlO1O0O41;
	initial
		nlO1Oil39 = 0;
	always @ ( posedge clk)
		  nlO1Oil39 <= nlO1Oil40;
	event nlO1Oil39_event;
	initial
		#1 ->nlO1Oil39_event;
	always @(nlO1Oil39_event)
		nlO1Oil39 <= {1{1'b1}};
	initial
		nlO1Oil40 = 0;
	always @ ( posedge clk)
		  nlO1Oil40 <= nlO1Oil39;
	initial
		nlO1Oli37 = 0;
	always @ ( posedge clk)
		  nlO1Oli37 <= nlO1Oli38;
	event nlO1Oli37_event;
	initial
		#1 ->nlO1Oli37_event;
	always @(nlO1Oli37_event)
		nlO1Oli37 <= {1{1'b1}};
	initial
		nlO1Oli38 = 0;
	always @ ( posedge clk)
		  nlO1Oli38 <= nlO1Oli37;
	initial
		nlO1OlO35 = 0;
	always @ ( posedge clk)
		  nlO1OlO35 <= nlO1OlO36;
	event nlO1OlO35_event;
	initial
		#1 ->nlO1OlO35_event;
	always @(nlO1OlO35_event)
		nlO1OlO35 <= {1{1'b1}};
	initial
		nlO1OlO36 = 0;
	always @ ( posedge clk)
		  nlO1OlO36 <= nlO1OlO35;
	initial
		nlO1OOl33 = 0;
	always @ ( posedge clk)
		  nlO1OOl33 <= nlO1OOl34;
	event nlO1OOl33_event;
	initial
		#1 ->nlO1OOl33_event;
	always @(nlO1OOl33_event)
		nlO1OOl33 <= {1{1'b1}};
	initial
		nlO1OOl34 = 0;
	always @ ( posedge clk)
		  nlO1OOl34 <= nlO1OOl33;
	initial
	begin
		n01ii = 0;
		n01iO = 0;
		n0lO0i = 0;
		n0lO0l = 0;
		n0lO0O = 0;
		n0lO1O = 0;
		n0lOii = 0;
		n0lOil = 0;
		n0lOiO = 0;
		nlO0i0l = 0;
		nlO0i0O = 0;
		nlO0iii = 0;
		nlO0iil = 0;
		nlO0iiO = 0;
		nlO0ili = 0;
		nlO0ill = 0;
		nlO0ilO = 0;
		nlO0iOi = 0;
		nlO0iOl = 0;
		nlO0iOO = 0;
		nlO0l0i = 0;
		nlO0l0l = 0;
		nlO0l0O = 0;
		nlO0l1i = 0;
		nlO0l1l = 0;
		nlO0l1O = 0;
		nlO0lii = 0;
		nlO0lil = 0;
		nlO0liO = 0;
		nlO0lli = 0;
		nlO0lOl = 0;
		nlO0O0l = 0;
		nlO0O1i = 0;
		nlO0O1O = 0;
		nlO0Oii = 0;
		nlO0OiO = 0;
		nlO0Oll = 0;
		nlO0OOi = 0;
		nlO0OOO = 0;
		nlOi00l = 0;
		nlOi01i = 0;
		nlOi01O = 0;
		nlOi0ii = 0;
		nlOi0iO = 0;
		nlOi0lO = 0;
		nlOi10i = 0;
		nlOi10O = 0;
		nlOi11l = 0;
		nlOi1il = 0;
		nlOi1li = 0;
		nlOi1lO = 0;
		nlOi1Ol = 0;
		nlOiiii = 0;
		nlOiiiO = 0;
		nlOiill = 0;
		nlOiiOi = 0;
		nlOiiOO = 0;
		nlOil0i = 0;
		nlOil0O = 0;
		nlOil1l = 0;
		nlOiliO = 0;
		nlOilll = 0;
		nlOilOi = 0;
		nlOilOO = 0;
		nlOiO0i = 0;
		nlOiO0O = 0;
		nlOiO1l = 0;
		nlOiOil = 0;
		nlOiOll = 0;
		nlOiOOi = 0;
		nlOiOOO = 0;
		nlOl00i = 0;
		nlOl00l = 0;
		nlOl00O = 0;
		nlOl01i = 0;
		nlOl01l = 0;
		nlOl01O = 0;
		nlOl0ii = 0;
		nlOl0il = 0;
		nlOl0iO = 0;
		nlOl0li = 0;
		nlOl0ll = 0;
		nlOl0lO = 0;
		nlOl0Oi = 0;
		nlOl0Ol = 0;
		nlOl0OO = 0;
		nlOl10i = 0;
		nlOl10O = 0;
		nlOl11l = 0;
		nlOl1il = 0;
		nlOl1li = 0;
		nlOl1lO = 0;
		nlOl1Oi = 0;
		nlOl1Ol = 0;
		nlOl1OO = 0;
		nlOli0i = 0;
		nlOli0l = 0;
		nlOli0O = 0;
		nlOli1i = 0;
		nlOli1l = 0;
		nlOli1O = 0;
		nlOliii = 0;
		nlOliil = 0;
		nlOliiO = 0;
		nlOlili = 0;
		nlOlill = 0;
		nlOlilO = 0;
		nlOliOi = 0;
		nlOliOl = 0;
		nlOliOO = 0;
		nlOll0i = 0;
		nlOll0l = 0;
		nlOll0O = 0;
		nlOll1i = 0;
		nlOll1l = 0;
		nlOll1O = 0;
		nlOllii = 0;
		nlOllil = 0;
		nlOlliO = 0;
		nlOllli = 0;
		nlOllll = 0;
		nlOlllO = 0;
		nlOllOi = 0;
		nlOllOl = 0;
		nlOllOO = 0;
		nlOlO0i = 0;
		nlOlO0l = 0;
		nlOlO0O = 0;
		nlOlO1i = 0;
		nlOlO1l = 0;
		nlOlO1O = 0;
		nlOlOii = 0;
		nlOlOil = 0;
		nlOlOiO = 0;
		nlOlOli = 0;
		nlOlOll = 0;
		nlOlOlO = 0;
		nlOlOOi = 0;
		nlOlOOl = 0;
		nlOlOOO = 0;
		nlOO00i = 0;
		nlOO00l = 0;
		nlOO00O = 0;
		nlOO01i = 0;
		nlOO01l = 0;
		nlOO01O = 0;
		nlOO0ii = 0;
		nlOO0il = 0;
		nlOO0iO = 0;
		nlOO0li = 0;
		nlOO0ll = 0;
		nlOO0lO = 0;
		nlOO0Oi = 0;
		nlOO0Ol = 0;
		nlOO0OO = 0;
		nlOO10i = 0;
		nlOO10l = 0;
		nlOO10O = 0;
		nlOO11i = 0;
		nlOO11l = 0;
		nlOO11O = 0;
		nlOO1ii = 0;
		nlOO1il = 0;
		nlOO1iO = 0;
		nlOO1li = 0;
		nlOO1ll = 0;
		nlOO1lO = 0;
		nlOO1Oi = 0;
		nlOO1Ol = 0;
		nlOO1OO = 0;
		nlOOi0i = 0;
		nlOOi0l = 0;
		nlOOi0O = 0;
		nlOOi1i = 0;
		nlOOi1l = 0;
		nlOOi1O = 0;
		nlOOiii = 0;
		nlOOiil = 0;
		nlOOiiO = 0;
		nlOOili = 0;
		nlOOill = 0;
		nlOOilO = 0;
		nlOOiOi = 0;
		nlOOiOl = 0;
		nlOOiOO = 0;
		nlOOl0i = 0;
		nlOOl0l = 0;
		nlOOl0O = 0;
		nlOOl1i = 0;
		nlOOl1l = 0;
		nlOOl1O = 0;
		nlOOlii = 0;
		nlOOlil = 0;
		nlOOliO = 0;
		nlOOlli = 0;
		nlOOlll = 0;
	end
	always @ ( posedge clk or  negedge wire_n01il_CLRN)
	begin
		if (wire_n01il_CLRN == 1'b0) 
		begin
			n01ii <= 0;
			n01iO <= 0;
			n0lO0i <= 0;
			n0lO0l <= 0;
			n0lO0O <= 0;
			n0lO1O <= 0;
			n0lOii <= 0;
			n0lOil <= 0;
			n0lOiO <= 0;
			nlO0i0l <= 0;
			nlO0i0O <= 0;
			nlO0iii <= 0;
			nlO0iil <= 0;
			nlO0iiO <= 0;
			nlO0ili <= 0;
			nlO0ill <= 0;
			nlO0ilO <= 0;
			nlO0iOi <= 0;
			nlO0iOl <= 0;
			nlO0iOO <= 0;
			nlO0l0i <= 0;
			nlO0l0l <= 0;
			nlO0l0O <= 0;
			nlO0l1i <= 0;
			nlO0l1l <= 0;
			nlO0l1O <= 0;
			nlO0lii <= 0;
			nlO0lil <= 0;
			nlO0liO <= 0;
			nlO0lli <= 0;
			nlO0lOl <= 0;
			nlO0O0l <= 0;
			nlO0O1i <= 0;
			nlO0O1O <= 0;
			nlO0Oii <= 0;
			nlO0OiO <= 0;
			nlO0Oll <= 0;
			nlO0OOi <= 0;
			nlO0OOO <= 0;
			nlOi00l <= 0;
			nlOi01i <= 0;
			nlOi01O <= 0;
			nlOi0ii <= 0;
			nlOi0iO <= 0;
			nlOi0lO <= 0;
			nlOi10i <= 0;
			nlOi10O <= 0;
			nlOi11l <= 0;
			nlOi1il <= 0;
			nlOi1li <= 0;
			nlOi1lO <= 0;
			nlOi1Ol <= 0;
			nlOiiii <= 0;
			nlOiiiO <= 0;
			nlOiill <= 0;
			nlOiiOi <= 0;
			nlOiiOO <= 0;
			nlOil0i <= 0;
			nlOil0O <= 0;
			nlOil1l <= 0;
			nlOiliO <= 0;
			nlOilll <= 0;
			nlOilOi <= 0;
			nlOilOO <= 0;
			nlOiO0i <= 0;
			nlOiO0O <= 0;
			nlOiO1l <= 0;
			nlOiOil <= 0;
			nlOiOll <= 0;
			nlOiOOi <= 0;
			nlOiOOO <= 0;
			nlOl00i <= 0;
			nlOl00l <= 0;
			nlOl00O <= 0;
			nlOl01i <= 0;
			nlOl01l <= 0;
			nlOl01O <= 0;
			nlOl0ii <= 0;
			nlOl0il <= 0;
			nlOl0iO <= 0;
			nlOl0li <= 0;
			nlOl0ll <= 0;
			nlOl0lO <= 0;
			nlOl0Oi <= 0;
			nlOl0Ol <= 0;
			nlOl0OO <= 0;
			nlOl10i <= 0;
			nlOl10O <= 0;
			nlOl11l <= 0;
			nlOl1il <= 0;
			nlOl1li <= 0;
			nlOl1lO <= 0;
			nlOl1Oi <= 0;
			nlOl1Ol <= 0;
			nlOl1OO <= 0;
			nlOli0i <= 0;
			nlOli0l <= 0;
			nlOli0O <= 0;
			nlOli1i <= 0;
			nlOli1l <= 0;
			nlOli1O <= 0;
			nlOliii <= 0;
			nlOliil <= 0;
			nlOliiO <= 0;
			nlOlili <= 0;
			nlOlill <= 0;
			nlOlilO <= 0;
			nlOliOi <= 0;
			nlOliOl <= 0;
			nlOliOO <= 0;
			nlOll0i <= 0;
			nlOll0l <= 0;
			nlOll0O <= 0;
			nlOll1i <= 0;
			nlOll1l <= 0;
			nlOll1O <= 0;
			nlOllii <= 0;
			nlOllil <= 0;
			nlOlliO <= 0;
			nlOllli <= 0;
			nlOllll <= 0;
			nlOlllO <= 0;
			nlOllOi <= 0;
			nlOllOl <= 0;
			nlOllOO <= 0;
			nlOlO0i <= 0;
			nlOlO0l <= 0;
			nlOlO0O <= 0;
			nlOlO1i <= 0;
			nlOlO1l <= 0;
			nlOlO1O <= 0;
			nlOlOii <= 0;
			nlOlOil <= 0;
			nlOlOiO <= 0;
			nlOlOli <= 0;
			nlOlOll <= 0;
			nlOlOlO <= 0;
			nlOlOOi <= 0;
			nlOlOOl <= 0;
			nlOlOOO <= 0;
			nlOO00i <= 0;
			nlOO00l <= 0;
			nlOO00O <= 0;
			nlOO01i <= 0;
			nlOO01l <= 0;
			nlOO01O <= 0;
			nlOO0ii <= 0;
			nlOO0il <= 0;
			nlOO0iO <= 0;
			nlOO0li <= 0;
			nlOO0ll <= 0;
			nlOO0lO <= 0;
			nlOO0Oi <= 0;
			nlOO0Ol <= 0;
			nlOO0OO <= 0;
			nlOO10i <= 0;
			nlOO10l <= 0;
			nlOO10O <= 0;
			nlOO11i <= 0;
			nlOO11l <= 0;
			nlOO11O <= 0;
			nlOO1ii <= 0;
			nlOO1il <= 0;
			nlOO1iO <= 0;
			nlOO1li <= 0;
			nlOO1ll <= 0;
			nlOO1lO <= 0;
			nlOO1Oi <= 0;
			nlOO1Ol <= 0;
			nlOO1OO <= 0;
			nlOOi0i <= 0;
			nlOOi0l <= 0;
			nlOOi0O <= 0;
			nlOOi1i <= 0;
			nlOOi1l <= 0;
			nlOOi1O <= 0;
			nlOOiii <= 0;
			nlOOiil <= 0;
			nlOOiiO <= 0;
			nlOOili <= 0;
			nlOOill <= 0;
			nlOOilO <= 0;
			nlOOiOi <= 0;
			nlOOiOl <= 0;
			nlOOiOO <= 0;
			nlOOl0i <= 0;
			nlOOl0l <= 0;
			nlOOl0O <= 0;
			nlOOl1i <= 0;
			nlOOl1l <= 0;
			nlOOl1O <= 0;
			nlOOlii <= 0;
			nlOOlil <= 0;
			nlOOliO <= 0;
			nlOOlli <= 0;
			nlOOlll <= 0;
		end
		else 
		begin
			n01ii <= (n0lO0l & n0lO0i);
			n01iO <= (~ nlO10ii);
			n0lO0i <= nlO0i0l;
			n0lO0l <= nlO0i0O;
			n0lO0O <= nlO0iii;
			n0lO1O <= wire_nlO0OlO_dataout;
			n0lOii <= nlO0iil;
			n0lOil <= nlO0iiO;
			n0lOiO <= nlO0ili;
			nlO0i0l <= datavalid;
			nlO0i0O <= endofpacket;
			nlO0iii <= empty[2];
			nlO0iil <= empty[1];
			nlO0iiO <= empty[0];
			nlO0ili <= startofpacket;
			nlO0ill <= data[63];
			nlO0ilO <= data[62];
			nlO0iOi <= data[61];
			nlO0iOl <= data[60];
			nlO0iOO <= data[59];
			nlO0l0i <= data[55];
			nlO0l0l <= data[54];
			nlO0l0O <= data[53];
			nlO0l1i <= data[58];
			nlO0l1l <= data[57];
			nlO0l1O <= data[56];
			nlO0lii <= data[52];
			nlO0lil <= data[51];
			nlO0liO <= data[50];
			nlO0lli <= data[49];
			nlO0lOl <= data[0];
			nlO0O0l <= data[3];
			nlO0O1i <= data[1];
			nlO0O1O <= data[2];
			nlO0Oii <= data[4];
			nlO0OiO <= data[5];
			nlO0Oll <= data[6];
			nlO0OOi <= data[7];
			nlO0OOO <= data[8];
			nlOi00l <= data[18];
			nlOi01i <= data[16];
			nlOi01O <= data[17];
			nlOi0ii <= data[19];
			nlOi0iO <= data[20];
			nlOi0lO <= data[21];
			nlOi10i <= data[10];
			nlOi10O <= data[11];
			nlOi11l <= data[9];
			nlOi1il <= data[12];
			nlOi1li <= data[13];
			nlOi1lO <= data[14];
			nlOi1Ol <= data[15];
			nlOiiii <= data[22];
			nlOiiiO <= data[23];
			nlOiill <= data[24];
			nlOiiOi <= data[25];
			nlOiiOO <= data[26];
			nlOil0i <= data[28];
			nlOil0O <= data[29];
			nlOil1l <= data[27];
			nlOiliO <= data[30];
			nlOilll <= data[31];
			nlOilOi <= data[32];
			nlOilOO <= data[33];
			nlOiO0i <= data[35];
			nlOiO0O <= data[36];
			nlOiO1l <= data[34];
			nlOiOil <= data[37];
			nlOiOll <= data[38];
			nlOiOOi <= data[39];
			nlOiOOO <= data[40];
			nlOl00i <= (wire_nlOiOii_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOi0Oi_dataout ^ (wire_nlOi1iO_dataout ^ (wire_nlOi11O_dataout ^ wire_nlO0lll_dataout)))));
			nlOl00l <= (nlO0iOO ^ (nlO0ill ^ (wire_nlOilil_dataout ^ (wire_nlOil0l_dataout ^ (wire_nlOiiOl_dataout ^ wire_nlOi1ii_dataout)))));
			nlOl00O <= (nlO0iOl ^ (wire_nlOl1iO_dataout ^ (wire_nlOiOii_dataout ^ (wire_nlOi0OO_dataout ^ (wire_nlOi00i_dataout ^ wire_nlO0lll_dataout)))));
			nlOl01i <= (wire_nlOl11i_dataout ^ (wire_nlOi10l_dataout ^ (wire_nlO0OOl_dataout ^ (wire_nlO0Oil_dataout ^ nllOO0l))));
			nlOl01l <= (wire_nlOiOii_dataout ^ (wire_nlOiO1i_dataout ^ (wire_nlOii0i_dataout ^ (wire_nlOi10l_dataout ^ nllOO0l))));
			nlOl01O <= (nlO0l1l ^ (wire_nlOl10l_dataout ^ (wire_nlOl11i_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOii1O_dataout ^ wire_nlOii1i_dataout)))));
			nlOl0ii <= (nlO0iOO ^ (wire_nlOl1iO_dataout ^ (wire_nlOl11O_dataout ^ (wire_nlOiili_dataout ^ (wire_nlOi11O_dataout ^ wire_nlO0OlO_dataout)))));
			nlOl0il <= (nlO0iOi ^ (wire_nlOiOli_dataout ^ (wire_nlOiO0l_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOii1l_dataout ^ wire_nlOi1ii_dataout)))));
			nlOl0iO <= (nlO0iOl ^ (wire_nlOl11i_dataout ^ (wire_nlOi0li_dataout ^ (wire_nlOi11i_dataout ^ nllOOil))));
			nlOl0li <= (nlO0iOO ^ (wire_nlOiOlO_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlOii1i_dataout ^ nllOOiO))));
			nlOl0ll <= (nlO0iOO ^ (nlO0iOi ^ (wire_nlOiOOl_dataout ^ (wire_nlOiili_dataout ^ (wire_nlOii1O_dataout ^ wire_nlOi0Ol_dataout)))));
			nlOl0lO <= (nlO0l1i ^ (nlO0ill ^ (wire_nlOl10l_dataout ^ (wire_nlOiOOl_dataout ^ (wire_nlOillO_dataout ^ wire_nlO0O0i_dataout)))));
			nlOl0Oi <= (wire_nlOl1ii_dataout ^ (wire_nlOl11i_dataout ^ (wire_nlOiOOl_dataout ^ (wire_nlOiOii_dataout ^ (wire_nlOi0Ol_dataout ^ wire_nlO0Oil_dataout)))));
			nlOl0Ol <= (wire_nlOl10l_dataout ^ (wire_nlOiOii_dataout ^ (wire_nlOii0l_dataout ^ (wire_nlOii1l_dataout ^ (wire_nlOi0OO_dataout ^ wire_nlO0OlO_dataout)))));
			nlOl0OO <= (wire_nlOilli_dataout ^ (wire_nlOiiOl_dataout ^ (wire_nlOii1l_dataout ^ (wire_nlOi0OO_dataout ^ (wire_nlOi1ll_dataout ^ wire_nlO0O1l_dataout)))));
			nlOl10i <= data[42];
			nlOl10O <= data[43];
			nlOl11l <= data[41];
			nlOl1il <= data[44];
			nlOl1li <= data[45];
			nlOl1lO <= data[46];
			nlOl1Oi <= data[47];
			nlOl1Ol <= data[48];
			nlOl1OO <= (nlO0l1l ^ (wire_nlOilil_dataout ^ (wire_nlOi00O_dataout ^ (wire_nlO0Oli_dataout ^ (wire_nlO0O0O_dataout ^ wire_nlO0O0i_dataout)))));
			nlOli0i <= (wire_nlOiO0l_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOi0Oi_dataout ^ (wire_nlOi00O_dataout ^ (wire_nlO0O0i_dataout ^ wire_nlO0lll_dataout)))));
			nlOli0l <= (wire_nlOl10l_dataout ^ (wire_nlOl11O_dataout ^ (wire_nlOilOl_dataout ^ (wire_nlOillO_dataout ^ (wire_nlOii0O_dataout ^ wire_nlOi0il_dataout)))));
			nlOli0O <= (wire_nlOl11O_dataout ^ (wire_nlOii0l_dataout ^ (wire_nlOi1OO_dataout ^ (wire_nlOi1Oi_dataout ^ (wire_nlO0OOl_dataout ^ wire_nlO0OlO_dataout)))));
			nlOli1i <= (wire_nlOiOOl_dataout ^ (wire_nlOii1i_dataout ^ (wire_nlOi1Oi_dataout ^ (wire_nlOi1ll_dataout ^ (wire_nlOi1iO_dataout ^ wire_nlO0llO_dataout)))));
			nlOli1l <= (nlO0ilO ^ (wire_nlOiO1i_dataout ^ (wire_nlOil1O_dataout ^ (wire_nlOiiil_dataout ^ nllOO0i))));
			nlOli1O <= (nlO0l1O ^ (nlO0iOl ^ (wire_nlOiOlO_dataout ^ (wire_nlOiO0l_dataout ^ (wire_nlOii1i_dataout ^ wire_nlOi11O_dataout)))));
			nlOliii <= (wire_nlOil0l_dataout ^ (wire_nlOil1O_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlOi0Oi_dataout ^ (wire_nlOi1OO_dataout ^ wire_nlOi10l_dataout)))));
			nlOliil <= (nlO0l1O ^ (wire_nlOl1iO_dataout ^ (wire_nlOl11O_dataout ^ (wire_nlOii1l_dataout ^ (wire_nlOi0OO_dataout ^ wire_nlO0O0O_dataout)))));
			nlOliiO <= (nlO0l1i ^ (wire_nlOl11i_dataout ^ (wire_nlOiilO_dataout ^ (wire_nlOii0i_dataout ^ (wire_nlO0OOl_dataout ^ wire_nlO0Oil_dataout)))));
			nlOlili <= (wire_nlOiOli_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOi0Oi_dataout ^ (wire_nlOi0li_dataout ^ (wire_nlOi01l_dataout ^ wire_nlO0O0O_dataout)))));
			nlOlill <= (wire_nlOiiil_dataout ^ (wire_nlOi1ll_dataout ^ (wire_nlOi1iO_dataout ^ (wire_nlO0Oli_dataout ^ (wire_nlO0Oil_dataout ^ wire_nlO0lOO_dataout)))));
			nlOlilO <= (wire_nlOl11i_dataout ^ (wire_nlOiOlO_dataout ^ (wire_nlOiO0l_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlOi1Oi_dataout ^ wire_nlOi10l_dataout)))));
			nlOliOi <= (nlO0ilO ^ (wire_nlOilOl_dataout ^ (wire_nlOiiOl_dataout ^ (wire_nlOi0Ol_dataout ^ (wire_nlOi1ii_dataout ^ wire_nlO0O0i_dataout)))));
			nlOliOl <= (nlO0iOi ^ (wire_nlOiOli_dataout ^ (wire_nlOii0O_dataout ^ (wire_nlOi00i_dataout ^ (wire_nlOi01l_dataout ^ wire_nlO0Oli_dataout)))));
			nlOliOO <= (wire_nlOiO1O_dataout ^ (wire_nlOillO_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOii0l_dataout ^ (wire_nlOii1i_dataout ^ wire_nlOi10l_dataout)))));
			nlOll0i <= (nlO0iOO ^ (wire_nlOiO1O_dataout ^ (wire_nlOil1O_dataout ^ (wire_nlOiiil_dataout ^ (wire_nlO0Oli_dataout ^ wire_nlO0llO_dataout)))));
			nlOll0l <= (wire_nlOl1iO_dataout ^ (wire_nlOiOii_dataout ^ (wire_nlOii0O_dataout ^ (wire_nlOi0il_dataout ^ (wire_nlOi00i_dataout ^ wire_nlO0Oil_dataout)))));
			nlOll0O <= (wire_nlOl1ii_dataout ^ (wire_nlOl11O_dataout ^ (wire_nlOiOOl_dataout ^ (wire_nlOil1O_dataout ^ (wire_nlO0Oli_dataout ^ wire_nlO0lll_dataout)))));
			nlOll1i <= (wire_nlOii0l_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlOi01l_dataout ^ (wire_nlO0O0O_dataout ^ (wire_nlO0lOO_dataout ^ wire_nlO0lll_dataout)))));
			nlOll1l <= (nlO0ilO ^ (wire_nlOl1iO_dataout ^ (wire_nlOl1ii_dataout ^ (wire_nlOiOOl_dataout ^ (wire_nlOii1l_dataout ^ wire_nlO0lOi_dataout)))));
			nlOll1O <= (nlO0l1i ^ (wire_nlOiO1i_dataout ^ (wire_nlOilOl_dataout ^ (wire_nlOii0O_dataout ^ nllOOlO))));
			nlOllii <= (nlO0l1l ^ (nlO0iOi ^ (wire_nlOil1O_dataout ^ (wire_nlOiilO_dataout ^ nllOOlO))));
			nlOllil <= (nlO0iOi ^ (wire_nlOiOli_dataout ^ (wire_nlOiO1O_dataout ^ (wire_nlOilOl_dataout ^ (wire_nlOi1ll_dataout ^ wire_nlO0O0O_dataout)))));
			nlOlliO <= (nlO0iOl ^ (nlO0ill ^ (wire_nlOi0OO_dataout ^ (wire_nlOi0Oi_dataout ^ (wire_nlO0O0i_dataout ^ wire_nlO0O1l_dataout)))));
			nlOllli <= (nlO0ill ^ (wire_nlOl11O_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOiiil_dataout ^ nllOOli))));
			nlOllll <= (wire_nlOl10l_dataout ^ (wire_nlOiO0l_dataout ^ (wire_nlOi0li_dataout ^ (wire_nlO0Oli_dataout ^ (wire_nlO0O1l_dataout ^ wire_nlO0llO_dataout)))));
			nlOlllO <= (nlO0iOl ^ (wire_nlOl1ii_dataout ^ (wire_nlOl10l_dataout ^ (wire_nlOi1iO_dataout ^ (wire_nlO0Oil_dataout ^ wire_nlO0lOi_dataout)))));
			nlOllOi <= (nlO0l1i ^ (nlO0ill ^ (wire_nlOl11i_dataout ^ (wire_nlOi0Ol_dataout ^ (wire_nlOi0il_dataout ^ wire_nlO0O1l_dataout)))));
			nlOllOl <= (nlO0ill ^ (wire_nlOl11i_dataout ^ (wire_nlOiiil_dataout ^ (wire_nlOii1l_dataout ^ (wire_nlOi0Oi_dataout ^ wire_nlO0OlO_dataout)))));
			nlOllOO <= (nlO0l1i ^ (nlO0iOl ^ (wire_nlOilil_dataout ^ (wire_nlOiilO_dataout ^ (wire_nlOi10l_dataout ^ wire_nlO0lOi_dataout)))));
			nlOlO0i <= (nlO0l1i ^ (wire_nlOiOOl_dataout ^ (wire_nlOiOli_dataout ^ (wire_nlOil0l_dataout ^ (wire_nlOii0i_dataout ^ wire_nlOi00O_dataout)))));
			nlOlO0l <= (nlO0l1O ^ (wire_nlOl1iO_dataout ^ (wire_nlOl10l_dataout ^ (wire_nlOiO0l_dataout ^ (wire_nlOilOl_dataout ^ wire_nlOilil_dataout)))));
			nlOlO0O <= (nlO0ilO ^ (wire_nlOilOl_dataout ^ (wire_nlOil0l_dataout ^ (wire_nlOii1l_dataout ^ (wire_nlOi0il_dataout ^ wire_nlO0lOi_dataout)))));
			nlOlO1i <= (nlO0l1i ^ (nlO0ilO ^ (wire_nlOiO1i_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlOii1i_dataout ^ wire_nlOi1ll_dataout)))));
			nlOlO1l <= (wire_nlOl1iO_dataout ^ (wire_nlOilOl_dataout ^ (wire_nlOiiil_dataout ^ (wire_nlOii0i_dataout ^ (wire_nlOi00i_dataout ^ wire_nlO0O1l_dataout)))));
			nlOlO1O <= (nlO0iOO ^ (nlO0iOi ^ (wire_nlOii0O_dataout ^ (wire_nlOi0Ol_dataout ^ (wire_nlOi01l_dataout ^ wire_nlO0lOO_dataout)))));
			nlOlOii <= (wire_nlOl1iO_dataout ^ (wire_nlOl1ii_dataout ^ (wire_nlOii0O_dataout ^ (wire_nlOii0l_dataout ^ (wire_nlOii0i_dataout ^ wire_nlO0OOl_dataout)))));
			nlOlOil <= (nlO0iOl ^ (wire_nlOl10l_dataout ^ (wire_nlOiOlO_dataout ^ (wire_nlOii1i_dataout ^ (wire_nlOi00i_dataout ^ wire_nlOi01l_dataout)))));
			nlOlOiO <= (nlO0l1l ^ (nlO0ill ^ (wire_nlOl11i_dataout ^ (wire_nlOil0l_dataout ^ (wire_nlOiiil_dataout ^ wire_nlOii1l_dataout)))));
			nlOlOli <= (wire_nlOl11O_dataout ^ (wire_nlOi0li_dataout ^ (wire_nlOi0il_dataout ^ (wire_nlOi1ll_dataout ^ nllOOll))));
			nlOlOll <= (wire_nlOl11i_dataout ^ (wire_nlOil0l_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOiiOl_dataout ^ (wire_nlOiilO_dataout ^ wire_nlOi1Oi_dataout)))));
			nlOlOlO <= (nlO0l1l ^ (nlO0iOl ^ (nlO0ill ^ (wire_nlOl1ii_dataout ^ (wire_nlOii0i_dataout ^ wire_nlO0OlO_dataout)))));
			nlOlOOi <= (nlO0iOl ^ (nlO0ill ^ (wire_nlOiOlO_dataout ^ (wire_nlOilOl_dataout ^ (wire_nlOii1O_dataout ^ wire_nlOi1ii_dataout)))));
			nlOlOOl <= (nlO0iOi ^ (wire_nlOiilO_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlOi1Oi_dataout ^ nllOO0O))));
			nlOlOOO <= (nlO0l1l ^ (nlO0ilO ^ (wire_nlOiO1i_dataout ^ (wire_nlOi00O_dataout ^ nllOOll))));
			nlOO00i <= (wire_nlOl11O_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOiili_dataout ^ (wire_nlOii0l_dataout ^ nllOOii))));
			nlOO00l <= (wire_nlOillO_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOilil_dataout ^ (wire_nlOil0l_dataout ^ (wire_nlOii0l_dataout ^ wire_nlOi1ll_dataout)))));
			nlOO00O <= (wire_nlOilOl_dataout ^ (wire_nlOiiOl_dataout ^ (wire_nlOii0O_dataout ^ (wire_nlOi0OO_dataout ^ (wire_nlO0Oli_dataout ^ wire_nlO0O0O_dataout)))));
			nlOO01i <= (nlO0l1O ^ (nlO0iOl ^ (wire_nlOiOOl_dataout ^ (wire_nlOilil_dataout ^ (wire_nlOii1O_dataout ^ wire_nlOi11i_dataout)))));
			nlOO01l <= (wire_nlOl11i_dataout ^ (wire_nlOiOii_dataout ^ (wire_nlOi0il_dataout ^ (wire_nlO0Oil_dataout ^ nllOOii))));
			nlOO01O <= (nlO0iOl ^ (wire_nlOiiOl_dataout ^ (wire_nlOiilO_dataout ^ (wire_nlOiiil_dataout ^ (wire_nlOi00O_dataout ^ wire_nlOi1iO_dataout)))));
			nlOO0ii <= (wire_nlOiO1O_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlOii1i_dataout ^ nllOO0O))));
			nlOO0il <= (nlO0iOi ^ (wire_nlOii0O_dataout ^ (wire_nlOi1OO_dataout ^ (wire_nlOi1ll_dataout ^ (wire_nlOi1ii_dataout ^ wire_nlO0Oil_dataout)))));
			nlOO0iO <= (nlO0ilO ^ (wire_nlOiOOl_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOiili_dataout ^ (wire_nlOii1l_dataout ^ wire_nlO0lll_dataout)))));
			nlOO0li <= (wire_nlOiO0l_dataout ^ (wire_nlOiO1i_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOi0OO_dataout ^ (wire_nlOi0li_dataout ^ wire_nlOi1iO_dataout)))));
			nlOO0ll <= (wire_nlOii0l_dataout ^ wire_nlOi11O_dataout);
			nlOO0lO <= (wire_nlOl10l_dataout ^ (wire_nlOil1i_dataout ^ wire_nlOiili_dataout));
			nlOO0Oi <= (wire_nlOi0Oi_dataout ^ nlO0iOl);
			nlOO0Ol <= (wire_nlOil1i_dataout ^ wire_nlOii1i_dataout);
			nlOO0OO <= (wire_nlOiO0l_dataout ^ (wire_nlOii0O_dataout ^ (wire_nlO0O0O_dataout ^ wire_nlO0lOi_dataout)));
			nlOO10i <= (nlO0iOO ^ (wire_nlOiOOl_dataout ^ (wire_nlOii0i_dataout ^ (wire_nlOi1Oi_dataout ^ (wire_nlOi1ll_dataout ^ wire_nlO0Oil_dataout)))));
			nlOO10l <= (wire_nlOiOli_dataout ^ (wire_nlOiOii_dataout ^ (wire_nlOii0O_dataout ^ (wire_nlOii0l_dataout ^ (wire_nlOi1OO_dataout ^ wire_nlOi1ii_dataout)))));
			nlOO10O <= (nlO0iOi ^ (wire_nlOl1ii_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOilil_dataout ^ (wire_nlOiiil_dataout ^ wire_nlO0O0i_dataout)))));
			nlOO11i <= (nlO0iOO ^ (wire_nlOl1ii_dataout ^ (wire_nlOl11O_dataout ^ (wire_nlOillO_dataout ^ (wire_nlOil1O_dataout ^ wire_nlO0lOO_dataout)))));
			nlOO11l <= (nlO0ilO ^ (wire_nlOiOOl_dataout ^ (wire_nlOiO1O_dataout ^ (wire_nlOii0i_dataout ^ (wire_nlOi0OO_dataout ^ wire_nlOi00O_dataout)))));
			nlOO11O <= (wire_nlOiOii_dataout ^ (wire_nlOiO1O_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOii0O_dataout ^ nllOOli))));
			nlOO1ii <= (wire_nlOl11i_dataout ^ (wire_nlOiOii_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlO0lOi_dataout ^ wire_nlO0lll_dataout)))));
			nlOO1il <= (nlO0l1O ^ (nlO0iOi ^ (wire_nlOil1i_dataout ^ (wire_nlOii0O_dataout ^ nllOOiO))));
			nlOO1iO <= (wire_nlOiO1O_dataout ^ (wire_nlOil0l_dataout ^ (wire_nlOii0i_dataout ^ (wire_nlOi0Ol_dataout ^ nllOOil))));
			nlOO1li <= (nlO0l1O ^ (wire_nlOiO1i_dataout ^ (wire_nlOii0l_dataout ^ (wire_nlO0O1l_dataout ^ (wire_nlO0lOO_dataout ^ wire_nlO0lOi_dataout)))));
			nlOO1ll <= (wire_nlOl1ii_dataout ^ (wire_nlOillO_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOii0O_dataout ^ (wire_nlOi1ll_dataout ^ wire_nlO0OlO_dataout)))));
			nlOO1lO <= (wire_nlOl1iO_dataout ^ (wire_nlOilOl_dataout ^ (wire_nlOiilO_dataout ^ (wire_nlOii0l_dataout ^ (wire_nlOi1Oi_dataout ^ wire_nlO0OOl_dataout)))));
			nlOO1Oi <= (nlO0l1O ^ (nlO0l1l ^ (wire_nlOil0l_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOi00O_dataout ^ wire_nlO0Oil_dataout)))));
			nlOO1Ol <= (nlO0l1i ^ (nlO0ilO ^ (wire_nlOi0Ol_dataout ^ (wire_nlOi00i_dataout ^ (wire_nlOi11O_dataout ^ wire_nlO0O0i_dataout)))));
			nlOO1OO <= (nlO0ill ^ (wire_nlOl11O_dataout ^ (wire_nlOii1i_dataout ^ (wire_nlOi1OO_dataout ^ (wire_nlO0OlO_dataout ^ wire_nlO0lOO_dataout)))));
			nlOOi0i <= (wire_nlOl1ii_dataout ^ wire_nlOi11O_dataout);
			nlOOi0l <= (wire_nlOiiOl_dataout ^ (wire_nlOiiil_dataout ^ wire_nlOi1Oi_dataout));
			nlOOi0O <= (nlO0l1l ^ (wire_nlOiOOl_dataout ^ nlO0l1i));
			nlOOi1i <= wire_nlOiO1i_dataout;
			nlOOi1l <= (wire_nlOillO_dataout ^ (wire_nlOiiil_dataout ^ (wire_nlOii1O_dataout ^ (wire_nlOi0il_dataout ^ (wire_nlOi11i_dataout ^ wire_nlO0lOi_dataout)))));
			nlOOi1O <= (wire_nlOl1ii_dataout ^ (wire_nlOl11i_dataout ^ (wire_nlOillO_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOi0li_dataout ^ wire_nlO0OOl_dataout)))));
			nlOOiii <= (nlO0l1O ^ (wire_nlOiOli_dataout ^ (wire_nlOiO1O_dataout ^ (wire_nlOiiil_dataout ^ (wire_nlOi11O_dataout ^ wire_nlO0lOi_dataout)))));
			nlOOiil <= (wire_nlOii1O_dataout ^ wire_nlO0llO_dataout);
			nlOOiiO <= (nlO0l1l ^ (wire_nlOi1ll_dataout ^ wire_nlO0O0i_dataout));
			nlOOili <= (nlO0l1i ^ (wire_nlOiO1i_dataout ^ (wire_nlOiiil_dataout ^ (wire_nlOii1l_dataout ^ wire_nlOi1Oi_dataout))));
			nlOOill <= (nlO0l1l ^ (nlO0iOl ^ (wire_nlOl1ii_dataout ^ (wire_nlOiO1i_dataout ^ (wire_nlOi01l_dataout ^ wire_nlOi1OO_dataout)))));
			nlOOilO <= (wire_nlOi0OO_dataout ^ (wire_nlO0Oli_dataout ^ nllOO0l));
			nlOOiOi <= (nlO0ilO ^ (wire_nlOiOlO_dataout ^ (wire_nlOii1i_dataout ^ wire_nlOi00i_dataout)));
			nlOOiOl <= (nlO0l1i ^ (wire_nlOl1iO_dataout ^ (wire_nlOiOlO_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOiili_dataout ^ wire_nlOi0OO_dataout)))));
			nlOOiOO <= (nlO0iOl ^ (wire_nlOl1iO_dataout ^ (wire_nlOiOii_dataout ^ (wire_nlOilil_dataout ^ (wire_nlOil1O_dataout ^ wire_nlOiilO_dataout)))));
			nlOOl0i <= (nlO0l1l ^ (nlO0ill ^ (wire_nlOi01l_dataout ^ wire_nlO0OlO_dataout)));
			nlOOl0l <= (nlO0l1l ^ (wire_nlOiOli_dataout ^ (wire_nlOi1OO_dataout ^ wire_nlOi1iO_dataout)));
			nlOOl0O <= (nlO0l1l ^ (wire_nlOi0il_dataout ^ (wire_nlOi01l_dataout ^ (wire_nlOi11i_dataout ^ wire_nlO0lOO_dataout))));
			nlOOl1i <= (wire_nlOl11i_dataout ^ (wire_nlOiiil_dataout ^ (wire_nlOi0Ol_dataout ^ (wire_nlOi0li_dataout ^ (wire_nlOi1Oi_dataout ^ wire_nlO0Oli_dataout)))));
			nlOOl1l <= (wire_nlOiOlO_dataout ^ (wire_nlOillO_dataout ^ (wire_nlOiili_dataout ^ (wire_nlOi0il_dataout ^ (wire_nlO0O1l_dataout ^ wire_nlO0lOi_dataout)))));
			nlOOl1O <= nllOO0i;
			nlOOlii <= (wire_nlOiOlO_dataout ^ (wire_nlOil1O_dataout ^ wire_nlO0OOl_dataout));
			nlOOlil <= (nlO0l1O ^ (wire_nlOiO1O_dataout ^ (wire_nlOil1i_dataout ^ (wire_nlOi0OO_dataout ^ wire_nlOi0Ol_dataout))));
			nlOOliO <= (wire_nlOiO1i_dataout ^ (wire_nlOilli_dataout ^ (wire_nlOi0OO_dataout ^ wire_nlOi0Oi_dataout)));
			nlOOlli <= wire_nlOi0li_dataout;
			nlOOlll <= (wire_nlOi0li_dataout ^ nlO0l1O);
		end
	end
	assign
		wire_n01il_CLRN = (nlO100O46 ^ nlO100O45);
	event n01ii_event;
	event n01iO_event;
	event n0lO0i_event;
	event n0lO0l_event;
	event n0lO0O_event;
	event n0lO1O_event;
	event n0lOii_event;
	event n0lOil_event;
	event n0lOiO_event;
	event nlO0i0l_event;
	event nlO0i0O_event;
	event nlO0iii_event;
	event nlO0iil_event;
	event nlO0iiO_event;
	event nlO0ili_event;
	event nlO0ill_event;
	event nlO0ilO_event;
	event nlO0iOi_event;
	event nlO0iOl_event;
	event nlO0iOO_event;
	event nlO0l0i_event;
	event nlO0l0l_event;
	event nlO0l0O_event;
	event nlO0l1i_event;
	event nlO0l1l_event;
	event nlO0l1O_event;
	event nlO0lii_event;
	event nlO0lil_event;
	event nlO0liO_event;
	event nlO0lli_event;
	event nlO0lOl_event;
	event nlO0O0l_event;
	event nlO0O1i_event;
	event nlO0O1O_event;
	event nlO0Oii_event;
	event nlO0OiO_event;
	event nlO0Oll_event;
	event nlO0OOi_event;
	event nlO0OOO_event;
	event nlOi00l_event;
	event nlOi01i_event;
	event nlOi01O_event;
	event nlOi0ii_event;
	event nlOi0iO_event;
	event nlOi0lO_event;
	event nlOi10i_event;
	event nlOi10O_event;
	event nlOi11l_event;
	event nlOi1il_event;
	event nlOi1li_event;
	event nlOi1lO_event;
	event nlOi1Ol_event;
	event nlOiiii_event;
	event nlOiiiO_event;
	event nlOiill_event;
	event nlOiiOi_event;
	event nlOiiOO_event;
	event nlOil0i_event;
	event nlOil0O_event;
	event nlOil1l_event;
	event nlOiliO_event;
	event nlOilll_event;
	event nlOilOi_event;
	event nlOilOO_event;
	event nlOiO0i_event;
	event nlOiO0O_event;
	event nlOiO1l_event;
	event nlOiOil_event;
	event nlOiOll_event;
	event nlOiOOi_event;
	event nlOiOOO_event;
	event nlOl00i_event;
	event nlOl00l_event;
	event nlOl00O_event;
	event nlOl01i_event;
	event nlOl01l_event;
	event nlOl01O_event;
	event nlOl0ii_event;
	event nlOl0il_event;
	event nlOl0iO_event;
	event nlOl0li_event;
	event nlOl0ll_event;
	event nlOl0lO_event;
	event nlOl0Oi_event;
	event nlOl0Ol_event;
	event nlOl0OO_event;
	event nlOl10i_event;
	event nlOl10O_event;
	event nlOl11l_event;
	event nlOl1il_event;
	event nlOl1li_event;
	event nlOl1lO_event;
	event nlOl1Oi_event;
	event nlOl1Ol_event;
	event nlOl1OO_event;
	event nlOli0i_event;
	event nlOli0l_event;
	event nlOli0O_event;
	event nlOli1i_event;
	event nlOli1l_event;
	event nlOli1O_event;
	event nlOliii_event;
	event nlOliil_event;
	event nlOliiO_event;
	event nlOlili_event;
	event nlOlill_event;
	event nlOlilO_event;
	event nlOliOi_event;
	event nlOliOl_event;
	event nlOliOO_event;
	event nlOll0i_event;
	event nlOll0l_event;
	event nlOll0O_event;
	event nlOll1i_event;
	event nlOll1l_event;
	event nlOll1O_event;
	event nlOllii_event;
	event nlOllil_event;
	event nlOlliO_event;
	event nlOllli_event;
	event nlOllll_event;
	event nlOlllO_event;
	event nlOllOi_event;
	event nlOllOl_event;
	event nlOllOO_event;
	event nlOlO0i_event;
	event nlOlO0l_event;
	event nlOlO0O_event;
	event nlOlO1i_event;
	event nlOlO1l_event;
	event nlOlO1O_event;
	event nlOlOii_event;
	event nlOlOil_event;
	event nlOlOiO_event;
	event nlOlOli_event;
	event nlOlOll_event;
	event nlOlOlO_event;
	event nlOlOOi_event;
	event nlOlOOl_event;
	event nlOlOOO_event;
	event nlOO00i_event;
	event nlOO00l_event;
	event nlOO00O_event;
	event nlOO01i_event;
	event nlOO01l_event;
	event nlOO01O_event;
	event nlOO0ii_event;
	event nlOO0il_event;
	event nlOO0iO_event;
	event nlOO0li_event;
	event nlOO0ll_event;
	event nlOO0lO_event;
	event nlOO0Oi_event;
	event nlOO0Ol_event;
	event nlOO0OO_event;
	event nlOO10i_event;
	event nlOO10l_event;
	event nlOO10O_event;
	event nlOO11i_event;
	event nlOO11l_event;
	event nlOO11O_event;
	event nlOO1ii_event;
	event nlOO1il_event;
	event nlOO1iO_event;
	event nlOO1li_event;
	event nlOO1ll_event;
	event nlOO1lO_event;
	event nlOO1Oi_event;
	event nlOO1Ol_event;
	event nlOO1OO_event;
	event nlOOi0i_event;
	event nlOOi0l_event;
	event nlOOi0O_event;
	event nlOOi1i_event;
	event nlOOi1l_event;
	event nlOOi1O_event;
	event nlOOiii_event;
	event nlOOiil_event;
	event nlOOiiO_event;
	event nlOOili_event;
	event nlOOill_event;
	event nlOOilO_event;
	event nlOOiOi_event;
	event nlOOiOl_event;
	event nlOOiOO_event;
	event nlOOl0i_event;
	event nlOOl0l_event;
	event nlOOl0O_event;
	event nlOOl1i_event;
	event nlOOl1l_event;
	event nlOOl1O_event;
	event nlOOlii_event;
	event nlOOlil_event;
	event nlOOliO_event;
	event nlOOlli_event;
	event nlOOlll_event;
	initial
		#1 ->n01ii_event;
	initial
		#1 ->n01iO_event;
	initial
		#1 ->n0lO0i_event;
	initial
		#1 ->n0lO0l_event;
	initial
		#1 ->n0lO0O_event;
	initial
		#1 ->n0lO1O_event;
	initial
		#1 ->n0lOii_event;
	initial
		#1 ->n0lOil_event;
	initial
		#1 ->n0lOiO_event;
	initial
		#1 ->nlO0i0l_event;
	initial
		#1 ->nlO0i0O_event;
	initial
		#1 ->nlO0iii_event;
	initial
		#1 ->nlO0iil_event;
	initial
		#1 ->nlO0iiO_event;
	initial
		#1 ->nlO0ili_event;
	initial
		#1 ->nlO0ill_event;
	initial
		#1 ->nlO0ilO_event;
	initial
		#1 ->nlO0iOi_event;
	initial
		#1 ->nlO0iOl_event;
	initial
		#1 ->nlO0iOO_event;
	initial
		#1 ->nlO0l0i_event;
	initial
		#1 ->nlO0l0l_event;
	initial
		#1 ->nlO0l0O_event;
	initial
		#1 ->nlO0l1i_event;
	initial
		#1 ->nlO0l1l_event;
	initial
		#1 ->nlO0l1O_event;
	initial
		#1 ->nlO0lii_event;
	initial
		#1 ->nlO0lil_event;
	initial
		#1 ->nlO0liO_event;
	initial
		#1 ->nlO0lli_event;
	initial
		#1 ->nlO0lOl_event;
	initial
		#1 ->nlO0O0l_event;
	initial
		#1 ->nlO0O1i_event;
	initial
		#1 ->nlO0O1O_event;
	initial
		#1 ->nlO0Oii_event;
	initial
		#1 ->nlO0OiO_event;
	initial
		#1 ->nlO0Oll_event;
	initial
		#1 ->nlO0OOi_event;
	initial
		#1 ->nlO0OOO_event;
	initial
		#1 ->nlOi00l_event;
	initial
		#1 ->nlOi01i_event;
	initial
		#1 ->nlOi01O_event;
	initial
		#1 ->nlOi0ii_event;
	initial
		#1 ->nlOi0iO_event;
	initial
		#1 ->nlOi0lO_event;
	initial
		#1 ->nlOi10i_event;
	initial
		#1 ->nlOi10O_event;
	initial
		#1 ->nlOi11l_event;
	initial
		#1 ->nlOi1il_event;
	initial
		#1 ->nlOi1li_event;
	initial
		#1 ->nlOi1lO_event;
	initial
		#1 ->nlOi1Ol_event;
	initial
		#1 ->nlOiiii_event;
	initial
		#1 ->nlOiiiO_event;
	initial
		#1 ->nlOiill_event;
	initial
		#1 ->nlOiiOi_event;
	initial
		#1 ->nlOiiOO_event;
	initial
		#1 ->nlOil0i_event;
	initial
		#1 ->nlOil0O_event;
	initial
		#1 ->nlOil1l_event;
	initial
		#1 ->nlOiliO_event;
	initial
		#1 ->nlOilll_event;
	initial
		#1 ->nlOilOi_event;
	initial
		#1 ->nlOilOO_event;
	initial
		#1 ->nlOiO0i_event;
	initial
		#1 ->nlOiO0O_event;
	initial
		#1 ->nlOiO1l_event;
	initial
		#1 ->nlOiOil_event;
	initial
		#1 ->nlOiOll_event;
	initial
		#1 ->nlOiOOi_event;
	initial
		#1 ->nlOiOOO_event;
	initial
		#1 ->nlOl00i_event;
	initial
		#1 ->nlOl00l_event;
	initial
		#1 ->nlOl00O_event;
	initial
		#1 ->nlOl01i_event;
	initial
		#1 ->nlOl01l_event;
	initial
		#1 ->nlOl01O_event;
	initial
		#1 ->nlOl0ii_event;
	initial
		#1 ->nlOl0il_event;
	initial
		#1 ->nlOl0iO_event;
	initial
		#1 ->nlOl0li_event;
	initial
		#1 ->nlOl0ll_event;
	initial
		#1 ->nlOl0lO_event;
	initial
		#1 ->nlOl0Oi_event;
	initial
		#1 ->nlOl0Ol_event;
	initial
		#1 ->nlOl0OO_event;
	initial
		#1 ->nlOl10i_event;
	initial
		#1 ->nlOl10O_event;
	initial
		#1 ->nlOl11l_event;
	initial
		#1 ->nlOl1il_event;
	initial
		#1 ->nlOl1li_event;
	initial
		#1 ->nlOl1lO_event;
	initial
		#1 ->nlOl1Oi_event;
	initial
		#1 ->nlOl1Ol_event;
	initial
		#1 ->nlOl1OO_event;
	initial
		#1 ->nlOli0i_event;
	initial
		#1 ->nlOli0l_event;
	initial
		#1 ->nlOli0O_event;
	initial
		#1 ->nlOli1i_event;
	initial
		#1 ->nlOli1l_event;
	initial
		#1 ->nlOli1O_event;
	initial
		#1 ->nlOliii_event;
	initial
		#1 ->nlOliil_event;
	initial
		#1 ->nlOliiO_event;
	initial
		#1 ->nlOlili_event;
	initial
		#1 ->nlOlill_event;
	initial
		#1 ->nlOlilO_event;
	initial
		#1 ->nlOliOi_event;
	initial
		#1 ->nlOliOl_event;
	initial
		#1 ->nlOliOO_event;
	initial
		#1 ->nlOll0i_event;
	initial
		#1 ->nlOll0l_event;
	initial
		#1 ->nlOll0O_event;
	initial
		#1 ->nlOll1i_event;
	initial
		#1 ->nlOll1l_event;
	initial
		#1 ->nlOll1O_event;
	initial
		#1 ->nlOllii_event;
	initial
		#1 ->nlOllil_event;
	initial
		#1 ->nlOlliO_event;
	initial
		#1 ->nlOllli_event;
	initial
		#1 ->nlOllll_event;
	initial
		#1 ->nlOlllO_event;
	initial
		#1 ->nlOllOi_event;
	initial
		#1 ->nlOllOl_event;
	initial
		#1 ->nlOllOO_event;
	initial
		#1 ->nlOlO0i_event;
	initial
		#1 ->nlOlO0l_event;
	initial
		#1 ->nlOlO0O_event;
	initial
		#1 ->nlOlO1i_event;
	initial
		#1 ->nlOlO1l_event;
	initial
		#1 ->nlOlO1O_event;
	initial
		#1 ->nlOlOii_event;
	initial
		#1 ->nlOlOil_event;
	initial
		#1 ->nlOlOiO_event;
	initial
		#1 ->nlOlOli_event;
	initial
		#1 ->nlOlOll_event;
	initial
		#1 ->nlOlOlO_event;
	initial
		#1 ->nlOlOOi_event;
	initial
		#1 ->nlOlOOl_event;
	initial
		#1 ->nlOlOOO_event;
	initial
		#1 ->nlOO00i_event;
	initial
		#1 ->nlOO00l_event;
	initial
		#1 ->nlOO00O_event;
	initial
		#1 ->nlOO01i_event;
	initial
		#1 ->nlOO01l_event;
	initial
		#1 ->nlOO01O_event;
	initial
		#1 ->nlOO0ii_event;
	initial
		#1 ->nlOO0il_event;
	initial
		#1 ->nlOO0iO_event;
	initial
		#1 ->nlOO0li_event;
	initial
		#1 ->nlOO0ll_event;
	initial
		#1 ->nlOO0lO_event;
	initial
		#1 ->nlOO0Oi_event;
	initial
		#1 ->nlOO0Ol_event;
	initial
		#1 ->nlOO0OO_event;
	initial
		#1 ->nlOO10i_event;
	initial
		#1 ->nlOO10l_event;
	initial
		#1 ->nlOO10O_event;
	initial
		#1 ->nlOO11i_event;
	initial
		#1 ->nlOO11l_event;
	initial
		#1 ->nlOO11O_event;
	initial
		#1 ->nlOO1ii_event;
	initial
		#1 ->nlOO1il_event;
	initial
		#1 ->nlOO1iO_event;
	initial
		#1 ->nlOO1li_event;
	initial
		#1 ->nlOO1ll_event;
	initial
		#1 ->nlOO1lO_event;
	initial
		#1 ->nlOO1Oi_event;
	initial
		#1 ->nlOO1Ol_event;
	initial
		#1 ->nlOO1OO_event;
	initial
		#1 ->nlOOi0i_event;
	initial
		#1 ->nlOOi0l_event;
	initial
		#1 ->nlOOi0O_event;
	initial
		#1 ->nlOOi1i_event;
	initial
		#1 ->nlOOi1l_event;
	initial
		#1 ->nlOOi1O_event;
	initial
		#1 ->nlOOiii_event;
	initial
		#1 ->nlOOiil_event;
	initial
		#1 ->nlOOiiO_event;
	initial
		#1 ->nlOOili_event;
	initial
		#1 ->nlOOill_event;
	initial
		#1 ->nlOOilO_event;
	initial
		#1 ->nlOOiOi_event;
	initial
		#1 ->nlOOiOl_event;
	initial
		#1 ->nlOOiOO_event;
	initial
		#1 ->nlOOl0i_event;
	initial
		#1 ->nlOOl0l_event;
	initial
		#1 ->nlOOl0O_event;
	initial
		#1 ->nlOOl1i_event;
	initial
		#1 ->nlOOl1l_event;
	initial
		#1 ->nlOOl1O_event;
	initial
		#1 ->nlOOlii_event;
	initial
		#1 ->nlOOlil_event;
	initial
		#1 ->nlOOliO_event;
	initial
		#1 ->nlOOlli_event;
	initial
		#1 ->nlOOlll_event;
	always @(n01ii_event)
		n01ii <= 1;
	always @(n01iO_event)
		n01iO <= 1;
	always @(n0lO0i_event)
		n0lO0i <= 1;
	always @(n0lO0l_event)
		n0lO0l <= 1;
	always @(n0lO0O_event)
		n0lO0O <= 1;
	always @(n0lO1O_event)
		n0lO1O <= 1;
	always @(n0lOii_event)
		n0lOii <= 1;
	always @(n0lOil_event)
		n0lOil <= 1;
	always @(n0lOiO_event)
		n0lOiO <= 1;
	always @(nlO0i0l_event)
		nlO0i0l <= 1;
	always @(nlO0i0O_event)
		nlO0i0O <= 1;
	always @(nlO0iii_event)
		nlO0iii <= 1;
	always @(nlO0iil_event)
		nlO0iil <= 1;
	always @(nlO0iiO_event)
		nlO0iiO <= 1;
	always @(nlO0ili_event)
		nlO0ili <= 1;
	always @(nlO0ill_event)
		nlO0ill <= 1;
	always @(nlO0ilO_event)
		nlO0ilO <= 1;
	always @(nlO0iOi_event)
		nlO0iOi <= 1;
	always @(nlO0iOl_event)
		nlO0iOl <= 1;
	always @(nlO0iOO_event)
		nlO0iOO <= 1;
	always @(nlO0l0i_event)
		nlO0l0i <= 1;
	always @(nlO0l0l_event)
		nlO0l0l <= 1;
	always @(nlO0l0O_event)
		nlO0l0O <= 1;
	always @(nlO0l1i_event)
		nlO0l1i <= 1;
	always @(nlO0l1l_event)
		nlO0l1l <= 1;
	always @(nlO0l1O_event)
		nlO0l1O <= 1;
	always @(nlO0lii_event)
		nlO0lii <= 1;
	always @(nlO0lil_event)
		nlO0lil <= 1;
	always @(nlO0liO_event)
		nlO0liO <= 1;
	always @(nlO0lli_event)
		nlO0lli <= 1;
	always @(nlO0lOl_event)
		nlO0lOl <= 1;
	always @(nlO0O0l_event)
		nlO0O0l <= 1;
	always @(nlO0O1i_event)
		nlO0O1i <= 1;
	always @(nlO0O1O_event)
		nlO0O1O <= 1;
	always @(nlO0Oii_event)
		nlO0Oii <= 1;
	always @(nlO0OiO_event)
		nlO0OiO <= 1;
	always @(nlO0Oll_event)
		nlO0Oll <= 1;
	always @(nlO0OOi_event)
		nlO0OOi <= 1;
	always @(nlO0OOO_event)
		nlO0OOO <= 1;
	always @(nlOi00l_event)
		nlOi00l <= 1;
	always @(nlOi01i_event)
		nlOi01i <= 1;
	always @(nlOi01O_event)
		nlOi01O <= 1;
	always @(nlOi0ii_event)
		nlOi0ii <= 1;
	always @(nlOi0iO_event)
		nlOi0iO <= 1;
	always @(nlOi0lO_event)
		nlOi0lO <= 1;
	always @(nlOi10i_event)
		nlOi10i <= 1;
	always @(nlOi10O_event)
		nlOi10O <= 1;
	always @(nlOi11l_event)
		nlOi11l <= 1;
	always @(nlOi1il_event)
		nlOi1il <= 1;
	always @(nlOi1li_event)
		nlOi1li <= 1;
	always @(nlOi1lO_event)
		nlOi1lO <= 1;
	always @(nlOi1Ol_event)
		nlOi1Ol <= 1;
	always @(nlOiiii_event)
		nlOiiii <= 1;
	always @(nlOiiiO_event)
		nlOiiiO <= 1;
	always @(nlOiill_event)
		nlOiill <= 1;
	always @(nlOiiOi_event)
		nlOiiOi <= 1;
	always @(nlOiiOO_event)
		nlOiiOO <= 1;
	always @(nlOil0i_event)
		nlOil0i <= 1;
	always @(nlOil0O_event)
		nlOil0O <= 1;
	always @(nlOil1l_event)
		nlOil1l <= 1;
	always @(nlOiliO_event)
		nlOiliO <= 1;
	always @(nlOilll_event)
		nlOilll <= 1;
	always @(nlOilOi_event)
		nlOilOi <= 1;
	always @(nlOilOO_event)
		nlOilOO <= 1;
	always @(nlOiO0i_event)
		nlOiO0i <= 1;
	always @(nlOiO0O_event)
		nlOiO0O <= 1;
	always @(nlOiO1l_event)
		nlOiO1l <= 1;
	always @(nlOiOil_event)
		nlOiOil <= 1;
	always @(nlOiOll_event)
		nlOiOll <= 1;
	always @(nlOiOOi_event)
		nlOiOOi <= 1;
	always @(nlOiOOO_event)
		nlOiOOO <= 1;
	always @(nlOl00i_event)
		nlOl00i <= 1;
	always @(nlOl00l_event)
		nlOl00l <= 1;
	always @(nlOl00O_event)
		nlOl00O <= 1;
	always @(nlOl01i_event)
		nlOl01i <= 1;
	always @(nlOl01l_event)
		nlOl01l <= 1;
	always @(nlOl01O_event)
		nlOl01O <= 1;
	always @(nlOl0ii_event)
		nlOl0ii <= 1;
	always @(nlOl0il_event)
		nlOl0il <= 1;
	always @(nlOl0iO_event)
		nlOl0iO <= 1;
	always @(nlOl0li_event)
		nlOl0li <= 1;
	always @(nlOl0ll_event)
		nlOl0ll <= 1;
	always @(nlOl0lO_event)
		nlOl0lO <= 1;
	always @(nlOl0Oi_event)
		nlOl0Oi <= 1;
	always @(nlOl0Ol_event)
		nlOl0Ol <= 1;
	always @(nlOl0OO_event)
		nlOl0OO <= 1;
	always @(nlOl10i_event)
		nlOl10i <= 1;
	always @(nlOl10O_event)
		nlOl10O <= 1;
	always @(nlOl11l_event)
		nlOl11l <= 1;
	always @(nlOl1il_event)
		nlOl1il <= 1;
	always @(nlOl1li_event)
		nlOl1li <= 1;
	always @(nlOl1lO_event)
		nlOl1lO <= 1;
	always @(nlOl1Oi_event)
		nlOl1Oi <= 1;
	always @(nlOl1Ol_event)
		nlOl1Ol <= 1;
	always @(nlOl1OO_event)
		nlOl1OO <= 1;
	always @(nlOli0i_event)
		nlOli0i <= 1;
	always @(nlOli0l_event)
		nlOli0l <= 1;
	always @(nlOli0O_event)
		nlOli0O <= 1;
	always @(nlOli1i_event)
		nlOli1i <= 1;
	always @(nlOli1l_event)
		nlOli1l <= 1;
	always @(nlOli1O_event)
		nlOli1O <= 1;
	always @(nlOliii_event)
		nlOliii <= 1;
	always @(nlOliil_event)
		nlOliil <= 1;
	always @(nlOliiO_event)
		nlOliiO <= 1;
	always @(nlOlili_event)
		nlOlili <= 1;
	always @(nlOlill_event)
		nlOlill <= 1;
	always @(nlOlilO_event)
		nlOlilO <= 1;
	always @(nlOliOi_event)
		nlOliOi <= 1;
	always @(nlOliOl_event)
		nlOliOl <= 1;
	always @(nlOliOO_event)
		nlOliOO <= 1;
	always @(nlOll0i_event)
		nlOll0i <= 1;
	always @(nlOll0l_event)
		nlOll0l <= 1;
	always @(nlOll0O_event)
		nlOll0O <= 1;
	always @(nlOll1i_event)
		nlOll1i <= 1;
	always @(nlOll1l_event)
		nlOll1l <= 1;
	always @(nlOll1O_event)
		nlOll1O <= 1;
	always @(nlOllii_event)
		nlOllii <= 1;
	always @(nlOllil_event)
		nlOllil <= 1;
	always @(nlOlliO_event)
		nlOlliO <= 1;
	always @(nlOllli_event)
		nlOllli <= 1;
	always @(nlOllll_event)
		nlOllll <= 1;
	always @(nlOlllO_event)
		nlOlllO <= 1;
	always @(nlOllOi_event)
		nlOllOi <= 1;
	always @(nlOllOl_event)
		nlOllOl <= 1;
	always @(nlOllOO_event)
		nlOllOO <= 1;
	always @(nlOlO0i_event)
		nlOlO0i <= 1;
	always @(nlOlO0l_event)
		nlOlO0l <= 1;
	always @(nlOlO0O_event)
		nlOlO0O <= 1;
	always @(nlOlO1i_event)
		nlOlO1i <= 1;
	always @(nlOlO1l_event)
		nlOlO1l <= 1;
	always @(nlOlO1O_event)
		nlOlO1O <= 1;
	always @(nlOlOii_event)
		nlOlOii <= 1;
	always @(nlOlOil_event)
		nlOlOil <= 1;
	always @(nlOlOiO_event)
		nlOlOiO <= 1;
	always @(nlOlOli_event)
		nlOlOli <= 1;
	always @(nlOlOll_event)
		nlOlOll <= 1;
	always @(nlOlOlO_event)
		nlOlOlO <= 1;
	always @(nlOlOOi_event)
		nlOlOOi <= 1;
	always @(nlOlOOl_event)
		nlOlOOl <= 1;
	always @(nlOlOOO_event)
		nlOlOOO <= 1;
	always @(nlOO00i_event)
		nlOO00i <= 1;
	always @(nlOO00l_event)
		nlOO00l <= 1;
	always @(nlOO00O_event)
		nlOO00O <= 1;
	always @(nlOO01i_event)
		nlOO01i <= 1;
	always @(nlOO01l_event)
		nlOO01l <= 1;
	always @(nlOO01O_event)
		nlOO01O <= 1;
	always @(nlOO0ii_event)
		nlOO0ii <= 1;
	always @(nlOO0il_event)
		nlOO0il <= 1;
	always @(nlOO0iO_event)
		nlOO0iO <= 1;
	always @(nlOO0li_event)
		nlOO0li <= 1;
	always @(nlOO0ll_event)
		nlOO0ll <= 1;
	always @(nlOO0lO_event)
		nlOO0lO <= 1;
	always @(nlOO0Oi_event)
		nlOO0Oi <= 1;
	always @(nlOO0Ol_event)
		nlOO0Ol <= 1;
	always @(nlOO0OO_event)
		nlOO0OO <= 1;
	always @(nlOO10i_event)
		nlOO10i <= 1;
	always @(nlOO10l_event)
		nlOO10l <= 1;
	always @(nlOO10O_event)
		nlOO10O <= 1;
	always @(nlOO11i_event)
		nlOO11i <= 1;
	always @(nlOO11l_event)
		nlOO11l <= 1;
	always @(nlOO11O_event)
		nlOO11O <= 1;
	always @(nlOO1ii_event)
		nlOO1ii <= 1;
	always @(nlOO1il_event)
		nlOO1il <= 1;
	always @(nlOO1iO_event)
		nlOO1iO <= 1;
	always @(nlOO1li_event)
		nlOO1li <= 1;
	always @(nlOO1ll_event)
		nlOO1ll <= 1;
	always @(nlOO1lO_event)
		nlOO1lO <= 1;
	always @(nlOO1Oi_event)
		nlOO1Oi <= 1;
	always @(nlOO1Ol_event)
		nlOO1Ol <= 1;
	always @(nlOO1OO_event)
		nlOO1OO <= 1;
	always @(nlOOi0i_event)
		nlOOi0i <= 1;
	always @(nlOOi0l_event)
		nlOOi0l <= 1;
	always @(nlOOi0O_event)
		nlOOi0O <= 1;
	always @(nlOOi1i_event)
		nlOOi1i <= 1;
	always @(nlOOi1l_event)
		nlOOi1l <= 1;
	always @(nlOOi1O_event)
		nlOOi1O <= 1;
	always @(nlOOiii_event)
		nlOOiii <= 1;
	always @(nlOOiil_event)
		nlOOiil <= 1;
	always @(nlOOiiO_event)
		nlOOiiO <= 1;
	always @(nlOOili_event)
		nlOOili <= 1;
	always @(nlOOill_event)
		nlOOill <= 1;
	always @(nlOOilO_event)
		nlOOilO <= 1;
	always @(nlOOiOi_event)
		nlOOiOi <= 1;
	always @(nlOOiOl_event)
		nlOOiOl <= 1;
	always @(nlOOiOO_event)
		nlOOiOO <= 1;
	always @(nlOOl0i_event)
		nlOOl0i <= 1;
	always @(nlOOl0l_event)
		nlOOl0l <= 1;
	always @(nlOOl0O_event)
		nlOOl0O <= 1;
	always @(nlOOl1i_event)
		nlOOl1i <= 1;
	always @(nlOOl1l_event)
		nlOOl1l <= 1;
	always @(nlOOl1O_event)
		nlOOl1O <= 1;
	always @(nlOOlii_event)
		nlOOlii <= 1;
	always @(nlOOlil_event)
		nlOOlil <= 1;
	always @(nlOOliO_event)
		nlOOliO <= 1;
	always @(nlOOlli_event)
		nlOOlli <= 1;
	always @(nlOOlll_event)
		nlOOlll <= 1;
	initial
	begin
		n1l1O = 0;
		nl011i = 0;
		nl100i = 0;
		nl100l = 0;
		nl100O = 0;
		nl101i = 0;
		nl101l = 0;
		nl101O = 0;
		nl10ii = 0;
		nl10il = 0;
		nl10iO = 0;
		nl10li = 0;
		nl10ll = 0;
		nl10lO = 0;
		nl10Oi = 0;
		nl10Ol = 0;
		nl10OO = 0;
		nl11ll = 0;
		nl11lO = 0;
		nl11Oi = 0;
		nl11Ol = 0;
		nl11OO = 0;
		nl1i0i = 0;
		nl1i0l = 0;
		nl1i0O = 0;
		nl1i1i = 0;
		nl1i1l = 0;
		nl1i1O = 0;
		nl1iii = 0;
		nl1iil = 0;
		nl1iiO = 0;
		nl1ili = 0;
		nl1ill = 0;
		nl1ilO = 0;
		nl1iOi = 0;
		nl1iOl = 0;
		nl1iOO = 0;
		nl1l0i = 0;
		nl1l0l = 0;
		nl1l0O = 0;
		nl1l1i = 0;
		nl1l1l = 0;
		nl1l1O = 0;
		nl1lii = 0;
		nl1lil = 0;
		nl1liO = 0;
		nl1lli = 0;
		nl1lll = 0;
		nl1llO = 0;
		nl1lOi = 0;
		nl1lOl = 0;
		nl1lOO = 0;
		nl1O0i = 0;
		nl1O0l = 0;
		nl1O0O = 0;
		nl1O1i = 0;
		nl1O1l = 0;
		nl1O1O = 0;
		nl1Oii = 0;
		nl1Oil = 0;
		nl1OiO = 0;
		nl1Oli = 0;
		nl1Oll = 0;
		nl1OlO = 0;
		nl1OOi = 0;
		nl1OOl = 0;
		nl1OOO = 0;
	end
	always @ ( posedge clk or  negedge wire_n1l1l_CLRN)
	begin
		if (wire_n1l1l_CLRN == 1'b0) 
		begin
			n1l1O <= 0;
			nl011i <= 0;
			nl100i <= 0;
			nl100l <= 0;
			nl100O <= 0;
			nl101i <= 0;
			nl101l <= 0;
			nl101O <= 0;
			nl10ii <= 0;
			nl10il <= 0;
			nl10iO <= 0;
			nl10li <= 0;
			nl10ll <= 0;
			nl10lO <= 0;
			nl10Oi <= 0;
			nl10Ol <= 0;
			nl10OO <= 0;
			nl11ll <= 0;
			nl11lO <= 0;
			nl11Oi <= 0;
			nl11Ol <= 0;
			nl11OO <= 0;
			nl1i0i <= 0;
			nl1i0l <= 0;
			nl1i0O <= 0;
			nl1i1i <= 0;
			nl1i1l <= 0;
			nl1i1O <= 0;
			nl1iii <= 0;
			nl1iil <= 0;
			nl1iiO <= 0;
			nl1ili <= 0;
			nl1ill <= 0;
			nl1ilO <= 0;
			nl1iOi <= 0;
			nl1iOl <= 0;
			nl1iOO <= 0;
			nl1l0i <= 0;
			nl1l0l <= 0;
			nl1l0O <= 0;
			nl1l1i <= 0;
			nl1l1l <= 0;
			nl1l1O <= 0;
			nl1lii <= 0;
			nl1lil <= 0;
			nl1liO <= 0;
			nl1lli <= 0;
			nl1lll <= 0;
			nl1llO <= 0;
			nl1lOi <= 0;
			nl1lOl <= 0;
			nl1lOO <= 0;
			nl1O0i <= 0;
			nl1O0l <= 0;
			nl1O0O <= 0;
			nl1O1i <= 0;
			nl1O1l <= 0;
			nl1O1O <= 0;
			nl1Oii <= 0;
			nl1Oil <= 0;
			nl1OiO <= 0;
			nl1Oli <= 0;
			nl1Oll <= 0;
			nl1OlO <= 0;
			nl1OOi <= 0;
			nl1OOl <= 0;
			nl1OOO <= 0;
		end
		else if  (n0lO0i == 1'b1) 
		begin
			n1l1O <= (nlO10lO ^ (nlO10Oi ^ (nlO1ill ^ (nlO1iOO ^ (nlO1lOO ^ nlO1llO)))));
			nl011i <= (nlO10lO ^ (nlO1i1i ^ (nlO1l0i ^ (nlO1lOi ^ nlO1lii))));
			nl100i <= (nlO10Ol ^ (nlO1i0i ^ (nlO1iil ^ (nlO1iiO ^ (nlO1lii ^ nlO1ilO)))));
			nl100l <= (nlO10Oi ^ (nlO10OO ^ (nlO1i0i ^ (nlO1iOi ^ (nlO1lOO ^ nlO1lli)))));
			nl100O <= (nlO1i1l ^ (nlO1i0l ^ (nlO1iii ^ (nlO1iiO ^ (nlO1l1i ^ nlO1ill)))));
			nl101i <= (nlO1i1i ^ (nlO1i0O ^ (nlO1iii ^ (nlO1ill ^ (nlO1O1l ^ nlO1ilO)))));
			nl101l <= (nlO10OO ^ (nlO1i1i ^ (nlO1iil ^ (nlO1ill ^ (nlO1lli ^ nlO1iOi)))));
			nl101O <= (nlO1i0O ^ (nlO1iil ^ (nlO1iiO ^ (nlO1ili ^ nlO101i))));
			nl10ii <= (nlO10lO ^ (nlO10Ol ^ (nlO1i1i ^ (nlO1i0i ^ (nlO1ill ^ nlO1iii)))));
			nl10il <= (nlO10OO ^ (nlO1i1l ^ (nlO1i0l ^ (nlO1iOl ^ (nlO1lii ^ nlO1l0i)))));
			nl10iO <= (nlO1iii ^ (nlO1ill ^ (nlO1ilO ^ (nlO1lll ^ nlO100i))));
			nl10li <= (nlO10Ol ^ (nlO1i1O ^ (nlO1i0l ^ (nlO1ilO ^ (nlO1lil ^ nlO1l0l)))));
			nl10ll <= (nlO1i1l ^ (nlO1iii ^ (nlO1iOl ^ (nlO1iOO ^ (nlO1O1l ^ nlO1l1l)))));
			nl10lO <= (nlO10Oi ^ (nlO1i1O ^ (nlO1i0i ^ (nlO1i0O ^ (nlO1O1i ^ nlO1iiO)))));
			nl10Oi <= (nlO10lO ^ (nlO10Ol ^ (nlO1i0i ^ (nlO1l1i ^ (nlO1llO ^ nlO1l1l)))));
			nl10Ol <= (nlO1i1i ^ (nlO1i1O ^ (nlO1iii ^ (nlO1iOO ^ nlO11Ol))));
			nl10OO <= (nlO1iii ^ (nlO1lii ^ (nlO1lil ^ (nlO1lli ^ nlO11OO))));
			nl11ll <= (nlO1i1l ^ (nlO1i0l ^ (nlO1ili ^ (nlO1ilO ^ (nlO1l0i ^ nlO1l1l)))));
			nl11lO <= (nlO1i1i ^ (nlO1ili ^ (nlO1iOl ^ (nlO1lil ^ nlO11Oi))));
			nl11Oi <= (nlO10OO ^ (nlO1iOi ^ (nlO1l1l ^ (nlO1llO ^ nlO11OO))));
			nl11Ol <= (nlO1i1l ^ (nlO1i1O ^ (nlO1i0l ^ (nlO1iil ^ (nlO1lOi ^ nlO1iOO)))));
			nl11OO <= (nlO10lO ^ (nlO10Ol ^ (nlO1i1i ^ (nlO1ili ^ (nlO1l1i ^ nlO1iOl)))));
			nl1i0i <= (nlO1i1l ^ (nlO1i1O ^ (nlO1iOO ^ (nlO1l1i ^ (nlO1O1i ^ nlO1lli)))));
			nl1i0l <= (nlO10OO ^ (nlO1iii ^ (nlO1iil ^ (nlO1iOi ^ nlO11OO))));
			nl1i0O <= (nlO1i1l ^ (nlO1i0i ^ (nlO1i0O ^ (nlO1iil ^ nlO11lO))));
			nl1i1i <= (nlO10OO ^ (nlO1iil ^ (nlO1ili ^ (nlO1lOi ^ nlO101l))));
			nl1i1l <= (nlO10lO ^ (nlO1i1i ^ (nlO1i0O ^ (nlO1ili ^ (nlO1O1l ^ nlO1lll)))));
			nl1i1O <= (nlO10Oi ^ (nlO1i1i ^ (nlO1iOi ^ (nlO1l1i ^ (nlO1llO ^ nlO1lii)))));
			nl1iii <= (nlO10Oi ^ (nlO10OO ^ (nlO1l0l ^ (nlO1lil ^ nlO100i))));
			nl1iil <= (nlO1i0i ^ (nlO1iiO ^ (nlO1ilO ^ (nlO1iOl ^ (nlO1lll ^ nlO1l1i)))));
			nl1iiO <= (nlO10Oi ^ (nlO1i0i ^ (nlO1i0l ^ (nlO1iii ^ (nlO1lOO ^ nlO1iOi)))));
			nl1ili <= (nlO10lO ^ (nlO1i0O ^ (nlO1iil ^ (nlO1iOl ^ (nlO1lOO ^ nlO1l1i)))));
			nl1ill <= (nlO10OO ^ (nlO1i1i ^ (nlO1iOO ^ (nlO1lii ^ (nlO1O1l ^ nlO1lil)))));
			nl1ilO <= (nlO1i0i ^ (nlO1ili ^ (nlO1l0l ^ (nlO1lll ^ (nlO1O1i ^ nlO1lOi)))));
			nl1iOi <= (nlO10OO ^ (nlO1i1i ^ (nlO1i0l ^ (nlO1ilO ^ (nlO1lll ^ nlO1iOi)))));
			nl1iOl <= (nlO10Oi ^ (nlO10Ol ^ (nlO10OO ^ (nlO1iil ^ (nlO1lli ^ nlO1ill)))));
			nl1iOO <= (nlO10lO ^ (nlO1ili ^ (nlO1iOi ^ (nlO1l1i ^ (nlO1lil ^ nlO1l0i)))));
			nl1l0i <= (nlO10OO ^ (nlO1i1i ^ (nlO1iOO ^ (nlO1llO ^ nlO1l0l))));
			nl1l0l <= (nlO1i1O ^ (nlO1i0l ^ (nlO1iOi ^ (nlO1lii ^ nlO1l1i))));
			nl1l0O <= (nlO1i0i ^ (nlO1iil ^ (nlO1l1i ^ (nlO1l0i ^ (nlO1lil ^ nlO1lii)))));
			nl1l1i <= (nlO1i0O ^ (nlO1lOO ^ nlO1l1l));
			nl1l1l <= (nlO1i1i ^ (nlO1i0O ^ (nlO1iii ^ (nlO1l1i ^ nlO101O))));
			nl1l1O <= (nlO1i1O ^ (nlO1iiO ^ (nlO1l1i ^ (nlO1lil ^ nlO101O))));
			nl1lii <= (nlO1i0l ^ (nlO1iOO ^ (nlO1l1l ^ (nlO1lOO ^ nlO1lii))));
			nl1lil <= (nlO10Oi ^ (nlO10OO ^ (nlO1i1O ^ (nlO1i0l ^ (nlO1lll ^ nlO1lil)))));
			nl1liO <= (nlO1iiO ^ (nlO1l1l ^ (nlO1lli ^ nlO101l)));
			nl1lli <= nlO1iOl;
			nl1lll <= (nlO10lO ^ (nlO10Oi ^ (nlO1i0i ^ (nlO1iil ^ nlO11OO))));
			nl1llO <= (nlO1iOO ^ nlO101i);
			nl1lOi <= (nlO1i1O ^ (nlO1iOl ^ nlO1iOi));
			nl1lOl <= nlO1i0i;
			nl1lOO <= (nlO1iii ^ (nlO1iil ^ (nlO1ill ^ (nlO1l1i ^ (nlO1O1i ^ nlO1llO)))));
			nl1O0i <= (nlO1i1l ^ nlO11Ol);
			nl1O0l <= (nlO10OO ^ (nlO1i0O ^ (nlO1iiO ^ (nlO1lii ^ (nlO1O1l ^ nlO1lOO)))));
			nl1O0O <= (nlO1i1O ^ (nlO1iiO ^ nlO11Oi));
			nl1O1i <= (nlO1i1l ^ (nlO1ili ^ nlO1i0O));
			nl1O1l <= (nlO1i1O ^ (nlO1iOi ^ (nlO1O1l ^ nlO1lOi)));
			nl1O1O <= (nlO10OO ^ (nlO1i1l ^ (nlO1iii ^ (nlO1ilO ^ nlO11OO))));
			nl1Oii <= (nlO1l0i ^ nlO10Oi);
			nl1Oil <= (nlO10lO ^ (nlO1ilO ^ nlO11lO));
			nl1OiO <= (nlO1i0l ^ (nlO1i0O ^ (nlO1l0i ^ nlO1ill)));
			nl1Oli <= (nlO10lO ^ (nlO1lii ^ nlO1iiO));
			nl1Oll <= (nlO10Oi ^ (nlO1ill ^ (nlO1iOO ^ (nlO1l0l ^ (nlO1llO ^ nlO1lll)))));
			nl1OlO <= (nlO10Oi ^ (nlO1i0O ^ (nlO1l0i ^ nlO1l1i)));
			nl1OOi <= nlO10Oi;
			nl1OOl <= (nlO1ill ^ (nlO1l1l ^ (nlO1lii ^ nlO1l0l)));
			nl1OOO <= nlO1iiO;
		end
	end
	assign
		wire_n1l1l_CLRN = (nlO100l48 ^ nlO100l47);
	event n1l1O_event;
	event nl011i_event;
	event nl100i_event;
	event nl100l_event;
	event nl100O_event;
	event nl101i_event;
	event nl101l_event;
	event nl101O_event;
	event nl10ii_event;
	event nl10il_event;
	event nl10iO_event;
	event nl10li_event;
	event nl10ll_event;
	event nl10lO_event;
	event nl10Oi_event;
	event nl10Ol_event;
	event nl10OO_event;
	event nl11ll_event;
	event nl11lO_event;
	event nl11Oi_event;
	event nl11Ol_event;
	event nl11OO_event;
	event nl1i0i_event;
	event nl1i0l_event;
	event nl1i0O_event;
	event nl1i1i_event;
	event nl1i1l_event;
	event nl1i1O_event;
	event nl1iii_event;
	event nl1iil_event;
	event nl1iiO_event;
	event nl1ili_event;
	event nl1ill_event;
	event nl1ilO_event;
	event nl1iOi_event;
	event nl1iOl_event;
	event nl1iOO_event;
	event nl1l0i_event;
	event nl1l0l_event;
	event nl1l0O_event;
	event nl1l1i_event;
	event nl1l1l_event;
	event nl1l1O_event;
	event nl1lii_event;
	event nl1lil_event;
	event nl1liO_event;
	event nl1lli_event;
	event nl1lll_event;
	event nl1llO_event;
	event nl1lOi_event;
	event nl1lOl_event;
	event nl1lOO_event;
	event nl1O0i_event;
	event nl1O0l_event;
	event nl1O0O_event;
	event nl1O1i_event;
	event nl1O1l_event;
	event nl1O1O_event;
	event nl1Oii_event;
	event nl1Oil_event;
	event nl1OiO_event;
	event nl1Oli_event;
	event nl1Oll_event;
	event nl1OlO_event;
	event nl1OOi_event;
	event nl1OOl_event;
	event nl1OOO_event;
	initial
		#1 ->n1l1O_event;
	initial
		#1 ->nl011i_event;
	initial
		#1 ->nl100i_event;
	initial
		#1 ->nl100l_event;
	initial
		#1 ->nl100O_event;
	initial
		#1 ->nl101i_event;
	initial
		#1 ->nl101l_event;
	initial
		#1 ->nl101O_event;
	initial
		#1 ->nl10ii_event;
	initial
		#1 ->nl10il_event;
	initial
		#1 ->nl10iO_event;
	initial
		#1 ->nl10li_event;
	initial
		#1 ->nl10ll_event;
	initial
		#1 ->nl10lO_event;
	initial
		#1 ->nl10Oi_event;
	initial
		#1 ->nl10Ol_event;
	initial
		#1 ->nl10OO_event;
	initial
		#1 ->nl11ll_event;
	initial
		#1 ->nl11lO_event;
	initial
		#1 ->nl11Oi_event;
	initial
		#1 ->nl11Ol_event;
	initial
		#1 ->nl11OO_event;
	initial
		#1 ->nl1i0i_event;
	initial
		#1 ->nl1i0l_event;
	initial
		#1 ->nl1i0O_event;
	initial
		#1 ->nl1i1i_event;
	initial
		#1 ->nl1i1l_event;
	initial
		#1 ->nl1i1O_event;
	initial
		#1 ->nl1iii_event;
	initial
		#1 ->nl1iil_event;
	initial
		#1 ->nl1iiO_event;
	initial
		#1 ->nl1ili_event;
	initial
		#1 ->nl1ill_event;
	initial
		#1 ->nl1ilO_event;
	initial
		#1 ->nl1iOi_event;
	initial
		#1 ->nl1iOl_event;
	initial
		#1 ->nl1iOO_event;
	initial
		#1 ->nl1l0i_event;
	initial
		#1 ->nl1l0l_event;
	initial
		#1 ->nl1l0O_event;
	initial
		#1 ->nl1l1i_event;
	initial
		#1 ->nl1l1l_event;
	initial
		#1 ->nl1l1O_event;
	initial
		#1 ->nl1lii_event;
	initial
		#1 ->nl1lil_event;
	initial
		#1 ->nl1liO_event;
	initial
		#1 ->nl1lli_event;
	initial
		#1 ->nl1lll_event;
	initial
		#1 ->nl1llO_event;
	initial
		#1 ->nl1lOi_event;
	initial
		#1 ->nl1lOl_event;
	initial
		#1 ->nl1lOO_event;
	initial
		#1 ->nl1O0i_event;
	initial
		#1 ->nl1O0l_event;
	initial
		#1 ->nl1O0O_event;
	initial
		#1 ->nl1O1i_event;
	initial
		#1 ->nl1O1l_event;
	initial
		#1 ->nl1O1O_event;
	initial
		#1 ->nl1Oii_event;
	initial
		#1 ->nl1Oil_event;
	initial
		#1 ->nl1OiO_event;
	initial
		#1 ->nl1Oli_event;
	initial
		#1 ->nl1Oll_event;
	initial
		#1 ->nl1OlO_event;
	initial
		#1 ->nl1OOi_event;
	initial
		#1 ->nl1OOl_event;
	initial
		#1 ->nl1OOO_event;
	always @(n1l1O_event)
		n1l1O <= 1;
	always @(nl011i_event)
		nl011i <= 1;
	always @(nl100i_event)
		nl100i <= 1;
	always @(nl100l_event)
		nl100l <= 1;
	always @(nl100O_event)
		nl100O <= 1;
	always @(nl101i_event)
		nl101i <= 1;
	always @(nl101l_event)
		nl101l <= 1;
	always @(nl101O_event)
		nl101O <= 1;
	always @(nl10ii_event)
		nl10ii <= 1;
	always @(nl10il_event)
		nl10il <= 1;
	always @(nl10iO_event)
		nl10iO <= 1;
	always @(nl10li_event)
		nl10li <= 1;
	always @(nl10ll_event)
		nl10ll <= 1;
	always @(nl10lO_event)
		nl10lO <= 1;
	always @(nl10Oi_event)
		nl10Oi <= 1;
	always @(nl10Ol_event)
		nl10Ol <= 1;
	always @(nl10OO_event)
		nl10OO <= 1;
	always @(nl11ll_event)
		nl11ll <= 1;
	always @(nl11lO_event)
		nl11lO <= 1;
	always @(nl11Oi_event)
		nl11Oi <= 1;
	always @(nl11Ol_event)
		nl11Ol <= 1;
	always @(nl11OO_event)
		nl11OO <= 1;
	always @(nl1i0i_event)
		nl1i0i <= 1;
	always @(nl1i0l_event)
		nl1i0l <= 1;
	always @(nl1i0O_event)
		nl1i0O <= 1;
	always @(nl1i1i_event)
		nl1i1i <= 1;
	always @(nl1i1l_event)
		nl1i1l <= 1;
	always @(nl1i1O_event)
		nl1i1O <= 1;
	always @(nl1iii_event)
		nl1iii <= 1;
	always @(nl1iil_event)
		nl1iil <= 1;
	always @(nl1iiO_event)
		nl1iiO <= 1;
	always @(nl1ili_event)
		nl1ili <= 1;
	always @(nl1ill_event)
		nl1ill <= 1;
	always @(nl1ilO_event)
		nl1ilO <= 1;
	always @(nl1iOi_event)
		nl1iOi <= 1;
	always @(nl1iOl_event)
		nl1iOl <= 1;
	always @(nl1iOO_event)
		nl1iOO <= 1;
	always @(nl1l0i_event)
		nl1l0i <= 1;
	always @(nl1l0l_event)
		nl1l0l <= 1;
	always @(nl1l0O_event)
		nl1l0O <= 1;
	always @(nl1l1i_event)
		nl1l1i <= 1;
	always @(nl1l1l_event)
		nl1l1l <= 1;
	always @(nl1l1O_event)
		nl1l1O <= 1;
	always @(nl1lii_event)
		nl1lii <= 1;
	always @(nl1lil_event)
		nl1lil <= 1;
	always @(nl1liO_event)
		nl1liO <= 1;
	always @(nl1lli_event)
		nl1lli <= 1;
	always @(nl1lll_event)
		nl1lll <= 1;
	always @(nl1llO_event)
		nl1llO <= 1;
	always @(nl1lOi_event)
		nl1lOi <= 1;
	always @(nl1lOl_event)
		nl1lOl <= 1;
	always @(nl1lOO_event)
		nl1lOO <= 1;
	always @(nl1O0i_event)
		nl1O0i <= 1;
	always @(nl1O0l_event)
		nl1O0l <= 1;
	always @(nl1O0O_event)
		nl1O0O <= 1;
	always @(nl1O1i_event)
		nl1O1i <= 1;
	always @(nl1O1l_event)
		nl1O1l <= 1;
	always @(nl1O1O_event)
		nl1O1O <= 1;
	always @(nl1Oii_event)
		nl1Oii <= 1;
	always @(nl1Oil_event)
		nl1Oil <= 1;
	always @(nl1OiO_event)
		nl1OiO <= 1;
	always @(nl1Oli_event)
		nl1Oli <= 1;
	always @(nl1Oll_event)
		nl1Oll <= 1;
	always @(nl1OlO_event)
		nl1OlO <= 1;
	always @(nl1OOi_event)
		nl1OOi <= 1;
	always @(nl1OOl_event)
		nl1OOl <= 1;
	always @(nl1OOO_event)
		nl1OOO <= 1;
	initial
	begin
		n0lOli = 0;
		n0lOll = 0;
		n0lOlO = 0;
		n0lOOi = 0;
		n0lOOl = 0;
		n0lOOO = 0;
		n0O00i = 0;
		n0O00l = 0;
		n0O00O = 0;
		n0O01i = 0;
		n0O01l = 0;
		n0O01O = 0;
		n0O0ii = 0;
		n0O0il = 0;
		n0O0iO = 0;
		n0O0li = 0;
		n0O0ll = 0;
		n0O0lO = 0;
		n0O0Oi = 0;
		n0O0Ol = 0;
		n0O0OO = 0;
		n0O10i = 0;
		n0O10l = 0;
		n0O10O = 0;
		n0O11i = 0;
		n0O11l = 0;
		n0O11O = 0;
		n0O1ii = 0;
		n0O1il = 0;
		n0O1iO = 0;
		n0O1li = 0;
		n0O1ll = 0;
		n0O1lO = 0;
		n0O1Oi = 0;
		n0O1Ol = 0;
		n0O1OO = 0;
		n0Oi0i = 0;
		n0Oi0l = 0;
		n0Oi0O = 0;
		n0Oi1i = 0;
		n0Oi1l = 0;
		n0Oi1O = 0;
		n0Oiii = 0;
		n0Oiil = 0;
		n0OiiO = 0;
		n0Oili = 0;
		n0Oill = 0;
		n0OilO = 0;
		n0OiOi = 0;
		n0OiOl = 0;
		n0OiOO = 0;
		n0Ol0i = 0;
		n0Ol0l = 0;
		n0Ol0O = 0;
		n0Ol1i = 0;
		n0Ol1l = 0;
		n0Ol1O = 0;
		n0Olii = 0;
		n0Olil = 0;
		n0OliO = 0;
		n0Olli = 0;
		n0Olll = 0;
		n0OllO = 0;
		n0OlOi = 0;
		n0OlOl = 0;
		n0OlOO = 0;
		n0OO0i = 0;
		n0OO0l = 0;
		n0OO0O = 0;
		n0OO1i = 0;
		n0OO1l = 0;
		n0OO1O = 0;
		nl11li = 0;
	end
	always @ (clk or wire_nl11iO_PRN or wire_nl11iO_CLRN)
	begin
		if (wire_nl11iO_PRN == 1'b0) 
		begin
			n0lOli <= 1;
			n0lOll <= 1;
			n0lOlO <= 1;
			n0lOOi <= 1;
			n0lOOl <= 1;
			n0lOOO <= 1;
			n0O00i <= 1;
			n0O00l <= 1;
			n0O00O <= 1;
			n0O01i <= 1;
			n0O01l <= 1;
			n0O01O <= 1;
			n0O0ii <= 1;
			n0O0il <= 1;
			n0O0iO <= 1;
			n0O0li <= 1;
			n0O0ll <= 1;
			n0O0lO <= 1;
			n0O0Oi <= 1;
			n0O0Ol <= 1;
			n0O0OO <= 1;
			n0O10i <= 1;
			n0O10l <= 1;
			n0O10O <= 1;
			n0O11i <= 1;
			n0O11l <= 1;
			n0O11O <= 1;
			n0O1ii <= 1;
			n0O1il <= 1;
			n0O1iO <= 1;
			n0O1li <= 1;
			n0O1ll <= 1;
			n0O1lO <= 1;
			n0O1Oi <= 1;
			n0O1Ol <= 1;
			n0O1OO <= 1;
			n0Oi0i <= 1;
			n0Oi0l <= 1;
			n0Oi0O <= 1;
			n0Oi1i <= 1;
			n0Oi1l <= 1;
			n0Oi1O <= 1;
			n0Oiii <= 1;
			n0Oiil <= 1;
			n0OiiO <= 1;
			n0Oili <= 1;
			n0Oill <= 1;
			n0OilO <= 1;
			n0OiOi <= 1;
			n0OiOl <= 1;
			n0OiOO <= 1;
			n0Ol0i <= 1;
			n0Ol0l <= 1;
			n0Ol0O <= 1;
			n0Ol1i <= 1;
			n0Ol1l <= 1;
			n0Ol1O <= 1;
			n0Olii <= 1;
			n0Olil <= 1;
			n0OliO <= 1;
			n0Olli <= 1;
			n0Olll <= 1;
			n0OllO <= 1;
			n0OlOi <= 1;
			n0OlOl <= 1;
			n0OlOO <= 1;
			n0OO0i <= 1;
			n0OO0l <= 1;
			n0OO0O <= 1;
			n0OO1i <= 1;
			n0OO1l <= 1;
			n0OO1O <= 1;
			nl11li <= 1;
		end
		else if  (wire_nl11iO_CLRN == 1'b0) 
		begin
			n0lOli <= 0;
			n0lOll <= 0;
			n0lOlO <= 0;
			n0lOOi <= 0;
			n0lOOl <= 0;
			n0lOOO <= 0;
			n0O00i <= 0;
			n0O00l <= 0;
			n0O00O <= 0;
			n0O01i <= 0;
			n0O01l <= 0;
			n0O01O <= 0;
			n0O0ii <= 0;
			n0O0il <= 0;
			n0O0iO <= 0;
			n0O0li <= 0;
			n0O0ll <= 0;
			n0O0lO <= 0;
			n0O0Oi <= 0;
			n0O0Ol <= 0;
			n0O0OO <= 0;
			n0O10i <= 0;
			n0O10l <= 0;
			n0O10O <= 0;
			n0O11i <= 0;
			n0O11l <= 0;
			n0O11O <= 0;
			n0O1ii <= 0;
			n0O1il <= 0;
			n0O1iO <= 0;
			n0O1li <= 0;
			n0O1ll <= 0;
			n0O1lO <= 0;
			n0O1Oi <= 0;
			n0O1Ol <= 0;
			n0O1OO <= 0;
			n0Oi0i <= 0;
			n0Oi0l <= 0;
			n0Oi0O <= 0;
			n0Oi1i <= 0;
			n0Oi1l <= 0;
			n0Oi1O <= 0;
			n0Oiii <= 0;
			n0Oiil <= 0;
			n0OiiO <= 0;
			n0Oili <= 0;
			n0Oill <= 0;
			n0OilO <= 0;
			n0OiOi <= 0;
			n0OiOl <= 0;
			n0OiOO <= 0;
			n0Ol0i <= 0;
			n0Ol0l <= 0;
			n0Ol0O <= 0;
			n0Ol1i <= 0;
			n0Ol1l <= 0;
			n0Ol1O <= 0;
			n0Olii <= 0;
			n0Olil <= 0;
			n0OliO <= 0;
			n0Olli <= 0;
			n0Olll <= 0;
			n0OllO <= 0;
			n0OlOi <= 0;
			n0OlOl <= 0;
			n0OlOO <= 0;
			n0OO0i <= 0;
			n0OO0l <= 0;
			n0OO0O <= 0;
			n0OO1i <= 0;
			n0OO1l <= 0;
			n0OO1O <= 0;
			nl11li <= 0;
		end
		else if  (nlO11iO == 1'b1) 
		if (clk != nl11iO_clk_prev && clk == 1'b1) 
		begin
			n0lOli <= (wire_nlO1O_dataout ^ (wire_nlO1i_dataout ^ (wire_nll0i_dataout ^ (wire_nll1O_dataout ^ nllOOOi))));
			n0lOll <= (wire_nlOll_dataout ^ (wire_nlOiO_dataout ^ (wire_nlO1l_dataout ^ (wire_nlllO_dataout ^ (wire_nll1l_dataout ^ wire_nll1i_dataout)))));
			n0lOlO <= (wire_nlOOi_dataout ^ (wire_nlOii_dataout ^ (wire_nlliO_dataout ^ (wire_nliOl_dataout ^ (wire_nliOi_dataout ^ wire_nlilO_dataout)))));
			n0lOOi <= (wire_nlO1O_dataout ^ (wire_nllOO_dataout ^ (wire_nllOl_dataout ^ (wire_nllil_dataout ^ (wire_nll0l_dataout ^ wire_nll1O_dataout)))));
			n0lOOl <= (wire_nlOii_dataout ^ (wire_nllOi_dataout ^ (wire_nlllO_dataout ^ (wire_nllll_dataout ^ nlO11il))));
			n0lOOO <= (wire_nlO0O_dataout ^ (wire_nlO1l_dataout ^ (wire_nllOi_dataout ^ (wire_nll0O_dataout ^ (wire_nll0i_dataout ^ wire_nll1l_dataout)))));
			n0O00i <= (wire_nlOli_dataout ^ (wire_nlOiO_dataout ^ (wire_nllOi_dataout ^ (wire_nlliO_dataout ^ (wire_nll1O_dataout ^ wire_nll1i_dataout)))));
			n0O00l <= (wire_nlOli_dataout ^ (wire_nlOiO_dataout ^ (wire_nlO0l_dataout ^ (wire_nll0O_dataout ^ nlO111i))));
			n0O00O <= (wire_nlOOi_dataout ^ (wire_nlOil_dataout ^ (wire_nlOii_dataout ^ (wire_nlliO_dataout ^ nlO11ii))));
			n0O01i <= (wire_nlOlO_dataout ^ (wire_nlOii_dataout ^ (wire_nlO1O_dataout ^ (wire_nllOl_dataout ^ (wire_nlliO_dataout ^ wire_nllii_dataout)))));
			n0O01l <= (wire_nlO0O_dataout ^ (wire_nlO0i_dataout ^ (wire_nlliO_dataout ^ (wire_nll0O_dataout ^ nllOOOl))));
			n0O01O <= (wire_nlOli_dataout ^ (wire_nlO1i_dataout ^ (wire_nllOO_dataout ^ (wire_nllOl_dataout ^ (wire_nlllO_dataout ^ wire_nllll_dataout)))));
			n0O0ii <= (wire_nlOOi_dataout ^ (wire_nlOlO_dataout ^ (wire_nlOiO_dataout ^ (wire_nll0l_dataout ^ nllOOOl))));
			n0O0il <= (wire_nlOOi_dataout ^ (wire_nlOlO_dataout ^ (wire_nlOli_dataout ^ (wire_nlO0i_dataout ^ (wire_nllli_dataout ^ wire_nliOi_dataout)))));
			n0O0iO <= (wire_nlOli_dataout ^ (wire_nlO0l_dataout ^ (wire_nllii_dataout ^ (wire_nll0l_dataout ^ nlO110O))));
			n0O0li <= (wire_nlOlO_dataout ^ (wire_nlO0O_dataout ^ (wire_nllll_dataout ^ (wire_nlliO_dataout ^ (wire_nll1l_dataout ^ wire_nliOi_dataout)))));
			n0O0ll <= (wire_nlOii_dataout ^ (wire_nlO1i_dataout ^ (wire_nllOl_dataout ^ (wire_nllOi_dataout ^ nlO111O))));
			n0O0lO <= (wire_nlOOi_dataout ^ (wire_nlO0l_dataout ^ (wire_nlO0i_dataout ^ (wire_nllOO_dataout ^ (wire_nllll_dataout ^ wire_nll0i_dataout)))));
			n0O0Oi <= (wire_nlOii_dataout ^ (wire_nlO0O_dataout ^ (wire_nllli_dataout ^ (wire_nll0O_dataout ^ (wire_nll0l_dataout ^ wire_nlilO_dataout)))));
			n0O0Ol <= (wire_nlOlO_dataout ^ (wire_nllOl_dataout ^ (wire_nllli_dataout ^ (wire_nll1l_dataout ^ nlO110l))));
			n0O0OO <= (wire_nlOll_dataout ^ (wire_nlOiO_dataout ^ (wire_nlOii_dataout ^ (wire_nlO0l_dataout ^ nlO110i))));
			n0O10i <= (wire_nlOOi_dataout ^ (wire_nlOll_dataout ^ (wire_nllOl_dataout ^ (wire_nllli_dataout ^ (wire_nllii_dataout ^ wire_nll0i_dataout)))));
			n0O10l <= (wire_nlOll_dataout ^ (wire_nllll_dataout ^ (wire_nlliO_dataout ^ (wire_nll0O_dataout ^ nlO110l))));
			n0O10O <= (wire_nlO0O_dataout ^ (wire_nlO0l_dataout ^ (wire_nlO1l_dataout ^ (wire_nlllO_dataout ^ nllOOOO))));
			n0O11i <= (wire_nlOli_dataout ^ (wire_nlOil_dataout ^ (wire_nllli_dataout ^ (wire_nllii_dataout ^ nlO110i))));
			n0O11l <= (wire_nlOll_dataout ^ (wire_nlO1O_dataout ^ (wire_nlO1l_dataout ^ (wire_nllOO_dataout ^ (wire_nlllO_dataout ^ wire_nliOi_dataout)))));
			n0O11O <= (wire_nlOll_dataout ^ (wire_nlOii_dataout ^ (wire_nllOi_dataout ^ (wire_nlllO_dataout ^ nlO110i))));
			n0O1ii <= (wire_nlOiO_dataout ^ (wire_nlO0O_dataout ^ (wire_nllOi_dataout ^ (wire_nllii_dataout ^ nlO110O))));
			n0O1il <= (wire_nlOil_dataout ^ (wire_nlOii_dataout ^ (wire_nlO1O_dataout ^ (wire_nllOi_dataout ^ (wire_nllll_dataout ^ wire_nll1i_dataout)))));
			n0O1iO <= (wire_nlO1O_dataout ^ (wire_nllOl_dataout ^ (wire_nllll_dataout ^ (wire_nllii_dataout ^ nlO11il))));
			n0O1li <= (wire_nlOli_dataout ^ (wire_nlOil_dataout ^ (wire_nlO0l_dataout ^ (wire_nllOl_dataout ^ (wire_nlliO_dataout ^ wire_nliOO_dataout)))));
			n0O1ll <= (wire_nlOil_dataout ^ (wire_nlO1l_dataout ^ (wire_nllOi_dataout ^ (wire_nllll_dataout ^ (wire_nllli_dataout ^ wire_nlilO_dataout)))));
			n0O1lO <= (wire_nlOil_dataout ^ (wire_nlOii_dataout ^ (wire_nlO0O_dataout ^ (wire_nllil_dataout ^ (wire_nllii_dataout ^ wire_nll0O_dataout)))));
			n0O1Oi <= (wire_nlOil_dataout ^ (wire_nlO0l_dataout ^ (wire_nlO1i_dataout ^ (wire_nllil_dataout ^ nlO11ii))));
			n0O1Ol <= (wire_nlOiO_dataout ^ (wire_nlO1O_dataout ^ (wire_nlO1i_dataout ^ (wire_nllOl_dataout ^ (wire_nll0O_dataout ^ wire_nll0l_dataout)))));
			n0O1OO <= (wire_nlO0O_dataout ^ (wire_nlO0i_dataout ^ (wire_nlllO_dataout ^ (wire_nllil_dataout ^ nllOOOO))));
			n0Oi0i <= (wire_nlOlO_dataout ^ (wire_nllOl_dataout ^ (wire_nllOi_dataout ^ (wire_nll0l_dataout ^ nlO111l))));
			n0Oi0l <= (wire_nlOii_dataout ^ (wire_nlO0i_dataout ^ (wire_nlO1O_dataout ^ (wire_nlO1i_dataout ^ (wire_nllOl_dataout ^ wire_nll1O_dataout)))));
			n0Oi0O <= (wire_nlOOi_dataout ^ (wire_nllOO_dataout ^ (wire_nllOl_dataout ^ (wire_nllii_dataout ^ (wire_nliOO_dataout ^ wire_nliOl_dataout)))));
			n0Oi1i <= (wire_nlOli_dataout ^ (wire_nlOii_dataout ^ (wire_nlO0O_dataout ^ (wire_nllOl_dataout ^ nlO111O))));
			n0Oi1l <= (wire_nlOlO_dataout ^ (wire_nlO0O_dataout ^ (wire_nll0O_dataout ^ (wire_nll1O_dataout ^ nlO111l))));
			n0Oi1O <= (wire_nlOlO_dataout ^ (wire_nlOil_dataout ^ (wire_nlO1i_dataout ^ (wire_nllOi_dataout ^ (wire_nllil_dataout ^ wire_nliOl_dataout)))));
			n0Oiii <= (wire_nlOll_dataout ^ (wire_nlOli_dataout ^ (wire_nllOl_dataout ^ (wire_nllil_dataout ^ (wire_nll0O_dataout ^ wire_nll1O_dataout)))));
			n0Oiil <= (wire_nlO0i_dataout ^ (wire_nllll_dataout ^ (wire_nllil_dataout ^ wire_nll0O_dataout)));
			n0OiiO <= (wire_nlO0O_dataout ^ (wire_nlO1i_dataout ^ wire_nliOi_dataout));
			n0Oili <= (wire_nlOii_dataout ^ (wire_nlO0O_dataout ^ (wire_nlO0l_dataout ^ (wire_nlO0i_dataout ^ (wire_nllOi_dataout ^ wire_nll1i_dataout)))));
			n0Oill <= (wire_nlOOi_dataout ^ wire_nlO1l_dataout);
			n0OilO <= (wire_nlOlO_dataout ^ (wire_nlO1l_dataout ^ (wire_nllOO_dataout ^ (wire_nlliO_dataout ^ wire_nlilO_dataout))));
			n0OiOi <= wire_nll0l_dataout;
			n0OiOl <= (wire_nlOOi_dataout ^ (wire_nlOli_dataout ^ (wire_nlO0l_dataout ^ (wire_nllOO_dataout ^ (wire_nllOl_dataout ^ wire_nllil_dataout)))));
			n0OiOO <= (wire_nlOii_dataout ^ (wire_nlO0l_dataout ^ (wire_nlO1i_dataout ^ (wire_nllll_dataout ^ wire_nll0O_dataout))));
			n0Ol0i <= wire_nllii_dataout;
			n0Ol0l <= (wire_nlOli_dataout ^ (wire_nlOiO_dataout ^ (wire_nlO0i_dataout ^ (wire_nllOl_dataout ^ (wire_nll0i_dataout ^ wire_nliOO_dataout)))));
			n0Ol0O <= (wire_nlO0O_dataout ^ (wire_nllOO_dataout ^ (wire_nllOi_dataout ^ (wire_nll0O_dataout ^ (wire_nll0l_dataout ^ wire_nliOi_dataout)))));
			n0Ol1i <= (wire_nlOll_dataout ^ wire_nll1i_dataout);
			n0Ol1l <= (wire_nlO0i_dataout ^ (wire_nlO1O_dataout ^ (wire_nllOi_dataout ^ (wire_nll0l_dataout ^ nlO111i))));
			n0Ol1O <= (wire_nlOil_dataout ^ (wire_nlO1O_dataout ^ (wire_nllOl_dataout ^ (wire_nllll_dataout ^ (wire_nllli_dataout ^ wire_nll1O_dataout)))));
			n0Olii <= (wire_nlO0O_dataout ^ (wire_nlO1i_dataout ^ (wire_nlllO_dataout ^ (wire_nll0O_dataout ^ wire_nll0i_dataout))));
			n0Olil <= (wire_nlOil_dataout ^ (wire_nlO0O_dataout ^ (wire_nlO0l_dataout ^ (wire_nlO1l_dataout ^ nllOOOO))));
			n0OliO <= (wire_nlOiO_dataout ^ (wire_nllOi_dataout ^ (wire_nll1O_dataout ^ nllOOOl)));
			n0Olli <= (wire_nlO0O_dataout ^ (wire_nlO1i_dataout ^ (wire_nllOl_dataout ^ (wire_nllll_dataout ^ wire_nliOi_dataout))));
			n0Olll <= (wire_nlOll_dataout ^ (wire_nlO1O_dataout ^ (wire_nllOO_dataout ^ (wire_nlllO_dataout ^ (wire_nlliO_dataout ^ wire_nllil_dataout)))));
			n0OllO <= (wire_nlOlO_dataout ^ (wire_nlOiO_dataout ^ (wire_nlO1l_dataout ^ (wire_nlO1i_dataout ^ wire_nll1i_dataout))));
			n0OlOi <= (wire_nlOli_dataout ^ (wire_nlO0O_dataout ^ (wire_nlO1O_dataout ^ (wire_nllOO_dataout ^ (wire_nll1l_dataout ^ wire_nliOl_dataout)))));
			n0OlOl <= (wire_nlOOi_dataout ^ (wire_nlOil_dataout ^ (wire_nllil_dataout ^ wire_nllii_dataout)));
			n0OlOO <= wire_nlOli_dataout;
			n0OO0i <= (wire_nlOiO_dataout ^ (wire_nlO1i_dataout ^ wire_nllli_dataout));
			n0OO0l <= (wire_nlOOi_dataout ^ (wire_nlOii_dataout ^ (wire_nlO0O_dataout ^ (wire_nlllO_dataout ^ (wire_nllil_dataout ^ wire_nll0i_dataout)))));
			n0OO0O <= wire_nlilO_dataout;
			n0OO1i <= (wire_nlOlO_dataout ^ (wire_nlllO_dataout ^ nllOOOi));
			n0OO1l <= (wire_nlO0l_dataout ^ (wire_nliOl_dataout ^ wire_nliOi_dataout));
			n0OO1O <= (wire_nlOiO_dataout ^ (wire_nlOil_dataout ^ (wire_nllOO_dataout ^ wire_nliOO_dataout)));
			nl11li <= (wire_nlOll_dataout ^ (wire_nllOl_dataout ^ (wire_nllli_dataout ^ wire_nll0O_dataout)));
		end
		nl11iO_clk_prev <= clk;
	end
	assign
		wire_nl11iO_CLRN = (nlO11ll50 ^ nlO11ll49),
		wire_nl11iO_PRN = (nlO11li52 ^ nlO11li51);
	event n0lOli_event;
	event n0lOll_event;
	event n0lOlO_event;
	event n0lOOi_event;
	event n0lOOl_event;
	event n0lOOO_event;
	event n0O00i_event;
	event n0O00l_event;
	event n0O00O_event;
	event n0O01i_event;
	event n0O01l_event;
	event n0O01O_event;
	event n0O0ii_event;
	event n0O0il_event;
	event n0O0iO_event;
	event n0O0li_event;
	event n0O0ll_event;
	event n0O0lO_event;
	event n0O0Oi_event;
	event n0O0Ol_event;
	event n0O0OO_event;
	event n0O10i_event;
	event n0O10l_event;
	event n0O10O_event;
	event n0O11i_event;
	event n0O11l_event;
	event n0O11O_event;
	event n0O1ii_event;
	event n0O1il_event;
	event n0O1iO_event;
	event n0O1li_event;
	event n0O1ll_event;
	event n0O1lO_event;
	event n0O1Oi_event;
	event n0O1Ol_event;
	event n0O1OO_event;
	event n0Oi0i_event;
	event n0Oi0l_event;
	event n0Oi0O_event;
	event n0Oi1i_event;
	event n0Oi1l_event;
	event n0Oi1O_event;
	event n0Oiii_event;
	event n0Oiil_event;
	event n0OiiO_event;
	event n0Oili_event;
	event n0Oill_event;
	event n0OilO_event;
	event n0OiOi_event;
	event n0OiOl_event;
	event n0OiOO_event;
	event n0Ol0i_event;
	event n0Ol0l_event;
	event n0Ol0O_event;
	event n0Ol1i_event;
	event n0Ol1l_event;
	event n0Ol1O_event;
	event n0Olii_event;
	event n0Olil_event;
	event n0OliO_event;
	event n0Olli_event;
	event n0Olll_event;
	event n0OllO_event;
	event n0OlOi_event;
	event n0OlOl_event;
	event n0OlOO_event;
	event n0OO0i_event;
	event n0OO0l_event;
	event n0OO0O_event;
	event n0OO1i_event;
	event n0OO1l_event;
	event n0OO1O_event;
	event nl11li_event;
	initial
		#1 ->n0lOli_event;
	initial
		#1 ->n0lOll_event;
	initial
		#1 ->n0lOlO_event;
	initial
		#1 ->n0lOOi_event;
	initial
		#1 ->n0lOOl_event;
	initial
		#1 ->n0lOOO_event;
	initial
		#1 ->n0O00i_event;
	initial
		#1 ->n0O00l_event;
	initial
		#1 ->n0O00O_event;
	initial
		#1 ->n0O01i_event;
	initial
		#1 ->n0O01l_event;
	initial
		#1 ->n0O01O_event;
	initial
		#1 ->n0O0ii_event;
	initial
		#1 ->n0O0il_event;
	initial
		#1 ->n0O0iO_event;
	initial
		#1 ->n0O0li_event;
	initial
		#1 ->n0O0ll_event;
	initial
		#1 ->n0O0lO_event;
	initial
		#1 ->n0O0Oi_event;
	initial
		#1 ->n0O0Ol_event;
	initial
		#1 ->n0O0OO_event;
	initial
		#1 ->n0O10i_event;
	initial
		#1 ->n0O10l_event;
	initial
		#1 ->n0O10O_event;
	initial
		#1 ->n0O11i_event;
	initial
		#1 ->n0O11l_event;
	initial
		#1 ->n0O11O_event;
	initial
		#1 ->n0O1ii_event;
	initial
		#1 ->n0O1il_event;
	initial
		#1 ->n0O1iO_event;
	initial
		#1 ->n0O1li_event;
	initial
		#1 ->n0O1ll_event;
	initial
		#1 ->n0O1lO_event;
	initial
		#1 ->n0O1Oi_event;
	initial
		#1 ->n0O1Ol_event;
	initial
		#1 ->n0O1OO_event;
	initial
		#1 ->n0Oi0i_event;
	initial
		#1 ->n0Oi0l_event;
	initial
		#1 ->n0Oi0O_event;
	initial
		#1 ->n0Oi1i_event;
	initial
		#1 ->n0Oi1l_event;
	initial
		#1 ->n0Oi1O_event;
	initial
		#1 ->n0Oiii_event;
	initial
		#1 ->n0Oiil_event;
	initial
		#1 ->n0OiiO_event;
	initial
		#1 ->n0Oili_event;
	initial
		#1 ->n0Oill_event;
	initial
		#1 ->n0OilO_event;
	initial
		#1 ->n0OiOi_event;
	initial
		#1 ->n0OiOl_event;
	initial
		#1 ->n0OiOO_event;
	initial
		#1 ->n0Ol0i_event;
	initial
		#1 ->n0Ol0l_event;
	initial
		#1 ->n0Ol0O_event;
	initial
		#1 ->n0Ol1i_event;
	initial
		#1 ->n0Ol1l_event;
	initial
		#1 ->n0Ol1O_event;
	initial
		#1 ->n0Olii_event;
	initial
		#1 ->n0Olil_event;
	initial
		#1 ->n0OliO_event;
	initial
		#1 ->n0Olli_event;
	initial
		#1 ->n0Olll_event;
	initial
		#1 ->n0OllO_event;
	initial
		#1 ->n0OlOi_event;
	initial
		#1 ->n0OlOl_event;
	initial
		#1 ->n0OlOO_event;
	initial
		#1 ->n0OO0i_event;
	initial
		#1 ->n0OO0l_event;
	initial
		#1 ->n0OO0O_event;
	initial
		#1 ->n0OO1i_event;
	initial
		#1 ->n0OO1l_event;
	initial
		#1 ->n0OO1O_event;
	initial
		#1 ->nl11li_event;
	always @(n0lOli_event)
		n0lOli <= 1;
	always @(n0lOll_event)
		n0lOll <= 1;
	always @(n0lOlO_event)
		n0lOlO <= 1;
	always @(n0lOOi_event)
		n0lOOi <= 1;
	always @(n0lOOl_event)
		n0lOOl <= 1;
	always @(n0lOOO_event)
		n0lOOO <= 1;
	always @(n0O00i_event)
		n0O00i <= 1;
	always @(n0O00l_event)
		n0O00l <= 1;
	always @(n0O00O_event)
		n0O00O <= 1;
	always @(n0O01i_event)
		n0O01i <= 1;
	always @(n0O01l_event)
		n0O01l <= 1;
	always @(n0O01O_event)
		n0O01O <= 1;
	always @(n0O0ii_event)
		n0O0ii <= 1;
	always @(n0O0il_event)
		n0O0il <= 1;
	always @(n0O0iO_event)
		n0O0iO <= 1;
	always @(n0O0li_event)
		n0O0li <= 1;
	always @(n0O0ll_event)
		n0O0ll <= 1;
	always @(n0O0lO_event)
		n0O0lO <= 1;
	always @(n0O0Oi_event)
		n0O0Oi <= 1;
	always @(n0O0Ol_event)
		n0O0Ol <= 1;
	always @(n0O0OO_event)
		n0O0OO <= 1;
	always @(n0O10i_event)
		n0O10i <= 1;
	always @(n0O10l_event)
		n0O10l <= 1;
	always @(n0O10O_event)
		n0O10O <= 1;
	always @(n0O11i_event)
		n0O11i <= 1;
	always @(n0O11l_event)
		n0O11l <= 1;
	always @(n0O11O_event)
		n0O11O <= 1;
	always @(n0O1ii_event)
		n0O1ii <= 1;
	always @(n0O1il_event)
		n0O1il <= 1;
	always @(n0O1iO_event)
		n0O1iO <= 1;
	always @(n0O1li_event)
		n0O1li <= 1;
	always @(n0O1ll_event)
		n0O1ll <= 1;
	always @(n0O1lO_event)
		n0O1lO <= 1;
	always @(n0O1Oi_event)
		n0O1Oi <= 1;
	always @(n0O1Ol_event)
		n0O1Ol <= 1;
	always @(n0O1OO_event)
		n0O1OO <= 1;
	always @(n0Oi0i_event)
		n0Oi0i <= 1;
	always @(n0Oi0l_event)
		n0Oi0l <= 1;
	always @(n0Oi0O_event)
		n0Oi0O <= 1;
	always @(n0Oi1i_event)
		n0Oi1i <= 1;
	always @(n0Oi1l_event)
		n0Oi1l <= 1;
	always @(n0Oi1O_event)
		n0Oi1O <= 1;
	always @(n0Oiii_event)
		n0Oiii <= 1;
	always @(n0Oiil_event)
		n0Oiil <= 1;
	always @(n0OiiO_event)
		n0OiiO <= 1;
	always @(n0Oili_event)
		n0Oili <= 1;
	always @(n0Oill_event)
		n0Oill <= 1;
	always @(n0OilO_event)
		n0OilO <= 1;
	always @(n0OiOi_event)
		n0OiOi <= 1;
	always @(n0OiOl_event)
		n0OiOl <= 1;
	always @(n0OiOO_event)
		n0OiOO <= 1;
	always @(n0Ol0i_event)
		n0Ol0i <= 1;
	always @(n0Ol0l_event)
		n0Ol0l <= 1;
	always @(n0Ol0O_event)
		n0Ol0O <= 1;
	always @(n0Ol1i_event)
		n0Ol1i <= 1;
	always @(n0Ol1l_event)
		n0Ol1l <= 1;
	always @(n0Ol1O_event)
		n0Ol1O <= 1;
	always @(n0Olii_event)
		n0Olii <= 1;
	always @(n0Olil_event)
		n0Olil <= 1;
	always @(n0OliO_event)
		n0OliO <= 1;
	always @(n0Olli_event)
		n0Olli <= 1;
	always @(n0Olll_event)
		n0Olll <= 1;
	always @(n0OllO_event)
		n0OllO <= 1;
	always @(n0OlOi_event)
		n0OlOi <= 1;
	always @(n0OlOl_event)
		n0OlOl <= 1;
	always @(n0OlOO_event)
		n0OlOO <= 1;
	always @(n0OO0i_event)
		n0OO0i <= 1;
	always @(n0OO0l_event)
		n0OO0l <= 1;
	always @(n0OO0O_event)
		n0OO0O <= 1;
	always @(n0OO1i_event)
		n0OO1i <= 1;
	always @(n0OO1l_event)
		n0OO1l <= 1;
	always @(n0OO1O_event)
		n0OO1O <= 1;
	always @(nl11li_event)
		nl11li <= 1;
	initial
	begin
		n0i0i = 0;
		n0i0l = 0;
		n0i0O = 0;
		n0i1O = 0;
		n0iii = 0;
		n0iil = 0;
		n0iiO = 0;
		n0ili = 0;
		n0ill = 0;
		n0ilO = 0;
		n0iOi = 0;
		n0iOl = 0;
		n0iOO = 0;
		n0l0i = 0;
		n0l0l = 0;
		n0l0O = 0;
		n0l1i = 0;
		n0l1l = 0;
		n0l1O = 0;
		n0lii = 0;
		n0lil = 0;
		n0liO = 0;
		n0lli = 0;
		n0lll = 0;
		n0llO = 0;
		n0lOi = 0;
		n0lOl = 0;
		n0lOO = 0;
		n0O1i = 0;
		n0O1l = 0;
		n0O1O = 0;
		n11i = 0;
	end
	always @ (clk or wire_nlOOO_PRN or wire_nlOOO_CLRN)
	begin
		if (wire_nlOOO_PRN == 1'b0) 
		begin
			n0i0i <= 1;
			n0i0l <= 1;
			n0i0O <= 1;
			n0i1O <= 1;
			n0iii <= 1;
			n0iil <= 1;
			n0iiO <= 1;
			n0ili <= 1;
			n0ill <= 1;
			n0ilO <= 1;
			n0iOi <= 1;
			n0iOl <= 1;
			n0iOO <= 1;
			n0l0i <= 1;
			n0l0l <= 1;
			n0l0O <= 1;
			n0l1i <= 1;
			n0l1l <= 1;
			n0l1O <= 1;
			n0lii <= 1;
			n0lil <= 1;
			n0liO <= 1;
			n0lli <= 1;
			n0lll <= 1;
			n0llO <= 1;
			n0lOi <= 1;
			n0lOl <= 1;
			n0lOO <= 1;
			n0O1i <= 1;
			n0O1l <= 1;
			n0O1O <= 1;
			n11i <= 1;
		end
		else if  (wire_nlOOO_CLRN == 1'b0) 
		begin
			n0i0i <= 0;
			n0i0l <= 0;
			n0i0O <= 0;
			n0i1O <= 0;
			n0iii <= 0;
			n0iil <= 0;
			n0iiO <= 0;
			n0ili <= 0;
			n0ill <= 0;
			n0ilO <= 0;
			n0iOi <= 0;
			n0iOl <= 0;
			n0iOO <= 0;
			n0l0i <= 0;
			n0l0l <= 0;
			n0l0O <= 0;
			n0l1i <= 0;
			n0l1l <= 0;
			n0l1O <= 0;
			n0lii <= 0;
			n0lil <= 0;
			n0liO <= 0;
			n0lli <= 0;
			n0lll <= 0;
			n0llO <= 0;
			n0lOi <= 0;
			n0lOl <= 0;
			n0lOO <= 0;
			n0O1i <= 0;
			n0O1l <= 0;
			n0O1O <= 0;
			n11i <= 0;
		end
		else if  (n0lO0i == 1'b1) 
		if (clk != nlOOO_clk_prev && clk == 1'b1) 
		begin
			n0i0i <= wire_n0O0O_dataout;
			n0i0l <= wire_n0Oii_dataout;
			n0i0O <= wire_n0Oil_dataout;
			n0i1O <= wire_n0O0l_dataout;
			n0iii <= wire_n0OiO_dataout;
			n0iil <= wire_n0Oli_dataout;
			n0iiO <= wire_n0Oll_dataout;
			n0ili <= wire_n0OlO_dataout;
			n0ill <= wire_n0OOi_dataout;
			n0ilO <= wire_n0OOl_dataout;
			n0iOi <= wire_n0OOO_dataout;
			n0iOl <= wire_ni11i_dataout;
			n0iOO <= wire_ni11l_dataout;
			n0l0i <= wire_ni10O_dataout;
			n0l0l <= wire_ni1ii_dataout;
			n0l0O <= wire_ni1il_dataout;
			n0l1i <= wire_ni11O_dataout;
			n0l1l <= wire_ni10i_dataout;
			n0l1O <= wire_ni10l_dataout;
			n0lii <= wire_ni1iO_dataout;
			n0lil <= wire_ni1li_dataout;
			n0liO <= wire_ni1ll_dataout;
			n0lli <= wire_ni1lO_dataout;
			n0lll <= wire_ni1Oi_dataout;
			n0llO <= wire_ni1Ol_dataout;
			n0lOi <= wire_ni1OO_dataout;
			n0lOl <= wire_ni01i_dataout;
			n0lOO <= wire_ni01l_dataout;
			n0O1i <= wire_ni01O_dataout;
			n0O1l <= wire_ni00i_dataout;
			n0O1O <= wire_ni00l_dataout;
			n11i <= wire_n0O0i_dataout;
		end
		nlOOO_clk_prev <= clk;
	end
	assign
		wire_nlOOO_CLRN = ((nlO0i0i2 ^ nlO0i0i1) & reset_n),
		wire_nlOOO_PRN = (nlO0i1O4 ^ nlO0i1O3);
	event n0i0i_event;
	event n0i0l_event;
	event n0i0O_event;
	event n0i1O_event;
	event n0iii_event;
	event n0iil_event;
	event n0iiO_event;
	event n0ili_event;
	event n0ill_event;
	event n0ilO_event;
	event n0iOi_event;
	event n0iOl_event;
	event n0iOO_event;
	event n0l0i_event;
	event n0l0l_event;
	event n0l0O_event;
	event n0l1i_event;
	event n0l1l_event;
	event n0l1O_event;
	event n0lii_event;
	event n0lil_event;
	event n0liO_event;
	event n0lli_event;
	event n0lll_event;
	event n0llO_event;
	event n0lOi_event;
	event n0lOl_event;
	event n0lOO_event;
	event n0O1i_event;
	event n0O1l_event;
	event n0O1O_event;
	event n11i_event;
	initial
		#1 ->n0i0i_event;
	initial
		#1 ->n0i0l_event;
	initial
		#1 ->n0i0O_event;
	initial
		#1 ->n0i1O_event;
	initial
		#1 ->n0iii_event;
	initial
		#1 ->n0iil_event;
	initial
		#1 ->n0iiO_event;
	initial
		#1 ->n0ili_event;
	initial
		#1 ->n0ill_event;
	initial
		#1 ->n0ilO_event;
	initial
		#1 ->n0iOi_event;
	initial
		#1 ->n0iOl_event;
	initial
		#1 ->n0iOO_event;
	initial
		#1 ->n0l0i_event;
	initial
		#1 ->n0l0l_event;
	initial
		#1 ->n0l0O_event;
	initial
		#1 ->n0l1i_event;
	initial
		#1 ->n0l1l_event;
	initial
		#1 ->n0l1O_event;
	initial
		#1 ->n0lii_event;
	initial
		#1 ->n0lil_event;
	initial
		#1 ->n0liO_event;
	initial
		#1 ->n0lli_event;
	initial
		#1 ->n0lll_event;
	initial
		#1 ->n0llO_event;
	initial
		#1 ->n0lOi_event;
	initial
		#1 ->n0lOl_event;
	initial
		#1 ->n0lOO_event;
	initial
		#1 ->n0O1i_event;
	initial
		#1 ->n0O1l_event;
	initial
		#1 ->n0O1O_event;
	initial
		#1 ->n11i_event;
	always @(n0i0i_event)
		n0i0i <= 1;
	always @(n0i0l_event)
		n0i0l <= 1;
	always @(n0i0O_event)
		n0i0O <= 1;
	always @(n0i1O_event)
		n0i1O <= 1;
	always @(n0iii_event)
		n0iii <= 1;
	always @(n0iil_event)
		n0iil <= 1;
	always @(n0iiO_event)
		n0iiO <= 1;
	always @(n0ili_event)
		n0ili <= 1;
	always @(n0ill_event)
		n0ill <= 1;
	always @(n0ilO_event)
		n0ilO <= 1;
	always @(n0iOi_event)
		n0iOi <= 1;
	always @(n0iOl_event)
		n0iOl <= 1;
	always @(n0iOO_event)
		n0iOO <= 1;
	always @(n0l0i_event)
		n0l0i <= 1;
	always @(n0l0l_event)
		n0l0l <= 1;
	always @(n0l0O_event)
		n0l0O <= 1;
	always @(n0l1i_event)
		n0l1i <= 1;
	always @(n0l1l_event)
		n0l1l <= 1;
	always @(n0l1O_event)
		n0l1O <= 1;
	always @(n0lii_event)
		n0lii <= 1;
	always @(n0lil_event)
		n0lil <= 1;
	always @(n0liO_event)
		n0liO <= 1;
	always @(n0lli_event)
		n0lli <= 1;
	always @(n0lll_event)
		n0lll <= 1;
	always @(n0llO_event)
		n0llO <= 1;
	always @(n0lOi_event)
		n0lOi <= 1;
	always @(n0lOl_event)
		n0lOl <= 1;
	always @(n0lOO_event)
		n0lOO <= 1;
	always @(n0O1i_event)
		n0O1i <= 1;
	always @(n0O1l_event)
		n0O1l <= 1;
	always @(n0O1O_event)
		n0O1O <= 1;
	always @(n11i_event)
		n11i <= 1;
	and(wire_n0O0i_dataout, nlO1O1l, ~(n0lO0l));
	and(wire_n0O0l_dataout, nlO1O1i, ~(n0lO0l));
	and(wire_n0O0O_dataout, nlO1lOO, ~(n0lO0l));
	and(wire_n0Oii_dataout, nlO1lOi, ~(n0lO0l));
	and(wire_n0Oil_dataout, nlO1llO, ~(n0lO0l));
	and(wire_n0OiO_dataout, nlO1lll, ~(n0lO0l));
	and(wire_n0Oli_dataout, nlO1lli, ~(n0lO0l));
	and(wire_n0Oll_dataout, nlO1lil, ~(n0lO0l));
	and(wire_n0OlO_dataout, nlO1lii, ~(n0lO0l));
	and(wire_n0OOi_dataout, nlO1l0l, ~(n0lO0l));
	and(wire_n0OOl_dataout, nlO1l0i, ~(n0lO0l));
	and(wire_n0OOO_dataout, nlO1l1l, ~(n0lO0l));
	and(wire_ni00i_dataout, nlO10Oi, ~(n0lO0l));
	and(wire_ni00l_dataout, nlO10lO, ~(n0lO0l));
	and(wire_ni01i_dataout, nlO1i1i, ~(n0lO0l));
	and(wire_ni01l_dataout, nlO10OO, ~(n0lO0l));
	and(wire_ni01O_dataout, nlO10Ol, ~(n0lO0l));
	and(wire_ni10i_dataout, nlO1iOi, ~(n0lO0l));
	and(wire_ni10l_dataout, nlO1ilO, ~(n0lO0l));
	and(wire_ni10O_dataout, nlO1ill, ~(n0lO0l));
	and(wire_ni11i_dataout, nlO1l1i, ~(n0lO0l));
	and(wire_ni11l_dataout, nlO1iOO, ~(n0lO0l));
	and(wire_ni11O_dataout, nlO1iOl, ~(n0lO0l));
	and(wire_ni1ii_dataout, nlO1ili, ~(n0lO0l));
	and(wire_ni1il_dataout, nlO1iiO, ~(n0lO0l));
	and(wire_ni1iO_dataout, nlO1iil, ~(n0lO0l));
	and(wire_ni1li_dataout, nlO1iii, ~(n0lO0l));
	and(wire_ni1ll_dataout, nlO1i0O, ~(n0lO0l));
	and(wire_ni1lO_dataout, nlO1i0l, ~(n0lO0l));
	and(wire_ni1Oi_dataout, nlO1i0i, ~(n0lO0l));
	and(wire_ni1Ol_dataout, nlO1i1O, ~(n0lO0l));
	and(wire_ni1OO_dataout, nlO1i1l, ~(n0lO0l));
	and(wire_nl00i_dataout, ((((nl100O ^ nl11Oi) ^ nl1iii) ^ nl1iOl) ^ nl1lli), ~(n0lOiO));
	and(wire_nl00l_dataout, ((nl10il ^ nl11lO) ^ nl1lll), ~(n0lOiO));
	and(wire_nl00O_dataout, ((nlO1O1O ^ nl1i1O) ^ nl1llO), ~(n0lOiO));
	and(wire_nl01i_dataout, ((nl100l ^ nl101O) ^ nl1lii), ~(n0lOiO));
	and(wire_nl01l_dataout, (((nl10ll ^ nl101O) ^ nl1iiO) ^ nl1lil), ~(n0lOiO));
	and(wire_nl01O_dataout, (((nl10il ^ nl11Ol) ^ nl1i1l) ^ nl1liO), ~(n0lOiO));
	and(wire_nl0ii_dataout, ((nl10ii ^ nl101O) ^ nl1lOi), ~(n0lOiO));
	and(wire_nl0il_dataout, ((nlO1O1O ^ nl1i0l) ^ nl1lOl), ~(n0lOiO));
	and(wire_nl0iO_dataout, (((nl100O ^ nl101i) ^ nl10Oi) ^ nl1lOO), ~(n0lOiO));
	and(wire_nl0li_dataout, (((nl1i0i ^ nl101l) ^ nl1iiO) ^ nl1O1i), ~(n0lOiO));
	and(wire_nl0ll_dataout, (nl1O1l ^ nl1iil), ~(n0lOiO));
	and(wire_nl0lO_dataout, ((((nl10Ol ^ nl101l) ^ (~ (nlO1O0O42 ^ nlO1O0O41))) ^ nl1O1O) ^ (~ (nlO1O0i44 ^ nlO1O0i43))), ~(n0lOiO));
	and(wire_nl0Oi_dataout, ((((nl10iO ^ nl11lO) ^ (~ (nlO1Oli38 ^ nlO1Oli37))) ^ nl1O0i) ^ (~ (nlO1Oil40 ^ nlO1Oil39))), ~(n0lOiO));
	and(wire_nl0Ol_dataout, (((nl1i1i ^ nl101l) ^ (~ (nlO1OlO36 ^ nlO1OlO35))) ^ nl1O0l), ~(n0lOiO));
	and(wire_nl0OO_dataout, ((nl1i1i ^ nl10li) ^ nl1O0O), ~(n0lOiO));
	and(wire_nl1li_dataout, (((nl10ll ^ nl11OO) ^ nl1iOi) ^ nl1l1i), ~(n0lOiO));
	and(wire_nl1ll_dataout, ((((nl1i1i ^ nl100O) ^ nl1iiO) ^ nl1ili) ^ nl1l1l), ~(n0lOiO));
	and(wire_nl1lO_dataout, ((nl10Ol ^ nl11Ol) ^ nl1l1O), ~(n0lOiO));
	and(wire_nl1Oi_dataout, ((nl1i0O ^ nl10OO) ^ nl1l0i), ~(n0lOiO));
	and(wire_nl1Ol_dataout, (((nl10li ^ nl11OO) ^ nl1i0i) ^ nl1l0l), ~(n0lOiO));
	and(wire_nl1OO_dataout, (((nl100O ^ nl11OO) ^ nl1i0O) ^ nl1l0O), ~(n0lOiO));
	and(wire_nli0i_dataout, ((((nl10li ^ nl11Oi) ^ nl1ilO) ^ nl1Oli) ^ (~ (nlO01ii26 ^ nlO01ii25))), ~(n0lOiO));
	and(wire_nli0l_dataout, ((((nl1i0i ^ nl100i) ^ (~ (nlO01ll22 ^ nlO01ll21))) ^ nl1Oll) ^ (~ (nlO01iO24 ^ nlO01iO23))), ~(n0lOiO));
	and(wire_nli0O_dataout, ((nl10li ^ nl101l) ^ nl1OlO), ~(n0lOiO));
	and(wire_nli1i_dataout, (((nl10iO ^ nl100i) ^ nl1Oii) ^ (~ (nlO1OOl34 ^ nlO1OOl33))), ~(n0lOiO));
	and(wire_nli1l_dataout, ((((nl100l ^ nl11Ol) ^ nl10Oi) ^ nl1Oil) ^ (~ (nlO011i32 ^ nlO011i31))), ~(n0lOiO));
	and(wire_nli1O_dataout, ((((nl100l ^ nl11lO) ^ (~ (nlO010l28 ^ nlO010l27))) ^ nl1OiO) ^ (~ (nlO011O30 ^ nlO011O29))), ~(n0lOiO));
	and(wire_nliii_dataout, (((nl10ii ^ nl11ll) ^ nl1ill) ^ nl1OOi), ~(n0lOiO));
	and(wire_nliil_dataout, (((nl10lO ^ nl11OO) ^ nl1OOl) ^ (~ (nlO01Oi20 ^ nlO01Oi19))), ~(n0lOiO));
	and(wire_nliiO_dataout, ((((((nl1iii ^ nl11Ol) ^ (~ (nlO000i14 ^ nlO000i13))) ^ nl1iOO) ^ (~ (nlO001l16 ^ nlO001l15))) ^ nl1OOO) ^ (~ (nlO01OO18 ^ nlO01OO17))), ~(n0lOiO));
	and(wire_nlili_dataout, ((((nl10ll ^ nl100i) ^ (~ (nlO00il10 ^ nlO00il9))) ^ nl011i) ^ (~ (nlO000O12 ^ nlO000O11))), ~(n0lOiO));
	and(wire_nlill_dataout, (n1l1O ^ (((nl10Ol ^ nl11Oi) ^ nl1ili) ^ (~ (nlO00li8 ^ nlO00li7)))), ~(n0lOiO));
	or(wire_nlilO_dataout, n11i, nlO00lO);
	or(wire_nliOi_dataout, n0i1O, nlO00lO);
	or(wire_nliOl_dataout, n0i0i, nlO00lO);
	and(wire_nliOO_dataout, n0i0l, ~(nlO00lO));
	or(wire_nll0i_dataout, n0iiO, nlO00lO);
	or(wire_nll0l_dataout, n0ili, nlO00lO);
	or(wire_nll0O_dataout, n0ill, nlO00lO);
	or(wire_nll1i_dataout, n0i0O, nlO00lO);
	or(wire_nll1l_dataout, n0iii, nlO00lO);
	or(wire_nll1O_dataout, n0iil, nlO00lO);
	or(wire_nllii_dataout, n0ilO, nlO00lO);
	and(wire_nllil_dataout, n0iOi, ~(nlO00lO));
	and(wire_nlliO_dataout, n0iOl, ~(nlO00lO));
	or(wire_nllli_dataout, n0iOO, nlO00lO);
	and(wire_nllll_dataout, n0l1i, ~(nlO00lO));
	and(wire_nlllO_dataout, n0l1l, ~(nlO00lO));
	or(wire_nllOi_dataout, n0l1O, nlO00lO);
	or(wire_nllOl_dataout, n0l0i, nlO00lO);
	and(wire_nllOO_dataout, n0l0l, ~(nlO00lO));
	and(wire_nlO0i_dataout, n0liO, ~(nlO00lO));
	and(wire_nlO0l_dataout, n0lli, ~(nlO00lO));
	and(wire_nlO0lll_dataout, nlO0OOi, wire_nlOl1ll_o[0]);
	and(wire_nlO0llO_dataout, nlO0Oll, wire_nlOl1ll_o[0]);
	and(wire_nlO0lOi_dataout, nlO0OiO, wire_nlOl1ll_o[0]);
	and(wire_nlO0lOO_dataout, nlO0Oii, wire_nlOl1ll_o[0]);
	or(wire_nlO0O_dataout, n0lll, nlO00lO);
	and(wire_nlO0O0i_dataout, nlO0O1O, wire_nlOl1ll_o[0]);
	and(wire_nlO0O0O_dataout, nlO0O1i, wire_nlOl1ll_o[0]);
	and(wire_nlO0O1l_dataout, nlO0O0l, wire_nlOl1ll_o[0]);
	and(wire_nlO0Oil_dataout, nlO0lOl, wire_nlOl1ll_o[0]);
	and(wire_nlO0Oli_dataout, nlOi1Ol, wire_nlOiOiO_o[0]);
	and(wire_nlO0OlO_dataout, nlOi1lO, wire_nlOiOiO_o[0]);
	and(wire_nlO0OOl_dataout, nlOi1li, wire_nlOiOiO_o[0]);
	or(wire_nlO1i_dataout, n0l0O, nlO00lO);
	and(wire_nlO1l_dataout, n0lii, ~(nlO00lO));
	and(wire_nlO1O_dataout, n0lil, ~(nlO00lO));
	and(wire_nlOi00i_dataout, nlOi0ii, nllOO1l);
	and(wire_nlOi00O_dataout, nlOi00l, nllOO1l);
	and(wire_nlOi01l_dataout, nlOi0iO, nllOO1l);
	and(wire_nlOi0il_dataout, nlOi01O, nllOO1l);
	and(wire_nlOi0li_dataout, nlOi01i, nllOO1l);
	and(wire_nlOi0Oi_dataout, nlOilll, ~(nlO0iii));
	and(wire_nlOi0Ol_dataout, nlOiliO, ~(nlO0iii));
	and(wire_nlOi0OO_dataout, nlOil0O, ~(nlO0iii));
	and(wire_nlOi10l_dataout, nlOi10i, wire_nlOiOiO_o[0]);
	and(wire_nlOi11i_dataout, nlOi1il, wire_nlOiOiO_o[0]);
	and(wire_nlOi11O_dataout, nlOi10O, wire_nlOiOiO_o[0]);
	and(wire_nlOi1ii_dataout, nlOi11l, wire_nlOiOiO_o[0]);
	and(wire_nlOi1iO_dataout, nlO0OOO, wire_nlOiOiO_o[0]);
	and(wire_nlOi1ll_dataout, nlOiiiO, nllOO1l);
	and(wire_nlOi1Oi_dataout, nlOiiii, nllOO1l);
	and(wire_nlOi1OO_dataout, nlOi0lO, nllOO1l);
	and(wire_nlOii_dataout, n0llO, ~(nlO00lO));
	and(wire_nlOii0i_dataout, nlOiiOi, ~(nlO0iii));
	and(wire_nlOii0l_dataout, nlOiill, ~(nlO0iii));
	and(wire_nlOii0O_dataout, nlOiOOi, ~(nllOO1O));
	and(wire_nlOii1i_dataout, nlOil0i, ~(nlO0iii));
	and(wire_nlOii1l_dataout, nlOil1l, ~(nlO0iii));
	and(wire_nlOii1O_dataout, nlOiiOO, ~(nlO0iii));
	and(wire_nlOiiil_dataout, nlOiOll, ~(nllOO1O));
	and(wire_nlOiili_dataout, nlOiOil, ~(nllOO1O));
	and(wire_nlOiilO_dataout, nlOiO0O, ~(nllOO1O));
	and(wire_nlOiiOl_dataout, nlOiO0i, ~(nllOO1O));
	or(wire_nlOil_dataout, n0lOi, nlO00lO);
	and(wire_nlOil0l_dataout, nlOilOi, ~(nllOO1O));
	and(wire_nlOil1i_dataout, nlOiO1l, ~(nllOO1O));
	and(wire_nlOil1O_dataout, nlOilOO, ~(nllOO1O));
	and(wire_nlOilil_dataout, nlOl1Oi, ~(wire_nlOiOiO_o[3]));
	and(wire_nlOilli_dataout, nlOl1lO, ~(wire_nlOiOiO_o[3]));
	and(wire_nlOillO_dataout, nlOl1li, ~(wire_nlOiOiO_o[3]));
	and(wire_nlOilOl_dataout, nlOl1il, ~(wire_nlOiOiO_o[3]));
	and(wire_nlOiO_dataout, n0lOl, ~(nlO00lO));
	and(wire_nlOiO0l_dataout, nlOl11l, ~(wire_nlOiOiO_o[3]));
	and(wire_nlOiO1i_dataout, nlOl10O, ~(wire_nlOiOiO_o[3]));
	and(wire_nlOiO1O_dataout, nlOl10i, ~(wire_nlOiOiO_o[3]));
	and(wire_nlOiOii_dataout, nlOiOOO, ~(wire_nlOiOiO_o[3]));
	and(wire_nlOiOli_dataout, nlO0l0i, ~(wire_nlOl1ll_o[7]));
	and(wire_nlOiOlO_dataout, nlO0l0l, ~(wire_nlOl1ll_o[7]));
	and(wire_nlOiOOl_dataout, nlO0l0O, ~(wire_nlOl1ll_o[7]));
	and(wire_nlOl10l_dataout, nlO0liO, ~(wire_nlOl1ll_o[7]));
	and(wire_nlOl11i_dataout, nlO0lii, ~(wire_nlOl1ll_o[7]));
	and(wire_nlOl11O_dataout, nlO0lil, ~(wire_nlOl1ll_o[7]));
	and(wire_nlOl1ii_dataout, nlO0lli, ~(wire_nlOl1ll_o[7]));
	and(wire_nlOl1iO_dataout, nlOl1Ol, ~(wire_nlOl1ll_o[7]));
	or(wire_nlOli_dataout, n0lOO, nlO00lO);
	or(wire_nlOll_dataout, n0O1i, nlO00lO);
	or(wire_nlOlO_dataout, n0O1l, nlO00lO);
	or(wire_nlOOi_dataout, n0O1O, nlO00lO);
	oper_decoder   n001O
	( 
	.i({n0lO0O, n0lOil}),
	.o(wire_n001O_o));
	defparam
		n001O.width_i = 2,
		n001O.width_o = 4;
	oper_decoder   n00ll
	( 
	.i({n0lO0O, n0lOii}),
	.o(wire_n00ll_o));
	defparam
		n00ll.width_i = 2,
		n00ll.width_o = 4;
	oper_decoder   n00Oi
	( 
	.i({n0lOii, n0lOil}),
	.o(wire_n00Oi_o));
	defparam
		n00Oi.width_i = 2,
		n00Oi.width_o = 4;
	oper_decoder   n0i1l
	( 
	.i({n0lO0O, n0lOii, n0lOil}),
	.o(wire_n0i1l_o));
	defparam
		n0i1l.width_i = 3,
		n0i1l.width_o = 8;
	oper_decoder   nlOiOiO
	( 
	.i({nlO0iii, nlO0iil}),
	.o(wire_nlOiOiO_o));
	defparam
		nlOiOiO.width_i = 2,
		nlOiOiO.width_o = 4;
	oper_decoder   nlOl1ll
	( 
	.i({nlO0iii, nlO0iil, nlO0iiO}),
	.o(wire_nlOl1ll_o));
	defparam
		nlOl1ll.width_i = 3,
		nlOl1ll.width_o = 8;
	assign
		crcbad = n01iO,
		crcvalid = n01ii,
		nllOO0i = (wire_nlOii0l_dataout ^ wire_nlOi1OO_dataout),
		nllOO0l = (wire_nlO0O0O_dataout ^ wire_nlO0llO_dataout),
		nllOO0O = (wire_nlO0Oli_dataout ^ wire_nlO0O0i_dataout),
		nllOO1l = ((wire_nlOl1ll_o[2] | wire_nlOl1ll_o[1]) | wire_nlOl1ll_o[0]),
		nllOO1O = ((wire_nlOl1ll_o[7] | wire_nlOl1ll_o[6]) | wire_nlOl1ll_o[5]),
		nllOOii = (wire_nlO0O0O_dataout ^ wire_nlO0lOO_dataout),
		nllOOil = (wire_nlO0O1l_dataout ^ wire_nlO0lOO_dataout),
		nllOOiO = (wire_nlOi0Oi_dataout ^ wire_nlOi11i_dataout),
		nllOOli = (wire_nlOi1ii_dataout ^ wire_nlO0Oli_dataout),
		nllOOll = (wire_nlO0OlO_dataout ^ wire_nlO0O0O_dataout),
		nllOOlO = (wire_nlOi11i_dataout ^ wire_nlO0lll_dataout),
		nllOOOi = (wire_nll1i_dataout ^ wire_nliOl_dataout),
		nllOOOl = (wire_nll1l_dataout ^ wire_nlilO_dataout),
		nllOOOO = (wire_nll0O_dataout ^ wire_nll1l_dataout),
		nlO00lO = (((~ reset_n) | n0lO0l) | (~ (nlO00Oi6 ^ nlO00Oi5))),
		nlO0i1i = 1'b1,
		nlO100i = (nlO1lOO ^ nlO1lOi),
		nlO101i = (nlO1l0l ^ nlO1l0i),
		nlO101l = (nlO1O1i ^ nlO1lOO),
		nlO101O = (nlO1lll ^ nlO1lli),
		nlO10ii = ((((((((((((((((((((((((((((((((wire_nl00O_dataout ^ nlO1l1l) & (~ ((wire_nl1li_dataout ^ nlO1O1l) ^ ((wire_n0i1l_o[4] | wire_n0i1l_o[7]) | wire_n0i1l_o[0])))) & (~ ((wire_nl1ll_dataout ^ nlO1O1i) ^ nlO10il))) & (~ ((wire_nl1lO_dataout ^ nlO1lOO) ^ wire_n001O_o[1]))) & (~ ((wire_nl1Oi_dataout ^ nlO1lOi) ^ (~ wire_n00ll_o[1])))) & (~ ((wire_nl1Ol_dataout ^ nlO1llO) ^ (~ wire_n00Oi_o[3])))) & (~ ((wire_nl1OO_dataout ^ nlO1lll) ^ (((wire_n0i1l_o[2] | wire_n0i1l_o[7]) | wire_n0i1l_o[0]) | wire_n0i1l_o[6])))) & (~ ((wire_nl01i_dataout ^ nlO1lli) ^ (~ (((wire_n0i1l_o[1] | wire_n0i1l_o[7]) | wire_n0i1l_o[5]) | wire_n0i1l_o[6]))))) & (~ ((wire_nl01l_dataout ^ nlO1lil) ^ wire_n00Oi_o[1]))) & (~ ((wire_nl01O_dataout ^ nlO1lii) ^ (~ nlO10iO)))) & (~ ((wire_nl00i_dataout ^ nlO1l0l) ^ (~ nlO10il)))) & (~ ((wire_nl00l_dataout ^ nlO1l0i) ^ (~ ((wire_n0i1l_o[4] | wire_n0i1l_o[1]) | wire_n0i1l_o[3]))))) & (~ ((wire_nl0ii_dataout ^ nlO1l1i) ^ (~ ((wire_n0i1l_o[5] | wire_n0i1l_o[6]) | wire_n0i1l_o[3]))))) & (~ ((wire_nl0il_dataout ^ nlO1iOO) ^ (~ ((wire_n0i1l_o[7] | wire_n0i1l_o[0]) | wire_n0i1l_o[3]))))) & (~ ((wire_nl0iO_dataout ^ nlO1iOl) ^ ((wire_n0i1l_o[0] | wire_n0i1l_o[5]) | wire_n0i1l_o[3])))) & (~ ((wire_nl0li_dataout ^ nlO1iOi) ^ (~ wire_n001O_o[3])))) & (~ ((wire_nl0ll_dataout ^ nlO1ilO) ^ nlO10li))) & (~ ((wire_nl0lO_dataout ^ nlO1ill) ^ nlO10ll))) & (~ ((wire_nl0Oi_dataout ^ nlO1ili) ^ (~ (((wire_n0i1l_o[2] | wire_n0i1l_o[1]) | wire_n0i1l_o[7]) | wire_n0i1l_o[6]))))) & (~ ((wire_nl0Ol_dataout ^ nlO1iiO) ^ wire_n00Oi_o[2]))) & (~ ((wire_nl0OO_dataout ^ nlO1iil) ^ (((wire_n0i1l_o[2] | wire_n0i1l_o[1]) | wire_n0i1l_o[7]) | wire_n0i1l_o[5])))) & (~ ((wire_nli1i_dataout ^ nlO1iii) ^ nlO10iO))) & (~ ((wire_nli1l_dataout ^ nlO1i0O) ^ (((wire_n0i1l_o[2] | wire_n0i1l_o[7]) | wire_n0i1l_o[5]) | wire_n0i1l_o[6])))) & (~ ((wire_nli1O_dataout ^ nlO1i0l) ^ nlO10li))) & (~ ((wire_nli0i_dataout ^ nlO1i0i) ^ (~ nlO10ll)))) & (~ ((wire_nli0l_dataout ^ nlO1i1O) ^ (~ (((wire_n0i1l_o[4] | wire_n0i1l_o[7]) | wire_n0i1l_o[6]) | wire_n0i1l_o[3]
))))) & (~ ((wire_nli0O_dataout ^ nlO1i1l) ^ wire_n00ll_o[0]))) & (~ ((wire_nliii_dataout ^ nlO1i1i) ^ (((wire_n0i1l_o[4] | wire_n0i1l_o[2]) | wire_n0i1l_o[7]) | wire_n0i1l_o[5])))) & (~ ((wire_nliil_dataout ^ nlO10OO) ^ wire_n00Oi_o[2]))) & (~ ((wire_nliiO_dataout ^ nlO10Ol) ^ (wire_n0i1l_o[4] | wire_n0i1l_o[2])))) & (~ ((wire_nlili_dataout ^ nlO10Oi) ^ (((wire_n0i1l_o[4] | wire_n0i1l_o[1]) | wire_n0i1l_o[7]) | wire_n0i1l_o[0])))) & (~ ((wire_nlill_dataout ^ nlO10lO) ^ (~ ((wire_n0i1l_o[4] | wire_n0i1l_o[2]) | wire_n0i1l_o[1]))))),
		nlO10il = ((wire_n0i1l_o[2] | wire_n0i1l_o[0]) | wire_n0i1l_o[3]),
		nlO10iO = ((wire_n0i1l_o[2] | wire_n0i1l_o[7]) | wire_n0i1l_o[6]),
		nlO10li = (wire_n0i1l_o[5] | wire_n0i1l_o[6]),
		nlO10ll = ((wire_n0i1l_o[2] | wire_n0i1l_o[7]) | wire_n0i1l_o[5]),
		nlO10lO = ((n0lO1O ^ (((((nlOl0Ol ^ nlOl0li) ^ nlOliOi) ^ nlOllli) ^ nlOlOlO) ^ nlOO0li)) ^ (nl11li ^ ((n0O1ll ^ n0lOli) ^ n0O0il))),
		nlO10Oi = ((((((nlOli0l ^ nlOl0il) ^ nlOliiO) ^ nlOlliO) ^ nlOO0ii) ^ nlOOlll) ^ ((((n0O00i ^ n0O11l) ^ n0O0ll) ^ n0Oi0i) ^ n0OO0O)),
		nlO10Ol = ((((((nlOliil ^ nlOl0ll) ^ nlOliOO) ^ nlOlOOO) ^ nlOO01l) ^ nlOOlli) ^ (((n0O01O ^ n0lOll) ^ n0O00O) ^ n0OO0l)),
		nlO10OO = ((((((nlOli1O ^ nlOl1OO) ^ nlOll1l) ^ nlOllOi) ^ nlOlO1l) ^ nlOOliO) ^ (((n0O1il ^ n0lOOi) ^ n0O0iO) ^ n0OO0i)),
		nlO110i = (wire_nll0i_dataout ^ wire_nliOl_dataout),
		nlO110l = (wire_nliOO_dataout ^ wire_nlilO_dataout),
		nlO110O = (wire_nliOO_dataout ^ wire_nliOi_dataout),
		nlO111i = (wire_nll1O_dataout ^ wire_nliOO_dataout),
		nlO111l = (wire_nll1l_dataout ^ wire_nliOO_dataout),
		nlO111O = (wire_nllli_dataout ^ wire_nll1i_dataout),
		nlO11ii = (wire_nliOl_dataout ^ wire_nlilO_dataout),
		nlO11il = (wire_nll0l_dataout ^ wire_nll1i_dataout),
		nlO11iO = ((~ reset_n) | n0lO0i),
		nlO11lO = (nlO1lll ^ nlO1l0l),
		nlO11Oi = (nlO1lOi ^ nlO1llO),
		nlO11Ol = (nlO1O1l ^ nlO1llO),
		nlO11OO = (nlO1O1l ^ nlO1O1i),
		nlO1i0i = (((((((nlOli1i ^ nlOl00l) ^ nlOliiO) ^ nlOll0l) ^ nlOlO0O) ^ nlOO1Oi) ^ nlOOl0l) ^ ((((n0O0iO ^ n0lOOO) ^ n0O0lO) ^ n0O0OO) ^ n0OlOO)),
		nlO1i0l = ((((((nlO1l1O ^ nlOlilO) ^ nlOlOll) ^ nlOO11i) ^ nlOO00i) ^ nlOOl0i) ^ ((((n0O1OO ^ n0lOli) ^ n0O0iO) ^ n0O0Ol) ^ n0OlOl)),
		nlO1i0O = (((((((nlOlili ^ nlOl0ii) ^ nlOllii) ^ nlOlO1i) ^ nlOO11O) ^ nlOO00O) ^ nlOOl1O) ^ (((n0O1Ol ^ n0O1li) ^ n0Oi1i) ^ n0OlOi)),
		nlO1i1i = (((((((nlOl0lO ^ nlOl0li) ^ nlOliOl) ^ nlOllll) ^ nlOlO0l) ^ nlOO1Oi) ^ nlOOlil) ^ (((n0O10i ^ n0O11O) ^ n0O01l) ^ n0OO1O)),
		nlO1i1l = (((((((nlOli1l ^ nlOl00O) ^ nlOlili) ^ nlOllOi) ^ nlOlOiO) ^ nlOO11i) ^ nlOOlii) ^ (((n0O1lO ^ n0lOOl) ^ n0O01i) ^ n0OO1l)),
		nlO1i1O = (((((((nlOli1l ^ nlOl0il) ^ nlOlilO) ^ nlOllli) ^ nlOllOO) ^ nlOO01O) ^ nlOOl0O) ^ (((n0O1Ol ^ n0O1lO) ^ n0O00l) ^ n0OO1i)),
		nlO1iii = (((((nlOli0O ^ nlOl01O) ^ nlOlliO) ^ nlOllOO) ^ nlOOl1l) ^ (((n0O10l ^ n0lOOi) ^ n0Oi1i) ^ n0OllO)),
		nlO1iil = ((((nlOl0OO ^ nlOl0ii) ^ nlOlO0i) ^ nlOOl1i) ^ ((nlO1liO ^ n0O1Ol) ^ n0Olll)),
		nlO1iiO = (((((nlOl0Oi ^ nlOl0li) ^ nlOlill) ^ nlOll0l) ^ nlOOiOO) ^ (((n0O00i ^ n0O1lO) ^ n0O0lO) ^ n0Olli)),
		nlO1ili = ((((((nlOlili ^ nlOl0il) ^ nlOlllO) ^ nlOlO0i) ^ nlOlOii) ^ nlOOiOl) ^ (((nlO1l0O ^ n0O1OO) ^ n0Oi1l) ^ n0OliO)),
		nlO1ill = ((((((nlOli1l ^ nlOl01l) ^ nlOliOi) ^ nlOllil) ^ nlOlOli) ^ nlOOiOi) ^ ((n0O1iO ^ n0O11O) ^ n0Olil)),
		nlO1ilO = (((((((nlOli0i ^ nlOl01l) ^ nlOliOl) ^ nlOllOi) ^ nlOlOOl) ^ nlOO1Ol) ^ nlOOilO) ^ ((((n0O10O ^ n0lOOl) ^ n0O0il) ^ n0Oi1l) ^ n0Olii)),
		nlO1iOi = ((((((nlOlill ^ nlOl0ii) ^ nlOlliO) ^ nlOlOil) ^ nlOO11l) ^ nlOOill) ^ ((n0O1li ^ n0lOll) ^ n0Ol0O)),
		nlO1iOl = ((((((nlOliil ^ nlOl0iO) ^ nlOliOl) ^ nlOlllO) ^ nlOlOOi) ^ nlOOili) ^ ((n0O1Oi ^ n0lOOl) ^ n0Ol0l)),
		nlO1iOO = ((((((nlOli0l ^ nlOl01i) ^ nlOll1l) ^ nlOlO1O) ^ nlOO10l) ^ nlOOiiO) ^ ((((n0O1ii ^ n0O11i) ^ n0O01O) ^ n0Oi0l) ^ n0Ol0i)),
		nlO1l0i = (((((((nlOliil ^ nlOl00l) ^ nlOll1i) ^ nlOllOO) ^ nlOO10O) ^ nlOO1ll) ^ nlOOi0O) ^ ((((n0O1Oi ^ n0O1iO) ^ n0O0ii) ^ n0O0Oi) ^ n0Ol1i)),
		nlO1l0l = (((((((nlOliii ^ nlOl0ii) ^ nlOll1O) ^ nlOllll) ^ nlOlOOl) ^ nlOO1ii) ^ nlOOi0l) ^ ((nlO1l0O ^ n0O00O) ^ n0OiOO)),
		nlO1l0O = (n0O1lO ^ n0lOOi),
		nlO1l1i = ((((((((nlOl0lO ^ nlOl00i) ^ nlOlilO) ^ nlOlOlO) ^ nlOlOOO) ^ nlOO1li) ^ nlOO1OO) ^ nlOOiil) ^ ((n0O10O ^ n0lOlO) ^ n0Ol1O)),
		nlO1l1l = ((((((nlO1l1O ^ nlOliOi) ^ nlOllOl) ^ nlOO10O) ^ nlOO1li) ^ nlOOiii) ^ ((nlO1lOl ^ n0O1OO) ^ n0Ol1l)),
		nlO1l1O = (nlOli1i ^ nlOl00O),
		nlO1lii = (((((((nlOli0l ^ nlOl0iO) ^ nlOll0i) ^ nlOlO0l) ^ nlOO1lO) ^ nlOO0iO) ^ nlOOi0i) ^ ((n0O0il ^ n0lOOO) ^ n0OiOl)),
		nlO1lil = (((((((nlOli0i ^ nlOl0ll) ^ nlOlill) ^ nlOllli) ^ nlOlO0O) ^ nlOO11O) ^ nlOOi1O) ^ ((nlO1liO ^ n0O0li) ^ n0OiOi)),
		nlO1liO = (n0O10O ^ n0O11i),
		nlO1lli = ((((((nlOl0Oi ^ nlOl1OO) ^ nlOll0i) ^ nlOllli) ^ nlOlO1l) ^ nlOOi1l) ^ (((n0O00i ^ n0lOOi) ^ n0O00O) ^ n0OilO)),
		nlO1lll = ((((((((nlOli0i ^ nlOl01i) ^ nlOll1l) ^ nlOlO1i) ^ nlOlOil) ^ nlOO1li) ^ nlOO00l) ^ nlOOi1i) ^ (((n0O1ii ^ n0O11O) ^ n0Oi1O) ^ n0Oill)),
		nlO1llO = ((((((nlOli1l ^ nlOl00i) ^ nlOliOl) ^ nlOO1iO) ^ nlOO01i) ^ nlOO0OO) ^ ((n0O10i ^ n0O11l) ^ n0Oili)),
		nlO1lOi = ((((((nlOli0O ^ nlOl00l) ^ nlOll0i) ^ nlOlllO) ^ nlOlO1O) ^ nlOO0Ol) ^ ((nlO1lOl ^ n0O0ll) ^ n0OiiO)),
		nlO1lOl = (n0O1li ^ n0O11O),
		nlO1lOO = (((((((nlOl0Ol ^ nlOl01l) ^ nlOll1l) ^ nlOll0O) ^ nlOlOll) ^ nlOO0il) ^ nlOO0Oi) ^ ((n0O00l ^ n0lOlO) ^ n0Oiil)),
		nlO1O1i = ((((((nlOli1O ^ nlOl01l) ^ nlOllii) ^ nlOllOl) ^ nlOO10i) ^ nlOO0lO) ^ (((n0O1iO ^ n0lOOO) ^ n0O1Ol) ^ n0Oiii)),
		nlO1O1l = (((((((nlOl0Ol ^ nlOl0ll) ^ nlOll1O) ^ nlOllil) ^ nlOlOii) ^ nlOO1il) ^ nlOO0ll) ^ (((n0O0ii ^ n0O11l) ^ n0O0lO) ^ n0Oi0O)),
		nlO1O1O = (nl10lO ^ nl11ll);
endmodule //altpcierd_rx_ecrc_64
//synopsys translate_on
//VALID FILE
