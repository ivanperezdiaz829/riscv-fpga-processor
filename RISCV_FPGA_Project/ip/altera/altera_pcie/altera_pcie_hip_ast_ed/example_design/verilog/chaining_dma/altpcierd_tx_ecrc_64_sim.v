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

//synthesis_resources = lut 544 mux21 248 oper_decoder 2 
`timescale 1 ps / 1 ps
module  altpcierd_tx_ecrc_64
	( 
	checksum,
	clk,
	crcvalid,
	data,
	datavalid,
	empty,
	endofpacket,
	reset_n,
	startofpacket) /* synthesis synthesis_clearbox=1 */;
	output   [31:0]  checksum;
	input   clk;
	output   crcvalid;
	input   [63:0]  data;
	input   datavalid;
	input   [2:0]  empty;
	input   endofpacket;
	input   reset_n;
	input   startofpacket;

	reg	nl0i0Oi47;
	reg	nl0i0Oi48;
	reg	nl0iiiO45;
	reg	nl0iiiO46;
	reg	nl0l1li43;
	reg	nl0l1li44;
	reg	nl0liOO41;
	reg	nl0liOO42;
	reg	nl0ll0i37;
	reg	nl0ll0i38;
	reg	nl0ll0O35;
	reg	nl0ll0O36;
	reg	nl0ll1l39;
	reg	nl0ll1l40;
	reg	nl0llil33;
	reg	nl0llil34;
	reg	nl0llli31;
	reg	nl0llli32;
	reg	nl0lllO29;
	reg	nl0lllO30;
	reg	nl0llOl27;
	reg	nl0llOl28;
	reg	nl0lO0l21;
	reg	nl0lO0l22;
	reg	nl0lO1i25;
	reg	nl0lO1i26;
	reg	nl0lO1O23;
	reg	nl0lO1O24;
	reg	nl0lOii19;
	reg	nl0lOii20;
	reg	nl0lOiO17;
	reg	nl0lOiO18;
	reg	nl0lOll15;
	reg	nl0lOll16;
	reg	nl0lOOi13;
	reg	nl0lOOi14;
	reg	nl0lOOO11;
	reg	nl0lOOO12;
	reg	nl0O10i7;
	reg	nl0O10i8;
	reg	nl0O10O5;
	reg	nl0O10O6;
	reg	nl0O11l10;
	reg	nl0O11l9;
	reg	nl0O1li3;
	reg	nl0O1li4;
	reg	nl0O1OO1;
	reg	nl0O1OO2;
	reg	n0l1OO;
	reg	n1ilii;
	reg	n1ilil;
	reg	n1iliO;
	reg	n1illi;
	reg	n1illl;
	reg	n1illO;
	reg	n1ilOi;
	reg	n1ilOl;
	reg	n1ilOO;
	reg	n1iO0i;
	reg	n1iO0l;
	reg	n1iO0O;
	reg	n1iO1i;
	reg	n1iO1l;
	reg	n1iO1O;
	reg	n1iOii;
	reg	n1iOil;
	reg	n1iOiO;
	reg	n1iOli;
	reg	n1iOll;
	reg	n1iOlO;
	reg	n1iOOi;
	reg	n1iOOl;
	reg	n1iOOO;
	reg	n1l00i;
	reg	n1l00l;
	reg	n1l00O;
	reg	n1l01i;
	reg	n1l01l;
	reg	n1l01O;
	reg	n1l0ii;
	reg	n1l0il;
	reg	n1l0iO;
	reg	n1l0li;
	reg	n1l0ll;
	reg	n1l0lO;
	reg	n1l0Oi;
	reg	n1l0Ol;
	reg	n1l0OO;
	reg	n1l10i;
	reg	n1l10l;
	reg	n1l10O;
	reg	n1l11i;
	reg	n1l11l;
	reg	n1l11O;
	reg	n1l1ii;
	reg	n1l1il;
	reg	n1l1iO;
	reg	n1l1li;
	reg	n1l1ll;
	reg	n1l1lO;
	reg	n1l1Oi;
	reg	n1l1Ol;
	reg	n1l1OO;
	reg	n1li0i;
	reg	n1li0l;
	reg	n1li0O;
	reg	n1li1i;
	reg	n1li1l;
	reg	n1li1O;
	reg	n1liii;
	reg	n1liil;
	reg	n1liiO;
	reg	n1lili;
	wire	wire_n0l1Ol_CLRN;
	reg	n1il0O;
	reg	nlO0llO;
	reg	nlO0lOi;
	reg	nlO0lOl;
	reg	nlO0lOO;
	reg	nlO0O0i;
	reg	nlO0O0l;
	reg	nlO0O0O;
	reg	nlO0O1i;
	reg	nlO0O1l;
	reg	nlO0O1O;
	reg	nlO0Oii;
	reg	nlO0Oil;
	reg	nlO0OiO;
	reg	nlO0Oli;
	reg	nlO0Oll;
	reg	nlO0OlO;
	reg	nlO0OOi;
	reg	nlO0OOl;
	reg	nlO0OOO;
	reg	nlOi00i;
	reg	nlOi00l;
	reg	nlOi00O;
	reg	nlOi01i;
	reg	nlOi01l;
	reg	nlOi01O;
	reg	nlOi0ii;
	reg	nlOi0il;
	reg	nlOi0iO;
	reg	nlOi0li;
	reg	nlOi0ll;
	reg	nlOi0lO;
	reg	nlOi0Oi;
	reg	nlOi0Ol;
	reg	nlOi0OO;
	reg	nlOi10i;
	reg	nlOi10l;
	reg	nlOi10O;
	reg	nlOi11i;
	reg	nlOi11l;
	reg	nlOi11O;
	reg	nlOi1ii;
	reg	nlOi1il;
	reg	nlOi1iO;
	reg	nlOi1li;
	reg	nlOi1ll;
	reg	nlOi1lO;
	reg	nlOi1Oi;
	reg	nlOi1Ol;
	reg	nlOi1OO;
	reg	nlOii0i;
	reg	nlOii0l;
	reg	nlOii0O;
	reg	nlOii1i;
	reg	nlOii1l;
	reg	nlOii1O;
	reg	nlOiiii;
	reg	nlOiiil;
	reg	nlOiiiO;
	reg	nlOiili;
	reg	nlOiill;
	reg	nlOiilO;
	reg	nlOiiOi;
	reg	nlOiiOl;
	reg	nlOiiOO;
	reg	nlOil0i;
	reg	nlOil1i;
	reg	nlOil1l;
	reg	nlOil1O;
	wire	wire_n1il0l_CLRN;
	reg	n011i;
	reg	n0l00i;
	reg	n0l00l;
	reg	n0l00O;
	reg	n0l01i;
	reg	n0l01l;
	reg	n0l01O;
	reg	n0l0ii;
	reg	n0l0il;
	reg	n0l0iO;
	reg	n0l0li;
	reg	n0l0ll;
	reg	n0l0lO;
	reg	n0l0Oi;
	reg	n0l0Ol;
	reg	n0l0OO;
	reg	n0li0i;
	reg	n0li0l;
	reg	n0li0O;
	reg	n0li1i;
	reg	n0li1l;
	reg	n0li1O;
	reg	n0liii;
	reg	n0liil;
	reg	n0liiO;
	reg	n0lili;
	reg	n0lill;
	reg	n0lilO;
	reg	n0liOi;
	reg	n0liOl;
	reg	n0liOO;
	reg	n0ll0i;
	reg	n0ll0l;
	reg	n0ll0O;
	reg	n0ll1i;
	reg	n0ll1l;
	reg	n0ll1O;
	reg	n0llii;
	reg	n0llil;
	reg	n0lliO;
	reg	n0llli;
	reg	n0llll;
	reg	n0lllO;
	reg	n0llOi;
	reg	n0llOl;
	reg	n0llOO;
	reg	n0lO0i;
	reg	n0lO0l;
	reg	n0lO0O;
	reg	n0lO1i;
	reg	n0lO1l;
	reg	n0lO1O;
	reg	n0lOii;
	reg	n0lOil;
	reg	n0lOiO;
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
	reg	n0OOii;
	reg	n0OOil;
	reg	n0OOiO;
	reg	n0OOli;
	reg	n0OOll;
	reg	n0OOlO;
	reg	n0OOOi;
	reg	n0OOOl;
	reg	n0OOOO;
	reg	niOO1i;
	reg	nl0O00i;
	reg	nl0O00l;
	reg	nl0O00O;
	reg	nl0O01i;
	reg	nl0O01l;
	reg	nl0O01O;
	reg	nl0O0ii;
	reg	nl0O0il;
	reg	nl0O0iO;
	reg	nl0O0li;
	reg	nl0O0ll;
	reg	nl0O0lO;
	reg	nl0O0Oi;
	reg	nl0O0Ol;
	reg	nl0O0OO;
	reg	nl0Oi0i;
	reg	nl0Oi0l;
	reg	nl0Oi0O;
	reg	nl0Oi1i;
	reg	nl0Oi1l;
	reg	nl0Oi1O;
	reg	nl0Oili;
	reg	nl0OilO;
	reg	nl0OiOl;
	reg	nl0Ol0l;
	reg	nl0Ol1i;
	reg	nl0Ol1O;
	reg	nl0Olii;
	reg	nl0OliO;
	reg	nl0Olll;
	reg	nl0OlOi;
	reg	nl0OlOO;
	reg	nl0OO0i;
	reg	nl0OO0O;
	reg	nl0OO1l;
	reg	nl0OOil;
	reg	nl0OOli;
	reg	nl0OOlO;
	reg	nl0OOOl;
	reg	nli000i;
	reg	nli000l;
	reg	nli000O;
	reg	nli001i;
	reg	nli001l;
	reg	nli001O;
	reg	nli00ii;
	reg	nli00il;
	reg	nli00iO;
	reg	nli00li;
	reg	nli00ll;
	reg	nli00lO;
	reg	nli00Oi;
	reg	nli00Ol;
	reg	nli00OO;
	reg	nli010i;
	reg	nli010l;
	reg	nli010O;
	reg	nli011i;
	reg	nli011l;
	reg	nli011O;
	reg	nli01ii;
	reg	nli01il;
	reg	nli01iO;
	reg	nli01li;
	reg	nli01ll;
	reg	nli01lO;
	reg	nli01Oi;
	reg	nli01Ol;
	reg	nli01OO;
	reg	nli0i0i;
	reg	nli0i0l;
	reg	nli0i0O;
	reg	nli0i1i;
	reg	nli0i1l;
	reg	nli0i1O;
	reg	nli0iii;
	reg	nli0iil;
	reg	nli0iiO;
	reg	nli0ili;
	reg	nli0ill;
	reg	nli0ilO;
	reg	nli0iOi;
	reg	nli0iOl;
	reg	nli0iOO;
	reg	nli0l0i;
	reg	nli0l0l;
	reg	nli0l0O;
	reg	nli0l1i;
	reg	nli0l1l;
	reg	nli0l1O;
	reg	nli0lii;
	reg	nli0lil;
	reg	nli0liO;
	reg	nli0lli;
	reg	nli0lll;
	reg	nli0llO;
	reg	nli0lOi;
	reg	nli0lOl;
	reg	nli0lOO;
	reg	nli0O0i;
	reg	nli0O0l;
	reg	nli0O0O;
	reg	nli0O1i;
	reg	nli0O1l;
	reg	nli0O1O;
	reg	nli0Oii;
	reg	nli0Oil;
	reg	nli0OiO;
	reg	nli0Oli;
	reg	nli0Oll;
	reg	nli0OlO;
	reg	nli0OOi;
	reg	nli0OOl;
	reg	nli0OOO;
	reg	nli100l;
	reg	nli101O;
	reg	nli10ii;
	reg	nli10iO;
	reg	nli10ll;
	reg	nli10Oi;
	reg	nli10OO;
	reg	nli110l;
	reg	nli111i;
	reg	nli111O;
	reg	nli11il;
	reg	nli1i0l;
	reg	nli1i1l;
	reg	nli1iii;
	reg	nli1iiO;
	reg	nli1ill;
	reg	nli1iOi;
	reg	nli1iOO;
	reg	nli1l0i;
	reg	nli1l1l;
	reg	nli1lii;
	reg	nli1liO;
	reg	nli1lll;
	reg	nli1lOi;
	reg	nli1lOO;
	reg	nli1O0i;
	reg	nli1O0O;
	reg	nli1O1l;
	reg	nli1Oil;
	reg	nli1OiO;
	reg	nli1Oli;
	reg	nli1Oll;
	reg	nli1OlO;
	reg	nli1OOi;
	reg	nli1OOl;
	reg	nli1OOO;
	reg	nlii00i;
	reg	nlii00l;
	reg	nlii00O;
	reg	nlii01i;
	reg	nlii01l;
	reg	nlii01O;
	reg	nlii0ii;
	reg	nlii0il;
	reg	nlii0iO;
	reg	nlii0li;
	reg	nlii0ll;
	reg	nlii0lO;
	reg	nlii0Oi;
	reg	nlii0Ol;
	reg	nlii0OO;
	reg	nlii10i;
	reg	nlii10l;
	reg	nlii10O;
	reg	nlii11i;
	reg	nlii11l;
	reg	nlii11O;
	reg	nlii1ii;
	reg	nlii1il;
	reg	nlii1iO;
	reg	nlii1li;
	reg	nlii1ll;
	reg	nlii1lO;
	reg	nlii1Oi;
	reg	nlii1Ol;
	reg	nlii1OO;
	reg	nliii0i;
	reg	nliii0l;
	reg	nliii0O;
	reg	nliii1i;
	reg	nliii1l;
	reg	nliii1O;
	reg	nlO0l0l;
	reg	nlO0l0O;
	reg	nlO0lii;
	reg	nlO0lil;
	reg	nlO0liO;
	reg	nlO0lli;
	reg	nlO0lll;
	wire	wire_n1OOO_CLRN;
	reg	n000i;
	reg	n000l;
	reg	n000O;
	reg	n001i;
	reg	n001l;
	reg	n001O;
	reg	n00ii;
	reg	n00il;
	reg	n00iO;
	reg	n00li;
	reg	n00ll;
	reg	n00lO;
	reg	n00Oi;
	reg	n00Ol;
	reg	n00OO;
	reg	n010i;
	reg	n010l;
	reg	n010O;
	reg	n011l;
	reg	n011O;
	reg	n01ii;
	reg	n01il;
	reg	n01iO;
	reg	n01li;
	reg	n01ll;
	reg	n01lO;
	reg	n01Oi;
	reg	n01Ol;
	reg	n01OO;
	reg	n0i1i;
	reg	n0i1l;
	reg	nliOO;
	wire	wire_nliOl_CLRN;
	wire	wire_n0i0i_dataout;
	wire	wire_n0i0l_dataout;
	wire	wire_n0i0O_dataout;
	wire	wire_n0i1O_dataout;
	wire	wire_n0iii_dataout;
	wire	wire_n0iil_dataout;
	wire	wire_n0iiO_dataout;
	wire	wire_n0ili_dataout;
	wire	wire_n0ill_dataout;
	wire	wire_n0ilO_dataout;
	wire	wire_n0iOi_dataout;
	wire	wire_n0iOl_dataout;
	wire	wire_n0iOO_dataout;
	wire	wire_n0l0i_dataout;
	wire	wire_n0l0l_dataout;
	wire	wire_n0l0O_dataout;
	wire	wire_n0l1i_dataout;
	wire	wire_n0l1l_dataout;
	wire	wire_n0l1O_dataout;
	wire	wire_n0lii_dataout;
	wire	wire_n0lil_dataout;
	wire	wire_n0liO_dataout;
	wire	wire_n0lli_dataout;
	wire	wire_n0lll_dataout;
	wire	wire_n0llO_dataout;
	wire	wire_n0lOi_dataout;
	wire	wire_n0lOl_dataout;
	wire	wire_n0lOO_dataout;
	wire	wire_n0O0i_dataout;
	wire	wire_n0O1i_dataout;
	wire	wire_n0O1l_dataout;
	wire	wire_n0O1O_dataout;
	wire	wire_ni0iii_dataout;
	wire	wire_ni0iil_dataout;
	wire	wire_ni0iiO_dataout;
	wire	wire_ni0ili_dataout;
	wire	wire_ni0ill_dataout;
	wire	wire_ni0ilO_dataout;
	wire	wire_ni0iOi_dataout;
	wire	wire_ni0iOl_dataout;
	wire	wire_ni0iOO_dataout;
	wire	wire_ni0l0i_dataout;
	wire	wire_ni0l0l_dataout;
	wire	wire_ni0l0O_dataout;
	wire	wire_ni0l1i_dataout;
	wire	wire_ni0l1l_dataout;
	wire	wire_ni0l1O_dataout;
	wire	wire_ni0lii_dataout;
	wire	wire_ni0lil_dataout;
	wire	wire_ni0liO_dataout;
	wire	wire_ni0lli_dataout;
	wire	wire_ni0lll_dataout;
	wire	wire_ni0llO_dataout;
	wire	wire_ni0lOi_dataout;
	wire	wire_ni0lOl_dataout;
	wire	wire_ni0lOO_dataout;
	wire	wire_ni0O0i_dataout;
	wire	wire_ni0O0l_dataout;
	wire	wire_ni0O0O_dataout;
	wire	wire_ni0O1i_dataout;
	wire	wire_ni0O1l_dataout;
	wire	wire_ni0O1O_dataout;
	wire	wire_ni0Oii_dataout;
	wire	wire_ni0Oil_dataout;
	wire	wire_ni100i_dataout;
	wire	wire_ni100l_dataout;
	wire	wire_ni100O_dataout;
	wire	wire_ni101i_dataout;
	wire	wire_ni101l_dataout;
	wire	wire_ni101O_dataout;
	wire	wire_ni10ii_dataout;
	wire	wire_ni10il_dataout;
	wire	wire_ni10iO_dataout;
	wire	wire_ni10li_dataout;
	wire	wire_ni10ll_dataout;
	wire	wire_ni10lO_dataout;
	wire	wire_ni10Oi_dataout;
	wire	wire_ni10Ol_dataout;
	wire	wire_ni10OO_dataout;
	wire	wire_ni110i_dataout;
	wire	wire_ni110l_dataout;
	wire	wire_ni110O_dataout;
	wire	wire_ni111i_dataout;
	wire	wire_ni111l_dataout;
	wire	wire_ni111O_dataout;
	wire	wire_ni11ii_dataout;
	wire	wire_ni11il_dataout;
	wire	wire_ni11iO_dataout;
	wire	wire_ni11li_dataout;
	wire	wire_ni11ll_dataout;
	wire	wire_ni11lO_dataout;
	wire	wire_ni11Oi_dataout;
	wire	wire_ni11Ol_dataout;
	wire	wire_ni11OO_dataout;
	wire	wire_ni1i1i_dataout;
	wire	wire_ni1i1l_dataout;
	wire	wire_niliO_dataout;
	wire	wire_nilli_dataout;
	wire	wire_nilll_dataout;
	wire	wire_nillO_dataout;
	wire	wire_nilOi_dataout;
	wire	wire_nilOl_dataout;
	wire	wire_nilOO_dataout;
	wire	wire_niO0i_dataout;
	wire	wire_niO0l_dataout;
	wire	wire_niO0O_dataout;
	wire	wire_niO1i_dataout;
	wire	wire_niO1l_dataout;
	wire	wire_niO1O_dataout;
	wire	wire_niOii_dataout;
	wire	wire_niOil_dataout;
	wire	wire_niOiO_dataout;
	wire	wire_niOli_dataout;
	wire	wire_niOll_dataout;
	wire	wire_niOlO_dataout;
	wire	wire_niOO0i_dataout;
	wire	wire_niOO0l_dataout;
	wire	wire_niOO0O_dataout;
	wire	wire_niOO1l_dataout;
	wire	wire_niOO1O_dataout;
	wire	wire_niOOi_dataout;
	wire	wire_niOOii_dataout;
	wire	wire_niOOil_dataout;
	wire	wire_niOOiO_dataout;
	wire	wire_niOOl_dataout;
	wire	wire_niOOli_dataout;
	wire	wire_niOOll_dataout;
	wire	wire_niOOlO_dataout;
	wire	wire_niOOO_dataout;
	wire	wire_niOOOi_dataout;
	wire	wire_niOOOl_dataout;
	wire	wire_niOOOO_dataout;
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
	wire	wire_nl0Oiii_dataout;
	wire	wire_nl0Oiil_dataout;
	wire	wire_nl0OiiO_dataout;
	wire	wire_nl0Oill_dataout;
	wire	wire_nl0OiOi_dataout;
	wire	wire_nl0OiOO_dataout;
	wire	wire_nl0Ol_dataout;
	wire	wire_nl0Ol0i_dataout;
	wire	wire_nl0Ol0O_dataout;
	wire	wire_nl0Ol1l_dataout;
	wire	wire_nl0Olil_dataout;
	wire	wire_nl0Olli_dataout;
	wire	wire_nl0OllO_dataout;
	wire	wire_nl0OlOl_dataout;
	wire	wire_nl0OO_dataout;
	wire	wire_nl0OO0l_dataout;
	wire	wire_nl0OO1i_dataout;
	wire	wire_nl0OO1O_dataout;
	wire	wire_nl0OOii_dataout;
	wire	wire_nl0OOiO_dataout;
	wire	wire_nl0OOll_dataout;
	wire	wire_nl0OOOi_dataout;
	wire	wire_nl0OOOO_dataout;
	wire	wire_nl101i_dataout;
	wire	wire_nl101l_dataout;
	wire	wire_nl101O_dataout;
	wire	wire_nl10i_dataout;
	wire	wire_nl10l_dataout;
	wire	wire_nl10O_dataout;
	wire	wire_nl110i_dataout;
	wire	wire_nl110l_dataout;
	wire	wire_nl110O_dataout;
	wire	wire_nl111i_dataout;
	wire	wire_nl111l_dataout;
	wire	wire_nl111O_dataout;
	wire	wire_nl11i_dataout;
	wire	wire_nl11ii_dataout;
	wire	wire_nl11il_dataout;
	wire	wire_nl11iO_dataout;
	wire	wire_nl11l_dataout;
	wire	wire_nl11li_dataout;
	wire	wire_nl11ll_dataout;
	wire	wire_nl11lO_dataout;
	wire	wire_nl11O_dataout;
	wire	wire_nl11Oi_dataout;
	wire	wire_nl11Ol_dataout;
	wire	wire_nl11OO_dataout;
	wire	wire_nl1ii_dataout;
	wire	wire_nl1il_dataout;
	wire	wire_nl1iO_dataout;
	wire	wire_nl1li_dataout;
	wire	wire_nl1ll_dataout;
	wire	wire_nl1lO_dataout;
	wire	wire_nl1Oi_dataout;
	wire	wire_nl1Ol_dataout;
	wire	wire_nl1OO_dataout;
	wire	wire_nli0i_dataout;
	wire	wire_nli0l_dataout;
	wire	wire_nli0O_dataout;
	wire	wire_nli100i_dataout;
	wire	wire_nli100O_dataout;
	wire	wire_nli101i_dataout;
	wire	wire_nli101l_dataout;
	wire	wire_nli10il_dataout;
	wire	wire_nli10li_dataout;
	wire	wire_nli10lO_dataout;
	wire	wire_nli10Ol_dataout;
	wire	wire_nli110i_dataout;
	wire	wire_nli110O_dataout;
	wire	wire_nli111l_dataout;
	wire	wire_nli11iO_dataout;
	wire	wire_nli11li_dataout;
	wire	wire_nli11ll_dataout;
	wire	wire_nli11lO_dataout;
	wire	wire_nli11Oi_dataout;
	wire	wire_nli11Ol_dataout;
	wire	wire_nli11OO_dataout;
	wire	wire_nli1i_dataout;
	wire	wire_nli1i0i_dataout;
	wire	wire_nli1i0O_dataout;
	wire	wire_nli1i1i_dataout;
	wire	wire_nli1iil_dataout;
	wire	wire_nli1ili_dataout;
	wire	wire_nli1ilO_dataout;
	wire	wire_nli1iOl_dataout;
	wire	wire_nli1l_dataout;
	wire	wire_nli1l0O_dataout;
	wire	wire_nli1l1i_dataout;
	wire	wire_nli1l1O_dataout;
	wire	wire_nli1lil_dataout;
	wire	wire_nli1lli_dataout;
	wire	wire_nli1llO_dataout;
	wire	wire_nli1lOl_dataout;
	wire	wire_nli1O_dataout;
	wire	wire_nli1O0l_dataout;
	wire	wire_nli1O1i_dataout;
	wire	wire_nli1O1O_dataout;
	wire	wire_nliii_dataout;
	wire	wire_nliil_dataout;
	wire	wire_nliiO_dataout;
	wire	wire_nlili_dataout;
	wire	wire_nlill_dataout;
	wire	wire_nlilO_dataout;
	wire  [3:0]   wire_nli1l0l_o;
	wire  [7:0]   wire_nli1Oii_o;
	wire  nl0i00i;
	wire  nl0i00l;
	wire  nl0i00O;
	wire  nl0i01i;
	wire  nl0i01l;
	wire  nl0i01O;
	wire  nl0i0ii;
	wire  nl0i0il;
	wire  nl0i0iO;
	wire  nl0i0li;
	wire  nl0i0ll;
	wire  nl0i0lO;
	wire  nl0i0Ol;
	wire  nl0i0OO;
	wire  nl0i10i;
	wire  nl0i10l;
	wire  nl0i10O;
	wire  nl0i1ii;
	wire  nl0i1il;
	wire  nl0i1iO;
	wire  nl0i1li;
	wire  nl0i1ll;
	wire  nl0i1lO;
	wire  nl0i1Oi;
	wire  nl0i1Ol;
	wire  nl0i1OO;
	wire  nl0ii0i;
	wire  nl0ii0l;
	wire  nl0ii0O;
	wire  nl0ii1i;
	wire  nl0ii1l;
	wire  nl0ii1O;
	wire  nl0iiii;
	wire  nl0iiil;
	wire  nl0iili;
	wire  nl0iill;
	wire  nl0iilO;
	wire  nl0iiOi;
	wire  nl0iiOl;
	wire  nl0iiOO;
	wire  nl0il0i;
	wire  nl0il0l;
	wire  nl0il0O;
	wire  nl0il1i;
	wire  nl0il1l;
	wire  nl0il1O;
	wire  nl0ilii;
	wire  nl0ilil;
	wire  nl0iliO;
	wire  nl0illi;
	wire  nl0illl;
	wire  nl0illO;
	wire  nl0ilOi;
	wire  nl0ilOl;
	wire  nl0ilOO;
	wire  nl0iO0i;
	wire  nl0iO0l;
	wire  nl0iO0O;
	wire  nl0iO1i;
	wire  nl0iO1l;
	wire  nl0iO1O;
	wire  nl0iOii;
	wire  nl0iOil;
	wire  nl0iOiO;
	wire  nl0iOli;
	wire  nl0iOll;
	wire  nl0iOlO;
	wire  nl0iOOi;
	wire  nl0iOOl;
	wire  nl0iOOO;
	wire  nl0l00i;
	wire  nl0l00l;
	wire  nl0l00O;
	wire  nl0l01i;
	wire  nl0l01l;
	wire  nl0l01O;
	wire  nl0l0ii;
	wire  nl0l0il;
	wire  nl0l0iO;
	wire  nl0l0li;
	wire  nl0l0ll;
	wire  nl0l0lO;
	wire  nl0l0Oi;
	wire  nl0l0Ol;
	wire  nl0l0OO;
	wire  nl0l10i;
	wire  nl0l10l;
	wire  nl0l10O;
	wire  nl0l11i;
	wire  nl0l11l;
	wire  nl0l11O;
	wire  nl0l1ii;
	wire  nl0l1il;
	wire  nl0l1iO;
	wire  nl0l1ll;
	wire  nl0l1lO;
	wire  nl0l1Oi;
	wire  nl0l1Ol;
	wire  nl0l1OO;
	wire  nl0li0i;
	wire  nl0li0l;
	wire  nl0li0O;
	wire  nl0li1i;
	wire  nl0li1l;
	wire  nl0li1O;
	wire  nl0liii;
	wire  nl0liil;
	wire  nl0liiO;
	wire  nl0lili;
	wire  nl0lill;
	wire  nl0lilO;
	wire  nl0liOi;
	wire  nl0liOl;
	wire  nl0O1il;
	wire  nl0O1iO;
	wire  nl0O1Oi;

	initial
		nl0i0Oi47 = 0;
	always @ ( posedge clk)
		  nl0i0Oi47 <= nl0i0Oi48;
	event nl0i0Oi47_event;
	initial
		#1 ->nl0i0Oi47_event;
	always @(nl0i0Oi47_event)
		nl0i0Oi47 <= {1{1'b1}};
	initial
		nl0i0Oi48 = 0;
	always @ ( posedge clk)
		  nl0i0Oi48 <= nl0i0Oi47;
	initial
		nl0iiiO45 = 0;
	always @ ( posedge clk)
		  nl0iiiO45 <= nl0iiiO46;
	event nl0iiiO45_event;
	initial
		#1 ->nl0iiiO45_event;
	always @(nl0iiiO45_event)
		nl0iiiO45 <= {1{1'b1}};
	initial
		nl0iiiO46 = 0;
	always @ ( posedge clk)
		  nl0iiiO46 <= nl0iiiO45;
	initial
		nl0l1li43 = 0;
	always @ ( posedge clk)
		  nl0l1li43 <= nl0l1li44;
	event nl0l1li43_event;
	initial
		#1 ->nl0l1li43_event;
	always @(nl0l1li43_event)
		nl0l1li43 <= {1{1'b1}};
	initial
		nl0l1li44 = 0;
	always @ ( posedge clk)
		  nl0l1li44 <= nl0l1li43;
	initial
		nl0liOO41 = 0;
	always @ ( posedge clk)
		  nl0liOO41 <= nl0liOO42;
	event nl0liOO41_event;
	initial
		#1 ->nl0liOO41_event;
	always @(nl0liOO41_event)
		nl0liOO41 <= {1{1'b1}};
	initial
		nl0liOO42 = 0;
	always @ ( posedge clk)
		  nl0liOO42 <= nl0liOO41;
	initial
		nl0ll0i37 = 0;
	always @ ( posedge clk)
		  nl0ll0i37 <= nl0ll0i38;
	event nl0ll0i37_event;
	initial
		#1 ->nl0ll0i37_event;
	always @(nl0ll0i37_event)
		nl0ll0i37 <= {1{1'b1}};
	initial
		nl0ll0i38 = 0;
	always @ ( posedge clk)
		  nl0ll0i38 <= nl0ll0i37;
	initial
		nl0ll0O35 = 0;
	always @ ( posedge clk)
		  nl0ll0O35 <= nl0ll0O36;
	event nl0ll0O35_event;
	initial
		#1 ->nl0ll0O35_event;
	always @(nl0ll0O35_event)
		nl0ll0O35 <= {1{1'b1}};
	initial
		nl0ll0O36 = 0;
	always @ ( posedge clk)
		  nl0ll0O36 <= nl0ll0O35;
	initial
		nl0ll1l39 = 0;
	always @ ( posedge clk)
		  nl0ll1l39 <= nl0ll1l40;
	event nl0ll1l39_event;
	initial
		#1 ->nl0ll1l39_event;
	always @(nl0ll1l39_event)
		nl0ll1l39 <= {1{1'b1}};
	initial
		nl0ll1l40 = 0;
	always @ ( posedge clk)
		  nl0ll1l40 <= nl0ll1l39;
	initial
		nl0llil33 = 0;
	always @ ( posedge clk)
		  nl0llil33 <= nl0llil34;
	event nl0llil33_event;
	initial
		#1 ->nl0llil33_event;
	always @(nl0llil33_event)
		nl0llil33 <= {1{1'b1}};
	initial
		nl0llil34 = 0;
	always @ ( posedge clk)
		  nl0llil34 <= nl0llil33;
	initial
		nl0llli31 = 0;
	always @ ( posedge clk)
		  nl0llli31 <= nl0llli32;
	event nl0llli31_event;
	initial
		#1 ->nl0llli31_event;
	always @(nl0llli31_event)
		nl0llli31 <= {1{1'b1}};
	initial
		nl0llli32 = 0;
	always @ ( posedge clk)
		  nl0llli32 <= nl0llli31;
	initial
		nl0lllO29 = 0;
	always @ ( posedge clk)
		  nl0lllO29 <= nl0lllO30;
	event nl0lllO29_event;
	initial
		#1 ->nl0lllO29_event;
	always @(nl0lllO29_event)
		nl0lllO29 <= {1{1'b1}};
	initial
		nl0lllO30 = 0;
	always @ ( posedge clk)
		  nl0lllO30 <= nl0lllO29;
	initial
		nl0llOl27 = 0;
	always @ ( posedge clk)
		  nl0llOl27 <= nl0llOl28;
	event nl0llOl27_event;
	initial
		#1 ->nl0llOl27_event;
	always @(nl0llOl27_event)
		nl0llOl27 <= {1{1'b1}};
	initial
		nl0llOl28 = 0;
	always @ ( posedge clk)
		  nl0llOl28 <= nl0llOl27;
	initial
		nl0lO0l21 = 0;
	always @ ( posedge clk)
		  nl0lO0l21 <= nl0lO0l22;
	event nl0lO0l21_event;
	initial
		#1 ->nl0lO0l21_event;
	always @(nl0lO0l21_event)
		nl0lO0l21 <= {1{1'b1}};
	initial
		nl0lO0l22 = 0;
	always @ ( posedge clk)
		  nl0lO0l22 <= nl0lO0l21;
	initial
		nl0lO1i25 = 0;
	always @ ( posedge clk)
		  nl0lO1i25 <= nl0lO1i26;
	event nl0lO1i25_event;
	initial
		#1 ->nl0lO1i25_event;
	always @(nl0lO1i25_event)
		nl0lO1i25 <= {1{1'b1}};
	initial
		nl0lO1i26 = 0;
	always @ ( posedge clk)
		  nl0lO1i26 <= nl0lO1i25;
	initial
		nl0lO1O23 = 0;
	always @ ( posedge clk)
		  nl0lO1O23 <= nl0lO1O24;
	event nl0lO1O23_event;
	initial
		#1 ->nl0lO1O23_event;
	always @(nl0lO1O23_event)
		nl0lO1O23 <= {1{1'b1}};
	initial
		nl0lO1O24 = 0;
	always @ ( posedge clk)
		  nl0lO1O24 <= nl0lO1O23;
	initial
		nl0lOii19 = 0;
	always @ ( posedge clk)
		  nl0lOii19 <= nl0lOii20;
	event nl0lOii19_event;
	initial
		#1 ->nl0lOii19_event;
	always @(nl0lOii19_event)
		nl0lOii19 <= {1{1'b1}};
	initial
		nl0lOii20 = 0;
	always @ ( posedge clk)
		  nl0lOii20 <= nl0lOii19;
	initial
		nl0lOiO17 = 0;
	always @ ( posedge clk)
		  nl0lOiO17 <= nl0lOiO18;
	event nl0lOiO17_event;
	initial
		#1 ->nl0lOiO17_event;
	always @(nl0lOiO17_event)
		nl0lOiO17 <= {1{1'b1}};
	initial
		nl0lOiO18 = 0;
	always @ ( posedge clk)
		  nl0lOiO18 <= nl0lOiO17;
	initial
		nl0lOll15 = 0;
	always @ ( posedge clk)
		  nl0lOll15 <= nl0lOll16;
	event nl0lOll15_event;
	initial
		#1 ->nl0lOll15_event;
	always @(nl0lOll15_event)
		nl0lOll15 <= {1{1'b1}};
	initial
		nl0lOll16 = 0;
	always @ ( posedge clk)
		  nl0lOll16 <= nl0lOll15;
	initial
		nl0lOOi13 = 0;
	always @ ( posedge clk)
		  nl0lOOi13 <= nl0lOOi14;
	event nl0lOOi13_event;
	initial
		#1 ->nl0lOOi13_event;
	always @(nl0lOOi13_event)
		nl0lOOi13 <= {1{1'b1}};
	initial
		nl0lOOi14 = 0;
	always @ ( posedge clk)
		  nl0lOOi14 <= nl0lOOi13;
	initial
		nl0lOOO11 = 0;
	always @ ( posedge clk)
		  nl0lOOO11 <= nl0lOOO12;
	event nl0lOOO11_event;
	initial
		#1 ->nl0lOOO11_event;
	always @(nl0lOOO11_event)
		nl0lOOO11 <= {1{1'b1}};
	initial
		nl0lOOO12 = 0;
	always @ ( posedge clk)
		  nl0lOOO12 <= nl0lOOO11;
	initial
		nl0O10i7 = 0;
	always @ ( posedge clk)
		  nl0O10i7 <= nl0O10i8;
	event nl0O10i7_event;
	initial
		#1 ->nl0O10i7_event;
	always @(nl0O10i7_event)
		nl0O10i7 <= {1{1'b1}};
	initial
		nl0O10i8 = 0;
	always @ ( posedge clk)
		  nl0O10i8 <= nl0O10i7;
	initial
		nl0O10O5 = 0;
	always @ ( posedge clk)
		  nl0O10O5 <= nl0O10O6;
	event nl0O10O5_event;
	initial
		#1 ->nl0O10O5_event;
	always @(nl0O10O5_event)
		nl0O10O5 <= {1{1'b1}};
	initial
		nl0O10O6 = 0;
	always @ ( posedge clk)
		  nl0O10O6 <= nl0O10O5;
	initial
		nl0O11l10 = 0;
	always @ ( posedge clk)
		  nl0O11l10 <= nl0O11l9;
	initial
		nl0O11l9 = 0;
	always @ ( posedge clk)
		  nl0O11l9 <= nl0O11l10;
	event nl0O11l9_event;
	initial
		#1 ->nl0O11l9_event;
	always @(nl0O11l9_event)
		nl0O11l9 <= {1{1'b1}};
	initial
		nl0O1li3 = 0;
	always @ ( posedge clk)
		  nl0O1li3 <= nl0O1li4;
	event nl0O1li3_event;
	initial
		#1 ->nl0O1li3_event;
	always @(nl0O1li3_event)
		nl0O1li3 <= {1{1'b1}};
	initial
		nl0O1li4 = 0;
	always @ ( posedge clk)
		  nl0O1li4 <= nl0O1li3;
	initial
		nl0O1OO1 = 0;
	always @ ( posedge clk)
		  nl0O1OO1 <= nl0O1OO2;
	event nl0O1OO1_event;
	initial
		#1 ->nl0O1OO1_event;
	always @(nl0O1OO1_event)
		nl0O1OO1 <= {1{1'b1}};
	initial
		nl0O1OO2 = 0;
	always @ ( posedge clk)
		  nl0O1OO2 <= nl0O1OO1;
	initial
	begin
		n0l1OO = 0;
		n1ilii = 0;
		n1ilil = 0;
		n1iliO = 0;
		n1illi = 0;
		n1illl = 0;
		n1illO = 0;
		n1ilOi = 0;
		n1ilOl = 0;
		n1ilOO = 0;
		n1iO0i = 0;
		n1iO0l = 0;
		n1iO0O = 0;
		n1iO1i = 0;
		n1iO1l = 0;
		n1iO1O = 0;
		n1iOii = 0;
		n1iOil = 0;
		n1iOiO = 0;
		n1iOli = 0;
		n1iOll = 0;
		n1iOlO = 0;
		n1iOOi = 0;
		n1iOOl = 0;
		n1iOOO = 0;
		n1l00i = 0;
		n1l00l = 0;
		n1l00O = 0;
		n1l01i = 0;
		n1l01l = 0;
		n1l01O = 0;
		n1l0ii = 0;
		n1l0il = 0;
		n1l0iO = 0;
		n1l0li = 0;
		n1l0ll = 0;
		n1l0lO = 0;
		n1l0Oi = 0;
		n1l0Ol = 0;
		n1l0OO = 0;
		n1l10i = 0;
		n1l10l = 0;
		n1l10O = 0;
		n1l11i = 0;
		n1l11l = 0;
		n1l11O = 0;
		n1l1ii = 0;
		n1l1il = 0;
		n1l1iO = 0;
		n1l1li = 0;
		n1l1ll = 0;
		n1l1lO = 0;
		n1l1Oi = 0;
		n1l1Ol = 0;
		n1l1OO = 0;
		n1li0i = 0;
		n1li0l = 0;
		n1li0O = 0;
		n1li1i = 0;
		n1li1l = 0;
		n1li1O = 0;
		n1liii = 0;
		n1liil = 0;
		n1liiO = 0;
		n1lili = 0;
	end
	always @ ( posedge clk or  negedge wire_n0l1Ol_CLRN)
	begin
		if (wire_n0l1Ol_CLRN == 1'b0) 
		begin
			n0l1OO <= 0;
			n1ilii <= 0;
			n1ilil <= 0;
			n1iliO <= 0;
			n1illi <= 0;
			n1illl <= 0;
			n1illO <= 0;
			n1ilOi <= 0;
			n1ilOl <= 0;
			n1ilOO <= 0;
			n1iO0i <= 0;
			n1iO0l <= 0;
			n1iO0O <= 0;
			n1iO1i <= 0;
			n1iO1l <= 0;
			n1iO1O <= 0;
			n1iOii <= 0;
			n1iOil <= 0;
			n1iOiO <= 0;
			n1iOli <= 0;
			n1iOll <= 0;
			n1iOlO <= 0;
			n1iOOi <= 0;
			n1iOOl <= 0;
			n1iOOO <= 0;
			n1l00i <= 0;
			n1l00l <= 0;
			n1l00O <= 0;
			n1l01i <= 0;
			n1l01l <= 0;
			n1l01O <= 0;
			n1l0ii <= 0;
			n1l0il <= 0;
			n1l0iO <= 0;
			n1l0li <= 0;
			n1l0ll <= 0;
			n1l0lO <= 0;
			n1l0Oi <= 0;
			n1l0Ol <= 0;
			n1l0OO <= 0;
			n1l10i <= 0;
			n1l10l <= 0;
			n1l10O <= 0;
			n1l11i <= 0;
			n1l11l <= 0;
			n1l11O <= 0;
			n1l1ii <= 0;
			n1l1il <= 0;
			n1l1iO <= 0;
			n1l1li <= 0;
			n1l1ll <= 0;
			n1l1lO <= 0;
			n1l1Oi <= 0;
			n1l1Ol <= 0;
			n1l1OO <= 0;
			n1li0i <= 0;
			n1li0l <= 0;
			n1li0O <= 0;
			n1li1i <= 0;
			n1li1l <= 0;
			n1li1O <= 0;
			n1liii <= 0;
			n1liil <= 0;
			n1liiO <= 0;
			n1lili <= 0;
		end
		else if  (nlO0l0O == 1'b1) 
		begin
			n0l1OO <= (nl0l1lO ^ (nl0l0ll ^ (nl0l0Ol ^ (nl0l0OO ^ nl0iili))));
			n1ilii <= (nl0l00O ^ (nl0l0li ^ (nl0li1l ^ (nl0liiO ^ (nl0liOl ^ nl0lill)))));
			n1ilil <= (nl0l1OO ^ (nl0l01l ^ (nl0l00O ^ (nl0l0il ^ (nl0liOi ^ nl0l0lO)))));
			n1iliO <= (nl0l01l ^ (nl0l00l ^ (nl0l0il ^ (nl0l0Oi ^ (nl0li0i ^ nl0l0Ol)))));
			n1illi <= (nl0l1OO ^ (nl0l00l ^ (nl0l0ll ^ (nl0l0lO ^ (nl0li0i ^ nl0l0OO)))));
			n1illl <= (nl0l01l ^ (nl0l01O ^ (nl0l0li ^ (nl0l0ll ^ (nl0liii ^ nl0li1O)))));
			n1illO <= (nl0l1Ol ^ (nl0l0li ^ (nl0l0ll ^ (nl0li1i ^ (nl0li0O ^ nl0li0i)))));
			n1ilOi <= (nl0l1ll ^ (nl0l1Ol ^ (nl0l01i ^ (nl0l00O ^ (nl0liiO ^ nl0l0ll)))));
			n1ilOl <= (nl0l1OO ^ (nl0l01i ^ (nl0l0li ^ (nl0l0lO ^ (nl0liOi ^ nl0l0Oi)))));
			n1ilOO <= (nl0l1lO ^ (nl0l1Ol ^ (nl0l01i ^ (nl0l0il ^ nl0iili))));
			n1iO0i <= (nl0l1ll ^ (nl0l1Oi ^ (nl0l00O ^ (nl0l0Oi ^ (nl0lill ^ nl0li1O)))));
			n1iO0l <= (nl0l1Ol ^ (nl0l01i ^ (nl0li1O ^ (nl0li0l ^ (nl0liiO ^ nl0liii)))));
			n1iO0O <= (nl0l1ll ^ (nl0l1Oi ^ (nl0l01l ^ (nl0l0il ^ (nl0l0Ol ^ nl0l0li)))));
			n1iO1i <= (nl0l1Ol ^ (nl0l01i ^ (nl0l00l ^ (nl0l0il ^ (nl0liOl ^ nl0l0Ol)))));
			n1iO1l <= (nl0l1ll ^ (nl0l1OO ^ (nl0l01i ^ (nl0liii ^ nl0iiil))));
			n1iO1O <= (nl0l1ll ^ (nl0l00i ^ (nl0l0il ^ (nl0li1l ^ nl0i0Ol))));
			n1iOii <= (nl0l1Oi ^ (nl0l00i ^ (nl0l0Oi ^ (nl0li1l ^ (nl0liii ^ nl0li0l)))));
			n1iOil <= (nl0l1Ol ^ (nl0l00l ^ (nl0l0ll ^ (nl0li1i ^ (nl0li1O ^ nl0li1l)))));
			n1iOiO <= (nl0l1lO ^ (nl0l01i ^ (nl0l0li ^ (nl0li1i ^ (nl0liOl ^ nl0li0i)))));
			n1iOli <= (nl0l00i ^ (nl0l0Ol ^ (nl0liii ^ (nl0lill ^ nl0iiii))));
			n1iOll <= (nl0l01l ^ (nl0l01O ^ (nl0l00i ^ (nl0l0Ol ^ (nl0liil ^ nl0li0l)))));
			n1iOlO <= (nl0l1lO ^ (nl0l1OO ^ (nl0l00l ^ (nl0l0OO ^ nl0iiil))));
			n1iOOi <= (nl0l01l ^ (nl0l0il ^ (nl0l0ll ^ (nl0l0Oi ^ (nl0lilO ^ nl0li1l)))));
			n1iOOl <= (nl0l1ll ^ (nl0l1lO ^ (nl0l1Oi ^ (nl0l00i ^ (nl0lilO ^ nl0l0il)))));
			n1iOOO <= (nl0l1ll ^ (nl0l1lO ^ (nl0l0OO ^ (nl0liil ^ nl0ii1O))));
			n1l00i <= nl0l0Ol;
			n1l00l <= (nl0l1OO ^ (nl0l01O ^ (nl0li1l ^ (nl0li1O ^ (nl0lill ^ nl0liii)))));
			n1l00O <= (nl0l1Ol ^ (nl0l0lO ^ (nl0li0O ^ nl0ii0O)));
			n1l01i <= (nl0l1lO ^ (nl0l01l ^ (nl0l00l ^ (nl0li1O ^ nl0l0il))));
			n1l01l <= (nl0l0OO ^ (nl0li1i ^ (nl0li0i ^ (nl0li0l ^ nl0ii1l))));
			n1l01O <= (nl0l1ll ^ nl0iiii);
			n1l0ii <= (nl0l01O ^ (nl0li0l ^ nl0l00O));
			n1l0il <= (nl0l1Ol ^ (nl0l00i ^ (nl0l00O ^ (nl0liOi ^ nl0l0il))));
			n1l0iO <= (nl0l1Oi ^ (nl0l01O ^ (nl0l00l ^ (nl0l00O ^ (nl0li0O ^ nl0li1O)))));
			n1l0li <= (nl0l1lO ^ (nl0l01O ^ (nl0l00i ^ (nl0lilO ^ nl0li1O))));
			n1l0ll <= (nl0l01l ^ (nl0l01O ^ (nl0l00O ^ (nl0l0Oi ^ (nl0l0OO ^ nl0l0Ol)))));
			n1l0lO <= nl0ii0l;
			n1l0Oi <= nl0ii0i;
			n1l0Ol <= (nl0l0il ^ (nl0l0ll ^ (nl0l0Oi ^ (nl0li0O ^ (nl0lill ^ nl0liil)))));
			n1l0OO <= (nl0l1Ol ^ (nl0l01l ^ (nl0l0li ^ (nl0l0Oi ^ nl0ii1O))));
			n1l10i <= (nl0l1lO ^ (nl0l1Oi ^ (nl0l1OO ^ (nl0l00i ^ (nl0lili ^ nl0li1l)))));
			n1l10l <= (nl0l01O ^ (nl0l0li ^ (nl0l0lO ^ (nl0l0Ol ^ (nl0lilO ^ nl0lill)))));
			n1l10O <= (nl0l00O ^ (nl0l0li ^ (nl0l0ll ^ (nl0l0OO ^ nl0i0OO))));
			n1l11i <= (nl0l1Oi ^ (nl0l01O ^ (nl0li0O ^ nl0ii0i)));
			n1l11l <= (nl0l1lO ^ (nl0l01l ^ (nl0l0il ^ (nl0li1O ^ (nl0lill ^ nl0liiO)))));
			n1l11O <= (nl0l01i ^ (nl0l00l ^ (nl0l0lO ^ (nl0li1i ^ nl0ii0O))));
			n1l1ii <= (nl0l1Oi ^ (nl0l01i ^ (nl0l0Ol ^ (nl0li0l ^ (nl0lilO ^ nl0li0O)))));
			n1l1il <= (nl0l0il ^ (nl0l0ll ^ (nl0li1i ^ (nl0li1O ^ nl0ii0l))));
			n1l1iO <= (nl0l1ll ^ (nl0l1Ol ^ (nl0l01O ^ (nl0l0Oi ^ nl0iiii))));
			n1l1li <= (nl0l00i ^ (nl0l00l ^ (nl0li1i ^ (nl0lill ^ nl0li0l))));
			n1l1ll <= (nl0li1l ^ nl0l00l);
			n1l1lO <= (nl0l1ll ^ (nl0l01l ^ (nl0l00i ^ (nl0l0il ^ nl0ii1O))));
			n1l1Oi <= (nl0l1Oi ^ (nl0l0OO ^ nl0l00O));
			n1l1Ol <= (nl0l1Oi ^ (nl0l01i ^ (nl0l0il ^ (nl0li1i ^ nl0l0OO))));
			n1l1OO <= (nl0l1ll ^ (nl0l00O ^ (nl0l0li ^ (nl0l0Oi ^ nl0ii1i))));
			n1li0i <= nl0lili;
			n1li0l <= (nl0l0il ^ (nl0l0Ol ^ nl0ii1i));
			n1li0O <= (nl0l1lO ^ (nl0l1Ol ^ (nl0l1OO ^ (nl0l0lO ^ (nl0liil ^ nl0l0Oi)))));
			n1li1i <= (nl0l01O ^ (nl0l0il ^ (nl0li0i ^ nl0l0lO)));
			n1li1l <= (nl0l1ll ^ (nl0l01O ^ (nl0l00O ^ (nl0li1l ^ nl0ii1l))));
			n1li1O <= (nl0l1lO ^ (nl0l1Ol ^ (nl0l01O ^ (nl0liil ^ (nl0liOl ^ nl0lili)))));
			n1liii <= (nl0l1lO ^ (nl0lill ^ nl0l01i));
			n1liil <= (nl0l1OO ^ (nl0l0lO ^ (nl0l0Ol ^ (nl0li1l ^ nl0i0OO))));
			n1liiO <= (nl0l1lO ^ (nl0l1Oi ^ (nl0l01l ^ nl0i0Ol)));
			n1lili <= (nl0l1lO ^ (nl0l1OO ^ (nl0l01O ^ (nl0l0OO ^ nl0l0il))));
		end
	end
	assign
		wire_n0l1Ol_CLRN = (nl0iiiO46 ^ nl0iiiO45);
	event n0l1OO_event;
	event n1ilii_event;
	event n1ilil_event;
	event n1iliO_event;
	event n1illi_event;
	event n1illl_event;
	event n1illO_event;
	event n1ilOi_event;
	event n1ilOl_event;
	event n1ilOO_event;
	event n1iO0i_event;
	event n1iO0l_event;
	event n1iO0O_event;
	event n1iO1i_event;
	event n1iO1l_event;
	event n1iO1O_event;
	event n1iOii_event;
	event n1iOil_event;
	event n1iOiO_event;
	event n1iOli_event;
	event n1iOll_event;
	event n1iOlO_event;
	event n1iOOi_event;
	event n1iOOl_event;
	event n1iOOO_event;
	event n1l00i_event;
	event n1l00l_event;
	event n1l00O_event;
	event n1l01i_event;
	event n1l01l_event;
	event n1l01O_event;
	event n1l0ii_event;
	event n1l0il_event;
	event n1l0iO_event;
	event n1l0li_event;
	event n1l0ll_event;
	event n1l0lO_event;
	event n1l0Oi_event;
	event n1l0Ol_event;
	event n1l0OO_event;
	event n1l10i_event;
	event n1l10l_event;
	event n1l10O_event;
	event n1l11i_event;
	event n1l11l_event;
	event n1l11O_event;
	event n1l1ii_event;
	event n1l1il_event;
	event n1l1iO_event;
	event n1l1li_event;
	event n1l1ll_event;
	event n1l1lO_event;
	event n1l1Oi_event;
	event n1l1Ol_event;
	event n1l1OO_event;
	event n1li0i_event;
	event n1li0l_event;
	event n1li0O_event;
	event n1li1i_event;
	event n1li1l_event;
	event n1li1O_event;
	event n1liii_event;
	event n1liil_event;
	event n1liiO_event;
	event n1lili_event;
	initial
		#1 ->n0l1OO_event;
	initial
		#1 ->n1ilii_event;
	initial
		#1 ->n1ilil_event;
	initial
		#1 ->n1iliO_event;
	initial
		#1 ->n1illi_event;
	initial
		#1 ->n1illl_event;
	initial
		#1 ->n1illO_event;
	initial
		#1 ->n1ilOi_event;
	initial
		#1 ->n1ilOl_event;
	initial
		#1 ->n1ilOO_event;
	initial
		#1 ->n1iO0i_event;
	initial
		#1 ->n1iO0l_event;
	initial
		#1 ->n1iO0O_event;
	initial
		#1 ->n1iO1i_event;
	initial
		#1 ->n1iO1l_event;
	initial
		#1 ->n1iO1O_event;
	initial
		#1 ->n1iOii_event;
	initial
		#1 ->n1iOil_event;
	initial
		#1 ->n1iOiO_event;
	initial
		#1 ->n1iOli_event;
	initial
		#1 ->n1iOll_event;
	initial
		#1 ->n1iOlO_event;
	initial
		#1 ->n1iOOi_event;
	initial
		#1 ->n1iOOl_event;
	initial
		#1 ->n1iOOO_event;
	initial
		#1 ->n1l00i_event;
	initial
		#1 ->n1l00l_event;
	initial
		#1 ->n1l00O_event;
	initial
		#1 ->n1l01i_event;
	initial
		#1 ->n1l01l_event;
	initial
		#1 ->n1l01O_event;
	initial
		#1 ->n1l0ii_event;
	initial
		#1 ->n1l0il_event;
	initial
		#1 ->n1l0iO_event;
	initial
		#1 ->n1l0li_event;
	initial
		#1 ->n1l0ll_event;
	initial
		#1 ->n1l0lO_event;
	initial
		#1 ->n1l0Oi_event;
	initial
		#1 ->n1l0Ol_event;
	initial
		#1 ->n1l0OO_event;
	initial
		#1 ->n1l10i_event;
	initial
		#1 ->n1l10l_event;
	initial
		#1 ->n1l10O_event;
	initial
		#1 ->n1l11i_event;
	initial
		#1 ->n1l11l_event;
	initial
		#1 ->n1l11O_event;
	initial
		#1 ->n1l1ii_event;
	initial
		#1 ->n1l1il_event;
	initial
		#1 ->n1l1iO_event;
	initial
		#1 ->n1l1li_event;
	initial
		#1 ->n1l1ll_event;
	initial
		#1 ->n1l1lO_event;
	initial
		#1 ->n1l1Oi_event;
	initial
		#1 ->n1l1Ol_event;
	initial
		#1 ->n1l1OO_event;
	initial
		#1 ->n1li0i_event;
	initial
		#1 ->n1li0l_event;
	initial
		#1 ->n1li0O_event;
	initial
		#1 ->n1li1i_event;
	initial
		#1 ->n1li1l_event;
	initial
		#1 ->n1li1O_event;
	initial
		#1 ->n1liii_event;
	initial
		#1 ->n1liil_event;
	initial
		#1 ->n1liiO_event;
	initial
		#1 ->n1lili_event;
	always @(n0l1OO_event)
		n0l1OO <= 1;
	always @(n1ilii_event)
		n1ilii <= 1;
	always @(n1ilil_event)
		n1ilil <= 1;
	always @(n1iliO_event)
		n1iliO <= 1;
	always @(n1illi_event)
		n1illi <= 1;
	always @(n1illl_event)
		n1illl <= 1;
	always @(n1illO_event)
		n1illO <= 1;
	always @(n1ilOi_event)
		n1ilOi <= 1;
	always @(n1ilOl_event)
		n1ilOl <= 1;
	always @(n1ilOO_event)
		n1ilOO <= 1;
	always @(n1iO0i_event)
		n1iO0i <= 1;
	always @(n1iO0l_event)
		n1iO0l <= 1;
	always @(n1iO0O_event)
		n1iO0O <= 1;
	always @(n1iO1i_event)
		n1iO1i <= 1;
	always @(n1iO1l_event)
		n1iO1l <= 1;
	always @(n1iO1O_event)
		n1iO1O <= 1;
	always @(n1iOii_event)
		n1iOii <= 1;
	always @(n1iOil_event)
		n1iOil <= 1;
	always @(n1iOiO_event)
		n1iOiO <= 1;
	always @(n1iOli_event)
		n1iOli <= 1;
	always @(n1iOll_event)
		n1iOll <= 1;
	always @(n1iOlO_event)
		n1iOlO <= 1;
	always @(n1iOOi_event)
		n1iOOi <= 1;
	always @(n1iOOl_event)
		n1iOOl <= 1;
	always @(n1iOOO_event)
		n1iOOO <= 1;
	always @(n1l00i_event)
		n1l00i <= 1;
	always @(n1l00l_event)
		n1l00l <= 1;
	always @(n1l00O_event)
		n1l00O <= 1;
	always @(n1l01i_event)
		n1l01i <= 1;
	always @(n1l01l_event)
		n1l01l <= 1;
	always @(n1l01O_event)
		n1l01O <= 1;
	always @(n1l0ii_event)
		n1l0ii <= 1;
	always @(n1l0il_event)
		n1l0il <= 1;
	always @(n1l0iO_event)
		n1l0iO <= 1;
	always @(n1l0li_event)
		n1l0li <= 1;
	always @(n1l0ll_event)
		n1l0ll <= 1;
	always @(n1l0lO_event)
		n1l0lO <= 1;
	always @(n1l0Oi_event)
		n1l0Oi <= 1;
	always @(n1l0Ol_event)
		n1l0Ol <= 1;
	always @(n1l0OO_event)
		n1l0OO <= 1;
	always @(n1l10i_event)
		n1l10i <= 1;
	always @(n1l10l_event)
		n1l10l <= 1;
	always @(n1l10O_event)
		n1l10O <= 1;
	always @(n1l11i_event)
		n1l11i <= 1;
	always @(n1l11l_event)
		n1l11l <= 1;
	always @(n1l11O_event)
		n1l11O <= 1;
	always @(n1l1ii_event)
		n1l1ii <= 1;
	always @(n1l1il_event)
		n1l1il <= 1;
	always @(n1l1iO_event)
		n1l1iO <= 1;
	always @(n1l1li_event)
		n1l1li <= 1;
	always @(n1l1ll_event)
		n1l1ll <= 1;
	always @(n1l1lO_event)
		n1l1lO <= 1;
	always @(n1l1Oi_event)
		n1l1Oi <= 1;
	always @(n1l1Ol_event)
		n1l1Ol <= 1;
	always @(n1l1OO_event)
		n1l1OO <= 1;
	always @(n1li0i_event)
		n1li0i <= 1;
	always @(n1li0l_event)
		n1li0l <= 1;
	always @(n1li0O_event)
		n1li0O <= 1;
	always @(n1li1i_event)
		n1li1i <= 1;
	always @(n1li1l_event)
		n1li1l <= 1;
	always @(n1li1O_event)
		n1li1O <= 1;
	always @(n1liii_event)
		n1liii <= 1;
	always @(n1liil_event)
		n1liil <= 1;
	always @(n1liiO_event)
		n1liiO <= 1;
	always @(n1lili_event)
		n1lili <= 1;
	initial
	begin
		n1il0O = 0;
		nlO0llO = 0;
		nlO0lOi = 0;
		nlO0lOl = 0;
		nlO0lOO = 0;
		nlO0O0i = 0;
		nlO0O0l = 0;
		nlO0O0O = 0;
		nlO0O1i = 0;
		nlO0O1l = 0;
		nlO0O1O = 0;
		nlO0Oii = 0;
		nlO0Oil = 0;
		nlO0OiO = 0;
		nlO0Oli = 0;
		nlO0Oll = 0;
		nlO0OlO = 0;
		nlO0OOi = 0;
		nlO0OOl = 0;
		nlO0OOO = 0;
		nlOi00i = 0;
		nlOi00l = 0;
		nlOi00O = 0;
		nlOi01i = 0;
		nlOi01l = 0;
		nlOi01O = 0;
		nlOi0ii = 0;
		nlOi0il = 0;
		nlOi0iO = 0;
		nlOi0li = 0;
		nlOi0ll = 0;
		nlOi0lO = 0;
		nlOi0Oi = 0;
		nlOi0Ol = 0;
		nlOi0OO = 0;
		nlOi10i = 0;
		nlOi10l = 0;
		nlOi10O = 0;
		nlOi11i = 0;
		nlOi11l = 0;
		nlOi11O = 0;
		nlOi1ii = 0;
		nlOi1il = 0;
		nlOi1iO = 0;
		nlOi1li = 0;
		nlOi1ll = 0;
		nlOi1lO = 0;
		nlOi1Oi = 0;
		nlOi1Ol = 0;
		nlOi1OO = 0;
		nlOii0i = 0;
		nlOii0l = 0;
		nlOii0O = 0;
		nlOii1i = 0;
		nlOii1l = 0;
		nlOii1O = 0;
		nlOiiii = 0;
		nlOiiil = 0;
		nlOiiiO = 0;
		nlOiili = 0;
		nlOiill = 0;
		nlOiilO = 0;
		nlOiiOi = 0;
		nlOiiOl = 0;
		nlOiiOO = 0;
		nlOil0i = 0;
		nlOil1i = 0;
		nlOil1l = 0;
		nlOil1O = 0;
	end
	always @ ( posedge clk or  negedge wire_n1il0l_CLRN)
	begin
		if (wire_n1il0l_CLRN == 1'b0) 
		begin
			n1il0O <= 0;
			nlO0llO <= 0;
			nlO0lOi <= 0;
			nlO0lOl <= 0;
			nlO0lOO <= 0;
			nlO0O0i <= 0;
			nlO0O0l <= 0;
			nlO0O0O <= 0;
			nlO0O1i <= 0;
			nlO0O1l <= 0;
			nlO0O1O <= 0;
			nlO0Oii <= 0;
			nlO0Oil <= 0;
			nlO0OiO <= 0;
			nlO0Oli <= 0;
			nlO0Oll <= 0;
			nlO0OlO <= 0;
			nlO0OOi <= 0;
			nlO0OOl <= 0;
			nlO0OOO <= 0;
			nlOi00i <= 0;
			nlOi00l <= 0;
			nlOi00O <= 0;
			nlOi01i <= 0;
			nlOi01l <= 0;
			nlOi01O <= 0;
			nlOi0ii <= 0;
			nlOi0il <= 0;
			nlOi0iO <= 0;
			nlOi0li <= 0;
			nlOi0ll <= 0;
			nlOi0lO <= 0;
			nlOi0Oi <= 0;
			nlOi0Ol <= 0;
			nlOi0OO <= 0;
			nlOi10i <= 0;
			nlOi10l <= 0;
			nlOi10O <= 0;
			nlOi11i <= 0;
			nlOi11l <= 0;
			nlOi11O <= 0;
			nlOi1ii <= 0;
			nlOi1il <= 0;
			nlOi1iO <= 0;
			nlOi1li <= 0;
			nlOi1ll <= 0;
			nlOi1lO <= 0;
			nlOi1Oi <= 0;
			nlOi1Ol <= 0;
			nlOi1OO <= 0;
			nlOii0i <= 0;
			nlOii0l <= 0;
			nlOii0O <= 0;
			nlOii1i <= 0;
			nlOii1l <= 0;
			nlOii1O <= 0;
			nlOiiii <= 0;
			nlOiiil <= 0;
			nlOiiiO <= 0;
			nlOiili <= 0;
			nlOiill <= 0;
			nlOiilO <= 0;
			nlOiiOi <= 0;
			nlOiiOl <= 0;
			nlOiiOO <= 0;
			nlOil0i <= 0;
			nlOil1i <= 0;
			nlOil1l <= 0;
			nlOil1O <= 0;
		end
		else if  (nl0i0lO == 1'b1) 
		begin
			n1il0O <= (wire_nlilO_dataout ^ (wire_nliiO_dataout ^ (wire_nli1O_dataout ^ wire_nl1ll_dataout)));
			nlO0llO <= (wire_nliil_dataout ^ (wire_nli0O_dataout ^ (wire_nl0OO_dataout ^ (wire_nl0lO_dataout ^ (wire_nl0iO_dataout ^ wire_nl1Ol_dataout)))));
			nlO0lOi <= (wire_nli1O_dataout ^ (wire_nli1l_dataout ^ nl0i00l));
			nlO0lOl <= (wire_nliil_dataout ^ (wire_nli0i_dataout ^ (wire_nl0lO_dataout ^ (wire_nl0ll_dataout ^ (wire_nl00i_dataout ^ wire_nl1Ol_dataout)))));
			nlO0lOO <= (wire_nli0O_dataout ^ (wire_nl0Oi_dataout ^ (wire_nl0il_dataout ^ (wire_nl0ii_dataout ^ nl0i0ll))));
			nlO0O0i <= (wire_nliil_dataout ^ (wire_nli0O_dataout ^ (wire_nli1O_dataout ^ (wire_nl0Ol_dataout ^ (wire_nl0iO_dataout ^ wire_nl00O_dataout)))));
			nlO0O0l <= (wire_nlili_dataout ^ (wire_nliiO_dataout ^ (wire_nli1i_dataout ^ (wire_nl0OO_dataout ^ (wire_nl0Oi_dataout ^ wire_nl01O_dataout)))));
			nlO0O0O <= (wire_nli0i_dataout ^ (wire_nli1i_dataout ^ (wire_nl0li_dataout ^ (wire_nl00i_dataout ^ nl0i01i))));
			nlO0O1i <= (wire_nli1l_dataout ^ (wire_nl0Oi_dataout ^ (wire_nl0li_dataout ^ (wire_nl00O_dataout ^ nl0i0ll))));
			nlO0O1l <= (wire_nli0l_dataout ^ (wire_nli1l_dataout ^ (wire_nl0iO_dataout ^ (wire_nl00l_dataout ^ (wire_nl01l_dataout ^ wire_nl1ll_dataout)))));
			nlO0O1O <= (wire_nlill_dataout ^ (wire_nli0i_dataout ^ (wire_nl0Oi_dataout ^ (wire_nl0ii_dataout ^ (wire_nl00O_dataout ^ wire_nl00l_dataout)))));
			nlO0Oii <= (wire_nliiO_dataout ^ (wire_nliii_dataout ^ (wire_nl0Ol_dataout ^ (wire_nl0Oi_dataout ^ nl0i0li))));
			nlO0Oil <= (wire_nliil_dataout ^ (wire_nli0l_dataout ^ (wire_nl0lO_dataout ^ (wire_nl00O_dataout ^ nl0i0li))));
			nlO0OiO <= (wire_nliii_dataout ^ (wire_nli0i_dataout ^ (wire_nl0li_dataout ^ (wire_nl0il_dataout ^ (wire_nl00O_dataout ^ wire_nl1lO_dataout)))));
			nlO0Oli <= (wire_nlill_dataout ^ (wire_nlili_dataout ^ (wire_nli0i_dataout ^ (wire_nl0OO_dataout ^ (wire_nl0ll_dataout ^ wire_nl1Ol_dataout)))));
			nlO0Oll <= (wire_nlill_dataout ^ (wire_nliii_dataout ^ (wire_nli0l_dataout ^ (wire_nli0i_dataout ^ (wire_nl00l_dataout ^ wire_nl1ll_dataout)))));
			nlO0OlO <= (wire_nli1l_dataout ^ (wire_nl0lO_dataout ^ (wire_nl0li_dataout ^ (wire_nl01l_dataout ^ nl0i00i))));
			nlO0OOi <= (wire_nliiO_dataout ^ (wire_nl00i_dataout ^ (wire_nl01l_dataout ^ (wire_nl1Ol_dataout ^ nl0i01l))));
			nlO0OOl <= (wire_nlilO_dataout ^ (wire_nli0O_dataout ^ (wire_nli0l_dataout ^ (wire_nl0iO_dataout ^ (wire_nl0il_dataout ^ wire_nl1OO_dataout)))));
			nlO0OOO <= (wire_nlili_dataout ^ (wire_nliiO_dataout ^ (wire_nli0O_dataout ^ (wire_nli0i_dataout ^ (wire_nl0ll_dataout ^ wire_nl01O_dataout)))));
			nlOi00i <= (wire_nliii_dataout ^ (wire_nli0O_dataout ^ (wire_nli1O_dataout ^ (wire_nli1i_dataout ^ (wire_nl0OO_dataout ^ wire_nl0ii_dataout)))));
			nlOi00l <= (wire_nl0li_dataout ^ (wire_nl0ii_dataout ^ nl0i00O));
			nlOi00O <= (wire_nlilO_dataout ^ (wire_nliil_dataout ^ (wire_nli0i_dataout ^ (wire_nli1O_dataout ^ (wire_nl0Oi_dataout ^ wire_nl0li_dataout)))));
			nlOi01i <= (wire_nli0i_dataout ^ (wire_nl0OO_dataout ^ (wire_nl0iO_dataout ^ nl0i0ii)));
			nlOi01l <= (wire_nlili_dataout ^ (wire_nliiO_dataout ^ (wire_nli1O_dataout ^ (wire_nl0Oi_dataout ^ (wire_nl01O_dataout ^ wire_nl1OO_dataout)))));
			nlOi01O <= (wire_nliii_dataout ^ (wire_nl0OO_dataout ^ (wire_nl00l_dataout ^ (wire_nl1Ol_dataout ^ (wire_nl1Oi_dataout ^ wire_nl1ll_dataout)))));
			nlOi0ii <= (wire_nlilO_dataout ^ (wire_nliii_dataout ^ (wire_nl1Ol_dataout ^ nl0i00i)));
			nlOi0il <= (wire_nli0i_dataout ^ (wire_nli1i_dataout ^ (wire_nl0lO_dataout ^ (wire_nl0il_dataout ^ nl0i01i))));
			nlOi0iO <= (wire_nlilO_dataout ^ (wire_nlili_dataout ^ (wire_nli1i_dataout ^ (wire_nl0ll_dataout ^ (wire_nl0ii_dataout ^ wire_nl00O_dataout)))));
			nlOi0li <= (wire_nlilO_dataout ^ (wire_nliil_dataout ^ wire_nl0lO_dataout));
			nlOi0ll <= (wire_nl0ll_dataout ^ (wire_nl0il_dataout ^ (wire_nl00O_dataout ^ nl0i01O)));
			nlOi0lO <= (wire_nli1O_dataout ^ (wire_nli1i_dataout ^ (wire_nl0lO_dataout ^ wire_nl01i_dataout)));
			nlOi0Oi <= wire_nl0Ol_dataout;
			nlOi0Ol <= (wire_nlili_dataout ^ (wire_nl0OO_dataout ^ (wire_nl0Ol_dataout ^ (wire_nl0iO_dataout ^ (wire_nl0ii_dataout ^ wire_nl1Oi_dataout)))));
			nlOi0OO <= (wire_nlill_dataout ^ (wire_nli0i_dataout ^ (wire_nli1l_dataout ^ (wire_nl01O_dataout ^ nl0i00O))));
			nlOi10i <= (wire_nli1l_dataout ^ (wire_nl0ll_dataout ^ (wire_nl0li_dataout ^ (wire_nl0il_dataout ^ (wire_nl01i_dataout ^ wire_nl1OO_dataout)))));
			nlOi10l <= (wire_nli0O_dataout ^ (wire_nli0l_dataout ^ (wire_nl00l_dataout ^ (wire_nl1OO_dataout ^ nl0i0il))));
			nlOi10O <= (wire_nliiO_dataout ^ (wire_nli1O_dataout ^ (wire_nl0OO_dataout ^ (wire_nl0lO_dataout ^ (wire_nl0ll_dataout ^ wire_nl01l_dataout)))));
			nlOi11i <= (wire_nliii_dataout ^ (wire_nl0Oi_dataout ^ (wire_nl0ii_dataout ^ nl0i0ii)));
			nlOi11l <= (wire_nlilO_dataout ^ (wire_nliil_dataout ^ (wire_nli0O_dataout ^ (wire_nl0Ol_dataout ^ nl0i0iO))));
			nlOi11O <= (wire_nlill_dataout ^ (wire_nliii_dataout ^ (wire_nli0l_dataout ^ (wire_nl0iO_dataout ^ nl0i01i))));
			nlOi1ii <= (wire_nli0l_dataout ^ (wire_nl0Ol_dataout ^ (wire_nl0iO_dataout ^ (wire_nl00O_dataout ^ nl0i01i))));
			nlOi1il <= (wire_nliil_dataout ^ (wire_nli1i_dataout ^ (wire_nl0Ol_dataout ^ (wire_nl0li_dataout ^ (wire_nl0ii_dataout ^ wire_nl01O_dataout)))));
			nlOi1iO <= (wire_nliii_dataout ^ (wire_nl0ii_dataout ^ (wire_nl01O_dataout ^ (wire_nl1Oi_dataout ^ nl0i01l))));
			nlOi1li <= (wire_nliiO_dataout ^ (wire_nli0O_dataout ^ (wire_nl0OO_dataout ^ (wire_nl0li_dataout ^ (wire_nl01O_dataout ^ wire_nl1Oi_dataout)))));
			nlOi1ll <= (wire_nliil_dataout ^ (wire_nl0Oi_dataout ^ (wire_nl0lO_dataout ^ (wire_nl0ll_dataout ^ nl0i0iO))));
			nlOi1lO <= (wire_nlill_dataout ^ (wire_nlili_dataout ^ (wire_nli0l_dataout ^ (wire_nl0Ol_dataout ^ (wire_nl0Oi_dataout ^ wire_nl1OO_dataout)))));
			nlOi1Oi <= (wire_nlill_dataout ^ (wire_nliiO_dataout ^ (wire_nliii_dataout ^ (wire_nl0iO_dataout ^ (wire_nl00l_dataout ^ wire_nl1OO_dataout)))));
			nlOi1Ol <= (wire_nlill_dataout ^ (wire_nliiO_dataout ^ (wire_nliii_dataout ^ (wire_nli1l_dataout ^ (wire_nli1i_dataout ^ wire_nl1OO_dataout)))));
			nlOi1OO <= (wire_nlilO_dataout ^ (wire_nliii_dataout ^ (wire_nli0l_dataout ^ (wire_nl00i_dataout ^ nl0i0il))));
			nlOii0i <= (wire_nlili_dataout ^ (wire_nli0l_dataout ^ (wire_nli1i_dataout ^ (wire_nl0il_dataout ^ (wire_nl1OO_dataout ^ wire_nl1lO_dataout)))));
			nlOii0l <= (wire_nl0il_dataout ^ (wire_nl00l_dataout ^ wire_nl1Ol_dataout));
			nlOii0O <= (wire_nlill_dataout ^ (wire_nli0l_dataout ^ (wire_nli1i_dataout ^ (wire_nl0lO_dataout ^ (wire_nl0iO_dataout ^ wire_nl01i_dataout)))));
			nlOii1i <= (wire_nliil_dataout ^ (wire_nli1i_dataout ^ nl0i00l));
			nlOii1l <= (wire_nliii_dataout ^ (wire_nli0l_dataout ^ (wire_nl0ll_dataout ^ (wire_nl01O_dataout ^ wire_nl1Ol_dataout))));
			nlOii1O <= (wire_nli1O_dataout ^ wire_nl01l_dataout);
			nlOiiii <= (wire_nlill_dataout ^ (wire_nl0ll_dataout ^ (wire_nl00i_dataout ^ nl0i00i)));
			nlOiiil <= (wire_nliil_dataout ^ (wire_nl0Ol_dataout ^ wire_nl0ll_dataout));
			nlOiiiO <= (wire_nliii_dataout ^ (wire_nli0O_dataout ^ (wire_nl0li_dataout ^ (wire_nl0iO_dataout ^ (wire_nl0ii_dataout ^ wire_nl1Ol_dataout)))));
			nlOiili <= (wire_nlili_dataout ^ (wire_nl0il_dataout ^ wire_nl00i_dataout));
			nlOiill <= (wire_nli0i_dataout ^ (wire_nl0lO_dataout ^ (wire_nl0il_dataout ^ (wire_nl00i_dataout ^ nl0i01O))));
			nlOiilO <= (wire_nli0l_dataout ^ wire_nl1Oi_dataout);
			nlOiiOi <= (wire_nlili_dataout ^ (wire_nliil_dataout ^ (wire_nli1O_dataout ^ (wire_nl01i_dataout ^ wire_nl1Ol_dataout))));
			nlOiiOl <= (wire_nli1l_dataout ^ wire_nl0ll_dataout);
			nlOiiOO <= (wire_nl0lO_dataout ^ (wire_nl0il_dataout ^ (wire_nl01i_dataout ^ nl0i01l)));
			nlOil0i <= (wire_nli0l_dataout ^ (wire_nli1i_dataout ^ (wire_nl0Oi_dataout ^ (wire_nl0li_dataout ^ wire_nl1Ol_dataout))));
			nlOil1i <= (wire_nliil_dataout ^ (wire_nl0il_dataout ^ (wire_nl00l_dataout ^ (wire_nl00i_dataout ^ nl0i01l))));
			nlOil1l <= (wire_nliiO_dataout ^ (wire_nliii_dataout ^ (wire_nl0Ol_dataout ^ (wire_nl0il_dataout ^ wire_nl1ll_dataout))));
			nlOil1O <= (wire_nliil_dataout ^ (wire_nli0l_dataout ^ (wire_nli1l_dataout ^ (wire_nl0Ol_dataout ^ nl0i01i))));
		end
	end
	assign
		wire_n1il0l_CLRN = (nl0i0Oi48 ^ nl0i0Oi47);
	initial
	begin
		n011i = 0;
		n0l00i = 0;
		n0l00l = 0;
		n0l00O = 0;
		n0l01i = 0;
		n0l01l = 0;
		n0l01O = 0;
		n0l0ii = 0;
		n0l0il = 0;
		n0l0iO = 0;
		n0l0li = 0;
		n0l0ll = 0;
		n0l0lO = 0;
		n0l0Oi = 0;
		n0l0Ol = 0;
		n0l0OO = 0;
		n0li0i = 0;
		n0li0l = 0;
		n0li0O = 0;
		n0li1i = 0;
		n0li1l = 0;
		n0li1O = 0;
		n0liii = 0;
		n0liil = 0;
		n0liiO = 0;
		n0lili = 0;
		n0lill = 0;
		n0lilO = 0;
		n0liOi = 0;
		n0liOl = 0;
		n0liOO = 0;
		n0ll0i = 0;
		n0ll0l = 0;
		n0ll0O = 0;
		n0ll1i = 0;
		n0ll1l = 0;
		n0ll1O = 0;
		n0llii = 0;
		n0llil = 0;
		n0lliO = 0;
		n0llli = 0;
		n0llll = 0;
		n0lllO = 0;
		n0llOi = 0;
		n0llOl = 0;
		n0llOO = 0;
		n0lO0i = 0;
		n0lO0l = 0;
		n0lO0O = 0;
		n0lO1i = 0;
		n0lO1l = 0;
		n0lO1O = 0;
		n0lOii = 0;
		n0lOil = 0;
		n0lOiO = 0;
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
		n0OOii = 0;
		n0OOil = 0;
		n0OOiO = 0;
		n0OOli = 0;
		n0OOll = 0;
		n0OOlO = 0;
		n0OOOi = 0;
		n0OOOl = 0;
		n0OOOO = 0;
		niOO1i = 0;
		nl0O00i = 0;
		nl0O00l = 0;
		nl0O00O = 0;
		nl0O01i = 0;
		nl0O01l = 0;
		nl0O01O = 0;
		nl0O0ii = 0;
		nl0O0il = 0;
		nl0O0iO = 0;
		nl0O0li = 0;
		nl0O0ll = 0;
		nl0O0lO = 0;
		nl0O0Oi = 0;
		nl0O0Ol = 0;
		nl0O0OO = 0;
		nl0Oi0i = 0;
		nl0Oi0l = 0;
		nl0Oi0O = 0;
		nl0Oi1i = 0;
		nl0Oi1l = 0;
		nl0Oi1O = 0;
		nl0Oili = 0;
		nl0OilO = 0;
		nl0OiOl = 0;
		nl0Ol0l = 0;
		nl0Ol1i = 0;
		nl0Ol1O = 0;
		nl0Olii = 0;
		nl0OliO = 0;
		nl0Olll = 0;
		nl0OlOi = 0;
		nl0OlOO = 0;
		nl0OO0i = 0;
		nl0OO0O = 0;
		nl0OO1l = 0;
		nl0OOil = 0;
		nl0OOli = 0;
		nl0OOlO = 0;
		nl0OOOl = 0;
		nli000i = 0;
		nli000l = 0;
		nli000O = 0;
		nli001i = 0;
		nli001l = 0;
		nli001O = 0;
		nli00ii = 0;
		nli00il = 0;
		nli00iO = 0;
		nli00li = 0;
		nli00ll = 0;
		nli00lO = 0;
		nli00Oi = 0;
		nli00Ol = 0;
		nli00OO = 0;
		nli010i = 0;
		nli010l = 0;
		nli010O = 0;
		nli011i = 0;
		nli011l = 0;
		nli011O = 0;
		nli01ii = 0;
		nli01il = 0;
		nli01iO = 0;
		nli01li = 0;
		nli01ll = 0;
		nli01lO = 0;
		nli01Oi = 0;
		nli01Ol = 0;
		nli01OO = 0;
		nli0i0i = 0;
		nli0i0l = 0;
		nli0i0O = 0;
		nli0i1i = 0;
		nli0i1l = 0;
		nli0i1O = 0;
		nli0iii = 0;
		nli0iil = 0;
		nli0iiO = 0;
		nli0ili = 0;
		nli0ill = 0;
		nli0ilO = 0;
		nli0iOi = 0;
		nli0iOl = 0;
		nli0iOO = 0;
		nli0l0i = 0;
		nli0l0l = 0;
		nli0l0O = 0;
		nli0l1i = 0;
		nli0l1l = 0;
		nli0l1O = 0;
		nli0lii = 0;
		nli0lil = 0;
		nli0liO = 0;
		nli0lli = 0;
		nli0lll = 0;
		nli0llO = 0;
		nli0lOi = 0;
		nli0lOl = 0;
		nli0lOO = 0;
		nli0O0i = 0;
		nli0O0l = 0;
		nli0O0O = 0;
		nli0O1i = 0;
		nli0O1l = 0;
		nli0O1O = 0;
		nli0Oii = 0;
		nli0Oil = 0;
		nli0OiO = 0;
		nli0Oli = 0;
		nli0Oll = 0;
		nli0OlO = 0;
		nli0OOi = 0;
		nli0OOl = 0;
		nli0OOO = 0;
		nli100l = 0;
		nli101O = 0;
		nli10ii = 0;
		nli10iO = 0;
		nli10ll = 0;
		nli10Oi = 0;
		nli10OO = 0;
		nli110l = 0;
		nli111i = 0;
		nli111O = 0;
		nli11il = 0;
		nli1i0l = 0;
		nli1i1l = 0;
		nli1iii = 0;
		nli1iiO = 0;
		nli1ill = 0;
		nli1iOi = 0;
		nli1iOO = 0;
		nli1l0i = 0;
		nli1l1l = 0;
		nli1lii = 0;
		nli1liO = 0;
		nli1lll = 0;
		nli1lOi = 0;
		nli1lOO = 0;
		nli1O0i = 0;
		nli1O0O = 0;
		nli1O1l = 0;
		nli1Oil = 0;
		nli1OiO = 0;
		nli1Oli = 0;
		nli1Oll = 0;
		nli1OlO = 0;
		nli1OOi = 0;
		nli1OOl = 0;
		nli1OOO = 0;
		nlii00i = 0;
		nlii00l = 0;
		nlii00O = 0;
		nlii01i = 0;
		nlii01l = 0;
		nlii01O = 0;
		nlii0ii = 0;
		nlii0il = 0;
		nlii0iO = 0;
		nlii0li = 0;
		nlii0ll = 0;
		nlii0lO = 0;
		nlii0Oi = 0;
		nlii0Ol = 0;
		nlii0OO = 0;
		nlii10i = 0;
		nlii10l = 0;
		nlii10O = 0;
		nlii11i = 0;
		nlii11l = 0;
		nlii11O = 0;
		nlii1ii = 0;
		nlii1il = 0;
		nlii1iO = 0;
		nlii1li = 0;
		nlii1ll = 0;
		nlii1lO = 0;
		nlii1Oi = 0;
		nlii1Ol = 0;
		nlii1OO = 0;
		nliii0i = 0;
		nliii0l = 0;
		nliii0O = 0;
		nliii1i = 0;
		nliii1l = 0;
		nliii1O = 0;
		nlO0l0l = 0;
		nlO0l0O = 0;
		nlO0lii = 0;
		nlO0lil = 0;
		nlO0liO = 0;
		nlO0lli = 0;
		nlO0lll = 0;
	end
	always @ ( posedge clk or  negedge wire_n1OOO_CLRN)
	begin
		if (wire_n1OOO_CLRN == 1'b0) 
		begin
			n011i <= 0;
			n0l00i <= 0;
			n0l00l <= 0;
			n0l00O <= 0;
			n0l01i <= 0;
			n0l01l <= 0;
			n0l01O <= 0;
			n0l0ii <= 0;
			n0l0il <= 0;
			n0l0iO <= 0;
			n0l0li <= 0;
			n0l0ll <= 0;
			n0l0lO <= 0;
			n0l0Oi <= 0;
			n0l0Ol <= 0;
			n0l0OO <= 0;
			n0li0i <= 0;
			n0li0l <= 0;
			n0li0O <= 0;
			n0li1i <= 0;
			n0li1l <= 0;
			n0li1O <= 0;
			n0liii <= 0;
			n0liil <= 0;
			n0liiO <= 0;
			n0lili <= 0;
			n0lill <= 0;
			n0lilO <= 0;
			n0liOi <= 0;
			n0liOl <= 0;
			n0liOO <= 0;
			n0ll0i <= 0;
			n0ll0l <= 0;
			n0ll0O <= 0;
			n0ll1i <= 0;
			n0ll1l <= 0;
			n0ll1O <= 0;
			n0llii <= 0;
			n0llil <= 0;
			n0lliO <= 0;
			n0llli <= 0;
			n0llll <= 0;
			n0lllO <= 0;
			n0llOi <= 0;
			n0llOl <= 0;
			n0llOO <= 0;
			n0lO0i <= 0;
			n0lO0l <= 0;
			n0lO0O <= 0;
			n0lO1i <= 0;
			n0lO1l <= 0;
			n0lO1O <= 0;
			n0lOii <= 0;
			n0lOil <= 0;
			n0lOiO <= 0;
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
			n0OOii <= 0;
			n0OOil <= 0;
			n0OOiO <= 0;
			n0OOli <= 0;
			n0OOll <= 0;
			n0OOlO <= 0;
			n0OOOi <= 0;
			n0OOOl <= 0;
			n0OOOO <= 0;
			niOO1i <= 0;
			nl0O00i <= 0;
			nl0O00l <= 0;
			nl0O00O <= 0;
			nl0O01i <= 0;
			nl0O01l <= 0;
			nl0O01O <= 0;
			nl0O0ii <= 0;
			nl0O0il <= 0;
			nl0O0iO <= 0;
			nl0O0li <= 0;
			nl0O0ll <= 0;
			nl0O0lO <= 0;
			nl0O0Oi <= 0;
			nl0O0Ol <= 0;
			nl0O0OO <= 0;
			nl0Oi0i <= 0;
			nl0Oi0l <= 0;
			nl0Oi0O <= 0;
			nl0Oi1i <= 0;
			nl0Oi1l <= 0;
			nl0Oi1O <= 0;
			nl0Oili <= 0;
			nl0OilO <= 0;
			nl0OiOl <= 0;
			nl0Ol0l <= 0;
			nl0Ol1i <= 0;
			nl0Ol1O <= 0;
			nl0Olii <= 0;
			nl0OliO <= 0;
			nl0Olll <= 0;
			nl0OlOi <= 0;
			nl0OlOO <= 0;
			nl0OO0i <= 0;
			nl0OO0O <= 0;
			nl0OO1l <= 0;
			nl0OOil <= 0;
			nl0OOli <= 0;
			nl0OOlO <= 0;
			nl0OOOl <= 0;
			nli000i <= 0;
			nli000l <= 0;
			nli000O <= 0;
			nli001i <= 0;
			nli001l <= 0;
			nli001O <= 0;
			nli00ii <= 0;
			nli00il <= 0;
			nli00iO <= 0;
			nli00li <= 0;
			nli00ll <= 0;
			nli00lO <= 0;
			nli00Oi <= 0;
			nli00Ol <= 0;
			nli00OO <= 0;
			nli010i <= 0;
			nli010l <= 0;
			nli010O <= 0;
			nli011i <= 0;
			nli011l <= 0;
			nli011O <= 0;
			nli01ii <= 0;
			nli01il <= 0;
			nli01iO <= 0;
			nli01li <= 0;
			nli01ll <= 0;
			nli01lO <= 0;
			nli01Oi <= 0;
			nli01Ol <= 0;
			nli01OO <= 0;
			nli0i0i <= 0;
			nli0i0l <= 0;
			nli0i0O <= 0;
			nli0i1i <= 0;
			nli0i1l <= 0;
			nli0i1O <= 0;
			nli0iii <= 0;
			nli0iil <= 0;
			nli0iiO <= 0;
			nli0ili <= 0;
			nli0ill <= 0;
			nli0ilO <= 0;
			nli0iOi <= 0;
			nli0iOl <= 0;
			nli0iOO <= 0;
			nli0l0i <= 0;
			nli0l0l <= 0;
			nli0l0O <= 0;
			nli0l1i <= 0;
			nli0l1l <= 0;
			nli0l1O <= 0;
			nli0lii <= 0;
			nli0lil <= 0;
			nli0liO <= 0;
			nli0lli <= 0;
			nli0lll <= 0;
			nli0llO <= 0;
			nli0lOi <= 0;
			nli0lOl <= 0;
			nli0lOO <= 0;
			nli0O0i <= 0;
			nli0O0l <= 0;
			nli0O0O <= 0;
			nli0O1i <= 0;
			nli0O1l <= 0;
			nli0O1O <= 0;
			nli0Oii <= 0;
			nli0Oil <= 0;
			nli0OiO <= 0;
			nli0Oli <= 0;
			nli0Oll <= 0;
			nli0OlO <= 0;
			nli0OOi <= 0;
			nli0OOl <= 0;
			nli0OOO <= 0;
			nli100l <= 0;
			nli101O <= 0;
			nli10ii <= 0;
			nli10iO <= 0;
			nli10ll <= 0;
			nli10Oi <= 0;
			nli10OO <= 0;
			nli110l <= 0;
			nli111i <= 0;
			nli111O <= 0;
			nli11il <= 0;
			nli1i0l <= 0;
			nli1i1l <= 0;
			nli1iii <= 0;
			nli1iiO <= 0;
			nli1ill <= 0;
			nli1iOi <= 0;
			nli1iOO <= 0;
			nli1l0i <= 0;
			nli1l1l <= 0;
			nli1lii <= 0;
			nli1liO <= 0;
			nli1lll <= 0;
			nli1lOi <= 0;
			nli1lOO <= 0;
			nli1O0i <= 0;
			nli1O0O <= 0;
			nli1O1l <= 0;
			nli1Oil <= 0;
			nli1OiO <= 0;
			nli1Oli <= 0;
			nli1Oll <= 0;
			nli1OlO <= 0;
			nli1OOi <= 0;
			nli1OOl <= 0;
			nli1OOO <= 0;
			nlii00i <= 0;
			nlii00l <= 0;
			nlii00O <= 0;
			nlii01i <= 0;
			nlii01l <= 0;
			nlii01O <= 0;
			nlii0ii <= 0;
			nlii0il <= 0;
			nlii0iO <= 0;
			nlii0li <= 0;
			nlii0ll <= 0;
			nlii0lO <= 0;
			nlii0Oi <= 0;
			nlii0Ol <= 0;
			nlii0OO <= 0;
			nlii10i <= 0;
			nlii10l <= 0;
			nlii10O <= 0;
			nlii11i <= 0;
			nlii11l <= 0;
			nlii11O <= 0;
			nlii1ii <= 0;
			nlii1il <= 0;
			nlii1iO <= 0;
			nlii1li <= 0;
			nlii1ll <= 0;
			nlii1lO <= 0;
			nlii1Oi <= 0;
			nlii1Ol <= 0;
			nlii1OO <= 0;
			nliii0i <= 0;
			nliii0l <= 0;
			nliii0O <= 0;
			nliii1i <= 0;
			nliii1l <= 0;
			nliii1O <= 0;
			nlO0l0l <= 0;
			nlO0l0O <= 0;
			nlO0lii <= 0;
			nlO0lil <= 0;
			nlO0liO <= 0;
			nlO0lli <= 0;
			nlO0lll <= 0;
		end
		else 
		begin
			n011i <= n0ll0O;
			n0l00i <= (wire_nl1ii_dataout ^ nl0l1Ol);
			n0l00l <= (wire_nl10O_dataout ^ nl0l1OO);
			n0l00O <= (wire_nl10l_dataout ^ nl0l01i);
			n0l01i <= (wire_nl1li_dataout ^ nl0l1ll);
			n0l01l <= (wire_nl1iO_dataout ^ nl0l1lO);
			n0l01O <= (wire_nl1il_dataout ^ nl0l1Oi);
			n0l0ii <= (wire_nl10i_dataout ^ nl0l01l);
			n0l0il <= (wire_nl11O_dataout ^ nl0l01O);
			n0l0iO <= (wire_nl11l_dataout ^ nl0l00i);
			n0l0li <= (wire_nl11i_dataout ^ nl0l00l);
			n0l0ll <= (wire_niOOO_dataout ^ nl0l00O);
			n0l0lO <= (wire_niOOl_dataout ^ nl0l0il);
			n0l0Oi <= (wire_niOOi_dataout ^ nl0l0li);
			n0l0Ol <= (wire_niOlO_dataout ^ nl0l0ll);
			n0l0OO <= (wire_niOll_dataout ^ nl0l0lO);
			n0li0i <= (wire_niOii_dataout ^ nl0li1i);
			n0li0l <= (wire_niO0O_dataout ^ nl0li1l);
			n0li0O <= (wire_niO0l_dataout ^ nl0li1O);
			n0li1i <= (wire_niOli_dataout ^ nl0l0Oi);
			n0li1l <= (wire_niOiO_dataout ^ nl0l0Ol);
			n0li1O <= (wire_niOil_dataout ^ nl0l0OO);
			n0liii <= (wire_niO0i_dataout ^ nl0li0i);
			n0liil <= (wire_niO1O_dataout ^ nl0li0l);
			n0liiO <= (wire_niO1l_dataout ^ nl0li0O);
			n0lili <= (wire_niO1i_dataout ^ nl0liii);
			n0lill <= (wire_nilOO_dataout ^ nl0liil);
			n0lilO <= (wire_nilOl_dataout ^ nl0liiO);
			n0liOi <= (wire_nilOi_dataout ^ nl0lili);
			n0liOl <= (wire_nillO_dataout ^ nl0lill);
			n0liOO <= (wire_nilll_dataout ^ nl0lilO);
			n0ll0i <= nlO0liO;
			n0ll0l <= nlO0lli;
			n0ll0O <= n0llii;
			n0ll1i <= (wire_nilli_dataout ^ nl0liOi);
			n0ll1l <= (wire_niliO_dataout ^ nl0liOl);
			n0ll1O <= nlO0lil;
			n0llii <= niOO1i;
			n0llil <= n0ll0i;
			n0lliO <= n0ll0l;
			n0llli <= wire_nl101O_dataout;
			n0llll <= wire_nl101l_dataout;
			n0lllO <= wire_nl101i_dataout;
			n0llOi <= wire_nl11OO_dataout;
			n0llOl <= wire_nl11Ol_dataout;
			n0llOO <= wire_nl11Oi_dataout;
			n0lO0i <= wire_nl11iO_dataout;
			n0lO0l <= wire_nl11il_dataout;
			n0lO0O <= wire_nl11ii_dataout;
			n0lO1i <= wire_nl11lO_dataout;
			n0lO1l <= wire_nl11ll_dataout;
			n0lO1O <= wire_nl11li_dataout;
			n0lOii <= wire_nl110O_dataout;
			n0lOil <= wire_nl110l_dataout;
			n0lOiO <= wire_nl110i_dataout;
			n0lOli <= wire_nl111O_dataout;
			n0lOll <= wire_nl111l_dataout;
			n0lOlO <= wire_nl111i_dataout;
			n0lOOi <= wire_niOOOO_dataout;
			n0lOOl <= wire_niOOOl_dataout;
			n0lOOO <= wire_niOOOi_dataout;
			n0O00i <= wire_ni10iO_dataout;
			n0O00l <= wire_ni10il_dataout;
			n0O00O <= wire_ni10ii_dataout;
			n0O01i <= wire_ni10lO_dataout;
			n0O01l <= wire_ni10ll_dataout;
			n0O01O <= wire_ni10li_dataout;
			n0O0ii <= wire_ni100O_dataout;
			n0O0il <= wire_ni100l_dataout;
			n0O0iO <= wire_ni100i_dataout;
			n0O0li <= wire_ni101O_dataout;
			n0O0ll <= wire_ni101l_dataout;
			n0O0lO <= wire_ni101i_dataout;
			n0O0Oi <= wire_ni11OO_dataout;
			n0O0Ol <= wire_ni11Ol_dataout;
			n0O0OO <= wire_ni11Oi_dataout;
			n0O10i <= wire_niOOiO_dataout;
			n0O10l <= wire_niOOil_dataout;
			n0O10O <= wire_niOOii_dataout;
			n0O11i <= wire_niOOlO_dataout;
			n0O11l <= wire_niOOll_dataout;
			n0O11O <= wire_niOOli_dataout;
			n0O1ii <= wire_niOO0O_dataout;
			n0O1il <= wire_niOO0l_dataout;
			n0O1iO <= wire_niOO0i_dataout;
			n0O1li <= wire_niOO1O_dataout;
			n0O1ll <= wire_ni1i1l_dataout;
			n0O1lO <= wire_ni1i1i_dataout;
			n0O1Oi <= wire_ni10OO_dataout;
			n0O1Ol <= wire_ni10Ol_dataout;
			n0O1OO <= wire_ni10Oi_dataout;
			n0Oi0i <= wire_ni11iO_dataout;
			n0Oi0l <= wire_ni11il_dataout;
			n0Oi0O <= wire_ni11ii_dataout;
			n0Oi1i <= wire_ni11lO_dataout;
			n0Oi1l <= wire_ni11ll_dataout;
			n0Oi1O <= wire_ni11li_dataout;
			n0Oiii <= wire_ni110O_dataout;
			n0Oiil <= wire_ni110l_dataout;
			n0OiiO <= wire_ni110i_dataout;
			n0Oili <= wire_ni111O_dataout;
			n0Oill <= wire_ni111l_dataout;
			n0OilO <= (~ n0O1ll);
			n0OiOi <= (~ n0O1lO);
			n0OiOl <= (~ n0O1Oi);
			n0OiOO <= (~ n0O1Ol);
			n0Ol0i <= (~ n0O01O);
			n0Ol0l <= (~ n0O00i);
			n0Ol0O <= (~ n0O00l);
			n0Ol1i <= (~ n0O1OO);
			n0Ol1l <= (~ n0O01i);
			n0Ol1O <= (~ n0O01l);
			n0Olii <= (~ n0O00O);
			n0Olil <= (~ n0O0ii);
			n0OliO <= (~ n0O0il);
			n0Olli <= (~ n0O0iO);
			n0Olll <= (~ n0O0li);
			n0OllO <= (~ n0O0ll);
			n0OlOi <= (~ n0O0lO);
			n0OlOl <= (~ n0O0Oi);
			n0OlOO <= (~ n0O0Ol);
			n0OO0i <= (~ n0Oi1O);
			n0OO0l <= (~ n0Oi0i);
			n0OO0O <= (~ n0Oi0l);
			n0OO1i <= (~ n0O0OO);
			n0OO1l <= (~ n0Oi1i);
			n0OO1O <= (~ n0Oi1l);
			n0OOii <= (~ n0Oi0O);
			n0OOil <= (~ n0Oiii);
			n0OOiO <= (~ n0Oiil);
			n0OOli <= (~ n0OiiO);
			n0OOll <= (~ n0Oili);
			n0OOlO <= (~ n0Oill);
			n0OOOi <= (~ n0OOOl);
			n0OOOl <= wire_ni111i_dataout;
			n0OOOO <= wire_niOO1l_dataout;
			niOO1i <= (nlO0lii & nlO0l0O);
			nl0O00i <= empty[1];
			nl0O00l <= empty[0];
			nl0O00O <= startofpacket;
			nl0O01i <= datavalid;
			nl0O01l <= endofpacket;
			nl0O01O <= empty[2];
			nl0O0ii <= data[63];
			nl0O0il <= data[62];
			nl0O0iO <= data[61];
			nl0O0li <= data[60];
			nl0O0ll <= data[59];
			nl0O0lO <= data[58];
			nl0O0Oi <= data[57];
			nl0O0Ol <= data[56];
			nl0O0OO <= data[55];
			nl0Oi0i <= data[51];
			nl0Oi0l <= data[50];
			nl0Oi0O <= data[49];
			nl0Oi1i <= data[54];
			nl0Oi1l <= data[53];
			nl0Oi1O <= data[52];
			nl0Oili <= data[0];
			nl0OilO <= data[1];
			nl0OiOl <= data[2];
			nl0Ol0l <= data[5];
			nl0Ol1i <= data[3];
			nl0Ol1O <= data[4];
			nl0Olii <= data[6];
			nl0OliO <= data[7];
			nl0Olll <= data[8];
			nl0OlOi <= data[9];
			nl0OlOO <= data[10];
			nl0OO0i <= data[12];
			nl0OO0O <= data[13];
			nl0OO1l <= data[11];
			nl0OOil <= data[14];
			nl0OOli <= data[15];
			nl0OOlO <= data[16];
			nl0OOOl <= data[17];
			nli000i <= (nl0O0li ^ (nl0O0il ^ (wire_nli1l1O_dataout ^ (wire_nli100O_dataout ^ (wire_nli11Ol_dataout ^ wire_nl0OlOl_dataout)))));
			nli000l <= (nl0O0Ol ^ (wire_nli1llO_dataout ^ (wire_nli1l0O_dataout ^ (wire_nli1i0O_dataout ^ nl0i1Ol))));
			nli000O <= (nl0O0Oi ^ (nl0O0ll ^ (nl0O0li ^ (nl0O0ii ^ (wire_nli1i1i_dataout ^ wire_nli11ll_dataout)))));
			nli001i <= (wire_nli1lli_dataout ^ (wire_nli1i0i_dataout ^ (wire_nli10il_dataout ^ (wire_nli101i_dataout ^ (wire_nli11lO_dataout ^ wire_nl0Olil_dataout)))));
			nli001l <= (nl0O0lO ^ (nl0O0il ^ (wire_nli1ili_dataout ^ (wire_nli1i0O_dataout ^ (wire_nli1i1i_dataout ^ wire_nli11Oi_dataout)))));
			nli001O <= (nl0O0lO ^ (nl0O0ii ^ (wire_nli1lOl_dataout ^ (wire_nli1ilO_dataout ^ (wire_nli10Ol_dataout ^ wire_nl0OOOO_dataout)))));
			nli00ii <= (nl0O0il ^ (wire_nli1llO_dataout ^ (wire_nli11Oi_dataout ^ (wire_nl0OOiO_dataout ^ (wire_nl0OO1i_dataout ^ wire_nl0Olil_dataout)))));
			nli00il <= (nl0O0ii ^ (wire_nli1llO_dataout ^ (wire_nli1l1O_dataout ^ (wire_nl0OOii_dataout ^ (wire_nl0OiOO_dataout ^ wire_nl0Oiii_dataout)))));
			nli00iO <= (wire_nli1O1O_dataout ^ (wire_nli1l1O_dataout ^ (wire_nli1ilO_dataout ^ (wire_nli11Ol_dataout ^ (wire_nl0Ol0O_dataout ^ wire_nl0OiOO_dataout)))));
			nli00li <= (wire_nli1i0i_dataout ^ (wire_nli100i_dataout ^ (wire_nl0OOOO_dataout ^ (wire_nl0OllO_dataout ^ (wire_nl0Ol0O_dataout ^ wire_nl0Oill_dataout)))));
			nli00ll <= (nl0O0Oi ^ (wire_nli1O0l_dataout ^ (wire_nli1O1i_dataout ^ (wire_nli1iOl_dataout ^ (wire_nli11lO_dataout ^ wire_nli11ll_dataout)))));
			nli00lO <= (wire_nli1O1O_dataout ^ (wire_nli10Ol_dataout ^ (wire_nli11lO_dataout ^ (wire_nli11li_dataout ^ (wire_nl0OOOO_dataout ^ wire_nl0Ol0O_dataout)))));
			nli00Oi <= (wire_nli1lil_dataout ^ (wire_nli101i_dataout ^ (wire_nli110i_dataout ^ (wire_nl0OO1O_dataout ^ nl0i10O))));
			nli00Ol <= (wire_nli1O1i_dataout ^ (wire_nli1lOl_dataout ^ (wire_nli1llO_dataout ^ (wire_nli1lli_dataout ^ (wire_nli1lil_dataout ^ wire_nli1iil_dataout)))));
			nli00OO <= (wire_nli1lli_dataout ^ (wire_nli1ili_dataout ^ (wire_nli11Ol_dataout ^ (wire_nli110O_dataout ^ (wire_nl0Olli_dataout ^ wire_nl0Ol0i_dataout)))));
			nli010i <= (nl0O0Ol ^ (wire_nli1O1O_dataout ^ (wire_nli1l1i_dataout ^ (wire_nli1ili_dataout ^ (wire_nli10Ol_dataout ^ wire_nl0Oiil_dataout)))));
			nli010l <= (nl0O0iO ^ (nl0O0il ^ (wire_nli10li_dataout ^ (wire_nli100i_dataout ^ (wire_nli11lO_dataout ^ wire_nl0OOOO_dataout)))));
			nli010O <= (wire_nli1O0l_dataout ^ (wire_nli1O1O_dataout ^ (wire_nli1iil_dataout ^ (wire_nl0OOOi_dataout ^ nl0i1lO))));
			nli011i <= (nl0O0iO ^ (wire_nli1l0O_dataout ^ (wire_nli101i_dataout ^ (wire_nl0OOOi_dataout ^ (wire_nl0OO0l_dataout ^ wire_nl0OiiO_dataout)))));
			nli011l <= (nl0O0ll ^ (wire_nli1O0l_dataout ^ (wire_nli1lli_dataout ^ (wire_nli11OO_dataout ^ (wire_nli111l_dataout ^ wire_nl0OOii_dataout)))));
			nli011O <= (nl0O0ll ^ (nl0O0iO ^ (wire_nli1O1i_dataout ^ (wire_nli10lO_dataout ^ (wire_nli10il_dataout ^ wire_nli11Ol_dataout)))));
			nli01ii <= (nl0O0Oi ^ (wire_nli1iil_dataout ^ (wire_nli11li_dataout ^ (wire_nli111l_dataout ^ (wire_nl0Ol0i_dataout ^ wire_nl0Ol1l_dataout)))));
			nli01il <= (wire_nli1lli_dataout ^ (wire_nli100O_dataout ^ (wire_nli11Oi_dataout ^ (wire_nli11ll_dataout ^ (wire_nl0OO1O_dataout ^ wire_nl0Olli_dataout)))));
			nli01iO <= (wire_nli1l0O_dataout ^ (wire_nli1l1O_dataout ^ (wire_nli1iOl_dataout ^ (wire_nli11li_dataout ^ (wire_nl0Olil_dataout ^ wire_nl0Ol1l_dataout)))));
			nli01li <= (nl0O0Oi ^ (nl0O0iO ^ (wire_nli1l0O_dataout ^ (wire_nli11li_dataout ^ (wire_nl0OO1i_dataout ^ wire_nl0Olli_dataout)))));
			nli01ll <= (nl0O0Ol ^ (nl0O0lO ^ (nl0O0iO ^ (wire_nli1iOl_dataout ^ (wire_nli11Ol_dataout ^ wire_nli110i_dataout)))));
			nli01lO <= (nl0O0Ol ^ (nl0O0lO ^ (wire_nli1i1i_dataout ^ (wire_nli11iO_dataout ^ nl0i1li))));
			nli01Oi <= (nl0O0lO ^ (wire_nl0OOOi_dataout ^ (wire_nl0OlOl_dataout ^ (wire_nl0OllO_dataout ^ (wire_nl0Olil_dataout ^ wire_nl0Oiii_dataout)))));
			nli01Ol <= (wire_nli1O1i_dataout ^ (wire_nli1i1i_dataout ^ (wire_nli10lO_dataout ^ (wire_nli10li_dataout ^ (wire_nl0OOll_dataout ^ wire_nl0OiiO_dataout)))));
			nli01OO <= (nl0O0li ^ (wire_nli1O1O_dataout ^ (wire_nli1l1O_dataout ^ (wire_nli11iO_dataout ^ (wire_nl0OOiO_dataout ^ wire_nl0Oiii_dataout)))));
			nli0i0i <= (nl0O0li ^ (wire_nli1ilO_dataout ^ (wire_nli101i_dataout ^ nl0i1ll)));
			nli0i0l <= (wire_nli1lOl_dataout ^ (wire_nli1lil_dataout ^ (wire_nli100i_dataout ^ (wire_nl0OlOl_dataout ^ nl0i1Oi))));
			nli0i0O <= (nl0O0il ^ (wire_nli101i_dataout ^ (wire_nli11Oi_dataout ^ (wire_nli110i_dataout ^ (wire_nl0OOll_dataout ^ wire_nl0Oill_dataout)))));
			nli0i1i <= (wire_nli1iOl_dataout ^ (wire_nli11ll_dataout ^ (wire_nli11li_dataout ^ (wire_nl0OO0l_dataout ^ (wire_nl0OlOl_dataout ^ wire_nl0OiOi_dataout)))));
			nli0i1l <= (nl0O0li ^ (wire_nli1lli_dataout ^ (wire_nli1ilO_dataout ^ (wire_nli11ll_dataout ^ (wire_nli110i_dataout ^ wire_nl0OlOl_dataout)))));
			nli0i1O <= (wire_nli1l1O_dataout ^ (wire_nli10lO_dataout ^ (wire_nli10li_dataout ^ (wire_nli10il_dataout ^ (wire_nl0OOOO_dataout ^ wire_nl0OO1O_dataout)))));
			nli0iii <= (wire_nli1l1O_dataout ^ (wire_nli1l1i_dataout ^ (wire_nli100O_dataout ^ (wire_nl0OOiO_dataout ^ (wire_nl0OOii_dataout ^ wire_nl0OO1i_dataout)))));
			nli0iil <= (nl0O0li ^ (wire_nli10lO_dataout ^ (wire_nli101l_dataout ^ (wire_nli110O_dataout ^ (wire_nli111l_dataout ^ wire_nl0Ol1l_dataout)))));
			nli0iiO <= (wire_nli1iil_dataout ^ (wire_nli11Ol_dataout ^ (wire_nli111l_dataout ^ (wire_nl0Ol0i_dataout ^ (wire_nl0OiOO_dataout ^ wire_nl0OiOi_dataout)))));
			nli0ili <= (wire_nli1O0l_dataout ^ (wire_nli101l_dataout ^ (wire_nli101i_dataout ^ (wire_nli11Oi_dataout ^ (wire_nl0OOii_dataout ^ wire_nl0Oill_dataout)))));
			nli0ill <= (nl0O0lO ^ (nl0O0ii ^ (wire_nli10il_dataout ^ (wire_nl0OOll_dataout ^ (wire_nl0OOiO_dataout ^ wire_nl0Olli_dataout)))));
			nli0ilO <= (nl0O0Oi ^ (nl0O0il ^ (wire_nli1l1i_dataout ^ (wire_nli11OO_dataout ^ nl0i1OO))));
			nli0iOi <= (wire_nli1l1i_dataout ^ (wire_nli11lO_dataout ^ (wire_nl0OllO_dataout ^ nl0i1ll)));
			nli0iOl <= (wire_nli1lOl_dataout ^ (wire_nli1iOl_dataout ^ (wire_nli100O_dataout ^ (wire_nli100i_dataout ^ (wire_nl0OiOi_dataout ^ wire_nl0Oiii_dataout)))));
			nli0iOO <= (nl0O0iO ^ (wire_nli1lOl_dataout ^ (wire_nli10Ol_dataout ^ (wire_nli100O_dataout ^ (wire_nl0OOii_dataout ^ wire_nl0OO1O_dataout)))));
			nli0l0i <= (nl0O0ll ^ (wire_nli11lO_dataout ^ (wire_nli11iO_dataout ^ (wire_nl0OO0l_dataout ^ (wire_nl0Olil_dataout ^ wire_nl0Ol0O_dataout)))));
			nli0l0l <= (nl0O0Ol ^ (wire_nli101i_dataout ^ (wire_nli11lO_dataout ^ (wire_nl0OOOi_dataout ^ (wire_nl0OO1i_dataout ^ wire_nl0OiiO_dataout)))));
			nli0l0O <= (nl0O0Oi ^ (wire_nli1iOl_dataout ^ (wire_nli101l_dataout ^ (wire_nli11iO_dataout ^ (wire_nl0OOll_dataout ^ wire_nl0OlOl_dataout)))));
			nli0l1i <= (wire_nli1lil_dataout ^ (wire_nli1l0O_dataout ^ (wire_nli1ili_dataout ^ (wire_nli11li_dataout ^ (wire_nli110O_dataout ^ wire_nl0OiOi_dataout)))));
			nli0l1l <= (nl0O0lO ^ (nl0O0ll ^ (wire_nli1ili_dataout ^ (wire_nli1i0O_dataout ^ (wire_nli1i0i_dataout ^ wire_nl0Oiil_dataout)))));
			nli0l1O <= (nl0O0ll ^ (nl0O0li ^ (wire_nli1lOl_dataout ^ (wire_nl0OO1i_dataout ^ (wire_nl0Olli_dataout ^ wire_nl0Oill_dataout)))));
			nli0lii <= (nl0O0iO ^ (nl0O0il ^ (wire_nli1l1O_dataout ^ (wire_nli101i_dataout ^ (wire_nli11iO_dataout ^ wire_nl0OOll_dataout)))));
			nli0lil <= (nl0O0ll ^ (nl0O0ii ^ (wire_nli1lli_dataout ^ (wire_nli1i0i_dataout ^ (wire_nli101l_dataout ^ wire_nl0OO1O_dataout)))));
			nli0liO <= (nl0O0Ol ^ (wire_nli1llO_dataout ^ (wire_nli11ll_dataout ^ (wire_nl0OOiO_dataout ^ nl0i1iO))));
			nli0lli <= (nl0O0Ol ^ (wire_nli1llO_dataout ^ (wire_nli1l1O_dataout ^ (wire_nli10Ol_dataout ^ (wire_nl0OiiO_dataout ^ wire_nl0Oiii_dataout)))));
			nli0lll <= (wire_nli1lOl_dataout ^ (wire_nli1l1i_dataout ^ (wire_nli10Ol_dataout ^ (wire_nli11iO_dataout ^ (wire_nl0OOll_dataout ^ wire_nl0Ol1l_dataout)))));
			nli0llO <= (nl0O0iO ^ (wire_nli1l0O_dataout ^ (wire_nli101l_dataout ^ (wire_nli110O_dataout ^ (wire_nl0OO1i_dataout ^ wire_nl0Ol0i_dataout)))));
			nli0lOi <= (wire_nli1i0O_dataout ^ (wire_nli1i0i_dataout ^ (wire_nli10lO_dataout ^ (wire_nli11Oi_dataout ^ nl0i1il))));
			nli0lOl <= (wire_nli1O1O_dataout ^ (wire_nli1lli_dataout ^ (wire_nli10il_dataout ^ (wire_nli100O_dataout ^ (wire_nli11ll_dataout ^ wire_nl0Oill_dataout)))));
			nli0lOO <= (wire_nli1O1i_dataout ^ (wire_nli1i0i_dataout ^ (wire_nli101l_dataout ^ (wire_nli11lO_dataout ^ (wire_nl0OOOO_dataout ^ wire_nl0Ol0i_dataout)))));
			nli0O0i <= (wire_nli1i0O_dataout ^ (wire_nl0OOOi_dataout ^ (wire_nl0OOll_dataout ^ (wire_nl0OlOl_dataout ^ (wire_nl0Ol1l_dataout ^ wire_nl0Oiil_dataout)))));
			nli0O0l <= (wire_nli1lOl_dataout ^ (wire_nli1iil_dataout ^ (wire_nli11lO_dataout ^ (wire_nli111l_dataout ^ (wire_nl0OlOl_dataout ^ wire_nl0OllO_dataout)))));
			nli0O0O <= (wire_nli1lil_dataout ^ (wire_nli1i0i_dataout ^ (wire_nli10Ol_dataout ^ (wire_nli10li_dataout ^ nl0i1li))));
			nli0O1i <= (nl0O0Ol ^ (nl0O0Oi ^ (wire_nli1lli_dataout ^ (wire_nli1ilO_dataout ^ (wire_nli1i0O_dataout ^ wire_nli100i_dataout)))));
			nli0O1l <= (wire_nli1O1i_dataout ^ (wire_nli1lOl_dataout ^ (wire_nli11Ol_dataout ^ (wire_nli11Oi_dataout ^ (wire_nli11li_dataout ^ wire_nli110O_dataout)))));
			nli0O1O <= (wire_nli1O1i_dataout ^ (wire_nli1ili_dataout ^ (wire_nli10Ol_dataout ^ (wire_nl0OO0l_dataout ^ (wire_nl0OO1O_dataout ^ wire_nl0OO1i_dataout)))));
			nli0Oii <= (nl0O0iO ^ (wire_nli1lOl_dataout ^ (wire_nli1iil_dataout ^ (wire_nli10li_dataout ^ (wire_nli11lO_dataout ^ wire_nl0OiOO_dataout)))));
			nli0Oil <= (nl0O0ii ^ (wire_nli1lil_dataout ^ (wire_nli1l0O_dataout ^ (wire_nli11Ol_dataout ^ (wire_nl0OO1O_dataout ^ wire_nl0OiOi_dataout)))));
			nli0OiO <= (nl0O0il ^ (wire_nli1lil_dataout ^ (wire_nli1i0i_dataout ^ (wire_nli1i1i_dataout ^ (wire_nli10li_dataout ^ wire_nli11iO_dataout)))));
			nli0Oli <= (nl0O0iO ^ (wire_nli1O1i_dataout ^ (wire_nli100O_dataout ^ (wire_nli11ll_dataout ^ (wire_nli11iO_dataout ^ wire_nli110i_dataout)))));
			nli0Oll <= (nl0O0li ^ (wire_nli1ilO_dataout ^ (wire_nli10lO_dataout ^ (wire_nli110i_dataout ^ (wire_nli111l_dataout ^ wire_nl0OOOi_dataout)))));
			nli0OlO <= (wire_nli1lOl_dataout ^ (wire_nli1i0O_dataout ^ (wire_nli10Ol_dataout ^ (wire_nl0OOii_dataout ^ (wire_nl0Ol0i_dataout ^ wire_nl0Oiil_dataout)))));
			nli0OOi <= (nl0O0Ol ^ (wire_nli1O0l_dataout ^ (wire_nli1llO_dataout ^ (wire_nli1ilO_dataout ^ (wire_nli11OO_dataout ^ wire_nl0OllO_dataout)))));
			nli0OOl <= (nl0O0lO ^ (wire_nli1ilO_dataout ^ (wire_nli11iO_dataout ^ (wire_nl0OlOl_dataout ^ (wire_nl0Olli_dataout ^ wire_nl0Oiii_dataout)))));
			nli0OOO <= (wire_nli1O1i_dataout ^ (wire_nli1lOl_dataout ^ (wire_nli1ili_dataout ^ (wire_nli1i0i_dataout ^ (wire_nl0Ol0i_dataout ^ wire_nl0OiiO_dataout)))));
			nli100l <= data[23];
			nli101O <= data[22];
			nli10ii <= data[24];
			nli10iO <= data[25];
			nli10ll <= data[26];
			nli10Oi <= data[27];
			nli10OO <= data[28];
			nli110l <= data[20];
			nli111i <= data[18];
			nli111O <= data[19];
			nli11il <= data[21];
			nli1i0l <= data[30];
			nli1i1l <= data[29];
			nli1iii <= data[31];
			nli1iiO <= data[32];
			nli1ill <= data[33];
			nli1iOi <= data[34];
			nli1iOO <= data[35];
			nli1l0i <= data[37];
			nli1l1l <= data[36];
			nli1lii <= data[38];
			nli1liO <= data[39];
			nli1lll <= data[40];
			nli1lOi <= data[41];
			nli1lOO <= data[42];
			nli1O0i <= data[44];
			nli1O0O <= data[45];
			nli1O1l <= data[43];
			nli1Oil <= data[46];
			nli1OiO <= data[47];
			nli1Oli <= data[48];
			nli1Oll <= (wire_nli10il_dataout ^ (wire_nli101l_dataout ^ (wire_nli11OO_dataout ^ (wire_nli11ll_dataout ^ (wire_nli11iO_dataout ^ wire_nl0Ol0O_dataout)))));
			nli1OlO <= (wire_nli1i0i_dataout ^ (wire_nl0OOOi_dataout ^ (wire_nl0OOiO_dataout ^ (wire_nl0OO1O_dataout ^ nl0i1Ol))));
			nli1OOi <= (nl0O0lO ^ (nl0O0ii ^ (wire_nli1l1i_dataout ^ (wire_nl0OO0l_dataout ^ nl0i1Oi))));
			nli1OOl <= (nl0O0li ^ (wire_nli1lil_dataout ^ (wire_nli100i_dataout ^ (wire_nli11Ol_dataout ^ (wire_nl0OllO_dataout ^ wire_nl0Ol0O_dataout)))));
			nli1OOO <= (wire_nli1l1i_dataout ^ (wire_nli1iOl_dataout ^ (wire_nli1ili_dataout ^ (wire_nli10lO_dataout ^ (wire_nli110i_dataout ^ wire_nl0OiiO_dataout)))));
			nlii00i <= wire_nl0Oiil_dataout;
			nlii00l <= (wire_nli1O0l_dataout ^ (wire_nli1O1O_dataout ^ (wire_nl0OOOi_dataout ^ (wire_nl0Ol1l_dataout ^ wire_nl0Oill_dataout))));
			nlii00O <= (nl0O0ii ^ (wire_nli1i0i_dataout ^ (wire_nl0OO0l_dataout ^ wire_nl0Oill_dataout)));
			nlii01i <= (wire_nli100i_dataout ^ (wire_nli11Ol_dataout ^ (wire_nli11lO_dataout ^ (wire_nl0OO1O_dataout ^ wire_nl0Oiii_dataout))));
			nlii01l <= (nl0O0Ol ^ (nl0O0ll ^ (wire_nli1ilO_dataout ^ wire_nli1ili_dataout)));
			nlii01O <= (wire_nli1l1i_dataout ^ nl0O0Oi);
			nlii0ii <= (wire_nli1l0O_dataout ^ wire_nl0OiOi_dataout);
			nlii0il <= (wire_nli1lOl_dataout ^ (wire_nli10Ol_dataout ^ (wire_nli11OO_dataout ^ (wire_nli110O_dataout ^ (wire_nl0OOll_dataout ^ wire_nl0Oiil_dataout)))));
			nlii0iO <= (wire_nli1O1i_dataout ^ (wire_nli1lil_dataout ^ (wire_nli1l1i_dataout ^ (wire_nli1i1i_dataout ^ nl0i1ii))));
			nlii0li <= (wire_nli1O0l_dataout ^ (wire_nli1llO_dataout ^ (wire_nli1l1O_dataout ^ (wire_nli11Oi_dataout ^ (wire_nli110i_dataout ^ wire_nl0Ol0i_dataout)))));
			nlii0ll <= (nl0O0Ol ^ (nl0O0il ^ (wire_nli10li_dataout ^ (wire_nli100O_dataout ^ (wire_nl0Ol0O_dataout ^ wire_nl0OiiO_dataout)))));
			nlii0lO <= (nl0O0Oi ^ (nl0O0ll ^ nl0i10O));
			nlii0Oi <= (wire_nli1l0O_dataout ^ (wire_nli1ilO_dataout ^ (wire_nli1ili_dataout ^ (wire_nli1i0O_dataout ^ (wire_nli10li_dataout ^ wire_nli110O_dataout)))));
			nlii0Ol <= (wire_nli11Ol_dataout ^ wire_nl0OO0l_dataout);
			nlii0OO <= (nl0O0lO ^ (wire_nli1O1i_dataout ^ (wire_nli10il_dataout ^ (wire_nl0OOOO_dataout ^ (wire_nl0Olil_dataout ^ wire_nl0OiiO_dataout)))));
			nlii10i <= (wire_nli1lli_dataout ^ (wire_nli1iOl_dataout ^ (wire_nli110i_dataout ^ (wire_nl0OO1O_dataout ^ nl0i1iO))));
			nlii10l <= (nl0O0Oi ^ (wire_nli1llO_dataout ^ (wire_nli1i1i_dataout ^ (wire_nli11Ol_dataout ^ (wire_nli111l_dataout ^ wire_nl0OOiO_dataout)))));
			nlii10O <= (wire_nli11OO_dataout ^ nl0O0Ol);
			nlii11i <= (wire_nli1O1O_dataout ^ (wire_nli100O_dataout ^ (wire_nli11li_dataout ^ (wire_nl0Olil_dataout ^ (wire_nl0OiOO_dataout ^ wire_nl0Oill_dataout)))));
			nlii11l <= (nl0O0Oi ^ (wire_nli11OO_dataout ^ (wire_nli110O_dataout ^ (wire_nl0OOiO_dataout ^ (wire_nl0OiOO_dataout ^ wire_nl0Oiil_dataout)))));
			nlii11O <= (nl0O0ii ^ (wire_nli1l0O_dataout ^ (wire_nli100i_dataout ^ (wire_nli101i_dataout ^ (wire_nl0OOOO_dataout ^ wire_nl0OO0l_dataout)))));
			nlii1ii <= (nl0O0ii ^ (wire_nli1lOl_dataout ^ (wire_nli1lil_dataout ^ nl0i1ii)));
			nlii1il <= (wire_nli1O0l_dataout ^ (wire_nli100O_dataout ^ (wire_nli11Oi_dataout ^ wire_nl0Oiil_dataout)));
			nlii1iO <= (wire_nli1iOl_dataout ^ wire_nli110O_dataout);
			nlii1li <= (nl0O0Oi ^ (wire_nli1i1i_dataout ^ (wire_nli11OO_dataout ^ wire_nli11li_dataout)));
			nlii1ll <= (nl0O0ll ^ (wire_nli1l1i_dataout ^ (wire_nli1ilO_dataout ^ nl0i1il)));
			nlii1lO <= (wire_nli1ilO_dataout ^ nl0O0Ol);
			nlii1Oi <= (nl0O0lO ^ (wire_nli10li_dataout ^ (wire_nli101l_dataout ^ wire_nli111l_dataout)));
			nlii1Ol <= (nl0O0li ^ (wire_nli110i_dataout ^ (wire_nl0Ol0O_dataout ^ wire_nl0Ol1l_dataout)));
			nlii1OO <= (wire_nli1l1i_dataout ^ (wire_nli10lO_dataout ^ wire_nli10li_dataout));
			nliii0i <= (nl0O0ii ^ (wire_nli1l1O_dataout ^ (wire_nli10li_dataout ^ (wire_nli100i_dataout ^ nl0i1lO))));
			nliii0l <= (nl0O0ll ^ (wire_nli1iOl_dataout ^ (wire_nli1i0O_dataout ^ (wire_nli10Ol_dataout ^ wire_nli11lO_dataout))));
			nliii0O <= (nl0O0li ^ (wire_nli1l1i_dataout ^ (wire_nli11Oi_dataout ^ wire_nli11lO_dataout)));
			nliii1i <= wire_nli11iO_dataout;
			nliii1l <= (wire_nli1l1O_dataout ^ (wire_nli1ili_dataout ^ (wire_nli1i0O_dataout ^ (wire_nli11iO_dataout ^ wire_nl0Olli_dataout))));
			nliii1O <= (nl0O0iO ^ (wire_nl0OOOi_dataout ^ (wire_nl0OO1O_dataout ^ (wire_nl0OllO_dataout ^ wire_nl0OiOi_dataout))));
			nlO0l0l <= (wire_nli1ili_dataout ^ (wire_nli10li_dataout ^ (wire_nli101i_dataout ^ nl0i1OO)));
			nlO0l0O <= nl0O01i;
			nlO0lii <= nl0O01l;
			nlO0lil <= nl0O01O;
			nlO0liO <= nl0O00i;
			nlO0lli <= nl0O00l;
			nlO0lll <= nl0O00O;
		end
	end
	assign
		wire_n1OOO_CLRN = (nl0l1li44 ^ nl0l1li43);
	initial
	begin
		n000i = 0;
		n000l = 0;
		n000O = 0;
		n001i = 0;
		n001l = 0;
		n001O = 0;
		n00ii = 0;
		n00il = 0;
		n00iO = 0;
		n00li = 0;
		n00ll = 0;
		n00lO = 0;
		n00Oi = 0;
		n00Ol = 0;
		n00OO = 0;
		n010i = 0;
		n010l = 0;
		n010O = 0;
		n011l = 0;
		n011O = 0;
		n01ii = 0;
		n01il = 0;
		n01iO = 0;
		n01li = 0;
		n01ll = 0;
		n01lO = 0;
		n01Oi = 0;
		n01Ol = 0;
		n01OO = 0;
		n0i1i = 0;
		n0i1l = 0;
		nliOO = 0;
	end
	always @ ( posedge clk or  negedge wire_nliOl_CLRN)
	begin
		if (wire_nliOl_CLRN == 1'b0) 
		begin
			n000i <= 0;
			n000l <= 0;
			n000O <= 0;
			n001i <= 0;
			n001l <= 0;
			n001O <= 0;
			n00ii <= 0;
			n00il <= 0;
			n00iO <= 0;
			n00li <= 0;
			n00ll <= 0;
			n00lO <= 0;
			n00Oi <= 0;
			n00Ol <= 0;
			n00OO <= 0;
			n010i <= 0;
			n010l <= 0;
			n010O <= 0;
			n011l <= 0;
			n011O <= 0;
			n01ii <= 0;
			n01il <= 0;
			n01iO <= 0;
			n01li <= 0;
			n01ll <= 0;
			n01lO <= 0;
			n01Oi <= 0;
			n01Ol <= 0;
			n01OO <= 0;
			n0i1i <= 0;
			n0i1l <= 0;
			nliOO <= 0;
		end
		else if  (nlO0l0O == 1'b1) 
		begin
			n000i <= wire_n0l0O_dataout;
			n000l <= wire_n0lii_dataout;
			n000O <= wire_n0lil_dataout;
			n001i <= wire_n0l1O_dataout;
			n001l <= wire_n0l0i_dataout;
			n001O <= wire_n0l0l_dataout;
			n00ii <= wire_n0liO_dataout;
			n00il <= wire_n0lli_dataout;
			n00iO <= wire_n0lll_dataout;
			n00li <= wire_n0llO_dataout;
			n00ll <= wire_n0lOi_dataout;
			n00lO <= wire_n0lOl_dataout;
			n00Oi <= wire_n0lOO_dataout;
			n00Ol <= wire_n0O1i_dataout;
			n00OO <= wire_n0O1l_dataout;
			n010i <= wire_n0i0O_dataout;
			n010l <= wire_n0iii_dataout;
			n010O <= wire_n0iil_dataout;
			n011l <= wire_n0i0i_dataout;
			n011O <= wire_n0i0l_dataout;
			n01ii <= wire_n0iiO_dataout;
			n01il <= wire_n0ili_dataout;
			n01iO <= wire_n0ill_dataout;
			n01li <= wire_n0ilO_dataout;
			n01ll <= wire_n0iOi_dataout;
			n01lO <= wire_n0iOl_dataout;
			n01Oi <= wire_n0iOO_dataout;
			n01Ol <= wire_n0l1i_dataout;
			n01OO <= wire_n0l1l_dataout;
			n0i1i <= wire_n0O1O_dataout;
			n0i1l <= wire_n0O0i_dataout;
			nliOO <= wire_n0i1O_dataout;
		end
	end
	assign
		wire_nliOl_CLRN = ((nl0O1OO2 ^ nl0O1OO1) & reset_n);
	and(wire_n0i0i_dataout, nl0liOi, ~(nlO0lii));
	and(wire_n0i0l_dataout, nl0lilO, ~(nlO0lii));
	and(wire_n0i0O_dataout, nl0lill, ~(nlO0lii));
	and(wire_n0i1O_dataout, nl0liOl, ~(nlO0lii));
	and(wire_n0iii_dataout, nl0lili, ~(nlO0lii));
	and(wire_n0iil_dataout, nl0liiO, ~(nlO0lii));
	and(wire_n0iiO_dataout, nl0liil, ~(nlO0lii));
	and(wire_n0ili_dataout, nl0liii, ~(nlO0lii));
	and(wire_n0ill_dataout, nl0li0O, ~(nlO0lii));
	and(wire_n0ilO_dataout, nl0li0l, ~(nlO0lii));
	and(wire_n0iOi_dataout, nl0li0i, ~(nlO0lii));
	and(wire_n0iOl_dataout, nl0li1O, ~(nlO0lii));
	and(wire_n0iOO_dataout, nl0li1l, ~(nlO0lii));
	and(wire_n0l0i_dataout, nl0l0Oi, ~(nlO0lii));
	and(wire_n0l0l_dataout, nl0l0lO, ~(nlO0lii));
	and(wire_n0l0O_dataout, nl0l0ll, ~(nlO0lii));
	and(wire_n0l1i_dataout, nl0li1i, ~(nlO0lii));
	and(wire_n0l1l_dataout, nl0l0OO, ~(nlO0lii));
	and(wire_n0l1O_dataout, nl0l0Ol, ~(nlO0lii));
	and(wire_n0lii_dataout, nl0l0li, ~(nlO0lii));
	and(wire_n0lil_dataout, nl0l0il, ~(nlO0lii));
	and(wire_n0liO_dataout, nl0l00O, ~(nlO0lii));
	and(wire_n0lli_dataout, nl0l00l, ~(nlO0lii));
	and(wire_n0lll_dataout, nl0l00i, ~(nlO0lii));
	and(wire_n0llO_dataout, nl0l01O, ~(nlO0lii));
	and(wire_n0lOi_dataout, nl0l01l, ~(nlO0lii));
	and(wire_n0lOl_dataout, nl0l01i, ~(nlO0lii));
	and(wire_n0lOO_dataout, nl0l1OO, ~(nlO0lii));
	and(wire_n0O0i_dataout, nl0l1ll, ~(nlO0lii));
	and(wire_n0O1i_dataout, nl0l1Ol, ~(nlO0lii));
	and(wire_n0O1l_dataout, nl0l1Oi, ~(nlO0lii));
	and(wire_n0O1O_dataout, nl0l1lO, ~(nlO0lii));
	assign		wire_ni0iii_dataout = (n0llil === 1'b1) ? ((((((((n0OOOO ^ n0O1ii) ^ n0O10O) ^ n0O10i) ^ n0O11l) ^ n0lOOO) ^ n0lOOi) ^ n0lOll) ^ n0lOli) : n0OOOO;
	assign		wire_ni0iil_dataout = (n0llil === 1'b1) ? ((((((((((((nl0iO0O ^ n0O1ii) ^ n0O10l) ^ n0O10i) ^ n0O11O) ^ n0O11l) ^ n0O11i) ^ n0lOOO) ^ n0lOOl) ^ n0lOOi) ^ n0lOlO) ^ n0lOll) ^ n0lOiO) : n0O1li;
	assign		wire_ni0iiO_dataout = (n0llil === 1'b1) ? (((((nl0iOlO ^ n0O11O) ^ n0O11i) ^ n0lOOl) ^ n0lOlO) ^ n0lOil) : n0O1iO;
	assign		wire_ni0ili_dataout = (n0llil === 1'b1) ? ((((((nl0iOli ^ n0O10O) ^ n0O11l) ^ n0lOOO) ^ n0lOOi) ^ n0lOll) ^ n0lOii) : n0O1il;
	assign		wire_ni0ill_dataout = (n0llil === 1'b1) ? ((((((((((nl0iOil ^ n0O10l) ^ n0O10i) ^ n0O11l) ^ n0O11i) ^ n0lOOO) ^ n0lOOl) ^ n0lOOi) ^ n0lOlO) ^ n0lOll) ^ n0lO0O) : n0O1ii;
	assign		wire_ni0ilO_dataout = (n0llil === 1'b1) ? (((((((nl0iOii ^ n0O10l) ^ n0O11O) ^ n0O11l) ^ n0O11i) ^ n0lOOl) ^ n0lOlO) ^ n0lO0l) : n0O10O;
	assign		wire_ni0iOi_dataout = (n0llil === 1'b1) ? ((((((((nl0iO0l ^ n0O10l) ^ n0O10i) ^ n0O11l) ^ n0O11i) ^ n0lOOO) ^ n0lOOi) ^ n0lOll) ^ n0lO0i) : n0O10l;
	assign		wire_ni0iOl_dataout = (n0llil === 1'b1) ? ((((((((((nl0iO0O ^ n0O1iO) ^ n0O10O) ^ n0O11O) ^ n0O11l) ^ n0O11i) ^ n0lOOl) ^ n0lOOi) ^ n0lOlO) ^ n0lOll) ^ n0lO1O) : n0O10i;
	assign		wire_ni0iOO_dataout = (n0llil === 1'b1) ? ((((((((nl0iOOi ^ n0O1il) ^ n0O1ii) ^ n0O10O) ^ n0O10l) ^ n0O10i) ^ n0O11i) ^ n0lOlO) ^ n0lO1l) : n0O11O;
	assign		wire_ni0l0i_dataout = (n0llil === 1'b1) ? (((((((nl0iO1O ^ n0O10O) ^ n0O10l) ^ n0O10i) ^ n0O11l) ^ n0lOOO) ^ n0lOOl) ^ n0llOi) : n0lOOl;
	assign		wire_ni0l0l_dataout = (n0llil === 1'b1) ? ((((((((n0O1iO ^ n0O10O) ^ n0O10l) ^ n0O10i) ^ n0O11O) ^ n0O11i) ^ n0lOOl) ^ n0lOOi) ^ n0lllO) : n0lOOi;
	assign		wire_ni0l0O_dataout = (n0llil === 1'b1) ? ((((((((nl0iO1l ^ n0O10l) ^ n0O10i) ^ n0O11O) ^ n0O11l) ^ n0lOOO) ^ n0lOOi) ^ n0lOlO) ^ n0llll) : n0lOlO;
	assign		wire_ni0l1i_dataout = (n0llil === 1'b1) ? ((((((((nl0iO0i ^ n0O1ii) ^ n0O10O) ^ n0O10l) ^ n0O10i) ^ n0O11O) ^ n0lOOO) ^ n0lOll) ^ n0lO1i) : n0O11l;
	assign		wire_ni0l1l_dataout = (n0llil === 1'b1) ? (((((((n0O1il ^ n0O10l) ^ n0O11O) ^ n0lOOO) ^ n0lOOl) ^ n0lOOi) ^ n0lOll) ^ n0llOO) : n0O11i;
	assign		wire_ni0l1O_dataout = (n0llil === 1'b1) ? ((((((n0OOOO ^ n0O10O) ^ n0lOOO) ^ n0lOOl) ^ n0lOlO) ^ n0lOll) ^ n0llOl) : n0lOOO;
	assign		wire_ni0lii_dataout = (n0llil === 1'b1) ? ((((((((nl0iO1O ^ n0O10i) ^ n0O11O) ^ n0O11l) ^ n0O11i) ^ n0lOOl) ^ n0lOlO) ^ n0lOll) ^ n0llli) : n0lOll;
	assign		wire_ni0lil_dataout = (n0llil === 1'b1) ? ((nl0iO1i ^ n0O11O) ^ n0O11i) : n0lOli;
	assign		wire_ni0liO_dataout = (n0llil === 1'b1) ? ((((nl0iO1l ^ n0O10O) ^ n0O11O) ^ n0O11l) ^ n0lOOO) : n0lOiO;
	assign		wire_ni0lli_dataout = (n0llil === 1'b1) ? ((((nl0iO1O ^ n0O10l) ^ n0O11l) ^ n0O11i) ^ n0lOOl) : n0lOil;
	assign		wire_ni0lll_dataout = (n0llil === 1'b1) ? ((((nl0iOii ^ n0O10i) ^ n0O11i) ^ n0lOOO) ^ n0lOOi) : n0lOii;
	assign		wire_ni0llO_dataout = (n0llil === 1'b1) ? (((((nl0iOiO ^ n0O10l) ^ n0O11O) ^ n0lOOO) ^ n0lOOl) ^ n0lOlO) : n0lO0O;
	assign		wire_ni0lOi_dataout = (n0llil === 1'b1) ? ((((nl0iO1i ^ n0O11l) ^ n0lOOl) ^ n0lOOi) ^ n0lOll) : n0lO0l;
	assign		wire_ni0lOl_dataout = (n0llil === 1'b1) ? ((((((((nl0iO1l ^ n0O1ii) ^ n0O10i) ^ n0O11O) ^ n0O11l) ^ n0O11i) ^ n0lOOO) ^ n0lOlO) ^ n0lOll) : n0lO0i;
	assign		wire_ni0lOO_dataout = (n0llil === 1'b1) ? (((((nl0iO0O ^ n0O10i) ^ n0O11O) ^ n0O11i) ^ n0lOOl) ^ n0lOOi) : n0lO1O;
	assign		wire_ni0O0i_dataout = (n0llil === 1'b1) ? (((((nl0iOll ^ n0O1ii) ^ n0O10l) ^ n0O11O) ^ n0O11i) ^ n0lOOO) : n0llOl;
	assign		wire_ni0O0l_dataout = (n0llil === 1'b1) ? (((((nl0iO0l ^ n0O10O) ^ n0O10i) ^ n0O11l) ^ n0lOOO) ^ n0lOOl) : n0llOi;
	assign		wire_ni0O0O_dataout = (n0llil === 1'b1) ? (((((nl0iOlO ^ n0O10l) ^ n0O11O) ^ n0O11i) ^ n0lOOl) ^ n0lOOi) : n0lllO;
	assign		wire_ni0O1i_dataout = (n0llil === 1'b1) ? (((((nl0iOOi ^ n0O11O) ^ n0O11l) ^ n0lOOO) ^ n0lOOi) ^ n0lOlO) : n0lO1l;
	assign		wire_ni0O1l_dataout = (n0llil === 1'b1) ? (((((nl0iOli ^ n0O11l) ^ n0O11i) ^ n0lOOl) ^ n0lOlO) ^ n0lOll) : n0lO1i;
	assign		wire_ni0O1O_dataout = (n0llil === 1'b1) ? (((nl0iOil ^ n0O10i) ^ n0O11l) ^ n0O11i) : n0llOO;
	assign		wire_ni0Oii_dataout = (n0llil === 1'b1) ? ((((((nl0iO0i ^ n0O10O) ^ n0O10i) ^ n0O11l) ^ n0lOOO) ^ n0lOOi) ^ n0lOlO) : n0llll;
	assign		wire_ni0Oil_dataout = (n0llil === 1'b1) ? (((((((n0O1il ^ n0O1ii) ^ n0O10l) ^ n0O11O) ^ n0O11i) ^ n0lOOl) ^ n0lOlO) ^ n0lOll) : n0llli;
	assign		wire_ni100i_dataout = (n0lliO === 1'b1) ? (wire_ni0O1O_dataout ^ nl0iill) : wire_ni0lli_dataout;
	assign		wire_ni100l_dataout = (n0lliO === 1'b1) ? (wire_ni0O0i_dataout ^ (wire_ni0ilO_dataout ^ (wire_ni0ili_dataout ^ wire_ni0iiO_dataout))) : wire_ni0lll_dataout;
	assign		wire_ni100O_dataout = (n0lliO === 1'b1) ? (wire_ni0O0l_dataout ^ (wire_ni0iOi_dataout ^ nl0il1i)) : wire_ni0llO_dataout;
	assign		wire_ni101i_dataout = (n0lliO === 1'b1) ? (wire_ni0lOO_dataout ^ (wire_ni0iOl_dataout ^ nl0il1O)) : wire_ni0lii_dataout;
	assign		wire_ni101l_dataout = (n0lliO === 1'b1) ? (wire_ni0O1i_dataout ^ nl0iliO) : wire_ni0lil_dataout;
	assign		wire_ni101O_dataout = (n0lliO === 1'b1) ? (wire_ni0O1l_dataout ^ nl0iiOi) : wire_ni0liO_dataout;
	assign		wire_ni10ii_dataout = (n0lliO === 1'b1) ? (wire_ni0O0O_dataout ^ (wire_ni0iOl_dataout ^ (wire_ni0ilO_dataout ^ (wire_ni0ill_dataout ^ wire_ni0iil_dataout)))) : wire_ni0lOi_dataout;
	assign		wire_ni10il_dataout = (n0lliO === 1'b1) ? (wire_ni0Oii_dataout ^ (wire_ni0iOl_dataout ^ (wire_ni0iOi_dataout ^ nl0illi))) : wire_ni0lOl_dataout;
	assign		wire_ni10iO_dataout = (n0lliO === 1'b1) ? (wire_ni0Oil_dataout ^ nl0iiOl) : wire_ni0lOO_dataout;
	assign		wire_ni10li_dataout = (n0lliO === 1'b1) ? nl0iilO : wire_ni0O1i_dataout;
	assign		wire_ni10ll_dataout = (n0lliO === 1'b1) ? (wire_ni0iOl_dataout ^ (wire_ni0iOi_dataout ^ nl0iill)) : wire_ni0O1l_dataout;
	assign		wire_ni10lO_dataout = (n0lliO === 1'b1) ? nl0il0O : wire_ni0O1O_dataout;
	assign		wire_ni10Oi_dataout = (n0lliO === 1'b1) ? (wire_ni0ili_dataout ^ nl0iliO) : wire_ni0O0i_dataout;
	assign		wire_ni10Ol_dataout = (n0lliO === 1'b1) ? nl0iiOO : wire_ni0O0l_dataout;
	assign		wire_ni10OO_dataout = (n0lliO === 1'b1) ? nl0iiOl : wire_ni0O0O_dataout;
	assign		wire_ni110i_dataout = (n0lliO === 1'b1) ? (wire_ni0l1O_dataout ^ nl0ilOi) : wire_ni0ili_dataout;
	assign		wire_ni110l_dataout = (n0lliO === 1'b1) ? (wire_ni0l0i_dataout ^ (wire_ni0iOl_dataout ^ (wire_ni0iOi_dataout ^ (wire_ni0ilO_dataout ^ (wire_ni0ill_dataout ^ nl0il0l))))) : wire_ni0ill_dataout;
	assign		wire_ni110O_dataout = (n0lliO === 1'b1) ? (wire_ni0l0l_dataout ^ nl0il1O) : wire_ni0ilO_dataout;
	assign		wire_ni111i_dataout = (n0lliO === 1'b1) ? (wire_ni0iOO_dataout ^ nl0ilOi) : wire_ni0iii_dataout;
	assign		wire_ni111l_dataout = (n0lliO === 1'b1) ? (wire_ni0l1i_dataout ^ (wire_ni0iOl_dataout ^ (wire_ni0iOi_dataout ^ (wire_ni0ilO_dataout ^ (wire_ni0ill_dataout ^ nl0illi))))) : wire_ni0iil_dataout;
	assign		wire_ni111O_dataout = (n0lliO === 1'b1) ? (wire_ni0l1l_dataout ^ nl0ilii) : wire_ni0iiO_dataout;
	assign		wire_ni11ii_dataout = (n0lliO === 1'b1) ? (wire_ni0l0O_dataout ^ (wire_ni0iOl_dataout ^ (wire_ni0ilO_dataout ^ nl0il0l))) : wire_ni0iOi_dataout;
	assign		wire_ni11il_dataout = (n0lliO === 1'b1) ? (wire_ni0lii_dataout ^ (wire_ni0iOl_dataout ^ (wire_ni0iOi_dataout ^ (wire_ni0ilO_dataout ^ nl0il0i)))) : wire_ni0iOl_dataout;
	assign		wire_ni11iO_dataout = (n0lliO === 1'b1) ? (wire_ni0lil_dataout ^ (wire_ni0iOi_dataout ^ wire_ni0iiO_dataout)) : wire_ni0iOO_dataout;
	assign		wire_ni11li_dataout = (n0lliO === 1'b1) ? (wire_ni0liO_dataout ^ (wire_ni0iOl_dataout ^ nl0il1l)) : wire_ni0l1i_dataout;
	assign		wire_ni11ll_dataout = (n0lliO === 1'b1) ? (wire_ni0lli_dataout ^ (wire_ni0iOl_dataout ^ (wire_ni0ilO_dataout ^ nl0il1i))) : wire_ni0l1l_dataout;
	assign		wire_ni11lO_dataout = (n0lliO === 1'b1) ? (wire_ni0lll_dataout ^ (wire_ni0iOl_dataout ^ (wire_ni0iOi_dataout ^ (wire_ni0ill_dataout ^ wire_ni0ili_dataout)))) : wire_ni0l1O_dataout;
	assign		wire_ni11Oi_dataout = (n0lliO === 1'b1) ? (wire_ni0llO_dataout ^ nl0iiOO) : wire_ni0l0i_dataout;
	assign		wire_ni11Ol_dataout = (n0lliO === 1'b1) ? (wire_ni0lOi_dataout ^ nl0iiOl) : wire_ni0l0l_dataout;
	assign		wire_ni11OO_dataout = (n0lliO === 1'b1) ? (wire_ni0lOl_dataout ^ nl0iilO) : wire_ni0l0O_dataout;
	assign		wire_ni1i1i_dataout = (n0lliO === 1'b1) ? (wire_ni0iOi_dataout ^ nl0ilOl) : wire_ni0Oii_dataout;
	assign		wire_ni1i1l_dataout = (n0lliO === 1'b1) ? (wire_ni0iOl_dataout ^ nl0ilii) : wire_ni0Oil_dataout;
	and(wire_niliO_dataout, (((n1iOii ^ n1ilOi) ^ n1iOli) ^ n1l1li), ~(nlO0lll));
	and(wire_nilli_dataout, (((n1iOlO ^ n1ilOi) ^ n1l10l) ^ n1l1ll), ~(nlO0lll));
	and(wire_nilll_dataout, ((n1iO1l ^ n1ilii) ^ n1l1lO), ~(nlO0lll));
	and(wire_nillO_dataout, (((n1iOlO ^ n1ilOO) ^ n1l11i) ^ n1l1Oi), ~(nlO0lll));
	and(wire_nilOi_dataout, (((n1iOOi ^ n1iO1l) ^ n1l1ii) ^ n1l1Ol), ~(nlO0lll));
	and(wire_nilOl_dataout, ((n1iOii ^ n1illi) ^ n1l1OO), ~(nlO0lll));
	and(wire_nilOO_dataout, ((n1iOll ^ n1illO) ^ n1l01i), ~(nlO0lll));
	and(wire_niO0i_dataout, (((n1iO1O ^ n1ilOO) ^ n1l1il) ^ n1l00l), ~(nlO0lll));
	and(wire_niO0l_dataout, (((n1iOil ^ n1ilOl) ^ n1iOll) ^ n1l00O), ~(nlO0lll));
	and(wire_niO0O_dataout, ((n1iO0O ^ n1illi) ^ n1l0ii), ~(nlO0lll));
	and(wire_niO1i_dataout, ((n1iO1i ^ n1illl) ^ n1l01l), ~(nlO0lll));
	and(wire_niO1l_dataout, (((n1iOlO ^ n1illO) ^ n1l11l) ^ n1l01O), ~(nlO0lll));
	and(wire_niO1O_dataout, ((((n1iO0l ^ n1ilii) ^ n1iOOl) ^ n1iOOO) ^ n1l00i), ~(nlO0lll));
	and(wire_niOii_dataout, (((n1iOiO ^ n1iliO) ^ n1l1il) ^ n1l0il), ~(nlO0lll));
	and(wire_niOil_dataout, ((n1iO1O ^ n1ilOl) ^ n1l0iO), ~(nlO0lll));
	and(wire_niOiO_dataout, ((nl0O1il ^ n1l0li) ^ (~ (nl0liOO42 ^ nl0liOO41))), ~(nlO0lll));
	and(wire_niOli_dataout, (n1l0ll ^ n1ilii), ~(nlO0lll));
	and(wire_niOll_dataout, ((n1l11O ^ n1iliO) ^ n1l0lO), ~(nlO0lll));
	and(wire_niOlO_dataout, (((n1l10O ^ n1ilOl) ^ (~ (nl0ll1l40 ^ nl0ll1l39))) ^ n1l0Oi), ~(nlO0lll));
	assign		wire_niOO0i_dataout = (n0ll1O === 1'b1) ? (((((((((((((((n0liOi ^ n0lilO) ^ n0lill) ^ n0lili) ^ n0liil) ^ n0liii) ^ n0li0O) ^ n0li1O) ^ n0li1l) ^ n0l0OO) ^ n0l0Ol) ^ n0l0lO) ^ n0l0il) ^ n0l00O) ^ n0l00i) ^ n0l01l) : n0liOO;
	assign		wire_niOO0l_dataout = (n0ll1O === 1'b1) ? ((((((((((((((nl0l1ii ^ n0lili) ^ n0liiO) ^ n0liii) ^ n0li0O) ^ n0li0l) ^ n0li1l) ^ n0li1i) ^ n0l0Ol) ^ n0l0Oi) ^ n0l0ll) ^ n0l0ii) ^ n0l00l) ^ n0l01O) ^ n0l01i) : n0liOl;
	assign		wire_niOO0O_dataout = (n0ll1O === 1'b1) ? (((((((((((((((((nl0l10i ^ n0liiO) ^ n0li0O) ^ n0li0l) ^ n0li0i) ^ n0li1O) ^ n0l0OO) ^ n0l0Oi) ^ n0l0ll) ^ n0l0li) ^ n0l0iO) ^ n0l0ii) ^ n0l00O) ^ n0l00l) ^ n0l00i) ^ n0l01O) ^ n0l01l) ^ n0l01i) : n0liOi;
	assign		wire_niOO1l_dataout = (n0ll1O === 1'b1) ? ((((((((((((n0ll1i ^ n0liOO) ^ n0lilO) ^ n0liil) ^ n0li1O) ^ n0li1i) ^ n0l0lO) ^ n0l0ll) ^ n0l0iO) ^ n0l0ii) ^ n0l00l) ^ n0l01O) ^ n0l01i) : n0ll1l;
	assign		wire_niOO1O_dataout = (n0ll1O === 1'b1) ? (((((((((((((((((((nl0l1il ^ n0lilO) ^ n0lill) ^ n0liil) ^ n0liii) ^ n0li1O) ^ n0li1l) ^ n0li1i) ^ n0l0OO) ^ n0l0lO) ^ n0l0li) ^ n0l0iO) ^ n0l0il) ^ n0l0ii) ^ n0l00O) ^ n0l00l) ^ n0l00i) ^ n0l01O) ^ n0l01l) ^ n0l01i) : n0ll1i;
	and(wire_niOOi_dataout, (((n1iO1i ^ n1ilOl) ^ n1l0Ol) ^ (~ (nl0ll0i38 ^ nl0ll0i37))), ~(nlO0lll));
	assign		wire_niOOii_dataout = (n0ll1O === 1'b1) ? ((((((((((((((((nl0l11O ^ n0lilO) ^ n0lill) ^ n0lili) ^ n0liiO) ^ n0li0l) ^ n0li0i) ^ n0li1l) ^ n0li1i) ^ n0l0Ol) ^ n0l0ll) ^ n0l0li) ^ n0l0il) ^ n0l0ii) ^ n0l00O) ^ n0l00i) ^ n0l01l) : n0lilO;
	assign		wire_niOOil_dataout = (n0ll1O === 1'b1) ? (((((((((((((((((nl0l11l ^ n0liOi) ^ n0lill) ^ n0lili) ^ n0liiO) ^ n0liil) ^ n0li0i) ^ n0li1O) ^ n0li1i) ^ n0l0OO) ^ n0l0Oi) ^ n0l0li) ^ n0l0iO) ^ n0l0ii) ^ n0l00O) ^ n0l00l) ^ n0l01O) ^ n0l01i) : n0lill;
	assign		wire_niOOiO_dataout = (n0ll1O === 1'b1) ? ((((((((((((((((nl0l10O ^ n0liOi) ^ n0lili) ^ n0liiO) ^ n0liii) ^ n0li1l) ^ n0li1i) ^ n0l0OO) ^ n0l0Ol) ^ n0l0ll) ^ n0l0il) ^ n0l0ii) ^ n0l00O) ^ n0l00i) ^ n0l01O) ^ n0l01l) ^ n0l01i) : n0lili;
	and(wire_niOOl_dataout, (((n1iOOi ^ n1iOii) ^ (~ (nl0ll0O36 ^ nl0ll0O35))) ^ n1l0OO), ~(nlO0lll));
	assign		wire_niOOli_dataout = (n0ll1O === 1'b1) ? ((((((((((((nl0l11O ^ n0liiO) ^ n0li0O) ^ n0li1O) ^ n0l0OO) ^ n0l0Ol) ^ n0l0Oi) ^ n0l0lO) ^ n0l0ll) ^ n0l0li) ^ n0l0iO) ^ n0l00O) ^ n0l01l) : n0liiO;
	assign		wire_niOOll_dataout = (n0ll1O === 1'b1) ? (((((((((((((n0liOl ^ n0liOi) ^ n0liil) ^ n0li0l) ^ n0li1l) ^ n0l0Ol) ^ n0l0Oi) ^ n0l0lO) ^ n0l0ll) ^ n0l0li) ^ n0l0iO) ^ n0l0il) ^ n0l00l) ^ n0l01i) : n0liil;
	assign		wire_niOOlO_dataout = (n0ll1O === 1'b1) ? (((((((((((nl0l11i ^ n0liil) ^ n0liii) ^ n0li0i) ^ n0li1O) ^ n0l0Oi) ^ n0l0li) ^ n0l0il) ^ n0l00l) ^ n0l00i) ^ n0l01O) ^ n0l01i) : n0liii;
	and(wire_niOOO_dataout, ((((n1iO1O ^ n1ilii) ^ (~ (nl0llil34 ^ nl0llil33))) ^ n1iOOl) ^ n1li1i), ~(nlO0lll));
	assign		wire_niOOOi_dataout = (n0ll1O === 1'b1) ? ((((((((((nl0l11l ^ n0liil) ^ n0liii) ^ n0li0O) ^ n0li1l) ^ n0li1i) ^ n0l0ll) ^ n0l00l) ^ n0l00i) ^ n0l01l) ^ n0l01i) : n0li0O;
	assign		wire_niOOOl_dataout = (n0ll1O === 1'b1) ? (((((((((((((nl0iOOO ^ n0liil) ^ n0liii) ^ n0li0O) ^ n0li0l) ^ n0li1O) ^ n0l0OO) ^ n0l0lO) ^ n0l0ll) ^ n0l0li) ^ n0l0iO) ^ n0l0ii) ^ n0l00l) ^ n0l00i) : n0li0l;
	assign		wire_niOOOO_dataout = (n0ll1O === 1'b1) ? (((((((((((((((nl0l11l ^ n0lilO) ^ n0lill) ^ n0liii) ^ n0li0O) ^ n0li0l) ^ n0li0i) ^ n0li1l) ^ n0l0Ol) ^ n0l0ll) ^ n0l0li) ^ n0l0iO) ^ n0l0il) ^ n0l00O) ^ n0l00i) ^ n0l01O) : n0li0i;
	or(wire_nl00i_dataout, n01iO, nl0O1iO);
	or(wire_nl00l_dataout, n01li, nl0O1iO);
	or(wire_nl00O_dataout, n01ll, nl0O1iO);
	or(wire_nl01i_dataout, n010O, nl0O1iO);
	or(wire_nl01l_dataout, n01ii, nl0O1iO);
	or(wire_nl01O_dataout, n01il, nl0O1iO);
	and(wire_nl0ii_dataout, n01lO, ~(nl0O1iO));
	and(wire_nl0il_dataout, n01Oi, ~(nl0O1iO));
	or(wire_nl0iO_dataout, n01Ol, nl0O1iO);
	and(wire_nl0li_dataout, n01OO, ~(nl0O1iO));
	and(wire_nl0ll_dataout, n001i, ~(nl0O1iO));
	or(wire_nl0lO_dataout, n001l, nl0O1iO);
	or(wire_nl0Oi_dataout, n001O, nl0O1iO);
	and(wire_nl0Oiii_dataout, nl0OliO, wire_nli1Oii_o[0]);
	and(wire_nl0Oiil_dataout, nl0Olii, wire_nli1Oii_o[0]);
	and(wire_nl0OiiO_dataout, nl0Ol0l, wire_nli1Oii_o[0]);
	and(wire_nl0Oill_dataout, nl0Ol1O, wire_nli1Oii_o[0]);
	and(wire_nl0OiOi_dataout, nl0Ol1i, wire_nli1Oii_o[0]);
	and(wire_nl0OiOO_dataout, nl0OiOl, wire_nli1Oii_o[0]);
	and(wire_nl0Ol_dataout, n000i, ~(nl0O1iO));
	and(wire_nl0Ol0i_dataout, nl0Oili, wire_nli1Oii_o[0]);
	and(wire_nl0Ol0O_dataout, nl0OOli, wire_nli1l0l_o[0]);
	and(wire_nl0Ol1l_dataout, nl0OilO, wire_nli1Oii_o[0]);
	and(wire_nl0Olil_dataout, nl0OOil, wire_nli1l0l_o[0]);
	and(wire_nl0Olli_dataout, nl0OO0O, wire_nli1l0l_o[0]);
	and(wire_nl0OllO_dataout, nl0OO0i, wire_nli1l0l_o[0]);
	and(wire_nl0OlOl_dataout, nl0OO1l, wire_nli1l0l_o[0]);
	or(wire_nl0OO_dataout, n000l, nl0O1iO);
	and(wire_nl0OO0l_dataout, nl0Olll, wire_nli1l0l_o[0]);
	and(wire_nl0OO1i_dataout, nl0OlOO, wire_nli1l0l_o[0]);
	and(wire_nl0OO1O_dataout, nl0OlOi, wire_nli1l0l_o[0]);
	and(wire_nl0OOii_dataout, nli100l, nl0i10i);
	and(wire_nl0OOiO_dataout, nli101O, nl0i10i);
	and(wire_nl0OOll_dataout, nli11il, nl0i10i);
	and(wire_nl0OOOi_dataout, nli110l, nl0i10i);
	and(wire_nl0OOOO_dataout, nli111O, nl0i10i);
	assign		wire_nl101i_dataout = (n0ll1O === 1'b1) ? (((((((((((n0liOO ^ n0lill) ^ n0li0O) ^ n0li0i) ^ n0l0OO) ^ n0l0Ol) ^ n0l0lO) ^ n0l0li) ^ n0l0il) ^ n0l00O) ^ n0l00i) ^ n0l01O) : n0l01O;
	assign		wire_nl101l_dataout = (n0ll1O === 1'b1) ? (((((((((((nl0l11l ^ n0lili) ^ n0li0l) ^ n0li1O) ^ n0l0Ol) ^ n0l0Oi) ^ n0l0ll) ^ n0l0iO) ^ n0l0ii) ^ n0l00l) ^ n0l01O) ^ n0l01l) : n0l01l;
	assign		wire_nl101O_dataout = (n0ll1O === 1'b1) ? ((((((((((((nl0l1iO ^ n0liOi) ^ n0liiO) ^ n0li0i) ^ n0li1l) ^ n0l0Oi) ^ n0l0lO) ^ n0l0li) ^ n0l0il) ^ n0l00O) ^ n0l00i) ^ n0l01l) ^ n0l01i) : n0l01i;
	and(wire_nl10i_dataout, (((((n1iOll ^ n1ilOl) ^ (~ (nl0lOii20 ^ nl0lOii19))) ^ n1l10i) ^ (~ (nl0lO0l22 ^ nl0lO0l21))) ^ n1li0l), ~(nlO0lll));
	and(wire_nl10l_dataout, ((n1iOii ^ n1iliO) ^ n1li0O), ~(nlO0lll));
	and(wire_nl10O_dataout, ((((((n1iO0i ^ n1illO) ^ n1iOli) ^ (~ (nl0lOll16 ^ nl0lOll15))) ^ n1l10l) ^ (~ (nl0lOiO18 ^ nl0lOiO17))) ^ n1liii), ~(nlO0lll));
	assign		wire_nl110i_dataout = (n0ll1O === 1'b1) ? ((((((((((((n0ll1i ^ n0liOl) ^ n0liOi) ^ n0lill) ^ n0lili) ^ n0liil) ^ n0li1O) ^ n0li1i) ^ n0l0Oi) ^ n0l0ll) ^ n0l0il) ^ n0l0ii) ^ n0l00l) : n0l0OO;
	assign		wire_nl110l_dataout = (n0ll1O === 1'b1) ? ((((((((((nl0iOOO ^ n0lili) ^ n0liiO) ^ n0liii) ^ n0li1l) ^ n0l0OO) ^ n0l0lO) ^ n0l0li) ^ n0l0ii) ^ n0l00O) ^ n0l00i) : n0l0Ol;
	assign		wire_nl110O_dataout = (n0ll1O === 1'b1) ? ((((((((((((n0liOl ^ n0lilO) ^ n0lill) ^ n0liiO) ^ n0liil) ^ n0li0O) ^ n0li1i) ^ n0l0Ol) ^ n0l0ll) ^ n0l0iO) ^ n0l00O) ^ n0l00l) ^ n0l01O) : n0l0Oi;
	assign		wire_nl111i_dataout = (n0ll1O === 1'b1) ? ((((((((((((((((n0ll1i ^ n0liOi) ^ n0lill) ^ n0lili) ^ n0li0O) ^ n0li0l) ^ n0li0i) ^ n0li1O) ^ n0li1i) ^ n0l0Oi) ^ n0l0li) ^ n0l0iO) ^ n0l0il) ^ n0l0ii) ^ n0l00l) ^ n0l01O) ^ n0l01l) : n0li1O;
	assign		wire_nl111l_dataout = (n0ll1O === 1'b1) ? (((((((((((((((nl0l10l ^ n0lili) ^ n0liiO) ^ n0li0l) ^ n0li0i) ^ n0li1O) ^ n0li1l) ^ n0l0OO) ^ n0l0lO) ^ n0l0iO) ^ n0l0il) ^ n0l0ii) ^ n0l00O) ^ n0l00i) ^ n0l01l) ^ n0l01i) : n0li1l;
	assign		wire_nl111O_dataout = (n0ll1O === 1'b1) ? (((((((((((nl0l10O ^ n0liOl) ^ n0lilO) ^ n0lill) ^ n0liiO) ^ n0li0i) ^ n0li1l) ^ n0l0Ol) ^ n0l0lO) ^ n0l0iO) ^ n0l0il) ^ n0l00O) : n0li1i;
	and(wire_nl11i_dataout, ((((n1iO0i ^ n1ilOO) ^ n1iOll) ^ (~ (nl0llli32 ^ nl0llli31))) ^ n1li1l), ~(nlO0lll));
	assign		wire_nl11ii_dataout = (n0ll1O === 1'b1) ? ((((((((((((nl0iOOl ^ n0lill) ^ n0lili) ^ n0liil) ^ n0liii) ^ n0li0l) ^ n0l0OO) ^ n0l0Oi) ^ n0l0li) ^ n0l0il) ^ n0l00l) ^ n0l00i) ^ n0l01l) : n0l0lO;
	assign		wire_nl11il_dataout = (n0ll1O === 1'b1) ? (((((((((((((nl0l1iO ^ n0lilO) ^ n0lili) ^ n0liiO) ^ n0liii) ^ n0li0O) ^ n0li0i) ^ n0l0Ol) ^ n0l0lO) ^ n0l0iO) ^ n0l0ii) ^ n0l00i) ^ n0l01O) ^ n0l01i) : n0l0ll;
	assign		wire_nl11iO_dataout = (n0ll1O === 1'b1) ? (((((((((((((nl0l1ii ^ n0liiO) ^ n0li0O) ^ n0li0l) ^ n0li1i) ^ n0l0Oi) ^ n0l0lO) ^ n0l0iO) ^ n0l0il) ^ n0l0ii) ^ n0l00O) ^ n0l00l) ^ n0l01l) ^ n0l01i) : n0l0li;
	and(wire_nl11l_dataout, ((((n1iOli ^ n1illi) ^ (~ (nl0llOl28 ^ nl0llOl27))) ^ n1li1O) ^ (~ (nl0lllO30 ^ nl0lllO29))), ~(nlO0lll));
	assign		wire_nl11li_dataout = (n0ll1O === 1'b1) ? ((((((((((nl0l10i ^ n0li0l) ^ n0li0i) ^ n0li1O) ^ n0li1i) ^ n0l0OO) ^ n0l0iO) ^ n0l0il) ^ n0l00O) ^ n0l00i) ^ n0l01O) : n0l0iO;
	assign		wire_nl11ll_dataout = (n0ll1O === 1'b1) ? (((((((((((((nl0l1il ^ n0lill) ^ n0lili) ^ n0liiO) ^ n0li0i) ^ n0li1O) ^ n0li1l) ^ n0l0OO) ^ n0l0Ol) ^ n0l0il) ^ n0l0ii) ^ n0l00l) ^ n0l01O) ^ n0l01l) : n0l0il;
	assign		wire_nl11lO_dataout = (n0ll1O === 1'b1) ? (((((((((((((nl0l11i ^ n0lili) ^ n0liiO) ^ n0liil) ^ n0li1O) ^ n0li1l) ^ n0li1i) ^ n0l0Ol) ^ n0l0Oi) ^ n0l0ii) ^ n0l00O) ^ n0l00i) ^ n0l01l) ^ n0l01i) : n0l0ii;
	and(wire_nl11O_dataout, ((((((n1iOli ^ n1illl) ^ n1l11i) ^ (~ (nl0lO1O24 ^ nl0lO1O23))) ^ n1l1iO) ^ n1li0i) ^ (~ (nl0lO1i26 ^ nl0lO1i25))), ~(nlO0lll));
	assign		wire_nl11Oi_dataout = (n0ll1O === 1'b1) ? ((((((((((n0liOl ^ n0liiO) ^ n0liii) ^ n0li1O) ^ n0li1l) ^ n0l0OO) ^ n0l0Oi) ^ n0l0ll) ^ n0l0iO) ^ n0l0ii) ^ n0l00O) : n0l00O;
	assign		wire_nl11Ol_dataout = (n0ll1O === 1'b1) ? ((((((((((nl0iOOl ^ n0liil) ^ n0li0O) ^ n0li1l) ^ n0li1i) ^ n0l0Ol) ^ n0l0lO) ^ n0l0li) ^ n0l0il) ^ n0l00O) ^ n0l00l) : n0l00l;
	assign		wire_nl11OO_dataout = (n0ll1O === 1'b1) ? (((((((((((n0ll1i ^ n0lilO) ^ n0liii) ^ n0li0l) ^ n0li1i) ^ n0l0OO) ^ n0l0Oi) ^ n0l0ll) ^ n0l0iO) ^ n0l0ii) ^ n0l00l) ^ n0l00i) : n0l00i;
	and(wire_nl1ii_dataout, (((((n1iO1l ^ n1illl) ^ n1iOlO) ^ n1l1ii) ^ (~ (nl0lOOi14 ^ nl0lOOi13))) ^ n1liil), ~(nlO0lll));
	and(wire_nl1il_dataout, ((((n1iO1O ^ n1illO) ^ n1l1ii) ^ (~ (nl0lOOO12 ^ nl0lOOO11))) ^ n1liiO), ~(nlO0lll));
	and(wire_nl1iO_dataout, ((((n1iOiO ^ n1iO0i) ^ (~ (nl0O10i8 ^ nl0O10i7))) ^ n1lili) ^ (~ (nl0O11l10 ^ nl0O11l9))), ~(nlO0lll));
	and(wire_nl1li_dataout, ((n0l1OO ^ nl0O1il) ^ (~ (nl0O10O6 ^ nl0O10O5))), ~(nlO0lll));
	or(wire_nl1ll_dataout, nliOO, nl0O1iO);
	or(wire_nl1lO_dataout, n011l, nl0O1iO);
	or(wire_nl1Oi_dataout, n011O, nl0O1iO);
	and(wire_nl1Ol_dataout, n010i, ~(nl0O1iO));
	or(wire_nl1OO_dataout, n010l, nl0O1iO);
	and(wire_nli0i_dataout, n00iO, ~(nl0O1iO));
	or(wire_nli0l_dataout, n00li, nl0O1iO);
	and(wire_nli0O_dataout, n00ll, ~(nl0O1iO));
	and(wire_nli100i_dataout, nli1lii, ~(nl0i10l));
	and(wire_nli100O_dataout, nli1l0i, ~(nl0i10l));
	and(wire_nli101i_dataout, nli10ii, ~(nl0O01O));
	and(wire_nli101l_dataout, nli1liO, ~(nl0i10l));
	and(wire_nli10il_dataout, nli1l1l, ~(nl0i10l));
	and(wire_nli10li_dataout, nli1iOO, ~(nl0i10l));
	and(wire_nli10lO_dataout, nli1iOi, ~(nl0i10l));
	and(wire_nli10Ol_dataout, nli1ill, ~(nl0i10l));
	and(wire_nli110i_dataout, nl0OOOl, nl0i10i);
	and(wire_nli110O_dataout, nl0OOlO, nl0i10i);
	and(wire_nli111l_dataout, nli111i, nl0i10i);
	and(wire_nli11iO_dataout, nli1iii, ~(nl0O01O));
	and(wire_nli11li_dataout, nli1i0l, ~(nl0O01O));
	and(wire_nli11ll_dataout, nli1i1l, ~(nl0O01O));
	and(wire_nli11lO_dataout, nli10OO, ~(nl0O01O));
	and(wire_nli11Oi_dataout, nli10Oi, ~(nl0O01O));
	and(wire_nli11Ol_dataout, nli10ll, ~(nl0O01O));
	and(wire_nli11OO_dataout, nli10iO, ~(nl0O01O));
	and(wire_nli1i_dataout, n000O, ~(nl0O1iO));
	and(wire_nli1i0i_dataout, nli1OiO, ~(wire_nli1l0l_o[3]));
	and(wire_nli1i0O_dataout, nli1Oil, ~(wire_nli1l0l_o[3]));
	and(wire_nli1i1i_dataout, nli1iiO, ~(nl0i10l));
	and(wire_nli1iil_dataout, nli1O0O, ~(wire_nli1l0l_o[3]));
	and(wire_nli1ili_dataout, nli1O0i, ~(wire_nli1l0l_o[3]));
	and(wire_nli1ilO_dataout, nli1O1l, ~(wire_nli1l0l_o[3]));
	and(wire_nli1iOl_dataout, nli1lOO, ~(wire_nli1l0l_o[3]));
	and(wire_nli1l_dataout, n00ii, ~(nl0O1iO));
	and(wire_nli1l0O_dataout, nl0O0OO, ~(wire_nli1Oii_o[7]));
	and(wire_nli1l1i_dataout, nli1lOi, ~(wire_nli1l0l_o[3]));
	and(wire_nli1l1O_dataout, nli1lll, ~(wire_nli1l0l_o[3]));
	and(wire_nli1lil_dataout, nl0Oi1i, ~(wire_nli1Oii_o[7]));
	and(wire_nli1lli_dataout, nl0Oi1l, ~(wire_nli1Oii_o[7]));
	and(wire_nli1llO_dataout, nl0Oi1O, ~(wire_nli1Oii_o[7]));
	and(wire_nli1lOl_dataout, nl0Oi0i, ~(wire_nli1Oii_o[7]));
	and(wire_nli1O_dataout, n00il, ~(nl0O1iO));
	and(wire_nli1O0l_dataout, nli1Oli, ~(wire_nli1Oii_o[7]));
	and(wire_nli1O1i_dataout, nl0Oi0l, ~(wire_nli1Oii_o[7]));
	and(wire_nli1O1O_dataout, nl0Oi0O, ~(wire_nli1Oii_o[7]));
	or(wire_nliii_dataout, n00lO, nl0O1iO);
	and(wire_nliil_dataout, n00Oi, ~(nl0O1iO));
	or(wire_nliiO_dataout, n00Ol, nl0O1iO);
	or(wire_nlili_dataout, n00OO, nl0O1iO);
	or(wire_nlill_dataout, n0i1i, nl0O1iO);
	or(wire_nlilO_dataout, n0i1l, nl0O1iO);
	oper_decoder   nli1l0l
	( 
	.i({nl0O01O, nl0O00i}),
	.o(wire_nli1l0l_o));
	defparam
		nli1l0l.width_i = 2,
		nli1l0l.width_o = 4;
	oper_decoder   nli1Oii
	( 
	.i({nl0O01O, nl0O00i, nl0O00l}),
	.o(wire_nli1Oii_o));
	defparam
		nli1Oii.width_i = 3,
		nli1Oii.width_o = 8;
	assign
		checksum = {n0OilO, n0OiOi, n0OiOl, n0OiOO, n0Ol1i, n0Ol1l, n0Ol1O, n0Ol0i, n0Ol0l, n0Ol0O, n0Olii, n0Olil, n0OliO, n0Olli, n0Olll, n0OllO, n0OlOi, n0OlOl, n0OlOO, n0OO1i, n0OO1l, n0OO1O, n0OO0i, n0OO0l, n0OO0O, n0OOii, n0OOil, n0OOiO, n0OOli, n0OOll, n0OOlO, n0OOOi},
		crcvalid = n011i,
		nl0i00i = (wire_nl1Oi_dataout ^ wire_nl1lO_dataout),
		nl0i00l = (wire_nl0Ol_dataout ^ (wire_nl0Oi_dataout ^ (wire_nl0ll_dataout ^ wire_nl00O_dataout))),
		nl0i00O = (wire_nl01l_dataout ^ wire_nl1OO_dataout),
		nl0i01i = (wire_nl01O_dataout ^ wire_nl1lO_dataout),
		nl0i01l = (wire_nl1lO_dataout ^ wire_nl1ll_dataout),
		nl0i01O = (wire_nl1OO_dataout ^ wire_nl1Oi_dataout),
		nl0i0ii = (wire_nl01l_dataout ^ (wire_nl1OO_dataout ^ wire_nl1ll_dataout)),
		nl0i0il = (wire_nl1Ol_dataout ^ wire_nl1lO_dataout),
		nl0i0iO = (wire_nl01i_dataout ^ wire_nl1Oi_dataout),
		nl0i0li = (wire_nl00l_dataout ^ wire_nl01i_dataout),
		nl0i0ll = (wire_nl00i_dataout ^ wire_nl1Oi_dataout),
		nl0i0lO = ((~ reset_n) | nlO0l0O),
		nl0i0Ol = (nl0liOl ^ nl0li0O),
		nl0i0OO = (nl0liOi ^ nl0lilO),
		nl0i10i = ((wire_nli1Oii_o[2] | wire_nli1Oii_o[1]) | wire_nli1Oii_o[0]),
		nl0i10l = ((wire_nli1Oii_o[7] | wire_nli1Oii_o[6]) | wire_nli1Oii_o[5]),
		nl0i10O = (wire_nl0OO1i_dataout ^ wire_nl0OiOO_dataout),
		nl0i1ii = (wire_nli11iO_dataout ^ wire_nl0Ol0i_dataout),
		nl0i1il = (wire_nli110i_dataout ^ wire_nl0OOll_dataout),
		nl0i1iO = (wire_nl0OiOi_dataout ^ wire_nl0OiiO_dataout),
		nl0i1li = (wire_nl0OOOO_dataout ^ wire_nl0Oiil_dataout),
		nl0i1ll = (wire_nl0Ol0i_dataout ^ nl0i1lO),
		nl0i1lO = (wire_nl0Ol1l_dataout ^ wire_nl0Oiii_dataout),
		nl0i1Oi = (wire_nl0Olil_dataout ^ wire_nl0OiOi_dataout),
		nl0i1Ol = (wire_nl0Olil_dataout ^ wire_nl0Oiil_dataout),
		nl0i1OO = (wire_nli111l_dataout ^ wire_nl0OiOO_dataout),
		nl0ii0i = (nl0liii ^ (nl0liOl ^ nl0liiO)),
		nl0ii0l = (nl0liOi ^ nl0li0i),
		nl0ii0O = (nl0lili ^ nl0liil),
		nl0ii1i = (nl0liiO ^ nl0li0O),
		nl0ii1l = (nl0lilO ^ nl0liiO),
		nl0ii1O = (nl0liOi ^ nl0lili),
		nl0iiii = (nl0liOl ^ nl0lilO),
		nl0iiil = (nl0liOi ^ nl0liil),
		nl0iili = (nl0lili ^ nl0li1i),
		nl0iill = (wire_ni0ill_dataout ^ nl0il0O),
		nl0iilO = (wire_ni0iOi_dataout ^ (wire_ni0ilO_dataout ^ nl0iiOi)),
		nl0iiOi = (wire_ni0ili_dataout ^ nl0illO),
		nl0iiOl = (wire_ni0ilO_dataout ^ nl0ilil),
		nl0iiOO = (wire_ni0ill_dataout ^ nl0ilOO),
		nl0il0i = (wire_ni0ill_dataout ^ nl0illl),
		nl0il0l = (wire_ni0ili_dataout ^ nl0il0O),
		nl0il0O = (wire_ni0iiO_dataout ^ wire_ni0iil_dataout),
		nl0il1i = (wire_ni0ill_dataout ^ nl0il1l),
		nl0il1l = (wire_ni0ili_dataout ^ wire_ni0iii_dataout),
		nl0il1O = (wire_ni0iOi_dataout ^ nl0il0i),
		nl0ilii = (wire_ni0iOi_dataout ^ nl0ilil),
		nl0ilil = (wire_ni0ill_dataout ^ nl0iliO),
		nl0iliO = (wire_ni0iiO_dataout ^ wire_ni0iii_dataout),
		nl0illi = (wire_ni0ili_dataout ^ nl0illl),
		nl0illl = (wire_ni0iiO_dataout ^ nl0illO),
		nl0illO = (wire_ni0iil_dataout ^ wire_ni0iii_dataout),
		nl0ilOi = (wire_ni0iOl_dataout ^ nl0ilOl),
		nl0ilOl = (wire_ni0ilO_dataout ^ nl0ilOO),
		nl0ilOO = (wire_ni0ili_dataout ^ wire_ni0iil_dataout),
		nl0iO0i = (n0O1iO ^ n0O1il),
		nl0iO0l = (nl0iO0O ^ n0O1il),
		nl0iO0O = (n0OOOO ^ n0O1li),
		nl0iO1i = ((n0O1iO ^ n0O1ii) ^ n0O10i),
		nl0iO1l = (n0OOOO ^ n0O1il),
		nl0iO1O = (n0O1li ^ n0O1ii),
		nl0iOii = (nl0iOll ^ n0O10O),
		nl0iOil = (nl0iOiO ^ n0O10O),
		nl0iOiO = (n0O1li ^ n0O1il),
		nl0iOli = (nl0iOll ^ n0O1il),
		nl0iOll = (n0OOOO ^ n0O1iO),
		nl0iOlO = (nl0iOOi ^ n0O1ii),
		nl0iOOi = (n0O1li ^ n0O1iO),
		nl0iOOl = (n0ll1l ^ n0liOi),
		nl0iOOO = ((n0liOO ^ n0liOi) ^ n0lilO),
		nl0l00i = ((((((nli001i ^ nli010O) ^ nli000O) ^ nli0iii) ^ nli0O0O) ^ nlii0Ol) ^ (((nl0l0ii ^ nlOi1OO) ^ nlOi01l) ^ nlOiilO)),
		nl0l00l = ((((((nli01Oi ^ nli011O) ^ nli00ll) ^ nli0iOO) ^ nli0lii) ^ nlii0Oi) ^ ((nlO0Oii ^ nlO0llO) ^ nlOiill)),
		nl0l00O = ((((((nli001i ^ nli011O) ^ nli00Ol) ^ nli0ill) ^ nli0Oli) ^ nlii0lO) ^ (((nl0l0ii ^ nlO0OOO) ^ nlOi1il) ^ nlOiili)),
		nl0l01i = ((((((nli001O ^ nli010O) ^ nli000O) ^ nli0i0O) ^ nli0l1i) ^ nliii1l) ^ (((nlO0Oll ^ nlO0lOO) ^ nlOi10i) ^ nlOiiOO)),
		nl0l01l = (((((((nli001O ^ nli011i) ^ nli00li) ^ nli0lOi) ^ nli0OiO) ^ nlii10l) ^ nliii1i) ^ ((((nlO0OOi ^ nlO0O1O) ^ nlOi10l) ^ nlOi01O) ^ nlOiiOl)),
		nl0l01O = ((((((nl0l0iO ^ nli000l) ^ nli0i1O) ^ nli0ill) ^ nli0lOO) ^ nlii0OO) ^ (((nlO0Oil ^ nlO0O0O) ^ nlOi11l) ^ nlOiiOi)),
		nl0l0ii = (nlO0Oli ^ nlO0O1l),
		nl0l0il = (((((nl0l0iO ^ nli0i0l) ^ nli0l1i) ^ nli0liO) ^ nlii0ll) ^ ((((nlO0OiO ^ nlO0O0l) ^ nlOi11l) ^ nlOi1OO) ^ nlOiiiO)),
		nl0l0iO = (nli001l ^ nli011l),
		nl0l0li = ((((((nli001i ^ nli1OOl) ^ nli00lO) ^ nli0ili) ^ nli0l0i) ^ nlii0li) ^ ((((nlO0OOl ^ nlO0O1O) ^ nlOi11O) ^ nlOi10O) ^ nlOiiil)),
		nl0l0ll = ((((nli01il ^ nli011i) ^ nli0iil) ^ nlii0iO) ^ ((((nlOi11i ^ nlO0lOi) ^ nlOi10l) ^ nlOi1ll) ^ nlOiiii)),
		nl0l0lO = ((((nli01iO ^ nli010l) ^ nli00Oi) ^ nlii0il) ^ (((nlO0OOO ^ nlO0O1i) ^ nlOi1Oi) ^ nlOii0O)),
		nl0l0Oi = ((((((nli000i ^ nli1Oll) ^ nli00il) ^ nli0iii) ^ nli0Oll) ^ nlii0ii) ^ (((nlO0OOl ^ nlO0O0O) ^ nlOi10O) ^ nlOii0l)),
		nl0l0Ol = (((((((nli000i ^ nli011l) ^ nli00iO) ^ nli0i0l) ^ nli0l0O) ^ nli0lOO) ^ nlii00O) ^ ((nlO0Oii ^ nlO0lOl) ^ nlOii0i)),
		nl0l0OO = ((((((nli001O ^ nli1OOl) ^ nli0liO) ^ nli0llO) ^ nli0O1O) ^ nlii00l) ^ (((nlOi11i ^ nlO0lOl) ^ nlOi1li) ^ nlOii1O)),
		nl0l10i = ((nl0l10l ^ n0lill) ^ n0lili),
		nl0l10l = (nl0l10O ^ n0lilO),
		nl0l10O = (n0ll1l ^ n0liOO),
		nl0l11i = ((nl0l1iO ^ n0liOO) ^ n0liOi),
		nl0l11l = (n0ll1l ^ n0liOl),
		nl0l11O = (n0liOO ^ n0liOl),
		nl0l1ii = ((n0ll1l ^ n0lilO) ^ n0lill),
		nl0l1il = (nl0l1iO ^ n0liOl),
		nl0l1iO = (n0ll1l ^ n0ll1i),
		nl0l1ll = ((nlO0l0l ^ ((((nli00iO ^ nli1OOl) ^ nli0ilO) ^ nli0l0i) ^ nli0O1l)) ^ (n1il0O ^ ((nlO0OlO ^ nlO0O0l) ^ nlOi1Oi))),
		nl0l1lO = ((((((nli01ll ^ nli1Oll) ^ nli00Ol) ^ nli00OO) ^ nli0Oil) ^ nliii0O) ^ ((((nlO0OOi ^ nlO0llO) ^ nlOi10i) ^ nlOi1lO) ^ nlOil0i)),
		nl0l1Oi = ((((((((nli000i ^ nli01ii) ^ nli000l) ^ nli0i1l) ^ nli0ili) ^ nli0llO) ^ nli0OlO) ^ nliii0l) ^ (((nlOi10i ^ nlO0O0l) ^ nlOi1iO) ^ nlOil1O)),
		nl0l1Ol = (((((((nli00lO ^ nli001l) ^ nli0i1l) ^ nli0ilO) ^ nli0lli) ^ nli0OiO) ^ nliii0i) ^ (((nlO0OiO ^ nlO0llO) ^ nlOi11i) ^ nlOil1l)),
		nl0l1OO = ((((((nli00ll ^ nli01lO) ^ nli0iiO) ^ nli0l1i) ^ nli0lil) ^ nliii1O) ^ (((nlOi1ll ^ nlO0O0i) ^ nlOi1OO) ^ nlOil1i)),
		nl0li0i = ((((((nli000O ^ nli001i) ^ nli0ili) ^ nli0l0l) ^ nli0Oii) ^ nlii01i) ^ (((nlO0Oll ^ nlO0O1i) ^ nlOi11l) ^ nlOi0Ol)),
		nl0li0l = (((((((((nli001l ^ nli011O) ^ nli00ii) ^ nli0iOl) ^ nli0l0O) ^ nli0lli) ^ nli0OOi) ^ nlii11l) ^ nlii1OO) ^ (((nlO0OOl ^ nlO0O1i) ^ nlOi01i) ^ nlOi0Oi)),
		nl0li0O = ((((((((nli001i ^ nli010i) ^ nli00ii) ^ nli0iil) ^ nli0iOl) ^ nli0l1O) ^ nli0O0l) ^ nlii1Ol) ^ ((nlOi1ii ^ nlO0O1O) ^ nlOi0lO)),
		nl0li1i = (((((((nli01li ^ nli010O) ^ nli00il) ^ nli0i0O) ^ nli0lil) ^ nli0OOO) ^ nlii00i) ^ ((nlO0OlO ^ nlO0O0i) ^ nlOii1l)),
		nl0li1l = (((((((nli01OO ^ nli1OOi) ^ nli00Ol) ^ nli0ilO) ^ nli0l0l) ^ nli0O0i) ^ nlii01O) ^ (((nlO0OiO ^ nlO0O1l) ^ nlOi11l) ^ nlOii1i)),
		nl0li1O = (((((((nli01OO ^ nli010l) ^ nli000l) ^ nli0i1i) ^ nli0ili) ^ nli0lil) ^ nlii01l) ^ (((nlO0Oii ^ nlO0lOO) ^ nlOi1lO) ^ nlOi0OO)),
		nl0liii = ((((((((nli001l ^ nli1OOO) ^ nli00il) ^ nli00OO) ^ nli0l0i) ^ nli0Oii) ^ nlii11i) ^ nlii1Oi) ^ ((nlOi1Oi ^ nlO0O0O) ^ nlOi0ll)),
		nl0liil = (((((((nli001O ^ nli01ii) ^ nli00iO) ^ nli0l1l) ^ nli0OOi) ^ nlii10i) ^ nlii1lO) ^ ((nlOi1Ol ^ nlO0lOO) ^ nlOi0li)),
		nl0liiO = (((((((nli01lO ^ nli010O) ^ nli00Ol) ^ nli0iiO) ^ nli0l1O) ^ nli0lOi) ^ nlii1ll) ^ ((nlOi11O ^ nlO0llO) ^ nlOi0iO)),
		nl0lili = (((((((nli000i ^ nli011i) ^ nli00li) ^ nli0iOl) ^ nli0lll) ^ nli0O1i) ^ nlii1li) ^ ((nlO0OOl ^ nlO0lOi) ^ nlOi0il)),
		nl0lill = (((((((nli01Ol ^ nli1OlO) ^ nli00lO) ^ nli0l1O) ^ nli0llO) ^ nlii11O) ^ nlii1iO) ^ ((nlO0OOO ^ nlO0OOl) ^ nlOi0ii)),
		nl0lilO = ((((((nli01Ol ^ nli1Oll) ^ nli00ii) ^ nli0i0i) ^ nli0iOO) ^ nlii1il) ^ ((nlO0OOi ^ nlO0lOO) ^ nlOi00O)),
		nl0liOi = (((((((nli000i ^ nli011O) ^ nli00ii) ^ nli0iOi) ^ nli0O1i) ^ nli0OlO) ^ nlii1ii) ^ ((nlO0Oil ^ nlO0O0l) ^ nlOi00l)),
		nl0liOl = ((((((nli01iO ^ nli011O) ^ nli0ili) ^ nli0lOl) ^ nli0OOl) ^ nlii10O) ^ ((((nlO0Oli ^ nlO0O1i) ^ nlOi11l) ^ nlOi1iO) ^ nlOi00i)),
		nl0O1il = (n1iOil ^ n1ilil),
		nl0O1iO = (((~ reset_n) | nlO0lii) | (~ (nl0O1li4 ^ nl0O1li3))),
		nl0O1Oi = 1'b1;
endmodule //altpcierd_tx_ecrc_64
//synopsys translate_on
//VALID FILE
