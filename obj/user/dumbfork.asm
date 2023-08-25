
obj/user/dumbfork.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 17 02 00 00       	call   800248 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 f7 0c 00 00       	call   800d4d <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 e0 20 80 	movl   $0x8020e0,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 f3 20 80 00 	movl   $0x8020f3,(%esp)
  800075:	e8 3e 02 00 00       	call   8002b8 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 03 0d 00 00       	call   800da1 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 03 21 80 	movl   $0x802103,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 f3 20 80 00 	movl   $0x8020f3,(%esp)
  8000bd:	e8 f6 01 00 00       	call   8002b8 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 fa 09 00 00       	call   800ad4 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 06 0d 00 00       	call   800df4 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 14 21 80 	movl   $0x802114,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 f3 20 80 00 	movl   $0x8020f3,(%esp)
  80010d:	e8 a6 01 00 00       	call   8002b8 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 27 21 80 	movl   $0x802127,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 f3 20 80 00 	movl   $0x8020f3,(%esp)
  80014d:	e8 66 01 00 00       	call   8002b8 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 22                	jne    800178 <dumbfork+0x5f>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 b4 0b 00 00       	call   800d0f <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800176:	eb 6e                	jmp    8001e6 <dumbfork+0xcd>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800178:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80017f:	eb 13                	jmp    800194 <dumbfork+0x7b>
		duppage(envid, addr);
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	89 1c 24             	mov    %ebx,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80018d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800197:	3d 00 60 80 00       	cmp    $0x806000,%eax
  80019c:	72 e3                	jb     800181 <dumbfork+0x68>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80019e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	89 34 24             	mov    %esi,(%esp)
  8001ad:	e8 82 fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001b9:	00 
  8001ba:	89 34 24             	mov    %esi,(%esp)
  8001bd:	e8 85 0c 00 00       	call   800e47 <sys_env_set_status>
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	79 20                	jns    8001e6 <dumbfork+0xcd>
		panic("sys_env_set_status: %e", r);
  8001c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ca:	c7 44 24 08 37 21 80 	movl   $0x802137,0x8(%esp)
  8001d1:	00 
  8001d2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 f3 20 80 00 	movl   $0x8020f3,(%esp)
  8001e1:	e8 d2 00 00 00       	call   8002b8 <_panic>

	return envid;
}
  8001e6:	89 f0                	mov    %esi,%eax
  8001e8:	83 c4 20             	add    $0x20,%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5e                   	pop    %esi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001f7:	e8 1d ff ff ff       	call   800119 <dumbfork>
  8001fc:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001fe:	be 00 00 00 00       	mov    $0x0,%esi
  800203:	eb 2a                	jmp    80022f <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800205:	85 db                	test   %ebx,%ebx
  800207:	74 07                	je     800210 <umain+0x21>
  800209:	b8 4e 21 80 00       	mov    $0x80214e,%eax
  80020e:	eb 05                	jmp    800215 <umain+0x26>
  800210:	b8 55 21 80 00       	mov    $0x802155,%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021d:	c7 04 24 5b 21 80 00 	movl   $0x80215b,(%esp)
  800224:	e8 87 01 00 00       	call   8003b0 <cprintf>
		sys_yield();
  800229:	e8 00 0b 00 00       	call   800d2e <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80022e:	46                   	inc    %esi
  80022f:	83 fb 01             	cmp    $0x1,%ebx
  800232:	19 c0                	sbb    %eax,%eax
  800234:	83 e0 0a             	and    $0xa,%eax
  800237:	83 c0 0a             	add    $0xa,%eax
  80023a:	39 c6                	cmp    %eax,%esi
  80023c:	7c c7                	jl     800205 <umain+0x16>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    
  800245:	00 00                	add    %al,(%eax)
	...

00800248 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 10             	sub    $0x10,%esp
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800256:	e8 b4 0a 00 00       	call   800d0f <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800267:	c1 e0 07             	shl    $0x7,%eax
  80026a:	29 d0                	sub    %edx,%eax
  80026c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800271:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800276:	85 f6                	test   %esi,%esi
  800278:	7e 07                	jle    800281 <libmain+0x39>
		binaryname = argv[0];
  80027a:	8b 03                	mov    (%ebx),%eax
  80027c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800281:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800285:	89 34 24             	mov    %esi,(%esp)
  800288:	e8 62 ff ff ff       	call   8001ef <umain>

	// exit gracefully
	exit();
  80028d:	e8 0a 00 00 00       	call   80029c <exit>
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
	...

0080029c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002a2:	e8 f8 0e 00 00       	call   80119f <close_all>
	sys_env_destroy(0);
  8002a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ae:	e8 0a 0a 00 00       	call   800cbd <sys_env_destroy>
}
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    
  8002b5:	00 00                	add    %al,(%eax)
	...

008002b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002c9:	e8 41 0a 00 00       	call   800d0f <sys_getenvid>
  8002ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e4:	c7 04 24 78 21 80 00 	movl   $0x802178,(%esp)
  8002eb:	e8 c0 00 00 00       	call   8003b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	e8 50 00 00 00       	call   80034f <vcprintf>
	cprintf("\n");
  8002ff:	c7 04 24 6b 21 80 00 	movl   $0x80216b,(%esp)
  800306:	e8 a5 00 00 00       	call   8003b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030b:	cc                   	int3   
  80030c:	eb fd                	jmp    80030b <_panic+0x53>
	...

00800310 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	53                   	push   %ebx
  800314:	83 ec 14             	sub    $0x14,%esp
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031a:	8b 03                	mov    (%ebx),%eax
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800323:	40                   	inc    %eax
  800324:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800326:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032b:	75 19                	jne    800346 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80032d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800334:	00 
  800335:	8d 43 08             	lea    0x8(%ebx),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 40 09 00 00       	call   800c80 <sys_cputs>
		b->idx = 0;
  800340:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800346:	ff 43 04             	incl   0x4(%ebx)
}
  800349:	83 c4 14             	add    $0x14,%esp
  80034c:	5b                   	pop    %ebx
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800358:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035f:	00 00 00 
	b.cnt = 0;
  800362:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800369:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800380:	89 44 24 04          	mov    %eax,0x4(%esp)
  800384:	c7 04 24 10 03 80 00 	movl   $0x800310,(%esp)
  80038b:	e8 82 01 00 00       	call   800512 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800390:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 d8 08 00 00       	call   800c80 <sys_cputs>

	return b.cnt;
}
  8003a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 87 ff ff ff       	call   80034f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    
	...

008003cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	57                   	push   %edi
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
  8003d2:	83 ec 3c             	sub    $0x3c,%esp
  8003d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d8:	89 d7                	mov    %edx,%edi
  8003da:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	75 08                	jne    8003f8 <printnum+0x2c>
  8003f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003f6:	77 57                	ja     80044f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003fc:	4b                   	dec    %ebx
  8003fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800401:	8b 45 10             	mov    0x10(%ebp),%eax
  800404:	89 44 24 08          	mov    %eax,0x8(%esp)
  800408:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80040c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800410:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800417:	00 
  800418:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800421:	89 44 24 04          	mov    %eax,0x4(%esp)
  800425:	e8 62 1a 00 00       	call   801e8c <__udivdi3>
  80042a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80042e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800432:	89 04 24             	mov    %eax,(%esp)
  800435:	89 54 24 04          	mov    %edx,0x4(%esp)
  800439:	89 fa                	mov    %edi,%edx
  80043b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80043e:	e8 89 ff ff ff       	call   8003cc <printnum>
  800443:	eb 0f                	jmp    800454 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800445:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800449:	89 34 24             	mov    %esi,(%esp)
  80044c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80044f:	4b                   	dec    %ebx
  800450:	85 db                	test   %ebx,%ebx
  800452:	7f f1                	jg     800445 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800454:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800458:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800463:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80046a:	00 
  80046b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80046e:	89 04 24             	mov    %eax,(%esp)
  800471:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800474:	89 44 24 04          	mov    %eax,0x4(%esp)
  800478:	e8 2f 1b 00 00       	call   801fac <__umoddi3>
  80047d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800481:	0f be 80 9b 21 80 00 	movsbl 0x80219b(%eax),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80048e:	83 c4 3c             	add    $0x3c,%esp
  800491:	5b                   	pop    %ebx
  800492:	5e                   	pop    %esi
  800493:	5f                   	pop    %edi
  800494:	5d                   	pop    %ebp
  800495:	c3                   	ret    

00800496 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800499:	83 fa 01             	cmp    $0x1,%edx
  80049c:	7e 0e                	jle    8004ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80049e:	8b 10                	mov    (%eax),%edx
  8004a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a3:	89 08                	mov    %ecx,(%eax)
  8004a5:	8b 02                	mov    (%edx),%eax
  8004a7:	8b 52 04             	mov    0x4(%edx),%edx
  8004aa:	eb 22                	jmp    8004ce <getuint+0x38>
	else if (lflag)
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	74 10                	je     8004c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b0:	8b 10                	mov    (%eax),%edx
  8004b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b5:	89 08                	mov    %ecx,(%eax)
  8004b7:	8b 02                	mov    (%edx),%eax
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004be:	eb 0e                	jmp    8004ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	3b 50 04             	cmp    0x4(%eax),%edx
  8004de:	73 08                	jae    8004e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8004e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e3:	88 0a                	mov    %cl,(%edx)
  8004e5:	42                   	inc    %edx
  8004e6:	89 10                	mov    %edx,(%eax)
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 02 00 00 00       	call   800512 <vprintfmt>
	va_end(ap);
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	57                   	push   %edi
  800516:	56                   	push   %esi
  800517:	53                   	push   %ebx
  800518:	83 ec 4c             	sub    $0x4c,%esp
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051e:	8b 75 10             	mov    0x10(%ebp),%esi
  800521:	eb 12                	jmp    800535 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800523:	85 c0                	test   %eax,%eax
  800525:	0f 84 6b 03 00 00    	je     800896 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80052b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800535:	0f b6 06             	movzbl (%esi),%eax
  800538:	46                   	inc    %esi
  800539:	83 f8 25             	cmp    $0x25,%eax
  80053c:	75 e5                	jne    800523 <vprintfmt+0x11>
  80053e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800542:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800549:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80054e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800555:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055a:	eb 26                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800563:	eb 1d                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800568:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80056c:	eb 14                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800571:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800578:	eb 08                	jmp    800582 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80057a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80057d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	0f b6 06             	movzbl (%esi),%eax
  800585:	8d 56 01             	lea    0x1(%esi),%edx
  800588:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058b:	8a 16                	mov    (%esi),%dl
  80058d:	83 ea 23             	sub    $0x23,%edx
  800590:	80 fa 55             	cmp    $0x55,%dl
  800593:	0f 87 e1 02 00 00    	ja     80087a <vprintfmt+0x368>
  800599:	0f b6 d2             	movzbl %dl,%edx
  80059c:	ff 24 95 e0 22 80 00 	jmp    *0x8022e0(,%edx,4)
  8005a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005b8:	83 fa 09             	cmp    $0x9,%edx
  8005bb:	77 2a                	ja     8005e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005be:	eb eb                	jmp    8005ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ce:	eb 17                	jmp    8005e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d4:	78 98                	js     80056e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005d9:	eb a7                	jmp    800582 <vprintfmt+0x70>
  8005db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005e5:	eb 9b                	jmp    800582 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005eb:	79 95                	jns    800582 <vprintfmt+0x70>
  8005ed:	eb 8b                	jmp    80057a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f3:	eb 8d                	jmp    800582 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060d:	e9 23 ff ff ff       	jmp    800535 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	85 c0                	test   %eax,%eax
  80061f:	79 02                	jns    800623 <vprintfmt+0x111>
  800621:	f7 d8                	neg    %eax
  800623:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800625:	83 f8 0f             	cmp    $0xf,%eax
  800628:	7f 0b                	jg     800635 <vprintfmt+0x123>
  80062a:	8b 04 85 40 24 80 00 	mov    0x802440(,%eax,4),%eax
  800631:	85 c0                	test   %eax,%eax
  800633:	75 23                	jne    800658 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800635:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800639:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
  800640:	00 
  800641:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	e8 9a fe ff ff       	call   8004ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800653:	e9 dd fe ff ff       	jmp    800535 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800658:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065c:	c7 44 24 08 9e 25 80 	movl   $0x80259e,0x8(%esp)
  800663:	00 
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	8b 55 08             	mov    0x8(%ebp),%edx
  80066b:	89 14 24             	mov    %edx,(%esp)
  80066e:	e8 77 fe ff ff       	call   8004ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	e9 ba fe ff ff       	jmp    800535 <vprintfmt+0x23>
  80067b:	89 f9                	mov    %edi,%ecx
  80067d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800680:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 30                	mov    (%eax),%esi
  80068e:	85 f6                	test   %esi,%esi
  800690:	75 05                	jne    800697 <vprintfmt+0x185>
				p = "(null)";
  800692:	be ac 21 80 00       	mov    $0x8021ac,%esi
			if (width > 0 && padc != '-')
  800697:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80069b:	0f 8e 84 00 00 00    	jle    800725 <vprintfmt+0x213>
  8006a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006a5:	74 7e                	je     800725 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ab:	89 34 24             	mov    %esi,(%esp)
  8006ae:	e8 8b 02 00 00       	call   80093e <strnlen>
  8006b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b6:	29 c2                	sub    %eax,%edx
  8006b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006c5:	89 de                	mov    %ebx,%esi
  8006c7:	89 d3                	mov    %edx,%ebx
  8006c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cb:	eb 0b                	jmp    8006d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d1:	89 3c 24             	mov    %edi,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	4b                   	dec    %ebx
  8006d8:	85 db                	test   %ebx,%ebx
  8006da:	7f f1                	jg     8006cd <vprintfmt+0x1bb>
  8006dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006df:	89 f3                	mov    %esi,%ebx
  8006e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	79 05                	jns    8006f0 <vprintfmt+0x1de>
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006f8:	eb 2b                	jmp    800725 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006fe:	74 18                	je     800718 <vprintfmt+0x206>
  800700:	8d 50 e0             	lea    -0x20(%eax),%edx
  800703:	83 fa 5e             	cmp    $0x5e,%edx
  800706:	76 10                	jbe    800718 <vprintfmt+0x206>
					putch('?', putdat);
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
  800716:	eb 0a                	jmp    800722 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800718:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800722:	ff 4d e4             	decl   -0x1c(%ebp)
  800725:	0f be 06             	movsbl (%esi),%eax
  800728:	46                   	inc    %esi
  800729:	85 c0                	test   %eax,%eax
  80072b:	74 21                	je     80074e <vprintfmt+0x23c>
  80072d:	85 ff                	test   %edi,%edi
  80072f:	78 c9                	js     8006fa <vprintfmt+0x1e8>
  800731:	4f                   	dec    %edi
  800732:	79 c6                	jns    8006fa <vprintfmt+0x1e8>
  800734:	8b 7d 08             	mov    0x8(%ebp),%edi
  800737:	89 de                	mov    %ebx,%esi
  800739:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80073c:	eb 18                	jmp    800756 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800742:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800749:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074b:	4b                   	dec    %ebx
  80074c:	eb 08                	jmp    800756 <vprintfmt+0x244>
  80074e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800751:	89 de                	mov    %ebx,%esi
  800753:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800756:	85 db                	test   %ebx,%ebx
  800758:	7f e4                	jg     80073e <vprintfmt+0x22c>
  80075a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80075d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800762:	e9 ce fd ff ff       	jmp    800535 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800767:	83 f9 01             	cmp    $0x1,%ecx
  80076a:	7e 10                	jle    80077c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 08             	lea    0x8(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)
  800775:	8b 30                	mov    (%eax),%esi
  800777:	8b 78 04             	mov    0x4(%eax),%edi
  80077a:	eb 26                	jmp    8007a2 <vprintfmt+0x290>
	else if (lflag)
  80077c:	85 c9                	test   %ecx,%ecx
  80077e:	74 12                	je     800792 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 50 04             	lea    0x4(%eax),%edx
  800786:	89 55 14             	mov    %edx,0x14(%ebp)
  800789:	8b 30                	mov    (%eax),%esi
  80078b:	89 f7                	mov    %esi,%edi
  80078d:	c1 ff 1f             	sar    $0x1f,%edi
  800790:	eb 10                	jmp    8007a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 50 04             	lea    0x4(%eax),%edx
  800798:	89 55 14             	mov    %edx,0x14(%ebp)
  80079b:	8b 30                	mov    (%eax),%esi
  80079d:	89 f7                	mov    %esi,%edi
  80079f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007a2:	85 ff                	test   %edi,%edi
  8007a4:	78 0a                	js     8007b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ab:	e9 8c 00 00 00       	jmp    80083c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007be:	f7 de                	neg    %esi
  8007c0:	83 d7 00             	adc    $0x0,%edi
  8007c3:	f7 df                	neg    %edi
			}
			base = 10;
  8007c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ca:	eb 70                	jmp    80083c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007cc:	89 ca                	mov    %ecx,%edx
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d1:	e8 c0 fc ff ff       	call   800496 <getuint>
  8007d6:	89 c6                	mov    %eax,%esi
  8007d8:	89 d7                	mov    %edx,%edi
			base = 10;
  8007da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007df:	eb 5b                	jmp    80083c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007e1:	89 ca                	mov    %ecx,%edx
  8007e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e6:	e8 ab fc ff ff       	call   800496 <getuint>
  8007eb:	89 c6                	mov    %eax,%esi
  8007ed:	89 d7                	mov    %edx,%edi
			base = 8;
  8007ef:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007f4:	eb 46                	jmp    80083c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8007f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800801:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800804:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800808:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80080f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80081b:	8b 30                	mov    (%eax),%esi
  80081d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800822:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800827:	eb 13                	jmp    80083c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800829:	89 ca                	mov    %ecx,%edx
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
  80082e:	e8 63 fc ff ff       	call   800496 <getuint>
  800833:	89 c6                	mov    %eax,%esi
  800835:	89 d7                	mov    %edx,%edi
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80083c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800840:	89 54 24 10          	mov    %edx,0x10(%esp)
  800844:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800847:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80084b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084f:	89 34 24             	mov    %esi,(%esp)
  800852:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800856:	89 da                	mov    %ebx,%edx
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	e8 6c fb ff ff       	call   8003cc <printnum>
			break;
  800860:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800863:	e9 cd fc ff ff       	jmp    800535 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800868:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800872:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800875:	e9 bb fc ff ff       	jmp    800535 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800885:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800888:	eb 01                	jmp    80088b <vprintfmt+0x379>
  80088a:	4e                   	dec    %esi
  80088b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80088f:	75 f9                	jne    80088a <vprintfmt+0x378>
  800891:	e9 9f fc ff ff       	jmp    800535 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800896:	83 c4 4c             	add    $0x4c,%esp
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5f                   	pop    %edi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	83 ec 28             	sub    $0x28,%esp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	74 30                	je     8008ef <vsnprintf+0x51>
  8008bf:	85 d2                	test   %edx,%edx
  8008c1:	7e 33                	jle    8008f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8008cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	c7 04 24 d0 04 80 00 	movl   $0x8004d0,(%esp)
  8008df:	e8 2e fc ff ff       	call   800512 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ed:	eb 0c                	jmp    8008fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f4:	eb 05                	jmp    8008fb <vsnprintf+0x5d>
  8008f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800903:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800906:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090a:	8b 45 10             	mov    0x10(%ebp),%eax
  80090d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800911:	8b 45 0c             	mov    0xc(%ebp),%eax
  800914:	89 44 24 04          	mov    %eax,0x4(%esp)
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	89 04 24             	mov    %eax,(%esp)
  80091e:	e8 7b ff ff ff       	call   80089e <vsnprintf>
	va_end(ap);

	return rc;
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    
  800925:	00 00                	add    %al,(%eax)
	...

00800928 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
  800933:	eb 01                	jmp    800936 <strlen+0xe>
		n++;
  800935:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093a:	75 f9                	jne    800935 <strlen+0xd>
		n++;
	return n;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
  80094c:	eb 01                	jmp    80094f <strnlen+0x11>
		n++;
  80094e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094f:	39 d0                	cmp    %edx,%eax
  800951:	74 06                	je     800959 <strnlen+0x1b>
  800953:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800957:	75 f5                	jne    80094e <strnlen+0x10>
		n++;
	return n;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
  80096a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80096d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800970:	42                   	inc    %edx
  800971:	84 c9                	test   %cl,%cl
  800973:	75 f5                	jne    80096a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800975:	5b                   	pop    %ebx
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	53                   	push   %ebx
  80097c:	83 ec 08             	sub    $0x8,%esp
  80097f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800982:	89 1c 24             	mov    %ebx,(%esp)
  800985:	e8 9e ff ff ff       	call   800928 <strlen>
	strcpy(dst + len, src);
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800991:	01 d8                	add    %ebx,%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 c0 ff ff ff       	call   80095b <strcpy>
	return dst;
}
  80099b:	89 d8                	mov    %ebx,%eax
  80099d:	83 c4 08             	add    $0x8,%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009b6:	eb 0c                	jmp    8009c4 <strncpy+0x21>
		*dst++ = *src;
  8009b8:	8a 1a                	mov    (%edx),%bl
  8009ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c3:	41                   	inc    %ecx
  8009c4:	39 f1                	cmp    %esi,%ecx
  8009c6:	75 f0                	jne    8009b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009da:	85 d2                	test   %edx,%edx
  8009dc:	75 0a                	jne    8009e8 <strlcpy+0x1c>
  8009de:	89 f0                	mov    %esi,%eax
  8009e0:	eb 1a                	jmp    8009fc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e2:	88 18                	mov    %bl,(%eax)
  8009e4:	40                   	inc    %eax
  8009e5:	41                   	inc    %ecx
  8009e6:	eb 02                	jmp    8009ea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009ea:	4a                   	dec    %edx
  8009eb:	74 0a                	je     8009f7 <strlcpy+0x2b>
  8009ed:	8a 19                	mov    (%ecx),%bl
  8009ef:	84 db                	test   %bl,%bl
  8009f1:	75 ef                	jne    8009e2 <strlcpy+0x16>
  8009f3:	89 c2                	mov    %eax,%edx
  8009f5:	eb 02                	jmp    8009f9 <strlcpy+0x2d>
  8009f7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009f9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009fc:	29 f0                	sub    %esi,%eax
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0b:	eb 02                	jmp    800a0f <strcmp+0xd>
		p++, q++;
  800a0d:	41                   	inc    %ecx
  800a0e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a0f:	8a 01                	mov    (%ecx),%al
  800a11:	84 c0                	test   %al,%al
  800a13:	74 04                	je     800a19 <strcmp+0x17>
  800a15:	3a 02                	cmp    (%edx),%al
  800a17:	74 f4                	je     800a0d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a19:	0f b6 c0             	movzbl %al,%eax
  800a1c:	0f b6 12             	movzbl (%edx),%edx
  800a1f:	29 d0                	sub    %edx,%eax
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	53                   	push   %ebx
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a30:	eb 03                	jmp    800a35 <strncmp+0x12>
		n--, p++, q++;
  800a32:	4a                   	dec    %edx
  800a33:	40                   	inc    %eax
  800a34:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a35:	85 d2                	test   %edx,%edx
  800a37:	74 14                	je     800a4d <strncmp+0x2a>
  800a39:	8a 18                	mov    (%eax),%bl
  800a3b:	84 db                	test   %bl,%bl
  800a3d:	74 04                	je     800a43 <strncmp+0x20>
  800a3f:	3a 19                	cmp    (%ecx),%bl
  800a41:	74 ef                	je     800a32 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a43:	0f b6 00             	movzbl (%eax),%eax
  800a46:	0f b6 11             	movzbl (%ecx),%edx
  800a49:	29 d0                	sub    %edx,%eax
  800a4b:	eb 05                	jmp    800a52 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a52:	5b                   	pop    %ebx
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a5e:	eb 05                	jmp    800a65 <strchr+0x10>
		if (*s == c)
  800a60:	38 ca                	cmp    %cl,%dl
  800a62:	74 0c                	je     800a70 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a64:	40                   	inc    %eax
  800a65:	8a 10                	mov    (%eax),%dl
  800a67:	84 d2                	test   %dl,%dl
  800a69:	75 f5                	jne    800a60 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a7b:	eb 05                	jmp    800a82 <strfind+0x10>
		if (*s == c)
  800a7d:	38 ca                	cmp    %cl,%dl
  800a7f:	74 07                	je     800a88 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a81:	40                   	inc    %eax
  800a82:	8a 10                	mov    (%eax),%dl
  800a84:	84 d2                	test   %dl,%dl
  800a86:	75 f5                	jne    800a7d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
  800a90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a99:	85 c9                	test   %ecx,%ecx
  800a9b:	74 30                	je     800acd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa3:	75 25                	jne    800aca <memset+0x40>
  800aa5:	f6 c1 03             	test   $0x3,%cl
  800aa8:	75 20                	jne    800aca <memset+0x40>
		c &= 0xFF;
  800aaa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	c1 e3 08             	shl    $0x8,%ebx
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	c1 e6 18             	shl    $0x18,%esi
  800ab7:	89 d0                	mov    %edx,%eax
  800ab9:	c1 e0 10             	shl    $0x10,%eax
  800abc:	09 f0                	or     %esi,%eax
  800abe:	09 d0                	or     %edx,%eax
  800ac0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac5:	fc                   	cld    
  800ac6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac8:	eb 03                	jmp    800acd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aca:	fc                   	cld    
  800acb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acd:	89 f8                	mov    %edi,%eax
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae2:	39 c6                	cmp    %eax,%esi
  800ae4:	73 34                	jae    800b1a <memmove+0x46>
  800ae6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae9:	39 d0                	cmp    %edx,%eax
  800aeb:	73 2d                	jae    800b1a <memmove+0x46>
		s += n;
		d += n;
  800aed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af0:	f6 c2 03             	test   $0x3,%dl
  800af3:	75 1b                	jne    800b10 <memmove+0x3c>
  800af5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afb:	75 13                	jne    800b10 <memmove+0x3c>
  800afd:	f6 c1 03             	test   $0x3,%cl
  800b00:	75 0e                	jne    800b10 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b02:	83 ef 04             	sub    $0x4,%edi
  800b05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b08:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b0b:	fd                   	std    
  800b0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0e:	eb 07                	jmp    800b17 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b10:	4f                   	dec    %edi
  800b11:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b14:	fd                   	std    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b17:	fc                   	cld    
  800b18:	eb 20                	jmp    800b3a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b20:	75 13                	jne    800b35 <memmove+0x61>
  800b22:	a8 03                	test   $0x3,%al
  800b24:	75 0f                	jne    800b35 <memmove+0x61>
  800b26:	f6 c1 03             	test   $0x3,%cl
  800b29:	75 0a                	jne    800b35 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	fc                   	cld    
  800b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b33:	eb 05                	jmp    800b3a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b35:	89 c7                	mov    %eax,%edi
  800b37:	fc                   	cld    
  800b38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b44:	8b 45 10             	mov    0x10(%ebp),%eax
  800b47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	89 04 24             	mov    %eax,(%esp)
  800b58:	e8 77 ff ff ff       	call   800ad4 <memmove>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	eb 16                	jmp    800b8b <memcmp+0x2c>
		if (*s1 != *s2)
  800b75:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b78:	42                   	inc    %edx
  800b79:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b7d:	38 c8                	cmp    %cl,%al
  800b7f:	74 0a                	je     800b8b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b81:	0f b6 c0             	movzbl %al,%eax
  800b84:	0f b6 c9             	movzbl %cl,%ecx
  800b87:	29 c8                	sub    %ecx,%eax
  800b89:	eb 09                	jmp    800b94 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8b:	39 da                	cmp    %ebx,%edx
  800b8d:	75 e6                	jne    800b75 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ba2:	89 c2                	mov    %eax,%edx
  800ba4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba7:	eb 05                	jmp    800bae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba9:	38 08                	cmp    %cl,(%eax)
  800bab:	74 05                	je     800bb2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bad:	40                   	inc    %eax
  800bae:	39 d0                	cmp    %edx,%eax
  800bb0:	72 f7                	jb     800ba9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc0:	eb 01                	jmp    800bc3 <strtol+0xf>
		s++;
  800bc2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc3:	8a 02                	mov    (%edx),%al
  800bc5:	3c 20                	cmp    $0x20,%al
  800bc7:	74 f9                	je     800bc2 <strtol+0xe>
  800bc9:	3c 09                	cmp    $0x9,%al
  800bcb:	74 f5                	je     800bc2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bcd:	3c 2b                	cmp    $0x2b,%al
  800bcf:	75 08                	jne    800bd9 <strtol+0x25>
		s++;
  800bd1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd7:	eb 13                	jmp    800bec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd9:	3c 2d                	cmp    $0x2d,%al
  800bdb:	75 0a                	jne    800be7 <strtol+0x33>
		s++, neg = 1;
  800bdd:	8d 52 01             	lea    0x1(%edx),%edx
  800be0:	bf 01 00 00 00       	mov    $0x1,%edi
  800be5:	eb 05                	jmp    800bec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bec:	85 db                	test   %ebx,%ebx
  800bee:	74 05                	je     800bf5 <strtol+0x41>
  800bf0:	83 fb 10             	cmp    $0x10,%ebx
  800bf3:	75 28                	jne    800c1d <strtol+0x69>
  800bf5:	8a 02                	mov    (%edx),%al
  800bf7:	3c 30                	cmp    $0x30,%al
  800bf9:	75 10                	jne    800c0b <strtol+0x57>
  800bfb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bff:	75 0a                	jne    800c0b <strtol+0x57>
		s += 2, base = 16;
  800c01:	83 c2 02             	add    $0x2,%edx
  800c04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c09:	eb 12                	jmp    800c1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c0b:	85 db                	test   %ebx,%ebx
  800c0d:	75 0e                	jne    800c1d <strtol+0x69>
  800c0f:	3c 30                	cmp    $0x30,%al
  800c11:	75 05                	jne    800c18 <strtol+0x64>
		s++, base = 8;
  800c13:	42                   	inc    %edx
  800c14:	b3 08                	mov    $0x8,%bl
  800c16:	eb 05                	jmp    800c1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c24:	8a 0a                	mov    (%edx),%cl
  800c26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c29:	80 fb 09             	cmp    $0x9,%bl
  800c2c:	77 08                	ja     800c36 <strtol+0x82>
			dig = *s - '0';
  800c2e:	0f be c9             	movsbl %cl,%ecx
  800c31:	83 e9 30             	sub    $0x30,%ecx
  800c34:	eb 1e                	jmp    800c54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c39:	80 fb 19             	cmp    $0x19,%bl
  800c3c:	77 08                	ja     800c46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c3e:	0f be c9             	movsbl %cl,%ecx
  800c41:	83 e9 57             	sub    $0x57,%ecx
  800c44:	eb 0e                	jmp    800c54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c49:	80 fb 19             	cmp    $0x19,%bl
  800c4c:	77 12                	ja     800c60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c4e:	0f be c9             	movsbl %cl,%ecx
  800c51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c54:	39 f1                	cmp    %esi,%ecx
  800c56:	7d 0c                	jge    800c64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c58:	42                   	inc    %edx
  800c59:	0f af c6             	imul   %esi,%eax
  800c5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c5e:	eb c4                	jmp    800c24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c60:	89 c1                	mov    %eax,%ecx
  800c62:	eb 02                	jmp    800c66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6a:	74 05                	je     800c71 <strtol+0xbd>
		*endptr = (char *) s;
  800c6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c71:	85 ff                	test   %edi,%edi
  800c73:	74 04                	je     800c79 <strtol+0xc5>
  800c75:	89 c8                	mov    %ecx,%eax
  800c77:	f7 d8                	neg    %eax
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
	...

00800c80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	89 c3                	mov    %eax,%ebx
  800c93:	89 c7                	mov    %eax,%edi
  800c95:	89 c6                	mov    %eax,%esi
  800c97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cae:	89 d1                	mov    %edx,%ecx
  800cb0:	89 d3                	mov    %edx,%ebx
  800cb2:	89 d7                	mov    %edx,%edi
  800cb4:	89 d6                	mov    %edx,%esi
  800cb6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccb:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	89 cb                	mov    %ecx,%ebx
  800cd5:	89 cf                	mov    %ecx,%edi
  800cd7:	89 ce                	mov    %ecx,%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 28                	jle    800d07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cea:	00 
  800ceb:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfa:	00 
  800cfb:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d02:	e8 b1 f5 ff ff       	call   8002b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d07:	83 c4 2c             	add    $0x2c,%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1f:	89 d1                	mov    %edx,%ecx
  800d21:	89 d3                	mov    %edx,%ebx
  800d23:	89 d7                	mov    %edx,%edi
  800d25:	89 d6                	mov    %edx,%esi
  800d27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_yield>:

void
sys_yield(void)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	ba 00 00 00 00       	mov    $0x0,%edx
  800d39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3e:	89 d1                	mov    %edx,%ecx
  800d40:	89 d3                	mov    %edx,%ebx
  800d42:	89 d7                	mov    %edx,%edi
  800d44:	89 d6                	mov    %edx,%esi
  800d46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	be 00 00 00 00       	mov    $0x0,%esi
  800d5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 f7                	mov    %esi,%edi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800d94:	e8 1f f5 ff ff       	call   8002b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b8 05 00 00 00       	mov    $0x5,%eax
  800daf:	8b 75 18             	mov    0x18(%ebp),%esi
  800db2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 28                	jle    800dec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800de7:	e8 cc f4 ff ff       	call   8002b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dec:	83 c4 2c             	add    $0x2c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
  800dfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e02:	b8 06 00 00 00       	mov    $0x6,%eax
  800e07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	89 df                	mov    %ebx,%edi
  800e0f:	89 de                	mov    %ebx,%esi
  800e11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7e 28                	jle    800e3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e22:	00 
  800e23:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e3a:	e8 79 f4 ff ff       	call   8002b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3f:	83 c4 2c             	add    $0x2c,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 08 00 00 00       	mov    $0x8,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800e8d:	e8 26 f4 ff ff       	call   8002b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e92:	83 c4 2c             	add    $0x2c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800ee0:	e8 d3 f3 ff ff       	call   8002b8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee5:	83 c4 2c             	add    $0x2c,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800f33:	e8 80 f3 ff ff       	call   8002b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f38:	83 c4 2c             	add    $0x2c,%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	be 00 00 00 00       	mov    $0x0,%esi
  800f4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f76:	8b 55 08             	mov    0x8(%ebp),%edx
  800f79:	89 cb                	mov    %ecx,%ebx
  800f7b:	89 cf                	mov    %ecx,%edi
  800f7d:	89 ce                	mov    %ecx,%esi
  800f7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f81:	85 c0                	test   %eax,%eax
  800f83:	7e 28                	jle    800fad <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f89:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f90:	00 
  800f91:	c7 44 24 08 9f 24 80 	movl   $0x80249f,0x8(%esp)
  800f98:	00 
  800f99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa0:	00 
  800fa1:	c7 04 24 bc 24 80 00 	movl   $0x8024bc,(%esp)
  800fa8:	e8 0b f3 ff ff       	call   8002b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fad:	83 c4 2c             	add    $0x2c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	00 00                	add    %al,(%eax)
	...

00800fb8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	05 00 00 00 30       	add    $0x30000000,%eax
  800fc3:	c1 e8 0c             	shr    $0xc,%eax
}
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	89 04 24             	mov    %eax,(%esp)
  800fd4:	e8 df ff ff ff       	call   800fb8 <fd2num>
  800fd9:	05 20 00 0d 00       	add    $0xd0020,%eax
  800fde:	c1 e0 0c             	shl    $0xc,%eax
}
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	53                   	push   %ebx
  800fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fef:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ff1:	89 c2                	mov    %eax,%edx
  800ff3:	c1 ea 16             	shr    $0x16,%edx
  800ff6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ffd:	f6 c2 01             	test   $0x1,%dl
  801000:	74 11                	je     801013 <fd_alloc+0x30>
  801002:	89 c2                	mov    %eax,%edx
  801004:	c1 ea 0c             	shr    $0xc,%edx
  801007:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80100e:	f6 c2 01             	test   $0x1,%dl
  801011:	75 09                	jne    80101c <fd_alloc+0x39>
			*fd_store = fd;
  801013:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801015:	b8 00 00 00 00       	mov    $0x0,%eax
  80101a:	eb 17                	jmp    801033 <fd_alloc+0x50>
  80101c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801021:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801026:	75 c7                	jne    800fef <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801028:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80102e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801033:	5b                   	pop    %ebx
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80103c:	83 f8 1f             	cmp    $0x1f,%eax
  80103f:	77 36                	ja     801077 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801041:	05 00 00 0d 00       	add    $0xd0000,%eax
  801046:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801049:	89 c2                	mov    %eax,%edx
  80104b:	c1 ea 16             	shr    $0x16,%edx
  80104e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801055:	f6 c2 01             	test   $0x1,%dl
  801058:	74 24                	je     80107e <fd_lookup+0x48>
  80105a:	89 c2                	mov    %eax,%edx
  80105c:	c1 ea 0c             	shr    $0xc,%edx
  80105f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801066:	f6 c2 01             	test   $0x1,%dl
  801069:	74 1a                	je     801085 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80106b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106e:	89 02                	mov    %eax,(%edx)
	return 0;
  801070:	b8 00 00 00 00       	mov    $0x0,%eax
  801075:	eb 13                	jmp    80108a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801077:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80107c:	eb 0c                	jmp    80108a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80107e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801083:	eb 05                	jmp    80108a <fd_lookup+0x54>
  801085:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	53                   	push   %ebx
  801090:	83 ec 14             	sub    $0x14,%esp
  801093:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801096:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801099:	ba 00 00 00 00       	mov    $0x0,%edx
  80109e:	eb 0e                	jmp    8010ae <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8010a0:	39 08                	cmp    %ecx,(%eax)
  8010a2:	75 09                	jne    8010ad <dev_lookup+0x21>
			*dev = devtab[i];
  8010a4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8010a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ab:	eb 33                	jmp    8010e0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010ad:	42                   	inc    %edx
  8010ae:	8b 04 95 4c 25 80 00 	mov    0x80254c(,%edx,4),%eax
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	75 e7                	jne    8010a0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010be:	8b 40 48             	mov    0x48(%eax),%eax
  8010c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c9:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  8010d0:	e8 db f2 ff ff       	call   8003b0 <cprintf>
	*dev = 0;
  8010d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010e0:	83 c4 14             	add    $0x14,%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 30             	sub    $0x30,%esp
  8010ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f1:	8a 45 0c             	mov    0xc(%ebp),%al
  8010f4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010f7:	89 34 24             	mov    %esi,(%esp)
  8010fa:	e8 b9 fe ff ff       	call   800fb8 <fd2num>
  8010ff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801102:	89 54 24 04          	mov    %edx,0x4(%esp)
  801106:	89 04 24             	mov    %eax,(%esp)
  801109:	e8 28 ff ff ff       	call   801036 <fd_lookup>
  80110e:	89 c3                	mov    %eax,%ebx
  801110:	85 c0                	test   %eax,%eax
  801112:	78 05                	js     801119 <fd_close+0x33>
	    || fd != fd2)
  801114:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801117:	74 0d                	je     801126 <fd_close+0x40>
		return (must_exist ? r : 0);
  801119:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80111d:	75 46                	jne    801165 <fd_close+0x7f>
  80111f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801124:	eb 3f                	jmp    801165 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801126:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112d:	8b 06                	mov    (%esi),%eax
  80112f:	89 04 24             	mov    %eax,(%esp)
  801132:	e8 55 ff ff ff       	call   80108c <dev_lookup>
  801137:	89 c3                	mov    %eax,%ebx
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 18                	js     801155 <fd_close+0x6f>
		if (dev->dev_close)
  80113d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801140:	8b 40 10             	mov    0x10(%eax),%eax
  801143:	85 c0                	test   %eax,%eax
  801145:	74 09                	je     801150 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801147:	89 34 24             	mov    %esi,(%esp)
  80114a:	ff d0                	call   *%eax
  80114c:	89 c3                	mov    %eax,%ebx
  80114e:	eb 05                	jmp    801155 <fd_close+0x6f>
		else
			r = 0;
  801150:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801155:	89 74 24 04          	mov    %esi,0x4(%esp)
  801159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801160:	e8 8f fc ff ff       	call   800df4 <sys_page_unmap>
	return r;
}
  801165:	89 d8                	mov    %ebx,%eax
  801167:	83 c4 30             	add    $0x30,%esp
  80116a:	5b                   	pop    %ebx
  80116b:	5e                   	pop    %esi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	89 04 24             	mov    %eax,(%esp)
  801181:	e8 b0 fe ff ff       	call   801036 <fd_lookup>
  801186:	85 c0                	test   %eax,%eax
  801188:	78 13                	js     80119d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80118a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801191:	00 
  801192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	e8 49 ff ff ff       	call   8010e6 <fd_close>
}
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    

0080119f <close_all>:

void
close_all(void)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011ab:	89 1c 24             	mov    %ebx,(%esp)
  8011ae:	e8 bb ff ff ff       	call   80116e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011b3:	43                   	inc    %ebx
  8011b4:	83 fb 20             	cmp    $0x20,%ebx
  8011b7:	75 f2                	jne    8011ab <close_all+0xc>
		close(i);
}
  8011b9:	83 c4 14             	add    $0x14,%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	57                   	push   %edi
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 4c             	sub    $0x4c,%esp
  8011c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d5:	89 04 24             	mov    %eax,(%esp)
  8011d8:	e8 59 fe ff ff       	call   801036 <fd_lookup>
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	0f 88 e1 00 00 00    	js     8012c8 <dup+0x109>
		return r;
	close(newfdnum);
  8011e7:	89 3c 24             	mov    %edi,(%esp)
  8011ea:	e8 7f ff ff ff       	call   80116e <close>

	newfd = INDEX2FD(newfdnum);
  8011ef:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8011f5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8011f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fb:	89 04 24             	mov    %eax,(%esp)
  8011fe:	e8 c5 fd ff ff       	call   800fc8 <fd2data>
  801203:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801205:	89 34 24             	mov    %esi,(%esp)
  801208:	e8 bb fd ff ff       	call   800fc8 <fd2data>
  80120d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801210:	89 d8                	mov    %ebx,%eax
  801212:	c1 e8 16             	shr    $0x16,%eax
  801215:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80121c:	a8 01                	test   $0x1,%al
  80121e:	74 46                	je     801266 <dup+0xa7>
  801220:	89 d8                	mov    %ebx,%eax
  801222:	c1 e8 0c             	shr    $0xc,%eax
  801225:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80122c:	f6 c2 01             	test   $0x1,%dl
  80122f:	74 35                	je     801266 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801231:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801238:	25 07 0e 00 00       	and    $0xe07,%eax
  80123d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801241:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801244:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801248:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80124f:	00 
  801250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801254:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80125b:	e8 41 fb ff ff       	call   800da1 <sys_page_map>
  801260:	89 c3                	mov    %eax,%ebx
  801262:	85 c0                	test   %eax,%eax
  801264:	78 3b                	js     8012a1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801266:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801269:	89 c2                	mov    %eax,%edx
  80126b:	c1 ea 0c             	shr    $0xc,%edx
  80126e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801275:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80127b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80127f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801283:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80128a:	00 
  80128b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801296:	e8 06 fb ff ff       	call   800da1 <sys_page_map>
  80129b:	89 c3                	mov    %eax,%ebx
  80129d:	85 c0                	test   %eax,%eax
  80129f:	79 25                	jns    8012c6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ac:	e8 43 fb ff ff       	call   800df4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bf:	e8 30 fb ff ff       	call   800df4 <sys_page_unmap>
	return r;
  8012c4:	eb 02                	jmp    8012c8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012c6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012c8:	89 d8                	mov    %ebx,%eax
  8012ca:	83 c4 4c             	add    $0x4c,%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 24             	sub    $0x24,%esp
  8012d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e3:	89 1c 24             	mov    %ebx,(%esp)
  8012e6:	e8 4b fd ff ff       	call   801036 <fd_lookup>
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 6d                	js     80135c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f9:	8b 00                	mov    (%eax),%eax
  8012fb:	89 04 24             	mov    %eax,(%esp)
  8012fe:	e8 89 fd ff ff       	call   80108c <dev_lookup>
  801303:	85 c0                	test   %eax,%eax
  801305:	78 55                	js     80135c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130a:	8b 50 08             	mov    0x8(%eax),%edx
  80130d:	83 e2 03             	and    $0x3,%edx
  801310:	83 fa 01             	cmp    $0x1,%edx
  801313:	75 23                	jne    801338 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801315:	a1 04 40 80 00       	mov    0x804004,%eax
  80131a:	8b 40 48             	mov    0x48(%eax),%eax
  80131d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801321:	89 44 24 04          	mov    %eax,0x4(%esp)
  801325:	c7 04 24 10 25 80 00 	movl   $0x802510,(%esp)
  80132c:	e8 7f f0 ff ff       	call   8003b0 <cprintf>
		return -E_INVAL;
  801331:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801336:	eb 24                	jmp    80135c <read+0x8a>
	}
	if (!dev->dev_read)
  801338:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80133b:	8b 52 08             	mov    0x8(%edx),%edx
  80133e:	85 d2                	test   %edx,%edx
  801340:	74 15                	je     801357 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801342:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801345:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801349:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801350:	89 04 24             	mov    %eax,(%esp)
  801353:	ff d2                	call   *%edx
  801355:	eb 05                	jmp    80135c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801357:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80135c:	83 c4 24             	add    $0x24,%esp
  80135f:	5b                   	pop    %ebx
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	57                   	push   %edi
  801366:	56                   	push   %esi
  801367:	53                   	push   %ebx
  801368:	83 ec 1c             	sub    $0x1c,%esp
  80136b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80136e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801371:	bb 00 00 00 00       	mov    $0x0,%ebx
  801376:	eb 23                	jmp    80139b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801378:	89 f0                	mov    %esi,%eax
  80137a:	29 d8                	sub    %ebx,%eax
  80137c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801380:	8b 45 0c             	mov    0xc(%ebp),%eax
  801383:	01 d8                	add    %ebx,%eax
  801385:	89 44 24 04          	mov    %eax,0x4(%esp)
  801389:	89 3c 24             	mov    %edi,(%esp)
  80138c:	e8 41 ff ff ff       	call   8012d2 <read>
		if (m < 0)
  801391:	85 c0                	test   %eax,%eax
  801393:	78 10                	js     8013a5 <readn+0x43>
			return m;
		if (m == 0)
  801395:	85 c0                	test   %eax,%eax
  801397:	74 0a                	je     8013a3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801399:	01 c3                	add    %eax,%ebx
  80139b:	39 f3                	cmp    %esi,%ebx
  80139d:	72 d9                	jb     801378 <readn+0x16>
  80139f:	89 d8                	mov    %ebx,%eax
  8013a1:	eb 02                	jmp    8013a5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8013a3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013a5:	83 c4 1c             	add    $0x1c,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 24             	sub    $0x24,%esp
  8013b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013be:	89 1c 24             	mov    %ebx,(%esp)
  8013c1:	e8 70 fc ff ff       	call   801036 <fd_lookup>
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 68                	js     801432 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	8b 00                	mov    (%eax),%eax
  8013d6:	89 04 24             	mov    %eax,(%esp)
  8013d9:	e8 ae fc ff ff       	call   80108c <dev_lookup>
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 50                	js     801432 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e9:	75 23                	jne    80140e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f0:	8b 40 48             	mov    0x48(%eax),%eax
  8013f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fb:	c7 04 24 2c 25 80 00 	movl   $0x80252c,(%esp)
  801402:	e8 a9 ef ff ff       	call   8003b0 <cprintf>
		return -E_INVAL;
  801407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140c:	eb 24                	jmp    801432 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80140e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801411:	8b 52 0c             	mov    0xc(%edx),%edx
  801414:	85 d2                	test   %edx,%edx
  801416:	74 15                	je     80142d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80141b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80141f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801422:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801426:	89 04 24             	mov    %eax,(%esp)
  801429:	ff d2                	call   *%edx
  80142b:	eb 05                	jmp    801432 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80142d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801432:	83 c4 24             	add    $0x24,%esp
  801435:	5b                   	pop    %ebx
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <seek>:

int
seek(int fdnum, off_t offset)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801441:	89 44 24 04          	mov    %eax,0x4(%esp)
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
  801448:	89 04 24             	mov    %eax,(%esp)
  80144b:	e8 e6 fb ff ff       	call   801036 <fd_lookup>
  801450:	85 c0                	test   %eax,%eax
  801452:	78 0e                	js     801462 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801454:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801457:	8b 55 0c             	mov    0xc(%ebp),%edx
  80145a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80145d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	53                   	push   %ebx
  801468:	83 ec 24             	sub    $0x24,%esp
  80146b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801471:	89 44 24 04          	mov    %eax,0x4(%esp)
  801475:	89 1c 24             	mov    %ebx,(%esp)
  801478:	e8 b9 fb ff ff       	call   801036 <fd_lookup>
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 61                	js     8014e2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	89 44 24 04          	mov    %eax,0x4(%esp)
  801488:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148b:	8b 00                	mov    (%eax),%eax
  80148d:	89 04 24             	mov    %eax,(%esp)
  801490:	e8 f7 fb ff ff       	call   80108c <dev_lookup>
  801495:	85 c0                	test   %eax,%eax
  801497:	78 49                	js     8014e2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801499:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a0:	75 23                	jne    8014c5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014a2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014a7:	8b 40 48             	mov    0x48(%eax),%eax
  8014aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b2:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  8014b9:	e8 f2 ee ff ff       	call   8003b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c3:	eb 1d                	jmp    8014e2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8014c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c8:	8b 52 18             	mov    0x18(%edx),%edx
  8014cb:	85 d2                	test   %edx,%edx
  8014cd:	74 0e                	je     8014dd <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014d6:	89 04 24             	mov    %eax,(%esp)
  8014d9:	ff d2                	call   *%edx
  8014db:	eb 05                	jmp    8014e2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014e2:	83 c4 24             	add    $0x24,%esp
  8014e5:	5b                   	pop    %ebx
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	53                   	push   %ebx
  8014ec:	83 ec 24             	sub    $0x24,%esp
  8014ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fc:	89 04 24             	mov    %eax,(%esp)
  8014ff:	e8 32 fb ff ff       	call   801036 <fd_lookup>
  801504:	85 c0                	test   %eax,%eax
  801506:	78 52                	js     80155a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	8b 00                	mov    (%eax),%eax
  801514:	89 04 24             	mov    %eax,(%esp)
  801517:	e8 70 fb ff ff       	call   80108c <dev_lookup>
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 3a                	js     80155a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801520:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801523:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801527:	74 2c                	je     801555 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801529:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80152c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801533:	00 00 00 
	stat->st_isdir = 0;
  801536:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80153d:	00 00 00 
	stat->st_dev = dev;
  801540:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801546:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80154a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80154d:	89 14 24             	mov    %edx,(%esp)
  801550:	ff 50 14             	call   *0x14(%eax)
  801553:	eb 05                	jmp    80155a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801555:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80155a:	83 c4 24             	add    $0x24,%esp
  80155d:	5b                   	pop    %ebx
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    

00801560 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	56                   	push   %esi
  801564:	53                   	push   %ebx
  801565:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801568:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80156f:	00 
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
  801573:	89 04 24             	mov    %eax,(%esp)
  801576:	e8 fe 01 00 00       	call   801779 <open>
  80157b:	89 c3                	mov    %eax,%ebx
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 1b                	js     80159c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801581:	8b 45 0c             	mov    0xc(%ebp),%eax
  801584:	89 44 24 04          	mov    %eax,0x4(%esp)
  801588:	89 1c 24             	mov    %ebx,(%esp)
  80158b:	e8 58 ff ff ff       	call   8014e8 <fstat>
  801590:	89 c6                	mov    %eax,%esi
	close(fd);
  801592:	89 1c 24             	mov    %ebx,(%esp)
  801595:	e8 d4 fb ff ff       	call   80116e <close>
	return r;
  80159a:	89 f3                	mov    %esi,%ebx
}
  80159c:	89 d8                	mov    %ebx,%eax
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    
  8015a5:	00 00                	add    %al,(%eax)
	...

008015a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 10             	sub    $0x10,%esp
  8015b0:	89 c3                	mov    %eax,%ebx
  8015b2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015b4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015bb:	75 11                	jne    8015ce <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015c4:	e8 3a 08 00 00       	call   801e03 <ipc_find_env>
  8015c9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015ce:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015d5:	00 
  8015d6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015dd:	00 
  8015de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e2:	a1 00 40 80 00       	mov    0x804000,%eax
  8015e7:	89 04 24             	mov    %eax,(%esp)
  8015ea:	e8 aa 07 00 00       	call   801d99 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f6:	00 
  8015f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801602:	e8 29 07 00 00       	call   801d30 <ipc_recv>
}
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	5b                   	pop    %ebx
  80160b:	5e                   	pop    %esi
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801614:	8b 45 08             	mov    0x8(%ebp),%eax
  801617:	8b 40 0c             	mov    0xc(%eax),%eax
  80161a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80161f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801622:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801627:	ba 00 00 00 00       	mov    $0x0,%edx
  80162c:	b8 02 00 00 00       	mov    $0x2,%eax
  801631:	e8 72 ff ff ff       	call   8015a8 <fsipc>
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80163e:	8b 45 08             	mov    0x8(%ebp),%eax
  801641:	8b 40 0c             	mov    0xc(%eax),%eax
  801644:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801649:	ba 00 00 00 00       	mov    $0x0,%edx
  80164e:	b8 06 00 00 00       	mov    $0x6,%eax
  801653:	e8 50 ff ff ff       	call   8015a8 <fsipc>
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 14             	sub    $0x14,%esp
  801661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801664:	8b 45 08             	mov    0x8(%ebp),%eax
  801667:	8b 40 0c             	mov    0xc(%eax),%eax
  80166a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80166f:	ba 00 00 00 00       	mov    $0x0,%edx
  801674:	b8 05 00 00 00       	mov    $0x5,%eax
  801679:	e8 2a ff ff ff       	call   8015a8 <fsipc>
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 2b                	js     8016ad <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801682:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801689:	00 
  80168a:	89 1c 24             	mov    %ebx,(%esp)
  80168d:	e8 c9 f2 ff ff       	call   80095b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801692:	a1 80 50 80 00       	mov    0x805080,%eax
  801697:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80169d:	a1 84 50 80 00       	mov    0x805084,%eax
  8016a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ad:	83 c4 14             	add    $0x14,%esp
  8016b0:	5b                   	pop    %ebx
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    

008016b3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8016b9:	c7 44 24 08 5c 25 80 	movl   $0x80255c,0x8(%esp)
  8016c0:	00 
  8016c1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016c8:	00 
  8016c9:	c7 04 24 7a 25 80 00 	movl   $0x80257a,(%esp)
  8016d0:	e8 e3 eb ff ff       	call   8002b8 <_panic>

008016d5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 10             	sub    $0x10,%esp
  8016dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8016fb:	e8 a8 fe ff ff       	call   8015a8 <fsipc>
  801700:	89 c3                	mov    %eax,%ebx
  801702:	85 c0                	test   %eax,%eax
  801704:	78 6a                	js     801770 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801706:	39 c6                	cmp    %eax,%esi
  801708:	73 24                	jae    80172e <devfile_read+0x59>
  80170a:	c7 44 24 0c 85 25 80 	movl   $0x802585,0xc(%esp)
  801711:	00 
  801712:	c7 44 24 08 8c 25 80 	movl   $0x80258c,0x8(%esp)
  801719:	00 
  80171a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801721:	00 
  801722:	c7 04 24 7a 25 80 00 	movl   $0x80257a,(%esp)
  801729:	e8 8a eb ff ff       	call   8002b8 <_panic>
	assert(r <= PGSIZE);
  80172e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801733:	7e 24                	jle    801759 <devfile_read+0x84>
  801735:	c7 44 24 0c a1 25 80 	movl   $0x8025a1,0xc(%esp)
  80173c:	00 
  80173d:	c7 44 24 08 8c 25 80 	movl   $0x80258c,0x8(%esp)
  801744:	00 
  801745:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80174c:	00 
  80174d:	c7 04 24 7a 25 80 00 	movl   $0x80257a,(%esp)
  801754:	e8 5f eb ff ff       	call   8002b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801759:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801764:	00 
  801765:	8b 45 0c             	mov    0xc(%ebp),%eax
  801768:	89 04 24             	mov    %eax,(%esp)
  80176b:	e8 64 f3 ff ff       	call   800ad4 <memmove>
	return r;
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
  80177e:	83 ec 20             	sub    $0x20,%esp
  801781:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801784:	89 34 24             	mov    %esi,(%esp)
  801787:	e8 9c f1 ff ff       	call   800928 <strlen>
  80178c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801791:	7f 60                	jg     8017f3 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801793:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801796:	89 04 24             	mov    %eax,(%esp)
  801799:	e8 45 f8 ff ff       	call   800fe3 <fd_alloc>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 54                	js     8017f8 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017af:	e8 a7 f1 ff ff       	call   80095b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c4:	e8 df fd ff ff       	call   8015a8 <fsipc>
  8017c9:	89 c3                	mov    %eax,%ebx
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	79 15                	jns    8017e4 <open+0x6b>
		fd_close(fd, 0);
  8017cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017d6:	00 
  8017d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017da:	89 04 24             	mov    %eax,(%esp)
  8017dd:	e8 04 f9 ff ff       	call   8010e6 <fd_close>
		return r;
  8017e2:	eb 14                	jmp    8017f8 <open+0x7f>
	}

	return fd2num(fd);
  8017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e7:	89 04 24             	mov    %eax,(%esp)
  8017ea:	e8 c9 f7 ff ff       	call   800fb8 <fd2num>
  8017ef:	89 c3                	mov    %eax,%ebx
  8017f1:	eb 05                	jmp    8017f8 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017f3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	83 c4 20             	add    $0x20,%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801807:	ba 00 00 00 00       	mov    $0x0,%edx
  80180c:	b8 08 00 00 00       	mov    $0x8,%eax
  801811:	e8 92 fd ff ff       	call   8015a8 <fsipc>
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	83 ec 10             	sub    $0x10,%esp
  801820:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	89 04 24             	mov    %eax,(%esp)
  801829:	e8 9a f7 ff ff       	call   800fc8 <fd2data>
  80182e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801830:	c7 44 24 04 ad 25 80 	movl   $0x8025ad,0x4(%esp)
  801837:	00 
  801838:	89 34 24             	mov    %esi,(%esp)
  80183b:	e8 1b f1 ff ff       	call   80095b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801840:	8b 43 04             	mov    0x4(%ebx),%eax
  801843:	2b 03                	sub    (%ebx),%eax
  801845:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80184b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801852:	00 00 00 
	stat->st_dev = &devpipe;
  801855:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80185c:	30 80 00 
	return 0;
}
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	5b                   	pop    %ebx
  801868:	5e                   	pop    %esi
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	53                   	push   %ebx
  80186f:	83 ec 14             	sub    $0x14,%esp
  801872:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801875:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801879:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801880:	e8 6f f5 ff ff       	call   800df4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801885:	89 1c 24             	mov    %ebx,(%esp)
  801888:	e8 3b f7 ff ff       	call   800fc8 <fd2data>
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801898:	e8 57 f5 ff ff       	call   800df4 <sys_page_unmap>
}
  80189d:	83 c4 14             	add    $0x14,%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	57                   	push   %edi
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 2c             	sub    $0x2c,%esp
  8018ac:	89 c7                	mov    %eax,%edi
  8018ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018b9:	89 3c 24             	mov    %edi,(%esp)
  8018bc:	e8 87 05 00 00       	call   801e48 <pageref>
  8018c1:	89 c6                	mov    %eax,%esi
  8018c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018c6:	89 04 24             	mov    %eax,(%esp)
  8018c9:	e8 7a 05 00 00       	call   801e48 <pageref>
  8018ce:	39 c6                	cmp    %eax,%esi
  8018d0:	0f 94 c0             	sete   %al
  8018d3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018d6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018dc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018df:	39 cb                	cmp    %ecx,%ebx
  8018e1:	75 08                	jne    8018eb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018e3:	83 c4 2c             	add    $0x2c,%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5f                   	pop    %edi
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018eb:	83 f8 01             	cmp    $0x1,%eax
  8018ee:	75 c1                	jne    8018b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f0:	8b 42 58             	mov    0x58(%edx),%eax
  8018f3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8018fa:	00 
  8018fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801903:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  80190a:	e8 a1 ea ff ff       	call   8003b0 <cprintf>
  80190f:	eb a0                	jmp    8018b1 <_pipeisclosed+0xe>

00801911 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	57                   	push   %edi
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	83 ec 1c             	sub    $0x1c,%esp
  80191a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80191d:	89 34 24             	mov    %esi,(%esp)
  801920:	e8 a3 f6 ff ff       	call   800fc8 <fd2data>
  801925:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801927:	bf 00 00 00 00       	mov    $0x0,%edi
  80192c:	eb 3c                	jmp    80196a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80192e:	89 da                	mov    %ebx,%edx
  801930:	89 f0                	mov    %esi,%eax
  801932:	e8 6c ff ff ff       	call   8018a3 <_pipeisclosed>
  801937:	85 c0                	test   %eax,%eax
  801939:	75 38                	jne    801973 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193b:	e8 ee f3 ff ff       	call   800d2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801940:	8b 43 04             	mov    0x4(%ebx),%eax
  801943:	8b 13                	mov    (%ebx),%edx
  801945:	83 c2 20             	add    $0x20,%edx
  801948:	39 d0                	cmp    %edx,%eax
  80194a:	73 e2                	jae    80192e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80194c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801952:	89 c2                	mov    %eax,%edx
  801954:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80195a:	79 05                	jns    801961 <devpipe_write+0x50>
  80195c:	4a                   	dec    %edx
  80195d:	83 ca e0             	or     $0xffffffe0,%edx
  801960:	42                   	inc    %edx
  801961:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801965:	40                   	inc    %eax
  801966:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801969:	47                   	inc    %edi
  80196a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80196d:	75 d1                	jne    801940 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80196f:	89 f8                	mov    %edi,%eax
  801971:	eb 05                	jmp    801978 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801978:	83 c4 1c             	add    $0x1c,%esp
  80197b:	5b                   	pop    %ebx
  80197c:	5e                   	pop    %esi
  80197d:	5f                   	pop    %edi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	57                   	push   %edi
  801984:	56                   	push   %esi
  801985:	53                   	push   %ebx
  801986:	83 ec 1c             	sub    $0x1c,%esp
  801989:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80198c:	89 3c 24             	mov    %edi,(%esp)
  80198f:	e8 34 f6 ff ff       	call   800fc8 <fd2data>
  801994:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801996:	be 00 00 00 00       	mov    $0x0,%esi
  80199b:	eb 3a                	jmp    8019d7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80199d:	85 f6                	test   %esi,%esi
  80199f:	74 04                	je     8019a5 <devpipe_read+0x25>
				return i;
  8019a1:	89 f0                	mov    %esi,%eax
  8019a3:	eb 40                	jmp    8019e5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019a5:	89 da                	mov    %ebx,%edx
  8019a7:	89 f8                	mov    %edi,%eax
  8019a9:	e8 f5 fe ff ff       	call   8018a3 <_pipeisclosed>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	75 2e                	jne    8019e0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019b2:	e8 77 f3 ff ff       	call   800d2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019b7:	8b 03                	mov    (%ebx),%eax
  8019b9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019bc:	74 df                	je     80199d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019be:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019c3:	79 05                	jns    8019ca <devpipe_read+0x4a>
  8019c5:	48                   	dec    %eax
  8019c6:	83 c8 e0             	or     $0xffffffe0,%eax
  8019c9:	40                   	inc    %eax
  8019ca:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019d4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d6:	46                   	inc    %esi
  8019d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019da:	75 db                	jne    8019b7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019dc:	89 f0                	mov    %esi,%eax
  8019de:	eb 05                	jmp    8019e5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019e5:	83 c4 1c             	add    $0x1c,%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5f                   	pop    %edi
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	57                   	push   %edi
  8019f1:	56                   	push   %esi
  8019f2:	53                   	push   %ebx
  8019f3:	83 ec 3c             	sub    $0x3c,%esp
  8019f6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019fc:	89 04 24             	mov    %eax,(%esp)
  8019ff:	e8 df f5 ff ff       	call   800fe3 <fd_alloc>
  801a04:	89 c3                	mov    %eax,%ebx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	0f 88 45 01 00 00    	js     801b53 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a0e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a15:	00 
  801a16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a24:	e8 24 f3 ff ff       	call   800d4d <sys_page_alloc>
  801a29:	89 c3                	mov    %eax,%ebx
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	0f 88 20 01 00 00    	js     801b53 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a33:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 a5 f5 ff ff       	call   800fe3 <fd_alloc>
  801a3e:	89 c3                	mov    %eax,%ebx
  801a40:	85 c0                	test   %eax,%eax
  801a42:	0f 88 f8 00 00 00    	js     801b40 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a48:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a4f:	00 
  801a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a5e:	e8 ea f2 ff ff       	call   800d4d <sys_page_alloc>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	85 c0                	test   %eax,%eax
  801a67:	0f 88 d3 00 00 00    	js     801b40 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a70:	89 04 24             	mov    %eax,(%esp)
  801a73:	e8 50 f5 ff ff       	call   800fc8 <fd2data>
  801a78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a81:	00 
  801a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a8d:	e8 bb f2 ff ff       	call   800d4d <sys_page_alloc>
  801a92:	89 c3                	mov    %eax,%ebx
  801a94:	85 c0                	test   %eax,%eax
  801a96:	0f 88 91 00 00 00    	js     801b2d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a9f:	89 04 24             	mov    %eax,(%esp)
  801aa2:	e8 21 f5 ff ff       	call   800fc8 <fd2data>
  801aa7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801aae:	00 
  801aaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aba:	00 
  801abb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801abf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac6:	e8 d6 f2 ff ff       	call   800da1 <sys_page_map>
  801acb:	89 c3                	mov    %eax,%ebx
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 4c                	js     801b1d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ad1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ada:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801adc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801adf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ae6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801aef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801af1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801af4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801afb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801afe:	89 04 24             	mov    %eax,(%esp)
  801b01:	e8 b2 f4 ff ff       	call   800fb8 <fd2num>
  801b06:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b08:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b0b:	89 04 24             	mov    %eax,(%esp)
  801b0e:	e8 a5 f4 ff ff       	call   800fb8 <fd2num>
  801b13:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b16:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b1b:	eb 36                	jmp    801b53 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801b1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b28:	e8 c7 f2 ff ff       	call   800df4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801b2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3b:	e8 b4 f2 ff ff       	call   800df4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801b40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b4e:	e8 a1 f2 ff ff       	call   800df4 <sys_page_unmap>
    err:
	return r;
}
  801b53:	89 d8                	mov    %ebx,%eax
  801b55:	83 c4 3c             	add    $0x3c,%esp
  801b58:	5b                   	pop    %ebx
  801b59:	5e                   	pop    %esi
  801b5a:	5f                   	pop    %edi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6d:	89 04 24             	mov    %eax,(%esp)
  801b70:	e8 c1 f4 ff ff       	call   801036 <fd_lookup>
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 15                	js     801b8e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	89 04 24             	mov    %eax,(%esp)
  801b7f:	e8 44 f4 ff ff       	call   800fc8 <fd2data>
	return _pipeisclosed(fd, p);
  801b84:	89 c2                	mov    %eax,%edx
  801b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b89:	e8 15 fd ff ff       	call   8018a3 <_pipeisclosed>
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b93:	b8 00 00 00 00       	mov    $0x0,%eax
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ba0:	c7 44 24 04 cc 25 80 	movl   $0x8025cc,0x4(%esp)
  801ba7:	00 
  801ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bab:	89 04 24             	mov    %eax,(%esp)
  801bae:	e8 a8 ed ff ff       	call   80095b <strcpy>
	return 0;
}
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	57                   	push   %edi
  801bbe:	56                   	push   %esi
  801bbf:	53                   	push   %ebx
  801bc0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bcb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bd1:	eb 30                	jmp    801c03 <devcons_write+0x49>
		m = n - tot;
  801bd3:	8b 75 10             	mov    0x10(%ebp),%esi
  801bd6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801bd8:	83 fe 7f             	cmp    $0x7f,%esi
  801bdb:	76 05                	jbe    801be2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801bdd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801be2:	89 74 24 08          	mov    %esi,0x8(%esp)
  801be6:	03 45 0c             	add    0xc(%ebp),%eax
  801be9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bed:	89 3c 24             	mov    %edi,(%esp)
  801bf0:	e8 df ee ff ff       	call   800ad4 <memmove>
		sys_cputs(buf, m);
  801bf5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bf9:	89 3c 24             	mov    %edi,(%esp)
  801bfc:	e8 7f f0 ff ff       	call   800c80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c01:	01 f3                	add    %esi,%ebx
  801c03:	89 d8                	mov    %ebx,%eax
  801c05:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c08:	72 c9                	jb     801bd3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c0a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c10:	5b                   	pop    %ebx
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c1f:	75 07                	jne    801c28 <devcons_read+0x13>
  801c21:	eb 25                	jmp    801c48 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c23:	e8 06 f1 ff ff       	call   800d2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c28:	e8 71 f0 ff ff       	call   800c9e <sys_cgetc>
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	74 f2                	je     801c23 <devcons_read+0xe>
  801c31:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c33:	85 c0                	test   %eax,%eax
  801c35:	78 1d                	js     801c54 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c37:	83 f8 04             	cmp    $0x4,%eax
  801c3a:	74 13                	je     801c4f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3f:	88 10                	mov    %dl,(%eax)
	return 1;
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	eb 0c                	jmp    801c54 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c48:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4d:	eb 05                	jmp    801c54 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c62:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c69:	00 
  801c6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c6d:	89 04 24             	mov    %eax,(%esp)
  801c70:	e8 0b f0 ff ff       	call   800c80 <sys_cputs>
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <getchar>:

int
getchar(void)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c7d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c84:	00 
  801c85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c93:	e8 3a f6 ff ff       	call   8012d2 <read>
	if (r < 0)
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 0f                	js     801cab <getchar+0x34>
		return r;
	if (r < 1)
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	7e 06                	jle    801ca6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801ca0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ca4:	eb 05                	jmp    801cab <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ca6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cba:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbd:	89 04 24             	mov    %eax,(%esp)
  801cc0:	e8 71 f3 ff ff       	call   801036 <fd_lookup>
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 11                	js     801cda <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd2:	39 10                	cmp    %edx,(%eax)
  801cd4:	0f 94 c0             	sete   %al
  801cd7:	0f b6 c0             	movzbl %al,%eax
}
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <opencons>:

int
opencons(void)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce5:	89 04 24             	mov    %eax,(%esp)
  801ce8:	e8 f6 f2 ff ff       	call   800fe3 <fd_alloc>
  801ced:	85 c0                	test   %eax,%eax
  801cef:	78 3c                	js     801d2d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cf1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cf8:	00 
  801cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d07:	e8 41 f0 ff ff       	call   800d4d <sys_page_alloc>
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 1d                	js     801d2d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d10:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d19:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d25:	89 04 24             	mov    %eax,(%esp)
  801d28:	e8 8b f2 ff ff       	call   800fb8 <fd2num>
}
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    
	...

00801d30 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	57                   	push   %edi
  801d34:	56                   	push   %esi
  801d35:	53                   	push   %ebx
  801d36:	83 ec 1c             	sub    $0x1c,%esp
  801d39:	8b 75 08             	mov    0x8(%ebp),%esi
  801d3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d3f:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801d42:	85 db                	test   %ebx,%ebx
  801d44:	75 05                	jne    801d4b <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801d46:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801d4b:	89 1c 24             	mov    %ebx,(%esp)
  801d4e:	e8 10 f2 ff ff       	call   800f63 <sys_ipc_recv>
  801d53:	85 c0                	test   %eax,%eax
  801d55:	79 16                	jns    801d6d <ipc_recv+0x3d>
		*from_env_store = 0;
  801d57:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801d5d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801d63:	89 1c 24             	mov    %ebx,(%esp)
  801d66:	e8 f8 f1 ff ff       	call   800f63 <sys_ipc_recv>
  801d6b:	eb 24                	jmp    801d91 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801d6d:	85 f6                	test   %esi,%esi
  801d6f:	74 0a                	je     801d7b <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801d71:	a1 04 40 80 00       	mov    0x804004,%eax
  801d76:	8b 40 74             	mov    0x74(%eax),%eax
  801d79:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801d7b:	85 ff                	test   %edi,%edi
  801d7d:	74 0a                	je     801d89 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801d7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801d84:	8b 40 78             	mov    0x78(%eax),%eax
  801d87:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801d89:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d91:	83 c4 1c             	add    $0x1c,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    

00801d99 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	57                   	push   %edi
  801d9d:	56                   	push   %esi
  801d9e:	53                   	push   %ebx
  801d9f:	83 ec 1c             	sub    $0x1c,%esp
  801da2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801da5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801da8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801dab:	85 db                	test   %ebx,%ebx
  801dad:	75 05                	jne    801db4 <ipc_send+0x1b>
		pg = (void *)-1;
  801daf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801db4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801db8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dbc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc3:	89 04 24             	mov    %eax,(%esp)
  801dc6:	e8 75 f1 ff ff       	call   800f40 <sys_ipc_try_send>
		if (r == 0) {		
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	74 2c                	je     801dfb <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801dcf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dd2:	75 07                	jne    801ddb <ipc_send+0x42>
			sys_yield();
  801dd4:	e8 55 ef ff ff       	call   800d2e <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801dd9:	eb d9                	jmp    801db4 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801ddb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ddf:	c7 44 24 08 d8 25 80 	movl   $0x8025d8,0x8(%esp)
  801de6:	00 
  801de7:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801dee:	00 
  801def:	c7 04 24 e6 25 80 00 	movl   $0x8025e6,(%esp)
  801df6:	e8 bd e4 ff ff       	call   8002b8 <_panic>
		}
	}
}
  801dfb:	83 c4 1c             	add    $0x1c,%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    

00801e03 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	53                   	push   %ebx
  801e07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801e0a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e0f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801e16:	89 c2                	mov    %eax,%edx
  801e18:	c1 e2 07             	shl    $0x7,%edx
  801e1b:	29 ca                	sub    %ecx,%edx
  801e1d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e23:	8b 52 50             	mov    0x50(%edx),%edx
  801e26:	39 da                	cmp    %ebx,%edx
  801e28:	75 0f                	jne    801e39 <ipc_find_env+0x36>
			return envs[i].env_id;
  801e2a:	c1 e0 07             	shl    $0x7,%eax
  801e2d:	29 c8                	sub    %ecx,%eax
  801e2f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e34:	8b 40 40             	mov    0x40(%eax),%eax
  801e37:	eb 0c                	jmp    801e45 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e39:	40                   	inc    %eax
  801e3a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e3f:	75 ce                	jne    801e0f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e41:	66 b8 00 00          	mov    $0x0,%ax
}
  801e45:	5b                   	pop    %ebx
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e4e:	89 c2                	mov    %eax,%edx
  801e50:	c1 ea 16             	shr    $0x16,%edx
  801e53:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e5a:	f6 c2 01             	test   $0x1,%dl
  801e5d:	74 1e                	je     801e7d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e5f:	c1 e8 0c             	shr    $0xc,%eax
  801e62:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e69:	a8 01                	test   $0x1,%al
  801e6b:	74 17                	je     801e84 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e6d:	c1 e8 0c             	shr    $0xc,%eax
  801e70:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e77:	ef 
  801e78:	0f b7 c0             	movzwl %ax,%eax
  801e7b:	eb 0c                	jmp    801e89 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e82:	eb 05                	jmp    801e89 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e84:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    
	...

00801e8c <__udivdi3>:
  801e8c:	55                   	push   %ebp
  801e8d:	57                   	push   %edi
  801e8e:	56                   	push   %esi
  801e8f:	83 ec 10             	sub    $0x10,%esp
  801e92:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e96:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801e9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e9e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801ea2:	89 cd                	mov    %ecx,%ebp
  801ea4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	75 2c                	jne    801ed8 <__udivdi3+0x4c>
  801eac:	39 f9                	cmp    %edi,%ecx
  801eae:	77 68                	ja     801f18 <__udivdi3+0x8c>
  801eb0:	85 c9                	test   %ecx,%ecx
  801eb2:	75 0b                	jne    801ebf <__udivdi3+0x33>
  801eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb9:	31 d2                	xor    %edx,%edx
  801ebb:	f7 f1                	div    %ecx
  801ebd:	89 c1                	mov    %eax,%ecx
  801ebf:	31 d2                	xor    %edx,%edx
  801ec1:	89 f8                	mov    %edi,%eax
  801ec3:	f7 f1                	div    %ecx
  801ec5:	89 c7                	mov    %eax,%edi
  801ec7:	89 f0                	mov    %esi,%eax
  801ec9:	f7 f1                	div    %ecx
  801ecb:	89 c6                	mov    %eax,%esi
  801ecd:	89 f0                	mov    %esi,%eax
  801ecf:	89 fa                	mov    %edi,%edx
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    
  801ed8:	39 f8                	cmp    %edi,%eax
  801eda:	77 2c                	ja     801f08 <__udivdi3+0x7c>
  801edc:	0f bd f0             	bsr    %eax,%esi
  801edf:	83 f6 1f             	xor    $0x1f,%esi
  801ee2:	75 4c                	jne    801f30 <__udivdi3+0xa4>
  801ee4:	39 f8                	cmp    %edi,%eax
  801ee6:	bf 00 00 00 00       	mov    $0x0,%edi
  801eeb:	72 0a                	jb     801ef7 <__udivdi3+0x6b>
  801eed:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ef1:	0f 87 ad 00 00 00    	ja     801fa4 <__udivdi3+0x118>
  801ef7:	be 01 00 00 00       	mov    $0x1,%esi
  801efc:	89 f0                	mov    %esi,%eax
  801efe:	89 fa                	mov    %edi,%edx
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	5e                   	pop    %esi
  801f04:	5f                   	pop    %edi
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    
  801f07:	90                   	nop
  801f08:	31 ff                	xor    %edi,%edi
  801f0a:	31 f6                	xor    %esi,%esi
  801f0c:	89 f0                	mov    %esi,%eax
  801f0e:	89 fa                	mov    %edi,%edx
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	5e                   	pop    %esi
  801f14:	5f                   	pop    %edi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    
  801f17:	90                   	nop
  801f18:	89 fa                	mov    %edi,%edx
  801f1a:	89 f0                	mov    %esi,%eax
  801f1c:	f7 f1                	div    %ecx
  801f1e:	89 c6                	mov    %eax,%esi
  801f20:	31 ff                	xor    %edi,%edi
  801f22:	89 f0                	mov    %esi,%eax
  801f24:	89 fa                	mov    %edi,%edx
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	5e                   	pop    %esi
  801f2a:	5f                   	pop    %edi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	8d 76 00             	lea    0x0(%esi),%esi
  801f30:	89 f1                	mov    %esi,%ecx
  801f32:	d3 e0                	shl    %cl,%eax
  801f34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f38:	b8 20 00 00 00       	mov    $0x20,%eax
  801f3d:	29 f0                	sub    %esi,%eax
  801f3f:	89 ea                	mov    %ebp,%edx
  801f41:	88 c1                	mov    %al,%cl
  801f43:	d3 ea                	shr    %cl,%edx
  801f45:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801f49:	09 ca                	or     %ecx,%edx
  801f4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f4f:	89 f1                	mov    %esi,%ecx
  801f51:	d3 e5                	shl    %cl,%ebp
  801f53:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801f57:	89 fd                	mov    %edi,%ebp
  801f59:	88 c1                	mov    %al,%cl
  801f5b:	d3 ed                	shr    %cl,%ebp
  801f5d:	89 fa                	mov    %edi,%edx
  801f5f:	89 f1                	mov    %esi,%ecx
  801f61:	d3 e2                	shl    %cl,%edx
  801f63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f67:	88 c1                	mov    %al,%cl
  801f69:	d3 ef                	shr    %cl,%edi
  801f6b:	09 d7                	or     %edx,%edi
  801f6d:	89 f8                	mov    %edi,%eax
  801f6f:	89 ea                	mov    %ebp,%edx
  801f71:	f7 74 24 08          	divl   0x8(%esp)
  801f75:	89 d1                	mov    %edx,%ecx
  801f77:	89 c7                	mov    %eax,%edi
  801f79:	f7 64 24 0c          	mull   0xc(%esp)
  801f7d:	39 d1                	cmp    %edx,%ecx
  801f7f:	72 17                	jb     801f98 <__udivdi3+0x10c>
  801f81:	74 09                	je     801f8c <__udivdi3+0x100>
  801f83:	89 fe                	mov    %edi,%esi
  801f85:	31 ff                	xor    %edi,%edi
  801f87:	e9 41 ff ff ff       	jmp    801ecd <__udivdi3+0x41>
  801f8c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f90:	89 f1                	mov    %esi,%ecx
  801f92:	d3 e2                	shl    %cl,%edx
  801f94:	39 c2                	cmp    %eax,%edx
  801f96:	73 eb                	jae    801f83 <__udivdi3+0xf7>
  801f98:	8d 77 ff             	lea    -0x1(%edi),%esi
  801f9b:	31 ff                	xor    %edi,%edi
  801f9d:	e9 2b ff ff ff       	jmp    801ecd <__udivdi3+0x41>
  801fa2:	66 90                	xchg   %ax,%ax
  801fa4:	31 f6                	xor    %esi,%esi
  801fa6:	e9 22 ff ff ff       	jmp    801ecd <__udivdi3+0x41>
	...

00801fac <__umoddi3>:
  801fac:	55                   	push   %ebp
  801fad:	57                   	push   %edi
  801fae:	56                   	push   %esi
  801faf:	83 ec 20             	sub    $0x20,%esp
  801fb2:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fb6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801fba:	89 44 24 14          	mov    %eax,0x14(%esp)
  801fbe:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fc2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fc6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801fca:	89 c7                	mov    %eax,%edi
  801fcc:	89 f2                	mov    %esi,%edx
  801fce:	85 ed                	test   %ebp,%ebp
  801fd0:	75 16                	jne    801fe8 <__umoddi3+0x3c>
  801fd2:	39 f1                	cmp    %esi,%ecx
  801fd4:	0f 86 a6 00 00 00    	jbe    802080 <__umoddi3+0xd4>
  801fda:	f7 f1                	div    %ecx
  801fdc:	89 d0                	mov    %edx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	83 c4 20             	add    $0x20,%esp
  801fe3:	5e                   	pop    %esi
  801fe4:	5f                   	pop    %edi
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    
  801fe7:	90                   	nop
  801fe8:	39 f5                	cmp    %esi,%ebp
  801fea:	0f 87 ac 00 00 00    	ja     80209c <__umoddi3+0xf0>
  801ff0:	0f bd c5             	bsr    %ebp,%eax
  801ff3:	83 f0 1f             	xor    $0x1f,%eax
  801ff6:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ffa:	0f 84 a8 00 00 00    	je     8020a8 <__umoddi3+0xfc>
  802000:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802004:	d3 e5                	shl    %cl,%ebp
  802006:	bf 20 00 00 00       	mov    $0x20,%edi
  80200b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80200f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802013:	89 f9                	mov    %edi,%ecx
  802015:	d3 e8                	shr    %cl,%eax
  802017:	09 e8                	or     %ebp,%eax
  802019:	89 44 24 18          	mov    %eax,0x18(%esp)
  80201d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802021:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802025:	d3 e0                	shl    %cl,%eax
  802027:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202b:	89 f2                	mov    %esi,%edx
  80202d:	d3 e2                	shl    %cl,%edx
  80202f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802033:	d3 e0                	shl    %cl,%eax
  802035:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802039:	8b 44 24 14          	mov    0x14(%esp),%eax
  80203d:	89 f9                	mov    %edi,%ecx
  80203f:	d3 e8                	shr    %cl,%eax
  802041:	09 d0                	or     %edx,%eax
  802043:	d3 ee                	shr    %cl,%esi
  802045:	89 f2                	mov    %esi,%edx
  802047:	f7 74 24 18          	divl   0x18(%esp)
  80204b:	89 d6                	mov    %edx,%esi
  80204d:	f7 64 24 0c          	mull   0xc(%esp)
  802051:	89 c5                	mov    %eax,%ebp
  802053:	89 d1                	mov    %edx,%ecx
  802055:	39 d6                	cmp    %edx,%esi
  802057:	72 67                	jb     8020c0 <__umoddi3+0x114>
  802059:	74 75                	je     8020d0 <__umoddi3+0x124>
  80205b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80205f:	29 e8                	sub    %ebp,%eax
  802061:	19 ce                	sbb    %ecx,%esi
  802063:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802067:	d3 e8                	shr    %cl,%eax
  802069:	89 f2                	mov    %esi,%edx
  80206b:	89 f9                	mov    %edi,%ecx
  80206d:	d3 e2                	shl    %cl,%edx
  80206f:	09 d0                	or     %edx,%eax
  802071:	89 f2                	mov    %esi,%edx
  802073:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802077:	d3 ea                	shr    %cl,%edx
  802079:	83 c4 20             	add    $0x20,%esp
  80207c:	5e                   	pop    %esi
  80207d:	5f                   	pop    %edi
  80207e:	5d                   	pop    %ebp
  80207f:	c3                   	ret    
  802080:	85 c9                	test   %ecx,%ecx
  802082:	75 0b                	jne    80208f <__umoddi3+0xe3>
  802084:	b8 01 00 00 00       	mov    $0x1,%eax
  802089:	31 d2                	xor    %edx,%edx
  80208b:	f7 f1                	div    %ecx
  80208d:	89 c1                	mov    %eax,%ecx
  80208f:	89 f0                	mov    %esi,%eax
  802091:	31 d2                	xor    %edx,%edx
  802093:	f7 f1                	div    %ecx
  802095:	89 f8                	mov    %edi,%eax
  802097:	e9 3e ff ff ff       	jmp    801fda <__umoddi3+0x2e>
  80209c:	89 f2                	mov    %esi,%edx
  80209e:	83 c4 20             	add    $0x20,%esp
  8020a1:	5e                   	pop    %esi
  8020a2:	5f                   	pop    %edi
  8020a3:	5d                   	pop    %ebp
  8020a4:	c3                   	ret    
  8020a5:	8d 76 00             	lea    0x0(%esi),%esi
  8020a8:	39 f5                	cmp    %esi,%ebp
  8020aa:	72 04                	jb     8020b0 <__umoddi3+0x104>
  8020ac:	39 f9                	cmp    %edi,%ecx
  8020ae:	77 06                	ja     8020b6 <__umoddi3+0x10a>
  8020b0:	89 f2                	mov    %esi,%edx
  8020b2:	29 cf                	sub    %ecx,%edi
  8020b4:	19 ea                	sbb    %ebp,%edx
  8020b6:	89 f8                	mov    %edi,%eax
  8020b8:	83 c4 20             	add    $0x20,%esp
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    
  8020bf:	90                   	nop
  8020c0:	89 d1                	mov    %edx,%ecx
  8020c2:	89 c5                	mov    %eax,%ebp
  8020c4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8020c8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8020cc:	eb 8d                	jmp    80205b <__umoddi3+0xaf>
  8020ce:	66 90                	xchg   %ax,%ax
  8020d0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8020d4:	72 ea                	jb     8020c0 <__umoddi3+0x114>
  8020d6:	89 f1                	mov    %esi,%ecx
  8020d8:	eb 81                	jmp    80205b <__umoddi3+0xaf>
