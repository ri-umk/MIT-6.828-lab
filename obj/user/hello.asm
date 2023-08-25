
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  800041:	e8 2a 01 00 00       	call   800170 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 40 80 00       	mov    0x804004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 0e 1f 80 00 	movl   $0x801f0e,(%esp)
  800059:	e8 12 01 00 00       	call   800170 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	83 ec 10             	sub    $0x10,%esp
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  80006e:	e8 5c 0a 00 00       	call   800acf <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007f:	c1 e0 07             	shl    $0x7,%eax
  800082:	29 d0                	sub    %edx,%eax
  800084:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800089:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 f6                	test   %esi,%esi
  800090:	7e 07                	jle    800099 <libmain+0x39>
		binaryname = argv[0];
  800092:	8b 03                	mov    (%ebx),%eax
  800094:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800099:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	e8 8f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0a 00 00 00       	call   8000b4 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	c3                   	ret    
  8000b1:	00 00                	add    %al,(%eax)
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ba:	e8 a0 0e 00 00       	call   800f5f <close_all>
	sys_env_destroy(0);
  8000bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c6:	e8 b2 09 00 00       	call   800a7d <sys_env_destroy>
}
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    
  8000cd:	00 00                	add    %al,(%eax)
	...

008000d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 14             	sub    $0x14,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 03                	mov    (%ebx),%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e3:	40                   	inc    %eax
  8000e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000eb:	75 19                	jne    800106 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f4:	00 
  8000f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 40 09 00 00       	call   800a40 <sys_cputs>
		b->idx = 0;
  800100:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800106:	ff 43 04             	incl   0x4(%ebx)
}
  800109:	83 c4 14             	add    $0x14,%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800133:	8b 45 08             	mov    0x8(%ebp),%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800140:	89 44 24 04          	mov    %eax,0x4(%esp)
  800144:	c7 04 24 d0 00 80 00 	movl   $0x8000d0,(%esp)
  80014b:	e8 82 01 00 00       	call   8002d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800150:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 d8 08 00 00       	call   800a40 <sys_cputs>

	return b.cnt;
}
  800168:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800176:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800179:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017d:	8b 45 08             	mov    0x8(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 87 ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800188:	c9                   	leave  
  800189:	c3                   	ret    
	...

0080018c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 3c             	sub    $0x3c,%esp
  800195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800198:	89 d7                	mov    %edx,%edi
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	75 08                	jne    8001b8 <printnum+0x2c>
  8001b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b6:	77 57                	ja     80020f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001bc:	4b                   	dec    %ebx
  8001bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d7:	00 
  8001d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	e8 ba 1a 00 00       	call   801ca4 <__udivdi3>
  8001ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f9:	89 fa                	mov    %edi,%edx
  8001fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fe:	e8 89 ff ff ff       	call   80018c <printnum>
  800203:	eb 0f                	jmp    800214 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800205:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800209:	89 34 24             	mov    %esi,(%esp)
  80020c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020f:	4b                   	dec    %ebx
  800210:	85 db                	test   %ebx,%ebx
  800212:	7f f1                	jg     800205 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800214:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800218:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021c:	8b 45 10             	mov    0x10(%ebp),%eax
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022a:	00 
  80022b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	e8 87 1b 00 00       	call   801dc4 <__umoddi3>
  80023d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800241:	0f be 80 2f 1f 80 00 	movsbl 0x801f2f(%eax),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80024e:	83 c4 3c             	add    $0x3c,%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800259:	83 fa 01             	cmp    $0x1,%edx
  80025c:	7e 0e                	jle    80026c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 08             	lea    0x8(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	8b 52 04             	mov    0x4(%edx),%edx
  80026a:	eb 22                	jmp    80028e <getuint+0x38>
	else if (lflag)
  80026c:	85 d2                	test   %edx,%edx
  80026e:	74 10                	je     800280 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 04             	lea    0x4(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
  80027e:	eb 0e                	jmp    80028e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800296:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	3b 50 04             	cmp    0x4(%eax),%edx
  80029e:	73 08                	jae    8002a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a3:	88 0a                	mov    %cl,(%edx)
  8002a5:	42                   	inc    %edx
  8002a6:	89 10                	mov    %edx,(%eax)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	e8 02 00 00 00       	call   8002d2 <vprintfmt>
	va_end(ap);
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 4c             	sub    $0x4c,%esp
  8002db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002de:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e1:	eb 12                	jmp    8002f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	0f 84 6b 03 00 00    	je     800656 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f5:	0f b6 06             	movzbl (%esi),%eax
  8002f8:	46                   	inc    %esi
  8002f9:	83 f8 25             	cmp    $0x25,%eax
  8002fc:	75 e5                	jne    8002e3 <vprintfmt+0x11>
  8002fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800302:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800309:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031a:	eb 26                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800323:	eb 1d                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80032c:	eb 14                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800331:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800338:	eb 08                	jmp    800342 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80033d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	0f b6 06             	movzbl (%esi),%eax
  800345:	8d 56 01             	lea    0x1(%esi),%edx
  800348:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80034b:	8a 16                	mov    (%esi),%dl
  80034d:	83 ea 23             	sub    $0x23,%edx
  800350:	80 fa 55             	cmp    $0x55,%dl
  800353:	0f 87 e1 02 00 00    	ja     80063a <vprintfmt+0x368>
  800359:	0f b6 d2             	movzbl %dl,%edx
  80035c:	ff 24 95 80 20 80 00 	jmp    *0x802080(,%edx,4)
  800363:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800366:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80036e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800372:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800375:	8d 50 d0             	lea    -0x30(%eax),%edx
  800378:	83 fa 09             	cmp    $0x9,%edx
  80037b:	77 2a                	ja     8003a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037e:	eb eb                	jmp    80036b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 50 04             	lea    0x4(%eax),%edx
  800386:	89 55 14             	mov    %edx,0x14(%ebp)
  800389:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038e:	eb 17                	jmp    8003a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800390:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800394:	78 98                	js     80032e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800399:	eb a7                	jmp    800342 <vprintfmt+0x70>
  80039b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a5:	eb 9b                	jmp    800342 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ab:	79 95                	jns    800342 <vprintfmt+0x70>
  8003ad:	eb 8b                	jmp    80033a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b3:	eb 8d                	jmp    800342 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 50 04             	lea    0x4(%eax),%edx
  8003bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003cd:	e9 23 ff ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	79 02                	jns    8003e3 <vprintfmt+0x111>
  8003e1:	f7 d8                	neg    %eax
  8003e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e5:	83 f8 0f             	cmp    $0xf,%eax
  8003e8:	7f 0b                	jg     8003f5 <vprintfmt+0x123>
  8003ea:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	75 23                	jne    800418 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f9:	c7 44 24 08 47 1f 80 	movl   $0x801f47,0x8(%esp)
  800400:	00 
  800401:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 9a fe ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 dd fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800418:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041c:	c7 44 24 08 3a 23 80 	movl   $0x80233a,0x8(%esp)
  800423:	00 
  800424:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800428:	8b 55 08             	mov    0x8(%ebp),%edx
  80042b:	89 14 24             	mov    %edx,(%esp)
  80042e:	e8 77 fe ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800436:	e9 ba fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
  80043b:	89 f9                	mov    %edi,%ecx
  80043d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800440:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 30                	mov    (%eax),%esi
  80044e:	85 f6                	test   %esi,%esi
  800450:	75 05                	jne    800457 <vprintfmt+0x185>
				p = "(null)";
  800452:	be 40 1f 80 00       	mov    $0x801f40,%esi
			if (width > 0 && padc != '-')
  800457:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045b:	0f 8e 84 00 00 00    	jle    8004e5 <vprintfmt+0x213>
  800461:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800465:	74 7e                	je     8004e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046b:	89 34 24             	mov    %esi,(%esp)
  80046e:	e8 8b 02 00 00       	call   8006fe <strnlen>
  800473:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800476:	29 c2                	sub    %eax,%edx
  800478:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80047b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80047f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800482:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800485:	89 de                	mov    %ebx,%esi
  800487:	89 d3                	mov    %edx,%ebx
  800489:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	eb 0b                	jmp    800498 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80048d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800491:	89 3c 24             	mov    %edi,(%esp)
  800494:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	4b                   	dec    %ebx
  800498:	85 db                	test   %ebx,%ebx
  80049a:	7f f1                	jg     80048d <vprintfmt+0x1bb>
  80049c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80049f:	89 f3                	mov    %esi,%ebx
  8004a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	79 05                	jns    8004b0 <vprintfmt+0x1de>
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b3:	29 c2                	sub    %eax,%edx
  8004b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b8:	eb 2b                	jmp    8004e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004be:	74 18                	je     8004d8 <vprintfmt+0x206>
  8004c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c3:	83 fa 5e             	cmp    $0x5e,%edx
  8004c6:	76 10                	jbe    8004d8 <vprintfmt+0x206>
					putch('?', putdat);
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
  8004d6:	eb 0a                	jmp    8004e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e5:	0f be 06             	movsbl (%esi),%eax
  8004e8:	46                   	inc    %esi
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	74 21                	je     80050e <vprintfmt+0x23c>
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	78 c9                	js     8004ba <vprintfmt+0x1e8>
  8004f1:	4f                   	dec    %edi
  8004f2:	79 c6                	jns    8004ba <vprintfmt+0x1e8>
  8004f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f7:	89 de                	mov    %ebx,%esi
  8004f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004fc:	eb 18                	jmp    800516 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800502:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800509:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050b:	4b                   	dec    %ebx
  80050c:	eb 08                	jmp    800516 <vprintfmt+0x244>
  80050e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800511:	89 de                	mov    %ebx,%esi
  800513:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800516:	85 db                	test   %ebx,%ebx
  800518:	7f e4                	jg     8004fe <vprintfmt+0x22c>
  80051a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80051d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800522:	e9 ce fd ff ff       	jmp    8002f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7e 10                	jle    80053c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 08             	lea    0x8(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 30                	mov    (%eax),%esi
  800537:	8b 78 04             	mov    0x4(%eax),%edi
  80053a:	eb 26                	jmp    800562 <vprintfmt+0x290>
	else if (lflag)
  80053c:	85 c9                	test   %ecx,%ecx
  80053e:	74 12                	je     800552 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 30                	mov    (%eax),%esi
  80054b:	89 f7                	mov    %esi,%edi
  80054d:	c1 ff 1f             	sar    $0x1f,%edi
  800550:	eb 10                	jmp    800562 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 30                	mov    (%eax),%esi
  80055d:	89 f7                	mov    %esi,%edi
  80055f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800562:	85 ff                	test   %edi,%edi
  800564:	78 0a                	js     800570 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056b:	e9 8c 00 00 00       	jmp    8005fc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057e:	f7 de                	neg    %esi
  800580:	83 d7 00             	adc    $0x0,%edi
  800583:	f7 df                	neg    %edi
			}
			base = 10;
  800585:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058a:	eb 70                	jmp    8005fc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058c:	89 ca                	mov    %ecx,%edx
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 c0 fc ff ff       	call   800256 <getuint>
  800596:	89 c6                	mov    %eax,%esi
  800598:	89 d7                	mov    %edx,%edi
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80059f:	eb 5b                	jmp    8005fc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005a1:	89 ca                	mov    %ecx,%edx
  8005a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a6:	e8 ab fc ff ff       	call   800256 <getuint>
  8005ab:	89 c6                	mov    %eax,%esi
  8005ad:	89 d7                	mov    %edx,%edi
			base = 8;
  8005af:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005b4:	eb 46                	jmp    8005fc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005db:	8b 30                	mov    (%eax),%esi
  8005dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005e7:	eb 13                	jmp    8005fc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 63 fc ff ff       	call   800256 <getuint>
  8005f3:	89 c6                	mov    %eax,%esi
  8005f5:	89 d7                	mov    %edx,%edi
			base = 16;
  8005f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800600:	89 54 24 10          	mov    %edx,0x10(%esp)
  800604:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800607:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060f:	89 34 24             	mov    %esi,(%esp)
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	89 da                	mov    %ebx,%edx
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	e8 6c fb ff ff       	call   80018c <printnum>
			break;
  800620:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800623:	e9 cd fc ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	89 04 24             	mov    %eax,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800635:	e9 bb fc ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800648:	eb 01                	jmp    80064b <vprintfmt+0x379>
  80064a:	4e                   	dec    %esi
  80064b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80064f:	75 f9                	jne    80064a <vprintfmt+0x378>
  800651:	e9 9f fc ff ff       	jmp    8002f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800656:	83 c4 4c             	add    $0x4c,%esp
  800659:	5b                   	pop    %ebx
  80065a:	5e                   	pop    %esi
  80065b:	5f                   	pop    %edi
  80065c:	5d                   	pop    %ebp
  80065d:	c3                   	ret    

0080065e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065e:	55                   	push   %ebp
  80065f:	89 e5                	mov    %esp,%ebp
  800661:	83 ec 28             	sub    $0x28,%esp
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80066d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800671:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800674:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067b:	85 c0                	test   %eax,%eax
  80067d:	74 30                	je     8006af <vsnprintf+0x51>
  80067f:	85 d2                	test   %edx,%edx
  800681:	7e 33                	jle    8006b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068a:	8b 45 10             	mov    0x10(%ebp),%eax
  80068d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800691:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800694:	89 44 24 04          	mov    %eax,0x4(%esp)
  800698:	c7 04 24 90 02 80 00 	movl   $0x800290,(%esp)
  80069f:	e8 2e fc ff ff       	call   8002d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ad:	eb 0c                	jmp    8006bb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb 05                	jmp    8006bb <vsnprintf+0x5d>
  8006b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	e8 7b ff ff ff       	call   80065e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    
  8006e5:	00 00                	add    %al,(%eax)
	...

008006e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f3:	eb 01                	jmp    8006f6 <strlen+0xe>
		n++;
  8006f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fa:	75 f9                	jne    8006f5 <strlen+0xd>
		n++;
	return n;
}
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
  80070c:	eb 01                	jmp    80070f <strnlen+0x11>
		n++;
  80070e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070f:	39 d0                	cmp    %edx,%eax
  800711:	74 06                	je     800719 <strnlen+0x1b>
  800713:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800717:	75 f5                	jne    80070e <strnlen+0x10>
		n++;
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
  80072a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80072d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800730:	42                   	inc    %edx
  800731:	84 c9                	test   %cl,%cl
  800733:	75 f5                	jne    80072a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800735:	5b                   	pop    %ebx
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800742:	89 1c 24             	mov    %ebx,(%esp)
  800745:	e8 9e ff ff ff       	call   8006e8 <strlen>
	strcpy(dst + len, src);
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800751:	01 d8                	add    %ebx,%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 c0 ff ff ff       	call   80071b <strcpy>
	return dst;
}
  80075b:	89 d8                	mov    %ebx,%eax
  80075d:	83 c4 08             	add    $0x8,%esp
  800760:	5b                   	pop    %ebx
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
  800776:	eb 0c                	jmp    800784 <strncpy+0x21>
		*dst++ = *src;
  800778:	8a 1a                	mov    (%edx),%bl
  80077a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077d:	80 3a 01             	cmpb   $0x1,(%edx)
  800780:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800783:	41                   	inc    %ecx
  800784:	39 f1                	cmp    %esi,%ecx
  800786:	75 f0                	jne    800778 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800797:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079a:	85 d2                	test   %edx,%edx
  80079c:	75 0a                	jne    8007a8 <strlcpy+0x1c>
  80079e:	89 f0                	mov    %esi,%eax
  8007a0:	eb 1a                	jmp    8007bc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a2:	88 18                	mov    %bl,(%eax)
  8007a4:	40                   	inc    %eax
  8007a5:	41                   	inc    %ecx
  8007a6:	eb 02                	jmp    8007aa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007aa:	4a                   	dec    %edx
  8007ab:	74 0a                	je     8007b7 <strlcpy+0x2b>
  8007ad:	8a 19                	mov    (%ecx),%bl
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 ef                	jne    8007a2 <strlcpy+0x16>
  8007b3:	89 c2                	mov    %eax,%edx
  8007b5:	eb 02                	jmp    8007b9 <strlcpy+0x2d>
  8007b7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007b9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007bc:	29 f0                	sub    %esi,%eax
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cb:	eb 02                	jmp    8007cf <strcmp+0xd>
		p++, q++;
  8007cd:	41                   	inc    %ecx
  8007ce:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cf:	8a 01                	mov    (%ecx),%al
  8007d1:	84 c0                	test   %al,%al
  8007d3:	74 04                	je     8007d9 <strcmp+0x17>
  8007d5:	3a 02                	cmp    (%edx),%al
  8007d7:	74 f4                	je     8007cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d9:	0f b6 c0             	movzbl %al,%eax
  8007dc:	0f b6 12             	movzbl (%edx),%edx
  8007df:	29 d0                	sub    %edx,%eax
}
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007f0:	eb 03                	jmp    8007f5 <strncmp+0x12>
		n--, p++, q++;
  8007f2:	4a                   	dec    %edx
  8007f3:	40                   	inc    %eax
  8007f4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 14                	je     80080d <strncmp+0x2a>
  8007f9:	8a 18                	mov    (%eax),%bl
  8007fb:	84 db                	test   %bl,%bl
  8007fd:	74 04                	je     800803 <strncmp+0x20>
  8007ff:	3a 19                	cmp    (%ecx),%bl
  800801:	74 ef                	je     8007f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800803:	0f b6 00             	movzbl (%eax),%eax
  800806:	0f b6 11             	movzbl (%ecx),%edx
  800809:	29 d0                	sub    %edx,%eax
  80080b:	eb 05                	jmp    800812 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80081e:	eb 05                	jmp    800825 <strchr+0x10>
		if (*s == c)
  800820:	38 ca                	cmp    %cl,%dl
  800822:	74 0c                	je     800830 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800824:	40                   	inc    %eax
  800825:	8a 10                	mov    (%eax),%dl
  800827:	84 d2                	test   %dl,%dl
  800829:	75 f5                	jne    800820 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083b:	eb 05                	jmp    800842 <strfind+0x10>
		if (*s == c)
  80083d:	38 ca                	cmp    %cl,%dl
  80083f:	74 07                	je     800848 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800841:	40                   	inc    %eax
  800842:	8a 10                	mov    (%eax),%dl
  800844:	84 d2                	test   %dl,%dl
  800846:	75 f5                	jne    80083d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	57                   	push   %edi
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 7d 08             	mov    0x8(%ebp),%edi
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
  800856:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800859:	85 c9                	test   %ecx,%ecx
  80085b:	74 30                	je     80088d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800863:	75 25                	jne    80088a <memset+0x40>
  800865:	f6 c1 03             	test   $0x3,%cl
  800868:	75 20                	jne    80088a <memset+0x40>
		c &= 0xFF;
  80086a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086d:	89 d3                	mov    %edx,%ebx
  80086f:	c1 e3 08             	shl    $0x8,%ebx
  800872:	89 d6                	mov    %edx,%esi
  800874:	c1 e6 18             	shl    $0x18,%esi
  800877:	89 d0                	mov    %edx,%eax
  800879:	c1 e0 10             	shl    $0x10,%eax
  80087c:	09 f0                	or     %esi,%eax
  80087e:	09 d0                	or     %edx,%eax
  800880:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800882:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800885:	fc                   	cld    
  800886:	f3 ab                	rep stos %eax,%es:(%edi)
  800888:	eb 03                	jmp    80088d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088a:	fc                   	cld    
  80088b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80088d:	89 f8                	mov    %edi,%eax
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5f                   	pop    %edi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	57                   	push   %edi
  800898:	56                   	push   %esi
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a2:	39 c6                	cmp    %eax,%esi
  8008a4:	73 34                	jae    8008da <memmove+0x46>
  8008a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a9:	39 d0                	cmp    %edx,%eax
  8008ab:	73 2d                	jae    8008da <memmove+0x46>
		s += n;
		d += n;
  8008ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b0:	f6 c2 03             	test   $0x3,%dl
  8008b3:	75 1b                	jne    8008d0 <memmove+0x3c>
  8008b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bb:	75 13                	jne    8008d0 <memmove+0x3c>
  8008bd:	f6 c1 03             	test   $0x3,%cl
  8008c0:	75 0e                	jne    8008d0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008c2:	83 ef 04             	sub    $0x4,%edi
  8008c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008cb:	fd                   	std    
  8008cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ce:	eb 07                	jmp    8008d7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008d0:	4f                   	dec    %edi
  8008d1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d4:	fd                   	std    
  8008d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d7:	fc                   	cld    
  8008d8:	eb 20                	jmp    8008fa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e0:	75 13                	jne    8008f5 <memmove+0x61>
  8008e2:	a8 03                	test   $0x3,%al
  8008e4:	75 0f                	jne    8008f5 <memmove+0x61>
  8008e6:	f6 c1 03             	test   $0x3,%cl
  8008e9:	75 0a                	jne    8008f5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008eb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ee:	89 c7                	mov    %eax,%edi
  8008f0:	fc                   	cld    
  8008f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f3:	eb 05                	jmp    8008fa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f5:	89 c7                	mov    %eax,%edi
  8008f7:	fc                   	cld    
  8008f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800904:	8b 45 10             	mov    0x10(%ebp),%eax
  800907:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	e8 77 ff ff ff       	call   800894 <memmove>
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	57                   	push   %edi
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 7d 08             	mov    0x8(%ebp),%edi
  800928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092e:	ba 00 00 00 00       	mov    $0x0,%edx
  800933:	eb 16                	jmp    80094b <memcmp+0x2c>
		if (*s1 != *s2)
  800935:	8a 04 17             	mov    (%edi,%edx,1),%al
  800938:	42                   	inc    %edx
  800939:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80093d:	38 c8                	cmp    %cl,%al
  80093f:	74 0a                	je     80094b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800941:	0f b6 c0             	movzbl %al,%eax
  800944:	0f b6 c9             	movzbl %cl,%ecx
  800947:	29 c8                	sub    %ecx,%eax
  800949:	eb 09                	jmp    800954 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	39 da                	cmp    %ebx,%edx
  80094d:	75 e6                	jne    800935 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800962:	89 c2                	mov    %eax,%edx
  800964:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800967:	eb 05                	jmp    80096e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800969:	38 08                	cmp    %cl,(%eax)
  80096b:	74 05                	je     800972 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096d:	40                   	inc    %eax
  80096e:	39 d0                	cmp    %edx,%eax
  800970:	72 f7                	jb     800969 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 55 08             	mov    0x8(%ebp),%edx
  80097d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800980:	eb 01                	jmp    800983 <strtol+0xf>
		s++;
  800982:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800983:	8a 02                	mov    (%edx),%al
  800985:	3c 20                	cmp    $0x20,%al
  800987:	74 f9                	je     800982 <strtol+0xe>
  800989:	3c 09                	cmp    $0x9,%al
  80098b:	74 f5                	je     800982 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098d:	3c 2b                	cmp    $0x2b,%al
  80098f:	75 08                	jne    800999 <strtol+0x25>
		s++;
  800991:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800992:	bf 00 00 00 00       	mov    $0x0,%edi
  800997:	eb 13                	jmp    8009ac <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800999:	3c 2d                	cmp    $0x2d,%al
  80099b:	75 0a                	jne    8009a7 <strtol+0x33>
		s++, neg = 1;
  80099d:	8d 52 01             	lea    0x1(%edx),%edx
  8009a0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a5:	eb 05                	jmp    8009ac <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ac:	85 db                	test   %ebx,%ebx
  8009ae:	74 05                	je     8009b5 <strtol+0x41>
  8009b0:	83 fb 10             	cmp    $0x10,%ebx
  8009b3:	75 28                	jne    8009dd <strtol+0x69>
  8009b5:	8a 02                	mov    (%edx),%al
  8009b7:	3c 30                	cmp    $0x30,%al
  8009b9:	75 10                	jne    8009cb <strtol+0x57>
  8009bb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009bf:	75 0a                	jne    8009cb <strtol+0x57>
		s += 2, base = 16;
  8009c1:	83 c2 02             	add    $0x2,%edx
  8009c4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c9:	eb 12                	jmp    8009dd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009cb:	85 db                	test   %ebx,%ebx
  8009cd:	75 0e                	jne    8009dd <strtol+0x69>
  8009cf:	3c 30                	cmp    $0x30,%al
  8009d1:	75 05                	jne    8009d8 <strtol+0x64>
		s++, base = 8;
  8009d3:	42                   	inc    %edx
  8009d4:	b3 08                	mov    $0x8,%bl
  8009d6:	eb 05                	jmp    8009dd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009d8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e4:	8a 0a                	mov    (%edx),%cl
  8009e6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009e9:	80 fb 09             	cmp    $0x9,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x82>
			dig = *s - '0';
  8009ee:	0f be c9             	movsbl %cl,%ecx
  8009f1:	83 e9 30             	sub    $0x30,%ecx
  8009f4:	eb 1e                	jmp    800a14 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009f6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009f9:	80 fb 19             	cmp    $0x19,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009fe:	0f be c9             	movsbl %cl,%ecx
  800a01:	83 e9 57             	sub    $0x57,%ecx
  800a04:	eb 0e                	jmp    800a14 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a06:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a09:	80 fb 19             	cmp    $0x19,%bl
  800a0c:	77 12                	ja     800a20 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a0e:	0f be c9             	movsbl %cl,%ecx
  800a11:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a14:	39 f1                	cmp    %esi,%ecx
  800a16:	7d 0c                	jge    800a24 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a18:	42                   	inc    %edx
  800a19:	0f af c6             	imul   %esi,%eax
  800a1c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a1e:	eb c4                	jmp    8009e4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a20:	89 c1                	mov    %eax,%ecx
  800a22:	eb 02                	jmp    800a26 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a24:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2a:	74 05                	je     800a31 <strtol+0xbd>
		*endptr = (char *) s;
  800a2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a31:	85 ff                	test   %edi,%edi
  800a33:	74 04                	je     800a39 <strtol+0xc5>
  800a35:	89 c8                	mov    %ecx,%eax
  800a37:	f7 d8                	neg    %eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    
	...

00800a40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a51:	89 c3                	mov    %eax,%ebx
  800a53:	89 c7                	mov    %eax,%edi
  800a55:	89 c6                	mov    %eax,%esi
  800a57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
  800a69:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6e:	89 d1                	mov    %edx,%ecx
  800a70:	89 d3                	mov    %edx,%ebx
  800a72:	89 d7                	mov    %edx,%edi
  800a74:	89 d6                	mov    %edx,%esi
  800a76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
  800a93:	89 cb                	mov    %ecx,%ebx
  800a95:	89 cf                	mov    %ecx,%edi
  800a97:	89 ce                	mov    %ecx,%esi
  800a99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9b:	85 c0                	test   %eax,%eax
  800a9d:	7e 28                	jle    800ac7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aa3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aaa:	00 
  800aab:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800ab2:	00 
  800ab3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aba:	00 
  800abb:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800ac2:	e8 29 10 00 00       	call   801af0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac7:	83 c4 2c             	add    $0x2c,%esp
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 02 00 00 00       	mov    $0x2,%eax
  800adf:	89 d1                	mov    %edx,%ecx
  800ae1:	89 d3                	mov    %edx,%ebx
  800ae3:	89 d7                	mov    %edx,%edi
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_yield>:

void
sys_yield(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	be 00 00 00 00       	mov    $0x0,%esi
  800b1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	89 f7                	mov    %esi,%edi
  800b2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	7e 28                	jle    800b59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b3c:	00 
  800b3d:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800b44:	00 
  800b45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4c:	00 
  800b4d:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800b54:	e8 97 0f 00 00       	call   801af0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b59:	83 c4 2c             	add    $0x2c,%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b80:	85 c0                	test   %eax,%eax
  800b82:	7e 28                	jle    800bac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b8f:	00 
  800b90:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800b97:	00 
  800b98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9f:	00 
  800ba0:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800ba7:	e8 44 0f 00 00       	call   801af0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bac:	83 c4 2c             	add    $0x2c,%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	89 df                	mov    %ebx,%edi
  800bcf:	89 de                	mov    %ebx,%esi
  800bd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 28                	jle    800bff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800be2:	00 
  800be3:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800bea:	00 
  800beb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf2:	00 
  800bf3:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800bfa:	e8 f1 0e 00 00       	call   801af0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bff:	83 c4 2c             	add    $0x2c,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c15:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 df                	mov    %ebx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 28                	jle    800c52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c35:	00 
  800c36:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800c3d:	00 
  800c3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c45:	00 
  800c46:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800c4d:	e8 9e 0e 00 00       	call   801af0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c52:	83 c4 2c             	add    $0x2c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 df                	mov    %ebx,%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 28                	jle    800ca5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c88:	00 
  800c89:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800c90:	00 
  800c91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c98:	00 
  800c99:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800ca0:	e8 4b 0e 00 00       	call   801af0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca5:	83 c4 2c             	add    $0x2c,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 28                	jle    800cf8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cdb:	00 
  800cdc:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ceb:	00 
  800cec:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800cf3:	e8 f8 0d 00 00       	call   801af0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf8:	83 c4 2c             	add    $0x2c,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	be 00 00 00 00       	mov    $0x0,%esi
  800d0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 cb                	mov    %ecx,%ebx
  800d3b:	89 cf                	mov    %ecx,%edi
  800d3d:	89 ce                	mov    %ecx,%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 28                	jle    800d6d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d49:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d50:	00 
  800d51:	c7 44 24 08 3f 22 80 	movl   $0x80223f,0x8(%esp)
  800d58:	00 
  800d59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d60:	00 
  800d61:	c7 04 24 5c 22 80 00 	movl   $0x80225c,(%esp)
  800d68:	e8 83 0d 00 00       	call   801af0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6d:	83 c4 2c             	add    $0x2c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	00 00                	add    %al,(%eax)
	...

00800d78 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d83:	c1 e8 0c             	shr    $0xc,%eax
}
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	89 04 24             	mov    %eax,(%esp)
  800d94:	e8 df ff ff ff       	call   800d78 <fd2num>
  800d99:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d9e:	c1 e0 0c             	shl    $0xc,%eax
}
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    

00800da3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	53                   	push   %ebx
  800da7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800daa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800daf:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	c1 ea 16             	shr    $0x16,%edx
  800db6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dbd:	f6 c2 01             	test   $0x1,%dl
  800dc0:	74 11                	je     800dd3 <fd_alloc+0x30>
  800dc2:	89 c2                	mov    %eax,%edx
  800dc4:	c1 ea 0c             	shr    $0xc,%edx
  800dc7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dce:	f6 c2 01             	test   $0x1,%dl
  800dd1:	75 09                	jne    800ddc <fd_alloc+0x39>
			*fd_store = fd;
  800dd3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dda:	eb 17                	jmp    800df3 <fd_alloc+0x50>
  800ddc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800de6:	75 c7                	jne    800daf <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800de8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800dee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800df3:	5b                   	pop    %ebx
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dfc:	83 f8 1f             	cmp    $0x1f,%eax
  800dff:	77 36                	ja     800e37 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e01:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e06:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e09:	89 c2                	mov    %eax,%edx
  800e0b:	c1 ea 16             	shr    $0x16,%edx
  800e0e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e15:	f6 c2 01             	test   $0x1,%dl
  800e18:	74 24                	je     800e3e <fd_lookup+0x48>
  800e1a:	89 c2                	mov    %eax,%edx
  800e1c:	c1 ea 0c             	shr    $0xc,%edx
  800e1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e26:	f6 c2 01             	test   $0x1,%dl
  800e29:	74 1a                	je     800e45 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
  800e35:	eb 13                	jmp    800e4a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3c:	eb 0c                	jmp    800e4a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e43:	eb 05                	jmp    800e4a <fd_lookup+0x54>
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 14             	sub    $0x14,%esp
  800e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e59:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5e:	eb 0e                	jmp    800e6e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800e60:	39 08                	cmp    %ecx,(%eax)
  800e62:	75 09                	jne    800e6d <dev_lookup+0x21>
			*dev = devtab[i];
  800e64:	89 03                	mov    %eax,(%ebx)
			return 0;
  800e66:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6b:	eb 33                	jmp    800ea0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e6d:	42                   	inc    %edx
  800e6e:	8b 04 95 e8 22 80 00 	mov    0x8022e8(,%edx,4),%eax
  800e75:	85 c0                	test   %eax,%eax
  800e77:	75 e7                	jne    800e60 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e79:	a1 04 40 80 00       	mov    0x804004,%eax
  800e7e:	8b 40 48             	mov    0x48(%eax),%eax
  800e81:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e89:	c7 04 24 6c 22 80 00 	movl   $0x80226c,(%esp)
  800e90:	e8 db f2 ff ff       	call   800170 <cprintf>
	*dev = 0;
  800e95:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea0:	83 c4 14             	add    $0x14,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 30             	sub    $0x30,%esp
  800eae:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb1:	8a 45 0c             	mov    0xc(%ebp),%al
  800eb4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb7:	89 34 24             	mov    %esi,(%esp)
  800eba:	e8 b9 fe ff ff       	call   800d78 <fd2num>
  800ebf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ec2:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ec6:	89 04 24             	mov    %eax,(%esp)
  800ec9:	e8 28 ff ff ff       	call   800df6 <fd_lookup>
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	78 05                	js     800ed9 <fd_close+0x33>
	    || fd != fd2)
  800ed4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ed7:	74 0d                	je     800ee6 <fd_close+0x40>
		return (must_exist ? r : 0);
  800ed9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800edd:	75 46                	jne    800f25 <fd_close+0x7f>
  800edf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee4:	eb 3f                	jmp    800f25 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eed:	8b 06                	mov    (%esi),%eax
  800eef:	89 04 24             	mov    %eax,(%esp)
  800ef2:	e8 55 ff ff ff       	call   800e4c <dev_lookup>
  800ef7:	89 c3                	mov    %eax,%ebx
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	78 18                	js     800f15 <fd_close+0x6f>
		if (dev->dev_close)
  800efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f00:	8b 40 10             	mov    0x10(%eax),%eax
  800f03:	85 c0                	test   %eax,%eax
  800f05:	74 09                	je     800f10 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f07:	89 34 24             	mov    %esi,(%esp)
  800f0a:	ff d0                	call   *%eax
  800f0c:	89 c3                	mov    %eax,%ebx
  800f0e:	eb 05                	jmp    800f15 <fd_close+0x6f>
		else
			r = 0;
  800f10:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f15:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f20:	e8 8f fc ff ff       	call   800bb4 <sys_page_unmap>
	return r;
}
  800f25:	89 d8                	mov    %ebx,%eax
  800f27:	83 c4 30             	add    $0x30,%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	89 04 24             	mov    %eax,(%esp)
  800f41:	e8 b0 fe ff ff       	call   800df6 <fd_lookup>
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 13                	js     800f5d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f51:	00 
  800f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f55:	89 04 24             	mov    %eax,(%esp)
  800f58:	e8 49 ff ff ff       	call   800ea6 <fd_close>
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <close_all>:

void
close_all(void)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	53                   	push   %ebx
  800f63:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f66:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f6b:	89 1c 24             	mov    %ebx,(%esp)
  800f6e:	e8 bb ff ff ff       	call   800f2e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f73:	43                   	inc    %ebx
  800f74:	83 fb 20             	cmp    $0x20,%ebx
  800f77:	75 f2                	jne    800f6b <close_all+0xc>
		close(i);
}
  800f79:	83 c4 14             	add    $0x14,%esp
  800f7c:	5b                   	pop    %ebx
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
  800f85:	83 ec 4c             	sub    $0x4c,%esp
  800f88:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f92:	8b 45 08             	mov    0x8(%ebp),%eax
  800f95:	89 04 24             	mov    %eax,(%esp)
  800f98:	e8 59 fe ff ff       	call   800df6 <fd_lookup>
  800f9d:	89 c3                	mov    %eax,%ebx
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	0f 88 e1 00 00 00    	js     801088 <dup+0x109>
		return r;
	close(newfdnum);
  800fa7:	89 3c 24             	mov    %edi,(%esp)
  800faa:	e8 7f ff ff ff       	call   800f2e <close>

	newfd = INDEX2FD(newfdnum);
  800faf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fb5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fbb:	89 04 24             	mov    %eax,(%esp)
  800fbe:	e8 c5 fd ff ff       	call   800d88 <fd2data>
  800fc3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fc5:	89 34 24             	mov    %esi,(%esp)
  800fc8:	e8 bb fd ff ff       	call   800d88 <fd2data>
  800fcd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	c1 e8 16             	shr    $0x16,%eax
  800fd5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdc:	a8 01                	test   $0x1,%al
  800fde:	74 46                	je     801026 <dup+0xa7>
  800fe0:	89 d8                	mov    %ebx,%eax
  800fe2:	c1 e8 0c             	shr    $0xc,%eax
  800fe5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fec:	f6 c2 01             	test   $0x1,%dl
  800fef:	74 35                	je     801026 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ff1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801001:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801004:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801008:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80100f:	00 
  801010:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801014:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101b:	e8 41 fb ff ff       	call   800b61 <sys_page_map>
  801020:	89 c3                	mov    %eax,%ebx
  801022:	85 c0                	test   %eax,%eax
  801024:	78 3b                	js     801061 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801029:	89 c2                	mov    %eax,%edx
  80102b:	c1 ea 0c             	shr    $0xc,%edx
  80102e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801035:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80103b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80103f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801043:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80104a:	00 
  80104b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801056:	e8 06 fb ff ff       	call   800b61 <sys_page_map>
  80105b:	89 c3                	mov    %eax,%ebx
  80105d:	85 c0                	test   %eax,%eax
  80105f:	79 25                	jns    801086 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801061:	89 74 24 04          	mov    %esi,0x4(%esp)
  801065:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80106c:	e8 43 fb ff ff       	call   800bb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801071:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801074:	89 44 24 04          	mov    %eax,0x4(%esp)
  801078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107f:	e8 30 fb ff ff       	call   800bb4 <sys_page_unmap>
	return r;
  801084:	eb 02                	jmp    801088 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801086:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801088:	89 d8                	mov    %ebx,%eax
  80108a:	83 c4 4c             	add    $0x4c,%esp
  80108d:	5b                   	pop    %ebx
  80108e:	5e                   	pop    %esi
  80108f:	5f                   	pop    %edi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	53                   	push   %ebx
  801096:	83 ec 24             	sub    $0x24,%esp
  801099:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80109c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80109f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a3:	89 1c 24             	mov    %ebx,(%esp)
  8010a6:	e8 4b fd ff ff       	call   800df6 <fd_lookup>
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 6d                	js     80111c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b9:	8b 00                	mov    (%eax),%eax
  8010bb:	89 04 24             	mov    %eax,(%esp)
  8010be:	e8 89 fd ff ff       	call   800e4c <dev_lookup>
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 55                	js     80111c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ca:	8b 50 08             	mov    0x8(%eax),%edx
  8010cd:	83 e2 03             	and    $0x3,%edx
  8010d0:	83 fa 01             	cmp    $0x1,%edx
  8010d3:	75 23                	jne    8010f8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010da:	8b 40 48             	mov    0x48(%eax),%eax
  8010dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e5:	c7 04 24 ad 22 80 00 	movl   $0x8022ad,(%esp)
  8010ec:	e8 7f f0 ff ff       	call   800170 <cprintf>
		return -E_INVAL;
  8010f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f6:	eb 24                	jmp    80111c <read+0x8a>
	}
	if (!dev->dev_read)
  8010f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010fb:	8b 52 08             	mov    0x8(%edx),%edx
  8010fe:	85 d2                	test   %edx,%edx
  801100:	74 15                	je     801117 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801102:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801105:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801109:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801110:	89 04 24             	mov    %eax,(%esp)
  801113:	ff d2                	call   *%edx
  801115:	eb 05                	jmp    80111c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801117:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80111c:	83 c4 24             	add    $0x24,%esp
  80111f:	5b                   	pop    %ebx
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	57                   	push   %edi
  801126:	56                   	push   %esi
  801127:	53                   	push   %ebx
  801128:	83 ec 1c             	sub    $0x1c,%esp
  80112b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801131:	bb 00 00 00 00       	mov    $0x0,%ebx
  801136:	eb 23                	jmp    80115b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801138:	89 f0                	mov    %esi,%eax
  80113a:	29 d8                	sub    %ebx,%eax
  80113c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801140:	8b 45 0c             	mov    0xc(%ebp),%eax
  801143:	01 d8                	add    %ebx,%eax
  801145:	89 44 24 04          	mov    %eax,0x4(%esp)
  801149:	89 3c 24             	mov    %edi,(%esp)
  80114c:	e8 41 ff ff ff       	call   801092 <read>
		if (m < 0)
  801151:	85 c0                	test   %eax,%eax
  801153:	78 10                	js     801165 <readn+0x43>
			return m;
		if (m == 0)
  801155:	85 c0                	test   %eax,%eax
  801157:	74 0a                	je     801163 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801159:	01 c3                	add    %eax,%ebx
  80115b:	39 f3                	cmp    %esi,%ebx
  80115d:	72 d9                	jb     801138 <readn+0x16>
  80115f:	89 d8                	mov    %ebx,%eax
  801161:	eb 02                	jmp    801165 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801163:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801165:	83 c4 1c             	add    $0x1c,%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	53                   	push   %ebx
  801171:	83 ec 24             	sub    $0x24,%esp
  801174:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801177:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117e:	89 1c 24             	mov    %ebx,(%esp)
  801181:	e8 70 fc ff ff       	call   800df6 <fd_lookup>
  801186:	85 c0                	test   %eax,%eax
  801188:	78 68                	js     8011f2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801194:	8b 00                	mov    (%eax),%eax
  801196:	89 04 24             	mov    %eax,(%esp)
  801199:	e8 ae fc ff ff       	call   800e4c <dev_lookup>
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 50                	js     8011f2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a9:	75 23                	jne    8011ce <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b0:	8b 40 48             	mov    0x48(%eax),%eax
  8011b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011bb:	c7 04 24 c9 22 80 00 	movl   $0x8022c9,(%esp)
  8011c2:	e8 a9 ef ff ff       	call   800170 <cprintf>
		return -E_INVAL;
  8011c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cc:	eb 24                	jmp    8011f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8011d4:	85 d2                	test   %edx,%edx
  8011d6:	74 15                	je     8011ed <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011e6:	89 04 24             	mov    %eax,(%esp)
  8011e9:	ff d2                	call   *%edx
  8011eb:	eb 05                	jmp    8011f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011f2:	83 c4 24             	add    $0x24,%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801201:	89 44 24 04          	mov    %eax,0x4(%esp)
  801205:	8b 45 08             	mov    0x8(%ebp),%eax
  801208:	89 04 24             	mov    %eax,(%esp)
  80120b:	e8 e6 fb ff ff       	call   800df6 <fd_lookup>
  801210:	85 c0                	test   %eax,%eax
  801212:	78 0e                	js     801222 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801214:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80121d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801222:	c9                   	leave  
  801223:	c3                   	ret    

00801224 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	53                   	push   %ebx
  801228:	83 ec 24             	sub    $0x24,%esp
  80122b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801231:	89 44 24 04          	mov    %eax,0x4(%esp)
  801235:	89 1c 24             	mov    %ebx,(%esp)
  801238:	e8 b9 fb ff ff       	call   800df6 <fd_lookup>
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 61                	js     8012a2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801244:	89 44 24 04          	mov    %eax,0x4(%esp)
  801248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124b:	8b 00                	mov    (%eax),%eax
  80124d:	89 04 24             	mov    %eax,(%esp)
  801250:	e8 f7 fb ff ff       	call   800e4c <dev_lookup>
  801255:	85 c0                	test   %eax,%eax
  801257:	78 49                	js     8012a2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801260:	75 23                	jne    801285 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801262:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801267:	8b 40 48             	mov    0x48(%eax),%eax
  80126a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80126e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801272:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  801279:	e8 f2 ee ff ff       	call   800170 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801283:	eb 1d                	jmp    8012a2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801285:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801288:	8b 52 18             	mov    0x18(%edx),%edx
  80128b:	85 d2                	test   %edx,%edx
  80128d:	74 0e                	je     80129d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801296:	89 04 24             	mov    %eax,(%esp)
  801299:	ff d2                	call   *%edx
  80129b:	eb 05                	jmp    8012a2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80129d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012a2:	83 c4 24             	add    $0x24,%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 24             	sub    $0x24,%esp
  8012af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	89 04 24             	mov    %eax,(%esp)
  8012bf:	e8 32 fb ff ff       	call   800df6 <fd_lookup>
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 52                	js     80131a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	8b 00                	mov    (%eax),%eax
  8012d4:	89 04 24             	mov    %eax,(%esp)
  8012d7:	e8 70 fb ff ff       	call   800e4c <dev_lookup>
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 3a                	js     80131a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8012e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012e7:	74 2c                	je     801315 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f3:	00 00 00 
	stat->st_isdir = 0;
  8012f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012fd:	00 00 00 
	stat->st_dev = dev;
  801300:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801306:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80130a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80130d:	89 14 24             	mov    %edx,(%esp)
  801310:	ff 50 14             	call   *0x14(%eax)
  801313:	eb 05                	jmp    80131a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801315:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80131a:	83 c4 24             	add    $0x24,%esp
  80131d:	5b                   	pop    %ebx
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801328:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80132f:	00 
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	89 04 24             	mov    %eax,(%esp)
  801336:	e8 fe 01 00 00       	call   801539 <open>
  80133b:	89 c3                	mov    %eax,%ebx
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 1b                	js     80135c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801341:	8b 45 0c             	mov    0xc(%ebp),%eax
  801344:	89 44 24 04          	mov    %eax,0x4(%esp)
  801348:	89 1c 24             	mov    %ebx,(%esp)
  80134b:	e8 58 ff ff ff       	call   8012a8 <fstat>
  801350:	89 c6                	mov    %eax,%esi
	close(fd);
  801352:	89 1c 24             	mov    %ebx,(%esp)
  801355:	e8 d4 fb ff ff       	call   800f2e <close>
	return r;
  80135a:	89 f3                	mov    %esi,%ebx
}
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    
  801365:	00 00                	add    %al,(%eax)
	...

00801368 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	56                   	push   %esi
  80136c:	53                   	push   %ebx
  80136d:	83 ec 10             	sub    $0x10,%esp
  801370:	89 c3                	mov    %eax,%ebx
  801372:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801374:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80137b:	75 11                	jne    80138e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80137d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801384:	e8 92 08 00 00       	call   801c1b <ipc_find_env>
  801389:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80138e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801395:	00 
  801396:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80139d:	00 
  80139e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8013a7:	89 04 24             	mov    %eax,(%esp)
  8013aa:	e8 02 08 00 00       	call   801bb1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013b6:	00 
  8013b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c2:	e8 81 07 00 00       	call   801b48 <ipc_recv>
}
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f1:	e8 72 ff ff ff       	call   801368 <fsipc>
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801401:	8b 40 0c             	mov    0xc(%eax),%eax
  801404:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801409:	ba 00 00 00 00       	mov    $0x0,%edx
  80140e:	b8 06 00 00 00       	mov    $0x6,%eax
  801413:	e8 50 ff ff ff       	call   801368 <fsipc>
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	53                   	push   %ebx
  80141e:	83 ec 14             	sub    $0x14,%esp
  801421:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	8b 40 0c             	mov    0xc(%eax),%eax
  80142a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	b8 05 00 00 00       	mov    $0x5,%eax
  801439:	e8 2a ff ff ff       	call   801368 <fsipc>
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 2b                	js     80146d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801442:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801449:	00 
  80144a:	89 1c 24             	mov    %ebx,(%esp)
  80144d:	e8 c9 f2 ff ff       	call   80071b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801452:	a1 80 50 80 00       	mov    0x805080,%eax
  801457:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80145d:	a1 84 50 80 00       	mov    0x805084,%eax
  801462:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146d:	83 c4 14             	add    $0x14,%esp
  801470:	5b                   	pop    %ebx
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801479:	c7 44 24 08 f8 22 80 	movl   $0x8022f8,0x8(%esp)
  801480:	00 
  801481:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801488:	00 
  801489:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  801490:	e8 5b 06 00 00       	call   801af0 <_panic>

00801495 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	56                   	push   %esi
  801499:	53                   	push   %ebx
  80149a:	83 ec 10             	sub    $0x10,%esp
  80149d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014ab:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8014bb:	e8 a8 fe ff ff       	call   801368 <fsipc>
  8014c0:	89 c3                	mov    %eax,%ebx
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 6a                	js     801530 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8014c6:	39 c6                	cmp    %eax,%esi
  8014c8:	73 24                	jae    8014ee <devfile_read+0x59>
  8014ca:	c7 44 24 0c 21 23 80 	movl   $0x802321,0xc(%esp)
  8014d1:	00 
  8014d2:	c7 44 24 08 28 23 80 	movl   $0x802328,0x8(%esp)
  8014d9:	00 
  8014da:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8014e1:	00 
  8014e2:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  8014e9:	e8 02 06 00 00       	call   801af0 <_panic>
	assert(r <= PGSIZE);
  8014ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f3:	7e 24                	jle    801519 <devfile_read+0x84>
  8014f5:	c7 44 24 0c 3d 23 80 	movl   $0x80233d,0xc(%esp)
  8014fc:	00 
  8014fd:	c7 44 24 08 28 23 80 	movl   $0x802328,0x8(%esp)
  801504:	00 
  801505:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80150c:	00 
  80150d:	c7 04 24 16 23 80 00 	movl   $0x802316,(%esp)
  801514:	e8 d7 05 00 00       	call   801af0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801519:	89 44 24 08          	mov    %eax,0x8(%esp)
  80151d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801524:	00 
  801525:	8b 45 0c             	mov    0xc(%ebp),%eax
  801528:	89 04 24             	mov    %eax,(%esp)
  80152b:	e8 64 f3 ff ff       	call   800894 <memmove>
	return r;
}
  801530:	89 d8                	mov    %ebx,%eax
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	5b                   	pop    %ebx
  801536:	5e                   	pop    %esi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    

00801539 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
  80153e:	83 ec 20             	sub    $0x20,%esp
  801541:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801544:	89 34 24             	mov    %esi,(%esp)
  801547:	e8 9c f1 ff ff       	call   8006e8 <strlen>
  80154c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801551:	7f 60                	jg     8015b3 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801553:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801556:	89 04 24             	mov    %eax,(%esp)
  801559:	e8 45 f8 ff ff       	call   800da3 <fd_alloc>
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	85 c0                	test   %eax,%eax
  801562:	78 54                	js     8015b8 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801564:	89 74 24 04          	mov    %esi,0x4(%esp)
  801568:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80156f:	e8 a7 f1 ff ff       	call   80071b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801574:	8b 45 0c             	mov    0xc(%ebp),%eax
  801577:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80157c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157f:	b8 01 00 00 00       	mov    $0x1,%eax
  801584:	e8 df fd ff ff       	call   801368 <fsipc>
  801589:	89 c3                	mov    %eax,%ebx
  80158b:	85 c0                	test   %eax,%eax
  80158d:	79 15                	jns    8015a4 <open+0x6b>
		fd_close(fd, 0);
  80158f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801596:	00 
  801597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159a:	89 04 24             	mov    %eax,(%esp)
  80159d:	e8 04 f9 ff ff       	call   800ea6 <fd_close>
		return r;
  8015a2:	eb 14                	jmp    8015b8 <open+0x7f>
	}

	return fd2num(fd);
  8015a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	e8 c9 f7 ff ff       	call   800d78 <fd2num>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	eb 05                	jmp    8015b8 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015b3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015b8:	89 d8                	mov    %ebx,%eax
  8015ba:	83 c4 20             	add    $0x20,%esp
  8015bd:	5b                   	pop    %ebx
  8015be:	5e                   	pop    %esi
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8015d1:	e8 92 fd ff ff       	call   801368 <fsipc>
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 10             	sub    $0x10,%esp
  8015e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e6:	89 04 24             	mov    %eax,(%esp)
  8015e9:	e8 9a f7 ff ff       	call   800d88 <fd2data>
  8015ee:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015f0:	c7 44 24 04 49 23 80 	movl   $0x802349,0x4(%esp)
  8015f7:	00 
  8015f8:	89 34 24             	mov    %esi,(%esp)
  8015fb:	e8 1b f1 ff ff       	call   80071b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801600:	8b 43 04             	mov    0x4(%ebx),%eax
  801603:	2b 03                	sub    (%ebx),%eax
  801605:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80160b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801612:	00 00 00 
	stat->st_dev = &devpipe;
  801615:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80161c:	30 80 00 
	return 0;
}
  80161f:	b8 00 00 00 00       	mov    $0x0,%eax
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	5b                   	pop    %ebx
  801628:	5e                   	pop    %esi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	53                   	push   %ebx
  80162f:	83 ec 14             	sub    $0x14,%esp
  801632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801635:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801639:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801640:	e8 6f f5 ff ff       	call   800bb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801645:	89 1c 24             	mov    %ebx,(%esp)
  801648:	e8 3b f7 ff ff       	call   800d88 <fd2data>
  80164d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801651:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801658:	e8 57 f5 ff ff       	call   800bb4 <sys_page_unmap>
}
  80165d:	83 c4 14             	add    $0x14,%esp
  801660:	5b                   	pop    %ebx
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    

00801663 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	57                   	push   %edi
  801667:	56                   	push   %esi
  801668:	53                   	push   %ebx
  801669:	83 ec 2c             	sub    $0x2c,%esp
  80166c:	89 c7                	mov    %eax,%edi
  80166e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801671:	a1 04 40 80 00       	mov    0x804004,%eax
  801676:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801679:	89 3c 24             	mov    %edi,(%esp)
  80167c:	e8 df 05 00 00       	call   801c60 <pageref>
  801681:	89 c6                	mov    %eax,%esi
  801683:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801686:	89 04 24             	mov    %eax,(%esp)
  801689:	e8 d2 05 00 00       	call   801c60 <pageref>
  80168e:	39 c6                	cmp    %eax,%esi
  801690:	0f 94 c0             	sete   %al
  801693:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801696:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80169c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80169f:	39 cb                	cmp    %ecx,%ebx
  8016a1:	75 08                	jne    8016ab <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016a3:	83 c4 2c             	add    $0x2c,%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5f                   	pop    %edi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016ab:	83 f8 01             	cmp    $0x1,%eax
  8016ae:	75 c1                	jne    801671 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016b0:	8b 42 58             	mov    0x58(%edx),%eax
  8016b3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016ba:	00 
  8016bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c3:	c7 04 24 50 23 80 00 	movl   $0x802350,(%esp)
  8016ca:	e8 a1 ea ff ff       	call   800170 <cprintf>
  8016cf:	eb a0                	jmp    801671 <_pipeisclosed+0xe>

008016d1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	57                   	push   %edi
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 1c             	sub    $0x1c,%esp
  8016da:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016dd:	89 34 24             	mov    %esi,(%esp)
  8016e0:	e8 a3 f6 ff ff       	call   800d88 <fd2data>
  8016e5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8016ec:	eb 3c                	jmp    80172a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016ee:	89 da                	mov    %ebx,%edx
  8016f0:	89 f0                	mov    %esi,%eax
  8016f2:	e8 6c ff ff ff       	call   801663 <_pipeisclosed>
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	75 38                	jne    801733 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016fb:	e8 ee f3 ff ff       	call   800aee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801700:	8b 43 04             	mov    0x4(%ebx),%eax
  801703:	8b 13                	mov    (%ebx),%edx
  801705:	83 c2 20             	add    $0x20,%edx
  801708:	39 d0                	cmp    %edx,%eax
  80170a:	73 e2                	jae    8016ee <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80170c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80170f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801712:	89 c2                	mov    %eax,%edx
  801714:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80171a:	79 05                	jns    801721 <devpipe_write+0x50>
  80171c:	4a                   	dec    %edx
  80171d:	83 ca e0             	or     $0xffffffe0,%edx
  801720:	42                   	inc    %edx
  801721:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801725:	40                   	inc    %eax
  801726:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801729:	47                   	inc    %edi
  80172a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80172d:	75 d1                	jne    801700 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80172f:	89 f8                	mov    %edi,%eax
  801731:	eb 05                	jmp    801738 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801738:	83 c4 1c             	add    $0x1c,%esp
  80173b:	5b                   	pop    %ebx
  80173c:	5e                   	pop    %esi
  80173d:	5f                   	pop    %edi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	57                   	push   %edi
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
  801746:	83 ec 1c             	sub    $0x1c,%esp
  801749:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80174c:	89 3c 24             	mov    %edi,(%esp)
  80174f:	e8 34 f6 ff ff       	call   800d88 <fd2data>
  801754:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801756:	be 00 00 00 00       	mov    $0x0,%esi
  80175b:	eb 3a                	jmp    801797 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80175d:	85 f6                	test   %esi,%esi
  80175f:	74 04                	je     801765 <devpipe_read+0x25>
				return i;
  801761:	89 f0                	mov    %esi,%eax
  801763:	eb 40                	jmp    8017a5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801765:	89 da                	mov    %ebx,%edx
  801767:	89 f8                	mov    %edi,%eax
  801769:	e8 f5 fe ff ff       	call   801663 <_pipeisclosed>
  80176e:	85 c0                	test   %eax,%eax
  801770:	75 2e                	jne    8017a0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801772:	e8 77 f3 ff ff       	call   800aee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801777:	8b 03                	mov    (%ebx),%eax
  801779:	3b 43 04             	cmp    0x4(%ebx),%eax
  80177c:	74 df                	je     80175d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80177e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801783:	79 05                	jns    80178a <devpipe_read+0x4a>
  801785:	48                   	dec    %eax
  801786:	83 c8 e0             	or     $0xffffffe0,%eax
  801789:	40                   	inc    %eax
  80178a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80178e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801791:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801794:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801796:	46                   	inc    %esi
  801797:	3b 75 10             	cmp    0x10(%ebp),%esi
  80179a:	75 db                	jne    801777 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80179c:	89 f0                	mov    %esi,%eax
  80179e:	eb 05                	jmp    8017a5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017a5:	83 c4 1c             	add    $0x1c,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	57                   	push   %edi
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	83 ec 3c             	sub    $0x3c,%esp
  8017b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017bc:	89 04 24             	mov    %eax,(%esp)
  8017bf:	e8 df f5 ff ff       	call   800da3 <fd_alloc>
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	0f 88 45 01 00 00    	js     801913 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ce:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017d5:	00 
  8017d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e4:	e8 24 f3 ff ff       	call   800b0d <sys_page_alloc>
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	0f 88 20 01 00 00    	js     801913 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017f6:	89 04 24             	mov    %eax,(%esp)
  8017f9:	e8 a5 f5 ff ff       	call   800da3 <fd_alloc>
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	85 c0                	test   %eax,%eax
  801802:	0f 88 f8 00 00 00    	js     801900 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801808:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80180f:	00 
  801810:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801813:	89 44 24 04          	mov    %eax,0x4(%esp)
  801817:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80181e:	e8 ea f2 ff ff       	call   800b0d <sys_page_alloc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	85 c0                	test   %eax,%eax
  801827:	0f 88 d3 00 00 00    	js     801900 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80182d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801830:	89 04 24             	mov    %eax,(%esp)
  801833:	e8 50 f5 ff ff       	call   800d88 <fd2data>
  801838:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801841:	00 
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80184d:	e8 bb f2 ff ff       	call   800b0d <sys_page_alloc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	85 c0                	test   %eax,%eax
  801856:	0f 88 91 00 00 00    	js     8018ed <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80185f:	89 04 24             	mov    %eax,(%esp)
  801862:	e8 21 f5 ff ff       	call   800d88 <fd2data>
  801867:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80186e:	00 
  80186f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801873:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80187a:	00 
  80187b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80187f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801886:	e8 d6 f2 ff ff       	call   800b61 <sys_page_map>
  80188b:	89 c3                	mov    %eax,%ebx
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 4c                	js     8018dd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801891:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801897:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80189a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80189c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80189f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018a6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018af:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018b4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018be:	89 04 24             	mov    %eax,(%esp)
  8018c1:	e8 b2 f4 ff ff       	call   800d78 <fd2num>
  8018c6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018cb:	89 04 24             	mov    %eax,(%esp)
  8018ce:	e8 a5 f4 ff ff       	call   800d78 <fd2num>
  8018d3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018db:	eb 36                	jmp    801913 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8018dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e8:	e8 c7 f2 ff ff       	call   800bb4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8018ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fb:	e8 b4 f2 ff ff       	call   800bb4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801900:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801903:	89 44 24 04          	mov    %eax,0x4(%esp)
  801907:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190e:	e8 a1 f2 ff ff       	call   800bb4 <sys_page_unmap>
    err:
	return r;
}
  801913:	89 d8                	mov    %ebx,%eax
  801915:	83 c4 3c             	add    $0x3c,%esp
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5f                   	pop    %edi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	89 04 24             	mov    %eax,(%esp)
  801930:	e8 c1 f4 ff ff       	call   800df6 <fd_lookup>
  801935:	85 c0                	test   %eax,%eax
  801937:	78 15                	js     80194e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 44 f4 ff ff       	call   800d88 <fd2data>
	return _pipeisclosed(fd, p);
  801944:	89 c2                	mov    %eax,%edx
  801946:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801949:	e8 15 fd ff ff       	call   801663 <_pipeisclosed>
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801953:	b8 00 00 00 00       	mov    $0x0,%eax
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801960:	c7 44 24 04 68 23 80 	movl   $0x802368,0x4(%esp)
  801967:	00 
  801968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196b:	89 04 24             	mov    %eax,(%esp)
  80196e:	e8 a8 ed ff ff       	call   80071b <strcpy>
	return 0;
}
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	57                   	push   %edi
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801986:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80198b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801991:	eb 30                	jmp    8019c3 <devcons_write+0x49>
		m = n - tot;
  801993:	8b 75 10             	mov    0x10(%ebp),%esi
  801996:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801998:	83 fe 7f             	cmp    $0x7f,%esi
  80199b:	76 05                	jbe    8019a2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80199d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019a2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019a6:	03 45 0c             	add    0xc(%ebp),%eax
  8019a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ad:	89 3c 24             	mov    %edi,(%esp)
  8019b0:	e8 df ee ff ff       	call   800894 <memmove>
		sys_cputs(buf, m);
  8019b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019b9:	89 3c 24             	mov    %edi,(%esp)
  8019bc:	e8 7f f0 ff ff       	call   800a40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c1:	01 f3                	add    %esi,%ebx
  8019c3:	89 d8                	mov    %ebx,%eax
  8019c5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019c8:	72 c9                	jb     801993 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019ca:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5f                   	pop    %edi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019df:	75 07                	jne    8019e8 <devcons_read+0x13>
  8019e1:	eb 25                	jmp    801a08 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019e3:	e8 06 f1 ff ff       	call   800aee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019e8:	e8 71 f0 ff ff       	call   800a5e <sys_cgetc>
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	74 f2                	je     8019e3 <devcons_read+0xe>
  8019f1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 1d                	js     801a14 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019f7:	83 f8 04             	cmp    $0x4,%eax
  8019fa:	74 13                	je     801a0f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ff:	88 10                	mov    %dl,(%eax)
	return 1;
  801a01:	b8 01 00 00 00       	mov    $0x1,%eax
  801a06:	eb 0c                	jmp    801a14 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0d:	eb 05                	jmp    801a14 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a22:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a29:	00 
  801a2a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a2d:	89 04 24             	mov    %eax,(%esp)
  801a30:	e8 0b f0 ff ff       	call   800a40 <sys_cputs>
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <getchar>:

int
getchar(void)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a3d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a44:	00 
  801a45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a53:	e8 3a f6 ff ff       	call   801092 <read>
	if (r < 0)
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 0f                	js     801a6b <getchar+0x34>
		return r;
	if (r < 1)
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	7e 06                	jle    801a66 <getchar+0x2f>
		return -E_EOF;
	return c;
  801a60:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a64:	eb 05                	jmp    801a6b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a66:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	89 04 24             	mov    %eax,(%esp)
  801a80:	e8 71 f3 ff ff       	call   800df6 <fd_lookup>
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 11                	js     801a9a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a92:	39 10                	cmp    %edx,(%eax)
  801a94:	0f 94 c0             	sete   %al
  801a97:	0f b6 c0             	movzbl %al,%eax
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <opencons>:

int
opencons(void)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa5:	89 04 24             	mov    %eax,(%esp)
  801aa8:	e8 f6 f2 ff ff       	call   800da3 <fd_alloc>
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 3c                	js     801aed <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ab8:	00 
  801ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac7:	e8 41 f0 ff ff       	call   800b0d <sys_page_alloc>
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 1d                	js     801aed <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ad0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ade:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae5:	89 04 24             	mov    %eax,(%esp)
  801ae8:	e8 8b f2 ff ff       	call   800d78 <fd2num>
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    
	...

00801af0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801af8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801afb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b01:	e8 c9 ef ff ff       	call   800acf <sys_getenvid>
  801b06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b09:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b10:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b14:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1c:	c7 04 24 74 23 80 00 	movl   $0x802374,(%esp)
  801b23:	e8 48 e6 ff ff       	call   800170 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b2f:	89 04 24             	mov    %eax,(%esp)
  801b32:	e8 d8 e5 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801b37:	c7 04 24 61 23 80 00 	movl   $0x802361,(%esp)
  801b3e:	e8 2d e6 ff ff       	call   800170 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b43:	cc                   	int3   
  801b44:	eb fd                	jmp    801b43 <_panic+0x53>
	...

00801b48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	57                   	push   %edi
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	83 ec 1c             	sub    $0x1c,%esp
  801b51:	8b 75 08             	mov    0x8(%ebp),%esi
  801b54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b57:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801b5a:	85 db                	test   %ebx,%ebx
  801b5c:	75 05                	jne    801b63 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801b5e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801b63:	89 1c 24             	mov    %ebx,(%esp)
  801b66:	e8 b8 f1 ff ff       	call   800d23 <sys_ipc_recv>
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	79 16                	jns    801b85 <ipc_recv+0x3d>
		*from_env_store = 0;
  801b6f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801b75:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801b7b:	89 1c 24             	mov    %ebx,(%esp)
  801b7e:	e8 a0 f1 ff ff       	call   800d23 <sys_ipc_recv>
  801b83:	eb 24                	jmp    801ba9 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801b85:	85 f6                	test   %esi,%esi
  801b87:	74 0a                	je     801b93 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801b89:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8e:	8b 40 74             	mov    0x74(%eax),%eax
  801b91:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801b93:	85 ff                	test   %edi,%edi
  801b95:	74 0a                	je     801ba1 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801b97:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9c:	8b 40 78             	mov    0x78(%eax),%eax
  801b9f:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801ba1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ba9:	83 c4 1c             	add    $0x1c,%esp
  801bac:	5b                   	pop    %ebx
  801bad:	5e                   	pop    %esi
  801bae:	5f                   	pop    %edi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	57                   	push   %edi
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 1c             	sub    $0x1c,%esp
  801bba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bc0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801bc3:	85 db                	test   %ebx,%ebx
  801bc5:	75 05                	jne    801bcc <ipc_send+0x1b>
		pg = (void *)-1;
  801bc7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bcc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bd0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bd4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	89 04 24             	mov    %eax,(%esp)
  801bde:	e8 1d f1 ff ff       	call   800d00 <sys_ipc_try_send>
		if (r == 0) {		
  801be3:	85 c0                	test   %eax,%eax
  801be5:	74 2c                	je     801c13 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801be7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bea:	75 07                	jne    801bf3 <ipc_send+0x42>
			sys_yield();
  801bec:	e8 fd ee ff ff       	call   800aee <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801bf1:	eb d9                	jmp    801bcc <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801bf3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf7:	c7 44 24 08 98 23 80 	movl   $0x802398,0x8(%esp)
  801bfe:	00 
  801bff:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c06:	00 
  801c07:	c7 04 24 a6 23 80 00 	movl   $0x8023a6,(%esp)
  801c0e:	e8 dd fe ff ff       	call   801af0 <_panic>
		}
	}
}
  801c13:	83 c4 1c             	add    $0x1c,%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5f                   	pop    %edi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	53                   	push   %ebx
  801c1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c27:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c2e:	89 c2                	mov    %eax,%edx
  801c30:	c1 e2 07             	shl    $0x7,%edx
  801c33:	29 ca                	sub    %ecx,%edx
  801c35:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c3b:	8b 52 50             	mov    0x50(%edx),%edx
  801c3e:	39 da                	cmp    %ebx,%edx
  801c40:	75 0f                	jne    801c51 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c42:	c1 e0 07             	shl    $0x7,%eax
  801c45:	29 c8                	sub    %ecx,%eax
  801c47:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c4c:	8b 40 40             	mov    0x40(%eax),%eax
  801c4f:	eb 0c                	jmp    801c5d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c51:	40                   	inc    %eax
  801c52:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c57:	75 ce                	jne    801c27 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c59:	66 b8 00 00          	mov    $0x0,%ax
}
  801c5d:	5b                   	pop    %ebx
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c66:	89 c2                	mov    %eax,%edx
  801c68:	c1 ea 16             	shr    $0x16,%edx
  801c6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c72:	f6 c2 01             	test   $0x1,%dl
  801c75:	74 1e                	je     801c95 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c77:	c1 e8 0c             	shr    $0xc,%eax
  801c7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c81:	a8 01                	test   $0x1,%al
  801c83:	74 17                	je     801c9c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c85:	c1 e8 0c             	shr    $0xc,%eax
  801c88:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c8f:	ef 
  801c90:	0f b7 c0             	movzwl %ax,%eax
  801c93:	eb 0c                	jmp    801ca1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9a:	eb 05                	jmp    801ca1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    
	...

00801ca4 <__udivdi3>:
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	83 ec 10             	sub    $0x10,%esp
  801caa:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cb2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cba:	89 cd                	mov    %ecx,%ebp
  801cbc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	75 2c                	jne    801cf0 <__udivdi3+0x4c>
  801cc4:	39 f9                	cmp    %edi,%ecx
  801cc6:	77 68                	ja     801d30 <__udivdi3+0x8c>
  801cc8:	85 c9                	test   %ecx,%ecx
  801cca:	75 0b                	jne    801cd7 <__udivdi3+0x33>
  801ccc:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd1:	31 d2                	xor    %edx,%edx
  801cd3:	f7 f1                	div    %ecx
  801cd5:	89 c1                	mov    %eax,%ecx
  801cd7:	31 d2                	xor    %edx,%edx
  801cd9:	89 f8                	mov    %edi,%eax
  801cdb:	f7 f1                	div    %ecx
  801cdd:	89 c7                	mov    %eax,%edi
  801cdf:	89 f0                	mov    %esi,%eax
  801ce1:	f7 f1                	div    %ecx
  801ce3:	89 c6                	mov    %eax,%esi
  801ce5:	89 f0                	mov    %esi,%eax
  801ce7:	89 fa                	mov    %edi,%edx
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	5e                   	pop    %esi
  801ced:	5f                   	pop    %edi
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    
  801cf0:	39 f8                	cmp    %edi,%eax
  801cf2:	77 2c                	ja     801d20 <__udivdi3+0x7c>
  801cf4:	0f bd f0             	bsr    %eax,%esi
  801cf7:	83 f6 1f             	xor    $0x1f,%esi
  801cfa:	75 4c                	jne    801d48 <__udivdi3+0xa4>
  801cfc:	39 f8                	cmp    %edi,%eax
  801cfe:	bf 00 00 00 00       	mov    $0x0,%edi
  801d03:	72 0a                	jb     801d0f <__udivdi3+0x6b>
  801d05:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d09:	0f 87 ad 00 00 00    	ja     801dbc <__udivdi3+0x118>
  801d0f:	be 01 00 00 00       	mov    $0x1,%esi
  801d14:	89 f0                	mov    %esi,%eax
  801d16:	89 fa                	mov    %edi,%edx
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	5e                   	pop    %esi
  801d1c:	5f                   	pop    %edi
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    
  801d1f:	90                   	nop
  801d20:	31 ff                	xor    %edi,%edi
  801d22:	31 f6                	xor    %esi,%esi
  801d24:	89 f0                	mov    %esi,%eax
  801d26:	89 fa                	mov    %edi,%edx
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	5e                   	pop    %esi
  801d2c:	5f                   	pop    %edi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    
  801d2f:	90                   	nop
  801d30:	89 fa                	mov    %edi,%edx
  801d32:	89 f0                	mov    %esi,%eax
  801d34:	f7 f1                	div    %ecx
  801d36:	89 c6                	mov    %eax,%esi
  801d38:	31 ff                	xor    %edi,%edi
  801d3a:	89 f0                	mov    %esi,%eax
  801d3c:	89 fa                	mov    %edi,%edx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    
  801d45:	8d 76 00             	lea    0x0(%esi),%esi
  801d48:	89 f1                	mov    %esi,%ecx
  801d4a:	d3 e0                	shl    %cl,%eax
  801d4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d50:	b8 20 00 00 00       	mov    $0x20,%eax
  801d55:	29 f0                	sub    %esi,%eax
  801d57:	89 ea                	mov    %ebp,%edx
  801d59:	88 c1                	mov    %al,%cl
  801d5b:	d3 ea                	shr    %cl,%edx
  801d5d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d61:	09 ca                	or     %ecx,%edx
  801d63:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d67:	89 f1                	mov    %esi,%ecx
  801d69:	d3 e5                	shl    %cl,%ebp
  801d6b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d6f:	89 fd                	mov    %edi,%ebp
  801d71:	88 c1                	mov    %al,%cl
  801d73:	d3 ed                	shr    %cl,%ebp
  801d75:	89 fa                	mov    %edi,%edx
  801d77:	89 f1                	mov    %esi,%ecx
  801d79:	d3 e2                	shl    %cl,%edx
  801d7b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d7f:	88 c1                	mov    %al,%cl
  801d81:	d3 ef                	shr    %cl,%edi
  801d83:	09 d7                	or     %edx,%edi
  801d85:	89 f8                	mov    %edi,%eax
  801d87:	89 ea                	mov    %ebp,%edx
  801d89:	f7 74 24 08          	divl   0x8(%esp)
  801d8d:	89 d1                	mov    %edx,%ecx
  801d8f:	89 c7                	mov    %eax,%edi
  801d91:	f7 64 24 0c          	mull   0xc(%esp)
  801d95:	39 d1                	cmp    %edx,%ecx
  801d97:	72 17                	jb     801db0 <__udivdi3+0x10c>
  801d99:	74 09                	je     801da4 <__udivdi3+0x100>
  801d9b:	89 fe                	mov    %edi,%esi
  801d9d:	31 ff                	xor    %edi,%edi
  801d9f:	e9 41 ff ff ff       	jmp    801ce5 <__udivdi3+0x41>
  801da4:	8b 54 24 04          	mov    0x4(%esp),%edx
  801da8:	89 f1                	mov    %esi,%ecx
  801daa:	d3 e2                	shl    %cl,%edx
  801dac:	39 c2                	cmp    %eax,%edx
  801dae:	73 eb                	jae    801d9b <__udivdi3+0xf7>
  801db0:	8d 77 ff             	lea    -0x1(%edi),%esi
  801db3:	31 ff                	xor    %edi,%edi
  801db5:	e9 2b ff ff ff       	jmp    801ce5 <__udivdi3+0x41>
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	31 f6                	xor    %esi,%esi
  801dbe:	e9 22 ff ff ff       	jmp    801ce5 <__udivdi3+0x41>
	...

00801dc4 <__umoddi3>:
  801dc4:	55                   	push   %ebp
  801dc5:	57                   	push   %edi
  801dc6:	56                   	push   %esi
  801dc7:	83 ec 20             	sub    $0x20,%esp
  801dca:	8b 44 24 30          	mov    0x30(%esp),%eax
  801dce:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801dd2:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dd6:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dda:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dde:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801de2:	89 c7                	mov    %eax,%edi
  801de4:	89 f2                	mov    %esi,%edx
  801de6:	85 ed                	test   %ebp,%ebp
  801de8:	75 16                	jne    801e00 <__umoddi3+0x3c>
  801dea:	39 f1                	cmp    %esi,%ecx
  801dec:	0f 86 a6 00 00 00    	jbe    801e98 <__umoddi3+0xd4>
  801df2:	f7 f1                	div    %ecx
  801df4:	89 d0                	mov    %edx,%eax
  801df6:	31 d2                	xor    %edx,%edx
  801df8:	83 c4 20             	add    $0x20,%esp
  801dfb:	5e                   	pop    %esi
  801dfc:	5f                   	pop    %edi
  801dfd:	5d                   	pop    %ebp
  801dfe:	c3                   	ret    
  801dff:	90                   	nop
  801e00:	39 f5                	cmp    %esi,%ebp
  801e02:	0f 87 ac 00 00 00    	ja     801eb4 <__umoddi3+0xf0>
  801e08:	0f bd c5             	bsr    %ebp,%eax
  801e0b:	83 f0 1f             	xor    $0x1f,%eax
  801e0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e12:	0f 84 a8 00 00 00    	je     801ec0 <__umoddi3+0xfc>
  801e18:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e1c:	d3 e5                	shl    %cl,%ebp
  801e1e:	bf 20 00 00 00       	mov    $0x20,%edi
  801e23:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e27:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e2b:	89 f9                	mov    %edi,%ecx
  801e2d:	d3 e8                	shr    %cl,%eax
  801e2f:	09 e8                	or     %ebp,%eax
  801e31:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e35:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e39:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e3d:	d3 e0                	shl    %cl,%eax
  801e3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	d3 e2                	shl    %cl,%edx
  801e47:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e4b:	d3 e0                	shl    %cl,%eax
  801e4d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e51:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e55:	89 f9                	mov    %edi,%ecx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	09 d0                	or     %edx,%eax
  801e5b:	d3 ee                	shr    %cl,%esi
  801e5d:	89 f2                	mov    %esi,%edx
  801e5f:	f7 74 24 18          	divl   0x18(%esp)
  801e63:	89 d6                	mov    %edx,%esi
  801e65:	f7 64 24 0c          	mull   0xc(%esp)
  801e69:	89 c5                	mov    %eax,%ebp
  801e6b:	89 d1                	mov    %edx,%ecx
  801e6d:	39 d6                	cmp    %edx,%esi
  801e6f:	72 67                	jb     801ed8 <__umoddi3+0x114>
  801e71:	74 75                	je     801ee8 <__umoddi3+0x124>
  801e73:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e77:	29 e8                	sub    %ebp,%eax
  801e79:	19 ce                	sbb    %ecx,%esi
  801e7b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e7f:	d3 e8                	shr    %cl,%eax
  801e81:	89 f2                	mov    %esi,%edx
  801e83:	89 f9                	mov    %edi,%ecx
  801e85:	d3 e2                	shl    %cl,%edx
  801e87:	09 d0                	or     %edx,%eax
  801e89:	89 f2                	mov    %esi,%edx
  801e8b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e8f:	d3 ea                	shr    %cl,%edx
  801e91:	83 c4 20             	add    $0x20,%esp
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    
  801e98:	85 c9                	test   %ecx,%ecx
  801e9a:	75 0b                	jne    801ea7 <__umoddi3+0xe3>
  801e9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea1:	31 d2                	xor    %edx,%edx
  801ea3:	f7 f1                	div    %ecx
  801ea5:	89 c1                	mov    %eax,%ecx
  801ea7:	89 f0                	mov    %esi,%eax
  801ea9:	31 d2                	xor    %edx,%edx
  801eab:	f7 f1                	div    %ecx
  801ead:	89 f8                	mov    %edi,%eax
  801eaf:	e9 3e ff ff ff       	jmp    801df2 <__umoddi3+0x2e>
  801eb4:	89 f2                	mov    %esi,%edx
  801eb6:	83 c4 20             	add    $0x20,%esp
  801eb9:	5e                   	pop    %esi
  801eba:	5f                   	pop    %edi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	39 f5                	cmp    %esi,%ebp
  801ec2:	72 04                	jb     801ec8 <__umoddi3+0x104>
  801ec4:	39 f9                	cmp    %edi,%ecx
  801ec6:	77 06                	ja     801ece <__umoddi3+0x10a>
  801ec8:	89 f2                	mov    %esi,%edx
  801eca:	29 cf                	sub    %ecx,%edi
  801ecc:	19 ea                	sbb    %ebp,%edx
  801ece:	89 f8                	mov    %edi,%eax
  801ed0:	83 c4 20             	add    $0x20,%esp
  801ed3:	5e                   	pop    %esi
  801ed4:	5f                   	pop    %edi
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    
  801ed7:	90                   	nop
  801ed8:	89 d1                	mov    %edx,%ecx
  801eda:	89 c5                	mov    %eax,%ebp
  801edc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ee0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ee4:	eb 8d                	jmp    801e73 <__umoddi3+0xaf>
  801ee6:	66 90                	xchg   %ax,%ax
  801ee8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801eec:	72 ea                	jb     801ed8 <__umoddi3+0x114>
  801eee:	89 f1                	mov    %esi,%ecx
  801ef0:	eb 81                	jmp    801e73 <__umoddi3+0xaf>
