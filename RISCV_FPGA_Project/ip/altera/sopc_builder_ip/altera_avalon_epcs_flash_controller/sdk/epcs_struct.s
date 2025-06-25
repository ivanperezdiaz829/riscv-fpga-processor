
  .equ nk_epcs_64K,0
  .equ nk_epcs_1M,0
  .equ nk_epcs_4M,1

; ----------------------------------------------
; EPCS Peripheral
;
  ;
  ; EPCS Registers
  ;
  .equ np_epcsrxdata,      256+0 ; Read-only, 1-16 bit
  .equ np_epcstxdata,      256+1 ; Write-only, same width as rxdata
  .equ np_epcsstatus,      256+2 ; Read-only, 9-bit
  .equ np_epcscontrol,     256+3 ; Read/Write, 9-bit
  .equ np_epcsreserved,    256+4 ; reserved
  .equ np_epcsslaveselect, 256+5 ; Read/Write, 1-16 bit, master only
  .equ np_epcsendofpacket, 256+6 ; Read/write, same width as txdata, rxdata.

  ;
  ; EPCS Status Register
  ;
  .equ np_epcsstatus_eop_mask,  (1 << 9)
  .equ np_epcsstatus_e_mask,    (1 << 8)
  .equ np_epcsstatus_rrdy_mask, (1 << 7)
  .equ np_epcsstatus_trdy_mask, (1 << 6)
  .equ np_epcsstatus_tmt_mask,  (1 << 5)
  .equ np_epcsstatus_toe_mask,  (1 << 4)
  .equ np_epcsstatus_roe_mask,  (1 << 3)

  .equ np_epcsstatus_eop_bit,  9
  .equ np_epcsstatus_e_bit,    8
  .equ np_epcsstatus_rrdy_bit, 7
  .equ np_epcsstatus_trdy_bit, 6
  .equ np_epcsstatus_tmt_bit,  5
  .equ np_epcsstatus_toe_bit,  4
  .equ np_epcsstatus_roe_bit,  3

  ;
  ; EPCS Control Register
  ;
  .equ np_epcscontrol_sso_mask,   (1 << 10)
  .equ np_epcscontrol_ieop_mask,  (1 << 9)
  .equ np_epcscontrol_ie_mask,    (1 << 8)
  .equ np_epcscontrol_irrdy_mask, (1 << 7)
  .equ np_epcscontrol_itrdy_mask, (1 << 6)
  .equ np_epcscontrol_itoe_mask,  (1 << 4)
  .equ np_epcscontrol_iroe_mask,  (1 << 3)

  .equ np_epcscontrol_sso_bit,   10
  .equ np_epcscontrol_ieop_bit,  9
  .equ np_epcscontrol_ie_bit,    8
  .equ np_epcscontrol_irrdy_bit, 7
  .equ np_epcscontrol_itrdy_bit, 6
  .equ np_epcscontrol_itoe_bit,  4
  .equ np_epcscontrol_iroe_bit,  3

  ; EPCS memory definitions
.if nk_epcs_64K
  .equ na_epcs_bulk_size,   (0x2000)
  .equ na_epcs_sector_size, (na_epcs_bulk_size >> 2)
  .equ na_epcs_page_size,   0x20

.elseif nk_epcs_1M
  .equ na_epcs_bulk_size,   (0x20000)
  .equ na_epcs_sector_size, (na_epcs_bulk_size >> 2)
  .equ na_epcs_page_size,   0x100

.elseif nk_epcs_4M
  .equ na_epcs_bulk_size,   (0x80000)
  .equ na_epcs_sector_size, (na_epcs_bulk_size >> 3)
  .equ na_epcs_page_size,   0x100
.endif

  ;EPCS memory instructions
  .equ na_epcs_read,    0x03
  .equ na_epcs_write,   0x02
  .equ na_epcs_wren,    0x06
  .equ na_epcs_wrdi,    0x04
  .equ na_epcs_rdsr,    0x05
  .equ na_epcs_wrsr,    0x01
  .equ na_epcs_se,      0xd8
  .equ na_epcs_be,      0xc7
  .equ na_epcs_dp,      0xb9

  ;EPCS memory status register bit masks
.if (nk_epcs_64K) || (nk_epcs_1M)
  .equ na_epcs_bp,      0xc
.else
  .equ na_epcs_bp,      0x1c
.endif
  .equ na_epcs_wel,     0x2
  .equ na_epcs_wip,     0x1

  ;EPCS protection masks
  .equ na_epcs_protect_none,        0
.if (nk_epcs_64K) || (nk_epcs_1M)
  .equ na_epcs_protect_top_quarter, 0x4
  .equ na_epcs_protect_top_half,    0x8
  .equ na_epcs_protect_all,         0xc
.else
  .equ na_epcs_protect_top_eighth,  0x4
  .equ na_epcs_protect_top_quarter, 0x8
  .equ na_epcs_protect_top_half,    0xc
  .equ na_epcs_protect_all,         0x10
.endif

