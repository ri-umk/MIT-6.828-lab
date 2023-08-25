
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 00 20 80 00 	movl   $0x802000,(%esp)
  80004b:	e8 fc 01 00 00       	call   80024c <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 7a 0b 00 00       	call   800be9 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 0a 20 80 00 	movl   $0x80200a,(%esp)
  800092:	e8 bd 00 00 00       	call   800154 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 4c 20 80 	movl   $0x80204c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 e6 06 00 00       	call   800799 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 89 0d 00 00       	call   800e54 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 3d 0a 00 00       	call   800b1c <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 10             	sub    $0x10,%esp
  8000ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8000f2:	e8 b4 0a 00 00       	call   800bab <sys_getenvid>
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800103:	c1 e0 07             	shl    $0x7,%eax
  800106:	29 d0                	sub    %edx,%eax
  800108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 f6                	test   %esi,%esi
  800114:	7e 07                	jle    80011d <libmain+0x39>
		binaryname = argv[0];
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800121:	89 34 24             	mov    %esi,(%esp)
  800124:	e8 90 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800129:	e8 0a 00 00 00       	call   800138 <exit>
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80013e:	e8 6c 0f 00 00       	call   8010af <close_all>
	sys_env_destroy(0);
  800143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014a:	e8 0a 0a 00 00       	call   800b59 <sys_env_destroy>
}
  80014f:	c9                   	leave  
  800150:	c3                   	ret    
  800151:	00 00                	add    %al,(%eax)
	...

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800165:	e8 41 0a 00 00       	call   800bab <sys_getenvid>
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 78 20 80 00 	movl   $0x802078,(%esp)
  800187:	e8 c0 00 00 00       	call   80024c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 50 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  80019b:	c7 04 24 c5 24 80 00 	movl   $0x8024c5,(%esp)
  8001a2:	e8 a5 00 00 00       	call   80024c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x53>
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	40                   	inc    %eax
  8001c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	75 19                	jne    8001e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d0:	00 
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 40 09 00 00       	call   800b1c <sys_cputs>
		b->idx = 0;
  8001dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e2:	ff 43 04             	incl   0x4(%ebx)
}
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fb:	00 00 00 
	b.cnt = 0;
  8001fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800205:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	89 44 24 08          	mov    %eax,0x8(%esp)
  800216:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  800227:	e8 82 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800232:	89 44 24 04          	mov    %eax,0x4(%esp)
  800236:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	e8 d8 08 00 00       	call   800b1c <sys_cputs>

	return b.cnt;
}
  800244:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800252:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 87 ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800264:	c9                   	leave  
  800265:	c3                   	ret    
	...

00800268 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800274:	89 d7                	mov    %edx,%edi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800282:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800285:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800288:	85 c0                	test   %eax,%eax
  80028a:	75 08                	jne    800294 <printnum+0x2c>
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800292:	77 57                	ja     8002eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800294:	89 74 24 10          	mov    %esi,0x10(%esp)
  800298:	4b                   	dec    %ebx
  800299:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029d:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b3:	00 
  8002b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	e8 d6 1a 00 00       	call   801d9c <__udivdi3>
  8002c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 89 ff ff ff       	call   800268 <printnum>
  8002df:	eb 0f                	jmp    8002f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	89 34 24             	mov    %esi,(%esp)
  8002e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002eb:	4b                   	dec    %ebx
  8002ec:	85 db                	test   %ebx,%ebx
  8002ee:	7f f1                	jg     8002e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800306:	00 
  800307:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	e8 a3 1b 00 00       	call   801ebc <__umoddi3>
  800319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031d:	0f be 80 9b 20 80 00 	movsbl 0x80209b(%eax),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032a:	83 c4 3c             	add    $0x3c,%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800335:	83 fa 01             	cmp    $0x1,%edx
  800338:	7e 0e                	jle    800348 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	8b 52 04             	mov    0x4(%edx),%edx
  800346:	eb 22                	jmp    80036a <getuint+0x38>
	else if (lflag)
  800348:	85 d2                	test   %edx,%edx
  80034a:	74 10                	je     80035c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	eb 0e                	jmp    80036a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800372:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800375:	8b 10                	mov    (%eax),%edx
  800377:	3b 50 04             	cmp    0x4(%eax),%edx
  80037a:	73 08                	jae    800384 <sprintputch+0x18>
		*b->buf++ = ch;
  80037c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037f:	88 0a                	mov    %cl,(%edx)
  800381:	42                   	inc    %edx
  800382:	89 10                	mov    %edx,(%eax)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800393:	8b 45 10             	mov    0x10(%ebp),%eax
  800396:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	e8 02 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 4c             	sub    $0x4c,%esp
  8003b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8003bd:	eb 12                	jmp    8003d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003bf:	85 c0                	test   %eax,%eax
  8003c1:	0f 84 6b 03 00 00    	je     800732 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d1:	0f b6 06             	movzbl (%esi),%eax
  8003d4:	46                   	inc    %esi
  8003d5:	83 f8 25             	cmp    $0x25,%eax
  8003d8:	75 e5                	jne    8003bf <vprintfmt+0x11>
  8003da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f6:	eb 26                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ff:	eb 1d                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800404:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800408:	eb 14                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80040d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800414:	eb 08                	jmp    80041e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800416:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800419:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	0f b6 06             	movzbl (%esi),%eax
  800421:	8d 56 01             	lea    0x1(%esi),%edx
  800424:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800427:	8a 16                	mov    (%esi),%dl
  800429:	83 ea 23             	sub    $0x23,%edx
  80042c:	80 fa 55             	cmp    $0x55,%dl
  80042f:	0f 87 e1 02 00 00    	ja     800716 <vprintfmt+0x368>
  800435:	0f b6 d2             	movzbl %dl,%edx
  800438:	ff 24 95 e0 21 80 00 	jmp    *0x8021e0(,%edx,4)
  80043f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800442:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800447:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80044e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800451:	8d 50 d0             	lea    -0x30(%eax),%edx
  800454:	83 fa 09             	cmp    $0x9,%edx
  800457:	77 2a                	ja     800483 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800459:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045a:	eb eb                	jmp    800447 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046a:	eb 17                	jmp    800483 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80046c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800470:	78 98                	js     80040a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800475:	eb a7                	jmp    80041e <vprintfmt+0x70>
  800477:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800481:	eb 9b                	jmp    80041e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800483:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800487:	79 95                	jns    80041e <vprintfmt+0x70>
  800489:	eb 8b                	jmp    800416 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048f:	eb 8d                	jmp    80041e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a9:	e9 23 ff ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	79 02                	jns    8004bf <vprintfmt+0x111>
  8004bd:	f7 d8                	neg    %eax
  8004bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c1:	83 f8 0f             	cmp    $0xf,%eax
  8004c4:	7f 0b                	jg     8004d1 <vprintfmt+0x123>
  8004c6:	8b 04 85 40 23 80 00 	mov    0x802340(,%eax,4),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	75 23                	jne    8004f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d5:	c7 44 24 08 b3 20 80 	movl   $0x8020b3,0x8(%esp)
  8004dc:	00 
  8004dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	e8 9a fe ff ff       	call   800386 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ef:	e9 dd fe ff ff       	jmp    8003d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f8:	c7 44 24 08 9e 24 80 	movl   $0x80249e,0x8(%esp)
  8004ff:	00 
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	8b 55 08             	mov    0x8(%ebp),%edx
  800507:	89 14 24             	mov    %edx,(%esp)
  80050a:	e8 77 fe ff ff       	call   800386 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800512:	e9 ba fe ff ff       	jmp    8003d1 <vprintfmt+0x23>
  800517:	89 f9                	mov    %edi,%ecx
  800519:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 30                	mov    (%eax),%esi
  80052a:	85 f6                	test   %esi,%esi
  80052c:	75 05                	jne    800533 <vprintfmt+0x185>
				p = "(null)";
  80052e:	be ac 20 80 00       	mov    $0x8020ac,%esi
			if (width > 0 && padc != '-')
  800533:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800537:	0f 8e 84 00 00 00    	jle    8005c1 <vprintfmt+0x213>
  80053d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800541:	74 7e                	je     8005c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800547:	89 34 24             	mov    %esi,(%esp)
  80054a:	e8 8b 02 00 00       	call   8007da <strnlen>
  80054f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800552:	29 c2                	sub    %eax,%edx
  800554:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800557:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80055e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800561:	89 de                	mov    %ebx,%esi
  800563:	89 d3                	mov    %edx,%ebx
  800565:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	eb 0b                	jmp    800574 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800569:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056d:	89 3c 24             	mov    %edi,(%esp)
  800570:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	4b                   	dec    %ebx
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f f1                	jg     800569 <vprintfmt+0x1bb>
  800578:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057b:	89 f3                	mov    %esi,%ebx
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	79 05                	jns    80058c <vprintfmt+0x1de>
  800587:	b8 00 00 00 00       	mov    $0x0,%eax
  80058c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058f:	29 c2                	sub    %eax,%edx
  800591:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800594:	eb 2b                	jmp    8005c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059a:	74 18                	je     8005b4 <vprintfmt+0x206>
  80059c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80059f:	83 fa 5e             	cmp    $0x5e,%edx
  8005a2:	76 10                	jbe    8005b4 <vprintfmt+0x206>
					putch('?', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	eb 0a                	jmp    8005be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c1:	0f be 06             	movsbl (%esi),%eax
  8005c4:	46                   	inc    %esi
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	74 21                	je     8005ea <vprintfmt+0x23c>
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	78 c9                	js     800596 <vprintfmt+0x1e8>
  8005cd:	4f                   	dec    %edi
  8005ce:	79 c6                	jns    800596 <vprintfmt+0x1e8>
  8005d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d3:	89 de                	mov    %ebx,%esi
  8005d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d8:	eb 18                	jmp    8005f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e7:	4b                   	dec    %ebx
  8005e8:	eb 08                	jmp    8005f2 <vprintfmt+0x244>
  8005ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ed:	89 de                	mov    %ebx,%esi
  8005ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	7f e4                	jg     8005da <vprintfmt+0x22c>
  8005f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fe:	e9 ce fd ff ff       	jmp    8003d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7e 10                	jle    800618 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 08             	lea    0x8(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 30                	mov    (%eax),%esi
  800613:	8b 78 04             	mov    0x4(%eax),%edi
  800616:	eb 26                	jmp    80063e <vprintfmt+0x290>
	else if (lflag)
  800618:	85 c9                	test   %ecx,%ecx
  80061a:	74 12                	je     80062e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 30                	mov    (%eax),%esi
  800627:	89 f7                	mov    %esi,%edi
  800629:	c1 ff 1f             	sar    $0x1f,%edi
  80062c:	eb 10                	jmp    80063e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 30                	mov    (%eax),%esi
  800639:	89 f7                	mov    %esi,%edi
  80063b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063e:	85 ff                	test   %edi,%edi
  800640:	78 0a                	js     80064c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 8c 00 00 00       	jmp    8006d8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065a:	f7 de                	neg    %esi
  80065c:	83 d7 00             	adc    $0x0,%edi
  80065f:	f7 df                	neg    %edi
			}
			base = 10;
  800661:	b8 0a 00 00 00       	mov    $0xa,%eax
  800666:	eb 70                	jmp    8006d8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800668:	89 ca                	mov    %ecx,%edx
  80066a:	8d 45 14             	lea    0x14(%ebp),%eax
  80066d:	e8 c0 fc ff ff       	call   800332 <getuint>
  800672:	89 c6                	mov    %eax,%esi
  800674:	89 d7                	mov    %edx,%edi
			base = 10;
  800676:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067b:	eb 5b                	jmp    8006d8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 ab fc ff ff       	call   800332 <getuint>
  800687:	89 c6                	mov    %eax,%esi
  800689:	89 d7                	mov    %edx,%edi
			base = 8;
  80068b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800690:	eb 46                	jmp    8006d8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800696:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b7:	8b 30                	mov    (%eax),%esi
  8006b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c3:	eb 13                	jmp    8006d8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c5:	89 ca                	mov    %ecx,%edx
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ca:	e8 63 fc ff ff       	call   800332 <getuint>
  8006cf:	89 c6                	mov    %eax,%esi
  8006d1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006eb:	89 34 24             	mov    %esi,(%esp)
  8006ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f2:	89 da                	mov    %ebx,%edx
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	e8 6c fb ff ff       	call   800268 <printnum>
			break;
  8006fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ff:	e9 cd fc ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	89 04 24             	mov    %eax,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800711:	e9 bb fc ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800716:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800721:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800724:	eb 01                	jmp    800727 <vprintfmt+0x379>
  800726:	4e                   	dec    %esi
  800727:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072b:	75 f9                	jne    800726 <vprintfmt+0x378>
  80072d:	e9 9f fc ff ff       	jmp    8003d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800732:	83 c4 4c             	add    $0x4c,%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5f                   	pop    %edi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 28             	sub    $0x28,%esp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800749:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800757:	85 c0                	test   %eax,%eax
  800759:	74 30                	je     80078b <vsnprintf+0x51>
  80075b:	85 d2                	test   %edx,%edx
  80075d:	7e 33                	jle    800792 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800770:	89 44 24 04          	mov    %eax,0x4(%esp)
  800774:	c7 04 24 6c 03 80 00 	movl   $0x80036c,(%esp)
  80077b:	e8 2e fc ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800780:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800783:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800789:	eb 0c                	jmp    800797 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800790:	eb 05                	jmp    800797 <vsnprintf+0x5d>
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 7b ff ff ff       	call   80073a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    
  8007c1:	00 00                	add    %al,(%eax)
	...

008007c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cf:	eb 01                	jmp    8007d2 <strlen+0xe>
		n++;
  8007d1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d6:	75 f9                	jne    8007d1 <strlen+0xd>
		n++;
	return n;
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e8:	eb 01                	jmp    8007eb <strnlen+0x11>
		n++;
  8007ea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	74 06                	je     8007f5 <strnlen+0x1b>
  8007ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f3:	75 f5                	jne    8007ea <strnlen+0x10>
		n++;
	return n;
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800801:	ba 00 00 00 00       	mov    $0x0,%edx
  800806:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800809:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80080c:	42                   	inc    %edx
  80080d:	84 c9                	test   %cl,%cl
  80080f:	75 f5                	jne    800806 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800811:	5b                   	pop    %ebx
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081e:	89 1c 24             	mov    %ebx,(%esp)
  800821:	e8 9e ff ff ff       	call   8007c4 <strlen>
	strcpy(dst + len, src);
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082d:	01 d8                	add    %ebx,%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 c0 ff ff ff       	call   8007f7 <strcpy>
	return dst;
}
  800837:	89 d8                	mov    %ebx,%eax
  800839:	83 c4 08             	add    $0x8,%esp
  80083c:	5b                   	pop    %ebx
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800852:	eb 0c                	jmp    800860 <strncpy+0x21>
		*dst++ = *src;
  800854:	8a 1a                	mov    (%edx),%bl
  800856:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800859:	80 3a 01             	cmpb   $0x1,(%edx)
  80085c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085f:	41                   	inc    %ecx
  800860:	39 f1                	cmp    %esi,%ecx
  800862:	75 f0                	jne    800854 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 75 08             	mov    0x8(%ebp),%esi
  800870:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800873:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800876:	85 d2                	test   %edx,%edx
  800878:	75 0a                	jne    800884 <strlcpy+0x1c>
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	eb 1a                	jmp    800898 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087e:	88 18                	mov    %bl,(%eax)
  800880:	40                   	inc    %eax
  800881:	41                   	inc    %ecx
  800882:	eb 02                	jmp    800886 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800886:	4a                   	dec    %edx
  800887:	74 0a                	je     800893 <strlcpy+0x2b>
  800889:	8a 19                	mov    (%ecx),%bl
  80088b:	84 db                	test   %bl,%bl
  80088d:	75 ef                	jne    80087e <strlcpy+0x16>
  80088f:	89 c2                	mov    %eax,%edx
  800891:	eb 02                	jmp    800895 <strlcpy+0x2d>
  800893:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800895:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800898:	29 f0                	sub    %esi,%eax
}
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a7:	eb 02                	jmp    8008ab <strcmp+0xd>
		p++, q++;
  8008a9:	41                   	inc    %ecx
  8008aa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ab:	8a 01                	mov    (%ecx),%al
  8008ad:	84 c0                	test   %al,%al
  8008af:	74 04                	je     8008b5 <strcmp+0x17>
  8008b1:	3a 02                	cmp    (%edx),%al
  8008b3:	74 f4                	je     8008a9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b5:	0f b6 c0             	movzbl %al,%eax
  8008b8:	0f b6 12             	movzbl (%edx),%edx
  8008bb:	29 d0                	sub    %edx,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008cc:	eb 03                	jmp    8008d1 <strncmp+0x12>
		n--, p++, q++;
  8008ce:	4a                   	dec    %edx
  8008cf:	40                   	inc    %eax
  8008d0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	74 14                	je     8008e9 <strncmp+0x2a>
  8008d5:	8a 18                	mov    (%eax),%bl
  8008d7:	84 db                	test   %bl,%bl
  8008d9:	74 04                	je     8008df <strncmp+0x20>
  8008db:	3a 19                	cmp    (%ecx),%bl
  8008dd:	74 ef                	je     8008ce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 00             	movzbl (%eax),%eax
  8008e2:	0f b6 11             	movzbl (%ecx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
  8008e7:	eb 05                	jmp    8008ee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fa:	eb 05                	jmp    800901 <strchr+0x10>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 0c                	je     80090c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800900:	40                   	inc    %eax
  800901:	8a 10                	mov    (%eax),%dl
  800903:	84 d2                	test   %dl,%dl
  800905:	75 f5                	jne    8008fc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800917:	eb 05                	jmp    80091e <strfind+0x10>
		if (*s == c)
  800919:	38 ca                	cmp    %cl,%dl
  80091b:	74 07                	je     800924 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80091d:	40                   	inc    %eax
  80091e:	8a 10                	mov    (%eax),%dl
  800920:	84 d2                	test   %dl,%dl
  800922:	75 f5                	jne    800919 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 30                	je     800969 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800939:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093f:	75 25                	jne    800966 <memset+0x40>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 20                	jne    800966 <memset+0x40>
		c &= 0xFF;
  800946:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800949:	89 d3                	mov    %edx,%ebx
  80094b:	c1 e3 08             	shl    $0x8,%ebx
  80094e:	89 d6                	mov    %edx,%esi
  800950:	c1 e6 18             	shl    $0x18,%esi
  800953:	89 d0                	mov    %edx,%eax
  800955:	c1 e0 10             	shl    $0x10,%eax
  800958:	09 f0                	or     %esi,%eax
  80095a:	09 d0                	or     %edx,%eax
  80095c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800961:	fc                   	cld    
  800962:	f3 ab                	rep stos %eax,%es:(%edi)
  800964:	eb 03                	jmp    800969 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800966:	fc                   	cld    
  800967:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800969:	89 f8                	mov    %edi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097e:	39 c6                	cmp    %eax,%esi
  800980:	73 34                	jae    8009b6 <memmove+0x46>
  800982:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800985:	39 d0                	cmp    %edx,%eax
  800987:	73 2d                	jae    8009b6 <memmove+0x46>
		s += n;
		d += n;
  800989:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	f6 c2 03             	test   $0x3,%dl
  80098f:	75 1b                	jne    8009ac <memmove+0x3c>
  800991:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800997:	75 13                	jne    8009ac <memmove+0x3c>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 0e                	jne    8009ac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099e:	83 ef 04             	sub    $0x4,%edi
  8009a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009a7:	fd                   	std    
  8009a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009aa:	eb 07                	jmp    8009b3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ac:	4f                   	dec    %edi
  8009ad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b0:	fd                   	std    
  8009b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b3:	fc                   	cld    
  8009b4:	eb 20                	jmp    8009d6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bc:	75 13                	jne    8009d1 <memmove+0x61>
  8009be:	a8 03                	test   $0x3,%al
  8009c0:	75 0f                	jne    8009d1 <memmove+0x61>
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 0a                	jne    8009d1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ca:	89 c7                	mov    %eax,%edi
  8009cc:	fc                   	cld    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb 05                	jmp    8009d6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	89 04 24             	mov    %eax,(%esp)
  8009f4:	e8 77 ff ff ff       	call   800970 <memmove>
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0f:	eb 16                	jmp    800a27 <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a14:	42                   	inc    %edx
  800a15:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a19:	38 c8                	cmp    %cl,%al
  800a1b:	74 0a                	je     800a27 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c0             	movzbl %al,%eax
  800a20:	0f b6 c9             	movzbl %cl,%ecx
  800a23:	29 c8                	sub    %ecx,%eax
  800a25:	eb 09                	jmp    800a30 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	39 da                	cmp    %ebx,%edx
  800a29:	75 e6                	jne    800a11 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3e:	89 c2                	mov    %eax,%edx
  800a40:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a43:	eb 05                	jmp    800a4a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a45:	38 08                	cmp    %cl,(%eax)
  800a47:	74 05                	je     800a4e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a49:	40                   	inc    %eax
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	72 f7                	jb     800a45 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 55 08             	mov    0x8(%ebp),%edx
  800a59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5c:	eb 01                	jmp    800a5f <strtol+0xf>
		s++;
  800a5e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	8a 02                	mov    (%edx),%al
  800a61:	3c 20                	cmp    $0x20,%al
  800a63:	74 f9                	je     800a5e <strtol+0xe>
  800a65:	3c 09                	cmp    $0x9,%al
  800a67:	74 f5                	je     800a5e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a69:	3c 2b                	cmp    $0x2b,%al
  800a6b:	75 08                	jne    800a75 <strtol+0x25>
		s++;
  800a6d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a73:	eb 13                	jmp    800a88 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a75:	3c 2d                	cmp    $0x2d,%al
  800a77:	75 0a                	jne    800a83 <strtol+0x33>
		s++, neg = 1;
  800a79:	8d 52 01             	lea    0x1(%edx),%edx
  800a7c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a81:	eb 05                	jmp    800a88 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	85 db                	test   %ebx,%ebx
  800a8a:	74 05                	je     800a91 <strtol+0x41>
  800a8c:	83 fb 10             	cmp    $0x10,%ebx
  800a8f:	75 28                	jne    800ab9 <strtol+0x69>
  800a91:	8a 02                	mov    (%edx),%al
  800a93:	3c 30                	cmp    $0x30,%al
  800a95:	75 10                	jne    800aa7 <strtol+0x57>
  800a97:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9b:	75 0a                	jne    800aa7 <strtol+0x57>
		s += 2, base = 16;
  800a9d:	83 c2 02             	add    $0x2,%edx
  800aa0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa5:	eb 12                	jmp    800ab9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa7:	85 db                	test   %ebx,%ebx
  800aa9:	75 0e                	jne    800ab9 <strtol+0x69>
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 05                	jne    800ab4 <strtol+0x64>
		s++, base = 8;
  800aaf:	42                   	inc    %edx
  800ab0:	b3 08                	mov    $0x8,%bl
  800ab2:	eb 05                	jmp    800ab9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  800abe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac0:	8a 0a                	mov    (%edx),%cl
  800ac2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac5:	80 fb 09             	cmp    $0x9,%bl
  800ac8:	77 08                	ja     800ad2 <strtol+0x82>
			dig = *s - '0';
  800aca:	0f be c9             	movsbl %cl,%ecx
  800acd:	83 e9 30             	sub    $0x30,%ecx
  800ad0:	eb 1e                	jmp    800af0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ada:	0f be c9             	movsbl %cl,%ecx
  800add:	83 e9 57             	sub    $0x57,%ecx
  800ae0:	eb 0e                	jmp    800af0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 12                	ja     800afc <strtol+0xac>
			dig = *s - 'A' + 10;
  800aea:	0f be c9             	movsbl %cl,%ecx
  800aed:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af0:	39 f1                	cmp    %esi,%ecx
  800af2:	7d 0c                	jge    800b00 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af4:	42                   	inc    %edx
  800af5:	0f af c6             	imul   %esi,%eax
  800af8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800afa:	eb c4                	jmp    800ac0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800afc:	89 c1                	mov    %eax,%ecx
  800afe:	eb 02                	jmp    800b02 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b00:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b06:	74 05                	je     800b0d <strtol+0xbd>
		*endptr = (char *) s;
  800b08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b0d:	85 ff                	test   %edi,%edi
  800b0f:	74 04                	je     800b15 <strtol+0xc5>
  800b11:	89 c8                	mov    %ecx,%eax
  800b13:	f7 d8                	neg    %eax
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    
	...

00800b1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	b8 00 00 00 00       	mov    $0x0,%eax
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	89 c3                	mov    %eax,%ebx
  800b2f:	89 c7                	mov    %eax,%edi
  800b31:	89 c6                	mov    %eax,%esi
  800b33:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4a:	89 d1                	mov    %edx,%ecx
  800b4c:	89 d3                	mov    %edx,%ebx
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b67:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	89 cb                	mov    %ecx,%ebx
  800b71:	89 cf                	mov    %ecx,%edi
  800b73:	89 ce                	mov    %ecx,%esi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 28                	jle    800ba3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b86:	00 
  800b87:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800b8e:	00 
  800b8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b96:	00 
  800b97:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800b9e:	e8 b1 f5 ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba3:	83 c4 2c             	add    $0x2c,%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbb:	89 d1                	mov    %edx,%ecx
  800bbd:	89 d3                	mov    %edx,%ebx
  800bbf:	89 d7                	mov    %edx,%edi
  800bc1:	89 d6                	mov    %edx,%esi
  800bc3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_yield>:

void
sys_yield(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	be 00 00 00 00       	mov    $0x0,%esi
  800bf7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 f7                	mov    %esi,%edi
  800c07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7e 28                	jle    800c35 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c11:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c18:	00 
  800c19:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800c20:	00 
  800c21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c28:	00 
  800c29:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800c30:	e8 1f f5 ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c35:	83 c4 2c             	add    $0x2c,%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 28                	jle    800c88 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c64:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c6b:	00 
  800c6c:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800c73:	00 
  800c74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7b:	00 
  800c7c:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800c83:	e8 cc f4 ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c88:	83 c4 2c             	add    $0x2c,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 df                	mov    %ebx,%edi
  800cab:	89 de                	mov    %ebx,%esi
  800cad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 28                	jle    800cdb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800cc6:	00 
  800cc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cce:	00 
  800ccf:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800cd6:	e8 79 f4 ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdb:	83 c4 2c             	add    $0x2c,%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	89 df                	mov    %ebx,%edi
  800cfe:	89 de                	mov    %ebx,%esi
  800d00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7e 28                	jle    800d2e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d11:	00 
  800d12:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800d19:	00 
  800d1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d21:	00 
  800d22:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800d29:	e8 26 f4 ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d2e:	83 c4 2c             	add    $0x2c,%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	b8 09 00 00 00       	mov    $0x9,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 28                	jle    800d81 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d64:	00 
  800d65:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800d6c:	00 
  800d6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d74:	00 
  800d75:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800d7c:	e8 d3 f3 ff ff       	call   800154 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d81:	83 c4 2c             	add    $0x2c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 28                	jle    800dd4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800db7:	00 
  800db8:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc7:	00 
  800dc8:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800dcf:	e8 80 f3 ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd4:	83 c4 2c             	add    $0x2c,%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	be 00 00 00 00       	mov    $0x0,%esi
  800de7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800def:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 cb                	mov    %ecx,%ebx
  800e17:	89 cf                	mov    %ecx,%edi
  800e19:	89 ce                	mov    %ecx,%esi
  800e1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	7e 28                	jle    800e49 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e25:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800e34:	00 
  800e35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3c:	00 
  800e3d:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800e44:	e8 0b f3 ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e49:	83 c4 2c             	add    $0x2c,%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    
  800e51:	00 00                	add    %al,(%eax)
	...

00800e54 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e5a:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e61:	75 32                	jne    800e95 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800e63:	e8 43 fd ff ff       	call   800bab <sys_getenvid>
  800e68:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800e6f:	00 
  800e70:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e77:	ee 
  800e78:	89 04 24             	mov    %eax,(%esp)
  800e7b:	e8 69 fd ff ff       	call   800be9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  800e80:	e8 26 fd ff ff       	call   800bab <sys_getenvid>
  800e85:	c7 44 24 04 a0 0e 80 	movl   $0x800ea0,0x4(%esp)
  800e8c:	00 
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	e8 f4 fe ff ff       	call   800d89 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    
	...

00800ea0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ea0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ea1:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800ea6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ea8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  800eab:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  800eaf:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  800eb2:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  800eb7:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  800ebb:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  800ebe:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  800ebf:	83 c4 04             	add    $0x4,%esp
	popfl
  800ec2:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  800ec3:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  800ec4:	c3                   	ret    
  800ec5:	00 00                	add    %al,(%eax)
	...

00800ec8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ece:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed3:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	89 04 24             	mov    %eax,(%esp)
  800ee4:	e8 df ff ff ff       	call   800ec8 <fd2num>
  800ee9:	05 20 00 0d 00       	add    $0xd0020,%eax
  800eee:	c1 e0 0c             	shl    $0xc,%eax
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	53                   	push   %ebx
  800ef7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800efa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800eff:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f01:	89 c2                	mov    %eax,%edx
  800f03:	c1 ea 16             	shr    $0x16,%edx
  800f06:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0d:	f6 c2 01             	test   $0x1,%dl
  800f10:	74 11                	je     800f23 <fd_alloc+0x30>
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	c1 ea 0c             	shr    $0xc,%edx
  800f17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1e:	f6 c2 01             	test   $0x1,%dl
  800f21:	75 09                	jne    800f2c <fd_alloc+0x39>
			*fd_store = fd;
  800f23:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2a:	eb 17                	jmp    800f43 <fd_alloc+0x50>
  800f2c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f31:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f36:	75 c7                	jne    800eff <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f38:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f3e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f43:	5b                   	pop    %ebx
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f4c:	83 f8 1f             	cmp    $0x1f,%eax
  800f4f:	77 36                	ja     800f87 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f51:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f56:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f59:	89 c2                	mov    %eax,%edx
  800f5b:	c1 ea 16             	shr    $0x16,%edx
  800f5e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f65:	f6 c2 01             	test   $0x1,%dl
  800f68:	74 24                	je     800f8e <fd_lookup+0x48>
  800f6a:	89 c2                	mov    %eax,%edx
  800f6c:	c1 ea 0c             	shr    $0xc,%edx
  800f6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f76:	f6 c2 01             	test   $0x1,%dl
  800f79:	74 1a                	je     800f95 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7e:	89 02                	mov    %eax,(%edx)
	return 0;
  800f80:	b8 00 00 00 00       	mov    $0x0,%eax
  800f85:	eb 13                	jmp    800f9a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8c:	eb 0c                	jmp    800f9a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f93:	eb 05                	jmp    800f9a <fd_lookup+0x54>
  800f95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	53                   	push   %ebx
  800fa0:	83 ec 14             	sub    $0x14,%esp
  800fa3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fae:	eb 0e                	jmp    800fbe <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fb0:	39 08                	cmp    %ecx,(%eax)
  800fb2:	75 09                	jne    800fbd <dev_lookup+0x21>
			*dev = devtab[i];
  800fb4:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbb:	eb 33                	jmp    800ff0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fbd:	42                   	inc    %edx
  800fbe:	8b 04 95 4c 24 80 00 	mov    0x80244c(,%edx,4),%eax
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	75 e7                	jne    800fb0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fc9:	a1 04 40 80 00       	mov    0x804004,%eax
  800fce:	8b 40 48             	mov    0x48(%eax),%eax
  800fd1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd9:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  800fe0:	e8 67 f2 ff ff       	call   80024c <cprintf>
	*dev = 0;
  800fe5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800feb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ff0:	83 c4 14             	add    $0x14,%esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 30             	sub    $0x30,%esp
  800ffe:	8b 75 08             	mov    0x8(%ebp),%esi
  801001:	8a 45 0c             	mov    0xc(%ebp),%al
  801004:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801007:	89 34 24             	mov    %esi,(%esp)
  80100a:	e8 b9 fe ff ff       	call   800ec8 <fd2num>
  80100f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801012:	89 54 24 04          	mov    %edx,0x4(%esp)
  801016:	89 04 24             	mov    %eax,(%esp)
  801019:	e8 28 ff ff ff       	call   800f46 <fd_lookup>
  80101e:	89 c3                	mov    %eax,%ebx
  801020:	85 c0                	test   %eax,%eax
  801022:	78 05                	js     801029 <fd_close+0x33>
	    || fd != fd2)
  801024:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801027:	74 0d                	je     801036 <fd_close+0x40>
		return (must_exist ? r : 0);
  801029:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80102d:	75 46                	jne    801075 <fd_close+0x7f>
  80102f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801034:	eb 3f                	jmp    801075 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801036:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801039:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103d:	8b 06                	mov    (%esi),%eax
  80103f:	89 04 24             	mov    %eax,(%esp)
  801042:	e8 55 ff ff ff       	call   800f9c <dev_lookup>
  801047:	89 c3                	mov    %eax,%ebx
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 18                	js     801065 <fd_close+0x6f>
		if (dev->dev_close)
  80104d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801050:	8b 40 10             	mov    0x10(%eax),%eax
  801053:	85 c0                	test   %eax,%eax
  801055:	74 09                	je     801060 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801057:	89 34 24             	mov    %esi,(%esp)
  80105a:	ff d0                	call   *%eax
  80105c:	89 c3                	mov    %eax,%ebx
  80105e:	eb 05                	jmp    801065 <fd_close+0x6f>
		else
			r = 0;
  801060:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801065:	89 74 24 04          	mov    %esi,0x4(%esp)
  801069:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801070:	e8 1b fc ff ff       	call   800c90 <sys_page_unmap>
	return r;
}
  801075:	89 d8                	mov    %ebx,%eax
  801077:	83 c4 30             	add    $0x30,%esp
  80107a:	5b                   	pop    %ebx
  80107b:	5e                   	pop    %esi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801084:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	89 04 24             	mov    %eax,(%esp)
  801091:	e8 b0 fe ff ff       	call   800f46 <fd_lookup>
  801096:	85 c0                	test   %eax,%eax
  801098:	78 13                	js     8010ad <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80109a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a1:	00 
  8010a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a5:	89 04 24             	mov    %eax,(%esp)
  8010a8:	e8 49 ff ff ff       	call   800ff6 <fd_close>
}
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <close_all>:

void
close_all(void)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010bb:	89 1c 24             	mov    %ebx,(%esp)
  8010be:	e8 bb ff ff ff       	call   80107e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c3:	43                   	inc    %ebx
  8010c4:	83 fb 20             	cmp    $0x20,%ebx
  8010c7:	75 f2                	jne    8010bb <close_all+0xc>
		close(i);
}
  8010c9:	83 c4 14             	add    $0x14,%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 4c             	sub    $0x4c,%esp
  8010d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	89 04 24             	mov    %eax,(%esp)
  8010e8:	e8 59 fe ff ff       	call   800f46 <fd_lookup>
  8010ed:	89 c3                	mov    %eax,%ebx
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	0f 88 e1 00 00 00    	js     8011d8 <dup+0x109>
		return r;
	close(newfdnum);
  8010f7:	89 3c 24             	mov    %edi,(%esp)
  8010fa:	e8 7f ff ff ff       	call   80107e <close>

	newfd = INDEX2FD(newfdnum);
  8010ff:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801105:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110b:	89 04 24             	mov    %eax,(%esp)
  80110e:	e8 c5 fd ff ff       	call   800ed8 <fd2data>
  801113:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801115:	89 34 24             	mov    %esi,(%esp)
  801118:	e8 bb fd ff ff       	call   800ed8 <fd2data>
  80111d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801120:	89 d8                	mov    %ebx,%eax
  801122:	c1 e8 16             	shr    $0x16,%eax
  801125:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112c:	a8 01                	test   $0x1,%al
  80112e:	74 46                	je     801176 <dup+0xa7>
  801130:	89 d8                	mov    %ebx,%eax
  801132:	c1 e8 0c             	shr    $0xc,%eax
  801135:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80113c:	f6 c2 01             	test   $0x1,%dl
  80113f:	74 35                	je     801176 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801141:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801148:	25 07 0e 00 00       	and    $0xe07,%eax
  80114d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801151:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801158:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80115f:	00 
  801160:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801164:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116b:	e8 cd fa ff ff       	call   800c3d <sys_page_map>
  801170:	89 c3                	mov    %eax,%ebx
  801172:	85 c0                	test   %eax,%eax
  801174:	78 3b                	js     8011b1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801176:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801179:	89 c2                	mov    %eax,%edx
  80117b:	c1 ea 0c             	shr    $0xc,%edx
  80117e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801185:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80118b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80118f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801193:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80119a:	00 
  80119b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a6:	e8 92 fa ff ff       	call   800c3d <sys_page_map>
  8011ab:	89 c3                	mov    %eax,%ebx
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	79 25                	jns    8011d6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011bc:	e8 cf fa ff ff       	call   800c90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011cf:	e8 bc fa ff ff       	call   800c90 <sys_page_unmap>
	return r;
  8011d4:	eb 02                	jmp    8011d8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011d6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011d8:	89 d8                	mov    %ebx,%eax
  8011da:	83 c4 4c             	add    $0x4c,%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 24             	sub    $0x24,%esp
  8011e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f3:	89 1c 24             	mov    %ebx,(%esp)
  8011f6:	e8 4b fd ff ff       	call   800f46 <fd_lookup>
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 6d                	js     80126c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	89 44 24 04          	mov    %eax,0x4(%esp)
  801206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801209:	8b 00                	mov    (%eax),%eax
  80120b:	89 04 24             	mov    %eax,(%esp)
  80120e:	e8 89 fd ff ff       	call   800f9c <dev_lookup>
  801213:	85 c0                	test   %eax,%eax
  801215:	78 55                	js     80126c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801217:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121a:	8b 50 08             	mov    0x8(%eax),%edx
  80121d:	83 e2 03             	and    $0x3,%edx
  801220:	83 fa 01             	cmp    $0x1,%edx
  801223:	75 23                	jne    801248 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801225:	a1 04 40 80 00       	mov    0x804004,%eax
  80122a:	8b 40 48             	mov    0x48(%eax),%eax
  80122d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801231:	89 44 24 04          	mov    %eax,0x4(%esp)
  801235:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  80123c:	e8 0b f0 ff ff       	call   80024c <cprintf>
		return -E_INVAL;
  801241:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801246:	eb 24                	jmp    80126c <read+0x8a>
	}
	if (!dev->dev_read)
  801248:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124b:	8b 52 08             	mov    0x8(%edx),%edx
  80124e:	85 d2                	test   %edx,%edx
  801250:	74 15                	je     801267 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801252:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801255:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801260:	89 04 24             	mov    %eax,(%esp)
  801263:	ff d2                	call   *%edx
  801265:	eb 05                	jmp    80126c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801267:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80126c:	83 c4 24             	add    $0x24,%esp
  80126f:	5b                   	pop    %ebx
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 1c             	sub    $0x1c,%esp
  80127b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80127e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801281:	bb 00 00 00 00       	mov    $0x0,%ebx
  801286:	eb 23                	jmp    8012ab <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801288:	89 f0                	mov    %esi,%eax
  80128a:	29 d8                	sub    %ebx,%eax
  80128c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801290:	8b 45 0c             	mov    0xc(%ebp),%eax
  801293:	01 d8                	add    %ebx,%eax
  801295:	89 44 24 04          	mov    %eax,0x4(%esp)
  801299:	89 3c 24             	mov    %edi,(%esp)
  80129c:	e8 41 ff ff ff       	call   8011e2 <read>
		if (m < 0)
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 10                	js     8012b5 <readn+0x43>
			return m;
		if (m == 0)
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	74 0a                	je     8012b3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012a9:	01 c3                	add    %eax,%ebx
  8012ab:	39 f3                	cmp    %esi,%ebx
  8012ad:	72 d9                	jb     801288 <readn+0x16>
  8012af:	89 d8                	mov    %ebx,%eax
  8012b1:	eb 02                	jmp    8012b5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012b3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012b5:	83 c4 1c             	add    $0x1c,%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 24             	sub    $0x24,%esp
  8012c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ce:	89 1c 24             	mov    %ebx,(%esp)
  8012d1:	e8 70 fc ff ff       	call   800f46 <fd_lookup>
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 68                	js     801342 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e4:	8b 00                	mov    (%eax),%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 ae fc ff ff       	call   800f9c <dev_lookup>
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 50                	js     801342 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f9:	75 23                	jne    80131e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801300:	8b 40 48             	mov    0x48(%eax),%eax
  801303:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130b:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  801312:	e8 35 ef ff ff       	call   80024c <cprintf>
		return -E_INVAL;
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131c:	eb 24                	jmp    801342 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80131e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801321:	8b 52 0c             	mov    0xc(%edx),%edx
  801324:	85 d2                	test   %edx,%edx
  801326:	74 15                	je     80133d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801328:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80132b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801332:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801336:	89 04 24             	mov    %eax,(%esp)
  801339:	ff d2                	call   *%edx
  80133b:	eb 05                	jmp    801342 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80133d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801342:	83 c4 24             	add    $0x24,%esp
  801345:	5b                   	pop    %ebx
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    

00801348 <seek>:

int
seek(int fdnum, off_t offset)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801351:	89 44 24 04          	mov    %eax,0x4(%esp)
  801355:	8b 45 08             	mov    0x8(%ebp),%eax
  801358:	89 04 24             	mov    %eax,(%esp)
  80135b:	e8 e6 fb ff ff       	call   800f46 <fd_lookup>
  801360:	85 c0                	test   %eax,%eax
  801362:	78 0e                	js     801372 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801364:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801367:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	53                   	push   %ebx
  801378:	83 ec 24             	sub    $0x24,%esp
  80137b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801381:	89 44 24 04          	mov    %eax,0x4(%esp)
  801385:	89 1c 24             	mov    %ebx,(%esp)
  801388:	e8 b9 fb ff ff       	call   800f46 <fd_lookup>
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 61                	js     8013f2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801391:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801394:	89 44 24 04          	mov    %eax,0x4(%esp)
  801398:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139b:	8b 00                	mov    (%eax),%eax
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	e8 f7 fb ff ff       	call   800f9c <dev_lookup>
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 49                	js     8013f2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b0:	75 23                	jne    8013d5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013b7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c2:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  8013c9:	e8 7e ee ff ff       	call   80024c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d3:	eb 1d                	jmp    8013f2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8013d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d8:	8b 52 18             	mov    0x18(%edx),%edx
  8013db:	85 d2                	test   %edx,%edx
  8013dd:	74 0e                	je     8013ed <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013e6:	89 04 24             	mov    %eax,(%esp)
  8013e9:	ff d2                	call   *%edx
  8013eb:	eb 05                	jmp    8013f2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f2:	83 c4 24             	add    $0x24,%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 24             	sub    $0x24,%esp
  8013ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801402:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801405:	89 44 24 04          	mov    %eax,0x4(%esp)
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	89 04 24             	mov    %eax,(%esp)
  80140f:	e8 32 fb ff ff       	call   800f46 <fd_lookup>
  801414:	85 c0                	test   %eax,%eax
  801416:	78 52                	js     80146a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801418:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801422:	8b 00                	mov    (%eax),%eax
  801424:	89 04 24             	mov    %eax,(%esp)
  801427:	e8 70 fb ff ff       	call   800f9c <dev_lookup>
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 3a                	js     80146a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801430:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801433:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801437:	74 2c                	je     801465 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801439:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80143c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801443:	00 00 00 
	stat->st_isdir = 0;
  801446:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80144d:	00 00 00 
	stat->st_dev = dev;
  801450:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801456:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80145a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80145d:	89 14 24             	mov    %edx,(%esp)
  801460:	ff 50 14             	call   *0x14(%eax)
  801463:	eb 05                	jmp    80146a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801465:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80146a:	83 c4 24             	add    $0x24,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
  801475:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801478:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80147f:	00 
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	89 04 24             	mov    %eax,(%esp)
  801486:	e8 fe 01 00 00       	call   801689 <open>
  80148b:	89 c3                	mov    %eax,%ebx
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 1b                	js     8014ac <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801491:	8b 45 0c             	mov    0xc(%ebp),%eax
  801494:	89 44 24 04          	mov    %eax,0x4(%esp)
  801498:	89 1c 24             	mov    %ebx,(%esp)
  80149b:	e8 58 ff ff ff       	call   8013f8 <fstat>
  8014a0:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a2:	89 1c 24             	mov    %ebx,(%esp)
  8014a5:	e8 d4 fb ff ff       	call   80107e <close>
	return r;
  8014aa:	89 f3                	mov    %esi,%ebx
}
  8014ac:	89 d8                	mov    %ebx,%eax
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    
  8014b5:	00 00                	add    %al,(%eax)
	...

008014b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	56                   	push   %esi
  8014bc:	53                   	push   %ebx
  8014bd:	83 ec 10             	sub    $0x10,%esp
  8014c0:	89 c3                	mov    %eax,%ebx
  8014c2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014c4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014cb:	75 11                	jne    8014de <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014d4:	e8 3a 08 00 00       	call   801d13 <ipc_find_env>
  8014d9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014de:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014e5:	00 
  8014e6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8014ed:	00 
  8014ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f2:	a1 00 40 80 00       	mov    0x804000,%eax
  8014f7:	89 04 24             	mov    %eax,(%esp)
  8014fa:	e8 aa 07 00 00       	call   801ca9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801506:	00 
  801507:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801512:	e8 29 07 00 00       	call   801c40 <ipc_recv>
}
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	5b                   	pop    %ebx
  80151b:	5e                   	pop    %esi
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    

0080151e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801524:	8b 45 08             	mov    0x8(%ebp),%eax
  801527:	8b 40 0c             	mov    0xc(%eax),%eax
  80152a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80152f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801532:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801537:	ba 00 00 00 00       	mov    $0x0,%edx
  80153c:	b8 02 00 00 00       	mov    $0x2,%eax
  801541:	e8 72 ff ff ff       	call   8014b8 <fsipc>
}
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80154e:	8b 45 08             	mov    0x8(%ebp),%eax
  801551:	8b 40 0c             	mov    0xc(%eax),%eax
  801554:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801559:	ba 00 00 00 00       	mov    $0x0,%edx
  80155e:	b8 06 00 00 00       	mov    $0x6,%eax
  801563:	e8 50 ff ff ff       	call   8014b8 <fsipc>
}
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
  801571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801574:	8b 45 08             	mov    0x8(%ebp),%eax
  801577:	8b 40 0c             	mov    0xc(%eax),%eax
  80157a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80157f:	ba 00 00 00 00       	mov    $0x0,%edx
  801584:	b8 05 00 00 00       	mov    $0x5,%eax
  801589:	e8 2a ff ff ff       	call   8014b8 <fsipc>
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 2b                	js     8015bd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801592:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801599:	00 
  80159a:	89 1c 24             	mov    %ebx,(%esp)
  80159d:	e8 55 f2 ff ff       	call   8007f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015a2:	a1 80 50 80 00       	mov    0x805080,%eax
  8015a7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015ad:	a1 84 50 80 00       	mov    0x805084,%eax
  8015b2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015bd:	83 c4 14             	add    $0x14,%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8015c9:	c7 44 24 08 5c 24 80 	movl   $0x80245c,0x8(%esp)
  8015d0:	00 
  8015d1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8015d8:	00 
  8015d9:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  8015e0:	e8 6f eb ff ff       	call   800154 <_panic>

008015e5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	56                   	push   %esi
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 10             	sub    $0x10,%esp
  8015ed:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015fb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801601:	ba 00 00 00 00       	mov    $0x0,%edx
  801606:	b8 03 00 00 00       	mov    $0x3,%eax
  80160b:	e8 a8 fe ff ff       	call   8014b8 <fsipc>
  801610:	89 c3                	mov    %eax,%ebx
  801612:	85 c0                	test   %eax,%eax
  801614:	78 6a                	js     801680 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801616:	39 c6                	cmp    %eax,%esi
  801618:	73 24                	jae    80163e <devfile_read+0x59>
  80161a:	c7 44 24 0c 85 24 80 	movl   $0x802485,0xc(%esp)
  801621:	00 
  801622:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  801629:	00 
  80162a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801631:	00 
  801632:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  801639:	e8 16 eb ff ff       	call   800154 <_panic>
	assert(r <= PGSIZE);
  80163e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801643:	7e 24                	jle    801669 <devfile_read+0x84>
  801645:	c7 44 24 0c a1 24 80 	movl   $0x8024a1,0xc(%esp)
  80164c:	00 
  80164d:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  801654:	00 
  801655:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80165c:	00 
  80165d:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  801664:	e8 eb ea ff ff       	call   800154 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801669:	89 44 24 08          	mov    %eax,0x8(%esp)
  80166d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801674:	00 
  801675:	8b 45 0c             	mov    0xc(%ebp),%eax
  801678:	89 04 24             	mov    %eax,(%esp)
  80167b:	e8 f0 f2 ff ff       	call   800970 <memmove>
	return r;
}
  801680:	89 d8                	mov    %ebx,%eax
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	56                   	push   %esi
  80168d:	53                   	push   %ebx
  80168e:	83 ec 20             	sub    $0x20,%esp
  801691:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801694:	89 34 24             	mov    %esi,(%esp)
  801697:	e8 28 f1 ff ff       	call   8007c4 <strlen>
  80169c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016a1:	7f 60                	jg     801703 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	89 04 24             	mov    %eax,(%esp)
  8016a9:	e8 45 f8 ff ff       	call   800ef3 <fd_alloc>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 54                	js     801708 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016bf:	e8 33 f1 ff ff       	call   8007f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d4:	e8 df fd ff ff       	call   8014b8 <fsipc>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	79 15                	jns    8016f4 <open+0x6b>
		fd_close(fd, 0);
  8016df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016e6:	00 
  8016e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ea:	89 04 24             	mov    %eax,(%esp)
  8016ed:	e8 04 f9 ff ff       	call   800ff6 <fd_close>
		return r;
  8016f2:	eb 14                	jmp    801708 <open+0x7f>
	}

	return fd2num(fd);
  8016f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f7:	89 04 24             	mov    %eax,(%esp)
  8016fa:	e8 c9 f7 ff ff       	call   800ec8 <fd2num>
  8016ff:	89 c3                	mov    %eax,%ebx
  801701:	eb 05                	jmp    801708 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801703:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	83 c4 20             	add    $0x20,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801717:	ba 00 00 00 00       	mov    $0x0,%edx
  80171c:	b8 08 00 00 00       	mov    $0x8,%eax
  801721:	e8 92 fd ff ff       	call   8014b8 <fsipc>
}
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 10             	sub    $0x10,%esp
  801730:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801733:	8b 45 08             	mov    0x8(%ebp),%eax
  801736:	89 04 24             	mov    %eax,(%esp)
  801739:	e8 9a f7 ff ff       	call   800ed8 <fd2data>
  80173e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801740:	c7 44 24 04 ad 24 80 	movl   $0x8024ad,0x4(%esp)
  801747:	00 
  801748:	89 34 24             	mov    %esi,(%esp)
  80174b:	e8 a7 f0 ff ff       	call   8007f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801750:	8b 43 04             	mov    0x4(%ebx),%eax
  801753:	2b 03                	sub    (%ebx),%eax
  801755:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80175b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801762:	00 00 00 
	stat->st_dev = &devpipe;
  801765:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80176c:	30 80 00 
	return 0;
}
  80176f:	b8 00 00 00 00       	mov    $0x0,%eax
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	5b                   	pop    %ebx
  801778:	5e                   	pop    %esi
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 14             	sub    $0x14,%esp
  801782:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801785:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801789:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801790:	e8 fb f4 ff ff       	call   800c90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801795:	89 1c 24             	mov    %ebx,(%esp)
  801798:	e8 3b f7 ff ff       	call   800ed8 <fd2data>
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a8:	e8 e3 f4 ff ff       	call   800c90 <sys_page_unmap>
}
  8017ad:	83 c4 14             	add    $0x14,%esp
  8017b0:	5b                   	pop    %ebx
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	57                   	push   %edi
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 2c             	sub    $0x2c,%esp
  8017bc:	89 c7                	mov    %eax,%edi
  8017be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017c9:	89 3c 24             	mov    %edi,(%esp)
  8017cc:	e8 87 05 00 00       	call   801d58 <pageref>
  8017d1:	89 c6                	mov    %eax,%esi
  8017d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017d6:	89 04 24             	mov    %eax,(%esp)
  8017d9:	e8 7a 05 00 00       	call   801d58 <pageref>
  8017de:	39 c6                	cmp    %eax,%esi
  8017e0:	0f 94 c0             	sete   %al
  8017e3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8017e6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017ec:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017ef:	39 cb                	cmp    %ecx,%ebx
  8017f1:	75 08                	jne    8017fb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8017f3:	83 c4 2c             	add    $0x2c,%esp
  8017f6:	5b                   	pop    %ebx
  8017f7:	5e                   	pop    %esi
  8017f8:	5f                   	pop    %edi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8017fb:	83 f8 01             	cmp    $0x1,%eax
  8017fe:	75 c1                	jne    8017c1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801800:	8b 42 58             	mov    0x58(%edx),%eax
  801803:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80180a:	00 
  80180b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80180f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801813:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  80181a:	e8 2d ea ff ff       	call   80024c <cprintf>
  80181f:	eb a0                	jmp    8017c1 <_pipeisclosed+0xe>

00801821 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	57                   	push   %edi
  801825:	56                   	push   %esi
  801826:	53                   	push   %ebx
  801827:	83 ec 1c             	sub    $0x1c,%esp
  80182a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80182d:	89 34 24             	mov    %esi,(%esp)
  801830:	e8 a3 f6 ff ff       	call   800ed8 <fd2data>
  801835:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801837:	bf 00 00 00 00       	mov    $0x0,%edi
  80183c:	eb 3c                	jmp    80187a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80183e:	89 da                	mov    %ebx,%edx
  801840:	89 f0                	mov    %esi,%eax
  801842:	e8 6c ff ff ff       	call   8017b3 <_pipeisclosed>
  801847:	85 c0                	test   %eax,%eax
  801849:	75 38                	jne    801883 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80184b:	e8 7a f3 ff ff       	call   800bca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801850:	8b 43 04             	mov    0x4(%ebx),%eax
  801853:	8b 13                	mov    (%ebx),%edx
  801855:	83 c2 20             	add    $0x20,%edx
  801858:	39 d0                	cmp    %edx,%eax
  80185a:	73 e2                	jae    80183e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80185c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801862:	89 c2                	mov    %eax,%edx
  801864:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80186a:	79 05                	jns    801871 <devpipe_write+0x50>
  80186c:	4a                   	dec    %edx
  80186d:	83 ca e0             	or     $0xffffffe0,%edx
  801870:	42                   	inc    %edx
  801871:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801875:	40                   	inc    %eax
  801876:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801879:	47                   	inc    %edi
  80187a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80187d:	75 d1                	jne    801850 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80187f:	89 f8                	mov    %edi,%eax
  801881:	eb 05                	jmp    801888 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801883:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801888:	83 c4 1c             	add    $0x1c,%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5e                   	pop    %esi
  80188d:	5f                   	pop    %edi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	57                   	push   %edi
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	83 ec 1c             	sub    $0x1c,%esp
  801899:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80189c:	89 3c 24             	mov    %edi,(%esp)
  80189f:	e8 34 f6 ff ff       	call   800ed8 <fd2data>
  8018a4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a6:	be 00 00 00 00       	mov    $0x0,%esi
  8018ab:	eb 3a                	jmp    8018e7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018ad:	85 f6                	test   %esi,%esi
  8018af:	74 04                	je     8018b5 <devpipe_read+0x25>
				return i;
  8018b1:	89 f0                	mov    %esi,%eax
  8018b3:	eb 40                	jmp    8018f5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018b5:	89 da                	mov    %ebx,%edx
  8018b7:	89 f8                	mov    %edi,%eax
  8018b9:	e8 f5 fe ff ff       	call   8017b3 <_pipeisclosed>
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	75 2e                	jne    8018f0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018c2:	e8 03 f3 ff ff       	call   800bca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018c7:	8b 03                	mov    (%ebx),%eax
  8018c9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018cc:	74 df                	je     8018ad <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018ce:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018d3:	79 05                	jns    8018da <devpipe_read+0x4a>
  8018d5:	48                   	dec    %eax
  8018d6:	83 c8 e0             	or     $0xffffffe0,%eax
  8018d9:	40                   	inc    %eax
  8018da:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8018de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8018e4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e6:	46                   	inc    %esi
  8018e7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018ea:	75 db                	jne    8018c7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018ec:	89 f0                	mov    %esi,%eax
  8018ee:	eb 05                	jmp    8018f5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018f5:	83 c4 1c             	add    $0x1c,%esp
  8018f8:	5b                   	pop    %ebx
  8018f9:	5e                   	pop    %esi
  8018fa:	5f                   	pop    %edi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	57                   	push   %edi
  801901:	56                   	push   %esi
  801902:	53                   	push   %ebx
  801903:	83 ec 3c             	sub    $0x3c,%esp
  801906:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801909:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80190c:	89 04 24             	mov    %eax,(%esp)
  80190f:	e8 df f5 ff ff       	call   800ef3 <fd_alloc>
  801914:	89 c3                	mov    %eax,%ebx
  801916:	85 c0                	test   %eax,%eax
  801918:	0f 88 45 01 00 00    	js     801a63 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801925:	00 
  801926:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801934:	e8 b0 f2 ff ff       	call   800be9 <sys_page_alloc>
  801939:	89 c3                	mov    %eax,%ebx
  80193b:	85 c0                	test   %eax,%eax
  80193d:	0f 88 20 01 00 00    	js     801a63 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801943:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801946:	89 04 24             	mov    %eax,(%esp)
  801949:	e8 a5 f5 ff ff       	call   800ef3 <fd_alloc>
  80194e:	89 c3                	mov    %eax,%ebx
  801950:	85 c0                	test   %eax,%eax
  801952:	0f 88 f8 00 00 00    	js     801a50 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801958:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80195f:	00 
  801960:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801963:	89 44 24 04          	mov    %eax,0x4(%esp)
  801967:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196e:	e8 76 f2 ff ff       	call   800be9 <sys_page_alloc>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	85 c0                	test   %eax,%eax
  801977:	0f 88 d3 00 00 00    	js     801a50 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80197d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801980:	89 04 24             	mov    %eax,(%esp)
  801983:	e8 50 f5 ff ff       	call   800ed8 <fd2data>
  801988:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80198a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801991:	00 
  801992:	89 44 24 04          	mov    %eax,0x4(%esp)
  801996:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199d:	e8 47 f2 ff ff       	call   800be9 <sys_page_alloc>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	0f 88 91 00 00 00    	js     801a3d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019af:	89 04 24             	mov    %eax,(%esp)
  8019b2:	e8 21 f5 ff ff       	call   800ed8 <fd2data>
  8019b7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019be:	00 
  8019bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019ca:	00 
  8019cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d6:	e8 62 f2 ff ff       	call   800c3d <sys_page_map>
  8019db:	89 c3                	mov    %eax,%ebx
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	78 4c                	js     801a2d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019e1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ea:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019f6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019ff:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a01:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a04:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 b2 f4 ff ff       	call   800ec8 <fd2num>
  801a16:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a1b:	89 04 24             	mov    %eax,(%esp)
  801a1e:	e8 a5 f4 ff ff       	call   800ec8 <fd2num>
  801a23:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a26:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a2b:	eb 36                	jmp    801a63 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801a2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a38:	e8 53 f2 ff ff       	call   800c90 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801a3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a4b:	e8 40 f2 ff ff       	call   800c90 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801a50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a5e:	e8 2d f2 ff ff       	call   800c90 <sys_page_unmap>
    err:
	return r;
}
  801a63:	89 d8                	mov    %ebx,%eax
  801a65:	83 c4 3c             	add    $0x3c,%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5f                   	pop    %edi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	89 04 24             	mov    %eax,(%esp)
  801a80:	e8 c1 f4 ff ff       	call   800f46 <fd_lookup>
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 15                	js     801a9e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8c:	89 04 24             	mov    %eax,(%esp)
  801a8f:	e8 44 f4 ff ff       	call   800ed8 <fd2data>
	return _pipeisclosed(fd, p);
  801a94:	89 c2                	mov    %eax,%edx
  801a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a99:	e8 15 fd ff ff       	call   8017b3 <_pipeisclosed>
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801aa3:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ab0:	c7 44 24 04 cc 24 80 	movl   $0x8024cc,0x4(%esp)
  801ab7:	00 
  801ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abb:	89 04 24             	mov    %eax,(%esp)
  801abe:	e8 34 ed ff ff       	call   8007f7 <strcpy>
	return 0;
}
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	57                   	push   %edi
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
  801ad0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ad6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801adb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ae1:	eb 30                	jmp    801b13 <devcons_write+0x49>
		m = n - tot;
  801ae3:	8b 75 10             	mov    0x10(%ebp),%esi
  801ae6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801ae8:	83 fe 7f             	cmp    $0x7f,%esi
  801aeb:	76 05                	jbe    801af2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801aed:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801af2:	89 74 24 08          	mov    %esi,0x8(%esp)
  801af6:	03 45 0c             	add    0xc(%ebp),%eax
  801af9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afd:	89 3c 24             	mov    %edi,(%esp)
  801b00:	e8 6b ee ff ff       	call   800970 <memmove>
		sys_cputs(buf, m);
  801b05:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b09:	89 3c 24             	mov    %edi,(%esp)
  801b0c:	e8 0b f0 ff ff       	call   800b1c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b11:	01 f3                	add    %esi,%ebx
  801b13:	89 d8                	mov    %ebx,%eax
  801b15:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b18:	72 c9                	jb     801ae3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b1a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5f                   	pop    %edi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b2f:	75 07                	jne    801b38 <devcons_read+0x13>
  801b31:	eb 25                	jmp    801b58 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b33:	e8 92 f0 ff ff       	call   800bca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b38:	e8 fd ef ff ff       	call   800b3a <sys_cgetc>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	74 f2                	je     801b33 <devcons_read+0xe>
  801b41:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b43:	85 c0                	test   %eax,%eax
  801b45:	78 1d                	js     801b64 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b47:	83 f8 04             	cmp    $0x4,%eax
  801b4a:	74 13                	je     801b5f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4f:	88 10                	mov    %dl,(%eax)
	return 1;
  801b51:	b8 01 00 00 00       	mov    $0x1,%eax
  801b56:	eb 0c                	jmp    801b64 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5d:	eb 05                	jmp    801b64 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b5f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b72:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b79:	00 
  801b7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b7d:	89 04 24             	mov    %eax,(%esp)
  801b80:	e8 97 ef ff ff       	call   800b1c <sys_cputs>
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <getchar>:

int
getchar(void)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b8d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801b94:	00 
  801b95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba3:	e8 3a f6 ff ff       	call   8011e2 <read>
	if (r < 0)
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 0f                	js     801bbb <getchar+0x34>
		return r;
	if (r < 1)
  801bac:	85 c0                	test   %eax,%eax
  801bae:	7e 06                	jle    801bb6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801bb0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bb4:	eb 05                	jmp    801bbb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bb6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bca:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcd:	89 04 24             	mov    %eax,(%esp)
  801bd0:	e8 71 f3 ff ff       	call   800f46 <fd_lookup>
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 11                	js     801bea <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801be2:	39 10                	cmp    %edx,(%eax)
  801be4:	0f 94 c0             	sete   %al
  801be7:	0f b6 c0             	movzbl %al,%eax
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <opencons>:

int
opencons(void)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf5:	89 04 24             	mov    %eax,(%esp)
  801bf8:	e8 f6 f2 ff ff       	call   800ef3 <fd_alloc>
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 3c                	js     801c3d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c01:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c08:	00 
  801c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c17:	e8 cd ef ff ff       	call   800be9 <sys_page_alloc>
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	78 1d                	js     801c3d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c20:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c29:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 8b f2 ff ff       	call   800ec8 <fd2num>
}
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    
	...

00801c40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	57                   	push   %edi
  801c44:	56                   	push   %esi
  801c45:	53                   	push   %ebx
  801c46:	83 ec 1c             	sub    $0x1c,%esp
  801c49:	8b 75 08             	mov    0x8(%ebp),%esi
  801c4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c4f:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801c52:	85 db                	test   %ebx,%ebx
  801c54:	75 05                	jne    801c5b <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801c56:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801c5b:	89 1c 24             	mov    %ebx,(%esp)
  801c5e:	e8 9c f1 ff ff       	call   800dff <sys_ipc_recv>
  801c63:	85 c0                	test   %eax,%eax
  801c65:	79 16                	jns    801c7d <ipc_recv+0x3d>
		*from_env_store = 0;
  801c67:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801c6d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801c73:	89 1c 24             	mov    %ebx,(%esp)
  801c76:	e8 84 f1 ff ff       	call   800dff <sys_ipc_recv>
  801c7b:	eb 24                	jmp    801ca1 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801c7d:	85 f6                	test   %esi,%esi
  801c7f:	74 0a                	je     801c8b <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801c81:	a1 04 40 80 00       	mov    0x804004,%eax
  801c86:	8b 40 74             	mov    0x74(%eax),%eax
  801c89:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801c8b:	85 ff                	test   %edi,%edi
  801c8d:	74 0a                	je     801c99 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801c8f:	a1 04 40 80 00       	mov    0x804004,%eax
  801c94:	8b 40 78             	mov    0x78(%eax),%eax
  801c97:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801c99:	a1 04 40 80 00       	mov    0x804004,%eax
  801c9e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ca1:	83 c4 1c             	add    $0x1c,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5f                   	pop    %edi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	57                   	push   %edi
  801cad:	56                   	push   %esi
  801cae:	53                   	push   %ebx
  801caf:	83 ec 1c             	sub    $0x1c,%esp
  801cb2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cb8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801cbb:	85 db                	test   %ebx,%ebx
  801cbd:	75 05                	jne    801cc4 <ipc_send+0x1b>
		pg = (void *)-1;
  801cbf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801cc4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801cc8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ccc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	89 04 24             	mov    %eax,(%esp)
  801cd6:	e8 01 f1 ff ff       	call   800ddc <sys_ipc_try_send>
		if (r == 0) {		
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	74 2c                	je     801d0b <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801cdf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ce2:	75 07                	jne    801ceb <ipc_send+0x42>
			sys_yield();
  801ce4:	e8 e1 ee ff ff       	call   800bca <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801ce9:	eb d9                	jmp    801cc4 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801ceb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cef:	c7 44 24 08 d8 24 80 	movl   $0x8024d8,0x8(%esp)
  801cf6:	00 
  801cf7:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801cfe:	00 
  801cff:	c7 04 24 e6 24 80 00 	movl   $0x8024e6,(%esp)
  801d06:	e8 49 e4 ff ff       	call   800154 <_panic>
		}
	}
}
  801d0b:	83 c4 1c             	add    $0x1c,%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d1f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d26:	89 c2                	mov    %eax,%edx
  801d28:	c1 e2 07             	shl    $0x7,%edx
  801d2b:	29 ca                	sub    %ecx,%edx
  801d2d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d33:	8b 52 50             	mov    0x50(%edx),%edx
  801d36:	39 da                	cmp    %ebx,%edx
  801d38:	75 0f                	jne    801d49 <ipc_find_env+0x36>
			return envs[i].env_id;
  801d3a:	c1 e0 07             	shl    $0x7,%eax
  801d3d:	29 c8                	sub    %ecx,%eax
  801d3f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d44:	8b 40 40             	mov    0x40(%eax),%eax
  801d47:	eb 0c                	jmp    801d55 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d49:	40                   	inc    %eax
  801d4a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d4f:	75 ce                	jne    801d1f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d51:	66 b8 00 00          	mov    $0x0,%ax
}
  801d55:	5b                   	pop    %ebx
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d5e:	89 c2                	mov    %eax,%edx
  801d60:	c1 ea 16             	shr    $0x16,%edx
  801d63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d6a:	f6 c2 01             	test   $0x1,%dl
  801d6d:	74 1e                	je     801d8d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d6f:	c1 e8 0c             	shr    $0xc,%eax
  801d72:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d79:	a8 01                	test   $0x1,%al
  801d7b:	74 17                	je     801d94 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d7d:	c1 e8 0c             	shr    $0xc,%eax
  801d80:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d87:	ef 
  801d88:	0f b7 c0             	movzwl %ax,%eax
  801d8b:	eb 0c                	jmp    801d99 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d92:	eb 05                	jmp    801d99 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    
	...

00801d9c <__udivdi3>:
  801d9c:	55                   	push   %ebp
  801d9d:	57                   	push   %edi
  801d9e:	56                   	push   %esi
  801d9f:	83 ec 10             	sub    $0x10,%esp
  801da2:	8b 74 24 20          	mov    0x20(%esp),%esi
  801da6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801daa:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801db2:	89 cd                	mov    %ecx,%ebp
  801db4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801db8:	85 c0                	test   %eax,%eax
  801dba:	75 2c                	jne    801de8 <__udivdi3+0x4c>
  801dbc:	39 f9                	cmp    %edi,%ecx
  801dbe:	77 68                	ja     801e28 <__udivdi3+0x8c>
  801dc0:	85 c9                	test   %ecx,%ecx
  801dc2:	75 0b                	jne    801dcf <__udivdi3+0x33>
  801dc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc9:	31 d2                	xor    %edx,%edx
  801dcb:	f7 f1                	div    %ecx
  801dcd:	89 c1                	mov    %eax,%ecx
  801dcf:	31 d2                	xor    %edx,%edx
  801dd1:	89 f8                	mov    %edi,%eax
  801dd3:	f7 f1                	div    %ecx
  801dd5:	89 c7                	mov    %eax,%edi
  801dd7:	89 f0                	mov    %esi,%eax
  801dd9:	f7 f1                	div    %ecx
  801ddb:	89 c6                	mov    %eax,%esi
  801ddd:	89 f0                	mov    %esi,%eax
  801ddf:	89 fa                	mov    %edi,%edx
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    
  801de8:	39 f8                	cmp    %edi,%eax
  801dea:	77 2c                	ja     801e18 <__udivdi3+0x7c>
  801dec:	0f bd f0             	bsr    %eax,%esi
  801def:	83 f6 1f             	xor    $0x1f,%esi
  801df2:	75 4c                	jne    801e40 <__udivdi3+0xa4>
  801df4:	39 f8                	cmp    %edi,%eax
  801df6:	bf 00 00 00 00       	mov    $0x0,%edi
  801dfb:	72 0a                	jb     801e07 <__udivdi3+0x6b>
  801dfd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e01:	0f 87 ad 00 00 00    	ja     801eb4 <__udivdi3+0x118>
  801e07:	be 01 00 00 00       	mov    $0x1,%esi
  801e0c:	89 f0                	mov    %esi,%eax
  801e0e:	89 fa                	mov    %edi,%edx
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	5e                   	pop    %esi
  801e14:	5f                   	pop    %edi
  801e15:	5d                   	pop    %ebp
  801e16:	c3                   	ret    
  801e17:	90                   	nop
  801e18:	31 ff                	xor    %edi,%edi
  801e1a:	31 f6                	xor    %esi,%esi
  801e1c:	89 f0                	mov    %esi,%eax
  801e1e:	89 fa                	mov    %edi,%edx
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	5e                   	pop    %esi
  801e24:	5f                   	pop    %edi
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    
  801e27:	90                   	nop
  801e28:	89 fa                	mov    %edi,%edx
  801e2a:	89 f0                	mov    %esi,%eax
  801e2c:	f7 f1                	div    %ecx
  801e2e:	89 c6                	mov    %eax,%esi
  801e30:	31 ff                	xor    %edi,%edi
  801e32:	89 f0                	mov    %esi,%eax
  801e34:	89 fa                	mov    %edi,%edx
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	89 f1                	mov    %esi,%ecx
  801e42:	d3 e0                	shl    %cl,%eax
  801e44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e48:	b8 20 00 00 00       	mov    $0x20,%eax
  801e4d:	29 f0                	sub    %esi,%eax
  801e4f:	89 ea                	mov    %ebp,%edx
  801e51:	88 c1                	mov    %al,%cl
  801e53:	d3 ea                	shr    %cl,%edx
  801e55:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e59:	09 ca                	or     %ecx,%edx
  801e5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e5f:	89 f1                	mov    %esi,%ecx
  801e61:	d3 e5                	shl    %cl,%ebp
  801e63:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801e67:	89 fd                	mov    %edi,%ebp
  801e69:	88 c1                	mov    %al,%cl
  801e6b:	d3 ed                	shr    %cl,%ebp
  801e6d:	89 fa                	mov    %edi,%edx
  801e6f:	89 f1                	mov    %esi,%ecx
  801e71:	d3 e2                	shl    %cl,%edx
  801e73:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e77:	88 c1                	mov    %al,%cl
  801e79:	d3 ef                	shr    %cl,%edi
  801e7b:	09 d7                	or     %edx,%edi
  801e7d:	89 f8                	mov    %edi,%eax
  801e7f:	89 ea                	mov    %ebp,%edx
  801e81:	f7 74 24 08          	divl   0x8(%esp)
  801e85:	89 d1                	mov    %edx,%ecx
  801e87:	89 c7                	mov    %eax,%edi
  801e89:	f7 64 24 0c          	mull   0xc(%esp)
  801e8d:	39 d1                	cmp    %edx,%ecx
  801e8f:	72 17                	jb     801ea8 <__udivdi3+0x10c>
  801e91:	74 09                	je     801e9c <__udivdi3+0x100>
  801e93:	89 fe                	mov    %edi,%esi
  801e95:	31 ff                	xor    %edi,%edi
  801e97:	e9 41 ff ff ff       	jmp    801ddd <__udivdi3+0x41>
  801e9c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ea0:	89 f1                	mov    %esi,%ecx
  801ea2:	d3 e2                	shl    %cl,%edx
  801ea4:	39 c2                	cmp    %eax,%edx
  801ea6:	73 eb                	jae    801e93 <__udivdi3+0xf7>
  801ea8:	8d 77 ff             	lea    -0x1(%edi),%esi
  801eab:	31 ff                	xor    %edi,%edi
  801ead:	e9 2b ff ff ff       	jmp    801ddd <__udivdi3+0x41>
  801eb2:	66 90                	xchg   %ax,%ax
  801eb4:	31 f6                	xor    %esi,%esi
  801eb6:	e9 22 ff ff ff       	jmp    801ddd <__udivdi3+0x41>
	...

00801ebc <__umoddi3>:
  801ebc:	55                   	push   %ebp
  801ebd:	57                   	push   %edi
  801ebe:	56                   	push   %esi
  801ebf:	83 ec 20             	sub    $0x20,%esp
  801ec2:	8b 44 24 30          	mov    0x30(%esp),%eax
  801ec6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801eca:	89 44 24 14          	mov    %eax,0x14(%esp)
  801ece:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ed2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ed6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801eda:	89 c7                	mov    %eax,%edi
  801edc:	89 f2                	mov    %esi,%edx
  801ede:	85 ed                	test   %ebp,%ebp
  801ee0:	75 16                	jne    801ef8 <__umoddi3+0x3c>
  801ee2:	39 f1                	cmp    %esi,%ecx
  801ee4:	0f 86 a6 00 00 00    	jbe    801f90 <__umoddi3+0xd4>
  801eea:	f7 f1                	div    %ecx
  801eec:	89 d0                	mov    %edx,%eax
  801eee:	31 d2                	xor    %edx,%edx
  801ef0:	83 c4 20             	add    $0x20,%esp
  801ef3:	5e                   	pop    %esi
  801ef4:	5f                   	pop    %edi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    
  801ef7:	90                   	nop
  801ef8:	39 f5                	cmp    %esi,%ebp
  801efa:	0f 87 ac 00 00 00    	ja     801fac <__umoddi3+0xf0>
  801f00:	0f bd c5             	bsr    %ebp,%eax
  801f03:	83 f0 1f             	xor    $0x1f,%eax
  801f06:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f0a:	0f 84 a8 00 00 00    	je     801fb8 <__umoddi3+0xfc>
  801f10:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f14:	d3 e5                	shl    %cl,%ebp
  801f16:	bf 20 00 00 00       	mov    $0x20,%edi
  801f1b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801f1f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f23:	89 f9                	mov    %edi,%ecx
  801f25:	d3 e8                	shr    %cl,%eax
  801f27:	09 e8                	or     %ebp,%eax
  801f29:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f2d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f31:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f35:	d3 e0                	shl    %cl,%eax
  801f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3b:	89 f2                	mov    %esi,%edx
  801f3d:	d3 e2                	shl    %cl,%edx
  801f3f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f43:	d3 e0                	shl    %cl,%eax
  801f45:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801f49:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f4d:	89 f9                	mov    %edi,%ecx
  801f4f:	d3 e8                	shr    %cl,%eax
  801f51:	09 d0                	or     %edx,%eax
  801f53:	d3 ee                	shr    %cl,%esi
  801f55:	89 f2                	mov    %esi,%edx
  801f57:	f7 74 24 18          	divl   0x18(%esp)
  801f5b:	89 d6                	mov    %edx,%esi
  801f5d:	f7 64 24 0c          	mull   0xc(%esp)
  801f61:	89 c5                	mov    %eax,%ebp
  801f63:	89 d1                	mov    %edx,%ecx
  801f65:	39 d6                	cmp    %edx,%esi
  801f67:	72 67                	jb     801fd0 <__umoddi3+0x114>
  801f69:	74 75                	je     801fe0 <__umoddi3+0x124>
  801f6b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f6f:	29 e8                	sub    %ebp,%eax
  801f71:	19 ce                	sbb    %ecx,%esi
  801f73:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f77:	d3 e8                	shr    %cl,%eax
  801f79:	89 f2                	mov    %esi,%edx
  801f7b:	89 f9                	mov    %edi,%ecx
  801f7d:	d3 e2                	shl    %cl,%edx
  801f7f:	09 d0                	or     %edx,%eax
  801f81:	89 f2                	mov    %esi,%edx
  801f83:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f87:	d3 ea                	shr    %cl,%edx
  801f89:	83 c4 20             	add    $0x20,%esp
  801f8c:	5e                   	pop    %esi
  801f8d:	5f                   	pop    %edi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    
  801f90:	85 c9                	test   %ecx,%ecx
  801f92:	75 0b                	jne    801f9f <__umoddi3+0xe3>
  801f94:	b8 01 00 00 00       	mov    $0x1,%eax
  801f99:	31 d2                	xor    %edx,%edx
  801f9b:	f7 f1                	div    %ecx
  801f9d:	89 c1                	mov    %eax,%ecx
  801f9f:	89 f0                	mov    %esi,%eax
  801fa1:	31 d2                	xor    %edx,%edx
  801fa3:	f7 f1                	div    %ecx
  801fa5:	89 f8                	mov    %edi,%eax
  801fa7:	e9 3e ff ff ff       	jmp    801eea <__umoddi3+0x2e>
  801fac:	89 f2                	mov    %esi,%edx
  801fae:	83 c4 20             	add    $0x20,%esp
  801fb1:	5e                   	pop    %esi
  801fb2:	5f                   	pop    %edi
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    
  801fb5:	8d 76 00             	lea    0x0(%esi),%esi
  801fb8:	39 f5                	cmp    %esi,%ebp
  801fba:	72 04                	jb     801fc0 <__umoddi3+0x104>
  801fbc:	39 f9                	cmp    %edi,%ecx
  801fbe:	77 06                	ja     801fc6 <__umoddi3+0x10a>
  801fc0:	89 f2                	mov    %esi,%edx
  801fc2:	29 cf                	sub    %ecx,%edi
  801fc4:	19 ea                	sbb    %ebp,%edx
  801fc6:	89 f8                	mov    %edi,%eax
  801fc8:	83 c4 20             	add    $0x20,%esp
  801fcb:	5e                   	pop    %esi
  801fcc:	5f                   	pop    %edi
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    
  801fcf:	90                   	nop
  801fd0:	89 d1                	mov    %edx,%ecx
  801fd2:	89 c5                	mov    %eax,%ebp
  801fd4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801fd8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801fdc:	eb 8d                	jmp    801f6b <__umoddi3+0xaf>
  801fde:	66 90                	xchg   %ax,%ax
  801fe0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801fe4:	72 ea                	jb     801fd0 <__umoddi3+0x114>
  801fe6:	89 f1                	mov    %esi,%ecx
  801fe8:	eb 81                	jmp    801f6b <__umoddi3+0xaf>
