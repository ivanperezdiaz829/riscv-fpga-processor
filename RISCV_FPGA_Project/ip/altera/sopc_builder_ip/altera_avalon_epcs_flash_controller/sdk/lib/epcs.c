// file: epcs.c
//
// 2004.02.09 dvb: copied from asmi.c with only name changes
//

//TODO: Increase address from 2 bytes to 3
#include "excalibur.h"

//wait until all the data is shifted out
void nr_epcs_wait_tx_complete ()
{
    while (!(na_epcs_controller->np_epcsstatus & np_epcsstatus_tmt_mask));
}

//set the chip-select
void nr_epcs_set_cs ()
{
    na_epcs_controller->np_epcscontrol = np_epcscontrol_sso_mask;
}

//clear the chip-select
void nr_epcs_clear_cs ()
{
    int value;
    nr_epcs_wait_tx_complete (na_epcs_controller);

    //clear only the sso bit
    value = na_epcs_controller->np_epcscontrol;
    value = value & (~np_epcscontrol_sso_mask);

    na_epcs_controller->np_epcscontrol = value;
}

//send 8 bits to the memory
void nr_epcs_txchar (unsigned char data)
{
    while (!(na_epcs_controller->np_epcsstatus & np_epcsstatus_trdy_mask));
    na_epcs_controller->np_epcstxdata = data;
}

//receive 8 bits from the memory
unsigned char nr_epcs_rxchar ()
{
    while (!(na_epcs_controller->np_epcsstatus & np_epcsstatus_rrdy_mask));
    return (na_epcs_controller->np_epcsrxdata);
}

//read the memories status register
unsigned char nr_epcs_read_status ()
{
    unsigned char value;
    // set chip select
    nr_epcs_set_cs ();

    // send READ command
    nr_epcs_txchar (na_epcs_rdsr);
    nr_epcs_rxchar ();   // throw out the garbage
    // read the byte
    nr_epcs_txchar (0); // send out some garbage while were reading
    value = nr_epcs_rxchar ();

    // clear chip select
    nr_epcs_clear_cs ();

    return (value);
}

//wait until the write operation is finished
int nr_epcs_wait_write_complete ()
{
    volatile unsigned long int i=0;

    // Compute a maximum timeout value for all callers of this function.
    // This value is computed for a maximum timeout of 10s (EPCS4 bulk
    // erase).  The calculation goes as follows:
    //
    // maximum EPCS clock rate: 20MHz
    // read status time: 16 clocks + 1/2 clock period on either side =
    //   17/20M = 850ns
    // 10s / 850ns = 11,764,706 read status commands.
    const unsigned long i_timeout=11770000;

    while ((nr_epcs_read_status() & na_epcs_wip) && (i<i_timeout))
    {
        i++;
    }
    if (i >= i_timeout)
        return (na_epcs_err_timedout);
    else
        return (na_epcs_success);
}

//returns true if the chip is present else false
int nr_epcs_is_device_present ()
{
    volatile int i;

    // set chip select
    nr_epcs_set_cs ();
    // send WRITE ENABLE command
    nr_epcs_txchar (na_epcs_wren);
    nr_epcs_rxchar ();  // throw out the garbage
    //clear chip select to set write enable latch
    nr_epcs_clear_cs ();
    // some delay between chip select change
    for (i=0;i<20;i++);

    //not check the value
    i = nr_epcs_read_status ();
    if (i & na_epcs_wel)
    {
        // previous write worked,
        // but if the pins are floating,
        // we don't know what the value might be,
        // so lets switch values and check again
        // set chip select
        nr_epcs_set_cs ();
        // send WRITE DISABLE command
        nr_epcs_txchar (na_epcs_wrdi);
        nr_epcs_rxchar ();  // throw out the garbage
        //clear chip select to set write enable latch
        nr_epcs_clear_cs ();
        // some delay between chip select change
        for (i=0;i<20;i++);

        //now check the value again
        i = nr_epcs_read_status ();
        if ((i & na_epcs_wel) == 0)
            return (1);
    }
    //if we made it this far then the device is not present
    return (0);
}

//returns the lowest protected address
unsigned long nr_epcs_lowest_protected_address()
{
    int bp;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    bp = nr_epcs_read_status () & na_epcs_bp;
    switch (bp)
    {
#if ((nk_epcs_64K) || (nk_epcs_1M))
        case na_epcs_protect_all:
            return (0);
        default:
            return (na_epcs_bulk_size - (na_epcs_sector_size * (bp>>2)));
#else
        case na_epcs_protect_none:
        case na_epcs_protect_top_eighth:
        case na_epcs_protect_top_quarter:
            return (na_epcs_bulk_size - (na_epcs_sector_size * (bp>>2)));
        case na_epcs_protect_top_half:
            return (na_epcs_bulk_size >> 1);
        default:
            return (0);
#endif
    }
    //this should never happen, but to make the compiler happy...
    return (0);
}

int nr_epcs_write_status (unsigned char value)
{
    volatile int i;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    // set chip select
    nr_epcs_set_cs ();
    // send WRITE ENABLE command
    nr_epcs_txchar (na_epcs_wren);
    nr_epcs_rxchar ();  // throw out the garbage
    // clear chip select to set write enable latch
    nr_epcs_clear_cs ();
    // some dealy between chip select change
    for (i=0; i<20; i++);

    // set chip select
    nr_epcs_set_cs ();

    // send WRSR command
    nr_epcs_txchar (na_epcs_wrsr);
    nr_epcs_rxchar ();   // throw out the garbage
    // write the byte
    nr_epcs_txchar (value);
    nr_epcs_rxchar ();

    // clear chip select
    nr_epcs_clear_cs ();

    //now wait until the write operation is finished
    if (i=nr_epcs_wait_write_complete ())
        return (i);

    //now verify that the write was successful
    i = nr_epcs_read_status ();
    if (i != (int)value) return (na_epcs_err_write_failed);

    return (na_epcs_success);
}

//set the status register to protect the selected region
int nr_epcs_protect_region (int bpcode)
{
    unsigned char value;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    value = nr_epcs_read_status ();
    value = value & (!na_epcs_bp);
    value |= bpcode;
    return (nr_epcs_write_status (value));
}

//read 1 byte from the memory
int nr_epcs_read_byte (unsigned long address, unsigned char *data)
{
    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    // set chip select
    nr_epcs_set_cs ();

    // send READ command
    nr_epcs_txchar (na_epcs_read);
    nr_epcs_rxchar ();
    // send high byte of address
    nr_epcs_txchar ((address >> 16)&0x000000ff);
    nr_epcs_rxchar ();
    // send middle byte of address
    nr_epcs_txchar ((address >> 8)&0x000000ff);
    nr_epcs_rxchar ();
    // send low byte of address
    nr_epcs_txchar (address&0x000000ff);
    nr_epcs_rxchar ();
    // read the byte
    nr_epcs_txchar (0); // send out some garbage while were reading
    *data = (unsigned char) nr_epcs_rxchar ();

    // clear chip select
    nr_epcs_clear_cs ();

    return (na_epcs_success);
}

//write 1 byte to the memroy
int nr_epcs_write_byte (unsigned long address, unsigned char data)
{
    volatile int i;
    unsigned char verify;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    // make sure the address is writable
    if (address >= nr_epcs_lowest_protected_address())
        return (na_epcs_err_write_failed);

    // set chip select
    nr_epcs_set_cs ();
    // send WRITE ENABLE command
    nr_epcs_txchar (na_epcs_wren);
    nr_epcs_rxchar ();  // throw out the garbage
    // clear chip select to set write enable latch
    nr_epcs_clear_cs ();
    //maybe we need some delay here?
    for (i=0; i<20; i++);

    //set chip select
    nr_epcs_set_cs ();
    // send WRITE command
    nr_epcs_txchar (na_epcs_write);
    nr_epcs_rxchar ();   // throw out the garbage
    // send high byte of address
    nr_epcs_txchar ((address >> 16)&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage
    // send middle byte of address
    nr_epcs_txchar ((address >> 8)&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage
    // send low byte of address
    nr_epcs_txchar (address&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage
    // send the data
    nr_epcs_txchar (data);
    nr_epcs_rxchar ();   // throw out the garbage

    // clear chip select to set complete the write cycle
    nr_epcs_clear_cs ();

    //now wait until the write operation is finished
    if (i=nr_epcs_wait_write_complete ())
        return (i);

    //now verify that the write was successful
    nr_epcs_read_byte (address, &verify);
    if (verify != data) return (na_epcs_err_write_failed);

    return (na_epcs_success);
}

//erase sector which contains address
int nr_epcs_erase_sector (unsigned long address)
{
    volatile int i;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    // make sure the address is writable
    if (address >= nr_epcs_lowest_protected_address())
        return (na_epcs_err_write_failed);

    // set chip select
    nr_epcs_set_cs ();
    // send WRITE ENABLE command
    nr_epcs_txchar (na_epcs_wren);
    nr_epcs_rxchar ();  // throw out the garbage
    // clear chip select to set write enable latch
    nr_epcs_clear_cs ();
    //maybe we need some delay here?
    for (i=0; i<20; i++);

    //set chip select
    nr_epcs_set_cs ();
    // send SE command
    nr_epcs_txchar (na_epcs_se);
    nr_epcs_rxchar ();   // throw out the garbage
    // send high byte of address
    nr_epcs_txchar ((address >> 16)&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage
    // send middle byte of address
    nr_epcs_txchar ((address >> 8)&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage
    // send low byte of address
    nr_epcs_txchar (address&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage

    // clear chip select to complete the write cycle
    nr_epcs_clear_cs ();

    //now wait until the write operation is finished
    if (i=nr_epcs_wait_write_complete ())
        return (i);

    return (na_epcs_success);
}

//erase entire chip
int nr_epcs_erase_bulk ()
{
    volatile int i;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    // make sure the address is writable
    if (nr_epcs_lowest_protected_address() != na_epcs_bulk_size)
        return (na_epcs_err_write_failed);

    // set chip select
    nr_epcs_set_cs ();
    // send WRITE ENABLE command
    nr_epcs_txchar (na_epcs_wren);
    nr_epcs_rxchar ();  // throw out the garbage
    // clear chip select to set write enable latch
    nr_epcs_clear_cs ();
    //maybe we need some delay here?
    for (i=0; i<20; i++);

    //set chip select
    nr_epcs_set_cs ();
    // send BE command
    nr_epcs_txchar (na_epcs_be);
    nr_epcs_rxchar ();   // throw out the garbage

    // clear chip select to complete the write cycle
    nr_epcs_clear_cs ();

    //now wait until the write operation is finished
    if (i=nr_epcs_wait_write_complete ())
        return (i);

    return (na_epcs_success);
}

//read buffer from memory
int nr_epcs_read_buffer (unsigned long address, int length,
            unsigned char *data)
{
    volatile int i;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    // set chip select
    nr_epcs_set_cs ();

    // send READ command
    nr_epcs_txchar (na_epcs_read);
    nr_epcs_rxchar ();
    // send high byte of address
    nr_epcs_txchar ((address >> 16)&0x000000ff);
    nr_epcs_rxchar ();
    // send middle byte of address
    nr_epcs_txchar ((address >> 8)&0x000000ff);
    nr_epcs_rxchar ();
    // send low byte of address
    nr_epcs_txchar (address&0x000000ff);
    nr_epcs_rxchar ();
    while (length-- > 0)
    {
        // read the byte
        nr_epcs_txchar (0); // send out some garbage while were reading
        *data++ = nr_epcs_rxchar ();
    }

    // clear chip select
    nr_epcs_clear_cs ();

    return (na_epcs_success);
}
//write page to memory
int nr_epcs_write_page (unsigned long address, int length,
            unsigned char *data)
{
    volatile int i;
    unsigned char verify[na_epcs_page_size];
    int my_length = length;
    unsigned char *my_data = data;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    // set chip select
    nr_epcs_set_cs ();
    // send WRITE ENABLE command
    nr_epcs_txchar (na_epcs_wren);
    nr_epcs_rxchar ();  // throw out the garbage
    // clear chip select to set write enable latch
    nr_epcs_clear_cs ();
    //maybe we need some delay here?
    for (i=0; i<20; i++);

    //set chip select
    nr_epcs_set_cs ();
    // send WRITE command
    nr_epcs_txchar (na_epcs_write);
    nr_epcs_rxchar ();   // throw out the garbage
    // send high byte of address
    nr_epcs_txchar ((address >> 16)&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage
    // send middle byte of address
    nr_epcs_txchar ((address >> 8)&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage
    // send low byte of address
    nr_epcs_txchar (address&0x000000ff);
    nr_epcs_rxchar ();   // throw out the garbage
    // send the data
    while (my_length-- > 0)
    {
        // write the byte
        nr_epcs_txchar (*my_data++);
        nr_epcs_rxchar ();   // throw out the garbage
    }

    // clear chip select to complete the write cycle
    nr_epcs_clear_cs ();

    //now wait until the write operation is finished
    if (i=nr_epcs_wait_write_complete ())
        return (i);

    //verify that the data was correctly written
    nr_epcs_read_buffer (address, length, verify);
    for (i=0; i<length; i++)
    {
        if (verify[i] != data[i]) return (na_epcs_err_write_failed);
    }
    return (na_epcs_success);
}

//write buffer to memroy
int nr_epcs_write_buffer (unsigned long address, int length,
            unsigned char *data)
{
    volatile int i;
    int status;

    //verify device presence
    if (!nr_epcs_is_device_present())
        return (na_epcs_err_device_not_present);

    // make sure the full address range is writable
    if ((address >= nr_epcs_lowest_protected_address()) ||
        ((address+length-1) >= nr_epcs_lowest_protected_address()))
        return (na_epcs_err_write_failed);

    //send partial first page (if there is one)
    i = address % na_epcs_page_size;
    if ((i != 0) && (i+length > na_epcs_page_size))
    {
        i = na_epcs_page_size-i;
        if (status = nr_epcs_write_page (address, i, data))
            return (status); //write failed
        address += i;
        data += i;
        length -= i;
    }

    //send all full pages
    while (length/na_epcs_page_size > 0)
    {
        if (status = nr_epcs_write_page (address, na_epcs_page_size, data))
            return (status); //write failed
        address += na_epcs_page_size;
        data += na_epcs_page_size;
        length -= na_epcs_page_size;
    }

    //send partial last page (if there is one)
    if (length > 0)
    {
        if (status = nr_epcs_write_page (address, length, data))
            return (status); //write failed
    }

    return (na_epcs_success);
}

#define NR_EPCS_BITREVERSE(x) \
  ((((x) & 0x80) ? 0x01 : 0) | \
   (((x) & 0x40) ? 0x02 : 0) | \
   (((x) & 0x20) ? 0x04 : 0) | \
   (((x) & 0x10) ? 0x08 : 0) | \
   (((x) & 0x08) ? 0x10 : 0) | \
   (((x) & 0x04) ? 0x20 : 0) | \
   (((x) & 0x02) ? 0x40 : 0) | \
   (((x) & 0x01) ? 0x80 : 0))

int nr_epcs_address_past_config (unsigned long *addr)
{
    unsigned long i;
    int j;
    unsigned char value;
    unsigned char buf[4];
    int err;

    if (err=nr_epcs_read_buffer(0, sizeof(buf) / sizeof(*buf), buf))
        return (err);

    for (i=0; i<na_epcs_bulk_size - 8; i++)
    {
        if (err=nr_epcs_read_byte (i, &value))
            return (err);
        if (value == NR_EPCS_BITREVERSE(0x6A)) break;
        if (value != 0xFF) return (na_epcs_invalid_config);
    }

    //if we haven't seen any data by the 64th byte,
    //then it doesn't look like there's any configuration data
    if (i >= na_epcs_bulk_size - 8) return (na_epcs_invalid_config);

    // If we made it this far, we found the 0x6A byte at address i.  Beyond that,
    // we expect an 8-byte "option register", of which the last 4 bytes are the
    // length, LS-byte first.
    i += 5; // Jump ahead to the length.

    // Read the 4 bytes of the length.
    if (err=nr_epcs_read_buffer(i,4,buf))
        return (err);

    // Compute the length.
    *addr = 0;
    for (j = 3; j != ~0; --j)
    {
        *addr <<= 8;
        *addr |= NR_EPCS_BITREVERSE(buf[j]);
    }
    // The last address, oddly enough, is in bits.
    // Convert to bytes, rounding up.
    *addr += 7;
    *addr /= 8;

    return (na_epcs_success);
}


