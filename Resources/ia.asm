
ia.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <uart_puts>:
   0:	20000737          	lui	a4,0x20000
   4:	00054783          	lbu	a5,0(a0)
   8:	00079463          	bnez	a5,10 <uart_puts+0x10>
   c:	00008067          	ret
  10:	00150513          	addi	a0,a0,1
  14:	00f70023          	sb	a5,0(a4) # 20000000 <_start+0x1fffffbc>
  18:	fedff06f          	j	4 <uart_puts+0x4>

0000001c <uart_putu>:
  1c:	00051a63          	bnez	a0,30 <uart_putu+0x14>
  20:	200007b7          	lui	a5,0x20000
  24:	03000713          	li	a4,48
  28:	00e78023          	sb	a4,0(a5) # 20000000 <_start+0x1fffffbc>
  2c:	00008067          	ret
  30:	03050513          	addi	a0,a0,48
  34:	0ff57513          	zext.b	a0,a0
  38:	200007b7          	lui	a5,0x20000
  3c:	00a78023          	sb	a0,0(a5) # 20000000 <_start+0x1fffffbc>
  40:	00008067          	ret

00000044 <_start>:
  44:	fc010113          	addi	sp,sp,-64
  48:	12400513          	li	a0,292
  4c:	02112e23          	sw	ra,60(sp)
  50:	02912a23          	sw	s1,52(sp)
  54:	03312623          	sw	s3,44(sp)
  58:	03412423          	sw	s4,40(sp)
  5c:	03512223          	sw	s5,36(sp)
  60:	03612023          	sw	s6,32(sp)
  64:	01712e23          	sw	s7,28(sp)
  68:	01812c23          	sw	s8,24(sp)
  6c:	02812c23          	sw	s0,56(sp)
  70:	03212823          	sw	s2,48(sp)
  74:	f8dff0ef          	jal	ra,0 <uart_puts>
  78:	15000513          	li	a0,336
  7c:	017d89b7          	lui	s3,0x17d8
  80:	f81ff0ef          	jal	ra,0 <uart_puts>
  84:	00000493          	li	s1,0
  88:	84098993          	addi	s3,s3,-1984 # 17d7840 <_start+0x17d77fc>
  8c:	00100a13          	li	s4,1
  90:	00149413          	slli	s0,s1,0x1
  94:	00000913          	li	s2,0
  98:	0080006f          	j	a0 <_start+0x5c>
  9c:	00100913          	li	s2,1
  a0:	00048513          	mv	a0,s1
  a4:	f79ff0ef          	jal	ra,1c <uart_putu>
  a8:	17000513          	li	a0,368
  ac:	f55ff0ef          	jal	ra,0 <uart_puts>
  b0:	00090513          	mv	a0,s2
  b4:	f69ff0ef          	jal	ra,1c <uart_putu>
  b8:	17400513          	li	a0,372
  bc:	f45ff0ef          	jal	ra,0 <uart_puts>
  c0:	00140513          	addi	a0,s0,1
  c4:	00055463          	bgez	a0,cc <_start+0x88>
  c8:	00000513          	li	a0,0
  cc:	f51ff0ef          	jal	ra,1c <uart_putu>
  d0:	18000513          	li	a0,384
  d4:	f2dff0ef          	jal	ra,0 <uart_puts>
  d8:	fff44513          	not	a0,s0
  dc:	01f55513          	srli	a0,a0,0x1f
  e0:	f3dff0ef          	jal	ra,1c <uart_putu>
  e4:	18c00513          	li	a0,396
  e8:	f19ff0ef          	jal	ra,0 <uart_puts>
  ec:	01312623          	sw	s3,12(sp)
  f0:	00c12783          	lw	a5,12(sp)
  f4:	fff78713          	addi	a4,a5,-1
  f8:	00e12623          	sw	a4,12(sp)
  fc:	00079c63          	bnez	a5,114 <_start+0xd0>
 100:	ffd40413          	addi	s0,s0,-3
 104:	f9491ce3          	bne	s2,s4,9c <_start+0x58>
 108:	01448a63          	beq	s1,s4,11c <_start+0xd8>
 10c:	00100493          	li	s1,1
 110:	f81ff06f          	j	90 <_start+0x4c>
 114:	00000013          	nop
 118:	fd9ff06f          	j	f0 <_start+0xac>
 11c:	10500073          	wfi
 120:	ffdff06f          	j	11c <_start+0xd8>
 124:	0a0d                	addi	s4,s4,3
 126:	2a2a                	fld	fs4,136(sp)
 128:	202a                	fld	ft0,136(sp)
 12a:	4952                	lw	s2,20(sp)
 12c:	562d4353          	0x562d4353
 130:	7320                	flw	fs0,96(a4)
 132:	6d69                	lui	s10,0x1a
 134:	6c70                	flw	fa2,92(s0)
 136:	2065                	jal	1de <_start+0x19a>
 138:	6570                	flw	fa2,76(a0)
 13a:	6372                	flw	ft6,28(sp)
 13c:	7065                	c.lui	zero,0xffff9
 13e:	7274                	flw	fa3,100(a2)
 140:	64206e6f          	jal	t3,6782 <_start+0x673e>
 144:	6d65                	lui	s10,0x19
 146:	2a2a206f          	j	a23e8 <_start+0xa23a4>
 14a:	0d2a                	slli	s10,s10,0xa
 14c:	000a                	c.slli	zero,0x2
 14e:	0000                	unimp
 150:	3178                	fld	fa4,224(a0)
 152:	7820                	flw	fs0,112(s0)
 154:	2032                	fld	ft0,264(sp)
 156:	207c                	fld	fa5,192(s0)
 158:	67696577          	0x67696577
 15c:	7468                	flw	fa0,108(s0)
 15e:	6465                	lui	s0,0x19
 160:	735f 6d75 7c20      	0x7c206d75735f
 166:	6f20                	flw	fs0,88(a4)
 168:	7475                	lui	s0,0xffffd
 16a:	7570                	flw	fa2,108(a0)
 16c:	0d74                	addi	a3,sp,668
 16e:	000a                	c.slli	zero,0x2
 170:	2020                	fld	fs0,64(s0)
 172:	0000                	unimp
 174:	2020                	fld	fs0,64(s0)
 176:	207c                	fld	fa5,192(s0)
 178:	2020                	fld	fs0,64(s0)
 17a:	2020                	fld	fs0,64(s0)
 17c:	0020                	addi	s0,sp,8
 17e:	0000                	unimp
 180:	2020                	fld	fs0,64(s0)
 182:	2020                	fld	fs0,64(s0)
 184:	2020                	fld	fs0,64(s0)
 186:	7c20                	flw	fs0,120(s0)
 188:	2020                	fld	fs0,64(s0)
 18a:	0020                	addi	s0,sp,8
 18c:	0a0d                	addi	s4,s4,3
	...
