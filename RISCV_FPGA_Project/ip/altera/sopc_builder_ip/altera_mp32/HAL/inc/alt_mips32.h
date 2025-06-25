#ifndef __ALT_MIPS32_H__
#define __ALT_MIPS32_H__

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

/*
 * This header provides processor specific macros for accessing MIPS32
 * control registers.
 */

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * Define __ASSEMBLER__ if a different tool specific define indicating
 * the an assembly language file is being processed is set.  This allows
 * support for new tools to be added in one place (here).  The remainder
 * of ArchDefs.h simply uses __ASSEMBLER__ to separate assembly specific
 * code from C or C++ code.
 */
#if defined(ALT_ASM_SRC) || defined(__LANGUAGE_ASM__) || defined(__assembler)
#undef __ASSEMBLER__
#define __ASSEMBLER__
#endif

/*
 ************************************************************************
 *                I N S T R U C T I O N   F O R M A T S                 *
 ************************************************************************
 *
 * The following definitions describe each field in an instruction.  There
 * is one diagram for each type of instruction, with field definitions
 * following the diagram for that instruction.  Note that if a field of
 * the same name and position is defined in an earlier diagram, it is
 * not defined again in the subsequent diagram.  Only new fields are
 * defined for each diagram.
 *
 * R-Type (operate)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |           |   rs    |   rt    |   rd    |   sa    |           |
 * |   Opcode  |         |         |       Tcode       |   func    |
 * |           |                  Bcode                |           |
 * |           |       |s|                   |h|       |s|         |
 * |           |       |r|                   |b| hint  |c|   | sel |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnOpcode		26
#define M_InstnOpcode		(0x3f << S_InstnOpcode)
#define S_InstnRS		21
#define M_InstnRS		(0x1f << S_InstnRS)
#define S_InstnRT		16
#define M_InstnRT		(0x1f << S_InstnRT)
#define S_InstnRD		11
#define M_InstnRD		(0x1f << S_InstnRD)
#define S_InstnSA		6
#define M_InstnSA		(0x1f << S_InstnSA)
#define S_InstnTcode		6
#define M_InstnTcode		(0x3ff << S_InstnTcode)
#define S_InstnBcode		6
#define M_InstnBcode		(0xfffff << S_InstnBcode)
#define S_InstnFunc		0
#define M_InstnFunc		(0x3f << S_InstnFunc)
#define S_InstnSel		0
#define M_InstnSel		(0x7 << S_InstnSel)

/* to distinguish release2 DI/EI */
#define S_InstnSC		5
#define M_InstnSC		(0x1 << S_InstnSC)

/* to distinguish release2 shift/rotate */
#define S_InstnSR		21
#define M_InstnSR		(0x1 << S_InstnSR)

/* to distinguish release2 jump with hazard barrier */
#define S_InstnHB		10
#define M_InstnHB		(0x1 << S_InstnHB)

/*
 * I-Type (load, store, branch, immediate)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   rs    |   rt    |             Offset            |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnOffset		0
#define M_InstnOffset		(0xffff << S_InstnOffset)

/*
 * I-Type (pref)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   rs    |  hint   |             Offset            |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnHint		S_InstnRT
#define M_InstnHint		M_InstnRT

/*
 * J-Type (jump)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |                    JIndex                         |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnJIndex		0
#define M_InstnJIndex		(0x03ffffff << S_InstnJIndex)

/*
 * FP R-Type (operate)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   fmt   |   ft    |   fs    |   fd    |   func    |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnFmt		S_InstnRS
#define M_InstnFmt		M_InstnRS
#define S_InstnFT		S_InstnRT
#define M_InstnFT		M_InstnRT
#define S_InstnFS		S_InstnRD
#define M_InstnFS		M_InstnRD
#define S_InstnFD		S_InstnSA
#define M_InstnFD		M_InstnSA

/*
 * FP R-Type (cpu <-> cpu data movement))
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   sub   |   rt    |   fs    |          0          |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnSub		S_InstnRS
#define M_InstnSub		M_InstnRS

/*
 * FP R-Type (compare)
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |           |         |         |         |     | |C|           |
 * |   Opcode  |   fmt   |   ft    |   fs    |  cc |0|A|   func    |
 * |           |         |         |         |     | |B|           |
 * |           |         |         |         |     | |S|           |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnCCcmp		8
#define M_InstnCCcmp		(0x7 << S_InstnCCcmp)
#define S_InstnCABS		6
#define M_InstnCABS		(0x1 << S_InstnCABS)

/*
 * FP R-Type (FPR conditional move on FP cc)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   fmt   |  cc |n|t|   fs    |   fd    |   func    |
 * |           |         |     |d|f|         |         |           |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnCC		18
#define M_InstnCC		(0x7 << S_InstnCC)
#define S_InstnND		17
#define M_InstnND		(0x1 << S_InstnND)
#define S_InstnTF		16
#define M_InstnTF		(0x1 << S_InstnTF)

/*
 * FP R-Type (3-operand operate)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   fr    |   ft    |   fs    |   fd    | op4 | fmt3|
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnFR		S_InstnRS
#define M_InstnFR		M_InstnRS
#define S_InstnOp4		3
#define M_InstnOp4		(0x7 << S_InstnOp4)
#define S_InstnFmt3		0
#define M_InstnFmt3		(0x7 << S_InstnFmt3)

/*
 * FP R-Type (Indexed load, store)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   rs    |   rt    |   0     |   fd    |   func    |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */
/*
 * FP R-Type (prefx)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   rs    |   rt    |  hint   |    0    |   func    |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnHintX		S_InstnRD
#define M_InstnHintX		M_InstnRD

/*
 * FP R-Type (GPR conditional move on FP cc)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |    rs   |  cc |n|t|   rd    |    0    |   func    |
 * |           |         |     |d|f|         |         |           |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

/*
 * FP I-Type (load, store)
 * 
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   rs    |    ft   |           Offset              |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

/*
 * FP I-Type (branch)
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |   fmt   |  cc |n|t|           Offset              |
 * |           |         |     |d|f|                               |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */


/*
 * Vector Type
 *
 * bit[25:21]  This field is mostly format select (fmtsel), or combind
 *             with operation select for shuffle, read/write accumulator,
 *             or fourth register (rs) for variable alignment, or
 *             immediate for constant alignment.
 * bit[10]     L bit is only used for VMac instructions.
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   Opcode  |  fmtsel |   vt    |   vs    |   vd    |   func    |
 * |           |  fmt/op |         |         |         |           |
 * |           |   rs    |         |         |         |           |
 * |           | 0 | imm |         |         |L|       |           |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define S_InstnVT		S_InstnRT
#define M_InstnVT		M_InstnRT
#define S_InstnVS		S_InstnRD
#define M_InstnVS		M_InstnRD
#define S_InstnVD		S_InstnSA
#define M_InstnVD		M_InstnSA

#define S_InstnFmtsel		S_InstnFmt
#define M_InstnFmtsel		(0x1 << S_InstnFmtsel)
#define S_InstnVImm		S_InstnFmt
#define M_InstnVImm		(0x7 << S_InstnVImm)

#define S_InstnL		10
#define M_InstnL		(0x1 << S_InstnL)



/*
 *************************************************************************
 *         V I R T U A L   A D D R E S S   D E F I N I T I O N S         *
 *************************************************************************
 */

#define A_K0BASE		0x80000000
#define A_K1BASE		0xa0000000
#define A_K2BASE		0xc0000000
#define A_K3BASE		0xe0000000
#define M_KMAPPED		0x40000000		/* KnSEG address is mapped if bit is one */
#define M_KUNCACHED		0x20000000		/* K[01]SEG address is uncached if bit is one */


#define S_KSEG3                 29
#define M_KSEG3                 (0x7 << S_KSEG3)
#define K_KSEG3                 7

#define S_KSSEG                 29
#define M_KSSEG                 (0x7 << S_KSSEG)
#define K_KSSEG                 6

#define S_SSEG                  29
#define M_SSEG                  (0x7 << S_SSEG)
#define K_SSEG                  6

#define S_KSEG1                 29
#define M_KSEG1                 (0x7 << S_KSEG1)
#define K_KSEG1                 5

#define S_KSEG0                 29
#define M_KSEG0                 (0x7 << S_KSEG0)
#define K_KSEG0                 4

#define S_KUSEG                 31
#define M_KUSEG                 (0x1 << S_KUSEG)
#define K_KUSEG                 0

#define S_SUSEG                 31
#define M_SUSEG                 (0x1 << S_SUSEG)
#define K_SUSEG                 0

#define S_USEG                  31
#define M_USEG                  (0x1 << S_USEG)
#define K_USEG                  0

#define K_EjtagLower            0xff200000
#define K_EjtagUpper            0xff3fffff

#define S_EjtagProbeMem         20
#define M_EjtagProbeMem         (0x1 << S_EjtagProbeMem)
#define K_EjtagProbeMem         0

/*
 *************************************************************************
 *   C A C H E   I N S T R U C T I O N   O P E R A T I O N   C O D E S   *
 *************************************************************************
 */

/*
 * Cache encodings
 */
#define K_CachePriI		0			/* Primary Icache */
#define K_CachePriD		1			/* Primary Dcache */
#define K_CachePriU		1			/* Unified primary */
#define K_CacheTerU		2			/* Unified Tertiary */
#define K_CacheSecU		3			/* Unified secondary */


/*
 * Function encodings
 */
#define S_CacheFunc		2			/* Amount to shift function encoding within 5-bit field */
#define K_CacheIndexInv		0			/* Index invalidate */
#define K_CacheIndexWBInv       0			/* Index writeback invalidate */
#define K_CacheIndexLdTag	1			/* Index load tag */
#define K_CacheIndexStTag	2			/* Index store tag */
#define K_CacheHitInv		4			/* Hit Invalidate */
#define K_CacheFill		5			/* Fill (Icache only) */
#define K_CacheHitWBInv		5			/* Hit writeback invalidate */
#define K_CacheHitWB		6			/* Hit writeback */
#define K_CacheFetchLock	7			/* Fetch and lock */

#define ICIndexInv		((K_CacheIndexInv << S_CacheFunc) | K_CachePriI)
#define DCIndexWBInv		((K_CacheIndexWBInv << S_CacheFunc) | K_CachePriD)
#define DCIndexInv		DCIndexWBInv
#define ICIndexLdTag		((K_CacheIndexLdTag << S_CacheFunc) | K_CachePriI)
#define DCIndexLdTag		((K_CacheIndexLdTag << S_CacheFunc) | K_CachePriD)
#define ICIndexStTag		((K_CacheIndexStTag << S_CacheFunc) | K_CachePriI)
#define DCIndexStTag		((K_CacheIndexStTag << S_CacheFunc) | K_CachePriD)
#define ICHitInv		((K_CacheHitInv << S_CacheFunc) | K_CachePriI)
#define DCHitInv		((K_CacheHitInv << S_CacheFunc) | K_CachePriD)
#define ICFill			((K_CacheFill << S_CacheFunc) | K_CachePriI)
#define DCHitWBInv		((K_CacheHitWBInv << S_CacheFunc) | K_CachePriD)
#define DCHitWB			((K_CacheHitWB << S_CacheFunc) | K_CachePriD)
#define ICFetchLock		((K_CacheFetchLock << S_CacheFunc) | K_CachePriI)
#define DCFetchLock		((K_CacheFetchLock << S_CacheFunc) | K_CachePriD)

#define SCIndexWBInv        	((K_CacheIndexWBInv 	<< S_CacheFunc) | K_CacheSecU)
#define SCIndexInv		SCIndexWBInv
#define SCIndexLdTag        	((K_CacheIndexLdTag 	<< S_CacheFunc) | K_CacheSecU)
#define SCIndexStTag        	((K_CacheIndexStTag 	<< S_CacheFunc) | K_CacheSecU)
#define SCHitInv            	((K_CacheHitInv 	<< S_CacheFunc) | K_CacheSecU)
#define SCHitWBInv          	((K_CacheHitWBInv 	<< S_CacheFunc) | K_CacheSecU)
#define SCHitWB             	((K_CacheHitWB 		<< S_CacheFunc)	| K_CacheSecU)

#define TCIndexWBInv        	((K_CacheIndexWBInv 	<< S_CacheFunc) | K_CacheTerU)
#define TCIndexInv		TCIndexWBInv
#define TCIndexLdTag        	((K_CacheIndexLdTag 	<< S_CacheFunc) | K_CacheTerU)
#define TCIndexStTag        	((K_CacheIndexStTag 	<< S_CacheFunc) | K_CacheTerU)
#define TCHitInv            	((K_CacheHitInv 	<< S_CacheFunc) | K_CacheTerU)
#define TCHitWBInv          	((K_CacheHitWBInv 	<< S_CacheFunc) | K_CacheTerU)
#define TCHitWB             	((K_CacheHitWB 		<< S_CacheFunc)	| K_CacheTerU)

/*
 *************************************************************************
 *          P R E F E T C H   I N S T R U C T I O N   H I N T S          *
 *************************************************************************
 */

#define PrefLoad		0
#define PrefStore		1
#define PrefLoadStreamed	4
#define PrefStoreStreamed	5
#define PrefLoadRetained	6
#define PrefStoreRetained	7
#define PrefWBInval		25
#define PrefNudge		25
#define PrefPrepareForStore	30


/*
 *************************************************************************
 *             C P U   R E G I S T E R   D E F I N I T I O N S           *
 *************************************************************************
 */


/*
 *************************************************************************
 *                  S O F T W A R E   G P R   N A M E S                  *
 *************************************************************************
 */

#if defined(__ASSEMBLER__)
#define zero		 $0
#define AT			 $1
#define v0			 $2
#define v1			 $3
#define a0			 $4
#define a1			 $5
#define a2			 $6
#define a3			 $7
#define t0			 $8
#define t1			 $9
#define t2			$10
#define t3			$11
#define t4			$12
#define t5			$13
#define t6			$14
#define t7			$15
#define s0			$16
#define s1			$17
#define s2			$18
#define s3			$19
#define s4			$20
#define s5			$21
#define s6			$22
#define s7			$23
#define t8			$24
#define t9			$25
#define k0			$26
#define k1			$27
#define gp			$28
#define sp			$29
#define fp			$30
#define ra			$31
#endif

/*
 *************************************************************************
 *                  H A R D W A R E   G P R   N A M E S                  *
 *************************************************************************
 *
 * In the HAL, several of the `r' names are removed from the
 * name space because they are used HAL for special purposes.
 * Removing them causes assembly rather than runtime errors for tests that
 * use the `r' names.
 *
 *    r26 (AKA k0) - Exception handler temporary
 *    r27 (AKA k1) - Stack limit (when runtime stack checking enabled) 
 */

#if defined(__ASSEMBLER__)
#define r0			 $0
#define r1			 $1
#define r2			 $2
#define r3			 $3
#define r4			 $4
#define r5			 $5
#define r6			 $6
#define r7			 $7
#define r8			 $8
#define r9			 $9
#define r10			$10
#define r11			$11
#define r12			$12
#define r13			$13
#define r14			$14
#define r15			$15
#define r16			$16
#define r17			$17
#define r18			$18
#define r19			$19
#define r20			$20
#define r21			$21
#define r22			$22
#define r23			$23
#define r24			$24
#define r25			$25
#define r27			$27
#define r28			$28
#define r29			$29
#define r30			$30
#define r31			$31
#endif /* defined(__ASSEMBLER__) */


/*
 *************************************************************************
 *                H A R D W A R E   G P R   I N D I C E S                *
 *************************************************************************
 *
 * These definitions provide the index (number) of the GPR, as opposed
 * to the assembler register name ($n).
 */

#define R_r0			 0
#define R_r1			 1
#define R_r2			 2
#define R_r3			 3
#define R_r4			 4
#define R_r5			 5
#define R_r6			 6
#define R_r7			 7
#define R_r8			 8
#define R_r9			 9
#define R_r10			10
#define R_r11			11
#define R_r12			12
#define R_r13			13
#define R_r14			14
#define R_r15			15
#define R_r16			16
#define R_r17			17
#define R_r18			18
#define R_r19			19
#define R_r20			20
#define R_r21			21
#define R_r22			22
#define R_r23			23
#define R_r24			24
#define R_r25			25
#define R_r26			26
#define R_r27			27
#define R_r28			28
#define R_r29			29
#define R_r30			30
#define R_r31			31


/*
 *************************************************************************
 *                S O F T W A R E   G P R   I N D I C E S                *
 *************************************************************************
 *
 * These definitions provide the index (number) of the GPR, as opposed
 * to the assembler register name ($n).
 */

#define R_zero			 0
#define R_AT			 1
#define R_v0			 2
#define R_v1			 3
#define R_a0			 4
#define R_a1			 5
#define R_a2			 6
#define R_a3			 7
#define R_t0			 8
#define R_t1			 9
#define R_t2			10
#define R_t3			11
#define R_t4			12
#define R_t5			13
#define R_t6			14
#define R_t7			15
#define R_s0			16
#define R_s1			17
#define R_s2			18
#define R_s3			19
#define R_s4			20
#define R_s5			21
#define R_s6			22
#define R_s7			23
#define R_t8			24
#define R_t9			25
#define R_repc			25
#define R_k0			26
#define R_k1			27
#define R_gp			28
#define R_sp			29
#define R_fp			30
#define R_s8			30
#define R_tid			30
#define R_ra			31
#define R_hi			32			/* Hi register */
#define R_lo			33			/* Lo register */


/*
 *************************************************************************
 *                  S O F T W A R E   G P R   M A S K S                  *
 *************************************************************************
 *
 * These definitions provide the bit mask corresponding to the GPR number
 */

#define M_AT			 (1<<1)
#define M_v0			 (1<<2)
#define M_v1			 (1<<3)
#define M_a0			 (1<<4)
#define M_a1			 (1<<5)
#define M_a2			 (1<<6)
#define M_a3			 (1<<7)
#define M_t0			 (1<<8)
#define M_t1			 (1<<9)
#define M_t2			(1<<10)
#define M_t3			(1<<11)
#define M_t4			(1<<12)
#define M_t5			(1<<13)
#define M_t6			(1<<14)
#define M_t7			(1<<15)
#define M_s0			(1<<16)
#define M_s1			(1<<17)
#define M_s2			(1<<18)
#define M_s3			(1<<19)
#define M_s4			(1<<20)
#define M_s5			(1<<21)
#define M_s6			(1<<22)
#define M_s7			(1<<23)
#define M_t8			(1<<24)
#define M_t9			(1<<25)
#define M_k0			(1<<26)
#define M_k1			(1<<27)
#define M_gp			(1<<28)
#define M_sp			(1<<29)
#define M_fp			(1<<30)
#define M_ra			(1<<31)

/*
 *************************************************************************
 *                H A R D W A R E   A C C   I N D I C E S                *
 *************************************************************************
 */

#define A_ac0			0
#define A_ac1			1
#define A_ac2			2
#define A_ac3			3

/*
 *************************************************************************
 *                S O F T W A R E   A C C   I N D I C E S                *
 *************************************************************************
 *
 * These definitions provide the index (number) of the accumulator, as
 * opposed to the assembler register name ($acn).
 */

#define R_ac0_lo		0
#define R_ac0_hi		1
#define R_ac1_lo		2
#define R_ac1_hi		3
#define R_ac2_lo		4
#define R_ac2_hi		5
#define R_ac3_lo		6
#define R_ac3_hi		7


/*
 *************************************************************************
 *             C P 0   R E G I S T E R   D E F I N I T I O N S           *
 *************************************************************************
 * Each register has the following definitions:
 *
 *	C0_rrr		The register number (as a $n value)
 *	R_C0_rrr	The register index (as an integer corresponding
 *			to the register number)
 *	R_C0_Selrrr	The register select (as an integer corresponding
 *			to the register select)
 *
 * Each field in a register has the following definitions:
 *
 *	S_rrrfff	The shift count required to right-justify
 *			the field.  This corresponds to the bit
 *			number of the right-most bit in the field.
 *	M_rrrfff	The Mask required to isolate the field.
 *
 * Register diagrams included below as comments correspond to the
 * MIPS32 and MIPS64 architecture specifications.  Refer to other
 * sources for register diagrams for older architectures.
 */


/*
 ************************************************************************
 *                 I N D E X   R E G I S T E R   ( 0 )                  *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |P|                         0                       |   Index   | Index
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Index		$0
#define R_C0_Index		0
#define R_C0_SelIndex		0
#define C0_INX			C0_Index		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_IndexP		31			/* Probe failure (R)*/
#define M_IndexP		(0x1 << S_IndexP)

#define S_IndexIndex		0			/* TLB index (R/W)*/
#define M_IndexIndex		(0x3f << S_IndexIndex)

#define M_Index0Fields		0x7fffffc0
#define M_IndexRFields		0x80000000


/*
 ************************************************************************
 *                R A N D O M   R E G I S T E R   ( 1 )                 *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                            0                      |   Index   | Random
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Random		$1
#define R_C0_Random		1
#define R_C0_SelRandom		0
#define C0_RAND			$1			/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_RandomIndex		0			/* TLB random index (R)*/
#define M_RandomIndex		(0x3f << S_RandomIndex)

#define M_Random0Fields		0xffffffc0
#define M_RandomRFields		0x0000003f


/*
 ************************************************************************
 *              E N T R Y L O 0   R E G I S T E R   ( 2 )               *
 ************************************************************************
 * 	
 *  6 6 6 6 5 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 2 1 0 9 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | Fill (0) //|R|X|                     PFN                       |  C  |D|V|G| EntryLo0
 * |          //|I|I|                                               |     | | | |
 * +-+-+-+-+-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_EntryLo0		$2
#define R_C0_EntryLo0		2
#define R_C0_SelEntryLo0	0
#define C0_TLBLO_0		C0_EntryLo0		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_EntryLoPFN		6			/* PFN (R/W) */
#define M_EntryLoPFN		(0xffffff << S_EntryLoPFN)
#define S_EntryLoC		3			/* Coherency attribute (R/W) */
#define M_EntryLoC		(0x7 << S_EntryLoC)
#define S_EntryLoD		2			/* Dirty (R/W) */
#define M_EntryLoD		(0x1 << S_EntryLoD)
#define S_EntryLoV		1			/* Valid (R/W) */
#define M_EntryLoV		(0x1 << S_EntryLoV)
#define S_EntryLoG		0			/* Global (R/W) */
#define M_EntryLoG		(0x1 << S_EntryLoG)
#define M_EntryLoOddPFN		(0x1 << S_EntryLoPFN)	/* Odd PFN bit */
#define S_EntryLo_RS		K_PageAlign		/* ? */
/* Shift to put PFN in its position within a physical address */
#define S_EntryLo_LS		(12 - S_EntryLoPFN)

#define M_EntryLo0Fields	0x00000000
#define M_EntryLoRFields	0xc0000000

/*
 * Cache attribute values in the C field of EntryLo and the
 * K0 field of Config
 */
#define K_CacheAttrCWTnWA	0			/* Cacheable, write-thru, no write allocate */
#define K_CacheAttrCWTWA	1			/* Cacheable, write-thru, write allocate */
#define K_CacheAttrU		2			/* Uncached */
#define K_CacheAttrC		3			/* Cacheable */
#define K_CacheAttrCN		3			/* Cacheable, non-coherent */
#define K_CacheAttrCCE		4			/* Cacheable, coherent, exclusive */
#define K_CacheAttrCCS		5			/* Cacheable, coherent, shared */
#define K_CacheAttrCCU		6			/* Cacheable, coherent, update */
#define K_CacheAttrUA		7			/* Uncached accelerated */


/*
 ************************************************************************
 *              E N T R Y L O 1   R E G I S T E R   ( 3 )               *
 ************************************************************************
 * 	
 *  6 6 6 6 5 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 2 1 0 9 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | Fill (0) //| 0 |                     PFN                       |  C  |D|V|G| EntryLo1
 * +-+-+-+-+-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_EntryLo1		$3
#define R_C0_EntryLo1		3
#define R_C0_SelEntryLo1	0
#define C0_TLBLO_1		C0_EntryLo1		/* OBSOLETE - DO NOT USE IN NEW CODE */

/*
 * Field definitions are as given for EntryLo0 above
 */


/*
 ************************************************************************
 *               C O N T E X T   R E G I S T E R   ( 4, SELECT 0 )      *
 ************************************************************************
 * 	
 *  6 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  //       PTEBase    |            BadVPN<31:13>            |   0   | Context
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Context	$4
#define R_C0_Context		4
#define R_C0_SelContext		0
#define C0_CTXT			C0_Context		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_ContextPTEBase	23			/* PTE base (R/W) */
#define S_ContextBadVPN		4			/* BadVPN2 (R) */

/*
 * Definitions that can be derived from the above two,
 * regardless of whether or not ContextConfig is implemented.
 */

#define M_Context0Fields	((1 << S_ContextBadVPN) - 1)
#define M_ContextRFields	(((1 << S_ContextPTEBase) - 1) & \
                             ~(M_Context0Fields))
#define M_ContextPTEBase	(((1 << S_ContextBadVPN_LS) - 1) << \
                             (S_ContextPTEBase))
#define M_ContextBadVPN		(((1 << (S_ContextPTEBase - S_ContextBadVPN)) - 1) << \
                             (S_ContextBadVPN))
/* Position BadVPN to bit 31. */
#define S_ContextBadVPN_LS	(32 - S_ContextPTEBase)
/* Right-justify shifted BadVPN field, i.e. VA bits not in BadVPN2 */
#define S_ContextBadVPN_RS	(32 - (S_ContextPTEBase - S_ContextBadVPN))

/*
 ************************************************************************
 *          UserLocal  R E G I S T E R   ( 4, SELECT 2 )              *
 ************************************************************************
 * 	
 *  6 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  //                      UserLocal                               | 
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_UserLocal     $4,2
#define R_C0_UserLocal    4
#define R_C0_SelUserLocal 2

/*
 ************************************************************************
 *              P A G E M A S K   R E G I S T E R   ( 5, SELECT 0 )     *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  0  |             Mask              |            0            | PageMask
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_PageMask		$5
#define R_C0_PageMask		5			/* Mask (R/W) */
#define R_C0_SelPageMask	0
#define C0_PGMASK		C0_PageMask		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_PageMaskMask		13
#define M_PageMaskMask		(0xffff << S_PageMaskMask)
#define S_PageMaskMaskX		11
#define M_PageMaskMaskX		(0x3 << S_PageMaskMaskX)

#define M_PageMask0Fields	0xe0001fff
#define M_PageMaskRFields	0x00000000

/*
 * Values in the Mask field
 */
#define K_PageMask4K		0x0000			/* K_PageMasknn values are values for use */
#define K_PageMask16K		0x0003			/* with KReqPageAttributes or KReqPageMask macros */
#define K_PageMask64K		0x000f
#define K_PageMask256K		0x003f
#define K_PageMask1M		0x00ff
#define K_PageMask4M		0x03ff
#define K_PageMask16M		0x0fff
#define K_PageMask64M		0x3fff
#define K_PageMask256M		0xffff

#define M_PageMask4K		(K_PageMask4K << S_PageMaskMask) /* M_PageMasknn values are masks */
#define M_PageMask16K		(K_PageMask16K << S_PageMaskMask) /* in position in the PageMask register */
#define M_PageMask64K		(K_PageMask64K << S_PageMaskMask)
#define M_PageMask256K		(K_PageMask256K << S_PageMaskMask)
#define M_PageMask1M		(K_PageMask1M << S_PageMaskMask)
#define M_PageMask4M		(K_PageMask4M << S_PageMaskMask)
#define M_PageMask16M		(K_PageMask16M << S_PageMaskMask)
#define M_PageMask64M		(K_PageMask64M << S_PageMaskMask)
#define M_PageMask256M		(K_PageMask256M << S_PageMaskMask)

/* Shift amounts for different Page Size */
#define S_PAGE1K	10
#define S_PAGE2K	11
#define S_PAGE4K	12
#define S_PAGE16K	14
#define S_PAGE64K	16
#define S_PAGE256K	18
#define S_PAGE1M	20
#define S_PAGE4M	22
#define S_PAGE16M	24
#define S_PAGE64M	26
#define S_PAGE256M	28

#define S_PageMask1K	(S_PAGE1K   + 1)
#define S_PageMask2K	(S_PAGE2K   + 1)
#define S_PageMask4K	(S_PAGE4K   + 1)
#define S_PageMask16K	(S_PAGE16K  + 1)
#define S_PageMask64K	(S_PAGE64K  + 1)
#define S_PageMask256K	(S_PAGE256K + 1)
#define S_PageMask1M	(S_PAGE1M   + 1)
#define S_PageMask4M	(S_PAGE4M   + 1)
#define S_PageMask16M	(S_PAGE16M  + 1)
#define S_PageMask64M	(S_PAGE64M  + 1)
#define S_PageMask256M	(S_PAGE256M + 1)
/* For Release 2 we need to write correct value to pagemask, default to 4k page*/
#define K_1KPAGEMASK	(0x00000)
#define K_2KPAGEMASK	(0x00800)
#define K_4KPAGEMASK	(0x01800)
#define K_16KPAGEMASK	(0x07800)
#define K_64KPAGEMASK	(0x1f800)
#define K_256KPAGEMASK	(0x7f800)
#define K_1MPAGEMASK	(0x1ff800)
#define K_4MPAGEMASK	(0x7ff800)
#define K_16MPAGEMASK	(0x1fff800)
#define K_64MPAGEMASK	(0x7fff800)
#define K_256MPAGEMASK	(0x1ffff800)

/*
 ************************************************************************
 *                 W I R E D   R E G I S T E R   ( 6 )                  *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                            0                      |   Index   | Wired
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Wired		$6
#define R_C0_Wired		6
#define R_C0_SelWired		0
#define C0_TLBWIRED		C0_Wired		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_WiredIndex		0			/* TLB wired boundary (R/W) */
#define M_WiredIndex		(0x3f << S_WiredIndex)

#define M_Wired0Fields		0xffffffc0
#define M_WiredRFields		0x00000000


/*
 ************************************************************************
 *                H W R E n a   R E G I S T E R   ( 7 )                 *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   |U|                                                 |C|C|S|C|
 * |   |s|                      0                          |C|y|Y|P|
 * |   |e|                                                 |R|c|N|U|
 * |   |r|                                                 |e|l|C|N|
 * |   |L|                                                 |s|e|I|u|
 * |   |o|                                                 | |C|S|m|
 * |   |c|                                                 | |o|t| |
 * |   |a|                                                 | |u|e| |
 * |   |l|                                                 | |n|p| |
 * |   | |                                                 | |t| | |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_HWREna		$7
#define R_C0_HWREna		7
#define R_C0_SelHWREna		0
#define S_HWREnaMask		0			/* Mask bits (R/W) */
#define M_HWREnaMask		(0xF << S_HWREnaMask)
        
/*
 * "Mask" is the set of mask bits which are required
 *  (used by legacy diags prior to introduction in of UserLocal register)
 */                
#define S_HWREnaMask		0			/* Mask bits (R/W) */
#define M_HWREnaMask		(0xF << S_HWREnaMask)

/*
 * The following defines both the individual mask bits, and the RDHWR
 * register numbers that correspond to the masks.
 */
#define S_HWREnaMask_CPUNum 	0
#define M_HWREnaMask_CPUNum 	(1 << S_HWREnaMask_CPUNum)
#define S_HWREnaMask_SYNCI_Step 1
#define M_HWREnaMask_SYNCI_Step (1 << S_HWREnaMask_SYNCI_Step)
#define S_HWREnaMask_CycleCount 2
#define M_HWREnaMask_CycleCount (1 << S_HWREnaMask_CycleCount)
#define S_HWREnaMask_CC 	2
#define M_HWREnaMask_CC 	(1 << S_HWREnaMask_CC)
#define S_HWREnaMask_CCRes 	3
#define M_HWREnaMask_CCRes 	(1 << S_HWREnaMask_CCRes)
#define S_HWREnaMask_UserLocal 29
#define M_HWREnaMask_UserLocal (1 << S_HWREnaMask_UserLocal)

#define HWR_CPUNum		$0			/* CPUNum */
#define R_HWR_CPUNum		S_HWREnaMask_CPUNum
#define HWR_SYNCI_Step		$1			/* Address step for SYNCI */
#define R_HWR_SYNCI_Step	S_HWREnaMask_SYNCI_Step
#define HWR_CycleCount		$2			/* Cycle counter */
#define R_HWR_CycleCount	S_HWREnaMask_CycleCount
#define HWR_CC			$2			/* CycleCounter */
#define R_HWR_CC		S_HWREnaMask_CC
#define HWR_CCRes		$3			/* CCRes */
#define R_HWR_CCRes		S_HWREnaMask_CCRes
#define HWR_UserLocal		$29			/* UserLocal */
#define R_HWR_UserLocal	S_HWREnaMask_UserLocal

#define M_HWREna0Fields		0x1ffffff0
#define M_HWREnaRFields		0x00000000


/*
 ************************************************************************
 *              B A D V A D D R   R E G I S T E R   ( 8 )               *
 ************************************************************************
 * 	
 *  6 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  //                     Bad Virtual Address                        | BadVAddr
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_BadVAddr		$8
#define R_C0_BadVAddr		8
#define R_C0_SelBadVAddr	0
#define C0_BADVADDR		C0_BadVAddr		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define M_BadVAddrOddPage	K_PageSize		/* Even/Odd VA bit for pair of PAs */

#define M_BadVAddr0Fields	0x00000000
#define M_BadVAddrRFields	0xffffffff

/*
 ************************************************************************
 *                 C O U N T   R E G I S T E R   ( 9 )                  *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                         Count Value                           | Count
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Count		$9
#define R_C0_Count		9
#define R_C0_SelCount		0
#define C0_COUNT		C0_Count		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define M_Count0Fields		0x00000000
#define M_CountRFields		0x00000000


/*
 ************************************************************************
 *              E N T R Y H I   R E G I S T E R   ( 1 0 )               *
 ************************************************************************
 * 	
 *  6 6 6 6 5 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 2 1 0 9 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | R | Fill //                 VPN2                 |    0    |     ASID      | EntryHi
 * +-+-+-+-+-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_EntryHi		$10
#define R_C0_EntryHi		10
#define R_C0_SelEntryHi		0
#define C0_TLBHI		C0_EntryHi		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_EntryHiVPN2		13			/* VPN/2 (R/W) */
#define M_EntryHiVPN2		(0x7ffff << S_EntryHiVPN2)

#define S_EntryHiVPN2X		11
#define M_EntryHiVPN2X		(0x3 << S_EntryHiVPN2X)

#define M_EntryHi0Fields	0x00000700
#define M_EntryHiRFields	0x00000000

#define S_EntryHiASID		0			/* ASID (R/W) */
#define M_EntryHiASID		(0xff << S_EntryHiASID)
#define W_EntryHiASID		8
#define S_EntryHiVPN_Shf	S_EntryHiVPN2

/*
 ************************************************************************
 *              C O M P A R E   R E G I S T E R   ( 1 1 )               *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                        Compare Value                          | Compare
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Compare		$11
#define R_C0_Compare		11
#define R_C0_SelCompare		0
#define C0_COMPARE		C0_Compare		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define M_Compare0Fields	0x00000000
#define M_CompareRFields	0x00000000


/*
 ************************************************************************
 *               S T A T U S   R E G I S T E R   ( 1 2 )                *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |C|C|C|C|R|F|R|M|P|B|T|S|M| | R |I|I|I|I|I|I|I|I|K|S|U|U|R|E|E|I|
 * |U|U|U|U|P|R|E|X|X|E|S|R|M| | s |M|M|M|M|M|M|M|M|X|X|X|M|s|R|X|E| Status
 * |3|2|1|0| | | | | |V| | |I| | v |7|6|5|4|3|2|1|0| | | | |v|L|L| |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Status		$12
#define R_C0_Status		12
#define R_C0_SelStatus		0
#define C0_SR			C0_Status		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_StatusCU		28			/* Coprocessor enable (R/W) */
#define M_StatusCU		(0xf << S_StatusCU)
#define S_StatusCU3		31 			/* No longer used in Release 2 */
#define M_StatusCU3     	(0x1 << S_StatusCU3)
#define S_StatusCU2		30
#define M_StatusCU2		(0x1 << S_StatusCU2)
#define S_StatusCU1		29
#define M_StatusCU1		(0x1 << S_StatusCU1)
#define S_StatusCU0		28
#define M_StatusCU0		(0x1 << S_StatusCU0)
#define S_StatusRP		27			/* Enable reduced power mode (R/W) */
#define M_StatusRP		(0x1 << S_StatusRP)
#define S_StatusFR		26			/* Enable 64-bit FPRs (R/W) */
#define M_StatusFR		(0x1 << S_StatusFR)
#define S_StatusRE		25			/* Enable reverse endian (R/W) */
#define M_StatusRE		(0x1 << S_StatusRE)
#define S_StatusMX		24			/* Enable access to MDMX and DSP ASE's (R/W) */
#define M_StatusMX		(0x1 << S_StatusMX)
#define S_StatusPX		23			/* Enable access to 64-bit instructions/data (MIPS64 only) (R/W) */
#define M_StatusPX		(0x1 << S_StatusPX)
#define S_StatusBEV		22			/* Enable Boot Exception Vectors (R/W) */
#define M_StatusBEV		(0x1 << S_StatusBEV)
#define S_StatusTS		21			/* Denote TLB shutdown (R/W) */
#define M_StatusTS		(0x1 << S_StatusTS)
#define S_StatusSR		20			/* Denote soft reset (R/W) */
#define M_StatusSR		(0x1 << S_StatusSR)
#define S_StatusNMI		19
#define M_StatusNMI		(0x1 << S_StatusNMI)	/* Denote NMI (R/W) */
#define S_StatusImpl		16
#define M_StatusImpl		(0x3 << S_StatusImpl)
#define S_StatusIM		8			/* Interrupt mask (R/W) */
#define M_StatusIM		(0xff << S_StatusIM)
#define W_StatusIM		8
#define S_StatusIM7		15
#define M_StatusIM7		(0x1 << S_StatusIM7)
#define S_StatusIM6		14
#define M_StatusIM6		(0x1 << S_StatusIM6)
#define S_StatusIM5		13
#define M_StatusIM5		(0x1 << S_StatusIM5)
#define S_StatusIM4		12
#define M_StatusIM4		(0x1 << S_StatusIM4)
#define S_StatusIM3		11
#define M_StatusIM3		(0x1 << S_StatusIM3)
#define S_StatusIM2		10
#define M_StatusIM2		(0x1 << S_StatusIM2)
#define S_StatusIM1		9
#define M_StatusIM1		(0x1 << S_StatusIM1)
#define S_StatusIM0		8
#define M_StatusIM0		(0x1 << S_StatusIM0)
#define S_StatusIPL     10
#define M_StatusIPL     (0x3f << S_StatusIPL)
#define S_StatusKX		7			/* Enable access to extended kernel addresses (MIPS64 only) (R/W) */
#define M_StatusKX		(0x1 << S_StatusKX)
#define S_StatusSX		6			/* Enable access to extended supervisor addresses (MIPS64 only) (R/W) */
#define M_StatusSX		(0x1 << S_StatusSX)
#define S_StatusUX		5			/* Enable access to extended user addresses (MIPS64 only) (R/W) */
#define M_StatusUX		(0x1 << S_StatusUX)
#define S_StatusKSU		3			/* Two-bit current mode (R/W) */
#define M_StatusKSU		(0x3 << S_StatusKSU)
#define W_StatusKSU		2
#define S_StatusUM		4			/* User mode if supervisor mode not implemented (R/W) */
#define M_StatusUM		(0x1 << S_StatusUM)
#define S_StatusSM		3			/* Supervisor mode (R/W) */
#define M_StatusSM		(0x1 << S_StatusSM)
#define S_StatusERL		2			/* Denotes error level (R/W) */
#define M_StatusERL		(0x1 << S_StatusERL)
#define S_StatusEXL		1			/* Denotes exception level (R/W) */
#define M_StatusEXL		(0x1 << S_StatusEXL)
#define S_StatusIE		0			/* Enables interrupts (R/W) */
#define M_StatusIE		(0x1 << S_StatusIE)
#define M_Status0Fields		0x00040000
#define M_StatusRFields		0x008000e0		/* PX, KX, SX, UX unused in MIPS32 R2*/
#define M_Status0Fields64	0x00040000
#define M_StatusRFields64	0x00000000

/*
 * Values in the KSU field
 */
#define K_StatusKSU_U		2			/* User mode in KSU field */
#define K_StatusKSU_S		1			/* Supervisor mode in KSU field */
#define K_StatusKSU_K		0			/* Kernel mode in KSU field */


/*
 ************************************************************************
 *          I N T C T L   R E G I S T E R   ( 1 2, SELECT 1 )           *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  I  |  I  |                               |         |         |
 * |  P  |  P  |         0                     |   VS    |   0     |  IntCtl
 * |  T  |  P  |                               |         |         |
 * |  I  |  C  |                               |         |         |
 * |     |  I  |                               |         |         |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_IntCtl		$12,1
#define R_C0_IntCtl		12
#define R_C0_SelIntCtl		1

#define S_IntCtlIPTI    29
#define M_IntCtlIPTI    (0x7 << S_IntCtlIPTI)
#define W_IntCtlIPTI	3
#define S_IntCtlIPPCI   26
#define M_IntCtlIPPCI   (0x7 << S_IntCtlIPPCI)
#define W_IntCtlIPPCI	3
#define S_IntCtlVS      5
#define M_IntCtlVS      (0x1f << S_IntCtlVS)

#define M_IntCtl0Fields		0x03fffc1f
#define M_IntCtlRFields		0xfc000000

/*
 * Constants in the VS field
 */

#define K_IntCtlVS0	0x00				/* 0 bytes */
#define K_IntCtlVS32	0x01				/* 32 bytes */
#define K_IntCtlVS64	0x02				/* 64 bytes */
#define K_IntCtlVS128	0x04				/* 128 bytes */
#define K_IntCtlVS256	0x08				/* 256 bytes */
#define K_IntCtlVS512	0x10				/* 512 bytes */


/*
 ************************************************************************
 *          S R S C t l   R E G I S T E R   ( 1 2, SELECT 2 )           *
 ************************************************************************
 *   
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | 0 | HSS   |   0   | EICSS | 0 | ESS   | 0 |  PSS  | 0 | CSS   | : SRSCtl
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                                             *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *
 */

#define C0_SRSCtl		$12,2
#define R_C0_SRSCtl		12
#define R_C0_SelSRSCtl		2

#define S_SRSCtlHSS		26			/* Highest shadow set (R) */
#define W_SRSCtlHSS		4
#define M_SRSCtlHSS		(0xf << S_SRSCtlHSS)
#define S_SRSCtlEICSS		18			/* Exception shadow set (R/W) */
#define W_SRSCtlEICSS		4
#define M_SRSCtlEICSS		(0xf << S_SRSCtlEICSS)
#define S_SRSCtlESS		12			/* Exception shadow set (R/W) */
#define W_SRSCtlESS		4
#define M_SRSCtlESS		(0xf << S_SRSCtlESS)
#define S_SRSCtlPSS		6			/* Previous shadow set (R/W) */
#define W_SRSCtlPSS		4
#define M_SRSCtlPSS		(0xf << S_SRSCtlPSS)
#define S_SRSCtlCSS		0
#define W_SRSCtlCSS		4
#define M_SRSCtlCSS		(0xf << S_SRSCtlCSS)	/* Current Shadow set (R/W) */

#define M_SRSCtl0Fields		0xc3c30c30
#define M_SRSCtlRFields		0x3c3c000f



/*
 ************************************************************************
 *          S R S Map   R E G I S T E R   ( 1 2, SELECT 3  )            *
 ************************************************************************
 *   
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | SSV7  |  SSV6 |  SSV5 |  SSV4 |  SSV3 |  SSV2 |  SSV1 |  SSV0 | SRSMap
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_SRSMap		$12, 3
#define R_C0_SRSMap		12
#define R_C0_SelSRSMap		3

#define S_SRSMapSSV7		28			/* Shadow Register for SSV7 */
#define W_SRSMapSSV7		4
#define M_SRSMapSSV7		(0xf << S_SRSMapSSV7)
#define S_SRSMapSSV6		24			/* Shadow Register for SSV6 */
#define W_SRSMapSSV6		4
#define M_SRSMapSSV6		(0xf << S_SRSMapSSV6)
#define S_SRSMapSSV5		20			/* Shadow Register for SSV5 */
#define W_SRSMapSSV5		4
#define M_SRSMapSSV5		(0xf << S_SRSMapSSV5)
#define S_SRSMapSSV4		16			/* Shadow Register for SSV4 */
#define W_SRSMapSSV4		4
#define M_SRSMapSSV4		(0xf << S_SRSMapSSV4)
#define S_SRSMapSSV3		12			/* Shadow Register for SSV3 */
#define W_SRSMapSSV3		4
#define M_SRSMapSSV3		(0xf << S_SRSMapSSV3)
#define S_SRSMapSSV2		8			/* Shadow Register for SSV2 */
#define W_SRSMapSSV2		4
#define M_SRSMapSSV2		(0xf << S_SRSMapSSV2)
#define S_SRSMapSSV1		4			/* Shadow Register for SSV1 */
#define W_SRSMapSSV1		4
#define M_SRSMapSSV1		(0xf << S_SRSMapSSV1)
#define S_SRSMapSSV0		0			/* Shadow Register for SSV0 */
#define W_SRSMapSSV0		4
#define M_SRSMapSSV0		(0xf << S_SRSMapSSV0)


#define M_SRSMap0Fields		0x00000000
#define M_SRSMapRFields		0x00000000

/*
 ************************************************************************
 *          S R S H i   R E G I S T E R   ( 1 2, SELECT 4  )            *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |            0          | IPL12 | IPL11 | IPL10 |  IPL9 |  IPL8 |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_SRSHi		$12, 4
#define R_C0_SRSHi		12
#define R_C0_SelSRSHi		4

#define S_SRSHiIPL12		16			/* Shadow Register for IPL12 */
#define W_SRSHiIPL12		4
#define M_SRSHiIPL12		(0xf << S_SRSHiIPL12)
#define S_SRSHiIPL11		12			/* Shadow Register for IPL11 */
#define W_SRSHiIPL11		4
#define M_SRSHiIPL11		(0xf << S_SRSHiIPL11)
#define S_SRSHiIPL10		8			/* Shadow Register for IPL10 */
#define W_SRSHiIPL10		4
#define M_SRSHiIPL10		(0xf << S_SRSHiIPL10)
#define S_SRSHiIPL9		4			/* Shadow Register for IPL9  */
#define W_SRSHiIPL9		4
#define M_SRSHiIPL9		(0xf << S_SRSHiIPL9)
#define S_SRSHiIPL8		0			/* Shadow Register for IPL8  */
#define W_SRSHiIPL8		4
#define M_SRSHiIPL8		(0xf << S_SRSHiIPL8)

#define M_SRSHi0Fields		0xfff00000
#define M_SRSHiRFields		0x000fffff


/*
 ************************************************************************
 *                C A U S E   R E G I S T E R   ( 1 3 )                 *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | | |   | | |   |I|W| | | | | | |I|I|I|I|I|I|I|I| |         |   |
 * |B|0| C |0|0| 0 |V|P| | | | | | |P|P|P|P|P|P|P|P|0| ExcCode | 0 | Cause
 * |D| | E | | |   | | | | | | | | |7|6|5|4|3|2|1|0| |         |   |
 * | | |   | | |   | | | | | | | | | | | | | | | | | |         |   |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 *    T     D P                    \---RIPL----/
 *    I     C C                      Release 2
 *            I
 */

#define C0_Cause		$13
#define R_C0_Cause		13
#define R_C0_SelCause	0
#define C0_CAUSE		C0_Cause		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_CauseBD		31
#define M_CauseBD		(0x1 << S_CauseBD)
#define S_CauseCE		28
#define M_CauseCE		(0x3<< S_CauseCE)
#define S_CauseIV		23
#define M_CauseIV		(0x1 << S_CauseIV)
#define S_CauseWP		22
#define M_CauseWP		(0x1 << S_CauseWP)


#define S_CauseIP		8
#define M_CauseIP		(0xff << S_CauseIP)
#define S_CauseIPEXT		10
#define M_CauseIPEXT		(0x3f << S_CauseIPEXT)

#define S_CausePCI      26
#define M_CausePCI      (0x1 << S_CausePCI)
#define S_CauseDC       27
#define M_CauseDC       (0x1 << S_CauseDC)
#define S_CauseTI       30
#define M_CauseTI       (0x1 << S_CauseTI)
#define S_CauseRIPL     10
#define M_CauseRIPL     (0x3f << S_CauseRIPL)

#define S_CauseIP13		21
#define M_CauseIP13		(0x1 << S_CauseIP13)
#define S_CauseIP12		20
#define M_CauseIP12		(0x1 << S_CauseIP12)
#define S_CauseIP11		19
#define M_CauseIP11		(0x1 << S_CauseIP11)
#define S_CauseIP10		18
#define M_CauseIP10		(0x1 << S_CauseIP10)
#define S_CauseIP9		17
#define M_CauseIP9		(0x1 << S_CauseIP9)
#define S_CauseIP8		16
#define M_CauseIP8		(0x1 << S_CauseIP8)

#define S_CauseIP7		15
#define M_CauseIP7		(0x1 << S_CauseIP7)
#define S_CauseIP6		14
#define M_CauseIP6		(0x1 << S_CauseIP6)
#define S_CauseIP5		13
#define M_CauseIP5		(0x1 << S_CauseIP5)
#define S_CauseIP4		12
#define M_CauseIP4		(0x1 << S_CauseIP4)
#define S_CauseIP3		11
#define M_CauseIP3		(0x1 << S_CauseIP3)
#define S_CauseIP2		10
#define M_CauseIP2		(0x1 << S_CauseIP2)
#define S_CauseIP1		9
#define M_CauseIP1		(0x1 << S_CauseIP1)
#define S_CauseIP0		8
#define M_CauseIP0		(0x1 << S_CauseIP0)
#define S_CauseExcCode		2
#define W_CauseExcCode		5
#define M_CauseExcCode		(((1 << W_CauseExcCode) -1 )  << S_CauseExcCode)
#define M_Cause0Fields   	0x033f0083
#define M_CauseRFields  	0xf400fc7c

/*
 * Values in the CE field
 */
#define K_CauseCE0		0			/* Coprocessor 0 in the CE field */
#define K_CauseCE1		1			/* Coprocessor 1 in the CE field */
#define K_CauseCE2		2			/* Coprocessor 2 in the CE field */
#define K_CauseCE3		3			/* Coprocessor 3 in the CE field */

/*
 * Values in the ExcCode field
 */
#define	EX_INT			0			/* Interrupt */
#define	EXC_INT			(EX_INT << S_CauseExcCode)
#define	EX_MOD			1			/* TLB modified */
#define	EXC_MOD			(EX_MOD << S_CauseExcCode)
#define	EX_TLBL		        2			/* TLB exception (load or ifetch) */
#define	EXC_TLBL		(EX_TLBL << S_CauseExcCode)
#define	EX_TLBS		        3			/* TLB exception (store) */
#define	EXC_TLBS		(EX_TLBS << S_CauseExcCode)
#define	EX_ADEL		        4			/* Address error (load or ifetch) */
#define	EXC_ADEL		(EX_ADEL << S_CauseExcCode)
#define	EX_ADES		        5			/* Address error (store) */
#define	EXC_ADES		(EX_ADES << S_CauseExcCode)
#define	EX_IBE			6			/* Instruction Bus Error */
#define	EXC_IBE			(EX_IBE << S_CauseExcCode)
#define	EX_DBE			7			/* Data Bus Error */
#define	EXC_DBE			(EX_DBE << S_CauseExcCode)
#define	EX_SYS			8			/* Syscall */
#define	EXC_SYS			(EX_SYS << S_CauseExcCode)
#define	EX_SYSCALL		EX_SYS
#define	EXC_SYSCALL		EXC_SYS
#define	EX_BP			9			/* Breakpoint */
#define	EXC_BP			(EX_BP << S_CauseExcCode)
#define	EX_BREAK		EX_BP
#define	EXC_BREAK		EXC_BP
#define	EX_RI			10			/* Reserved instruction */
#define	EXC_RI			(EX_RI << S_CauseExcCode)
#define	EX_CPU			11			/* CoProcessor Unusable */
#define	EXC_CPU			(EX_CPU << S_CauseExcCode)
#define	EX_OV			12			/* OVerflow */
#define	EXC_OV			(EX_OV << S_CauseExcCode)
#define	EX_TR		    	13			/* Trap instruction */
#define	EXC_TR			(EX_TR << S_CauseExcCode)
#define	EX_TRAP			EX_TR
#define	EXC_TRAP		EXC_TR
#define EX_FPE			15			/* floating point exception */
#define EXC_FPE			(EX_FPE << S_CauseExcCode)
#define EX_CEU			17			/* CorExtend exception */
#define EXC_CEU			(EX_CEU << S_CauseExcCode)
#define EX_C2E			18			/* COP2 exception */
#define EXC_C2E			(EX_C2E << S_CauseExcCode)
#define EX_MDMX			22			/* MDMX exception */
#define EXC_MDMX		(EX_MDMX << S_CauseExcCode)
#define EX_WATCH		23			/* Watch exception */
#define EXC_WATCH		(EX_WATCH << S_CauseExcCode)
#define EX_MCHECK	    24 		/* Machine check exception */
#define EXC_MCHECK  	(EX_MCHECK << S_CauseExcCode)
#define EX_THREAD	        25			/* MT Thread exception */
#define EXC_THREAD 		(EX_THREAD << S_CauseExcCode)
#define EX_DSPDIS	        26			/* DSP Disabled exception */
#define EXC_DSPDIS 		(EX_DSPDIS << S_CauseExcCode)
#define EX_CacheErr	        30			/* Cache error caused re-entry to Debug Mode */
#define EXC_CacheErr 	(EX_CacheErr << S_CauseExcCode)


/*
 ************************************************************************
 *                   E P C   R E G I S T E R   ( 1 4 )                  *
 ************************************************************************
 * 	
 *  6 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  //                        Exception PC                            | EPC
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_EPC			$14
#define R_C0_EPC		14
#define R_C0_SelEPC		0

#define M_EPC0Fields		0x00000000
#define M_EPCRFields		0x00000000

/*
 ************************************************************************
 *                  P R I D   R E G I S T E R   ( 1 5 )                 *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  Company Opts |   Company ID  |  Procesor ID  |   Revision    | PRId
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_PRId			$15
#define R_C0_PRId		15
#define R_C0_SelPRId		0
#define C0_PRID			C0_PRID			/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_PRIdCoOpt		24			/* Company options (R) */
#define M_PRIdCoOpt		(0xff << S_PRIdCoOpt)
#define S_PRIdCoID		16			/* Company ID (R) */
#define M_PRIdCoID		(0xff << S_PRIdCoID)
#define S_PRIdImp		8			/* Implementation ID (R) */
#define M_PRIdImp		(0xff << S_PRIdImp)
#define S_PRIdRev		0			/* Revision (R) */
#define M_PRIdRev		(0xff << S_PRIdRev)

#define M_PRId0Fields		0x00000000
#define M_PRIdRFields		0xffffffff
/*
 * Values in the Company ID field
 */
#define K_PRIdCoID_MIPS	1
#define K_PRIdCoID_Broadcom 2
#define K_PRIdCoID_Alchemy 3
#define K_PRIdCoID_SiByte 4
#define K_PRIdCoID_SandCraft 5
#define K_PRIdCoID_Philips 6
#define K_PRIdCoID_Toshiba 7
#define K_PRIdCoID_LSI 8
#define K_PRIdCoID_Intrinsity 9
#define K_PRIdCoID_UNANNOUNCED10 10
#define K_PRIdCoID_Lexra 11
#define K_PRIdCoID_Raza 12
#define K_PRIdCoID_Cavium 13
#define K_PRIdCoID_UNANNOUNCED14 14
#define K_PRIdCoID_UNANNOUNCED15 15
#define K_PRIdCoID_NextAvailable 16 /* Next available encoding */


/*
 * Values in the implementation number field
 */
#define K_PRIdImp_4KC		0x80	/* MIPS32 4Kc with TLB MMU and Release 1 Architecture*/
#define K_PRIdImp_Jade		0x80	/*   Alternate (obsolete) name */
#define K_PRIdImp_5KC		0x81	/* MIPS64 5Kc/5Kf with TLB MMU and Release 1 Architecture */
#define K_PRIdImp_Opal		0x81	/*   Alternate (obsolete) name */
#define K_PRIdImp_20KC		0x82	/* MIPS64 20Kc with TLB MMU and Release 1 Architecture */
#define K_PRIdImp_Ruby		0x82	/*   Alternate (obsolete) name */
#define K_PRIdImp_4KMP		0x83	/* MIPS32 4Kp/4Km with FM MMU and Release 1 Architectur */
#define K_PRIdImp_JadeLite	0x83	/*   Alternate (obsolete) name */
#define K_PRIdImp_4KEc		0x84	/* MIPS32 4KEc with TLB MMU and Release 1 Architecture */
#define K_PRIdImp_4KEmp		0x85	/* MIPS32 4KEm/4KEp with FM MMU and Release 1 Architecture */
#define K_PRIdImp_4KSc		0x86	/* MIPS32 4KSc with TLB MMU and Release 1 Architecture */
#define K_PRIdImp_M4K		0x87	/* MIPS32 M4K with FM MMU and Release 2 Architecture */
#define K_PRIdImp_25Kf		0x88	/* MIPS64 25Kf with TLB MMU and Release 1 Architecture */
#define K_PRIdImp_Amethyst	0x88	/*   Alternate (obsolete) name */
#define K_PRIdImp_5KE		0x89	/* MIPS64 5KE with TLB MMU and Release 2 Architecture */
#define K_PRIdImp_4KEc_R2	0x90	/* MIPS32 4KEc with TLB MMU and Release 2 Architecture */
#define K_PRIdImp_4KEmp_R2	0x91	/* MIPS32 4KEm/4KEp with FM MMU and Release 2 Architecture */
#define K_PRIdImp_4KSd		0x92	/* MIPS32 4KSd with TLB MMU and Release 2 Architecture */

#define K_PRIdImp_24K		0x93	/* MIPS32 24K (Topaz) with Release 2 Architecture */
#define K_PRIdImp_Topaz		0x93	/*   Alternate (obsolete) name */
#define K_PRIdImp_TopazTLB	0x93	/*   Alternate (obsolete) name */

#define K_PRIdImp_34K		0x95	/* MIPS32 34K */
#define K_PRIdImp_24KE		0x96	/* MIPS32 24KE */
#define K_PRIdImp_54K		0x97	/*   Alternate (obsolete) name */ 
#define K_PRIdImp_74K		0x97	/* MIPS32 74K */
#define K_PRIdImp_84K		0x98	/* MIPS32 84K */
#define K_PRIdImp_34KMP		0x99	/* MIPS32 34K + MP */

#define K_PRIdImp_R3000		0x01
#define K_PRIdImp_R4000		0x04
#define K_PRIdImp_R10000	0x09
#define K_PRIdImp_R4300		0x0b
#define K_PRIdImp_R5000		0x23
#define K_PRIdImp_R5200		0x28
#define K_PRIdImp_R5400		0x54

/*
 ************************************************************************
 *           E B A S E   R E G I S T E R   ( 1 5, SELECT 1 )            *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |1|0|           Exception Base          |0 0|       CPUNum      | EBase
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_EBase		$15,1
#define R_C0_EBase		15
#define R_C0_SelEBase		1
#define S_EBaseVA		12	 		/* Exception Base (R/W) */
#define M_EBaseVA		(0xfffff << S_EBaseVA)
#define S_EBaseCPUNum		0			/* CPU Number (R) */
#define M_EBaseCPUNum		(0x3ff << S_EBaseCPUNum)
#define W_EBaseCPUNum           18
#define M_EBase0Fields		0x40000C00
#define M_EBaseRFields		0x800003ff

/*
 ************************************************************************
 *               C O N F I G   R E G I S T E R   ( 1 6 )                *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |M|                             |B| A |  A  |  M  |RSVD |V|  K  | Config
 * | | Reserved for Implementations|E| T |  R  |  T  |     |I|  0  |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 *                         |M|   |B|
 *                         |M|   |M|
 *                         +-+   +-+
 */

#define C0_Config		$16
#define R_C0_Config		16
#define R_C0_SelConfig		0
#define C0_CONFIG		C0_Config		/* OBSOLETE - DO NOT USE IN NEW CODE */


#define S_ConfigMore		31			/* Additional config registers present (R) */
#define M_ConfigMore		(0x1 << S_ConfigMore)
#define S_ConfigMM		18                      /* Merge mode (implementation specific) */
#define M_ConfigMM		(0x1 << S_ConfigMM)
#define S_ConfigBM		16                      /* Burst mode (implementation specific) */
#define M_ConfigBM            (0x1 << S_ConfigBM)
#define S_ConfigImpl		16			/* Implementation-specific fields */
#define M_ConfigImpl		(0x7fff << S_ConfigImpl)
#define S_ConfigBE		15			/* Denotes big-endian operation (R) */
#define M_ConfigBE		(0x1 << S_ConfigBE)
#define S_ConfigAT		13			/* Architecture type (R) */
#define M_ConfigAT		(0x3 << S_ConfigAT)
#define W_ConfigAT		2
#define S_ConfigAR		10			/* Architecture revision (R) */
#define M_ConfigAR		(0x7 << S_ConfigAR)
#define S_ConfigMT		7			/* MMU Type (R) */
#define M_ConfigMT		(0x7 << S_ConfigMT)
#define W_ConfigMT		3
#define S_ConfigVI		3			/* Icache is virtual (R) */
#define M_ConfigVI		(0x1 << S_ConfigVI)
#define S_ConfigK0		0			/* Kseg0 coherency algorithm (R/W) */
#define M_ConfigK0		(0x7 << S_ConfigK0)
#define W_ConfigK0		3

/*
 * The following definitions are technically part of the "reserved for
 * implementations" field, but are the semi-standard definition used in
 * fixed-mapping MMUs to control the cacheability of kuseg and kseg2/3
 * references.  For that reason, they are included here, but may be
 * overridden by true implementation-specific definitions
 */
#define S_ConfigK23		28			/* Kseg2/3 coherency algorithm (FM MMU only) (R/W) */
#define M_ConfigK23		(0x7 << S_ConfigK23)
#define W_ConfigK23		3
#define S_ConfigKU		25			/* Kuseg coherency algorithm (FM MMU only) (R/W) */
#define M_ConfigKU		(0x7 << S_ConfigKU)
#define W_ConfigKU		3

#define M_Config0Fields		0x00000070
#define M_ConfigRFields		0x8000ff88

/*
 * Values in the AT field
 */
#define K_ConfigAT_MIPS32	0			/* MIPS32 */
#define K_ConfigAT_MIPS64S	1			/* MIPS64 with 32-bit addresses */
#define K_ConfigAT_MIPS64	2			/* MIPS64 with 32/64-bit addresses */
#define K_ConfigAT_MAX		2			/* Max value */

/*
 * Values in the AR field
 */

#define K_ConfigAR_Rel1		0			/* Release 1 of the architecture */
#define K_ConfigAR_Rel2		1			/* Release 2 of the architecture */

/*
 * Values in the MT field
 */
#define K_ConfigMT_NoMMU	0			/* No MMU */
#define K_ConfigMT_TLBMMU	1			/* Standard TLB MMU */
#define K_ConfigMT_BATMMU	2			/* Standard BAT MMU */
#define K_ConfigMT_FMTMMU	3			/* Standard FMT MMU */
#define K_ConfigMT_FMMMU	K_ConfigMT_FMTMMU       /* alias for compatibility */


/*
 ************************************************************************
 *         C O N F I G 1   R E G I S T E R   ( 1 6, SELECT 1 )          *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |M|  MMU Size |  IS |  IL |  IA |  DS |  DL |  DA |C|M|P|W|C|E|F| Config1
 * | |           |     |     |     |     |     |     |2|D|C|R|A|P|P|
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Config1		$16,1
#define R_C0_Config1		16
#define R_C0_SelConfig1		1

#define S_Config1M		31			/* Additional Config registers present (R) */
#define M_Config1M		(0x1 << S_Config1More)
#define S_Config1More		S_Config1M		/* OBSOLETE */
#define M_Config1More		(0x1 << S_Config1M)
#define S_Config1MMUSize 	25			/* Number of MMU entries - 1 (R) */
#define M_Config1MMUSize 	(0x3f << S_Config1MMUSize)
#define W_Config1MMUSize 	6
#define S_Config1IS		22			/* Icache sets per way (R) */
#define M_Config1IS		(0x7 << S_Config1IS)
#define W_Config1IS		3
#define S_Config1IL		19			/* Icache line size (R) */
#define M_Config1IL		(0x7 << S_Config1IL)
#define W_Config1IL		3
#define S_Config1IA		16			/* Icache associativity - 1 (R) */
#define M_Config1IA		(0x7 << S_Config1IA)
#define W_Config1IA		3
#define S_Config1DS		13			/* Dcache sets per way (R) */
#define M_Config1DS		(0x7 << S_Config1DS)
#define W_Config1DS		3
#define S_Config1DL		10			/* Dcache line size (R) */
#define M_Config1DL		(0x7 << S_Config1DL)
#define W_Config1DL		3
#define S_Config1DA		7			/* Dcache associativity (R) */
#define M_Config1DA		(0x7 << S_Config1DA)
#define S_Config1C2		6			/* Coprocessor 2 present (R) */
#define W_Config1DA		3
#define M_Config1C2		(0x1 << S_Config1C2)
#define S_Config1MD		5			/* Denotes MDMX present (R) */
#define M_Config1MD		(0x1 << S_Config1MD)
#define S_Config1PC		4			/* Denotes performance counters present (R) */
#define M_Config1PC		(0x1 << S_Config1PC)
#define S_Config1WR		3			/* Denotes watch registers present (R) */
#define M_Config1WR		(0x1 << S_Config1WR)
#define S_Config1CA		2			/* Denotes MIPS-16 present (R) */
#define M_Config1CA		(0x1 << S_Config1CA)
#define S_Config1EP		1			/* Denotes EJTAG present (R) */
#define M_Config1EP		(0x1 << S_Config1EP)
#define S_Config1FP		0			/* Denotes floating point present (R) */
#define M_Config1FP		(0x1 << S_Config1FP)
#define W_Config1FP		1

#define M_Config10Fields	0x00000000
#define M_Config1RFields	0xffffffff

/*
 * The following macro generates a table that is indexed
 * by the Icache or Dcache sets field in Config1 or the
 * Scache or Tcache sets field in Config2 and
 * contains the decoded value of sets per way
 */
#define Config1CacheSets()	\
	HALF(64);		\
	HALF(128);		\
	HALF(256);		\
	HALF(512);		\
	HALF(1024);		\
	HALF(2048);		\
	HALF(4096);		\
	HALF(8192);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);

/*
 * The following macro generates a table that is indexed
 * by the Icache or Dcache line size field in Config1 or
 * the Scache or Tcache line size field in Config2 and
 * contains the decoded value of the cache line size, in bytes
 */
#define Config1CacheLineSize()	\
	HALF(0);		\
	HALF(4);		\
	HALF(8);		\
	HALF(16);		\
	HALF(32);		\
	HALF(64);		\
	HALF(128);		\
	HALF(256);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);		\
	HALF(0);

/*
 ************************************************************************
 *         C O N F I G 2   R E G I S T E R   ( 1 6, SELECT 2 )          *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |M| TU  |  TS   |  TL   |  TA   |  SU   |  SS   |  SL   |  SA   | Config2
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Config2		$16,2
#define R_C0_Config2		16
#define R_C0_SelConfig2		2

#define S_Config2M		31			/* Additional Config registers present (R) */
#define M_Config2M		(0x1 << S_Config2M)

#define M_Config20Fields	0x00000000
#define M_Config2RFields	0xffffffff

/*
 * The following definitions are not inside a MIPS_Release2 conditional
 * because a number of Release 1 chips have stanardized on this
 * definition.
 */
#define S_Config2TU             28
#define M_Config2TU             (0x7 << S_Config2TU)	/* Implementation-dependent tertiary cache control (R/W) */
#define W_Config2TU             4
#define S_Config2TS             24
#define M_Config2TS             (0xf << S_Config2TS)	/* Tertiary cache sets per way (R) */
#define W_Config2TS             4
#define S_Config2TL             20
#define M_Config2TL             (0xf << S_Config2TL)	/* Tertiary cache line size (R) */
#define W_Config2TL             4
#define S_Config2TA             16
#define M_Config2TA             (0xf << S_Config2TA)	/* Tertiary cache associativity (R) */
#define W_Config2TA             4

#define S_Config2SU             12
#define M_Config2SU             (0xf << S_Config2SU)	/* Implementation-dependent secondary cache control (R/W) */
#define W_Config2SU             4
#define S_Config2SS             8
#define M_Config2SS             (0xf << S_Config2SS)	/* Secondary cache sets per way (R) */
#define W_Config2SS             4
#define S_Config2SL             4
#define M_Config2SL             (0xf << S_Config2SL)	/* Secondary cache line size (R) */
#define W_Config2SL             4
#define S_Config2SA             0
#define M_Config2SA             (0xf << S_Config2SA)	/* Secondary cache associativity (R) */
#define W_Config2SA             4



/*
 ************************************************************************
 *         C O N F I G 3   R E G I S T E R   ( 1 6, SELECT 3 )          *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | |                             |   |U| |D|D|   | |V|V| | | | | |
 * | |                             | I |L|R|S|S|   |L|E|I| | |M| | |
 * |M|                             | S |R|X|P|P|   |P|I|n|S| |T|S|T| Config3
 * | |                             | A |I|I|2|P|   |A|C|t|P| | |M|L|
 * | |                             |   | | |P| |   | | | | | | | | | 
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Config3		$16,3
#define R_C0_Config3		16
#define R_C0_SelConfig3		3

#define S_Config3M		31			/* Additional Config registers present (R) */
#define M_Config3M		(0x1 << S_Config3M)

#define S_Config3ISA            14                      /* MicroMIPS Mode */
#define M_Config3ISA            (0x3 << S_Config3ISA)
#define S_Config3ULRI           13                      /* User Local Register Implemented (R) */
#define M_Config3ULRI           (0x1 << S_Config3ULRI)
#define S_Config3RXI            12                      /* Read/execute inhibit implemented */
#define M_Config3RXI            (0x1 << S_Config3RXI)
#define S_Config3DSP2P          11                      /* DSP Rev2 Present */
#define M_Config3DSP2P          (0x1 << S_Config3DSP2P)
#define S_Config3DSPP           10                      /* DSP Present */
#define M_Config3DSPP           (0x1 << S_Config3DSPP)
#define S_Config3ITL		8			/* Denotes IFlow Tracing Logic present */
#define M_Config3ITL		(0x1 << S_Config3ITL)
#define S_Config3LPA  		7			/* Large Physical address support */
#define M_Config3LPA  		(0x1 << S_Config3LPA)
#define S_Config3VEIC  		6
#define M_Config3VEIC  		(0x1 << S_Config3VEIC)
#define S_Config3VInt  		5			/* External Interrupt controller support*/
#define M_Config3VInt  		(0x1 << S_Config3VInt)
#define S_Config3SP             4			/* Small Page & PageGrain present */
#define M_Config3SP             (0x1 << S_Config3SP)
#define S_Config3MT             2                       /* MT ASE is implemented */
#define W_Config3MT             1
#define M_Config3MT             (((1 << W_Config3MT) -1 )  << S_Config3MT)
#define S_Config3SM		1			/* Denotes SmartMIPS ASE present (R) */
#define M_Config3SM		(0x1 << S_Config3SM)
#define S_Config3TL		0			/* Denotes Tracing Logic present (R) */
#define M_Config3TL		(0x1 << S_Config3TL)

#define K_Config3ISA_LM		0
#define K_Config3ISA_LMMM	1
#define K_Config3ISA_MMLM	2
#define K_Config3ISA_MM		3
#define M_Config30Fields	0xfffffb08
#define M_Config3RFields	0x000004f7

/*
 ************************************************************************
 *                L L A D D R   R E G I S T E R   ( 1 7 )               *
 ************************************************************************
 * 	
 *  6 6    3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 2    1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |    //                      LL Physical Address                       | LLAddr
 * +-+-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_LLAddr		$17
#define R_C0_LLAddr		17
#define R_C0_SelLLAddr		0
#define C0_LLADDR		C0_LLAddr		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define M_LLAddr0Fields		0x00000000
#define M_LLAddrRFields		0x00000000


/*
 ************************************************************************
 *               W A T C H L O   R E G I S T E R   ( 1 8 )              *
 ************************************************************************
 * 	
 *  6 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  //                    Watch Virtual Address                 |I|R|W| WatchLo
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_WatchLo		$18
#define R_C0_WatchLo		18
#define R_C0_SelWatchLo		0
#define C0_WATCHLO		C0_WatchLo		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_WatchLoVAddr		3			/* Watch virtual address (R/W) */
#define M_WatchLoVAddr		(0x1fffffff << S_WatchLoVAddr)
#define S_WatchLoI		2			/* Enable Istream watch (R/W) */
#define M_WatchLoI		(0x1 << S_WatchLoI)
#define S_WatchLoR		1			/* Enable data read watch (R/W) */
#define M_WatchLoR		(0x1 << S_WatchLoR)
#define S_WatchLoW		0			/* Enable data write watch (R/W) */
#define M_WatchLoW		(0x1 << S_WatchLoW)

#define M_WatchLo0Fields	0x00000000
#define M_WatchLoRFields	0x00000000

#define M_WatchLoEnables	(M_WatchLoI | M_WatchLoR | M_WatchLoW)


/*
 ************************************************************************
 *               W A T C H H I   R E G I S T E R   ( 1 9 )              *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |M|G|    Rsvd   |      ASID     |  Rsvd |       Mask      |  0  | WatchHi
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_WatchHi		$19
#define R_C0_WatchHi		19
#define R_C0_SelWatchHi		0
#define C0_WATCHHI		C0_WatchHi		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_WatchHiM		31			/* Denotes additional Watch registers present (R) */
#define M_WatchHiM		(0x1 << S_WatchHiM)
#define S_WatchHiG		30			/* Enable ASID-independent Watch match (R/W) */
#define M_WatchHiG		(0x1 << S_WatchHiG)
#define S_WatchHiASID		16			/* ASID value to match (R/W) */
#define M_WatchHiASID		(0xff << S_WatchHiASID)
#define S_WatchHiMask		3			/* Address inhibit mask (R/W) */
#define M_WatchHiMask		(0x1ff << S_WatchHiMask)
#define S_WatchHiI		2
#define M_WatchHiI		(0x1 << S_WatchHiI)
#define S_WatchHiR		1
#define M_WatchHiR		(0x1 << S_WatchHiR)
#define S_WatchHiW		0
#define M_WatchHiW		(0x1 << S_WatchHiW)
#define M_WatchHi0Fields	0x3f00f000
#define M_WatchHiRFields	0x80000000


/*
 ************************************************************************
 *                 D E B U G   R E G I S T E R   ( 2 3 )                *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |D|D|N|L|D|H|C|I|M|C|D|I|D|D|     |         |N|S|O| |D|D|D|D|D|D|
 * |B|M|o|S|o|a|o|B|C|a|B|E|D|D|EJTAG|DExcCode |o|S|f| |I|I|D|D|B|S|
 * |D| |D|N|z|l|u|u|h|c|u|X|B|B| ver |         |S|t|f| |N|B|B|B|p|S|
 * | | |C|M|e|t|n|s|e|h|s|I|S|L|     |         |S| |L|0|T| |S|L| | | Debug
 * | | |R| | | |t|E|c|e|E| |I|I|     |         |t| |i| | | | | | | |
 * | | | | | | |D|P|k|E|P| |m|m|     |         | | |n| | | | | | | |
 * | | | | | | |M| |P|P| | |p|p|     |         | | |e| | | | | | | |
 * | | | | | | | | | | | | |r|r|     |         | | | | | | | | | | |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Debug		$23	/* EJTAG */
#define R_C0_Debug		23
#define R_C0_SelDebug		0

#define S_DebugDBD		31			/* Debug branch delay (R) */
#define M_DebugDBD		(0x1 << S_DebugDBD)
#define S_DebugDM		30			/* Debug mode (R) */
#define M_DebugDM		(0x1 << S_DebugDM)
#define S_DebugNoDCR		29			/* No debug control register present (R) */
#define M_DebugNoDCR		(0x1 << S_DebugNoDCR)
#define S_DebugLSNM		28			/* Load/Store Normal Memory (R/W) */
#define M_DebugLSNM		(0x1 << S_DebugLSNM)
#define S_DebugDoze		27			/* Doze (R) */
#define M_DebugDoze		(0x1 << S_DebugDoze)
#define S_DebugHalt		26			/* Halt (R) */
#define M_DebugHalt		(0x1 << S_DebugHalt)
#define S_DebugCountDM		25			/* Count register behavior in debug mode (R/W) */
#define M_DebugCountDM		(0x1 << S_DebugCountDM)
#define S_DebugIBusEP		24			/* Imprecise Instn Bus Error Pending (R/W) */
#define M_DebugIBusEP		(0x1 << S_DebugIBusEP)
#define S_DebugMCheckP		23			/* Imprecise Machine Check Pending (R/W) */
#define M_DebugMCheckP		(0x1 << S_DebugMCheckP)
#define S_DebugCacheEP		22			/* Imprecise Cache Error Pending (R/W) */
#define M_DebugCacheEP		(0x1 << S_DebugCacheEP)
#define S_DebugDBusEP		21			/* Imprecise Data Bus Error Pending (R/W) */
#define M_DebugDBusEP		(0x1 << S_DebugDBusEP)
#define S_DebugIEXI		20			/* Imprecise Exception Inhibit (R/W) */
#define M_DebugIEXI		(0x1 << S_DebugIEXI)
#define S_DebugDDBSImpr		19			/* Debug data break store imprecise (R) */
#define M_DebugDDBSImpr		(0x1 << S_DebugDDBSImpr)
#define S_DebugDDBLImpr		18			/* Debug data break load imprecise (R) */
#define M_DebugDDBLImpr		(0x1 << S_DebugDDBLImpr)
#define S_DebugEJTAGver		15			/* EJTAG version number (R) */
#define M_DebugEJTAGver		(0x7 << S_DebugEJTAGver)
#define S_DebugDExcCode		10			/* Debug exception code (R) */
#define M_DebugDExcCode		(0x1f << S_DebugDExcCode)
#define S_DebugNoSSt		9			/* No single step implemented (R) */
#define M_DebugNoSSt		(0x1 << S_DebugNoSSt)
#define S_DebugSSt		8			/* Single step enable (R/W) */
#define M_DebugSSt		(0x1 << S_DebugSSt)
#define S_DebugOffLine		7			/* CPU/TC offline except for Debug mode (R/W) */
#define M_DebugOffLine		(0x1 << S_DebugOffLine)
#define S_DebugDIBImpr		6			/* Debug instruction break imprecise (R) */
#define M_DebugDIBImpr		(0x1 << S_DebugDIBImpr)
#define S_DebugDINT		5			/* Debug interrupt (R) */
#define M_DebugDINT		(0x1 << S_DebugDINT)
#define S_DebugDIB		4			/* Debug instruction break (R) */
#define M_DebugDIB		(0x1 << S_DebugDIB)
#define S_DebugDDBS		3			/* Debug data break store (R) */
#define M_DebugDDBS		(0x1 << S_DebugDDBS)
#define S_DebugDDBL		2			/* Debug data break load (R) */
#define M_DebugDDBL		(0x1 << S_DebugDDBL)
#define S_DebugDBp		1			/* Debug breakpoint (R) */
#define M_DebugDBp		(0x1 << S_DebugDBp)
#define S_DebugDSS		0			/* Debug single step (R) */
#define M_DebugDSS		(0x1 << S_DebugDSS)

#define M_Debug0Fields	0x01f000c0
#define M_DebugRFields	0xec0ffe3f


/*
 ************************************************************************
 *     T r a c e C o n t r o l   R E G I S T E R   ( 2 3, SELECT 1 )    *
 ************************************************************************
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | | | | | | | | | | | |               |               | |T|T| | |
 * |T|U| |T|T|I| | | | | |               |               | |F|L|T|O|
 * |S|T|0|P|B|O|D|E|K|S|U|   ASID_M      |    ASID       |G|C|S|I|n|  TraceControl
 * | | | |C| | | | | | | |               |               | |R|M|M| |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_TraceControl		$23,1
#define R_C0_TraceControl	23
#define R_C0_SelTraceControl	1

#define S_TraceControlTS	31			/* Trace Select */
#define M_TraceControlTS	(0x1 << S_TraceControlTS)
#define S_TraceControlUT	30			/* User Triggered */
#define M_TraceControlUT	(0x1 << S_TraceControlUT)
#define S_TraceControlTPC       28                      /* Trace PC */
#define M_TraceControlTPC       (0x1 << S_TraceControlTPC)
#define S_TraceControlTB	27			/* Trace Branch */
#define M_TraceControlTB	(0x1 << S_TraceControlTB)
#define S_TraceControlIO	26			/* Inhibit Overflow */
#define M_TraceControlIO	(0x1 << S_TraceControlIO)
#define S_TraceControlD		25			/* Debug Mode Enable */
#define M_TraceControlD		(0x1 << S_TraceControlD)
#define S_TraceControlE		24			/* Exception Mode Enable */
#define M_TraceControlE		(0x1 << S_TraceControlE)
#define S_TraceControlK		23			/* Kernel Mode Enable */
#define M_TraceControlK		(0x1 << S_TraceControlK)
#define S_TraceControlS		22			/* Supervisor Mode Enable */
#define M_TraceControlS		(0x1 << S_TraceControlS)
#define S_TraceControlU		21			/* User Mode Enable */
#define M_TraceControlU		(0x1 << S_TraceControlU)
#define S_TraceControlASID_M	13			/* ASID Mask */
#define M_TraceControlASID_M	(0xff << S_TraceControlASID_M)
#define S_TraceControlASID	5			/* ASID */
#define M_TraceControlASID	(0xff << S_TraceControlASID)
#define S_TraceControlG		4			/* Global (all ASIDs) */
#define M_TraceControlG		(0x1 << S_TraceControlG)
#define S_TraceControlTFCR	3			/* Trace Function Call and Return */
#define M_TraceControlTFCR	(0x1 << S_TraceControlTFCR)
#define S_TraceControlTLSM	2			/* Trace Load Store Misses */
#define M_TraceControlTLSM	(0x1 << S_TraceControlTLSM)
#define S_TraceControlTIM	1			/* Trace Instruction Missses */
#define M_TraceControlTIM	(0x1 << S_TraceControlTIM)
#define S_TraceControlOn	0			/* Master Trace Enable */
#define M_TraceControlOn	(0x1 << S_TraceControlOn)

/* Reserved bits */
#define M_TraceControlR		(0x1 << 29)


/*
 ************************************************************************
 *   T r a c e C o n t r o l 2   R E G I S T E R   ( 2 3, SELECT 2 )    *
 ************************************************************************
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |   |C|               | |               |         |V  | | |     |
 * | 0 |P|               |T|               |         |a M|T|T|     |
 * |   |U|     CPUId     |C|   TCNum       |  Mode   |l o|B|B| SyP | TraceControl2
 * |   |I|               |V|               |         |i d|I|U|     |
 * |   |d|               | |               |         |d e| | |     |
 * |   |V|               | |               |         |  s| | |     |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */
#define C0_TraceControl2	$23,2
#define R_C0_TraceControl2	23
#define R_C0_SelTraceControl2	2

#define S_TraceControl2CPUIdV   29                      /* Trace Specified VPE only */
#define M_TraceControl2CPUIdV   (0x1 << S_TraceControl2CPUIdV)
#define S_TraceControl2CPUId    21                      /* VPE number to trace */
#define M_TraceControl2CPUId    (0xff << S_TraceControl2CPUId)
#define S_TraceControl2TCV      20                      /* Trace Specified TC only */
#define M_TraceControl2TCV      (0x1 << S_TraceControl2TCV)
#define S_TraceControl2TCNum    12                      /* TC number to trace */
#define M_TraceControl2TCNum    (0xff << S_TraceControl2TCNum)
#define S_TraceControl2Mode     7                       /* Trace Mode */
#define M_TraceControl2Mode     (0x1f << S_TraceControl2Mode)
#define S_TraceControl2ValidModes 5			/* Trace Modes supported by the processor */
#define M_TraceControl2ValidModes (0x3 << S_TraceControl2ValidModes)
#define S_TraceControl2TBI	4			/* Trace Buffers Implemented */
#define M_TraceControl2TBI	(0x1 << S_TraceControl2TBI)
#define S_TraceControl2TBU	3			/* Trace Buffer in Use */
#define M_TraceControl2TBU	(0x1 << S_TraceControl2TBU)
#define S_TraceControl2SyP	0			/* Sync Period */
#define M_TraceControl2SyP	(0x7 << S_TraceControl2SyP)

/* Reserved bits */
#define M_TraceControl2R	(0x3 << 30)


/*
 ************************************************************************
 *   U s e r T r a c e D a t a   R E G I S T E R   ( 2 3, SELECT 3 )    *
 ************************************************************************
 */
#define C0_UserTraceData	$23,3
#define R_C0_UserTraceData	23
#define R_C0_SelUserTraceData	3
#define M_UserTraceDataData	0xffffffff

/*
 ************************************************************************
 *   U s e r T r a c e D a t a 2   R E G I S T E R   ( 2 4, SELECT 3 )  *
 ************************************************************************
 */
#define C0_UserTraceData2	$24,3
#define R_C0_UserTraceData2	24
#define R_C0_SelUserTraceData2	3
#define M_UserTraceData2Data	0xffffffff


/*
 ************************************************************************
 *        T r a c e B P C   R E G I S T E R   ( 2 3, SELECT 4 )         *
 ************************************************************************
 */
#define C0_TraceBPC		$23,4
#define R_C0_TraceBPC		23
#define R_C0_SelTraceBPC	4

#define S_TraceBPCDE		31			/* Enable EJTAG data breakpoint triggers */
#define M_TraceBPCDE		(0x1 << S_TraceBPCDE)
#define S_TraceBPCDBPOn		16			/* Enable individual EJTAG data breakpoints to trigger tracing */
#define M_TraceBPCDBPOn		(0x7fff << S_TraceBPCDBPOn)
#define S_TraceBPCIE		15			/* Enable EJTAG instruction breakpoint triggers */
#define M_TraceBPCIE		(0x1 << S_TraceBPCIE)
#define S_TraceBPCIBPOn		0			/* Enable individual EJTAG instruction breakpoints to trigger tracing */
#define M_TraceBPCIBPOn		(0x7fff << S_TraceBPCIBPOn)

/*
 ************************************************************************
 *        T r a c e I B P C   R E G I S T E R   ( 2 3, SELECT 4 )       *
 ************************************************************************
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | |   | | |     |     |     |     |     |     |     |     |     |
 * |M| 0 |I|A|     |     |     |     |     |     |     |     |     |
 * |B|   |E|T|IBPC8|IBPC7|IBPC6|IBPC5|IBPC4|IBPC3|IBPC2|IBPC1|IBPC0| TraceIBPC
 * | |   | |E|     |     |     |     |     |     |     |     |     |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_TraceIBPC		$23,4
#define R_C0_TraceIBPC		23
#define R_C0_SelTraceIBPC	4

#define S_TraceIBPCMB		31			/* More Instruction breakpoints are present, look at TraceIBPC2 */
#define M_TraceIBPCMB		(0x1 << S_TraceIBPCMB)
#define S_TraceIBPCIE		28			/* Enable EJTAG instruction breakpoint triggers */
#define M_TraceIBPCIE		(0x1 << S_TraceIBPCIE)
#define S_TraceIBPCATE		27			/* Enable EJTAG instruction breakpoint triggers */
#define M_TraceIBPCATE		(0x1 << S_TraceIBPCATE)
#define S_TraceIBPCIBPC8	24			
#define M_TraceIBPCIBPC8	(0x7 << S_TraceIBPCIBPC8)
#define S_TraceIBPCIBPC7	21			
#define M_TraceIBPCIBPC7	(0x7 << S_TraceIBPCIBPC7)
#define S_TraceIBPCIBPC6	18			
#define M_TraceIBPCIBPC6	(0x7 << S_TraceIBPCIBPC6)
#define S_TraceIBPCIBPC5	15			
#define M_TraceIBPCIBPC5	(0x7 << S_TraceIBPCIBPC5)
#define S_TraceIBPCIBPC4	12			
#define M_TraceIBPCIBPC4	(0x7 << S_TraceIBPCIBPC4)
#define S_TraceIBPCIBPC3	9 			
#define M_TraceIBPCIBPC3	(0x7 << S_TraceIBPCIBPC3)
#define S_TraceIBPCIBPC2	6 			
#define M_TraceIBPCIBPC2	(0x7 << S_TraceIBPCIBPC2)
#define S_TraceIBPCIBPC1	3 			
#define M_TraceIBPCIBPC1	(0x7 << S_TraceIBPCIBPC1)
#define S_TraceIBPCIBPC0	0
#define M_TraceIBPCIBPC0	(0x7 << S_TraceIBPCIBPC0)

/*
 ************************************************************************
 *        T r a c e D B P C   R E G I S T E R   ( 2 3, SELECT 5 )       *
 ************************************************************************
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | |   | | |     |     |     |     |     |     |     |     |     |
 * |M| 0 |D|A|     |     |     |     |     |     |     |     |     |
 * |B|   |E|T|DBPC8|DBPC7|DBPC6|DBPC5|DBPC4|DBPC3|DBPC2|DBPC1|DBPC0| TraceDBPC
 * | |   | |E|     |     |     |     |     |     |     |     |     |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_TraceDBPC		$23,5
#define R_C0_TraceDBPC		23
#define R_C0_SelTraceDBPC	5

#define S_TraceDBPCMB		31			/* More Data Breakpoints are present, look at TraceDBPC2 */
#define M_TraceDBPCMB		(0x1 << S_TraceDBPCMB)
#define S_TraceDBPCDE		28			/* Enable EJTAG Data Breakpoint triggers */
#define M_TraceDBPCDE		(0x1 << S_TraceDBPCDE)
#define S_TraceDBPCATE		27
#define M_TraceDBPCATE		(0x1 << S_TraceDBPCATE)
#define S_TraceDBPCDBPC8	24			
#define M_TraceDBPCDBPC8	(0x7 << S_TraceDBPCDBPC8)
#define S_TraceDBPCDBPC7	21			
#define M_TraceDBPCDBPC7	(0x7 << S_TraceDBPCDBPC7)
#define S_TraceDBPCDBPC6	18			
#define M_TraceDBPCDBPC6	(0x7 << S_TraceDBPCDBPC6)
#define S_TraceDBPCDBPC5	15			
#define M_TraceDBPCDBPC5	(0x7 << S_TraceDBPCDBPC5)
#define S_TraceDBPCDBPC4	12			
#define M_TraceDBPCDBPC4	(0x7 << S_TraceDBPCDBPC4)
#define S_TraceDBPCDBPC3	9 			
#define M_TraceDBPCDBPC3	(0x7 << S_TraceDBPCDBPC3)
#define S_TraceDBPCDBPC2	6 			
#define M_TraceDBPCDBPC2	(0x7 << S_TraceDBPCDBPC2)
#define S_TraceDBPCDBPC1	3 			
#define M_TraceDBPCDBPC1	(0x7 << S_TraceDBPCDBPC1)
#define S_TraceDBPCDBPC0	0
#define M_TraceDBPCDBPC0	(0x7 << S_TraceDBPCDBPC0)

/* Breakpoint control modes for TraceIBPC, TraceDBPC */

#define K_TraceBPCModeTraceStop    0  
#define K_TraceBPCModeTraceStart   1
#define K_TraceBPCModeQualifTrace  2
#define K_TraceBPCModeARMTrace     3
#define K_TraceBPCModeStopIfArmed  4
#define K_TraceBPCModeStartIfArmed 5
#define K_TraceBPCModeQualIfArmed  6
#define K_TraceBPCModeDISARM       7

/*
 ************************************************************************
 *                 D E B U G 2  R E G I S T E R   ( 2 3, Select 6 )     *
 ************************************************************************
 *  
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                                                       |P|D|T|P|
 * |                                                       |r|Q|u|a|
 * |                         0                             |m| |p|C| Debug2
 * |                                                       | | | |o|
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_Debug2       $23,6 /* EJTAG */
#define R_C0_Debug2     23
#define R_C0_SelDebug2  6

#define S_Debug2Prm     3           /* Break exception due to Primed match (R) */
#define M_Debug2Prm     (0x1 << S_Debug2Prm)
#define S_Debug2DQ      2           /* Break exception due to Qualified match (R) */
#define M_Debug2DQ      (0x1 << S_Debug2DQ)
#define S_Debug2Tup     1           /* Break exception due to Tuple match (R) */
#define M_Debug2Tup     (0x1 << S_Debug2Tup)
#define S_Debug2PaCo    0           /* Break exception due to Pass Counter match (R) */
#define M_Debug2PaCo    (0x1 << S_Debug2PaCo)

/*
 ************************************************************************
 *   T r a c e C o n t r o l 3   R E G I S T E R   ( 2 4, SELECT 2 )    *
 ************************************************************************
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                               |   |P|P|P|P|P|P|           |T|F|
 * |                               |   |e|e|e|e|e|e|           |R|D|
 * |               0               | 0 |C|C|C|C|C|C|     0     |P|T| TraceControl3
 * |                               |   |O|F|B|S|E| |           |A| |
 * |                               |   |v|C|P|y| | |           |D| |
 * |                               |   |f|R| |n| | |           | | |
 * |                               |   | | | |c| | |           | | |
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */
#define C0_TraceControl3	$24,2
#define R_C0_TraceControl3	24
#define R_C0_SelTraceControl3	2

#define S_TraceControl3PeCOvf	13
#define M_TraceControl3PeCOvf  (0x1 << S_TraceControl3PeCOvf)

#define S_TraceControl3PeCFCR	12
#define M_TraceControl3PeCFCR  (0x1 << S_TraceControl3PeCFCR)

#define S_TraceControl3PeCBP 	11
#define M_TraceControl3PeCBP   (0x1 << S_TraceControl3PeCBP)

#define S_TraceControl3PeCSync  10
#define M_TraceControl3PeCSync  (0x1 << S_TraceControl3PeCSync)

#define S_TraceControl3PeCE	9
#define M_TraceControl3PeCE	(0x1 << S_TraceControl3PeCE)

#define S_TraceControl3PeC	8
#define M_TraceControl3PeC	(0x1 << S_TraceControl3PeC)

#define S_TraceControl3TRPAD	1
#define M_TraceControl3TRPAD   (0x1 << S_TraceControl3TRPAD)

#define S_TraceControl3PeCFDT	0
#define M_TraceControl3PeCFDT  (0x1 << S_TraceControl3PeCFDT)

/*
 ************************************************************************
 *                 D E P C   R E G I S T E R   ( 2 4 )                  *
 ************************************************************************
 * 	
 *  6 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  //                  EJTAG Debug Exception PC                      | DEPC
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */


#define C0_DEPC			$24
#define R_C0_DEPC		24
#define R_C0_SelDEPC		0

#define M_DEEPC0Fields		0x00000000
#define M_DEEPCRFields		0x00000000


/*
 ************************************************************************
 *              P E R F C N T   R E G I S T E R   ( 2 5 )               *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | | |                                     |           |I| | | |E|
 * |M|W|                  0                  |   Event   |E|U|S|K|X| PerfCnt
 * | | |                                     |           | | | | |L|
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 *
 *
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                          Event Count                          | PerfCnt
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_PerfCnt		$25
#define R_C0_PerfCnt		25
#define R_C0_SelPerfCnt		0
#define R_C0_SelPerfCnt0	1
#define R_C0_SelPerfCnt1	3
#define R_C0_SelPerfCnt2	5
#define R_C0_SelPerfCnt3	7

#define R_C0_PerfCtrl           25
#define R_C0_SelPerfCtrl0	0
#define R_C0_SelPerfCtrl1	2
#define R_C0_SelPerfCtrl2	4
#define R_C0_SelPerfCtrl3	6

#define C0_PRFCNT0		C0_PerfCnt		/* OBSOLETE - DO NOT USE IN NEW CODE */
#define C0_PRFCNT1		C0_PerfCnt		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define S_PerfCntM		31			/* More performance counters exist (R) */
#define M_PerfCntM		(1 << S_PerfCntM)
#define S_PerfCntW		30			/* Event count is 64 bits (R) */
#define M_PerfCntW		(1 << S_PerfCntW)

#define S_PerfCntEvent		5			/* Enabled event (R/W) */
#define M_PerfCntEvent		(0x3f << S_PerfCntEvent)
#define S_PerfCntIE		4			/* Interrupt Enable (R/W) */
#define M_PerfCntIE		(1 << S_PerfCntIE)
#define S_PerfCntU		3			/* Enable counting in User Mode (R/W) */
#define M_PerfCntU		(1 << S_PerfCntU)
#define S_PerfCntS		2			/* Enable counting in Supervisor Mode (R/W) */
#define M_PerfCntS		(1 << S_PerfCntS)
#define S_PerfCntK		1			/* Enable counting in Kernel Mode (R/W) */
#define M_PerfCntK		(1 << S_PerfCntK)
#define S_PerfCntEXL		0			/* Enable counting while EXL==1 (R/W) */
#define M_PerfCntEXL		(1 << S_PerfCntEXL)
#define M_PerfCnt0Fields	0x3ffff000
#define M_PerfCntRFields	0xc0000000

/*
 ************************************************************************
 *               E R R C T L   R E G I S T E R   ( 2 6 )                *
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                        Error Control                          | ErrCtl
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_ErrCtl		$26
#define R_C0_ErrCtl		26
#define R_C0_SelErrCtl		0
#define C0_ECC			$26		/* OBSOLETE - DO NOT USE IN NEW CODE */
#define R_C0_ECC		26		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define M_ErrCtl0Fields		0x00000000
#define M_ErrCtlRFields		0x00000000


/*
 ************************************************************************
 *             C A C H E E R R   R E G I S T E R   ( 2 7 )              * CacheErr
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                     Cache Error Control                       | CacheErr
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_CacheErr		$27
#define R_C0_CacheErr		27
#define R_C0_SelCacheErr	0
#define C0_CACHE_ERR		C0_CacheErr		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define M_CacheErr0Fields	0x00000000
#define M_CachErrRFields	0x00000000


/*
 ************************************************************************
 *                T A G L O   R E G I S T E R   ( 2 8 )                 * TagLo
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                            TagLo                              | TagLo
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 *
 * Example implementation
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                   PTagLo                      |V|D|L|Imp| 0 |P|
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_TagLo		$28
#define R_C0_TagLo		28
#define R_C0_SelTagLo		0
#define C0_TAGLO		C0_TagLo		/* OBSOLETE - DO NOT USE IN NEW CODE */

/* bitfield definitions for a sample implementation */
#define S_TagLoPTagLo		8
#define M_TagLoPTagLo		(0xffffff << S_TagLoPTagLo)
#define S_TagLoV                7
#define M_TagLoV      		(1 << S_TagLoV)
#define S_TagLoD                6
#define M_TagLoD      		(1 << S_TagLoD)
#define S_TagLoL                5
#define M_TagLoL      		(1 << S_TagLoL)
#define S_TagLoP                0
#define M_TagLoP      		(1 << S_TagLoP)


/*
 * Some implementations use separate TagLo registers for the
 * instruction and data caches.  In those cases, the following
 * definitions can be used in relevant code
 */

#define C0_ITagLo		$28,0
#define R_C0_ITagLo		28
#define R_C0_SelITagLo		0

#define C0_DTagLo		$28,2
#define R_C0_DTagLo		28
#define R_C0_SelDTagLo		2

#define M_TagLo0Fields		0x00000000
#define M_TagLoRFields		0x00000000


/*
 ************************************************************************
 *        D A T A L O   R E G I S T E R   ( 2 8, SELECT 1 )             * DataLo
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                           DataLo                              | DataLo
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_DataLo		$28,1
#define R_C0_DataLo		28
#define R_C0_SelDataLo		1

/*
 * Some implementations use separate DataLo registers for the
 * instruction and data caches.  In those cases, the following
 * definitions can be used in relevant code
 */

#define C0_IDataLo		$28,1
#define R_C0_IDataLo		28
#define R_C0_SelIDataLo		1

#define C0_DDataLo		$28,3
#define R_C0_DDataLo		28
#define R_C0_SelDDataLo		3

#define M_DataLo0Fields		0x00000000
#define M_DataLoRFields		0xffffffff


/*
 ************************************************************************
 *                T A G H I   R E G I S T E R   ( 2 9 )                 * TagHi
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                            TagHi                              | TagHi
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_TagHi		$29
#define R_C0_TagHi		29
#define R_C0_SelTagHi		0
#define C0_TAGHI		C0_TagHi		/* OBSOLETE - DO NOT USE IN NEW CODE */

/*
 * Some implementations use separate TagHi registers for the
 * instruction and data caches.  In those cases, the following
 * definitions can be used in relevant code
 */

#define C0_ITagHi		$29,0
#define R_C0_ITagHi		29
#define R_C0_SelITagHi		0

#define C0_DTagHi		$29,2
#define R_C0_DTagHi		29
#define R_C0_SelDTagHi		2

#define M_TagHi0Fields		0x00000000
#define M_TagHiRFields		0x00000000


/*
 ************************************************************************
 *        D A T A H I   R E G I S T E R   ( 2 9, SELECT 1 )             * DataHi
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |                           DataHi                              | DataHi
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_DataHi		$29,1
#define R_C0_DataHi		29
#define R_C0_SelDataHi		1

/*
 * Some implementations use separate DataHi registers for the
 * instruction and data caches.  In those cases, the following
 * definitions can be used in relevant code
 */

#define C0_IDataHi		$29,1
#define C0_DDataHi		$29,3

#define M_DataHi0Fields		0x00000000
#define M_DataHiRFields		0xffffffff


/*
 ************************************************************************
 *            E R R O R E P C   R E G I S T E R   ( 3 0 )               *
 ************************************************************************
 * 	
 *  6 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  //                          Error PC                              | ErrorEPC
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_ErrorEPC		$30
#define R_C0_ErrorEPC		30
#define R_C0_SelErrorEPC	0
#define C0_ERROR_EPC		C0_ErrorEPC		/* OBSOLETE - DO NOT USE IN NEW CODE */

#define M_ErrorEPC0Fields	0x00000000
#define M_ErrorEPCRFields	0x00000000


/*
 ************************************************************************
 *            D E S A V E   R E G I S T E R   ( 3 1 )                   *
 ************************************************************************
 * 	
 *  6 // 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  3 // 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |  //                   EJTAG Register Save Value                    | DESAVE
 * +-+//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_DESAVE		$31
#define R_C0_DESAVE		31
#define R_C0_SelDESAVE		0

#define M_DESAVE0Fields		0x00000000
#define M_DESAVERFields		0x00000000

/*
 ************************************************************************
 *           S R S C o n f 0   R E G I S T E R   ( 6, SELECT 1 )        * SRSConf0
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |M|0|        SRS3       |        SRS2       |        SRS1       | 
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_SRSConf0      $6,1
#define R_C0_SRSConf0    6
#define R_C0_SelSRSConf0 1

#define S_SRSConf0M    31
#define M_SRSConf0M    (0x1 << S_SRSConf0M)
#define S_SRSConf0SRS3 20
#define M_SRSConf0SRS3 (0x3ff << S_SRSConf0SRS3)
#define S_SRSConf0SRS2 10
#define M_SRSConf0SRS2 (0x3ff << S_SRSConf0SRS2)
#define S_SRSConf0SRS1 0
#define M_SRSConf0SRS1 (0x3ff << S_SRSConf0SRS1)

#define M_SRSConf00Fields 0x40000000
#define M_SRSConf0RFields 0x80000000

/*
 ************************************************************************
 *           S R S C o n f 1   R E G I S T E R   ( 6, SELECT 2 )        * SRSConf1
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |M|0|        SRS6       |        SRS5       |        SRS4       | 
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_SRSConf1      $6,2
#define R_C0_SRSConf1    6
#define R_C0_SelSRSConf1 2

#define S_SRSConf1M    31
#define M_SRSConf1M    (0x1 << S_SRSConf1M)
#define S_SRSConf1SRS6 20
#define M_SRSConf1SRS6 (0x3ff << S_SRSConf1SRS6)
#define S_SRSConf1SRS5 10
#define M_SRSConf1SRS5 (0x3ff << S_SRSConf1SRS5)
#define S_SRSConf1SRS4 0
#define M_SRSConf1SRS4 (0x3ff << S_SRSConf1SRS4)

#define M_SRSConf10Fields 0x40000000
#define M_SRSConf1RFields 0x80000000

/*
 ************************************************************************
 *           S R S C o n f 2   R E G I S T E R   ( 6, SELECT 3 )        * SRSConf2
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |M|0|        SRS9       |        SRS8       |        SRS7       | 
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_SRSConf2      $6,3
#define R_C0_SRSConf2    6
#define R_C0_SelSRSConf2 3

#define S_SRSConf2M    31
#define M_SRSConf2M    (0x1 << S_SRSConf2M)
#define S_SRSConf2SRS9 20
#define M_SRSConf2SRS9 (0x3ff << S_SRSConf2SRS9)
#define S_SRSConf2SRS8 10
#define M_SRSConf2SRS8 (0x3ff << S_SRSConf2SRS8)
#define S_SRSConf2SRS7 0
#define M_SRSConf2SRS7 (0x3ff << S_SRSConf2SRS7)

#define M_SRSConf20Fields 0x40000000
#define M_SRSConf2RFields 0x80000000

/*
 ************************************************************************
 *           S R S C o n f 3   R E G I S T E R   ( 6, SELECT 4 )        * SRSConf3
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |M|0|        SRS12      |        SRS11      |        SRS10      | 
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_SRSConf3      $6,4
#define R_C0_SRSConf3    6
#define R_C0_SelSRSConf3 4

#define S_SRSConf3M    31
#define M_SRSConf3M    (0x1 << S_SRSConf3M)
#define S_SRSConf3SRS12 20
#define M_SRSConf3SRS12 (0x3ff << S_SRSConf3SRS12)
#define S_SRSConf3SRS11 10
#define M_SRSConf3SRS11 (0x3ff << S_SRSConf3SRS11)
#define S_SRSConf3SRS10 0
#define M_SRSConf3SRS10 (0x3ff << S_SRSConf3SRS10)

#define M_SRSConf30Fields 0x40000000
#define M_SRSConf3RFields 0x80000000

/*
 ************************************************************************
 *           S R S C o n f 4   R E G I S T E R   ( 6, SELECT 5 )        * SRSConf4
 ************************************************************************
 * 	
 *  3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * | 0 |        SRS15      |        SRS14      |        SRS13      | 
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 */

#define C0_SRSConf4      $6,5
#define R_C0_SRSConf4    6
#define R_C0_SelSRSConf4 5

#define S_SRSConf4SRS15 20
#define M_SRSConf4SRS15 (0x3ff << S_SRSConf4SRS15)
#define S_SRSConf4SRS14 10
#define M_SRSConf4SRS14 (0x3ff << S_SRSConf4SRS14)
#define S_SRSConf4SRS13 0
#define M_SRSConf4SRS13 (0x3ff << S_SRSConf4SRS13)

#define M_SRSConf40Fields 0xC0000000
#define M_SRSConf4RFields 0x00000000

/*
 * ALTERA CONTENT
 */

/*
 * Macros for accessing selected processor registers
 */

/* HAL reserves register 26 (AKA k0) as the exception temporary register. */
#define MIPS32_READ_ET(et) \
	do { __asm volatile ("move %0, $26" : "=r" (et) ); } while (0)

#define MIPS32_WRITE_ET(et) \
	do { __asm volatile ("move $26, %z0" : : "rM" (et)); } while (0)

/* HAL reserves register 27 (AKA k1) as the stack limit register. */
#define MIPS32_READ_STACK_LIMIT(stack_limit) \
	do { __asm volatile ("move %0, $27" : "=r" (stack_limit) ); } while (0)

#define MIPS32_WRITE_STACK_LIMIT(stack_limit) \
	do { __asm volatile ("move $27, %z0" : : "rM" (stack_limit)); } while (0)

/* HAL reserves register 29 as the stack pointer register. */
#define MIPS32_READ_SP(sp) \
	do { __asm volatile ("move %0, $29" : "=r" (sp) ); } while (0)

/*
 * Macros for useful processor instructions
 */

#define MIPS32_BREAK() \
    do { __asm volatile ("sdbbp"); } while (0)

#define MIPS32_REPORT_STACK_OVERFLOW() \
    do { __asm volatile("sdbbp 3"); } while (0)

/* 
 * Sets C0_STATUS.IE to enable interrupts and returns it previous value.
 * No execution barrier added so it may take a few instructions to have
 * an effect after this macro returns.
 */
#define MIPS32_EI_RETURN_IE(dest) \
	do { __asm volatile ("ei %0" : "=r" (dest) ); } while (0)

/* 
 * Clears C0_STATUS.IE to disable interrupts and returns it previous value. 
 * Adds execution barrier to ensure interrupts are disabled when this
 * macro returns.
 */
#define MIPS32_DI_RETURN_IE(dest) \
	do { __asm volatile ("di %0; ehb" : "=r" (dest) ); } while (0)

/* 
 * Sets C0_STATUS.IE to enable interrupts. 
 * No execution barrier added so it may take a few instructions to have
 * an effect after this macro returns.
 */
#define MIPS32_EI() \
	do { __asm volatile ("ei"); } while (0)

/*
 * Clears C0_STATUS.IE to disable interrupts.
 * Adds execution barrier to ensure interrupts are disabled when this
 * macro returns.
 */
#define MIPS32_DI() \
	do { __asm volatile ("di; ehb"); } while (0)

/* Execution hazard barrier */
#define MIPS32_EHB() \
	do { __asm volatile ("ehb"); } while (0)

/*
 * Macros for accessing the control registers.
 */

#define MIPS32_READ_STATUS(dest) \
	do { __asm volatile ("mfc0 %0, $12" : "=r" (dest) ); } while (0)

#define MIPS32_WRITE_STATUS(src) \
	do { __asm volatile ("mtc0 %z0, $12" : : "rM" (src)); } while (0)

#define MIPS32_READ_CAUSE(dest) \
	do { __asm volatile ("mfc0 %0, $13" : "=r" (dest) ); } while (0)

#define MIPS32_READ_BAD_VADDR(dest) \
	do { __asm volatile ("mfc0 %0, $8" : "=r" (dest) ); } while (0)

/*
 * Number of available IRQs (hardware and software).
 */
#define MIPS32_HW_NIRQ 6
#define MIPS32_SW_NIRQ 2
#define MIPS32_NIRQ (MIPS32_HW_NIRQ + MIPS32_SW_NIRQ)

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALT_MIPS32_H__ */
