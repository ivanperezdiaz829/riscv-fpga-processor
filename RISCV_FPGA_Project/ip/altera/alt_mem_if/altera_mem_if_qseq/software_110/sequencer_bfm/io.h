/* io.h for simulation replacing the normal NIOS2 io.h */

#if HHP_HPS

void    io_write(alt_u32 addr, alt_u32 data, alt_u32 avl_addr);
alt_u32 io_read(alt_u32 addr, alt_u32 avl_addr);

#define BASE_APB_ADDR    0xffC20000

#define MGR_SELECT_MASK   0xf8000

#define APB_BASE_SCC_MGR  0x0000
#define APB_BASE_PHY_MGR  0x1000
#define APB_BASE_RW_MGR   0x2000
#define APB_BASE_DATA_MGR 0x4000
#define APB_BASE_REG_FILE 0x4800
#define APB_BASE_MMR      0x5000

#define __AVL_TO_APB(ADDR) \
	((((ADDR) & MGR_SELECT_MASK) == (BASE_PHY_MGR))  ? (APB_BASE_PHY_MGR)  | (((ADDR) >> (14-6)) & (0x1<<6))  | ((ADDR) & 0x3f) : \
	 (((ADDR) & MGR_SELECT_MASK) == (BASE_RW_MGR))   ? (APB_BASE_RW_MGR)   | ((ADDR) & 0x1fff) : \
 	 (((ADDR) & MGR_SELECT_MASK) == (BASE_DATA_MGR)) ? (APB_BASE_DATA_MGR) | ((ADDR) & 0x7ff) : \
	 (((ADDR) & MGR_SELECT_MASK) == (BASE_SCC_MGR))  ? (APB_BASE_SCC_MGR)  | ((ADDR) & 0xfff) : \
	 (((ADDR) & MGR_SELECT_MASK) == (BASE_REG_FILE)) ? (APB_BASE_REG_FILE) | ((ADDR) & 0x7ff) : \
	 (((ADDR) & MGR_SELECT_MASK) == (BASE_MMR))      ? (APB_BASE_MMR)      | ((ADDR) & 0xfff) : \
	 -1)

#define IOWR_32DIRECT(BASE, OFFSET, DATA) \
	io_write((BASE_APB_ADDR) + __AVL_TO_APB((alt_u32)((BASE) + (OFFSET))), DATA, (BASE) + (OFFSET))


#define IORD_32DIRECT(BASE, OFFSET) \
	io_read((BASE_APB_ADDR) + __AVL_TO_APB((alt_u32)((BASE) + (OFFSET))), (BASE) + (OFFSET))

#else

void    io_write(alt_u32 *addr, alt_u32 data);
alt_u32 io_read(alt_u32 *addr);

#define __IO_CALC_ADDRESS_DYNAMIC(BASE, OFFSET) \
  ((void *)(((alt_u8*)BASE) + (OFFSET)))

#define IOWR_32DIRECT(BASE, OFFSET, DATA) \
	io_write((alt_u32*)(__IO_CALC_ADDRESS_DYNAMIC ((BASE), (OFFSET))), (DATA))


#define IORD_32DIRECT(BASE, OFFSET) \
	io_read((alt_u32*)(__IO_CALC_ADDRESS_DYNAMIC ((BASE), (OFFSET))))

#endif
