/*
  file: flash_AM29LV065d.c

  contents: implementation of flash routines
            for the AMD part.

        author: Aaron Ferrucci

  10/21/02  Support for 8bit data on
        Nios Pro flash AM29LV065d.
        Tested by writing to AM29LV065d
        on Nios Pro flash (only 8bit data).

  11/8/04  Marcus Negron
  	Changed arbitrary AMD algorithm addresses (am29lv065d don't cares)
  	to specific algorithm addresses (other CFI command 02 flash cares)
  	so that this driver may work with other devices than the am29lv065d,
  	like perhaps am29lv128m or Atmel flash, or just "look like each other".
	Also, fixed the sector map to be correct for am29lv065d.
	Test using NDKs 1S10, 1S40, and 1C20 (8bit data).
*/


#include "excalibur.h"


// +-----------------------------
// | Some CPU's need to have their
// | caches flushed all the time when
// | dealing with flash. The Nios 2
// | definitely does. It does not hurt
// | to do this for first generation
// | Nios, but it is not needed and
// | makes the code just barely too
// | large for the Germs monitor.
// |
// | So, here, we squelch it.
// |

#if defined(nm_cpu_architecture) && (nm_cpu_architecture == nios2)
#define DO_CACHE_INIT 1
#else
#define DO_CACHE_INIT 0
#endif


// ---------------------------------------------
// Private Routines

// Wait for the given address to contain 0xFF.
// Return value: 1 on success, 0 on timeout failure.

static int await_erase_complete(int entire_chip, volatile unsigned char *addr)
{
  int iTimeout = 40;

  // The "typical" time for an erase command is 0.7 seconds.
  // Empirically (as expected), it takes longer to erase the entire
  // chip than a single sector. Give a generous timeout for a single
  // sector, and even more for the entire chip.

  if (entire_chip)
    iTimeout = 20000;

  while (iTimeout)
  {
    nr_delay(100);      // Wait 100 ms.
    if (0xFF == *addr)  // done? note: 8bit data
                  {
                    return 0;     // leave
                  }

    iTimeout--;
  }

  // Timeout error.
  return -1;
}

// This routine actually takes about 3 us on a 33.333MHz Nios32.
static wait_at_least_1_us(void)
{
  volatile unsigned long iTimeout = nasys_clock_freq_1000 / 8250;
  while (iTimeout--)
  {
    ;
  }
}

// Unlock bypass mode, enabling fast writes.
static void unlock_bypass_mode(volatile unsigned char *flash_base)
{ // 065d
  flash_base[0xAAA] = 0xAA; // unlock bypass command - cycle 1
  flash_base[0x555] = 0x55; // unlock bypass command - cycle 2
  flash_base[0xAAA] = 0x20; // unlock bypass command - cycle 3
}

// Turn bypass mode off, disabling fast writes and enabling normal function.
static void reset_bypass_mode(volatile unsigned char *flash_base)
{
  *flash_base = 0x90; // exit unlock bypass reset command - cycle 1
  *flash_base = 0x0;  // exit unlock bypass reset command - cycle 2
}

// Read the given address until two successive reads yield the
// same value.
// Return value: 0 on success, -1 on timeout failure.
static int await_write_complete(volatile unsigned char *addr, const unsigned char correct_value)
{
        //
        // TPA 2/14/2003: The *Maximum* programming time is 150us.
        //                Waiting several times the maximum time
        //                seems like a much better idea than giving-up
        //                well before the published spec says we
        //                should.
        //
  unsigned long iTimeout = 600;
  int return_value = -1; // Pessimistic return value.

  while (iTimeout)
  {
    wait_at_least_1_us();

    // While the flash is working on program data, read accesses return
    // "status" instead of data.  Status bit 7 is the complement of the
    // data being written.  When the program operation is complete and
    // successful, the written data is returned.  So, read the written
    // address until it equals the data written.

    if (*addr == correct_value)
      break;
    iTimeout--;
  }

  if (iTimeout)
    return_value = 0;

  return return_value;
}

static int erase_flash_single_command(volatile unsigned char *flash_base)
{
  int result;

#if DO_CACHE_INIT
  nr_dcache_init();
  nr_icache_init();
#endif

// Erase the entire flash in one command. AKA CHIP ERASE on AM29LV065d
  flash_base[0xAAA] = 0xAA; // 1st cycle
  flash_base[0x555] = 0x55; // 2nd cycle
  flash_base[0xAAA] = 0x80; // 3rd cycle
  flash_base[0xAAA] = 0xAA; // 4th cycle
  flash_base[0x555] = 0x55; // 5th cycle
  flash_base[0xAAA] = 0x10; // 6th cycle

  result = await_erase_complete(1, flash_base);
}               // (entire chip, base)


// Write val to the given flash address, in bypass mode (assumes
// that bypass mode has been enabled already).
// Return value: 0 on success, -1 on failure.
static int nr_flash_write_bypass(volatile unsigned char *flash_base,
  volatile unsigned char *addr, unsigned char val)
{
  unsigned char us1, us2;
  int iTimeout;
  int result = 0;

  nm_dcache_invalidate_line(addr);
  nm_icache_invalidate_line(addr);

  *flash_base = 0xA0;   // unlock bypass program command - 1st cycle
  *addr = val;          // program address and data    - 2nd cycle

  result = await_write_complete(addr,val);
  if(result)
    return result;

  us1 = *addr;

  if (us1 != val)
    result = -1;

  return result;
}

// ---------------------------------------------
// Public Routines

// Erase the flash sector at sector_address.
// Return value: 0 on success, -1 on failure.

int nr_flash_erase_sector
  (
      unsigned short *flash_base,
      unsigned short *sector_address
  )
{
  volatile unsigned char *fb = (unsigned char *) flash_base;
  volatile unsigned char *sa = (unsigned char *) sector_address;
  int result;

#if DO_CACHE_INIT
  nr_dcache_init();
  nr_icache_init();
#endif

#ifdef nasys_main_flash
  if (-1 == (int)fb)
    fb = nasys_main_flash;
#endif // nasys_main_flash
//  AM29LV065d
  fb[0xAAA] = 0xAA; // 1st cycle
  fb[0x555] = 0x55; // 2nd cycle
  fb[0xAAA] = 0x80; // 3rd cycle
  fb[0xAAA] = 0xAA; // 4th cycle
  fb[0x555] = 0x55; // 5th cycle

  *sa = 0x30; // 6th cycle

  // Loop until the data reads as 0xFF.

  result = await_erase_complete(0, sa);
  return result;
}


// Erase the entire flash.
// Return value: 0 on success, -1 on failure.

int nr_flash_erase(unsigned short *flash_base)
{
  volatile unsigned char *fb = (unsigned char*) flash_base;
  int result = 0;

#if DO_CACHE_INIT
  nr_dcache_init();
  nr_icache_init();
#endif

#if __nios32__
#define ALLSECTORERASE 1
#if ALLSECTORERASE
#ifdef nasys_main_flash
  if (-1 == (int)fb)
  {
    fb = nasys_main_flash;
  }
#endif // nasys_main_flash

  result = erase_flash_single_command(fb);
  return result;

#else // !ALLSECTORERASE

  int i;

  // For nios32, the AM29LV065d is divided into sectors as follows:
  // [0x000000, 0x010000)
  // [0x010000, 0x020000)
  // [0x020000, 0x030000)
  // etc...
  int sectorOffset[] =  // AM29LV065d sector map
  {
    0x000000, 0x010000, 0x020000, 0x030000,
    0x040000, 0x050000, 0x060000, 0x070000,
    0x080000, 0x090000, 0x0A0000, 0x0B0000,
    0x0C0000, 0x0D0000, 0x0E0000, 0x0F0000,
    0x100000, 0x110000, 0x120000, 0x130000,
    0x140000, 0x150000, 0x160000, 0x170000,
    0x180000, 0x190000, 0x1A0000, 0x1B0000,
    0x1C0000, 0x1D0000, 0x1E0000, 0x1F0000,
    0x200000, 0x210000, 0x220000, 0x230000,
    0x240000, 0x250000, 0x260000, 0x270000,
    0x280000, 0x290000, 0x2A0000, 0x2B0000,
    0x2C0000, 0x2D0000, 0x2E0000, 0x2F0000,
    0x300000, 0x310000, 0x320000, 0x330000,
    0x340000, 0x350000, 0x360000, 0x370000,
    0x380000, 0x390000, 0x3A0000, 0x3B0000,
    0x3C0000, 0x3D0000, 0x3E0000, 0x3F0000,
    0x400000, 0x410000, 0x420000, 0x430000,
    0x440000, 0x450000, 0x460000, 0x470000,
    0x480000, 0x490000, 0x4A0000, 0x4B0000,
    0x4C0000, 0x4D0000, 0x4E0000, 0x4F0000,
    0x500000, 0x510000, 0x520000, 0x530000,
    0x540000, 0x550000, 0x560000, 0x570000,
    0x580000, 0x590000, 0x5A0000, 0x5B0000,
    0x5C0000, 0x5D0000, 0x5E0000, 0x5F0000,
    0x600000, 0x610000, 0x620000, 0x630000,
    0x640000, 0x650000, 0x660000, 0x670000,
    0x680000, 0x690000, 0x6A0000, 0x6B0000,
    0x6C0000, 0x6D0000, 0x6E0000, 0x6F0000,
    0x700000, 0x710000, 0x720000, 0x730000,
    0x740000, 0x750000, 0x760000, 0x770000,
    0x780000, 0x790000, 0x7A0000, 0x7B0000,
    0x7C0000, 0x7D0000, 0x7E0000, 0x7F0000,
  };

  if (-1 == (int)fb)
    fb = nasys_main_flash;

  // Erase each sector in turn.

  for (i = 0; i < sizeof(sectorOffset) / sizeof(*sectorOffset); ++i)
  {
    int sector = (int)fb + sectorOffset[i];

    result = nr_flash_erase_sector(fb, (unsigned char*)sector);
    if(result)
      break;
  }
  return result;

#endif // ALLSECTORERASE
#else // !__nios32__
#ifdef nasys_main_flash
  if (-1 == (int)fb)
    fb = nasys_main_flash;
#endif // nasys_main_flash

  result =  erase_flash_single_command(fb);
  return result;

#endif // __nios32__
}

// Write val to the given flash address.
// Return value: 1 on success, 0 on failure.
int amd29lv065d_flash_write_byte
  (
    unsigned char *flash_base,
    unsigned char *addr,
    unsigned char val
  )
{
  volatile unsigned char *fb = flash_base;
  volatile unsigned char *a = addr;
  unsigned char us1, us2;
  int result = 0;

  nm_dcache_invalidate_line(a);
  nm_icache_invalidate_line(a);

#ifdef nasys_main_flash
  if (-1 == (int)fb)
    fb = nasys_main_flash;
#endif // nasys_main_flash

  fb[0x555] = 0xAA; // 1st cycle  addr = XXX, data = AA
  fb[0x333] = 0x55; // 2nd cycle  addr = XXX, data = 55
  fb[0x555] = 0xA0; // 3rd cycle  addr = XXX, data = A0

  *a = val;     // 4th cycle  addr = PA, data = PD

  result = await_write_complete(a,val);
  if(result)
    return result;

  us1 = *a;
  if (us1 != val)
    result = -1;

  return result;
}

int nr_flash_write
    (
    unsigned short *flash_base,
    unsigned short *addr,
    unsigned short val
    )
{
  unsigned char* fb       = (unsigned char *) flash_base;
  unsigned char* a        = (unsigned char *) addr;
  unsigned char  byte_val = val & 0xff;
  int result;

  result = amd29lv065d_flash_write_byte (fb, a,   byte_val);

  // Nonzero result means error.
  if (result)
    return result;

  byte_val = (val >> 8) & 0xff;
  result = amd29lv065d_flash_write_byte (fb, a+1, byte_val);
  return result;
}

// Write a buffer of data to the flash, using bypass mode.
// Return value: 1 on success, 0 on failure.
// Note: the integer "size" is given as a number of half-words to
// write.   How convenient.  We write this 8-bit-wide flash one byte
// at a time (of course).
int nr_flash_write_buffer
    (
    unsigned short *flash_base,
    unsigned short *start_address,
    unsigned short *buffer,
    int size
    )
{
  volatile unsigned char *fb  = (unsigned char *) flash_base;
                 unsigned char *sa  = (unsigned char *) start_address;
                 unsigned char *buf = (unsigned char *) buffer;
        int num_bytes = size * 2;
  int i;
  int result = 0;

#ifdef nasys_main_flash
  if (-1 == (int)fb)
    fb = nasys_main_flash;
#endif // nasys_main_flash

  unlock_bypass_mode(fb);
  for (i = 0; i < num_bytes; ++i)
  {
    result = nr_flash_write_bypass(fb, sa + i, buf[i]);
    if(result)
      break;

  }
  reset_bypass_mode(fb);

  return result;
}


