
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  80004b:	e8 10 02 00 00       	call   800260 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 8e 0b 00 00       	call   800bfd <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 0a 20 80 00 	movl   $0x80200a,(%esp)
  800092:	e8 d1 00 00 00       	call   800168 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 4c 20 80 	movl   $0x80204c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 fa 06 00 00       	call   8007ad <snprintf>
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
  8000c6:	e8 9d 0d 00 00       	call   800e68 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 1c 20 80 00 	movl   $0x80201c,(%esp)
  8000da:	e8 81 01 00 00       	call   800260 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 1c 20 80 00 	movl   $0x80201c,(%esp)
  8000ee:	e8 6d 01 00 00       	call   800260 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800106:	e8 b4 0a 00 00       	call   800bbf <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x39>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800135:	89 34 24             	mov    %esi,(%esp)
  800138:	e8 7c ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800152:	e8 6c 0f 00 00       	call   8010c3 <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 0a 0a 00 00       	call   800b6d <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800170:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800173:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800179:	e8 41 0a 00 00       	call   800bbf <sys_getenvid>
  80017e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800181:	89 54 24 10          	mov    %edx,0x10(%esp)
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80018c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 78 20 80 00 	movl   $0x802078,(%esp)
  80019b:	e8 c0 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 50 00 00 00       	call   8001ff <vcprintf>
	cprintf("\n");
  8001af:	c7 04 24 c5 24 80 00 	movl   $0x8024c5,(%esp)
  8001b6:	e8 a5 00 00 00       	call   800260 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bb:	cc                   	int3   
  8001bc:	eb fd                	jmp    8001bb <_panic+0x53>
	...

008001c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 14             	sub    $0x14,%esp
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ca:	8b 03                	mov    (%ebx),%eax
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d3:	40                   	inc    %eax
  8001d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	75 19                	jne    8001f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e4:	00 
  8001e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 40 09 00 00       	call   800b30 <sys_cputs>
		b->idx = 0;
  8001f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f6:	ff 43 04             	incl   0x4(%ebx)
}
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800208:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020f:	00 00 00 
	b.cnt = 0;
  800212:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800219:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	c7 04 24 c0 01 80 00 	movl   $0x8001c0,(%esp)
  80023b:	e8 82 01 00 00       	call   8003c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800240:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 d8 08 00 00       	call   800b30 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 87 ff ff ff       	call   8001ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    
	...

0080027c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 3c             	sub    $0x3c,%esp
  800285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800288:	89 d7                	mov    %edx,%edi
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029c:	85 c0                	test   %eax,%eax
  80029e:	75 08                	jne    8002a8 <printnum+0x2c>
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a6:	77 57                	ja     8002ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ac:	4b                   	dec    %ebx
  8002ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c7:	00 
  8002c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	e8 d6 1a 00 00       	call   801db0 <__udivdi3>
  8002da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	89 fa                	mov    %edi,%edx
  8002eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ee:	e8 89 ff ff ff       	call   80027c <printnum>
  8002f3:	eb 0f                	jmp    800304 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ff:	4b                   	dec    %ebx
  800300:	85 db                	test   %ebx,%ebx
  800302:	7f f1                	jg     8002f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800304:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800308:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031a:	00 
  80031b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	e8 a3 1b 00 00       	call   801ed0 <__umoddi3>
  80032d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800331:	0f be 80 9b 20 80 00 	movsbl 0x80209b(%eax),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033e:	83 c4 3c             	add    $0x3c,%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800386:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 08                	jae    800398 <sprintputch+0x18>
		*b->buf++ = ch;
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	88 0a                	mov    %cl,(%edx)
  800395:	42                   	inc    %edx
  800396:	89 10                	mov    %edx,(%eax)
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 02 00 00 00       	call   8003c2 <vprintfmt>
	va_end(ap);
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    

008003c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	57                   	push   %edi
  8003c6:	56                   	push   %esi
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 4c             	sub    $0x4c,%esp
  8003cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d1:	eb 12                	jmp    8003e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	0f 84 6b 03 00 00    	je     800746 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	0f b6 06             	movzbl (%esi),%eax
  8003e8:	46                   	inc    %esi
  8003e9:	83 f8 25             	cmp    $0x25,%eax
  8003ec:	75 e5                	jne    8003d3 <vprintfmt+0x11>
  8003ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800405:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040a:	eb 26                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800413:	eb 1d                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800418:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80041c:	eb 14                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800421:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800428:	eb 08                	jmp    800432 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80042d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	0f b6 06             	movzbl (%esi),%eax
  800435:	8d 56 01             	lea    0x1(%esi),%edx
  800438:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043b:	8a 16                	mov    (%esi),%dl
  80043d:	83 ea 23             	sub    $0x23,%edx
  800440:	80 fa 55             	cmp    $0x55,%dl
  800443:	0f 87 e1 02 00 00    	ja     80072a <vprintfmt+0x368>
  800449:	0f b6 d2             	movzbl %dl,%edx
  80044c:	ff 24 95 e0 21 80 00 	jmp    *0x8021e0(,%edx,4)
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800456:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80045e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800462:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800465:	8d 50 d0             	lea    -0x30(%eax),%edx
  800468:	83 fa 09             	cmp    $0x9,%edx
  80046b:	77 2a                	ja     800497 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046e:	eb eb                	jmp    80045b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047e:	eb 17                	jmp    800497 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800480:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800484:	78 98                	js     80041e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800489:	eb a7                	jmp    800432 <vprintfmt+0x70>
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800495:	eb 9b                	jmp    800432 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049b:	79 95                	jns    800432 <vprintfmt+0x70>
  80049d:	eb 8b                	jmp    80042a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a3:	eb 8d                	jmp    800432 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004bd:	e9 23 ff ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	79 02                	jns    8004d3 <vprintfmt+0x111>
  8004d1:	f7 d8                	neg    %eax
  8004d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 0f             	cmp    $0xf,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x123>
  8004da:	8b 04 85 40 23 80 00 	mov    0x802340(,%eax,4),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	75 23                	jne    800508 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e9:	c7 44 24 08 b3 20 80 	movl   $0x8020b3,0x8(%esp)
  8004f0:	00 
  8004f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 9a fe ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800503:	e9 dd fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800508:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050c:	c7 44 24 08 9e 24 80 	movl   $0x80249e,0x8(%esp)
  800513:	00 
  800514:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800518:	8b 55 08             	mov    0x8(%ebp),%edx
  80051b:	89 14 24             	mov    %edx,(%esp)
  80051e:	e8 77 fe ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800526:	e9 ba fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
  80052b:	89 f9                	mov    %edi,%ecx
  80052d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800530:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 30                	mov    (%eax),%esi
  80053e:	85 f6                	test   %esi,%esi
  800540:	75 05                	jne    800547 <vprintfmt+0x185>
				p = "(null)";
  800542:	be ac 20 80 00       	mov    $0x8020ac,%esi
			if (width > 0 && padc != '-')
  800547:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054b:	0f 8e 84 00 00 00    	jle    8005d5 <vprintfmt+0x213>
  800551:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800555:	74 7e                	je     8005d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055b:	89 34 24             	mov    %esi,(%esp)
  80055e:	e8 8b 02 00 00       	call   8007ee <strnlen>
  800563:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80056f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800572:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800575:	89 de                	mov    %ebx,%esi
  800577:	89 d3                	mov    %edx,%ebx
  800579:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	eb 0b                	jmp    800588 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80057d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800581:	89 3c 24             	mov    %edi,(%esp)
  800584:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	4b                   	dec    %ebx
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f f1                	jg     80057d <vprintfmt+0x1bb>
  80058c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058f:	89 f3                	mov    %esi,%ebx
  800591:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	79 05                	jns    8005a0 <vprintfmt+0x1de>
  80059b:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a3:	29 c2                	sub    %eax,%edx
  8005a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a8:	eb 2b                	jmp    8005d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ae:	74 18                	je     8005c8 <vprintfmt+0x206>
  8005b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b3:	83 fa 5e             	cmp    $0x5e,%edx
  8005b6:	76 10                	jbe    8005c8 <vprintfmt+0x206>
					putch('?', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
  8005c6:	eb 0a                	jmp    8005d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	89 04 24             	mov    %eax,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d5:	0f be 06             	movsbl (%esi),%eax
  8005d8:	46                   	inc    %esi
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	74 21                	je     8005fe <vprintfmt+0x23c>
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	78 c9                	js     8005aa <vprintfmt+0x1e8>
  8005e1:	4f                   	dec    %edi
  8005e2:	79 c6                	jns    8005aa <vprintfmt+0x1e8>
  8005e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e7:	89 de                	mov    %ebx,%esi
  8005e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ec:	eb 18                	jmp    800606 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fb:	4b                   	dec    %ebx
  8005fc:	eb 08                	jmp    800606 <vprintfmt+0x244>
  8005fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800601:	89 de                	mov    %ebx,%esi
  800603:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800606:	85 db                	test   %ebx,%ebx
  800608:	7f e4                	jg     8005ee <vprintfmt+0x22c>
  80060a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80060d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800612:	e9 ce fd ff ff       	jmp    8003e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800617:	83 f9 01             	cmp    $0x1,%ecx
  80061a:	7e 10                	jle    80062c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 08             	lea    0x8(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 30                	mov    (%eax),%esi
  800627:	8b 78 04             	mov    0x4(%eax),%edi
  80062a:	eb 26                	jmp    800652 <vprintfmt+0x290>
	else if (lflag)
  80062c:	85 c9                	test   %ecx,%ecx
  80062e:	74 12                	je     800642 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	8b 30                	mov    (%eax),%esi
  80063b:	89 f7                	mov    %esi,%edi
  80063d:	c1 ff 1f             	sar    $0x1f,%edi
  800640:	eb 10                	jmp    800652 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 30                	mov    (%eax),%esi
  80064d:	89 f7                	mov    %esi,%edi
  80064f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800652:	85 ff                	test   %edi,%edi
  800654:	78 0a                	js     800660 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 8c 00 00 00       	jmp    8006ec <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800664:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066e:	f7 de                	neg    %esi
  800670:	83 d7 00             	adc    $0x0,%edi
  800673:	f7 df                	neg    %edi
			}
			base = 10;
  800675:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067a:	eb 70                	jmp    8006ec <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067c:	89 ca                	mov    %ecx,%edx
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 c0 fc ff ff       	call   800346 <getuint>
  800686:	89 c6                	mov    %eax,%esi
  800688:	89 d7                	mov    %edx,%edi
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068f:	eb 5b                	jmp    8006ec <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800691:	89 ca                	mov    %ecx,%edx
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 ab fc ff ff       	call   800346 <getuint>
  80069b:	89 c6                	mov    %eax,%esi
  80069d:	89 d7                	mov    %edx,%edi
			base = 8;
  80069f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a4:	eb 46                	jmp    8006ec <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 04             	lea    0x4(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cb:	8b 30                	mov    (%eax),%esi
  8006cd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d7:	eb 13                	jmp    8006ec <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d9:	89 ca                	mov    %ecx,%edx
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	e8 63 fc ff ff       	call   800346 <getuint>
  8006e3:	89 c6                	mov    %eax,%esi
  8006e5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ec:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ff:	89 34 24             	mov    %esi,(%esp)
  800702:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800706:	89 da                	mov    %ebx,%edx
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	e8 6c fb ff ff       	call   80027c <printnum>
			break;
  800710:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800713:	e9 cd fc ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800718:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800725:	e9 bb fc ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	eb 01                	jmp    80073b <vprintfmt+0x379>
  80073a:	4e                   	dec    %esi
  80073b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80073f:	75 f9                	jne    80073a <vprintfmt+0x378>
  800741:	e9 9f fc ff ff       	jmp    8003e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800746:	83 c4 4c             	add    $0x4c,%esp
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 28             	sub    $0x28,%esp
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800761:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800764:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076b:	85 c0                	test   %eax,%eax
  80076d:	74 30                	je     80079f <vsnprintf+0x51>
  80076f:	85 d2                	test   %edx,%edx
  800771:	7e 33                	jle    8007a6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077a:	8b 45 10             	mov    0x10(%ebp),%eax
  80077d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800781:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	c7 04 24 80 03 80 00 	movl   $0x800380,(%esp)
  80078f:	e8 2e fc ff ff       	call   8003c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079d:	eb 0c                	jmp    8007ab <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb 05                	jmp    8007ab <vsnprintf+0x5d>
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	e8 7b ff ff ff       	call   80074e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    
  8007d5:	00 00                	add    %al,(%eax)
	...

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 01                	jmp    8007e6 <strlen+0xe>
		n++;
  8007e5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ea:	75 f9                	jne    8007e5 <strlen+0xd>
		n++;
	return n;
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb 01                	jmp    8007ff <strnlen+0x11>
		n++;
  8007fe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	39 d0                	cmp    %edx,%eax
  800801:	74 06                	je     800809 <strnlen+0x1b>
  800803:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800807:	75 f5                	jne    8007fe <strnlen+0x10>
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800815:	ba 00 00 00 00       	mov    $0x0,%edx
  80081a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80081d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800820:	42                   	inc    %edx
  800821:	84 c9                	test   %cl,%cl
  800823:	75 f5                	jne    80081a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800825:	5b                   	pop    %ebx
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800832:	89 1c 24             	mov    %ebx,(%esp)
  800835:	e8 9e ff ff ff       	call   8007d8 <strlen>
	strcpy(dst + len, src);
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800841:	01 d8                	add    %ebx,%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 c0 ff ff ff       	call   80080b <strcpy>
	return dst;
}
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	83 c4 08             	add    $0x8,%esp
  800850:	5b                   	pop    %ebx
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	b9 00 00 00 00       	mov    $0x0,%ecx
  800866:	eb 0c                	jmp    800874 <strncpy+0x21>
		*dst++ = *src;
  800868:	8a 1a                	mov    (%edx),%bl
  80086a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086d:	80 3a 01             	cmpb   $0x1,(%edx)
  800870:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800873:	41                   	inc    %ecx
  800874:	39 f1                	cmp    %esi,%ecx
  800876:	75 f0                	jne    800868 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800887:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088a:	85 d2                	test   %edx,%edx
  80088c:	75 0a                	jne    800898 <strlcpy+0x1c>
  80088e:	89 f0                	mov    %esi,%eax
  800890:	eb 1a                	jmp    8008ac <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800892:	88 18                	mov    %bl,(%eax)
  800894:	40                   	inc    %eax
  800895:	41                   	inc    %ecx
  800896:	eb 02                	jmp    80089a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800898:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089a:	4a                   	dec    %edx
  80089b:	74 0a                	je     8008a7 <strlcpy+0x2b>
  80089d:	8a 19                	mov    (%ecx),%bl
  80089f:	84 db                	test   %bl,%bl
  8008a1:	75 ef                	jne    800892 <strlcpy+0x16>
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	eb 02                	jmp    8008a9 <strlcpy+0x2d>
  8008a7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008ac:	29 f0                	sub    %esi,%eax
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bb:	eb 02                	jmp    8008bf <strcmp+0xd>
		p++, q++;
  8008bd:	41                   	inc    %ecx
  8008be:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bf:	8a 01                	mov    (%ecx),%al
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 04                	je     8008c9 <strcmp+0x17>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	74 f4                	je     8008bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 c0             	movzbl %al,%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e0:	eb 03                	jmp    8008e5 <strncmp+0x12>
		n--, p++, q++;
  8008e2:	4a                   	dec    %edx
  8008e3:	40                   	inc    %eax
  8008e4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	74 14                	je     8008fd <strncmp+0x2a>
  8008e9:	8a 18                	mov    (%eax),%bl
  8008eb:	84 db                	test   %bl,%bl
  8008ed:	74 04                	je     8008f3 <strncmp+0x20>
  8008ef:	3a 19                	cmp    (%ecx),%bl
  8008f1:	74 ef                	je     8008e2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f3:	0f b6 00             	movzbl (%eax),%eax
  8008f6:	0f b6 11             	movzbl (%ecx),%edx
  8008f9:	29 d0                	sub    %edx,%eax
  8008fb:	eb 05                	jmp    800902 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090e:	eb 05                	jmp    800915 <strchr+0x10>
		if (*s == c)
  800910:	38 ca                	cmp    %cl,%dl
  800912:	74 0c                	je     800920 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800914:	40                   	inc    %eax
  800915:	8a 10                	mov    (%eax),%dl
  800917:	84 d2                	test   %dl,%dl
  800919:	75 f5                	jne    800910 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092b:	eb 05                	jmp    800932 <strfind+0x10>
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 07                	je     800938 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800931:	40                   	inc    %eax
  800932:	8a 10                	mov    (%eax),%dl
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f5                	jne    80092d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800949:	85 c9                	test   %ecx,%ecx
  80094b:	74 30                	je     80097d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 25                	jne    80097a <memset+0x40>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 20                	jne    80097a <memset+0x40>
		c &= 0xFF;
  80095a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095d:	89 d3                	mov    %edx,%ebx
  80095f:	c1 e3 08             	shl    $0x8,%ebx
  800962:	89 d6                	mov    %edx,%esi
  800964:	c1 e6 18             	shl    $0x18,%esi
  800967:	89 d0                	mov    %edx,%eax
  800969:	c1 e0 10             	shl    $0x10,%eax
  80096c:	09 f0                	or     %esi,%eax
  80096e:	09 d0                	or     %edx,%eax
  800970:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800972:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 03                	jmp    80097d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 34                	jae    8009ca <memmove+0x46>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2d                	jae    8009ca <memmove+0x46>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	f6 c2 03             	test   $0x3,%dl
  8009a3:	75 1b                	jne    8009c0 <memmove+0x3c>
  8009a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ab:	75 13                	jne    8009c0 <memmove+0x3c>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 0e                	jne    8009c0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b2:	83 ef 04             	sub    $0x4,%edi
  8009b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 07                	jmp    8009c7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c0:	4f                   	dec    %edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 20                	jmp    8009ea <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d0:	75 13                	jne    8009e5 <memmove+0x61>
  8009d2:	a8 03                	test   $0x3,%al
  8009d4:	75 0f                	jne    8009e5 <memmove+0x61>
  8009d6:	f6 c1 03             	test   $0x3,%cl
  8009d9:	75 0a                	jne    8009e5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009db:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e3:	eb 05                	jmp    8009ea <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 77 ff ff ff       	call   800984 <memmove>
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	eb 16                	jmp    800a3b <memcmp+0x2c>
		if (*s1 != *s2)
  800a25:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a28:	42                   	inc    %edx
  800a29:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a2d:	38 c8                	cmp    %cl,%al
  800a2f:	74 0a                	je     800a3b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a31:	0f b6 c0             	movzbl %al,%eax
  800a34:	0f b6 c9             	movzbl %cl,%ecx
  800a37:	29 c8                	sub    %ecx,%eax
  800a39:	eb 09                	jmp    800a44 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3b:	39 da                	cmp    %ebx,%edx
  800a3d:	75 e6                	jne    800a25 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a57:	eb 05                	jmp    800a5e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a59:	38 08                	cmp    %cl,(%eax)
  800a5b:	74 05                	je     800a62 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5d:	40                   	inc    %eax
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	72 f7                	jb     800a59 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a70:	eb 01                	jmp    800a73 <strtol+0xf>
		s++;
  800a72:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a73:	8a 02                	mov    (%edx),%al
  800a75:	3c 20                	cmp    $0x20,%al
  800a77:	74 f9                	je     800a72 <strtol+0xe>
  800a79:	3c 09                	cmp    $0x9,%al
  800a7b:	74 f5                	je     800a72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7d:	3c 2b                	cmp    $0x2b,%al
  800a7f:	75 08                	jne    800a89 <strtol+0x25>
		s++;
  800a81:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
  800a87:	eb 13                	jmp    800a9c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a89:	3c 2d                	cmp    $0x2d,%al
  800a8b:	75 0a                	jne    800a97 <strtol+0x33>
		s++, neg = 1;
  800a8d:	8d 52 01             	lea    0x1(%edx),%edx
  800a90:	bf 01 00 00 00       	mov    $0x1,%edi
  800a95:	eb 05                	jmp    800a9c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	74 05                	je     800aa5 <strtol+0x41>
  800aa0:	83 fb 10             	cmp    $0x10,%ebx
  800aa3:	75 28                	jne    800acd <strtol+0x69>
  800aa5:	8a 02                	mov    (%edx),%al
  800aa7:	3c 30                	cmp    $0x30,%al
  800aa9:	75 10                	jne    800abb <strtol+0x57>
  800aab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aaf:	75 0a                	jne    800abb <strtol+0x57>
		s += 2, base = 16;
  800ab1:	83 c2 02             	add    $0x2,%edx
  800ab4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab9:	eb 12                	jmp    800acd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	75 0e                	jne    800acd <strtol+0x69>
  800abf:	3c 30                	cmp    $0x30,%al
  800ac1:	75 05                	jne    800ac8 <strtol+0x64>
		s++, base = 8;
  800ac3:	42                   	inc    %edx
  800ac4:	b3 08                	mov    $0x8,%bl
  800ac6:	eb 05                	jmp    800acd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad4:	8a 0a                	mov    (%edx),%cl
  800ad6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x82>
			dig = *s - '0';
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 30             	sub    $0x30,%ecx
  800ae4:	eb 1e                	jmp    800b04 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 57             	sub    $0x57,%ecx
  800af4:	eb 0e                	jmp    800b04 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 12                	ja     800b10 <strtol+0xac>
			dig = *s - 'A' + 10;
  800afe:	0f be c9             	movsbl %cl,%ecx
  800b01:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b04:	39 f1                	cmp    %esi,%ecx
  800b06:	7d 0c                	jge    800b14 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b08:	42                   	inc    %edx
  800b09:	0f af c6             	imul   %esi,%eax
  800b0c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b0e:	eb c4                	jmp    800ad4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b10:	89 c1                	mov    %eax,%ecx
  800b12:	eb 02                	jmp    800b16 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b14:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 05                	je     800b21 <strtol+0xbd>
		*endptr = (char *) s;
  800b1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b21:	85 ff                	test   %edi,%edi
  800b23:	74 04                	je     800b29 <strtol+0xc5>
  800b25:	89 c8                	mov    %ecx,%eax
  800b27:	f7 d8                	neg    %eax
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    
	...

00800b30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	89 c6                	mov    %eax,%esi
  800b47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	89 cb                	mov    %ecx,%ebx
  800b85:	89 cf                	mov    %ecx,%edi
  800b87:	89 ce                	mov    %ecx,%esi
  800b89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7e 28                	jle    800bb7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b93:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9a:	00 
  800b9b:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800ba2:	00 
  800ba3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800baa:	00 
  800bab:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800bb2:	e8 b1 f5 ff ff       	call   800168 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb7:	83 c4 2c             	add    $0x2c,%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_yield>:

void
sys_yield(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	be 00 00 00 00       	mov    $0x0,%esi
  800c0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 f7                	mov    %esi,%edi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 28                	jle    800c49 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c25:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c2c:	00 
  800c2d:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800c34:	00 
  800c35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3c:	00 
  800c3d:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800c44:	e8 1f f5 ff ff       	call   800168 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c49:	83 c4 2c             	add    $0x2c,%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 28                	jle    800c9c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c78:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c7f:	00 
  800c80:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800c87:	00 
  800c88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8f:	00 
  800c90:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800c97:	e8 cc f4 ff ff       	call   800168 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9c:	83 c4 2c             	add    $0x2c,%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 28                	jle    800cef <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800cda:	00 
  800cdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce2:	00 
  800ce3:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800cea:	e8 79 f4 ff ff       	call   800168 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cef:	83 c4 2c             	add    $0x2c,%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 28                	jle    800d42 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d25:	00 
  800d26:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800d2d:	00 
  800d2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d35:	00 
  800d36:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800d3d:	e8 26 f4 ff ff       	call   800168 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d42:	83 c4 2c             	add    $0x2c,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800d90:	e8 d3 f3 ff ff       	call   800168 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d95:	83 c4 2c             	add    $0x2c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 28                	jle    800de8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddb:	00 
  800ddc:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800de3:	e8 80 f3 ff ff       	call   800168 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de8:	83 c4 2c             	add    $0x2c,%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	be 00 00 00 00       	mov    $0x0,%esi
  800dfb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e21:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 cb                	mov    %ecx,%ebx
  800e2b:	89 cf                	mov    %ecx,%edi
  800e2d:	89 ce                	mov    %ecx,%esi
  800e2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 28                	jle    800e5d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e39:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e40:	00 
  800e41:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800e48:	00 
  800e49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e50:	00 
  800e51:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800e58:	e8 0b f3 ff ff       	call   800168 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5d:	83 c4 2c             	add    $0x2c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	00 00                	add    %al,(%eax)
	...

00800e68 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e6e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e75:	75 32                	jne    800ea9 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800e77:	e8 43 fd ff ff       	call   800bbf <sys_getenvid>
  800e7c:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e8b:	ee 
  800e8c:	89 04 24             	mov    %eax,(%esp)
  800e8f:	e8 69 fd ff ff       	call   800bfd <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  800e94:	e8 26 fd ff ff       	call   800bbf <sys_getenvid>
  800e99:	c7 44 24 04 b4 0e 80 	movl   $0x800eb4,0x4(%esp)
  800ea0:	00 
  800ea1:	89 04 24             	mov    %eax,(%esp)
  800ea4:	e8 f4 fe ff ff       	call   800d9d <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eac:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    
	...

00800eb4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800eb4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800eb5:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800eba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ebc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  800ebf:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  800ec3:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  800ec6:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  800ecb:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  800ecf:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  800ed2:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  800ed3:	83 c4 04             	add    $0x4,%esp
	popfl
  800ed6:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  800ed7:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  800ed8:	c3                   	ret    
  800ed9:	00 00                	add    %al,(%eax)
	...

00800edc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef5:	89 04 24             	mov    %eax,(%esp)
  800ef8:	e8 df ff ff ff       	call   800edc <fd2num>
  800efd:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f02:	c1 e0 0c             	shl    $0xc,%eax
}
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	53                   	push   %ebx
  800f0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f0e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f13:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f15:	89 c2                	mov    %eax,%edx
  800f17:	c1 ea 16             	shr    $0x16,%edx
  800f1a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f21:	f6 c2 01             	test   $0x1,%dl
  800f24:	74 11                	je     800f37 <fd_alloc+0x30>
  800f26:	89 c2                	mov    %eax,%edx
  800f28:	c1 ea 0c             	shr    $0xc,%edx
  800f2b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f32:	f6 c2 01             	test   $0x1,%dl
  800f35:	75 09                	jne    800f40 <fd_alloc+0x39>
			*fd_store = fd;
  800f37:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb 17                	jmp    800f57 <fd_alloc+0x50>
  800f40:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f45:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f4a:	75 c7                	jne    800f13 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f52:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f57:	5b                   	pop    %ebx
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f60:	83 f8 1f             	cmp    $0x1f,%eax
  800f63:	77 36                	ja     800f9b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f65:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f6a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	c1 ea 16             	shr    $0x16,%edx
  800f72:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f79:	f6 c2 01             	test   $0x1,%dl
  800f7c:	74 24                	je     800fa2 <fd_lookup+0x48>
  800f7e:	89 c2                	mov    %eax,%edx
  800f80:	c1 ea 0c             	shr    $0xc,%edx
  800f83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8a:	f6 c2 01             	test   $0x1,%dl
  800f8d:	74 1a                	je     800fa9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f92:	89 02                	mov    %eax,(%edx)
	return 0;
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
  800f99:	eb 13                	jmp    800fae <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa0:	eb 0c                	jmp    800fae <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa7:	eb 05                	jmp    800fae <fd_lookup+0x54>
  800fa9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 14             	sub    $0x14,%esp
  800fb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc2:	eb 0e                	jmp    800fd2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fc4:	39 08                	cmp    %ecx,(%eax)
  800fc6:	75 09                	jne    800fd1 <dev_lookup+0x21>
			*dev = devtab[i];
  800fc8:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcf:	eb 33                	jmp    801004 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fd1:	42                   	inc    %edx
  800fd2:	8b 04 95 4c 24 80 00 	mov    0x80244c(,%edx,4),%eax
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	75 e7                	jne    800fc4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fdd:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe2:	8b 40 48             	mov    0x48(%eax),%eax
  800fe5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fed:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  800ff4:	e8 67 f2 ff ff       	call   800260 <cprintf>
	*dev = 0;
  800ff9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801004:	83 c4 14             	add    $0x14,%esp
  801007:	5b                   	pop    %ebx
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 30             	sub    $0x30,%esp
  801012:	8b 75 08             	mov    0x8(%ebp),%esi
  801015:	8a 45 0c             	mov    0xc(%ebp),%al
  801018:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80101b:	89 34 24             	mov    %esi,(%esp)
  80101e:	e8 b9 fe ff ff       	call   800edc <fd2num>
  801023:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801026:	89 54 24 04          	mov    %edx,0x4(%esp)
  80102a:	89 04 24             	mov    %eax,(%esp)
  80102d:	e8 28 ff ff ff       	call   800f5a <fd_lookup>
  801032:	89 c3                	mov    %eax,%ebx
  801034:	85 c0                	test   %eax,%eax
  801036:	78 05                	js     80103d <fd_close+0x33>
	    || fd != fd2)
  801038:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80103b:	74 0d                	je     80104a <fd_close+0x40>
		return (must_exist ? r : 0);
  80103d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801041:	75 46                	jne    801089 <fd_close+0x7f>
  801043:	bb 00 00 00 00       	mov    $0x0,%ebx
  801048:	eb 3f                	jmp    801089 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80104a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80104d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801051:	8b 06                	mov    (%esi),%eax
  801053:	89 04 24             	mov    %eax,(%esp)
  801056:	e8 55 ff ff ff       	call   800fb0 <dev_lookup>
  80105b:	89 c3                	mov    %eax,%ebx
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 18                	js     801079 <fd_close+0x6f>
		if (dev->dev_close)
  801061:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801064:	8b 40 10             	mov    0x10(%eax),%eax
  801067:	85 c0                	test   %eax,%eax
  801069:	74 09                	je     801074 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80106b:	89 34 24             	mov    %esi,(%esp)
  80106e:	ff d0                	call   *%eax
  801070:	89 c3                	mov    %eax,%ebx
  801072:	eb 05                	jmp    801079 <fd_close+0x6f>
		else
			r = 0;
  801074:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801079:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801084:	e8 1b fc ff ff       	call   800ca4 <sys_page_unmap>
	return r;
}
  801089:	89 d8                	mov    %ebx,%eax
  80108b:	83 c4 30             	add    $0x30,%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801098:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a2:	89 04 24             	mov    %eax,(%esp)
  8010a5:	e8 b0 fe ff ff       	call   800f5a <fd_lookup>
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 13                	js     8010c1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010ae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b5:	00 
  8010b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b9:	89 04 24             	mov    %eax,(%esp)
  8010bc:	e8 49 ff ff ff       	call   80100a <fd_close>
}
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <close_all>:

void
close_all(void)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010cf:	89 1c 24             	mov    %ebx,(%esp)
  8010d2:	e8 bb ff ff ff       	call   801092 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010d7:	43                   	inc    %ebx
  8010d8:	83 fb 20             	cmp    $0x20,%ebx
  8010db:	75 f2                	jne    8010cf <close_all+0xc>
		close(i);
}
  8010dd:	83 c4 14             	add    $0x14,%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 4c             	sub    $0x4c,%esp
  8010ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	89 04 24             	mov    %eax,(%esp)
  8010fc:	e8 59 fe ff ff       	call   800f5a <fd_lookup>
  801101:	89 c3                	mov    %eax,%ebx
  801103:	85 c0                	test   %eax,%eax
  801105:	0f 88 e1 00 00 00    	js     8011ec <dup+0x109>
		return r;
	close(newfdnum);
  80110b:	89 3c 24             	mov    %edi,(%esp)
  80110e:	e8 7f ff ff ff       	call   801092 <close>

	newfd = INDEX2FD(newfdnum);
  801113:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801119:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80111c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111f:	89 04 24             	mov    %eax,(%esp)
  801122:	e8 c5 fd ff ff       	call   800eec <fd2data>
  801127:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801129:	89 34 24             	mov    %esi,(%esp)
  80112c:	e8 bb fd ff ff       	call   800eec <fd2data>
  801131:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801134:	89 d8                	mov    %ebx,%eax
  801136:	c1 e8 16             	shr    $0x16,%eax
  801139:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801140:	a8 01                	test   $0x1,%al
  801142:	74 46                	je     80118a <dup+0xa7>
  801144:	89 d8                	mov    %ebx,%eax
  801146:	c1 e8 0c             	shr    $0xc,%eax
  801149:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801150:	f6 c2 01             	test   $0x1,%dl
  801153:	74 35                	je     80118a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801155:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115c:	25 07 0e 00 00       	and    $0xe07,%eax
  801161:	89 44 24 10          	mov    %eax,0x10(%esp)
  801165:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801168:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801173:	00 
  801174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117f:	e8 cd fa ff ff       	call   800c51 <sys_page_map>
  801184:	89 c3                	mov    %eax,%ebx
  801186:	85 c0                	test   %eax,%eax
  801188:	78 3b                	js     8011c5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80118a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	c1 ea 0c             	shr    $0xc,%edx
  801192:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801199:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80119f:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011ae:	00 
  8011af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ba:	e8 92 fa ff ff       	call   800c51 <sys_page_map>
  8011bf:	89 c3                	mov    %eax,%ebx
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	79 25                	jns    8011ea <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d0:	e8 cf fa ff ff       	call   800ca4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e3:	e8 bc fa ff ff       	call   800ca4 <sys_page_unmap>
	return r;
  8011e8:	eb 02                	jmp    8011ec <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011ea:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011ec:	89 d8                	mov    %ebx,%eax
  8011ee:	83 c4 4c             	add    $0x4c,%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	53                   	push   %ebx
  8011fa:	83 ec 24             	sub    $0x24,%esp
  8011fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801200:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801203:	89 44 24 04          	mov    %eax,0x4(%esp)
  801207:	89 1c 24             	mov    %ebx,(%esp)
  80120a:	e8 4b fd ff ff       	call   800f5a <fd_lookup>
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 6d                	js     801280 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	8b 00                	mov    (%eax),%eax
  80121f:	89 04 24             	mov    %eax,(%esp)
  801222:	e8 89 fd ff ff       	call   800fb0 <dev_lookup>
  801227:	85 c0                	test   %eax,%eax
  801229:	78 55                	js     801280 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	8b 50 08             	mov    0x8(%eax),%edx
  801231:	83 e2 03             	and    $0x3,%edx
  801234:	83 fa 01             	cmp    $0x1,%edx
  801237:	75 23                	jne    80125c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801239:	a1 04 40 80 00       	mov    0x804004,%eax
  80123e:	8b 40 48             	mov    0x48(%eax),%eax
  801241:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801245:	89 44 24 04          	mov    %eax,0x4(%esp)
  801249:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  801250:	e8 0b f0 ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  801255:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125a:	eb 24                	jmp    801280 <read+0x8a>
	}
	if (!dev->dev_read)
  80125c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125f:	8b 52 08             	mov    0x8(%edx),%edx
  801262:	85 d2                	test   %edx,%edx
  801264:	74 15                	je     80127b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801266:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801269:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801270:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801274:	89 04 24             	mov    %eax,(%esp)
  801277:	ff d2                	call   *%edx
  801279:	eb 05                	jmp    801280 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80127b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801280:	83 c4 24             	add    $0x24,%esp
  801283:	5b                   	pop    %ebx
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	57                   	push   %edi
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
  80128c:	83 ec 1c             	sub    $0x1c,%esp
  80128f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801292:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801295:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129a:	eb 23                	jmp    8012bf <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129c:	89 f0                	mov    %esi,%eax
  80129e:	29 d8                	sub    %ebx,%eax
  8012a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a7:	01 d8                	add    %ebx,%eax
  8012a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ad:	89 3c 24             	mov    %edi,(%esp)
  8012b0:	e8 41 ff ff ff       	call   8011f6 <read>
		if (m < 0)
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 10                	js     8012c9 <readn+0x43>
			return m;
		if (m == 0)
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	74 0a                	je     8012c7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012bd:	01 c3                	add    %eax,%ebx
  8012bf:	39 f3                	cmp    %esi,%ebx
  8012c1:	72 d9                	jb     80129c <readn+0x16>
  8012c3:	89 d8                	mov    %ebx,%eax
  8012c5:	eb 02                	jmp    8012c9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012c7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012c9:	83 c4 1c             	add    $0x1c,%esp
  8012cc:	5b                   	pop    %ebx
  8012cd:	5e                   	pop    %esi
  8012ce:	5f                   	pop    %edi
  8012cf:	5d                   	pop    %ebp
  8012d0:	c3                   	ret    

008012d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 24             	sub    $0x24,%esp
  8012d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e2:	89 1c 24             	mov    %ebx,(%esp)
  8012e5:	e8 70 fc ff ff       	call   800f5a <fd_lookup>
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 68                	js     801356 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	8b 00                	mov    (%eax),%eax
  8012fa:	89 04 24             	mov    %eax,(%esp)
  8012fd:	e8 ae fc ff ff       	call   800fb0 <dev_lookup>
  801302:	85 c0                	test   %eax,%eax
  801304:	78 50                	js     801356 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130d:	75 23                	jne    801332 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80130f:	a1 04 40 80 00       	mov    0x804004,%eax
  801314:	8b 40 48             	mov    0x48(%eax),%eax
  801317:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131f:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  801326:	e8 35 ef ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  80132b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801330:	eb 24                	jmp    801356 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801332:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801335:	8b 52 0c             	mov    0xc(%edx),%edx
  801338:	85 d2                	test   %edx,%edx
  80133a:	74 15                	je     801351 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80133f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801343:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801346:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80134a:	89 04 24             	mov    %eax,(%esp)
  80134d:	ff d2                	call   *%edx
  80134f:	eb 05                	jmp    801356 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801351:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801356:	83 c4 24             	add    $0x24,%esp
  801359:	5b                   	pop    %ebx
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <seek>:

int
seek(int fdnum, off_t offset)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801362:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801365:	89 44 24 04          	mov    %eax,0x4(%esp)
  801369:	8b 45 08             	mov    0x8(%ebp),%eax
  80136c:	89 04 24             	mov    %eax,(%esp)
  80136f:	e8 e6 fb ff ff       	call   800f5a <fd_lookup>
  801374:	85 c0                	test   %eax,%eax
  801376:	78 0e                	js     801386 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801378:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801381:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	53                   	push   %ebx
  80138c:	83 ec 24             	sub    $0x24,%esp
  80138f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801392:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801395:	89 44 24 04          	mov    %eax,0x4(%esp)
  801399:	89 1c 24             	mov    %ebx,(%esp)
  80139c:	e8 b9 fb ff ff       	call   800f5a <fd_lookup>
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 61                	js     801406 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013af:	8b 00                	mov    (%eax),%eax
  8013b1:	89 04 24             	mov    %eax,(%esp)
  8013b4:	e8 f7 fb ff ff       	call   800fb0 <dev_lookup>
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 49                	js     801406 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c4:	75 23                	jne    8013e9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013cb:	8b 40 48             	mov    0x48(%eax),%eax
  8013ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d6:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  8013dd:	e8 7e ee ff ff       	call   800260 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e7:	eb 1d                	jmp    801406 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8013e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ec:	8b 52 18             	mov    0x18(%edx),%edx
  8013ef:	85 d2                	test   %edx,%edx
  8013f1:	74 0e                	je     801401 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013fa:	89 04 24             	mov    %eax,(%esp)
  8013fd:	ff d2                	call   *%edx
  8013ff:	eb 05                	jmp    801406 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801401:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801406:	83 c4 24             	add    $0x24,%esp
  801409:	5b                   	pop    %ebx
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	53                   	push   %ebx
  801410:	83 ec 24             	sub    $0x24,%esp
  801413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801416:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141d:	8b 45 08             	mov    0x8(%ebp),%eax
  801420:	89 04 24             	mov    %eax,(%esp)
  801423:	e8 32 fb ff ff       	call   800f5a <fd_lookup>
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 52                	js     80147e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801436:	8b 00                	mov    (%eax),%eax
  801438:	89 04 24             	mov    %eax,(%esp)
  80143b:	e8 70 fb ff ff       	call   800fb0 <dev_lookup>
  801440:	85 c0                	test   %eax,%eax
  801442:	78 3a                	js     80147e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801444:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801447:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80144b:	74 2c                	je     801479 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80144d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801450:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801457:	00 00 00 
	stat->st_isdir = 0;
  80145a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801461:	00 00 00 
	stat->st_dev = dev;
  801464:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80146a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80146e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801471:	89 14 24             	mov    %edx,(%esp)
  801474:	ff 50 14             	call   *0x14(%eax)
  801477:	eb 05                	jmp    80147e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801479:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80147e:	83 c4 24             	add    $0x24,%esp
  801481:	5b                   	pop    %ebx
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80148c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801493:	00 
  801494:	8b 45 08             	mov    0x8(%ebp),%eax
  801497:	89 04 24             	mov    %eax,(%esp)
  80149a:	e8 fe 01 00 00       	call   80169d <open>
  80149f:	89 c3                	mov    %eax,%ebx
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 1b                	js     8014c0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ac:	89 1c 24             	mov    %ebx,(%esp)
  8014af:	e8 58 ff ff ff       	call   80140c <fstat>
  8014b4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b6:	89 1c 24             	mov    %ebx,(%esp)
  8014b9:	e8 d4 fb ff ff       	call   801092 <close>
	return r;
  8014be:	89 f3                	mov    %esi,%ebx
}
  8014c0:	89 d8                	mov    %ebx,%eax
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	5b                   	pop    %ebx
  8014c6:	5e                   	pop    %esi
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    
  8014c9:	00 00                	add    %al,(%eax)
	...

008014cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 10             	sub    $0x10,%esp
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014d8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014df:	75 11                	jne    8014f2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014e8:	e8 3a 08 00 00       	call   801d27 <ipc_find_env>
  8014ed:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014f2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801501:	00 
  801502:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801506:	a1 00 40 80 00       	mov    0x804000,%eax
  80150b:	89 04 24             	mov    %eax,(%esp)
  80150e:	e8 aa 07 00 00       	call   801cbd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801513:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80151a:	00 
  80151b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80151f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801526:	e8 29 07 00 00       	call   801c54 <ipc_recv>
}
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    

00801532 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801538:	8b 45 08             	mov    0x8(%ebp),%eax
  80153b:	8b 40 0c             	mov    0xc(%eax),%eax
  80153e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801543:	8b 45 0c             	mov    0xc(%ebp),%eax
  801546:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80154b:	ba 00 00 00 00       	mov    $0x0,%edx
  801550:	b8 02 00 00 00       	mov    $0x2,%eax
  801555:	e8 72 ff ff ff       	call   8014cc <fsipc>
}
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801562:	8b 45 08             	mov    0x8(%ebp),%eax
  801565:	8b 40 0c             	mov    0xc(%eax),%eax
  801568:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80156d:	ba 00 00 00 00       	mov    $0x0,%edx
  801572:	b8 06 00 00 00       	mov    $0x6,%eax
  801577:	e8 50 ff ff ff       	call   8014cc <fsipc>
}
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	53                   	push   %ebx
  801582:	83 ec 14             	sub    $0x14,%esp
  801585:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801588:	8b 45 08             	mov    0x8(%ebp),%eax
  80158b:	8b 40 0c             	mov    0xc(%eax),%eax
  80158e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801593:	ba 00 00 00 00       	mov    $0x0,%edx
  801598:	b8 05 00 00 00       	mov    $0x5,%eax
  80159d:	e8 2a ff ff ff       	call   8014cc <fsipc>
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 2b                	js     8015d1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015a6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015ad:	00 
  8015ae:	89 1c 24             	mov    %ebx,(%esp)
  8015b1:	e8 55 f2 ff ff       	call   80080b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8015bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8015c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d1:	83 c4 14             	add    $0x14,%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8015dd:	c7 44 24 08 5c 24 80 	movl   $0x80245c,0x8(%esp)
  8015e4:	00 
  8015e5:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8015ec:	00 
  8015ed:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  8015f4:	e8 6f eb ff ff       	call   800168 <_panic>

008015f9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	56                   	push   %esi
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 10             	sub    $0x10,%esp
  801601:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801604:	8b 45 08             	mov    0x8(%ebp),%eax
  801607:	8b 40 0c             	mov    0xc(%eax),%eax
  80160a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80160f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801615:	ba 00 00 00 00       	mov    $0x0,%edx
  80161a:	b8 03 00 00 00       	mov    $0x3,%eax
  80161f:	e8 a8 fe ff ff       	call   8014cc <fsipc>
  801624:	89 c3                	mov    %eax,%ebx
  801626:	85 c0                	test   %eax,%eax
  801628:	78 6a                	js     801694 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80162a:	39 c6                	cmp    %eax,%esi
  80162c:	73 24                	jae    801652 <devfile_read+0x59>
  80162e:	c7 44 24 0c 85 24 80 	movl   $0x802485,0xc(%esp)
  801635:	00 
  801636:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  80163d:	00 
  80163e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801645:	00 
  801646:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  80164d:	e8 16 eb ff ff       	call   800168 <_panic>
	assert(r <= PGSIZE);
  801652:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801657:	7e 24                	jle    80167d <devfile_read+0x84>
  801659:	c7 44 24 0c a1 24 80 	movl   $0x8024a1,0xc(%esp)
  801660:	00 
  801661:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  801668:	00 
  801669:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801670:	00 
  801671:	c7 04 24 7a 24 80 00 	movl   $0x80247a,(%esp)
  801678:	e8 eb ea ff ff       	call   800168 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80167d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801681:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801688:	00 
  801689:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 f0 f2 ff ff       	call   800984 <memmove>
	return r;
}
  801694:	89 d8                	mov    %ebx,%eax
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	56                   	push   %esi
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 20             	sub    $0x20,%esp
  8016a5:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016a8:	89 34 24             	mov    %esi,(%esp)
  8016ab:	e8 28 f1 ff ff       	call   8007d8 <strlen>
  8016b0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016b5:	7f 60                	jg     801717 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ba:	89 04 24             	mov    %eax,(%esp)
  8016bd:	e8 45 f8 ff ff       	call   800f07 <fd_alloc>
  8016c2:	89 c3                	mov    %eax,%ebx
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 54                	js     80171c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016cc:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016d3:	e8 33 f1 ff ff       	call   80080b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016db:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8016e8:	e8 df fd ff ff       	call   8014cc <fsipc>
  8016ed:	89 c3                	mov    %eax,%ebx
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	79 15                	jns    801708 <open+0x6b>
		fd_close(fd, 0);
  8016f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016fa:	00 
  8016fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fe:	89 04 24             	mov    %eax,(%esp)
  801701:	e8 04 f9 ff ff       	call   80100a <fd_close>
		return r;
  801706:	eb 14                	jmp    80171c <open+0x7f>
	}

	return fd2num(fd);
  801708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170b:	89 04 24             	mov    %eax,(%esp)
  80170e:	e8 c9 f7 ff ff       	call   800edc <fd2num>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	eb 05                	jmp    80171c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801717:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80171c:	89 d8                	mov    %ebx,%eax
  80171e:	83 c4 20             	add    $0x20,%esp
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	b8 08 00 00 00       	mov    $0x8,%eax
  801735:	e8 92 fd ff ff       	call   8014cc <fsipc>
}
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	83 ec 10             	sub    $0x10,%esp
  801744:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801747:	8b 45 08             	mov    0x8(%ebp),%eax
  80174a:	89 04 24             	mov    %eax,(%esp)
  80174d:	e8 9a f7 ff ff       	call   800eec <fd2data>
  801752:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801754:	c7 44 24 04 ad 24 80 	movl   $0x8024ad,0x4(%esp)
  80175b:	00 
  80175c:	89 34 24             	mov    %esi,(%esp)
  80175f:	e8 a7 f0 ff ff       	call   80080b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801764:	8b 43 04             	mov    0x4(%ebx),%eax
  801767:	2b 03                	sub    (%ebx),%eax
  801769:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80176f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801776:	00 00 00 
	stat->st_dev = &devpipe;
  801779:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801780:	30 80 00 
	return 0;
}
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	53                   	push   %ebx
  801793:	83 ec 14             	sub    $0x14,%esp
  801796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801799:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80179d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a4:	e8 fb f4 ff ff       	call   800ca4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017a9:	89 1c 24             	mov    %ebx,(%esp)
  8017ac:	e8 3b f7 ff ff       	call   800eec <fd2data>
  8017b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bc:	e8 e3 f4 ff ff       	call   800ca4 <sys_page_unmap>
}
  8017c1:	83 c4 14             	add    $0x14,%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	57                   	push   %edi
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 2c             	sub    $0x2c,%esp
  8017d0:	89 c7                	mov    %eax,%edi
  8017d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8017da:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017dd:	89 3c 24             	mov    %edi,(%esp)
  8017e0:	e8 87 05 00 00       	call   801d6c <pageref>
  8017e5:	89 c6                	mov    %eax,%esi
  8017e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ea:	89 04 24             	mov    %eax,(%esp)
  8017ed:	e8 7a 05 00 00       	call   801d6c <pageref>
  8017f2:	39 c6                	cmp    %eax,%esi
  8017f4:	0f 94 c0             	sete   %al
  8017f7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8017fa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801800:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801803:	39 cb                	cmp    %ecx,%ebx
  801805:	75 08                	jne    80180f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801807:	83 c4 2c             	add    $0x2c,%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5f                   	pop    %edi
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80180f:	83 f8 01             	cmp    $0x1,%eax
  801812:	75 c1                	jne    8017d5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801814:	8b 42 58             	mov    0x58(%edx),%eax
  801817:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80181e:	00 
  80181f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801823:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801827:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  80182e:	e8 2d ea ff ff       	call   800260 <cprintf>
  801833:	eb a0                	jmp    8017d5 <_pipeisclosed+0xe>

00801835 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	57                   	push   %edi
  801839:	56                   	push   %esi
  80183a:	53                   	push   %ebx
  80183b:	83 ec 1c             	sub    $0x1c,%esp
  80183e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801841:	89 34 24             	mov    %esi,(%esp)
  801844:	e8 a3 f6 ff ff       	call   800eec <fd2data>
  801849:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80184b:	bf 00 00 00 00       	mov    $0x0,%edi
  801850:	eb 3c                	jmp    80188e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801852:	89 da                	mov    %ebx,%edx
  801854:	89 f0                	mov    %esi,%eax
  801856:	e8 6c ff ff ff       	call   8017c7 <_pipeisclosed>
  80185b:	85 c0                	test   %eax,%eax
  80185d:	75 38                	jne    801897 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80185f:	e8 7a f3 ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801864:	8b 43 04             	mov    0x4(%ebx),%eax
  801867:	8b 13                	mov    (%ebx),%edx
  801869:	83 c2 20             	add    $0x20,%edx
  80186c:	39 d0                	cmp    %edx,%eax
  80186e:	73 e2                	jae    801852 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801870:	8b 55 0c             	mov    0xc(%ebp),%edx
  801873:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801876:	89 c2                	mov    %eax,%edx
  801878:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80187e:	79 05                	jns    801885 <devpipe_write+0x50>
  801880:	4a                   	dec    %edx
  801881:	83 ca e0             	or     $0xffffffe0,%edx
  801884:	42                   	inc    %edx
  801885:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801889:	40                   	inc    %eax
  80188a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80188d:	47                   	inc    %edi
  80188e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801891:	75 d1                	jne    801864 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801893:	89 f8                	mov    %edi,%eax
  801895:	eb 05                	jmp    80189c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801897:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80189c:	83 c4 1c             	add    $0x1c,%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5f                   	pop    %edi
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	57                   	push   %edi
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	83 ec 1c             	sub    $0x1c,%esp
  8018ad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018b0:	89 3c 24             	mov    %edi,(%esp)
  8018b3:	e8 34 f6 ff ff       	call   800eec <fd2data>
  8018b8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ba:	be 00 00 00 00       	mov    $0x0,%esi
  8018bf:	eb 3a                	jmp    8018fb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018c1:	85 f6                	test   %esi,%esi
  8018c3:	74 04                	je     8018c9 <devpipe_read+0x25>
				return i;
  8018c5:	89 f0                	mov    %esi,%eax
  8018c7:	eb 40                	jmp    801909 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018c9:	89 da                	mov    %ebx,%edx
  8018cb:	89 f8                	mov    %edi,%eax
  8018cd:	e8 f5 fe ff ff       	call   8017c7 <_pipeisclosed>
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	75 2e                	jne    801904 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018d6:	e8 03 f3 ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018db:	8b 03                	mov    (%ebx),%eax
  8018dd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018e0:	74 df                	je     8018c1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018e2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018e7:	79 05                	jns    8018ee <devpipe_read+0x4a>
  8018e9:	48                   	dec    %eax
  8018ea:	83 c8 e0             	or     $0xffffffe0,%eax
  8018ed:	40                   	inc    %eax
  8018ee:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8018f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8018f8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fa:	46                   	inc    %esi
  8018fb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018fe:	75 db                	jne    8018db <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801900:	89 f0                	mov    %esi,%eax
  801902:	eb 05                	jmp    801909 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801904:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801909:	83 c4 1c             	add    $0x1c,%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5f                   	pop    %edi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	57                   	push   %edi
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	83 ec 3c             	sub    $0x3c,%esp
  80191a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80191d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801920:	89 04 24             	mov    %eax,(%esp)
  801923:	e8 df f5 ff ff       	call   800f07 <fd_alloc>
  801928:	89 c3                	mov    %eax,%ebx
  80192a:	85 c0                	test   %eax,%eax
  80192c:	0f 88 45 01 00 00    	js     801a77 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801932:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801939:	00 
  80193a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801941:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801948:	e8 b0 f2 ff ff       	call   800bfd <sys_page_alloc>
  80194d:	89 c3                	mov    %eax,%ebx
  80194f:	85 c0                	test   %eax,%eax
  801951:	0f 88 20 01 00 00    	js     801a77 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801957:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80195a:	89 04 24             	mov    %eax,(%esp)
  80195d:	e8 a5 f5 ff ff       	call   800f07 <fd_alloc>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	85 c0                	test   %eax,%eax
  801966:	0f 88 f8 00 00 00    	js     801a64 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80196c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801973:	00 
  801974:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801982:	e8 76 f2 ff ff       	call   800bfd <sys_page_alloc>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	85 c0                	test   %eax,%eax
  80198b:	0f 88 d3 00 00 00    	js     801a64 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801991:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801994:	89 04 24             	mov    %eax,(%esp)
  801997:	e8 50 f5 ff ff       	call   800eec <fd2data>
  80199c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019a5:	00 
  8019a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b1:	e8 47 f2 ff ff       	call   800bfd <sys_page_alloc>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	0f 88 91 00 00 00    	js     801a51 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019c3:	89 04 24             	mov    %eax,(%esp)
  8019c6:	e8 21 f5 ff ff       	call   800eec <fd2data>
  8019cb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019d2:	00 
  8019d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019de:	00 
  8019df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ea:	e8 62 f2 ff ff       	call   800c51 <sys_page_map>
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	78 4c                	js     801a41 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019f5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019fe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a0a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a13:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a22:	89 04 24             	mov    %eax,(%esp)
  801a25:	e8 b2 f4 ff ff       	call   800edc <fd2num>
  801a2a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a2f:	89 04 24             	mov    %eax,(%esp)
  801a32:	e8 a5 f4 ff ff       	call   800edc <fd2num>
  801a37:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a3f:	eb 36                	jmp    801a77 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801a41:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a4c:	e8 53 f2 ff ff       	call   800ca4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801a51:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a5f:	e8 40 f2 ff ff       	call   800ca4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801a64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a72:	e8 2d f2 ff ff       	call   800ca4 <sys_page_unmap>
    err:
	return r;
}
  801a77:	89 d8                	mov    %ebx,%eax
  801a79:	83 c4 3c             	add    $0x3c,%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5f                   	pop    %edi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    

00801a81 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	89 04 24             	mov    %eax,(%esp)
  801a94:	e8 c1 f4 ff ff       	call   800f5a <fd_lookup>
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 15                	js     801ab2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa0:	89 04 24             	mov    %eax,(%esp)
  801aa3:	e8 44 f4 ff ff       	call   800eec <fd2data>
	return _pipeisclosed(fd, p);
  801aa8:	89 c2                	mov    %eax,%edx
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	e8 15 fd ff ff       	call   8017c7 <_pipeisclosed>
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ac4:	c7 44 24 04 cc 24 80 	movl   $0x8024cc,0x4(%esp)
  801acb:	00 
  801acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acf:	89 04 24             	mov    %eax,(%esp)
  801ad2:	e8 34 ed ff ff       	call   80080b <strcpy>
	return 0;
}
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aea:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801aef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801af5:	eb 30                	jmp    801b27 <devcons_write+0x49>
		m = n - tot;
  801af7:	8b 75 10             	mov    0x10(%ebp),%esi
  801afa:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801afc:	83 fe 7f             	cmp    $0x7f,%esi
  801aff:	76 05                	jbe    801b06 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801b01:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b06:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b0a:	03 45 0c             	add    0xc(%ebp),%eax
  801b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b11:	89 3c 24             	mov    %edi,(%esp)
  801b14:	e8 6b ee ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  801b19:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b1d:	89 3c 24             	mov    %edi,(%esp)
  801b20:	e8 0b f0 ff ff       	call   800b30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b25:	01 f3                	add    %esi,%ebx
  801b27:	89 d8                	mov    %ebx,%eax
  801b29:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b2c:	72 c9                	jb     801af7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b2e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5f                   	pop    %edi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b43:	75 07                	jne    801b4c <devcons_read+0x13>
  801b45:	eb 25                	jmp    801b6c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b47:	e8 92 f0 ff ff       	call   800bde <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b4c:	e8 fd ef ff ff       	call   800b4e <sys_cgetc>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	74 f2                	je     801b47 <devcons_read+0xe>
  801b55:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 1d                	js     801b78 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b5b:	83 f8 04             	cmp    $0x4,%eax
  801b5e:	74 13                	je     801b73 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b63:	88 10                	mov    %dl,(%eax)
	return 1;
  801b65:	b8 01 00 00 00       	mov    $0x1,%eax
  801b6a:	eb 0c                	jmp    801b78 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b71:	eb 05                	jmp    801b78 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b86:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b8d:	00 
  801b8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b91:	89 04 24             	mov    %eax,(%esp)
  801b94:	e8 97 ef ff ff       	call   800b30 <sys_cputs>
}
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <getchar>:

int
getchar(void)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ba1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ba8:	00 
  801ba9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb7:	e8 3a f6 ff ff       	call   8011f6 <read>
	if (r < 0)
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	78 0f                	js     801bcf <getchar+0x34>
		return r;
	if (r < 1)
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	7e 06                	jle    801bca <getchar+0x2f>
		return -E_EOF;
	return c;
  801bc4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bc8:	eb 05                	jmp    801bcf <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bca:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bcf:	c9                   	leave  
  801bd0:	c3                   	ret    

00801bd1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bde:	8b 45 08             	mov    0x8(%ebp),%eax
  801be1:	89 04 24             	mov    %eax,(%esp)
  801be4:	e8 71 f3 ff ff       	call   800f5a <fd_lookup>
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 11                	js     801bfe <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bf6:	39 10                	cmp    %edx,(%eax)
  801bf8:	0f 94 c0             	sete   %al
  801bfb:	0f b6 c0             	movzbl %al,%eax
}
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <opencons>:

int
opencons(void)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c09:	89 04 24             	mov    %eax,(%esp)
  801c0c:	e8 f6 f2 ff ff       	call   800f07 <fd_alloc>
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 3c                	js     801c51 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c15:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c1c:	00 
  801c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2b:	e8 cd ef ff ff       	call   800bfd <sys_page_alloc>
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 1d                	js     801c51 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c34:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c42:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c49:	89 04 24             	mov    %eax,(%esp)
  801c4c:	e8 8b f2 ff ff       	call   800edc <fd2num>
}
  801c51:	c9                   	leave  
  801c52:	c3                   	ret    
	...

00801c54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	57                   	push   %edi
  801c58:	56                   	push   %esi
  801c59:	53                   	push   %ebx
  801c5a:	83 ec 1c             	sub    $0x1c,%esp
  801c5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c63:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801c66:	85 db                	test   %ebx,%ebx
  801c68:	75 05                	jne    801c6f <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801c6a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801c6f:	89 1c 24             	mov    %ebx,(%esp)
  801c72:	e8 9c f1 ff ff       	call   800e13 <sys_ipc_recv>
  801c77:	85 c0                	test   %eax,%eax
  801c79:	79 16                	jns    801c91 <ipc_recv+0x3d>
		*from_env_store = 0;
  801c7b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801c81:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801c87:	89 1c 24             	mov    %ebx,(%esp)
  801c8a:	e8 84 f1 ff ff       	call   800e13 <sys_ipc_recv>
  801c8f:	eb 24                	jmp    801cb5 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801c91:	85 f6                	test   %esi,%esi
  801c93:	74 0a                	je     801c9f <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801c95:	a1 04 40 80 00       	mov    0x804004,%eax
  801c9a:	8b 40 74             	mov    0x74(%eax),%eax
  801c9d:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801c9f:	85 ff                	test   %edi,%edi
  801ca1:	74 0a                	je     801cad <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801ca3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ca8:	8b 40 78             	mov    0x78(%eax),%eax
  801cab:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801cad:	a1 04 40 80 00       	mov    0x804004,%eax
  801cb2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cb5:	83 c4 1c             	add    $0x1c,%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5e                   	pop    %esi
  801cba:	5f                   	pop    %edi
  801cbb:	5d                   	pop    %ebp
  801cbc:	c3                   	ret    

00801cbd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	57                   	push   %edi
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
  801cc3:	83 ec 1c             	sub    $0x1c,%esp
  801cc6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ccc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801ccf:	85 db                	test   %ebx,%ebx
  801cd1:	75 05                	jne    801cd8 <ipc_send+0x1b>
		pg = (void *)-1;
  801cd3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801cd8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801cdc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ce0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	89 04 24             	mov    %eax,(%esp)
  801cea:	e8 01 f1 ff ff       	call   800df0 <sys_ipc_try_send>
		if (r == 0) {		
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	74 2c                	je     801d1f <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801cf3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cf6:	75 07                	jne    801cff <ipc_send+0x42>
			sys_yield();
  801cf8:	e8 e1 ee ff ff       	call   800bde <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801cfd:	eb d9                	jmp    801cd8 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801cff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d03:	c7 44 24 08 d8 24 80 	movl   $0x8024d8,0x8(%esp)
  801d0a:	00 
  801d0b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801d12:	00 
  801d13:	c7 04 24 e6 24 80 00 	movl   $0x8024e6,(%esp)
  801d1a:	e8 49 e4 ff ff       	call   800168 <_panic>
		}
	}
}
  801d1f:	83 c4 1c             	add    $0x1c,%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5f                   	pop    %edi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	53                   	push   %ebx
  801d2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d2e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d33:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d3a:	89 c2                	mov    %eax,%edx
  801d3c:	c1 e2 07             	shl    $0x7,%edx
  801d3f:	29 ca                	sub    %ecx,%edx
  801d41:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d47:	8b 52 50             	mov    0x50(%edx),%edx
  801d4a:	39 da                	cmp    %ebx,%edx
  801d4c:	75 0f                	jne    801d5d <ipc_find_env+0x36>
			return envs[i].env_id;
  801d4e:	c1 e0 07             	shl    $0x7,%eax
  801d51:	29 c8                	sub    %ecx,%eax
  801d53:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d58:	8b 40 40             	mov    0x40(%eax),%eax
  801d5b:	eb 0c                	jmp    801d69 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d5d:	40                   	inc    %eax
  801d5e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d63:	75 ce                	jne    801d33 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d65:	66 b8 00 00          	mov    $0x0,%ax
}
  801d69:	5b                   	pop    %ebx
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    

00801d6c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d72:	89 c2                	mov    %eax,%edx
  801d74:	c1 ea 16             	shr    $0x16,%edx
  801d77:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d7e:	f6 c2 01             	test   $0x1,%dl
  801d81:	74 1e                	je     801da1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d83:	c1 e8 0c             	shr    $0xc,%eax
  801d86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d8d:	a8 01                	test   $0x1,%al
  801d8f:	74 17                	je     801da8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d91:	c1 e8 0c             	shr    $0xc,%eax
  801d94:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d9b:	ef 
  801d9c:	0f b7 c0             	movzwl %ax,%eax
  801d9f:	eb 0c                	jmp    801dad <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
  801da6:	eb 05                	jmp    801dad <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    
	...

00801db0 <__udivdi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	83 ec 10             	sub    $0x10,%esp
  801db6:	8b 74 24 20          	mov    0x20(%esp),%esi
  801dba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801dbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801dc6:	89 cd                	mov    %ecx,%ebp
  801dc8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	75 2c                	jne    801dfc <__udivdi3+0x4c>
  801dd0:	39 f9                	cmp    %edi,%ecx
  801dd2:	77 68                	ja     801e3c <__udivdi3+0x8c>
  801dd4:	85 c9                	test   %ecx,%ecx
  801dd6:	75 0b                	jne    801de3 <__udivdi3+0x33>
  801dd8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddd:	31 d2                	xor    %edx,%edx
  801ddf:	f7 f1                	div    %ecx
  801de1:	89 c1                	mov    %eax,%ecx
  801de3:	31 d2                	xor    %edx,%edx
  801de5:	89 f8                	mov    %edi,%eax
  801de7:	f7 f1                	div    %ecx
  801de9:	89 c7                	mov    %eax,%edi
  801deb:	89 f0                	mov    %esi,%eax
  801ded:	f7 f1                	div    %ecx
  801def:	89 c6                	mov    %eax,%esi
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	89 fa                	mov    %edi,%edx
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	5e                   	pop    %esi
  801df9:	5f                   	pop    %edi
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    
  801dfc:	39 f8                	cmp    %edi,%eax
  801dfe:	77 2c                	ja     801e2c <__udivdi3+0x7c>
  801e00:	0f bd f0             	bsr    %eax,%esi
  801e03:	83 f6 1f             	xor    $0x1f,%esi
  801e06:	75 4c                	jne    801e54 <__udivdi3+0xa4>
  801e08:	39 f8                	cmp    %edi,%eax
  801e0a:	bf 00 00 00 00       	mov    $0x0,%edi
  801e0f:	72 0a                	jb     801e1b <__udivdi3+0x6b>
  801e11:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e15:	0f 87 ad 00 00 00    	ja     801ec8 <__udivdi3+0x118>
  801e1b:	be 01 00 00 00       	mov    $0x1,%esi
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	89 fa                	mov    %edi,%edx
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    
  801e2b:	90                   	nop
  801e2c:	31 ff                	xor    %edi,%edi
  801e2e:	31 f6                	xor    %esi,%esi
  801e30:	89 f0                	mov    %esi,%eax
  801e32:	89 fa                	mov    %edi,%edx
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	5e                   	pop    %esi
  801e38:	5f                   	pop    %edi
  801e39:	5d                   	pop    %ebp
  801e3a:	c3                   	ret    
  801e3b:	90                   	nop
  801e3c:	89 fa                	mov    %edi,%edx
  801e3e:	89 f0                	mov    %esi,%eax
  801e40:	f7 f1                	div    %ecx
  801e42:	89 c6                	mov    %eax,%esi
  801e44:	31 ff                	xor    %edi,%edi
  801e46:	89 f0                	mov    %esi,%eax
  801e48:	89 fa                	mov    %edi,%edx
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	5e                   	pop    %esi
  801e4e:	5f                   	pop    %edi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    
  801e51:	8d 76 00             	lea    0x0(%esi),%esi
  801e54:	89 f1                	mov    %esi,%ecx
  801e56:	d3 e0                	shl    %cl,%eax
  801e58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e5c:	b8 20 00 00 00       	mov    $0x20,%eax
  801e61:	29 f0                	sub    %esi,%eax
  801e63:	89 ea                	mov    %ebp,%edx
  801e65:	88 c1                	mov    %al,%cl
  801e67:	d3 ea                	shr    %cl,%edx
  801e69:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e6d:	09 ca                	or     %ecx,%edx
  801e6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e73:	89 f1                	mov    %esi,%ecx
  801e75:	d3 e5                	shl    %cl,%ebp
  801e77:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801e7b:	89 fd                	mov    %edi,%ebp
  801e7d:	88 c1                	mov    %al,%cl
  801e7f:	d3 ed                	shr    %cl,%ebp
  801e81:	89 fa                	mov    %edi,%edx
  801e83:	89 f1                	mov    %esi,%ecx
  801e85:	d3 e2                	shl    %cl,%edx
  801e87:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e8b:	88 c1                	mov    %al,%cl
  801e8d:	d3 ef                	shr    %cl,%edi
  801e8f:	09 d7                	or     %edx,%edi
  801e91:	89 f8                	mov    %edi,%eax
  801e93:	89 ea                	mov    %ebp,%edx
  801e95:	f7 74 24 08          	divl   0x8(%esp)
  801e99:	89 d1                	mov    %edx,%ecx
  801e9b:	89 c7                	mov    %eax,%edi
  801e9d:	f7 64 24 0c          	mull   0xc(%esp)
  801ea1:	39 d1                	cmp    %edx,%ecx
  801ea3:	72 17                	jb     801ebc <__udivdi3+0x10c>
  801ea5:	74 09                	je     801eb0 <__udivdi3+0x100>
  801ea7:	89 fe                	mov    %edi,%esi
  801ea9:	31 ff                	xor    %edi,%edi
  801eab:	e9 41 ff ff ff       	jmp    801df1 <__udivdi3+0x41>
  801eb0:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eb4:	89 f1                	mov    %esi,%ecx
  801eb6:	d3 e2                	shl    %cl,%edx
  801eb8:	39 c2                	cmp    %eax,%edx
  801eba:	73 eb                	jae    801ea7 <__udivdi3+0xf7>
  801ebc:	8d 77 ff             	lea    -0x1(%edi),%esi
  801ebf:	31 ff                	xor    %edi,%edi
  801ec1:	e9 2b ff ff ff       	jmp    801df1 <__udivdi3+0x41>
  801ec6:	66 90                	xchg   %ax,%ax
  801ec8:	31 f6                	xor    %esi,%esi
  801eca:	e9 22 ff ff ff       	jmp    801df1 <__udivdi3+0x41>
	...

00801ed0 <__umoddi3>:
  801ed0:	55                   	push   %ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	83 ec 20             	sub    $0x20,%esp
  801ed6:	8b 44 24 30          	mov    0x30(%esp),%eax
  801eda:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801ede:	89 44 24 14          	mov    %eax,0x14(%esp)
  801ee2:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ee6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801eea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801eee:	89 c7                	mov    %eax,%edi
  801ef0:	89 f2                	mov    %esi,%edx
  801ef2:	85 ed                	test   %ebp,%ebp
  801ef4:	75 16                	jne    801f0c <__umoddi3+0x3c>
  801ef6:	39 f1                	cmp    %esi,%ecx
  801ef8:	0f 86 a6 00 00 00    	jbe    801fa4 <__umoddi3+0xd4>
  801efe:	f7 f1                	div    %ecx
  801f00:	89 d0                	mov    %edx,%eax
  801f02:	31 d2                	xor    %edx,%edx
  801f04:	83 c4 20             	add    $0x20,%esp
  801f07:	5e                   	pop    %esi
  801f08:	5f                   	pop    %edi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    
  801f0b:	90                   	nop
  801f0c:	39 f5                	cmp    %esi,%ebp
  801f0e:	0f 87 ac 00 00 00    	ja     801fc0 <__umoddi3+0xf0>
  801f14:	0f bd c5             	bsr    %ebp,%eax
  801f17:	83 f0 1f             	xor    $0x1f,%eax
  801f1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f1e:	0f 84 a8 00 00 00    	je     801fcc <__umoddi3+0xfc>
  801f24:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f28:	d3 e5                	shl    %cl,%ebp
  801f2a:	bf 20 00 00 00       	mov    $0x20,%edi
  801f2f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801f33:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f37:	89 f9                	mov    %edi,%ecx
  801f39:	d3 e8                	shr    %cl,%eax
  801f3b:	09 e8                	or     %ebp,%eax
  801f3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f45:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f49:	d3 e0                	shl    %cl,%eax
  801f4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f4f:	89 f2                	mov    %esi,%edx
  801f51:	d3 e2                	shl    %cl,%edx
  801f53:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f57:	d3 e0                	shl    %cl,%eax
  801f59:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801f5d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f61:	89 f9                	mov    %edi,%ecx
  801f63:	d3 e8                	shr    %cl,%eax
  801f65:	09 d0                	or     %edx,%eax
  801f67:	d3 ee                	shr    %cl,%esi
  801f69:	89 f2                	mov    %esi,%edx
  801f6b:	f7 74 24 18          	divl   0x18(%esp)
  801f6f:	89 d6                	mov    %edx,%esi
  801f71:	f7 64 24 0c          	mull   0xc(%esp)
  801f75:	89 c5                	mov    %eax,%ebp
  801f77:	89 d1                	mov    %edx,%ecx
  801f79:	39 d6                	cmp    %edx,%esi
  801f7b:	72 67                	jb     801fe4 <__umoddi3+0x114>
  801f7d:	74 75                	je     801ff4 <__umoddi3+0x124>
  801f7f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f83:	29 e8                	sub    %ebp,%eax
  801f85:	19 ce                	sbb    %ecx,%esi
  801f87:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f8b:	d3 e8                	shr    %cl,%eax
  801f8d:	89 f2                	mov    %esi,%edx
  801f8f:	89 f9                	mov    %edi,%ecx
  801f91:	d3 e2                	shl    %cl,%edx
  801f93:	09 d0                	or     %edx,%eax
  801f95:	89 f2                	mov    %esi,%edx
  801f97:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f9b:	d3 ea                	shr    %cl,%edx
  801f9d:	83 c4 20             	add    $0x20,%esp
  801fa0:	5e                   	pop    %esi
  801fa1:	5f                   	pop    %edi
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    
  801fa4:	85 c9                	test   %ecx,%ecx
  801fa6:	75 0b                	jne    801fb3 <__umoddi3+0xe3>
  801fa8:	b8 01 00 00 00       	mov    $0x1,%eax
  801fad:	31 d2                	xor    %edx,%edx
  801faf:	f7 f1                	div    %ecx
  801fb1:	89 c1                	mov    %eax,%ecx
  801fb3:	89 f0                	mov    %esi,%eax
  801fb5:	31 d2                	xor    %edx,%edx
  801fb7:	f7 f1                	div    %ecx
  801fb9:	89 f8                	mov    %edi,%eax
  801fbb:	e9 3e ff ff ff       	jmp    801efe <__umoddi3+0x2e>
  801fc0:	89 f2                	mov    %esi,%edx
  801fc2:	83 c4 20             	add    $0x20,%esp
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    
  801fc9:	8d 76 00             	lea    0x0(%esi),%esi
  801fcc:	39 f5                	cmp    %esi,%ebp
  801fce:	72 04                	jb     801fd4 <__umoddi3+0x104>
  801fd0:	39 f9                	cmp    %edi,%ecx
  801fd2:	77 06                	ja     801fda <__umoddi3+0x10a>
  801fd4:	89 f2                	mov    %esi,%edx
  801fd6:	29 cf                	sub    %ecx,%edi
  801fd8:	19 ea                	sbb    %ebp,%edx
  801fda:	89 f8                	mov    %edi,%eax
  801fdc:	83 c4 20             	add    $0x20,%esp
  801fdf:	5e                   	pop    %esi
  801fe0:	5f                   	pop    %edi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    
  801fe3:	90                   	nop
  801fe4:	89 d1                	mov    %edx,%ecx
  801fe6:	89 c5                	mov    %eax,%ebp
  801fe8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801fec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ff0:	eb 8d                	jmp    801f7f <__umoddi3+0xaf>
  801ff2:	66 90                	xchg   %ax,%ax
  801ff4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801ff8:	72 ea                	jb     801fe4 <__umoddi3+0x114>
  801ffa:	89 f1                	mov    %esi,%ecx
  801ffc:	eb 81                	jmp    801f7f <__umoddi3+0xaf>
