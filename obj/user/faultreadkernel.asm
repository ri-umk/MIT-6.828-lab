
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  80004a:	e8 15 01 00 00       	call   800164 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800062:	e8 5c 0a 00 00       	call   800ac3 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ae:	e8 a0 0e 00 00       	call   800f53 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 b2 09 00 00       	call   800a71 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	40                   	inc    %eax
  8000d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	75 19                	jne    8000fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e8:	00 
  8000e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ec:	89 04 24             	mov    %eax,(%esp)
  8000ef:	e8 40 09 00 00       	call   800a34 <sys_cputs>
		b->idx = 0;
  8000f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fa:	ff 43 04             	incl   0x4(%ebx)
}
  8000fd:	83 c4 14             	add    $0x14,%esp
  800100:	5b                   	pop    %ebx
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	8b 45 08             	mov    0x8(%ebp),%eax
  80012a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  80013f:	e8 82 01 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800144:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800154:	89 04 24             	mov    %eax,(%esp)
  800157:	e8 d8 08 00 00       	call   800a34 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800171:	8b 45 08             	mov    0x8(%ebp),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 87 ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	75 08                	jne    8001ac <printnum+0x2c>
  8001a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001aa:	77 57                	ja     800203 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b0:	4b                   	dec    %ebx
  8001b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cb:	00 
  8001cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cf:	89 04 24             	mov    %eax,(%esp)
  8001d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d9:	e8 ba 1a 00 00       	call   801c98 <__udivdi3>
  8001de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ed:	89 fa                	mov    %edi,%edx
  8001ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f2:	e8 89 ff ff ff       	call   800180 <printnum>
  8001f7:	eb 0f                	jmp    800208 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fd:	89 34 24             	mov    %esi,(%esp)
  800200:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800203:	4b                   	dec    %ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f f1                	jg     8001f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 44 24 08          	mov    %eax,0x8(%esp)
  800217:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021e:	00 
  80021f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	e8 87 1b 00 00       	call   801db8 <__umoddi3>
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	0f be 80 31 1f 80 00 	movsbl 0x801f31(%eax),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800242:	83 c4 3c             	add    $0x3c,%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024d:	83 fa 01             	cmp    $0x1,%edx
  800250:	7e 0e                	jle    800260 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 08             	lea    0x8(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	8b 52 04             	mov    0x4(%edx),%edx
  80025e:	eb 22                	jmp    800282 <getuint+0x38>
	else if (lflag)
  800260:	85 d2                	test   %edx,%edx
  800262:	74 10                	je     800274 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	eb 0e                	jmp    800282 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	3b 50 04             	cmp    0x4(%eax),%edx
  800292:	73 08                	jae    80029c <sprintputch+0x18>
		*b->buf++ = ch;
  800294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800297:	88 0a                	mov    %cl,(%edx)
  800299:	42                   	inc    %edx
  80029a:	89 10                	mov    %edx,(%eax)
}
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 02 00 00 00       	call   8002c6 <vprintfmt>
	va_end(ap);
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 4c             	sub    $0x4c,%esp
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d5:	eb 12                	jmp    8002e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	0f 84 6b 03 00 00    	je     80064a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	0f b6 06             	movzbl (%esi),%eax
  8002ec:	46                   	inc    %esi
  8002ed:	83 f8 25             	cmp    $0x25,%eax
  8002f0:	75 e5                	jne    8002d7 <vprintfmt+0x11>
  8002f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800302:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800309:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030e:	eb 26                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800313:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800317:	eb 1d                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800319:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800320:	eb 14                	jmp    800336 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800325:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80032c:	eb 08                	jmp    800336 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80032e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800331:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	0f b6 06             	movzbl (%esi),%eax
  800339:	8d 56 01             	lea    0x1(%esi),%edx
  80033c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80033f:	8a 16                	mov    (%esi),%dl
  800341:	83 ea 23             	sub    $0x23,%edx
  800344:	80 fa 55             	cmp    $0x55,%dl
  800347:	0f 87 e1 02 00 00    	ja     80062e <vprintfmt+0x368>
  80034d:	0f b6 d2             	movzbl %dl,%edx
  800350:	ff 24 95 80 20 80 00 	jmp    *0x802080(,%edx,4)
  800357:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80035a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800362:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800366:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800369:	8d 50 d0             	lea    -0x30(%eax),%edx
  80036c:	83 fa 09             	cmp    $0x9,%edx
  80036f:	77 2a                	ja     80039b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800372:	eb eb                	jmp    80035f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 50 04             	lea    0x4(%eax),%edx
  80037a:	89 55 14             	mov    %edx,0x14(%ebp)
  80037d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800382:	eb 17                	jmp    80039b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800384:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800388:	78 98                	js     800322 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80038d:	eb a7                	jmp    800336 <vprintfmt+0x70>
  80038f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800392:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800399:	eb 9b                	jmp    800336 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80039b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039f:	79 95                	jns    800336 <vprintfmt+0x70>
  8003a1:	eb 8b                	jmp    80032e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a7:	eb 8d                	jmp    800336 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8d 50 04             	lea    0x4(%eax),%edx
  8003af:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c1:	e9 23 ff ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 50 04             	lea    0x4(%eax),%edx
  8003cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	79 02                	jns    8003d7 <vprintfmt+0x111>
  8003d5:	f7 d8                	neg    %eax
  8003d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d9:	83 f8 0f             	cmp    $0xf,%eax
  8003dc:	7f 0b                	jg     8003e9 <vprintfmt+0x123>
  8003de:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	75 23                	jne    80040c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ed:	c7 44 24 08 49 1f 80 	movl   $0x801f49,0x8(%esp)
  8003f4:	00 
  8003f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	e8 9a fe ff ff       	call   80029e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800407:	e9 dd fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80040c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800410:	c7 44 24 08 3a 23 80 	movl   $0x80233a,0x8(%esp)
  800417:	00 
  800418:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041c:	8b 55 08             	mov    0x8(%ebp),%edx
  80041f:	89 14 24             	mov    %edx,(%esp)
  800422:	e8 77 fe ff ff       	call   80029e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042a:	e9 ba fe ff ff       	jmp    8002e9 <vprintfmt+0x23>
  80042f:	89 f9                	mov    %edi,%ecx
  800431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 50 04             	lea    0x4(%eax),%edx
  80043d:	89 55 14             	mov    %edx,0x14(%ebp)
  800440:	8b 30                	mov    (%eax),%esi
  800442:	85 f6                	test   %esi,%esi
  800444:	75 05                	jne    80044b <vprintfmt+0x185>
				p = "(null)";
  800446:	be 42 1f 80 00       	mov    $0x801f42,%esi
			if (width > 0 && padc != '-')
  80044b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80044f:	0f 8e 84 00 00 00    	jle    8004d9 <vprintfmt+0x213>
  800455:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800459:	74 7e                	je     8004d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80045f:	89 34 24             	mov    %esi,(%esp)
  800462:	e8 8b 02 00 00       	call   8006f2 <strnlen>
  800467:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80046a:	29 c2                	sub    %eax,%edx
  80046c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80046f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800473:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800476:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800479:	89 de                	mov    %ebx,%esi
  80047b:	89 d3                	mov    %edx,%ebx
  80047d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	eb 0b                	jmp    80048c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800481:	89 74 24 04          	mov    %esi,0x4(%esp)
  800485:	89 3c 24             	mov    %edi,(%esp)
  800488:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	4b                   	dec    %ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f f1                	jg     800481 <vprintfmt+0x1bb>
  800490:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800493:	89 f3                	mov    %esi,%ebx
  800495:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800498:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	79 05                	jns    8004a4 <vprintfmt+0x1de>
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a7:	29 c2                	sub    %eax,%edx
  8004a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ac:	eb 2b                	jmp    8004d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b2:	74 18                	je     8004cc <vprintfmt+0x206>
  8004b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004b7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ba:	76 10                	jbe    8004cc <vprintfmt+0x206>
					putch('?', putdat);
  8004bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
  8004ca:	eb 0a                	jmp    8004d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d9:	0f be 06             	movsbl (%esi),%eax
  8004dc:	46                   	inc    %esi
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	74 21                	je     800502 <vprintfmt+0x23c>
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	78 c9                	js     8004ae <vprintfmt+0x1e8>
  8004e5:	4f                   	dec    %edi
  8004e6:	79 c6                	jns    8004ae <vprintfmt+0x1e8>
  8004e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004eb:	89 de                	mov    %ebx,%esi
  8004ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f0:	eb 18                	jmp    80050a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ff:	4b                   	dec    %ebx
  800500:	eb 08                	jmp    80050a <vprintfmt+0x244>
  800502:	8b 7d 08             	mov    0x8(%ebp),%edi
  800505:	89 de                	mov    %ebx,%esi
  800507:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050a:	85 db                	test   %ebx,%ebx
  80050c:	7f e4                	jg     8004f2 <vprintfmt+0x22c>
  80050e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800511:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 ce fd ff ff       	jmp    8002e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051b:	83 f9 01             	cmp    $0x1,%ecx
  80051e:	7e 10                	jle    800530 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 08             	lea    0x8(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 30                	mov    (%eax),%esi
  80052b:	8b 78 04             	mov    0x4(%eax),%edi
  80052e:	eb 26                	jmp    800556 <vprintfmt+0x290>
	else if (lflag)
  800530:	85 c9                	test   %ecx,%ecx
  800532:	74 12                	je     800546 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 30                	mov    (%eax),%esi
  80053f:	89 f7                	mov    %esi,%edi
  800541:	c1 ff 1f             	sar    $0x1f,%edi
  800544:	eb 10                	jmp    800556 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	8b 30                	mov    (%eax),%esi
  800551:	89 f7                	mov    %esi,%edi
  800553:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800556:	85 ff                	test   %edi,%edi
  800558:	78 0a                	js     800564 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055f:	e9 8c 00 00 00       	jmp    8005f0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80056f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800572:	f7 de                	neg    %esi
  800574:	83 d7 00             	adc    $0x0,%edi
  800577:	f7 df                	neg    %edi
			}
			base = 10;
  800579:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057e:	eb 70                	jmp    8005f0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800580:	89 ca                	mov    %ecx,%edx
  800582:	8d 45 14             	lea    0x14(%ebp),%eax
  800585:	e8 c0 fc ff ff       	call   80024a <getuint>
  80058a:	89 c6                	mov    %eax,%esi
  80058c:	89 d7                	mov    %edx,%edi
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800593:	eb 5b                	jmp    8005f0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800595:	89 ca                	mov    %ecx,%edx
  800597:	8d 45 14             	lea    0x14(%ebp),%eax
  80059a:	e8 ab fc ff ff       	call   80024a <getuint>
  80059f:	89 c6                	mov    %eax,%esi
  8005a1:	89 d7                	mov    %edx,%edi
			base = 8;
  8005a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005a8:	eb 46                	jmp    8005f0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cf:	8b 30                	mov    (%eax),%esi
  8005d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005db:	eb 13                	jmp    8005f0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005dd:	89 ca                	mov    %ecx,%edx
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 63 fc ff ff       	call   80024a <getuint>
  8005e7:	89 c6                	mov    %eax,%esi
  8005e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8005eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800603:	89 34 24             	mov    %esi,(%esp)
  800606:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060a:	89 da                	mov    %ebx,%edx
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	e8 6c fb ff ff       	call   800180 <printnum>
			break;
  800614:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800617:	e9 cd fc ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800629:	e9 bb fc ff ff       	jmp    8002e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800632:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800639:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	eb 01                	jmp    80063f <vprintfmt+0x379>
  80063e:	4e                   	dec    %esi
  80063f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800643:	75 f9                	jne    80063e <vprintfmt+0x378>
  800645:	e9 9f fc ff ff       	jmp    8002e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80064a:	83 c4 4c             	add    $0x4c,%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	83 ec 28             	sub    $0x28,%esp
  800658:	8b 45 08             	mov    0x8(%ebp),%eax
  80065b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800661:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800665:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800668:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066f:	85 c0                	test   %eax,%eax
  800671:	74 30                	je     8006a3 <vsnprintf+0x51>
  800673:	85 d2                	test   %edx,%edx
  800675:	7e 33                	jle    8006aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067e:	8b 45 10             	mov    0x10(%ebp),%eax
  800681:	89 44 24 08          	mov    %eax,0x8(%esp)
  800685:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068c:	c7 04 24 84 02 80 00 	movl   $0x800284,(%esp)
  800693:	e8 2e fc ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800698:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a1:	eb 0c                	jmp    8006af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a8:	eb 05                	jmp    8006af <vsnprintf+0x5d>
  8006aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006be:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	e8 7b ff ff ff       	call   800652 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    
  8006d9:	00 00                	add    %al,(%eax)
	...

008006dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e7:	eb 01                	jmp    8006ea <strlen+0xe>
		n++;
  8006e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ee:	75 f9                	jne    8006e9 <strlen+0xd>
		n++;
	return n;
}
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 01                	jmp    800703 <strnlen+0x11>
		n++;
  800702:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	39 d0                	cmp    %edx,%eax
  800705:	74 06                	je     80070d <strnlen+0x1b>
  800707:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070b:	75 f5                	jne    800702 <strnlen+0x10>
		n++;
	return n;
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	53                   	push   %ebx
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800719:	ba 00 00 00 00       	mov    $0x0,%edx
  80071e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800721:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800724:	42                   	inc    %edx
  800725:	84 c9                	test   %cl,%cl
  800727:	75 f5                	jne    80071e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800729:	5b                   	pop    %ebx
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800736:	89 1c 24             	mov    %ebx,(%esp)
  800739:	e8 9e ff ff ff       	call   8006dc <strlen>
	strcpy(dst + len, src);
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800741:	89 54 24 04          	mov    %edx,0x4(%esp)
  800745:	01 d8                	add    %ebx,%eax
  800747:	89 04 24             	mov    %eax,(%esp)
  80074a:	e8 c0 ff ff ff       	call   80070f <strcpy>
	return dst;
}
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	5b                   	pop    %ebx
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	56                   	push   %esi
  80075b:	53                   	push   %ebx
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800762:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800765:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076a:	eb 0c                	jmp    800778 <strncpy+0x21>
		*dst++ = *src;
  80076c:	8a 1a                	mov    (%edx),%bl
  80076e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800771:	80 3a 01             	cmpb   $0x1,(%edx)
  800774:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	41                   	inc    %ecx
  800778:	39 f1                	cmp    %esi,%ecx
  80077a:	75 f0                	jne    80076c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078e:	85 d2                	test   %edx,%edx
  800790:	75 0a                	jne    80079c <strlcpy+0x1c>
  800792:	89 f0                	mov    %esi,%eax
  800794:	eb 1a                	jmp    8007b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800796:	88 18                	mov    %bl,(%eax)
  800798:	40                   	inc    %eax
  800799:	41                   	inc    %ecx
  80079a:	eb 02                	jmp    80079e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80079e:	4a                   	dec    %edx
  80079f:	74 0a                	je     8007ab <strlcpy+0x2b>
  8007a1:	8a 19                	mov    (%ecx),%bl
  8007a3:	84 db                	test   %bl,%bl
  8007a5:	75 ef                	jne    800796 <strlcpy+0x16>
  8007a7:	89 c2                	mov    %eax,%edx
  8007a9:	eb 02                	jmp    8007ad <strlcpy+0x2d>
  8007ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007b0:	29 f0                	sub    %esi,%eax
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bf:	eb 02                	jmp    8007c3 <strcmp+0xd>
		p++, q++;
  8007c1:	41                   	inc    %ecx
  8007c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c3:	8a 01                	mov    (%ecx),%al
  8007c5:	84 c0                	test   %al,%al
  8007c7:	74 04                	je     8007cd <strcmp+0x17>
  8007c9:	3a 02                	cmp    (%edx),%al
  8007cb:	74 f4                	je     8007c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cd:	0f b6 c0             	movzbl %al,%eax
  8007d0:	0f b6 12             	movzbl (%edx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007e4:	eb 03                	jmp    8007e9 <strncmp+0x12>
		n--, p++, q++;
  8007e6:	4a                   	dec    %edx
  8007e7:	40                   	inc    %eax
  8007e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	74 14                	je     800801 <strncmp+0x2a>
  8007ed:	8a 18                	mov    (%eax),%bl
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	74 04                	je     8007f7 <strncmp+0x20>
  8007f3:	3a 19                	cmp    (%ecx),%bl
  8007f5:	74 ef                	je     8007e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f7:	0f b6 00             	movzbl (%eax),%eax
  8007fa:	0f b6 11             	movzbl (%ecx),%edx
  8007fd:	29 d0                	sub    %edx,%eax
  8007ff:	eb 05                	jmp    800806 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800812:	eb 05                	jmp    800819 <strchr+0x10>
		if (*s == c)
  800814:	38 ca                	cmp    %cl,%dl
  800816:	74 0c                	je     800824 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800818:	40                   	inc    %eax
  800819:	8a 10                	mov    (%eax),%dl
  80081b:	84 d2                	test   %dl,%dl
  80081d:	75 f5                	jne    800814 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082f:	eb 05                	jmp    800836 <strfind+0x10>
		if (*s == c)
  800831:	38 ca                	cmp    %cl,%dl
  800833:	74 07                	je     80083c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800835:	40                   	inc    %eax
  800836:	8a 10                	mov    (%eax),%dl
  800838:	84 d2                	test   %dl,%dl
  80083a:	75 f5                	jne    800831 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	57                   	push   %edi
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 7d 08             	mov    0x8(%ebp),%edi
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	74 30                	je     800881 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800851:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800857:	75 25                	jne    80087e <memset+0x40>
  800859:	f6 c1 03             	test   $0x3,%cl
  80085c:	75 20                	jne    80087e <memset+0x40>
		c &= 0xFF;
  80085e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800861:	89 d3                	mov    %edx,%ebx
  800863:	c1 e3 08             	shl    $0x8,%ebx
  800866:	89 d6                	mov    %edx,%esi
  800868:	c1 e6 18             	shl    $0x18,%esi
  80086b:	89 d0                	mov    %edx,%eax
  80086d:	c1 e0 10             	shl    $0x10,%eax
  800870:	09 f0                	or     %esi,%eax
  800872:	09 d0                	or     %edx,%eax
  800874:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800876:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800879:	fc                   	cld    
  80087a:	f3 ab                	rep stos %eax,%es:(%edi)
  80087c:	eb 03                	jmp    800881 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087e:	fc                   	cld    
  80087f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800881:	89 f8                	mov    %edi,%eax
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5f                   	pop    %edi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	57                   	push   %edi
  80088c:	56                   	push   %esi
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 75 0c             	mov    0xc(%ebp),%esi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800896:	39 c6                	cmp    %eax,%esi
  800898:	73 34                	jae    8008ce <memmove+0x46>
  80089a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089d:	39 d0                	cmp    %edx,%eax
  80089f:	73 2d                	jae    8008ce <memmove+0x46>
		s += n;
		d += n;
  8008a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a4:	f6 c2 03             	test   $0x3,%dl
  8008a7:	75 1b                	jne    8008c4 <memmove+0x3c>
  8008a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008af:	75 13                	jne    8008c4 <memmove+0x3c>
  8008b1:	f6 c1 03             	test   $0x3,%cl
  8008b4:	75 0e                	jne    8008c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b6:	83 ef 04             	sub    $0x4,%edi
  8008b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008bf:	fd                   	std    
  8008c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c2:	eb 07                	jmp    8008cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c4:	4f                   	dec    %edi
  8008c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c8:	fd                   	std    
  8008c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cb:	fc                   	cld    
  8008cc:	eb 20                	jmp    8008ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d4:	75 13                	jne    8008e9 <memmove+0x61>
  8008d6:	a8 03                	test   $0x3,%al
  8008d8:	75 0f                	jne    8008e9 <memmove+0x61>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8008fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800902:	89 44 24 04          	mov    %eax,0x4(%esp)
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	89 04 24             	mov    %eax,(%esp)
  80090c:	e8 77 ff ff ff       	call   800888 <memmove>
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	57                   	push   %edi
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800922:	ba 00 00 00 00       	mov    $0x0,%edx
  800927:	eb 16                	jmp    80093f <memcmp+0x2c>
		if (*s1 != *s2)
  800929:	8a 04 17             	mov    (%edi,%edx,1),%al
  80092c:	42                   	inc    %edx
  80092d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800931:	38 c8                	cmp    %cl,%al
  800933:	74 0a                	je     80093f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800935:	0f b6 c0             	movzbl %al,%eax
  800938:	0f b6 c9             	movzbl %cl,%ecx
  80093b:	29 c8                	sub    %ecx,%eax
  80093d:	eb 09                	jmp    800948 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093f:	39 da                	cmp    %ebx,%edx
  800941:	75 e6                	jne    800929 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800956:	89 c2                	mov    %eax,%edx
  800958:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80095b:	eb 05                	jmp    800962 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095d:	38 08                	cmp    %cl,(%eax)
  80095f:	74 05                	je     800966 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800961:	40                   	inc    %eax
  800962:	39 d0                	cmp    %edx,%eax
  800964:	72 f7                	jb     80095d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
  80096e:	8b 55 08             	mov    0x8(%ebp),%edx
  800971:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800974:	eb 01                	jmp    800977 <strtol+0xf>
		s++;
  800976:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800977:	8a 02                	mov    (%edx),%al
  800979:	3c 20                	cmp    $0x20,%al
  80097b:	74 f9                	je     800976 <strtol+0xe>
  80097d:	3c 09                	cmp    $0x9,%al
  80097f:	74 f5                	je     800976 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800981:	3c 2b                	cmp    $0x2b,%al
  800983:	75 08                	jne    80098d <strtol+0x25>
		s++;
  800985:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800986:	bf 00 00 00 00       	mov    $0x0,%edi
  80098b:	eb 13                	jmp    8009a0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80098d:	3c 2d                	cmp    $0x2d,%al
  80098f:	75 0a                	jne    80099b <strtol+0x33>
		s++, neg = 1;
  800991:	8d 52 01             	lea    0x1(%edx),%edx
  800994:	bf 01 00 00 00       	mov    $0x1,%edi
  800999:	eb 05                	jmp    8009a0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a0:	85 db                	test   %ebx,%ebx
  8009a2:	74 05                	je     8009a9 <strtol+0x41>
  8009a4:	83 fb 10             	cmp    $0x10,%ebx
  8009a7:	75 28                	jne    8009d1 <strtol+0x69>
  8009a9:	8a 02                	mov    (%edx),%al
  8009ab:	3c 30                	cmp    $0x30,%al
  8009ad:	75 10                	jne    8009bf <strtol+0x57>
  8009af:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009b3:	75 0a                	jne    8009bf <strtol+0x57>
		s += 2, base = 16;
  8009b5:	83 c2 02             	add    $0x2,%edx
  8009b8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009bd:	eb 12                	jmp    8009d1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	75 0e                	jne    8009d1 <strtol+0x69>
  8009c3:	3c 30                	cmp    $0x30,%al
  8009c5:	75 05                	jne    8009cc <strtol+0x64>
		s++, base = 8;
  8009c7:	42                   	inc    %edx
  8009c8:	b3 08                	mov    $0x8,%bl
  8009ca:	eb 05                	jmp    8009d1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009cc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d8:	8a 0a                	mov    (%edx),%cl
  8009da:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009dd:	80 fb 09             	cmp    $0x9,%bl
  8009e0:	77 08                	ja     8009ea <strtol+0x82>
			dig = *s - '0';
  8009e2:	0f be c9             	movsbl %cl,%ecx
  8009e5:	83 e9 30             	sub    $0x30,%ecx
  8009e8:	eb 1e                	jmp    800a08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009ea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009ed:	80 fb 19             	cmp    $0x19,%bl
  8009f0:	77 08                	ja     8009fa <strtol+0x92>
			dig = *s - 'a' + 10;
  8009f2:	0f be c9             	movsbl %cl,%ecx
  8009f5:	83 e9 57             	sub    $0x57,%ecx
  8009f8:	eb 0e                	jmp    800a08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009fa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009fd:	80 fb 19             	cmp    $0x19,%bl
  800a00:	77 12                	ja     800a14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a02:	0f be c9             	movsbl %cl,%ecx
  800a05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a08:	39 f1                	cmp    %esi,%ecx
  800a0a:	7d 0c                	jge    800a18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a0c:	42                   	inc    %edx
  800a0d:	0f af c6             	imul   %esi,%eax
  800a10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a12:	eb c4                	jmp    8009d8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a14:	89 c1                	mov    %eax,%ecx
  800a16:	eb 02                	jmp    800a1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1e:	74 05                	je     800a25 <strtol+0xbd>
		*endptr = (char *) s;
  800a20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a25:	85 ff                	test   %edi,%edi
  800a27:	74 04                	je     800a2d <strtol+0xc5>
  800a29:	89 c8                	mov    %ecx,%eax
  800a2b:	f7 d8                	neg    %eax
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    
	...

00800a34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	89 c3                	mov    %eax,%ebx
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	89 c6                	mov    %eax,%esi
  800a4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a62:	89 d1                	mov    %edx,%ecx
  800a64:	89 d3                	mov    %edx,%ebx
  800a66:	89 d7                	mov    %edx,%edi
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	89 cb                	mov    %ecx,%ebx
  800a89:	89 cf                	mov    %ecx,%edi
  800a8b:	89 ce                	mov    %ecx,%esi
  800a8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	7e 28                	jle    800abb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a9e:	00 
  800a9f:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800aa6:	00 
  800aa7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aae:	00 
  800aaf:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800ab6:	e8 29 10 00 00       	call   801ae4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abb:	83 c4 2c             	add    $0x2c,%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ace:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad3:	89 d1                	mov    %edx,%ecx
  800ad5:	89 d3                	mov    %edx,%ebx
  800ad7:	89 d7                	mov    %edx,%edi
  800ad9:	89 d6                	mov    %edx,%esi
  800adb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_yield>:

void
sys_yield(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	be 00 00 00 00       	mov    $0x0,%esi
  800b0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	89 f7                	mov    %esi,%edi
  800b1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	7e 28                	jle    800b4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b30:	00 
  800b31:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800b38:	00 
  800b39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b40:	00 
  800b41:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800b48:	e8 97 0f 00 00       	call   801ae4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b4d:	83 c4 2c             	add    $0x2c,%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b63:	8b 75 18             	mov    0x18(%ebp),%esi
  800b66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b74:	85 c0                	test   %eax,%eax
  800b76:	7e 28                	jle    800ba0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b83:	00 
  800b84:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800b8b:	00 
  800b8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b93:	00 
  800b94:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800b9b:	e8 44 0f 00 00       	call   801ae4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba0:	83 c4 2c             	add    $0x2c,%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	89 df                	mov    %ebx,%edi
  800bc3:	89 de                	mov    %ebx,%esi
  800bc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7e 28                	jle    800bf3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bd6:	00 
  800bd7:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800bde:	00 
  800bdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be6:	00 
  800be7:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800bee:	e8 f1 0e 00 00       	call   801ae4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf3:	83 c4 2c             	add    $0x2c,%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 28                	jle    800c46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c29:	00 
  800c2a:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800c31:	00 
  800c32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c39:	00 
  800c3a:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800c41:	e8 9e 0e 00 00       	call   801ae4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c46:	83 c4 2c             	add    $0x2c,%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 df                	mov    %ebx,%edi
  800c69:	89 de                	mov    %ebx,%esi
  800c6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7e 28                	jle    800c99 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800c84:	00 
  800c85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8c:	00 
  800c8d:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800c94:	e8 4b 0e 00 00       	call   801ae4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c99:	83 c4 2c             	add    $0x2c,%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 28                	jle    800cec <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdf:	00 
  800ce0:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800ce7:	e8 f8 0d 00 00       	call   801ae4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cec:	83 c4 2c             	add    $0x2c,%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	be 00 00 00 00       	mov    $0x0,%esi
  800cff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 cb                	mov    %ecx,%ebx
  800d2f:	89 cf                	mov    %ecx,%edi
  800d31:	89 ce                	mov    %ecx,%esi
  800d33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d35:	85 c0                	test   %eax,%eax
  800d37:	7e 28                	jle    800d61 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d44:	00 
  800d45:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800d4c:	00 
  800d4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d54:	00 
  800d55:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800d5c:	e8 83 0d 00 00       	call   801ae4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d61:	83 c4 2c             	add    $0x2c,%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    
  800d69:	00 00                	add    %al,(%eax)
	...

00800d6c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	05 00 00 00 30       	add    $0x30000000,%eax
  800d77:	c1 e8 0c             	shr    $0xc,%eax
}
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	89 04 24             	mov    %eax,(%esp)
  800d88:	e8 df ff ff ff       	call   800d6c <fd2num>
  800d8d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d92:	c1 e0 0c             	shl    $0xc,%eax
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	53                   	push   %ebx
  800d9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d9e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800da3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da5:	89 c2                	mov    %eax,%edx
  800da7:	c1 ea 16             	shr    $0x16,%edx
  800daa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db1:	f6 c2 01             	test   $0x1,%dl
  800db4:	74 11                	je     800dc7 <fd_alloc+0x30>
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	c1 ea 0c             	shr    $0xc,%edx
  800dbb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc2:	f6 c2 01             	test   $0x1,%dl
  800dc5:	75 09                	jne    800dd0 <fd_alloc+0x39>
			*fd_store = fd;
  800dc7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dce:	eb 17                	jmp    800de7 <fd_alloc+0x50>
  800dd0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dda:	75 c7                	jne    800da3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ddc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800de2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800de7:	5b                   	pop    %ebx
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df0:	83 f8 1f             	cmp    $0x1f,%eax
  800df3:	77 36                	ja     800e2b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df5:	05 00 00 0d 00       	add    $0xd0000,%eax
  800dfa:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dfd:	89 c2                	mov    %eax,%edx
  800dff:	c1 ea 16             	shr    $0x16,%edx
  800e02:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e09:	f6 c2 01             	test   $0x1,%dl
  800e0c:	74 24                	je     800e32 <fd_lookup+0x48>
  800e0e:	89 c2                	mov    %eax,%edx
  800e10:	c1 ea 0c             	shr    $0xc,%edx
  800e13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1a:	f6 c2 01             	test   $0x1,%dl
  800e1d:	74 1a                	je     800e39 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e22:	89 02                	mov    %eax,(%edx)
	return 0;
  800e24:	b8 00 00 00 00       	mov    $0x0,%eax
  800e29:	eb 13                	jmp    800e3e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e30:	eb 0c                	jmp    800e3e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e37:	eb 05                	jmp    800e3e <fd_lookup+0x54>
  800e39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	53                   	push   %ebx
  800e44:	83 ec 14             	sub    $0x14,%esp
  800e47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e52:	eb 0e                	jmp    800e62 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800e54:	39 08                	cmp    %ecx,(%eax)
  800e56:	75 09                	jne    800e61 <dev_lookup+0x21>
			*dev = devtab[i];
  800e58:	89 03                	mov    %eax,(%ebx)
			return 0;
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5f:	eb 33                	jmp    800e94 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e61:	42                   	inc    %edx
  800e62:	8b 04 95 e8 22 80 00 	mov    0x8022e8(,%edx,4),%eax
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	75 e7                	jne    800e54 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6d:	a1 04 40 80 00       	mov    0x804004,%eax
  800e72:	8b 40 48             	mov    0x48(%eax),%eax
  800e75:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7d:	c7 04 24 6c 22 80 00 	movl   $0x80226c,(%esp)
  800e84:	e8 db f2 ff ff       	call   800164 <cprintf>
	*dev = 0;
  800e89:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e94:	83 c4 14             	add    $0x14,%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 30             	sub    $0x30,%esp
  800ea2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea5:	8a 45 0c             	mov    0xc(%ebp),%al
  800ea8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eab:	89 34 24             	mov    %esi,(%esp)
  800eae:	e8 b9 fe ff ff       	call   800d6c <fd2num>
  800eb3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800eb6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eba:	89 04 24             	mov    %eax,(%esp)
  800ebd:	e8 28 ff ff ff       	call   800dea <fd_lookup>
  800ec2:	89 c3                	mov    %eax,%ebx
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	78 05                	js     800ecd <fd_close+0x33>
	    || fd != fd2)
  800ec8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ecb:	74 0d                	je     800eda <fd_close+0x40>
		return (must_exist ? r : 0);
  800ecd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ed1:	75 46                	jne    800f19 <fd_close+0x7f>
  800ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed8:	eb 3f                	jmp    800f19 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800edd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee1:	8b 06                	mov    (%esi),%eax
  800ee3:	89 04 24             	mov    %eax,(%esp)
  800ee6:	e8 55 ff ff ff       	call   800e40 <dev_lookup>
  800eeb:	89 c3                	mov    %eax,%ebx
  800eed:	85 c0                	test   %eax,%eax
  800eef:	78 18                	js     800f09 <fd_close+0x6f>
		if (dev->dev_close)
  800ef1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef4:	8b 40 10             	mov    0x10(%eax),%eax
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	74 09                	je     800f04 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800efb:	89 34 24             	mov    %esi,(%esp)
  800efe:	ff d0                	call   *%eax
  800f00:	89 c3                	mov    %eax,%ebx
  800f02:	eb 05                	jmp    800f09 <fd_close+0x6f>
		else
			r = 0;
  800f04:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f09:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f14:	e8 8f fc ff ff       	call   800ba8 <sys_page_unmap>
	return r;
}
  800f19:	89 d8                	mov    %ebx,%eax
  800f1b:	83 c4 30             	add    $0x30,%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	89 04 24             	mov    %eax,(%esp)
  800f35:	e8 b0 fe ff ff       	call   800dea <fd_lookup>
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 13                	js     800f51 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f3e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f45:	00 
  800f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f49:	89 04 24             	mov    %eax,(%esp)
  800f4c:	e8 49 ff ff ff       	call   800e9a <fd_close>
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <close_all>:

void
close_all(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	53                   	push   %ebx
  800f57:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5f:	89 1c 24             	mov    %ebx,(%esp)
  800f62:	e8 bb ff ff ff       	call   800f22 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f67:	43                   	inc    %ebx
  800f68:	83 fb 20             	cmp    $0x20,%ebx
  800f6b:	75 f2                	jne    800f5f <close_all+0xc>
		close(i);
}
  800f6d:	83 c4 14             	add    $0x14,%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 4c             	sub    $0x4c,%esp
  800f7c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f86:	8b 45 08             	mov    0x8(%ebp),%eax
  800f89:	89 04 24             	mov    %eax,(%esp)
  800f8c:	e8 59 fe ff ff       	call   800dea <fd_lookup>
  800f91:	89 c3                	mov    %eax,%ebx
  800f93:	85 c0                	test   %eax,%eax
  800f95:	0f 88 e1 00 00 00    	js     80107c <dup+0x109>
		return r;
	close(newfdnum);
  800f9b:	89 3c 24             	mov    %edi,(%esp)
  800f9e:	e8 7f ff ff ff       	call   800f22 <close>

	newfd = INDEX2FD(newfdnum);
  800fa3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fa9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800faf:	89 04 24             	mov    %eax,(%esp)
  800fb2:	e8 c5 fd ff ff       	call   800d7c <fd2data>
  800fb7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fb9:	89 34 24             	mov    %esi,(%esp)
  800fbc:	e8 bb fd ff ff       	call   800d7c <fd2data>
  800fc1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc4:	89 d8                	mov    %ebx,%eax
  800fc6:	c1 e8 16             	shr    $0x16,%eax
  800fc9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd0:	a8 01                	test   $0x1,%al
  800fd2:	74 46                	je     80101a <dup+0xa7>
  800fd4:	89 d8                	mov    %ebx,%eax
  800fd6:	c1 e8 0c             	shr    $0xc,%eax
  800fd9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe0:	f6 c2 01             	test   $0x1,%dl
  800fe3:	74 35                	je     80101a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fec:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ff8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ffc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801003:	00 
  801004:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801008:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100f:	e8 41 fb ff ff       	call   800b55 <sys_page_map>
  801014:	89 c3                	mov    %eax,%ebx
  801016:	85 c0                	test   %eax,%eax
  801018:	78 3b                	js     801055 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80101a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101d:	89 c2                	mov    %eax,%edx
  80101f:	c1 ea 0c             	shr    $0xc,%edx
  801022:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801029:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80102f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801033:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801037:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103e:	00 
  80103f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801043:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80104a:	e8 06 fb ff ff       	call   800b55 <sys_page_map>
  80104f:	89 c3                	mov    %eax,%ebx
  801051:	85 c0                	test   %eax,%eax
  801053:	79 25                	jns    80107a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801055:	89 74 24 04          	mov    %esi,0x4(%esp)
  801059:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801060:	e8 43 fb ff ff       	call   800ba8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801065:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801073:	e8 30 fb ff ff       	call   800ba8 <sys_page_unmap>
	return r;
  801078:	eb 02                	jmp    80107c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80107a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80107c:	89 d8                	mov    %ebx,%eax
  80107e:	83 c4 4c             	add    $0x4c,%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	53                   	push   %ebx
  80108a:	83 ec 24             	sub    $0x24,%esp
  80108d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801090:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801093:	89 44 24 04          	mov    %eax,0x4(%esp)
  801097:	89 1c 24             	mov    %ebx,(%esp)
  80109a:	e8 4b fd ff ff       	call   800dea <fd_lookup>
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 6d                	js     801110 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ad:	8b 00                	mov    (%eax),%eax
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 89 fd ff ff       	call   800e40 <dev_lookup>
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 55                	js     801110 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010be:	8b 50 08             	mov    0x8(%eax),%edx
  8010c1:	83 e2 03             	and    $0x3,%edx
  8010c4:	83 fa 01             	cmp    $0x1,%edx
  8010c7:	75 23                	jne    8010ec <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ce:	8b 40 48             	mov    0x48(%eax),%eax
  8010d1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d9:	c7 04 24 ad 22 80 00 	movl   $0x8022ad,(%esp)
  8010e0:	e8 7f f0 ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8010e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ea:	eb 24                	jmp    801110 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010ef:	8b 52 08             	mov    0x8(%edx),%edx
  8010f2:	85 d2                	test   %edx,%edx
  8010f4:	74 15                	je     80110b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801100:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801104:	89 04 24             	mov    %eax,(%esp)
  801107:	ff d2                	call   *%edx
  801109:	eb 05                	jmp    801110 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80110b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801110:	83 c4 24             	add    $0x24,%esp
  801113:	5b                   	pop    %ebx
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	83 ec 1c             	sub    $0x1c,%esp
  80111f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801122:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801125:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112a:	eb 23                	jmp    80114f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80112c:	89 f0                	mov    %esi,%eax
  80112e:	29 d8                	sub    %ebx,%eax
  801130:	89 44 24 08          	mov    %eax,0x8(%esp)
  801134:	8b 45 0c             	mov    0xc(%ebp),%eax
  801137:	01 d8                	add    %ebx,%eax
  801139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113d:	89 3c 24             	mov    %edi,(%esp)
  801140:	e8 41 ff ff ff       	call   801086 <read>
		if (m < 0)
  801145:	85 c0                	test   %eax,%eax
  801147:	78 10                	js     801159 <readn+0x43>
			return m;
		if (m == 0)
  801149:	85 c0                	test   %eax,%eax
  80114b:	74 0a                	je     801157 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114d:	01 c3                	add    %eax,%ebx
  80114f:	39 f3                	cmp    %esi,%ebx
  801151:	72 d9                	jb     80112c <readn+0x16>
  801153:	89 d8                	mov    %ebx,%eax
  801155:	eb 02                	jmp    801159 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801157:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801159:	83 c4 1c             	add    $0x1c,%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	53                   	push   %ebx
  801165:	83 ec 24             	sub    $0x24,%esp
  801168:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801172:	89 1c 24             	mov    %ebx,(%esp)
  801175:	e8 70 fc ff ff       	call   800dea <fd_lookup>
  80117a:	85 c0                	test   %eax,%eax
  80117c:	78 68                	js     8011e6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801181:	89 44 24 04          	mov    %eax,0x4(%esp)
  801185:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801188:	8b 00                	mov    (%eax),%eax
  80118a:	89 04 24             	mov    %eax,(%esp)
  80118d:	e8 ae fc ff ff       	call   800e40 <dev_lookup>
  801192:	85 c0                	test   %eax,%eax
  801194:	78 50                	js     8011e6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801196:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801199:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80119d:	75 23                	jne    8011c2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80119f:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a4:	8b 40 48             	mov    0x48(%eax),%eax
  8011a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011af:	c7 04 24 c9 22 80 00 	movl   $0x8022c9,(%esp)
  8011b6:	e8 a9 ef ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8011bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c0:	eb 24                	jmp    8011e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011c8:	85 d2                	test   %edx,%edx
  8011ca:	74 15                	je     8011e1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011da:	89 04 24             	mov    %eax,(%esp)
  8011dd:	ff d2                	call   *%edx
  8011df:	eb 05                	jmp    8011e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011e6:	83 c4 24             	add    $0x24,%esp
  8011e9:	5b                   	pop    %ebx
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	89 04 24             	mov    %eax,(%esp)
  8011ff:	e8 e6 fb ff ff       	call   800dea <fd_lookup>
  801204:	85 c0                	test   %eax,%eax
  801206:	78 0e                	js     801216 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801208:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	53                   	push   %ebx
  80121c:	83 ec 24             	sub    $0x24,%esp
  80121f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	89 44 24 04          	mov    %eax,0x4(%esp)
  801229:	89 1c 24             	mov    %ebx,(%esp)
  80122c:	e8 b9 fb ff ff       	call   800dea <fd_lookup>
  801231:	85 c0                	test   %eax,%eax
  801233:	78 61                	js     801296 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	8b 00                	mov    (%eax),%eax
  801241:	89 04 24             	mov    %eax,(%esp)
  801244:	e8 f7 fb ff ff       	call   800e40 <dev_lookup>
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 49                	js     801296 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801250:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801254:	75 23                	jne    801279 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801256:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80125b:	8b 40 48             	mov    0x48(%eax),%eax
  80125e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  80126d:	e8 f2 ee ff ff       	call   800164 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801272:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801277:	eb 1d                	jmp    801296 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801279:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127c:	8b 52 18             	mov    0x18(%edx),%edx
  80127f:	85 d2                	test   %edx,%edx
  801281:	74 0e                	je     801291 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801286:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80128a:	89 04 24             	mov    %eax,(%esp)
  80128d:	ff d2                	call   *%edx
  80128f:	eb 05                	jmp    801296 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801291:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801296:	83 c4 24             	add    $0x24,%esp
  801299:	5b                   	pop    %ebx
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 24             	sub    $0x24,%esp
  8012a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b0:	89 04 24             	mov    %eax,(%esp)
  8012b3:	e8 32 fb ff ff       	call   800dea <fd_lookup>
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 52                	js     80130e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c6:	8b 00                	mov    (%eax),%eax
  8012c8:	89 04 24             	mov    %eax,(%esp)
  8012cb:	e8 70 fb ff ff       	call   800e40 <dev_lookup>
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 3a                	js     80130e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8012d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012db:	74 2c                	je     801309 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012e7:	00 00 00 
	stat->st_isdir = 0;
  8012ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f1:	00 00 00 
	stat->st_dev = dev;
  8012f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801301:	89 14 24             	mov    %edx,(%esp)
  801304:	ff 50 14             	call   *0x14(%eax)
  801307:	eb 05                	jmp    80130e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801309:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80130e:	83 c4 24             	add    $0x24,%esp
  801311:	5b                   	pop    %ebx
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    

00801314 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	56                   	push   %esi
  801318:	53                   	push   %ebx
  801319:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80131c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801323:	00 
  801324:	8b 45 08             	mov    0x8(%ebp),%eax
  801327:	89 04 24             	mov    %eax,(%esp)
  80132a:	e8 fe 01 00 00       	call   80152d <open>
  80132f:	89 c3                	mov    %eax,%ebx
  801331:	85 c0                	test   %eax,%eax
  801333:	78 1b                	js     801350 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801335:	8b 45 0c             	mov    0xc(%ebp),%eax
  801338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133c:	89 1c 24             	mov    %ebx,(%esp)
  80133f:	e8 58 ff ff ff       	call   80129c <fstat>
  801344:	89 c6                	mov    %eax,%esi
	close(fd);
  801346:	89 1c 24             	mov    %ebx,(%esp)
  801349:	e8 d4 fb ff ff       	call   800f22 <close>
	return r;
  80134e:	89 f3                	mov    %esi,%ebx
}
  801350:	89 d8                	mov    %ebx,%eax
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	5b                   	pop    %ebx
  801356:	5e                   	pop    %esi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    
  801359:	00 00                	add    %al,(%eax)
	...

0080135c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
  801361:	83 ec 10             	sub    $0x10,%esp
  801364:	89 c3                	mov    %eax,%ebx
  801366:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801368:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80136f:	75 11                	jne    801382 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801371:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801378:	e8 92 08 00 00       	call   801c0f <ipc_find_env>
  80137d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801382:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801389:	00 
  80138a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801391:	00 
  801392:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801396:	a1 00 40 80 00       	mov    0x804000,%eax
  80139b:	89 04 24             	mov    %eax,(%esp)
  80139e:	e8 02 08 00 00       	call   801ba5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013aa:	00 
  8013ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b6:	e8 81 07 00 00       	call   801b3c <ipc_recv>
}
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	5b                   	pop    %ebx
  8013bf:	5e                   	pop    %esi
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013db:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8013e5:	e8 72 ff ff ff       	call   80135c <fsipc>
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801402:	b8 06 00 00 00       	mov    $0x6,%eax
  801407:	e8 50 ff ff ff       	call   80135c <fsipc>
}
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	53                   	push   %ebx
  801412:	83 ec 14             	sub    $0x14,%esp
  801415:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
  80141b:	8b 40 0c             	mov    0xc(%eax),%eax
  80141e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801423:	ba 00 00 00 00       	mov    $0x0,%edx
  801428:	b8 05 00 00 00       	mov    $0x5,%eax
  80142d:	e8 2a ff ff ff       	call   80135c <fsipc>
  801432:	85 c0                	test   %eax,%eax
  801434:	78 2b                	js     801461 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801436:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80143d:	00 
  80143e:	89 1c 24             	mov    %ebx,(%esp)
  801441:	e8 c9 f2 ff ff       	call   80070f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801446:	a1 80 50 80 00       	mov    0x805080,%eax
  80144b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801451:	a1 84 50 80 00       	mov    0x805084,%eax
  801456:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80145c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801461:	83 c4 14             	add    $0x14,%esp
  801464:	5b                   	pop    %ebx
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    

00801467 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80146d:	c7 44 24 08 f8 22 80 	movl   $0x8022f8,0x8(%esp)
  801474:	00 
  801475:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80147c:	00 
  80147d:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  801484:	e8 5b 06 00 00       	call   801ae4 <_panic>

00801489 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	83 ec 10             	sub    $0x10,%esp
  801491:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801494:	8b 45 08             	mov    0x8(%ebp),%eax
  801497:	8b 40 0c             	mov    0xc(%eax),%eax
  80149a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80149f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014aa:	b8 03 00 00 00       	mov    $0x3,%eax
  8014af:	e8 a8 fe ff ff       	call   80135c <fsipc>
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 6a                	js     801524 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8014ba:	39 c6                	cmp    %eax,%esi
  8014bc:	73 24                	jae    8014e2 <devfile_read+0x59>
  8014be:	c7 44 24 0c 21 23 80 	movl   $0x802321,0xc(%esp)
  8014c5:	00 
  8014c6:	c7 44 24 08 28 23 80 	movl   $0x802328,0x8(%esp)
  8014cd:	00 
  8014ce:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8014d5:	00 
  8014d6:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  8014dd:	e8 02 06 00 00       	call   801ae4 <_panic>
	assert(r <= PGSIZE);
  8014e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014e7:	7e 24                	jle    80150d <devfile_read+0x84>
  8014e9:	c7 44 24 0c 3d 23 80 	movl   $0x80233d,0xc(%esp)
  8014f0:	00 
  8014f1:	c7 44 24 08 28 23 80 	movl   $0x802328,0x8(%esp)
  8014f8:	00 
  8014f9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801500:	00 
  801501:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  801508:	e8 d7 05 00 00       	call   801ae4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80150d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801511:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801518:	00 
  801519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151c:	89 04 24             	mov    %eax,(%esp)
  80151f:	e8 64 f3 ff ff       	call   800888 <memmove>
	return r;
}
  801524:	89 d8                	mov    %ebx,%eax
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	5b                   	pop    %ebx
  80152a:	5e                   	pop    %esi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	83 ec 20             	sub    $0x20,%esp
  801535:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801538:	89 34 24             	mov    %esi,(%esp)
  80153b:	e8 9c f1 ff ff       	call   8006dc <strlen>
  801540:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801545:	7f 60                	jg     8015a7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154a:	89 04 24             	mov    %eax,(%esp)
  80154d:	e8 45 f8 ff ff       	call   800d97 <fd_alloc>
  801552:	89 c3                	mov    %eax,%ebx
  801554:	85 c0                	test   %eax,%eax
  801556:	78 54                	js     8015ac <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801558:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155c:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801563:	e8 a7 f1 ff ff       	call   80070f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801570:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801573:	b8 01 00 00 00       	mov    $0x1,%eax
  801578:	e8 df fd ff ff       	call   80135c <fsipc>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	85 c0                	test   %eax,%eax
  801581:	79 15                	jns    801598 <open+0x6b>
		fd_close(fd, 0);
  801583:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80158a:	00 
  80158b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158e:	89 04 24             	mov    %eax,(%esp)
  801591:	e8 04 f9 ff ff       	call   800e9a <fd_close>
		return r;
  801596:	eb 14                	jmp    8015ac <open+0x7f>
	}

	return fd2num(fd);
  801598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159b:	89 04 24             	mov    %eax,(%esp)
  80159e:	e8 c9 f7 ff ff       	call   800d6c <fd2num>
  8015a3:	89 c3                	mov    %eax,%ebx
  8015a5:	eb 05                	jmp    8015ac <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015a7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015ac:	89 d8                	mov    %ebx,%eax
  8015ae:	83 c4 20             	add    $0x20,%esp
  8015b1:	5b                   	pop    %ebx
  8015b2:	5e                   	pop    %esi
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c5:	e8 92 fd ff ff       	call   80135c <fsipc>
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 10             	sub    $0x10,%esp
  8015d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015da:	89 04 24             	mov    %eax,(%esp)
  8015dd:	e8 9a f7 ff ff       	call   800d7c <fd2data>
  8015e2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015e4:	c7 44 24 04 49 23 80 	movl   $0x802349,0x4(%esp)
  8015eb:	00 
  8015ec:	89 34 24             	mov    %esi,(%esp)
  8015ef:	e8 1b f1 ff ff       	call   80070f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015f4:	8b 43 04             	mov    0x4(%ebx),%eax
  8015f7:	2b 03                	sub    (%ebx),%eax
  8015f9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8015ff:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801606:	00 00 00 
	stat->st_dev = &devpipe;
  801609:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801610:	30 80 00 
	return 0;
}
  801613:	b8 00 00 00 00       	mov    $0x0,%eax
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	83 ec 14             	sub    $0x14,%esp
  801626:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80162d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801634:	e8 6f f5 ff ff       	call   800ba8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801639:	89 1c 24             	mov    %ebx,(%esp)
  80163c:	e8 3b f7 ff ff       	call   800d7c <fd2data>
  801641:	89 44 24 04          	mov    %eax,0x4(%esp)
  801645:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164c:	e8 57 f5 ff ff       	call   800ba8 <sys_page_unmap>
}
  801651:	83 c4 14             	add    $0x14,%esp
  801654:	5b                   	pop    %ebx
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    

00801657 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	57                   	push   %edi
  80165b:	56                   	push   %esi
  80165c:	53                   	push   %ebx
  80165d:	83 ec 2c             	sub    $0x2c,%esp
  801660:	89 c7                	mov    %eax,%edi
  801662:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801665:	a1 04 40 80 00       	mov    0x804004,%eax
  80166a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80166d:	89 3c 24             	mov    %edi,(%esp)
  801670:	e8 df 05 00 00       	call   801c54 <pageref>
  801675:	89 c6                	mov    %eax,%esi
  801677:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167a:	89 04 24             	mov    %eax,(%esp)
  80167d:	e8 d2 05 00 00       	call   801c54 <pageref>
  801682:	39 c6                	cmp    %eax,%esi
  801684:	0f 94 c0             	sete   %al
  801687:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80168a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801690:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801693:	39 cb                	cmp    %ecx,%ebx
  801695:	75 08                	jne    80169f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801697:	83 c4 2c             	add    $0x2c,%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5f                   	pop    %edi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80169f:	83 f8 01             	cmp    $0x1,%eax
  8016a2:	75 c1                	jne    801665 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016a4:	8b 42 58             	mov    0x58(%edx),%eax
  8016a7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016ae:	00 
  8016af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b7:	c7 04 24 50 23 80 00 	movl   $0x802350,(%esp)
  8016be:	e8 a1 ea ff ff       	call   800164 <cprintf>
  8016c3:	eb a0                	jmp    801665 <_pipeisclosed+0xe>

008016c5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	57                   	push   %edi
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 1c             	sub    $0x1c,%esp
  8016ce:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016d1:	89 34 24             	mov    %esi,(%esp)
  8016d4:	e8 a3 f6 ff ff       	call   800d7c <fd2data>
  8016d9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016db:	bf 00 00 00 00       	mov    $0x0,%edi
  8016e0:	eb 3c                	jmp    80171e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016e2:	89 da                	mov    %ebx,%edx
  8016e4:	89 f0                	mov    %esi,%eax
  8016e6:	e8 6c ff ff ff       	call   801657 <_pipeisclosed>
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	75 38                	jne    801727 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016ef:	e8 ee f3 ff ff       	call   800ae2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f4:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f7:	8b 13                	mov    (%ebx),%edx
  8016f9:	83 c2 20             	add    $0x20,%edx
  8016fc:	39 d0                	cmp    %edx,%eax
  8016fe:	73 e2                	jae    8016e2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801700:	8b 55 0c             	mov    0xc(%ebp),%edx
  801703:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801706:	89 c2                	mov    %eax,%edx
  801708:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80170e:	79 05                	jns    801715 <devpipe_write+0x50>
  801710:	4a                   	dec    %edx
  801711:	83 ca e0             	or     $0xffffffe0,%edx
  801714:	42                   	inc    %edx
  801715:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801719:	40                   	inc    %eax
  80171a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171d:	47                   	inc    %edi
  80171e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801721:	75 d1                	jne    8016f4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801723:	89 f8                	mov    %edi,%eax
  801725:	eb 05                	jmp    80172c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801727:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80172c:	83 c4 1c             	add    $0x1c,%esp
  80172f:	5b                   	pop    %ebx
  801730:	5e                   	pop    %esi
  801731:	5f                   	pop    %edi
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	57                   	push   %edi
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	83 ec 1c             	sub    $0x1c,%esp
  80173d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801740:	89 3c 24             	mov    %edi,(%esp)
  801743:	e8 34 f6 ff ff       	call   800d7c <fd2data>
  801748:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174a:	be 00 00 00 00       	mov    $0x0,%esi
  80174f:	eb 3a                	jmp    80178b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801751:	85 f6                	test   %esi,%esi
  801753:	74 04                	je     801759 <devpipe_read+0x25>
				return i;
  801755:	89 f0                	mov    %esi,%eax
  801757:	eb 40                	jmp    801799 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801759:	89 da                	mov    %ebx,%edx
  80175b:	89 f8                	mov    %edi,%eax
  80175d:	e8 f5 fe ff ff       	call   801657 <_pipeisclosed>
  801762:	85 c0                	test   %eax,%eax
  801764:	75 2e                	jne    801794 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801766:	e8 77 f3 ff ff       	call   800ae2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80176b:	8b 03                	mov    (%ebx),%eax
  80176d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801770:	74 df                	je     801751 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801772:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801777:	79 05                	jns    80177e <devpipe_read+0x4a>
  801779:	48                   	dec    %eax
  80177a:	83 c8 e0             	or     $0xffffffe0,%eax
  80177d:	40                   	inc    %eax
  80177e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801782:	8b 55 0c             	mov    0xc(%ebp),%edx
  801785:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801788:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178a:	46                   	inc    %esi
  80178b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80178e:	75 db                	jne    80176b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801790:	89 f0                	mov    %esi,%eax
  801792:	eb 05                	jmp    801799 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801794:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801799:	83 c4 1c             	add    $0x1c,%esp
  80179c:	5b                   	pop    %ebx
  80179d:	5e                   	pop    %esi
  80179e:	5f                   	pop    %edi
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	57                   	push   %edi
  8017a5:	56                   	push   %esi
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 3c             	sub    $0x3c,%esp
  8017aa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017b0:	89 04 24             	mov    %eax,(%esp)
  8017b3:	e8 df f5 ff ff       	call   800d97 <fd_alloc>
  8017b8:	89 c3                	mov    %eax,%ebx
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	0f 88 45 01 00 00    	js     801907 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017c9:	00 
  8017ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d8:	e8 24 f3 ff ff       	call   800b01 <sys_page_alloc>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	0f 88 20 01 00 00    	js     801907 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017ea:	89 04 24             	mov    %eax,(%esp)
  8017ed:	e8 a5 f5 ff ff       	call   800d97 <fd_alloc>
  8017f2:	89 c3                	mov    %eax,%ebx
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	0f 88 f8 00 00 00    	js     8018f4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017fc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801803:	00 
  801804:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801812:	e8 ea f2 ff ff       	call   800b01 <sys_page_alloc>
  801817:	89 c3                	mov    %eax,%ebx
  801819:	85 c0                	test   %eax,%eax
  80181b:	0f 88 d3 00 00 00    	js     8018f4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801824:	89 04 24             	mov    %eax,(%esp)
  801827:	e8 50 f5 ff ff       	call   800d7c <fd2data>
  80182c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801835:	00 
  801836:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801841:	e8 bb f2 ff ff       	call   800b01 <sys_page_alloc>
  801846:	89 c3                	mov    %eax,%ebx
  801848:	85 c0                	test   %eax,%eax
  80184a:	0f 88 91 00 00 00    	js     8018e1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801850:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801853:	89 04 24             	mov    %eax,(%esp)
  801856:	e8 21 f5 ff ff       	call   800d7c <fd2data>
  80185b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801862:	00 
  801863:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801867:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80186e:	00 
  80186f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801873:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187a:	e8 d6 f2 ff ff       	call   800b55 <sys_page_map>
  80187f:	89 c3                	mov    %eax,%ebx
  801881:	85 c0                	test   %eax,%eax
  801883:	78 4c                	js     8018d1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801885:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80188b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80188e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801890:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801893:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80189a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b2:	89 04 24             	mov    %eax,(%esp)
  8018b5:	e8 b2 f4 ff ff       	call   800d6c <fd2num>
  8018ba:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018bf:	89 04 24             	mov    %eax,(%esp)
  8018c2:	e8 a5 f4 ff ff       	call   800d6c <fd2num>
  8018c7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018cf:	eb 36                	jmp    801907 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8018d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018dc:	e8 c7 f2 ff ff       	call   800ba8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8018e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ef:	e8 b4 f2 ff ff       	call   800ba8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8018f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801902:	e8 a1 f2 ff ff       	call   800ba8 <sys_page_unmap>
    err:
	return r;
}
  801907:	89 d8                	mov    %ebx,%eax
  801909:	83 c4 3c             	add    $0x3c,%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5f                   	pop    %edi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	89 04 24             	mov    %eax,(%esp)
  801924:	e8 c1 f4 ff ff       	call   800dea <fd_lookup>
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 15                	js     801942 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80192d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801930:	89 04 24             	mov    %eax,(%esp)
  801933:	e8 44 f4 ff ff       	call   800d7c <fd2data>
	return _pipeisclosed(fd, p);
  801938:	89 c2                	mov    %eax,%edx
  80193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193d:	e8 15 fd ff ff       	call   801657 <_pipeisclosed>
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801954:	c7 44 24 04 68 23 80 	movl   $0x802368,0x4(%esp)
  80195b:	00 
  80195c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	e8 a8 ed ff ff       	call   80070f <strcpy>
	return 0;
}
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	57                   	push   %edi
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80197a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80197f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801985:	eb 30                	jmp    8019b7 <devcons_write+0x49>
		m = n - tot;
  801987:	8b 75 10             	mov    0x10(%ebp),%esi
  80198a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80198c:	83 fe 7f             	cmp    $0x7f,%esi
  80198f:	76 05                	jbe    801996 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801991:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801996:	89 74 24 08          	mov    %esi,0x8(%esp)
  80199a:	03 45 0c             	add    0xc(%ebp),%eax
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	89 3c 24             	mov    %edi,(%esp)
  8019a4:	e8 df ee ff ff       	call   800888 <memmove>
		sys_cputs(buf, m);
  8019a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ad:	89 3c 24             	mov    %edi,(%esp)
  8019b0:	e8 7f f0 ff ff       	call   800a34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019b5:	01 f3                	add    %esi,%ebx
  8019b7:	89 d8                	mov    %ebx,%eax
  8019b9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019bc:	72 c9                	jb     801987 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019be:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5f                   	pop    %edi
  8019c7:	5d                   	pop    %ebp
  8019c8:	c3                   	ret    

008019c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019d3:	75 07                	jne    8019dc <devcons_read+0x13>
  8019d5:	eb 25                	jmp    8019fc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019d7:	e8 06 f1 ff ff       	call   800ae2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019dc:	e8 71 f0 ff ff       	call   800a52 <sys_cgetc>
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	74 f2                	je     8019d7 <devcons_read+0xe>
  8019e5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 1d                	js     801a08 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019eb:	83 f8 04             	cmp    $0x4,%eax
  8019ee:	74 13                	je     801a03 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8019f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f3:	88 10                	mov    %dl,(%eax)
	return 1;
  8019f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fa:	eb 0c                	jmp    801a08 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8019fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801a01:	eb 05                	jmp    801a08 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a16:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a1d:	00 
  801a1e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 0b f0 ff ff       	call   800a34 <sys_cputs>
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <getchar>:

int
getchar(void)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a31:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a38:	00 
  801a39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a47:	e8 3a f6 ff ff       	call   801086 <read>
	if (r < 0)
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	78 0f                	js     801a5f <getchar+0x34>
		return r;
	if (r < 1)
  801a50:	85 c0                	test   %eax,%eax
  801a52:	7e 06                	jle    801a5a <getchar+0x2f>
		return -E_EOF;
	return c;
  801a54:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a58:	eb 05                	jmp    801a5f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a5a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	89 04 24             	mov    %eax,(%esp)
  801a74:	e8 71 f3 ff ff       	call   800dea <fd_lookup>
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	78 11                	js     801a8e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a80:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a86:	39 10                	cmp    %edx,(%eax)
  801a88:	0f 94 c0             	sete   %al
  801a8b:	0f b6 c0             	movzbl %al,%eax
}
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <opencons>:

int
opencons(void)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a99:	89 04 24             	mov    %eax,(%esp)
  801a9c:	e8 f6 f2 ff ff       	call   800d97 <fd_alloc>
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	78 3c                	js     801ae1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aa5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aac:	00 
  801aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abb:	e8 41 f0 ff ff       	call   800b01 <sys_page_alloc>
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	78 1d                	js     801ae1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ac4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ad9:	89 04 24             	mov    %eax,(%esp)
  801adc:	e8 8b f2 ff ff       	call   800d6c <fd2num>
}
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    
	...

00801ae4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801aec:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aef:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801af5:	e8 c9 ef ff ff       	call   800ac3 <sys_getenvid>
  801afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afd:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b01:	8b 55 08             	mov    0x8(%ebp),%edx
  801b04:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b10:	c7 04 24 74 23 80 00 	movl   $0x802374,(%esp)
  801b17:	e8 48 e6 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b20:	8b 45 10             	mov    0x10(%ebp),%eax
  801b23:	89 04 24             	mov    %eax,(%esp)
  801b26:	e8 d8 e5 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  801b2b:	c7 04 24 61 23 80 00 	movl   $0x802361,(%esp)
  801b32:	e8 2d e6 ff ff       	call   800164 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b37:	cc                   	int3   
  801b38:	eb fd                	jmp    801b37 <_panic+0x53>
	...

00801b3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	57                   	push   %edi
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	83 ec 1c             	sub    $0x1c,%esp
  801b45:	8b 75 08             	mov    0x8(%ebp),%esi
  801b48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b4b:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801b4e:	85 db                	test   %ebx,%ebx
  801b50:	75 05                	jne    801b57 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801b52:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801b57:	89 1c 24             	mov    %ebx,(%esp)
  801b5a:	e8 b8 f1 ff ff       	call   800d17 <sys_ipc_recv>
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	79 16                	jns    801b79 <ipc_recv+0x3d>
		*from_env_store = 0;
  801b63:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801b69:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801b6f:	89 1c 24             	mov    %ebx,(%esp)
  801b72:	e8 a0 f1 ff ff       	call   800d17 <sys_ipc_recv>
  801b77:	eb 24                	jmp    801b9d <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801b79:	85 f6                	test   %esi,%esi
  801b7b:	74 0a                	je     801b87 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801b7d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b82:	8b 40 74             	mov    0x74(%eax),%eax
  801b85:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801b87:	85 ff                	test   %edi,%edi
  801b89:	74 0a                	je     801b95 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801b8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b90:	8b 40 78             	mov    0x78(%eax),%eax
  801b93:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801b95:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b9d:	83 c4 1c             	add    $0x1c,%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	57                   	push   %edi
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	83 ec 1c             	sub    $0x1c,%esp
  801bae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bb4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801bb7:	85 db                	test   %ebx,%ebx
  801bb9:	75 05                	jne    801bc0 <ipc_send+0x1b>
		pg = (void *)-1;
  801bbb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bc0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bc4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bc8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	89 04 24             	mov    %eax,(%esp)
  801bd2:	e8 1d f1 ff ff       	call   800cf4 <sys_ipc_try_send>
		if (r == 0) {		
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	74 2c                	je     801c07 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801bdb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bde:	75 07                	jne    801be7 <ipc_send+0x42>
			sys_yield();
  801be0:	e8 fd ee ff ff       	call   800ae2 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801be5:	eb d9                	jmp    801bc0 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801be7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801beb:	c7 44 24 08 98 23 80 	movl   $0x802398,0x8(%esp)
  801bf2:	00 
  801bf3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801bfa:	00 
  801bfb:	c7 04 24 a6 23 80 00 	movl   $0x8023a6,(%esp)
  801c02:	e8 dd fe ff ff       	call   801ae4 <_panic>
		}
	}
}
  801c07:	83 c4 1c             	add    $0x1c,%esp
  801c0a:	5b                   	pop    %ebx
  801c0b:	5e                   	pop    %esi
  801c0c:	5f                   	pop    %edi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	53                   	push   %ebx
  801c13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c16:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c1b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c22:	89 c2                	mov    %eax,%edx
  801c24:	c1 e2 07             	shl    $0x7,%edx
  801c27:	29 ca                	sub    %ecx,%edx
  801c29:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c2f:	8b 52 50             	mov    0x50(%edx),%edx
  801c32:	39 da                	cmp    %ebx,%edx
  801c34:	75 0f                	jne    801c45 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c36:	c1 e0 07             	shl    $0x7,%eax
  801c39:	29 c8                	sub    %ecx,%eax
  801c3b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c40:	8b 40 40             	mov    0x40(%eax),%eax
  801c43:	eb 0c                	jmp    801c51 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c45:	40                   	inc    %eax
  801c46:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c4b:	75 ce                	jne    801c1b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c4d:	66 b8 00 00          	mov    $0x0,%ax
}
  801c51:	5b                   	pop    %ebx
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    

00801c54 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c5a:	89 c2                	mov    %eax,%edx
  801c5c:	c1 ea 16             	shr    $0x16,%edx
  801c5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c66:	f6 c2 01             	test   $0x1,%dl
  801c69:	74 1e                	je     801c89 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c6b:	c1 e8 0c             	shr    $0xc,%eax
  801c6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c75:	a8 01                	test   $0x1,%al
  801c77:	74 17                	je     801c90 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c79:	c1 e8 0c             	shr    $0xc,%eax
  801c7c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c83:	ef 
  801c84:	0f b7 c0             	movzwl %ax,%eax
  801c87:	eb 0c                	jmp    801c95 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8e:	eb 05                	jmp    801c95 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c90:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    
	...

00801c98 <__udivdi3>:
  801c98:	55                   	push   %ebp
  801c99:	57                   	push   %edi
  801c9a:	56                   	push   %esi
  801c9b:	83 ec 10             	sub    $0x10,%esp
  801c9e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801ca2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801caa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cae:	89 cd                	mov    %ecx,%ebp
  801cb0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	75 2c                	jne    801ce4 <__udivdi3+0x4c>
  801cb8:	39 f9                	cmp    %edi,%ecx
  801cba:	77 68                	ja     801d24 <__udivdi3+0x8c>
  801cbc:	85 c9                	test   %ecx,%ecx
  801cbe:	75 0b                	jne    801ccb <__udivdi3+0x33>
  801cc0:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc5:	31 d2                	xor    %edx,%edx
  801cc7:	f7 f1                	div    %ecx
  801cc9:	89 c1                	mov    %eax,%ecx
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	89 f8                	mov    %edi,%eax
  801ccf:	f7 f1                	div    %ecx
  801cd1:	89 c7                	mov    %eax,%edi
  801cd3:	89 f0                	mov    %esi,%eax
  801cd5:	f7 f1                	div    %ecx
  801cd7:	89 c6                	mov    %eax,%esi
  801cd9:	89 f0                	mov    %esi,%eax
  801cdb:	89 fa                	mov    %edi,%edx
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    
  801ce4:	39 f8                	cmp    %edi,%eax
  801ce6:	77 2c                	ja     801d14 <__udivdi3+0x7c>
  801ce8:	0f bd f0             	bsr    %eax,%esi
  801ceb:	83 f6 1f             	xor    $0x1f,%esi
  801cee:	75 4c                	jne    801d3c <__udivdi3+0xa4>
  801cf0:	39 f8                	cmp    %edi,%eax
  801cf2:	bf 00 00 00 00       	mov    $0x0,%edi
  801cf7:	72 0a                	jb     801d03 <__udivdi3+0x6b>
  801cf9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801cfd:	0f 87 ad 00 00 00    	ja     801db0 <__udivdi3+0x118>
  801d03:	be 01 00 00 00       	mov    $0x1,%esi
  801d08:	89 f0                	mov    %esi,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
  801d13:	90                   	nop
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	31 f6                	xor    %esi,%esi
  801d18:	89 f0                	mov    %esi,%eax
  801d1a:	89 fa                	mov    %edi,%edx
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    
  801d23:	90                   	nop
  801d24:	89 fa                	mov    %edi,%edx
  801d26:	89 f0                	mov    %esi,%eax
  801d28:	f7 f1                	div    %ecx
  801d2a:	89 c6                	mov    %eax,%esi
  801d2c:	31 ff                	xor    %edi,%edi
  801d2e:	89 f0                	mov    %esi,%eax
  801d30:	89 fa                	mov    %edi,%edx
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d 76 00             	lea    0x0(%esi),%esi
  801d3c:	89 f1                	mov    %esi,%ecx
  801d3e:	d3 e0                	shl    %cl,%eax
  801d40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d44:	b8 20 00 00 00       	mov    $0x20,%eax
  801d49:	29 f0                	sub    %esi,%eax
  801d4b:	89 ea                	mov    %ebp,%edx
  801d4d:	88 c1                	mov    %al,%cl
  801d4f:	d3 ea                	shr    %cl,%edx
  801d51:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d55:	09 ca                	or     %ecx,%edx
  801d57:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d5b:	89 f1                	mov    %esi,%ecx
  801d5d:	d3 e5                	shl    %cl,%ebp
  801d5f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d63:	89 fd                	mov    %edi,%ebp
  801d65:	88 c1                	mov    %al,%cl
  801d67:	d3 ed                	shr    %cl,%ebp
  801d69:	89 fa                	mov    %edi,%edx
  801d6b:	89 f1                	mov    %esi,%ecx
  801d6d:	d3 e2                	shl    %cl,%edx
  801d6f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d73:	88 c1                	mov    %al,%cl
  801d75:	d3 ef                	shr    %cl,%edi
  801d77:	09 d7                	or     %edx,%edi
  801d79:	89 f8                	mov    %edi,%eax
  801d7b:	89 ea                	mov    %ebp,%edx
  801d7d:	f7 74 24 08          	divl   0x8(%esp)
  801d81:	89 d1                	mov    %edx,%ecx
  801d83:	89 c7                	mov    %eax,%edi
  801d85:	f7 64 24 0c          	mull   0xc(%esp)
  801d89:	39 d1                	cmp    %edx,%ecx
  801d8b:	72 17                	jb     801da4 <__udivdi3+0x10c>
  801d8d:	74 09                	je     801d98 <__udivdi3+0x100>
  801d8f:	89 fe                	mov    %edi,%esi
  801d91:	31 ff                	xor    %edi,%edi
  801d93:	e9 41 ff ff ff       	jmp    801cd9 <__udivdi3+0x41>
  801d98:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d9c:	89 f1                	mov    %esi,%ecx
  801d9e:	d3 e2                	shl    %cl,%edx
  801da0:	39 c2                	cmp    %eax,%edx
  801da2:	73 eb                	jae    801d8f <__udivdi3+0xf7>
  801da4:	8d 77 ff             	lea    -0x1(%edi),%esi
  801da7:	31 ff                	xor    %edi,%edi
  801da9:	e9 2b ff ff ff       	jmp    801cd9 <__udivdi3+0x41>
  801dae:	66 90                	xchg   %ax,%ax
  801db0:	31 f6                	xor    %esi,%esi
  801db2:	e9 22 ff ff ff       	jmp    801cd9 <__udivdi3+0x41>
	...

00801db8 <__umoddi3>:
  801db8:	55                   	push   %ebp
  801db9:	57                   	push   %edi
  801dba:	56                   	push   %esi
  801dbb:	83 ec 20             	sub    $0x20,%esp
  801dbe:	8b 44 24 30          	mov    0x30(%esp),%eax
  801dc2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801dc6:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dca:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dd2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dd6:	89 c7                	mov    %eax,%edi
  801dd8:	89 f2                	mov    %esi,%edx
  801dda:	85 ed                	test   %ebp,%ebp
  801ddc:	75 16                	jne    801df4 <__umoddi3+0x3c>
  801dde:	39 f1                	cmp    %esi,%ecx
  801de0:	0f 86 a6 00 00 00    	jbe    801e8c <__umoddi3+0xd4>
  801de6:	f7 f1                	div    %ecx
  801de8:	89 d0                	mov    %edx,%eax
  801dea:	31 d2                	xor    %edx,%edx
  801dec:	83 c4 20             	add    $0x20,%esp
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    
  801df3:	90                   	nop
  801df4:	39 f5                	cmp    %esi,%ebp
  801df6:	0f 87 ac 00 00 00    	ja     801ea8 <__umoddi3+0xf0>
  801dfc:	0f bd c5             	bsr    %ebp,%eax
  801dff:	83 f0 1f             	xor    $0x1f,%eax
  801e02:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e06:	0f 84 a8 00 00 00    	je     801eb4 <__umoddi3+0xfc>
  801e0c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e10:	d3 e5                	shl    %cl,%ebp
  801e12:	bf 20 00 00 00       	mov    $0x20,%edi
  801e17:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e1b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e1f:	89 f9                	mov    %edi,%ecx
  801e21:	d3 e8                	shr    %cl,%eax
  801e23:	09 e8                	or     %ebp,%eax
  801e25:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e29:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e2d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e31:	d3 e0                	shl    %cl,%eax
  801e33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e37:	89 f2                	mov    %esi,%edx
  801e39:	d3 e2                	shl    %cl,%edx
  801e3b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e3f:	d3 e0                	shl    %cl,%eax
  801e41:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e45:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e49:	89 f9                	mov    %edi,%ecx
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	09 d0                	or     %edx,%eax
  801e4f:	d3 ee                	shr    %cl,%esi
  801e51:	89 f2                	mov    %esi,%edx
  801e53:	f7 74 24 18          	divl   0x18(%esp)
  801e57:	89 d6                	mov    %edx,%esi
  801e59:	f7 64 24 0c          	mull   0xc(%esp)
  801e5d:	89 c5                	mov    %eax,%ebp
  801e5f:	89 d1                	mov    %edx,%ecx
  801e61:	39 d6                	cmp    %edx,%esi
  801e63:	72 67                	jb     801ecc <__umoddi3+0x114>
  801e65:	74 75                	je     801edc <__umoddi3+0x124>
  801e67:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e6b:	29 e8                	sub    %ebp,%eax
  801e6d:	19 ce                	sbb    %ecx,%esi
  801e6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e73:	d3 e8                	shr    %cl,%eax
  801e75:	89 f2                	mov    %esi,%edx
  801e77:	89 f9                	mov    %edi,%ecx
  801e79:	d3 e2                	shl    %cl,%edx
  801e7b:	09 d0                	or     %edx,%eax
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e83:	d3 ea                	shr    %cl,%edx
  801e85:	83 c4 20             	add    $0x20,%esp
  801e88:	5e                   	pop    %esi
  801e89:	5f                   	pop    %edi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    
  801e8c:	85 c9                	test   %ecx,%ecx
  801e8e:	75 0b                	jne    801e9b <__umoddi3+0xe3>
  801e90:	b8 01 00 00 00       	mov    $0x1,%eax
  801e95:	31 d2                	xor    %edx,%edx
  801e97:	f7 f1                	div    %ecx
  801e99:	89 c1                	mov    %eax,%ecx
  801e9b:	89 f0                	mov    %esi,%eax
  801e9d:	31 d2                	xor    %edx,%edx
  801e9f:	f7 f1                	div    %ecx
  801ea1:	89 f8                	mov    %edi,%eax
  801ea3:	e9 3e ff ff ff       	jmp    801de6 <__umoddi3+0x2e>
  801ea8:	89 f2                	mov    %esi,%edx
  801eaa:	83 c4 20             	add    $0x20,%esp
  801ead:	5e                   	pop    %esi
  801eae:	5f                   	pop    %edi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    
  801eb1:	8d 76 00             	lea    0x0(%esi),%esi
  801eb4:	39 f5                	cmp    %esi,%ebp
  801eb6:	72 04                	jb     801ebc <__umoddi3+0x104>
  801eb8:	39 f9                	cmp    %edi,%ecx
  801eba:	77 06                	ja     801ec2 <__umoddi3+0x10a>
  801ebc:	89 f2                	mov    %esi,%edx
  801ebe:	29 cf                	sub    %ecx,%edi
  801ec0:	19 ea                	sbb    %ebp,%edx
  801ec2:	89 f8                	mov    %edi,%eax
  801ec4:	83 c4 20             	add    $0x20,%esp
  801ec7:	5e                   	pop    %esi
  801ec8:	5f                   	pop    %edi
  801ec9:	5d                   	pop    %ebp
  801eca:	c3                   	ret    
  801ecb:	90                   	nop
  801ecc:	89 d1                	mov    %edx,%ecx
  801ece:	89 c5                	mov    %eax,%ebp
  801ed0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ed4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ed8:	eb 8d                	jmp    801e67 <__umoddi3+0xaf>
  801eda:	66 90                	xchg   %ax,%ax
  801edc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801ee0:	72 ea                	jb     801ecc <__umoddi3+0x114>
  801ee2:	89 f1                	mov    %esi,%ecx
  801ee4:	eb 81                	jmp    801e67 <__umoddi3+0xaf>
