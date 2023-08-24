/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 // Error Code : no
TRAPHANDLER_NOEC(Int_divide, T_DIVIDE)
TRAPHANDLER_NOEC(Int_debug, T_DEBUG)
TRAPHANDLER_NOEC(Int_nmi, T_NMI)
TRAPHANDLER_NOEC(Int_brkpt, T_BRKPT)
TRAPHANDLER_NOEC(Int_oflow, T_OFLOW)
TRAPHANDLER_NOEC(Int_bound, T_BOUND)
TRAPHANDLER_NOEC(Int_illop, T_ILLOP)
TRAPHANDLER_NOEC(Int_device, T_DEVICE)
TRAPHANDLER_NOEC(Int_fperr, T_FPERR)
TRAPHANDLER_NOEC(Int_mchk, T_MCHK)
TRAPHANDLER_NOEC(Int_simderr, T_SIMDERR)
TRAPHANDLER_NOEC(Int_syscall, T_SYSCALL)
 // Error Code : yes
TRAPHANDLER(Int_dblflt, T_DBLFLT)
TRAPHANDLER(Int_tss, T_TSS)
TRAPHANDLER(Int_segnp, T_SEGNP)
TRAPHANDLER(Int_stack, T_STACK)
TRAPHANDLER(Int_gpflt, T_GPFLT)
TRAPHANDLER(Int_pgflt, T_PGFLT)
TRAPHANDLER(Int_align, T_ALIGN)

TRAPHANDLER_NOEC(Int_timer, IRQ_OFFSET + IRQ_TIMER)
TRAPHANDLER_NOEC(Int_kbd, IRQ_OFFSET + IRQ_KBD)
TRAPHANDLER_NOEC(Int_serial, IRQ_OFFSET + IRQ_SERIAL)
TRAPHANDLER_NOEC(Int_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
TRAPHANDLER_NOEC(Int_ide, IRQ_OFFSET + IRQ_IDE)
TRAPHANDLER_NOEC(Int_error, IRQ_OFFSET + IRQ_ERROR)

	
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
	pushl %es	
	pushal
	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp
	call trap
 	 
