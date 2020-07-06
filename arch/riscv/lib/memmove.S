/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (C) 2013 Regents of the University of California
 */

#include <linux/linkage.h>
#include <asm/asm.h>

/* void *memmove(void *, const void *, size_t) */
ENTRY(__memmove)
WEAK(memmove)
	/* Nothing to do if destination pointer equals to source pointer or
	   if count is zero */
	beq a0, a1, 8f
	beqz a2, 8f

	/* Just jump to memcpy if source and distination are not overlapped or
	   if source pointer is greater (assuming memcpy handles data from
	   head to tail) */
	add t1, a0, a2
	add t2, a1, a2
	sltu t3, a0, t2
	sltu t4, t2, t1
	and t3, t3, t4
	bnez t3, 1f
	j memcpy

1:
	/* Copy in reverse order */

	/* Calculate start + 1 address */
	add t6, a0, a2
	add a1, a1, a2

	/* Defer to byte-oriented copy for small sizes */
	sltiu a3, a2, 128
	bnez a3, 5f

	/* Use word-oriented copy only if low-order bits match */
	andi a3, t6, SZREG-1
	andi a4, a1, SZREG-1
	bne a3, a4, 5f

	beqz a3, 3f  /* Skip if already aligned */

	/*
	 * Round to nearest double word-aligned address
	 * less than or equal to start + 1 address
	 */
	andi a3, a1, ~(SZREG-1)

	/* Handle initial misalignment */
	sub a4, a1, a3
2:
	addi a1, a1, -1
	lb a5, 0(a1)
	addi t6, t6, -1
	sb a5, 0(t6)
	bne a1, a3, 2b
	sub a2, a2, a4  /* Update count */

3:
	andi a4, a2, ~((16*SZREG)-1)
	beqz a4, 5f
	sub a3, t6, a4

4:
	addi a1, a1, -16*SZREG
	REG_L a4, 15*SZREG(a1)
	REG_L a5, 14*SZREG(a1)
	REG_L a6, 13*SZREG(a1)
	REG_L a7, 12*SZREG(a1)
	REG_L t0, 11*SZREG(a1)
	REG_L t1, 10*SZREG(a1)
	REG_L t2, 9*SZREG(a1)
	REG_L t3, 8*SZREG(a1)
	REG_L t4, 7*SZREG(a1)
	REG_L t5, 6*SZREG(a1)
	addi t6, t6, -16*SZREG
	REG_S a4, 15*SZREG(t6)
	REG_S a5, 14*SZREG(t6)
	REG_S a6, 13*SZREG(t6)
	REG_S a7, 12*SZREG(t6)
	REG_S t0, 11*SZREG(t6)
	REG_S t1, 10*SZREG(t6)
	REG_S t2, 9*SZREG(t6)
	REG_S t3, 8*SZREG(t6)
	REG_S t4, 7*SZREG(t6)
	REG_S t5, 6*SZREG(t6)
	REG_L a4, 5*SZREG(a1)
	REG_L a5, 4*SZREG(a1)
	REG_L a6, 3*SZREG(a1)
	REG_L a7, 2*SZREG(a1)
	REG_L t0,   SZREG(a1)
	REG_L t1,       0(a1)
	REG_S a4, 5*SZREG(t6)
	REG_S a5, 4*SZREG(t6)
	REG_S a6, 3*SZREG(t6)
	REG_S a7, 2*SZREG(t6)
	REG_S t0,   SZREG(t6)
	REG_S t1,       0(t6)
	bne a3, t6, 4b
	andi a2, a2, (16*SZREG)-1  /* Update count */

5:
	/* Handle trailing misalignment */
	beqz a2, 8f

	/* Use word-oriented copy if co-aligned to word boundary */
	or a5, a1, t6
	or a5, a5, a0
	andi a5, a5, 3
	bnez a5, 7f

6:
	addi a1, a1, -4
	lw a4, 0(a1)
	addi t6, t6, -4
	sw a4, 0(t6)
	bne a0, t6, 6b
	j 8f

7:
	/* Copy byte by byte */
	addi a1, a1, -1
	lb a4, 0(a1)
	addi t6, t6, -1
	sb a4, 0(t6)
	bne a0, t6, 7b

8:
	ret
END(__memmove)
