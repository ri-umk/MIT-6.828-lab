
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 70 12 f0       	mov    $0xf0127000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 4e 22 f0 00 	cmpl   $0x0,0xf0224e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 4e 22 f0    	mov    %esi,0xf0224e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 98 63 00 00       	call   f01063fc <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 c0 6a 10 f0 	movl   $0xf0106ac0,(%esp)
f010007d:	e8 f4 3e 00 00       	call   f0103f76 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 b5 3e 00 00       	call   f0103f43 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 b6 7c 10 f0 	movl   $0xf0107cb6,(%esp)
f0100095:	e8 dc 3e 00 00       	call   f0103f76 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 f3 08 00 00       	call   f0100999 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 2b 6b 10 f0 	movl   $0xf0106b2b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 15 63 00 00       	call   f01063fc <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 37 6b 10 f0 	movl   $0xf0106b37,(%esp)
f01000f2:	e8 7f 3e 00 00       	call   f0103f76 <cprintf>

	lapic_init();
f01000f7:	e8 1b 63 00 00       	call   f0106417 <lapic_init>
	env_init_percpu();
f01000fc:	e8 18 36 00 00       	call   f0103719 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 8a 3e 00 00       	call   f0103f90 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 f1 62 00 00       	call   f01063fc <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 50 22 f0    	add    $0xf0225020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100124:	e8 92 65 00 00       	call   f01066bb <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	// Remove this after you finish Exercise 6
	sched_yield();
f0100129:	e8 5c 4b 00 00       	call   f0104c8a <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 08 60 26 f0       	mov    $0xf0266008,%eax
f010013a:	2d 1c 3d 22 f0       	sub    $0xf0223d1c,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 1c 3d 22 f0 	movl   $0xf0223d1c,(%esp)
f0100152:	e8 77 5c 00 00       	call   f0105dce <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 41 05 00 00       	call   f010069d <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 4d 6b 10 f0 	movl   $0xf0106b4d,(%esp)
f010016b:	e8 06 3e 00 00       	call   f0103f76 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 25 13 00 00       	call   f010149a <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 c9 35 00 00       	call   f0103743 <env_init>
	trap_init();
f010017a:	e8 31 3f 00 00       	call   f01040b0 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	e8 90 5f 00 00       	call   f0106114 <mp_init>
	lapic_init();
f0100184:	e8 8e 62 00 00       	call   f0106417 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100189:	e8 3e 3d 00 00       	call   f0103ecc <pic_init>
f010018e:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100195:	e8 21 65 00 00       	call   f01066bb <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019a:	83 3d 88 4e 22 f0 07 	cmpl   $0x7,0xf0224e88
f01001a1:	77 24                	ja     f01001c7 <i386_init+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a3:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001aa:	00 
f01001ab:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01001b2:	f0 
f01001b3:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01001ba:	00 
f01001bb:	c7 04 24 2b 6b 10 f0 	movl   $0xf0106b2b,(%esp)
f01001c2:	e8 79 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c7:	b8 3e 60 10 f0       	mov    $0xf010603e,%eax
f01001cc:	2d c4 5f 10 f0       	sub    $0xf0105fc4,%eax
f01001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d5:	c7 44 24 04 c4 5f 10 	movl   $0xf0105fc4,0x4(%esp)
f01001dc:	f0 
f01001dd:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e4:	e8 2f 5c 00 00       	call   f0105e18 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e9:	bb 20 50 22 f0       	mov    $0xf0225020,%ebx
f01001ee:	eb 6f                	jmp    f010025f <i386_init+0x131>
		if (c == cpus + cpunum())  // We've started already.
f01001f0:	e8 07 62 00 00       	call   f01063fc <cpunum>
f01001f5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001fc:	29 c2                	sub    %eax,%edx
f01001fe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100201:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f0100208:	39 c3                	cmp    %eax,%ebx
f010020a:	74 50                	je     f010025c <i386_init+0x12e>

static void boot_aps(void);


void
i386_init(void)
f010020c:	89 d8                	mov    %ebx,%eax
f010020e:	2d 20 50 22 f0       	sub    $0xf0225020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100213:	c1 f8 02             	sar    $0x2,%eax
f0100216:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0100219:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f010021c:	89 d1                	mov    %edx,%ecx
f010021e:	c1 e1 05             	shl    $0x5,%ecx
f0100221:	29 d1                	sub    %edx,%ecx
f0100223:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100226:	89 d1                	mov    %edx,%ecx
f0100228:	c1 e1 0e             	shl    $0xe,%ecx
f010022b:	29 d1                	sub    %edx,%ecx
f010022d:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100230:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100234:	c1 e0 0f             	shl    $0xf,%eax
f0100237:	05 00 60 22 f0       	add    $0xf0226000,%eax
f010023c:	a3 84 4e 22 f0       	mov    %eax,0xf0224e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100241:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100248:	00 
f0100249:	0f b6 03             	movzbl (%ebx),%eax
f010024c:	89 04 24             	mov    %eax,(%esp)
f010024f:	e8 1c 63 00 00       	call   f0106570 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100254:	8b 43 04             	mov    0x4(%ebx),%eax
f0100257:	83 f8 01             	cmp    $0x1,%eax
f010025a:	75 f8                	jne    f0100254 <i386_init+0x126>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010025c:	83 c3 74             	add    $0x74,%ebx
f010025f:	a1 c4 53 22 f0       	mov    0xf02253c4,%eax
f0100264:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010026b:	29 c2                	sub    %eax,%edx
f010026d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100270:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f0100277:	39 c3                	cmp    %eax,%ebx
f0100279:	0f 82 71 ff ff ff    	jb     f01001f0 <i386_init+0xc2>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010027f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100286:	00 
f0100287:	c7 04 24 bc aa 1d f0 	movl   $0xf01daabc,(%esp)
f010028e:	e8 8d 36 00 00       	call   f0103920 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100293:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010029a:	00 
f010029b:	c7 04 24 5d 3e 21 f0 	movl   $0xf0213e5d,(%esp)
f01002a2:	e8 79 36 00 00       	call   f0103920 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01002a7:	e8 98 03 00 00       	call   f0100644 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01002ac:	e8 d9 49 00 00       	call   f0104c8a <sched_yield>

f01002b1 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002b1:	55                   	push   %ebp
f01002b2:	89 e5                	mov    %esp,%ebp
f01002b4:	53                   	push   %ebx
f01002b5:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002b8:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002be:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002c9:	c7 04 24 68 6b 10 f0 	movl   $0xf0106b68,(%esp)
f01002d0:	e8 a1 3c 00 00       	call   f0103f76 <cprintf>
	vcprintf(fmt, ap);
f01002d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01002dc:	89 04 24             	mov    %eax,(%esp)
f01002df:	e8 5f 3c 00 00       	call   f0103f43 <vcprintf>
	cprintf("\n");
f01002e4:	c7 04 24 b6 7c 10 f0 	movl   $0xf0107cb6,(%esp)
f01002eb:	e8 86 3c 00 00       	call   f0103f76 <cprintf>
	va_end(ap);
}
f01002f0:	83 c4 14             	add    $0x14,%esp
f01002f3:	5b                   	pop    %ebx
f01002f4:	5d                   	pop    %ebp
f01002f5:	c3                   	ret    
	...

f01002f8 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002f8:	55                   	push   %ebp
f01002f9:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002fb:	ba 84 00 00 00       	mov    $0x84,%edx
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100304:	5d                   	pop    %ebp
f0100305:	c3                   	ret    

f0100306 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100306:	55                   	push   %ebp
f0100307:	89 e5                	mov    %esp,%ebp
f0100309:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010030e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010030f:	a8 01                	test   $0x1,%al
f0100311:	74 08                	je     f010031b <serial_proc_data+0x15>
f0100313:	b2 f8                	mov    $0xf8,%dl
f0100315:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100316:	0f b6 c0             	movzbl %al,%eax
f0100319:	eb 05                	jmp    f0100320 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010031b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100320:	5d                   	pop    %ebp
f0100321:	c3                   	ret    

f0100322 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100322:	55                   	push   %ebp
f0100323:	89 e5                	mov    %esp,%ebp
f0100325:	53                   	push   %ebx
f0100326:	83 ec 04             	sub    $0x4,%esp
f0100329:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010032b:	eb 29                	jmp    f0100356 <cons_intr+0x34>
		if (c == 0)
f010032d:	85 c0                	test   %eax,%eax
f010032f:	74 25                	je     f0100356 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100331:	8b 15 24 42 22 f0    	mov    0xf0224224,%edx
f0100337:	88 82 20 40 22 f0    	mov    %al,-0xfddbfe0(%edx)
f010033d:	8d 42 01             	lea    0x1(%edx),%eax
f0100340:	a3 24 42 22 f0       	mov    %eax,0xf0224224
		if (cons.wpos == CONSBUFSIZE)
f0100345:	3d 00 02 00 00       	cmp    $0x200,%eax
f010034a:	75 0a                	jne    f0100356 <cons_intr+0x34>
			cons.wpos = 0;
f010034c:	c7 05 24 42 22 f0 00 	movl   $0x0,0xf0224224
f0100353:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100356:	ff d3                	call   *%ebx
f0100358:	83 f8 ff             	cmp    $0xffffffff,%eax
f010035b:	75 d0                	jne    f010032d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010035d:	83 c4 04             	add    $0x4,%esp
f0100360:	5b                   	pop    %ebx
f0100361:	5d                   	pop    %ebp
f0100362:	c3                   	ret    

f0100363 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100363:	55                   	push   %ebp
f0100364:	89 e5                	mov    %esp,%ebp
f0100366:	57                   	push   %edi
f0100367:	56                   	push   %esi
f0100368:	53                   	push   %ebx
f0100369:	83 ec 2c             	sub    $0x2c,%esp
f010036c:	89 c6                	mov    %eax,%esi
f010036e:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100373:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100378:	eb 05                	jmp    f010037f <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010037a:	e8 79 ff ff ff       	call   f01002f8 <delay>
f010037f:	89 fa                	mov    %edi,%edx
f0100381:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100382:	a8 20                	test   $0x20,%al
f0100384:	75 03                	jne    f0100389 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100386:	4b                   	dec    %ebx
f0100387:	75 f1                	jne    f010037a <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100389:	89 f2                	mov    %esi,%edx
f010038b:	89 f0                	mov    %esi,%eax
f010038d:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100390:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100395:	ee                   	out    %al,(%dx)
f0100396:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010039b:	bf 79 03 00 00       	mov    $0x379,%edi
f01003a0:	eb 05                	jmp    f01003a7 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01003a2:	e8 51 ff ff ff       	call   f01002f8 <delay>
f01003a7:	89 fa                	mov    %edi,%edx
f01003a9:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	84 c0                	test   %al,%al
f01003ac:	78 03                	js     f01003b1 <cons_putc+0x4e>
f01003ae:	4b                   	dec    %ebx
f01003af:	75 f1                	jne    f01003a2 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b1:	ba 78 03 00 00       	mov    $0x378,%edx
f01003b6:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003b9:	ee                   	out    %al,(%dx)
f01003ba:	b2 7a                	mov    $0x7a,%dl
f01003bc:	b0 0d                	mov    $0xd,%al
f01003be:	ee                   	out    %al,(%dx)
f01003bf:	b0 08                	mov    $0x8,%al
f01003c1:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003c2:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003c8:	75 06                	jne    f01003d0 <cons_putc+0x6d>
		c |= 0x0700;
f01003ca:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003d0:	89 f0                	mov    %esi,%eax
f01003d2:	25 ff 00 00 00       	and    $0xff,%eax
f01003d7:	83 f8 09             	cmp    $0x9,%eax
f01003da:	74 78                	je     f0100454 <cons_putc+0xf1>
f01003dc:	83 f8 09             	cmp    $0x9,%eax
f01003df:	7f 0b                	jg     f01003ec <cons_putc+0x89>
f01003e1:	83 f8 08             	cmp    $0x8,%eax
f01003e4:	0f 85 9e 00 00 00    	jne    f0100488 <cons_putc+0x125>
f01003ea:	eb 10                	jmp    f01003fc <cons_putc+0x99>
f01003ec:	83 f8 0a             	cmp    $0xa,%eax
f01003ef:	74 39                	je     f010042a <cons_putc+0xc7>
f01003f1:	83 f8 0d             	cmp    $0xd,%eax
f01003f4:	0f 85 8e 00 00 00    	jne    f0100488 <cons_putc+0x125>
f01003fa:	eb 36                	jmp    f0100432 <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f01003fc:	66 a1 34 42 22 f0    	mov    0xf0224234,%ax
f0100402:	66 85 c0             	test   %ax,%ax
f0100405:	0f 84 e2 00 00 00    	je     f01004ed <cons_putc+0x18a>
			crt_pos--;
f010040b:	48                   	dec    %eax
f010040c:	66 a3 34 42 22 f0    	mov    %ax,0xf0224234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100412:	0f b7 c0             	movzwl %ax,%eax
f0100415:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010041b:	83 ce 20             	or     $0x20,%esi
f010041e:	8b 15 30 42 22 f0    	mov    0xf0224230,%edx
f0100424:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100428:	eb 78                	jmp    f01004a2 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010042a:	66 83 05 34 42 22 f0 	addw   $0x50,0xf0224234
f0100431:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100432:	66 8b 0d 34 42 22 f0 	mov    0xf0224234,%cx
f0100439:	bb 50 00 00 00       	mov    $0x50,%ebx
f010043e:	89 c8                	mov    %ecx,%eax
f0100440:	ba 00 00 00 00       	mov    $0x0,%edx
f0100445:	66 f7 f3             	div    %bx
f0100448:	66 29 d1             	sub    %dx,%cx
f010044b:	66 89 0d 34 42 22 f0 	mov    %cx,0xf0224234
f0100452:	eb 4e                	jmp    f01004a2 <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f0100454:	b8 20 00 00 00       	mov    $0x20,%eax
f0100459:	e8 05 ff ff ff       	call   f0100363 <cons_putc>
		cons_putc(' ');
f010045e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100463:	e8 fb fe ff ff       	call   f0100363 <cons_putc>
		cons_putc(' ');
f0100468:	b8 20 00 00 00       	mov    $0x20,%eax
f010046d:	e8 f1 fe ff ff       	call   f0100363 <cons_putc>
		cons_putc(' ');
f0100472:	b8 20 00 00 00       	mov    $0x20,%eax
f0100477:	e8 e7 fe ff ff       	call   f0100363 <cons_putc>
		cons_putc(' ');
f010047c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100481:	e8 dd fe ff ff       	call   f0100363 <cons_putc>
f0100486:	eb 1a                	jmp    f01004a2 <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100488:	66 a1 34 42 22 f0    	mov    0xf0224234,%ax
f010048e:	0f b7 c8             	movzwl %ax,%ecx
f0100491:	8b 15 30 42 22 f0    	mov    0xf0224230,%edx
f0100497:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010049b:	40                   	inc    %eax
f010049c:	66 a3 34 42 22 f0    	mov    %ax,0xf0224234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004a2:	66 81 3d 34 42 22 f0 	cmpw   $0x7cf,0xf0224234
f01004a9:	cf 07 
f01004ab:	76 40                	jbe    f01004ed <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004ad:	a1 30 42 22 f0       	mov    0xf0224230,%eax
f01004b2:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004b9:	00 
f01004ba:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004c0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004c4:	89 04 24             	mov    %eax,(%esp)
f01004c7:	e8 4c 59 00 00       	call   f0105e18 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004cc:	8b 15 30 42 22 f0    	mov    0xf0224230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004d2:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004d7:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004dd:	40                   	inc    %eax
f01004de:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004e3:	75 f2                	jne    f01004d7 <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004e5:	66 83 2d 34 42 22 f0 	subw   $0x50,0xf0224234
f01004ec:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004ed:	8b 0d 2c 42 22 f0    	mov    0xf022422c,%ecx
f01004f3:	b0 0e                	mov    $0xe,%al
f01004f5:	89 ca                	mov    %ecx,%edx
f01004f7:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004f8:	66 8b 35 34 42 22 f0 	mov    0xf0224234,%si
f01004ff:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100502:	89 f0                	mov    %esi,%eax
f0100504:	66 c1 e8 08          	shr    $0x8,%ax
f0100508:	89 da                	mov    %ebx,%edx
f010050a:	ee                   	out    %al,(%dx)
f010050b:	b0 0f                	mov    $0xf,%al
f010050d:	89 ca                	mov    %ecx,%edx
f010050f:	ee                   	out    %al,(%dx)
f0100510:	89 f0                	mov    %esi,%eax
f0100512:	89 da                	mov    %ebx,%edx
f0100514:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100515:	83 c4 2c             	add    $0x2c,%esp
f0100518:	5b                   	pop    %ebx
f0100519:	5e                   	pop    %esi
f010051a:	5f                   	pop    %edi
f010051b:	5d                   	pop    %ebp
f010051c:	c3                   	ret    

f010051d <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010051d:	55                   	push   %ebp
f010051e:	89 e5                	mov    %esp,%ebp
f0100520:	53                   	push   %ebx
f0100521:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100524:	ba 64 00 00 00       	mov    $0x64,%edx
f0100529:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f010052a:	0f b6 c0             	movzbl %al,%eax
f010052d:	a8 01                	test   $0x1,%al
f010052f:	0f 84 e0 00 00 00    	je     f0100615 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100535:	a8 20                	test   $0x20,%al
f0100537:	0f 85 df 00 00 00    	jne    f010061c <kbd_proc_data+0xff>
f010053d:	b2 60                	mov    $0x60,%dl
f010053f:	ec                   	in     (%dx),%al
f0100540:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100542:	3c e0                	cmp    $0xe0,%al
f0100544:	75 11                	jne    f0100557 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f0100546:	83 0d 28 42 22 f0 40 	orl    $0x40,0xf0224228
		return 0;
f010054d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100552:	e9 ca 00 00 00       	jmp    f0100621 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f0100557:	84 c0                	test   %al,%al
f0100559:	79 33                	jns    f010058e <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010055b:	8b 0d 28 42 22 f0    	mov    0xf0224228,%ecx
f0100561:	f6 c1 40             	test   $0x40,%cl
f0100564:	75 05                	jne    f010056b <kbd_proc_data+0x4e>
f0100566:	88 c2                	mov    %al,%dl
f0100568:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010056b:	0f b6 d2             	movzbl %dl,%edx
f010056e:	8a 82 c0 6b 10 f0    	mov    -0xfef9440(%edx),%al
f0100574:	83 c8 40             	or     $0x40,%eax
f0100577:	0f b6 c0             	movzbl %al,%eax
f010057a:	f7 d0                	not    %eax
f010057c:	21 c1                	and    %eax,%ecx
f010057e:	89 0d 28 42 22 f0    	mov    %ecx,0xf0224228
		return 0;
f0100584:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100589:	e9 93 00 00 00       	jmp    f0100621 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f010058e:	8b 0d 28 42 22 f0    	mov    0xf0224228,%ecx
f0100594:	f6 c1 40             	test   $0x40,%cl
f0100597:	74 0e                	je     f01005a7 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100599:	88 c2                	mov    %al,%dl
f010059b:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010059e:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005a1:	89 0d 28 42 22 f0    	mov    %ecx,0xf0224228
	}

	shift |= shiftcode[data];
f01005a7:	0f b6 d2             	movzbl %dl,%edx
f01005aa:	0f b6 82 c0 6b 10 f0 	movzbl -0xfef9440(%edx),%eax
f01005b1:	0b 05 28 42 22 f0    	or     0xf0224228,%eax
	shift ^= togglecode[data];
f01005b7:	0f b6 8a c0 6c 10 f0 	movzbl -0xfef9340(%edx),%ecx
f01005be:	31 c8                	xor    %ecx,%eax
f01005c0:	a3 28 42 22 f0       	mov    %eax,0xf0224228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005c5:	89 c1                	mov    %eax,%ecx
f01005c7:	83 e1 03             	and    $0x3,%ecx
f01005ca:	8b 0c 8d c0 6d 10 f0 	mov    -0xfef9240(,%ecx,4),%ecx
f01005d1:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005d5:	a8 08                	test   $0x8,%al
f01005d7:	74 18                	je     f01005f1 <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f01005d9:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005dc:	83 fa 19             	cmp    $0x19,%edx
f01005df:	77 05                	ja     f01005e6 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f01005e1:	83 eb 20             	sub    $0x20,%ebx
f01005e4:	eb 0b                	jmp    f01005f1 <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f01005e6:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005e9:	83 fa 19             	cmp    $0x19,%edx
f01005ec:	77 03                	ja     f01005f1 <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f01005ee:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005f1:	f7 d0                	not    %eax
f01005f3:	a8 06                	test   $0x6,%al
f01005f5:	75 2a                	jne    f0100621 <kbd_proc_data+0x104>
f01005f7:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005fd:	75 22                	jne    f0100621 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01005ff:	c7 04 24 82 6b 10 f0 	movl   $0xf0106b82,(%esp)
f0100606:	e8 6b 39 00 00       	call   f0103f76 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010060b:	ba 92 00 00 00       	mov    $0x92,%edx
f0100610:	b0 03                	mov    $0x3,%al
f0100612:	ee                   	out    %al,(%dx)
f0100613:	eb 0c                	jmp    f0100621 <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100615:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010061a:	eb 05                	jmp    f0100621 <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010061c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100621:	89 d8                	mov    %ebx,%eax
f0100623:	83 c4 14             	add    $0x14,%esp
f0100626:	5b                   	pop    %ebx
f0100627:	5d                   	pop    %ebp
f0100628:	c3                   	ret    

f0100629 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100629:	55                   	push   %ebp
f010062a:	89 e5                	mov    %esp,%ebp
f010062c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010062f:	80 3d 00 40 22 f0 00 	cmpb   $0x0,0xf0224000
f0100636:	74 0a                	je     f0100642 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100638:	b8 06 03 10 f0       	mov    $0xf0100306,%eax
f010063d:	e8 e0 fc ff ff       	call   f0100322 <cons_intr>
}
f0100642:	c9                   	leave  
f0100643:	c3                   	ret    

f0100644 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100644:	55                   	push   %ebp
f0100645:	89 e5                	mov    %esp,%ebp
f0100647:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010064a:	b8 1d 05 10 f0       	mov    $0xf010051d,%eax
f010064f:	e8 ce fc ff ff       	call   f0100322 <cons_intr>
}
f0100654:	c9                   	leave  
f0100655:	c3                   	ret    

f0100656 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100656:	55                   	push   %ebp
f0100657:	89 e5                	mov    %esp,%ebp
f0100659:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010065c:	e8 c8 ff ff ff       	call   f0100629 <serial_intr>
	kbd_intr();
f0100661:	e8 de ff ff ff       	call   f0100644 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100666:	8b 15 20 42 22 f0    	mov    0xf0224220,%edx
f010066c:	3b 15 24 42 22 f0    	cmp    0xf0224224,%edx
f0100672:	74 22                	je     f0100696 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100674:	0f b6 82 20 40 22 f0 	movzbl -0xfddbfe0(%edx),%eax
f010067b:	42                   	inc    %edx
f010067c:	89 15 20 42 22 f0    	mov    %edx,0xf0224220
		if (cons.rpos == CONSBUFSIZE)
f0100682:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100688:	75 11                	jne    f010069b <cons_getc+0x45>
			cons.rpos = 0;
f010068a:	c7 05 20 42 22 f0 00 	movl   $0x0,0xf0224220
f0100691:	00 00 00 
f0100694:	eb 05                	jmp    f010069b <cons_getc+0x45>
		return c;
	}
	return 0;
f0100696:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010069b:	c9                   	leave  
f010069c:	c3                   	ret    

f010069d <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010069d:	55                   	push   %ebp
f010069e:	89 e5                	mov    %esp,%ebp
f01006a0:	57                   	push   %edi
f01006a1:	56                   	push   %esi
f01006a2:	53                   	push   %ebx
f01006a3:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006a6:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01006ad:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006b4:	5a a5 
	if (*cp != 0xA55A) {
f01006b6:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01006bc:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006c0:	74 11                	je     f01006d3 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006c2:	c7 05 2c 42 22 f0 b4 	movl   $0x3b4,0xf022422c
f01006c9:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006cc:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006d1:	eb 16                	jmp    f01006e9 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006d3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006da:	c7 05 2c 42 22 f0 d4 	movl   $0x3d4,0xf022422c
f01006e1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006e4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006e9:	8b 0d 2c 42 22 f0    	mov    0xf022422c,%ecx
f01006ef:	b0 0e                	mov    $0xe,%al
f01006f1:	89 ca                	mov    %ecx,%edx
f01006f3:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006f4:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f7:	89 da                	mov    %ebx,%edx
f01006f9:	ec                   	in     (%dx),%al
f01006fa:	0f b6 f8             	movzbl %al,%edi
f01006fd:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100700:	b0 0f                	mov    $0xf,%al
f0100702:	89 ca                	mov    %ecx,%edx
f0100704:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100705:	89 da                	mov    %ebx,%edx
f0100707:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100708:	89 35 30 42 22 f0    	mov    %esi,0xf0224230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010070e:	0f b6 d8             	movzbl %al,%ebx
f0100711:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100713:	66 89 3d 34 42 22 f0 	mov    %di,0xf0224234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f010071a:	e8 25 ff ff ff       	call   f0100644 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f010071f:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f0100726:	25 fd ff 00 00       	and    $0xfffd,%eax
f010072b:	89 04 24             	mov    %eax,(%esp)
f010072e:	e8 25 37 00 00       	call   f0103e58 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100733:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100738:	b0 00                	mov    $0x0,%al
f010073a:	89 da                	mov    %ebx,%edx
f010073c:	ee                   	out    %al,(%dx)
f010073d:	b2 fb                	mov    $0xfb,%dl
f010073f:	b0 80                	mov    $0x80,%al
f0100741:	ee                   	out    %al,(%dx)
f0100742:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100747:	b0 0c                	mov    $0xc,%al
f0100749:	89 ca                	mov    %ecx,%edx
f010074b:	ee                   	out    %al,(%dx)
f010074c:	b2 f9                	mov    $0xf9,%dl
f010074e:	b0 00                	mov    $0x0,%al
f0100750:	ee                   	out    %al,(%dx)
f0100751:	b2 fb                	mov    $0xfb,%dl
f0100753:	b0 03                	mov    $0x3,%al
f0100755:	ee                   	out    %al,(%dx)
f0100756:	b2 fc                	mov    $0xfc,%dl
f0100758:	b0 00                	mov    $0x0,%al
f010075a:	ee                   	out    %al,(%dx)
f010075b:	b2 f9                	mov    $0xf9,%dl
f010075d:	b0 01                	mov    $0x1,%al
f010075f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100760:	b2 fd                	mov    $0xfd,%dl
f0100762:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100763:	3c ff                	cmp    $0xff,%al
f0100765:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100769:	8a 45 e7             	mov    -0x19(%ebp),%al
f010076c:	a2 00 40 22 f0       	mov    %al,0xf0224000
f0100771:	89 da                	mov    %ebx,%edx
f0100773:	ec                   	in     (%dx),%al
f0100774:	89 ca                	mov    %ecx,%edx
f0100776:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100777:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f010077b:	74 1d                	je     f010079a <cons_init+0xfd>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f010077d:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f0100784:	25 ef ff 00 00       	and    $0xffef,%eax
f0100789:	89 04 24             	mov    %eax,(%esp)
f010078c:	e8 c7 36 00 00       	call   f0103e58 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100791:	80 3d 00 40 22 f0 00 	cmpb   $0x0,0xf0224000
f0100798:	75 0c                	jne    f01007a6 <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f010079a:	c7 04 24 8e 6b 10 f0 	movl   $0xf0106b8e,(%esp)
f01007a1:	e8 d0 37 00 00       	call   f0103f76 <cprintf>
}
f01007a6:	83 c4 2c             	add    $0x2c,%esp
f01007a9:	5b                   	pop    %ebx
f01007aa:	5e                   	pop    %esi
f01007ab:	5f                   	pop    %edi
f01007ac:	5d                   	pop    %ebp
f01007ad:	c3                   	ret    

f01007ae <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007ae:	55                   	push   %ebp
f01007af:	89 e5                	mov    %esp,%ebp
f01007b1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01007b7:	e8 a7 fb ff ff       	call   f0100363 <cons_putc>
}
f01007bc:	c9                   	leave  
f01007bd:	c3                   	ret    

f01007be <getchar>:

int
getchar(void)
{
f01007be:	55                   	push   %ebp
f01007bf:	89 e5                	mov    %esp,%ebp
f01007c1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007c4:	e8 8d fe ff ff       	call   f0100656 <cons_getc>
f01007c9:	85 c0                	test   %eax,%eax
f01007cb:	74 f7                	je     f01007c4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007cd:	c9                   	leave  
f01007ce:	c3                   	ret    

f01007cf <iscons>:

int
iscons(int fdnum)
{
f01007cf:	55                   	push   %ebp
f01007d0:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007d2:	b8 01 00 00 00       	mov    $0x1,%eax
f01007d7:	5d                   	pop    %ebp
f01007d8:	c3                   	ret    
f01007d9:	00 00                	add    %al,(%eax)
	...

f01007dc <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007dc:	55                   	push   %ebp
f01007dd:	89 e5                	mov    %esp,%ebp
f01007df:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007e2:	c7 04 24 d0 6d 10 f0 	movl   $0xf0106dd0,(%esp)
f01007e9:	e8 88 37 00 00       	call   f0103f76 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ee:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007f5:	00 
f01007f6:	c7 04 24 b0 6e 10 f0 	movl   $0xf0106eb0,(%esp)
f01007fd:	e8 74 37 00 00       	call   f0103f76 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100802:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100809:	00 
f010080a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100811:	f0 
f0100812:	c7 04 24 d8 6e 10 f0 	movl   $0xf0106ed8,(%esp)
f0100819:	e8 58 37 00 00       	call   f0103f76 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081e:	c7 44 24 08 ba 6a 10 	movl   $0x106aba,0x8(%esp)
f0100825:	00 
f0100826:	c7 44 24 04 ba 6a 10 	movl   $0xf0106aba,0x4(%esp)
f010082d:	f0 
f010082e:	c7 04 24 fc 6e 10 f0 	movl   $0xf0106efc,(%esp)
f0100835:	e8 3c 37 00 00       	call   f0103f76 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010083a:	c7 44 24 08 1c 3d 22 	movl   $0x223d1c,0x8(%esp)
f0100841:	00 
f0100842:	c7 44 24 04 1c 3d 22 	movl   $0xf0223d1c,0x4(%esp)
f0100849:	f0 
f010084a:	c7 04 24 20 6f 10 f0 	movl   $0xf0106f20,(%esp)
f0100851:	e8 20 37 00 00       	call   f0103f76 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100856:	c7 44 24 08 08 60 26 	movl   $0x266008,0x8(%esp)
f010085d:	00 
f010085e:	c7 44 24 04 08 60 26 	movl   $0xf0266008,0x4(%esp)
f0100865:	f0 
f0100866:	c7 04 24 44 6f 10 f0 	movl   $0xf0106f44,(%esp)
f010086d:	e8 04 37 00 00       	call   f0103f76 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100872:	b8 07 64 26 f0       	mov    $0xf0266407,%eax
f0100877:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010087c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100881:	89 c2                	mov    %eax,%edx
f0100883:	85 c0                	test   %eax,%eax
f0100885:	79 06                	jns    f010088d <mon_kerninfo+0xb1>
f0100887:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010088d:	c1 fa 0a             	sar    $0xa,%edx
f0100890:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100894:	c7 04 24 68 6f 10 f0 	movl   $0xf0106f68,(%esp)
f010089b:	e8 d6 36 00 00       	call   f0103f76 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a5:	c9                   	leave  
f01008a6:	c3                   	ret    

f01008a7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008a7:	55                   	push   %ebp
f01008a8:	89 e5                	mov    %esp,%ebp
f01008aa:	53                   	push   %ebx
f01008ab:	83 ec 14             	sub    $0x14,%esp
f01008ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008b3:	8b 83 24 70 10 f0    	mov    -0xfef8fdc(%ebx),%eax
f01008b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008bd:	8b 83 20 70 10 f0    	mov    -0xfef8fe0(%ebx),%eax
f01008c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c7:	c7 04 24 e9 6d 10 f0 	movl   $0xf0106de9,(%esp)
f01008ce:	e8 a3 36 00 00       	call   f0103f76 <cprintf>
f01008d3:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01008d6:	83 fb 24             	cmp    $0x24,%ebx
f01008d9:	75 d8                	jne    f01008b3 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008db:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e0:	83 c4 14             	add    $0x14,%esp
f01008e3:	5b                   	pop    %ebx
f01008e4:	5d                   	pop    %ebp
f01008e5:	c3                   	ret    

f01008e6 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008e6:	55                   	push   %ebp
f01008e7:	89 e5                	mov    %esp,%ebp
f01008e9:	57                   	push   %edi
f01008ea:	56                   	push   %esi
f01008eb:	53                   	push   %ebx
f01008ec:	83 ec 4c             	sub    $0x4c,%esp
	cprintf("Stack backtrace:\n");
f01008ef:	c7 04 24 f2 6d 10 f0 	movl   $0xf0106df2,(%esp)
f01008f6:	e8 7b 36 00 00       	call   f0103f76 <cprintf>
	uint32_t *ebp = (uint32_t*)read_ebp();
f01008fb:	89 ee                	mov    %ebp,%esi
    	uint32_t eip ;
    	while(ebp){
f01008fd:	e9 82 00 00 00       	jmp    f0100984 <mon_backtrace+0x9e>
		eip = *(ebp + 1);
f0100902:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("ebp %x eip %x args", ebp, eip);
f0100905:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100909:	89 74 24 04          	mov    %esi,0x4(%esp)
f010090d:	c7 04 24 04 6e 10 f0 	movl   $0xf0106e04,(%esp)
f0100914:	e8 5d 36 00 00       	call   f0103f76 <cprintf>
		uint32_t *esp = ebp + 2;
		for(int i = 0; i < 5; ++i) {
f0100919:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf(" %08x", esp[i]);
f010091e:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100922:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100926:	c7 04 24 17 6e 10 f0 	movl   $0xf0106e17,(%esp)
f010092d:	e8 44 36 00 00       	call   f0103f76 <cprintf>
    	uint32_t eip ;
    	while(ebp){
		eip = *(ebp + 1);
		cprintf("ebp %x eip %x args", ebp, eip);
		uint32_t *esp = ebp + 2;
		for(int i = 0; i < 5; ++i) {
f0100932:	43                   	inc    %ebx
f0100933:	83 fb 05             	cmp    $0x5,%ebx
f0100936:	75 e6                	jne    f010091e <mon_backtrace+0x38>
			cprintf(" %08x", esp[i]);
		}
		cprintf("\n");
f0100938:	c7 04 24 b6 7c 10 f0 	movl   $0xf0107cb6,(%esp)
f010093f:	e8 32 36 00 00       	call   f0103f76 <cprintf>
		struct Eipdebuginfo info;
	
		debuginfo_eip((uintptr_t)eip, &info);
f0100944:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100947:	89 44 24 04          	mov    %eax,0x4(%esp)
f010094b:	89 3c 24             	mov    %edi,(%esp)
f010094e:	e8 82 4a 00 00       	call   f01053d5 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n",
f0100953:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100956:	89 7c 24 14          	mov    %edi,0x14(%esp)
f010095a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010095d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100961:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100964:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010096b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010096f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100972:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100976:	c7 04 24 1d 6e 10 f0 	movl   $0xf0106e1d,(%esp)
f010097d:	e8 f4 35 00 00       	call   f0103f76 <cprintf>
		 	info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name, (uintptr_t)eip - info.eip_fn_addr);
		ebp = (uint32_t*)(*ebp);
f0100982:	8b 36                	mov    (%esi),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	cprintf("Stack backtrace:\n");
	uint32_t *ebp = (uint32_t*)read_ebp();
    	uint32_t eip ;
    	while(ebp){
f0100984:	85 f6                	test   %esi,%esi
f0100986:	0f 85 76 ff ff ff    	jne    f0100902 <mon_backtrace+0x1c>
		ebp = (uint32_t*)(*ebp);
    	}  
    	 

	return 0;
}
f010098c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100991:	83 c4 4c             	add    $0x4c,%esp
f0100994:	5b                   	pop    %ebx
f0100995:	5e                   	pop    %esi
f0100996:	5f                   	pop    %edi
f0100997:	5d                   	pop    %ebp
f0100998:	c3                   	ret    

f0100999 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100999:	55                   	push   %ebp
f010099a:	89 e5                	mov    %esp,%ebp
f010099c:	57                   	push   %edi
f010099d:	56                   	push   %esi
f010099e:	53                   	push   %ebx
f010099f:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009a2:	c7 04 24 94 6f 10 f0 	movl   $0xf0106f94,(%esp)
f01009a9:	e8 c8 35 00 00       	call   f0103f76 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009ae:	c7 04 24 b8 6f 10 f0 	movl   $0xf0106fb8,(%esp)
f01009b5:	e8 bc 35 00 00       	call   f0103f76 <cprintf>

	if (tf != NULL)
f01009ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009be:	74 0b                	je     f01009cb <monitor+0x32>
		print_trapframe(tf);
f01009c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01009c3:	89 04 24             	mov    %eax,(%esp)
f01009c6:	e8 cc 3b 00 00       	call   f0104597 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01009cb:	c7 04 24 2e 6e 10 f0 	movl   $0xf0106e2e,(%esp)
f01009d2:	e8 bd 51 00 00       	call   f0105b94 <readline>
f01009d7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009d9:	85 c0                	test   %eax,%eax
f01009db:	74 ee                	je     f01009cb <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009dd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009e4:	be 00 00 00 00       	mov    $0x0,%esi
f01009e9:	eb 04                	jmp    f01009ef <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009eb:	c6 03 00             	movb   $0x0,(%ebx)
f01009ee:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009ef:	8a 03                	mov    (%ebx),%al
f01009f1:	84 c0                	test   %al,%al
f01009f3:	74 5e                	je     f0100a53 <monitor+0xba>
f01009f5:	0f be c0             	movsbl %al,%eax
f01009f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009fc:	c7 04 24 32 6e 10 f0 	movl   $0xf0106e32,(%esp)
f0100a03:	e8 91 53 00 00       	call   f0105d99 <strchr>
f0100a08:	85 c0                	test   %eax,%eax
f0100a0a:	75 df                	jne    f01009eb <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100a0c:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a0f:	74 42                	je     f0100a53 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a11:	83 fe 0f             	cmp    $0xf,%esi
f0100a14:	75 16                	jne    f0100a2c <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a16:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a1d:	00 
f0100a1e:	c7 04 24 37 6e 10 f0 	movl   $0xf0106e37,(%esp)
f0100a25:	e8 4c 35 00 00       	call   f0103f76 <cprintf>
f0100a2a:	eb 9f                	jmp    f01009cb <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a2c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a30:	46                   	inc    %esi
f0100a31:	eb 01                	jmp    f0100a34 <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a33:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a34:	8a 03                	mov    (%ebx),%al
f0100a36:	84 c0                	test   %al,%al
f0100a38:	74 b5                	je     f01009ef <monitor+0x56>
f0100a3a:	0f be c0             	movsbl %al,%eax
f0100a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a41:	c7 04 24 32 6e 10 f0 	movl   $0xf0106e32,(%esp)
f0100a48:	e8 4c 53 00 00       	call   f0105d99 <strchr>
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	74 e2                	je     f0100a33 <monitor+0x9a>
f0100a51:	eb 9c                	jmp    f01009ef <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100a53:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a5a:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a5b:	85 f6                	test   %esi,%esi
f0100a5d:	0f 84 68 ff ff ff    	je     f01009cb <monitor+0x32>
f0100a63:	bb 20 70 10 f0       	mov    $0xf0107020,%ebx
f0100a68:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a6d:	8b 03                	mov    (%ebx),%eax
f0100a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a73:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a76:	89 04 24             	mov    %eax,(%esp)
f0100a79:	e8 c8 52 00 00       	call   f0105d46 <strcmp>
f0100a7e:	85 c0                	test   %eax,%eax
f0100a80:	75 24                	jne    f0100aa6 <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100a82:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100a85:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a88:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a8c:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a8f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a93:	89 34 24             	mov    %esi,(%esp)
f0100a96:	ff 14 85 28 70 10 f0 	call   *-0xfef8fd8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a9d:	85 c0                	test   %eax,%eax
f0100a9f:	78 26                	js     f0100ac7 <monitor+0x12e>
f0100aa1:	e9 25 ff ff ff       	jmp    f01009cb <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100aa6:	47                   	inc    %edi
f0100aa7:	83 c3 0c             	add    $0xc,%ebx
f0100aaa:	83 ff 03             	cmp    $0x3,%edi
f0100aad:	75 be                	jne    f0100a6d <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aaf:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ab6:	c7 04 24 54 6e 10 f0 	movl   $0xf0106e54,(%esp)
f0100abd:	e8 b4 34 00 00       	call   f0103f76 <cprintf>
f0100ac2:	e9 04 ff ff ff       	jmp    f01009cb <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ac7:	83 c4 5c             	add    $0x5c,%esp
f0100aca:	5b                   	pop    %ebx
f0100acb:	5e                   	pop    %esi
f0100acc:	5f                   	pop    %edi
f0100acd:	5d                   	pop    %ebp
f0100ace:	c3                   	ret    
	...

f0100ad0 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ad0:	55                   	push   %ebp
f0100ad1:	89 e5                	mov    %esp,%ebp
f0100ad3:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ad5:	83 3d 3c 42 22 f0 00 	cmpl   $0x0,0xf022423c
f0100adc:	75 0f                	jne    f0100aed <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ade:	b8 07 70 26 f0       	mov    $0xf0267007,%eax
f0100ae3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ae8:	a3 3c 42 22 f0       	mov    %eax,0xf022423c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n == 0){
f0100aed:	85 d2                	test   %edx,%edx
f0100aef:	75 07                	jne    f0100af8 <boot_alloc+0x28>
		return nextfree;
f0100af1:	a1 3c 42 22 f0       	mov    0xf022423c,%eax
f0100af6:	eb 18                	jmp    f0100b10 <boot_alloc+0x40>
	} else if (n > 0){
		result = nextfree;
f0100af8:	a1 3c 42 22 f0       	mov    0xf022423c,%eax
		nextfree = ROUNDUP((char *)result + n, PGSIZE);
f0100afd:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b04:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b0a:	89 15 3c 42 22 f0    	mov    %edx,0xf022423c
		return result;
	}
	return NULL;
}
f0100b10:	5d                   	pop    %ebp
f0100b11:	c3                   	ret    

f0100b12 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b12:	55                   	push   %ebp
f0100b13:	89 e5                	mov    %esp,%ebp
f0100b15:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b18:	89 d1                	mov    %edx,%ecx
f0100b1a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b1d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b20:	a8 01                	test   $0x1,%al
f0100b22:	74 4d                	je     f0100b71 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b29:	89 c1                	mov    %eax,%ecx
f0100b2b:	c1 e9 0c             	shr    $0xc,%ecx
f0100b2e:	3b 0d 88 4e 22 f0    	cmp    0xf0224e88,%ecx
f0100b34:	72 20                	jb     f0100b56 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b3a:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f0100b41:	f0 
f0100b42:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0100b49:	00 
f0100b4a:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100b51:	e8 ea f4 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b56:	c1 ea 0c             	shr    $0xc,%edx
f0100b59:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b5f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b66:	a8 01                	test   $0x1,%al
f0100b68:	74 0e                	je     f0100b78 <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b6f:	eb 0c                	jmp    f0100b7d <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b76:	eb 05                	jmp    f0100b7d <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100b78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100b7d:	c9                   	leave  
f0100b7e:	c3                   	ret    

f0100b7f <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b7f:	55                   	push   %ebp
f0100b80:	89 e5                	mov    %esp,%ebp
f0100b82:	56                   	push   %esi
f0100b83:	53                   	push   %ebx
f0100b84:	83 ec 10             	sub    $0x10,%esp
f0100b87:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b89:	89 04 24             	mov    %eax,(%esp)
f0100b8c:	e8 9f 32 00 00       	call   f0103e30 <mc146818_read>
f0100b91:	89 c6                	mov    %eax,%esi
f0100b93:	43                   	inc    %ebx
f0100b94:	89 1c 24             	mov    %ebx,(%esp)
f0100b97:	e8 94 32 00 00       	call   f0103e30 <mc146818_read>
f0100b9c:	c1 e0 08             	shl    $0x8,%eax
f0100b9f:	09 f0                	or     %esi,%eax
}
f0100ba1:	83 c4 10             	add    $0x10,%esp
f0100ba4:	5b                   	pop    %ebx
f0100ba5:	5e                   	pop    %esi
f0100ba6:	5d                   	pop    %ebp
f0100ba7:	c3                   	ret    

f0100ba8 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ba8:	55                   	push   %ebp
f0100ba9:	89 e5                	mov    %esp,%ebp
f0100bab:	57                   	push   %edi
f0100bac:	56                   	push   %esi
f0100bad:	53                   	push   %ebx
f0100bae:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb1:	3c 01                	cmp    $0x1,%al
f0100bb3:	19 f6                	sbb    %esi,%esi
f0100bb5:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100bbb:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100bbc:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
f0100bc2:	85 d2                	test   %edx,%edx
f0100bc4:	75 1c                	jne    f0100be2 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100bc6:	c7 44 24 08 44 70 10 	movl   $0xf0107044,0x8(%esp)
f0100bcd:	f0 
f0100bce:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f0100bd5:	00 
f0100bd6:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100bdd:	e8 5e f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100be2:	84 c0                	test   %al,%al
f0100be4:	74 4b                	je     f0100c31 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100be6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100be9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100bef:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bf2:	89 d0                	mov    %edx,%eax
f0100bf4:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0100bfa:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bfd:	c1 e8 16             	shr    $0x16,%eax
f0100c00:	39 c6                	cmp    %eax,%esi
f0100c02:	0f 96 c0             	setbe  %al
f0100c05:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100c08:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100c0c:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c0e:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c12:	8b 12                	mov    (%edx),%edx
f0100c14:	85 d2                	test   %edx,%edx
f0100c16:	75 da                	jne    f0100bf2 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c18:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c21:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c27:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c2c:	a3 40 42 22 f0       	mov    %eax,0xf0224240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c31:	8b 1d 40 42 22 f0    	mov    0xf0224240,%ebx
f0100c37:	eb 63                	jmp    f0100c9c <check_page_free_list+0xf4>
f0100c39:	89 d8                	mov    %ebx,%eax
f0100c3b:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0100c41:	c1 f8 03             	sar    $0x3,%eax
f0100c44:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c47:	89 c2                	mov    %eax,%edx
f0100c49:	c1 ea 16             	shr    $0x16,%edx
f0100c4c:	39 d6                	cmp    %edx,%esi
f0100c4e:	76 4a                	jbe    f0100c9a <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c50:	89 c2                	mov    %eax,%edx
f0100c52:	c1 ea 0c             	shr    $0xc,%edx
f0100c55:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0100c5b:	72 20                	jb     f0100c7d <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c61:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f0100c68:	f0 
f0100c69:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c70:	00 
f0100c71:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c7d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c84:	00 
f0100c85:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c8c:	00 
	return (void *)(pa + KERNBASE);
f0100c8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c92:	89 04 24             	mov    %eax,(%esp)
f0100c95:	e8 34 51 00 00       	call   f0105dce <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c9a:	8b 1b                	mov    (%ebx),%ebx
f0100c9c:	85 db                	test   %ebx,%ebx
f0100c9e:	75 99                	jne    f0100c39 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca5:	e8 26 fe ff ff       	call   f0100ad0 <boot_alloc>
f0100caa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cad:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cb3:	8b 0d 90 4e 22 f0    	mov    0xf0224e90,%ecx
		assert(pp < pages + npages);
f0100cb9:	a1 88 4e 22 f0       	mov    0xf0224e88,%eax
f0100cbe:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cc1:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cc7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cca:	be 00 00 00 00       	mov    $0x0,%esi
f0100ccf:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cd2:	e9 c4 01 00 00       	jmp    f0100e9b <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cd7:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100cda:	73 24                	jae    f0100d00 <check_page_free_list+0x158>
f0100cdc:	c7 44 24 0c bf 79 10 	movl   $0xf01079bf,0xc(%esp)
f0100ce3:	f0 
f0100ce4:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100ceb:	f0 
f0100cec:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0100cf3:	00 
f0100cf4:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100cfb:	e8 40 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d00:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d03:	72 24                	jb     f0100d29 <check_page_free_list+0x181>
f0100d05:	c7 44 24 0c e0 79 10 	movl   $0xf01079e0,0xc(%esp)
f0100d0c:	f0 
f0100d0d:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100d14:	f0 
f0100d15:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f0100d1c:	00 
f0100d1d:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100d24:	e8 17 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d29:	89 d0                	mov    %edx,%eax
f0100d2b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d2e:	a8 07                	test   $0x7,%al
f0100d30:	74 24                	je     f0100d56 <check_page_free_list+0x1ae>
f0100d32:	c7 44 24 0c 68 70 10 	movl   $0xf0107068,0xc(%esp)
f0100d39:	f0 
f0100d3a:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100d41:	f0 
f0100d42:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0100d49:	00 
f0100d4a:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100d51:	e8 ea f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d56:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d59:	c1 e0 0c             	shl    $0xc,%eax
f0100d5c:	75 24                	jne    f0100d82 <check_page_free_list+0x1da>
f0100d5e:	c7 44 24 0c f4 79 10 	movl   $0xf01079f4,0xc(%esp)
f0100d65:	f0 
f0100d66:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100d6d:	f0 
f0100d6e:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0100d75:	00 
f0100d76:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100d7d:	e8 be f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d82:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d87:	75 24                	jne    f0100dad <check_page_free_list+0x205>
f0100d89:	c7 44 24 0c 05 7a 10 	movl   $0xf0107a05,0xc(%esp)
f0100d90:	f0 
f0100d91:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100d98:	f0 
f0100d99:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100da0:	00 
f0100da1:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100da8:	e8 93 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100dad:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100db2:	75 24                	jne    f0100dd8 <check_page_free_list+0x230>
f0100db4:	c7 44 24 0c 9c 70 10 	movl   $0xf010709c,0xc(%esp)
f0100dbb:	f0 
f0100dbc:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100dc3:	f0 
f0100dc4:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0100dcb:	00 
f0100dcc:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100dd3:	e8 68 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dd8:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ddd:	75 24                	jne    f0100e03 <check_page_free_list+0x25b>
f0100ddf:	c7 44 24 0c 1e 7a 10 	movl   $0xf0107a1e,0xc(%esp)
f0100de6:	f0 
f0100de7:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100dee:	f0 
f0100def:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f0100df6:	00 
f0100df7:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100dfe:	e8 3d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e03:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e08:	76 59                	jbe    f0100e63 <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e0a:	89 c1                	mov    %eax,%ecx
f0100e0c:	c1 e9 0c             	shr    $0xc,%ecx
f0100e0f:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100e12:	77 20                	ja     f0100e34 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e14:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e18:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f0100e1f:	f0 
f0100e20:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100e27:	00 
f0100e28:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f0100e2f:	e8 0c f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100e34:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e3a:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100e3d:	76 24                	jbe    f0100e63 <check_page_free_list+0x2bb>
f0100e3f:	c7 44 24 0c c0 70 10 	movl   $0xf01070c0,0xc(%esp)
f0100e46:	f0 
f0100e47:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100e4e:	f0 
f0100e4f:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0100e56:	00 
f0100e57:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100e5e:	e8 dd f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e63:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e68:	75 24                	jne    f0100e8e <check_page_free_list+0x2e6>
f0100e6a:	c7 44 24 0c 38 7a 10 	movl   $0xf0107a38,0xc(%esp)
f0100e71:	f0 
f0100e72:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100e79:	f0 
f0100e7a:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0100e81:	00 
f0100e82:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100e89:	e8 b2 f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100e8e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e93:	77 03                	ja     f0100e98 <check_page_free_list+0x2f0>
			++nfree_basemem;
f0100e95:	46                   	inc    %esi
f0100e96:	eb 01                	jmp    f0100e99 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f0100e98:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e99:	8b 12                	mov    (%edx),%edx
f0100e9b:	85 d2                	test   %edx,%edx
f0100e9d:	0f 85 34 fe ff ff    	jne    f0100cd7 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ea3:	85 f6                	test   %esi,%esi
f0100ea5:	7f 24                	jg     f0100ecb <check_page_free_list+0x323>
f0100ea7:	c7 44 24 0c 55 7a 10 	movl   $0xf0107a55,0xc(%esp)
f0100eae:	f0 
f0100eaf:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100eb6:	f0 
f0100eb7:	c7 44 24 04 eb 02 00 	movl   $0x2eb,0x4(%esp)
f0100ebe:	00 
f0100ebf:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100ec6:	e8 75 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100ecb:	85 db                	test   %ebx,%ebx
f0100ecd:	7f 24                	jg     f0100ef3 <check_page_free_list+0x34b>
f0100ecf:	c7 44 24 0c 67 7a 10 	movl   $0xf0107a67,0xc(%esp)
f0100ed6:	f0 
f0100ed7:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0100ede:	f0 
f0100edf:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0100ee6:	00 
f0100ee7:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100eee:	e8 4d f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ef3:	c7 04 24 08 71 10 f0 	movl   $0xf0107108,(%esp)
f0100efa:	e8 77 30 00 00       	call   f0103f76 <cprintf>
}
f0100eff:	83 c4 4c             	add    $0x4c,%esp
f0100f02:	5b                   	pop    %ebx
f0100f03:	5e                   	pop    %esi
f0100f04:	5f                   	pop    %edi
f0100f05:	5d                   	pop    %ebp
f0100f06:	c3                   	ret    

f0100f07 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f07:	55                   	push   %ebp
f0100f08:	89 e5                	mov    %esp,%ebp
f0100f0a:	56                   	push   %esi
f0100f0b:	53                   	push   %ebx
f0100f0c:	83 ec 10             	sub    $0x10,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100f0f:	be 00 00 00 00       	mov    $0x0,%esi
f0100f14:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f19:	e9 02 01 00 00       	jmp    f0101020 <page_init+0x119>
		if(i == 0){
f0100f1e:	85 db                	test   %ebx,%ebx
f0100f20:	75 16                	jne    f0100f38 <page_init+0x31>
                        pages[i].pp_ref = 1;
f0100f22:	a1 90 4e 22 f0       	mov    0xf0224e90,%eax
f0100f27:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100f2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f33:	e9 e4 00 00 00       	jmp    f010101c <page_init+0x115>
                } else if(i>=1 && i<npages_basemem){
f0100f38:	3b 1d 38 42 22 f0    	cmp    0xf0224238,%ebx
f0100f3e:	73 3d                	jae    f0100f7d <page_init+0x76>
                	if (i == MPENTRY_PADDR/PGSIZE){
f0100f40:	83 fb 07             	cmp    $0x7,%ebx
f0100f43:	75 10                	jne    f0100f55 <page_init+0x4e>
                		pages[i].pp_ref = 1;
f0100f45:	a1 90 4e 22 f0       	mov    0xf0224e90,%eax
f0100f4a:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
                		continue;
f0100f50:	e9 c7 00 00 00       	jmp    f010101c <page_init+0x115>
                	}
                        pages[i].pp_ref = 0;
f0100f55:	89 f0                	mov    %esi,%eax
f0100f57:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
f0100f5d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = page_free_list;
f0100f63:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
f0100f69:	89 10                	mov    %edx,(%eax)
                        page_free_list = &pages[i];
f0100f6b:	89 f0                	mov    %esi,%eax
f0100f6d:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
f0100f73:	a3 40 42 22 f0       	mov    %eax,0xf0224240
f0100f78:	e9 9f 00 00 00       	jmp    f010101c <page_init+0x115>
                } else if(i>=IOPHYSMEM/PGSIZE && i < EXTPHYSMEM/PGSIZE){
f0100f7d:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100f83:	83 f8 5f             	cmp    $0x5f,%eax
f0100f86:	77 16                	ja     f0100f9e <page_init+0x97>
                        pages[i].pp_ref = 1;
f0100f88:	89 f0                	mov    %esi,%eax
f0100f8a:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
f0100f90:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100f96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f9c:	eb 7e                	jmp    f010101c <page_init+0x115>
                } else if(i >= EXTPHYSMEM/ PGSIZE && i < (PADDR(boot_alloc(0)))/PGSIZE){
f0100f9e:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100fa4:	76 53                	jbe    f0100ff9 <page_init+0xf2>
f0100fa6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fab:	e8 20 fb ff ff       	call   f0100ad0 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100fb0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fb5:	77 20                	ja     f0100fd7 <page_init+0xd0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fbb:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0100fc2:	f0 
f0100fc3:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
f0100fca:	00 
f0100fcb:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0100fd2:	e8 69 f0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100fd7:	05 00 00 00 10       	add    $0x10000000,%eax
f0100fdc:	c1 e8 0c             	shr    $0xc,%eax
f0100fdf:	39 c3                	cmp    %eax,%ebx
f0100fe1:	73 16                	jae    f0100ff9 <page_init+0xf2>
                        pages[i].pp_ref = 1;
f0100fe3:	89 f0                	mov    %esi,%eax
f0100fe5:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
f0100feb:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                        pages[i].pp_link = NULL;
f0100ff1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ff7:	eb 23                	jmp    f010101c <page_init+0x115>
                } else{
                        pages[i].pp_ref = 0;
f0100ff9:	89 f0                	mov    %esi,%eax
f0100ffb:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
f0101001:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                        pages[i].pp_link = page_free_list;
f0101007:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
f010100d:	89 10                	mov    %edx,(%eax)
                        page_free_list = &pages[i];
f010100f:	89 f0                	mov    %esi,%eax
f0101011:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
f0101017:	a3 40 42 22 f0       	mov    %eax,0xf0224240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010101c:	43                   	inc    %ebx
f010101d:	83 c6 08             	add    $0x8,%esi
f0101020:	3b 1d 88 4e 22 f0    	cmp    0xf0224e88,%ebx
f0101026:	0f 82 f2 fe ff ff    	jb     f0100f1e <page_init+0x17>
                        pages[i].pp_ref = 0;
                        pages[i].pp_link = page_free_list;
                        page_free_list = &pages[i];
                }
	}
}
f010102c:	83 c4 10             	add    $0x10,%esp
f010102f:	5b                   	pop    %ebx
f0101030:	5e                   	pop    %esi
f0101031:	5d                   	pop    %ebp
f0101032:	c3                   	ret    

f0101033 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101033:	55                   	push   %ebp
f0101034:	89 e5                	mov    %esp,%ebp
f0101036:	53                   	push   %ebx
f0101037:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo *ppt = page_free_list;
f010103a:	8b 1d 40 42 22 f0    	mov    0xf0224240,%ebx
	if (ppt == NULL){
f0101040:	85 db                	test   %ebx,%ebx
f0101042:	75 0e                	jne    f0101052 <page_alloc+0x1f>
		cprintf("There is no memory to allocate\n");
f0101044:	c7 04 24 2c 71 10 f0 	movl   $0xf010712c,(%esp)
f010104b:	e8 26 2f 00 00       	call   f0103f76 <cprintf>
		return NULL;
f0101050:	eb 6b                	jmp    f01010bd <page_alloc+0x8a>
	}
	
	page_free_list = page_free_list->pp_link;
f0101052:	8b 03                	mov    (%ebx),%eax
f0101054:	a3 40 42 22 f0       	mov    %eax,0xf0224240
	ppt->pp_link = NULL;
f0101059:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	
	if (alloc_flags & ALLOC_ZERO){
f010105f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101063:	74 58                	je     f01010bd <page_alloc+0x8a>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101065:	89 d8                	mov    %ebx,%eax
f0101067:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f010106d:	c1 f8 03             	sar    $0x3,%eax
f0101070:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101073:	89 c2                	mov    %eax,%edx
f0101075:	c1 ea 0c             	shr    $0xc,%edx
f0101078:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f010107e:	72 20                	jb     f01010a0 <page_alloc+0x6d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101080:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101084:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f010108b:	f0 
f010108c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101093:	00 
f0101094:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f010109b:	e8 a0 ef ff ff       	call   f0100040 <_panic>
		memset(page2kva(ppt), 0, PGSIZE);
f01010a0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01010a7:	00 
f01010a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01010af:	00 
	return (void *)(pa + KERNBASE);
f01010b0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010b5:	89 04 24             	mov    %eax,(%esp)
f01010b8:	e8 11 4d 00 00       	call   f0105dce <memset>
	}
	
	return ppt;
}
f01010bd:	89 d8                	mov    %ebx,%eax
f01010bf:	83 c4 14             	add    $0x14,%esp
f01010c2:	5b                   	pop    %ebx
f01010c3:	5d                   	pop    %ebp
f01010c4:	c3                   	ret    

f01010c5 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01010c5:	55                   	push   %ebp
f01010c6:	89 e5                	mov    %esp,%ebp
f01010c8:	83 ec 18             	sub    $0x18,%esp
f01010cb:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL){
f01010ce:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010d3:	75 05                	jne    f01010da <page_free+0x15>
f01010d5:	83 38 00             	cmpl   $0x0,(%eax)
f01010d8:	74 1c                	je     f01010f6 <page_free+0x31>
		panic("page_free can free the memory");
f01010da:	c7 44 24 08 78 7a 10 	movl   $0xf0107a78,0x8(%esp)
f01010e1:	f0 
f01010e2:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f01010e9:	00 
f01010ea:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01010f1:	e8 4a ef ff ff       	call   f0100040 <_panic>
		return ;
	} 
	pp->pp_link = page_free_list;
f01010f6:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
f01010fc:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f01010fe:	a3 40 42 22 f0       	mov    %eax,0xf0224240
}
f0101103:	c9                   	leave  
f0101104:	c3                   	ret    

f0101105 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101105:	55                   	push   %ebp
f0101106:	89 e5                	mov    %esp,%ebp
f0101108:	83 ec 18             	sub    $0x18,%esp
f010110b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010110e:	8b 50 04             	mov    0x4(%eax),%edx
f0101111:	4a                   	dec    %edx
f0101112:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101116:	66 85 d2             	test   %dx,%dx
f0101119:	75 08                	jne    f0101123 <page_decref+0x1e>
		page_free(pp);
f010111b:	89 04 24             	mov    %eax,(%esp)
f010111e:	e8 a2 ff ff ff       	call   f01010c5 <page_free>
}
f0101123:	c9                   	leave  
f0101124:	c3                   	ret    

f0101125 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101125:	55                   	push   %ebp
f0101126:	89 e5                	mov    %esp,%ebp
f0101128:	56                   	push   %esi
f0101129:	53                   	push   %ebx
f010112a:	83 ec 10             	sub    $0x10,%esp
f010112d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pde_t *dir = pgdir + PDX(va);
f0101130:	89 f3                	mov    %esi,%ebx
f0101132:	c1 eb 16             	shr    $0x16,%ebx
f0101135:	c1 e3 02             	shl    $0x2,%ebx
f0101138:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*dir & PTE_P) && create == false){
f010113b:	8b 03                	mov    (%ebx),%eax
f010113d:	a8 01                	test   $0x1,%al
f010113f:	0f 85 80 00 00 00    	jne    f01011c5 <pgdir_walk+0xa0>
f0101145:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101149:	0f 84 ba 00 00 00    	je     f0101209 <pgdir_walk+0xe4>
		return NULL;
	} else if (!(*dir & PTE_P) && create != false){
		struct PageInfo *pp = page_alloc(1);
f010114f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101156:	e8 d8 fe ff ff       	call   f0101033 <page_alloc>
		if (pp == NULL){
f010115b:	85 c0                	test   %eax,%eax
f010115d:	0f 84 ad 00 00 00    	je     f0101210 <pgdir_walk+0xeb>
			return NULL;
		} else {
			pp->pp_ref++;
f0101163:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101167:	89 c2                	mov    %eax,%edx
f0101169:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f010116f:	c1 fa 03             	sar    $0x3,%edx
f0101172:	c1 e2 0c             	shl    $0xc,%edx
			*dir = page2pa(pp) | PTE_P | PTE_W | PTE_U;
f0101175:	83 ca 07             	or     $0x7,%edx
f0101178:	89 13                	mov    %edx,(%ebx)
f010117a:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0101180:	c1 f8 03             	sar    $0x3,%eax
f0101183:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101186:	89 c2                	mov    %eax,%edx
f0101188:	c1 ea 0c             	shr    $0xc,%edx
f010118b:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0101191:	72 20                	jb     f01011b3 <pgdir_walk+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101193:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101197:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f010119e:	f0 
f010119f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01011a6:	00 
f01011a7:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f01011ae:	e8 8d ee ff ff       	call   f0100040 <_panic>
			return (pde_t *)page2kva(pp) + PTX(va);
f01011b3:	c1 ee 0a             	shr    $0xa,%esi
f01011b6:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01011bc:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01011c3:	eb 50                	jmp    f0101215 <pgdir_walk+0xf0>
		}
	}
	return (pte_t*)KADDR(PTE_ADDR(*dir)) + PTX(va);
f01011c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011ca:	89 c2                	mov    %eax,%edx
f01011cc:	c1 ea 0c             	shr    $0xc,%edx
f01011cf:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f01011d5:	72 20                	jb     f01011f7 <pgdir_walk+0xd2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011db:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01011e2:	f0 
f01011e3:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
f01011ea:	00 
f01011eb:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01011f2:	e8 49 ee ff ff       	call   f0100040 <_panic>
f01011f7:	c1 ee 0a             	shr    $0xa,%esi
f01011fa:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101200:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101207:	eb 0c                	jmp    f0101215 <pgdir_walk+0xf0>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	pde_t *dir = pgdir + PDX(va);
	if (!(*dir & PTE_P) && create == false){
		return NULL;
f0101209:	b8 00 00 00 00       	mov    $0x0,%eax
f010120e:	eb 05                	jmp    f0101215 <pgdir_walk+0xf0>
	} else if (!(*dir & PTE_P) && create != false){
		struct PageInfo *pp = page_alloc(1);
		if (pp == NULL){
			return NULL;
f0101210:	b8 00 00 00 00       	mov    $0x0,%eax
			*dir = page2pa(pp) | PTE_P | PTE_W | PTE_U;
			return (pde_t *)page2kva(pp) + PTX(va);
		}
	}
	return (pte_t*)KADDR(PTE_ADDR(*dir)) + PTX(va);
}
f0101215:	83 c4 10             	add    $0x10,%esp
f0101218:	5b                   	pop    %ebx
f0101219:	5e                   	pop    %esi
f010121a:	5d                   	pop    %ebp
f010121b:	c3                   	ret    

f010121c <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010121c:	55                   	push   %ebp
f010121d:	89 e5                	mov    %esp,%ebp
f010121f:	57                   	push   %edi
f0101220:	56                   	push   %esi
f0101221:	53                   	push   %ebx
f0101222:	83 ec 2c             	sub    $0x2c,%esp
f0101225:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101228:	89 d3                	mov    %edx,%ebx
f010122a:	8b 7d 08             	mov    0x8(%ebp),%edi
	// Fill this function in
		size_t num = size /PGSIZE;
f010122d:	c1 e9 0c             	shr    $0xc,%ecx
f0101230:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0; i < num; i++){
f0101233:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
		if(pte == NULL){
			panic("run out of memory!");
		} else {
			*pte = pa | perm | PTE_P;
f0101238:	8b 45 0c             	mov    0xc(%ebp),%eax
f010123b:	83 c8 01             	or     $0x1,%eax
f010123e:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
		size_t num = size /PGSIZE;
	for (size_t i = 0; i < num; i++){
f0101241:	eb 4b                	jmp    f010128e <boot_map_region+0x72>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0101243:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010124a:	00 
f010124b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010124f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101252:	89 04 24             	mov    %eax,(%esp)
f0101255:	e8 cb fe ff ff       	call   f0101125 <pgdir_walk>
		if(pte == NULL){
f010125a:	85 c0                	test   %eax,%eax
f010125c:	75 1c                	jne    f010127a <boot_map_region+0x5e>
			panic("run out of memory!");
f010125e:	c7 44 24 08 96 7a 10 	movl   $0xf0107a96,0x8(%esp)
f0101265:	f0 
f0101266:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
f010126d:	00 
f010126e:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101275:	e8 c6 ed ff ff       	call   f0100040 <_panic>
		} else {
			*pte = pa | perm | PTE_P;
f010127a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010127d:	09 fa                	or     %edi,%edx
f010127f:	89 10                	mov    %edx,(%eax)
		}
		pa += PGSIZE;
f0101281:	81 c7 00 10 00 00    	add    $0x1000,%edi
		va += PGSIZE;		 
f0101287:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
		size_t num = size /PGSIZE;
	for (size_t i = 0; i < num; i++){
f010128d:	46                   	inc    %esi
f010128e:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101291:	75 b0                	jne    f0101243 <boot_map_region+0x27>
			*pte = pa | perm | PTE_P;
		}
		pa += PGSIZE;
		va += PGSIZE;		 
	} 	
}
f0101293:	83 c4 2c             	add    $0x2c,%esp
f0101296:	5b                   	pop    %ebx
f0101297:	5e                   	pop    %esi
f0101298:	5f                   	pop    %edi
f0101299:	5d                   	pop    %ebp
f010129a:	c3                   	ret    

f010129b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010129b:	55                   	push   %ebp
f010129c:	89 e5                	mov    %esp,%ebp
f010129e:	53                   	push   %ebx
f010129f:	83 ec 14             	sub    $0x14,%esp
f01012a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01012a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01012ac:	00 
f01012ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01012b7:	89 04 24             	mov    %eax,(%esp)
f01012ba:	e8 66 fe ff ff       	call   f0101125 <pgdir_walk>
	if (pte_store != 0){
f01012bf:	85 db                	test   %ebx,%ebx
f01012c1:	74 02                	je     f01012c5 <page_lookup+0x2a>
		*pte_store = pte;
f01012c3:	89 03                	mov    %eax,(%ebx)
	} 
	if (pte == NULL || !(*pte & PTE_P)){
f01012c5:	85 c0                	test   %eax,%eax
f01012c7:	74 38                	je     f0101301 <page_lookup+0x66>
f01012c9:	8b 00                	mov    (%eax),%eax
f01012cb:	a8 01                	test   $0x1,%al
f01012cd:	74 39                	je     f0101308 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012cf:	c1 e8 0c             	shr    $0xc,%eax
f01012d2:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f01012d8:	72 1c                	jb     f01012f6 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01012da:	c7 44 24 08 4c 71 10 	movl   $0xf010714c,0x8(%esp)
f01012e1:	f0 
f01012e2:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01012e9:	00 
f01012ea:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f01012f1:	e8 4a ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012f6:	c1 e0 03             	shl    $0x3,%eax
f01012f9:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
		return NULL;
	}	
	return pa2page(PTE_ADDR(*pte));
f01012ff:	eb 0c                	jmp    f010130d <page_lookup+0x72>
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if (pte_store != 0){
		*pte_store = pte;
	} 
	if (pte == NULL || !(*pte & PTE_P)){
		return NULL;
f0101301:	b8 00 00 00 00       	mov    $0x0,%eax
f0101306:	eb 05                	jmp    f010130d <page_lookup+0x72>
f0101308:	b8 00 00 00 00       	mov    $0x0,%eax
	}	
	return pa2page(PTE_ADDR(*pte));
}
f010130d:	83 c4 14             	add    $0x14,%esp
f0101310:	5b                   	pop    %ebx
f0101311:	5d                   	pop    %ebp
f0101312:	c3                   	ret    

f0101313 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101313:	55                   	push   %ebp
f0101314:	89 e5                	mov    %esp,%ebp
f0101316:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101319:	e8 de 50 00 00       	call   f01063fc <cpunum>
f010131e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101325:	29 c2                	sub    %eax,%edx
f0101327:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010132a:	83 3c 85 28 50 22 f0 	cmpl   $0x0,-0xfddafd8(,%eax,4)
f0101331:	00 
f0101332:	74 20                	je     f0101354 <tlb_invalidate+0x41>
f0101334:	e8 c3 50 00 00       	call   f01063fc <cpunum>
f0101339:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101340:	29 c2                	sub    %eax,%edx
f0101342:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101345:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f010134c:	8b 55 08             	mov    0x8(%ebp),%edx
f010134f:	39 50 60             	cmp    %edx,0x60(%eax)
f0101352:	75 06                	jne    f010135a <tlb_invalidate+0x47>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101354:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101357:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010135a:	c9                   	leave  
f010135b:	c3                   	ret    

f010135c <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010135c:	55                   	push   %ebp
f010135d:	89 e5                	mov    %esp,%ebp
f010135f:	56                   	push   %esi
f0101360:	53                   	push   %ebx
f0101361:	83 ec 20             	sub    $0x20,%esp
f0101364:	8b 75 08             	mov    0x8(%ebp),%esi
f0101367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte_store;
	struct PageInfo* pp = page_lookup(pgdir, va, &pte_store);
f010136a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010136d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101371:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101375:	89 34 24             	mov    %esi,(%esp)
f0101378:	e8 1e ff ff ff       	call   f010129b <page_lookup>
	if (pp){
f010137d:	85 c0                	test   %eax,%eax
f010137f:	74 1d                	je     f010139e <page_remove+0x42>
		*pte_store = 0;
f0101381:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101384:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(pp);
f010138a:	89 04 24             	mov    %eax,(%esp)
f010138d:	e8 73 fd ff ff       	call   f0101105 <page_decref>
		tlb_invalidate(pgdir, va);
f0101392:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101396:	89 34 24             	mov    %esi,(%esp)
f0101399:	e8 75 ff ff ff       	call   f0101313 <tlb_invalidate>
	}	
}
f010139e:	83 c4 20             	add    $0x20,%esp
f01013a1:	5b                   	pop    %ebx
f01013a2:	5e                   	pop    %esi
f01013a3:	5d                   	pop    %ebp
f01013a4:	c3                   	ret    

f01013a5 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01013a5:	55                   	push   %ebp
f01013a6:	89 e5                	mov    %esp,%ebp
f01013a8:	57                   	push   %edi
f01013a9:	56                   	push   %esi
f01013aa:	53                   	push   %ebx
f01013ab:	83 ec 1c             	sub    $0x1c,%esp
f01013ae:	8b 75 0c             	mov    0xc(%ebp),%esi
f01013b1:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01013b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01013bb:	00 
f01013bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013c3:	89 04 24             	mov    %eax,(%esp)
f01013c6:	e8 5a fd ff ff       	call   f0101125 <pgdir_walk>
f01013cb:	89 c3                	mov    %eax,%ebx
	if (!pte){
f01013cd:	85 c0                	test   %eax,%eax
f01013cf:	74 48                	je     f0101419 <page_insert+0x74>
		return -E_NO_MEM;
	}
	pp->pp_ref++;
f01013d1:	66 ff 46 04          	incw   0x4(%esi)

	if (*pte & PTE_P){
f01013d5:	f6 00 01             	testb  $0x1,(%eax)
f01013d8:	74 1e                	je     f01013f8 <page_insert+0x53>
		page_remove(pgdir, va);
f01013da:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013de:	8b 45 08             	mov    0x8(%ebp),%eax
f01013e1:	89 04 24             	mov    %eax,(%esp)
f01013e4:	e8 73 ff ff ff       	call   f010135c <page_remove>
		tlb_invalidate(pgdir, va);
f01013e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01013f0:	89 04 24             	mov    %eax,(%esp)
f01013f3:	e8 1b ff ff ff       	call   f0101313 <tlb_invalidate>
	} 
	
	*pte = page2pa(pp) | PTE_P | perm;
f01013f8:	8b 55 14             	mov    0x14(%ebp),%edx
f01013fb:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013fe:	2b 35 90 4e 22 f0    	sub    0xf0224e90,%esi
f0101404:	c1 fe 03             	sar    $0x3,%esi
f0101407:	89 f0                	mov    %esi,%eax
f0101409:	c1 e0 0c             	shl    $0xc,%eax
f010140c:	89 d6                	mov    %edx,%esi
f010140e:	09 c6                	or     %eax,%esi
f0101410:	89 33                	mov    %esi,(%ebx)
	return 0;	
f0101412:	b8 00 00 00 00       	mov    $0x0,%eax
f0101417:	eb 05                	jmp    f010141e <page_insert+0x79>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (!pte){
		return -E_NO_MEM;
f0101419:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		tlb_invalidate(pgdir, va);
	} 
	
	*pte = page2pa(pp) | PTE_P | perm;
	return 0;	
}
f010141e:	83 c4 1c             	add    $0x1c,%esp
f0101421:	5b                   	pop    %ebx
f0101422:	5e                   	pop    %esi
f0101423:	5f                   	pop    %edi
f0101424:	5d                   	pop    %ebp
f0101425:	c3                   	ret    

f0101426 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101426:	55                   	push   %ebp
f0101427:	89 e5                	mov    %esp,%ebp
f0101429:	53                   	push   %ebx
f010142a:	83 ec 14             	sub    $0x14,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f010142d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101430:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0101436:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa =ROUNDDOWN(pa, PGSIZE);
	if(base + size >= MMIOLIM)
f010143c:	8b 15 00 93 12 f0    	mov    0xf0129300,%edx
f0101442:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101445:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010144a:	76 1c                	jbe    f0101468 <mmio_map_region+0x42>
		panic("mmio_map_region not implemented");
f010144c:	c7 44 24 08 6c 71 10 	movl   $0xf010716c,0x8(%esp)
f0101453:	f0 
f0101454:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f010145b:	00 
f010145c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101463:	e8 d8 eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PCD | PTE_PWT);  
f0101468:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f010146f:	00 
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
	pa =ROUNDDOWN(pa, PGSIZE);
f0101470:	8b 45 08             	mov    0x8(%ebp),%eax
f0101473:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if(base + size >= MMIOLIM)
		panic("mmio_map_region not implemented");
	boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PCD | PTE_PWT);  
f0101478:	89 04 24             	mov    %eax,(%esp)
f010147b:	89 d9                	mov    %ebx,%ecx
f010147d:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101482:	e8 95 fd ff ff       	call   f010121c <boot_map_region>
	
	uintptr_t curr_base = base;
f0101487:	a1 00 93 12 f0       	mov    0xf0129300,%eax
	base += size;
f010148c:	01 c3                	add    %eax,%ebx
f010148e:	89 1d 00 93 12 f0    	mov    %ebx,0xf0129300
	return (uint32_t *)(curr_base);
}
f0101494:	83 c4 14             	add    $0x14,%esp
f0101497:	5b                   	pop    %ebx
f0101498:	5d                   	pop    %ebp
f0101499:	c3                   	ret    

f010149a <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010149a:	55                   	push   %ebp
f010149b:	89 e5                	mov    %esp,%ebp
f010149d:	57                   	push   %edi
f010149e:	56                   	push   %esi
f010149f:	53                   	push   %ebx
f01014a0:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01014a3:	b8 15 00 00 00       	mov    $0x15,%eax
f01014a8:	e8 d2 f6 ff ff       	call   f0100b7f <nvram_read>
f01014ad:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01014af:	b8 17 00 00 00       	mov    $0x17,%eax
f01014b4:	e8 c6 f6 ff ff       	call   f0100b7f <nvram_read>
f01014b9:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014bb:	b8 34 00 00 00       	mov    $0x34,%eax
f01014c0:	e8 ba f6 ff ff       	call   f0100b7f <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014c5:	c1 e0 06             	shl    $0x6,%eax
f01014c8:	74 08                	je     f01014d2 <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f01014ca:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f01014d0:	eb 0e                	jmp    f01014e0 <mem_init+0x46>
	else if (extmem)
f01014d2:	85 f6                	test   %esi,%esi
f01014d4:	74 08                	je     f01014de <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f01014d6:	81 c6 00 04 00 00    	add    $0x400,%esi
f01014dc:	eb 02                	jmp    f01014e0 <mem_init+0x46>
	else
		totalmem = basemem;
f01014de:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f01014e0:	89 f0                	mov    %esi,%eax
f01014e2:	c1 e8 02             	shr    $0x2,%eax
f01014e5:	a3 88 4e 22 f0       	mov    %eax,0xf0224e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014ea:	89 d8                	mov    %ebx,%eax
f01014ec:	c1 e8 02             	shr    $0x2,%eax
f01014ef:	a3 38 42 22 f0       	mov    %eax,0xf0224238

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014f4:	89 f0                	mov    %esi,%eax
f01014f6:	29 d8                	sub    %ebx,%eax
f01014f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101500:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101504:	c7 04 24 8c 71 10 f0 	movl   $0xf010718c,(%esp)
f010150b:	e8 66 2a 00 00       	call   f0103f76 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101510:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101515:	e8 b6 f5 ff ff       	call   f0100ad0 <boot_alloc>
f010151a:	a3 8c 4e 22 f0       	mov    %eax,0xf0224e8c
	memset(kern_pgdir, 0, PGSIZE);
f010151f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101526:	00 
f0101527:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010152e:	00 
f010152f:	89 04 24             	mov    %eax,(%esp)
f0101532:	e8 97 48 00 00       	call   f0105dce <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101537:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010153c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101541:	77 20                	ja     f0101563 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101543:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101547:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f010154e:	f0 
f010154f:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101556:	00 
f0101557:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010155e:	e8 dd ea ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101563:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101569:	83 ca 05             	or     $0x5,%edx
f010156c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc (npages * sizeof(struct PageInfo));
f0101572:	a1 88 4e 22 f0       	mov    0xf0224e88,%eax
f0101577:	c1 e0 03             	shl    $0x3,%eax
f010157a:	e8 51 f5 ff ff       	call   f0100ad0 <boot_alloc>
f010157f:	a3 90 4e 22 f0       	mov    %eax,0xf0224e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101584:	8b 15 88 4e 22 f0    	mov    0xf0224e88,%edx
f010158a:	c1 e2 03             	shl    $0x3,%edx
f010158d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101591:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101598:	00 
f0101599:	89 04 24             	mov    %eax,(%esp)
f010159c:	e8 2d 48 00 00       	call   f0105dce <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc (NENV * sizeof(struct Env));
f01015a1:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01015a6:	e8 25 f5 ff ff       	call   f0100ad0 <boot_alloc>
f01015ab:	a3 48 42 22 f0       	mov    %eax,0xf0224248
	memset(envs, 0, NENV * sizeof(struct Env));
f01015b0:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f01015b7:	00 
f01015b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015bf:	00 
f01015c0:	89 04 24             	mov    %eax,(%esp)
f01015c3:	e8 06 48 00 00       	call   f0105dce <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015c8:	e8 3a f9 ff ff       	call   f0100f07 <page_init>

	check_page_free_list(1);
f01015cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01015d2:	e8 d1 f5 ff ff       	call   f0100ba8 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015d7:	83 3d 90 4e 22 f0 00 	cmpl   $0x0,0xf0224e90
f01015de:	75 1c                	jne    f01015fc <mem_init+0x162>
		panic("'pages' is a null pointer!");
f01015e0:	c7 44 24 08 a9 7a 10 	movl   $0xf0107aa9,0x8(%esp)
f01015e7:	f0 
f01015e8:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f01015ef:	00 
f01015f0:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01015f7:	e8 44 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015fc:	a1 40 42 22 f0       	mov    0xf0224240,%eax
f0101601:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101606:	eb 03                	jmp    f010160b <mem_init+0x171>
		++nfree;
f0101608:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101609:	8b 00                	mov    (%eax),%eax
f010160b:	85 c0                	test   %eax,%eax
f010160d:	75 f9                	jne    f0101608 <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010160f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101616:	e8 18 fa ff ff       	call   f0101033 <page_alloc>
f010161b:	89 c6                	mov    %eax,%esi
f010161d:	85 c0                	test   %eax,%eax
f010161f:	75 24                	jne    f0101645 <mem_init+0x1ab>
f0101621:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f0101628:	f0 
f0101629:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101630:	f0 
f0101631:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0101638:	00 
f0101639:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101640:	e8 fb e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101645:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010164c:	e8 e2 f9 ff ff       	call   f0101033 <page_alloc>
f0101651:	89 c7                	mov    %eax,%edi
f0101653:	85 c0                	test   %eax,%eax
f0101655:	75 24                	jne    f010167b <mem_init+0x1e1>
f0101657:	c7 44 24 0c da 7a 10 	movl   $0xf0107ada,0xc(%esp)
f010165e:	f0 
f010165f:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101666:	f0 
f0101667:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f010166e:	00 
f010166f:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101676:	e8 c5 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010167b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101682:	e8 ac f9 ff ff       	call   f0101033 <page_alloc>
f0101687:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010168a:	85 c0                	test   %eax,%eax
f010168c:	75 24                	jne    f01016b2 <mem_init+0x218>
f010168e:	c7 44 24 0c f0 7a 10 	movl   $0xf0107af0,0xc(%esp)
f0101695:	f0 
f0101696:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010169d:	f0 
f010169e:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f01016a5:	00 
f01016a6:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01016ad:	e8 8e e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016b2:	39 fe                	cmp    %edi,%esi
f01016b4:	75 24                	jne    f01016da <mem_init+0x240>
f01016b6:	c7 44 24 0c 06 7b 10 	movl   $0xf0107b06,0xc(%esp)
f01016bd:	f0 
f01016be:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01016c5:	f0 
f01016c6:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f01016cd:	00 
f01016ce:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01016d5:	e8 66 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016da:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01016dd:	74 05                	je     f01016e4 <mem_init+0x24a>
f01016df:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01016e2:	75 24                	jne    f0101708 <mem_init+0x26e>
f01016e4:	c7 44 24 0c c8 71 10 	movl   $0xf01071c8,0xc(%esp)
f01016eb:	f0 
f01016ec:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01016f3:	f0 
f01016f4:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f01016fb:	00 
f01016fc:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101703:	e8 38 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101708:	8b 15 90 4e 22 f0    	mov    0xf0224e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010170e:	a1 88 4e 22 f0       	mov    0xf0224e88,%eax
f0101713:	c1 e0 0c             	shl    $0xc,%eax
f0101716:	89 f1                	mov    %esi,%ecx
f0101718:	29 d1                	sub    %edx,%ecx
f010171a:	c1 f9 03             	sar    $0x3,%ecx
f010171d:	c1 e1 0c             	shl    $0xc,%ecx
f0101720:	39 c1                	cmp    %eax,%ecx
f0101722:	72 24                	jb     f0101748 <mem_init+0x2ae>
f0101724:	c7 44 24 0c 18 7b 10 	movl   $0xf0107b18,0xc(%esp)
f010172b:	f0 
f010172c:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101733:	f0 
f0101734:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f010173b:	00 
f010173c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101743:	e8 f8 e8 ff ff       	call   f0100040 <_panic>
f0101748:	89 f9                	mov    %edi,%ecx
f010174a:	29 d1                	sub    %edx,%ecx
f010174c:	c1 f9 03             	sar    $0x3,%ecx
f010174f:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101752:	39 c8                	cmp    %ecx,%eax
f0101754:	77 24                	ja     f010177a <mem_init+0x2e0>
f0101756:	c7 44 24 0c 35 7b 10 	movl   $0xf0107b35,0xc(%esp)
f010175d:	f0 
f010175e:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101765:	f0 
f0101766:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f010176d:	00 
f010176e:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101775:	e8 c6 e8 ff ff       	call   f0100040 <_panic>
f010177a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010177d:	29 d1                	sub    %edx,%ecx
f010177f:	89 ca                	mov    %ecx,%edx
f0101781:	c1 fa 03             	sar    $0x3,%edx
f0101784:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101787:	39 d0                	cmp    %edx,%eax
f0101789:	77 24                	ja     f01017af <mem_init+0x315>
f010178b:	c7 44 24 0c 52 7b 10 	movl   $0xf0107b52,0xc(%esp)
f0101792:	f0 
f0101793:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010179a:	f0 
f010179b:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f01017a2:	00 
f01017a3:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01017aa:	e8 91 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017af:	a1 40 42 22 f0       	mov    0xf0224240,%eax
f01017b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01017b7:	c7 05 40 42 22 f0 00 	movl   $0x0,0xf0224240
f01017be:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017c8:	e8 66 f8 ff ff       	call   f0101033 <page_alloc>
f01017cd:	85 c0                	test   %eax,%eax
f01017cf:	74 24                	je     f01017f5 <mem_init+0x35b>
f01017d1:	c7 44 24 0c 6f 7b 10 	movl   $0xf0107b6f,0xc(%esp)
f01017d8:	f0 
f01017d9:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01017e0:	f0 
f01017e1:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01017e8:	00 
f01017e9:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01017f0:	e8 4b e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01017f5:	89 34 24             	mov    %esi,(%esp)
f01017f8:	e8 c8 f8 ff ff       	call   f01010c5 <page_free>
	page_free(pp1);
f01017fd:	89 3c 24             	mov    %edi,(%esp)
f0101800:	e8 c0 f8 ff ff       	call   f01010c5 <page_free>
	page_free(pp2);
f0101805:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101808:	89 04 24             	mov    %eax,(%esp)
f010180b:	e8 b5 f8 ff ff       	call   f01010c5 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101810:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101817:	e8 17 f8 ff ff       	call   f0101033 <page_alloc>
f010181c:	89 c6                	mov    %eax,%esi
f010181e:	85 c0                	test   %eax,%eax
f0101820:	75 24                	jne    f0101846 <mem_init+0x3ac>
f0101822:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f0101829:	f0 
f010182a:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101831:	f0 
f0101832:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0101839:	00 
f010183a:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101841:	e8 fa e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101846:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010184d:	e8 e1 f7 ff ff       	call   f0101033 <page_alloc>
f0101852:	89 c7                	mov    %eax,%edi
f0101854:	85 c0                	test   %eax,%eax
f0101856:	75 24                	jne    f010187c <mem_init+0x3e2>
f0101858:	c7 44 24 0c da 7a 10 	movl   $0xf0107ada,0xc(%esp)
f010185f:	f0 
f0101860:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101867:	f0 
f0101868:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f010186f:	00 
f0101870:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101877:	e8 c4 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010187c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101883:	e8 ab f7 ff ff       	call   f0101033 <page_alloc>
f0101888:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010188b:	85 c0                	test   %eax,%eax
f010188d:	75 24                	jne    f01018b3 <mem_init+0x419>
f010188f:	c7 44 24 0c f0 7a 10 	movl   $0xf0107af0,0xc(%esp)
f0101896:	f0 
f0101897:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010189e:	f0 
f010189f:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f01018a6:	00 
f01018a7:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01018ae:	e8 8d e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018b3:	39 fe                	cmp    %edi,%esi
f01018b5:	75 24                	jne    f01018db <mem_init+0x441>
f01018b7:	c7 44 24 0c 06 7b 10 	movl   $0xf0107b06,0xc(%esp)
f01018be:	f0 
f01018bf:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01018c6:	f0 
f01018c7:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f01018ce:	00 
f01018cf:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01018d6:	e8 65 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018db:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018de:	74 05                	je     f01018e5 <mem_init+0x44b>
f01018e0:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018e3:	75 24                	jne    f0101909 <mem_init+0x46f>
f01018e5:	c7 44 24 0c c8 71 10 	movl   $0xf01071c8,0xc(%esp)
f01018ec:	f0 
f01018ed:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01018f4:	f0 
f01018f5:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01018fc:	00 
f01018fd:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101904:	e8 37 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101909:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101910:	e8 1e f7 ff ff       	call   f0101033 <page_alloc>
f0101915:	85 c0                	test   %eax,%eax
f0101917:	74 24                	je     f010193d <mem_init+0x4a3>
f0101919:	c7 44 24 0c 6f 7b 10 	movl   $0xf0107b6f,0xc(%esp)
f0101920:	f0 
f0101921:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101928:	f0 
f0101929:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101930:	00 
f0101931:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101938:	e8 03 e7 ff ff       	call   f0100040 <_panic>
f010193d:	89 f0                	mov    %esi,%eax
f010193f:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0101945:	c1 f8 03             	sar    $0x3,%eax
f0101948:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010194b:	89 c2                	mov    %eax,%edx
f010194d:	c1 ea 0c             	shr    $0xc,%edx
f0101950:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0101956:	72 20                	jb     f0101978 <mem_init+0x4de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101958:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010195c:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f0101963:	f0 
f0101964:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010196b:	00 
f010196c:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f0101973:	e8 c8 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101978:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010197f:	00 
f0101980:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101987:	00 
	return (void *)(pa + KERNBASE);
f0101988:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010198d:	89 04 24             	mov    %eax,(%esp)
f0101990:	e8 39 44 00 00       	call   f0105dce <memset>
	page_free(pp0);
f0101995:	89 34 24             	mov    %esi,(%esp)
f0101998:	e8 28 f7 ff ff       	call   f01010c5 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010199d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019a4:	e8 8a f6 ff ff       	call   f0101033 <page_alloc>
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	75 24                	jne    f01019d1 <mem_init+0x537>
f01019ad:	c7 44 24 0c 7e 7b 10 	movl   $0xf0107b7e,0xc(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01019bc:	f0 
f01019bd:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f01019c4:	00 
f01019c5:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01019cc:	e8 6f e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019d1:	39 c6                	cmp    %eax,%esi
f01019d3:	74 24                	je     f01019f9 <mem_init+0x55f>
f01019d5:	c7 44 24 0c 9c 7b 10 	movl   $0xf0107b9c,0xc(%esp)
f01019dc:	f0 
f01019dd:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01019e4:	f0 
f01019e5:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f01019ec:	00 
f01019ed:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01019f4:	e8 47 e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019f9:	89 f2                	mov    %esi,%edx
f01019fb:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0101a01:	c1 fa 03             	sar    $0x3,%edx
f0101a04:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a07:	89 d0                	mov    %edx,%eax
f0101a09:	c1 e8 0c             	shr    $0xc,%eax
f0101a0c:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f0101a12:	72 20                	jb     f0101a34 <mem_init+0x59a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a14:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a18:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f0101a1f:	f0 
f0101a20:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101a27:	00 
f0101a28:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f0101a2f:	e8 0c e6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101a34:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101a3a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a40:	80 38 00             	cmpb   $0x0,(%eax)
f0101a43:	74 24                	je     f0101a69 <mem_init+0x5cf>
f0101a45:	c7 44 24 0c ac 7b 10 	movl   $0xf0107bac,0xc(%esp)
f0101a4c:	f0 
f0101a4d:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101a54:	f0 
f0101a55:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0101a5c:	00 
f0101a5d:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101a64:	e8 d7 e5 ff ff       	call   f0100040 <_panic>
f0101a69:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101a6a:	39 d0                	cmp    %edx,%eax
f0101a6c:	75 d2                	jne    f0101a40 <mem_init+0x5a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101a6e:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a71:	89 15 40 42 22 f0    	mov    %edx,0xf0224240

	// free the pages we took
	page_free(pp0);
f0101a77:	89 34 24             	mov    %esi,(%esp)
f0101a7a:	e8 46 f6 ff ff       	call   f01010c5 <page_free>
	page_free(pp1);
f0101a7f:	89 3c 24             	mov    %edi,(%esp)
f0101a82:	e8 3e f6 ff ff       	call   f01010c5 <page_free>
	page_free(pp2);
f0101a87:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a8a:	89 04 24             	mov    %eax,(%esp)
f0101a8d:	e8 33 f6 ff ff       	call   f01010c5 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a92:	a1 40 42 22 f0       	mov    0xf0224240,%eax
f0101a97:	eb 03                	jmp    f0101a9c <mem_init+0x602>
		--nfree;
f0101a99:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a9a:	8b 00                	mov    (%eax),%eax
f0101a9c:	85 c0                	test   %eax,%eax
f0101a9e:	75 f9                	jne    f0101a99 <mem_init+0x5ff>
		--nfree;
	assert(nfree == 0);
f0101aa0:	85 db                	test   %ebx,%ebx
f0101aa2:	74 24                	je     f0101ac8 <mem_init+0x62e>
f0101aa4:	c7 44 24 0c b6 7b 10 	movl   $0xf0107bb6,0xc(%esp)
f0101aab:	f0 
f0101aac:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101ab3:	f0 
f0101ab4:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101abb:	00 
f0101abc:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101ac3:	e8 78 e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101ac8:	c7 04 24 e8 71 10 f0 	movl   $0xf01071e8,(%esp)
f0101acf:	e8 a2 24 00 00       	call   f0103f76 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ad4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101adb:	e8 53 f5 ff ff       	call   f0101033 <page_alloc>
f0101ae0:	89 c7                	mov    %eax,%edi
f0101ae2:	85 c0                	test   %eax,%eax
f0101ae4:	75 24                	jne    f0101b0a <mem_init+0x670>
f0101ae6:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f0101aed:	f0 
f0101aee:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101af5:	f0 
f0101af6:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0101afd:	00 
f0101afe:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101b05:	e8 36 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b11:	e8 1d f5 ff ff       	call   f0101033 <page_alloc>
f0101b16:	89 c6                	mov    %eax,%esi
f0101b18:	85 c0                	test   %eax,%eax
f0101b1a:	75 24                	jne    f0101b40 <mem_init+0x6a6>
f0101b1c:	c7 44 24 0c da 7a 10 	movl   $0xf0107ada,0xc(%esp)
f0101b23:	f0 
f0101b24:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101b2b:	f0 
f0101b2c:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0101b33:	00 
f0101b34:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101b3b:	e8 00 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b47:	e8 e7 f4 ff ff       	call   f0101033 <page_alloc>
f0101b4c:	89 c3                	mov    %eax,%ebx
f0101b4e:	85 c0                	test   %eax,%eax
f0101b50:	75 24                	jne    f0101b76 <mem_init+0x6dc>
f0101b52:	c7 44 24 0c f0 7a 10 	movl   $0xf0107af0,0xc(%esp)
f0101b59:	f0 
f0101b5a:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101b61:	f0 
f0101b62:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0101b69:	00 
f0101b6a:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101b71:	e8 ca e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b76:	39 f7                	cmp    %esi,%edi
f0101b78:	75 24                	jne    f0101b9e <mem_init+0x704>
f0101b7a:	c7 44 24 0c 06 7b 10 	movl   $0xf0107b06,0xc(%esp)
f0101b81:	f0 
f0101b82:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101b89:	f0 
f0101b8a:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0101b91:	00 
f0101b92:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101b99:	e8 a2 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b9e:	39 c6                	cmp    %eax,%esi
f0101ba0:	74 04                	je     f0101ba6 <mem_init+0x70c>
f0101ba2:	39 c7                	cmp    %eax,%edi
f0101ba4:	75 24                	jne    f0101bca <mem_init+0x730>
f0101ba6:	c7 44 24 0c c8 71 10 	movl   $0xf01071c8,0xc(%esp)
f0101bad:	f0 
f0101bae:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101bb5:	f0 
f0101bb6:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101bbd:	00 
f0101bbe:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101bc5:	e8 76 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bca:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
f0101bd0:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101bd3:	c7 05 40 42 22 f0 00 	movl   $0x0,0xf0224240
f0101bda:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be4:	e8 4a f4 ff ff       	call   f0101033 <page_alloc>
f0101be9:	85 c0                	test   %eax,%eax
f0101beb:	74 24                	je     f0101c11 <mem_init+0x777>
f0101bed:	c7 44 24 0c 6f 7b 10 	movl   $0xf0107b6f,0xc(%esp)
f0101bf4:	f0 
f0101bf5:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101bfc:	f0 
f0101bfd:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0101c04:	00 
f0101c05:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101c0c:	e8 2f e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c14:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c1f:	00 
f0101c20:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101c25:	89 04 24             	mov    %eax,(%esp)
f0101c28:	e8 6e f6 ff ff       	call   f010129b <page_lookup>
f0101c2d:	85 c0                	test   %eax,%eax
f0101c2f:	74 24                	je     f0101c55 <mem_init+0x7bb>
f0101c31:	c7 44 24 0c 08 72 10 	movl   $0xf0107208,0xc(%esp)
f0101c38:	f0 
f0101c39:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101c40:	f0 
f0101c41:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101c48:	00 
f0101c49:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101c50:	e8 eb e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c55:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c5c:	00 
f0101c5d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c64:	00 
f0101c65:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c69:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101c6e:	89 04 24             	mov    %eax,(%esp)
f0101c71:	e8 2f f7 ff ff       	call   f01013a5 <page_insert>
f0101c76:	85 c0                	test   %eax,%eax
f0101c78:	78 24                	js     f0101c9e <mem_init+0x804>
f0101c7a:	c7 44 24 0c 40 72 10 	movl   $0xf0107240,0xc(%esp)
f0101c81:	f0 
f0101c82:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101c89:	f0 
f0101c8a:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0101c91:	00 
f0101c92:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101c99:	e8 a2 e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c9e:	89 3c 24             	mov    %edi,(%esp)
f0101ca1:	e8 1f f4 ff ff       	call   f01010c5 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ca6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cad:	00 
f0101cae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cb5:	00 
f0101cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101cba:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101cbf:	89 04 24             	mov    %eax,(%esp)
f0101cc2:	e8 de f6 ff ff       	call   f01013a5 <page_insert>
f0101cc7:	85 c0                	test   %eax,%eax
f0101cc9:	74 24                	je     f0101cef <mem_init+0x855>
f0101ccb:	c7 44 24 0c 70 72 10 	movl   $0xf0107270,0xc(%esp)
f0101cd2:	f0 
f0101cd3:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101cda:	f0 
f0101cdb:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0101ce2:	00 
f0101ce3:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101cea:	e8 51 e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cef:	8b 0d 8c 4e 22 f0    	mov    0xf0224e8c,%ecx
f0101cf5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101cf8:	a1 90 4e 22 f0       	mov    0xf0224e90,%eax
f0101cfd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101d00:	8b 11                	mov    (%ecx),%edx
f0101d02:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d08:	89 f8                	mov    %edi,%eax
f0101d0a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101d0d:	c1 f8 03             	sar    $0x3,%eax
f0101d10:	c1 e0 0c             	shl    $0xc,%eax
f0101d13:	39 c2                	cmp    %eax,%edx
f0101d15:	74 24                	je     f0101d3b <mem_init+0x8a1>
f0101d17:	c7 44 24 0c a0 72 10 	movl   $0xf01072a0,0xc(%esp)
f0101d1e:	f0 
f0101d1f:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101d26:	f0 
f0101d27:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101d2e:	00 
f0101d2f:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101d36:	e8 05 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d3b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d43:	e8 ca ed ff ff       	call   f0100b12 <check_va2pa>
f0101d48:	89 f2                	mov    %esi,%edx
f0101d4a:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101d4d:	c1 fa 03             	sar    $0x3,%edx
f0101d50:	c1 e2 0c             	shl    $0xc,%edx
f0101d53:	39 d0                	cmp    %edx,%eax
f0101d55:	74 24                	je     f0101d7b <mem_init+0x8e1>
f0101d57:	c7 44 24 0c c8 72 10 	movl   $0xf01072c8,0xc(%esp)
f0101d5e:	f0 
f0101d5f:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101d66:	f0 
f0101d67:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101d6e:	00 
f0101d6f:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101d76:	e8 c5 e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101d7b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d80:	74 24                	je     f0101da6 <mem_init+0x90c>
f0101d82:	c7 44 24 0c c1 7b 10 	movl   $0xf0107bc1,0xc(%esp)
f0101d89:	f0 
f0101d8a:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101d91:	f0 
f0101d92:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101d99:	00 
f0101d9a:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101da1:	e8 9a e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101da6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101dab:	74 24                	je     f0101dd1 <mem_init+0x937>
f0101dad:	c7 44 24 0c d2 7b 10 	movl   $0xf0107bd2,0xc(%esp)
f0101db4:	f0 
f0101db5:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101dbc:	f0 
f0101dbd:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101dc4:	00 
f0101dc5:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101dcc:	e8 6f e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dd1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dd8:	00 
f0101dd9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101de0:	00 
f0101de1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101de5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101de8:	89 14 24             	mov    %edx,(%esp)
f0101deb:	e8 b5 f5 ff ff       	call   f01013a5 <page_insert>
f0101df0:	85 c0                	test   %eax,%eax
f0101df2:	74 24                	je     f0101e18 <mem_init+0x97e>
f0101df4:	c7 44 24 0c f8 72 10 	movl   $0xf01072f8,0xc(%esp)
f0101dfb:	f0 
f0101dfc:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101e03:	f0 
f0101e04:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101e0b:	00 
f0101e0c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101e13:	e8 28 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e18:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e1d:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101e22:	e8 eb ec ff ff       	call   f0100b12 <check_va2pa>
f0101e27:	89 da                	mov    %ebx,%edx
f0101e29:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0101e2f:	c1 fa 03             	sar    $0x3,%edx
f0101e32:	c1 e2 0c             	shl    $0xc,%edx
f0101e35:	39 d0                	cmp    %edx,%eax
f0101e37:	74 24                	je     f0101e5d <mem_init+0x9c3>
f0101e39:	c7 44 24 0c 34 73 10 	movl   $0xf0107334,0xc(%esp)
f0101e40:	f0 
f0101e41:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101e48:	f0 
f0101e49:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101e50:	00 
f0101e51:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101e58:	e8 e3 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e5d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e62:	74 24                	je     f0101e88 <mem_init+0x9ee>
f0101e64:	c7 44 24 0c e3 7b 10 	movl   $0xf0107be3,0xc(%esp)
f0101e6b:	f0 
f0101e6c:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101e73:	f0 
f0101e74:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101e7b:	00 
f0101e7c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101e83:	e8 b8 e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e8f:	e8 9f f1 ff ff       	call   f0101033 <page_alloc>
f0101e94:	85 c0                	test   %eax,%eax
f0101e96:	74 24                	je     f0101ebc <mem_init+0xa22>
f0101e98:	c7 44 24 0c 6f 7b 10 	movl   $0xf0107b6f,0xc(%esp)
f0101e9f:	f0 
f0101ea0:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101ea7:	f0 
f0101ea8:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101eaf:	00 
f0101eb0:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101eb7:	e8 84 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ebc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ec3:	00 
f0101ec4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ecb:	00 
f0101ecc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ed0:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101ed5:	89 04 24             	mov    %eax,(%esp)
f0101ed8:	e8 c8 f4 ff ff       	call   f01013a5 <page_insert>
f0101edd:	85 c0                	test   %eax,%eax
f0101edf:	74 24                	je     f0101f05 <mem_init+0xa6b>
f0101ee1:	c7 44 24 0c f8 72 10 	movl   $0xf01072f8,0xc(%esp)
f0101ee8:	f0 
f0101ee9:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101ef0:	f0 
f0101ef1:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0101ef8:	00 
f0101ef9:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101f00:	e8 3b e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f0a:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101f0f:	e8 fe eb ff ff       	call   f0100b12 <check_va2pa>
f0101f14:	89 da                	mov    %ebx,%edx
f0101f16:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0101f1c:	c1 fa 03             	sar    $0x3,%edx
f0101f1f:	c1 e2 0c             	shl    $0xc,%edx
f0101f22:	39 d0                	cmp    %edx,%eax
f0101f24:	74 24                	je     f0101f4a <mem_init+0xab0>
f0101f26:	c7 44 24 0c 34 73 10 	movl   $0xf0107334,0xc(%esp)
f0101f2d:	f0 
f0101f2e:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101f35:	f0 
f0101f36:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101f3d:	00 
f0101f3e:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101f45:	e8 f6 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f4a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f4f:	74 24                	je     f0101f75 <mem_init+0xadb>
f0101f51:	c7 44 24 0c e3 7b 10 	movl   $0xf0107be3,0xc(%esp)
f0101f58:	f0 
f0101f59:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101f60:	f0 
f0101f61:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101f68:	00 
f0101f69:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101f70:	e8 cb e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f7c:	e8 b2 f0 ff ff       	call   f0101033 <page_alloc>
f0101f81:	85 c0                	test   %eax,%eax
f0101f83:	74 24                	je     f0101fa9 <mem_init+0xb0f>
f0101f85:	c7 44 24 0c 6f 7b 10 	movl   $0xf0107b6f,0xc(%esp)
f0101f8c:	f0 
f0101f8d:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0101f94:	f0 
f0101f95:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101f9c:	00 
f0101f9d:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101fa4:	e8 97 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fa9:	8b 15 8c 4e 22 f0    	mov    0xf0224e8c,%edx
f0101faf:	8b 02                	mov    (%edx),%eax
f0101fb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fb6:	89 c1                	mov    %eax,%ecx
f0101fb8:	c1 e9 0c             	shr    $0xc,%ecx
f0101fbb:	3b 0d 88 4e 22 f0    	cmp    0xf0224e88,%ecx
f0101fc1:	72 20                	jb     f0101fe3 <mem_init+0xb49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101fc7:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f0101fce:	f0 
f0101fcf:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101fd6:	00 
f0101fd7:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0101fde:	e8 5d e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101fe3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fe8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101feb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ff2:	00 
f0101ff3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ffa:	00 
f0101ffb:	89 14 24             	mov    %edx,(%esp)
f0101ffe:	e8 22 f1 ff ff       	call   f0101125 <pgdir_walk>
f0102003:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102006:	83 c2 04             	add    $0x4,%edx
f0102009:	39 d0                	cmp    %edx,%eax
f010200b:	74 24                	je     f0102031 <mem_init+0xb97>
f010200d:	c7 44 24 0c 64 73 10 	movl   $0xf0107364,0xc(%esp)
f0102014:	f0 
f0102015:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010201c:	f0 
f010201d:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102024:	00 
f0102025:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010202c:	e8 0f e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102031:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102038:	00 
f0102039:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102040:	00 
f0102041:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102045:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f010204a:	89 04 24             	mov    %eax,(%esp)
f010204d:	e8 53 f3 ff ff       	call   f01013a5 <page_insert>
f0102052:	85 c0                	test   %eax,%eax
f0102054:	74 24                	je     f010207a <mem_init+0xbe0>
f0102056:	c7 44 24 0c a4 73 10 	movl   $0xf01073a4,0xc(%esp)
f010205d:	f0 
f010205e:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102065:	f0 
f0102066:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010206d:	00 
f010206e:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102075:	e8 c6 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010207a:	8b 0d 8c 4e 22 f0    	mov    0xf0224e8c,%ecx
f0102080:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102083:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102088:	89 c8                	mov    %ecx,%eax
f010208a:	e8 83 ea ff ff       	call   f0100b12 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010208f:	89 da                	mov    %ebx,%edx
f0102091:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0102097:	c1 fa 03             	sar    $0x3,%edx
f010209a:	c1 e2 0c             	shl    $0xc,%edx
f010209d:	39 d0                	cmp    %edx,%eax
f010209f:	74 24                	je     f01020c5 <mem_init+0xc2b>
f01020a1:	c7 44 24 0c 34 73 10 	movl   $0xf0107334,0xc(%esp)
f01020a8:	f0 
f01020a9:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01020b0:	f0 
f01020b1:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f01020b8:	00 
f01020b9:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01020c0:	e8 7b df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01020c5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020ca:	74 24                	je     f01020f0 <mem_init+0xc56>
f01020cc:	c7 44 24 0c e3 7b 10 	movl   $0xf0107be3,0xc(%esp)
f01020d3:	f0 
f01020d4:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01020db:	f0 
f01020dc:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f01020e3:	00 
f01020e4:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01020eb:	e8 50 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01020f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020f7:	00 
f01020f8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020ff:	00 
f0102100:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102103:	89 04 24             	mov    %eax,(%esp)
f0102106:	e8 1a f0 ff ff       	call   f0101125 <pgdir_walk>
f010210b:	f6 00 04             	testb  $0x4,(%eax)
f010210e:	75 24                	jne    f0102134 <mem_init+0xc9a>
f0102110:	c7 44 24 0c e4 73 10 	movl   $0xf01073e4,0xc(%esp)
f0102117:	f0 
f0102118:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010211f:	f0 
f0102120:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0102127:	00 
f0102128:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010212f:	e8 0c df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102134:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102139:	f6 00 04             	testb  $0x4,(%eax)
f010213c:	75 24                	jne    f0102162 <mem_init+0xcc8>
f010213e:	c7 44 24 0c f4 7b 10 	movl   $0xf0107bf4,0xc(%esp)
f0102145:	f0 
f0102146:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010214d:	f0 
f010214e:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0102155:	00 
f0102156:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010215d:	e8 de de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102162:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102169:	00 
f010216a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102171:	00 
f0102172:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102176:	89 04 24             	mov    %eax,(%esp)
f0102179:	e8 27 f2 ff ff       	call   f01013a5 <page_insert>
f010217e:	85 c0                	test   %eax,%eax
f0102180:	74 24                	je     f01021a6 <mem_init+0xd0c>
f0102182:	c7 44 24 0c f8 72 10 	movl   $0xf01072f8,0xc(%esp)
f0102189:	f0 
f010218a:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102191:	f0 
f0102192:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102199:	00 
f010219a:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01021a1:	e8 9a de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01021a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021ad:	00 
f01021ae:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021b5:	00 
f01021b6:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01021bb:	89 04 24             	mov    %eax,(%esp)
f01021be:	e8 62 ef ff ff       	call   f0101125 <pgdir_walk>
f01021c3:	f6 00 02             	testb  $0x2,(%eax)
f01021c6:	75 24                	jne    f01021ec <mem_init+0xd52>
f01021c8:	c7 44 24 0c 18 74 10 	movl   $0xf0107418,0xc(%esp)
f01021cf:	f0 
f01021d0:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01021d7:	f0 
f01021d8:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f01021df:	00 
f01021e0:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01021e7:	e8 54 de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021f3:	00 
f01021f4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021fb:	00 
f01021fc:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102201:	89 04 24             	mov    %eax,(%esp)
f0102204:	e8 1c ef ff ff       	call   f0101125 <pgdir_walk>
f0102209:	f6 00 04             	testb  $0x4,(%eax)
f010220c:	74 24                	je     f0102232 <mem_init+0xd98>
f010220e:	c7 44 24 0c 4c 74 10 	movl   $0xf010744c,0xc(%esp)
f0102215:	f0 
f0102216:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010221d:	f0 
f010221e:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102225:	00 
f0102226:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010222d:	e8 0e de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102232:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102239:	00 
f010223a:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102241:	00 
f0102242:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102246:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f010224b:	89 04 24             	mov    %eax,(%esp)
f010224e:	e8 52 f1 ff ff       	call   f01013a5 <page_insert>
f0102253:	85 c0                	test   %eax,%eax
f0102255:	78 24                	js     f010227b <mem_init+0xde1>
f0102257:	c7 44 24 0c 84 74 10 	movl   $0xf0107484,0xc(%esp)
f010225e:	f0 
f010225f:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102266:	f0 
f0102267:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f010226e:	00 
f010226f:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102276:	e8 c5 dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010227b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102282:	00 
f0102283:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010228a:	00 
f010228b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010228f:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102294:	89 04 24             	mov    %eax,(%esp)
f0102297:	e8 09 f1 ff ff       	call   f01013a5 <page_insert>
f010229c:	85 c0                	test   %eax,%eax
f010229e:	74 24                	je     f01022c4 <mem_init+0xe2a>
f01022a0:	c7 44 24 0c bc 74 10 	movl   $0xf01074bc,0xc(%esp)
f01022a7:	f0 
f01022a8:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01022af:	f0 
f01022b0:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01022b7:	00 
f01022b8:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01022bf:	e8 7c dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01022c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022cb:	00 
f01022cc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022d3:	00 
f01022d4:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01022d9:	89 04 24             	mov    %eax,(%esp)
f01022dc:	e8 44 ee ff ff       	call   f0101125 <pgdir_walk>
f01022e1:	f6 00 04             	testb  $0x4,(%eax)
f01022e4:	74 24                	je     f010230a <mem_init+0xe70>
f01022e6:	c7 44 24 0c 4c 74 10 	movl   $0xf010744c,0xc(%esp)
f01022ed:	f0 
f01022ee:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01022f5:	f0 
f01022f6:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01022fd:	00 
f01022fe:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102305:	e8 36 dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010230a:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f010230f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102312:	ba 00 00 00 00       	mov    $0x0,%edx
f0102317:	e8 f6 e7 ff ff       	call   f0100b12 <check_va2pa>
f010231c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010231f:	89 f0                	mov    %esi,%eax
f0102321:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0102327:	c1 f8 03             	sar    $0x3,%eax
f010232a:	c1 e0 0c             	shl    $0xc,%eax
f010232d:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102330:	74 24                	je     f0102356 <mem_init+0xebc>
f0102332:	c7 44 24 0c f8 74 10 	movl   $0xf01074f8,0xc(%esp)
f0102339:	f0 
f010233a:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102341:	f0 
f0102342:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102349:	00 
f010234a:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102351:	e8 ea dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102356:	ba 00 10 00 00       	mov    $0x1000,%edx
f010235b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010235e:	e8 af e7 ff ff       	call   f0100b12 <check_va2pa>
f0102363:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102366:	74 24                	je     f010238c <mem_init+0xef2>
f0102368:	c7 44 24 0c 24 75 10 	movl   $0xf0107524,0xc(%esp)
f010236f:	f0 
f0102370:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102377:	f0 
f0102378:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f010237f:	00 
f0102380:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102387:	e8 b4 dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010238c:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102391:	74 24                	je     f01023b7 <mem_init+0xf1d>
f0102393:	c7 44 24 0c 0a 7c 10 	movl   $0xf0107c0a,0xc(%esp)
f010239a:	f0 
f010239b:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01023a2:	f0 
f01023a3:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01023aa:	00 
f01023ab:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01023b2:	e8 89 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01023b7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023bc:	74 24                	je     f01023e2 <mem_init+0xf48>
f01023be:	c7 44 24 0c 1b 7c 10 	movl   $0xf0107c1b,0xc(%esp)
f01023c5:	f0 
f01023c6:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01023cd:	f0 
f01023ce:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01023d5:	00 
f01023d6:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01023dd:	e8 5e dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01023e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023e9:	e8 45 ec ff ff       	call   f0101033 <page_alloc>
f01023ee:	85 c0                	test   %eax,%eax
f01023f0:	74 04                	je     f01023f6 <mem_init+0xf5c>
f01023f2:	39 c3                	cmp    %eax,%ebx
f01023f4:	74 24                	je     f010241a <mem_init+0xf80>
f01023f6:	c7 44 24 0c 54 75 10 	movl   $0xf0107554,0xc(%esp)
f01023fd:	f0 
f01023fe:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102405:	f0 
f0102406:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f010240d:	00 
f010240e:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102415:	e8 26 dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010241a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102421:	00 
f0102422:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102427:	89 04 24             	mov    %eax,(%esp)
f010242a:	e8 2d ef ff ff       	call   f010135c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010242f:	8b 15 8c 4e 22 f0    	mov    0xf0224e8c,%edx
f0102435:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102438:	ba 00 00 00 00       	mov    $0x0,%edx
f010243d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102440:	e8 cd e6 ff ff       	call   f0100b12 <check_va2pa>
f0102445:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102448:	74 24                	je     f010246e <mem_init+0xfd4>
f010244a:	c7 44 24 0c 78 75 10 	movl   $0xf0107578,0xc(%esp)
f0102451:	f0 
f0102452:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102459:	f0 
f010245a:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102461:	00 
f0102462:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102469:	e8 d2 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010246e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102473:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102476:	e8 97 e6 ff ff       	call   f0100b12 <check_va2pa>
f010247b:	89 f2                	mov    %esi,%edx
f010247d:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0102483:	c1 fa 03             	sar    $0x3,%edx
f0102486:	c1 e2 0c             	shl    $0xc,%edx
f0102489:	39 d0                	cmp    %edx,%eax
f010248b:	74 24                	je     f01024b1 <mem_init+0x1017>
f010248d:	c7 44 24 0c 24 75 10 	movl   $0xf0107524,0xc(%esp)
f0102494:	f0 
f0102495:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010249c:	f0 
f010249d:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01024a4:	00 
f01024a5:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01024ac:	e8 8f db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01024b1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024b6:	74 24                	je     f01024dc <mem_init+0x1042>
f01024b8:	c7 44 24 0c c1 7b 10 	movl   $0xf0107bc1,0xc(%esp)
f01024bf:	f0 
f01024c0:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01024c7:	f0 
f01024c8:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01024cf:	00 
f01024d0:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01024d7:	e8 64 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01024dc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024e1:	74 24                	je     f0102507 <mem_init+0x106d>
f01024e3:	c7 44 24 0c 1b 7c 10 	movl   $0xf0107c1b,0xc(%esp)
f01024ea:	f0 
f01024eb:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01024f2:	f0 
f01024f3:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01024fa:	00 
f01024fb:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102502:	e8 39 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102507:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010250e:	00 
f010250f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102516:	00 
f0102517:	89 74 24 04          	mov    %esi,0x4(%esp)
f010251b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010251e:	89 0c 24             	mov    %ecx,(%esp)
f0102521:	e8 7f ee ff ff       	call   f01013a5 <page_insert>
f0102526:	85 c0                	test   %eax,%eax
f0102528:	74 24                	je     f010254e <mem_init+0x10b4>
f010252a:	c7 44 24 0c 9c 75 10 	movl   $0xf010759c,0xc(%esp)
f0102531:	f0 
f0102532:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102539:	f0 
f010253a:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102541:	00 
f0102542:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102549:	e8 f2 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010254e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102553:	75 24                	jne    f0102579 <mem_init+0x10df>
f0102555:	c7 44 24 0c 2c 7c 10 	movl   $0xf0107c2c,0xc(%esp)
f010255c:	f0 
f010255d:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102564:	f0 
f0102565:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f010256c:	00 
f010256d:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102574:	e8 c7 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102579:	83 3e 00             	cmpl   $0x0,(%esi)
f010257c:	74 24                	je     f01025a2 <mem_init+0x1108>
f010257e:	c7 44 24 0c 38 7c 10 	movl   $0xf0107c38,0xc(%esp)
f0102585:	f0 
f0102586:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010258d:	f0 
f010258e:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102595:	00 
f0102596:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010259d:	e8 9e da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025a2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025a9:	00 
f01025aa:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01025af:	89 04 24             	mov    %eax,(%esp)
f01025b2:	e8 a5 ed ff ff       	call   f010135c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025b7:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01025bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025bf:	ba 00 00 00 00       	mov    $0x0,%edx
f01025c4:	e8 49 e5 ff ff       	call   f0100b12 <check_va2pa>
f01025c9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025cc:	74 24                	je     f01025f2 <mem_init+0x1158>
f01025ce:	c7 44 24 0c 78 75 10 	movl   $0xf0107578,0xc(%esp)
f01025d5:	f0 
f01025d6:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01025dd:	f0 
f01025de:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f01025e5:	00 
f01025e6:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01025ed:	e8 4e da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01025f2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025fa:	e8 13 e5 ff ff       	call   f0100b12 <check_va2pa>
f01025ff:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102602:	74 24                	je     f0102628 <mem_init+0x118e>
f0102604:	c7 44 24 0c d4 75 10 	movl   $0xf01075d4,0xc(%esp)
f010260b:	f0 
f010260c:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102613:	f0 
f0102614:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f010261b:	00 
f010261c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102623:	e8 18 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102628:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010262d:	74 24                	je     f0102653 <mem_init+0x11b9>
f010262f:	c7 44 24 0c 4d 7c 10 	movl   $0xf0107c4d,0xc(%esp)
f0102636:	f0 
f0102637:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010263e:	f0 
f010263f:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102646:	00 
f0102647:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010264e:	e8 ed d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102653:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102658:	74 24                	je     f010267e <mem_init+0x11e4>
f010265a:	c7 44 24 0c 1b 7c 10 	movl   $0xf0107c1b,0xc(%esp)
f0102661:	f0 
f0102662:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102669:	f0 
f010266a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102671:	00 
f0102672:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102679:	e8 c2 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010267e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102685:	e8 a9 e9 ff ff       	call   f0101033 <page_alloc>
f010268a:	85 c0                	test   %eax,%eax
f010268c:	74 04                	je     f0102692 <mem_init+0x11f8>
f010268e:	39 c6                	cmp    %eax,%esi
f0102690:	74 24                	je     f01026b6 <mem_init+0x121c>
f0102692:	c7 44 24 0c fc 75 10 	movl   $0xf01075fc,0xc(%esp)
f0102699:	f0 
f010269a:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01026a1:	f0 
f01026a2:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01026a9:	00 
f01026aa:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01026b1:	e8 8a d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01026b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026bd:	e8 71 e9 ff ff       	call   f0101033 <page_alloc>
f01026c2:	85 c0                	test   %eax,%eax
f01026c4:	74 24                	je     f01026ea <mem_init+0x1250>
f01026c6:	c7 44 24 0c 6f 7b 10 	movl   $0xf0107b6f,0xc(%esp)
f01026cd:	f0 
f01026ce:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01026d5:	f0 
f01026d6:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01026dd:	00 
f01026de:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01026e5:	e8 56 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026ea:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01026ef:	8b 08                	mov    (%eax),%ecx
f01026f1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026f7:	89 fa                	mov    %edi,%edx
f01026f9:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f01026ff:	c1 fa 03             	sar    $0x3,%edx
f0102702:	c1 e2 0c             	shl    $0xc,%edx
f0102705:	39 d1                	cmp    %edx,%ecx
f0102707:	74 24                	je     f010272d <mem_init+0x1293>
f0102709:	c7 44 24 0c a0 72 10 	movl   $0xf01072a0,0xc(%esp)
f0102710:	f0 
f0102711:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102718:	f0 
f0102719:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102720:	00 
f0102721:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102728:	e8 13 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010272d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102733:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102738:	74 24                	je     f010275e <mem_init+0x12c4>
f010273a:	c7 44 24 0c d2 7b 10 	movl   $0xf0107bd2,0xc(%esp)
f0102741:	f0 
f0102742:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102749:	f0 
f010274a:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102751:	00 
f0102752:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102759:	e8 e2 d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010275e:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102764:	89 3c 24             	mov    %edi,(%esp)
f0102767:	e8 59 e9 ff ff       	call   f01010c5 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010276c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102773:	00 
f0102774:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010277b:	00 
f010277c:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102781:	89 04 24             	mov    %eax,(%esp)
f0102784:	e8 9c e9 ff ff       	call   f0101125 <pgdir_walk>
f0102789:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010278c:	8b 0d 8c 4e 22 f0    	mov    0xf0224e8c,%ecx
f0102792:	8b 51 04             	mov    0x4(%ecx),%edx
f0102795:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010279b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010279e:	8b 15 88 4e 22 f0    	mov    0xf0224e88,%edx
f01027a4:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01027a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01027aa:	c1 ea 0c             	shr    $0xc,%edx
f01027ad:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01027b0:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01027b3:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01027b6:	72 23                	jb     f01027db <mem_init+0x1341>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027b8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01027bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01027bf:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01027c6:	f0 
f01027c7:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01027ce:	00 
f01027cf:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01027d6:	e8 65 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01027de:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01027e4:	39 d0                	cmp    %edx,%eax
f01027e6:	74 24                	je     f010280c <mem_init+0x1372>
f01027e8:	c7 44 24 0c 5e 7c 10 	movl   $0xf0107c5e,0xc(%esp)
f01027ef:	f0 
f01027f0:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01027f7:	f0 
f01027f8:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01027ff:	00 
f0102800:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102807:	e8 34 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010280c:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102813:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102819:	89 f8                	mov    %edi,%eax
f010281b:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0102821:	c1 f8 03             	sar    $0x3,%eax
f0102824:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102827:	89 c1                	mov    %eax,%ecx
f0102829:	c1 e9 0c             	shr    $0xc,%ecx
f010282c:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010282f:	77 20                	ja     f0102851 <mem_init+0x13b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102831:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102835:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f010283c:	f0 
f010283d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102844:	00 
f0102845:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f010284c:	e8 ef d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102851:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102858:	00 
f0102859:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102860:	00 
	return (void *)(pa + KERNBASE);
f0102861:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102866:	89 04 24             	mov    %eax,(%esp)
f0102869:	e8 60 35 00 00       	call   f0105dce <memset>
	page_free(pp0);
f010286e:	89 3c 24             	mov    %edi,(%esp)
f0102871:	e8 4f e8 ff ff       	call   f01010c5 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102876:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010287d:	00 
f010287e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102885:	00 
f0102886:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f010288b:	89 04 24             	mov    %eax,(%esp)
f010288e:	e8 92 e8 ff ff       	call   f0101125 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102893:	89 fa                	mov    %edi,%edx
f0102895:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f010289b:	c1 fa 03             	sar    $0x3,%edx
f010289e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028a1:	89 d0                	mov    %edx,%eax
f01028a3:	c1 e8 0c             	shr    $0xc,%eax
f01028a6:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f01028ac:	72 20                	jb     f01028ce <mem_init+0x1434>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01028b2:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01028b9:	f0 
f01028ba:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01028c1:	00 
f01028c2:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01028ce:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01028d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028d7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01028dd:	f6 00 01             	testb  $0x1,(%eax)
f01028e0:	74 24                	je     f0102906 <mem_init+0x146c>
f01028e2:	c7 44 24 0c 76 7c 10 	movl   $0xf0107c76,0xc(%esp)
f01028e9:	f0 
f01028ea:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01028f1:	f0 
f01028f2:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f01028f9:	00 
f01028fa:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102901:	e8 3a d7 ff ff       	call   f0100040 <_panic>
f0102906:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102909:	39 d0                	cmp    %edx,%eax
f010290b:	75 d0                	jne    f01028dd <mem_init+0x1443>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010290d:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102912:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102918:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010291e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102921:	89 0d 40 42 22 f0    	mov    %ecx,0xf0224240

	// free the pages we took
	page_free(pp0);
f0102927:	89 3c 24             	mov    %edi,(%esp)
f010292a:	e8 96 e7 ff ff       	call   f01010c5 <page_free>
	page_free(pp1);
f010292f:	89 34 24             	mov    %esi,(%esp)
f0102932:	e8 8e e7 ff ff       	call   f01010c5 <page_free>
	page_free(pp2);
f0102937:	89 1c 24             	mov    %ebx,(%esp)
f010293a:	e8 86 e7 ff ff       	call   f01010c5 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010293f:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102946:	00 
f0102947:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010294e:	e8 d3 ea ff ff       	call   f0101426 <mmio_map_region>
f0102953:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102955:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010295c:	00 
f010295d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102964:	e8 bd ea ff ff       	call   f0101426 <mmio_map_region>
f0102969:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010296b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102971:	76 0d                	jbe    f0102980 <mem_init+0x14e6>
f0102973:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102979:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010297e:	76 24                	jbe    f01029a4 <mem_init+0x150a>
f0102980:	c7 44 24 0c 20 76 10 	movl   $0xf0107620,0xc(%esp)
f0102987:	f0 
f0102988:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010298f:	f0 
f0102990:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0102997:	00 
f0102998:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010299f:	e8 9c d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01029a4:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01029aa:	76 0e                	jbe    f01029ba <mem_init+0x1520>
f01029ac:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01029b2:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01029b8:	76 24                	jbe    f01029de <mem_init+0x1544>
f01029ba:	c7 44 24 0c 48 76 10 	movl   $0xf0107648,0xc(%esp)
f01029c1:	f0 
f01029c2:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01029c9:	f0 
f01029ca:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f01029d1:	00 
f01029d2:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01029d9:	e8 62 d6 ff ff       	call   f0100040 <_panic>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01029de:	89 da                	mov    %ebx,%edx
f01029e0:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01029e2:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01029e8:	74 24                	je     f0102a0e <mem_init+0x1574>
f01029ea:	c7 44 24 0c 70 76 10 	movl   $0xf0107670,0xc(%esp)
f01029f1:	f0 
f01029f2:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01029f9:	f0 
f01029fa:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f0102a01:	00 
f0102a02:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102a09:	e8 32 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102a0e:	39 c6                	cmp    %eax,%esi
f0102a10:	73 24                	jae    f0102a36 <mem_init+0x159c>
f0102a12:	c7 44 24 0c 8d 7c 10 	movl   $0xf0107c8d,0xc(%esp)
f0102a19:	f0 
f0102a1a:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102a21:	f0 
f0102a22:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102a29:	00 
f0102a2a:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102a31:	e8 0a d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102a36:	8b 3d 8c 4e 22 f0    	mov    0xf0224e8c,%edi
f0102a3c:	89 da                	mov    %ebx,%edx
f0102a3e:	89 f8                	mov    %edi,%eax
f0102a40:	e8 cd e0 ff ff       	call   f0100b12 <check_va2pa>
f0102a45:	85 c0                	test   %eax,%eax
f0102a47:	74 24                	je     f0102a6d <mem_init+0x15d3>
f0102a49:	c7 44 24 0c 98 76 10 	movl   $0xf0107698,0xc(%esp)
f0102a50:	f0 
f0102a51:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102a58:	f0 
f0102a59:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102a60:	00 
f0102a61:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102a68:	e8 d3 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102a6d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102a73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a76:	89 c2                	mov    %eax,%edx
f0102a78:	89 f8                	mov    %edi,%eax
f0102a7a:	e8 93 e0 ff ff       	call   f0100b12 <check_va2pa>
f0102a7f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a84:	74 24                	je     f0102aaa <mem_init+0x1610>
f0102a86:	c7 44 24 0c bc 76 10 	movl   $0xf01076bc,0xc(%esp)
f0102a8d:	f0 
f0102a8e:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102a95:	f0 
f0102a96:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102a9d:	00 
f0102a9e:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102aa5:	e8 96 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102aaa:	89 f2                	mov    %esi,%edx
f0102aac:	89 f8                	mov    %edi,%eax
f0102aae:	e8 5f e0 ff ff       	call   f0100b12 <check_va2pa>
f0102ab3:	85 c0                	test   %eax,%eax
f0102ab5:	74 24                	je     f0102adb <mem_init+0x1641>
f0102ab7:	c7 44 24 0c ec 76 10 	movl   $0xf01076ec,0xc(%esp)
f0102abe:	f0 
f0102abf:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102ac6:	f0 
f0102ac7:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0102ace:	00 
f0102acf:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102ad6:	e8 65 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102adb:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102ae1:	89 f8                	mov    %edi,%eax
f0102ae3:	e8 2a e0 ff ff       	call   f0100b12 <check_va2pa>
f0102ae8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102aeb:	74 24                	je     f0102b11 <mem_init+0x1677>
f0102aed:	c7 44 24 0c 10 77 10 	movl   $0xf0107710,0xc(%esp)
f0102af4:	f0 
f0102af5:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102afc:	f0 
f0102afd:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102b04:	00 
f0102b05:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102b0c:	e8 2f d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102b11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b18:	00 
f0102b19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b1d:	89 3c 24             	mov    %edi,(%esp)
f0102b20:	e8 00 e6 ff ff       	call   f0101125 <pgdir_walk>
f0102b25:	f6 00 1a             	testb  $0x1a,(%eax)
f0102b28:	75 24                	jne    f0102b4e <mem_init+0x16b4>
f0102b2a:	c7 44 24 0c 3c 77 10 	movl   $0xf010773c,0xc(%esp)
f0102b31:	f0 
f0102b32:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102b39:	f0 
f0102b3a:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102b41:	00 
f0102b42:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102b49:	e8 f2 d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102b4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b55:	00 
f0102b56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b5a:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102b5f:	89 04 24             	mov    %eax,(%esp)
f0102b62:	e8 be e5 ff ff       	call   f0101125 <pgdir_walk>
f0102b67:	f6 00 04             	testb  $0x4,(%eax)
f0102b6a:	74 24                	je     f0102b90 <mem_init+0x16f6>
f0102b6c:	c7 44 24 0c 80 77 10 	movl   $0xf0107780,0xc(%esp)
f0102b73:	f0 
f0102b74:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102b7b:	f0 
f0102b7c:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102b83:	00 
f0102b84:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102b8b:	e8 b0 d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102b90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b97:	00 
f0102b98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b9c:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102ba1:	89 04 24             	mov    %eax,(%esp)
f0102ba4:	e8 7c e5 ff ff       	call   f0101125 <pgdir_walk>
f0102ba9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102baf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bb6:	00 
f0102bb7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102bba:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102bbe:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102bc3:	89 04 24             	mov    %eax,(%esp)
f0102bc6:	e8 5a e5 ff ff       	call   f0101125 <pgdir_walk>
f0102bcb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102bd1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bd8:	00 
f0102bd9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102bdd:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102be2:	89 04 24             	mov    %eax,(%esp)
f0102be5:	e8 3b e5 ff ff       	call   f0101125 <pgdir_walk>
f0102bea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102bf0:	c7 04 24 9f 7c 10 f0 	movl   $0xf0107c9f,(%esp)
f0102bf7:	e8 7a 13 00 00       	call   f0103f76 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U| PTE_P);
f0102bfc:	a1 90 4e 22 f0       	mov    0xf0224e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c01:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c06:	77 20                	ja     f0102c28 <mem_init+0x178e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c08:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c0c:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0102c13:	f0 
f0102c14:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0102c1b:	00 
f0102c1c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102c23:	e8 18 d4 ff ff       	call   f0100040 <_panic>
f0102c28:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c2f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c30:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c35:	89 04 24             	mov    %eax,(%esp)
f0102c38:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102c3d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c42:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102c47:	e8 d0 e5 ff ff       	call   f010121c <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U| PTE_P);
f0102c4c:	a1 48 42 22 f0       	mov    0xf0224248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c51:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c56:	77 20                	ja     f0102c78 <mem_init+0x17de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c58:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c5c:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0102c63:	f0 
f0102c64:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102c6b:	00 
f0102c6c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102c73:	e8 c8 d3 ff ff       	call   f0100040 <_panic>
f0102c78:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c7f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c80:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c85:	89 04 24             	mov    %eax,(%esp)
f0102c88:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102c8d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c92:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102c97:	e8 80 e5 ff ff       	call   f010121c <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c9c:	b8 00 f0 11 f0       	mov    $0xf011f000,%eax
f0102ca1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ca6:	77 20                	ja     f0102cc8 <mem_init+0x182e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ca8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cac:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0102cb3:	f0 
f0102cb4:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
f0102cbb:	00 
f0102cbc:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102cc3:	e8 78 d3 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W| PTE_P);
f0102cc8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102ccf:	00 
f0102cd0:	c7 04 24 00 f0 11 00 	movl   $0x11f000,(%esp)
f0102cd7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cdc:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102ce1:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102ce6:	e8 31 e5 ff ff       	call   f010121c <boot_map_region>
f0102ceb:	c7 45 cc 00 60 22 f0 	movl   $0xf0226000,-0x34(%ebp)
f0102cf2:	bb 00 60 22 f0       	mov    $0xf0226000,%ebx
f0102cf7:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cfc:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d02:	77 20                	ja     f0102d24 <mem_init+0x188a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d04:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102d08:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0102d0f:	f0 
f0102d10:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0102d17:	00 
f0102d18:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102d1f:	e8 1c d3 ff ff       	call   f0100040 <_panic>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	for(int i = 0; i<NCPU; i++){
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE,
f0102d24:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d2b:	00 
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d2c:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	for(int i = 0; i<NCPU; i++){
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE,
f0102d32:	89 04 24             	mov    %eax,(%esp)
f0102d35:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d3a:	89 f2                	mov    %esi,%edx
f0102d3c:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102d41:	e8 d6 e4 ff ff       	call   f010121c <boot_map_region>
f0102d46:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d4c:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	for(int i = 0; i<NCPU; i++){
f0102d52:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102d58:	75 a2                	jne    f0102cfc <mem_init+0x1862>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();


	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W| PTE_P);
f0102d5a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d61:	00 
f0102d62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d69:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102d6e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d73:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102d78:	e8 9f e4 ff ff       	call   f010121c <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d7d:	8b 1d 8c 4e 22 f0    	mov    0xf0224e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d83:	8b 0d 88 4e 22 f0    	mov    0xf0224e88,%ecx
f0102d89:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102d8c:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102d93:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102d99:	be 00 00 00 00       	mov    $0x0,%esi
f0102d9e:	eb 70                	jmp    f0102e10 <mem_init+0x1976>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102da0:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102da6:	89 d8                	mov    %ebx,%eax
f0102da8:	e8 65 dd ff ff       	call   f0100b12 <check_va2pa>
f0102dad:	8b 15 90 4e 22 f0    	mov    0xf0224e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102db3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102db9:	77 20                	ja     f0102ddb <mem_init+0x1941>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dbb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102dbf:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0102dc6:	f0 
f0102dc7:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0102dce:	00 
f0102dcf:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102dd6:	e8 65 d2 ff ff       	call   f0100040 <_panic>
f0102ddb:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102de2:	39 d0                	cmp    %edx,%eax
f0102de4:	74 24                	je     f0102e0a <mem_init+0x1970>
f0102de6:	c7 44 24 0c b4 77 10 	movl   $0xf01077b4,0xc(%esp)
f0102ded:	f0 
f0102dee:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102df5:	f0 
f0102df6:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0102dfd:	00 
f0102dfe:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102e05:	e8 36 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e0a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e10:	39 f7                	cmp    %esi,%edi
f0102e12:	77 8c                	ja     f0102da0 <mem_init+0x1906>
f0102e14:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e19:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e1f:	89 d8                	mov    %ebx,%eax
f0102e21:	e8 ec dc ff ff       	call   f0100b12 <check_va2pa>
f0102e26:	8b 15 48 42 22 f0    	mov    0xf0224248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e2c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102e32:	77 20                	ja     f0102e54 <mem_init+0x19ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e34:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e38:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0102e3f:	f0 
f0102e40:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102e47:	00 
f0102e48:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102e4f:	e8 ec d1 ff ff       	call   f0100040 <_panic>
f0102e54:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102e5b:	39 d0                	cmp    %edx,%eax
f0102e5d:	74 24                	je     f0102e83 <mem_init+0x19e9>
f0102e5f:	c7 44 24 0c e8 77 10 	movl   $0xf01077e8,0xc(%esp)
f0102e66:	f0 
f0102e67:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102e6e:	f0 
f0102e6f:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102e76:	00 
f0102e77:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102e7e:	e8 bd d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e83:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e89:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102e8f:	75 88                	jne    f0102e19 <mem_init+0x197f>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e91:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e94:	c1 e7 0c             	shl    $0xc,%edi
f0102e97:	be 00 00 00 00       	mov    $0x0,%esi
f0102e9c:	eb 3b                	jmp    f0102ed9 <mem_init+0x1a3f>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e9e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102ea4:	89 d8                	mov    %ebx,%eax
f0102ea6:	e8 67 dc ff ff       	call   f0100b12 <check_va2pa>
f0102eab:	39 c6                	cmp    %eax,%esi
f0102ead:	74 24                	je     f0102ed3 <mem_init+0x1a39>
f0102eaf:	c7 44 24 0c 1c 78 10 	movl   $0xf010781c,0xc(%esp)
f0102eb6:	f0 
f0102eb7:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102ebe:	f0 
f0102ebf:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0102ec6:	00 
f0102ec7:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102ece:	e8 6d d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ed3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ed9:	39 fe                	cmp    %edi,%esi
f0102edb:	72 c1                	jb     f0102e9e <mem_init+0x1a04>
f0102edd:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102ee2:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ee5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102ee8:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102eeb:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ef1:	89 c6                	mov    %eax,%esi
f0102ef3:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102ef9:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0102eff:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f02:	89 da                	mov    %ebx,%edx
f0102f04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f07:	e8 06 dc ff ff       	call   f0100b12 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f0c:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102f13:	77 23                	ja     f0102f38 <mem_init+0x1a9e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f15:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f18:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102f1c:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0102f23:	f0 
f0102f24:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102f2b:	00 
f0102f2c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102f33:	e8 08 d1 ff ff       	call   f0100040 <_panic>
f0102f38:	39 f0                	cmp    %esi,%eax
f0102f3a:	74 24                	je     f0102f60 <mem_init+0x1ac6>
f0102f3c:	c7 44 24 0c 44 78 10 	movl   $0xf0107844,0xc(%esp)
f0102f43:	f0 
f0102f44:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102f4b:	f0 
f0102f4c:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102f53:	00 
f0102f54:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102f5b:	e8 e0 d0 ff ff       	call   f0100040 <_panic>
f0102f60:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f66:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f6c:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f6f:	0f 85 55 05 00 00    	jne    f01034ca <mem_init+0x2030>
f0102f75:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f7a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f7d:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102f80:	89 f0                	mov    %esi,%eax
f0102f82:	e8 8b db ff ff       	call   f0100b12 <check_va2pa>
f0102f87:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f8a:	74 24                	je     f0102fb0 <mem_init+0x1b16>
f0102f8c:	c7 44 24 0c 8c 78 10 	movl   $0xf010788c,0xc(%esp)
f0102f93:	f0 
f0102f94:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0102f9b:	f0 
f0102f9c:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102fa3:	00 
f0102fa4:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0102fab:	e8 90 d0 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102fb0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fb6:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102fbc:	75 bf                	jne    f0102f7d <mem_init+0x1ae3>
f0102fbe:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102fc4:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102fcb:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102fd1:	0f 85 0e ff ff ff    	jne    f0102ee5 <mem_init+0x1a4b>
f0102fd7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fda:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102fdf:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102fe5:	83 fa 04             	cmp    $0x4,%edx
f0102fe8:	77 2e                	ja     f0103018 <mem_init+0x1b7e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102fea:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102fee:	0f 85 aa 00 00 00    	jne    f010309e <mem_init+0x1c04>
f0102ff4:	c7 44 24 0c b8 7c 10 	movl   $0xf0107cb8,0xc(%esp)
f0102ffb:	f0 
f0102ffc:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103003:	f0 
f0103004:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f010300b:	00 
f010300c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0103013:	e8 28 d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103018:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010301d:	76 55                	jbe    f0103074 <mem_init+0x1bda>
				assert(pgdir[i] & PTE_P);
f010301f:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0103022:	f6 c2 01             	test   $0x1,%dl
f0103025:	75 24                	jne    f010304b <mem_init+0x1bb1>
f0103027:	c7 44 24 0c b8 7c 10 	movl   $0xf0107cb8,0xc(%esp)
f010302e:	f0 
f010302f:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103036:	f0 
f0103037:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f010303e:	00 
f010303f:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0103046:	e8 f5 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010304b:	f6 c2 02             	test   $0x2,%dl
f010304e:	75 4e                	jne    f010309e <mem_init+0x1c04>
f0103050:	c7 44 24 0c c9 7c 10 	movl   $0xf0107cc9,0xc(%esp)
f0103057:	f0 
f0103058:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010305f:	f0 
f0103060:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0103067:	00 
f0103068:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010306f:	e8 cc cf ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103074:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103078:	74 24                	je     f010309e <mem_init+0x1c04>
f010307a:	c7 44 24 0c da 7c 10 	movl   $0xf0107cda,0xc(%esp)
f0103081:	f0 
f0103082:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103089:	f0 
f010308a:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0103091:	00 
f0103092:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0103099:	e8 a2 cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010309e:	40                   	inc    %eax
f010309f:	3d 00 04 00 00       	cmp    $0x400,%eax
f01030a4:	0f 85 35 ff ff ff    	jne    f0102fdf <mem_init+0x1b45>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01030aa:	c7 04 24 b0 78 10 f0 	movl   $0xf01078b0,(%esp)
f01030b1:	e8 c0 0e 00 00       	call   f0103f76 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01030b6:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030c0:	77 20                	ja     f01030e2 <mem_init+0x1c48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030c6:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f01030cd:	f0 
f01030ce:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f01030d5:	00 
f01030d6:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01030dd:	e8 5e cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030e2:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01030e7:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01030ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01030ef:	e8 b4 da ff ff       	call   f0100ba8 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01030f4:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01030f7:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01030fc:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01030ff:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103102:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103109:	e8 25 df ff ff       	call   f0101033 <page_alloc>
f010310e:	89 c6                	mov    %eax,%esi
f0103110:	85 c0                	test   %eax,%eax
f0103112:	75 24                	jne    f0103138 <mem_init+0x1c9e>
f0103114:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f010311b:	f0 
f010311c:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103123:	f0 
f0103124:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f010312b:	00 
f010312c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0103133:	e8 08 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0103138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010313f:	e8 ef de ff ff       	call   f0101033 <page_alloc>
f0103144:	89 c7                	mov    %eax,%edi
f0103146:	85 c0                	test   %eax,%eax
f0103148:	75 24                	jne    f010316e <mem_init+0x1cd4>
f010314a:	c7 44 24 0c da 7a 10 	movl   $0xf0107ada,0xc(%esp)
f0103151:	f0 
f0103152:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103159:	f0 
f010315a:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0103161:	00 
f0103162:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0103169:	e8 d2 ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010316e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103175:	e8 b9 de ff ff       	call   f0101033 <page_alloc>
f010317a:	89 c3                	mov    %eax,%ebx
f010317c:	85 c0                	test   %eax,%eax
f010317e:	75 24                	jne    f01031a4 <mem_init+0x1d0a>
f0103180:	c7 44 24 0c f0 7a 10 	movl   $0xf0107af0,0xc(%esp)
f0103187:	f0 
f0103188:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010318f:	f0 
f0103190:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f0103197:	00 
f0103198:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010319f:	e8 9c ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01031a4:	89 34 24             	mov    %esi,(%esp)
f01031a7:	e8 19 df ff ff       	call   f01010c5 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01031ac:	89 f8                	mov    %edi,%eax
f01031ae:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f01031b4:	c1 f8 03             	sar    $0x3,%eax
f01031b7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031ba:	89 c2                	mov    %eax,%edx
f01031bc:	c1 ea 0c             	shr    $0xc,%edx
f01031bf:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f01031c5:	72 20                	jb     f01031e7 <mem_init+0x1d4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031cb:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01031d2:	f0 
f01031d3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031da:	00 
f01031db:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f01031e2:	e8 59 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01031e7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031ee:	00 
f01031ef:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01031f6:	00 
	return (void *)(pa + KERNBASE);
f01031f7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031fc:	89 04 24             	mov    %eax,(%esp)
f01031ff:	e8 ca 2b 00 00       	call   f0105dce <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103204:	89 d8                	mov    %ebx,%eax
f0103206:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f010320c:	c1 f8 03             	sar    $0x3,%eax
f010320f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103212:	89 c2                	mov    %eax,%edx
f0103214:	c1 ea 0c             	shr    $0xc,%edx
f0103217:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f010321d:	72 20                	jb     f010323f <mem_init+0x1da5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010321f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103223:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f010322a:	f0 
f010322b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103232:	00 
f0103233:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f010323a:	e8 01 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010323f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103246:	00 
f0103247:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010324e:	00 
	return (void *)(pa + KERNBASE);
f010324f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103254:	89 04 24             	mov    %eax,(%esp)
f0103257:	e8 72 2b 00 00       	call   f0105dce <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010325c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103263:	00 
f0103264:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010326b:	00 
f010326c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103270:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0103275:	89 04 24             	mov    %eax,(%esp)
f0103278:	e8 28 e1 ff ff       	call   f01013a5 <page_insert>
	assert(pp1->pp_ref == 1);
f010327d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103282:	74 24                	je     f01032a8 <mem_init+0x1e0e>
f0103284:	c7 44 24 0c c1 7b 10 	movl   $0xf0107bc1,0xc(%esp)
f010328b:	f0 
f010328c:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103293:	f0 
f0103294:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f010329b:	00 
f010329c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01032a3:	e8 98 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01032a8:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01032af:	01 01 01 
f01032b2:	74 24                	je     f01032d8 <mem_init+0x1e3e>
f01032b4:	c7 44 24 0c d0 78 10 	movl   $0xf01078d0,0xc(%esp)
f01032bb:	f0 
f01032bc:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01032c3:	f0 
f01032c4:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f01032cb:	00 
f01032cc:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01032d3:	e8 68 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01032d8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032df:	00 
f01032e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032e7:	00 
f01032e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032ec:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01032f1:	89 04 24             	mov    %eax,(%esp)
f01032f4:	e8 ac e0 ff ff       	call   f01013a5 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032f9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103300:	02 02 02 
f0103303:	74 24                	je     f0103329 <mem_init+0x1e8f>
f0103305:	c7 44 24 0c f4 78 10 	movl   $0xf01078f4,0xc(%esp)
f010330c:	f0 
f010330d:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103314:	f0 
f0103315:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f010331c:	00 
f010331d:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0103324:	e8 17 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103329:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010332e:	74 24                	je     f0103354 <mem_init+0x1eba>
f0103330:	c7 44 24 0c e3 7b 10 	movl   $0xf0107be3,0xc(%esp)
f0103337:	f0 
f0103338:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010333f:	f0 
f0103340:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0103347:	00 
f0103348:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010334f:	e8 ec cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103354:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103359:	74 24                	je     f010337f <mem_init+0x1ee5>
f010335b:	c7 44 24 0c 4d 7c 10 	movl   $0xf0107c4d,0xc(%esp)
f0103362:	f0 
f0103363:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010336a:	f0 
f010336b:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0103372:	00 
f0103373:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010337a:	e8 c1 cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010337f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103386:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103389:	89 d8                	mov    %ebx,%eax
f010338b:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0103391:	c1 f8 03             	sar    $0x3,%eax
f0103394:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103397:	89 c2                	mov    %eax,%edx
f0103399:	c1 ea 0c             	shr    $0xc,%edx
f010339c:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f01033a2:	72 20                	jb     f01033c4 <mem_init+0x1f2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033a8:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01033af:	f0 
f01033b0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01033b7:	00 
f01033b8:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f01033bf:	e8 7c cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033c4:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01033cb:	03 03 03 
f01033ce:	74 24                	je     f01033f4 <mem_init+0x1f5a>
f01033d0:	c7 44 24 0c 18 79 10 	movl   $0xf0107918,0xc(%esp)
f01033d7:	f0 
f01033d8:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f01033df:	f0 
f01033e0:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f01033e7:	00 
f01033e8:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01033ef:	e8 4c cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01033f4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033fb:	00 
f01033fc:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0103401:	89 04 24             	mov    %eax,(%esp)
f0103404:	e8 53 df ff ff       	call   f010135c <page_remove>
	assert(pp2->pp_ref == 0);
f0103409:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010340e:	74 24                	je     f0103434 <mem_init+0x1f9a>
f0103410:	c7 44 24 0c 1b 7c 10 	movl   $0xf0107c1b,0xc(%esp)
f0103417:	f0 
f0103418:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010341f:	f0 
f0103420:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0103427:	00 
f0103428:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f010342f:	e8 0c cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103434:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0103439:	8b 08                	mov    (%eax),%ecx
f010343b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103441:	89 f2                	mov    %esi,%edx
f0103443:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0103449:	c1 fa 03             	sar    $0x3,%edx
f010344c:	c1 e2 0c             	shl    $0xc,%edx
f010344f:	39 d1                	cmp    %edx,%ecx
f0103451:	74 24                	je     f0103477 <mem_init+0x1fdd>
f0103453:	c7 44 24 0c a0 72 10 	movl   $0xf01072a0,0xc(%esp)
f010345a:	f0 
f010345b:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103462:	f0 
f0103463:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f010346a:	00 
f010346b:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f0103472:	e8 c9 cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103477:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010347d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103482:	74 24                	je     f01034a8 <mem_init+0x200e>
f0103484:	c7 44 24 0c d2 7b 10 	movl   $0xf0107bd2,0xc(%esp)
f010348b:	f0 
f010348c:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f0103493:	f0 
f0103494:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f010349b:	00 
f010349c:	c7 04 24 a5 79 10 f0 	movl   $0xf01079a5,(%esp)
f01034a3:	e8 98 cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01034a8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01034ae:	89 34 24             	mov    %esi,(%esp)
f01034b1:	e8 0f dc ff ff       	call   f01010c5 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01034b6:	c7 04 24 44 79 10 f0 	movl   $0xf0107944,(%esp)
f01034bd:	e8 b4 0a 00 00       	call   f0103f76 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01034c2:	83 c4 3c             	add    $0x3c,%esp
f01034c5:	5b                   	pop    %ebx
f01034c6:	5e                   	pop    %esi
f01034c7:	5f                   	pop    %edi
f01034c8:	5d                   	pop    %ebp
f01034c9:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01034ca:	89 da                	mov    %ebx,%edx
f01034cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034cf:	e8 3e d6 ff ff       	call   f0100b12 <check_va2pa>
f01034d4:	e9 5f fa ff ff       	jmp    f0102f38 <mem_init+0x1a9e>

f01034d9 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01034d9:	55                   	push   %ebp
f01034da:	89 e5                	mov    %esp,%ebp
f01034dc:	57                   	push   %edi
f01034dd:	56                   	push   %esi
f01034de:	53                   	push   %ebx
f01034df:	83 ec 1c             	sub    $0x1c,%esp
f01034e2:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	size_t end = (size_t)ROUNDUP(va+len, PGSIZE);
f01034e5:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01034e8:	03 7d 10             	add    0x10(%ebp),%edi
f01034eb:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f01034f1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f01034f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034fa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	for(;start < end; start += PGSIZE){
f0103500:	eb 4a                	jmp    f010354c <user_mem_check+0x73>
		pte_t *env_pte = pgdir_walk(env->env_pgdir,(void *)start, 0);
f0103502:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103509:	00 
f010350a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010350e:	8b 46 60             	mov    0x60(%esi),%eax
f0103511:	89 04 24             	mov    %eax,(%esp)
f0103514:	e8 0c dc ff ff       	call   f0101125 <pgdir_walk>
		if((start >= ULIM) || !(env_pte) || !(*env_pte & PTE_P) || !(*env_pte & perm)){
f0103519:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010351f:	77 0f                	ja     f0103530 <user_mem_check+0x57>
f0103521:	85 c0                	test   %eax,%eax
f0103523:	74 0b                	je     f0103530 <user_mem_check+0x57>
f0103525:	8b 00                	mov    (%eax),%eax
f0103527:	a8 01                	test   $0x1,%al
f0103529:	74 05                	je     f0103530 <user_mem_check+0x57>
f010352b:	85 45 14             	test   %eax,0x14(%ebp)
f010352e:	75 16                	jne    f0103546 <user_mem_check+0x6d>
			user_mem_check_addr = (start < (uint32_t)va ? (uint32_t)va : start); 
f0103530:	89 d8                	mov    %ebx,%eax
f0103532:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103535:	73 03                	jae    f010353a <user_mem_check+0x61>
f0103537:	8b 45 0c             	mov    0xc(%ebp),%eax
f010353a:	a3 44 42 22 f0       	mov    %eax,0xf0224244
			return -E_FAULT;	
f010353f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103544:	eb 0f                	jmp    f0103555 <user_mem_check+0x7c>
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	size_t end = (size_t)ROUNDUP(va+len, PGSIZE);
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
	
	for(;start < end; start += PGSIZE){
f0103546:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010354c:	39 fb                	cmp    %edi,%ebx
f010354e:	72 b2                	jb     f0103502 <user_mem_check+0x29>
		if((start >= ULIM) || !(env_pte) || !(*env_pte & PTE_P) || !(*env_pte & perm)){
			user_mem_check_addr = (start < (uint32_t)va ? (uint32_t)va : start); 
			return -E_FAULT;	
		}
	}
	return 0;
f0103550:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103555:	83 c4 1c             	add    $0x1c,%esp
f0103558:	5b                   	pop    %ebx
f0103559:	5e                   	pop    %esi
f010355a:	5f                   	pop    %edi
f010355b:	5d                   	pop    %ebp
f010355c:	c3                   	ret    

f010355d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010355d:	55                   	push   %ebp
f010355e:	89 e5                	mov    %esp,%ebp
f0103560:	53                   	push   %ebx
f0103561:	83 ec 14             	sub    $0x14,%esp
f0103564:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103567:	8b 45 14             	mov    0x14(%ebp),%eax
f010356a:	83 c8 04             	or     $0x4,%eax
f010356d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103571:	8b 45 10             	mov    0x10(%ebp),%eax
f0103574:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103578:	8b 45 0c             	mov    0xc(%ebp),%eax
f010357b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010357f:	89 1c 24             	mov    %ebx,(%esp)
f0103582:	e8 52 ff ff ff       	call   f01034d9 <user_mem_check>
f0103587:	85 c0                	test   %eax,%eax
f0103589:	79 24                	jns    f01035af <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010358b:	a1 44 42 22 f0       	mov    0xf0224244,%eax
f0103590:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103594:	8b 43 48             	mov    0x48(%ebx),%eax
f0103597:	89 44 24 04          	mov    %eax,0x4(%esp)
f010359b:	c7 04 24 70 79 10 f0 	movl   $0xf0107970,(%esp)
f01035a2:	e8 cf 09 00 00       	call   f0103f76 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01035a7:	89 1c 24             	mov    %ebx,(%esp)
f01035aa:	e8 9e 06 00 00       	call   f0103c4d <env_destroy>
	}
}
f01035af:	83 c4 14             	add    $0x14,%esp
f01035b2:	5b                   	pop    %ebx
f01035b3:	5d                   	pop    %ebp
f01035b4:	c3                   	ret    
f01035b5:	00 00                	add    %al,(%eax)
	...

f01035b8 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01035b8:	55                   	push   %ebp
f01035b9:	89 e5                	mov    %esp,%ebp
f01035bb:	57                   	push   %edi
f01035bc:	56                   	push   %esi
f01035bd:	53                   	push   %ebx
f01035be:	83 ec 1c             	sub    $0x1c,%esp
f01035c1:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start=ROUNDDOWN(va,PGSIZE),*end=ROUNDUP(va+len,PGSIZE);
f01035c3:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01035ca:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (void * addr=start;addr<end;addr+=PGSIZE){
f01035d0:	89 d3                	mov    %edx,%ebx
f01035d2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01035d8:	eb 6d                	jmp    f0103647 <region_alloc+0x8f>
		struct PageInfo* p=page_alloc(0);
f01035da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035e1:	e8 4d da ff ff       	call   f0101033 <page_alloc>
		if(p==NULL){
f01035e6:	85 c0                	test   %eax,%eax
f01035e8:	75 1c                	jne    f0103606 <region_alloc+0x4e>
			panic("region alloc failed: No more page to be allocated.\n");
f01035ea:	c7 44 24 08 e8 7c 10 	movl   $0xf0107ce8,0x8(%esp)
f01035f1:	f0 
f01035f2:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
f01035f9:	00 
f01035fa:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f0103601:	e8 3a ca ff ff       	call   f0100040 <_panic>
		}
		else {
			if(page_insert(e->env_pgdir,p,addr, PTE_U | PTE_W)){
f0103606:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010360d:	00 
f010360e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103612:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103616:	8b 46 60             	mov    0x60(%esi),%eax
f0103619:	89 04 24             	mov    %eax,(%esp)
f010361c:	e8 84 dd ff ff       	call   f01013a5 <page_insert>
f0103621:	85 c0                	test   %eax,%eax
f0103623:	74 1c                	je     f0103641 <region_alloc+0x89>
				panic("region alloc failed: page table couldn't be allocated.\n");
f0103625:	c7 44 24 08 1c 7d 10 	movl   $0xf0107d1c,0x8(%esp)
f010362c:	f0 
f010362d:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
f0103634:	00 
f0103635:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f010363c:	e8 ff c9 ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start=ROUNDDOWN(va,PGSIZE),*end=ROUNDUP(va+len,PGSIZE);
	for (void * addr=start;addr<end;addr+=PGSIZE){
f0103641:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103647:	39 fb                	cmp    %edi,%ebx
f0103649:	72 8f                	jb     f01035da <region_alloc+0x22>
			if(page_insert(e->env_pgdir,p,addr, PTE_U | PTE_W)){
				panic("region alloc failed: page table couldn't be allocated.\n");
			}
		}
	}
}
f010364b:	83 c4 1c             	add    $0x1c,%esp
f010364e:	5b                   	pop    %ebx
f010364f:	5e                   	pop    %esi
f0103650:	5f                   	pop    %edi
f0103651:	5d                   	pop    %ebp
f0103652:	c3                   	ret    

f0103653 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103653:	55                   	push   %ebp
f0103654:	89 e5                	mov    %esp,%ebp
f0103656:	57                   	push   %edi
f0103657:	56                   	push   %esi
f0103658:	53                   	push   %ebx
f0103659:	83 ec 0c             	sub    $0xc,%esp
f010365c:	8b 45 08             	mov    0x8(%ebp),%eax
f010365f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103662:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103665:	85 c0                	test   %eax,%eax
f0103667:	75 24                	jne    f010368d <envid2env+0x3a>
		*env_store = curenv;
f0103669:	e8 8e 2d 00 00       	call   f01063fc <cpunum>
f010366e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103675:	29 c2                	sub    %eax,%edx
f0103677:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010367a:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103681:	89 06                	mov    %eax,(%esi)
		return 0;
f0103683:	b8 00 00 00 00       	mov    $0x0,%eax
f0103688:	e9 84 00 00 00       	jmp    f0103711 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010368d:	89 c3                	mov    %eax,%ebx
f010368f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103695:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f010369c:	c1 e3 07             	shl    $0x7,%ebx
f010369f:	29 cb                	sub    %ecx,%ebx
f01036a1:	03 1d 48 42 22 f0    	add    0xf0224248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01036a7:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01036ab:	74 05                	je     f01036b2 <envid2env+0x5f>
f01036ad:	39 43 48             	cmp    %eax,0x48(%ebx)
f01036b0:	74 0d                	je     f01036bf <envid2env+0x6c>
		*env_store = 0;
f01036b2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036b8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036bd:	eb 52                	jmp    f0103711 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01036bf:	84 d2                	test   %dl,%dl
f01036c1:	74 47                	je     f010370a <envid2env+0xb7>
f01036c3:	e8 34 2d 00 00       	call   f01063fc <cpunum>
f01036c8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036cf:	29 c2                	sub    %eax,%edx
f01036d1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036d4:	39 1c 85 28 50 22 f0 	cmp    %ebx,-0xfddafd8(,%eax,4)
f01036db:	74 2d                	je     f010370a <envid2env+0xb7>
f01036dd:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01036e0:	e8 17 2d 00 00       	call   f01063fc <cpunum>
f01036e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036ec:	29 c2                	sub    %eax,%edx
f01036ee:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036f1:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f01036f8:	3b 78 48             	cmp    0x48(%eax),%edi
f01036fb:	74 0d                	je     f010370a <envid2env+0xb7>
		*env_store = 0;
f01036fd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103703:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103708:	eb 07                	jmp    f0103711 <envid2env+0xbe>
	}

	*env_store = e;
f010370a:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010370c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103711:	83 c4 0c             	add    $0xc,%esp
f0103714:	5b                   	pop    %ebx
f0103715:	5e                   	pop    %esi
f0103716:	5f                   	pop    %edi
f0103717:	5d                   	pop    %ebp
f0103718:	c3                   	ret    

f0103719 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103719:	55                   	push   %ebp
f010371a:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f010371c:	b8 20 93 12 f0       	mov    $0xf0129320,%eax
f0103721:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103724:	b8 23 00 00 00       	mov    $0x23,%eax
f0103729:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010372b:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010372d:	b0 10                	mov    $0x10,%al
f010372f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103731:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103733:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103735:	ea 3c 37 10 f0 08 00 	ljmp   $0x8,$0xf010373c
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f010373c:	b0 00                	mov    $0x0,%al
f010373e:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103741:	5d                   	pop    %ebp
f0103742:	c3                   	ret    

f0103743 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103743:	55                   	push   %ebp
f0103744:	89 e5                	mov    %esp,%ebp
f0103746:	56                   	push   %esi
f0103747:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	for(int i = NENV - 1; i >= 0; i--){
		envs[i].env_status = ENV_FREE;
f0103748:	8b 35 48 42 22 f0    	mov    0xf0224248,%esi
f010374e:	8b 0d 4c 42 22 f0    	mov    0xf022424c,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103754:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	for(int i = NENV - 1; i >= 0; i--){
f010375a:	ba ff 03 00 00       	mov    $0x3ff,%edx
f010375f:	eb 02                	jmp    f0103763 <env_init+0x20>
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
        	env_free_list = &envs[i];
f0103761:	89 d9                	mov    %ebx,%ecx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for(int i = NENV - 1; i >= 0; i--){
		envs[i].env_status = ENV_FREE;
f0103763:	89 c3                	mov    %eax,%ebx
f0103765:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f010376c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103773:	89 48 44             	mov    %ecx,0x44(%eax)
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for(int i = NENV - 1; i >= 0; i--){
f0103776:	4a                   	dec    %edx
f0103777:	83 e8 7c             	sub    $0x7c,%eax
f010377a:	83 fa ff             	cmp    $0xffffffff,%edx
f010377d:	75 e2                	jne    f0103761 <env_init+0x1e>
f010377f:	89 35 4c 42 22 f0    	mov    %esi,0xf022424c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
        	env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103785:	e8 8f ff ff ff       	call   f0103719 <env_init_percpu>
}
f010378a:	5b                   	pop    %ebx
f010378b:	5e                   	pop    %esi
f010378c:	5d                   	pop    %ebp
f010378d:	c3                   	ret    

f010378e <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010378e:	55                   	push   %ebp
f010378f:	89 e5                	mov    %esp,%ebp
f0103791:	56                   	push   %esi
f0103792:	53                   	push   %ebx
f0103793:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103796:	8b 1d 4c 42 22 f0    	mov    0xf022424c,%ebx
f010379c:	85 db                	test   %ebx,%ebx
f010379e:	0f 84 69 01 00 00    	je     f010390d <env_alloc+0x17f>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01037a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01037ab:	e8 83 d8 ff ff       	call   f0101033 <page_alloc>
f01037b0:	89 c6                	mov    %eax,%esi
f01037b2:	85 c0                	test   %eax,%eax
f01037b4:	0f 84 5a 01 00 00    	je     f0103914 <env_alloc+0x186>
f01037ba:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f01037c0:	c1 f8 03             	sar    $0x3,%eax
f01037c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037c6:	89 c2                	mov    %eax,%edx
f01037c8:	c1 ea 0c             	shr    $0xc,%edx
f01037cb:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f01037d1:	72 20                	jb     f01037f3 <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037d7:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01037de:	f0 
f01037df:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01037e6:	00 
f01037e7:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f01037ee:	e8 4d c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037f3:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f01037f8:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01037fb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103802:	00 
f0103803:	8b 15 8c 4e 22 f0    	mov    0xf0224e8c,%edx
f0103809:	89 54 24 04          	mov    %edx,0x4(%esp)
f010380d:	89 04 24             	mov    %eax,(%esp)
f0103810:	e8 6d 26 00 00       	call   f0105e82 <memcpy>
	p->pp_ref++;
f0103815:	66 ff 46 04          	incw   0x4(%esi)
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103819:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010381c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103821:	77 20                	ja     f0103843 <env_alloc+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103823:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103827:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f010382e:	f0 
f010382f:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f0103836:	00 
f0103837:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f010383e:	e8 fd c7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103843:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103849:	83 ca 05             	or     $0x5,%edx
f010384c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103852:	8b 43 48             	mov    0x48(%ebx),%eax
f0103855:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010385a:	89 c1                	mov    %eax,%ecx
f010385c:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103862:	7f 05                	jg     f0103869 <env_alloc+0xdb>
		generation = 1 << ENVGENSHIFT;
f0103864:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103869:	89 d8                	mov    %ebx,%eax
f010386b:	2b 05 48 42 22 f0    	sub    0xf0224248,%eax
f0103871:	c1 f8 02             	sar    $0x2,%eax
f0103874:	89 c6                	mov    %eax,%esi
f0103876:	c1 e6 05             	shl    $0x5,%esi
f0103879:	89 c2                	mov    %eax,%edx
f010387b:	c1 e2 0a             	shl    $0xa,%edx
f010387e:	01 f2                	add    %esi,%edx
f0103880:	01 c2                	add    %eax,%edx
f0103882:	89 d6                	mov    %edx,%esi
f0103884:	c1 e6 0f             	shl    $0xf,%esi
f0103887:	01 f2                	add    %esi,%edx
f0103889:	c1 e2 05             	shl    $0x5,%edx
f010388c:	01 d0                	add    %edx,%eax
f010388e:	f7 d8                	neg    %eax
f0103890:	09 c1                	or     %eax,%ecx
f0103892:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103895:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103898:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010389b:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01038a2:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01038a9:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01038b0:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01038b7:	00 
f01038b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038bf:	00 
f01038c0:	89 1c 24             	mov    %ebx,(%esp)
f01038c3:	e8 06 25 00 00       	call   f0105dce <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01038c8:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01038ce:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01038d4:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01038da:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01038e1:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01038e7:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01038ee:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01038f5:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01038f9:	8b 43 44             	mov    0x44(%ebx),%eax
f01038fc:	a3 4c 42 22 f0       	mov    %eax,0xf022424c
	*newenv_store = e;
f0103901:	8b 45 08             	mov    0x8(%ebp),%eax
f0103904:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103906:	b8 00 00 00 00       	mov    $0x0,%eax
f010390b:	eb 0c                	jmp    f0103919 <env_alloc+0x18b>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010390d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103912:	eb 05                	jmp    f0103919 <env_alloc+0x18b>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103914:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103919:	83 c4 10             	add    $0x10,%esp
f010391c:	5b                   	pop    %ebx
f010391d:	5e                   	pop    %esi
f010391e:	5d                   	pop    %ebp
f010391f:	c3                   	ret    

f0103920 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103920:	55                   	push   %ebp
f0103921:	89 e5                	mov    %esp,%ebp
f0103923:	57                   	push   %edi
f0103924:	56                   	push   %esi
f0103925:	53                   	push   %ebx
f0103926:	83 ec 3c             	sub    $0x3c,%esp
f0103929:	8b 75 08             	mov    0x8(%ebp),%esi


	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env *e = NULL;
f010392c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	env_alloc(&e, 0);
f0103933:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010393a:	00 
f010393b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010393e:	89 04 24             	mov    %eax,(%esp)
f0103941:	e8 48 fe ff ff       	call   f010378e <env_alloc>
	if (type == ENV_TYPE_FS){
f0103946:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f010394a:	75 0a                	jne    f0103956 <env_create+0x36>
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f010394c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010394f:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
	load_icode(e, binary);
f0103956:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103959:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010395c:	89 f3                	mov    %esi,%ebx
f010395e:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103961:	0f b7 7e 2c          	movzwl 0x2c(%esi),%edi
f0103965:	c1 e7 05             	shl    $0x5,%edi
f0103968:	01 df                	add    %ebx,%edi
	int va = (int)elf + ph->p_offset;
	
	if (elf->e_magic != ELF_MAGIC){
f010396a:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103970:	74 1c                	je     f010398e <env_create+0x6e>
		panic("ELF is illegal");
f0103972:	c7 44 24 08 5f 7d 10 	movl   $0xf0107d5f,0x8(%esp)
f0103979:	f0 
f010397a:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f0103981:	00 
f0103982:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f0103989:	e8 b2 c6 ff ff       	call   f0100040 <_panic>
	}
	lcr3(PADDR(e->env_pgdir));
f010398e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103991:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103994:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103999:	77 20                	ja     f01039bb <env_create+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010399b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010399f:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f01039a6:	f0 
f01039a7:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f01039ae:	00 
f01039af:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f01039b6:	e8 85 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039bb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01039c0:	0f 22 d8             	mov    %eax,%cr3
f01039c3:	eb 4b                	jmp    f0103a10 <env_create+0xf0>

	for (; ph < eph; ph++){
		if(ph->p_type == ELF_PROG_LOAD){
f01039c5:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039c8:	75 43                	jne    f0103a0d <env_create+0xed>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01039ca:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039cd:	8b 53 08             	mov    0x8(%ebx),%edx
f01039d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039d3:	e8 e0 fb ff ff       	call   f01035b8 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f01039d8:	8b 43 14             	mov    0x14(%ebx),%eax
f01039db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039e6:	00 
f01039e7:	8b 43 08             	mov    0x8(%ebx),%eax
f01039ea:	89 04 24             	mov    %eax,(%esp)
f01039ed:	e8 dc 23 00 00       	call   f0105dce <memset>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01039f2:	8b 43 10             	mov    0x10(%ebx),%eax
f01039f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039f9:	89 f0                	mov    %esi,%eax
f01039fb:	03 43 04             	add    0x4(%ebx),%eax
f01039fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a02:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a05:	89 04 24             	mov    %eax,(%esp)
f0103a08:	e8 75 24 00 00       	call   f0105e82 <memcpy>
	if (elf->e_magic != ELF_MAGIC){
		panic("ELF is illegal");
	}
	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++){
f0103a0d:	83 c3 20             	add    $0x20,%ebx
f0103a10:	39 df                	cmp    %ebx,%edi
f0103a12:	77 b1                	ja     f01039c5 <env_create+0xa5>
	}
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	lcr3(PADDR(kern_pgdir));
f0103a14:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a19:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a1e:	77 20                	ja     f0103a40 <env_create+0x120>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a24:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0103a2b:	f0 
f0103a2c:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0103a33:	00 
f0103a34:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f0103a3b:	e8 00 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a40:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a45:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = elf->e_entry;
f0103a48:	8b 46 18             	mov    0x18(%esi),%eax
f0103a4b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a4e:	89 42 30             	mov    %eax,0x30(%edx)
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103a51:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a56:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a5e:	e8 55 fb ff ff       	call   f01035b8 <region_alloc>
	env_alloc(&e, 0);
	if (type == ENV_TYPE_FS){
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
	}
	load_icode(e, binary);
	e->env_type = type;
f0103a63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a66:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a69:	89 50 50             	mov    %edx,0x50(%eax)

}
f0103a6c:	83 c4 3c             	add    $0x3c,%esp
f0103a6f:	5b                   	pop    %ebx
f0103a70:	5e                   	pop    %esi
f0103a71:	5f                   	pop    %edi
f0103a72:	5d                   	pop    %ebp
f0103a73:	c3                   	ret    

f0103a74 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a74:	55                   	push   %ebp
f0103a75:	89 e5                	mov    %esp,%ebp
f0103a77:	57                   	push   %edi
f0103a78:	56                   	push   %esi
f0103a79:	53                   	push   %ebx
f0103a7a:	83 ec 2c             	sub    $0x2c,%esp
f0103a7d:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a80:	e8 77 29 00 00       	call   f01063fc <cpunum>
f0103a85:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a8c:	29 c2                	sub    %eax,%edx
f0103a8e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a91:	39 3c 85 28 50 22 f0 	cmp    %edi,-0xfddafd8(,%eax,4)
f0103a98:	75 3d                	jne    f0103ad7 <env_free+0x63>
		lcr3(PADDR(kern_pgdir));
f0103a9a:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a9f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103aa4:	77 20                	ja     f0103ac6 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103aa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aaa:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0103ab1:	f0 
f0103ab2:	c7 44 24 04 ac 01 00 	movl   $0x1ac,0x4(%esp)
f0103ab9:	00 
f0103aba:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f0103ac1:	e8 7a c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ac6:	05 00 00 00 10       	add    $0x10000000,%eax
f0103acb:	0f 22 d8             	mov    %eax,%cr3
f0103ace:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103ad5:	eb 07                	jmp    f0103ade <env_free+0x6a>
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ad7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103ade:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ae1:	c1 e0 02             	shl    $0x2,%eax
f0103ae4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103ae7:	8b 47 60             	mov    0x60(%edi),%eax
f0103aea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103aed:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103af0:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103af6:	0f 84 b6 00 00 00    	je     f0103bb2 <env_free+0x13e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103afc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b02:	89 f0                	mov    %esi,%eax
f0103b04:	c1 e8 0c             	shr    $0xc,%eax
f0103b07:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b0a:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f0103b10:	72 20                	jb     f0103b32 <env_free+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b12:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b16:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f0103b1d:	f0 
f0103b1e:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f0103b25:	00 
f0103b26:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f0103b2d:	e8 0e c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b32:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b35:	c1 e2 16             	shl    $0x16,%edx
f0103b38:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b3b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b40:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b47:	01 
f0103b48:	74 17                	je     f0103b61 <env_free+0xed>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b4a:	89 d8                	mov    %ebx,%eax
f0103b4c:	c1 e0 0c             	shl    $0xc,%eax
f0103b4f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b56:	8b 47 60             	mov    0x60(%edi),%eax
f0103b59:	89 04 24             	mov    %eax,(%esp)
f0103b5c:	e8 fb d7 ff ff       	call   f010135c <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b61:	43                   	inc    %ebx
f0103b62:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b68:	75 d6                	jne    f0103b40 <env_free+0xcc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b6a:	8b 47 60             	mov    0x60(%edi),%eax
f0103b6d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b70:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b77:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b7a:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f0103b80:	72 1c                	jb     f0103b9e <env_free+0x12a>
		panic("pa2page called with invalid pa");
f0103b82:	c7 44 24 08 4c 71 10 	movl   $0xf010714c,0x8(%esp)
f0103b89:	f0 
f0103b8a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b91:	00 
f0103b92:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f0103b99:	e8 a2 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b9e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ba1:	c1 e0 03             	shl    $0x3,%eax
f0103ba4:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
		page_decref(pa2page(pa));
f0103baa:	89 04 24             	mov    %eax,(%esp)
f0103bad:	e8 53 d5 ff ff       	call   f0101105 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bb2:	ff 45 e0             	incl   -0x20(%ebp)
f0103bb5:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bbc:	0f 85 1c ff ff ff    	jne    f0103ade <env_free+0x6a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bc2:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bc5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bca:	77 20                	ja     f0103bec <env_free+0x178>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bd0:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0103bd7:	f0 
f0103bd8:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f0103bdf:	00 
f0103be0:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f0103be7:	e8 54 c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103bec:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103bf3:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bf8:	c1 e8 0c             	shr    $0xc,%eax
f0103bfb:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f0103c01:	72 1c                	jb     f0103c1f <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f0103c03:	c7 44 24 08 4c 71 10 	movl   $0xf010714c,0x8(%esp)
f0103c0a:	f0 
f0103c0b:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c12:	00 
f0103c13:	c7 04 24 b1 79 10 f0 	movl   $0xf01079b1,(%esp)
f0103c1a:	e8 21 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c1f:	c1 e0 03             	shl    $0x3,%eax
f0103c22:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
	page_decref(pa2page(pa));
f0103c28:	89 04 24             	mov    %eax,(%esp)
f0103c2b:	e8 d5 d4 ff ff       	call   f0101105 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c30:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c37:	a1 4c 42 22 f0       	mov    0xf022424c,%eax
f0103c3c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c3f:	89 3d 4c 42 22 f0    	mov    %edi,0xf022424c
}
f0103c45:	83 c4 2c             	add    $0x2c,%esp
f0103c48:	5b                   	pop    %ebx
f0103c49:	5e                   	pop    %esi
f0103c4a:	5f                   	pop    %edi
f0103c4b:	5d                   	pop    %ebp
f0103c4c:	c3                   	ret    

f0103c4d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c4d:	55                   	push   %ebp
f0103c4e:	89 e5                	mov    %esp,%ebp
f0103c50:	53                   	push   %ebx
f0103c51:	83 ec 14             	sub    $0x14,%esp
f0103c54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c57:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c5b:	75 23                	jne    f0103c80 <env_destroy+0x33>
f0103c5d:	e8 9a 27 00 00       	call   f01063fc <cpunum>
f0103c62:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c69:	29 c2                	sub    %eax,%edx
f0103c6b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c6e:	39 1c 85 28 50 22 f0 	cmp    %ebx,-0xfddafd8(,%eax,4)
f0103c75:	74 09                	je     f0103c80 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103c77:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c7e:	eb 39                	jmp    f0103cb9 <env_destroy+0x6c>
	}

	env_free(e);
f0103c80:	89 1c 24             	mov    %ebx,(%esp)
f0103c83:	e8 ec fd ff ff       	call   f0103a74 <env_free>

	if (curenv == e) {
f0103c88:	e8 6f 27 00 00       	call   f01063fc <cpunum>
f0103c8d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c94:	29 c2                	sub    %eax,%edx
f0103c96:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c99:	39 1c 85 28 50 22 f0 	cmp    %ebx,-0xfddafd8(,%eax,4)
f0103ca0:	75 17                	jne    f0103cb9 <env_destroy+0x6c>
		curenv = NULL;
f0103ca2:	e8 55 27 00 00       	call   f01063fc <cpunum>
f0103ca7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103caa:	c7 80 28 50 22 f0 00 	movl   $0x0,-0xfddafd8(%eax)
f0103cb1:	00 00 00 
		sched_yield();
f0103cb4:	e8 d1 0f 00 00       	call   f0104c8a <sched_yield>
	}
}
f0103cb9:	83 c4 14             	add    $0x14,%esp
f0103cbc:	5b                   	pop    %ebx
f0103cbd:	5d                   	pop    %ebp
f0103cbe:	c3                   	ret    

f0103cbf <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cbf:	55                   	push   %ebp
f0103cc0:	89 e5                	mov    %esp,%ebp
f0103cc2:	53                   	push   %ebx
f0103cc3:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cc6:	e8 31 27 00 00       	call   f01063fc <cpunum>
f0103ccb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cd2:	29 c2                	sub    %eax,%edx
f0103cd4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cd7:	8b 1c 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%ebx
f0103cde:	e8 19 27 00 00       	call   f01063fc <cpunum>
f0103ce3:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103ce6:	8b 65 08             	mov    0x8(%ebp),%esp
f0103ce9:	61                   	popa   
f0103cea:	07                   	pop    %es
f0103ceb:	1f                   	pop    %ds
f0103cec:	83 c4 08             	add    $0x8,%esp
f0103cef:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cf0:	c7 44 24 08 6e 7d 10 	movl   $0xf0107d6e,0x8(%esp)
f0103cf7:	f0 
f0103cf8:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
f0103cff:	00 
f0103d00:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f0103d07:	e8 34 c3 ff ff       	call   f0100040 <_panic>

f0103d0c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d0c:	55                   	push   %ebp
f0103d0d:	89 e5                	mov    %esp,%ebp
f0103d0f:	83 ec 18             	sub    $0x18,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103d12:	e8 e5 26 00 00       	call   f01063fc <cpunum>
f0103d17:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d1e:	29 c2                	sub    %eax,%edx
f0103d20:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d23:	83 3c 85 28 50 22 f0 	cmpl   $0x0,-0xfddafd8(,%eax,4)
f0103d2a:	00 
f0103d2b:	74 33                	je     f0103d60 <env_run+0x54>
f0103d2d:	e8 ca 26 00 00       	call   f01063fc <cpunum>
f0103d32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d39:	29 c2                	sub    %eax,%edx
f0103d3b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d3e:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103d45:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d49:	75 15                	jne    f0103d60 <env_run+0x54>
		curenv->env_status = ENV_RUNNABLE;
f0103d4b:	e8 ac 26 00 00       	call   f01063fc <cpunum>
f0103d50:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d53:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0103d59:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;
f0103d60:	e8 97 26 00 00       	call   f01063fc <cpunum>
f0103d65:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d6c:	29 c2                	sub    %eax,%edx
f0103d6e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d71:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d74:	89 14 85 28 50 22 f0 	mov    %edx,-0xfddafd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0103d7b:	e8 7c 26 00 00       	call   f01063fc <cpunum>
f0103d80:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d87:	29 c2                	sub    %eax,%edx
f0103d89:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d8c:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103d93:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103d9a:	e8 5d 26 00 00       	call   f01063fc <cpunum>
f0103d9f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103da6:	29 c2                	sub    %eax,%edx
f0103da8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dab:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103db2:	ff 40 58             	incl   0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103db5:	e8 42 26 00 00       	call   f01063fc <cpunum>
f0103dba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103dc1:	29 c2                	sub    %eax,%edx
f0103dc3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dc6:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103dcd:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103dd0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dd5:	77 20                	ja     f0103df7 <env_run+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ddb:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0103de2:	f0 
f0103de3:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
f0103dea:	00 
f0103deb:	c7 04 24 54 7d 10 f0 	movl   $0xf0107d54,(%esp)
f0103df2:	e8 49 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103df7:	05 00 00 00 10       	add    $0x10000000,%eax
f0103dfc:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103dff:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0103e06:	e8 53 29 00 00       	call   f010675e <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e0b:	f3 90                	pause  
	
	unlock_kernel();
	env_pop_tf(&(curenv->env_tf));
f0103e0d:	e8 ea 25 00 00       	call   f01063fc <cpunum>
f0103e12:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e19:	29 c2                	sub    %eax,%edx
f0103e1b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e1e:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103e25:	89 04 24             	mov    %eax,(%esp)
f0103e28:	e8 92 fe ff ff       	call   f0103cbf <env_pop_tf>
f0103e2d:	00 00                	add    %al,(%eax)
	...

f0103e30 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e30:	55                   	push   %ebp
f0103e31:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e33:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e38:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e3b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e3c:	b2 71                	mov    $0x71,%dl
f0103e3e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e3f:	0f b6 c0             	movzbl %al,%eax
}
f0103e42:	5d                   	pop    %ebp
f0103e43:	c3                   	ret    

f0103e44 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e44:	55                   	push   %ebp
f0103e45:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e47:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e4f:	ee                   	out    %al,(%dx)
f0103e50:	b2 71                	mov    $0x71,%dl
f0103e52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e55:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e56:	5d                   	pop    %ebp
f0103e57:	c3                   	ret    

f0103e58 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e58:	55                   	push   %ebp
f0103e59:	89 e5                	mov    %esp,%ebp
f0103e5b:	56                   	push   %esi
f0103e5c:	53                   	push   %ebx
f0103e5d:	83 ec 10             	sub    $0x10,%esp
f0103e60:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e63:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103e65:	66 a3 a8 93 12 f0    	mov    %ax,0xf01293a8
	if (!didinit)
f0103e6b:	80 3d 50 42 22 f0 00 	cmpb   $0x0,0xf0224250
f0103e72:	74 51                	je     f0103ec5 <irq_setmask_8259A+0x6d>
f0103e74:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e79:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e7a:	89 f0                	mov    %esi,%eax
f0103e7c:	66 c1 e8 08          	shr    $0x8,%ax
f0103e80:	b2 a1                	mov    $0xa1,%dl
f0103e82:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e83:	c7 04 24 7a 7d 10 f0 	movl   $0xf0107d7a,(%esp)
f0103e8a:	e8 e7 00 00 00       	call   f0103f76 <cprintf>
	for (i = 0; i < 16; i++)
f0103e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e94:	0f b7 f6             	movzwl %si,%esi
f0103e97:	f7 d6                	not    %esi
f0103e99:	89 f0                	mov    %esi,%eax
f0103e9b:	88 d9                	mov    %bl,%cl
f0103e9d:	d3 f8                	sar    %cl,%eax
f0103e9f:	a8 01                	test   $0x1,%al
f0103ea1:	74 10                	je     f0103eb3 <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f0103ea3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ea7:	c7 04 24 0b 82 10 f0 	movl   $0xf010820b,(%esp)
f0103eae:	e8 c3 00 00 00       	call   f0103f76 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103eb3:	43                   	inc    %ebx
f0103eb4:	83 fb 10             	cmp    $0x10,%ebx
f0103eb7:	75 e0                	jne    f0103e99 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103eb9:	c7 04 24 b6 7c 10 f0 	movl   $0xf0107cb6,(%esp)
f0103ec0:	e8 b1 00 00 00       	call   f0103f76 <cprintf>
}
f0103ec5:	83 c4 10             	add    $0x10,%esp
f0103ec8:	5b                   	pop    %ebx
f0103ec9:	5e                   	pop    %esi
f0103eca:	5d                   	pop    %ebp
f0103ecb:	c3                   	ret    

f0103ecc <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103ecc:	55                   	push   %ebp
f0103ecd:	89 e5                	mov    %esp,%ebp
f0103ecf:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103ed2:	c6 05 50 42 22 f0 01 	movb   $0x1,0xf0224250
f0103ed9:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ede:	b0 ff                	mov    $0xff,%al
f0103ee0:	ee                   	out    %al,(%dx)
f0103ee1:	b2 a1                	mov    $0xa1,%dl
f0103ee3:	ee                   	out    %al,(%dx)
f0103ee4:	b2 20                	mov    $0x20,%dl
f0103ee6:	b0 11                	mov    $0x11,%al
f0103ee8:	ee                   	out    %al,(%dx)
f0103ee9:	b2 21                	mov    $0x21,%dl
f0103eeb:	b0 20                	mov    $0x20,%al
f0103eed:	ee                   	out    %al,(%dx)
f0103eee:	b0 04                	mov    $0x4,%al
f0103ef0:	ee                   	out    %al,(%dx)
f0103ef1:	b0 03                	mov    $0x3,%al
f0103ef3:	ee                   	out    %al,(%dx)
f0103ef4:	b2 a0                	mov    $0xa0,%dl
f0103ef6:	b0 11                	mov    $0x11,%al
f0103ef8:	ee                   	out    %al,(%dx)
f0103ef9:	b2 a1                	mov    $0xa1,%dl
f0103efb:	b0 28                	mov    $0x28,%al
f0103efd:	ee                   	out    %al,(%dx)
f0103efe:	b0 02                	mov    $0x2,%al
f0103f00:	ee                   	out    %al,(%dx)
f0103f01:	b0 01                	mov    $0x1,%al
f0103f03:	ee                   	out    %al,(%dx)
f0103f04:	b2 20                	mov    $0x20,%dl
f0103f06:	b0 68                	mov    $0x68,%al
f0103f08:	ee                   	out    %al,(%dx)
f0103f09:	b0 0a                	mov    $0xa,%al
f0103f0b:	ee                   	out    %al,(%dx)
f0103f0c:	b2 a0                	mov    $0xa0,%dl
f0103f0e:	b0 68                	mov    $0x68,%al
f0103f10:	ee                   	out    %al,(%dx)
f0103f11:	b0 0a                	mov    $0xa,%al
f0103f13:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f14:	66 a1 a8 93 12 f0    	mov    0xf01293a8,%ax
f0103f1a:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103f1e:	74 0b                	je     f0103f2b <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103f20:	0f b7 c0             	movzwl %ax,%eax
f0103f23:	89 04 24             	mov    %eax,(%esp)
f0103f26:	e8 2d ff ff ff       	call   f0103e58 <irq_setmask_8259A>
}
f0103f2b:	c9                   	leave  
f0103f2c:	c3                   	ret    
f0103f2d:	00 00                	add    %al,(%eax)
	...

f0103f30 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f30:	55                   	push   %ebp
f0103f31:	89 e5                	mov    %esp,%ebp
f0103f33:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f36:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f39:	89 04 24             	mov    %eax,(%esp)
f0103f3c:	e8 6d c8 ff ff       	call   f01007ae <cputchar>
	*cnt++;
}
f0103f41:	c9                   	leave  
f0103f42:	c3                   	ret    

f0103f43 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f43:	55                   	push   %ebp
f0103f44:	89 e5                	mov    %esp,%ebp
f0103f46:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f50:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f53:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f57:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f5a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f65:	c7 04 24 30 3f 10 f0 	movl   $0xf0103f30,(%esp)
f0103f6c:	e8 0d 18 00 00       	call   f010577e <vprintfmt>
	return cnt;
}
f0103f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f74:	c9                   	leave  
f0103f75:	c3                   	ret    

f0103f76 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f76:	55                   	push   %ebp
f0103f77:	89 e5                	mov    %esp,%ebp
f0103f79:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f7c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f83:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f86:	89 04 24             	mov    %eax,(%esp)
f0103f89:	e8 b5 ff ff ff       	call   f0103f43 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f8e:	c9                   	leave  
f0103f8f:	c3                   	ret    

f0103f90 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f90:	55                   	push   %ebp
f0103f91:	89 e5                	mov    %esp,%ebp
f0103f93:	57                   	push   %edi
f0103f94:	56                   	push   %esi
f0103f95:	53                   	push   %ebx
f0103f96:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int i = thiscpu->cpu_id;
f0103f99:	e8 5e 24 00 00       	call   f01063fc <cpunum>
f0103f9e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fa5:	29 c2                	sub    %eax,%edx
f0103fa7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103faa:	0f b6 34 85 20 50 22 	movzbl -0xfddafe0(,%eax,4),%esi
f0103fb1:	f0 
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103fb2:	e8 45 24 00 00       	call   f01063fc <cpunum>
f0103fb7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fbe:	29 c2                	sub    %eax,%edx
f0103fc0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fc3:	89 f2                	mov    %esi,%edx
f0103fc5:	f7 da                	neg    %edx
f0103fc7:	c1 e2 10             	shl    $0x10,%edx
f0103fca:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103fd0:	89 14 85 30 50 22 f0 	mov    %edx,-0xfddafd0(,%eax,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103fd7:	e8 20 24 00 00       	call   f01063fc <cpunum>
f0103fdc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fe3:	29 c2                	sub    %eax,%edx
f0103fe5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fe8:	66 c7 04 85 34 50 22 	movw   $0x10,-0xfddafcc(,%eax,4)
f0103fef:	f0 10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103ff2:	e8 05 24 00 00       	call   f01063fc <cpunum>
f0103ff7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ffe:	29 c2                	sub    %eax,%edx
f0104000:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104003:	66 c7 04 85 92 50 22 	movw   $0x68,-0xfddaf6e(,%eax,4)
f010400a:	f0 68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f010400d:	8d 5e 05             	lea    0x5(%esi),%ebx
f0104010:	e8 e7 23 00 00       	call   f01063fc <cpunum>
f0104015:	89 c7                	mov    %eax,%edi
f0104017:	e8 e0 23 00 00       	call   f01063fc <cpunum>
f010401c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010401f:	e8 d8 23 00 00       	call   f01063fc <cpunum>
f0104024:	66 c7 04 dd 40 93 12 	movw   $0x67,-0xfed6cc0(,%ebx,8)
f010402b:	f0 67 00 
f010402e:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0104035:	29 fa                	sub    %edi,%edx
f0104037:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010403a:	8d 14 95 2c 50 22 f0 	lea    -0xfddafd4(,%edx,4),%edx
f0104041:	66 89 14 dd 42 93 12 	mov    %dx,-0xfed6cbe(,%ebx,8)
f0104048:	f0 
f0104049:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010404c:	c1 e2 03             	shl    $0x3,%edx
f010404f:	2b 55 e4             	sub    -0x1c(%ebp),%edx
f0104052:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104055:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0104058:	8d 14 95 2c 50 22 f0 	lea    -0xfddafd4(,%edx,4),%edx
f010405f:	c1 ea 10             	shr    $0x10,%edx
f0104062:	88 14 dd 44 93 12 f0 	mov    %dl,-0xfed6cbc(,%ebx,8)
f0104069:	c6 04 dd 46 93 12 f0 	movb   $0x40,-0xfed6cba(,%ebx,8)
f0104070:	40 
f0104071:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104078:	29 c2                	sub    %eax,%edx
f010407a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010407d:	8d 04 85 2c 50 22 f0 	lea    -0xfddafd4(,%eax,4),%eax
f0104084:	c1 e8 18             	shr    $0x18,%eax
f0104087:	88 04 dd 47 93 12 f0 	mov    %al,-0xfed6cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f010408e:	c6 04 dd 45 93 12 f0 	movb   $0x89,-0xfed6cbb(,%ebx,8)
f0104095:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));
f0104096:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f010409d:	0f 00 de             	ltr    %si
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f01040a0:	b8 ac 93 12 f0       	mov    $0xf01293ac,%eax
f01040a5:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01040a8:	83 c4 1c             	add    $0x1c,%esp
f01040ab:	5b                   	pop    %ebx
f01040ac:	5e                   	pop    %esi
f01040ad:	5f                   	pop    %edi
f01040ae:	5d                   	pop    %ebp
f01040af:	c3                   	ret    

f01040b0 <trap_init>:
}


void
trap_init(void)
{
f01040b0:	55                   	push   %ebp
f01040b1:	89 e5                	mov    %esp,%ebp
f01040b3:	83 ec 08             	sub    $0x8,%esp
	void Int_pgflt();
	void Int_align();
	void Int_syscall();
	
	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 	 0, GD_KT, Int_divide,	0);
f01040b6:	b8 f8 4a 10 f0       	mov    $0xf0104af8,%eax
f01040bb:	66 a3 60 42 22 f0    	mov    %ax,0xf0224260
f01040c1:	66 c7 05 62 42 22 f0 	movw   $0x8,0xf0224262
f01040c8:	08 00 
f01040ca:	c6 05 64 42 22 f0 00 	movb   $0x0,0xf0224264
f01040d1:	c6 05 65 42 22 f0 8e 	movb   $0x8e,0xf0224265
f01040d8:	c1 e8 10             	shr    $0x10,%eax
f01040db:	66 a3 66 42 22 f0    	mov    %ax,0xf0224266
	SETGATE(idt[T_DEBUG],	 0, GD_KT, Int_debug, 	0);
f01040e1:	b8 02 4b 10 f0       	mov    $0xf0104b02,%eax
f01040e6:	66 a3 68 42 22 f0    	mov    %ax,0xf0224268
f01040ec:	66 c7 05 6a 42 22 f0 	movw   $0x8,0xf022426a
f01040f3:	08 00 
f01040f5:	c6 05 6c 42 22 f0 00 	movb   $0x0,0xf022426c
f01040fc:	c6 05 6d 42 22 f0 8e 	movb   $0x8e,0xf022426d
f0104103:	c1 e8 10             	shr    $0x10,%eax
f0104106:	66 a3 6e 42 22 f0    	mov    %ax,0xf022426e
	SETGATE(idt[T_NMI], 	 0, GD_KT, Int_nmi, 	0);
f010410c:	b8 08 4b 10 f0       	mov    $0xf0104b08,%eax
f0104111:	66 a3 70 42 22 f0    	mov    %ax,0xf0224270
f0104117:	66 c7 05 72 42 22 f0 	movw   $0x8,0xf0224272
f010411e:	08 00 
f0104120:	c6 05 74 42 22 f0 00 	movb   $0x0,0xf0224274
f0104127:	c6 05 75 42 22 f0 8e 	movb   $0x8e,0xf0224275
f010412e:	c1 e8 10             	shr    $0x10,%eax
f0104131:	66 a3 76 42 22 f0    	mov    %ax,0xf0224276
	SETGATE(idt[T_BRKPT], 	 0, GD_KT, Int_brkpt,	3);
f0104137:	b8 0e 4b 10 f0       	mov    $0xf0104b0e,%eax
f010413c:	66 a3 78 42 22 f0    	mov    %ax,0xf0224278
f0104142:	66 c7 05 7a 42 22 f0 	movw   $0x8,0xf022427a
f0104149:	08 00 
f010414b:	c6 05 7c 42 22 f0 00 	movb   $0x0,0xf022427c
f0104152:	c6 05 7d 42 22 f0 ee 	movb   $0xee,0xf022427d
f0104159:	c1 e8 10             	shr    $0x10,%eax
f010415c:	66 a3 7e 42 22 f0    	mov    %ax,0xf022427e
	SETGATE(idt[T_OFLOW], 	 0, GD_KT, Int_oflow, 	0);
f0104162:	b8 14 4b 10 f0       	mov    $0xf0104b14,%eax
f0104167:	66 a3 80 42 22 f0    	mov    %ax,0xf0224280
f010416d:	66 c7 05 82 42 22 f0 	movw   $0x8,0xf0224282
f0104174:	08 00 
f0104176:	c6 05 84 42 22 f0 00 	movb   $0x0,0xf0224284
f010417d:	c6 05 85 42 22 f0 8e 	movb   $0x8e,0xf0224285
f0104184:	c1 e8 10             	shr    $0x10,%eax
f0104187:	66 a3 86 42 22 f0    	mov    %ax,0xf0224286
	SETGATE(idt[T_BOUND], 	 0, GD_KT, Int_bound, 	0);
f010418d:	b8 1a 4b 10 f0       	mov    $0xf0104b1a,%eax
f0104192:	66 a3 88 42 22 f0    	mov    %ax,0xf0224288
f0104198:	66 c7 05 8a 42 22 f0 	movw   $0x8,0xf022428a
f010419f:	08 00 
f01041a1:	c6 05 8c 42 22 f0 00 	movb   $0x0,0xf022428c
f01041a8:	c6 05 8d 42 22 f0 8e 	movb   $0x8e,0xf022428d
f01041af:	c1 e8 10             	shr    $0x10,%eax
f01041b2:	66 a3 8e 42 22 f0    	mov    %ax,0xf022428e
	SETGATE(idt[T_ILLOP], 	 0, GD_KT, Int_illop, 	0);
f01041b8:	b8 20 4b 10 f0       	mov    $0xf0104b20,%eax
f01041bd:	66 a3 90 42 22 f0    	mov    %ax,0xf0224290
f01041c3:	66 c7 05 92 42 22 f0 	movw   $0x8,0xf0224292
f01041ca:	08 00 
f01041cc:	c6 05 94 42 22 f0 00 	movb   $0x0,0xf0224294
f01041d3:	c6 05 95 42 22 f0 8e 	movb   $0x8e,0xf0224295
f01041da:	c1 e8 10             	shr    $0x10,%eax
f01041dd:	66 a3 96 42 22 f0    	mov    %ax,0xf0224296
	SETGATE(idt[T_DEVICE], 	 0, GD_KT, Int_device, 	0);
f01041e3:	b8 26 4b 10 f0       	mov    $0xf0104b26,%eax
f01041e8:	66 a3 98 42 22 f0    	mov    %ax,0xf0224298
f01041ee:	66 c7 05 9a 42 22 f0 	movw   $0x8,0xf022429a
f01041f5:	08 00 
f01041f7:	c6 05 9c 42 22 f0 00 	movb   $0x0,0xf022429c
f01041fe:	c6 05 9d 42 22 f0 8e 	movb   $0x8e,0xf022429d
f0104205:	c1 e8 10             	shr    $0x10,%eax
f0104208:	66 a3 9e 42 22 f0    	mov    %ax,0xf022429e
	SETGATE(idt[T_DBLFLT], 	 0, GD_KT, Int_dblflt, 	0);
f010420e:	b8 44 4b 10 f0       	mov    $0xf0104b44,%eax
f0104213:	66 a3 a0 42 22 f0    	mov    %ax,0xf02242a0
f0104219:	66 c7 05 a2 42 22 f0 	movw   $0x8,0xf02242a2
f0104220:	08 00 
f0104222:	c6 05 a4 42 22 f0 00 	movb   $0x0,0xf02242a4
f0104229:	c6 05 a5 42 22 f0 8e 	movb   $0x8e,0xf02242a5
f0104230:	c1 e8 10             	shr    $0x10,%eax
f0104233:	66 a3 a6 42 22 f0    	mov    %ax,0xf02242a6
	SETGATE(idt[T_TSS], 	 0, GD_KT, Int_tss, 	0);
f0104239:	b8 48 4b 10 f0       	mov    $0xf0104b48,%eax
f010423e:	66 a3 b0 42 22 f0    	mov    %ax,0xf02242b0
f0104244:	66 c7 05 b2 42 22 f0 	movw   $0x8,0xf02242b2
f010424b:	08 00 
f010424d:	c6 05 b4 42 22 f0 00 	movb   $0x0,0xf02242b4
f0104254:	c6 05 b5 42 22 f0 8e 	movb   $0x8e,0xf02242b5
f010425b:	c1 e8 10             	shr    $0x10,%eax
f010425e:	66 a3 b6 42 22 f0    	mov    %ax,0xf02242b6
	SETGATE(idt[T_SEGNP], 	 0, GD_KT, Int_segnp, 	0);
f0104264:	b8 4c 4b 10 f0       	mov    $0xf0104b4c,%eax
f0104269:	66 a3 b8 42 22 f0    	mov    %ax,0xf02242b8
f010426f:	66 c7 05 ba 42 22 f0 	movw   $0x8,0xf02242ba
f0104276:	08 00 
f0104278:	c6 05 bc 42 22 f0 00 	movb   $0x0,0xf02242bc
f010427f:	c6 05 bd 42 22 f0 8e 	movb   $0x8e,0xf02242bd
f0104286:	c1 e8 10             	shr    $0x10,%eax
f0104289:	66 a3 be 42 22 f0    	mov    %ax,0xf02242be
	SETGATE(idt[T_STACK], 	 0, GD_KT, Int_stack, 	0);
f010428f:	b8 50 4b 10 f0       	mov    $0xf0104b50,%eax
f0104294:	66 a3 c0 42 22 f0    	mov    %ax,0xf02242c0
f010429a:	66 c7 05 c2 42 22 f0 	movw   $0x8,0xf02242c2
f01042a1:	08 00 
f01042a3:	c6 05 c4 42 22 f0 00 	movb   $0x0,0xf02242c4
f01042aa:	c6 05 c5 42 22 f0 8e 	movb   $0x8e,0xf02242c5
f01042b1:	c1 e8 10             	shr    $0x10,%eax
f01042b4:	66 a3 c6 42 22 f0    	mov    %ax,0xf02242c6
	SETGATE(idt[T_GPFLT], 	 0, GD_KT, Int_gpflt, 	0);
f01042ba:	b8 54 4b 10 f0       	mov    $0xf0104b54,%eax
f01042bf:	66 a3 c8 42 22 f0    	mov    %ax,0xf02242c8
f01042c5:	66 c7 05 ca 42 22 f0 	movw   $0x8,0xf02242ca
f01042cc:	08 00 
f01042ce:	c6 05 cc 42 22 f0 00 	movb   $0x0,0xf02242cc
f01042d5:	c6 05 cd 42 22 f0 8e 	movb   $0x8e,0xf02242cd
f01042dc:	c1 e8 10             	shr    $0x10,%eax
f01042df:	66 a3 ce 42 22 f0    	mov    %ax,0xf02242ce
	SETGATE(idt[T_PGFLT], 	 0, GD_KT, Int_pgflt, 	0);
f01042e5:	b8 58 4b 10 f0       	mov    $0xf0104b58,%eax
f01042ea:	66 a3 d0 42 22 f0    	mov    %ax,0xf02242d0
f01042f0:	66 c7 05 d2 42 22 f0 	movw   $0x8,0xf02242d2
f01042f7:	08 00 
f01042f9:	c6 05 d4 42 22 f0 00 	movb   $0x0,0xf02242d4
f0104300:	c6 05 d5 42 22 f0 8e 	movb   $0x8e,0xf02242d5
f0104307:	c1 e8 10             	shr    $0x10,%eax
f010430a:	66 a3 d6 42 22 f0    	mov    %ax,0xf02242d6
	SETGATE(idt[T_FPERR], 	 0, GD_KT, Int_fperr, 	0);
f0104310:	b8 2c 4b 10 f0       	mov    $0xf0104b2c,%eax
f0104315:	66 a3 e0 42 22 f0    	mov    %ax,0xf02242e0
f010431b:	66 c7 05 e2 42 22 f0 	movw   $0x8,0xf02242e2
f0104322:	08 00 
f0104324:	c6 05 e4 42 22 f0 00 	movb   $0x0,0xf02242e4
f010432b:	c6 05 e5 42 22 f0 8e 	movb   $0x8e,0xf02242e5
f0104332:	c1 e8 10             	shr    $0x10,%eax
f0104335:	66 a3 e6 42 22 f0    	mov    %ax,0xf02242e6
	SETGATE(idt[T_ALIGN], 	 0, GD_KT, Int_align, 	0);
f010433b:	b8 5c 4b 10 f0       	mov    $0xf0104b5c,%eax
f0104340:	66 a3 e8 42 22 f0    	mov    %ax,0xf02242e8
f0104346:	66 c7 05 ea 42 22 f0 	movw   $0x8,0xf02242ea
f010434d:	08 00 
f010434f:	c6 05 ec 42 22 f0 00 	movb   $0x0,0xf02242ec
f0104356:	c6 05 ed 42 22 f0 8e 	movb   $0x8e,0xf02242ed
f010435d:	c1 e8 10             	shr    $0x10,%eax
f0104360:	66 a3 ee 42 22 f0    	mov    %ax,0xf02242ee
	SETGATE(idt[T_MCHK], 	 0, GD_KT, Int_mchk, 	0);
f0104366:	b8 32 4b 10 f0       	mov    $0xf0104b32,%eax
f010436b:	66 a3 f0 42 22 f0    	mov    %ax,0xf02242f0
f0104371:	66 c7 05 f2 42 22 f0 	movw   $0x8,0xf02242f2
f0104378:	08 00 
f010437a:	c6 05 f4 42 22 f0 00 	movb   $0x0,0xf02242f4
f0104381:	c6 05 f5 42 22 f0 8e 	movb   $0x8e,0xf02242f5
f0104388:	c1 e8 10             	shr    $0x10,%eax
f010438b:	66 a3 f6 42 22 f0    	mov    %ax,0xf02242f6
	SETGATE(idt[T_SIMDERR],  0, GD_KT, Int_simderr, 0);
f0104391:	b8 38 4b 10 f0       	mov    $0xf0104b38,%eax
f0104396:	66 a3 f8 42 22 f0    	mov    %ax,0xf02242f8
f010439c:	66 c7 05 fa 42 22 f0 	movw   $0x8,0xf02242fa
f01043a3:	08 00 
f01043a5:	c6 05 fc 42 22 f0 00 	movb   $0x0,0xf02242fc
f01043ac:	c6 05 fd 42 22 f0 8e 	movb   $0x8e,0xf02242fd
f01043b3:	c1 e8 10             	shr    $0x10,%eax
f01043b6:	66 a3 fe 42 22 f0    	mov    %ax,0xf02242fe
	SETGATE(idt[T_SYSCALL],  0, GD_KT, Int_syscall, 3);
f01043bc:	b8 3e 4b 10 f0       	mov    $0xf0104b3e,%eax
f01043c1:	66 a3 e0 43 22 f0    	mov    %ax,0xf02243e0
f01043c7:	66 c7 05 e2 43 22 f0 	movw   $0x8,0xf02243e2
f01043ce:	08 00 
f01043d0:	c6 05 e4 43 22 f0 00 	movb   $0x0,0xf02243e4
f01043d7:	c6 05 e5 43 22 f0 ee 	movb   $0xee,0xf02243e5
f01043de:	c1 e8 10             	shr    $0x10,%eax
f01043e1:	66 a3 e6 43 22 f0    	mov    %ax,0xf02243e6
	void Int_spurious();
	void Int_ide();
	void Int_error();

	//lab 4: IRQs Settings
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 	 0, GD_KT, Int_timer, 	3);
f01043e7:	b8 60 4b 10 f0       	mov    $0xf0104b60,%eax
f01043ec:	66 a3 60 43 22 f0    	mov    %ax,0xf0224360
f01043f2:	66 c7 05 62 43 22 f0 	movw   $0x8,0xf0224362
f01043f9:	08 00 
f01043fb:	c6 05 64 43 22 f0 00 	movb   $0x0,0xf0224364
f0104402:	c6 05 65 43 22 f0 ee 	movb   $0xee,0xf0224365
f0104409:	c1 e8 10             	shr    $0x10,%eax
f010440c:	66 a3 66 43 22 f0    	mov    %ax,0xf0224366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 	 0, GD_KT, Int_kbd, 	3);
f0104412:	b8 66 4b 10 f0       	mov    $0xf0104b66,%eax
f0104417:	66 a3 68 43 22 f0    	mov    %ax,0xf0224368
f010441d:	66 c7 05 6a 43 22 f0 	movw   $0x8,0xf022436a
f0104424:	08 00 
f0104426:	c6 05 6c 43 22 f0 00 	movb   $0x0,0xf022436c
f010442d:	c6 05 6d 43 22 f0 ee 	movb   $0xee,0xf022436d
f0104434:	c1 e8 10             	shr    $0x10,%eax
f0104437:	66 a3 6e 43 22 f0    	mov    %ax,0xf022436e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 	 0, GD_KT, Int_serial, 	3);
f010443d:	b8 6c 4b 10 f0       	mov    $0xf0104b6c,%eax
f0104442:	66 a3 80 43 22 f0    	mov    %ax,0xf0224380
f0104448:	66 c7 05 82 43 22 f0 	movw   $0x8,0xf0224382
f010444f:	08 00 
f0104451:	c6 05 84 43 22 f0 00 	movb   $0x0,0xf0224384
f0104458:	c6 05 85 43 22 f0 ee 	movb   $0xee,0xf0224385
f010445f:	c1 e8 10             	shr    $0x10,%eax
f0104462:	66 a3 86 43 22 f0    	mov    %ax,0xf0224386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS],  0, GD_KT, Int_spurious,3);
f0104468:	b8 72 4b 10 f0       	mov    $0xf0104b72,%eax
f010446d:	66 a3 98 43 22 f0    	mov    %ax,0xf0224398
f0104473:	66 c7 05 9a 43 22 f0 	movw   $0x8,0xf022439a
f010447a:	08 00 
f010447c:	c6 05 9c 43 22 f0 00 	movb   $0x0,0xf022439c
f0104483:	c6 05 9d 43 22 f0 ee 	movb   $0xee,0xf022439d
f010448a:	c1 e8 10             	shr    $0x10,%eax
f010448d:	66 a3 9e 43 22 f0    	mov    %ax,0xf022439e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],  	 0, GD_KT, Int_ide,     3);
f0104493:	b8 78 4b 10 f0       	mov    $0xf0104b78,%eax
f0104498:	66 a3 d0 43 22 f0    	mov    %ax,0xf02243d0
f010449e:	66 c7 05 d2 43 22 f0 	movw   $0x8,0xf02243d2
f01044a5:	08 00 
f01044a7:	c6 05 d4 43 22 f0 00 	movb   $0x0,0xf02243d4
f01044ae:	c6 05 d5 43 22 f0 ee 	movb   $0xee,0xf02243d5
f01044b5:	c1 e8 10             	shr    $0x10,%eax
f01044b8:	66 a3 d6 43 22 f0    	mov    %ax,0xf02243d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],     0, GD_KT, Int_error,   3);
f01044be:	b8 7e 4b 10 f0       	mov    $0xf0104b7e,%eax
f01044c3:	66 a3 f8 43 22 f0    	mov    %ax,0xf02243f8
f01044c9:	66 c7 05 fa 43 22 f0 	movw   $0x8,0xf02243fa
f01044d0:	08 00 
f01044d2:	c6 05 fc 43 22 f0 00 	movb   $0x0,0xf02243fc
f01044d9:	c6 05 fd 43 22 f0 ee 	movb   $0xee,0xf02243fd
f01044e0:	c1 e8 10             	shr    $0x10,%eax
f01044e3:	66 a3 fe 43 22 f0    	mov    %ax,0xf02243fe
	// Per-CPU setup 
	trap_init_percpu();
f01044e9:	e8 a2 fa ff ff       	call   f0103f90 <trap_init_percpu>
}
f01044ee:	c9                   	leave  
f01044ef:	c3                   	ret    

f01044f0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044f0:	55                   	push   %ebp
f01044f1:	89 e5                	mov    %esp,%ebp
f01044f3:	53                   	push   %ebx
f01044f4:	83 ec 14             	sub    $0x14,%esp
f01044f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01044fa:	8b 03                	mov    (%ebx),%eax
f01044fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104500:	c7 04 24 8e 7d 10 f0 	movl   $0xf0107d8e,(%esp)
f0104507:	e8 6a fa ff ff       	call   f0103f76 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010450c:	8b 43 04             	mov    0x4(%ebx),%eax
f010450f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104513:	c7 04 24 9d 7d 10 f0 	movl   $0xf0107d9d,(%esp)
f010451a:	e8 57 fa ff ff       	call   f0103f76 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010451f:	8b 43 08             	mov    0x8(%ebx),%eax
f0104522:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104526:	c7 04 24 ac 7d 10 f0 	movl   $0xf0107dac,(%esp)
f010452d:	e8 44 fa ff ff       	call   f0103f76 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104532:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104535:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104539:	c7 04 24 bb 7d 10 f0 	movl   $0xf0107dbb,(%esp)
f0104540:	e8 31 fa ff ff       	call   f0103f76 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104545:	8b 43 10             	mov    0x10(%ebx),%eax
f0104548:	89 44 24 04          	mov    %eax,0x4(%esp)
f010454c:	c7 04 24 ca 7d 10 f0 	movl   $0xf0107dca,(%esp)
f0104553:	e8 1e fa ff ff       	call   f0103f76 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104558:	8b 43 14             	mov    0x14(%ebx),%eax
f010455b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010455f:	c7 04 24 d9 7d 10 f0 	movl   $0xf0107dd9,(%esp)
f0104566:	e8 0b fa ff ff       	call   f0103f76 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010456b:	8b 43 18             	mov    0x18(%ebx),%eax
f010456e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104572:	c7 04 24 e8 7d 10 f0 	movl   $0xf0107de8,(%esp)
f0104579:	e8 f8 f9 ff ff       	call   f0103f76 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010457e:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104581:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104585:	c7 04 24 f7 7d 10 f0 	movl   $0xf0107df7,(%esp)
f010458c:	e8 e5 f9 ff ff       	call   f0103f76 <cprintf>
}
f0104591:	83 c4 14             	add    $0x14,%esp
f0104594:	5b                   	pop    %ebx
f0104595:	5d                   	pop    %ebp
f0104596:	c3                   	ret    

f0104597 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104597:	55                   	push   %ebp
f0104598:	89 e5                	mov    %esp,%ebp
f010459a:	53                   	push   %ebx
f010459b:	83 ec 14             	sub    $0x14,%esp
f010459e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01045a1:	e8 56 1e 00 00       	call   f01063fc <cpunum>
f01045a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045ae:	c7 04 24 5b 7e 10 f0 	movl   $0xf0107e5b,(%esp)
f01045b5:	e8 bc f9 ff ff       	call   f0103f76 <cprintf>
	print_regs(&tf->tf_regs);
f01045ba:	89 1c 24             	mov    %ebx,(%esp)
f01045bd:	e8 2e ff ff ff       	call   f01044f0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01045c2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01045c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ca:	c7 04 24 79 7e 10 f0 	movl   $0xf0107e79,(%esp)
f01045d1:	e8 a0 f9 ff ff       	call   f0103f76 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01045d6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01045da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045de:	c7 04 24 8c 7e 10 f0 	movl   $0xf0107e8c,(%esp)
f01045e5:	e8 8c f9 ff ff       	call   f0103f76 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045ea:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01045ed:	83 f8 13             	cmp    $0x13,%eax
f01045f0:	77 09                	ja     f01045fb <print_trapframe+0x64>
		return excnames[trapno];
f01045f2:	8b 14 85 20 81 10 f0 	mov    -0xfef7ee0(,%eax,4),%edx
f01045f9:	eb 20                	jmp    f010461b <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01045fb:	83 f8 30             	cmp    $0x30,%eax
f01045fe:	74 0f                	je     f010460f <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104600:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104603:	83 fa 0f             	cmp    $0xf,%edx
f0104606:	77 0e                	ja     f0104616 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f0104608:	ba 12 7e 10 f0       	mov    $0xf0107e12,%edx
f010460d:	eb 0c                	jmp    f010461b <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010460f:	ba 06 7e 10 f0       	mov    $0xf0107e06,%edx
f0104614:	eb 05                	jmp    f010461b <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104616:	ba 25 7e 10 f0       	mov    $0xf0107e25,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010461b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010461f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104623:	c7 04 24 9f 7e 10 f0 	movl   $0xf0107e9f,(%esp)
f010462a:	e8 47 f9 ff ff       	call   f0103f76 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010462f:	3b 1d 60 4a 22 f0    	cmp    0xf0224a60,%ebx
f0104635:	75 19                	jne    f0104650 <print_trapframe+0xb9>
f0104637:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010463b:	75 13                	jne    f0104650 <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010463d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104640:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104644:	c7 04 24 b1 7e 10 f0 	movl   $0xf0107eb1,(%esp)
f010464b:	e8 26 f9 ff ff       	call   f0103f76 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104650:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104653:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104657:	c7 04 24 c0 7e 10 f0 	movl   $0xf0107ec0,(%esp)
f010465e:	e8 13 f9 ff ff       	call   f0103f76 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104663:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104667:	75 4d                	jne    f01046b6 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104669:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010466c:	a8 01                	test   $0x1,%al
f010466e:	74 07                	je     f0104677 <print_trapframe+0xe0>
f0104670:	b9 34 7e 10 f0       	mov    $0xf0107e34,%ecx
f0104675:	eb 05                	jmp    f010467c <print_trapframe+0xe5>
f0104677:	b9 3f 7e 10 f0       	mov    $0xf0107e3f,%ecx
f010467c:	a8 02                	test   $0x2,%al
f010467e:	74 07                	je     f0104687 <print_trapframe+0xf0>
f0104680:	ba 4b 7e 10 f0       	mov    $0xf0107e4b,%edx
f0104685:	eb 05                	jmp    f010468c <print_trapframe+0xf5>
f0104687:	ba 51 7e 10 f0       	mov    $0xf0107e51,%edx
f010468c:	a8 04                	test   $0x4,%al
f010468e:	74 07                	je     f0104697 <print_trapframe+0x100>
f0104690:	b8 56 7e 10 f0       	mov    $0xf0107e56,%eax
f0104695:	eb 05                	jmp    f010469c <print_trapframe+0x105>
f0104697:	b8 a7 7f 10 f0       	mov    $0xf0107fa7,%eax
f010469c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046a0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01046a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046a8:	c7 04 24 ce 7e 10 f0 	movl   $0xf0107ece,(%esp)
f01046af:	e8 c2 f8 ff ff       	call   f0103f76 <cprintf>
f01046b4:	eb 0c                	jmp    f01046c2 <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01046b6:	c7 04 24 b6 7c 10 f0 	movl   $0xf0107cb6,(%esp)
f01046bd:	e8 b4 f8 ff ff       	call   f0103f76 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01046c2:	8b 43 30             	mov    0x30(%ebx),%eax
f01046c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046c9:	c7 04 24 dd 7e 10 f0 	movl   $0xf0107edd,(%esp)
f01046d0:	e8 a1 f8 ff ff       	call   f0103f76 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01046d5:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01046d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046dd:	c7 04 24 ec 7e 10 f0 	movl   $0xf0107eec,(%esp)
f01046e4:	e8 8d f8 ff ff       	call   f0103f76 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01046e9:	8b 43 38             	mov    0x38(%ebx),%eax
f01046ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046f0:	c7 04 24 ff 7e 10 f0 	movl   $0xf0107eff,(%esp)
f01046f7:	e8 7a f8 ff ff       	call   f0103f76 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01046fc:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104700:	74 27                	je     f0104729 <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104702:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104705:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104709:	c7 04 24 0e 7f 10 f0 	movl   $0xf0107f0e,(%esp)
f0104710:	e8 61 f8 ff ff       	call   f0103f76 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104715:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104719:	89 44 24 04          	mov    %eax,0x4(%esp)
f010471d:	c7 04 24 1d 7f 10 f0 	movl   $0xf0107f1d,(%esp)
f0104724:	e8 4d f8 ff ff       	call   f0103f76 <cprintf>
	}
}
f0104729:	83 c4 14             	add    $0x14,%esp
f010472c:	5b                   	pop    %ebx
f010472d:	5d                   	pop    %ebp
f010472e:	c3                   	ret    

f010472f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010472f:	55                   	push   %ebp
f0104730:	89 e5                	mov    %esp,%ebp
f0104732:	57                   	push   %edi
f0104733:	56                   	push   %esi
f0104734:	53                   	push   %ebx
f0104735:	83 ec 2c             	sub    $0x2c,%esp
f0104738:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010473b:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 3) == 0){
f010473e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104742:	75 1c                	jne    f0104760 <page_fault_handler+0x31>
		panic("page fault in kernel mode!\n");
f0104744:	c7 44 24 08 30 7f 10 	movl   $0xf0107f30,0x8(%esp)
f010474b:	f0 
f010474c:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f0104753:	00 
f0104754:	c7 04 24 4c 7f 10 f0 	movl   $0xf0107f4c,(%esp)
f010475b:	e8 e0 b8 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	struct UTrapframe *utf;
	
	if (curenv->env_pgfault_upcall) {
f0104760:	e8 97 1c 00 00       	call   f01063fc <cpunum>
f0104765:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010476c:	29 c2                	sub    %eax,%edx
f010476e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104771:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104778:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010477c:	0f 84 d4 00 00 00    	je     f0104856 <page_fault_handler+0x127>
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE) {
f0104782:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104785:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			//In the exception stack
			utf = (struct UTrapframe*)(tf->tf_esp-4-sizeof(struct UTrapframe));
		} else {
			// outside the exception stack
			utf = (struct UTrapframe*)(UXSTACKTOP-sizeof(struct UTrapframe));
f010478b:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)

	// Destroy the environment that caused the fault.
	struct UTrapframe *utf;
	
	if (curenv->env_pgfault_upcall) {
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE) {
f0104792:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104798:	77 06                	ja     f01047a0 <page_fault_handler+0x71>
			//In the exception stack
			utf = (struct UTrapframe*)(tf->tf_esp-4-sizeof(struct UTrapframe));
f010479a:	83 e8 38             	sub    $0x38,%eax
f010479d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		} else {
			// outside the exception stack
			utf = (struct UTrapframe*)(UXSTACKTOP-sizeof(struct UTrapframe));
		}
		
		user_mem_assert(curenv, (const void *) utf, 
f01047a0:	e8 57 1c 00 00       	call   f01063fc <cpunum>
f01047a5:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
f01047ac:	00 
f01047ad:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01047b4:	00 
f01047b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047b8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01047bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01047bf:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f01047c5:	89 04 24             	mov    %eax,(%esp)
f01047c8:	e8 90 ed ff ff       	call   f010355d <user_mem_assert>
			sizeof(struct UTrapframe), PTE_P|PTE_W);
				
		utf->utf_fault_va = fault_va;	
f01047cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047d0:	89 30                	mov    %esi,(%eax)
		utf->utf_err = tf->tf_trapno;
f01047d2:	8b 43 28             	mov    0x28(%ebx),%eax
f01047d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047d8:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs = tf->tf_regs;
f01047db:	89 d7                	mov    %edx,%edi
f01047dd:	83 c7 08             	add    $0x8,%edi
f01047e0:	89 de                	mov    %ebx,%esi
f01047e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01047e7:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01047ed:	74 03                	je     f01047f2 <page_fault_handler+0xc3>
f01047ef:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01047f0:	b0 1f                	mov    $0x1f,%al
f01047f2:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01047f8:	74 05                	je     f01047ff <page_fault_handler+0xd0>
f01047fa:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01047fc:	83 e8 02             	sub    $0x2,%eax
f01047ff:	89 c1                	mov    %eax,%ecx
f0104801:	c1 e9 02             	shr    $0x2,%ecx
f0104804:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104806:	a8 02                	test   $0x2,%al
f0104808:	74 02                	je     f010480c <page_fault_handler+0xdd>
f010480a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010480c:	a8 01                	test   $0x1,%al
f010480e:	74 01                	je     f0104811 <page_fault_handler+0xe2>
f0104810:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0104811:	8b 43 30             	mov    0x30(%ebx),%eax
f0104814:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104817:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f010481a:	8b 43 38             	mov    0x38(%ebx),%eax
f010481d:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104820:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104823:	89 42 30             	mov    %eax,0x30(%edx)
		
		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104826:	e8 d1 1b 00 00       	call   f01063fc <cpunum>
f010482b:	6b c0 74             	imul   $0x74,%eax,%eax
f010482e:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104834:	8b 40 64             	mov    0x64(%eax),%eax
f0104837:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uint32_t)utf;
f010483a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010483d:	89 43 3c             	mov    %eax,0x3c(%ebx)
		env_run(curenv);
f0104840:	e8 b7 1b 00 00       	call   f01063fc <cpunum>
f0104845:	6b c0 74             	imul   $0x74,%eax,%eax
f0104848:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010484e:	89 04 24             	mov    %eax,(%esp)
f0104851:	e8 b6 f4 ff ff       	call   f0103d0c <env_run>
	} else {		
		// Destroy the environment that caused the fault.	
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104856:	8b 7b 30             	mov    0x30(%ebx),%edi
				curenv->env_id, fault_va, tf->tf_eip);
f0104859:	e8 9e 1b 00 00       	call   f01063fc <cpunum>
		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
		tf->tf_esp = (uint32_t)utf;
		env_run(curenv);
	} else {		
		// Destroy the environment that caused the fault.	
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010485e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104862:	89 74 24 08          	mov    %esi,0x8(%esp)
				curenv->env_id, fault_va, tf->tf_eip);
f0104866:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010486d:	29 c2                	sub    %eax,%edx
f010486f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104872:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
		tf->tf_esp = (uint32_t)utf;
		env_run(curenv);
	} else {		
		// Destroy the environment that caused the fault.	
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104879:	8b 40 48             	mov    0x48(%eax),%eax
f010487c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104880:	c7 04 24 f4 80 10 f0 	movl   $0xf01080f4,(%esp)
f0104887:	e8 ea f6 ff ff       	call   f0103f76 <cprintf>
				curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f010488c:	89 1c 24             	mov    %ebx,(%esp)
f010488f:	e8 03 fd ff ff       	call   f0104597 <print_trapframe>
		env_destroy(curenv);
f0104894:	e8 63 1b 00 00       	call   f01063fc <cpunum>
f0104899:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048a0:	29 c2                	sub    %eax,%edx
f01048a2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048a5:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f01048ac:	89 04 24             	mov    %eax,(%esp)
f01048af:	e8 99 f3 ff ff       	call   f0103c4d <env_destroy>
	}
}
f01048b4:	83 c4 2c             	add    $0x2c,%esp
f01048b7:	5b                   	pop    %ebx
f01048b8:	5e                   	pop    %esi
f01048b9:	5f                   	pop    %edi
f01048ba:	5d                   	pop    %ebp
f01048bb:	c3                   	ret    

f01048bc <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01048bc:	55                   	push   %ebp
f01048bd:	89 e5                	mov    %esp,%ebp
f01048bf:	57                   	push   %edi
f01048c0:	56                   	push   %esi
f01048c1:	83 ec 20             	sub    $0x20,%esp
f01048c4:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01048c7:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01048c8:	83 3d 80 4e 22 f0 00 	cmpl   $0x0,0xf0224e80
f01048cf:	74 01                	je     f01048d2 <trap+0x16>
		asm volatile("hlt");
f01048d1:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01048d2:	e8 25 1b 00 00       	call   f01063fc <cpunum>
f01048d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048de:	29 c2                	sub    %eax,%edx
f01048e0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048e3:	8d 14 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01048ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01048ef:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01048f3:	83 f8 02             	cmp    $0x2,%eax
f01048f6:	75 0c                	jne    f0104904 <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01048f8:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f01048ff:	e8 b7 1d 00 00       	call   f01066bb <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104904:	9c                   	pushf  
f0104905:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104906:	f6 c4 02             	test   $0x2,%ah
f0104909:	74 24                	je     f010492f <trap+0x73>
f010490b:	c7 44 24 0c 58 7f 10 	movl   $0xf0107f58,0xc(%esp)
f0104912:	f0 
f0104913:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010491a:	f0 
f010491b:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
f0104922:	00 
f0104923:	c7 04 24 4c 7f 10 f0 	movl   $0xf0107f4c,(%esp)
f010492a:	e8 11 b7 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010492f:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104933:	83 e0 03             	and    $0x3,%eax
f0104936:	83 f8 03             	cmp    $0x3,%eax
f0104939:	0f 85 a7 00 00 00    	jne    f01049e6 <trap+0x12a>
f010493f:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104946:	e8 70 1d 00 00       	call   f01066bb <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f010494b:	e8 ac 1a 00 00       	call   f01063fc <cpunum>
f0104950:	6b c0 74             	imul   $0x74,%eax,%eax
f0104953:	83 b8 28 50 22 f0 00 	cmpl   $0x0,-0xfddafd8(%eax)
f010495a:	75 24                	jne    f0104980 <trap+0xc4>
f010495c:	c7 44 24 0c 71 7f 10 	movl   $0xf0107f71,0xc(%esp)
f0104963:	f0 
f0104964:	c7 44 24 08 cb 79 10 	movl   $0xf01079cb,0x8(%esp)
f010496b:	f0 
f010496c:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
f0104973:	00 
f0104974:	c7 04 24 4c 7f 10 f0 	movl   $0xf0107f4c,(%esp)
f010497b:	e8 c0 b6 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104980:	e8 77 1a 00 00       	call   f01063fc <cpunum>
f0104985:	6b c0 74             	imul   $0x74,%eax,%eax
f0104988:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010498e:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104992:	75 2d                	jne    f01049c1 <trap+0x105>
			env_free(curenv);
f0104994:	e8 63 1a 00 00       	call   f01063fc <cpunum>
f0104999:	6b c0 74             	imul   $0x74,%eax,%eax
f010499c:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f01049a2:	89 04 24             	mov    %eax,(%esp)
f01049a5:	e8 ca f0 ff ff       	call   f0103a74 <env_free>
			curenv = NULL;
f01049aa:	e8 4d 1a 00 00       	call   f01063fc <cpunum>
f01049af:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b2:	c7 80 28 50 22 f0 00 	movl   $0x0,-0xfddafd8(%eax)
f01049b9:	00 00 00 
			sched_yield();
f01049bc:	e8 c9 02 00 00       	call   f0104c8a <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01049c1:	e8 36 1a 00 00       	call   f01063fc <cpunum>
f01049c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c9:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f01049cf:	b9 11 00 00 00       	mov    $0x11,%ecx
f01049d4:	89 c7                	mov    %eax,%edi
f01049d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01049d8:	e8 1f 1a 00 00       	call   f01063fc <cpunum>
f01049dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e0:	8b b0 28 50 22 f0    	mov    -0xfddafd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01049e6:	89 35 60 4a 22 f0    	mov    %esi,0xf0224a60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01049ec:	8b 46 28             	mov    0x28(%esi),%eax
f01049ef:	83 f8 27             	cmp    $0x27,%eax
f01049f2:	75 19                	jne    f0104a0d <trap+0x151>
		cprintf("Spurious interrupt on irq 7\n");
f01049f4:	c7 04 24 78 7f 10 f0 	movl   $0xf0107f78,(%esp)
f01049fb:	e8 76 f5 ff ff       	call   f0103f76 <cprintf>
		print_trapframe(tf);
f0104a00:	89 34 24             	mov    %esi,(%esp)
f0104a03:	e8 8f fb ff ff       	call   f0104597 <print_trapframe>
f0104a08:	e9 a8 00 00 00       	jmp    f0104ab5 <trap+0x1f9>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104a0d:	83 f8 20             	cmp    $0x20,%eax
f0104a10:	75 0a                	jne    f0104a1c <trap+0x160>
		lapic_eoi();
f0104a12:	e8 3c 1b 00 00       	call   f0106553 <lapic_eoi>
		sched_yield();
f0104a17:	e8 6e 02 00 00       	call   f0104c8a <sched_yield>
		return;
	}

	if (tf->tf_trapno == T_PGFLT){
f0104a1c:	83 f8 0e             	cmp    $0xe,%eax
f0104a1f:	75 0d                	jne    f0104a2e <trap+0x172>
		page_fault_handler(tf);
f0104a21:	89 34 24             	mov    %esi,(%esp)
f0104a24:	e8 06 fd ff ff       	call   f010472f <page_fault_handler>
f0104a29:	e9 87 00 00 00       	jmp    f0104ab5 <trap+0x1f9>
		return;
	}
	if (tf->tf_trapno == T_BRKPT){
f0104a2e:	83 f8 03             	cmp    $0x3,%eax
f0104a31:	75 0a                	jne    f0104a3d <trap+0x181>
		monitor(tf);
f0104a33:	89 34 24             	mov    %esi,(%esp)
f0104a36:	e8 5e bf ff ff       	call   f0100999 <monitor>
f0104a3b:	eb 78                	jmp    f0104ab5 <trap+0x1f9>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL){
f0104a3d:	83 f8 30             	cmp    $0x30,%eax
f0104a40:	75 32                	jne    f0104a74 <trap+0x1b8>
		struct PushRegs* regs = &tf->tf_regs;
		regs->reg_eax = syscall(regs->reg_eax,regs->reg_edx, regs->reg_ecx, 
f0104a42:	8b 46 04             	mov    0x4(%esi),%eax
f0104a45:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104a49:	8b 06                	mov    (%esi),%eax
f0104a4b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a4f:	8b 46 10             	mov    0x10(%esi),%eax
f0104a52:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a56:	8b 46 18             	mov    0x18(%esi),%eax
f0104a59:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a5d:	8b 46 14             	mov    0x14(%esi),%eax
f0104a60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a64:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104a67:	89 04 24             	mov    %eax,(%esp)
f0104a6a:	e8 c5 02 00 00       	call   f0104d34 <syscall>
f0104a6f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a72:	eb 41                	jmp    f0104ab5 <trap+0x1f9>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104a74:	89 34 24             	mov    %esi,(%esp)
f0104a77:	e8 1b fb ff ff       	call   f0104597 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104a7c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104a81:	75 1c                	jne    f0104a9f <trap+0x1e3>
		panic("unhandled trap in kernel");
f0104a83:	c7 44 24 08 95 7f 10 	movl   $0xf0107f95,0x8(%esp)
f0104a8a:	f0 
f0104a8b:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f0104a92:	00 
f0104a93:	c7 04 24 4c 7f 10 f0 	movl   $0xf0107f4c,(%esp)
f0104a9a:	e8 a1 b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104a9f:	e8 58 19 00 00       	call   f01063fc <cpunum>
f0104aa4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa7:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104aad:	89 04 24             	mov    %eax,(%esp)
f0104ab0:	e8 98 f1 ff ff       	call   f0103c4d <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104ab5:	e8 42 19 00 00       	call   f01063fc <cpunum>
f0104aba:	6b c0 74             	imul   $0x74,%eax,%eax
f0104abd:	83 b8 28 50 22 f0 00 	cmpl   $0x0,-0xfddafd8(%eax)
f0104ac4:	74 2a                	je     f0104af0 <trap+0x234>
f0104ac6:	e8 31 19 00 00       	call   f01063fc <cpunum>
f0104acb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ace:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104ad4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ad8:	75 16                	jne    f0104af0 <trap+0x234>
		env_run(curenv);
f0104ada:	e8 1d 19 00 00       	call   f01063fc <cpunum>
f0104adf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae2:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104ae8:	89 04 24             	mov    %eax,(%esp)
f0104aeb:	e8 1c f2 ff ff       	call   f0103d0c <env_run>
	else
		sched_yield();
f0104af0:	e8 95 01 00 00       	call   f0104c8a <sched_yield>
f0104af5:	00 00                	add    %al,(%eax)
	...

f0104af8 <Int_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 // Error Code : no
TRAPHANDLER_NOEC(Int_divide, T_DIVIDE)
f0104af8:	6a 00                	push   $0x0
f0104afa:	6a 00                	push   $0x0
f0104afc:	e9 83 00 00 00       	jmp    f0104b84 <_alltraps>
f0104b01:	90                   	nop

f0104b02 <Int_debug>:
TRAPHANDLER_NOEC(Int_debug, T_DEBUG)
f0104b02:	6a 00                	push   $0x0
f0104b04:	6a 01                	push   $0x1
f0104b06:	eb 7c                	jmp    f0104b84 <_alltraps>

f0104b08 <Int_nmi>:
TRAPHANDLER_NOEC(Int_nmi, T_NMI)
f0104b08:	6a 00                	push   $0x0
f0104b0a:	6a 02                	push   $0x2
f0104b0c:	eb 76                	jmp    f0104b84 <_alltraps>

f0104b0e <Int_brkpt>:
TRAPHANDLER_NOEC(Int_brkpt, T_BRKPT)
f0104b0e:	6a 00                	push   $0x0
f0104b10:	6a 03                	push   $0x3
f0104b12:	eb 70                	jmp    f0104b84 <_alltraps>

f0104b14 <Int_oflow>:
TRAPHANDLER_NOEC(Int_oflow, T_OFLOW)
f0104b14:	6a 00                	push   $0x0
f0104b16:	6a 04                	push   $0x4
f0104b18:	eb 6a                	jmp    f0104b84 <_alltraps>

f0104b1a <Int_bound>:
TRAPHANDLER_NOEC(Int_bound, T_BOUND)
f0104b1a:	6a 00                	push   $0x0
f0104b1c:	6a 05                	push   $0x5
f0104b1e:	eb 64                	jmp    f0104b84 <_alltraps>

f0104b20 <Int_illop>:
TRAPHANDLER_NOEC(Int_illop, T_ILLOP)
f0104b20:	6a 00                	push   $0x0
f0104b22:	6a 06                	push   $0x6
f0104b24:	eb 5e                	jmp    f0104b84 <_alltraps>

f0104b26 <Int_device>:
TRAPHANDLER_NOEC(Int_device, T_DEVICE)
f0104b26:	6a 00                	push   $0x0
f0104b28:	6a 07                	push   $0x7
f0104b2a:	eb 58                	jmp    f0104b84 <_alltraps>

f0104b2c <Int_fperr>:
TRAPHANDLER_NOEC(Int_fperr, T_FPERR)
f0104b2c:	6a 00                	push   $0x0
f0104b2e:	6a 10                	push   $0x10
f0104b30:	eb 52                	jmp    f0104b84 <_alltraps>

f0104b32 <Int_mchk>:
TRAPHANDLER_NOEC(Int_mchk, T_MCHK)
f0104b32:	6a 00                	push   $0x0
f0104b34:	6a 12                	push   $0x12
f0104b36:	eb 4c                	jmp    f0104b84 <_alltraps>

f0104b38 <Int_simderr>:
TRAPHANDLER_NOEC(Int_simderr, T_SIMDERR)
f0104b38:	6a 00                	push   $0x0
f0104b3a:	6a 13                	push   $0x13
f0104b3c:	eb 46                	jmp    f0104b84 <_alltraps>

f0104b3e <Int_syscall>:
TRAPHANDLER_NOEC(Int_syscall, T_SYSCALL)
f0104b3e:	6a 00                	push   $0x0
f0104b40:	6a 30                	push   $0x30
f0104b42:	eb 40                	jmp    f0104b84 <_alltraps>

f0104b44 <Int_dblflt>:
 // Error Code : yes
TRAPHANDLER(Int_dblflt, T_DBLFLT)
f0104b44:	6a 08                	push   $0x8
f0104b46:	eb 3c                	jmp    f0104b84 <_alltraps>

f0104b48 <Int_tss>:
TRAPHANDLER(Int_tss, T_TSS)
f0104b48:	6a 0a                	push   $0xa
f0104b4a:	eb 38                	jmp    f0104b84 <_alltraps>

f0104b4c <Int_segnp>:
TRAPHANDLER(Int_segnp, T_SEGNP)
f0104b4c:	6a 0b                	push   $0xb
f0104b4e:	eb 34                	jmp    f0104b84 <_alltraps>

f0104b50 <Int_stack>:
TRAPHANDLER(Int_stack, T_STACK)
f0104b50:	6a 0c                	push   $0xc
f0104b52:	eb 30                	jmp    f0104b84 <_alltraps>

f0104b54 <Int_gpflt>:
TRAPHANDLER(Int_gpflt, T_GPFLT)
f0104b54:	6a 0d                	push   $0xd
f0104b56:	eb 2c                	jmp    f0104b84 <_alltraps>

f0104b58 <Int_pgflt>:
TRAPHANDLER(Int_pgflt, T_PGFLT)
f0104b58:	6a 0e                	push   $0xe
f0104b5a:	eb 28                	jmp    f0104b84 <_alltraps>

f0104b5c <Int_align>:
TRAPHANDLER(Int_align, T_ALIGN)
f0104b5c:	6a 11                	push   $0x11
f0104b5e:	eb 24                	jmp    f0104b84 <_alltraps>

f0104b60 <Int_timer>:

TRAPHANDLER_NOEC(Int_timer, IRQ_OFFSET + IRQ_TIMER)
f0104b60:	6a 00                	push   $0x0
f0104b62:	6a 20                	push   $0x20
f0104b64:	eb 1e                	jmp    f0104b84 <_alltraps>

f0104b66 <Int_kbd>:
TRAPHANDLER_NOEC(Int_kbd, IRQ_OFFSET + IRQ_KBD)
f0104b66:	6a 00                	push   $0x0
f0104b68:	6a 21                	push   $0x21
f0104b6a:	eb 18                	jmp    f0104b84 <_alltraps>

f0104b6c <Int_serial>:
TRAPHANDLER_NOEC(Int_serial, IRQ_OFFSET + IRQ_SERIAL)
f0104b6c:	6a 00                	push   $0x0
f0104b6e:	6a 24                	push   $0x24
f0104b70:	eb 12                	jmp    f0104b84 <_alltraps>

f0104b72 <Int_spurious>:
TRAPHANDLER_NOEC(Int_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f0104b72:	6a 00                	push   $0x0
f0104b74:	6a 27                	push   $0x27
f0104b76:	eb 0c                	jmp    f0104b84 <_alltraps>

f0104b78 <Int_ide>:
TRAPHANDLER_NOEC(Int_ide, IRQ_OFFSET + IRQ_IDE)
f0104b78:	6a 00                	push   $0x0
f0104b7a:	6a 2e                	push   $0x2e
f0104b7c:	eb 06                	jmp    f0104b84 <_alltraps>

f0104b7e <Int_error>:
TRAPHANDLER_NOEC(Int_error, IRQ_OFFSET + IRQ_ERROR)
f0104b7e:	6a 00                	push   $0x0
f0104b80:	6a 33                	push   $0x33
f0104b82:	eb 00                	jmp    f0104b84 <_alltraps>

f0104b84 <_alltraps>:
	
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104b84:	1e                   	push   %ds
	pushl %es	
f0104b85:	06                   	push   %es
	pushal
f0104b86:	60                   	pusha  
	movw $GD_KD, %ax
f0104b87:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104b8b:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104b8d:	8e c0                	mov    %eax,%es
	pushl %esp
f0104b8f:	54                   	push   %esp
	call trap
f0104b90:	e8 27 fd ff ff       	call   f01048bc <trap>
f0104b95:	00 00                	add    %al,(%eax)
	...

f0104b98 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104b98:	55                   	push   %ebp
f0104b99:	89 e5                	mov    %esp,%ebp
f0104b9b:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104b9e:	8b 15 48 42 22 f0    	mov    0xf0224248,%edx
f0104ba4:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ba7:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104bac:	8b 0a                	mov    (%edx),%ecx
f0104bae:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104baf:	83 f9 02             	cmp    $0x2,%ecx
f0104bb2:	76 0d                	jbe    f0104bc1 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104bb4:	40                   	inc    %eax
f0104bb5:	83 c2 7c             	add    $0x7c,%edx
f0104bb8:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104bbd:	75 ed                	jne    f0104bac <sched_halt+0x14>
f0104bbf:	eb 07                	jmp    f0104bc8 <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104bc1:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104bc6:	75 1a                	jne    f0104be2 <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104bc8:	c7 04 24 70 81 10 f0 	movl   $0xf0108170,(%esp)
f0104bcf:	e8 a2 f3 ff ff       	call   f0103f76 <cprintf>
		while (1)
			monitor(NULL);
f0104bd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104bdb:	e8 b9 bd ff ff       	call   f0100999 <monitor>
f0104be0:	eb f2                	jmp    f0104bd4 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104be2:	e8 15 18 00 00       	call   f01063fc <cpunum>
f0104be7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104bee:	29 c2                	sub    %eax,%edx
f0104bf0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bf3:	c7 04 85 28 50 22 f0 	movl   $0x0,-0xfddafd8(,%eax,4)
f0104bfa:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104bfe:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104c03:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c08:	77 20                	ja     f0104c2a <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c0e:	c7 44 24 08 e4 6a 10 	movl   $0xf0106ae4,0x8(%esp)
f0104c15:	f0 
f0104c16:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
f0104c1d:	00 
f0104c1e:	c7 04 24 99 81 10 f0 	movl   $0xf0108199,(%esp)
f0104c25:	e8 16 b4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104c2a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104c2f:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104c32:	e8 c5 17 00 00       	call   f01063fc <cpunum>
f0104c37:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c3e:	29 c2                	sub    %eax,%edx
f0104c40:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c43:	8d 14 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104c4a:	b8 02 00 00 00       	mov    $0x2,%eax
f0104c4f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104c53:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104c5a:	e8 ff 1a 00 00       	call   f010675e <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104c5f:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104c61:	e8 96 17 00 00       	call   f01063fc <cpunum>
f0104c66:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c6d:	29 c2                	sub    %eax,%edx
f0104c6f:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104c72:	8b 04 85 30 50 22 f0 	mov    -0xfddafd0(,%eax,4),%eax
f0104c79:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104c7e:	89 c4                	mov    %eax,%esp
f0104c80:	6a 00                	push   $0x0
f0104c82:	6a 00                	push   $0x0
f0104c84:	fb                   	sti    
f0104c85:	f4                   	hlt    
f0104c86:	eb fd                	jmp    f0104c85 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104c88:	c9                   	leave  
f0104c89:	c3                   	ret    

f0104c8a <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104c8a:	55                   	push   %ebp
f0104c8b:	89 e5                	mov    %esp,%ebp
f0104c8d:	57                   	push   %edi
f0104c8e:	56                   	push   %esi
f0104c8f:	53                   	push   %ebx
f0104c90:	83 ec 1c             	sub    $0x1c,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *i = thiscpu->cpu_env;
f0104c93:	e8 64 17 00 00       	call   f01063fc <cpunum>
f0104c98:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c9f:	29 c2                	sub    %eax,%edx
f0104ca1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ca4:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
	int32_t startid = (i) ? ENVX(i->env_id): 0;
f0104cab:	85 c0                	test   %eax,%eax
f0104cad:	74 0a                	je     f0104cb9 <sched_yield+0x2f>
f0104caf:	8b 40 48             	mov    0x48(%eax),%eax
f0104cb2:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104cb7:	eb 05                	jmp    f0104cbe <sched_yield+0x34>
f0104cb9:	b8 00 00 00 00       	mov    $0x0,%eax
	int32_t nextid;
	size_t j;

	for(j = 0; j < NENV; j++) {
     		nextid = (startid+j)%NENV;
     		if(envs[nextid].env_status == ENV_RUNNABLE) {
f0104cbe:	8b 0d 48 42 22 f0    	mov    0xf0224248,%ecx
f0104cc4:	89 c6                	mov    %eax,%esi

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f0104cc6:	8d 98 00 04 00 00    	lea    0x400(%eax),%ebx
	int32_t startid = (i) ? ENVX(i->env_id): 0;
	int32_t nextid;
	size_t j;

	for(j = 0; j < NENV; j++) {
     		nextid = (startid+j)%NENV;
f0104ccc:	89 c2                	mov    %eax,%edx
f0104cce:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
     		if(envs[nextid].env_status == ENV_RUNNABLE) {
f0104cd4:	8d 3c 95 00 00 00 00 	lea    0x0(,%edx,4),%edi
f0104cdb:	c1 e2 07             	shl    $0x7,%edx
f0104cde:	29 fa                	sub    %edi,%edx
f0104ce0:	01 ca                	add    %ecx,%edx
f0104ce2:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104ce6:	75 08                	jne    f0104cf0 <sched_yield+0x66>
             		env_run(&envs[nextid]);
f0104ce8:	89 14 24             	mov    %edx,(%esp)
f0104ceb:	e8 1c f0 ff ff       	call   f0103d0c <env_run>
f0104cf0:	40                   	inc    %eax
	struct Env *i = thiscpu->cpu_env;
	int32_t startid = (i) ? ENVX(i->env_id): 0;
	int32_t nextid;
	size_t j;

	for(j = 0; j < NENV; j++) {
f0104cf1:	39 d8                	cmp    %ebx,%eax
f0104cf3:	75 d7                	jne    f0104ccc <sched_yield+0x42>
             		env_run(&envs[nextid]);
             		return;
	        }
	}
 
	if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f0104cf5:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
f0104cfc:	89 f3                	mov    %esi,%ebx
f0104cfe:	c1 e3 07             	shl    $0x7,%ebx
f0104d01:	29 c3                	sub    %eax,%ebx
f0104d03:	01 d9                	add    %ebx,%ecx
f0104d05:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f0104d09:	75 1a                	jne    f0104d25 <sched_yield+0x9b>
f0104d0b:	8b 71 5c             	mov    0x5c(%ecx),%esi
f0104d0e:	e8 e9 16 00 00       	call   f01063fc <cpunum>
f0104d13:	39 c6                	cmp    %eax,%esi
f0104d15:	75 0e                	jne    f0104d25 <sched_yield+0x9b>
		env_run(&envs[startid]);
f0104d17:	03 1d 48 42 22 f0    	add    0xf0224248,%ebx
f0104d1d:	89 1c 24             	mov    %ebx,(%esp)
f0104d20:	e8 e7 ef ff ff       	call   f0103d0c <env_run>
	}
 
	// sched_halt never returns
 	sched_halt();
f0104d25:	e8 6e fe ff ff       	call   f0104b98 <sched_halt>
}
f0104d2a:	83 c4 1c             	add    $0x1c,%esp
f0104d2d:	5b                   	pop    %ebx
f0104d2e:	5e                   	pop    %esi
f0104d2f:	5f                   	pop    %edi
f0104d30:	5d                   	pop    %ebp
f0104d31:	c3                   	ret    
	...

f0104d34 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d34:	55                   	push   %ebp
f0104d35:	89 e5                	mov    %esp,%ebp
f0104d37:	57                   	push   %edi
f0104d38:	56                   	push   %esi
f0104d39:	53                   	push   %ebx
f0104d3a:	83 ec 2c             	sub    $0x2c,%esp
f0104d3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d40:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104d43:	8b 75 10             	mov    0x10(%ebp),%esi
f0104d46:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104d49:	83 f8 0d             	cmp    $0xd,%eax
f0104d4c:	0f 87 76 05 00 00    	ja     f01052c8 <syscall+0x594>
f0104d52:	ff 24 85 ac 81 10 f0 	jmp    *-0xfef7e54(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104d59:	e8 9e 16 00 00       	call   f01063fc <cpunum>
f0104d5e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104d65:	00 
f0104d66:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104d6a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104d6e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d75:	29 c2                	sub    %eax,%edx
f0104d77:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d7a:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104d81:	89 04 24             	mov    %eax,(%esp)
f0104d84:	e8 d4 e7 ff ff       	call   f010355d <user_mem_assert>
	
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104d89:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104d8d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d91:	c7 04 24 a6 81 10 f0 	movl   $0xf01081a6,(%esp)
f0104d98:	e8 d9 f1 ff ff       	call   f0103f76 <cprintf>
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char *)a1,a2);
		return -E_INVAL;
f0104d9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104da2:	e9 2d 05 00 00       	jmp    f01052d4 <syscall+0x5a0>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104da7:	e8 aa b8 ff ff       	call   f0100656 <cons_getc>
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char *)a1,a2);
		return -E_INVAL;
	case SYS_cgetc:
		return sys_cgetc();
f0104dac:	e9 23 05 00 00       	jmp    f01052d4 <syscall+0x5a0>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104db1:	e8 46 16 00 00       	call   f01063fc <cpunum>
f0104db6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104dbd:	29 c2                	sub    %eax,%edx
f0104dbf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dc2:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104dc9:	8b 40 48             	mov    0x48(%eax),%eax
		sys_cputs((const char *)a1,a2);
		return -E_INVAL;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
f0104dcc:	e9 03 05 00 00       	jmp    f01052d4 <syscall+0x5a0>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104dd1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104dd8:	00 
f0104dd9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104de0:	89 3c 24             	mov    %edi,(%esp)
f0104de3:	e8 6b e8 ff ff       	call   f0103653 <envid2env>
f0104de8:	85 c0                	test   %eax,%eax
f0104dea:	0f 88 e4 04 00 00    	js     f01052d4 <syscall+0x5a0>
		return r;
	env_destroy(e);
f0104df0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104df3:	89 04 24             	mov    %eax,(%esp)
f0104df6:	e8 52 ee ff ff       	call   f0103c4d <env_destroy>
	return 0;
f0104dfb:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
f0104e00:	e9 cf 04 00 00       	jmp    f01052d4 <syscall+0x5a0>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104e05:	e8 80 fe ff ff       	call   f0104c8a <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *new_env;
	if(env_alloc(&new_env, curenv->env_id) < 0)
f0104e0a:	e8 ed 15 00 00       	call   f01063fc <cpunum>
f0104e0f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e16:	29 c2                	sub    %eax,%edx
f0104e18:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e1b:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104e22:	8b 40 48             	mov    0x48(%eax),%eax
f0104e25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e29:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e2c:	89 04 24             	mov    %eax,(%esp)
f0104e2f:	e8 5a e9 ff ff       	call   f010378e <env_alloc>
f0104e34:	85 c0                	test   %eax,%eax
f0104e36:	78 3d                	js     f0104e75 <syscall+0x141>
		return 0;
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104e38:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104e3b:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	new_env->env_tf = curenv->env_tf;
f0104e42:	e8 b5 15 00 00       	call   f01063fc <cpunum>
f0104e47:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e4e:	29 c2                	sub    %eax,%edx
f0104e50:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e53:	8b 34 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%esi
f0104e5a:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e5f:	89 df                	mov    %ebx,%edi
f0104e61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104e63:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e66:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	
	return new_env->env_id;
f0104e6d:	8b 40 48             	mov    0x48(%eax),%eax
f0104e70:	e9 5f 04 00 00       	jmp    f01052d4 <syscall+0x5a0>
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *new_env;
	if(env_alloc(&new_env, curenv->env_id) < 0)
		return 0;
f0104e75:	b8 00 00 00 00       	mov    $0x0,%eax
		return sys_env_destroy(a1);
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
        	return sys_exofork();
f0104e7a:	e9 55 04 00 00       	jmp    f01052d4 <syscall+0x5a0>
	// envid's status.

	// LAB 4: Your code here.
	struct Env *env_store;
	
	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104e7f:	83 fe 02             	cmp    $0x2,%esi
f0104e82:	74 05                	je     f0104e89 <syscall+0x155>
f0104e84:	83 fe 04             	cmp    $0x4,%esi
f0104e87:	75 2b                	jne    f0104eb4 <syscall+0x180>
		return -E_INVAL;
	int err_code = envid2env(envid, &env_store, 1);
f0104e89:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e90:	00 
f0104e91:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e98:	89 3c 24             	mov    %edi,(%esp)
f0104e9b:	e8 b3 e7 ff ff       	call   f0103653 <envid2env>
	if(err_code < 0){
f0104ea0:	85 c0                	test   %eax,%eax
f0104ea2:	78 1a                	js     f0104ebe <syscall+0x18a>
		return -E_BAD_ENV;
	}
	env_store->env_status = status;
f0104ea4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ea7:	89 70 54             	mov    %esi,0x54(%eax)
	
	return 0; 
f0104eaa:	b8 00 00 00 00       	mov    $0x0,%eax
f0104eaf:	e9 20 04 00 00       	jmp    f01052d4 <syscall+0x5a0>

	// LAB 4: Your code here.
	struct Env *env_store;
	
	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104eb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104eb9:	e9 16 04 00 00       	jmp    f01052d4 <syscall+0x5a0>
	int err_code = envid2env(envid, &env_store, 1);
	if(err_code < 0){
		return -E_BAD_ENV;
f0104ebe:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		sys_yield();
		return 0;
	case SYS_exofork:
        	return sys_exofork();
    	case SYS_env_set_status:
    		return sys_env_set_status(a1, a2);
f0104ec3:	e9 0c 04 00 00       	jmp    f01052d4 <syscall+0x5a0>
static int
sys_page_alloc(envid_t envid, void *va, int perm){
	struct Env *env;

// 调用函数 envid2env(envid, &env, 1) 来获取指定 envid 对应的环境结构体，并将结果存储在 env 中。然后检测一些参数是否合法。
	if(envid2env(envid, &env, 1) < 0)
f0104ec8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ecf:	00 
f0104ed0:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ed7:	89 3c 24             	mov    %edi,(%esp)
f0104eda:	e8 74 e7 ff ff       	call   f0103653 <envid2env>
f0104edf:	85 c0                	test   %eax,%eax
f0104ee1:	78 55                	js     f0104f38 <syscall+0x204>
		return -E_BAD_ENV;
	if((int)va >= UTOP || PGOFF(va))
f0104ee3:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104ee9:	77 57                	ja     f0104f42 <syscall+0x20e>
f0104eeb:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104ef1:	75 59                	jne    f0104f4c <syscall+0x218>
		return -E_INVAL;
	if((perm & PTE_SYSCALL) == 0)
f0104ef3:	f7 c3 07 0e 00 00    	test   $0xe07,%ebx
f0104ef9:	74 5b                	je     f0104f56 <syscall+0x222>
		return -E_INVAL;
	if(perm & ~PTE_SYSCALL)
f0104efb:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
f0104f01:	75 5d                	jne    f0104f60 <syscall+0x22c>
		return -E_INVAL;

// 分配物理页。根据指定的标志分配一个物理页，并返回该页的信息。将一个物理页 pp 映射到给定的虚拟地址 va 上，并设置相应的权限 perm。
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0104f03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104f0a:	e8 24 c1 ff ff       	call   f0101033 <page_alloc>
	if(!pp)
f0104f0f:	85 c0                	test   %eax,%eax
f0104f11:	74 57                	je     f0104f6a <syscall+0x236>
		return -E_NO_MEM;
	if(page_insert(env->env_pgdir, pp, va, perm) < 0)
f0104f13:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104f17:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f22:	8b 40 60             	mov    0x60(%eax),%eax
f0104f25:	89 04 24             	mov    %eax,(%esp)
f0104f28:	e8 78 c4 ff ff       	call   f01013a5 <page_insert>
		return -E_NO_MEM;
f0104f2d:	c1 f8 1f             	sar    $0x1f,%eax
f0104f30:	83 e0 fc             	and    $0xfffffffc,%eax
f0104f33:	e9 9c 03 00 00       	jmp    f01052d4 <syscall+0x5a0>
sys_page_alloc(envid_t envid, void *va, int perm){
	struct Env *env;

// 调用函数 envid2env(envid, &env, 1) 来获取指定 envid 对应的环境结构体，并将结果存储在 env 中。然后检测一些参数是否合法。
	if(envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
f0104f38:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104f3d:	e9 92 03 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if((int)va >= UTOP || PGOFF(va))
		return -E_INVAL;
f0104f42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f47:	e9 88 03 00 00       	jmp    f01052d4 <syscall+0x5a0>
f0104f4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f51:	e9 7e 03 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if((perm & PTE_SYSCALL) == 0)
		return -E_INVAL;
f0104f56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f5b:	e9 74 03 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if(perm & ~PTE_SYSCALL)
		return -E_INVAL;
f0104f60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f65:	e9 6a 03 00 00       	jmp    f01052d4 <syscall+0x5a0>

// 分配物理页。根据指定的标志分配一个物理页，并返回该页的信息。将一个物理页 pp 映射到给定的虚拟地址 va 上，并设置相应的权限 perm。
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if(!pp)
		return -E_NO_MEM;
f0104f6a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104f6f:	e9 60 03 00 00       	jmp    f01052d4 <syscall+0x5a0>

	// LAB 4: Your code here.
	// LAB 4: Your code here.
	struct Env *srcenv, *dstenv;
	struct PageInfo *srcpp, *dstpp;
	pte_t *pte = 0;
f0104f74:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1))
f0104f7b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f82:	00 
f0104f83:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f8a:	89 3c 24             	mov    %edi,(%esp)
f0104f8d:	e8 c1 e6 ff ff       	call   f0103653 <envid2env>
f0104f92:	85 c0                	test   %eax,%eax
f0104f94:	0f 88 b8 00 00 00    	js     f0105052 <syscall+0x31e>
f0104f9a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104fa1:	00 
f0104fa2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fa9:	89 1c 24             	mov    %ebx,(%esp)
f0104fac:	e8 a2 e6 ff ff       	call   f0103653 <envid2env>
f0104fb1:	85 c0                	test   %eax,%eax
f0104fb3:	0f 85 a3 00 00 00    	jne    f010505c <syscall+0x328>
		return -E_BAD_ENV;
	if (((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) || (PGOFF(srcva) || PGOFF(dstva)))
f0104fb9:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104fbf:	0f 87 a1 00 00 00    	ja     f0105066 <syscall+0x332>
f0104fc5:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104fcc:	0f 87 9e 00 00 00    	ja     f0105070 <syscall+0x33c>
	return -E_INVAL;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
f0104fd2:	8b 45 18             	mov    0x18(%ebp),%eax
f0104fd5:	09 f0                	or     %esi,%eax
	struct PageInfo *srcpp, *dstpp;
	pte_t *pte = 0;
	
	if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1))
		return -E_BAD_ENV;
	if (((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) || (PGOFF(srcva) || PGOFF(dstva)))
f0104fd7:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104fdc:	0f 85 98 00 00 00    	jne    f010507a <syscall+0x346>
		return -E_INVAL;
	if((perm & PTE_SYSCALL) == 0)
f0104fe2:	f7 45 1c 07 0e 00 00 	testl  $0xe07,0x1c(%ebp)
f0104fe9:	0f 84 95 00 00 00    	je     f0105084 <syscall+0x350>
		return -E_INVAL;
	if(perm & ~PTE_SYSCALL)
f0104fef:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104ff6:	0f 85 92 00 00 00    	jne    f010508e <syscall+0x35a>
		return -E_INVAL;
	if(!(srcpp = page_lookup(srcenv->env_pgdir, srcva, &pte)))
f0104ffc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104fff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105003:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105007:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010500a:	8b 40 60             	mov    0x60(%eax),%eax
f010500d:	89 04 24             	mov    %eax,(%esp)
f0105010:	e8 86 c2 ff ff       	call   f010129b <page_lookup>
f0105015:	85 c0                	test   %eax,%eax
f0105017:	74 7f                	je     f0105098 <syscall+0x364>
		return -E_INVAL;
	if((perm & PTE_W) && (*pte & PTE_W) == 0)
f0105019:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010501d:	74 08                	je     f0105027 <syscall+0x2f3>
f010501f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105022:	f6 02 02             	testb  $0x2,(%edx)
f0105025:	74 7b                	je     f01050a2 <syscall+0x36e>
		return -E_INVAL;
	if(page_insert(dstenv->env_pgdir, srcpp, dstva, perm) < 0)
f0105027:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f010502a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010502e:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105031:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105035:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105039:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010503c:	8b 40 60             	mov    0x60(%eax),%eax
f010503f:	89 04 24             	mov    %eax,(%esp)
f0105042:	e8 5e c3 ff ff       	call   f01013a5 <page_insert>
		return -E_NO_MEM;
f0105047:	c1 f8 1f             	sar    $0x1f,%eax
f010504a:	83 e0 fc             	and    $0xfffffffc,%eax
f010504d:	e9 82 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
	struct Env *srcenv, *dstenv;
	struct PageInfo *srcpp, *dstpp;
	pte_t *pte = 0;
	
	if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1))
		return -E_BAD_ENV;
f0105052:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105057:	e9 78 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
f010505c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105061:	e9 6e 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if (((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) || (PGOFF(srcva) || PGOFF(dstva)))
		return -E_INVAL;
f0105066:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010506b:	e9 64 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
f0105070:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105075:	e9 5a 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
f010507a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010507f:	e9 50 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if((perm & PTE_SYSCALL) == 0)
		return -E_INVAL;
f0105084:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105089:	e9 46 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if(perm & ~PTE_SYSCALL)
		return -E_INVAL;
f010508e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105093:	e9 3c 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if(!(srcpp = page_lookup(srcenv->env_pgdir, srcva, &pte)))
		return -E_INVAL;
f0105098:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010509d:	e9 32 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if((perm & PTE_W) && (*pte & PTE_W) == 0)
		return -E_INVAL;
f01050a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050a7:	e9 28 02 00 00       	jmp    f01052d4 <syscall+0x5a0>
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va){
	struct Env *env;
 
	if (envid2env(envid, &env, 1) < 0) 
f01050ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050b3:	00 
f01050b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050bb:	89 3c 24             	mov    %edi,(%esp)
f01050be:	e8 90 e5 ff ff       	call   f0103653 <envid2env>
f01050c3:	85 c0                	test   %eax,%eax
f01050c5:	78 2c                	js     f01050f3 <syscall+0x3bf>
     		return -E_BAD_ENV;
	if ((uintptr_t)va >= UTOP || PGOFF(va))
f01050c7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01050cd:	77 2e                	ja     f01050fd <syscall+0x3c9>
f01050cf:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f01050d5:	75 30                	jne    f0105107 <syscall+0x3d3>
    		return -E_INVAL;
	page_remove(env->env_pgdir, va);
f01050d7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01050db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050de:	8b 40 60             	mov    0x60(%eax),%eax
f01050e1:	89 04 24             	mov    %eax,(%esp)
f01050e4:	e8 73 c2 ff ff       	call   f010135c <page_remove>
		return 0;
f01050e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01050ee:	e9 e1 01 00 00       	jmp    f01052d4 <syscall+0x5a0>
static int
sys_page_unmap(envid_t envid, void *va){
	struct Env *env;
 
	if (envid2env(envid, &env, 1) < 0) 
     		return -E_BAD_ENV;
f01050f3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01050f8:	e9 d7 01 00 00       	jmp    f01052d4 <syscall+0x5a0>
	if ((uintptr_t)va >= UTOP || PGOFF(va))
    		return -E_INVAL;
f01050fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105102:	e9 cd 01 00 00       	jmp    f01052d4 <syscall+0x5a0>
f0105107:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_alloc:
        	return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
        	return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
	case SYS_page_unmap:
        	return sys_page_unmap(a1, (void *) a2);
f010510c:	e9 c3 01 00 00       	jmp    f01052d4 <syscall+0x5a0>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *env;
	int err_code = envid2env(envid, &env, 1);
f0105111:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105118:	00 
f0105119:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010511c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105120:	89 3c 24             	mov    %edi,(%esp)
f0105123:	e8 2b e5 ff ff       	call   f0103653 <envid2env>
	
	if(err_code < 0)
f0105128:	85 c0                	test   %eax,%eax
f010512a:	78 10                	js     f010513c <syscall+0x408>
		return -E_BAD_ENV;
	
	env->env_pgfault_upcall = func;
f010512c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010512f:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0105132:	b8 00 00 00 00       	mov    $0x0,%eax
f0105137:	e9 98 01 00 00       	jmp    f01052d4 <syscall+0x5a0>
	// LAB 4: Your code here.
	struct Env *env;
	int err_code = envid2env(envid, &env, 1);
	
	if(err_code < 0)
		return -E_BAD_ENV;
f010513c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	case SYS_page_map:
        	return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
	case SYS_page_unmap:
        	return sys_page_unmap(a1, (void *) a2);
        case SYS_env_set_pgfault_upcall:
        	return sys_env_set_pgfault_upcall(a1, (void *) a2);
f0105141:	e9 8e 01 00 00       	jmp    f01052d4 <syscall+0x5a0>
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	if(!(dstva < (void*)UTOP) || !PGOFF(dstva)){
f0105146:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010514c:	77 0c                	ja     f010515a <syscall+0x426>
f010514e:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0105154:	0f 85 75 01 00 00    	jne    f01052cf <syscall+0x59b>
    	curenv->env_ipc_recving = 1;
f010515a:	e8 9d 12 00 00       	call   f01063fc <cpunum>
f010515f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105162:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0105168:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    	curenv->env_ipc_dstva   = dstva;
f010516c:	e8 8b 12 00 00       	call   f01063fc <cpunum>
f0105171:	6b c0 74             	imul   $0x74,%eax,%eax
f0105174:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010517a:	89 78 6c             	mov    %edi,0x6c(%eax)
    	curenv->env_status      = ENV_NOT_RUNNABLE;
f010517d:	e8 7a 12 00 00       	call   f01063fc <cpunum>
f0105182:	6b c0 74             	imul   $0x74,%eax,%eax
f0105185:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010518b:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
		sched_yield();
f0105192:	e8 f3 fa ff ff       	call   f0104c8a <sched_yield>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
  struct Env *e;
  int r;
  if((r = envid2env(envid, &e, 0) ) < 0)
f0105197:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010519e:	00 
f010519f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051a6:	89 3c 24             	mov    %edi,(%esp)
f01051a9:	e8 a5 e4 ff ff       	call   f0103653 <envid2env>
f01051ae:	85 c0                	test   %eax,%eax
f01051b0:	0f 88 1e 01 00 00    	js     f01052d4 <syscall+0x5a0>
    return r;
  if(!e->env_ipc_recving)
f01051b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051b9:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01051bd:	0f 84 e2 00 00 00    	je     f01052a5 <syscall+0x571>
    return -E_IPC_NOT_RECV;
  if(srcva < (void*)UTOP){
f01051c3:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01051c9:	0f 87 90 00 00 00    	ja     f010525f <syscall+0x52b>
    if(PGOFF(srcva) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & (~PTE_SYSCALL)))
f01051cf:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01051d5:	0f 85 d1 00 00 00    	jne    f01052ac <syscall+0x578>
f01051db:	8b 45 18             	mov    0x18(%ebp),%eax
f01051de:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01051e3:	83 f8 05             	cmp    $0x5,%eax
f01051e6:	0f 85 c7 00 00 00    	jne    f01052b3 <syscall+0x57f>
      return -E_INVAL;
    pte_t *pte;
    struct PageInfo *pg;
    if(!(pg = page_lookup(curenv->env_pgdir, srcva, &pte)))
f01051ec:	e8 0b 12 00 00       	call   f01063fc <cpunum>
f01051f1:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01051f4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01051f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01051fc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105203:	29 c2                	sub    %eax,%edx
f0105205:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105208:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f010520f:	8b 40 60             	mov    0x60(%eax),%eax
f0105212:	89 04 24             	mov    %eax,(%esp)
f0105215:	e8 81 c0 ff ff       	call   f010129b <page_lookup>
f010521a:	85 c0                	test   %eax,%eax
f010521c:	0f 84 98 00 00 00    	je     f01052ba <syscall+0x586>
      return -E_INVAL;
    if((*pte & perm) != perm)
f0105222:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105225:	8b 12                	mov    (%edx),%edx
f0105227:	23 55 18             	and    0x18(%ebp),%edx
f010522a:	39 55 18             	cmp    %edx,0x18(%ebp)
f010522d:	0f 85 8e 00 00 00    	jne    f01052c1 <syscall+0x58d>
      return -E_INVAL;
    if(e->env_ipc_dstva < (void *)UTOP){
f0105233:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105236:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105239:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010523f:	77 1e                	ja     f010525f <syscall+0x52b>
      if((r = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm)) < 0)
f0105241:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105244:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010524c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105250:	8b 42 60             	mov    0x60(%edx),%eax
f0105253:	89 04 24             	mov    %eax,(%esp)
f0105256:	e8 4a c1 ff ff       	call   f01013a5 <page_insert>
f010525b:	85 c0                	test   %eax,%eax
f010525d:	78 75                	js     f01052d4 <syscall+0x5a0>
        return r;
    }
  }
  e->env_ipc_recving        = 0;
f010525f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105262:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
  e->env_ipc_from           = curenv->env_id;
f0105266:	e8 91 11 00 00       	call   f01063fc <cpunum>
f010526b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105272:	29 c2                	sub    %eax,%edx
f0105274:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105277:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f010527e:	8b 40 48             	mov    0x48(%eax),%eax
f0105281:	89 43 74             	mov    %eax,0x74(%ebx)
  e->env_ipc_value          = value;
f0105284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105287:	89 70 70             	mov    %esi,0x70(%eax)
  e->env_ipc_perm           = perm;
f010528a:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010528d:	89 58 78             	mov    %ebx,0x78(%eax)
  e->env_status             = ENV_RUNNABLE;
f0105290:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
  e->env_tf.tf_regs.reg_eax = 0;
f0105297:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  return 0;
f010529e:	b8 00 00 00 00       	mov    $0x0,%eax
f01052a3:	eb 2f                	jmp    f01052d4 <syscall+0x5a0>
  struct Env *e;
  int r;
  if((r = envid2env(envid, &e, 0) ) < 0)
    return r;
  if(!e->env_ipc_recving)
    return -E_IPC_NOT_RECV;
f01052a5:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01052aa:	eb 28                	jmp    f01052d4 <syscall+0x5a0>
  if(srcva < (void*)UTOP){
    if(PGOFF(srcva) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & (~PTE_SYSCALL)))
      return -E_INVAL;
f01052ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052b1:	eb 21                	jmp    f01052d4 <syscall+0x5a0>
f01052b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052b8:	eb 1a                	jmp    f01052d4 <syscall+0x5a0>
    pte_t *pte;
    struct PageInfo *pg;
    if(!(pg = page_lookup(curenv->env_pgdir, srcva, &pte)))
      return -E_INVAL;
f01052ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052bf:	eb 13                	jmp    f01052d4 <syscall+0x5a0>
    if((*pte & perm) != perm)
      return -E_INVAL;
f01052c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        case SYS_env_set_pgfault_upcall:
        	return sys_env_set_pgfault_upcall(a1, (void *) a2);
        case SYS_ipc_recv:
		return sys_ipc_recv( (void *) a1);
	case SYS_ipc_try_send:
		return sys_ipc_try_send((envid_t) a1, (uint32_t) a2, (void *) a3, (int) a4);	
f01052c6:	eb 0c                	jmp    f01052d4 <syscall+0x5a0>
	default:
		return -E_INVAL;
f01052c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052cd:	eb 05                	jmp    f01052d4 <syscall+0x5a0>
	case SYS_page_unmap:
        	return sys_page_unmap(a1, (void *) a2);
        case SYS_env_set_pgfault_upcall:
        	return sys_env_set_pgfault_upcall(a1, (void *) a2);
        case SYS_ipc_recv:
		return sys_ipc_recv( (void *) a1);
f01052cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_ipc_try_send:
		return sys_ipc_try_send((envid_t) a1, (uint32_t) a2, (void *) a3, (int) a4);	
	default:
		return -E_INVAL;
	}
}
f01052d4:	83 c4 2c             	add    $0x2c,%esp
f01052d7:	5b                   	pop    %ebx
f01052d8:	5e                   	pop    %esi
f01052d9:	5f                   	pop    %edi
f01052da:	5d                   	pop    %ebp
f01052db:	c3                   	ret    

f01052dc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01052dc:	55                   	push   %ebp
f01052dd:	89 e5                	mov    %esp,%ebp
f01052df:	57                   	push   %edi
f01052e0:	56                   	push   %esi
f01052e1:	53                   	push   %ebx
f01052e2:	83 ec 14             	sub    $0x14,%esp
f01052e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01052e8:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01052eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01052ee:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01052f1:	8b 1a                	mov    (%edx),%ebx
f01052f3:	8b 01                	mov    (%ecx),%eax
f01052f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01052f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f01052ff:	e9 83 00 00 00       	jmp    f0105387 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0105304:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105307:	01 d8                	add    %ebx,%eax
f0105309:	89 c7                	mov    %eax,%edi
f010530b:	c1 ef 1f             	shr    $0x1f,%edi
f010530e:	01 c7                	add    %eax,%edi
f0105310:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105312:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105315:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105318:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010531c:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010531e:	eb 01                	jmp    f0105321 <stab_binsearch+0x45>
			m--;
f0105320:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105321:	39 c3                	cmp    %eax,%ebx
f0105323:	7f 1e                	jg     f0105343 <stab_binsearch+0x67>
f0105325:	0f b6 0a             	movzbl (%edx),%ecx
f0105328:	83 ea 0c             	sub    $0xc,%edx
f010532b:	39 f1                	cmp    %esi,%ecx
f010532d:	75 f1                	jne    f0105320 <stab_binsearch+0x44>
f010532f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105332:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105335:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105338:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010533c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010533f:	76 18                	jbe    f0105359 <stab_binsearch+0x7d>
f0105341:	eb 05                	jmp    f0105348 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105343:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105346:	eb 3f                	jmp    f0105387 <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105348:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010534b:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010534d:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105350:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105357:	eb 2e                	jmp    f0105387 <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105359:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010535c:	73 15                	jae    f0105373 <stab_binsearch+0x97>
			*region_right = m - 1;
f010535e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105361:	49                   	dec    %ecx
f0105362:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105365:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105368:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010536a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105371:	eb 14                	jmp    f0105387 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105373:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105376:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105379:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f010537b:	ff 45 0c             	incl   0xc(%ebp)
f010537e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105380:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105387:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010538a:	0f 8e 74 ff ff ff    	jle    f0105304 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105390:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105394:	75 0d                	jne    f01053a3 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0105396:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105399:	8b 02                	mov    (%edx),%eax
f010539b:	48                   	dec    %eax
f010539c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010539f:	89 01                	mov    %eax,(%ecx)
f01053a1:	eb 2a                	jmp    f01053cd <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01053a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01053a6:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01053a8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01053ab:	8b 0a                	mov    (%edx),%ecx
f01053ad:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01053b0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01053b3:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01053b7:	eb 01                	jmp    f01053ba <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01053b9:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01053ba:	39 c8                	cmp    %ecx,%eax
f01053bc:	7e 0a                	jle    f01053c8 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f01053be:	0f b6 1a             	movzbl (%edx),%ebx
f01053c1:	83 ea 0c             	sub    $0xc,%edx
f01053c4:	39 f3                	cmp    %esi,%ebx
f01053c6:	75 f1                	jne    f01053b9 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f01053c8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01053cb:	89 02                	mov    %eax,(%edx)
	}
}
f01053cd:	83 c4 14             	add    $0x14,%esp
f01053d0:	5b                   	pop    %ebx
f01053d1:	5e                   	pop    %esi
f01053d2:	5f                   	pop    %edi
f01053d3:	5d                   	pop    %ebp
f01053d4:	c3                   	ret    

f01053d5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01053d5:	55                   	push   %ebp
f01053d6:	89 e5                	mov    %esp,%ebp
f01053d8:	57                   	push   %edi
f01053d9:	56                   	push   %esi
f01053da:	53                   	push   %ebx
f01053db:	83 ec 5c             	sub    $0x5c,%esp
f01053de:	8b 75 08             	mov    0x8(%ebp),%esi
f01053e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01053e4:	c7 03 e4 81 10 f0    	movl   $0xf01081e4,(%ebx)
	info->eip_line = 0;
f01053ea:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01053f1:	c7 43 08 e4 81 10 f0 	movl   $0xf01081e4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01053f8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01053ff:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105402:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105409:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010540f:	77 22                	ja     f0105433 <debuginfo_eip+0x5e>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0105411:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105417:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010541a:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010541f:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0105425:	89 7d bc             	mov    %edi,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105428:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f010542e:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0105431:	eb 1a                	jmp    f010544d <debuginfo_eip+0x78>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105433:	c7 45 c0 3b e5 11 f0 	movl   $0xf011e53b,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010543a:	c7 45 bc ad 3a 11 f0 	movl   $0xf0113aad,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105441:	b8 ac 3a 11 f0       	mov    $0xf0113aac,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105446:	c7 45 c4 90 87 10 f0 	movl   $0xf0108790,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010544d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105450:	39 7d bc             	cmp    %edi,-0x44(%ebp)
f0105453:	0f 83 8b 01 00 00    	jae    f01055e4 <debuginfo_eip+0x20f>
f0105459:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010545d:	0f 85 88 01 00 00    	jne    f01055eb <debuginfo_eip+0x216>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105463:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010546a:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f010546d:	c1 f8 02             	sar    $0x2,%eax
f0105470:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0105473:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105476:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105479:	89 d1                	mov    %edx,%ecx
f010547b:	c1 e1 08             	shl    $0x8,%ecx
f010547e:	01 ca                	add    %ecx,%edx
f0105480:	89 d1                	mov    %edx,%ecx
f0105482:	c1 e1 10             	shl    $0x10,%ecx
f0105485:	01 ca                	add    %ecx,%edx
f0105487:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f010548b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010548e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105492:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105499:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010549c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010549f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01054a2:	e8 35 fe ff ff       	call   f01052dc <stab_binsearch>
	if (lfile == 0)
f01054a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054aa:	85 c0                	test   %eax,%eax
f01054ac:	0f 84 40 01 00 00    	je     f01055f2 <debuginfo_eip+0x21d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01054b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01054b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01054bb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01054bf:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01054c6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01054c9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01054cc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01054cf:	e8 08 fe ff ff       	call   f01052dc <stab_binsearch>

	if (lfun <= rfun) {
f01054d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01054d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01054da:	39 d0                	cmp    %edx,%eax
f01054dc:	7f 32                	jg     f0105510 <debuginfo_eip+0x13b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01054de:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01054e1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01054e4:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01054e7:	8b 39                	mov    (%ecx),%edi
f01054e9:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01054ec:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01054ef:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01054f2:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01054f5:	73 09                	jae    f0105500 <debuginfo_eip+0x12b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01054f7:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01054fa:	03 7d bc             	add    -0x44(%ebp),%edi
f01054fd:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105500:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105503:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105506:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105508:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010550b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010550e:	eb 0f                	jmp    f010551f <debuginfo_eip+0x14a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105510:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105516:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105519:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010551c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010551f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105526:	00 
f0105527:	8b 43 08             	mov    0x8(%ebx),%eax
f010552a:	89 04 24             	mov    %eax,(%esp)
f010552d:	e8 84 08 00 00       	call   f0105db6 <strfind>
f0105532:	2b 43 08             	sub    0x8(%ebx),%eax
f0105535:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105538:	89 74 24 04          	mov    %esi,0x4(%esp)
f010553c:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105543:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105546:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105549:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010554c:	e8 8b fd ff ff       	call   f01052dc <stab_binsearch>
	if (lline <= rline)
f0105551:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105554:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105557:	0f 8f 9c 00 00 00    	jg     f01055f9 <debuginfo_eip+0x224>
    		info->eip_line = stabs[lline].n_desc;
f010555d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105560:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105563:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0105568:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010556b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010556e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105571:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105574:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f0105578:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010557b:	eb 04                	jmp    f0105581 <debuginfo_eip+0x1ac>
f010557d:	48                   	dec    %eax
f010557e:	83 ea 0c             	sub    $0xc,%edx
f0105581:	89 c7                	mov    %eax,%edi
f0105583:	39 c6                	cmp    %eax,%esi
f0105585:	7f 25                	jg     f01055ac <debuginfo_eip+0x1d7>
	       && stabs[lline].n_type != N_SOL
f0105587:	8a 4a fc             	mov    -0x4(%edx),%cl
f010558a:	80 f9 84             	cmp    $0x84,%cl
f010558d:	0f 84 81 00 00 00    	je     f0105614 <debuginfo_eip+0x23f>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105593:	80 f9 64             	cmp    $0x64,%cl
f0105596:	75 e5                	jne    f010557d <debuginfo_eip+0x1a8>
f0105598:	83 3a 00             	cmpl   $0x0,(%edx)
f010559b:	74 e0                	je     f010557d <debuginfo_eip+0x1a8>
f010559d:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01055a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01055a3:	eb 75                	jmp    f010561a <debuginfo_eip+0x245>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01055a5:	03 45 bc             	add    -0x44(%ebp),%eax
f01055a8:	89 03                	mov    %eax,(%ebx)
f01055aa:	eb 03                	jmp    f01055af <debuginfo_eip+0x1da>
f01055ac:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01055af:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01055b2:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01055b5:	39 f2                	cmp    %esi,%edx
f01055b7:	7d 47                	jge    f0105600 <debuginfo_eip+0x22b>
		for (lline = lfun + 1;
f01055b9:	42                   	inc    %edx
f01055ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01055bd:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055bf:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01055c2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01055c5:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01055c9:	eb 03                	jmp    f01055ce <debuginfo_eip+0x1f9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01055cb:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01055ce:	39 f0                	cmp    %esi,%eax
f01055d0:	7d 35                	jge    f0105607 <debuginfo_eip+0x232>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055d2:	8a 0a                	mov    (%edx),%cl
f01055d4:	40                   	inc    %eax
f01055d5:	83 c2 0c             	add    $0xc,%edx
f01055d8:	80 f9 a0             	cmp    $0xa0,%cl
f01055db:	74 ee                	je     f01055cb <debuginfo_eip+0x1f6>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01055dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01055e2:	eb 28                	jmp    f010560c <debuginfo_eip+0x237>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01055e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055e9:	eb 21                	jmp    f010560c <debuginfo_eip+0x237>
f01055eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055f0:	eb 1a                	jmp    f010560c <debuginfo_eip+0x237>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01055f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055f7:	eb 13                	jmp    f010560c <debuginfo_eip+0x237>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
    		info->eip_line = stabs[lline].n_desc;
	else
    		return -1;
f01055f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055fe:	eb 0c                	jmp    f010560c <debuginfo_eip+0x237>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105600:	b8 00 00 00 00       	mov    $0x0,%eax
f0105605:	eb 05                	jmp    f010560c <debuginfo_eip+0x237>
f0105607:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010560c:	83 c4 5c             	add    $0x5c,%esp
f010560f:	5b                   	pop    %ebx
f0105610:	5e                   	pop    %esi
f0105611:	5f                   	pop    %edi
f0105612:	5d                   	pop    %ebp
f0105613:	c3                   	ret    
f0105614:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105617:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010561a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010561d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105620:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0105623:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105626:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105629:	39 d0                	cmp    %edx,%eax
f010562b:	0f 82 74 ff ff ff    	jb     f01055a5 <debuginfo_eip+0x1d0>
f0105631:	e9 79 ff ff ff       	jmp    f01055af <debuginfo_eip+0x1da>
	...

f0105638 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105638:	55                   	push   %ebp
f0105639:	89 e5                	mov    %esp,%ebp
f010563b:	57                   	push   %edi
f010563c:	56                   	push   %esi
f010563d:	53                   	push   %ebx
f010563e:	83 ec 3c             	sub    $0x3c,%esp
f0105641:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105644:	89 d7                	mov    %edx,%edi
f0105646:	8b 45 08             	mov    0x8(%ebp),%eax
f0105649:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010564c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010564f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105652:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105655:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105658:	85 c0                	test   %eax,%eax
f010565a:	75 08                	jne    f0105664 <printnum+0x2c>
f010565c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010565f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105662:	77 57                	ja     f01056bb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105664:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105668:	4b                   	dec    %ebx
f0105669:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010566d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105670:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105674:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105678:	8b 74 24 0c          	mov    0xc(%esp),%esi
f010567c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105683:	00 
f0105684:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105687:	89 04 24             	mov    %eax,(%esp)
f010568a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010568d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105691:	e8 d6 11 00 00       	call   f010686c <__udivdi3>
f0105696:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010569a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010569e:	89 04 24             	mov    %eax,(%esp)
f01056a1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01056a5:	89 fa                	mov    %edi,%edx
f01056a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056aa:	e8 89 ff ff ff       	call   f0105638 <printnum>
f01056af:	eb 0f                	jmp    f01056c0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01056b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056b5:	89 34 24             	mov    %esi,(%esp)
f01056b8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01056bb:	4b                   	dec    %ebx
f01056bc:	85 db                	test   %ebx,%ebx
f01056be:	7f f1                	jg     f01056b1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01056c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056c4:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01056c8:	8b 45 10             	mov    0x10(%ebp),%eax
f01056cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01056d6:	00 
f01056d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01056da:	89 04 24             	mov    %eax,(%esp)
f01056dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056e4:	e8 a3 12 00 00       	call   f010698c <__umoddi3>
f01056e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056ed:	0f be 80 ee 81 10 f0 	movsbl -0xfef7e12(%eax),%eax
f01056f4:	89 04 24             	mov    %eax,(%esp)
f01056f7:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01056fa:	83 c4 3c             	add    $0x3c,%esp
f01056fd:	5b                   	pop    %ebx
f01056fe:	5e                   	pop    %esi
f01056ff:	5f                   	pop    %edi
f0105700:	5d                   	pop    %ebp
f0105701:	c3                   	ret    

f0105702 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105702:	55                   	push   %ebp
f0105703:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105705:	83 fa 01             	cmp    $0x1,%edx
f0105708:	7e 0e                	jle    f0105718 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010570a:	8b 10                	mov    (%eax),%edx
f010570c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010570f:	89 08                	mov    %ecx,(%eax)
f0105711:	8b 02                	mov    (%edx),%eax
f0105713:	8b 52 04             	mov    0x4(%edx),%edx
f0105716:	eb 22                	jmp    f010573a <getuint+0x38>
	else if (lflag)
f0105718:	85 d2                	test   %edx,%edx
f010571a:	74 10                	je     f010572c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010571c:	8b 10                	mov    (%eax),%edx
f010571e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105721:	89 08                	mov    %ecx,(%eax)
f0105723:	8b 02                	mov    (%edx),%eax
f0105725:	ba 00 00 00 00       	mov    $0x0,%edx
f010572a:	eb 0e                	jmp    f010573a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010572c:	8b 10                	mov    (%eax),%edx
f010572e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105731:	89 08                	mov    %ecx,(%eax)
f0105733:	8b 02                	mov    (%edx),%eax
f0105735:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010573a:	5d                   	pop    %ebp
f010573b:	c3                   	ret    

f010573c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010573c:	55                   	push   %ebp
f010573d:	89 e5                	mov    %esp,%ebp
f010573f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105742:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105745:	8b 10                	mov    (%eax),%edx
f0105747:	3b 50 04             	cmp    0x4(%eax),%edx
f010574a:	73 08                	jae    f0105754 <sprintputch+0x18>
		*b->buf++ = ch;
f010574c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010574f:	88 0a                	mov    %cl,(%edx)
f0105751:	42                   	inc    %edx
f0105752:	89 10                	mov    %edx,(%eax)
}
f0105754:	5d                   	pop    %ebp
f0105755:	c3                   	ret    

f0105756 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105756:	55                   	push   %ebp
f0105757:	89 e5                	mov    %esp,%ebp
f0105759:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010575c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010575f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105763:	8b 45 10             	mov    0x10(%ebp),%eax
f0105766:	89 44 24 08          	mov    %eax,0x8(%esp)
f010576a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010576d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105771:	8b 45 08             	mov    0x8(%ebp),%eax
f0105774:	89 04 24             	mov    %eax,(%esp)
f0105777:	e8 02 00 00 00       	call   f010577e <vprintfmt>
	va_end(ap);
}
f010577c:	c9                   	leave  
f010577d:	c3                   	ret    

f010577e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010577e:	55                   	push   %ebp
f010577f:	89 e5                	mov    %esp,%ebp
f0105781:	57                   	push   %edi
f0105782:	56                   	push   %esi
f0105783:	53                   	push   %ebx
f0105784:	83 ec 4c             	sub    $0x4c,%esp
f0105787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010578a:	8b 75 10             	mov    0x10(%ebp),%esi
f010578d:	eb 12                	jmp    f01057a1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010578f:	85 c0                	test   %eax,%eax
f0105791:	0f 84 6b 03 00 00    	je     f0105b02 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0105797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010579b:	89 04 24             	mov    %eax,(%esp)
f010579e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01057a1:	0f b6 06             	movzbl (%esi),%eax
f01057a4:	46                   	inc    %esi
f01057a5:	83 f8 25             	cmp    $0x25,%eax
f01057a8:	75 e5                	jne    f010578f <vprintfmt+0x11>
f01057aa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01057ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01057b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01057ba:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01057c1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057c6:	eb 26                	jmp    f01057ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057c8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01057cb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01057cf:	eb 1d                	jmp    f01057ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01057d4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01057d8:	eb 14                	jmp    f01057ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01057dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01057e4:	eb 08                	jmp    f01057ee <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01057e6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01057e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057ee:	0f b6 06             	movzbl (%esi),%eax
f01057f1:	8d 56 01             	lea    0x1(%esi),%edx
f01057f4:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01057f7:	8a 16                	mov    (%esi),%dl
f01057f9:	83 ea 23             	sub    $0x23,%edx
f01057fc:	80 fa 55             	cmp    $0x55,%dl
f01057ff:	0f 87 e1 02 00 00    	ja     f0105ae6 <vprintfmt+0x368>
f0105805:	0f b6 d2             	movzbl %dl,%edx
f0105808:	ff 24 95 40 83 10 f0 	jmp    *-0xfef7cc0(,%edx,4)
f010580f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105812:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105817:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010581a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010581e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105821:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105824:	83 fa 09             	cmp    $0x9,%edx
f0105827:	77 2a                	ja     f0105853 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105829:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010582a:	eb eb                	jmp    f0105817 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010582c:	8b 45 14             	mov    0x14(%ebp),%eax
f010582f:	8d 50 04             	lea    0x4(%eax),%edx
f0105832:	89 55 14             	mov    %edx,0x14(%ebp)
f0105835:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105837:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010583a:	eb 17                	jmp    f0105853 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f010583c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105840:	78 98                	js     f01057da <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105842:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105845:	eb a7                	jmp    f01057ee <vprintfmt+0x70>
f0105847:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010584a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105851:	eb 9b                	jmp    f01057ee <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105853:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105857:	79 95                	jns    f01057ee <vprintfmt+0x70>
f0105859:	eb 8b                	jmp    f01057e6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010585b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010585c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010585f:	eb 8d                	jmp    f01057ee <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105861:	8b 45 14             	mov    0x14(%ebp),%eax
f0105864:	8d 50 04             	lea    0x4(%eax),%edx
f0105867:	89 55 14             	mov    %edx,0x14(%ebp)
f010586a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010586e:	8b 00                	mov    (%eax),%eax
f0105870:	89 04 24             	mov    %eax,(%esp)
f0105873:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105876:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105879:	e9 23 ff ff ff       	jmp    f01057a1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010587e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105881:	8d 50 04             	lea    0x4(%eax),%edx
f0105884:	89 55 14             	mov    %edx,0x14(%ebp)
f0105887:	8b 00                	mov    (%eax),%eax
f0105889:	85 c0                	test   %eax,%eax
f010588b:	79 02                	jns    f010588f <vprintfmt+0x111>
f010588d:	f7 d8                	neg    %eax
f010588f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105891:	83 f8 0f             	cmp    $0xf,%eax
f0105894:	7f 0b                	jg     f01058a1 <vprintfmt+0x123>
f0105896:	8b 04 85 a0 84 10 f0 	mov    -0xfef7b60(,%eax,4),%eax
f010589d:	85 c0                	test   %eax,%eax
f010589f:	75 23                	jne    f01058c4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01058a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01058a5:	c7 44 24 08 06 82 10 	movl   $0xf0108206,0x8(%esp)
f01058ac:	f0 
f01058ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01058b4:	89 04 24             	mov    %eax,(%esp)
f01058b7:	e8 9a fe ff ff       	call   f0105756 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01058bf:	e9 dd fe ff ff       	jmp    f01057a1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01058c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01058c8:	c7 44 24 08 dd 79 10 	movl   $0xf01079dd,0x8(%esp)
f01058cf:	f0 
f01058d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058d4:	8b 55 08             	mov    0x8(%ebp),%edx
f01058d7:	89 14 24             	mov    %edx,(%esp)
f01058da:	e8 77 fe ff ff       	call   f0105756 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058df:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01058e2:	e9 ba fe ff ff       	jmp    f01057a1 <vprintfmt+0x23>
f01058e7:	89 f9                	mov    %edi,%ecx
f01058e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01058ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01058f2:	8d 50 04             	lea    0x4(%eax),%edx
f01058f5:	89 55 14             	mov    %edx,0x14(%ebp)
f01058f8:	8b 30                	mov    (%eax),%esi
f01058fa:	85 f6                	test   %esi,%esi
f01058fc:	75 05                	jne    f0105903 <vprintfmt+0x185>
				p = "(null)";
f01058fe:	be ff 81 10 f0       	mov    $0xf01081ff,%esi
			if (width > 0 && padc != '-')
f0105903:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105907:	0f 8e 84 00 00 00    	jle    f0105991 <vprintfmt+0x213>
f010590d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105911:	74 7e                	je     f0105991 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105913:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105917:	89 34 24             	mov    %esi,(%esp)
f010591a:	e8 63 03 00 00       	call   f0105c82 <strnlen>
f010591f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105922:	29 c2                	sub    %eax,%edx
f0105924:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105927:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010592b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010592e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105931:	89 de                	mov    %ebx,%esi
f0105933:	89 d3                	mov    %edx,%ebx
f0105935:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105937:	eb 0b                	jmp    f0105944 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105939:	89 74 24 04          	mov    %esi,0x4(%esp)
f010593d:	89 3c 24             	mov    %edi,(%esp)
f0105940:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105943:	4b                   	dec    %ebx
f0105944:	85 db                	test   %ebx,%ebx
f0105946:	7f f1                	jg     f0105939 <vprintfmt+0x1bb>
f0105948:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010594b:	89 f3                	mov    %esi,%ebx
f010594d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105950:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105953:	85 c0                	test   %eax,%eax
f0105955:	79 05                	jns    f010595c <vprintfmt+0x1de>
f0105957:	b8 00 00 00 00       	mov    $0x0,%eax
f010595c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010595f:	29 c2                	sub    %eax,%edx
f0105961:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105964:	eb 2b                	jmp    f0105991 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105966:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010596a:	74 18                	je     f0105984 <vprintfmt+0x206>
f010596c:	8d 50 e0             	lea    -0x20(%eax),%edx
f010596f:	83 fa 5e             	cmp    $0x5e,%edx
f0105972:	76 10                	jbe    f0105984 <vprintfmt+0x206>
					putch('?', putdat);
f0105974:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105978:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010597f:	ff 55 08             	call   *0x8(%ebp)
f0105982:	eb 0a                	jmp    f010598e <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105988:	89 04 24             	mov    %eax,(%esp)
f010598b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010598e:	ff 4d e4             	decl   -0x1c(%ebp)
f0105991:	0f be 06             	movsbl (%esi),%eax
f0105994:	46                   	inc    %esi
f0105995:	85 c0                	test   %eax,%eax
f0105997:	74 21                	je     f01059ba <vprintfmt+0x23c>
f0105999:	85 ff                	test   %edi,%edi
f010599b:	78 c9                	js     f0105966 <vprintfmt+0x1e8>
f010599d:	4f                   	dec    %edi
f010599e:	79 c6                	jns    f0105966 <vprintfmt+0x1e8>
f01059a0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059a3:	89 de                	mov    %ebx,%esi
f01059a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01059a8:	eb 18                	jmp    f01059c2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01059aa:	89 74 24 04          	mov    %esi,0x4(%esp)
f01059ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01059b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01059b7:	4b                   	dec    %ebx
f01059b8:	eb 08                	jmp    f01059c2 <vprintfmt+0x244>
f01059ba:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059bd:	89 de                	mov    %ebx,%esi
f01059bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01059c2:	85 db                	test   %ebx,%ebx
f01059c4:	7f e4                	jg     f01059aa <vprintfmt+0x22c>
f01059c6:	89 7d 08             	mov    %edi,0x8(%ebp)
f01059c9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01059ce:	e9 ce fd ff ff       	jmp    f01057a1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01059d3:	83 f9 01             	cmp    $0x1,%ecx
f01059d6:	7e 10                	jle    f01059e8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f01059d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01059db:	8d 50 08             	lea    0x8(%eax),%edx
f01059de:	89 55 14             	mov    %edx,0x14(%ebp)
f01059e1:	8b 30                	mov    (%eax),%esi
f01059e3:	8b 78 04             	mov    0x4(%eax),%edi
f01059e6:	eb 26                	jmp    f0105a0e <vprintfmt+0x290>
	else if (lflag)
f01059e8:	85 c9                	test   %ecx,%ecx
f01059ea:	74 12                	je     f01059fe <vprintfmt+0x280>
		return va_arg(*ap, long);
f01059ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01059ef:	8d 50 04             	lea    0x4(%eax),%edx
f01059f2:	89 55 14             	mov    %edx,0x14(%ebp)
f01059f5:	8b 30                	mov    (%eax),%esi
f01059f7:	89 f7                	mov    %esi,%edi
f01059f9:	c1 ff 1f             	sar    $0x1f,%edi
f01059fc:	eb 10                	jmp    f0105a0e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f01059fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a01:	8d 50 04             	lea    0x4(%eax),%edx
f0105a04:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a07:	8b 30                	mov    (%eax),%esi
f0105a09:	89 f7                	mov    %esi,%edi
f0105a0b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105a0e:	85 ff                	test   %edi,%edi
f0105a10:	78 0a                	js     f0105a1c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105a12:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a17:	e9 8c 00 00 00       	jmp    f0105aa8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105a1c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a20:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105a27:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105a2a:	f7 de                	neg    %esi
f0105a2c:	83 d7 00             	adc    $0x0,%edi
f0105a2f:	f7 df                	neg    %edi
			}
			base = 10;
f0105a31:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a36:	eb 70                	jmp    f0105aa8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105a38:	89 ca                	mov    %ecx,%edx
f0105a3a:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a3d:	e8 c0 fc ff ff       	call   f0105702 <getuint>
f0105a42:	89 c6                	mov    %eax,%esi
f0105a44:	89 d7                	mov    %edx,%edi
			base = 10;
f0105a46:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105a4b:	eb 5b                	jmp    f0105aa8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0105a4d:	89 ca                	mov    %ecx,%edx
f0105a4f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a52:	e8 ab fc ff ff       	call   f0105702 <getuint>
f0105a57:	89 c6                	mov    %eax,%esi
f0105a59:	89 d7                	mov    %edx,%edi
			base = 8;
f0105a5b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105a60:	eb 46                	jmp    f0105aa8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f0105a62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a66:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105a6d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105a70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a74:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105a7b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105a7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a81:	8d 50 04             	lea    0x4(%eax),%edx
f0105a84:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105a87:	8b 30                	mov    (%eax),%esi
f0105a89:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105a8e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105a93:	eb 13                	jmp    f0105aa8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105a95:	89 ca                	mov    %ecx,%edx
f0105a97:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a9a:	e8 63 fc ff ff       	call   f0105702 <getuint>
f0105a9f:	89 c6                	mov    %eax,%esi
f0105aa1:	89 d7                	mov    %edx,%edi
			base = 16;
f0105aa3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105aa8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105aac:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105ab0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105ab3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105abb:	89 34 24             	mov    %esi,(%esp)
f0105abe:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ac2:	89 da                	mov    %ebx,%edx
f0105ac4:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ac7:	e8 6c fb ff ff       	call   f0105638 <printnum>
			break;
f0105acc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105acf:	e9 cd fc ff ff       	jmp    f01057a1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105ad4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ad8:	89 04 24             	mov    %eax,(%esp)
f0105adb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ade:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105ae1:	e9 bb fc ff ff       	jmp    f01057a1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105ae6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105aea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105af1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105af4:	eb 01                	jmp    f0105af7 <vprintfmt+0x379>
f0105af6:	4e                   	dec    %esi
f0105af7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105afb:	75 f9                	jne    f0105af6 <vprintfmt+0x378>
f0105afd:	e9 9f fc ff ff       	jmp    f01057a1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105b02:	83 c4 4c             	add    $0x4c,%esp
f0105b05:	5b                   	pop    %ebx
f0105b06:	5e                   	pop    %esi
f0105b07:	5f                   	pop    %edi
f0105b08:	5d                   	pop    %ebp
f0105b09:	c3                   	ret    

f0105b0a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105b0a:	55                   	push   %ebp
f0105b0b:	89 e5                	mov    %esp,%ebp
f0105b0d:	83 ec 28             	sub    $0x28,%esp
f0105b10:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b13:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105b16:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b19:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b1d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105b20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105b27:	85 c0                	test   %eax,%eax
f0105b29:	74 30                	je     f0105b5b <vsnprintf+0x51>
f0105b2b:	85 d2                	test   %edx,%edx
f0105b2d:	7e 33                	jle    f0105b62 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105b2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b32:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b36:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b39:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105b40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b44:	c7 04 24 3c 57 10 f0 	movl   $0xf010573c,(%esp)
f0105b4b:	e8 2e fc ff ff       	call   f010577e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105b50:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b53:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105b59:	eb 0c                	jmp    f0105b67 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105b5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105b60:	eb 05                	jmp    f0105b67 <vsnprintf+0x5d>
f0105b62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105b67:	c9                   	leave  
f0105b68:	c3                   	ret    

f0105b69 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105b69:	55                   	push   %ebp
f0105b6a:	89 e5                	mov    %esp,%ebp
f0105b6c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105b6f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105b72:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b76:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b79:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b84:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b87:	89 04 24             	mov    %eax,(%esp)
f0105b8a:	e8 7b ff ff ff       	call   f0105b0a <vsnprintf>
	va_end(ap);

	return rc;
}
f0105b8f:	c9                   	leave  
f0105b90:	c3                   	ret    
f0105b91:	00 00                	add    %al,(%eax)
	...

f0105b94 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105b94:	55                   	push   %ebp
f0105b95:	89 e5                	mov    %esp,%ebp
f0105b97:	57                   	push   %edi
f0105b98:	56                   	push   %esi
f0105b99:	53                   	push   %ebx
f0105b9a:	83 ec 1c             	sub    $0x1c,%esp
f0105b9d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105ba0:	85 c0                	test   %eax,%eax
f0105ba2:	74 10                	je     f0105bb4 <readline+0x20>
		cprintf("%s", prompt);
f0105ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ba8:	c7 04 24 dd 79 10 f0 	movl   $0xf01079dd,(%esp)
f0105baf:	e8 c2 e3 ff ff       	call   f0103f76 <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105bb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105bbb:	e8 0f ac ff ff       	call   f01007cf <iscons>
f0105bc0:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105bc2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105bc7:	e8 f2 ab ff ff       	call   f01007be <getchar>
f0105bcc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105bce:	85 c0                	test   %eax,%eax
f0105bd0:	79 20                	jns    f0105bf2 <readline+0x5e>
			if (c != -E_EOF)
f0105bd2:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105bd5:	0f 84 82 00 00 00    	je     f0105c5d <readline+0xc9>
				cprintf("read error: %e\n", c);
f0105bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bdf:	c7 04 24 ff 84 10 f0 	movl   $0xf01084ff,(%esp)
f0105be6:	e8 8b e3 ff ff       	call   f0103f76 <cprintf>
			return NULL;
f0105beb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bf0:	eb 70                	jmp    f0105c62 <readline+0xce>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105bf2:	83 f8 08             	cmp    $0x8,%eax
f0105bf5:	74 05                	je     f0105bfc <readline+0x68>
f0105bf7:	83 f8 7f             	cmp    $0x7f,%eax
f0105bfa:	75 17                	jne    f0105c13 <readline+0x7f>
f0105bfc:	85 f6                	test   %esi,%esi
f0105bfe:	7e 13                	jle    f0105c13 <readline+0x7f>
			if (echoing)
f0105c00:	85 ff                	test   %edi,%edi
f0105c02:	74 0c                	je     f0105c10 <readline+0x7c>
				cputchar('\b');
f0105c04:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105c0b:	e8 9e ab ff ff       	call   f01007ae <cputchar>
			i--;
f0105c10:	4e                   	dec    %esi
f0105c11:	eb b4                	jmp    f0105bc7 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c13:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c16:	7e 1d                	jle    f0105c35 <readline+0xa1>
f0105c18:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c1e:	7f 15                	jg     f0105c35 <readline+0xa1>
			if (echoing)
f0105c20:	85 ff                	test   %edi,%edi
f0105c22:	74 08                	je     f0105c2c <readline+0x98>
				cputchar(c);
f0105c24:	89 1c 24             	mov    %ebx,(%esp)
f0105c27:	e8 82 ab ff ff       	call   f01007ae <cputchar>
			buf[i++] = c;
f0105c2c:	88 9e 80 4a 22 f0    	mov    %bl,-0xfddb580(%esi)
f0105c32:	46                   	inc    %esi
f0105c33:	eb 92                	jmp    f0105bc7 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105c35:	83 fb 0a             	cmp    $0xa,%ebx
f0105c38:	74 05                	je     f0105c3f <readline+0xab>
f0105c3a:	83 fb 0d             	cmp    $0xd,%ebx
f0105c3d:	75 88                	jne    f0105bc7 <readline+0x33>
			if (echoing)
f0105c3f:	85 ff                	test   %edi,%edi
f0105c41:	74 0c                	je     f0105c4f <readline+0xbb>
				cputchar('\n');
f0105c43:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105c4a:	e8 5f ab ff ff       	call   f01007ae <cputchar>
			buf[i] = 0;
f0105c4f:	c6 86 80 4a 22 f0 00 	movb   $0x0,-0xfddb580(%esi)
			return buf;
f0105c56:	b8 80 4a 22 f0       	mov    $0xf0224a80,%eax
f0105c5b:	eb 05                	jmp    f0105c62 <readline+0xce>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105c5d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105c62:	83 c4 1c             	add    $0x1c,%esp
f0105c65:	5b                   	pop    %ebx
f0105c66:	5e                   	pop    %esi
f0105c67:	5f                   	pop    %edi
f0105c68:	5d                   	pop    %ebp
f0105c69:	c3                   	ret    
	...

f0105c6c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105c6c:	55                   	push   %ebp
f0105c6d:	89 e5                	mov    %esp,%ebp
f0105c6f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c72:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c77:	eb 01                	jmp    f0105c7a <strlen+0xe>
		n++;
f0105c79:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c7a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105c7e:	75 f9                	jne    f0105c79 <strlen+0xd>
		n++;
	return n;
}
f0105c80:	5d                   	pop    %ebp
f0105c81:	c3                   	ret    

f0105c82 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105c82:	55                   	push   %ebp
f0105c83:	89 e5                	mov    %esp,%ebp
f0105c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105c88:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c90:	eb 01                	jmp    f0105c93 <strnlen+0x11>
		n++;
f0105c92:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c93:	39 d0                	cmp    %edx,%eax
f0105c95:	74 06                	je     f0105c9d <strnlen+0x1b>
f0105c97:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105c9b:	75 f5                	jne    f0105c92 <strnlen+0x10>
		n++;
	return n;
}
f0105c9d:	5d                   	pop    %ebp
f0105c9e:	c3                   	ret    

f0105c9f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105c9f:	55                   	push   %ebp
f0105ca0:	89 e5                	mov    %esp,%ebp
f0105ca2:	53                   	push   %ebx
f0105ca3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ca6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105ca9:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105cb1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105cb4:	42                   	inc    %edx
f0105cb5:	84 c9                	test   %cl,%cl
f0105cb7:	75 f5                	jne    f0105cae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105cb9:	5b                   	pop    %ebx
f0105cba:	5d                   	pop    %ebp
f0105cbb:	c3                   	ret    

f0105cbc <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105cbc:	55                   	push   %ebp
f0105cbd:	89 e5                	mov    %esp,%ebp
f0105cbf:	53                   	push   %ebx
f0105cc0:	83 ec 08             	sub    $0x8,%esp
f0105cc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105cc6:	89 1c 24             	mov    %ebx,(%esp)
f0105cc9:	e8 9e ff ff ff       	call   f0105c6c <strlen>
	strcpy(dst + len, src);
f0105cce:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cd1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105cd5:	01 d8                	add    %ebx,%eax
f0105cd7:	89 04 24             	mov    %eax,(%esp)
f0105cda:	e8 c0 ff ff ff       	call   f0105c9f <strcpy>
	return dst;
}
f0105cdf:	89 d8                	mov    %ebx,%eax
f0105ce1:	83 c4 08             	add    $0x8,%esp
f0105ce4:	5b                   	pop    %ebx
f0105ce5:	5d                   	pop    %ebp
f0105ce6:	c3                   	ret    

f0105ce7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105ce7:	55                   	push   %ebp
f0105ce8:	89 e5                	mov    %esp,%ebp
f0105cea:	56                   	push   %esi
f0105ceb:	53                   	push   %ebx
f0105cec:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cef:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cf2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105cfa:	eb 0c                	jmp    f0105d08 <strncpy+0x21>
		*dst++ = *src;
f0105cfc:	8a 1a                	mov    (%edx),%bl
f0105cfe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105d01:	80 3a 01             	cmpb   $0x1,(%edx)
f0105d04:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d07:	41                   	inc    %ecx
f0105d08:	39 f1                	cmp    %esi,%ecx
f0105d0a:	75 f0                	jne    f0105cfc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105d0c:	5b                   	pop    %ebx
f0105d0d:	5e                   	pop    %esi
f0105d0e:	5d                   	pop    %ebp
f0105d0f:	c3                   	ret    

f0105d10 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d10:	55                   	push   %ebp
f0105d11:	89 e5                	mov    %esp,%ebp
f0105d13:	56                   	push   %esi
f0105d14:	53                   	push   %ebx
f0105d15:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d1b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d1e:	85 d2                	test   %edx,%edx
f0105d20:	75 0a                	jne    f0105d2c <strlcpy+0x1c>
f0105d22:	89 f0                	mov    %esi,%eax
f0105d24:	eb 1a                	jmp    f0105d40 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105d26:	88 18                	mov    %bl,(%eax)
f0105d28:	40                   	inc    %eax
f0105d29:	41                   	inc    %ecx
f0105d2a:	eb 02                	jmp    f0105d2e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d2c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0105d2e:	4a                   	dec    %edx
f0105d2f:	74 0a                	je     f0105d3b <strlcpy+0x2b>
f0105d31:	8a 19                	mov    (%ecx),%bl
f0105d33:	84 db                	test   %bl,%bl
f0105d35:	75 ef                	jne    f0105d26 <strlcpy+0x16>
f0105d37:	89 c2                	mov    %eax,%edx
f0105d39:	eb 02                	jmp    f0105d3d <strlcpy+0x2d>
f0105d3b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105d3d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105d40:	29 f0                	sub    %esi,%eax
}
f0105d42:	5b                   	pop    %ebx
f0105d43:	5e                   	pop    %esi
f0105d44:	5d                   	pop    %ebp
f0105d45:	c3                   	ret    

f0105d46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105d46:	55                   	push   %ebp
f0105d47:	89 e5                	mov    %esp,%ebp
f0105d49:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105d4f:	eb 02                	jmp    f0105d53 <strcmp+0xd>
		p++, q++;
f0105d51:	41                   	inc    %ecx
f0105d52:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105d53:	8a 01                	mov    (%ecx),%al
f0105d55:	84 c0                	test   %al,%al
f0105d57:	74 04                	je     f0105d5d <strcmp+0x17>
f0105d59:	3a 02                	cmp    (%edx),%al
f0105d5b:	74 f4                	je     f0105d51 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d5d:	0f b6 c0             	movzbl %al,%eax
f0105d60:	0f b6 12             	movzbl (%edx),%edx
f0105d63:	29 d0                	sub    %edx,%eax
}
f0105d65:	5d                   	pop    %ebp
f0105d66:	c3                   	ret    

f0105d67 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105d67:	55                   	push   %ebp
f0105d68:	89 e5                	mov    %esp,%ebp
f0105d6a:	53                   	push   %ebx
f0105d6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d71:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105d74:	eb 03                	jmp    f0105d79 <strncmp+0x12>
		n--, p++, q++;
f0105d76:	4a                   	dec    %edx
f0105d77:	40                   	inc    %eax
f0105d78:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105d79:	85 d2                	test   %edx,%edx
f0105d7b:	74 14                	je     f0105d91 <strncmp+0x2a>
f0105d7d:	8a 18                	mov    (%eax),%bl
f0105d7f:	84 db                	test   %bl,%bl
f0105d81:	74 04                	je     f0105d87 <strncmp+0x20>
f0105d83:	3a 19                	cmp    (%ecx),%bl
f0105d85:	74 ef                	je     f0105d76 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d87:	0f b6 00             	movzbl (%eax),%eax
f0105d8a:	0f b6 11             	movzbl (%ecx),%edx
f0105d8d:	29 d0                	sub    %edx,%eax
f0105d8f:	eb 05                	jmp    f0105d96 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105d91:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105d96:	5b                   	pop    %ebx
f0105d97:	5d                   	pop    %ebp
f0105d98:	c3                   	ret    

f0105d99 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105d99:	55                   	push   %ebp
f0105d9a:	89 e5                	mov    %esp,%ebp
f0105d9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d9f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105da2:	eb 05                	jmp    f0105da9 <strchr+0x10>
		if (*s == c)
f0105da4:	38 ca                	cmp    %cl,%dl
f0105da6:	74 0c                	je     f0105db4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105da8:	40                   	inc    %eax
f0105da9:	8a 10                	mov    (%eax),%dl
f0105dab:	84 d2                	test   %dl,%dl
f0105dad:	75 f5                	jne    f0105da4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0105daf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105db4:	5d                   	pop    %ebp
f0105db5:	c3                   	ret    

f0105db6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105db6:	55                   	push   %ebp
f0105db7:	89 e5                	mov    %esp,%ebp
f0105db9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dbc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105dbf:	eb 05                	jmp    f0105dc6 <strfind+0x10>
		if (*s == c)
f0105dc1:	38 ca                	cmp    %cl,%dl
f0105dc3:	74 07                	je     f0105dcc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105dc5:	40                   	inc    %eax
f0105dc6:	8a 10                	mov    (%eax),%dl
f0105dc8:	84 d2                	test   %dl,%dl
f0105dca:	75 f5                	jne    f0105dc1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0105dcc:	5d                   	pop    %ebp
f0105dcd:	c3                   	ret    

f0105dce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105dce:	55                   	push   %ebp
f0105dcf:	89 e5                	mov    %esp,%ebp
f0105dd1:	57                   	push   %edi
f0105dd2:	56                   	push   %esi
f0105dd3:	53                   	push   %ebx
f0105dd4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105dda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105ddd:	85 c9                	test   %ecx,%ecx
f0105ddf:	74 30                	je     f0105e11 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105de1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105de7:	75 25                	jne    f0105e0e <memset+0x40>
f0105de9:	f6 c1 03             	test   $0x3,%cl
f0105dec:	75 20                	jne    f0105e0e <memset+0x40>
		c &= 0xFF;
f0105dee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105df1:	89 d3                	mov    %edx,%ebx
f0105df3:	c1 e3 08             	shl    $0x8,%ebx
f0105df6:	89 d6                	mov    %edx,%esi
f0105df8:	c1 e6 18             	shl    $0x18,%esi
f0105dfb:	89 d0                	mov    %edx,%eax
f0105dfd:	c1 e0 10             	shl    $0x10,%eax
f0105e00:	09 f0                	or     %esi,%eax
f0105e02:	09 d0                	or     %edx,%eax
f0105e04:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105e06:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105e09:	fc                   	cld    
f0105e0a:	f3 ab                	rep stos %eax,%es:(%edi)
f0105e0c:	eb 03                	jmp    f0105e11 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105e0e:	fc                   	cld    
f0105e0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105e11:	89 f8                	mov    %edi,%eax
f0105e13:	5b                   	pop    %ebx
f0105e14:	5e                   	pop    %esi
f0105e15:	5f                   	pop    %edi
f0105e16:	5d                   	pop    %ebp
f0105e17:	c3                   	ret    

f0105e18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105e18:	55                   	push   %ebp
f0105e19:	89 e5                	mov    %esp,%ebp
f0105e1b:	57                   	push   %edi
f0105e1c:	56                   	push   %esi
f0105e1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e20:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105e26:	39 c6                	cmp    %eax,%esi
f0105e28:	73 34                	jae    f0105e5e <memmove+0x46>
f0105e2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105e2d:	39 d0                	cmp    %edx,%eax
f0105e2f:	73 2d                	jae    f0105e5e <memmove+0x46>
		s += n;
		d += n;
f0105e31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e34:	f6 c2 03             	test   $0x3,%dl
f0105e37:	75 1b                	jne    f0105e54 <memmove+0x3c>
f0105e39:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105e3f:	75 13                	jne    f0105e54 <memmove+0x3c>
f0105e41:	f6 c1 03             	test   $0x3,%cl
f0105e44:	75 0e                	jne    f0105e54 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105e46:	83 ef 04             	sub    $0x4,%edi
f0105e49:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105e4c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105e4f:	fd                   	std    
f0105e50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e52:	eb 07                	jmp    f0105e5b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105e54:	4f                   	dec    %edi
f0105e55:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105e58:	fd                   	std    
f0105e59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105e5b:	fc                   	cld    
f0105e5c:	eb 20                	jmp    f0105e7e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105e64:	75 13                	jne    f0105e79 <memmove+0x61>
f0105e66:	a8 03                	test   $0x3,%al
f0105e68:	75 0f                	jne    f0105e79 <memmove+0x61>
f0105e6a:	f6 c1 03             	test   $0x3,%cl
f0105e6d:	75 0a                	jne    f0105e79 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105e6f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105e72:	89 c7                	mov    %eax,%edi
f0105e74:	fc                   	cld    
f0105e75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e77:	eb 05                	jmp    f0105e7e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105e79:	89 c7                	mov    %eax,%edi
f0105e7b:	fc                   	cld    
f0105e7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105e7e:	5e                   	pop    %esi
f0105e7f:	5f                   	pop    %edi
f0105e80:	5d                   	pop    %ebp
f0105e81:	c3                   	ret    

f0105e82 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105e82:	55                   	push   %ebp
f0105e83:	89 e5                	mov    %esp,%ebp
f0105e85:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105e88:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e96:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e99:	89 04 24             	mov    %eax,(%esp)
f0105e9c:	e8 77 ff ff ff       	call   f0105e18 <memmove>
}
f0105ea1:	c9                   	leave  
f0105ea2:	c3                   	ret    

f0105ea3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105ea3:	55                   	push   %ebp
f0105ea4:	89 e5                	mov    %esp,%ebp
f0105ea6:	57                   	push   %edi
f0105ea7:	56                   	push   %esi
f0105ea8:	53                   	push   %ebx
f0105ea9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105eac:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105eaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105eb2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eb7:	eb 16                	jmp    f0105ecf <memcmp+0x2c>
		if (*s1 != *s2)
f0105eb9:	8a 04 17             	mov    (%edi,%edx,1),%al
f0105ebc:	42                   	inc    %edx
f0105ebd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0105ec1:	38 c8                	cmp    %cl,%al
f0105ec3:	74 0a                	je     f0105ecf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0105ec5:	0f b6 c0             	movzbl %al,%eax
f0105ec8:	0f b6 c9             	movzbl %cl,%ecx
f0105ecb:	29 c8                	sub    %ecx,%eax
f0105ecd:	eb 09                	jmp    f0105ed8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ecf:	39 da                	cmp    %ebx,%edx
f0105ed1:	75 e6                	jne    f0105eb9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105ed3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ed8:	5b                   	pop    %ebx
f0105ed9:	5e                   	pop    %esi
f0105eda:	5f                   	pop    %edi
f0105edb:	5d                   	pop    %ebp
f0105edc:	c3                   	ret    

f0105edd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105edd:	55                   	push   %ebp
f0105ede:	89 e5                	mov    %esp,%ebp
f0105ee0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105ee6:	89 c2                	mov    %eax,%edx
f0105ee8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105eeb:	eb 05                	jmp    f0105ef2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105eed:	38 08                	cmp    %cl,(%eax)
f0105eef:	74 05                	je     f0105ef6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105ef1:	40                   	inc    %eax
f0105ef2:	39 d0                	cmp    %edx,%eax
f0105ef4:	72 f7                	jb     f0105eed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105ef6:	5d                   	pop    %ebp
f0105ef7:	c3                   	ret    

f0105ef8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105ef8:	55                   	push   %ebp
f0105ef9:	89 e5                	mov    %esp,%ebp
f0105efb:	57                   	push   %edi
f0105efc:	56                   	push   %esi
f0105efd:	53                   	push   %ebx
f0105efe:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105f04:	eb 01                	jmp    f0105f07 <strtol+0xf>
		s++;
f0105f06:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105f07:	8a 02                	mov    (%edx),%al
f0105f09:	3c 20                	cmp    $0x20,%al
f0105f0b:	74 f9                	je     f0105f06 <strtol+0xe>
f0105f0d:	3c 09                	cmp    $0x9,%al
f0105f0f:	74 f5                	je     f0105f06 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105f11:	3c 2b                	cmp    $0x2b,%al
f0105f13:	75 08                	jne    f0105f1d <strtol+0x25>
		s++;
f0105f15:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105f16:	bf 00 00 00 00       	mov    $0x0,%edi
f0105f1b:	eb 13                	jmp    f0105f30 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105f1d:	3c 2d                	cmp    $0x2d,%al
f0105f1f:	75 0a                	jne    f0105f2b <strtol+0x33>
		s++, neg = 1;
f0105f21:	8d 52 01             	lea    0x1(%edx),%edx
f0105f24:	bf 01 00 00 00       	mov    $0x1,%edi
f0105f29:	eb 05                	jmp    f0105f30 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105f2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f30:	85 db                	test   %ebx,%ebx
f0105f32:	74 05                	je     f0105f39 <strtol+0x41>
f0105f34:	83 fb 10             	cmp    $0x10,%ebx
f0105f37:	75 28                	jne    f0105f61 <strtol+0x69>
f0105f39:	8a 02                	mov    (%edx),%al
f0105f3b:	3c 30                	cmp    $0x30,%al
f0105f3d:	75 10                	jne    f0105f4f <strtol+0x57>
f0105f3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105f43:	75 0a                	jne    f0105f4f <strtol+0x57>
		s += 2, base = 16;
f0105f45:	83 c2 02             	add    $0x2,%edx
f0105f48:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105f4d:	eb 12                	jmp    f0105f61 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0105f4f:	85 db                	test   %ebx,%ebx
f0105f51:	75 0e                	jne    f0105f61 <strtol+0x69>
f0105f53:	3c 30                	cmp    $0x30,%al
f0105f55:	75 05                	jne    f0105f5c <strtol+0x64>
		s++, base = 8;
f0105f57:	42                   	inc    %edx
f0105f58:	b3 08                	mov    $0x8,%bl
f0105f5a:	eb 05                	jmp    f0105f61 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0105f5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105f61:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105f68:	8a 0a                	mov    (%edx),%cl
f0105f6a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105f6d:	80 fb 09             	cmp    $0x9,%bl
f0105f70:	77 08                	ja     f0105f7a <strtol+0x82>
			dig = *s - '0';
f0105f72:	0f be c9             	movsbl %cl,%ecx
f0105f75:	83 e9 30             	sub    $0x30,%ecx
f0105f78:	eb 1e                	jmp    f0105f98 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0105f7a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105f7d:	80 fb 19             	cmp    $0x19,%bl
f0105f80:	77 08                	ja     f0105f8a <strtol+0x92>
			dig = *s - 'a' + 10;
f0105f82:	0f be c9             	movsbl %cl,%ecx
f0105f85:	83 e9 57             	sub    $0x57,%ecx
f0105f88:	eb 0e                	jmp    f0105f98 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0105f8a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105f8d:	80 fb 19             	cmp    $0x19,%bl
f0105f90:	77 12                	ja     f0105fa4 <strtol+0xac>
			dig = *s - 'A' + 10;
f0105f92:	0f be c9             	movsbl %cl,%ecx
f0105f95:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105f98:	39 f1                	cmp    %esi,%ecx
f0105f9a:	7d 0c                	jge    f0105fa8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0105f9c:	42                   	inc    %edx
f0105f9d:	0f af c6             	imul   %esi,%eax
f0105fa0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0105fa2:	eb c4                	jmp    f0105f68 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105fa4:	89 c1                	mov    %eax,%ecx
f0105fa6:	eb 02                	jmp    f0105faa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105fa8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105faa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105fae:	74 05                	je     f0105fb5 <strtol+0xbd>
		*endptr = (char *) s;
f0105fb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105fb3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105fb5:	85 ff                	test   %edi,%edi
f0105fb7:	74 04                	je     f0105fbd <strtol+0xc5>
f0105fb9:	89 c8                	mov    %ecx,%eax
f0105fbb:	f7 d8                	neg    %eax
}
f0105fbd:	5b                   	pop    %ebx
f0105fbe:	5e                   	pop    %esi
f0105fbf:	5f                   	pop    %edi
f0105fc0:	5d                   	pop    %ebp
f0105fc1:	c3                   	ret    
	...

f0105fc4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105fc4:	fa                   	cli    

	xorw    %ax, %ax
f0105fc5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105fc7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105fc9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105fcb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105fcd:	0f 01 16             	lgdtl  (%esi)
f0105fd0:	74 70                	je     f0106042 <sum+0x2>
	movl    %cr0, %eax
f0105fd2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105fd5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105fd9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105fdc:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105fe2:	08 00                	or     %al,(%eax)

f0105fe4 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105fe4:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105fe8:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105fea:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105fec:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105fee:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105ff2:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105ff4:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105ff6:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f0105ffb:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105ffe:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106001:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106006:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106009:	8b 25 84 4e 22 f0    	mov    0xf0224e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010600f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106014:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106019:	ff d0                	call   *%eax

f010601b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010601b:	eb fe                	jmp    f010601b <spin>
f010601d:	8d 76 00             	lea    0x0(%esi),%esi

f0106020 <gdt>:
	...
f0106028:	ff                   	(bad)  
f0106029:	ff 00                	incl   (%eax)
f010602b:	00 00                	add    %al,(%eax)
f010602d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106034:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106038 <gdtdesc>:
f0106038:	17                   	pop    %ss
f0106039:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010603e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010603e:	90                   	nop
	...

f0106040 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106040:	55                   	push   %ebp
f0106041:	89 e5                	mov    %esp,%ebp
f0106043:	56                   	push   %esi
f0106044:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106045:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010604a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010604f:	eb 07                	jmp    f0106058 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f0106051:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106055:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106057:	41                   	inc    %ecx
f0106058:	39 d1                	cmp    %edx,%ecx
f010605a:	7c f5                	jl     f0106051 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f010605c:	88 d8                	mov    %bl,%al
f010605e:	5b                   	pop    %ebx
f010605f:	5e                   	pop    %esi
f0106060:	5d                   	pop    %ebp
f0106061:	c3                   	ret    

f0106062 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106062:	55                   	push   %ebp
f0106063:	89 e5                	mov    %esp,%ebp
f0106065:	56                   	push   %esi
f0106066:	53                   	push   %ebx
f0106067:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010606a:	8b 0d 88 4e 22 f0    	mov    0xf0224e88,%ecx
f0106070:	89 c3                	mov    %eax,%ebx
f0106072:	c1 eb 0c             	shr    $0xc,%ebx
f0106075:	39 cb                	cmp    %ecx,%ebx
f0106077:	72 20                	jb     f0106099 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106079:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010607d:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f0106084:	f0 
f0106085:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010608c:	00 
f010608d:	c7 04 24 9d 86 10 f0 	movl   $0xf010869d,(%esp)
f0106094:	e8 a7 9f ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106099:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010609c:	89 f2                	mov    %esi,%edx
f010609e:	c1 ea 0c             	shr    $0xc,%edx
f01060a1:	39 d1                	cmp    %edx,%ecx
f01060a3:	77 20                	ja     f01060c5 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01060a9:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01060b0:	f0 
f01060b1:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01060b8:	00 
f01060b9:	c7 04 24 9d 86 10 f0 	movl   $0xf010869d,(%esp)
f01060c0:	e8 7b 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01060c5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01060cb:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01060d1:	eb 2f                	jmp    f0106102 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060d3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01060da:	00 
f01060db:	c7 44 24 04 ad 86 10 	movl   $0xf01086ad,0x4(%esp)
f01060e2:	f0 
f01060e3:	89 1c 24             	mov    %ebx,(%esp)
f01060e6:	e8 b8 fd ff ff       	call   f0105ea3 <memcmp>
f01060eb:	85 c0                	test   %eax,%eax
f01060ed:	75 10                	jne    f01060ff <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f01060ef:	ba 10 00 00 00       	mov    $0x10,%edx
f01060f4:	89 d8                	mov    %ebx,%eax
f01060f6:	e8 45 ff ff ff       	call   f0106040 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060fb:	84 c0                	test   %al,%al
f01060fd:	74 0c                	je     f010610b <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01060ff:	83 c3 10             	add    $0x10,%ebx
f0106102:	39 f3                	cmp    %esi,%ebx
f0106104:	72 cd                	jb     f01060d3 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106106:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010610b:	89 d8                	mov    %ebx,%eax
f010610d:	83 c4 10             	add    $0x10,%esp
f0106110:	5b                   	pop    %ebx
f0106111:	5e                   	pop    %esi
f0106112:	5d                   	pop    %ebp
f0106113:	c3                   	ret    

f0106114 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106114:	55                   	push   %ebp
f0106115:	89 e5                	mov    %esp,%ebp
f0106117:	57                   	push   %edi
f0106118:	56                   	push   %esi
f0106119:	53                   	push   %ebx
f010611a:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010611d:	c7 05 c0 53 22 f0 20 	movl   $0xf0225020,0xf02253c0
f0106124:	50 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106127:	83 3d 88 4e 22 f0 00 	cmpl   $0x0,0xf0224e88
f010612e:	75 24                	jne    f0106154 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106130:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106137:	00 
f0106138:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f010613f:	f0 
f0106140:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106147:	00 
f0106148:	c7 04 24 9d 86 10 f0 	movl   $0xf010869d,(%esp)
f010614f:	e8 ec 9e ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106154:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010615b:	85 c0                	test   %eax,%eax
f010615d:	74 16                	je     f0106175 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010615f:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106162:	ba 00 04 00 00       	mov    $0x400,%edx
f0106167:	e8 f6 fe ff ff       	call   f0106062 <mpsearch1>
f010616c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010616f:	85 c0                	test   %eax,%eax
f0106171:	75 3c                	jne    f01061af <mp_init+0x9b>
f0106173:	eb 20                	jmp    f0106195 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106175:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010617c:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010617f:	2d 00 04 00 00       	sub    $0x400,%eax
f0106184:	ba 00 04 00 00       	mov    $0x400,%edx
f0106189:	e8 d4 fe ff ff       	call   f0106062 <mpsearch1>
f010618e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106191:	85 c0                	test   %eax,%eax
f0106193:	75 1a                	jne    f01061af <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106195:	ba 00 00 01 00       	mov    $0x10000,%edx
f010619a:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010619f:	e8 be fe ff ff       	call   f0106062 <mpsearch1>
f01061a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01061a7:	85 c0                	test   %eax,%eax
f01061a9:	0f 84 2c 02 00 00    	je     f01063db <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01061af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01061b2:	8b 58 04             	mov    0x4(%eax),%ebx
f01061b5:	85 db                	test   %ebx,%ebx
f01061b7:	74 06                	je     f01061bf <mp_init+0xab>
f01061b9:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01061bd:	74 11                	je     f01061d0 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01061bf:	c7 04 24 10 85 10 f0 	movl   $0xf0108510,(%esp)
f01061c6:	e8 ab dd ff ff       	call   f0103f76 <cprintf>
f01061cb:	e9 0b 02 00 00       	jmp    f01063db <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061d0:	89 d8                	mov    %ebx,%eax
f01061d2:	c1 e8 0c             	shr    $0xc,%eax
f01061d5:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f01061db:	72 20                	jb     f01061fd <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01061e1:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01061e8:	f0 
f01061e9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01061f0:	00 
f01061f1:	c7 04 24 9d 86 10 f0 	movl   $0xf010869d,(%esp)
f01061f8:	e8 43 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01061fd:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106203:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010620a:	00 
f010620b:	c7 44 24 04 b2 86 10 	movl   $0xf01086b2,0x4(%esp)
f0106212:	f0 
f0106213:	89 1c 24             	mov    %ebx,(%esp)
f0106216:	e8 88 fc ff ff       	call   f0105ea3 <memcmp>
f010621b:	85 c0                	test   %eax,%eax
f010621d:	74 11                	je     f0106230 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010621f:	c7 04 24 40 85 10 f0 	movl   $0xf0108540,(%esp)
f0106226:	e8 4b dd ff ff       	call   f0103f76 <cprintf>
f010622b:	e9 ab 01 00 00       	jmp    f01063db <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106230:	66 8b 73 04          	mov    0x4(%ebx),%si
f0106234:	0f b7 d6             	movzwl %si,%edx
f0106237:	89 d8                	mov    %ebx,%eax
f0106239:	e8 02 fe ff ff       	call   f0106040 <sum>
f010623e:	84 c0                	test   %al,%al
f0106240:	74 11                	je     f0106253 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106242:	c7 04 24 74 85 10 f0 	movl   $0xf0108574,(%esp)
f0106249:	e8 28 dd ff ff       	call   f0103f76 <cprintf>
f010624e:	e9 88 01 00 00       	jmp    f01063db <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106253:	8a 43 06             	mov    0x6(%ebx),%al
f0106256:	3c 01                	cmp    $0x1,%al
f0106258:	74 1c                	je     f0106276 <mp_init+0x162>
f010625a:	3c 04                	cmp    $0x4,%al
f010625c:	74 18                	je     f0106276 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010625e:	0f b6 c0             	movzbl %al,%eax
f0106261:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106265:	c7 04 24 98 85 10 f0 	movl   $0xf0108598,(%esp)
f010626c:	e8 05 dd ff ff       	call   f0103f76 <cprintf>
f0106271:	e9 65 01 00 00       	jmp    f01063db <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106276:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f010627a:	0f b7 c6             	movzwl %si,%eax
f010627d:	01 d8                	add    %ebx,%eax
f010627f:	e8 bc fd ff ff       	call   f0106040 <sum>
f0106284:	02 43 2a             	add    0x2a(%ebx),%al
f0106287:	84 c0                	test   %al,%al
f0106289:	74 11                	je     f010629c <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010628b:	c7 04 24 b8 85 10 f0 	movl   $0xf01085b8,(%esp)
f0106292:	e8 df dc ff ff       	call   f0103f76 <cprintf>
f0106297:	e9 3f 01 00 00       	jmp    f01063db <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010629c:	85 db                	test   %ebx,%ebx
f010629e:	0f 84 37 01 00 00    	je     f01063db <mp_init+0x2c7>
		return;
	ismp = 1;
f01062a4:	c7 05 00 50 22 f0 01 	movl   $0x1,0xf0225000
f01062ab:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01062ae:	8b 43 24             	mov    0x24(%ebx),%eax
f01062b1:	a3 00 60 26 f0       	mov    %eax,0xf0266000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062b6:	8d 73 2c             	lea    0x2c(%ebx),%esi
f01062b9:	bf 00 00 00 00       	mov    $0x0,%edi
f01062be:	e9 94 00 00 00       	jmp    f0106357 <mp_init+0x243>
		switch (*p) {
f01062c3:	8a 06                	mov    (%esi),%al
f01062c5:	84 c0                	test   %al,%al
f01062c7:	74 06                	je     f01062cf <mp_init+0x1bb>
f01062c9:	3c 04                	cmp    $0x4,%al
f01062cb:	77 68                	ja     f0106335 <mp_init+0x221>
f01062cd:	eb 61                	jmp    f0106330 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01062cf:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01062d3:	74 1d                	je     f01062f2 <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f01062d5:	a1 c4 53 22 f0       	mov    0xf02253c4,%eax
f01062da:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01062e1:	29 c2                	sub    %eax,%edx
f01062e3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01062e6:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f01062ed:	a3 c0 53 22 f0       	mov    %eax,0xf02253c0
			if (ncpu < NCPU) {
f01062f2:	a1 c4 53 22 f0       	mov    0xf02253c4,%eax
f01062f7:	83 f8 07             	cmp    $0x7,%eax
f01062fa:	7f 1b                	jg     f0106317 <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f01062fc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106303:	29 c2                	sub    %eax,%edx
f0106305:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106308:	88 04 95 20 50 22 f0 	mov    %al,-0xfddafe0(,%edx,4)
				ncpu++;
f010630f:	40                   	inc    %eax
f0106310:	a3 c4 53 22 f0       	mov    %eax,0xf02253c4
f0106315:	eb 14                	jmp    f010632b <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106317:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010631b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010631f:	c7 04 24 e8 85 10 f0 	movl   $0xf01085e8,(%esp)
f0106326:	e8 4b dc ff ff       	call   f0103f76 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010632b:	83 c6 14             	add    $0x14,%esi
			continue;
f010632e:	eb 26                	jmp    f0106356 <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106330:	83 c6 08             	add    $0x8,%esi
			continue;
f0106333:	eb 21                	jmp    f0106356 <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106335:	0f b6 c0             	movzbl %al,%eax
f0106338:	89 44 24 04          	mov    %eax,0x4(%esp)
f010633c:	c7 04 24 10 86 10 f0 	movl   $0xf0108610,(%esp)
f0106343:	e8 2e dc ff ff       	call   f0103f76 <cprintf>
			ismp = 0;
f0106348:	c7 05 00 50 22 f0 00 	movl   $0x0,0xf0225000
f010634f:	00 00 00 
			i = conf->entry;
f0106352:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106356:	47                   	inc    %edi
f0106357:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010635b:	39 c7                	cmp    %eax,%edi
f010635d:	0f 82 60 ff ff ff    	jb     f01062c3 <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106363:	a1 c0 53 22 f0       	mov    0xf02253c0,%eax
f0106368:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010636f:	83 3d 00 50 22 f0 00 	cmpl   $0x0,0xf0225000
f0106376:	75 22                	jne    f010639a <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106378:	c7 05 c4 53 22 f0 01 	movl   $0x1,0xf02253c4
f010637f:	00 00 00 
		lapicaddr = 0;
f0106382:	c7 05 00 60 26 f0 00 	movl   $0x0,0xf0266000
f0106389:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010638c:	c7 04 24 30 86 10 f0 	movl   $0xf0108630,(%esp)
f0106393:	e8 de db ff ff       	call   f0103f76 <cprintf>
		return;
f0106398:	eb 41                	jmp    f01063db <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010639a:	8b 15 c4 53 22 f0    	mov    0xf02253c4,%edx
f01063a0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01063a4:	0f b6 00             	movzbl (%eax),%eax
f01063a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063ab:	c7 04 24 b7 86 10 f0 	movl   $0xf01086b7,(%esp)
f01063b2:	e8 bf db ff ff       	call   f0103f76 <cprintf>

	if (mp->imcrp) {
f01063b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063ba:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01063be:	74 1b                	je     f01063db <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01063c0:	c7 04 24 5c 86 10 f0 	movl   $0xf010865c,(%esp)
f01063c7:	e8 aa db ff ff       	call   f0103f76 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063cc:	ba 22 00 00 00       	mov    $0x22,%edx
f01063d1:	b0 70                	mov    $0x70,%al
f01063d3:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01063d4:	b2 23                	mov    $0x23,%dl
f01063d6:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01063d7:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063da:	ee                   	out    %al,(%dx)
	}
}
f01063db:	83 c4 2c             	add    $0x2c,%esp
f01063de:	5b                   	pop    %ebx
f01063df:	5e                   	pop    %esi
f01063e0:	5f                   	pop    %edi
f01063e1:	5d                   	pop    %ebp
f01063e2:	c3                   	ret    
	...

f01063e4 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01063e4:	55                   	push   %ebp
f01063e5:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01063e7:	c1 e0 02             	shl    $0x2,%eax
f01063ea:	03 05 04 60 26 f0    	add    0xf0266004,%eax
f01063f0:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01063f2:	a1 04 60 26 f0       	mov    0xf0266004,%eax
f01063f7:	8b 40 20             	mov    0x20(%eax),%eax
}
f01063fa:	5d                   	pop    %ebp
f01063fb:	c3                   	ret    

f01063fc <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01063fc:	55                   	push   %ebp
f01063fd:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01063ff:	a1 04 60 26 f0       	mov    0xf0266004,%eax
f0106404:	85 c0                	test   %eax,%eax
f0106406:	74 08                	je     f0106410 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106408:	8b 40 20             	mov    0x20(%eax),%eax
f010640b:	c1 e8 18             	shr    $0x18,%eax
f010640e:	eb 05                	jmp    f0106415 <cpunum+0x19>
	return 0;
f0106410:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106415:	5d                   	pop    %ebp
f0106416:	c3                   	ret    

f0106417 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106417:	55                   	push   %ebp
f0106418:	89 e5                	mov    %esp,%ebp
f010641a:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f010641d:	a1 00 60 26 f0       	mov    0xf0266000,%eax
f0106422:	85 c0                	test   %eax,%eax
f0106424:	0f 84 27 01 00 00    	je     f0106551 <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010642a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106431:	00 
f0106432:	89 04 24             	mov    %eax,(%esp)
f0106435:	e8 ec af ff ff       	call   f0101426 <mmio_map_region>
f010643a:	a3 04 60 26 f0       	mov    %eax,0xf0266004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010643f:	ba 27 01 00 00       	mov    $0x127,%edx
f0106444:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106449:	e8 96 ff ff ff       	call   f01063e4 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010644e:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106453:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106458:	e8 87 ff ff ff       	call   f01063e4 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010645d:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106462:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106467:	e8 78 ff ff ff       	call   f01063e4 <lapicw>
	lapicw(TICR, 10000000); 
f010646c:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106471:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106476:	e8 69 ff ff ff       	call   f01063e4 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010647b:	e8 7c ff ff ff       	call   f01063fc <cpunum>
f0106480:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106487:	29 c2                	sub    %eax,%edx
f0106489:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010648c:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f0106493:	39 05 c0 53 22 f0    	cmp    %eax,0xf02253c0
f0106499:	74 0f                	je     f01064aa <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f010649b:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064a0:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01064a5:	e8 3a ff ff ff       	call   f01063e4 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01064aa:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064af:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01064b4:	e8 2b ff ff ff       	call   f01063e4 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01064b9:	a1 04 60 26 f0       	mov    0xf0266004,%eax
f01064be:	8b 40 30             	mov    0x30(%eax),%eax
f01064c1:	c1 e8 10             	shr    $0x10,%eax
f01064c4:	3c 03                	cmp    $0x3,%al
f01064c6:	76 0f                	jbe    f01064d7 <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f01064c8:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064cd:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01064d2:	e8 0d ff ff ff       	call   f01063e4 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01064d7:	ba 33 00 00 00       	mov    $0x33,%edx
f01064dc:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01064e1:	e8 fe fe ff ff       	call   f01063e4 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01064e6:	ba 00 00 00 00       	mov    $0x0,%edx
f01064eb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01064f0:	e8 ef fe ff ff       	call   f01063e4 <lapicw>
	lapicw(ESR, 0);
f01064f5:	ba 00 00 00 00       	mov    $0x0,%edx
f01064fa:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01064ff:	e8 e0 fe ff ff       	call   f01063e4 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106504:	ba 00 00 00 00       	mov    $0x0,%edx
f0106509:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010650e:	e8 d1 fe ff ff       	call   f01063e4 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106513:	ba 00 00 00 00       	mov    $0x0,%edx
f0106518:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010651d:	e8 c2 fe ff ff       	call   f01063e4 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106522:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106527:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010652c:	e8 b3 fe ff ff       	call   f01063e4 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106531:	8b 15 04 60 26 f0    	mov    0xf0266004,%edx
f0106537:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010653d:	f6 c4 10             	test   $0x10,%ah
f0106540:	75 f5                	jne    f0106537 <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106542:	ba 00 00 00 00       	mov    $0x0,%edx
f0106547:	b8 20 00 00 00       	mov    $0x20,%eax
f010654c:	e8 93 fe ff ff       	call   f01063e4 <lapicw>
}
f0106551:	c9                   	leave  
f0106552:	c3                   	ret    

f0106553 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106553:	55                   	push   %ebp
f0106554:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106556:	83 3d 04 60 26 f0 00 	cmpl   $0x0,0xf0266004
f010655d:	74 0f                	je     f010656e <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f010655f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106564:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106569:	e8 76 fe ff ff       	call   f01063e4 <lapicw>
}
f010656e:	5d                   	pop    %ebp
f010656f:	c3                   	ret    

f0106570 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106570:	55                   	push   %ebp
f0106571:	89 e5                	mov    %esp,%ebp
f0106573:	56                   	push   %esi
f0106574:	53                   	push   %ebx
f0106575:	83 ec 10             	sub    $0x10,%esp
f0106578:	8b 75 0c             	mov    0xc(%ebp),%esi
f010657b:	8a 5d 08             	mov    0x8(%ebp),%bl
f010657e:	ba 70 00 00 00       	mov    $0x70,%edx
f0106583:	b0 0f                	mov    $0xf,%al
f0106585:	ee                   	out    %al,(%dx)
f0106586:	b2 71                	mov    $0x71,%dl
f0106588:	b0 0a                	mov    $0xa,%al
f010658a:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010658b:	83 3d 88 4e 22 f0 00 	cmpl   $0x0,0xf0224e88
f0106592:	75 24                	jne    f01065b8 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106594:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010659b:	00 
f010659c:	c7 44 24 08 08 6b 10 	movl   $0xf0106b08,0x8(%esp)
f01065a3:	f0 
f01065a4:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01065ab:	00 
f01065ac:	c7 04 24 d4 86 10 f0 	movl   $0xf01086d4,(%esp)
f01065b3:	e8 88 9a ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01065b8:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01065bf:	00 00 
	wrv[1] = addr >> 4;
f01065c1:	89 f0                	mov    %esi,%eax
f01065c3:	c1 e8 04             	shr    $0x4,%eax
f01065c6:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01065cc:	c1 e3 18             	shl    $0x18,%ebx
f01065cf:	89 da                	mov    %ebx,%edx
f01065d1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065d6:	e8 09 fe ff ff       	call   f01063e4 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01065db:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01065e0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065e5:	e8 fa fd ff ff       	call   f01063e4 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01065ea:	ba 00 85 00 00       	mov    $0x8500,%edx
f01065ef:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065f4:	e8 eb fd ff ff       	call   f01063e4 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065f9:	c1 ee 0c             	shr    $0xc,%esi
f01065fc:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106602:	89 da                	mov    %ebx,%edx
f0106604:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106609:	e8 d6 fd ff ff       	call   f01063e4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010660e:	89 f2                	mov    %esi,%edx
f0106610:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106615:	e8 ca fd ff ff       	call   f01063e4 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010661a:	89 da                	mov    %ebx,%edx
f010661c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106621:	e8 be fd ff ff       	call   f01063e4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106626:	89 f2                	mov    %esi,%edx
f0106628:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010662d:	e8 b2 fd ff ff       	call   f01063e4 <lapicw>
		microdelay(200);
	}
}
f0106632:	83 c4 10             	add    $0x10,%esp
f0106635:	5b                   	pop    %ebx
f0106636:	5e                   	pop    %esi
f0106637:	5d                   	pop    %ebp
f0106638:	c3                   	ret    

f0106639 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106639:	55                   	push   %ebp
f010663a:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010663c:	8b 55 08             	mov    0x8(%ebp),%edx
f010663f:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106645:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010664a:	e8 95 fd ff ff       	call   f01063e4 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010664f:	8b 15 04 60 26 f0    	mov    0xf0266004,%edx
f0106655:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010665b:	f6 c4 10             	test   $0x10,%ah
f010665e:	75 f5                	jne    f0106655 <lapic_ipi+0x1c>
		;
}
f0106660:	5d                   	pop    %ebp
f0106661:	c3                   	ret    
	...

f0106664 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106664:	55                   	push   %ebp
f0106665:	89 e5                	mov    %esp,%ebp
f0106667:	53                   	push   %ebx
f0106668:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f010666b:	83 38 00             	cmpl   $0x0,(%eax)
f010666e:	74 25                	je     f0106695 <holding+0x31>
f0106670:	8b 58 08             	mov    0x8(%eax),%ebx
f0106673:	e8 84 fd ff ff       	call   f01063fc <cpunum>
f0106678:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010667f:	29 c2                	sub    %eax,%edx
f0106681:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106684:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f010668b:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f010668d:	0f 94 c0             	sete   %al
f0106690:	0f b6 c0             	movzbl %al,%eax
f0106693:	eb 05                	jmp    f010669a <holding+0x36>
f0106695:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010669a:	83 c4 04             	add    $0x4,%esp
f010669d:	5b                   	pop    %ebx
f010669e:	5d                   	pop    %ebp
f010669f:	c3                   	ret    

f01066a0 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01066a0:	55                   	push   %ebp
f01066a1:	89 e5                	mov    %esp,%ebp
f01066a3:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01066a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01066ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01066af:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01066b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01066b9:	5d                   	pop    %ebp
f01066ba:	c3                   	ret    

f01066bb <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01066bb:	55                   	push   %ebp
f01066bc:	89 e5                	mov    %esp,%ebp
f01066be:	53                   	push   %ebx
f01066bf:	83 ec 24             	sub    $0x24,%esp
f01066c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01066c5:	89 d8                	mov    %ebx,%eax
f01066c7:	e8 98 ff ff ff       	call   f0106664 <holding>
f01066cc:	85 c0                	test   %eax,%eax
f01066ce:	74 30                	je     f0106700 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01066d0:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01066d3:	e8 24 fd ff ff       	call   f01063fc <cpunum>
f01066d8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01066dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01066e0:	c7 44 24 08 e4 86 10 	movl   $0xf01086e4,0x8(%esp)
f01066e7:	f0 
f01066e8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f01066ef:	00 
f01066f0:	c7 04 24 48 87 10 f0 	movl   $0xf0108748,(%esp)
f01066f7:	e8 44 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01066fc:	f3 90                	pause  
f01066fe:	eb 05                	jmp    f0106705 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106700:	ba 01 00 00 00       	mov    $0x1,%edx
f0106705:	89 d0                	mov    %edx,%eax
f0106707:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010670a:	85 c0                	test   %eax,%eax
f010670c:	75 ee                	jne    f01066fc <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010670e:	e8 e9 fc ff ff       	call   f01063fc <cpunum>
f0106713:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010671a:	29 c2                	sub    %eax,%edx
f010671c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010671f:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f0106726:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106729:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010672c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010672e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106733:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106739:	76 10                	jbe    f010674b <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010673b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010673e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106741:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106743:	40                   	inc    %eax
f0106744:	83 f8 0a             	cmp    $0xa,%eax
f0106747:	75 ea                	jne    f0106733 <spin_lock+0x78>
f0106749:	eb 0d                	jmp    f0106758 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010674b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106752:	40                   	inc    %eax
f0106753:	83 f8 09             	cmp    $0x9,%eax
f0106756:	7e f3                	jle    f010674b <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106758:	83 c4 24             	add    $0x24,%esp
f010675b:	5b                   	pop    %ebx
f010675c:	5d                   	pop    %ebp
f010675d:	c3                   	ret    

f010675e <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010675e:	55                   	push   %ebp
f010675f:	89 e5                	mov    %esp,%ebp
f0106761:	57                   	push   %edi
f0106762:	56                   	push   %esi
f0106763:	53                   	push   %ebx
f0106764:	83 ec 7c             	sub    $0x7c,%esp
f0106767:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010676a:	89 d8                	mov    %ebx,%eax
f010676c:	e8 f3 fe ff ff       	call   f0106664 <holding>
f0106771:	85 c0                	test   %eax,%eax
f0106773:	0f 85 d3 00 00 00    	jne    f010684c <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106779:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106780:	00 
f0106781:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106784:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106788:	8d 75 a8             	lea    -0x58(%ebp),%esi
f010678b:	89 34 24             	mov    %esi,(%esp)
f010678e:	e8 85 f6 ff ff       	call   f0105e18 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106793:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106796:	0f b6 38             	movzbl (%eax),%edi
f0106799:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010679c:	e8 5b fc ff ff       	call   f01063fc <cpunum>
f01067a1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01067a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01067a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067ad:	c7 04 24 10 87 10 f0 	movl   $0xf0108710,(%esp)
f01067b4:	e8 bd d7 ff ff       	call   f0103f76 <cprintf>
f01067b9:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01067bb:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01067be:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01067c1:	89 c7                	mov    %eax,%edi
f01067c3:	eb 63                	jmp    f0106828 <spin_unlock+0xca>
f01067c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01067c9:	89 04 24             	mov    %eax,(%esp)
f01067cc:	e8 04 ec ff ff       	call   f01053d5 <debuginfo_eip>
f01067d1:	85 c0                	test   %eax,%eax
f01067d3:	78 39                	js     f010680e <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01067d5:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01067d7:	89 c2                	mov    %eax,%edx
f01067d9:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01067dc:	89 54 24 18          	mov    %edx,0x18(%esp)
f01067e0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01067e3:	89 54 24 14          	mov    %edx,0x14(%esp)
f01067e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01067ea:	89 54 24 10          	mov    %edx,0x10(%esp)
f01067ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01067f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01067f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01067f8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01067fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106800:	c7 04 24 58 87 10 f0 	movl   $0xf0108758,(%esp)
f0106807:	e8 6a d7 ff ff       	call   f0103f76 <cprintf>
f010680c:	eb 12                	jmp    f0106820 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010680e:	8b 06                	mov    (%esi),%eax
f0106810:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106814:	c7 04 24 6f 87 10 f0 	movl   $0xf010876f,(%esp)
f010681b:	e8 56 d7 ff ff       	call   f0103f76 <cprintf>
f0106820:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106823:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106826:	74 08                	je     f0106830 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106828:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010682a:	8b 03                	mov    (%ebx),%eax
f010682c:	85 c0                	test   %eax,%eax
f010682e:	75 95                	jne    f01067c5 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106830:	c7 44 24 08 77 87 10 	movl   $0xf0108777,0x8(%esp)
f0106837:	f0 
f0106838:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010683f:	00 
f0106840:	c7 04 24 48 87 10 f0 	movl   $0xf0108748,(%esp)
f0106847:	e8 f4 97 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010684c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106853:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f010685a:	b8 00 00 00 00       	mov    $0x0,%eax
f010685f:	f0 87 03             	lock xchg %eax,(%ebx)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106862:	83 c4 7c             	add    $0x7c,%esp
f0106865:	5b                   	pop    %ebx
f0106866:	5e                   	pop    %esi
f0106867:	5f                   	pop    %edi
f0106868:	5d                   	pop    %ebp
f0106869:	c3                   	ret    
	...

f010686c <__udivdi3>:
f010686c:	55                   	push   %ebp
f010686d:	57                   	push   %edi
f010686e:	56                   	push   %esi
f010686f:	83 ec 10             	sub    $0x10,%esp
f0106872:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106876:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f010687a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010687e:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0106882:	89 cd                	mov    %ecx,%ebp
f0106884:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0106888:	85 c0                	test   %eax,%eax
f010688a:	75 2c                	jne    f01068b8 <__udivdi3+0x4c>
f010688c:	39 f9                	cmp    %edi,%ecx
f010688e:	77 68                	ja     f01068f8 <__udivdi3+0x8c>
f0106890:	85 c9                	test   %ecx,%ecx
f0106892:	75 0b                	jne    f010689f <__udivdi3+0x33>
f0106894:	b8 01 00 00 00       	mov    $0x1,%eax
f0106899:	31 d2                	xor    %edx,%edx
f010689b:	f7 f1                	div    %ecx
f010689d:	89 c1                	mov    %eax,%ecx
f010689f:	31 d2                	xor    %edx,%edx
f01068a1:	89 f8                	mov    %edi,%eax
f01068a3:	f7 f1                	div    %ecx
f01068a5:	89 c7                	mov    %eax,%edi
f01068a7:	89 f0                	mov    %esi,%eax
f01068a9:	f7 f1                	div    %ecx
f01068ab:	89 c6                	mov    %eax,%esi
f01068ad:	89 f0                	mov    %esi,%eax
f01068af:	89 fa                	mov    %edi,%edx
f01068b1:	83 c4 10             	add    $0x10,%esp
f01068b4:	5e                   	pop    %esi
f01068b5:	5f                   	pop    %edi
f01068b6:	5d                   	pop    %ebp
f01068b7:	c3                   	ret    
f01068b8:	39 f8                	cmp    %edi,%eax
f01068ba:	77 2c                	ja     f01068e8 <__udivdi3+0x7c>
f01068bc:	0f bd f0             	bsr    %eax,%esi
f01068bf:	83 f6 1f             	xor    $0x1f,%esi
f01068c2:	75 4c                	jne    f0106910 <__udivdi3+0xa4>
f01068c4:	39 f8                	cmp    %edi,%eax
f01068c6:	bf 00 00 00 00       	mov    $0x0,%edi
f01068cb:	72 0a                	jb     f01068d7 <__udivdi3+0x6b>
f01068cd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01068d1:	0f 87 ad 00 00 00    	ja     f0106984 <__udivdi3+0x118>
f01068d7:	be 01 00 00 00       	mov    $0x1,%esi
f01068dc:	89 f0                	mov    %esi,%eax
f01068de:	89 fa                	mov    %edi,%edx
f01068e0:	83 c4 10             	add    $0x10,%esp
f01068e3:	5e                   	pop    %esi
f01068e4:	5f                   	pop    %edi
f01068e5:	5d                   	pop    %ebp
f01068e6:	c3                   	ret    
f01068e7:	90                   	nop
f01068e8:	31 ff                	xor    %edi,%edi
f01068ea:	31 f6                	xor    %esi,%esi
f01068ec:	89 f0                	mov    %esi,%eax
f01068ee:	89 fa                	mov    %edi,%edx
f01068f0:	83 c4 10             	add    $0x10,%esp
f01068f3:	5e                   	pop    %esi
f01068f4:	5f                   	pop    %edi
f01068f5:	5d                   	pop    %ebp
f01068f6:	c3                   	ret    
f01068f7:	90                   	nop
f01068f8:	89 fa                	mov    %edi,%edx
f01068fa:	89 f0                	mov    %esi,%eax
f01068fc:	f7 f1                	div    %ecx
f01068fe:	89 c6                	mov    %eax,%esi
f0106900:	31 ff                	xor    %edi,%edi
f0106902:	89 f0                	mov    %esi,%eax
f0106904:	89 fa                	mov    %edi,%edx
f0106906:	83 c4 10             	add    $0x10,%esp
f0106909:	5e                   	pop    %esi
f010690a:	5f                   	pop    %edi
f010690b:	5d                   	pop    %ebp
f010690c:	c3                   	ret    
f010690d:	8d 76 00             	lea    0x0(%esi),%esi
f0106910:	89 f1                	mov    %esi,%ecx
f0106912:	d3 e0                	shl    %cl,%eax
f0106914:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106918:	b8 20 00 00 00       	mov    $0x20,%eax
f010691d:	29 f0                	sub    %esi,%eax
f010691f:	89 ea                	mov    %ebp,%edx
f0106921:	88 c1                	mov    %al,%cl
f0106923:	d3 ea                	shr    %cl,%edx
f0106925:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0106929:	09 ca                	or     %ecx,%edx
f010692b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010692f:	89 f1                	mov    %esi,%ecx
f0106931:	d3 e5                	shl    %cl,%ebp
f0106933:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0106937:	89 fd                	mov    %edi,%ebp
f0106939:	88 c1                	mov    %al,%cl
f010693b:	d3 ed                	shr    %cl,%ebp
f010693d:	89 fa                	mov    %edi,%edx
f010693f:	89 f1                	mov    %esi,%ecx
f0106941:	d3 e2                	shl    %cl,%edx
f0106943:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106947:	88 c1                	mov    %al,%cl
f0106949:	d3 ef                	shr    %cl,%edi
f010694b:	09 d7                	or     %edx,%edi
f010694d:	89 f8                	mov    %edi,%eax
f010694f:	89 ea                	mov    %ebp,%edx
f0106951:	f7 74 24 08          	divl   0x8(%esp)
f0106955:	89 d1                	mov    %edx,%ecx
f0106957:	89 c7                	mov    %eax,%edi
f0106959:	f7 64 24 0c          	mull   0xc(%esp)
f010695d:	39 d1                	cmp    %edx,%ecx
f010695f:	72 17                	jb     f0106978 <__udivdi3+0x10c>
f0106961:	74 09                	je     f010696c <__udivdi3+0x100>
f0106963:	89 fe                	mov    %edi,%esi
f0106965:	31 ff                	xor    %edi,%edi
f0106967:	e9 41 ff ff ff       	jmp    f01068ad <__udivdi3+0x41>
f010696c:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106970:	89 f1                	mov    %esi,%ecx
f0106972:	d3 e2                	shl    %cl,%edx
f0106974:	39 c2                	cmp    %eax,%edx
f0106976:	73 eb                	jae    f0106963 <__udivdi3+0xf7>
f0106978:	8d 77 ff             	lea    -0x1(%edi),%esi
f010697b:	31 ff                	xor    %edi,%edi
f010697d:	e9 2b ff ff ff       	jmp    f01068ad <__udivdi3+0x41>
f0106982:	66 90                	xchg   %ax,%ax
f0106984:	31 f6                	xor    %esi,%esi
f0106986:	e9 22 ff ff ff       	jmp    f01068ad <__udivdi3+0x41>
	...

f010698c <__umoddi3>:
f010698c:	55                   	push   %ebp
f010698d:	57                   	push   %edi
f010698e:	56                   	push   %esi
f010698f:	83 ec 20             	sub    $0x20,%esp
f0106992:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106996:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f010699a:	89 44 24 14          	mov    %eax,0x14(%esp)
f010699e:	8b 74 24 34          	mov    0x34(%esp),%esi
f01069a2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01069a6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01069aa:	89 c7                	mov    %eax,%edi
f01069ac:	89 f2                	mov    %esi,%edx
f01069ae:	85 ed                	test   %ebp,%ebp
f01069b0:	75 16                	jne    f01069c8 <__umoddi3+0x3c>
f01069b2:	39 f1                	cmp    %esi,%ecx
f01069b4:	0f 86 a6 00 00 00    	jbe    f0106a60 <__umoddi3+0xd4>
f01069ba:	f7 f1                	div    %ecx
f01069bc:	89 d0                	mov    %edx,%eax
f01069be:	31 d2                	xor    %edx,%edx
f01069c0:	83 c4 20             	add    $0x20,%esp
f01069c3:	5e                   	pop    %esi
f01069c4:	5f                   	pop    %edi
f01069c5:	5d                   	pop    %ebp
f01069c6:	c3                   	ret    
f01069c7:	90                   	nop
f01069c8:	39 f5                	cmp    %esi,%ebp
f01069ca:	0f 87 ac 00 00 00    	ja     f0106a7c <__umoddi3+0xf0>
f01069d0:	0f bd c5             	bsr    %ebp,%eax
f01069d3:	83 f0 1f             	xor    $0x1f,%eax
f01069d6:	89 44 24 10          	mov    %eax,0x10(%esp)
f01069da:	0f 84 a8 00 00 00    	je     f0106a88 <__umoddi3+0xfc>
f01069e0:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01069e4:	d3 e5                	shl    %cl,%ebp
f01069e6:	bf 20 00 00 00       	mov    $0x20,%edi
f01069eb:	2b 7c 24 10          	sub    0x10(%esp),%edi
f01069ef:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01069f3:	89 f9                	mov    %edi,%ecx
f01069f5:	d3 e8                	shr    %cl,%eax
f01069f7:	09 e8                	or     %ebp,%eax
f01069f9:	89 44 24 18          	mov    %eax,0x18(%esp)
f01069fd:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106a01:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106a05:	d3 e0                	shl    %cl,%eax
f0106a07:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a0b:	89 f2                	mov    %esi,%edx
f0106a0d:	d3 e2                	shl    %cl,%edx
f0106a0f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106a13:	d3 e0                	shl    %cl,%eax
f0106a15:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0106a19:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106a1d:	89 f9                	mov    %edi,%ecx
f0106a1f:	d3 e8                	shr    %cl,%eax
f0106a21:	09 d0                	or     %edx,%eax
f0106a23:	d3 ee                	shr    %cl,%esi
f0106a25:	89 f2                	mov    %esi,%edx
f0106a27:	f7 74 24 18          	divl   0x18(%esp)
f0106a2b:	89 d6                	mov    %edx,%esi
f0106a2d:	f7 64 24 0c          	mull   0xc(%esp)
f0106a31:	89 c5                	mov    %eax,%ebp
f0106a33:	89 d1                	mov    %edx,%ecx
f0106a35:	39 d6                	cmp    %edx,%esi
f0106a37:	72 67                	jb     f0106aa0 <__umoddi3+0x114>
f0106a39:	74 75                	je     f0106ab0 <__umoddi3+0x124>
f0106a3b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106a3f:	29 e8                	sub    %ebp,%eax
f0106a41:	19 ce                	sbb    %ecx,%esi
f0106a43:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106a47:	d3 e8                	shr    %cl,%eax
f0106a49:	89 f2                	mov    %esi,%edx
f0106a4b:	89 f9                	mov    %edi,%ecx
f0106a4d:	d3 e2                	shl    %cl,%edx
f0106a4f:	09 d0                	or     %edx,%eax
f0106a51:	89 f2                	mov    %esi,%edx
f0106a53:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106a57:	d3 ea                	shr    %cl,%edx
f0106a59:	83 c4 20             	add    $0x20,%esp
f0106a5c:	5e                   	pop    %esi
f0106a5d:	5f                   	pop    %edi
f0106a5e:	5d                   	pop    %ebp
f0106a5f:	c3                   	ret    
f0106a60:	85 c9                	test   %ecx,%ecx
f0106a62:	75 0b                	jne    f0106a6f <__umoddi3+0xe3>
f0106a64:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a69:	31 d2                	xor    %edx,%edx
f0106a6b:	f7 f1                	div    %ecx
f0106a6d:	89 c1                	mov    %eax,%ecx
f0106a6f:	89 f0                	mov    %esi,%eax
f0106a71:	31 d2                	xor    %edx,%edx
f0106a73:	f7 f1                	div    %ecx
f0106a75:	89 f8                	mov    %edi,%eax
f0106a77:	e9 3e ff ff ff       	jmp    f01069ba <__umoddi3+0x2e>
f0106a7c:	89 f2                	mov    %esi,%edx
f0106a7e:	83 c4 20             	add    $0x20,%esp
f0106a81:	5e                   	pop    %esi
f0106a82:	5f                   	pop    %edi
f0106a83:	5d                   	pop    %ebp
f0106a84:	c3                   	ret    
f0106a85:	8d 76 00             	lea    0x0(%esi),%esi
f0106a88:	39 f5                	cmp    %esi,%ebp
f0106a8a:	72 04                	jb     f0106a90 <__umoddi3+0x104>
f0106a8c:	39 f9                	cmp    %edi,%ecx
f0106a8e:	77 06                	ja     f0106a96 <__umoddi3+0x10a>
f0106a90:	89 f2                	mov    %esi,%edx
f0106a92:	29 cf                	sub    %ecx,%edi
f0106a94:	19 ea                	sbb    %ebp,%edx
f0106a96:	89 f8                	mov    %edi,%eax
f0106a98:	83 c4 20             	add    $0x20,%esp
f0106a9b:	5e                   	pop    %esi
f0106a9c:	5f                   	pop    %edi
f0106a9d:	5d                   	pop    %ebp
f0106a9e:	c3                   	ret    
f0106a9f:	90                   	nop
f0106aa0:	89 d1                	mov    %edx,%ecx
f0106aa2:	89 c5                	mov    %eax,%ebp
f0106aa4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0106aa8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106aac:	eb 8d                	jmp    f0106a3b <__umoddi3+0xaf>
f0106aae:	66 90                	xchg   %ax,%ax
f0106ab0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0106ab4:	72 ea                	jb     f0106aa0 <__umoddi3+0x114>
f0106ab6:	89 f1                	mov    %esi,%ecx
f0106ab8:	eb 81                	jmp    f0106a3b <__umoddi3+0xaf>
