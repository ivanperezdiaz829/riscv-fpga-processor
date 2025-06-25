-- Copyright (C) 1991-2004 Altera Corporation
-- Any megafunction design, and related net list (encrypted or decrypted),
-- support information, device programming or simulation file, and any other
-- associated documentation or information provided by Altera or a partner
-- under Altera's Megafunction Partnership Program may be used only to
-- program PLD devices (but not masked PLD devices) from Altera.  Any other
-- use of such megafunction design, net list, support information, device
-- programming or simulation file, or any other related documentation or
-- information is prohibited for any other purpose, including, but not
-- limited to modification, reverse engineering, de-compiling, or use with
-- any other silicon devices, unless such use is explicitly licensed under
-- a separate agreement with Altera or a megafunction partner.  Title to
-- the intellectual property, including patents, copyrights, trademarks,
-- trade secrets, or maskworks, embodied in any such megafunction design,
-- net list, support information, device programming or simulation file, or
-- any other related documentation or information provided by Altera or a
-- megafunction partner, remains with Altera, the megafunction partner, or
-- their respective licensors.  No other licenses, including any licenses
-- needed under any third party's intellectual property, are provided herein.

FUNCTION pci_t64 (clk, rstn, idsel, cben[7..0], framen_in, req64n_in, irdyn_in, l_adi[63..0], lt_rdyn, lt_abortn, lt_discn, lirqn, l_dis_64_extn)
    WITH (TARGET_DEVICE, PCI_66MHZ_CAPABLE, INTERNAL_ARBITER, VENDOR_ID, DEVICE_ID, REVISION_ID, CLASS_CODE, SUBSYSTEM_ID, SUBSYSTEM_VENDOR_ID, MIN_GRANT, MAX_LATENCY, CAP_PTR, CIS_PTR, ENABLE_BITS, HARDWIRE_EXP_ROM, EXP_ROM_BAR, 
    		INTERRUPT_PIN_REG, NUMBER_OF_BARS, BAR0, BAR1, BAR2, BAR3, BAR4, BAR5,HARDWIRE_BAR0 ,HARDWIRE_BAR1 , HARDWIRE_BAR2 , HARDWIRE_BAR3 , HARDWIRE_BAR4 , HARDWIRE_BAR5, MAX_64_BAR_RW_BITS)
    RETURNS (intan, serrn, ad[63..0], par, par64, perrn, trdyn_out, devseln_out, ack64n_out, stopn_out, l_adro[63..0], l_dato[63..0], l_beno[7..0], l_cmdo[3..0], l_ldat_ackn, l_hdat_ackn, lt_framen, lt_ackn, lt_dxfrn, lt_tsr[11..0], cmd_reg[5..0], stat_reg[5..0]);
