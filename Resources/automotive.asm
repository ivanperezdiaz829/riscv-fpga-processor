
automotive.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <uart_puts>:
   0:	20000737          	lui	a4,0x20000
   4:	00054783          	lbu	a5,0(a0)
   8:	00079463          	bnez	a5,10 <uart_puts+0x10>
   c:	00008067          	ret
  10:	00150513          	addi	a0,a0,1
  14:	00f70023          	sb	a5,0(a4) # 20000000 <_start+0x1fffff58>
  18:	fedff06f          	j	4 <uart_puts+0x4>

0000001c <uart_putu>:
  1c:	06051063          	bnez	a0,7c <uart_putu+0x60>
  20:	200007b7          	lui	a5,0x20000
  24:	03000713          	li	a4,48
  28:	00e78023          	sb	a4,0(a5) # 20000000 <_start+0x1fffff58>
  2c:	00008067          	ret
  30:	ff670713          	addi	a4,a4,-10
  34:	fee66ee3          	bltu	a2,a4,30 <uart_putu+0x14>
  38:	03070713          	addi	a4,a4,48
  3c:	00e68023          	sb	a4,0(a3)
  40:	00178793          	addi	a5,a5,1
  44:	00050713          	mv	a4,a0
  48:	00000513          	li	a0,0
  4c:	02e66263          	bltu	a2,a4,70 <uart_putu+0x54>
  50:	00168693          	addi	a3,a3,1
  54:	02051e63          	bnez	a0,90 <uart_putu+0x74>
  58:	fff00713          	li	a4,-1
  5c:	200006b7          	lui	a3,0x20000
  60:	fff78793          	addi	a5,a5,-1
  64:	02e79a63          	bne	a5,a4,98 <uart_putu+0x7c>
  68:	01010113          	addi	sp,sp,16
  6c:	00008067          	ret
  70:	ff670713          	addi	a4,a4,-10
  74:	00150513          	addi	a0,a0,1
  78:	fd5ff06f          	j	4c <uart_putu+0x30>
  7c:	ff010113          	addi	sp,sp,-16
  80:	00410693          	addi	a3,sp,4
  84:	00000793          	li	a5,0
  88:	00068593          	mv	a1,a3
  8c:	00900613          	li	a2,9
  90:	00050713          	mv	a4,a0
  94:	fa1ff06f          	j	34 <uart_putu+0x18>
  98:	00f58633          	add	a2,a1,a5
  9c:	00064603          	lbu	a2,0(a2)
  a0:	00c68023          	sb	a2,0(a3) # 20000000 <_start+0x1fffff58>
  a4:	fbdff06f          	j	60 <uart_putu+0x44>

000000a8 <_start>:
  a8:	fb010113          	addi	sp,sp,-80
  ac:	1b800513          	li	a0,440
  b0:	04812423          	sw	s0,72(sp)
  b4:	04912223          	sw	s1,68(sp)
  b8:	05212023          	sw	s2,64(sp)
  bc:	03312e23          	sw	s3,60(sp)
  c0:	03412c23          	sw	s4,56(sp)
  c4:	03512a23          	sw	s5,52(sp)
  c8:	03612823          	sw	s6,48(sp)
  cc:	03712623          	sw	s7,44(sp)
  d0:	03812423          	sw	s8,40(sp)
  d4:	03912223          	sw	s9,36(sp)
  d8:	03a12023          	sw	s10,32(sp)
  dc:	01b12e23          	sw	s11,28(sp)
  e0:	04112623          	sw	ra,76(sp)
  e4:	00200993          	li	s3,2
  e8:	f19ff0ef          	jal	ra,0 <uart_puts>
  ec:	04600913          	li	s2,70
  f0:	00000493          	li	s1,0
  f4:	38400413          	li	s0,900
  f8:	1e800513          	li	a0,488
  fc:	f05ff0ef          	jal	ra,0 <uart_puts>
 100:	00040513          	mv	a0,s0
 104:	f19ff0ef          	jal	ra,1c <uart_putu>
 108:	1f000513          	li	a0,496
 10c:	ef5ff0ef          	jal	ra,0 <uart_puts>
 110:	1f800513          	li	a0,504
 114:	eedff0ef          	jal	ra,0 <uart_puts>
 118:	00048513          	mv	a0,s1
 11c:	f01ff0ef          	jal	ra,1c <uart_putu>
 120:	20000513          	li	a0,512
 124:	eddff0ef          	jal	ra,0 <uart_puts>
 128:	20c00513          	li	a0,524
 12c:	ed5ff0ef          	jal	ra,0 <uart_puts>
 130:	00090513          	mv	a0,s2
 134:	ee9ff0ef          	jal	ra,1c <uart_putu>
 138:	21400513          	li	a0,532
 13c:	ec5ff0ef          	jal	ra,0 <uart_puts>
 140:	21c00513          	li	a0,540
 144:	ebdff0ef          	jal	ra,0 <uart_puts>
 148:	00098513          	mv	a0,s3
 14c:	ed1ff0ef          	jal	ra,1c <uart_putu>
 150:	22800513          	li	a0,552
 154:	eadff0ef          	jal	ra,0 <uart_puts>
 158:	07700793          	li	a5,119
 15c:	0497e663          	bltu	a5,s1,1a8 <_start+0x100>
 160:	00348493          	addi	s1,s1,3
 164:	07840413          	addi	s0,s0,120
 168:	01e00993          	li	s3,30
 16c:	32000793          	li	a5,800
 170:	00f47463          	bgeu	s0,a5,178 <_start+0xd0>
 174:	32000413          	li	s0,800
 178:	05e00793          	li	a5,94
 17c:	0127e463          	bltu	a5,s2,184 <_start+0xdc>
 180:	00190913          	addi	s2,s2,1
 184:	017d87b7          	lui	a5,0x17d8
 188:	84078793          	addi	a5,a5,-1984 # 17d7840 <_start+0x17d7798>
 18c:	00f12623          	sw	a5,12(sp)
 190:	00c12783          	lw	a5,12(sp)
 194:	fff78713          	addi	a4,a5,-1
 198:	00e12623          	sw	a4,12(sp)
 19c:	f4078ee3          	beqz	a5,f8 <_start+0x50>
 1a0:	00000013          	nop
 1a4:	fedff06f          	j	190 <_start+0xe8>
 1a8:	ffb48493          	addi	s1,s1,-5
 1ac:	f3840413          	addi	s0,s0,-200
 1b0:	00500993          	li	s3,5
 1b4:	fb9ff06f          	j	16c <_start+0xc4>
 1b8:	0a0d                	addi	s4,s4,3
 1ba:	2a2a                	fld	fs4,136(sp)
 1bc:	202a                	fld	ft0,136(sp)
 1be:	4952                	lw	s2,20(sp)
 1c0:	562d4353          	0x562d4353
 1c4:	6120                	flw	fs0,64(a0)
 1c6:	7475                	lui	s0,0xffffd
 1c8:	746f6d6f          	jal	s10,f690e <_start+0xf6866>
 1cc:	7669                	lui	a2,0xffffa
 1ce:	2065                	jal	276 <_start+0x1ce>
 1d0:	6164                	flw	fs1,68(a0)
 1d2:	6f626873          	csrrsi	a6,0x6f6,4
 1d6:	7261                	lui	tp,0xffff8
 1d8:	2064                	fld	fs1,192(s0)
 1da:	6564                	flw	fs1,76(a0)
 1dc:	6f6d                	lui	t5,0x1b
 1de:	2a20                	fld	fs0,80(a2)
 1e0:	2a2a                	fld	fs4,136(sp)
 1e2:	0a0d                	addi	s4,s4,3
 1e4:	0000                	unimp
 1e6:	0000                	unimp
 1e8:	5052                	0x5052
 1ea:	3a4d                	jal	fffffb9c <_start+0xfffffaf4>
 1ec:	0020                	addi	s0,sp,8
 1ee:	0000                	unimp
 1f0:	2020                	fld	fs0,64(s0)
 1f2:	207c                	fld	fa5,192(s0)
 1f4:	0020                	addi	s0,sp,8
 1f6:	0000                	unimp
 1f8:	65657053          	0x65657053
 1fc:	3a64                	fld	fs1,240(a2)
 1fe:	0020                	addi	s0,sp,8
 200:	6b20                	flw	fs0,80(a4)
 202:	2f6d                	jal	9bc <_start+0x914>
 204:	2068                	fld	fa0,192(s0)
 206:	7c20                	flw	fs0,120(s0)
 208:	2020                	fld	fs0,64(s0)
 20a:	0000                	unimp
 20c:	6554                	flw	fa3,12(a0)
 20e:	706d                	c.lui	zero,0xffffb
 210:	203a                	fld	ft0,392(sp)
 212:	0000                	unimp
 214:	4320                	lw	s0,64(a4)
 216:	2020                	fld	fs0,64(s0)
 218:	207c                	fld	fa5,192(s0)
 21a:	0020                	addi	s0,sp,8
 21c:	6854                	flw	fa3,20(s0)
 21e:	6f72                	flw	ft10,28(sp)
 220:	7474                	flw	fa3,108(s0)
 222:	656c                	flw	fa1,76(a0)
 224:	203a                	fld	ft0,392(sp)
 226:	0000                	unimp
 228:	2520                	fld	fs0,72(a0)
 22a:	0a0d                	addi	s4,s4,3
	...
