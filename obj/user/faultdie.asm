
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 a0 1f 80 00 	movl   $0x801fa0,(%esp)
  800054:	e8 3f 01 00 00       	call   800198 <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 99 0a 00 00       	call   800af7 <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 3f 0a 00 00       	call   800aa5 <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 26 0d 00 00       	call   800da0 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800096:	e8 5c 0a 00 00       	call   800af7 <sys_getenvid>
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a7:	c1 e0 07             	shl    $0x7,%eax
  8000aa:	29 d0                	sub    %edx,%eax
  8000ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b6:	85 f6                	test   %esi,%esi
  8000b8:	7e 07                	jle    8000c1 <libmain+0x39>
		binaryname = argv[0];
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c5:	89 34 24             	mov    %esi,(%esp)
  8000c8:	e8 9b ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 0a 00 00 00       	call   8000dc <exit>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    
  8000d9:	00 00                	add    %al,(%eax)
	...

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000e2:	e8 14 0f 00 00       	call   800ffb <close_all>
	sys_env_destroy(0);
  8000e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ee:	e8 b2 09 00 00       	call   800aa5 <sys_env_destroy>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	40                   	inc    %eax
  80010c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80010e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800113:	75 19                	jne    80012e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800115:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011c:	00 
  80011d:	8d 43 08             	lea    0x8(%ebx),%eax
  800120:	89 04 24             	mov    %eax,(%esp)
  800123:	e8 40 09 00 00       	call   800a68 <sys_cputs>
		b->idx = 0;
  800128:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80012e:	ff 43 04             	incl   0x4(%ebx)
}
  800131:	83 c4 14             	add    $0x14,%esp
  800134:	5b                   	pop    %ebx
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800140:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800147:	00 00 00 
	b.cnt = 0;
  80014a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800151:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800154:	8b 45 0c             	mov    0xc(%ebp),%eax
  800157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015b:	8b 45 08             	mov    0x8(%ebp),%eax
  80015e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800173:	e8 82 01 00 00       	call   8002fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800178:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 d8 08 00 00       	call   800a68 <sys_cputs>

	return b.cnt;
}
  800190:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 87 ff ff ff       	call   800137 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    
	...

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 3c             	sub    $0x3c,%esp
  8001bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c0:	89 d7                	mov    %edx,%edi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	75 08                	jne    8001e0 <printnum+0x2c>
  8001d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001de:	77 57                	ja     800237 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001e4:	4b                   	dec    %ebx
  8001e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	e8 2e 1b 00 00       	call   801d40 <__udivdi3>
  800212:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800216:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800221:	89 fa                	mov    %edi,%edx
  800223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800226:	e8 89 ff ff ff       	call   8001b4 <printnum>
  80022b:	eb 0f                	jmp    80023c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800231:	89 34 24             	mov    %esi,(%esp)
  800234:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800237:	4b                   	dec    %ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f f1                	jg     80022d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800240:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800244:	8b 45 10             	mov    0x10(%ebp),%eax
  800247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800252:	00 
  800253:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80025c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800260:	e8 fb 1b 00 00       	call   801e60 <__umoddi3>
  800265:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800269:	0f be 80 c6 1f 80 00 	movsbl 0x801fc6(%eax),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800276:	83 c4 3c             	add    $0x3c,%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800281:	83 fa 01             	cmp    $0x1,%edx
  800284:	7e 0e                	jle    800294 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	8b 52 04             	mov    0x4(%edx),%edx
  800292:	eb 22                	jmp    8002b6 <getuint+0x38>
	else if (lflag)
  800294:	85 d2                	test   %edx,%edx
  800296:	74 10                	je     8002a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a6:	eb 0e                	jmp    8002b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c6:	73 08                	jae    8002d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8002c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cb:	88 0a                	mov    %cl,(%edx)
  8002cd:	42                   	inc    %edx
  8002ce:	89 10                	mov    %edx,(%eax)
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002df:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	e8 02 00 00 00       	call   8002fa <vprintfmt>
	va_end(ap);
}
  8002f8:	c9                   	leave  
  8002f9:	c3                   	ret    

008002fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	57                   	push   %edi
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
  800300:	83 ec 4c             	sub    $0x4c,%esp
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800306:	8b 75 10             	mov    0x10(%ebp),%esi
  800309:	eb 12                	jmp    80031d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030b:	85 c0                	test   %eax,%eax
  80030d:	0f 84 6b 03 00 00    	je     80067e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800313:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031d:	0f b6 06             	movzbl (%esi),%eax
  800320:	46                   	inc    %esi
  800321:	83 f8 25             	cmp    $0x25,%eax
  800324:	75 e5                	jne    80030b <vprintfmt+0x11>
  800326:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80032a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800331:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800336:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	eb 26                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800347:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034b:	eb 1d                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800350:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800354:	eb 14                	jmp    80036a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800359:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800360:	eb 08                	jmp    80036a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800362:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800365:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	0f b6 06             	movzbl (%esi),%eax
  80036d:	8d 56 01             	lea    0x1(%esi),%edx
  800370:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800373:	8a 16                	mov    (%esi),%dl
  800375:	83 ea 23             	sub    $0x23,%edx
  800378:	80 fa 55             	cmp    $0x55,%dl
  80037b:	0f 87 e1 02 00 00    	ja     800662 <vprintfmt+0x368>
  800381:	0f b6 d2             	movzbl %dl,%edx
  800384:	ff 24 95 00 21 80 00 	jmp    *0x802100(,%edx,4)
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80038e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800393:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800396:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80039a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80039d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a0:	83 fa 09             	cmp    $0x9,%edx
  8003a3:	77 2a                	ja     8003cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a6:	eb eb                	jmp    800393 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 50 04             	lea    0x4(%eax),%edx
  8003ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b6:	eb 17                	jmp    8003cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003bc:	78 98                	js     800356 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c1:	eb a7                	jmp    80036a <vprintfmt+0x70>
  8003c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003cd:	eb 9b                	jmp    80036a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d3:	79 95                	jns    80036a <vprintfmt+0x70>
  8003d5:	eb 8b                	jmp    800362 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003db:	eb 8d                	jmp    80036a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f5:	e9 23 ff ff ff       	jmp    80031d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 00                	mov    (%eax),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	79 02                	jns    80040b <vprintfmt+0x111>
  800409:	f7 d8                	neg    %eax
  80040b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040d:	83 f8 0f             	cmp    $0xf,%eax
  800410:	7f 0b                	jg     80041d <vprintfmt+0x123>
  800412:	8b 04 85 60 22 80 00 	mov    0x802260(,%eax,4),%eax
  800419:	85 c0                	test   %eax,%eax
  80041b:	75 23                	jne    800440 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80041d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800421:	c7 44 24 08 de 1f 80 	movl   $0x801fde,0x8(%esp)
  800428:	00 
  800429:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	e8 9a fe ff ff       	call   8002d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043b:	e9 dd fe ff ff       	jmp    80031d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	c7 44 24 08 ba 23 80 	movl   $0x8023ba,0x8(%esp)
  80044b:	00 
  80044c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800450:	8b 55 08             	mov    0x8(%ebp),%edx
  800453:	89 14 24             	mov    %edx,(%esp)
  800456:	e8 77 fe ff ff       	call   8002d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045e:	e9 ba fe ff ff       	jmp    80031d <vprintfmt+0x23>
  800463:	89 f9                	mov    %edi,%ecx
  800465:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800468:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	8b 30                	mov    (%eax),%esi
  800476:	85 f6                	test   %esi,%esi
  800478:	75 05                	jne    80047f <vprintfmt+0x185>
				p = "(null)";
  80047a:	be d7 1f 80 00       	mov    $0x801fd7,%esi
			if (width > 0 && padc != '-')
  80047f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800483:	0f 8e 84 00 00 00    	jle    80050d <vprintfmt+0x213>
  800489:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80048d:	74 7e                	je     80050d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800493:	89 34 24             	mov    %esi,(%esp)
  800496:	e8 8b 02 00 00       	call   800726 <strnlen>
  80049b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049e:	29 c2                	sub    %eax,%edx
  8004a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004ad:	89 de                	mov    %ebx,%esi
  8004af:	89 d3                	mov    %edx,%ebx
  8004b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	eb 0b                	jmp    8004c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b9:	89 3c 24             	mov    %edi,(%esp)
  8004bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	4b                   	dec    %ebx
  8004c0:	85 db                	test   %ebx,%ebx
  8004c2:	7f f1                	jg     8004b5 <vprintfmt+0x1bb>
  8004c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c7:	89 f3                	mov    %esi,%ebx
  8004c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	79 05                	jns    8004d8 <vprintfmt+0x1de>
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004db:	29 c2                	sub    %eax,%edx
  8004dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e0:	eb 2b                	jmp    80050d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e6:	74 18                	je     800500 <vprintfmt+0x206>
  8004e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004eb:	83 fa 5e             	cmp    $0x5e,%edx
  8004ee:	76 10                	jbe    800500 <vprintfmt+0x206>
					putch('?', putdat);
  8004f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004fb:	ff 55 08             	call   *0x8(%ebp)
  8004fe:	eb 0a                	jmp    80050a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	ff 4d e4             	decl   -0x1c(%ebp)
  80050d:	0f be 06             	movsbl (%esi),%eax
  800510:	46                   	inc    %esi
  800511:	85 c0                	test   %eax,%eax
  800513:	74 21                	je     800536 <vprintfmt+0x23c>
  800515:	85 ff                	test   %edi,%edi
  800517:	78 c9                	js     8004e2 <vprintfmt+0x1e8>
  800519:	4f                   	dec    %edi
  80051a:	79 c6                	jns    8004e2 <vprintfmt+0x1e8>
  80051c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051f:	89 de                	mov    %ebx,%esi
  800521:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800524:	eb 18                	jmp    80053e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800526:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800531:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	4b                   	dec    %ebx
  800534:	eb 08                	jmp    80053e <vprintfmt+0x244>
  800536:	8b 7d 08             	mov    0x8(%ebp),%edi
  800539:	89 de                	mov    %ebx,%esi
  80053b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053e:	85 db                	test   %ebx,%ebx
  800540:	7f e4                	jg     800526 <vprintfmt+0x22c>
  800542:	89 7d 08             	mov    %edi,0x8(%ebp)
  800545:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054a:	e9 ce fd ff ff       	jmp    80031d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 f9 01             	cmp    $0x1,%ecx
  800552:	7e 10                	jle    800564 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 30                	mov    (%eax),%esi
  80055f:	8b 78 04             	mov    0x4(%eax),%edi
  800562:	eb 26                	jmp    80058a <vprintfmt+0x290>
	else if (lflag)
  800564:	85 c9                	test   %ecx,%ecx
  800566:	74 12                	je     80057a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 30                	mov    (%eax),%esi
  800573:	89 f7                	mov    %esi,%edi
  800575:	c1 ff 1f             	sar    $0x1f,%edi
  800578:	eb 10                	jmp    80058a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 50 04             	lea    0x4(%eax),%edx
  800580:	89 55 14             	mov    %edx,0x14(%ebp)
  800583:	8b 30                	mov    (%eax),%esi
  800585:	89 f7                	mov    %esi,%edi
  800587:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058a:	85 ff                	test   %edi,%edi
  80058c:	78 0a                	js     800598 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 8c 00 00 00       	jmp    800624 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a6:	f7 de                	neg    %esi
  8005a8:	83 d7 00             	adc    $0x0,%edi
  8005ab:	f7 df                	neg    %edi
			}
			base = 10;
  8005ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b2:	eb 70                	jmp    800624 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b4:	89 ca                	mov    %ecx,%edx
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 c0 fc ff ff       	call   80027e <getuint>
  8005be:	89 c6                	mov    %eax,%esi
  8005c0:	89 d7                	mov    %edx,%edi
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005c7:	eb 5b                	jmp    800624 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005c9:	89 ca                	mov    %ecx,%edx
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 ab fc ff ff       	call   80027e <getuint>
  8005d3:	89 c6                	mov    %eax,%esi
  8005d5:	89 d7                	mov    %edx,%edi
			base = 8;
  8005d7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005dc:	eb 46                	jmp    800624 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800603:	8b 30                	mov    (%eax),%esi
  800605:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060f:	eb 13                	jmp    800624 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800611:	89 ca                	mov    %ecx,%edx
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 63 fc ff ff       	call   80027e <getuint>
  80061b:	89 c6                	mov    %eax,%esi
  80061d:	89 d7                	mov    %edx,%edi
			base = 16;
  80061f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800624:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800628:	89 54 24 10          	mov    %edx,0x10(%esp)
  80062c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800633:	89 44 24 08          	mov    %eax,0x8(%esp)
  800637:	89 34 24             	mov    %esi,(%esp)
  80063a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063e:	89 da                	mov    %ebx,%edx
  800640:	8b 45 08             	mov    0x8(%ebp),%eax
  800643:	e8 6c fb ff ff       	call   8001b4 <printnum>
			break;
  800648:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064b:	e9 cd fc ff ff       	jmp    80031d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80065d:	e9 bb fc ff ff       	jmp    80031d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800662:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800666:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80066d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800670:	eb 01                	jmp    800673 <vprintfmt+0x379>
  800672:	4e                   	dec    %esi
  800673:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800677:	75 f9                	jne    800672 <vprintfmt+0x378>
  800679:	e9 9f fc ff ff       	jmp    80031d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80067e:	83 c4 4c             	add    $0x4c,%esp
  800681:	5b                   	pop    %ebx
  800682:	5e                   	pop    %esi
  800683:	5f                   	pop    %edi
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 28             	sub    $0x28,%esp
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800692:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800695:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800699:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	74 30                	je     8006d7 <vsnprintf+0x51>
  8006a7:	85 d2                	test   %edx,%edx
  8006a9:	7e 33                	jle    8006de <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c0:	c7 04 24 b8 02 80 00 	movl   $0x8002b8,(%esp)
  8006c7:	e8 2e fc ff ff       	call   8002fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d5:	eb 0c                	jmp    8006e3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006dc:	eb 05                	jmp    8006e3 <vsnprintf+0x5d>
  8006de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	89 04 24             	mov    %eax,(%esp)
  800706:	e8 7b ff ff ff       	call   800686 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    
  80070d:	00 00                	add    %al,(%eax)
	...

00800710 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	eb 01                	jmp    80071e <strlen+0xe>
		n++;
  80071d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800722:	75 f9                	jne    80071d <strlen+0xd>
		n++;
	return n;
}
  800724:	5d                   	pop    %ebp
  800725:	c3                   	ret    

00800726 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80072c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072f:	b8 00 00 00 00       	mov    $0x0,%eax
  800734:	eb 01                	jmp    800737 <strnlen+0x11>
		n++;
  800736:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	39 d0                	cmp    %edx,%eax
  800739:	74 06                	je     800741 <strnlen+0x1b>
  80073b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80073f:	75 f5                	jne    800736 <strnlen+0x10>
		n++;
	return n;
}
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074d:	ba 00 00 00 00       	mov    $0x0,%edx
  800752:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800755:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800758:	42                   	inc    %edx
  800759:	84 c9                	test   %cl,%cl
  80075b:	75 f5                	jne    800752 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80075d:	5b                   	pop    %ebx
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076a:	89 1c 24             	mov    %ebx,(%esp)
  80076d:	e8 9e ff ff ff       	call   800710 <strlen>
	strcpy(dst + len, src);
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
  800775:	89 54 24 04          	mov    %edx,0x4(%esp)
  800779:	01 d8                	add    %ebx,%eax
  80077b:	89 04 24             	mov    %eax,(%esp)
  80077e:	e8 c0 ff ff ff       	call   800743 <strcpy>
	return dst;
}
  800783:	89 d8                	mov    %ebx,%eax
  800785:	83 c4 08             	add    $0x8,%esp
  800788:	5b                   	pop    %ebx
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
  800796:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800799:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079e:	eb 0c                	jmp    8007ac <strncpy+0x21>
		*dst++ = *src;
  8007a0:	8a 1a                	mov    (%edx),%bl
  8007a2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	41                   	inc    %ecx
  8007ac:	39 f1                	cmp    %esi,%ecx
  8007ae:	75 f0                	jne    8007a0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	75 0a                	jne    8007d0 <strlcpy+0x1c>
  8007c6:	89 f0                	mov    %esi,%eax
  8007c8:	eb 1a                	jmp    8007e4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ca:	88 18                	mov    %bl,(%eax)
  8007cc:	40                   	inc    %eax
  8007cd:	41                   	inc    %ecx
  8007ce:	eb 02                	jmp    8007d2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007d2:	4a                   	dec    %edx
  8007d3:	74 0a                	je     8007df <strlcpy+0x2b>
  8007d5:	8a 19                	mov    (%ecx),%bl
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 ef                	jne    8007ca <strlcpy+0x16>
  8007db:	89 c2                	mov    %eax,%edx
  8007dd:	eb 02                	jmp    8007e1 <strlcpy+0x2d>
  8007df:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007e1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007e4:	29 f0                	sub    %esi,%eax
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f3:	eb 02                	jmp    8007f7 <strcmp+0xd>
		p++, q++;
  8007f5:	41                   	inc    %ecx
  8007f6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f7:	8a 01                	mov    (%ecx),%al
  8007f9:	84 c0                	test   %al,%al
  8007fb:	74 04                	je     800801 <strcmp+0x17>
  8007fd:	3a 02                	cmp    (%edx),%al
  8007ff:	74 f4                	je     8007f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800801:	0f b6 c0             	movzbl %al,%eax
  800804:	0f b6 12             	movzbl (%edx),%edx
  800807:	29 d0                	sub    %edx,%eax
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800815:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800818:	eb 03                	jmp    80081d <strncmp+0x12>
		n--, p++, q++;
  80081a:	4a                   	dec    %edx
  80081b:	40                   	inc    %eax
  80081c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081d:	85 d2                	test   %edx,%edx
  80081f:	74 14                	je     800835 <strncmp+0x2a>
  800821:	8a 18                	mov    (%eax),%bl
  800823:	84 db                	test   %bl,%bl
  800825:	74 04                	je     80082b <strncmp+0x20>
  800827:	3a 19                	cmp    (%ecx),%bl
  800829:	74 ef                	je     80081a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082b:	0f b6 00             	movzbl (%eax),%eax
  80082e:	0f b6 11             	movzbl (%ecx),%edx
  800831:	29 d0                	sub    %edx,%eax
  800833:	eb 05                	jmp    80083a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800846:	eb 05                	jmp    80084d <strchr+0x10>
		if (*s == c)
  800848:	38 ca                	cmp    %cl,%dl
  80084a:	74 0c                	je     800858 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084c:	40                   	inc    %eax
  80084d:	8a 10                	mov    (%eax),%dl
  80084f:	84 d2                	test   %dl,%dl
  800851:	75 f5                	jne    800848 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800863:	eb 05                	jmp    80086a <strfind+0x10>
		if (*s == c)
  800865:	38 ca                	cmp    %cl,%dl
  800867:	74 07                	je     800870 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800869:	40                   	inc    %eax
  80086a:	8a 10                	mov    (%eax),%dl
  80086c:	84 d2                	test   %dl,%dl
  80086e:	75 f5                	jne    800865 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800881:	85 c9                	test   %ecx,%ecx
  800883:	74 30                	je     8008b5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800885:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088b:	75 25                	jne    8008b2 <memset+0x40>
  80088d:	f6 c1 03             	test   $0x3,%cl
  800890:	75 20                	jne    8008b2 <memset+0x40>
		c &= 0xFF;
  800892:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800895:	89 d3                	mov    %edx,%ebx
  800897:	c1 e3 08             	shl    $0x8,%ebx
  80089a:	89 d6                	mov    %edx,%esi
  80089c:	c1 e6 18             	shl    $0x18,%esi
  80089f:	89 d0                	mov    %edx,%eax
  8008a1:	c1 e0 10             	shl    $0x10,%eax
  8008a4:	09 f0                	or     %esi,%eax
  8008a6:	09 d0                	or     %edx,%eax
  8008a8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ad:	fc                   	cld    
  8008ae:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b0:	eb 03                	jmp    8008b5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b2:	fc                   	cld    
  8008b3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b5:	89 f8                	mov    %edi,%eax
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5f                   	pop    %edi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ca:	39 c6                	cmp    %eax,%esi
  8008cc:	73 34                	jae    800902 <memmove+0x46>
  8008ce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d1:	39 d0                	cmp    %edx,%eax
  8008d3:	73 2d                	jae    800902 <memmove+0x46>
		s += n;
		d += n;
  8008d5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d8:	f6 c2 03             	test   $0x3,%dl
  8008db:	75 1b                	jne    8008f8 <memmove+0x3c>
  8008dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e3:	75 13                	jne    8008f8 <memmove+0x3c>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	75 0e                	jne    8008f8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ea:	83 ef 04             	sub    $0x4,%edi
  8008ed:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f3:	fd                   	std    
  8008f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f6:	eb 07                	jmp    8008ff <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f8:	4f                   	dec    %edi
  8008f9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fc:	fd                   	std    
  8008fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ff:	fc                   	cld    
  800900:	eb 20                	jmp    800922 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800902:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800908:	75 13                	jne    80091d <memmove+0x61>
  80090a:	a8 03                	test   $0x3,%al
  80090c:	75 0f                	jne    80091d <memmove+0x61>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 0a                	jne    80091d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800913:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800916:	89 c7                	mov    %eax,%edi
  800918:	fc                   	cld    
  800919:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091b:	eb 05                	jmp    800922 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091d:	89 c7                	mov    %eax,%edi
  80091f:	fc                   	cld    
  800920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80092c:	8b 45 10             	mov    0x10(%ebp),%eax
  80092f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	89 04 24             	mov    %eax,(%esp)
  800940:	e8 77 ff ff ff       	call   8008bc <memmove>
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	ba 00 00 00 00       	mov    $0x0,%edx
  80095b:	eb 16                	jmp    800973 <memcmp+0x2c>
		if (*s1 != *s2)
  80095d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800960:	42                   	inc    %edx
  800961:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800965:	38 c8                	cmp    %cl,%al
  800967:	74 0a                	je     800973 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800969:	0f b6 c0             	movzbl %al,%eax
  80096c:	0f b6 c9             	movzbl %cl,%ecx
  80096f:	29 c8                	sub    %ecx,%eax
  800971:	eb 09                	jmp    80097c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800973:	39 da                	cmp    %ebx,%edx
  800975:	75 e6                	jne    80095d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098a:	89 c2                	mov    %eax,%edx
  80098c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098f:	eb 05                	jmp    800996 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	38 08                	cmp    %cl,(%eax)
  800993:	74 05                	je     80099a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	40                   	inc    %eax
  800996:	39 d0                	cmp    %edx,%eax
  800998:	72 f7                	jb     800991 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a8:	eb 01                	jmp    8009ab <strtol+0xf>
		s++;
  8009aa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ab:	8a 02                	mov    (%edx),%al
  8009ad:	3c 20                	cmp    $0x20,%al
  8009af:	74 f9                	je     8009aa <strtol+0xe>
  8009b1:	3c 09                	cmp    $0x9,%al
  8009b3:	74 f5                	je     8009aa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b5:	3c 2b                	cmp    $0x2b,%al
  8009b7:	75 08                	jne    8009c1 <strtol+0x25>
		s++;
  8009b9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bf:	eb 13                	jmp    8009d4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c1:	3c 2d                	cmp    $0x2d,%al
  8009c3:	75 0a                	jne    8009cf <strtol+0x33>
		s++, neg = 1;
  8009c5:	8d 52 01             	lea    0x1(%edx),%edx
  8009c8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009cd:	eb 05                	jmp    8009d4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d4:	85 db                	test   %ebx,%ebx
  8009d6:	74 05                	je     8009dd <strtol+0x41>
  8009d8:	83 fb 10             	cmp    $0x10,%ebx
  8009db:	75 28                	jne    800a05 <strtol+0x69>
  8009dd:	8a 02                	mov    (%edx),%al
  8009df:	3c 30                	cmp    $0x30,%al
  8009e1:	75 10                	jne    8009f3 <strtol+0x57>
  8009e3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009e7:	75 0a                	jne    8009f3 <strtol+0x57>
		s += 2, base = 16;
  8009e9:	83 c2 02             	add    $0x2,%edx
  8009ec:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f1:	eb 12                	jmp    800a05 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009f3:	85 db                	test   %ebx,%ebx
  8009f5:	75 0e                	jne    800a05 <strtol+0x69>
  8009f7:	3c 30                	cmp    $0x30,%al
  8009f9:	75 05                	jne    800a00 <strtol+0x64>
		s++, base = 8;
  8009fb:	42                   	inc    %edx
  8009fc:	b3 08                	mov    $0x8,%bl
  8009fe:	eb 05                	jmp    800a05 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a00:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0c:	8a 0a                	mov    (%edx),%cl
  800a0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a11:	80 fb 09             	cmp    $0x9,%bl
  800a14:	77 08                	ja     800a1e <strtol+0x82>
			dig = *s - '0';
  800a16:	0f be c9             	movsbl %cl,%ecx
  800a19:	83 e9 30             	sub    $0x30,%ecx
  800a1c:	eb 1e                	jmp    800a3c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 08                	ja     800a2e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a26:	0f be c9             	movsbl %cl,%ecx
  800a29:	83 e9 57             	sub    $0x57,%ecx
  800a2c:	eb 0e                	jmp    800a3c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a31:	80 fb 19             	cmp    $0x19,%bl
  800a34:	77 12                	ja     800a48 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a36:	0f be c9             	movsbl %cl,%ecx
  800a39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a3c:	39 f1                	cmp    %esi,%ecx
  800a3e:	7d 0c                	jge    800a4c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a40:	42                   	inc    %edx
  800a41:	0f af c6             	imul   %esi,%eax
  800a44:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a46:	eb c4                	jmp    800a0c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a48:	89 c1                	mov    %eax,%ecx
  800a4a:	eb 02                	jmp    800a4e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a4c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a52:	74 05                	je     800a59 <strtol+0xbd>
		*endptr = (char *) s;
  800a54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a57:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	74 04                	je     800a61 <strtol+0xc5>
  800a5d:	89 c8                	mov    %ecx,%eax
  800a5f:	f7 d8                	neg    %eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
	...

00800a68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	89 c3                	mov    %eax,%ebx
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	89 c6                	mov    %eax,%esi
  800a7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 01 00 00 00       	mov    $0x1,%eax
  800a96:	89 d1                	mov    %edx,%ecx
  800a98:	89 d3                	mov    %edx,%ebx
  800a9a:	89 d7                	mov    %edx,%edi
  800a9c:	89 d6                	mov    %edx,%esi
  800a9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	89 cb                	mov    %ecx,%ebx
  800abd:	89 cf                	mov    %ecx,%edi
  800abf:	89 ce                	mov    %ecx,%esi
  800ac1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	7e 28                	jle    800aef <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800acb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ad2:	00 
  800ad3:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800ada:	00 
  800adb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ae2:	00 
  800ae3:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800aea:	e8 9d 10 00 00       	call   801b8c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aef:	83 c4 2c             	add    $0x2c,%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afd:	ba 00 00 00 00       	mov    $0x0,%edx
  800b02:	b8 02 00 00 00       	mov    $0x2,%eax
  800b07:	89 d1                	mov    %edx,%ecx
  800b09:	89 d3                	mov    %edx,%ebx
  800b0b:	89 d7                	mov    %edx,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_yield>:

void
sys_yield(void)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b26:	89 d1                	mov    %edx,%ecx
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	89 d7                	mov    %edx,%edi
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	be 00 00 00 00       	mov    $0x0,%esi
  800b43:	b8 04 00 00 00       	mov    $0x4,%eax
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 f7                	mov    %esi,%edi
  800b53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	7e 28                	jle    800b81 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b5d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b64:	00 
  800b65:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800b6c:	00 
  800b6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b74:	00 
  800b75:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800b7c:	e8 0b 10 00 00       	call   801b8c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b81:	83 c4 2c             	add    $0x2c,%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	b8 05 00 00 00       	mov    $0x5,%eax
  800b97:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7e 28                	jle    800bd4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bb7:	00 
  800bb8:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800bbf:	00 
  800bc0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc7:	00 
  800bc8:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800bcf:	e8 b8 0f 00 00       	call   801b8c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd4:	83 c4 2c             	add    $0x2c,%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 06 00 00 00       	mov    $0x6,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 28                	jle    800c27 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c03:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800c12:	00 
  800c13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1a:	00 
  800c1b:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800c22:	e8 65 0f 00 00       	call   801b8c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c27:	83 c4 2c             	add    $0x2c,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	89 df                	mov    %ebx,%edi
  800c4a:	89 de                	mov    %ebx,%esi
  800c4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7e 28                	jle    800c7a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c56:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c5d:	00 
  800c5e:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800c65:	00 
  800c66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6d:	00 
  800c6e:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800c75:	e8 12 0f 00 00       	call   801b8c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7a:	83 c4 2c             	add    $0x2c,%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 09 00 00 00       	mov    $0x9,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 28                	jle    800ccd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc0:	00 
  800cc1:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800cc8:	e8 bf 0e 00 00       	call   801b8c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ccd:	83 c4 2c             	add    $0x2c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 df                	mov    %ebx,%edi
  800cf0:	89 de                	mov    %ebx,%esi
  800cf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 28                	jle    800d20 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d03:	00 
  800d04:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800d0b:	00 
  800d0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d13:	00 
  800d14:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800d1b:	e8 6c 0e 00 00       	call   801b8c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d20:	83 c4 2c             	add    $0x2c,%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 cb                	mov    %ecx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
  800d65:	89 ce                	mov    %ecx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800d90:	e8 f7 0d 00 00       	call   801b8c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d95:	83 c4 2c             	add    $0x2c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    
  800d9d:	00 00                	add    %al,(%eax)
	...

00800da0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800da6:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dad:	75 32                	jne    800de1 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  800daf:	e8 43 fd ff ff       	call   800af7 <sys_getenvid>
  800db4:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800dc3:	ee 
  800dc4:	89 04 24             	mov    %eax,(%esp)
  800dc7:	e8 69 fd ff ff       	call   800b35 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  800dcc:	e8 26 fd ff ff       	call   800af7 <sys_getenvid>
  800dd1:	c7 44 24 04 ec 0d 80 	movl   $0x800dec,0x4(%esp)
  800dd8:	00 
  800dd9:	89 04 24             	mov    %eax,(%esp)
  800ddc:	e8 f4 fe ff ff       	call   800cd5 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    
	...

00800dec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ded:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800df2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800df4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  800df7:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  800dfb:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  800dfe:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  800e03:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  800e07:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  800e0a:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  800e0b:	83 c4 04             	add    $0x4,%esp
	popfl
  800e0e:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  800e0f:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  800e10:	c3                   	ret    
  800e11:	00 00                	add    %al,(%eax)
	...

00800e14 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	89 04 24             	mov    %eax,(%esp)
  800e30:	e8 df ff ff ff       	call   800e14 <fd2num>
  800e35:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e3a:	c1 e0 0c             	shl    $0xc,%eax
}
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	53                   	push   %ebx
  800e43:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e46:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e4b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	c1 ea 16             	shr    $0x16,%edx
  800e52:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e59:	f6 c2 01             	test   $0x1,%dl
  800e5c:	74 11                	je     800e6f <fd_alloc+0x30>
  800e5e:	89 c2                	mov    %eax,%edx
  800e60:	c1 ea 0c             	shr    $0xc,%edx
  800e63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6a:	f6 c2 01             	test   $0x1,%dl
  800e6d:	75 09                	jne    800e78 <fd_alloc+0x39>
			*fd_store = fd;
  800e6f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	eb 17                	jmp    800e8f <fd_alloc+0x50>
  800e78:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e7d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e82:	75 c7                	jne    800e4b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e8a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e8f:	5b                   	pop    %ebx
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e98:	83 f8 1f             	cmp    $0x1f,%eax
  800e9b:	77 36                	ja     800ed3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e9d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800ea2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	c1 ea 16             	shr    $0x16,%edx
  800eaa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb1:	f6 c2 01             	test   $0x1,%dl
  800eb4:	74 24                	je     800eda <fd_lookup+0x48>
  800eb6:	89 c2                	mov    %eax,%edx
  800eb8:	c1 ea 0c             	shr    $0xc,%edx
  800ebb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec2:	f6 c2 01             	test   $0x1,%dl
  800ec5:	74 1a                	je     800ee1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ec7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eca:	89 02                	mov    %eax,(%edx)
	return 0;
  800ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed1:	eb 13                	jmp    800ee6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed8:	eb 0c                	jmp    800ee6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edf:	eb 05                	jmp    800ee6 <fd_lookup+0x54>
  800ee1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 14             	sub    $0x14,%esp
  800eef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800ef5:	ba 00 00 00 00       	mov    $0x0,%edx
  800efa:	eb 0e                	jmp    800f0a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800efc:	39 08                	cmp    %ecx,(%eax)
  800efe:	75 09                	jne    800f09 <dev_lookup+0x21>
			*dev = devtab[i];
  800f00:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	eb 33                	jmp    800f3c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f09:	42                   	inc    %edx
  800f0a:	8b 04 95 68 23 80 00 	mov    0x802368(,%edx,4),%eax
  800f11:	85 c0                	test   %eax,%eax
  800f13:	75 e7                	jne    800efc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f15:	a1 04 40 80 00       	mov    0x804004,%eax
  800f1a:	8b 40 48             	mov    0x48(%eax),%eax
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f25:	c7 04 24 ec 22 80 00 	movl   $0x8022ec,(%esp)
  800f2c:	e8 67 f2 ff ff       	call   800198 <cprintf>
	*dev = 0;
  800f31:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f3c:	83 c4 14             	add    $0x14,%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	83 ec 30             	sub    $0x30,%esp
  800f4a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4d:	8a 45 0c             	mov    0xc(%ebp),%al
  800f50:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f53:	89 34 24             	mov    %esi,(%esp)
  800f56:	e8 b9 fe ff ff       	call   800e14 <fd2num>
  800f5b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f62:	89 04 24             	mov    %eax,(%esp)
  800f65:	e8 28 ff ff ff       	call   800e92 <fd_lookup>
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 05                	js     800f75 <fd_close+0x33>
	    || fd != fd2)
  800f70:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f73:	74 0d                	je     800f82 <fd_close+0x40>
		return (must_exist ? r : 0);
  800f75:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f79:	75 46                	jne    800fc1 <fd_close+0x7f>
  800f7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f80:	eb 3f                	jmp    800fc1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f89:	8b 06                	mov    (%esi),%eax
  800f8b:	89 04 24             	mov    %eax,(%esp)
  800f8e:	e8 55 ff ff ff       	call   800ee8 <dev_lookup>
  800f93:	89 c3                	mov    %eax,%ebx
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 18                	js     800fb1 <fd_close+0x6f>
		if (dev->dev_close)
  800f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f9c:	8b 40 10             	mov    0x10(%eax),%eax
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	74 09                	je     800fac <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fa3:	89 34 24             	mov    %esi,(%esp)
  800fa6:	ff d0                	call   *%eax
  800fa8:	89 c3                	mov    %eax,%ebx
  800faa:	eb 05                	jmp    800fb1 <fd_close+0x6f>
		else
			r = 0;
  800fac:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fbc:	e8 1b fc ff ff       	call   800bdc <sys_page_unmap>
	return r;
}
  800fc1:	89 d8                	mov    %ebx,%eax
  800fc3:	83 c4 30             	add    $0x30,%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fda:	89 04 24             	mov    %eax,(%esp)
  800fdd:	e8 b0 fe ff ff       	call   800e92 <fd_lookup>
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 13                	js     800ff9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800fe6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fed:	00 
  800fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff1:	89 04 24             	mov    %eax,(%esp)
  800ff4:	e8 49 ff ff ff       	call   800f42 <fd_close>
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <close_all>:

void
close_all(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801007:	89 1c 24             	mov    %ebx,(%esp)
  80100a:	e8 bb ff ff ff       	call   800fca <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80100f:	43                   	inc    %ebx
  801010:	83 fb 20             	cmp    $0x20,%ebx
  801013:	75 f2                	jne    801007 <close_all+0xc>
		close(i);
}
  801015:	83 c4 14             	add    $0x14,%esp
  801018:	5b                   	pop    %ebx
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 4c             	sub    $0x4c,%esp
  801024:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801027:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102e:	8b 45 08             	mov    0x8(%ebp),%eax
  801031:	89 04 24             	mov    %eax,(%esp)
  801034:	e8 59 fe ff ff       	call   800e92 <fd_lookup>
  801039:	89 c3                	mov    %eax,%ebx
  80103b:	85 c0                	test   %eax,%eax
  80103d:	0f 88 e1 00 00 00    	js     801124 <dup+0x109>
		return r;
	close(newfdnum);
  801043:	89 3c 24             	mov    %edi,(%esp)
  801046:	e8 7f ff ff ff       	call   800fca <close>

	newfd = INDEX2FD(newfdnum);
  80104b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801051:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	e8 c5 fd ff ff       	call   800e24 <fd2data>
  80105f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801061:	89 34 24             	mov    %esi,(%esp)
  801064:	e8 bb fd ff ff       	call   800e24 <fd2data>
  801069:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	c1 e8 16             	shr    $0x16,%eax
  801071:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801078:	a8 01                	test   $0x1,%al
  80107a:	74 46                	je     8010c2 <dup+0xa7>
  80107c:	89 d8                	mov    %ebx,%eax
  80107e:	c1 e8 0c             	shr    $0xc,%eax
  801081:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801088:	f6 c2 01             	test   $0x1,%dl
  80108b:	74 35                	je     8010c2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80108d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801094:	25 07 0e 00 00       	and    $0xe07,%eax
  801099:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010ab:	00 
  8010ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b7:	e8 cd fa ff ff       	call   800b89 <sys_page_map>
  8010bc:	89 c3                	mov    %eax,%ebx
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	78 3b                	js     8010fd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c5:	89 c2                	mov    %eax,%edx
  8010c7:	c1 ea 0c             	shr    $0xc,%edx
  8010ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e6:	00 
  8010e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f2:	e8 92 fa ff ff       	call   800b89 <sys_page_map>
  8010f7:	89 c3                	mov    %eax,%ebx
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	79 25                	jns    801122 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801108:	e8 cf fa ff ff       	call   800bdc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80110d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801110:	89 44 24 04          	mov    %eax,0x4(%esp)
  801114:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80111b:	e8 bc fa ff ff       	call   800bdc <sys_page_unmap>
	return r;
  801120:	eb 02                	jmp    801124 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801122:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801124:	89 d8                	mov    %ebx,%eax
  801126:	83 c4 4c             	add    $0x4c,%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	53                   	push   %ebx
  801132:	83 ec 24             	sub    $0x24,%esp
  801135:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801138:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113f:	89 1c 24             	mov    %ebx,(%esp)
  801142:	e8 4b fd ff ff       	call   800e92 <fd_lookup>
  801147:	85 c0                	test   %eax,%eax
  801149:	78 6d                	js     8011b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801152:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801155:	8b 00                	mov    (%eax),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	e8 89 fd ff ff       	call   800ee8 <dev_lookup>
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 55                	js     8011b8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801166:	8b 50 08             	mov    0x8(%eax),%edx
  801169:	83 e2 03             	and    $0x3,%edx
  80116c:	83 fa 01             	cmp    $0x1,%edx
  80116f:	75 23                	jne    801194 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801171:	a1 04 40 80 00       	mov    0x804004,%eax
  801176:	8b 40 48             	mov    0x48(%eax),%eax
  801179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80117d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801181:	c7 04 24 2d 23 80 00 	movl   $0x80232d,(%esp)
  801188:	e8 0b f0 ff ff       	call   800198 <cprintf>
		return -E_INVAL;
  80118d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801192:	eb 24                	jmp    8011b8 <read+0x8a>
	}
	if (!dev->dev_read)
  801194:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801197:	8b 52 08             	mov    0x8(%edx),%edx
  80119a:	85 d2                	test   %edx,%edx
  80119c:	74 15                	je     8011b3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80119e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011ac:	89 04 24             	mov    %eax,(%esp)
  8011af:	ff d2                	call   *%edx
  8011b1:	eb 05                	jmp    8011b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011b8:	83 c4 24             	add    $0x24,%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 1c             	sub    $0x1c,%esp
  8011c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d2:	eb 23                	jmp    8011f7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d4:	89 f0                	mov    %esi,%eax
  8011d6:	29 d8                	sub    %ebx,%eax
  8011d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011df:	01 d8                	add    %ebx,%eax
  8011e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e5:	89 3c 24             	mov    %edi,(%esp)
  8011e8:	e8 41 ff ff ff       	call   80112e <read>
		if (m < 0)
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 10                	js     801201 <readn+0x43>
			return m;
		if (m == 0)
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	74 0a                	je     8011ff <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f5:	01 c3                	add    %eax,%ebx
  8011f7:	39 f3                	cmp    %esi,%ebx
  8011f9:	72 d9                	jb     8011d4 <readn+0x16>
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	eb 02                	jmp    801201 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011ff:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801201:	83 c4 1c             	add    $0x1c,%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	53                   	push   %ebx
  80120d:	83 ec 24             	sub    $0x24,%esp
  801210:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801213:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121a:	89 1c 24             	mov    %ebx,(%esp)
  80121d:	e8 70 fc ff ff       	call   800e92 <fd_lookup>
  801222:	85 c0                	test   %eax,%eax
  801224:	78 68                	js     80128e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801226:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801230:	8b 00                	mov    (%eax),%eax
  801232:	89 04 24             	mov    %eax,(%esp)
  801235:	e8 ae fc ff ff       	call   800ee8 <dev_lookup>
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 50                	js     80128e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801245:	75 23                	jne    80126a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801247:	a1 04 40 80 00       	mov    0x804004,%eax
  80124c:	8b 40 48             	mov    0x48(%eax),%eax
  80124f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801253:	89 44 24 04          	mov    %eax,0x4(%esp)
  801257:	c7 04 24 49 23 80 00 	movl   $0x802349,(%esp)
  80125e:	e8 35 ef ff ff       	call   800198 <cprintf>
		return -E_INVAL;
  801263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801268:	eb 24                	jmp    80128e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80126a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126d:	8b 52 0c             	mov    0xc(%edx),%edx
  801270:	85 d2                	test   %edx,%edx
  801272:	74 15                	je     801289 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801274:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801277:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80127b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801282:	89 04 24             	mov    %eax,(%esp)
  801285:	ff d2                	call   *%edx
  801287:	eb 05                	jmp    80128e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801289:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80128e:	83 c4 24             	add    $0x24,%esp
  801291:	5b                   	pop    %ebx
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <seek>:

int
seek(int fdnum, off_t offset)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a4:	89 04 24             	mov    %eax,(%esp)
  8012a7:	e8 e6 fb ff ff       	call   800e92 <fd_lookup>
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 0e                	js     8012be <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 24             	sub    $0x24,%esp
  8012c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	89 1c 24             	mov    %ebx,(%esp)
  8012d4:	e8 b9 fb ff ff       	call   800e92 <fd_lookup>
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 61                	js     80133e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e7:	8b 00                	mov    (%eax),%eax
  8012e9:	89 04 24             	mov    %eax,(%esp)
  8012ec:	e8 f7 fb ff ff       	call   800ee8 <dev_lookup>
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 49                	js     80133e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fc:	75 23                	jne    801321 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fe:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801303:	8b 40 48             	mov    0x48(%eax),%eax
  801306:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130e:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  801315:	e8 7e ee ff ff       	call   800198 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80131a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131f:	eb 1d                	jmp    80133e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801321:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801324:	8b 52 18             	mov    0x18(%edx),%edx
  801327:	85 d2                	test   %edx,%edx
  801329:	74 0e                	je     801339 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	ff d2                	call   *%edx
  801337:	eb 05                	jmp    80133e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801339:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80133e:	83 c4 24             	add    $0x24,%esp
  801341:	5b                   	pop    %ebx
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	53                   	push   %ebx
  801348:	83 ec 24             	sub    $0x24,%esp
  80134b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801351:	89 44 24 04          	mov    %eax,0x4(%esp)
  801355:	8b 45 08             	mov    0x8(%ebp),%eax
  801358:	89 04 24             	mov    %eax,(%esp)
  80135b:	e8 32 fb ff ff       	call   800e92 <fd_lookup>
  801360:	85 c0                	test   %eax,%eax
  801362:	78 52                	js     8013b6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	8b 00                	mov    (%eax),%eax
  801370:	89 04 24             	mov    %eax,(%esp)
  801373:	e8 70 fb ff ff       	call   800ee8 <dev_lookup>
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 3a                	js     8013b6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80137c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801383:	74 2c                	je     8013b1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801385:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801388:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138f:	00 00 00 
	stat->st_isdir = 0;
  801392:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801399:	00 00 00 
	stat->st_dev = dev;
  80139c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a9:	89 14 24             	mov    %edx,(%esp)
  8013ac:	ff 50 14             	call   *0x14(%eax)
  8013af:	eb 05                	jmp    8013b6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013b6:	83 c4 24             	add    $0x24,%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013cb:	00 
  8013cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cf:	89 04 24             	mov    %eax,(%esp)
  8013d2:	e8 fe 01 00 00       	call   8015d5 <open>
  8013d7:	89 c3                	mov    %eax,%ebx
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 1b                	js     8013f8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e4:	89 1c 24             	mov    %ebx,(%esp)
  8013e7:	e8 58 ff ff ff       	call   801344 <fstat>
  8013ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ee:	89 1c 24             	mov    %ebx,(%esp)
  8013f1:	e8 d4 fb ff ff       	call   800fca <close>
	return r;
  8013f6:	89 f3                	mov    %esi,%ebx
}
  8013f8:	89 d8                	mov    %ebx,%eax
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    
  801401:	00 00                	add    %al,(%eax)
	...

00801404 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	83 ec 10             	sub    $0x10,%esp
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801410:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801417:	75 11                	jne    80142a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801419:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801420:	e8 92 08 00 00       	call   801cb7 <ipc_find_env>
  801425:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801431:	00 
  801432:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801439:	00 
  80143a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80143e:	a1 00 40 80 00       	mov    0x804000,%eax
  801443:	89 04 24             	mov    %eax,(%esp)
  801446:	e8 02 08 00 00       	call   801c4d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801452:	00 
  801453:	89 74 24 04          	mov    %esi,0x4(%esp)
  801457:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145e:	e8 81 07 00 00       	call   801be4 <ipc_recv>
}
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	5b                   	pop    %ebx
  801467:	5e                   	pop    %esi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801470:	8b 45 08             	mov    0x8(%ebp),%eax
  801473:	8b 40 0c             	mov    0xc(%eax),%eax
  801476:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80147b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801483:	ba 00 00 00 00       	mov    $0x0,%edx
  801488:	b8 02 00 00 00       	mov    $0x2,%eax
  80148d:	e8 72 ff ff ff       	call   801404 <fsipc>
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8014af:	e8 50 ff ff ff       	call   801404 <fsipc>
}
  8014b4:	c9                   	leave  
  8014b5:	c3                   	ret    

008014b6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	53                   	push   %ebx
  8014ba:	83 ec 14             	sub    $0x14,%esp
  8014bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d5:	e8 2a ff ff ff       	call   801404 <fsipc>
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 2b                	js     801509 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014de:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014e5:	00 
  8014e6:	89 1c 24             	mov    %ebx,(%esp)
  8014e9:	e8 55 f2 ff ff       	call   800743 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801504:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801509:	83 c4 14             	add    $0x14,%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801515:	c7 44 24 08 78 23 80 	movl   $0x802378,0x8(%esp)
  80151c:	00 
  80151d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801524:	00 
  801525:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  80152c:	e8 5b 06 00 00       	call   801b8c <_panic>

00801531 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 10             	sub    $0x10,%esp
  801539:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80153c:	8b 45 08             	mov    0x8(%ebp),%eax
  80153f:	8b 40 0c             	mov    0xc(%eax),%eax
  801542:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801547:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80154d:	ba 00 00 00 00       	mov    $0x0,%edx
  801552:	b8 03 00 00 00       	mov    $0x3,%eax
  801557:	e8 a8 fe ff ff       	call   801404 <fsipc>
  80155c:	89 c3                	mov    %eax,%ebx
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 6a                	js     8015cc <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801562:	39 c6                	cmp    %eax,%esi
  801564:	73 24                	jae    80158a <devfile_read+0x59>
  801566:	c7 44 24 0c a1 23 80 	movl   $0x8023a1,0xc(%esp)
  80156d:	00 
  80156e:	c7 44 24 08 a8 23 80 	movl   $0x8023a8,0x8(%esp)
  801575:	00 
  801576:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80157d:	00 
  80157e:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  801585:	e8 02 06 00 00       	call   801b8c <_panic>
	assert(r <= PGSIZE);
  80158a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80158f:	7e 24                	jle    8015b5 <devfile_read+0x84>
  801591:	c7 44 24 0c bd 23 80 	movl   $0x8023bd,0xc(%esp)
  801598:	00 
  801599:	c7 44 24 08 a8 23 80 	movl   $0x8023a8,0x8(%esp)
  8015a0:	00 
  8015a1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8015a8:	00 
  8015a9:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  8015b0:	e8 d7 05 00 00       	call   801b8c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b9:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015c0:	00 
  8015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c4:	89 04 24             	mov    %eax,(%esp)
  8015c7:	e8 f0 f2 ff ff       	call   8008bc <memmove>
	return r;
}
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 20             	sub    $0x20,%esp
  8015dd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015e0:	89 34 24             	mov    %esi,(%esp)
  8015e3:	e8 28 f1 ff ff       	call   800710 <strlen>
  8015e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ed:	7f 60                	jg     80164f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 45 f8 ff ff       	call   800e3f <fd_alloc>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 54                	js     801654 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801600:	89 74 24 04          	mov    %esi,0x4(%esp)
  801604:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80160b:	e8 33 f1 ff ff       	call   800743 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801610:	8b 45 0c             	mov    0xc(%ebp),%eax
  801613:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801618:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161b:	b8 01 00 00 00       	mov    $0x1,%eax
  801620:	e8 df fd ff ff       	call   801404 <fsipc>
  801625:	89 c3                	mov    %eax,%ebx
  801627:	85 c0                	test   %eax,%eax
  801629:	79 15                	jns    801640 <open+0x6b>
		fd_close(fd, 0);
  80162b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801632:	00 
  801633:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801636:	89 04 24             	mov    %eax,(%esp)
  801639:	e8 04 f9 ff ff       	call   800f42 <fd_close>
		return r;
  80163e:	eb 14                	jmp    801654 <open+0x7f>
	}

	return fd2num(fd);
  801640:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801643:	89 04 24             	mov    %eax,(%esp)
  801646:	e8 c9 f7 ff ff       	call   800e14 <fd2num>
  80164b:	89 c3                	mov    %eax,%ebx
  80164d:	eb 05                	jmp    801654 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801654:	89 d8                	mov    %ebx,%eax
  801656:	83 c4 20             	add    $0x20,%esp
  801659:	5b                   	pop    %ebx
  80165a:	5e                   	pop    %esi
  80165b:	5d                   	pop    %ebp
  80165c:	c3                   	ret    

0080165d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801663:	ba 00 00 00 00       	mov    $0x0,%edx
  801668:	b8 08 00 00 00       	mov    $0x8,%eax
  80166d:	e8 92 fd ff ff       	call   801404 <fsipc>
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	83 ec 10             	sub    $0x10,%esp
  80167c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	89 04 24             	mov    %eax,(%esp)
  801685:	e8 9a f7 ff ff       	call   800e24 <fd2data>
  80168a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80168c:	c7 44 24 04 c9 23 80 	movl   $0x8023c9,0x4(%esp)
  801693:	00 
  801694:	89 34 24             	mov    %esi,(%esp)
  801697:	e8 a7 f0 ff ff       	call   800743 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80169c:	8b 43 04             	mov    0x4(%ebx),%eax
  80169f:	2b 03                	sub    (%ebx),%eax
  8016a1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8016a7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8016ae:	00 00 00 
	stat->st_dev = &devpipe;
  8016b1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8016b8:	30 80 00 
	return 0;
}
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 14             	sub    $0x14,%esp
  8016ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016dc:	e8 fb f4 ff ff       	call   800bdc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016e1:	89 1c 24             	mov    %ebx,(%esp)
  8016e4:	e8 3b f7 ff ff       	call   800e24 <fd2data>
  8016e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f4:	e8 e3 f4 ff ff       	call   800bdc <sys_page_unmap>
}
  8016f9:	83 c4 14             	add    $0x14,%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	57                   	push   %edi
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	83 ec 2c             	sub    $0x2c,%esp
  801708:	89 c7                	mov    %eax,%edi
  80170a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80170d:	a1 04 40 80 00       	mov    0x804004,%eax
  801712:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801715:	89 3c 24             	mov    %edi,(%esp)
  801718:	e8 df 05 00 00       	call   801cfc <pageref>
  80171d:	89 c6                	mov    %eax,%esi
  80171f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801722:	89 04 24             	mov    %eax,(%esp)
  801725:	e8 d2 05 00 00       	call   801cfc <pageref>
  80172a:	39 c6                	cmp    %eax,%esi
  80172c:	0f 94 c0             	sete   %al
  80172f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801732:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801738:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80173b:	39 cb                	cmp    %ecx,%ebx
  80173d:	75 08                	jne    801747 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80173f:	83 c4 2c             	add    $0x2c,%esp
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5f                   	pop    %edi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801747:	83 f8 01             	cmp    $0x1,%eax
  80174a:	75 c1                	jne    80170d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80174c:	8b 42 58             	mov    0x58(%edx),%eax
  80174f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801756:	00 
  801757:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80175f:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  801766:	e8 2d ea ff ff       	call   800198 <cprintf>
  80176b:	eb a0                	jmp    80170d <_pipeisclosed+0xe>

0080176d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	57                   	push   %edi
  801771:	56                   	push   %esi
  801772:	53                   	push   %ebx
  801773:	83 ec 1c             	sub    $0x1c,%esp
  801776:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801779:	89 34 24             	mov    %esi,(%esp)
  80177c:	e8 a3 f6 ff ff       	call   800e24 <fd2data>
  801781:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801783:	bf 00 00 00 00       	mov    $0x0,%edi
  801788:	eb 3c                	jmp    8017c6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80178a:	89 da                	mov    %ebx,%edx
  80178c:	89 f0                	mov    %esi,%eax
  80178e:	e8 6c ff ff ff       	call   8016ff <_pipeisclosed>
  801793:	85 c0                	test   %eax,%eax
  801795:	75 38                	jne    8017cf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801797:	e8 7a f3 ff ff       	call   800b16 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80179c:	8b 43 04             	mov    0x4(%ebx),%eax
  80179f:	8b 13                	mov    (%ebx),%edx
  8017a1:	83 c2 20             	add    $0x20,%edx
  8017a4:	39 d0                	cmp    %edx,%eax
  8017a6:	73 e2                	jae    80178a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ab:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8017ae:	89 c2                	mov    %eax,%edx
  8017b0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8017b6:	79 05                	jns    8017bd <devpipe_write+0x50>
  8017b8:	4a                   	dec    %edx
  8017b9:	83 ca e0             	or     $0xffffffe0,%edx
  8017bc:	42                   	inc    %edx
  8017bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017c1:	40                   	inc    %eax
  8017c2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c5:	47                   	inc    %edi
  8017c6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017c9:	75 d1                	jne    80179c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017cb:	89 f8                	mov    %edi,%eax
  8017cd:	eb 05                	jmp    8017d4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017d4:	83 c4 1c             	add    $0x1c,%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5f                   	pop    %edi
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	57                   	push   %edi
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 1c             	sub    $0x1c,%esp
  8017e5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017e8:	89 3c 24             	mov    %edi,(%esp)
  8017eb:	e8 34 f6 ff ff       	call   800e24 <fd2data>
  8017f0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f2:	be 00 00 00 00       	mov    $0x0,%esi
  8017f7:	eb 3a                	jmp    801833 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017f9:	85 f6                	test   %esi,%esi
  8017fb:	74 04                	je     801801 <devpipe_read+0x25>
				return i;
  8017fd:	89 f0                	mov    %esi,%eax
  8017ff:	eb 40                	jmp    801841 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801801:	89 da                	mov    %ebx,%edx
  801803:	89 f8                	mov    %edi,%eax
  801805:	e8 f5 fe ff ff       	call   8016ff <_pipeisclosed>
  80180a:	85 c0                	test   %eax,%eax
  80180c:	75 2e                	jne    80183c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80180e:	e8 03 f3 ff ff       	call   800b16 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801813:	8b 03                	mov    (%ebx),%eax
  801815:	3b 43 04             	cmp    0x4(%ebx),%eax
  801818:	74 df                	je     8017f9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80181a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80181f:	79 05                	jns    801826 <devpipe_read+0x4a>
  801821:	48                   	dec    %eax
  801822:	83 c8 e0             	or     $0xffffffe0,%eax
  801825:	40                   	inc    %eax
  801826:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80182a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801830:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801832:	46                   	inc    %esi
  801833:	3b 75 10             	cmp    0x10(%ebp),%esi
  801836:	75 db                	jne    801813 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801838:	89 f0                	mov    %esi,%eax
  80183a:	eb 05                	jmp    801841 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80183c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801841:	83 c4 1c             	add    $0x1c,%esp
  801844:	5b                   	pop    %ebx
  801845:	5e                   	pop    %esi
  801846:	5f                   	pop    %edi
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	57                   	push   %edi
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
  80184f:	83 ec 3c             	sub    $0x3c,%esp
  801852:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801855:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801858:	89 04 24             	mov    %eax,(%esp)
  80185b:	e8 df f5 ff ff       	call   800e3f <fd_alloc>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	85 c0                	test   %eax,%eax
  801864:	0f 88 45 01 00 00    	js     8019af <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801871:	00 
  801872:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801880:	e8 b0 f2 ff ff       	call   800b35 <sys_page_alloc>
  801885:	89 c3                	mov    %eax,%ebx
  801887:	85 c0                	test   %eax,%eax
  801889:	0f 88 20 01 00 00    	js     8019af <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80188f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 a5 f5 ff ff       	call   800e3f <fd_alloc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	85 c0                	test   %eax,%eax
  80189e:	0f 88 f8 00 00 00    	js     80199c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018ab:	00 
  8018ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ba:	e8 76 f2 ff ff       	call   800b35 <sys_page_alloc>
  8018bf:	89 c3                	mov    %eax,%ebx
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	0f 88 d3 00 00 00    	js     80199c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018cc:	89 04 24             	mov    %eax,(%esp)
  8018cf:	e8 50 f5 ff ff       	call   800e24 <fd2data>
  8018d4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018dd:	00 
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e9:	e8 47 f2 ff ff       	call   800b35 <sys_page_alloc>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	0f 88 91 00 00 00    	js     801989 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018fb:	89 04 24             	mov    %eax,(%esp)
  8018fe:	e8 21 f5 ff ff       	call   800e24 <fd2data>
  801903:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80190a:	00 
  80190b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80190f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801916:	00 
  801917:	89 74 24 04          	mov    %esi,0x4(%esp)
  80191b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801922:	e8 62 f2 ff ff       	call   800b89 <sys_page_map>
  801927:	89 c3                	mov    %eax,%ebx
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 4c                	js     801979 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80192d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801933:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801936:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801938:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801942:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801948:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80194b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80194d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801950:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801957:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80195a:	89 04 24             	mov    %eax,(%esp)
  80195d:	e8 b2 f4 ff ff       	call   800e14 <fd2num>
  801962:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801964:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801967:	89 04 24             	mov    %eax,(%esp)
  80196a:	e8 a5 f4 ff ff       	call   800e14 <fd2num>
  80196f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801972:	bb 00 00 00 00       	mov    $0x0,%ebx
  801977:	eb 36                	jmp    8019af <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801979:	89 74 24 04          	mov    %esi,0x4(%esp)
  80197d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801984:	e8 53 f2 ff ff       	call   800bdc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801989:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80198c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801990:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801997:	e8 40 f2 ff ff       	call   800bdc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80199c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80199f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019aa:	e8 2d f2 ff ff       	call   800bdc <sys_page_unmap>
    err:
	return r;
}
  8019af:	89 d8                	mov    %ebx,%eax
  8019b1:	83 c4 3c             	add    $0x3c,%esp
  8019b4:	5b                   	pop    %ebx
  8019b5:	5e                   	pop    %esi
  8019b6:	5f                   	pop    %edi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    

008019b9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 c1 f4 ff ff       	call   800e92 <fd_lookup>
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 15                	js     8019ea <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d8:	89 04 24             	mov    %eax,(%esp)
  8019db:	e8 44 f4 ff ff       	call   800e24 <fd2data>
	return _pipeisclosed(fd, p);
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e5:	e8 15 fd ff ff       	call   8016ff <_pipeisclosed>
}
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8019fc:	c7 44 24 04 e8 23 80 	movl   $0x8023e8,0x4(%esp)
  801a03:	00 
  801a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a07:	89 04 24             	mov    %eax,(%esp)
  801a0a:	e8 34 ed ff ff       	call   800743 <strcpy>
	return 0;
}
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	57                   	push   %edi
  801a1a:	56                   	push   %esi
  801a1b:	53                   	push   %ebx
  801a1c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a22:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a2d:	eb 30                	jmp    801a5f <devcons_write+0x49>
		m = n - tot;
  801a2f:	8b 75 10             	mov    0x10(%ebp),%esi
  801a32:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a34:	83 fe 7f             	cmp    $0x7f,%esi
  801a37:	76 05                	jbe    801a3e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801a39:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a3e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a42:	03 45 0c             	add    0xc(%ebp),%eax
  801a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a49:	89 3c 24             	mov    %edi,(%esp)
  801a4c:	e8 6b ee ff ff       	call   8008bc <memmove>
		sys_cputs(buf, m);
  801a51:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a55:	89 3c 24             	mov    %edi,(%esp)
  801a58:	e8 0b f0 ff ff       	call   800a68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a5d:	01 f3                	add    %esi,%ebx
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a64:	72 c9                	jb     801a2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a66:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5e                   	pop    %esi
  801a6e:	5f                   	pop    %edi
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a7b:	75 07                	jne    801a84 <devcons_read+0x13>
  801a7d:	eb 25                	jmp    801aa4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a7f:	e8 92 f0 ff ff       	call   800b16 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a84:	e8 fd ef ff ff       	call   800a86 <sys_cgetc>
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	74 f2                	je     801a7f <devcons_read+0xe>
  801a8d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 1d                	js     801ab0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a93:	83 f8 04             	cmp    $0x4,%eax
  801a96:	74 13                	je     801aab <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9b:	88 10                	mov    %dl,(%eax)
	return 1;
  801a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa2:	eb 0c                	jmp    801ab0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa9:	eb 05                	jmp    801ab0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  801abb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801abe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ac5:	00 
  801ac6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ac9:	89 04 24             	mov    %eax,(%esp)
  801acc:	e8 97 ef ff ff       	call   800a68 <sys_cputs>
}
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <getchar>:

int
getchar(void)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ad9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ae0:	00 
  801ae1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aef:	e8 3a f6 ff ff       	call   80112e <read>
	if (r < 0)
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 0f                	js     801b07 <getchar+0x34>
		return r;
	if (r < 1)
  801af8:	85 c0                	test   %eax,%eax
  801afa:	7e 06                	jle    801b02 <getchar+0x2f>
		return -E_EOF;
	return c;
  801afc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b00:	eb 05                	jmp    801b07 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b02:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	89 04 24             	mov    %eax,(%esp)
  801b1c:	e8 71 f3 ff ff       	call   800e92 <fd_lookup>
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 11                	js     801b36 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b28:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b2e:	39 10                	cmp    %edx,(%eax)
  801b30:	0f 94 c0             	sete   %al
  801b33:	0f b6 c0             	movzbl %al,%eax
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <opencons>:

int
opencons(void)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 f6 f2 ff ff       	call   800e3f <fd_alloc>
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 3c                	js     801b89 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b4d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b54:	00 
  801b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b63:	e8 cd ef ff ff       	call   800b35 <sys_page_alloc>
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	78 1d                	js     801b89 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b75:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b81:	89 04 24             	mov    %eax,(%esp)
  801b84:	e8 8b f2 ff ff       	call   800e14 <fd2num>
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    
	...

00801b8c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b94:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b97:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b9d:	e8 55 ef ff ff       	call   800af7 <sys_getenvid>
  801ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba5:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  801bac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801bb0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb8:	c7 04 24 f4 23 80 00 	movl   $0x8023f4,(%esp)
  801bbf:	e8 d4 e5 ff ff       	call   800198 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801bcb:	89 04 24             	mov    %eax,(%esp)
  801bce:	e8 64 e5 ff ff       	call   800137 <vcprintf>
	cprintf("\n");
  801bd3:	c7 04 24 e1 23 80 00 	movl   $0x8023e1,(%esp)
  801bda:	e8 b9 e5 ff ff       	call   800198 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bdf:	cc                   	int3   
  801be0:	eb fd                	jmp    801bdf <_panic+0x53>
	...

00801be4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	57                   	push   %edi
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	83 ec 1c             	sub    $0x1c,%esp
  801bed:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bf3:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801bf6:	85 db                	test   %ebx,%ebx
  801bf8:	75 05                	jne    801bff <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801bfa:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801bff:	89 1c 24             	mov    %ebx,(%esp)
  801c02:	e8 44 f1 ff ff       	call   800d4b <sys_ipc_recv>
  801c07:	85 c0                	test   %eax,%eax
  801c09:	79 16                	jns    801c21 <ipc_recv+0x3d>
		*from_env_store = 0;
  801c0b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801c11:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801c17:	89 1c 24             	mov    %ebx,(%esp)
  801c1a:	e8 2c f1 ff ff       	call   800d4b <sys_ipc_recv>
  801c1f:	eb 24                	jmp    801c45 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801c21:	85 f6                	test   %esi,%esi
  801c23:	74 0a                	je     801c2f <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801c25:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2a:	8b 40 74             	mov    0x74(%eax),%eax
  801c2d:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801c2f:	85 ff                	test   %edi,%edi
  801c31:	74 0a                	je     801c3d <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801c33:	a1 04 40 80 00       	mov    0x804004,%eax
  801c38:	8b 40 78             	mov    0x78(%eax),%eax
  801c3b:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801c3d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c42:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c45:	83 c4 1c             	add    $0x1c,%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5e                   	pop    %esi
  801c4a:	5f                   	pop    %edi
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	57                   	push   %edi
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	83 ec 1c             	sub    $0x1c,%esp
  801c56:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c5c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801c5f:	85 db                	test   %ebx,%ebx
  801c61:	75 05                	jne    801c68 <ipc_send+0x1b>
		pg = (void *)-1;
  801c63:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c68:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c70:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	89 04 24             	mov    %eax,(%esp)
  801c7a:	e8 a9 f0 ff ff       	call   800d28 <sys_ipc_try_send>
		if (r == 0) {		
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	74 2c                	je     801caf <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801c83:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c86:	75 07                	jne    801c8f <ipc_send+0x42>
			sys_yield();
  801c88:	e8 89 ee ff ff       	call   800b16 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801c8d:	eb d9                	jmp    801c68 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801c8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c93:	c7 44 24 08 18 24 80 	movl   $0x802418,0x8(%esp)
  801c9a:	00 
  801c9b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801ca2:	00 
  801ca3:	c7 04 24 26 24 80 00 	movl   $0x802426,(%esp)
  801caa:	e8 dd fe ff ff       	call   801b8c <_panic>
		}
	}
}
  801caf:	83 c4 1c             	add    $0x1c,%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5e                   	pop    %esi
  801cb4:	5f                   	pop    %edi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	53                   	push   %ebx
  801cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cc3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cca:	89 c2                	mov    %eax,%edx
  801ccc:	c1 e2 07             	shl    $0x7,%edx
  801ccf:	29 ca                	sub    %ecx,%edx
  801cd1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cd7:	8b 52 50             	mov    0x50(%edx),%edx
  801cda:	39 da                	cmp    %ebx,%edx
  801cdc:	75 0f                	jne    801ced <ipc_find_env+0x36>
			return envs[i].env_id;
  801cde:	c1 e0 07             	shl    $0x7,%eax
  801ce1:	29 c8                	sub    %ecx,%eax
  801ce3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ce8:	8b 40 40             	mov    0x40(%eax),%eax
  801ceb:	eb 0c                	jmp    801cf9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ced:	40                   	inc    %eax
  801cee:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cf3:	75 ce                	jne    801cc3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cf5:	66 b8 00 00          	mov    $0x0,%ax
}
  801cf9:	5b                   	pop    %ebx
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	c1 ea 16             	shr    $0x16,%edx
  801d07:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d0e:	f6 c2 01             	test   $0x1,%dl
  801d11:	74 1e                	je     801d31 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d13:	c1 e8 0c             	shr    $0xc,%eax
  801d16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d1d:	a8 01                	test   $0x1,%al
  801d1f:	74 17                	je     801d38 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d21:	c1 e8 0c             	shr    $0xc,%eax
  801d24:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d2b:	ef 
  801d2c:	0f b7 c0             	movzwl %ax,%eax
  801d2f:	eb 0c                	jmp    801d3d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
  801d36:	eb 05                	jmp    801d3d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    
	...

00801d40 <__udivdi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	83 ec 10             	sub    $0x10,%esp
  801d46:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d4a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d52:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d56:	89 cd                	mov    %ecx,%ebp
  801d58:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	75 2c                	jne    801d8c <__udivdi3+0x4c>
  801d60:	39 f9                	cmp    %edi,%ecx
  801d62:	77 68                	ja     801dcc <__udivdi3+0x8c>
  801d64:	85 c9                	test   %ecx,%ecx
  801d66:	75 0b                	jne    801d73 <__udivdi3+0x33>
  801d68:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	f7 f1                	div    %ecx
  801d71:	89 c1                	mov    %eax,%ecx
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	89 f8                	mov    %edi,%eax
  801d77:	f7 f1                	div    %ecx
  801d79:	89 c7                	mov    %eax,%edi
  801d7b:	89 f0                	mov    %esi,%eax
  801d7d:	f7 f1                	div    %ecx
  801d7f:	89 c6                	mov    %eax,%esi
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	89 fa                	mov    %edi,%edx
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	39 f8                	cmp    %edi,%eax
  801d8e:	77 2c                	ja     801dbc <__udivdi3+0x7c>
  801d90:	0f bd f0             	bsr    %eax,%esi
  801d93:	83 f6 1f             	xor    $0x1f,%esi
  801d96:	75 4c                	jne    801de4 <__udivdi3+0xa4>
  801d98:	39 f8                	cmp    %edi,%eax
  801d9a:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9f:	72 0a                	jb     801dab <__udivdi3+0x6b>
  801da1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801da5:	0f 87 ad 00 00 00    	ja     801e58 <__udivdi3+0x118>
  801dab:	be 01 00 00 00       	mov    $0x1,%esi
  801db0:	89 f0                	mov    %esi,%eax
  801db2:	89 fa                	mov    %edi,%edx
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    
  801dbb:	90                   	nop
  801dbc:	31 ff                	xor    %edi,%edi
  801dbe:	31 f6                	xor    %esi,%esi
  801dc0:	89 f0                	mov    %esi,%eax
  801dc2:	89 fa                	mov    %edi,%edx
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	5e                   	pop    %esi
  801dc8:	5f                   	pop    %edi
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    
  801dcb:	90                   	nop
  801dcc:	89 fa                	mov    %edi,%edx
  801dce:	89 f0                	mov    %esi,%eax
  801dd0:	f7 f1                	div    %ecx
  801dd2:	89 c6                	mov    %eax,%esi
  801dd4:	31 ff                	xor    %edi,%edi
  801dd6:	89 f0                	mov    %esi,%eax
  801dd8:	89 fa                	mov    %edi,%edx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	5e                   	pop    %esi
  801dde:	5f                   	pop    %edi
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    
  801de1:	8d 76 00             	lea    0x0(%esi),%esi
  801de4:	89 f1                	mov    %esi,%ecx
  801de6:	d3 e0                	shl    %cl,%eax
  801de8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dec:	b8 20 00 00 00       	mov    $0x20,%eax
  801df1:	29 f0                	sub    %esi,%eax
  801df3:	89 ea                	mov    %ebp,%edx
  801df5:	88 c1                	mov    %al,%cl
  801df7:	d3 ea                	shr    %cl,%edx
  801df9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801dfd:	09 ca                	or     %ecx,%edx
  801dff:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e03:	89 f1                	mov    %esi,%ecx
  801e05:	d3 e5                	shl    %cl,%ebp
  801e07:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801e0b:	89 fd                	mov    %edi,%ebp
  801e0d:	88 c1                	mov    %al,%cl
  801e0f:	d3 ed                	shr    %cl,%ebp
  801e11:	89 fa                	mov    %edi,%edx
  801e13:	89 f1                	mov    %esi,%ecx
  801e15:	d3 e2                	shl    %cl,%edx
  801e17:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e1b:	88 c1                	mov    %al,%cl
  801e1d:	d3 ef                	shr    %cl,%edi
  801e1f:	09 d7                	or     %edx,%edi
  801e21:	89 f8                	mov    %edi,%eax
  801e23:	89 ea                	mov    %ebp,%edx
  801e25:	f7 74 24 08          	divl   0x8(%esp)
  801e29:	89 d1                	mov    %edx,%ecx
  801e2b:	89 c7                	mov    %eax,%edi
  801e2d:	f7 64 24 0c          	mull   0xc(%esp)
  801e31:	39 d1                	cmp    %edx,%ecx
  801e33:	72 17                	jb     801e4c <__udivdi3+0x10c>
  801e35:	74 09                	je     801e40 <__udivdi3+0x100>
  801e37:	89 fe                	mov    %edi,%esi
  801e39:	31 ff                	xor    %edi,%edi
  801e3b:	e9 41 ff ff ff       	jmp    801d81 <__udivdi3+0x41>
  801e40:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e44:	89 f1                	mov    %esi,%ecx
  801e46:	d3 e2                	shl    %cl,%edx
  801e48:	39 c2                	cmp    %eax,%edx
  801e4a:	73 eb                	jae    801e37 <__udivdi3+0xf7>
  801e4c:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e4f:	31 ff                	xor    %edi,%edi
  801e51:	e9 2b ff ff ff       	jmp    801d81 <__udivdi3+0x41>
  801e56:	66 90                	xchg   %ax,%ax
  801e58:	31 f6                	xor    %esi,%esi
  801e5a:	e9 22 ff ff ff       	jmp    801d81 <__udivdi3+0x41>
	...

00801e60 <__umoddi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	83 ec 20             	sub    $0x20,%esp
  801e66:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e6a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e6e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e72:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e76:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e7a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e7e:	89 c7                	mov    %eax,%edi
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	85 ed                	test   %ebp,%ebp
  801e84:	75 16                	jne    801e9c <__umoddi3+0x3c>
  801e86:	39 f1                	cmp    %esi,%ecx
  801e88:	0f 86 a6 00 00 00    	jbe    801f34 <__umoddi3+0xd4>
  801e8e:	f7 f1                	div    %ecx
  801e90:	89 d0                	mov    %edx,%eax
  801e92:	31 d2                	xor    %edx,%edx
  801e94:	83 c4 20             	add    $0x20,%esp
  801e97:	5e                   	pop    %esi
  801e98:	5f                   	pop    %edi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    
  801e9b:	90                   	nop
  801e9c:	39 f5                	cmp    %esi,%ebp
  801e9e:	0f 87 ac 00 00 00    	ja     801f50 <__umoddi3+0xf0>
  801ea4:	0f bd c5             	bsr    %ebp,%eax
  801ea7:	83 f0 1f             	xor    $0x1f,%eax
  801eaa:	89 44 24 10          	mov    %eax,0x10(%esp)
  801eae:	0f 84 a8 00 00 00    	je     801f5c <__umoddi3+0xfc>
  801eb4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eb8:	d3 e5                	shl    %cl,%ebp
  801eba:	bf 20 00 00 00       	mov    $0x20,%edi
  801ebf:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801ec3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ec7:	89 f9                	mov    %edi,%ecx
  801ec9:	d3 e8                	shr    %cl,%eax
  801ecb:	09 e8                	or     %ebp,%eax
  801ecd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801ed1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ed5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ed9:	d3 e0                	shl    %cl,%eax
  801edb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801edf:	89 f2                	mov    %esi,%edx
  801ee1:	d3 e2                	shl    %cl,%edx
  801ee3:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801eed:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ef1:	89 f9                	mov    %edi,%ecx
  801ef3:	d3 e8                	shr    %cl,%eax
  801ef5:	09 d0                	or     %edx,%eax
  801ef7:	d3 ee                	shr    %cl,%esi
  801ef9:	89 f2                	mov    %esi,%edx
  801efb:	f7 74 24 18          	divl   0x18(%esp)
  801eff:	89 d6                	mov    %edx,%esi
  801f01:	f7 64 24 0c          	mull   0xc(%esp)
  801f05:	89 c5                	mov    %eax,%ebp
  801f07:	89 d1                	mov    %edx,%ecx
  801f09:	39 d6                	cmp    %edx,%esi
  801f0b:	72 67                	jb     801f74 <__umoddi3+0x114>
  801f0d:	74 75                	je     801f84 <__umoddi3+0x124>
  801f0f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f13:	29 e8                	sub    %ebp,%eax
  801f15:	19 ce                	sbb    %ecx,%esi
  801f17:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1b:	d3 e8                	shr    %cl,%eax
  801f1d:	89 f2                	mov    %esi,%edx
  801f1f:	89 f9                	mov    %edi,%ecx
  801f21:	d3 e2                	shl    %cl,%edx
  801f23:	09 d0                	or     %edx,%eax
  801f25:	89 f2                	mov    %esi,%edx
  801f27:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f2b:	d3 ea                	shr    %cl,%edx
  801f2d:	83 c4 20             	add    $0x20,%esp
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    
  801f34:	85 c9                	test   %ecx,%ecx
  801f36:	75 0b                	jne    801f43 <__umoddi3+0xe3>
  801f38:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3d:	31 d2                	xor    %edx,%edx
  801f3f:	f7 f1                	div    %ecx
  801f41:	89 c1                	mov    %eax,%ecx
  801f43:	89 f0                	mov    %esi,%eax
  801f45:	31 d2                	xor    %edx,%edx
  801f47:	f7 f1                	div    %ecx
  801f49:	89 f8                	mov    %edi,%eax
  801f4b:	e9 3e ff ff ff       	jmp    801e8e <__umoddi3+0x2e>
  801f50:	89 f2                	mov    %esi,%edx
  801f52:	83 c4 20             	add    $0x20,%esp
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    
  801f59:	8d 76 00             	lea    0x0(%esi),%esi
  801f5c:	39 f5                	cmp    %esi,%ebp
  801f5e:	72 04                	jb     801f64 <__umoddi3+0x104>
  801f60:	39 f9                	cmp    %edi,%ecx
  801f62:	77 06                	ja     801f6a <__umoddi3+0x10a>
  801f64:	89 f2                	mov    %esi,%edx
  801f66:	29 cf                	sub    %ecx,%edi
  801f68:	19 ea                	sbb    %ebp,%edx
  801f6a:	89 f8                	mov    %edi,%eax
  801f6c:	83 c4 20             	add    $0x20,%esp
  801f6f:	5e                   	pop    %esi
  801f70:	5f                   	pop    %edi
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    
  801f73:	90                   	nop
  801f74:	89 d1                	mov    %edx,%ecx
  801f76:	89 c5                	mov    %eax,%ebp
  801f78:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f7c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f80:	eb 8d                	jmp    801f0f <__umoddi3+0xaf>
  801f82:	66 90                	xchg   %ax,%ax
  801f84:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f88:	72 ea                	jb     801f74 <__umoddi3+0x114>
  801f8a:	89 f1                	mov    %esi,%ecx
  801f8c:	eb 81                	jmp    801f0f <__umoddi3+0xaf>
