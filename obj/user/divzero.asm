
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  80005c:	e8 13 01 00 00       	call   800174 <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 10             	sub    $0x10,%esp
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800072:	e8 5c 0a 00 00       	call   800ad3 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800083:	c1 e0 07             	shl    $0x7,%eax
  800086:	29 d0                	sub    %edx,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 07                	jle    80009d <libmain+0x39>
		binaryname = argv[0];
  800096:	8b 03                	mov    (%ebx),%eax
  800098:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	89 34 24             	mov    %esi,(%esp)
  8000a4:	e8 8b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a9:	e8 0a 00 00 00       	call   8000b8 <exit>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    
  8000b5:	00 00                	add    %al,(%eax)
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000be:	e8 a0 0e 00 00       	call   800f63 <close_all>
	sys_env_destroy(0);
  8000c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ca:	e8 b2 09 00 00       	call   800a81 <sys_env_destroy>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    
  8000d1:	00 00                	add    %al,(%eax)
	...

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 14             	sub    $0x14,%esp
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000de:	8b 03                	mov    (%ebx),%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e7:	40                   	inc    %eax
  8000e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	75 19                	jne    80010a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000f1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f8:	00 
  8000f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fc:	89 04 24             	mov    %eax,(%esp)
  8000ff:	e8 40 09 00 00       	call   800a44 <sys_cputs>
		b->idx = 0;
  800104:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010a:	ff 43 04             	incl   0x4(%ebx)
}
  80010d:	83 c4 14             	add    $0x14,%esp
  800110:	5b                   	pop    %ebx
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	8b 45 0c             	mov    0xc(%ebp),%eax
  800133:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800137:	8b 45 08             	mov    0x8(%ebp),%eax
  80013a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800144:	89 44 24 04          	mov    %eax,0x4(%esp)
  800148:	c7 04 24 d4 00 80 00 	movl   $0x8000d4,(%esp)
  80014f:	e8 82 01 00 00       	call   8002d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800154:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 d8 08 00 00       	call   800a44 <sys_cputs>

	return b.cnt;
}
  80016c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 87 ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	75 08                	jne    8001bc <printnum+0x2c>
  8001b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ba:	77 57                	ja     800213 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001c0:	4b                   	dec    %ebx
  8001c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001db:	00 
  8001dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	e8 ba 1a 00 00       	call   801ca8 <__udivdi3>
  8001ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f6:	89 04 24             	mov    %eax,(%esp)
  8001f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fd:	89 fa                	mov    %edi,%edx
  8001ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800202:	e8 89 ff ff ff       	call   800190 <printnum>
  800207:	eb 0f                	jmp    800218 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800209:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020d:	89 34 24             	mov    %esi,(%esp)
  800210:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800213:	4b                   	dec    %ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7f f1                	jg     800209 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800218:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800220:	8b 45 10             	mov    0x10(%ebp),%eax
  800223:	89 44 24 08          	mov    %eax,0x8(%esp)
  800227:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022e:	00 
  80022f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	e8 87 1b 00 00       	call   801dc8 <__umoddi3>
  800241:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800245:	0f be 80 18 1f 80 00 	movsbl 0x801f18(%eax),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800252:	83 c4 3c             	add    $0x3c,%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025d:	83 fa 01             	cmp    $0x1,%edx
  800260:	7e 0e                	jle    800270 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 08             	lea    0x8(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	8b 52 04             	mov    0x4(%edx),%edx
  80026e:	eb 22                	jmp    800292 <getuint+0x38>
	else if (lflag)
  800270:	85 d2                	test   %edx,%edx
  800272:	74 10                	je     800284 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
  800282:	eb 0e                	jmp    800292 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 04             	lea    0x4(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a2:	73 08                	jae    8002ac <sprintputch+0x18>
		*b->buf++ = ch;
  8002a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a7:	88 0a                	mov    %cl,(%edx)
  8002a9:	42                   	inc    %edx
  8002aa:	89 10                	mov    %edx,(%eax)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	e8 02 00 00 00       	call   8002d6 <vprintfmt>
	va_end(ap);
}
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 4c             	sub    $0x4c,%esp
  8002df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e5:	eb 12                	jmp    8002f9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	0f 84 6b 03 00 00    	je     80065a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	0f b6 06             	movzbl (%esi),%eax
  8002fc:	46                   	inc    %esi
  8002fd:	83 f8 25             	cmp    $0x25,%eax
  800300:	75 e5                	jne    8002e7 <vprintfmt+0x11>
  800302:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800306:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80030d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800312:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800319:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031e:	eb 26                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800323:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800327:	eb 1d                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800330:	eb 14                	jmp    800346 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800335:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80033c:	eb 08                	jmp    800346 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800341:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	0f b6 06             	movzbl (%esi),%eax
  800349:	8d 56 01             	lea    0x1(%esi),%edx
  80034c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80034f:	8a 16                	mov    (%esi),%dl
  800351:	83 ea 23             	sub    $0x23,%edx
  800354:	80 fa 55             	cmp    $0x55,%dl
  800357:	0f 87 e1 02 00 00    	ja     80063e <vprintfmt+0x368>
  80035d:	0f b6 d2             	movzbl %dl,%edx
  800360:	ff 24 95 60 20 80 00 	jmp    *0x802060(,%edx,4)
  800367:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80036a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800372:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800376:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800379:	8d 50 d0             	lea    -0x30(%eax),%edx
  80037c:	83 fa 09             	cmp    $0x9,%edx
  80037f:	77 2a                	ja     8003ab <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800381:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800382:	eb eb                	jmp    80036f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 50 04             	lea    0x4(%eax),%edx
  80038a:	89 55 14             	mov    %edx,0x14(%ebp)
  80038d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800392:	eb 17                	jmp    8003ab <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800394:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800398:	78 98                	js     800332 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80039d:	eb a7                	jmp    800346 <vprintfmt+0x70>
  80039f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a9:	eb 9b                	jmp    800346 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003af:	79 95                	jns    800346 <vprintfmt+0x70>
  8003b1:	eb 8b                	jmp    80033e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b7:	eb 8d                	jmp    800346 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 50 04             	lea    0x4(%eax),%edx
  8003bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d1:	e9 23 ff ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 50 04             	lea    0x4(%eax),%edx
  8003dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	79 02                	jns    8003e7 <vprintfmt+0x111>
  8003e5:	f7 d8                	neg    %eax
  8003e7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e9:	83 f8 0f             	cmp    $0xf,%eax
  8003ec:	7f 0b                	jg     8003f9 <vprintfmt+0x123>
  8003ee:	8b 04 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	75 23                	jne    80041c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003fd:	c7 44 24 08 30 1f 80 	movl   $0x801f30,0x8(%esp)
  800404:	00 
  800405:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 9a fe ff ff       	call   8002ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800417:	e9 dd fe ff ff       	jmp    8002f9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80041c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800420:	c7 44 24 08 1a 23 80 	movl   $0x80231a,0x8(%esp)
  800427:	00 
  800428:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042c:	8b 55 08             	mov    0x8(%ebp),%edx
  80042f:	89 14 24             	mov    %edx,(%esp)
  800432:	e8 77 fe ff ff       	call   8002ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043a:	e9 ba fe ff ff       	jmp    8002f9 <vprintfmt+0x23>
  80043f:	89 f9                	mov    %edi,%ecx
  800441:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800444:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 30                	mov    (%eax),%esi
  800452:	85 f6                	test   %esi,%esi
  800454:	75 05                	jne    80045b <vprintfmt+0x185>
				p = "(null)";
  800456:	be 29 1f 80 00       	mov    $0x801f29,%esi
			if (width > 0 && padc != '-')
  80045b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045f:	0f 8e 84 00 00 00    	jle    8004e9 <vprintfmt+0x213>
  800465:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800469:	74 7e                	je     8004e9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046f:	89 34 24             	mov    %esi,(%esp)
  800472:	e8 8b 02 00 00       	call   800702 <strnlen>
  800477:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80047a:	29 c2                	sub    %eax,%edx
  80047c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80047f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800483:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800486:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800489:	89 de                	mov    %ebx,%esi
  80048b:	89 d3                	mov    %edx,%ebx
  80048d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	eb 0b                	jmp    80049c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800491:	89 74 24 04          	mov    %esi,0x4(%esp)
  800495:	89 3c 24             	mov    %edi,(%esp)
  800498:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	4b                   	dec    %ebx
  80049c:	85 db                	test   %ebx,%ebx
  80049e:	7f f1                	jg     800491 <vprintfmt+0x1bb>
  8004a0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004a3:	89 f3                	mov    %esi,%ebx
  8004a5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	79 05                	jns    8004b4 <vprintfmt+0x1de>
  8004af:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b7:	29 c2                	sub    %eax,%edx
  8004b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004bc:	eb 2b                	jmp    8004e9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c2:	74 18                	je     8004dc <vprintfmt+0x206>
  8004c4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ca:	76 10                	jbe    8004dc <vprintfmt+0x206>
					putch('?', putdat);
  8004cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
  8004da:	eb 0a                	jmp    8004e6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e9:	0f be 06             	movsbl (%esi),%eax
  8004ec:	46                   	inc    %esi
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	74 21                	je     800512 <vprintfmt+0x23c>
  8004f1:	85 ff                	test   %edi,%edi
  8004f3:	78 c9                	js     8004be <vprintfmt+0x1e8>
  8004f5:	4f                   	dec    %edi
  8004f6:	79 c6                	jns    8004be <vprintfmt+0x1e8>
  8004f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004fb:	89 de                	mov    %ebx,%esi
  8004fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800500:	eb 18                	jmp    80051a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800502:	89 74 24 04          	mov    %esi,0x4(%esp)
  800506:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80050d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050f:	4b                   	dec    %ebx
  800510:	eb 08                	jmp    80051a <vprintfmt+0x244>
  800512:	8b 7d 08             	mov    0x8(%ebp),%edi
  800515:	89 de                	mov    %ebx,%esi
  800517:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80051a:	85 db                	test   %ebx,%ebx
  80051c:	7f e4                	jg     800502 <vprintfmt+0x22c>
  80051e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800521:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800526:	e9 ce fd ff ff       	jmp    8002f9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052b:	83 f9 01             	cmp    $0x1,%ecx
  80052e:	7e 10                	jle    800540 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 08             	lea    0x8(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 30                	mov    (%eax),%esi
  80053b:	8b 78 04             	mov    0x4(%eax),%edi
  80053e:	eb 26                	jmp    800566 <vprintfmt+0x290>
	else if (lflag)
  800540:	85 c9                	test   %ecx,%ecx
  800542:	74 12                	je     800556 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 30                	mov    (%eax),%esi
  80054f:	89 f7                	mov    %esi,%edi
  800551:	c1 ff 1f             	sar    $0x1f,%edi
  800554:	eb 10                	jmp    800566 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 30                	mov    (%eax),%esi
  800561:	89 f7                	mov    %esi,%edi
  800563:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800566:	85 ff                	test   %edi,%edi
  800568:	78 0a                	js     800574 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056f:	e9 8c 00 00 00       	jmp    800600 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800574:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800578:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800582:	f7 de                	neg    %esi
  800584:	83 d7 00             	adc    $0x0,%edi
  800587:	f7 df                	neg    %edi
			}
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058e:	eb 70                	jmp    800600 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800590:	89 ca                	mov    %ecx,%edx
  800592:	8d 45 14             	lea    0x14(%ebp),%eax
  800595:	e8 c0 fc ff ff       	call   80025a <getuint>
  80059a:	89 c6                	mov    %eax,%esi
  80059c:	89 d7                	mov    %edx,%edi
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a3:	eb 5b                	jmp    800600 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005a5:	89 ca                	mov    %ecx,%edx
  8005a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005aa:	e8 ab fc ff ff       	call   80025a <getuint>
  8005af:	89 c6                	mov    %eax,%esi
  8005b1:	89 d7                	mov    %edx,%edi
			base = 8;
  8005b3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005b8:	eb 46                	jmp    800600 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005be:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005df:	8b 30                	mov    (%eax),%esi
  8005e1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005eb:	eb 13                	jmp    800600 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005ed:	89 ca                	mov    %ecx,%edx
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 63 fc ff ff       	call   80025a <getuint>
  8005f7:	89 c6                	mov    %eax,%esi
  8005f9:	89 d7                	mov    %edx,%edi
			base = 16;
  8005fb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800600:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800604:	89 54 24 10          	mov    %edx,0x10(%esp)
  800608:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800613:	89 34 24             	mov    %esi,(%esp)
  800616:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061a:	89 da                	mov    %ebx,%edx
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	e8 6c fb ff ff       	call   800190 <printnum>
			break;
  800624:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800627:	e9 cd fc ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800639:	e9 bb fc ff ff       	jmp    8002f9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800642:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800649:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064c:	eb 01                	jmp    80064f <vprintfmt+0x379>
  80064e:	4e                   	dec    %esi
  80064f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800653:	75 f9                	jne    80064e <vprintfmt+0x378>
  800655:	e9 9f fc ff ff       	jmp    8002f9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80065a:	83 c4 4c             	add    $0x4c,%esp
  80065d:	5b                   	pop    %ebx
  80065e:	5e                   	pop    %esi
  80065f:	5f                   	pop    %edi
  800660:	5d                   	pop    %ebp
  800661:	c3                   	ret    

00800662 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	83 ec 28             	sub    $0x28,%esp
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800671:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800675:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067f:	85 c0                	test   %eax,%eax
  800681:	74 30                	je     8006b3 <vsnprintf+0x51>
  800683:	85 d2                	test   %edx,%edx
  800685:	7e 33                	jle    8006ba <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068e:	8b 45 10             	mov    0x10(%ebp),%eax
  800691:	89 44 24 08          	mov    %eax,0x8(%esp)
  800695:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069c:	c7 04 24 94 02 80 00 	movl   $0x800294,(%esp)
  8006a3:	e8 2e fc ff ff       	call   8002d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b1:	eb 0c                	jmp    8006bf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b8:	eb 05                	jmp    8006bf <vsnprintf+0x5d>
  8006ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	e8 7b ff ff ff       	call   800662 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    
  8006e9:	00 00                	add    %al,(%eax)
	...

008006ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	eb 01                	jmp    8006fa <strlen+0xe>
		n++;
  8006f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fe:	75 f9                	jne    8006f9 <strlen+0xd>
		n++;
	return n;
}
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
  800710:	eb 01                	jmp    800713 <strnlen+0x11>
		n++;
  800712:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800713:	39 d0                	cmp    %edx,%eax
  800715:	74 06                	je     80071d <strnlen+0x1b>
  800717:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80071b:	75 f5                	jne    800712 <strnlen+0x10>
		n++;
	return n;
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800729:	ba 00 00 00 00       	mov    $0x0,%edx
  80072e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800731:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800734:	42                   	inc    %edx
  800735:	84 c9                	test   %cl,%cl
  800737:	75 f5                	jne    80072e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800739:	5b                   	pop    %ebx
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800746:	89 1c 24             	mov    %ebx,(%esp)
  800749:	e8 9e ff ff ff       	call   8006ec <strlen>
	strcpy(dst + len, src);
  80074e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800751:	89 54 24 04          	mov    %edx,0x4(%esp)
  800755:	01 d8                	add    %ebx,%eax
  800757:	89 04 24             	mov    %eax,(%esp)
  80075a:	e8 c0 ff ff ff       	call   80071f <strcpy>
	return dst;
}
  80075f:	89 d8                	mov    %ebx,%eax
  800761:	83 c4 08             	add    $0x8,%esp
  800764:	5b                   	pop    %ebx
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800772:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800775:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077a:	eb 0c                	jmp    800788 <strncpy+0x21>
		*dst++ = *src;
  80077c:	8a 1a                	mov    (%edx),%bl
  80077e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800781:	80 3a 01             	cmpb   $0x1,(%edx)
  800784:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800787:	41                   	inc    %ecx
  800788:	39 f1                	cmp    %esi,%ecx
  80078a:	75 f0                	jne    80077c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078c:	5b                   	pop    %ebx
  80078d:	5e                   	pop    %esi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	56                   	push   %esi
  800794:	53                   	push   %ebx
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	75 0a                	jne    8007ac <strlcpy+0x1c>
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	eb 1a                	jmp    8007c0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a6:	88 18                	mov    %bl,(%eax)
  8007a8:	40                   	inc    %eax
  8007a9:	41                   	inc    %ecx
  8007aa:	eb 02                	jmp    8007ae <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ac:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ae:	4a                   	dec    %edx
  8007af:	74 0a                	je     8007bb <strlcpy+0x2b>
  8007b1:	8a 19                	mov    (%ecx),%bl
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ef                	jne    8007a6 <strlcpy+0x16>
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	eb 02                	jmp    8007bd <strlcpy+0x2d>
  8007bb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007bd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007c0:	29 f0                	sub    %esi,%eax
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cf:	eb 02                	jmp    8007d3 <strcmp+0xd>
		p++, q++;
  8007d1:	41                   	inc    %ecx
  8007d2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d3:	8a 01                	mov    (%ecx),%al
  8007d5:	84 c0                	test   %al,%al
  8007d7:	74 04                	je     8007dd <strcmp+0x17>
  8007d9:	3a 02                	cmp    (%edx),%al
  8007db:	74 f4                	je     8007d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dd:	0f b6 c0             	movzbl %al,%eax
  8007e0:	0f b6 12             	movzbl (%edx),%edx
  8007e3:	29 d0                	sub    %edx,%eax
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007f4:	eb 03                	jmp    8007f9 <strncmp+0x12>
		n--, p++, q++;
  8007f6:	4a                   	dec    %edx
  8007f7:	40                   	inc    %eax
  8007f8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 14                	je     800811 <strncmp+0x2a>
  8007fd:	8a 18                	mov    (%eax),%bl
  8007ff:	84 db                	test   %bl,%bl
  800801:	74 04                	je     800807 <strncmp+0x20>
  800803:	3a 19                	cmp    (%ecx),%bl
  800805:	74 ef                	je     8007f6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800807:	0f b6 00             	movzbl (%eax),%eax
  80080a:	0f b6 11             	movzbl (%ecx),%edx
  80080d:	29 d0                	sub    %edx,%eax
  80080f:	eb 05                	jmp    800816 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800822:	eb 05                	jmp    800829 <strchr+0x10>
		if (*s == c)
  800824:	38 ca                	cmp    %cl,%dl
  800826:	74 0c                	je     800834 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800828:	40                   	inc    %eax
  800829:	8a 10                	mov    (%eax),%dl
  80082b:	84 d2                	test   %dl,%dl
  80082d:	75 f5                	jne    800824 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083f:	eb 05                	jmp    800846 <strfind+0x10>
		if (*s == c)
  800841:	38 ca                	cmp    %cl,%dl
  800843:	74 07                	je     80084c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800845:	40                   	inc    %eax
  800846:	8a 10                	mov    (%eax),%dl
  800848:	84 d2                	test   %dl,%dl
  80084a:	75 f5                	jne    800841 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	57                   	push   %edi
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 7d 08             	mov    0x8(%ebp),%edi
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80085d:	85 c9                	test   %ecx,%ecx
  80085f:	74 30                	je     800891 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800861:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800867:	75 25                	jne    80088e <memset+0x40>
  800869:	f6 c1 03             	test   $0x3,%cl
  80086c:	75 20                	jne    80088e <memset+0x40>
		c &= 0xFF;
  80086e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800871:	89 d3                	mov    %edx,%ebx
  800873:	c1 e3 08             	shl    $0x8,%ebx
  800876:	89 d6                	mov    %edx,%esi
  800878:	c1 e6 18             	shl    $0x18,%esi
  80087b:	89 d0                	mov    %edx,%eax
  80087d:	c1 e0 10             	shl    $0x10,%eax
  800880:	09 f0                	or     %esi,%eax
  800882:	09 d0                	or     %edx,%eax
  800884:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800886:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800889:	fc                   	cld    
  80088a:	f3 ab                	rep stos %eax,%es:(%edi)
  80088c:	eb 03                	jmp    800891 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088e:	fc                   	cld    
  80088f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800891:	89 f8                	mov    %edi,%eax
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5f                   	pop    %edi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a6:	39 c6                	cmp    %eax,%esi
  8008a8:	73 34                	jae    8008de <memmove+0x46>
  8008aa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ad:	39 d0                	cmp    %edx,%eax
  8008af:	73 2d                	jae    8008de <memmove+0x46>
		s += n;
		d += n;
  8008b1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b4:	f6 c2 03             	test   $0x3,%dl
  8008b7:	75 1b                	jne    8008d4 <memmove+0x3c>
  8008b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bf:	75 13                	jne    8008d4 <memmove+0x3c>
  8008c1:	f6 c1 03             	test   $0x3,%cl
  8008c4:	75 0e                	jne    8008d4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008c6:	83 ef 04             	sub    $0x4,%edi
  8008c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008cc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008cf:	fd                   	std    
  8008d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d2:	eb 07                	jmp    8008db <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008d4:	4f                   	dec    %edi
  8008d5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d8:	fd                   	std    
  8008d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008db:	fc                   	cld    
  8008dc:	eb 20                	jmp    8008fe <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008de:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e4:	75 13                	jne    8008f9 <memmove+0x61>
  8008e6:	a8 03                	test   $0x3,%al
  8008e8:	75 0f                	jne    8008f9 <memmove+0x61>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	75 0a                	jne    8008f9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008ef:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008f2:	89 c7                	mov    %eax,%edi
  8008f4:	fc                   	cld    
  8008f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f7:	eb 05                	jmp    8008fe <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f9:	89 c7                	mov    %eax,%edi
  8008fb:	fc                   	cld    
  8008fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fe:	5e                   	pop    %esi
  8008ff:	5f                   	pop    %edi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800908:	8b 45 10             	mov    0x10(%ebp),%eax
  80090b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800912:	89 44 24 04          	mov    %eax,0x4(%esp)
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	89 04 24             	mov    %eax,(%esp)
  80091c:	e8 77 ff ff ff       	call   800898 <memmove>
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800932:	ba 00 00 00 00       	mov    $0x0,%edx
  800937:	eb 16                	jmp    80094f <memcmp+0x2c>
		if (*s1 != *s2)
  800939:	8a 04 17             	mov    (%edi,%edx,1),%al
  80093c:	42                   	inc    %edx
  80093d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800941:	38 c8                	cmp    %cl,%al
  800943:	74 0a                	je     80094f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800945:	0f b6 c0             	movzbl %al,%eax
  800948:	0f b6 c9             	movzbl %cl,%ecx
  80094b:	29 c8                	sub    %ecx,%eax
  80094d:	eb 09                	jmp    800958 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094f:	39 da                	cmp    %ebx,%edx
  800951:	75 e6                	jne    800939 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5f                   	pop    %edi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800966:	89 c2                	mov    %eax,%edx
  800968:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80096b:	eb 05                	jmp    800972 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096d:	38 08                	cmp    %cl,(%eax)
  80096f:	74 05                	je     800976 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800971:	40                   	inc    %eax
  800972:	39 d0                	cmp    %edx,%eax
  800974:	72 f7                	jb     80096d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	57                   	push   %edi
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 55 08             	mov    0x8(%ebp),%edx
  800981:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800984:	eb 01                	jmp    800987 <strtol+0xf>
		s++;
  800986:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	8a 02                	mov    (%edx),%al
  800989:	3c 20                	cmp    $0x20,%al
  80098b:	74 f9                	je     800986 <strtol+0xe>
  80098d:	3c 09                	cmp    $0x9,%al
  80098f:	74 f5                	je     800986 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800991:	3c 2b                	cmp    $0x2b,%al
  800993:	75 08                	jne    80099d <strtol+0x25>
		s++;
  800995:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800996:	bf 00 00 00 00       	mov    $0x0,%edi
  80099b:	eb 13                	jmp    8009b0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099d:	3c 2d                	cmp    $0x2d,%al
  80099f:	75 0a                	jne    8009ab <strtol+0x33>
		s++, neg = 1;
  8009a1:	8d 52 01             	lea    0x1(%edx),%edx
  8009a4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a9:	eb 05                	jmp    8009b0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b0:	85 db                	test   %ebx,%ebx
  8009b2:	74 05                	je     8009b9 <strtol+0x41>
  8009b4:	83 fb 10             	cmp    $0x10,%ebx
  8009b7:	75 28                	jne    8009e1 <strtol+0x69>
  8009b9:	8a 02                	mov    (%edx),%al
  8009bb:	3c 30                	cmp    $0x30,%al
  8009bd:	75 10                	jne    8009cf <strtol+0x57>
  8009bf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009c3:	75 0a                	jne    8009cf <strtol+0x57>
		s += 2, base = 16;
  8009c5:	83 c2 02             	add    $0x2,%edx
  8009c8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009cd:	eb 12                	jmp    8009e1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009cf:	85 db                	test   %ebx,%ebx
  8009d1:	75 0e                	jne    8009e1 <strtol+0x69>
  8009d3:	3c 30                	cmp    $0x30,%al
  8009d5:	75 05                	jne    8009dc <strtol+0x64>
		s++, base = 8;
  8009d7:	42                   	inc    %edx
  8009d8:	b3 08                	mov    $0x8,%bl
  8009da:	eb 05                	jmp    8009e1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009dc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e8:	8a 0a                	mov    (%edx),%cl
  8009ea:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009ed:	80 fb 09             	cmp    $0x9,%bl
  8009f0:	77 08                	ja     8009fa <strtol+0x82>
			dig = *s - '0';
  8009f2:	0f be c9             	movsbl %cl,%ecx
  8009f5:	83 e9 30             	sub    $0x30,%ecx
  8009f8:	eb 1e                	jmp    800a18 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009fa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009fd:	80 fb 19             	cmp    $0x19,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a02:	0f be c9             	movsbl %cl,%ecx
  800a05:	83 e9 57             	sub    $0x57,%ecx
  800a08:	eb 0e                	jmp    800a18 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a0a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a0d:	80 fb 19             	cmp    $0x19,%bl
  800a10:	77 12                	ja     800a24 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a12:	0f be c9             	movsbl %cl,%ecx
  800a15:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a18:	39 f1                	cmp    %esi,%ecx
  800a1a:	7d 0c                	jge    800a28 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a1c:	42                   	inc    %edx
  800a1d:	0f af c6             	imul   %esi,%eax
  800a20:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a22:	eb c4                	jmp    8009e8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a24:	89 c1                	mov    %eax,%ecx
  800a26:	eb 02                	jmp    800a2a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a28:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2e:	74 05                	je     800a35 <strtol+0xbd>
		*endptr = (char *) s;
  800a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a33:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a35:	85 ff                	test   %edi,%edi
  800a37:	74 04                	je     800a3d <strtol+0xc5>
  800a39:	89 c8                	mov    %ecx,%eax
  800a3b:	f7 d8                	neg    %eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    
	...

00800a44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a52:	8b 55 08             	mov    0x8(%ebp),%edx
  800a55:	89 c3                	mov    %eax,%ebx
  800a57:	89 c7                	mov    %eax,%edi
  800a59:	89 c6                	mov    %eax,%esi
  800a5b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a72:	89 d1                	mov    %edx,%ecx
  800a74:	89 d3                	mov    %edx,%ebx
  800a76:	89 d7                	mov    %edx,%edi
  800a78:	89 d6                	mov    %edx,%esi
  800a7a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
  800a97:	89 cb                	mov    %ecx,%ebx
  800a99:	89 cf                	mov    %ecx,%edi
  800a9b:	89 ce                	mov    %ecx,%esi
  800a9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	7e 28                	jle    800acb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aa7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aae:	00 
  800aaf:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800ab6:	00 
  800ab7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800abe:	00 
  800abf:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800ac6:	e8 29 10 00 00       	call   801af4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acb:	83 c4 2c             	add    $0x2c,%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ade:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae3:	89 d1                	mov    %edx,%ecx
  800ae5:	89 d3                	mov    %edx,%ebx
  800ae7:	89 d7                	mov    %edx,%edi
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_yield>:

void
sys_yield(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	be 00 00 00 00       	mov    $0x0,%esi
  800b1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	89 f7                	mov    %esi,%edi
  800b2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7e 28                	jle    800b5d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b39:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b40:	00 
  800b41:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800b48:	00 
  800b49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b50:	00 
  800b51:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800b58:	e8 97 0f 00 00       	call   801af4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5d:	83 c4 2c             	add    $0x2c,%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b73:	8b 75 18             	mov    0x18(%ebp),%esi
  800b76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7e 28                	jle    800bb0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b93:	00 
  800b94:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800b9b:	00 
  800b9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba3:	00 
  800ba4:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800bab:	e8 44 0f 00 00       	call   801af4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb0:	83 c4 2c             	add    $0x2c,%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	89 df                	mov    %ebx,%edi
  800bd3:	89 de                	mov    %ebx,%esi
  800bd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 28                	jle    800c03 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800be6:	00 
  800be7:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800bee:	00 
  800bef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf6:	00 
  800bf7:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800bfe:	e8 f1 0e 00 00       	call   801af4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c03:	83 c4 2c             	add    $0x2c,%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c19:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	89 df                	mov    %ebx,%edi
  800c26:	89 de                	mov    %ebx,%esi
  800c28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 28                	jle    800c56 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c32:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c39:	00 
  800c3a:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800c41:	00 
  800c42:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c49:	00 
  800c4a:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800c51:	e8 9e 0e 00 00       	call   801af4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c56:	83 c4 2c             	add    $0x2c,%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 df                	mov    %ebx,%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 28                	jle    800ca9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c85:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800c94:	00 
  800c95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9c:	00 
  800c9d:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800ca4:	e8 4b 0e 00 00       	call   801af4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca9:	83 c4 2c             	add    $0x2c,%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	89 de                	mov    %ebx,%esi
  800cce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7e 28                	jle    800cfc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800ce7:	00 
  800ce8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cef:	00 
  800cf0:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800cf7:	e8 f8 0d 00 00       	call   801af4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfc:	83 c4 2c             	add    $0x2c,%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	be 00 00 00 00       	mov    $0x0,%esi
  800d0f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d35:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 cb                	mov    %ecx,%ebx
  800d3f:	89 cf                	mov    %ecx,%edi
  800d41:	89 ce                	mov    %ecx,%esi
  800d43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 28                	jle    800d71 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d54:	00 
  800d55:	c7 44 24 08 1f 22 80 	movl   $0x80221f,0x8(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d64:	00 
  800d65:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800d6c:	e8 83 0d 00 00       	call   801af4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d71:	83 c4 2c             	add    $0x2c,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
  800d79:	00 00                	add    %al,(%eax)
	...

00800d7c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	05 00 00 00 30       	add    $0x30000000,%eax
  800d87:	c1 e8 0c             	shr    $0xc,%eax
}
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	89 04 24             	mov    %eax,(%esp)
  800d98:	e8 df ff ff ff       	call   800d7c <fd2num>
  800d9d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800da2:	c1 e0 0c             	shl    $0xc,%eax
}
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	53                   	push   %ebx
  800dab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dae:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800db3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db5:	89 c2                	mov    %eax,%edx
  800db7:	c1 ea 16             	shr    $0x16,%edx
  800dba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc1:	f6 c2 01             	test   $0x1,%dl
  800dc4:	74 11                	je     800dd7 <fd_alloc+0x30>
  800dc6:	89 c2                	mov    %eax,%edx
  800dc8:	c1 ea 0c             	shr    $0xc,%edx
  800dcb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd2:	f6 c2 01             	test   $0x1,%dl
  800dd5:	75 09                	jne    800de0 <fd_alloc+0x39>
			*fd_store = fd;
  800dd7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dde:	eb 17                	jmp    800df7 <fd_alloc+0x50>
  800de0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dea:	75 c7                	jne    800db3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800df2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800df7:	5b                   	pop    %ebx
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e00:	83 f8 1f             	cmp    $0x1f,%eax
  800e03:	77 36                	ja     800e3b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e05:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e0a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 16             	shr    $0x16,%edx
  800e12:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	74 24                	je     800e42 <fd_lookup+0x48>
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	c1 ea 0c             	shr    $0xc,%edx
  800e23:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2a:	f6 c2 01             	test   $0x1,%dl
  800e2d:	74 1a                	je     800e49 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e32:	89 02                	mov    %eax,(%edx)
	return 0;
  800e34:	b8 00 00 00 00       	mov    $0x0,%eax
  800e39:	eb 13                	jmp    800e4e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e40:	eb 0c                	jmp    800e4e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e47:	eb 05                	jmp    800e4e <fd_lookup+0x54>
  800e49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	53                   	push   %ebx
  800e54:	83 ec 14             	sub    $0x14,%esp
  800e57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e62:	eb 0e                	jmp    800e72 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800e64:	39 08                	cmp    %ecx,(%eax)
  800e66:	75 09                	jne    800e71 <dev_lookup+0x21>
			*dev = devtab[i];
  800e68:	89 03                	mov    %eax,(%ebx)
			return 0;
  800e6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6f:	eb 33                	jmp    800ea4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e71:	42                   	inc    %edx
  800e72:	8b 04 95 c8 22 80 00 	mov    0x8022c8(,%edx,4),%eax
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	75 e7                	jne    800e64 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e7d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e82:	8b 40 48             	mov    0x48(%eax),%eax
  800e85:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8d:	c7 04 24 4c 22 80 00 	movl   $0x80224c,(%esp)
  800e94:	e8 db f2 ff ff       	call   800174 <cprintf>
	*dev = 0;
  800e99:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea4:	83 c4 14             	add    $0x14,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 30             	sub    $0x30,%esp
  800eb2:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb5:	8a 45 0c             	mov    0xc(%ebp),%al
  800eb8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ebb:	89 34 24             	mov    %esi,(%esp)
  800ebe:	e8 b9 fe ff ff       	call   800d7c <fd2num>
  800ec3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ec6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eca:	89 04 24             	mov    %eax,(%esp)
  800ecd:	e8 28 ff ff ff       	call   800dfa <fd_lookup>
  800ed2:	89 c3                	mov    %eax,%ebx
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	78 05                	js     800edd <fd_close+0x33>
	    || fd != fd2)
  800ed8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800edb:	74 0d                	je     800eea <fd_close+0x40>
		return (must_exist ? r : 0);
  800edd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ee1:	75 46                	jne    800f29 <fd_close+0x7f>
  800ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee8:	eb 3f                	jmp    800f29 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef1:	8b 06                	mov    (%esi),%eax
  800ef3:	89 04 24             	mov    %eax,(%esp)
  800ef6:	e8 55 ff ff ff       	call   800e50 <dev_lookup>
  800efb:	89 c3                	mov    %eax,%ebx
  800efd:	85 c0                	test   %eax,%eax
  800eff:	78 18                	js     800f19 <fd_close+0x6f>
		if (dev->dev_close)
  800f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f04:	8b 40 10             	mov    0x10(%eax),%eax
  800f07:	85 c0                	test   %eax,%eax
  800f09:	74 09                	je     800f14 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f0b:	89 34 24             	mov    %esi,(%esp)
  800f0e:	ff d0                	call   *%eax
  800f10:	89 c3                	mov    %eax,%ebx
  800f12:	eb 05                	jmp    800f19 <fd_close+0x6f>
		else
			r = 0;
  800f14:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f24:	e8 8f fc ff ff       	call   800bb8 <sys_page_unmap>
	return r;
}
  800f29:	89 d8                	mov    %ebx,%eax
  800f2b:	83 c4 30             	add    $0x30,%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f42:	89 04 24             	mov    %eax,(%esp)
  800f45:	e8 b0 fe ff ff       	call   800dfa <fd_lookup>
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	78 13                	js     800f61 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f4e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f55:	00 
  800f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f59:	89 04 24             	mov    %eax,(%esp)
  800f5c:	e8 49 ff ff ff       	call   800eaa <fd_close>
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <close_all>:

void
close_all(void)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	53                   	push   %ebx
  800f67:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f6a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f6f:	89 1c 24             	mov    %ebx,(%esp)
  800f72:	e8 bb ff ff ff       	call   800f32 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f77:	43                   	inc    %ebx
  800f78:	83 fb 20             	cmp    $0x20,%ebx
  800f7b:	75 f2                	jne    800f6f <close_all+0xc>
		close(i);
}
  800f7d:	83 c4 14             	add    $0x14,%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 4c             	sub    $0x4c,%esp
  800f8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	89 04 24             	mov    %eax,(%esp)
  800f9c:	e8 59 fe ff ff       	call   800dfa <fd_lookup>
  800fa1:	89 c3                	mov    %eax,%ebx
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	0f 88 e1 00 00 00    	js     80108c <dup+0x109>
		return r;
	close(newfdnum);
  800fab:	89 3c 24             	mov    %edi,(%esp)
  800fae:	e8 7f ff ff ff       	call   800f32 <close>

	newfd = INDEX2FD(newfdnum);
  800fb3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fb9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fbf:	89 04 24             	mov    %eax,(%esp)
  800fc2:	e8 c5 fd ff ff       	call   800d8c <fd2data>
  800fc7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fc9:	89 34 24             	mov    %esi,(%esp)
  800fcc:	e8 bb fd ff ff       	call   800d8c <fd2data>
  800fd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fd4:	89 d8                	mov    %ebx,%eax
  800fd6:	c1 e8 16             	shr    $0x16,%eax
  800fd9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe0:	a8 01                	test   $0x1,%al
  800fe2:	74 46                	je     80102a <dup+0xa7>
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 0c             	shr    $0xc,%eax
  800fe9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff0:	f6 c2 01             	test   $0x1,%dl
  800ff3:	74 35                	je     80102a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ff5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ffc:	25 07 0e 00 00       	and    $0xe07,%eax
  801001:	89 44 24 10          	mov    %eax,0x10(%esp)
  801005:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801008:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80100c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801013:	00 
  801014:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801018:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101f:	e8 41 fb ff ff       	call   800b65 <sys_page_map>
  801024:	89 c3                	mov    %eax,%ebx
  801026:	85 c0                	test   %eax,%eax
  801028:	78 3b                	js     801065 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80102a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80102d:	89 c2                	mov    %eax,%edx
  80102f:	c1 ea 0c             	shr    $0xc,%edx
  801032:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801039:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80103f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801043:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801047:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80104e:	00 
  80104f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801053:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80105a:	e8 06 fb ff ff       	call   800b65 <sys_page_map>
  80105f:	89 c3                	mov    %eax,%ebx
  801061:	85 c0                	test   %eax,%eax
  801063:	79 25                	jns    80108a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801065:	89 74 24 04          	mov    %esi,0x4(%esp)
  801069:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801070:	e8 43 fb ff ff       	call   800bb8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801075:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801078:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801083:	e8 30 fb ff ff       	call   800bb8 <sys_page_unmap>
	return r;
  801088:	eb 02                	jmp    80108c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80108a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80108c:	89 d8                	mov    %ebx,%eax
  80108e:	83 c4 4c             	add    $0x4c,%esp
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	53                   	push   %ebx
  80109a:	83 ec 24             	sub    $0x24,%esp
  80109d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a7:	89 1c 24             	mov    %ebx,(%esp)
  8010aa:	e8 4b fd ff ff       	call   800dfa <fd_lookup>
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	78 6d                	js     801120 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bd:	8b 00                	mov    (%eax),%eax
  8010bf:	89 04 24             	mov    %eax,(%esp)
  8010c2:	e8 89 fd ff ff       	call   800e50 <dev_lookup>
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 55                	js     801120 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ce:	8b 50 08             	mov    0x8(%eax),%edx
  8010d1:	83 e2 03             	and    $0x3,%edx
  8010d4:	83 fa 01             	cmp    $0x1,%edx
  8010d7:	75 23                	jne    8010fc <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010de:	8b 40 48             	mov    0x48(%eax),%eax
  8010e1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e9:	c7 04 24 8d 22 80 00 	movl   $0x80228d,(%esp)
  8010f0:	e8 7f f0 ff ff       	call   800174 <cprintf>
		return -E_INVAL;
  8010f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fa:	eb 24                	jmp    801120 <read+0x8a>
	}
	if (!dev->dev_read)
  8010fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010ff:	8b 52 08             	mov    0x8(%edx),%edx
  801102:	85 d2                	test   %edx,%edx
  801104:	74 15                	je     80111b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801106:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801109:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80110d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801110:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801114:	89 04 24             	mov    %eax,(%esp)
  801117:	ff d2                	call   *%edx
  801119:	eb 05                	jmp    801120 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80111b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801120:	83 c4 24             	add    $0x24,%esp
  801123:	5b                   	pop    %ebx
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	57                   	push   %edi
  80112a:	56                   	push   %esi
  80112b:	53                   	push   %ebx
  80112c:	83 ec 1c             	sub    $0x1c,%esp
  80112f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801132:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801135:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113a:	eb 23                	jmp    80115f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80113c:	89 f0                	mov    %esi,%eax
  80113e:	29 d8                	sub    %ebx,%eax
  801140:	89 44 24 08          	mov    %eax,0x8(%esp)
  801144:	8b 45 0c             	mov    0xc(%ebp),%eax
  801147:	01 d8                	add    %ebx,%eax
  801149:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114d:	89 3c 24             	mov    %edi,(%esp)
  801150:	e8 41 ff ff ff       	call   801096 <read>
		if (m < 0)
  801155:	85 c0                	test   %eax,%eax
  801157:	78 10                	js     801169 <readn+0x43>
			return m;
		if (m == 0)
  801159:	85 c0                	test   %eax,%eax
  80115b:	74 0a                	je     801167 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80115d:	01 c3                	add    %eax,%ebx
  80115f:	39 f3                	cmp    %esi,%ebx
  801161:	72 d9                	jb     80113c <readn+0x16>
  801163:	89 d8                	mov    %ebx,%eax
  801165:	eb 02                	jmp    801169 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801167:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801169:	83 c4 1c             	add    $0x1c,%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	53                   	push   %ebx
  801175:	83 ec 24             	sub    $0x24,%esp
  801178:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801182:	89 1c 24             	mov    %ebx,(%esp)
  801185:	e8 70 fc ff ff       	call   800dfa <fd_lookup>
  80118a:	85 c0                	test   %eax,%eax
  80118c:	78 68                	js     8011f6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801191:	89 44 24 04          	mov    %eax,0x4(%esp)
  801195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801198:	8b 00                	mov    (%eax),%eax
  80119a:	89 04 24             	mov    %eax,(%esp)
  80119d:	e8 ae fc ff ff       	call   800e50 <dev_lookup>
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 50                	js     8011f6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ad:	75 23                	jne    8011d2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011af:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b4:	8b 40 48             	mov    0x48(%eax),%eax
  8011b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011bf:	c7 04 24 a9 22 80 00 	movl   $0x8022a9,(%esp)
  8011c6:	e8 a9 ef ff ff       	call   800174 <cprintf>
		return -E_INVAL;
  8011cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d0:	eb 24                	jmp    8011f6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011d8:	85 d2                	test   %edx,%edx
  8011da:	74 15                	je     8011f1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011ea:	89 04 24             	mov    %eax,(%esp)
  8011ed:	ff d2                	call   *%edx
  8011ef:	eb 05                	jmp    8011f6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011f6:	83 c4 24             	add    $0x24,%esp
  8011f9:	5b                   	pop    %ebx
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <seek>:

int
seek(int fdnum, off_t offset)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801202:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801205:	89 44 24 04          	mov    %eax,0x4(%esp)
  801209:	8b 45 08             	mov    0x8(%ebp),%eax
  80120c:	89 04 24             	mov    %eax,(%esp)
  80120f:	e8 e6 fb ff ff       	call   800dfa <fd_lookup>
  801214:	85 c0                	test   %eax,%eax
  801216:	78 0e                	js     801226 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801218:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80121b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801221:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 24             	sub    $0x24,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801232:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801235:	89 44 24 04          	mov    %eax,0x4(%esp)
  801239:	89 1c 24             	mov    %ebx,(%esp)
  80123c:	e8 b9 fb ff ff       	call   800dfa <fd_lookup>
  801241:	85 c0                	test   %eax,%eax
  801243:	78 61                	js     8012a6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801245:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124f:	8b 00                	mov    (%eax),%eax
  801251:	89 04 24             	mov    %eax,(%esp)
  801254:	e8 f7 fb ff ff       	call   800e50 <dev_lookup>
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 49                	js     8012a6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80125d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801260:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801264:	75 23                	jne    801289 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801266:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80126b:	8b 40 48             	mov    0x48(%eax),%eax
  80126e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	c7 04 24 6c 22 80 00 	movl   $0x80226c,(%esp)
  80127d:	e8 f2 ee ff ff       	call   800174 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801282:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801287:	eb 1d                	jmp    8012a6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801289:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128c:	8b 52 18             	mov    0x18(%edx),%edx
  80128f:	85 d2                	test   %edx,%edx
  801291:	74 0e                	je     8012a1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80129a:	89 04 24             	mov    %eax,(%esp)
  80129d:	ff d2                	call   *%edx
  80129f:	eb 05                	jmp    8012a6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012a6:	83 c4 24             	add    $0x24,%esp
  8012a9:	5b                   	pop    %ebx
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 24             	sub    $0x24,%esp
  8012b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c0:	89 04 24             	mov    %eax,(%esp)
  8012c3:	e8 32 fb ff ff       	call   800dfa <fd_lookup>
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 52                	js     80131e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d6:	8b 00                	mov    (%eax),%eax
  8012d8:	89 04 24             	mov    %eax,(%esp)
  8012db:	e8 70 fb ff ff       	call   800e50 <dev_lookup>
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 3a                	js     80131e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8012e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012eb:	74 2c                	je     801319 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ed:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012f0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f7:	00 00 00 
	stat->st_isdir = 0;
  8012fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801301:	00 00 00 
	stat->st_dev = dev;
  801304:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80130a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80130e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801311:	89 14 24             	mov    %edx,(%esp)
  801314:	ff 50 14             	call   *0x14(%eax)
  801317:	eb 05                	jmp    80131e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801319:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80131e:	83 c4 24             	add    $0x24,%esp
  801321:	5b                   	pop    %ebx
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80132c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801333:	00 
  801334:	8b 45 08             	mov    0x8(%ebp),%eax
  801337:	89 04 24             	mov    %eax,(%esp)
  80133a:	e8 fe 01 00 00       	call   80153d <open>
  80133f:	89 c3                	mov    %eax,%ebx
  801341:	85 c0                	test   %eax,%eax
  801343:	78 1b                	js     801360 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801345:	8b 45 0c             	mov    0xc(%ebp),%eax
  801348:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134c:	89 1c 24             	mov    %ebx,(%esp)
  80134f:	e8 58 ff ff ff       	call   8012ac <fstat>
  801354:	89 c6                	mov    %eax,%esi
	close(fd);
  801356:	89 1c 24             	mov    %ebx,(%esp)
  801359:	e8 d4 fb ff ff       	call   800f32 <close>
	return r;
  80135e:	89 f3                	mov    %esi,%ebx
}
  801360:	89 d8                	mov    %ebx,%eax
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    
  801369:	00 00                	add    %al,(%eax)
	...

0080136c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	56                   	push   %esi
  801370:	53                   	push   %ebx
  801371:	83 ec 10             	sub    $0x10,%esp
  801374:	89 c3                	mov    %eax,%ebx
  801376:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801378:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80137f:	75 11                	jne    801392 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801381:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801388:	e8 92 08 00 00       	call   801c1f <ipc_find_env>
  80138d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801392:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801399:	00 
  80139a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013a1:	00 
  8013a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a6:	a1 00 40 80 00       	mov    0x804000,%eax
  8013ab:	89 04 24             	mov    %eax,(%esp)
  8013ae:	e8 02 08 00 00       	call   801bb5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013ba:	00 
  8013bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c6:	e8 81 07 00 00       	call   801b4c <ipc_recv>
}
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	5b                   	pop    %ebx
  8013cf:	5e                   	pop    %esi
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	8b 40 0c             	mov    0xc(%eax),%eax
  8013de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f5:	e8 72 ff ff ff       	call   80136c <fsipc>
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	8b 40 0c             	mov    0xc(%eax),%eax
  801408:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 06 00 00 00       	mov    $0x6,%eax
  801417:	e8 50 ff ff ff       	call   80136c <fsipc>
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 14             	sub    $0x14,%esp
  801425:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801428:	8b 45 08             	mov    0x8(%ebp),%eax
  80142b:	8b 40 0c             	mov    0xc(%eax),%eax
  80142e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801433:	ba 00 00 00 00       	mov    $0x0,%edx
  801438:	b8 05 00 00 00       	mov    $0x5,%eax
  80143d:	e8 2a ff ff ff       	call   80136c <fsipc>
  801442:	85 c0                	test   %eax,%eax
  801444:	78 2b                	js     801471 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801446:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80144d:	00 
  80144e:	89 1c 24             	mov    %ebx,(%esp)
  801451:	e8 c9 f2 ff ff       	call   80071f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801456:	a1 80 50 80 00       	mov    0x805080,%eax
  80145b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801461:	a1 84 50 80 00       	mov    0x805084,%eax
  801466:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801471:	83 c4 14             	add    $0x14,%esp
  801474:	5b                   	pop    %ebx
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80147d:	c7 44 24 08 d8 22 80 	movl   $0x8022d8,0x8(%esp)
  801484:	00 
  801485:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80148c:	00 
  80148d:	c7 04 24 f6 22 80 00 	movl   $0x8022f6,(%esp)
  801494:	e8 5b 06 00 00       	call   801af4 <_panic>

00801499 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	56                   	push   %esi
  80149d:	53                   	push   %ebx
  80149e:	83 ec 10             	sub    $0x10,%esp
  8014a1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014af:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ba:	b8 03 00 00 00       	mov    $0x3,%eax
  8014bf:	e8 a8 fe ff ff       	call   80136c <fsipc>
  8014c4:	89 c3                	mov    %eax,%ebx
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 6a                	js     801534 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8014ca:	39 c6                	cmp    %eax,%esi
  8014cc:	73 24                	jae    8014f2 <devfile_read+0x59>
  8014ce:	c7 44 24 0c 01 23 80 	movl   $0x802301,0xc(%esp)
  8014d5:	00 
  8014d6:	c7 44 24 08 08 23 80 	movl   $0x802308,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 f6 22 80 00 	movl   $0x8022f6,(%esp)
  8014ed:	e8 02 06 00 00       	call   801af4 <_panic>
	assert(r <= PGSIZE);
  8014f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f7:	7e 24                	jle    80151d <devfile_read+0x84>
  8014f9:	c7 44 24 0c 1d 23 80 	movl   $0x80231d,0xc(%esp)
  801500:	00 
  801501:	c7 44 24 08 08 23 80 	movl   $0x802308,0x8(%esp)
  801508:	00 
  801509:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801510:	00 
  801511:	c7 04 24 f6 22 80 00 	movl   $0x8022f6,(%esp)
  801518:	e8 d7 05 00 00       	call   801af4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80151d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801521:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801528:	00 
  801529:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152c:	89 04 24             	mov    %eax,(%esp)
  80152f:	e8 64 f3 ff ff       	call   800898 <memmove>
	return r;
}
  801534:	89 d8                	mov    %ebx,%eax
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	56                   	push   %esi
  801541:	53                   	push   %ebx
  801542:	83 ec 20             	sub    $0x20,%esp
  801545:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801548:	89 34 24             	mov    %esi,(%esp)
  80154b:	e8 9c f1 ff ff       	call   8006ec <strlen>
  801550:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801555:	7f 60                	jg     8015b7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155a:	89 04 24             	mov    %eax,(%esp)
  80155d:	e8 45 f8 ff ff       	call   800da7 <fd_alloc>
  801562:	89 c3                	mov    %eax,%ebx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 54                	js     8015bc <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801568:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156c:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801573:	e8 a7 f1 ff ff       	call   80071f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801578:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801580:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801583:	b8 01 00 00 00       	mov    $0x1,%eax
  801588:	e8 df fd ff ff       	call   80136c <fsipc>
  80158d:	89 c3                	mov    %eax,%ebx
  80158f:	85 c0                	test   %eax,%eax
  801591:	79 15                	jns    8015a8 <open+0x6b>
		fd_close(fd, 0);
  801593:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80159a:	00 
  80159b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159e:	89 04 24             	mov    %eax,(%esp)
  8015a1:	e8 04 f9 ff ff       	call   800eaa <fd_close>
		return r;
  8015a6:	eb 14                	jmp    8015bc <open+0x7f>
	}

	return fd2num(fd);
  8015a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ab:	89 04 24             	mov    %eax,(%esp)
  8015ae:	e8 c9 f7 ff ff       	call   800d7c <fd2num>
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	eb 05                	jmp    8015bc <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015b7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015bc:	89 d8                	mov    %ebx,%eax
  8015be:	83 c4 20             	add    $0x20,%esp
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5d                   	pop    %ebp
  8015c4:	c3                   	ret    

008015c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8015d5:	e8 92 fd ff ff       	call   80136c <fsipc>
}
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 10             	sub    $0x10,%esp
  8015e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ea:	89 04 24             	mov    %eax,(%esp)
  8015ed:	e8 9a f7 ff ff       	call   800d8c <fd2data>
  8015f2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015f4:	c7 44 24 04 29 23 80 	movl   $0x802329,0x4(%esp)
  8015fb:	00 
  8015fc:	89 34 24             	mov    %esi,(%esp)
  8015ff:	e8 1b f1 ff ff       	call   80071f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801604:	8b 43 04             	mov    0x4(%ebx),%eax
  801607:	2b 03                	sub    (%ebx),%eax
  801609:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80160f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801616:	00 00 00 
	stat->st_dev = &devpipe;
  801619:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801620:	30 80 00 
	return 0;
}
  801623:	b8 00 00 00 00       	mov    $0x0,%eax
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	83 ec 14             	sub    $0x14,%esp
  801636:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801639:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80163d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801644:	e8 6f f5 ff ff       	call   800bb8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801649:	89 1c 24             	mov    %ebx,(%esp)
  80164c:	e8 3b f7 ff ff       	call   800d8c <fd2data>
  801651:	89 44 24 04          	mov    %eax,0x4(%esp)
  801655:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165c:	e8 57 f5 ff ff       	call   800bb8 <sys_page_unmap>
}
  801661:	83 c4 14             	add    $0x14,%esp
  801664:	5b                   	pop    %ebx
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	57                   	push   %edi
  80166b:	56                   	push   %esi
  80166c:	53                   	push   %ebx
  80166d:	83 ec 2c             	sub    $0x2c,%esp
  801670:	89 c7                	mov    %eax,%edi
  801672:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801675:	a1 08 40 80 00       	mov    0x804008,%eax
  80167a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80167d:	89 3c 24             	mov    %edi,(%esp)
  801680:	e8 df 05 00 00       	call   801c64 <pageref>
  801685:	89 c6                	mov    %eax,%esi
  801687:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80168a:	89 04 24             	mov    %eax,(%esp)
  80168d:	e8 d2 05 00 00       	call   801c64 <pageref>
  801692:	39 c6                	cmp    %eax,%esi
  801694:	0f 94 c0             	sete   %al
  801697:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80169a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8016a0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016a3:	39 cb                	cmp    %ecx,%ebx
  8016a5:	75 08                	jne    8016af <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016a7:	83 c4 2c             	add    $0x2c,%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5f                   	pop    %edi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016af:	83 f8 01             	cmp    $0x1,%eax
  8016b2:	75 c1                	jne    801675 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016b4:	8b 42 58             	mov    0x58(%edx),%eax
  8016b7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016be:	00 
  8016bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c7:	c7 04 24 30 23 80 00 	movl   $0x802330,(%esp)
  8016ce:	e8 a1 ea ff ff       	call   800174 <cprintf>
  8016d3:	eb a0                	jmp    801675 <_pipeisclosed+0xe>

008016d5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	57                   	push   %edi
  8016d9:	56                   	push   %esi
  8016da:	53                   	push   %ebx
  8016db:	83 ec 1c             	sub    $0x1c,%esp
  8016de:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016e1:	89 34 24             	mov    %esi,(%esp)
  8016e4:	e8 a3 f6 ff ff       	call   800d8c <fd2data>
  8016e9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8016f0:	eb 3c                	jmp    80172e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016f2:	89 da                	mov    %ebx,%edx
  8016f4:	89 f0                	mov    %esi,%eax
  8016f6:	e8 6c ff ff ff       	call   801667 <_pipeisclosed>
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	75 38                	jne    801737 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016ff:	e8 ee f3 ff ff       	call   800af2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801704:	8b 43 04             	mov    0x4(%ebx),%eax
  801707:	8b 13                	mov    (%ebx),%edx
  801709:	83 c2 20             	add    $0x20,%edx
  80170c:	39 d0                	cmp    %edx,%eax
  80170e:	73 e2                	jae    8016f2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801710:	8b 55 0c             	mov    0xc(%ebp),%edx
  801713:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801716:	89 c2                	mov    %eax,%edx
  801718:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80171e:	79 05                	jns    801725 <devpipe_write+0x50>
  801720:	4a                   	dec    %edx
  801721:	83 ca e0             	or     $0xffffffe0,%edx
  801724:	42                   	inc    %edx
  801725:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801729:	40                   	inc    %eax
  80172a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172d:	47                   	inc    %edi
  80172e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801731:	75 d1                	jne    801704 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801733:	89 f8                	mov    %edi,%eax
  801735:	eb 05                	jmp    80173c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801737:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80173c:	83 c4 1c             	add    $0x1c,%esp
  80173f:	5b                   	pop    %ebx
  801740:	5e                   	pop    %esi
  801741:	5f                   	pop    %edi
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	57                   	push   %edi
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	83 ec 1c             	sub    $0x1c,%esp
  80174d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801750:	89 3c 24             	mov    %edi,(%esp)
  801753:	e8 34 f6 ff ff       	call   800d8c <fd2data>
  801758:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175a:	be 00 00 00 00       	mov    $0x0,%esi
  80175f:	eb 3a                	jmp    80179b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801761:	85 f6                	test   %esi,%esi
  801763:	74 04                	je     801769 <devpipe_read+0x25>
				return i;
  801765:	89 f0                	mov    %esi,%eax
  801767:	eb 40                	jmp    8017a9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801769:	89 da                	mov    %ebx,%edx
  80176b:	89 f8                	mov    %edi,%eax
  80176d:	e8 f5 fe ff ff       	call   801667 <_pipeisclosed>
  801772:	85 c0                	test   %eax,%eax
  801774:	75 2e                	jne    8017a4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801776:	e8 77 f3 ff ff       	call   800af2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80177b:	8b 03                	mov    (%ebx),%eax
  80177d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801780:	74 df                	je     801761 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801782:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801787:	79 05                	jns    80178e <devpipe_read+0x4a>
  801789:	48                   	dec    %eax
  80178a:	83 c8 e0             	or     $0xffffffe0,%eax
  80178d:	40                   	inc    %eax
  80178e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801792:	8b 55 0c             	mov    0xc(%ebp),%edx
  801795:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801798:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179a:	46                   	inc    %esi
  80179b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80179e:	75 db                	jne    80177b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a0:	89 f0                	mov    %esi,%eax
  8017a2:	eb 05                	jmp    8017a9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017a9:	83 c4 1c             	add    $0x1c,%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5f                   	pop    %edi
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	57                   	push   %edi
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 3c             	sub    $0x3c,%esp
  8017ba:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017c0:	89 04 24             	mov    %eax,(%esp)
  8017c3:	e8 df f5 ff ff       	call   800da7 <fd_alloc>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	0f 88 45 01 00 00    	js     801917 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017d9:	00 
  8017da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e8:	e8 24 f3 ff ff       	call   800b11 <sys_page_alloc>
  8017ed:	89 c3                	mov    %eax,%ebx
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	0f 88 20 01 00 00    	js     801917 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017f7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	e8 a5 f5 ff ff       	call   800da7 <fd_alloc>
  801802:	89 c3                	mov    %eax,%ebx
  801804:	85 c0                	test   %eax,%eax
  801806:	0f 88 f8 00 00 00    	js     801904 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801813:	00 
  801814:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801822:	e8 ea f2 ff ff       	call   800b11 <sys_page_alloc>
  801827:	89 c3                	mov    %eax,%ebx
  801829:	85 c0                	test   %eax,%eax
  80182b:	0f 88 d3 00 00 00    	js     801904 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801831:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801834:	89 04 24             	mov    %eax,(%esp)
  801837:	e8 50 f5 ff ff       	call   800d8c <fd2data>
  80183c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801845:	00 
  801846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801851:	e8 bb f2 ff ff       	call   800b11 <sys_page_alloc>
  801856:	89 c3                	mov    %eax,%ebx
  801858:	85 c0                	test   %eax,%eax
  80185a:	0f 88 91 00 00 00    	js     8018f1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801860:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801863:	89 04 24             	mov    %eax,(%esp)
  801866:	e8 21 f5 ff ff       	call   800d8c <fd2data>
  80186b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801872:	00 
  801873:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801877:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80187e:	00 
  80187f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801883:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80188a:	e8 d6 f2 ff ff       	call   800b65 <sys_page_map>
  80188f:	89 c3                	mov    %eax,%ebx
  801891:	85 c0                	test   %eax,%eax
  801893:	78 4c                	js     8018e1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801895:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80189b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80189e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018aa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018b3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018b8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018c2:	89 04 24             	mov    %eax,(%esp)
  8018c5:	e8 b2 f4 ff ff       	call   800d7c <fd2num>
  8018ca:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018cf:	89 04 24             	mov    %eax,(%esp)
  8018d2:	e8 a5 f4 ff ff       	call   800d7c <fd2num>
  8018d7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018df:	eb 36                	jmp    801917 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8018e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ec:	e8 c7 f2 ff ff       	call   800bb8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8018f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ff:	e8 b4 f2 ff ff       	call   800bb8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801904:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801912:	e8 a1 f2 ff ff       	call   800bb8 <sys_page_unmap>
    err:
	return r;
}
  801917:	89 d8                	mov    %ebx,%eax
  801919:	83 c4 3c             	add    $0x3c,%esp
  80191c:	5b                   	pop    %ebx
  80191d:	5e                   	pop    %esi
  80191e:	5f                   	pop    %edi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801927:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	89 04 24             	mov    %eax,(%esp)
  801934:	e8 c1 f4 ff ff       	call   800dfa <fd_lookup>
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 15                	js     801952 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801940:	89 04 24             	mov    %eax,(%esp)
  801943:	e8 44 f4 ff ff       	call   800d8c <fd2data>
	return _pipeisclosed(fd, p);
  801948:	89 c2                	mov    %eax,%edx
  80194a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194d:	e8 15 fd ff ff       	call   801667 <_pipeisclosed>
}
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801964:	c7 44 24 04 48 23 80 	movl   $0x802348,0x4(%esp)
  80196b:	00 
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	89 04 24             	mov    %eax,(%esp)
  801972:	e8 a8 ed ff ff       	call   80071f <strcpy>
	return 0;
}
  801977:	b8 00 00 00 00       	mov    $0x0,%eax
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	57                   	push   %edi
  801982:	56                   	push   %esi
  801983:	53                   	push   %ebx
  801984:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80198a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80198f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801995:	eb 30                	jmp    8019c7 <devcons_write+0x49>
		m = n - tot;
  801997:	8b 75 10             	mov    0x10(%ebp),%esi
  80199a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80199c:	83 fe 7f             	cmp    $0x7f,%esi
  80199f:	76 05                	jbe    8019a6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8019a1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019a6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019aa:	03 45 0c             	add    0xc(%ebp),%eax
  8019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b1:	89 3c 24             	mov    %edi,(%esp)
  8019b4:	e8 df ee ff ff       	call   800898 <memmove>
		sys_cputs(buf, m);
  8019b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019bd:	89 3c 24             	mov    %edi,(%esp)
  8019c0:	e8 7f f0 ff ff       	call   800a44 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c5:	01 f3                	add    %esi,%ebx
  8019c7:	89 d8                	mov    %ebx,%eax
  8019c9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019cc:	72 c9                	jb     801997 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019ce:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5f                   	pop    %edi
  8019d7:	5d                   	pop    %ebp
  8019d8:	c3                   	ret    

008019d9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e3:	75 07                	jne    8019ec <devcons_read+0x13>
  8019e5:	eb 25                	jmp    801a0c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019e7:	e8 06 f1 ff ff       	call   800af2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019ec:	e8 71 f0 ff ff       	call   800a62 <sys_cgetc>
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	74 f2                	je     8019e7 <devcons_read+0xe>
  8019f5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 1d                	js     801a18 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019fb:	83 f8 04             	cmp    $0x4,%eax
  8019fe:	74 13                	je     801a13 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a03:	88 10                	mov    %dl,(%eax)
	return 1;
  801a05:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0a:	eb 0c                	jmp    801a18 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a11:	eb 05                	jmp    801a18 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a20:	8b 45 08             	mov    0x8(%ebp),%eax
  801a23:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a26:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a2d:	00 
  801a2e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a31:	89 04 24             	mov    %eax,(%esp)
  801a34:	e8 0b f0 ff ff       	call   800a44 <sys_cputs>
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <getchar>:

int
getchar(void)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a41:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a48:	00 
  801a49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a57:	e8 3a f6 ff ff       	call   801096 <read>
	if (r < 0)
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 0f                	js     801a6f <getchar+0x34>
		return r;
	if (r < 1)
  801a60:	85 c0                	test   %eax,%eax
  801a62:	7e 06                	jle    801a6a <getchar+0x2f>
		return -E_EOF;
	return c;
  801a64:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a68:	eb 05                	jmp    801a6f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a6a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a81:	89 04 24             	mov    %eax,(%esp)
  801a84:	e8 71 f3 ff ff       	call   800dfa <fd_lookup>
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 11                	js     801a9e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a96:	39 10                	cmp    %edx,(%eax)
  801a98:	0f 94 c0             	sete   %al
  801a9b:	0f b6 c0             	movzbl %al,%eax
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <opencons>:

int
opencons(void)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa9:	89 04 24             	mov    %eax,(%esp)
  801aac:	e8 f6 f2 ff ff       	call   800da7 <fd_alloc>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 3c                	js     801af1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801abc:	00 
  801abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801acb:	e8 41 f0 ff ff       	call   800b11 <sys_page_alloc>
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	78 1d                	js     801af1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ad4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801add:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae9:	89 04 24             	mov    %eax,(%esp)
  801aec:	e8 8b f2 ff ff       	call   800d7c <fd2num>
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    
	...

00801af4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801afc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aff:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b05:	e8 c9 ef ff ff       	call   800ad3 <sys_getenvid>
  801b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b0d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b11:	8b 55 08             	mov    0x8(%ebp),%edx
  801b14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b18:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b20:	c7 04 24 54 23 80 00 	movl   $0x802354,(%esp)
  801b27:	e8 48 e6 ff ff       	call   800174 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b30:	8b 45 10             	mov    0x10(%ebp),%eax
  801b33:	89 04 24             	mov    %eax,(%esp)
  801b36:	e8 d8 e5 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  801b3b:	c7 04 24 0c 1f 80 00 	movl   $0x801f0c,(%esp)
  801b42:	e8 2d e6 ff ff       	call   800174 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b47:	cc                   	int3   
  801b48:	eb fd                	jmp    801b47 <_panic+0x53>
	...

00801b4c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	57                   	push   %edi
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	83 ec 1c             	sub    $0x1c,%esp
  801b55:	8b 75 08             	mov    0x8(%ebp),%esi
  801b58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b5b:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801b5e:	85 db                	test   %ebx,%ebx
  801b60:	75 05                	jne    801b67 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801b62:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801b67:	89 1c 24             	mov    %ebx,(%esp)
  801b6a:	e8 b8 f1 ff ff       	call   800d27 <sys_ipc_recv>
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	79 16                	jns    801b89 <ipc_recv+0x3d>
		*from_env_store = 0;
  801b73:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801b79:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801b7f:	89 1c 24             	mov    %ebx,(%esp)
  801b82:	e8 a0 f1 ff ff       	call   800d27 <sys_ipc_recv>
  801b87:	eb 24                	jmp    801bad <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801b89:	85 f6                	test   %esi,%esi
  801b8b:	74 0a                	je     801b97 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801b8d:	a1 08 40 80 00       	mov    0x804008,%eax
  801b92:	8b 40 74             	mov    0x74(%eax),%eax
  801b95:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801b97:	85 ff                	test   %edi,%edi
  801b99:	74 0a                	je     801ba5 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801b9b:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba0:	8b 40 78             	mov    0x78(%eax),%eax
  801ba3:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801ba5:	a1 08 40 80 00       	mov    0x804008,%eax
  801baa:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bad:	83 c4 1c             	add    $0x1c,%esp
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5f                   	pop    %edi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	57                   	push   %edi
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 1c             	sub    $0x1c,%esp
  801bbe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bc4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801bc7:	85 db                	test   %ebx,%ebx
  801bc9:	75 05                	jne    801bd0 <ipc_send+0x1b>
		pg = (void *)-1;
  801bcb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bd0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bd4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	89 04 24             	mov    %eax,(%esp)
  801be2:	e8 1d f1 ff ff       	call   800d04 <sys_ipc_try_send>
		if (r == 0) {		
  801be7:	85 c0                	test   %eax,%eax
  801be9:	74 2c                	je     801c17 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801beb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bee:	75 07                	jne    801bf7 <ipc_send+0x42>
			sys_yield();
  801bf0:	e8 fd ee ff ff       	call   800af2 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801bf5:	eb d9                	jmp    801bd0 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801bf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfb:	c7 44 24 08 78 23 80 	movl   $0x802378,0x8(%esp)
  801c02:	00 
  801c03:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c0a:	00 
  801c0b:	c7 04 24 86 23 80 00 	movl   $0x802386,(%esp)
  801c12:	e8 dd fe ff ff       	call   801af4 <_panic>
		}
	}
}
  801c17:	83 c4 1c             	add    $0x1c,%esp
  801c1a:	5b                   	pop    %ebx
  801c1b:	5e                   	pop    %esi
  801c1c:	5f                   	pop    %edi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	53                   	push   %ebx
  801c23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c2b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c32:	89 c2                	mov    %eax,%edx
  801c34:	c1 e2 07             	shl    $0x7,%edx
  801c37:	29 ca                	sub    %ecx,%edx
  801c39:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c3f:	8b 52 50             	mov    0x50(%edx),%edx
  801c42:	39 da                	cmp    %ebx,%edx
  801c44:	75 0f                	jne    801c55 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c46:	c1 e0 07             	shl    $0x7,%eax
  801c49:	29 c8                	sub    %ecx,%eax
  801c4b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c50:	8b 40 40             	mov    0x40(%eax),%eax
  801c53:	eb 0c                	jmp    801c61 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c55:	40                   	inc    %eax
  801c56:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c5b:	75 ce                	jne    801c2b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c5d:	66 b8 00 00          	mov    $0x0,%ax
}
  801c61:	5b                   	pop    %ebx
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c6a:	89 c2                	mov    %eax,%edx
  801c6c:	c1 ea 16             	shr    $0x16,%edx
  801c6f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c76:	f6 c2 01             	test   $0x1,%dl
  801c79:	74 1e                	je     801c99 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c7b:	c1 e8 0c             	shr    $0xc,%eax
  801c7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c85:	a8 01                	test   $0x1,%al
  801c87:	74 17                	je     801ca0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c89:	c1 e8 0c             	shr    $0xc,%eax
  801c8c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c93:	ef 
  801c94:	0f b7 c0             	movzwl %ax,%eax
  801c97:	eb 0c                	jmp    801ca5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c99:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9e:	eb 05                	jmp    801ca5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    
	...

00801ca8 <__udivdi3>:
  801ca8:	55                   	push   %ebp
  801ca9:	57                   	push   %edi
  801caa:	56                   	push   %esi
  801cab:	83 ec 10             	sub    $0x10,%esp
  801cae:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cb2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cbe:	89 cd                	mov    %ecx,%ebp
  801cc0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	75 2c                	jne    801cf4 <__udivdi3+0x4c>
  801cc8:	39 f9                	cmp    %edi,%ecx
  801cca:	77 68                	ja     801d34 <__udivdi3+0x8c>
  801ccc:	85 c9                	test   %ecx,%ecx
  801cce:	75 0b                	jne    801cdb <__udivdi3+0x33>
  801cd0:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd5:	31 d2                	xor    %edx,%edx
  801cd7:	f7 f1                	div    %ecx
  801cd9:	89 c1                	mov    %eax,%ecx
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	89 f8                	mov    %edi,%eax
  801cdf:	f7 f1                	div    %ecx
  801ce1:	89 c7                	mov    %eax,%edi
  801ce3:	89 f0                	mov    %esi,%eax
  801ce5:	f7 f1                	div    %ecx
  801ce7:	89 c6                	mov    %eax,%esi
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	89 fa                	mov    %edi,%edx
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    
  801cf4:	39 f8                	cmp    %edi,%eax
  801cf6:	77 2c                	ja     801d24 <__udivdi3+0x7c>
  801cf8:	0f bd f0             	bsr    %eax,%esi
  801cfb:	83 f6 1f             	xor    $0x1f,%esi
  801cfe:	75 4c                	jne    801d4c <__udivdi3+0xa4>
  801d00:	39 f8                	cmp    %edi,%eax
  801d02:	bf 00 00 00 00       	mov    $0x0,%edi
  801d07:	72 0a                	jb     801d13 <__udivdi3+0x6b>
  801d09:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d0d:	0f 87 ad 00 00 00    	ja     801dc0 <__udivdi3+0x118>
  801d13:	be 01 00 00 00       	mov    $0x1,%esi
  801d18:	89 f0                	mov    %esi,%eax
  801d1a:	89 fa                	mov    %edi,%edx
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    
  801d23:	90                   	nop
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	31 f6                	xor    %esi,%esi
  801d28:	89 f0                	mov    %esi,%eax
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	5e                   	pop    %esi
  801d30:	5f                   	pop    %edi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    
  801d33:	90                   	nop
  801d34:	89 fa                	mov    %edi,%edx
  801d36:	89 f0                	mov    %esi,%eax
  801d38:	f7 f1                	div    %ecx
  801d3a:	89 c6                	mov    %eax,%esi
  801d3c:	31 ff                	xor    %edi,%edi
  801d3e:	89 f0                	mov    %esi,%eax
  801d40:	89 fa                	mov    %edi,%edx
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
  801d49:	8d 76 00             	lea    0x0(%esi),%esi
  801d4c:	89 f1                	mov    %esi,%ecx
  801d4e:	d3 e0                	shl    %cl,%eax
  801d50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d54:	b8 20 00 00 00       	mov    $0x20,%eax
  801d59:	29 f0                	sub    %esi,%eax
  801d5b:	89 ea                	mov    %ebp,%edx
  801d5d:	88 c1                	mov    %al,%cl
  801d5f:	d3 ea                	shr    %cl,%edx
  801d61:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d65:	09 ca                	or     %ecx,%edx
  801d67:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d6b:	89 f1                	mov    %esi,%ecx
  801d6d:	d3 e5                	shl    %cl,%ebp
  801d6f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d73:	89 fd                	mov    %edi,%ebp
  801d75:	88 c1                	mov    %al,%cl
  801d77:	d3 ed                	shr    %cl,%ebp
  801d79:	89 fa                	mov    %edi,%edx
  801d7b:	89 f1                	mov    %esi,%ecx
  801d7d:	d3 e2                	shl    %cl,%edx
  801d7f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d83:	88 c1                	mov    %al,%cl
  801d85:	d3 ef                	shr    %cl,%edi
  801d87:	09 d7                	or     %edx,%edi
  801d89:	89 f8                	mov    %edi,%eax
  801d8b:	89 ea                	mov    %ebp,%edx
  801d8d:	f7 74 24 08          	divl   0x8(%esp)
  801d91:	89 d1                	mov    %edx,%ecx
  801d93:	89 c7                	mov    %eax,%edi
  801d95:	f7 64 24 0c          	mull   0xc(%esp)
  801d99:	39 d1                	cmp    %edx,%ecx
  801d9b:	72 17                	jb     801db4 <__udivdi3+0x10c>
  801d9d:	74 09                	je     801da8 <__udivdi3+0x100>
  801d9f:	89 fe                	mov    %edi,%esi
  801da1:	31 ff                	xor    %edi,%edi
  801da3:	e9 41 ff ff ff       	jmp    801ce9 <__udivdi3+0x41>
  801da8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dac:	89 f1                	mov    %esi,%ecx
  801dae:	d3 e2                	shl    %cl,%edx
  801db0:	39 c2                	cmp    %eax,%edx
  801db2:	73 eb                	jae    801d9f <__udivdi3+0xf7>
  801db4:	8d 77 ff             	lea    -0x1(%edi),%esi
  801db7:	31 ff                	xor    %edi,%edi
  801db9:	e9 2b ff ff ff       	jmp    801ce9 <__udivdi3+0x41>
  801dbe:	66 90                	xchg   %ax,%ax
  801dc0:	31 f6                	xor    %esi,%esi
  801dc2:	e9 22 ff ff ff       	jmp    801ce9 <__udivdi3+0x41>
	...

00801dc8 <__umoddi3>:
  801dc8:	55                   	push   %ebp
  801dc9:	57                   	push   %edi
  801dca:	56                   	push   %esi
  801dcb:	83 ec 20             	sub    $0x20,%esp
  801dce:	8b 44 24 30          	mov    0x30(%esp),%eax
  801dd2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801dd6:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dda:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dde:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801de2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801de6:	89 c7                	mov    %eax,%edi
  801de8:	89 f2                	mov    %esi,%edx
  801dea:	85 ed                	test   %ebp,%ebp
  801dec:	75 16                	jne    801e04 <__umoddi3+0x3c>
  801dee:	39 f1                	cmp    %esi,%ecx
  801df0:	0f 86 a6 00 00 00    	jbe    801e9c <__umoddi3+0xd4>
  801df6:	f7 f1                	div    %ecx
  801df8:	89 d0                	mov    %edx,%eax
  801dfa:	31 d2                	xor    %edx,%edx
  801dfc:	83 c4 20             	add    $0x20,%esp
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    
  801e03:	90                   	nop
  801e04:	39 f5                	cmp    %esi,%ebp
  801e06:	0f 87 ac 00 00 00    	ja     801eb8 <__umoddi3+0xf0>
  801e0c:	0f bd c5             	bsr    %ebp,%eax
  801e0f:	83 f0 1f             	xor    $0x1f,%eax
  801e12:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e16:	0f 84 a8 00 00 00    	je     801ec4 <__umoddi3+0xfc>
  801e1c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e20:	d3 e5                	shl    %cl,%ebp
  801e22:	bf 20 00 00 00       	mov    $0x20,%edi
  801e27:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e2b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e2f:	89 f9                	mov    %edi,%ecx
  801e31:	d3 e8                	shr    %cl,%eax
  801e33:	09 e8                	or     %ebp,%eax
  801e35:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e39:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e3d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e41:	d3 e0                	shl    %cl,%eax
  801e43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e47:	89 f2                	mov    %esi,%edx
  801e49:	d3 e2                	shl    %cl,%edx
  801e4b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e4f:	d3 e0                	shl    %cl,%eax
  801e51:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e55:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e59:	89 f9                	mov    %edi,%ecx
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	09 d0                	or     %edx,%eax
  801e5f:	d3 ee                	shr    %cl,%esi
  801e61:	89 f2                	mov    %esi,%edx
  801e63:	f7 74 24 18          	divl   0x18(%esp)
  801e67:	89 d6                	mov    %edx,%esi
  801e69:	f7 64 24 0c          	mull   0xc(%esp)
  801e6d:	89 c5                	mov    %eax,%ebp
  801e6f:	89 d1                	mov    %edx,%ecx
  801e71:	39 d6                	cmp    %edx,%esi
  801e73:	72 67                	jb     801edc <__umoddi3+0x114>
  801e75:	74 75                	je     801eec <__umoddi3+0x124>
  801e77:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e7b:	29 e8                	sub    %ebp,%eax
  801e7d:	19 ce                	sbb    %ecx,%esi
  801e7f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e83:	d3 e8                	shr    %cl,%eax
  801e85:	89 f2                	mov    %esi,%edx
  801e87:	89 f9                	mov    %edi,%ecx
  801e89:	d3 e2                	shl    %cl,%edx
  801e8b:	09 d0                	or     %edx,%eax
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e93:	d3 ea                	shr    %cl,%edx
  801e95:	83 c4 20             	add    $0x20,%esp
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    
  801e9c:	85 c9                	test   %ecx,%ecx
  801e9e:	75 0b                	jne    801eab <__umoddi3+0xe3>
  801ea0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea5:	31 d2                	xor    %edx,%edx
  801ea7:	f7 f1                	div    %ecx
  801ea9:	89 c1                	mov    %eax,%ecx
  801eab:	89 f0                	mov    %esi,%eax
  801ead:	31 d2                	xor    %edx,%edx
  801eaf:	f7 f1                	div    %ecx
  801eb1:	89 f8                	mov    %edi,%eax
  801eb3:	e9 3e ff ff ff       	jmp    801df6 <__umoddi3+0x2e>
  801eb8:	89 f2                	mov    %esi,%edx
  801eba:	83 c4 20             	add    $0x20,%esp
  801ebd:	5e                   	pop    %esi
  801ebe:	5f                   	pop    %edi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    
  801ec1:	8d 76 00             	lea    0x0(%esi),%esi
  801ec4:	39 f5                	cmp    %esi,%ebp
  801ec6:	72 04                	jb     801ecc <__umoddi3+0x104>
  801ec8:	39 f9                	cmp    %edi,%ecx
  801eca:	77 06                	ja     801ed2 <__umoddi3+0x10a>
  801ecc:	89 f2                	mov    %esi,%edx
  801ece:	29 cf                	sub    %ecx,%edi
  801ed0:	19 ea                	sbb    %ebp,%edx
  801ed2:	89 f8                	mov    %edi,%eax
  801ed4:	83 c4 20             	add    $0x20,%esp
  801ed7:	5e                   	pop    %esi
  801ed8:	5f                   	pop    %edi
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    
  801edb:	90                   	nop
  801edc:	89 d1                	mov    %edx,%ecx
  801ede:	89 c5                	mov    %eax,%ebp
  801ee0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ee4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ee8:	eb 8d                	jmp    801e77 <__umoddi3+0xaf>
  801eea:	66 90                	xchg   %ax,%ax
  801eec:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801ef0:	72 ea                	jb     801edc <__umoddi3+0x114>
  801ef2:	89 f1                	mov    %esi,%ecx
  801ef4:	eb 81                	jmp    801e77 <__umoddi3+0xaf>
