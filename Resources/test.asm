
test.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	02000793          	li	a5,32
   4:	200006b7          	lui	a3,0x20000
   8:	0007c703          	lbu	a4,0(a5)
   c:	00071463          	bnez	a4,14 <_start+0x14>
  10:	0000006f          	j	10 <_start+0x10>
  14:	00178793          	addi	a5,a5,1
  18:	00e68023          	sb	a4,0(a3) # 20000000 <_start+0x20000000>
  1c:	fedff06f          	j	8 <_start+0x8>
  20:	0a0d                	addi	s4,s4,3
  22:	2a2a                	fld	fs4,136(sp)
  24:	202a                	fld	ft0,136(sp)
  26:	6f48                	flw	fa0,28(a4)
  28:	616c                	flw	fa1,68(a0)
  2a:	6420                	flw	fs0,72(s0)
  2c:	7365                	lui	t1,0xffff9
  2e:	6564                	flw	fs1,76(a0)
  30:	6d20                	flw	fs0,88(a0)
  32:	2069                	jal	bc <_start+0xbc>
  34:	20555043          	fmadd.s	ft0,fa0,ft5,ft4,unknown
  38:	4952                	lw	s2,20(sp)
  3a:	562d4353          	0x562d4353
  3e:	2021                	jal	46 <_start+0x46>
  40:	2a2a                	fld	fs4,136(sp)
  42:	0d2a                	slli	s10,s10,0xa
  44:	000a                	c.slli	zero,0x2
