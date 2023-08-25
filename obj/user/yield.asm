
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  80004e:	e8 5d 01 00 00       	call   8001b0 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 d1 0a 00 00       	call   800b2e <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 60 1f 80 00 	movl   $0x801f60,(%esp)
  800074:	e8 37 01 00 00       	call   8001b0 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	43                   	inc    %ebx
  80007a:	83 fb 05             	cmp    $0x5,%ebx
  80007d:	75 d9                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007f:	a1 04 40 80 00       	mov    0x804004,%eax
  800084:	8b 40 48             	mov    0x48(%eax),%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 8c 1f 80 00 	movl   $0x801f8c,(%esp)
  800092:	e8 19 01 00 00       	call   8001b0 <cprintf>
}
  800097:	83 c4 14             	add    $0x14,%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8000ae:	e8 5c 0a 00 00       	call   800b0f <sys_getenvid>
  8000b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000bf:	c1 e0 07             	shl    $0x7,%eax
  8000c2:	29 d0                	sub    %edx,%eax
  8000c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ce:	85 f6                	test   %esi,%esi
  8000d0:	7e 07                	jle    8000d9 <libmain+0x39>
		binaryname = argv[0];
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000dd:	89 34 24             	mov    %esi,(%esp)
  8000e0:	e8 4f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e5:	e8 0a 00 00 00       	call   8000f4 <exit>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    
  8000f1:	00 00                	add    %al,(%eax)
	...

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000fa:	e8 a0 0e 00 00       	call   800f9f <close_all>
	sys_env_destroy(0);
  8000ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800106:	e8 b2 09 00 00       	call   800abd <sys_env_destroy>
}
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    
  80010d:	00 00                	add    %al,(%eax)
	...

00800110 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	53                   	push   %ebx
  800114:	83 ec 14             	sub    $0x14,%esp
  800117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011a:	8b 03                	mov    (%ebx),%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800123:	40                   	inc    %eax
  800124:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800126:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012b:	75 19                	jne    800146 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80012d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800134:	00 
  800135:	8d 43 08             	lea    0x8(%ebx),%eax
  800138:	89 04 24             	mov    %eax,(%esp)
  80013b:	e8 40 09 00 00       	call   800a80 <sys_cputs>
		b->idx = 0;
  800140:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800146:	ff 43 04             	incl   0x4(%ebx)
}
  800149:	83 c4 14             	add    $0x14,%esp
  80014c:	5b                   	pop    %ebx
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800173:	8b 45 08             	mov    0x8(%ebp),%eax
  800176:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
  800184:	c7 04 24 10 01 80 00 	movl   $0x800110,(%esp)
  80018b:	e8 82 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 d8 08 00 00       	call   800a80 <sys_cputs>

	return b.cnt;
}
  8001a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 87 ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    
	...

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 3c             	sub    $0x3c,%esp
  8001d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d8:	89 d7                	mov    %edx,%edi
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	75 08                	jne    8001f8 <printnum+0x2c>
  8001f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 57                	ja     80024f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001fc:	4b                   	dec    %ebx
  8001fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800201:	8b 45 10             	mov    0x10(%ebp),%eax
  800204:	89 44 24 08          	mov    %eax,0x8(%esp)
  800208:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80020c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800210:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800217:	00 
  800218:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021b:	89 04 24             	mov    %eax,(%esp)
  80021e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800221:	89 44 24 04          	mov    %eax,0x4(%esp)
  800225:	e8 ba 1a 00 00       	call   801ce4 <__udivdi3>
  80022a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80022e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	89 54 24 04          	mov    %edx,0x4(%esp)
  800239:	89 fa                	mov    %edi,%edx
  80023b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023e:	e8 89 ff ff ff       	call   8001cc <printnum>
  800243:	eb 0f                	jmp    800254 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800245:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800249:	89 34 24             	mov    %esi,(%esp)
  80024c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024f:	4b                   	dec    %ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7f f1                	jg     800245 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800258:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80025c:	8b 45 10             	mov    0x10(%ebp),%eax
  80025f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800263:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026a:	00 
  80026b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	e8 87 1b 00 00       	call   801e04 <__umoddi3>
  80027d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800281:	0f be 80 b5 1f 80 00 	movsbl 0x801fb5(%eax),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80028e:	83 c4 3c             	add    $0x3c,%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800299:	83 fa 01             	cmp    $0x1,%edx
  80029c:	7e 0e                	jle    8002ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	8b 52 04             	mov    0x4(%edx),%edx
  8002aa:	eb 22                	jmp    8002ce <getuint+0x38>
	else if (lflag)
  8002ac:	85 d2                	test   %edx,%edx
  8002ae:	74 10                	je     8002c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002be:	eb 0e                	jmp    8002ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	3b 50 04             	cmp    0x4(%eax),%edx
  8002de:	73 08                	jae    8002e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e3:	88 0a                	mov    %cl,(%edx)
  8002e5:	42                   	inc    %edx
  8002e6:	89 10                	mov    %edx,(%eax)
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800301:	89 44 24 04          	mov    %eax,0x4(%esp)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	e8 02 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 4c             	sub    $0x4c,%esp
  80031b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031e:	8b 75 10             	mov    0x10(%ebp),%esi
  800321:	eb 12                	jmp    800335 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800323:	85 c0                	test   %eax,%eax
  800325:	0f 84 6b 03 00 00    	je     800696 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80032b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800335:	0f b6 06             	movzbl (%esi),%eax
  800338:	46                   	inc    %esi
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e5                	jne    800323 <vprintfmt+0x11>
  80033e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800342:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800349:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80034e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035a:	eb 26                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800363:	eb 1d                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80036c:	eb 14                	jmp    800382 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800371:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800378:	eb 08                	jmp    800382 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80037a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80037d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	0f b6 06             	movzbl (%esi),%eax
  800385:	8d 56 01             	lea    0x1(%esi),%edx
  800388:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80038b:	8a 16                	mov    (%esi),%dl
  80038d:	83 ea 23             	sub    $0x23,%edx
  800390:	80 fa 55             	cmp    $0x55,%dl
  800393:	0f 87 e1 02 00 00    	ja     80067a <vprintfmt+0x368>
  800399:	0f b6 d2             	movzbl %dl,%edx
  80039c:	ff 24 95 00 21 80 00 	jmp    *0x802100(,%edx,4)
  8003a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b8:	83 fa 09             	cmp    $0x9,%edx
  8003bb:	77 2a                	ja     8003e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003be:	eb eb                	jmp    8003ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 50 04             	lea    0x4(%eax),%edx
  8003c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ce:	eb 17                	jmp    8003e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d4:	78 98                	js     80036e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003d9:	eb a7                	jmp    800382 <vprintfmt+0x70>
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003e5:	eb 9b                	jmp    800382 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003eb:	79 95                	jns    800382 <vprintfmt+0x70>
  8003ed:	eb 8b                	jmp    80037a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f3:	eb 8d                	jmp    800382 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 50 04             	lea    0x4(%eax),%edx
  8003fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800402:	8b 00                	mov    (%eax),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040d:	e9 23 ff ff ff       	jmp    800335 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	85 c0                	test   %eax,%eax
  80041f:	79 02                	jns    800423 <vprintfmt+0x111>
  800421:	f7 d8                	neg    %eax
  800423:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800425:	83 f8 0f             	cmp    $0xf,%eax
  800428:	7f 0b                	jg     800435 <vprintfmt+0x123>
  80042a:	8b 04 85 60 22 80 00 	mov    0x802260(,%eax,4),%eax
  800431:	85 c0                	test   %eax,%eax
  800433:	75 23                	jne    800458 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800435:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800439:	c7 44 24 08 cd 1f 80 	movl   $0x801fcd,0x8(%esp)
  800440:	00 
  800441:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 9a fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800453:	e9 dd fe ff ff       	jmp    800335 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800458:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045c:	c7 44 24 08 ba 23 80 	movl   $0x8023ba,0x8(%esp)
  800463:	00 
  800464:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800468:	8b 55 08             	mov    0x8(%ebp),%edx
  80046b:	89 14 24             	mov    %edx,(%esp)
  80046e:	e8 77 fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800476:	e9 ba fe ff ff       	jmp    800335 <vprintfmt+0x23>
  80047b:	89 f9                	mov    %edi,%ecx
  80047d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800480:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 30                	mov    (%eax),%esi
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 05                	jne    800497 <vprintfmt+0x185>
				p = "(null)";
  800492:	be c6 1f 80 00       	mov    $0x801fc6,%esi
			if (width > 0 && padc != '-')
  800497:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049b:	0f 8e 84 00 00 00    	jle    800525 <vprintfmt+0x213>
  8004a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004a5:	74 7e                	je     800525 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ab:	89 34 24             	mov    %esi,(%esp)
  8004ae:	e8 8b 02 00 00       	call   80073e <strnlen>
  8004b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b6:	29 c2                	sub    %eax,%edx
  8004b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004c5:	89 de                	mov    %ebx,%esi
  8004c7:	89 d3                	mov    %edx,%ebx
  8004c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	eb 0b                	jmp    8004d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d1:	89 3c 24             	mov    %edi,(%esp)
  8004d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	4b                   	dec    %ebx
  8004d8:	85 db                	test   %ebx,%ebx
  8004da:	7f f1                	jg     8004cd <vprintfmt+0x1bb>
  8004dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004df:	89 f3                	mov    %esi,%ebx
  8004e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	79 05                	jns    8004f0 <vprintfmt+0x1de>
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f3:	29 c2                	sub    %eax,%edx
  8004f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f8:	eb 2b                	jmp    800525 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004fe:	74 18                	je     800518 <vprintfmt+0x206>
  800500:	8d 50 e0             	lea    -0x20(%eax),%edx
  800503:	83 fa 5e             	cmp    $0x5e,%edx
  800506:	76 10                	jbe    800518 <vprintfmt+0x206>
					putch('?', putdat);
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
  800516:	eb 0a                	jmp    800522 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800522:	ff 4d e4             	decl   -0x1c(%ebp)
  800525:	0f be 06             	movsbl (%esi),%eax
  800528:	46                   	inc    %esi
  800529:	85 c0                	test   %eax,%eax
  80052b:	74 21                	je     80054e <vprintfmt+0x23c>
  80052d:	85 ff                	test   %edi,%edi
  80052f:	78 c9                	js     8004fa <vprintfmt+0x1e8>
  800531:	4f                   	dec    %edi
  800532:	79 c6                	jns    8004fa <vprintfmt+0x1e8>
  800534:	8b 7d 08             	mov    0x8(%ebp),%edi
  800537:	89 de                	mov    %ebx,%esi
  800539:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053c:	eb 18                	jmp    800556 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800542:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800549:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054b:	4b                   	dec    %ebx
  80054c:	eb 08                	jmp    800556 <vprintfmt+0x244>
  80054e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800551:	89 de                	mov    %ebx,%esi
  800553:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800556:	85 db                	test   %ebx,%ebx
  800558:	7f e4                	jg     80053e <vprintfmt+0x22c>
  80055a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80055d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800562:	e9 ce fd ff ff       	jmp    800335 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 10                	jle    80057c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 08             	lea    0x8(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	8b 30                	mov    (%eax),%esi
  800577:	8b 78 04             	mov    0x4(%eax),%edi
  80057a:	eb 26                	jmp    8005a2 <vprintfmt+0x290>
	else if (lflag)
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	74 12                	je     800592 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 30                	mov    (%eax),%esi
  80058b:	89 f7                	mov    %esi,%edi
  80058d:	c1 ff 1f             	sar    $0x1f,%edi
  800590:	eb 10                	jmp    8005a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 30                	mov    (%eax),%esi
  80059d:	89 f7                	mov    %esi,%edi
  80059f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a2:	85 ff                	test   %edi,%edi
  8005a4:	78 0a                	js     8005b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 8c 00 00 00       	jmp    80063c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005be:	f7 de                	neg    %esi
  8005c0:	83 d7 00             	adc    $0x0,%edi
  8005c3:	f7 df                	neg    %edi
			}
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	eb 70                	jmp    80063c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cc:	89 ca                	mov    %ecx,%edx
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 c0 fc ff ff       	call   800296 <getuint>
  8005d6:	89 c6                	mov    %eax,%esi
  8005d8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005df:	eb 5b                	jmp    80063c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005e1:	89 ca                	mov    %ecx,%edx
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 ab fc ff ff       	call   800296 <getuint>
  8005eb:	89 c6                	mov    %eax,%esi
  8005ed:	89 d7                	mov    %edx,%edi
			base = 8;
  8005ef:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005f4:	eb 46                	jmp    80063c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800601:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061b:	8b 30                	mov    (%eax),%esi
  80061d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800622:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800627:	eb 13                	jmp    80063c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800629:	89 ca                	mov    %ecx,%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 63 fc ff ff       	call   800296 <getuint>
  800633:	89 c6                	mov    %eax,%esi
  800635:	89 d7                	mov    %edx,%edi
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800640:	89 54 24 10          	mov    %edx,0x10(%esp)
  800644:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800647:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064f:	89 34 24             	mov    %esi,(%esp)
  800652:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800656:	89 da                	mov    %ebx,%edx
  800658:	8b 45 08             	mov    0x8(%ebp),%eax
  80065b:	e8 6c fb ff ff       	call   8001cc <printnum>
			break;
  800660:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800663:	e9 cd fc ff ff       	jmp    800335 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	89 04 24             	mov    %eax,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800675:	e9 bb fc ff ff       	jmp    800335 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800685:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800688:	eb 01                	jmp    80068b <vprintfmt+0x379>
  80068a:	4e                   	dec    %esi
  80068b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068f:	75 f9                	jne    80068a <vprintfmt+0x378>
  800691:	e9 9f fc ff ff       	jmp    800335 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800696:	83 c4 4c             	add    $0x4c,%esp
  800699:	5b                   	pop    %ebx
  80069a:	5e                   	pop    %esi
  80069b:	5f                   	pop    %edi
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 28             	sub    $0x28,%esp
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	74 30                	je     8006ef <vsnprintf+0x51>
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	7e 33                	jle    8006f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	c7 04 24 d0 02 80 00 	movl   $0x8002d0,(%esp)
  8006df:	e8 2e fc ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ed:	eb 0c                	jmp    8006fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f4:	eb 05                	jmp    8006fb <vsnprintf+0x5d>
  8006f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800706:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070a:	8b 45 10             	mov    0x10(%ebp),%eax
  80070d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	e8 7b ff ff ff       	call   80069e <vsnprintf>
	va_end(ap);

	return rc;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    
  800725:	00 00                	add    %al,(%eax)
	...

00800728 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
  800733:	eb 01                	jmp    800736 <strlen+0xe>
		n++;
  800735:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073a:	75 f9                	jne    800735 <strlen+0xd>
		n++;
	return n;
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 01                	jmp    80074f <strnlen+0x11>
		n++;
  80074e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	39 d0                	cmp    %edx,%eax
  800751:	74 06                	je     800759 <strnlen+0x1b>
  800753:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800757:	75 f5                	jne    80074e <strnlen+0x10>
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
  80076a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80076d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800770:	42                   	inc    %edx
  800771:	84 c9                	test   %cl,%cl
  800773:	75 f5                	jne    80076a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800775:	5b                   	pop    %ebx
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800782:	89 1c 24             	mov    %ebx,(%esp)
  800785:	e8 9e ff ff ff       	call   800728 <strlen>
	strcpy(dst + len, src);
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800791:	01 d8                	add    %ebx,%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	e8 c0 ff ff ff       	call   80075b <strcpy>
	return dst;
}
  80079b:	89 d8                	mov    %ebx,%eax
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	5b                   	pop    %ebx
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	56                   	push   %esi
  8007a7:	53                   	push   %ebx
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	eb 0c                	jmp    8007c4 <strncpy+0x21>
		*dst++ = *src;
  8007b8:	8a 1a                	mov    (%edx),%bl
  8007ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c3:	41                   	inc    %ecx
  8007c4:	39 f1                	cmp    %esi,%ecx
  8007c6:	75 f0                	jne    8007b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	75 0a                	jne    8007e8 <strlcpy+0x1c>
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	eb 1a                	jmp    8007fc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e2:	88 18                	mov    %bl,(%eax)
  8007e4:	40                   	inc    %eax
  8007e5:	41                   	inc    %ecx
  8007e6:	eb 02                	jmp    8007ea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ea:	4a                   	dec    %edx
  8007eb:	74 0a                	je     8007f7 <strlcpy+0x2b>
  8007ed:	8a 19                	mov    (%ecx),%bl
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 ef                	jne    8007e2 <strlcpy+0x16>
  8007f3:	89 c2                	mov    %eax,%edx
  8007f5:	eb 02                	jmp    8007f9 <strlcpy+0x2d>
  8007f7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007f9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007fc:	29 f0                	sub    %esi,%eax
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080b:	eb 02                	jmp    80080f <strcmp+0xd>
		p++, q++;
  80080d:	41                   	inc    %ecx
  80080e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080f:	8a 01                	mov    (%ecx),%al
  800811:	84 c0                	test   %al,%al
  800813:	74 04                	je     800819 <strcmp+0x17>
  800815:	3a 02                	cmp    (%edx),%al
  800817:	74 f4                	je     80080d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800819:	0f b6 c0             	movzbl %al,%eax
  80081c:	0f b6 12             	movzbl (%edx),%edx
  80081f:	29 d0                	sub    %edx,%eax
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800830:	eb 03                	jmp    800835 <strncmp+0x12>
		n--, p++, q++;
  800832:	4a                   	dec    %edx
  800833:	40                   	inc    %eax
  800834:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800835:	85 d2                	test   %edx,%edx
  800837:	74 14                	je     80084d <strncmp+0x2a>
  800839:	8a 18                	mov    (%eax),%bl
  80083b:	84 db                	test   %bl,%bl
  80083d:	74 04                	je     800843 <strncmp+0x20>
  80083f:	3a 19                	cmp    (%ecx),%bl
  800841:	74 ef                	je     800832 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 00             	movzbl (%eax),%eax
  800846:	0f b6 11             	movzbl (%ecx),%edx
  800849:	29 d0                	sub    %edx,%eax
  80084b:	eb 05                	jmp    800852 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085e:	eb 05                	jmp    800865 <strchr+0x10>
		if (*s == c)
  800860:	38 ca                	cmp    %cl,%dl
  800862:	74 0c                	je     800870 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800864:	40                   	inc    %eax
  800865:	8a 10                	mov    (%eax),%dl
  800867:	84 d2                	test   %dl,%dl
  800869:	75 f5                	jne    800860 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087b:	eb 05                	jmp    800882 <strfind+0x10>
		if (*s == c)
  80087d:	38 ca                	cmp    %cl,%dl
  80087f:	74 07                	je     800888 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800881:	40                   	inc    %eax
  800882:	8a 10                	mov    (%eax),%dl
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f5                	jne    80087d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 7d 08             	mov    0x8(%ebp),%edi
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
  800896:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800899:	85 c9                	test   %ecx,%ecx
  80089b:	74 30                	je     8008cd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a3:	75 25                	jne    8008ca <memset+0x40>
  8008a5:	f6 c1 03             	test   $0x3,%cl
  8008a8:	75 20                	jne    8008ca <memset+0x40>
		c &= 0xFF;
  8008aa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ad:	89 d3                	mov    %edx,%ebx
  8008af:	c1 e3 08             	shl    $0x8,%ebx
  8008b2:	89 d6                	mov    %edx,%esi
  8008b4:	c1 e6 18             	shl    $0x18,%esi
  8008b7:	89 d0                	mov    %edx,%eax
  8008b9:	c1 e0 10             	shl    $0x10,%eax
  8008bc:	09 f0                	or     %esi,%eax
  8008be:	09 d0                	or     %edx,%eax
  8008c0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 03                	jmp    8008cd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	fc                   	cld    
  8008cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008cd:	89 f8                	mov    %edi,%eax
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e2:	39 c6                	cmp    %eax,%esi
  8008e4:	73 34                	jae    80091a <memmove+0x46>
  8008e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e9:	39 d0                	cmp    %edx,%eax
  8008eb:	73 2d                	jae    80091a <memmove+0x46>
		s += n;
		d += n;
  8008ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	f6 c2 03             	test   $0x3,%dl
  8008f3:	75 1b                	jne    800910 <memmove+0x3c>
  8008f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fb:	75 13                	jne    800910 <memmove+0x3c>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 0e                	jne    800910 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800902:	83 ef 04             	sub    $0x4,%edi
  800905:	8d 72 fc             	lea    -0x4(%edx),%esi
  800908:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80090b:	fd                   	std    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 07                	jmp    800917 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800910:	4f                   	dec    %edi
  800911:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800914:	fd                   	std    
  800915:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800917:	fc                   	cld    
  800918:	eb 20                	jmp    80093a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800920:	75 13                	jne    800935 <memmove+0x61>
  800922:	a8 03                	test   $0x3,%al
  800924:	75 0f                	jne    800935 <memmove+0x61>
  800926:	f6 c1 03             	test   $0x3,%cl
  800929:	75 0a                	jne    800935 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80092b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800933:	eb 05                	jmp    80093a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800935:	89 c7                	mov    %eax,%edi
  800937:	fc                   	cld    
  800938:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800944:	8b 45 10             	mov    0x10(%ebp),%eax
  800947:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	e8 77 ff ff ff       	call   8008d4 <memmove>
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 7d 08             	mov    0x8(%ebp),%edi
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	eb 16                	jmp    80098b <memcmp+0x2c>
		if (*s1 != *s2)
  800975:	8a 04 17             	mov    (%edi,%edx,1),%al
  800978:	42                   	inc    %edx
  800979:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80097d:	38 c8                	cmp    %cl,%al
  80097f:	74 0a                	je     80098b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800981:	0f b6 c0             	movzbl %al,%eax
  800984:	0f b6 c9             	movzbl %cl,%ecx
  800987:	29 c8                	sub    %ecx,%eax
  800989:	eb 09                	jmp    800994 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	75 e6                	jne    800975 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a7:	eb 05                	jmp    8009ae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	38 08                	cmp    %cl,(%eax)
  8009ab:	74 05                	je     8009b2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ad:	40                   	inc    %eax
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	72 f7                	jb     8009a9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c0:	eb 01                	jmp    8009c3 <strtol+0xf>
		s++;
  8009c2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c3:	8a 02                	mov    (%edx),%al
  8009c5:	3c 20                	cmp    $0x20,%al
  8009c7:	74 f9                	je     8009c2 <strtol+0xe>
  8009c9:	3c 09                	cmp    $0x9,%al
  8009cb:	74 f5                	je     8009c2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009cd:	3c 2b                	cmp    $0x2b,%al
  8009cf:	75 08                	jne    8009d9 <strtol+0x25>
		s++;
  8009d1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d7:	eb 13                	jmp    8009ec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d9:	3c 2d                	cmp    $0x2d,%al
  8009db:	75 0a                	jne    8009e7 <strtol+0x33>
		s++, neg = 1;
  8009dd:	8d 52 01             	lea    0x1(%edx),%edx
  8009e0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e5:	eb 05                	jmp    8009ec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ec:	85 db                	test   %ebx,%ebx
  8009ee:	74 05                	je     8009f5 <strtol+0x41>
  8009f0:	83 fb 10             	cmp    $0x10,%ebx
  8009f3:	75 28                	jne    800a1d <strtol+0x69>
  8009f5:	8a 02                	mov    (%edx),%al
  8009f7:	3c 30                	cmp    $0x30,%al
  8009f9:	75 10                	jne    800a0b <strtol+0x57>
  8009fb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ff:	75 0a                	jne    800a0b <strtol+0x57>
		s += 2, base = 16;
  800a01:	83 c2 02             	add    $0x2,%edx
  800a04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a09:	eb 12                	jmp    800a1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a0b:	85 db                	test   %ebx,%ebx
  800a0d:	75 0e                	jne    800a1d <strtol+0x69>
  800a0f:	3c 30                	cmp    $0x30,%al
  800a11:	75 05                	jne    800a18 <strtol+0x64>
		s++, base = 8;
  800a13:	42                   	inc    %edx
  800a14:	b3 08                	mov    $0x8,%bl
  800a16:	eb 05                	jmp    800a1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a24:	8a 0a                	mov    (%edx),%cl
  800a26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a29:	80 fb 09             	cmp    $0x9,%bl
  800a2c:	77 08                	ja     800a36 <strtol+0x82>
			dig = *s - '0';
  800a2e:	0f be c9             	movsbl %cl,%ecx
  800a31:	83 e9 30             	sub    $0x30,%ecx
  800a34:	eb 1e                	jmp    800a54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a39:	80 fb 19             	cmp    $0x19,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a3e:	0f be c9             	movsbl %cl,%ecx
  800a41:	83 e9 57             	sub    $0x57,%ecx
  800a44:	eb 0e                	jmp    800a54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 12                	ja     800a60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a4e:	0f be c9             	movsbl %cl,%ecx
  800a51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a54:	39 f1                	cmp    %esi,%ecx
  800a56:	7d 0c                	jge    800a64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a58:	42                   	inc    %edx
  800a59:	0f af c6             	imul   %esi,%eax
  800a5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a5e:	eb c4                	jmp    800a24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a60:	89 c1                	mov    %eax,%ecx
  800a62:	eb 02                	jmp    800a66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 05                	je     800a71 <strtol+0xbd>
		*endptr = (char *) s;
  800a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a71:	85 ff                	test   %edi,%edi
  800a73:	74 04                	je     800a79 <strtol+0xc5>
  800a75:	89 c8                	mov    %ecx,%eax
  800a77:	f7 d8                	neg    %eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    
	...

00800a80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 cb                	mov    %ecx,%ebx
  800ad5:	89 cf                	mov    %ecx,%edi
  800ad7:	89 ce                	mov    %ecx,%esi
  800ad9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 28                	jle    800b07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ae3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aea:	00 
  800aeb:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800af2:	00 
  800af3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800afa:	00 
  800afb:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800b02:	e8 29 10 00 00       	call   801b30 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b07:	83 c4 2c             	add    $0x2c,%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1f:	89 d1                	mov    %edx,%ecx
  800b21:	89 d3                	mov    %edx,%ebx
  800b23:	89 d7                	mov    %edx,%edi
  800b25:	89 d6                	mov    %edx,%esi
  800b27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <sys_yield>:

void
sys_yield(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b3e:	89 d1                	mov    %edx,%ecx
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	89 d7                	mov    %edx,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	be 00 00 00 00       	mov    $0x0,%esi
  800b5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 f7                	mov    %esi,%edi
  800b6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7e 28                	jle    800b99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b7c:	00 
  800b7d:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800b84:	00 
  800b85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8c:	00 
  800b8d:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800b94:	e8 97 0f 00 00       	call   801b30 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b99:	83 c4 2c             	add    $0x2c,%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b8 05 00 00 00       	mov    $0x5,%eax
  800baf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 28                	jle    800bec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bcf:	00 
  800bd0:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bdf:	00 
  800be0:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800be7:	e8 44 0f 00 00       	call   801b30 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bec:	83 c4 2c             	add    $0x2c,%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c02:	b8 06 00 00 00       	mov    $0x6,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 df                	mov    %ebx,%edi
  800c0f:	89 de                	mov    %ebx,%esi
  800c11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 28                	jle    800c3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c22:	00 
  800c23:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c32:	00 
  800c33:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800c3a:	e8 f1 0e 00 00       	call   801b30 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3f:	83 c4 2c             	add    $0x2c,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 28                	jle    800c92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c75:	00 
  800c76:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800c7d:	00 
  800c7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c85:	00 
  800c86:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800c8d:	e8 9e 0e 00 00       	call   801b30 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c92:	83 c4 2c             	add    $0x2c,%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 28                	jle    800ce5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd8:	00 
  800cd9:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800ce0:	e8 4b 0e 00 00       	call   801b30 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce5:	83 c4 2c             	add    $0x2c,%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	89 df                	mov    %ebx,%edi
  800d08:	89 de                	mov    %ebx,%esi
  800d0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7e 28                	jle    800d38 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d14:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d1b:	00 
  800d1c:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800d23:	00 
  800d24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2b:	00 
  800d2c:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800d33:	e8 f8 0d 00 00       	call   801b30 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d38:	83 c4 2c             	add    $0x2c,%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	be 00 00 00 00       	mov    $0x0,%esi
  800d4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 cb                	mov    %ecx,%ebx
  800d7b:	89 cf                	mov    %ecx,%edi
  800d7d:	89 ce                	mov    %ecx,%esi
  800d7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 28                	jle    800dad <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 bf 22 80 	movl   $0x8022bf,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  800da8:	e8 83 0d 00 00       	call   801b30 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dad:	83 c4 2c             	add    $0x2c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
  800db5:	00 00                	add    %al,(%eax)
	...

00800db8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc3:	c1 e8 0c             	shr    $0xc,%eax
}
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	89 04 24             	mov    %eax,(%esp)
  800dd4:	e8 df ff ff ff       	call   800db8 <fd2num>
  800dd9:	05 20 00 0d 00       	add    $0xd0020,%eax
  800dde:	c1 e0 0c             	shl    $0xc,%eax
}
  800de1:	c9                   	leave  
  800de2:	c3                   	ret    

00800de3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	53                   	push   %ebx
  800de7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800def:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	c1 ea 16             	shr    $0x16,%edx
  800df6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dfd:	f6 c2 01             	test   $0x1,%dl
  800e00:	74 11                	je     800e13 <fd_alloc+0x30>
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	c1 ea 0c             	shr    $0xc,%edx
  800e07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0e:	f6 c2 01             	test   $0x1,%dl
  800e11:	75 09                	jne    800e1c <fd_alloc+0x39>
			*fd_store = fd;
  800e13:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e15:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1a:	eb 17                	jmp    800e33 <fd_alloc+0x50>
  800e1c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e21:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e26:	75 c7                	jne    800def <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e28:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e2e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e33:	5b                   	pop    %ebx
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e3c:	83 f8 1f             	cmp    $0x1f,%eax
  800e3f:	77 36                	ja     800e77 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e41:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e46:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e49:	89 c2                	mov    %eax,%edx
  800e4b:	c1 ea 16             	shr    $0x16,%edx
  800e4e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e55:	f6 c2 01             	test   $0x1,%dl
  800e58:	74 24                	je     800e7e <fd_lookup+0x48>
  800e5a:	89 c2                	mov    %eax,%edx
  800e5c:	c1 ea 0c             	shr    $0xc,%edx
  800e5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e66:	f6 c2 01             	test   $0x1,%dl
  800e69:	74 1a                	je     800e85 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
  800e75:	eb 13                	jmp    800e8a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7c:	eb 0c                	jmp    800e8a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e83:	eb 05                	jmp    800e8a <fd_lookup+0x54>
  800e85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	53                   	push   %ebx
  800e90:	83 ec 14             	sub    $0x14,%esp
  800e93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e99:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9e:	eb 0e                	jmp    800eae <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800ea0:	39 08                	cmp    %ecx,(%eax)
  800ea2:	75 09                	jne    800ead <dev_lookup+0x21>
			*dev = devtab[i];
  800ea4:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eab:	eb 33                	jmp    800ee0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ead:	42                   	inc    %edx
  800eae:	8b 04 95 68 23 80 00 	mov    0x802368(,%edx,4),%eax
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	75 e7                	jne    800ea0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eb9:	a1 04 40 80 00       	mov    0x804004,%eax
  800ebe:	8b 40 48             	mov    0x48(%eax),%eax
  800ec1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec9:	c7 04 24 ec 22 80 00 	movl   $0x8022ec,(%esp)
  800ed0:	e8 db f2 ff ff       	call   8001b0 <cprintf>
	*dev = 0;
  800ed5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800edb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee0:	83 c4 14             	add    $0x14,%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 30             	sub    $0x30,%esp
  800eee:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef1:	8a 45 0c             	mov    0xc(%ebp),%al
  800ef4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef7:	89 34 24             	mov    %esi,(%esp)
  800efa:	e8 b9 fe ff ff       	call   800db8 <fd2num>
  800eff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f02:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f06:	89 04 24             	mov    %eax,(%esp)
  800f09:	e8 28 ff ff ff       	call   800e36 <fd_lookup>
  800f0e:	89 c3                	mov    %eax,%ebx
  800f10:	85 c0                	test   %eax,%eax
  800f12:	78 05                	js     800f19 <fd_close+0x33>
	    || fd != fd2)
  800f14:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f17:	74 0d                	je     800f26 <fd_close+0x40>
		return (must_exist ? r : 0);
  800f19:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f1d:	75 46                	jne    800f65 <fd_close+0x7f>
  800f1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f24:	eb 3f                	jmp    800f65 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2d:	8b 06                	mov    (%esi),%eax
  800f2f:	89 04 24             	mov    %eax,(%esp)
  800f32:	e8 55 ff ff ff       	call   800e8c <dev_lookup>
  800f37:	89 c3                	mov    %eax,%ebx
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 18                	js     800f55 <fd_close+0x6f>
		if (dev->dev_close)
  800f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f40:	8b 40 10             	mov    0x10(%eax),%eax
  800f43:	85 c0                	test   %eax,%eax
  800f45:	74 09                	je     800f50 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f47:	89 34 24             	mov    %esi,(%esp)
  800f4a:	ff d0                	call   *%eax
  800f4c:	89 c3                	mov    %eax,%ebx
  800f4e:	eb 05                	jmp    800f55 <fd_close+0x6f>
		else
			r = 0;
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f55:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f60:	e8 8f fc ff ff       	call   800bf4 <sys_page_unmap>
	return r;
}
  800f65:	89 d8                	mov    %ebx,%eax
  800f67:	83 c4 30             	add    $0x30,%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	89 04 24             	mov    %eax,(%esp)
  800f81:	e8 b0 fe ff ff       	call   800e36 <fd_lookup>
  800f86:	85 c0                	test   %eax,%eax
  800f88:	78 13                	js     800f9d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f91:	00 
  800f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f95:	89 04 24             	mov    %eax,(%esp)
  800f98:	e8 49 ff ff ff       	call   800ee6 <fd_close>
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <close_all>:

void
close_all(void)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fab:	89 1c 24             	mov    %ebx,(%esp)
  800fae:	e8 bb ff ff ff       	call   800f6e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb3:	43                   	inc    %ebx
  800fb4:	83 fb 20             	cmp    $0x20,%ebx
  800fb7:	75 f2                	jne    800fab <close_all+0xc>
		close(i);
}
  800fb9:	83 c4 14             	add    $0x14,%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 4c             	sub    $0x4c,%esp
  800fc8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fcb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	e8 59 fe ff ff       	call   800e36 <fd_lookup>
  800fdd:	89 c3                	mov    %eax,%ebx
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	0f 88 e1 00 00 00    	js     8010c8 <dup+0x109>
		return r;
	close(newfdnum);
  800fe7:	89 3c 24             	mov    %edi,(%esp)
  800fea:	e8 7f ff ff ff       	call   800f6e <close>

	newfd = INDEX2FD(newfdnum);
  800fef:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800ff5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800ff8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ffb:	89 04 24             	mov    %eax,(%esp)
  800ffe:	e8 c5 fd ff ff       	call   800dc8 <fd2data>
  801003:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801005:	89 34 24             	mov    %esi,(%esp)
  801008:	e8 bb fd ff ff       	call   800dc8 <fd2data>
  80100d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801010:	89 d8                	mov    %ebx,%eax
  801012:	c1 e8 16             	shr    $0x16,%eax
  801015:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101c:	a8 01                	test   $0x1,%al
  80101e:	74 46                	je     801066 <dup+0xa7>
  801020:	89 d8                	mov    %ebx,%eax
  801022:	c1 e8 0c             	shr    $0xc,%eax
  801025:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102c:	f6 c2 01             	test   $0x1,%dl
  80102f:	74 35                	je     801066 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801031:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801038:	25 07 0e 00 00       	and    $0xe07,%eax
  80103d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801041:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801048:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80104f:	00 
  801050:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801054:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80105b:	e8 41 fb ff ff       	call   800ba1 <sys_page_map>
  801060:	89 c3                	mov    %eax,%ebx
  801062:	85 c0                	test   %eax,%eax
  801064:	78 3b                	js     8010a1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801069:	89 c2                	mov    %eax,%edx
  80106b:	c1 ea 0c             	shr    $0xc,%edx
  80106e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801075:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80107b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80107f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801083:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80108a:	00 
  80108b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801096:	e8 06 fb ff ff       	call   800ba1 <sys_page_map>
  80109b:	89 c3                	mov    %eax,%ebx
  80109d:	85 c0                	test   %eax,%eax
  80109f:	79 25                	jns    8010c6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ac:	e8 43 fb ff ff       	call   800bf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010bf:	e8 30 fb ff ff       	call   800bf4 <sys_page_unmap>
	return r;
  8010c4:	eb 02                	jmp    8010c8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010c6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010c8:	89 d8                	mov    %ebx,%eax
  8010ca:	83 c4 4c             	add    $0x4c,%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	53                   	push   %ebx
  8010d6:	83 ec 24             	sub    $0x24,%esp
  8010d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e3:	89 1c 24             	mov    %ebx,(%esp)
  8010e6:	e8 4b fd ff ff       	call   800e36 <fd_lookup>
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 6d                	js     80115c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f9:	8b 00                	mov    (%eax),%eax
  8010fb:	89 04 24             	mov    %eax,(%esp)
  8010fe:	e8 89 fd ff ff       	call   800e8c <dev_lookup>
  801103:	85 c0                	test   %eax,%eax
  801105:	78 55                	js     80115c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801107:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110a:	8b 50 08             	mov    0x8(%eax),%edx
  80110d:	83 e2 03             	and    $0x3,%edx
  801110:	83 fa 01             	cmp    $0x1,%edx
  801113:	75 23                	jne    801138 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801115:	a1 04 40 80 00       	mov    0x804004,%eax
  80111a:	8b 40 48             	mov    0x48(%eax),%eax
  80111d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801121:	89 44 24 04          	mov    %eax,0x4(%esp)
  801125:	c7 04 24 2d 23 80 00 	movl   $0x80232d,(%esp)
  80112c:	e8 7f f0 ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801131:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801136:	eb 24                	jmp    80115c <read+0x8a>
	}
	if (!dev->dev_read)
  801138:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80113b:	8b 52 08             	mov    0x8(%edx),%edx
  80113e:	85 d2                	test   %edx,%edx
  801140:	74 15                	je     801157 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801142:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801145:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801149:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801150:	89 04 24             	mov    %eax,(%esp)
  801153:	ff d2                	call   *%edx
  801155:	eb 05                	jmp    80115c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801157:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80115c:	83 c4 24             	add    $0x24,%esp
  80115f:	5b                   	pop    %ebx
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	57                   	push   %edi
  801166:	56                   	push   %esi
  801167:	53                   	push   %ebx
  801168:	83 ec 1c             	sub    $0x1c,%esp
  80116b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80116e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801171:	bb 00 00 00 00       	mov    $0x0,%ebx
  801176:	eb 23                	jmp    80119b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801178:	89 f0                	mov    %esi,%eax
  80117a:	29 d8                	sub    %ebx,%eax
  80117c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801180:	8b 45 0c             	mov    0xc(%ebp),%eax
  801183:	01 d8                	add    %ebx,%eax
  801185:	89 44 24 04          	mov    %eax,0x4(%esp)
  801189:	89 3c 24             	mov    %edi,(%esp)
  80118c:	e8 41 ff ff ff       	call   8010d2 <read>
		if (m < 0)
  801191:	85 c0                	test   %eax,%eax
  801193:	78 10                	js     8011a5 <readn+0x43>
			return m;
		if (m == 0)
  801195:	85 c0                	test   %eax,%eax
  801197:	74 0a                	je     8011a3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801199:	01 c3                	add    %eax,%ebx
  80119b:	39 f3                	cmp    %esi,%ebx
  80119d:	72 d9                	jb     801178 <readn+0x16>
  80119f:	89 d8                	mov    %ebx,%eax
  8011a1:	eb 02                	jmp    8011a5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011a3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011a5:	83 c4 1c             	add    $0x1c,%esp
  8011a8:	5b                   	pop    %ebx
  8011a9:	5e                   	pop    %esi
  8011aa:	5f                   	pop    %edi
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	53                   	push   %ebx
  8011b1:	83 ec 24             	sub    $0x24,%esp
  8011b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011be:	89 1c 24             	mov    %ebx,(%esp)
  8011c1:	e8 70 fc ff ff       	call   800e36 <fd_lookup>
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 68                	js     801232 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d4:	8b 00                	mov    (%eax),%eax
  8011d6:	89 04 24             	mov    %eax,(%esp)
  8011d9:	e8 ae fc ff ff       	call   800e8c <dev_lookup>
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 50                	js     801232 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e9:	75 23                	jne    80120e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f0:	8b 40 48             	mov    0x48(%eax),%eax
  8011f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fb:	c7 04 24 49 23 80 00 	movl   $0x802349,(%esp)
  801202:	e8 a9 ef ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801207:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120c:	eb 24                	jmp    801232 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80120e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801211:	8b 52 0c             	mov    0xc(%edx),%edx
  801214:	85 d2                	test   %edx,%edx
  801216:	74 15                	je     80122d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801218:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80121b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80121f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801222:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801226:	89 04 24             	mov    %eax,(%esp)
  801229:	ff d2                	call   *%edx
  80122b:	eb 05                	jmp    801232 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80122d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801232:	83 c4 24             	add    $0x24,%esp
  801235:	5b                   	pop    %ebx
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <seek>:

int
seek(int fdnum, off_t offset)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801241:	89 44 24 04          	mov    %eax,0x4(%esp)
  801245:	8b 45 08             	mov    0x8(%ebp),%eax
  801248:	89 04 24             	mov    %eax,(%esp)
  80124b:	e8 e6 fb ff ff       	call   800e36 <fd_lookup>
  801250:	85 c0                	test   %eax,%eax
  801252:	78 0e                	js     801262 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801254:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80125d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 24             	sub    $0x24,%esp
  80126b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801271:	89 44 24 04          	mov    %eax,0x4(%esp)
  801275:	89 1c 24             	mov    %ebx,(%esp)
  801278:	e8 b9 fb ff ff       	call   800e36 <fd_lookup>
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 61                	js     8012e2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801284:	89 44 24 04          	mov    %eax,0x4(%esp)
  801288:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128b:	8b 00                	mov    (%eax),%eax
  80128d:	89 04 24             	mov    %eax,(%esp)
  801290:	e8 f7 fb ff ff       	call   800e8c <dev_lookup>
  801295:	85 c0                	test   %eax,%eax
  801297:	78 49                	js     8012e2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a0:	75 23                	jne    8012c5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a7:	8b 40 48             	mov    0x48(%eax),%eax
  8012aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b2:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  8012b9:	e8 f2 ee ff ff       	call   8001b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c3:	eb 1d                	jmp    8012e2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8012c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c8:	8b 52 18             	mov    0x18(%edx),%edx
  8012cb:	85 d2                	test   %edx,%edx
  8012cd:	74 0e                	je     8012dd <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012d6:	89 04 24             	mov    %eax,(%esp)
  8012d9:	ff d2                	call   *%edx
  8012db:	eb 05                	jmp    8012e2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e2:	83 c4 24             	add    $0x24,%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	53                   	push   %ebx
  8012ec:	83 ec 24             	sub    $0x24,%esp
  8012ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fc:	89 04 24             	mov    %eax,(%esp)
  8012ff:	e8 32 fb ff ff       	call   800e36 <fd_lookup>
  801304:	85 c0                	test   %eax,%eax
  801306:	78 52                	js     80135a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801312:	8b 00                	mov    (%eax),%eax
  801314:	89 04 24             	mov    %eax,(%esp)
  801317:	e8 70 fb ff ff       	call   800e8c <dev_lookup>
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 3a                	js     80135a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801320:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801323:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801327:	74 2c                	je     801355 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801329:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80132c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801333:	00 00 00 
	stat->st_isdir = 0;
  801336:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80133d:	00 00 00 
	stat->st_dev = dev;
  801340:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801346:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80134a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80134d:	89 14 24             	mov    %edx,(%esp)
  801350:	ff 50 14             	call   *0x14(%eax)
  801353:	eb 05                	jmp    80135a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801355:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80135a:	83 c4 24             	add    $0x24,%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
  801365:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801368:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80136f:	00 
  801370:	8b 45 08             	mov    0x8(%ebp),%eax
  801373:	89 04 24             	mov    %eax,(%esp)
  801376:	e8 fe 01 00 00       	call   801579 <open>
  80137b:	89 c3                	mov    %eax,%ebx
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 1b                	js     80139c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801381:	8b 45 0c             	mov    0xc(%ebp),%eax
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	89 1c 24             	mov    %ebx,(%esp)
  80138b:	e8 58 ff ff ff       	call   8012e8 <fstat>
  801390:	89 c6                	mov    %eax,%esi
	close(fd);
  801392:	89 1c 24             	mov    %ebx,(%esp)
  801395:	e8 d4 fb ff ff       	call   800f6e <close>
	return r;
  80139a:	89 f3                	mov    %esi,%ebx
}
  80139c:	89 d8                	mov    %ebx,%eax
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    
  8013a5:	00 00                	add    %al,(%eax)
	...

008013a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	56                   	push   %esi
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 10             	sub    $0x10,%esp
  8013b0:	89 c3                	mov    %eax,%ebx
  8013b2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013b4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013bb:	75 11                	jne    8013ce <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013c4:	e8 92 08 00 00       	call   801c5b <ipc_find_env>
  8013c9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ce:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013d5:	00 
  8013d6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013dd:	00 
  8013de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e2:	a1 00 40 80 00       	mov    0x804000,%eax
  8013e7:	89 04 24             	mov    %eax,(%esp)
  8013ea:	e8 02 08 00 00       	call   801bf1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013f6:	00 
  8013f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801402:	e8 81 07 00 00       	call   801b88 <ipc_recv>
}
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801414:	8b 45 08             	mov    0x8(%ebp),%eax
  801417:	8b 40 0c             	mov    0xc(%eax),%eax
  80141a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80141f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801422:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801427:	ba 00 00 00 00       	mov    $0x0,%edx
  80142c:	b8 02 00 00 00       	mov    $0x2,%eax
  801431:	e8 72 ff ff ff       	call   8013a8 <fsipc>
}
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80143e:	8b 45 08             	mov    0x8(%ebp),%eax
  801441:	8b 40 0c             	mov    0xc(%eax),%eax
  801444:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801449:	ba 00 00 00 00       	mov    $0x0,%edx
  80144e:	b8 06 00 00 00       	mov    $0x6,%eax
  801453:	e8 50 ff ff ff       	call   8013a8 <fsipc>
}
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 14             	sub    $0x14,%esp
  801461:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801464:	8b 45 08             	mov    0x8(%ebp),%eax
  801467:	8b 40 0c             	mov    0xc(%eax),%eax
  80146a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80146f:	ba 00 00 00 00       	mov    $0x0,%edx
  801474:	b8 05 00 00 00       	mov    $0x5,%eax
  801479:	e8 2a ff ff ff       	call   8013a8 <fsipc>
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 2b                	js     8014ad <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801482:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801489:	00 
  80148a:	89 1c 24             	mov    %ebx,(%esp)
  80148d:	e8 c9 f2 ff ff       	call   80075b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801492:	a1 80 50 80 00       	mov    0x805080,%eax
  801497:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80149d:	a1 84 50 80 00       	mov    0x805084,%eax
  8014a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ad:	83 c4 14             	add    $0x14,%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8014b9:	c7 44 24 08 78 23 80 	movl   $0x802378,0x8(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8014c8:	00 
  8014c9:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  8014d0:	e8 5b 06 00 00       	call   801b30 <_panic>

008014d5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	56                   	push   %esi
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 10             	sub    $0x10,%esp
  8014dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fb:	e8 a8 fe ff ff       	call   8013a8 <fsipc>
  801500:	89 c3                	mov    %eax,%ebx
  801502:	85 c0                	test   %eax,%eax
  801504:	78 6a                	js     801570 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801506:	39 c6                	cmp    %eax,%esi
  801508:	73 24                	jae    80152e <devfile_read+0x59>
  80150a:	c7 44 24 0c a1 23 80 	movl   $0x8023a1,0xc(%esp)
  801511:	00 
  801512:	c7 44 24 08 a8 23 80 	movl   $0x8023a8,0x8(%esp)
  801519:	00 
  80151a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801521:	00 
  801522:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  801529:	e8 02 06 00 00       	call   801b30 <_panic>
	assert(r <= PGSIZE);
  80152e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801533:	7e 24                	jle    801559 <devfile_read+0x84>
  801535:	c7 44 24 0c bd 23 80 	movl   $0x8023bd,0xc(%esp)
  80153c:	00 
  80153d:	c7 44 24 08 a8 23 80 	movl   $0x8023a8,0x8(%esp)
  801544:	00 
  801545:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80154c:	00 
  80154d:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  801554:	e8 d7 05 00 00       	call   801b30 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801559:	89 44 24 08          	mov    %eax,0x8(%esp)
  80155d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801564:	00 
  801565:	8b 45 0c             	mov    0xc(%ebp),%eax
  801568:	89 04 24             	mov    %eax,(%esp)
  80156b:	e8 64 f3 ff ff       	call   8008d4 <memmove>
	return r;
}
  801570:	89 d8                	mov    %ebx,%eax
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	5b                   	pop    %ebx
  801576:	5e                   	pop    %esi
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	56                   	push   %esi
  80157d:	53                   	push   %ebx
  80157e:	83 ec 20             	sub    $0x20,%esp
  801581:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801584:	89 34 24             	mov    %esi,(%esp)
  801587:	e8 9c f1 ff ff       	call   800728 <strlen>
  80158c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801591:	7f 60                	jg     8015f3 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801593:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801596:	89 04 24             	mov    %eax,(%esp)
  801599:	e8 45 f8 ff ff       	call   800de3 <fd_alloc>
  80159e:	89 c3                	mov    %eax,%ebx
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 54                	js     8015f8 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015a8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015af:	e8 a7 f1 ff ff       	call   80075b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c4:	e8 df fd ff ff       	call   8013a8 <fsipc>
  8015c9:	89 c3                	mov    %eax,%ebx
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	79 15                	jns    8015e4 <open+0x6b>
		fd_close(fd, 0);
  8015cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015d6:	00 
  8015d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015da:	89 04 24             	mov    %eax,(%esp)
  8015dd:	e8 04 f9 ff ff       	call   800ee6 <fd_close>
		return r;
  8015e2:	eb 14                	jmp    8015f8 <open+0x7f>
	}

	return fd2num(fd);
  8015e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e7:	89 04 24             	mov    %eax,(%esp)
  8015ea:	e8 c9 f7 ff ff       	call   800db8 <fd2num>
  8015ef:	89 c3                	mov    %eax,%ebx
  8015f1:	eb 05                	jmp    8015f8 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015f8:	89 d8                	mov    %ebx,%eax
  8015fa:	83 c4 20             	add    $0x20,%esp
  8015fd:	5b                   	pop    %ebx
  8015fe:	5e                   	pop    %esi
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801607:	ba 00 00 00 00       	mov    $0x0,%edx
  80160c:	b8 08 00 00 00       	mov    $0x8,%eax
  801611:	e8 92 fd ff ff       	call   8013a8 <fsipc>
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	83 ec 10             	sub    $0x10,%esp
  801620:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	89 04 24             	mov    %eax,(%esp)
  801629:	e8 9a f7 ff ff       	call   800dc8 <fd2data>
  80162e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801630:	c7 44 24 04 c9 23 80 	movl   $0x8023c9,0x4(%esp)
  801637:	00 
  801638:	89 34 24             	mov    %esi,(%esp)
  80163b:	e8 1b f1 ff ff       	call   80075b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801640:	8b 43 04             	mov    0x4(%ebx),%eax
  801643:	2b 03                	sub    (%ebx),%eax
  801645:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80164b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801652:	00 00 00 
	stat->st_dev = &devpipe;
  801655:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80165c:	30 80 00 
	return 0;
}
  80165f:	b8 00 00 00 00       	mov    $0x0,%eax
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    

0080166b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	53                   	push   %ebx
  80166f:	83 ec 14             	sub    $0x14,%esp
  801672:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801675:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801679:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801680:	e8 6f f5 ff ff       	call   800bf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801685:	89 1c 24             	mov    %ebx,(%esp)
  801688:	e8 3b f7 ff ff       	call   800dc8 <fd2data>
  80168d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801691:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801698:	e8 57 f5 ff ff       	call   800bf4 <sys_page_unmap>
}
  80169d:	83 c4 14             	add    $0x14,%esp
  8016a0:	5b                   	pop    %ebx
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	57                   	push   %edi
  8016a7:	56                   	push   %esi
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 2c             	sub    $0x2c,%esp
  8016ac:	89 c7                	mov    %eax,%edi
  8016ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016b9:	89 3c 24             	mov    %edi,(%esp)
  8016bc:	e8 df 05 00 00       	call   801ca0 <pageref>
  8016c1:	89 c6                	mov    %eax,%esi
  8016c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016c6:	89 04 24             	mov    %eax,(%esp)
  8016c9:	e8 d2 05 00 00       	call   801ca0 <pageref>
  8016ce:	39 c6                	cmp    %eax,%esi
  8016d0:	0f 94 c0             	sete   %al
  8016d3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016d6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016dc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016df:	39 cb                	cmp    %ecx,%ebx
  8016e1:	75 08                	jne    8016eb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016e3:	83 c4 2c             	add    $0x2c,%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5e                   	pop    %esi
  8016e8:	5f                   	pop    %edi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016eb:	83 f8 01             	cmp    $0x1,%eax
  8016ee:	75 c1                	jne    8016b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016f0:	8b 42 58             	mov    0x58(%edx),%eax
  8016f3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016fa:	00 
  8016fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801703:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  80170a:	e8 a1 ea ff ff       	call   8001b0 <cprintf>
  80170f:	eb a0                	jmp    8016b1 <_pipeisclosed+0xe>

00801711 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	57                   	push   %edi
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	83 ec 1c             	sub    $0x1c,%esp
  80171a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80171d:	89 34 24             	mov    %esi,(%esp)
  801720:	e8 a3 f6 ff ff       	call   800dc8 <fd2data>
  801725:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801727:	bf 00 00 00 00       	mov    $0x0,%edi
  80172c:	eb 3c                	jmp    80176a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80172e:	89 da                	mov    %ebx,%edx
  801730:	89 f0                	mov    %esi,%eax
  801732:	e8 6c ff ff ff       	call   8016a3 <_pipeisclosed>
  801737:	85 c0                	test   %eax,%eax
  801739:	75 38                	jne    801773 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80173b:	e8 ee f3 ff ff       	call   800b2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801740:	8b 43 04             	mov    0x4(%ebx),%eax
  801743:	8b 13                	mov    (%ebx),%edx
  801745:	83 c2 20             	add    $0x20,%edx
  801748:	39 d0                	cmp    %edx,%eax
  80174a:	73 e2                	jae    80172e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80174c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801752:	89 c2                	mov    %eax,%edx
  801754:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80175a:	79 05                	jns    801761 <devpipe_write+0x50>
  80175c:	4a                   	dec    %edx
  80175d:	83 ca e0             	or     $0xffffffe0,%edx
  801760:	42                   	inc    %edx
  801761:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801765:	40                   	inc    %eax
  801766:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801769:	47                   	inc    %edi
  80176a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80176d:	75 d1                	jne    801740 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80176f:	89 f8                	mov    %edi,%eax
  801771:	eb 05                	jmp    801778 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801778:	83 c4 1c             	add    $0x1c,%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5f                   	pop    %edi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	57                   	push   %edi
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 1c             	sub    $0x1c,%esp
  801789:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80178c:	89 3c 24             	mov    %edi,(%esp)
  80178f:	e8 34 f6 ff ff       	call   800dc8 <fd2data>
  801794:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801796:	be 00 00 00 00       	mov    $0x0,%esi
  80179b:	eb 3a                	jmp    8017d7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80179d:	85 f6                	test   %esi,%esi
  80179f:	74 04                	je     8017a5 <devpipe_read+0x25>
				return i;
  8017a1:	89 f0                	mov    %esi,%eax
  8017a3:	eb 40                	jmp    8017e5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017a5:	89 da                	mov    %ebx,%edx
  8017a7:	89 f8                	mov    %edi,%eax
  8017a9:	e8 f5 fe ff ff       	call   8016a3 <_pipeisclosed>
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	75 2e                	jne    8017e0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017b2:	e8 77 f3 ff ff       	call   800b2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017b7:	8b 03                	mov    (%ebx),%eax
  8017b9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017bc:	74 df                	je     80179d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017be:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017c3:	79 05                	jns    8017ca <devpipe_read+0x4a>
  8017c5:	48                   	dec    %eax
  8017c6:	83 c8 e0             	or     $0xffffffe0,%eax
  8017c9:	40                   	inc    %eax
  8017ca:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017d4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d6:	46                   	inc    %esi
  8017d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017da:	75 db                	jne    8017b7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017dc:	89 f0                	mov    %esi,%eax
  8017de:	eb 05                	jmp    8017e5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017e0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017e5:	83 c4 1c             	add    $0x1c,%esp
  8017e8:	5b                   	pop    %ebx
  8017e9:	5e                   	pop    %esi
  8017ea:	5f                   	pop    %edi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	57                   	push   %edi
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 3c             	sub    $0x3c,%esp
  8017f6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017fc:	89 04 24             	mov    %eax,(%esp)
  8017ff:	e8 df f5 ff ff       	call   800de3 <fd_alloc>
  801804:	89 c3                	mov    %eax,%ebx
  801806:	85 c0                	test   %eax,%eax
  801808:	0f 88 45 01 00 00    	js     801953 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801815:	00 
  801816:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801824:	e8 24 f3 ff ff       	call   800b4d <sys_page_alloc>
  801829:	89 c3                	mov    %eax,%ebx
  80182b:	85 c0                	test   %eax,%eax
  80182d:	0f 88 20 01 00 00    	js     801953 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801833:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801836:	89 04 24             	mov    %eax,(%esp)
  801839:	e8 a5 f5 ff ff       	call   800de3 <fd_alloc>
  80183e:	89 c3                	mov    %eax,%ebx
  801840:	85 c0                	test   %eax,%eax
  801842:	0f 88 f8 00 00 00    	js     801940 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801848:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80184f:	00 
  801850:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801853:	89 44 24 04          	mov    %eax,0x4(%esp)
  801857:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80185e:	e8 ea f2 ff ff       	call   800b4d <sys_page_alloc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	85 c0                	test   %eax,%eax
  801867:	0f 88 d3 00 00 00    	js     801940 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80186d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801870:	89 04 24             	mov    %eax,(%esp)
  801873:	e8 50 f5 ff ff       	call   800dc8 <fd2data>
  801878:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801881:	00 
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80188d:	e8 bb f2 ff ff       	call   800b4d <sys_page_alloc>
  801892:	89 c3                	mov    %eax,%ebx
  801894:	85 c0                	test   %eax,%eax
  801896:	0f 88 91 00 00 00    	js     80192d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80189f:	89 04 24             	mov    %eax,(%esp)
  8018a2:	e8 21 f5 ff ff       	call   800dc8 <fd2data>
  8018a7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8018ae:	00 
  8018af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018ba:	00 
  8018bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c6:	e8 d6 f2 ff ff       	call   800ba1 <sys_page_map>
  8018cb:	89 c3                	mov    %eax,%ebx
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 4c                	js     80191d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018d1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018e6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	e8 b2 f4 ff ff       	call   800db8 <fd2num>
  801906:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801908:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80190b:	89 04 24             	mov    %eax,(%esp)
  80190e:	e8 a5 f4 ff ff       	call   800db8 <fd2num>
  801913:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801916:	bb 00 00 00 00       	mov    $0x0,%ebx
  80191b:	eb 36                	jmp    801953 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80191d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801921:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801928:	e8 c7 f2 ff ff       	call   800bf4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80192d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801930:	89 44 24 04          	mov    %eax,0x4(%esp)
  801934:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193b:	e8 b4 f2 ff ff       	call   800bf4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801940:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801943:	89 44 24 04          	mov    %eax,0x4(%esp)
  801947:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194e:	e8 a1 f2 ff ff       	call   800bf4 <sys_page_unmap>
    err:
	return r;
}
  801953:	89 d8                	mov    %ebx,%eax
  801955:	83 c4 3c             	add    $0x3c,%esp
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5f                   	pop    %edi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
  80196d:	89 04 24             	mov    %eax,(%esp)
  801970:	e8 c1 f4 ff ff       	call   800e36 <fd_lookup>
  801975:	85 c0                	test   %eax,%eax
  801977:	78 15                	js     80198e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197c:	89 04 24             	mov    %eax,(%esp)
  80197f:	e8 44 f4 ff ff       	call   800dc8 <fd2data>
	return _pipeisclosed(fd, p);
  801984:	89 c2                	mov    %eax,%edx
  801986:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801989:	e8 15 fd ff ff       	call   8016a3 <_pipeisclosed>
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801993:	b8 00 00 00 00       	mov    $0x0,%eax
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8019a0:	c7 44 24 04 e8 23 80 	movl   $0x8023e8,0x4(%esp)
  8019a7:	00 
  8019a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ab:	89 04 24             	mov    %eax,(%esp)
  8019ae:	e8 a8 ed ff ff       	call   80075b <strcpy>
	return 0;
}
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	57                   	push   %edi
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d1:	eb 30                	jmp    801a03 <devcons_write+0x49>
		m = n - tot;
  8019d3:	8b 75 10             	mov    0x10(%ebp),%esi
  8019d6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8019d8:	83 fe 7f             	cmp    $0x7f,%esi
  8019db:	76 05                	jbe    8019e2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8019dd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019e2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019e6:	03 45 0c             	add    0xc(%ebp),%eax
  8019e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ed:	89 3c 24             	mov    %edi,(%esp)
  8019f0:	e8 df ee ff ff       	call   8008d4 <memmove>
		sys_cputs(buf, m);
  8019f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f9:	89 3c 24             	mov    %edi,(%esp)
  8019fc:	e8 7f f0 ff ff       	call   800a80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a01:	01 f3                	add    %esi,%ebx
  801a03:	89 d8                	mov    %ebx,%eax
  801a05:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a08:	72 c9                	jb     8019d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a0a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5f                   	pop    %edi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a1f:	75 07                	jne    801a28 <devcons_read+0x13>
  801a21:	eb 25                	jmp    801a48 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a23:	e8 06 f1 ff ff       	call   800b2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a28:	e8 71 f0 ff ff       	call   800a9e <sys_cgetc>
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	74 f2                	je     801a23 <devcons_read+0xe>
  801a31:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 1d                	js     801a54 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a37:	83 f8 04             	cmp    $0x4,%eax
  801a3a:	74 13                	je     801a4f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3f:	88 10                	mov    %dl,(%eax)
	return 1;
  801a41:	b8 01 00 00 00       	mov    $0x1,%eax
  801a46:	eb 0c                	jmp    801a54 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a48:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4d:	eb 05                	jmp    801a54 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a4f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a62:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a69:	00 
  801a6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a6d:	89 04 24             	mov    %eax,(%esp)
  801a70:	e8 0b f0 ff ff       	call   800a80 <sys_cputs>
}
  801a75:	c9                   	leave  
  801a76:	c3                   	ret    

00801a77 <getchar>:

int
getchar(void)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a7d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a84:	00 
  801a85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a93:	e8 3a f6 ff ff       	call   8010d2 <read>
	if (r < 0)
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 0f                	js     801aab <getchar+0x34>
		return r;
	if (r < 1)
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	7e 06                	jle    801aa6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801aa0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801aa4:	eb 05                	jmp    801aab <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801aa6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ab3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	89 04 24             	mov    %eax,(%esp)
  801ac0:	e8 71 f3 ff ff       	call   800e36 <fd_lookup>
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 11                	js     801ada <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad2:	39 10                	cmp    %edx,(%eax)
  801ad4:	0f 94 c0             	sete   %al
  801ad7:	0f b6 c0             	movzbl %al,%eax
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <opencons>:

int
opencons(void)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ae2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae5:	89 04 24             	mov    %eax,(%esp)
  801ae8:	e8 f6 f2 ff ff       	call   800de3 <fd_alloc>
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 3c                	js     801b2d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801af1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801af8:	00 
  801af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b07:	e8 41 f0 ff ff       	call   800b4d <sys_page_alloc>
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 1d                	js     801b2d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b10:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b19:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b25:	89 04 24             	mov    %eax,(%esp)
  801b28:	e8 8b f2 ff ff       	call   800db8 <fd2num>
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    
	...

00801b30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	56                   	push   %esi
  801b34:	53                   	push   %ebx
  801b35:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b38:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b3b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b41:	e8 c9 ef ff ff       	call   800b0f <sys_getenvid>
  801b46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b49:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b50:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	c7 04 24 f4 23 80 00 	movl   $0x8023f4,(%esp)
  801b63:	e8 48 e6 ff ff       	call   8001b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6f:	89 04 24             	mov    %eax,(%esp)
  801b72:	e8 d8 e5 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  801b77:	c7 04 24 e1 23 80 00 	movl   $0x8023e1,(%esp)
  801b7e:	e8 2d e6 ff ff       	call   8001b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b83:	cc                   	int3   
  801b84:	eb fd                	jmp    801b83 <_panic+0x53>
	...

00801b88 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	57                   	push   %edi
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 1c             	sub    $0x1c,%esp
  801b91:	8b 75 08             	mov    0x8(%ebp),%esi
  801b94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b97:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801b9a:	85 db                	test   %ebx,%ebx
  801b9c:	75 05                	jne    801ba3 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801b9e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801ba3:	89 1c 24             	mov    %ebx,(%esp)
  801ba6:	e8 b8 f1 ff ff       	call   800d63 <sys_ipc_recv>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	79 16                	jns    801bc5 <ipc_recv+0x3d>
		*from_env_store = 0;
  801baf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801bb5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801bbb:	89 1c 24             	mov    %ebx,(%esp)
  801bbe:	e8 a0 f1 ff ff       	call   800d63 <sys_ipc_recv>
  801bc3:	eb 24                	jmp    801be9 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801bc5:	85 f6                	test   %esi,%esi
  801bc7:	74 0a                	je     801bd3 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801bc9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bce:	8b 40 74             	mov    0x74(%eax),%eax
  801bd1:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801bd3:	85 ff                	test   %edi,%edi
  801bd5:	74 0a                	je     801be1 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801bd7:	a1 04 40 80 00       	mov    0x804004,%eax
  801bdc:	8b 40 78             	mov    0x78(%eax),%eax
  801bdf:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801be1:	a1 04 40 80 00       	mov    0x804004,%eax
  801be6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801be9:	83 c4 1c             	add    $0x1c,%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	5f                   	pop    %edi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	57                   	push   %edi
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 1c             	sub    $0x1c,%esp
  801bfa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c00:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801c03:	85 db                	test   %ebx,%ebx
  801c05:	75 05                	jne    801c0c <ipc_send+0x1b>
		pg = (void *)-1;
  801c07:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c0c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c10:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c14:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1b:	89 04 24             	mov    %eax,(%esp)
  801c1e:	e8 1d f1 ff ff       	call   800d40 <sys_ipc_try_send>
		if (r == 0) {		
  801c23:	85 c0                	test   %eax,%eax
  801c25:	74 2c                	je     801c53 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801c27:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c2a:	75 07                	jne    801c33 <ipc_send+0x42>
			sys_yield();
  801c2c:	e8 fd ee ff ff       	call   800b2e <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801c31:	eb d9                	jmp    801c0c <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801c33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c37:	c7 44 24 08 18 24 80 	movl   $0x802418,0x8(%esp)
  801c3e:	00 
  801c3f:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c46:	00 
  801c47:	c7 04 24 26 24 80 00 	movl   $0x802426,(%esp)
  801c4e:	e8 dd fe ff ff       	call   801b30 <_panic>
		}
	}
}
  801c53:	83 c4 1c             	add    $0x1c,%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c62:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c67:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c6e:	89 c2                	mov    %eax,%edx
  801c70:	c1 e2 07             	shl    $0x7,%edx
  801c73:	29 ca                	sub    %ecx,%edx
  801c75:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c7b:	8b 52 50             	mov    0x50(%edx),%edx
  801c7e:	39 da                	cmp    %ebx,%edx
  801c80:	75 0f                	jne    801c91 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c82:	c1 e0 07             	shl    $0x7,%eax
  801c85:	29 c8                	sub    %ecx,%eax
  801c87:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c8c:	8b 40 40             	mov    0x40(%eax),%eax
  801c8f:	eb 0c                	jmp    801c9d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c91:	40                   	inc    %eax
  801c92:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c97:	75 ce                	jne    801c67 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c99:	66 b8 00 00          	mov    $0x0,%ax
}
  801c9d:	5b                   	pop    %ebx
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ca6:	89 c2                	mov    %eax,%edx
  801ca8:	c1 ea 16             	shr    $0x16,%edx
  801cab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cb2:	f6 c2 01             	test   $0x1,%dl
  801cb5:	74 1e                	je     801cd5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cb7:	c1 e8 0c             	shr    $0xc,%eax
  801cba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cc1:	a8 01                	test   $0x1,%al
  801cc3:	74 17                	je     801cdc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cc5:	c1 e8 0c             	shr    $0xc,%eax
  801cc8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ccf:	ef 
  801cd0:	0f b7 c0             	movzwl %ax,%eax
  801cd3:	eb 0c                	jmp    801ce1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cda:	eb 05                	jmp    801ce1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cdc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    
	...

00801ce4 <__udivdi3>:
  801ce4:	55                   	push   %ebp
  801ce5:	57                   	push   %edi
  801ce6:	56                   	push   %esi
  801ce7:	83 ec 10             	sub    $0x10,%esp
  801cea:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cee:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cf6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cfa:	89 cd                	mov    %ecx,%ebp
  801cfc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d00:	85 c0                	test   %eax,%eax
  801d02:	75 2c                	jne    801d30 <__udivdi3+0x4c>
  801d04:	39 f9                	cmp    %edi,%ecx
  801d06:	77 68                	ja     801d70 <__udivdi3+0x8c>
  801d08:	85 c9                	test   %ecx,%ecx
  801d0a:	75 0b                	jne    801d17 <__udivdi3+0x33>
  801d0c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d11:	31 d2                	xor    %edx,%edx
  801d13:	f7 f1                	div    %ecx
  801d15:	89 c1                	mov    %eax,%ecx
  801d17:	31 d2                	xor    %edx,%edx
  801d19:	89 f8                	mov    %edi,%eax
  801d1b:	f7 f1                	div    %ecx
  801d1d:	89 c7                	mov    %eax,%edi
  801d1f:	89 f0                	mov    %esi,%eax
  801d21:	f7 f1                	div    %ecx
  801d23:	89 c6                	mov    %eax,%esi
  801d25:	89 f0                	mov    %esi,%eax
  801d27:	89 fa                	mov    %edi,%edx
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    
  801d30:	39 f8                	cmp    %edi,%eax
  801d32:	77 2c                	ja     801d60 <__udivdi3+0x7c>
  801d34:	0f bd f0             	bsr    %eax,%esi
  801d37:	83 f6 1f             	xor    $0x1f,%esi
  801d3a:	75 4c                	jne    801d88 <__udivdi3+0xa4>
  801d3c:	39 f8                	cmp    %edi,%eax
  801d3e:	bf 00 00 00 00       	mov    $0x0,%edi
  801d43:	72 0a                	jb     801d4f <__udivdi3+0x6b>
  801d45:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d49:	0f 87 ad 00 00 00    	ja     801dfc <__udivdi3+0x118>
  801d4f:	be 01 00 00 00       	mov    $0x1,%esi
  801d54:	89 f0                	mov    %esi,%eax
  801d56:	89 fa                	mov    %edi,%edx
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    
  801d5f:	90                   	nop
  801d60:	31 ff                	xor    %edi,%edi
  801d62:	31 f6                	xor    %esi,%esi
  801d64:	89 f0                	mov    %esi,%eax
  801d66:	89 fa                	mov    %edi,%edx
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	5e                   	pop    %esi
  801d6c:	5f                   	pop    %edi
  801d6d:	5d                   	pop    %ebp
  801d6e:	c3                   	ret    
  801d6f:	90                   	nop
  801d70:	89 fa                	mov    %edi,%edx
  801d72:	89 f0                	mov    %esi,%eax
  801d74:	f7 f1                	div    %ecx
  801d76:	89 c6                	mov    %eax,%esi
  801d78:	31 ff                	xor    %edi,%edi
  801d7a:	89 f0                	mov    %esi,%eax
  801d7c:	89 fa                	mov    %edi,%edx
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    
  801d85:	8d 76 00             	lea    0x0(%esi),%esi
  801d88:	89 f1                	mov    %esi,%ecx
  801d8a:	d3 e0                	shl    %cl,%eax
  801d8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d90:	b8 20 00 00 00       	mov    $0x20,%eax
  801d95:	29 f0                	sub    %esi,%eax
  801d97:	89 ea                	mov    %ebp,%edx
  801d99:	88 c1                	mov    %al,%cl
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801da1:	09 ca                	or     %ecx,%edx
  801da3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801da7:	89 f1                	mov    %esi,%ecx
  801da9:	d3 e5                	shl    %cl,%ebp
  801dab:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801daf:	89 fd                	mov    %edi,%ebp
  801db1:	88 c1                	mov    %al,%cl
  801db3:	d3 ed                	shr    %cl,%ebp
  801db5:	89 fa                	mov    %edi,%edx
  801db7:	89 f1                	mov    %esi,%ecx
  801db9:	d3 e2                	shl    %cl,%edx
  801dbb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801dbf:	88 c1                	mov    %al,%cl
  801dc1:	d3 ef                	shr    %cl,%edi
  801dc3:	09 d7                	or     %edx,%edi
  801dc5:	89 f8                	mov    %edi,%eax
  801dc7:	89 ea                	mov    %ebp,%edx
  801dc9:	f7 74 24 08          	divl   0x8(%esp)
  801dcd:	89 d1                	mov    %edx,%ecx
  801dcf:	89 c7                	mov    %eax,%edi
  801dd1:	f7 64 24 0c          	mull   0xc(%esp)
  801dd5:	39 d1                	cmp    %edx,%ecx
  801dd7:	72 17                	jb     801df0 <__udivdi3+0x10c>
  801dd9:	74 09                	je     801de4 <__udivdi3+0x100>
  801ddb:	89 fe                	mov    %edi,%esi
  801ddd:	31 ff                	xor    %edi,%edi
  801ddf:	e9 41 ff ff ff       	jmp    801d25 <__udivdi3+0x41>
  801de4:	8b 54 24 04          	mov    0x4(%esp),%edx
  801de8:	89 f1                	mov    %esi,%ecx
  801dea:	d3 e2                	shl    %cl,%edx
  801dec:	39 c2                	cmp    %eax,%edx
  801dee:	73 eb                	jae    801ddb <__udivdi3+0xf7>
  801df0:	8d 77 ff             	lea    -0x1(%edi),%esi
  801df3:	31 ff                	xor    %edi,%edi
  801df5:	e9 2b ff ff ff       	jmp    801d25 <__udivdi3+0x41>
  801dfa:	66 90                	xchg   %ax,%ax
  801dfc:	31 f6                	xor    %esi,%esi
  801dfe:	e9 22 ff ff ff       	jmp    801d25 <__udivdi3+0x41>
	...

00801e04 <__umoddi3>:
  801e04:	55                   	push   %ebp
  801e05:	57                   	push   %edi
  801e06:	56                   	push   %esi
  801e07:	83 ec 20             	sub    $0x20,%esp
  801e0a:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e0e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e12:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e16:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e1a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e1e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e22:	89 c7                	mov    %eax,%edi
  801e24:	89 f2                	mov    %esi,%edx
  801e26:	85 ed                	test   %ebp,%ebp
  801e28:	75 16                	jne    801e40 <__umoddi3+0x3c>
  801e2a:	39 f1                	cmp    %esi,%ecx
  801e2c:	0f 86 a6 00 00 00    	jbe    801ed8 <__umoddi3+0xd4>
  801e32:	f7 f1                	div    %ecx
  801e34:	89 d0                	mov    %edx,%eax
  801e36:	31 d2                	xor    %edx,%edx
  801e38:	83 c4 20             	add    $0x20,%esp
  801e3b:	5e                   	pop    %esi
  801e3c:	5f                   	pop    %edi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    
  801e3f:	90                   	nop
  801e40:	39 f5                	cmp    %esi,%ebp
  801e42:	0f 87 ac 00 00 00    	ja     801ef4 <__umoddi3+0xf0>
  801e48:	0f bd c5             	bsr    %ebp,%eax
  801e4b:	83 f0 1f             	xor    $0x1f,%eax
  801e4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e52:	0f 84 a8 00 00 00    	je     801f00 <__umoddi3+0xfc>
  801e58:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e5c:	d3 e5                	shl    %cl,%ebp
  801e5e:	bf 20 00 00 00       	mov    $0x20,%edi
  801e63:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e67:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e6b:	89 f9                	mov    %edi,%ecx
  801e6d:	d3 e8                	shr    %cl,%eax
  801e6f:	09 e8                	or     %ebp,%eax
  801e71:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e75:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e79:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e7d:	d3 e0                	shl    %cl,%eax
  801e7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e83:	89 f2                	mov    %esi,%edx
  801e85:	d3 e2                	shl    %cl,%edx
  801e87:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e8b:	d3 e0                	shl    %cl,%eax
  801e8d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e91:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e95:	89 f9                	mov    %edi,%ecx
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	09 d0                	or     %edx,%eax
  801e9b:	d3 ee                	shr    %cl,%esi
  801e9d:	89 f2                	mov    %esi,%edx
  801e9f:	f7 74 24 18          	divl   0x18(%esp)
  801ea3:	89 d6                	mov    %edx,%esi
  801ea5:	f7 64 24 0c          	mull   0xc(%esp)
  801ea9:	89 c5                	mov    %eax,%ebp
  801eab:	89 d1                	mov    %edx,%ecx
  801ead:	39 d6                	cmp    %edx,%esi
  801eaf:	72 67                	jb     801f18 <__umoddi3+0x114>
  801eb1:	74 75                	je     801f28 <__umoddi3+0x124>
  801eb3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801eb7:	29 e8                	sub    %ebp,%eax
  801eb9:	19 ce                	sbb    %ecx,%esi
  801ebb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ebf:	d3 e8                	shr    %cl,%eax
  801ec1:	89 f2                	mov    %esi,%edx
  801ec3:	89 f9                	mov    %edi,%ecx
  801ec5:	d3 e2                	shl    %cl,%edx
  801ec7:	09 d0                	or     %edx,%eax
  801ec9:	89 f2                	mov    %esi,%edx
  801ecb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ecf:	d3 ea                	shr    %cl,%edx
  801ed1:	83 c4 20             	add    $0x20,%esp
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    
  801ed8:	85 c9                	test   %ecx,%ecx
  801eda:	75 0b                	jne    801ee7 <__umoddi3+0xe3>
  801edc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee1:	31 d2                	xor    %edx,%edx
  801ee3:	f7 f1                	div    %ecx
  801ee5:	89 c1                	mov    %eax,%ecx
  801ee7:	89 f0                	mov    %esi,%eax
  801ee9:	31 d2                	xor    %edx,%edx
  801eeb:	f7 f1                	div    %ecx
  801eed:	89 f8                	mov    %edi,%eax
  801eef:	e9 3e ff ff ff       	jmp    801e32 <__umoddi3+0x2e>
  801ef4:	89 f2                	mov    %esi,%edx
  801ef6:	83 c4 20             	add    $0x20,%esp
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	39 f5                	cmp    %esi,%ebp
  801f02:	72 04                	jb     801f08 <__umoddi3+0x104>
  801f04:	39 f9                	cmp    %edi,%ecx
  801f06:	77 06                	ja     801f0e <__umoddi3+0x10a>
  801f08:	89 f2                	mov    %esi,%edx
  801f0a:	29 cf                	sub    %ecx,%edi
  801f0c:	19 ea                	sbb    %ebp,%edx
  801f0e:	89 f8                	mov    %edi,%eax
  801f10:	83 c4 20             	add    $0x20,%esp
  801f13:	5e                   	pop    %esi
  801f14:	5f                   	pop    %edi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    
  801f17:	90                   	nop
  801f18:	89 d1                	mov    %edx,%ecx
  801f1a:	89 c5                	mov    %eax,%ebp
  801f1c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f20:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f24:	eb 8d                	jmp    801eb3 <__umoddi3+0xaf>
  801f26:	66 90                	xchg   %ax,%ax
  801f28:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f2c:	72 ea                	jb     801f18 <__umoddi3+0x114>
  801f2e:	89 f1                	mov    %esi,%ecx
  801f30:	eb 81                	jmp    801eb3 <__umoddi3+0xaf>
