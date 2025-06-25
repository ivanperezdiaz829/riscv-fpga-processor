

#define nk_epcs_64K 0
#define nk_epcs_1M 0
#define nk_epcs_4M 1

// EPCS Registers
typedef volatile struct
  {
  int np_dummy[256];       // EPCS component fills lower 1k with code
  int np_epcsrxdata;       // Read-only, 1-16 bit
  int np_epcstxdata;       // Write-only, same width as rxdata
  int np_epcsstatus;       // Read-only, 9-bit
  int np_epcscontrol;      // Read/Write, 9-bit
  int np_epcsreserved;     // reserved
  int np_epcsslaveselect;  // Read/Write, 1-16 bit, master only
  int np_epcsendofpacket;  // Read/write, same width as txdata, rxdata.
  } np_epcs;

// EPCS Status Register Bits
enum
  {
  np_epcsstatus_eop_bit  = 9,
  np_epcsstatus_e_bit    = 8,
  np_epcsstatus_rrdy_bit = 7,
  np_epcsstatus_trdy_bit = 6,
  np_epcsstatus_tmt_bit  = 5,
  np_epcsstatus_toe_bit  = 4,
  np_epcsstatus_roe_bit  = 3,

  np_epcsstatus_eop_mask  = (1 << 9),
  np_epcsstatus_e_mask    = (1 << 8),
  np_epcsstatus_rrdy_mask = (1 << 7),
  np_epcsstatus_trdy_mask = (1 << 6),
  np_epcsstatus_tmt_mask  = (1 << 5),
  np_epcsstatus_toe_mask  = (1 << 4),
  np_epcsstatus_roe_mask  = (1 << 3),
  };

// EPCS Control Register Bits
enum
  {
  np_epcscontrol_sso_bit   = 10,
  np_epcscontrol_ieop_bit  = 9,
  np_epcscontrol_ie_bit    = 8,
  np_epcscontrol_irrdy_bit = 7,
  np_epcscontrol_itrdy_bit = 6,
  np_epcscontrol_itoe_bit  = 4,
  np_epcscontrol_iroe_bit  = 3,

  np_epcscontrol_sso_mask   = (1 << 10),
  np_epcscontrol_ieop_mask  = (1 << 9),
  np_epcscontrol_ie_mask    = (1 << 8),
  np_epcscontrol_irrdy_mask = (1 << 7),
  np_epcscontrol_itrdy_mask = (1 << 6),
  np_epcscontrol_itoe_mask  = (1 << 4),
  np_epcscontrol_iroe_mask  = (1 << 3),
  };


//EPCS memory definitions
#if nk_epcs_64K
#define na_epcs_bulk_size   (0x2000)
#define na_epcs_sector_size (na_epcs_bulk_size >> 2)
#define na_epcs_page_size   0x20

#elif nk_epcs_1M
#define na_epcs_bulk_size   (0x20000)
#define na_epcs_sector_size (na_epcs_bulk_size >> 2)
#define na_epcs_page_size   0x100

#elif nk_epcs_4M
#define na_epcs_bulk_size   (0x80000)
#define na_epcs_sector_size (na_epcs_bulk_size >> 3)
#define na_epcs_page_size   0x100
#endif

//EPCS memory instructions
#define na_epcs_read    (unsigned char)0x03
#define na_epcs_write   (unsigned char)0x02
#define na_epcs_wren    (unsigned char)0x06
#define na_epcs_wrdi    (unsigned char)0x04
#define na_epcs_rdsr    (unsigned char)0x05
#define na_epcs_wrsr    (unsigned char)0x01
#define na_epcs_se      (unsigned char)0xd8
#define na_epcs_be      (unsigned char)0xc7
#define na_epcs_dp      (unsigned char)0xb9

//EPCS memory status register bit masks
#if (na_epcs_64K) || (na_epcs_1M)
#define na_epcs_bp      (unsigned char)0xc
#else
#define na_epcs_bp      (unsigned char)0x1c
#endif
#define na_epcs_wel     (unsigned char)0x2
#define na_epcs_wip     (unsigned char)0x1

//EPCS function error codes
#define na_epcs_success                 0
#define na_epcs_err_device_not_present  1
#define na_epcs_err_device_not_ready    2
#define na_epcs_err_timedout            3
#define na_epcs_err_write_failed        4
#define na_epcs_invalid_config          5

//EPCS protection masks
#define na_epcs_protect_none        0
#if (na_epcs_64K) || (na_epcs_1M)
#define na_epcs_protect_top_quarter 0x4
#define na_epcs_protect_top_half    0x8
#define na_epcs_protect_all         0xc
#else
#define na_epcs_protect_top_eighth  0x4
#define na_epcs_protect_top_quarter 0x8
#define na_epcs_protect_top_half    0xc
#define na_epcs_protect_all         0x10
#endif

//EPCS macros
//returns the protect bits shifted into the lsbs
#define nm_epcs_prot_sect(t) ((t & na_epcs_bp) >> 2)

//EPCS library routines
//

extern unsigned char nr_epcs_read_status ();
extern unsigned long nr_epcs_lowest_protected_address();
extern int nr_epcs_write_status (unsigned char value);
extern int nr_epcs_protect_region (int bpcode);
extern int nr_epcs_read_byte (unsigned long address, unsigned char *data);
extern int nr_epcs_write_byte (unsigned long address, unsigned char data);
extern int nr_epcs_erase_sector (unsigned long address);
extern int nr_epcs_erase_bulk ();
extern int nr_epcs_read_buffer (unsigned long address, int length, unsigned char *data);
extern int nr_epcs_write_page (unsigned long address, int length, unsigned char *data);
extern int nr_epcs_write_buffer (unsigned long address, int length, unsigned char *data);
extern int nr_epcs_address_past_config (unsigned long *addr);
        
