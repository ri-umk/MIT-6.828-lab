
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 f2 0a 00 00       	call   800b33 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 72 0d 00 00       	call   800ddc <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 60 1f 80 00 	movl   $0x801f60,(%esp)
  80007c:	e8 53 01 00 00       	call   8001d4 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 71 1f 80 00 	movl   $0x801f71,(%esp)
  800097:	e8 38 01 00 00       	call   8001d4 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 84 0d 00 00       	call   800e45 <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 10             	sub    $0x10,%esp
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8000d2:	e8 5c 0a 00 00       	call   800b33 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e3:	c1 e0 07             	shl    $0x7,%eax
  8000e6:	29 d0                	sub    %edx,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 f6                	test   %esi,%esi
  8000f4:	7e 07                	jle    8000fd <libmain+0x39>
		binaryname = argv[0];
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800101:	89 34 24             	mov    %esi,(%esp)
  800104:	e8 2b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800109:	e8 0a 00 00 00       	call   800118 <exit>
}
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
  800115:	00 00                	add    %al,(%eax)
	...

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80011e:	e8 b8 0f 00 00       	call   8010db <close_all>
	sys_env_destroy(0);
  800123:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012a:	e8 b2 09 00 00       	call   800ae1 <sys_env_destroy>
}
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	53                   	push   %ebx
  800138:	83 ec 14             	sub    $0x14,%esp
  80013b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013e:	8b 03                	mov    (%ebx),%eax
  800140:	8b 55 08             	mov    0x8(%ebp),%edx
  800143:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800147:	40                   	inc    %eax
  800148:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014f:	75 19                	jne    80016a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800151:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800158:	00 
  800159:	8d 43 08             	lea    0x8(%ebx),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 40 09 00 00       	call   800aa4 <sys_cputs>
		b->idx = 0;
  800164:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016a:	ff 43 04             	incl   0x4(%ebx)
}
  80016d:	83 c4 14             	add    $0x14,%esp
  800170:	5b                   	pop    %ebx
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800183:	00 00 00 
	b.cnt = 0;
  800186:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800190:	8b 45 0c             	mov    0xc(%ebp),%eax
  800193:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800197:	8b 45 08             	mov    0x8(%ebp),%eax
  80019a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	c7 04 24 34 01 80 00 	movl   $0x800134,(%esp)
  8001af:	e8 82 01 00 00       	call   800336 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 d8 08 00 00       	call   800aa4 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 87 ff ff ff       	call   800173 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 3c             	sub    $0x3c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	85 c0                	test   %eax,%eax
  800212:	75 08                	jne    80021c <printnum+0x2c>
  800214:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 57                	ja     800273 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800220:	4b                   	dec    %ebx
  800221:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800225:	8b 45 10             	mov    0x10(%ebp),%eax
  800228:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800230:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800234:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023b:	00 
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	e8 ba 1a 00 00       	call   801d08 <__udivdi3>
  80024e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800252:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025d:	89 fa                	mov    %edi,%edx
  80025f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800262:	e8 89 ff ff ff       	call   8001f0 <printnum>
  800267:	eb 0f                	jmp    800278 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800273:	4b                   	dec    %ebx
  800274:	85 db                	test   %ebx,%ebx
  800276:	7f f1                	jg     800269 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800278:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800280:	8b 45 10             	mov    0x10(%ebp),%eax
  800283:	89 44 24 08          	mov    %eax,0x8(%esp)
  800287:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028e:	00 
  80028f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	e8 87 1b 00 00       	call   801e28 <__umoddi3>
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	0f be 80 92 1f 80 00 	movsbl 0x801f92(%eax),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b2:	83 c4 3c             	add    $0x3c,%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x38>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 08                	jae    80030c <sprintputch+0x18>
		*b->buf++ = ch;
  800304:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800307:	88 0a                	mov    %cl,(%edx)
  800309:	42                   	inc    %edx
  80030a:	89 10                	mov    %edx,(%eax)
}
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800314:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800317:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031b:	8b 45 10             	mov    0x10(%ebp),%eax
  80031e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
  800325:	89 44 24 04          	mov    %eax,0x4(%esp)
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	e8 02 00 00 00       	call   800336 <vprintfmt>
	va_end(ap);
}
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	56                   	push   %esi
  80033b:	53                   	push   %ebx
  80033c:	83 ec 4c             	sub    $0x4c,%esp
  80033f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800342:	8b 75 10             	mov    0x10(%ebp),%esi
  800345:	eb 12                	jmp    800359 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800347:	85 c0                	test   %eax,%eax
  800349:	0f 84 6b 03 00 00    	je     8006ba <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80034f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	0f b6 06             	movzbl (%esi),%eax
  80035c:	46                   	inc    %esi
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e5                	jne    800347 <vprintfmt+0x11>
  800362:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800366:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80036d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800372:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	eb 26                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800387:	eb 1d                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800390:	eb 14                	jmp    8003a6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800395:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80039c:	eb 08                	jmp    8003a6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80039e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	0f b6 06             	movzbl (%esi),%eax
  8003a9:	8d 56 01             	lea    0x1(%esi),%edx
  8003ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003af:	8a 16                	mov    (%esi),%dl
  8003b1:	83 ea 23             	sub    $0x23,%edx
  8003b4:	80 fa 55             	cmp    $0x55,%dl
  8003b7:	0f 87 e1 02 00 00    	ja     80069e <vprintfmt+0x368>
  8003bd:	0f b6 d2             	movzbl %dl,%edx
  8003c0:	ff 24 95 e0 20 80 00 	jmp    *0x8020e0(,%edx,4)
  8003c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ca:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003d2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003d6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003dc:	83 fa 09             	cmp    $0x9,%edx
  8003df:	77 2a                	ja     80040b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e2:	eb eb                	jmp    8003cf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ed:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f2:	eb 17                	jmp    80040b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f8:	78 98                	js     800392 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fd:	eb a7                	jmp    8003a6 <vprintfmt+0x70>
  8003ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800402:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800409:	eb 9b                	jmp    8003a6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80040b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040f:	79 95                	jns    8003a6 <vprintfmt+0x70>
  800411:	eb 8b                	jmp    80039e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800413:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800417:	eb 8d                	jmp    8003a6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800426:	8b 00                	mov    (%eax),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800431:	e9 23 ff ff ff       	jmp    800359 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	79 02                	jns    800447 <vprintfmt+0x111>
  800445:	f7 d8                	neg    %eax
  800447:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800449:	83 f8 0f             	cmp    $0xf,%eax
  80044c:	7f 0b                	jg     800459 <vprintfmt+0x123>
  80044e:	8b 04 85 40 22 80 00 	mov    0x802240(,%eax,4),%eax
  800455:	85 c0                	test   %eax,%eax
  800457:	75 23                	jne    80047c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800459:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045d:	c7 44 24 08 aa 1f 80 	movl   $0x801faa,0x8(%esp)
  800464:	00 
  800465:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	e8 9a fe ff ff       	call   80030e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800477:	e9 dd fe ff ff       	jmp    800359 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80047c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800480:	c7 44 24 08 b2 23 80 	movl   $0x8023b2,0x8(%esp)
  800487:	00 
  800488:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048c:	8b 55 08             	mov    0x8(%ebp),%edx
  80048f:	89 14 24             	mov    %edx,(%esp)
  800492:	e8 77 fe ff ff       	call   80030e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049a:	e9 ba fe ff ff       	jmp    800359 <vprintfmt+0x23>
  80049f:	89 f9                	mov    %edi,%ecx
  8004a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 50 04             	lea    0x4(%eax),%edx
  8004ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b0:	8b 30                	mov    (%eax),%esi
  8004b2:	85 f6                	test   %esi,%esi
  8004b4:	75 05                	jne    8004bb <vprintfmt+0x185>
				p = "(null)";
  8004b6:	be a3 1f 80 00       	mov    $0x801fa3,%esi
			if (width > 0 && padc != '-')
  8004bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bf:	0f 8e 84 00 00 00    	jle    800549 <vprintfmt+0x213>
  8004c5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004c9:	74 7e                	je     800549 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004cf:	89 34 24             	mov    %esi,(%esp)
  8004d2:	e8 8b 02 00 00       	call   800762 <strnlen>
  8004d7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004df:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004e3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004e6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004e9:	89 de                	mov    %ebx,%esi
  8004eb:	89 d3                	mov    %edx,%ebx
  8004ed:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	eb 0b                	jmp    8004fc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f5:	89 3c 24             	mov    %edi,(%esp)
  8004f8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	4b                   	dec    %ebx
  8004fc:	85 db                	test   %ebx,%ebx
  8004fe:	7f f1                	jg     8004f1 <vprintfmt+0x1bb>
  800500:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800503:	89 f3                	mov    %esi,%ebx
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	79 05                	jns    800514 <vprintfmt+0x1de>
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800517:	29 c2                	sub    %eax,%edx
  800519:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051c:	eb 2b                	jmp    800549 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800522:	74 18                	je     80053c <vprintfmt+0x206>
  800524:	8d 50 e0             	lea    -0x20(%eax),%edx
  800527:	83 fa 5e             	cmp    $0x5e,%edx
  80052a:	76 10                	jbe    80053c <vprintfmt+0x206>
					putch('?', putdat);
  80052c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800530:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800537:	ff 55 08             	call   *0x8(%ebp)
  80053a:	eb 0a                	jmp    800546 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80053c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800546:	ff 4d e4             	decl   -0x1c(%ebp)
  800549:	0f be 06             	movsbl (%esi),%eax
  80054c:	46                   	inc    %esi
  80054d:	85 c0                	test   %eax,%eax
  80054f:	74 21                	je     800572 <vprintfmt+0x23c>
  800551:	85 ff                	test   %edi,%edi
  800553:	78 c9                	js     80051e <vprintfmt+0x1e8>
  800555:	4f                   	dec    %edi
  800556:	79 c6                	jns    80051e <vprintfmt+0x1e8>
  800558:	8b 7d 08             	mov    0x8(%ebp),%edi
  80055b:	89 de                	mov    %ebx,%esi
  80055d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800560:	eb 18                	jmp    80057a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800562:	89 74 24 04          	mov    %esi,0x4(%esp)
  800566:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056f:	4b                   	dec    %ebx
  800570:	eb 08                	jmp    80057a <vprintfmt+0x244>
  800572:	8b 7d 08             	mov    0x8(%ebp),%edi
  800575:	89 de                	mov    %ebx,%esi
  800577:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80057a:	85 db                	test   %ebx,%ebx
  80057c:	7f e4                	jg     800562 <vprintfmt+0x22c>
  80057e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800581:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800586:	e9 ce fd ff ff       	jmp    800359 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058b:	83 f9 01             	cmp    $0x1,%ecx
  80058e:	7e 10                	jle    8005a0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 08             	lea    0x8(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	8b 78 04             	mov    0x4(%eax),%edi
  80059e:	eb 26                	jmp    8005c6 <vprintfmt+0x290>
	else if (lflag)
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	74 12                	je     8005b6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 30                	mov    (%eax),%esi
  8005af:	89 f7                	mov    %esi,%edi
  8005b1:	c1 ff 1f             	sar    $0x1f,%edi
  8005b4:	eb 10                	jmp    8005c6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 30                	mov    (%eax),%esi
  8005c1:	89 f7                	mov    %esi,%edi
  8005c3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	78 0a                	js     8005d4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cf:	e9 8c 00 00 00       	jmp    800660 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e2:	f7 de                	neg    %esi
  8005e4:	83 d7 00             	adc    $0x0,%edi
  8005e7:	f7 df                	neg    %edi
			}
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ee:	eb 70                	jmp    800660 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f0:	89 ca                	mov    %ecx,%edx
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 c0 fc ff ff       	call   8002ba <getuint>
  8005fa:	89 c6                	mov    %eax,%esi
  8005fc:	89 d7                	mov    %edx,%edi
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800603:	eb 5b                	jmp    800660 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800605:	89 ca                	mov    %ecx,%edx
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	e8 ab fc ff ff       	call   8002ba <getuint>
  80060f:	89 c6                	mov    %eax,%esi
  800611:	89 d7                	mov    %edx,%edi
			base = 8;
  800613:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800618:	eb 46                	jmp    800660 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80061a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800625:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 50 04             	lea    0x4(%eax),%edx
  80063c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063f:	8b 30                	mov    (%eax),%esi
  800641:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800646:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064b:	eb 13                	jmp    800660 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064d:	89 ca                	mov    %ecx,%edx
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 63 fc ff ff       	call   8002ba <getuint>
  800657:	89 c6                	mov    %eax,%esi
  800659:	89 d7                	mov    %edx,%edi
			base = 16;
  80065b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800660:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800664:	89 54 24 10          	mov    %edx,0x10(%esp)
  800668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80066f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800673:	89 34 24             	mov    %esi,(%esp)
  800676:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067a:	89 da                	mov    %ebx,%edx
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	e8 6c fb ff ff       	call   8001f0 <printnum>
			break;
  800684:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800687:	e9 cd fc ff ff       	jmp    800359 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800699:	e9 bb fc ff ff       	jmp    800359 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ac:	eb 01                	jmp    8006af <vprintfmt+0x379>
  8006ae:	4e                   	dec    %esi
  8006af:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b3:	75 f9                	jne    8006ae <vprintfmt+0x378>
  8006b5:	e9 9f fc ff ff       	jmp    800359 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ba:	83 c4 4c             	add    $0x4c,%esp
  8006bd:	5b                   	pop    %ebx
  8006be:	5e                   	pop    %esi
  8006bf:	5f                   	pop    %edi
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 28             	sub    $0x28,%esp
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 30                	je     800713 <vsnprintf+0x51>
  8006e3:	85 d2                	test   %edx,%edx
  8006e5:	7e 33                	jle    80071a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	c7 04 24 f4 02 80 00 	movl   $0x8002f4,(%esp)
  800703:	e8 2e fc ff ff       	call   800336 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800708:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800711:	eb 0c                	jmp    80071f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800718:	eb 05                	jmp    80071f <vsnprintf+0x5d>
  80071a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800727:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072e:	8b 45 10             	mov    0x10(%ebp),%eax
  800731:	89 44 24 08          	mov    %eax,0x8(%esp)
  800735:	8b 45 0c             	mov    0xc(%ebp),%eax
  800738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	e8 7b ff ff ff       	call   8006c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    
  800749:	00 00                	add    %al,(%eax)
	...

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 01                	jmp    80075a <strlen+0xe>
		n++;
  800759:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075e:	75 f9                	jne    800759 <strlen+0xd>
		n++;
	return n;
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800768:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	eb 01                	jmp    800773 <strnlen+0x11>
		n++;
  800772:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800773:	39 d0                	cmp    %edx,%eax
  800775:	74 06                	je     80077d <strnlen+0x1b>
  800777:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077b:	75 f5                	jne    800772 <strnlen+0x10>
		n++;
	return n;
}
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800789:	ba 00 00 00 00       	mov    $0x0,%edx
  80078e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800791:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800794:	42                   	inc    %edx
  800795:	84 c9                	test   %cl,%cl
  800797:	75 f5                	jne    80078e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800799:	5b                   	pop    %ebx
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a6:	89 1c 24             	mov    %ebx,(%esp)
  8007a9:	e8 9e ff ff ff       	call   80074c <strlen>
	strcpy(dst + len, src);
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b5:	01 d8                	add    %ebx,%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 c0 ff ff ff       	call   80077f <strcpy>
	return dst;
}
  8007bf:	89 d8                	mov    %ebx,%eax
  8007c1:	83 c4 08             	add    $0x8,%esp
  8007c4:	5b                   	pop    %ebx
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007da:	eb 0c                	jmp    8007e8 <strncpy+0x21>
		*dst++ = *src;
  8007dc:	8a 1a                	mov    (%edx),%bl
  8007de:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e7:	41                   	inc    %ecx
  8007e8:	39 f1                	cmp    %esi,%ecx
  8007ea:	75 f0                	jne    8007dc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fe:	85 d2                	test   %edx,%edx
  800800:	75 0a                	jne    80080c <strlcpy+0x1c>
  800802:	89 f0                	mov    %esi,%eax
  800804:	eb 1a                	jmp    800820 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800806:	88 18                	mov    %bl,(%eax)
  800808:	40                   	inc    %eax
  800809:	41                   	inc    %ecx
  80080a:	eb 02                	jmp    80080e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80080e:	4a                   	dec    %edx
  80080f:	74 0a                	je     80081b <strlcpy+0x2b>
  800811:	8a 19                	mov    (%ecx),%bl
  800813:	84 db                	test   %bl,%bl
  800815:	75 ef                	jne    800806 <strlcpy+0x16>
  800817:	89 c2                	mov    %eax,%edx
  800819:	eb 02                	jmp    80081d <strlcpy+0x2d>
  80081b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80081d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800820:	29 f0                	sub    %esi,%eax
}
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082f:	eb 02                	jmp    800833 <strcmp+0xd>
		p++, q++;
  800831:	41                   	inc    %ecx
  800832:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800833:	8a 01                	mov    (%ecx),%al
  800835:	84 c0                	test   %al,%al
  800837:	74 04                	je     80083d <strcmp+0x17>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	74 f4                	je     800831 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	0f b6 12             	movzbl (%edx),%edx
  800843:	29 d0                	sub    %edx,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800854:	eb 03                	jmp    800859 <strncmp+0x12>
		n--, p++, q++;
  800856:	4a                   	dec    %edx
  800857:	40                   	inc    %eax
  800858:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800859:	85 d2                	test   %edx,%edx
  80085b:	74 14                	je     800871 <strncmp+0x2a>
  80085d:	8a 18                	mov    (%eax),%bl
  80085f:	84 db                	test   %bl,%bl
  800861:	74 04                	je     800867 <strncmp+0x20>
  800863:	3a 19                	cmp    (%ecx),%bl
  800865:	74 ef                	je     800856 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800867:	0f b6 00             	movzbl (%eax),%eax
  80086a:	0f b6 11             	movzbl (%ecx),%edx
  80086d:	29 d0                	sub    %edx,%eax
  80086f:	eb 05                	jmp    800876 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800876:	5b                   	pop    %ebx
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800882:	eb 05                	jmp    800889 <strchr+0x10>
		if (*s == c)
  800884:	38 ca                	cmp    %cl,%dl
  800886:	74 0c                	je     800894 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800888:	40                   	inc    %eax
  800889:	8a 10                	mov    (%eax),%dl
  80088b:	84 d2                	test   %dl,%dl
  80088d:	75 f5                	jne    800884 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089f:	eb 05                	jmp    8008a6 <strfind+0x10>
		if (*s == c)
  8008a1:	38 ca                	cmp    %cl,%dl
  8008a3:	74 07                	je     8008ac <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a5:	40                   	inc    %eax
  8008a6:	8a 10                	mov    (%eax),%dl
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	75 f5                	jne    8008a1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bd:	85 c9                	test   %ecx,%ecx
  8008bf:	74 30                	je     8008f1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c7:	75 25                	jne    8008ee <memset+0x40>
  8008c9:	f6 c1 03             	test   $0x3,%cl
  8008cc:	75 20                	jne    8008ee <memset+0x40>
		c &= 0xFF;
  8008ce:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d1:	89 d3                	mov    %edx,%ebx
  8008d3:	c1 e3 08             	shl    $0x8,%ebx
  8008d6:	89 d6                	mov    %edx,%esi
  8008d8:	c1 e6 18             	shl    $0x18,%esi
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	c1 e0 10             	shl    $0x10,%eax
  8008e0:	09 f0                	or     %esi,%eax
  8008e2:	09 d0                	or     %edx,%eax
  8008e4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e9:	fc                   	cld    
  8008ea:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ec:	eb 03                	jmp    8008f1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ee:	fc                   	cld    
  8008ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f1:	89 f8                	mov    %edi,%eax
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5f                   	pop    %edi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	57                   	push   %edi
  8008fc:	56                   	push   %esi
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8b 75 0c             	mov    0xc(%ebp),%esi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800906:	39 c6                	cmp    %eax,%esi
  800908:	73 34                	jae    80093e <memmove+0x46>
  80090a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090d:	39 d0                	cmp    %edx,%eax
  80090f:	73 2d                	jae    80093e <memmove+0x46>
		s += n;
		d += n;
  800911:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800914:	f6 c2 03             	test   $0x3,%dl
  800917:	75 1b                	jne    800934 <memmove+0x3c>
  800919:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091f:	75 13                	jne    800934 <memmove+0x3c>
  800921:	f6 c1 03             	test   $0x3,%cl
  800924:	75 0e                	jne    800934 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800926:	83 ef 04             	sub    $0x4,%edi
  800929:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80092f:	fd                   	std    
  800930:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800932:	eb 07                	jmp    80093b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800934:	4f                   	dec    %edi
  800935:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800938:	fd                   	std    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093b:	fc                   	cld    
  80093c:	eb 20                	jmp    80095e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800944:	75 13                	jne    800959 <memmove+0x61>
  800946:	a8 03                	test   $0x3,%al
  800948:	75 0f                	jne    800959 <memmove+0x61>
  80094a:	f6 c1 03             	test   $0x3,%cl
  80094d:	75 0a                	jne    800959 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800952:	89 c7                	mov    %eax,%edi
  800954:	fc                   	cld    
  800955:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800957:	eb 05                	jmp    80095e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800959:	89 c7                	mov    %eax,%edi
  80095b:	fc                   	cld    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800968:	8b 45 10             	mov    0x10(%ebp),%eax
  80096b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	89 44 24 04          	mov    %eax,0x4(%esp)
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	89 04 24             	mov    %eax,(%esp)
  80097c:	e8 77 ff ff ff       	call   8008f8 <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	ba 00 00 00 00       	mov    $0x0,%edx
  800997:	eb 16                	jmp    8009af <memcmp+0x2c>
		if (*s1 != *s2)
  800999:	8a 04 17             	mov    (%edi,%edx,1),%al
  80099c:	42                   	inc    %edx
  80099d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009a1:	38 c8                	cmp    %cl,%al
  8009a3:	74 0a                	je     8009af <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009a5:	0f b6 c0             	movzbl %al,%eax
  8009a8:	0f b6 c9             	movzbl %cl,%ecx
  8009ab:	29 c8                	sub    %ecx,%eax
  8009ad:	eb 09                	jmp    8009b8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	75 e6                	jne    800999 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c6:	89 c2                	mov    %eax,%edx
  8009c8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009cb:	eb 05                	jmp    8009d2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cd:	38 08                	cmp    %cl,(%eax)
  8009cf:	74 05                	je     8009d6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d1:	40                   	inc    %eax
  8009d2:	39 d0                	cmp    %edx,%eax
  8009d4:	72 f7                	jb     8009cd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e4:	eb 01                	jmp    8009e7 <strtol+0xf>
		s++;
  8009e6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e7:	8a 02                	mov    (%edx),%al
  8009e9:	3c 20                	cmp    $0x20,%al
  8009eb:	74 f9                	je     8009e6 <strtol+0xe>
  8009ed:	3c 09                	cmp    $0x9,%al
  8009ef:	74 f5                	je     8009e6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f1:	3c 2b                	cmp    $0x2b,%al
  8009f3:	75 08                	jne    8009fd <strtol+0x25>
		s++;
  8009f5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fb:	eb 13                	jmp    800a10 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009fd:	3c 2d                	cmp    $0x2d,%al
  8009ff:	75 0a                	jne    800a0b <strtol+0x33>
		s++, neg = 1;
  800a01:	8d 52 01             	lea    0x1(%edx),%edx
  800a04:	bf 01 00 00 00       	mov    $0x1,%edi
  800a09:	eb 05                	jmp    800a10 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a10:	85 db                	test   %ebx,%ebx
  800a12:	74 05                	je     800a19 <strtol+0x41>
  800a14:	83 fb 10             	cmp    $0x10,%ebx
  800a17:	75 28                	jne    800a41 <strtol+0x69>
  800a19:	8a 02                	mov    (%edx),%al
  800a1b:	3c 30                	cmp    $0x30,%al
  800a1d:	75 10                	jne    800a2f <strtol+0x57>
  800a1f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a23:	75 0a                	jne    800a2f <strtol+0x57>
		s += 2, base = 16;
  800a25:	83 c2 02             	add    $0x2,%edx
  800a28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2d:	eb 12                	jmp    800a41 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a2f:	85 db                	test   %ebx,%ebx
  800a31:	75 0e                	jne    800a41 <strtol+0x69>
  800a33:	3c 30                	cmp    $0x30,%al
  800a35:	75 05                	jne    800a3c <strtol+0x64>
		s++, base = 8;
  800a37:	42                   	inc    %edx
  800a38:	b3 08                	mov    $0x8,%bl
  800a3a:	eb 05                	jmp    800a41 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
  800a46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a48:	8a 0a                	mov    (%edx),%cl
  800a4a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a4d:	80 fb 09             	cmp    $0x9,%bl
  800a50:	77 08                	ja     800a5a <strtol+0x82>
			dig = *s - '0';
  800a52:	0f be c9             	movsbl %cl,%ecx
  800a55:	83 e9 30             	sub    $0x30,%ecx
  800a58:	eb 1e                	jmp    800a78 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a5a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a5d:	80 fb 19             	cmp    $0x19,%bl
  800a60:	77 08                	ja     800a6a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a62:	0f be c9             	movsbl %cl,%ecx
  800a65:	83 e9 57             	sub    $0x57,%ecx
  800a68:	eb 0e                	jmp    800a78 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a6a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a6d:	80 fb 19             	cmp    $0x19,%bl
  800a70:	77 12                	ja     800a84 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a72:	0f be c9             	movsbl %cl,%ecx
  800a75:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a78:	39 f1                	cmp    %esi,%ecx
  800a7a:	7d 0c                	jge    800a88 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a7c:	42                   	inc    %edx
  800a7d:	0f af c6             	imul   %esi,%eax
  800a80:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a82:	eb c4                	jmp    800a48 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a84:	89 c1                	mov    %eax,%ecx
  800a86:	eb 02                	jmp    800a8a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a88:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8e:	74 05                	je     800a95 <strtol+0xbd>
		*endptr = (char *) s;
  800a90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a93:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a95:	85 ff                	test   %edi,%edi
  800a97:	74 04                	je     800a9d <strtol+0xc5>
  800a99:	89 c8                	mov    %ecx,%eax
  800a9b:	f7 d8                	neg    %eax
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    
	...

00800aa4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	89 c7                	mov    %eax,%edi
  800ab9:	89 c6                	mov    %eax,%esi
  800abb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  800acd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad2:	89 d1                	mov    %edx,%ecx
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	89 d7                	mov    %edx,%edi
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aef:	b8 03 00 00 00       	mov    $0x3,%eax
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	89 cb                	mov    %ecx,%ebx
  800af9:	89 cf                	mov    %ecx,%edi
  800afb:	89 ce                	mov    %ecx,%esi
  800afd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aff:	85 c0                	test   %eax,%eax
  800b01:	7e 28                	jle    800b2b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b07:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b0e:	00 
  800b0f:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800b16:	00 
  800b17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b1e:	00 
  800b1f:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800b26:	e8 41 11 00 00       	call   801c6c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2b:	83 c4 2c             	add    $0x2c,%esp
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b43:	89 d1                	mov    %edx,%ecx
  800b45:	89 d3                	mov    %edx,%ebx
  800b47:	89 d7                	mov    %edx,%edi
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_yield>:

void
sys_yield(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	be 00 00 00 00       	mov    $0x0,%esi
  800b7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	89 f7                	mov    %esi,%edi
  800b8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 28                	jle    800bbd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b99:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800bb8:	e8 af 10 00 00       	call   801c6c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbd:	83 c4 2c             	add    $0x2c,%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 28                	jle    800c10 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bec:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bf3:	00 
  800bf4:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800bfb:	00 
  800bfc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c03:	00 
  800c04:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800c0b:	e8 5c 10 00 00       	call   801c6c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c10:	83 c4 2c             	add    $0x2c,%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c26:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	89 df                	mov    %ebx,%edi
  800c33:	89 de                	mov    %ebx,%esi
  800c35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	7e 28                	jle    800c63 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c46:	00 
  800c47:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c56:	00 
  800c57:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800c5e:	e8 09 10 00 00       	call   801c6c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c63:	83 c4 2c             	add    $0x2c,%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 28                	jle    800cb6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c92:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c99:	00 
  800c9a:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800ca1:	00 
  800ca2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca9:	00 
  800caa:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800cb1:	e8 b6 0f 00 00       	call   801c6c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb6:	83 c4 2c             	add    $0x2c,%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 28                	jle    800d09 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cec:	00 
  800ced:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfc:	00 
  800cfd:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800d04:	e8 63 0f 00 00       	call   801c6c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d09:	83 c4 2c             	add    $0x2c,%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 28                	jle    800d5c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d38:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d3f:	00 
  800d40:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800d47:	00 
  800d48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4f:	00 
  800d50:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800d57:	e8 10 0f 00 00       	call   801c6c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5c:	83 c4 2c             	add    $0x2c,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	be 00 00 00 00       	mov    $0x0,%esi
  800d6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 28                	jle    800dd1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dad:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800db4:	00 
  800db5:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800dbc:	00 
  800dbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc4:	00 
  800dc5:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800dcc:	e8 9b 0e 00 00       	call   801c6c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd1:	83 c4 2c             	add    $0x2c,%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    
  800dd9:	00 00                	add    %al,(%eax)
	...

00800ddc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	83 ec 1c             	sub    $0x1c,%esp
  800de5:	8b 75 08             	mov    0x8(%ebp),%esi
  800de8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800deb:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  800dee:	85 db                	test   %ebx,%ebx
  800df0:	75 05                	jne    800df7 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  800df2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  800df7:	89 1c 24             	mov    %ebx,(%esp)
  800dfa:	e8 88 ff ff ff       	call   800d87 <sys_ipc_recv>
  800dff:	85 c0                	test   %eax,%eax
  800e01:	79 16                	jns    800e19 <ipc_recv+0x3d>
		*from_env_store = 0;
  800e03:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  800e09:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  800e0f:	89 1c 24             	mov    %ebx,(%esp)
  800e12:	e8 70 ff ff ff       	call   800d87 <sys_ipc_recv>
  800e17:	eb 24                	jmp    800e3d <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  800e19:	85 f6                	test   %esi,%esi
  800e1b:	74 0a                	je     800e27 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  800e1d:	a1 04 40 80 00       	mov    0x804004,%eax
  800e22:	8b 40 74             	mov    0x74(%eax),%eax
  800e25:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  800e27:	85 ff                	test   %edi,%edi
  800e29:	74 0a                	je     800e35 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  800e2b:	a1 04 40 80 00       	mov    0x804004,%eax
  800e30:	8b 40 78             	mov    0x78(%eax),%eax
  800e33:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  800e35:	a1 04 40 80 00       	mov    0x804004,%eax
  800e3a:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e3d:	83 c4 1c             	add    $0x1c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
  800e4b:	83 ec 1c             	sub    $0x1c,%esp
  800e4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e54:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  800e57:	85 db                	test   %ebx,%ebx
  800e59:	75 05                	jne    800e60 <ipc_send+0x1b>
		pg = (void *)-1;
  800e5b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800e60:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	89 04 24             	mov    %eax,(%esp)
  800e72:	e8 ed fe ff ff       	call   800d64 <sys_ipc_try_send>
		if (r == 0) {		
  800e77:	85 c0                	test   %eax,%eax
  800e79:	74 2c                	je     800ea7 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  800e7b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e7e:	75 07                	jne    800e87 <ipc_send+0x42>
			sys_yield();
  800e80:	e8 cd fc ff ff       	call   800b52 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  800e85:	eb d9                	jmp    800e60 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  800e87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e8b:	c7 44 24 08 ca 22 80 	movl   $0x8022ca,0x8(%esp)
  800e92:	00 
  800e93:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800e9a:	00 
  800e9b:	c7 04 24 d8 22 80 00 	movl   $0x8022d8,(%esp)
  800ea2:	e8 c5 0d 00 00       	call   801c6c <_panic>
		}
	}
}
  800ea7:	83 c4 1c             	add    $0x1c,%esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	53                   	push   %ebx
  800eb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ebb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	c1 e2 07             	shl    $0x7,%edx
  800ec7:	29 ca                	sub    %ecx,%edx
  800ec9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ecf:	8b 52 50             	mov    0x50(%edx),%edx
  800ed2:	39 da                	cmp    %ebx,%edx
  800ed4:	75 0f                	jne    800ee5 <ipc_find_env+0x36>
			return envs[i].env_id;
  800ed6:	c1 e0 07             	shl    $0x7,%eax
  800ed9:	29 c8                	sub    %ecx,%eax
  800edb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800ee0:	8b 40 40             	mov    0x40(%eax),%eax
  800ee3:	eb 0c                	jmp    800ef1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ee5:	40                   	inc    %eax
  800ee6:	3d 00 04 00 00       	cmp    $0x400,%eax
  800eeb:	75 ce                	jne    800ebb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800eed:	66 b8 00 00          	mov    $0x0,%ax
}
  800ef1:	5b                   	pop    %ebx
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	05 00 00 00 30       	add    $0x30000000,%eax
  800eff:	c1 e8 0c             	shr    $0xc,%eax
}
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	89 04 24             	mov    %eax,(%esp)
  800f10:	e8 df ff ff ff       	call   800ef4 <fd2num>
  800f15:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f1a:	c1 e0 0c             	shl    $0xc,%eax
}
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	53                   	push   %ebx
  800f23:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f26:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f2b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f2d:	89 c2                	mov    %eax,%edx
  800f2f:	c1 ea 16             	shr    $0x16,%edx
  800f32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	74 11                	je     800f4f <fd_alloc+0x30>
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 0c             	shr    $0xc,%edx
  800f43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4a:	f6 c2 01             	test   $0x1,%dl
  800f4d:	75 09                	jne    800f58 <fd_alloc+0x39>
			*fd_store = fd;
  800f4f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
  800f56:	eb 17                	jmp    800f6f <fd_alloc+0x50>
  800f58:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f5d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f62:	75 c7                	jne    800f2b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f64:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f6a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f6f:	5b                   	pop    %ebx
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f78:	83 f8 1f             	cmp    $0x1f,%eax
  800f7b:	77 36                	ja     800fb3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f7d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f82:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f85:	89 c2                	mov    %eax,%edx
  800f87:	c1 ea 16             	shr    $0x16,%edx
  800f8a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f91:	f6 c2 01             	test   $0x1,%dl
  800f94:	74 24                	je     800fba <fd_lookup+0x48>
  800f96:	89 c2                	mov    %eax,%edx
  800f98:	c1 ea 0c             	shr    $0xc,%edx
  800f9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa2:	f6 c2 01             	test   $0x1,%dl
  800fa5:	74 1a                	je     800fc1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800faa:	89 02                	mov    %eax,(%edx)
	return 0;
  800fac:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb1:	eb 13                	jmp    800fc6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb8:	eb 0c                	jmp    800fc6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fbf:	eb 05                	jmp    800fc6 <fd_lookup+0x54>
  800fc1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 14             	sub    $0x14,%esp
  800fcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fda:	eb 0e                	jmp    800fea <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fdc:	39 08                	cmp    %ecx,(%eax)
  800fde:	75 09                	jne    800fe9 <dev_lookup+0x21>
			*dev = devtab[i];
  800fe0:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe7:	eb 33                	jmp    80101c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fe9:	42                   	inc    %edx
  800fea:	8b 04 95 60 23 80 00 	mov    0x802360(,%edx,4),%eax
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	75 e7                	jne    800fdc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ff5:	a1 04 40 80 00       	mov    0x804004,%eax
  800ffa:	8b 40 48             	mov    0x48(%eax),%eax
  800ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801001:	89 44 24 04          	mov    %eax,0x4(%esp)
  801005:	c7 04 24 e4 22 80 00 	movl   $0x8022e4,(%esp)
  80100c:	e8 c3 f1 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801011:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801017:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80101c:	83 c4 14             	add    $0x14,%esp
  80101f:	5b                   	pop    %ebx
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	83 ec 30             	sub    $0x30,%esp
  80102a:	8b 75 08             	mov    0x8(%ebp),%esi
  80102d:	8a 45 0c             	mov    0xc(%ebp),%al
  801030:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801033:	89 34 24             	mov    %esi,(%esp)
  801036:	e8 b9 fe ff ff       	call   800ef4 <fd2num>
  80103b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80103e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801042:	89 04 24             	mov    %eax,(%esp)
  801045:	e8 28 ff ff ff       	call   800f72 <fd_lookup>
  80104a:	89 c3                	mov    %eax,%ebx
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 05                	js     801055 <fd_close+0x33>
	    || fd != fd2)
  801050:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801053:	74 0d                	je     801062 <fd_close+0x40>
		return (must_exist ? r : 0);
  801055:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801059:	75 46                	jne    8010a1 <fd_close+0x7f>
  80105b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801060:	eb 3f                	jmp    8010a1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801062:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801065:	89 44 24 04          	mov    %eax,0x4(%esp)
  801069:	8b 06                	mov    (%esi),%eax
  80106b:	89 04 24             	mov    %eax,(%esp)
  80106e:	e8 55 ff ff ff       	call   800fc8 <dev_lookup>
  801073:	89 c3                	mov    %eax,%ebx
  801075:	85 c0                	test   %eax,%eax
  801077:	78 18                	js     801091 <fd_close+0x6f>
		if (dev->dev_close)
  801079:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107c:	8b 40 10             	mov    0x10(%eax),%eax
  80107f:	85 c0                	test   %eax,%eax
  801081:	74 09                	je     80108c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801083:	89 34 24             	mov    %esi,(%esp)
  801086:	ff d0                	call   *%eax
  801088:	89 c3                	mov    %eax,%ebx
  80108a:	eb 05                	jmp    801091 <fd_close+0x6f>
		else
			r = 0;
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801091:	89 74 24 04          	mov    %esi,0x4(%esp)
  801095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109c:	e8 77 fb ff ff       	call   800c18 <sys_page_unmap>
	return r;
}
  8010a1:	89 d8                	mov    %ebx,%eax
  8010a3:	83 c4 30             	add    $0x30,%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	89 04 24             	mov    %eax,(%esp)
  8010bd:	e8 b0 fe ff ff       	call   800f72 <fd_lookup>
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	78 13                	js     8010d9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010cd:	00 
  8010ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d1:	89 04 24             	mov    %eax,(%esp)
  8010d4:	e8 49 ff ff ff       	call   801022 <fd_close>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <close_all>:

void
close_all(void)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010e7:	89 1c 24             	mov    %ebx,(%esp)
  8010ea:	e8 bb ff ff ff       	call   8010aa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ef:	43                   	inc    %ebx
  8010f0:	83 fb 20             	cmp    $0x20,%ebx
  8010f3:	75 f2                	jne    8010e7 <close_all+0xc>
		close(i);
}
  8010f5:	83 c4 14             	add    $0x14,%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 4c             	sub    $0x4c,%esp
  801104:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801107:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80110a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	e8 59 fe ff ff       	call   800f72 <fd_lookup>
  801119:	89 c3                	mov    %eax,%ebx
  80111b:	85 c0                	test   %eax,%eax
  80111d:	0f 88 e1 00 00 00    	js     801204 <dup+0x109>
		return r;
	close(newfdnum);
  801123:	89 3c 24             	mov    %edi,(%esp)
  801126:	e8 7f ff ff ff       	call   8010aa <close>

	newfd = INDEX2FD(newfdnum);
  80112b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801131:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801137:	89 04 24             	mov    %eax,(%esp)
  80113a:	e8 c5 fd ff ff       	call   800f04 <fd2data>
  80113f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801141:	89 34 24             	mov    %esi,(%esp)
  801144:	e8 bb fd ff ff       	call   800f04 <fd2data>
  801149:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80114c:	89 d8                	mov    %ebx,%eax
  80114e:	c1 e8 16             	shr    $0x16,%eax
  801151:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801158:	a8 01                	test   $0x1,%al
  80115a:	74 46                	je     8011a2 <dup+0xa7>
  80115c:	89 d8                	mov    %ebx,%eax
  80115e:	c1 e8 0c             	shr    $0xc,%eax
  801161:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801168:	f6 c2 01             	test   $0x1,%dl
  80116b:	74 35                	je     8011a2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80116d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801174:	25 07 0e 00 00       	and    $0xe07,%eax
  801179:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801184:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80118b:	00 
  80118c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801190:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801197:	e8 29 fa ff ff       	call   800bc5 <sys_page_map>
  80119c:	89 c3                	mov    %eax,%ebx
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 3b                	js     8011dd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 ea 0c             	shr    $0xc,%edx
  8011aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c6:	00 
  8011c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d2:	e8 ee f9 ff ff       	call   800bc5 <sys_page_map>
  8011d7:	89 c3                	mov    %eax,%ebx
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	79 25                	jns    801202 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e8:	e8 2b fa ff ff       	call   800c18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011fb:	e8 18 fa ff ff       	call   800c18 <sys_page_unmap>
	return r;
  801200:	eb 02                	jmp    801204 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801202:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801204:	89 d8                	mov    %ebx,%eax
  801206:	83 c4 4c             	add    $0x4c,%esp
  801209:	5b                   	pop    %ebx
  80120a:	5e                   	pop    %esi
  80120b:	5f                   	pop    %edi
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	53                   	push   %ebx
  801212:	83 ec 24             	sub    $0x24,%esp
  801215:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801218:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121f:	89 1c 24             	mov    %ebx,(%esp)
  801222:	e8 4b fd ff ff       	call   800f72 <fd_lookup>
  801227:	85 c0                	test   %eax,%eax
  801229:	78 6d                	js     801298 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801232:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801235:	8b 00                	mov    (%eax),%eax
  801237:	89 04 24             	mov    %eax,(%esp)
  80123a:	e8 89 fd ff ff       	call   800fc8 <dev_lookup>
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 55                	js     801298 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801243:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801246:	8b 50 08             	mov    0x8(%eax),%edx
  801249:	83 e2 03             	and    $0x3,%edx
  80124c:	83 fa 01             	cmp    $0x1,%edx
  80124f:	75 23                	jne    801274 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801251:	a1 04 40 80 00       	mov    0x804004,%eax
  801256:	8b 40 48             	mov    0x48(%eax),%eax
  801259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80125d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801261:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  801268:	e8 67 ef ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80126d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801272:	eb 24                	jmp    801298 <read+0x8a>
	}
	if (!dev->dev_read)
  801274:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801277:	8b 52 08             	mov    0x8(%edx),%edx
  80127a:	85 d2                	test   %edx,%edx
  80127c:	74 15                	je     801293 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80127e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801281:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801288:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80128c:	89 04 24             	mov    %eax,(%esp)
  80128f:	ff d2                	call   *%edx
  801291:	eb 05                	jmp    801298 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801293:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801298:	83 c4 24             	add    $0x24,%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 1c             	sub    $0x1c,%esp
  8012a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b2:	eb 23                	jmp    8012d7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b4:	89 f0                	mov    %esi,%eax
  8012b6:	29 d8                	sub    %ebx,%eax
  8012b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bf:	01 d8                	add    %ebx,%eax
  8012c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c5:	89 3c 24             	mov    %edi,(%esp)
  8012c8:	e8 41 ff ff ff       	call   80120e <read>
		if (m < 0)
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 10                	js     8012e1 <readn+0x43>
			return m;
		if (m == 0)
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	74 0a                	je     8012df <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012d5:	01 c3                	add    %eax,%ebx
  8012d7:	39 f3                	cmp    %esi,%ebx
  8012d9:	72 d9                	jb     8012b4 <readn+0x16>
  8012db:	89 d8                	mov    %ebx,%eax
  8012dd:	eb 02                	jmp    8012e1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012df:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012e1:	83 c4 1c             	add    $0x1c,%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 24             	sub    $0x24,%esp
  8012f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fa:	89 1c 24             	mov    %ebx,(%esp)
  8012fd:	e8 70 fc ff ff       	call   800f72 <fd_lookup>
  801302:	85 c0                	test   %eax,%eax
  801304:	78 68                	js     80136e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	8b 00                	mov    (%eax),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	e8 ae fc ff ff       	call   800fc8 <dev_lookup>
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 50                	js     80136e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801321:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801325:	75 23                	jne    80134a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801327:	a1 04 40 80 00       	mov    0x804004,%eax
  80132c:	8b 40 48             	mov    0x48(%eax),%eax
  80132f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801333:	89 44 24 04          	mov    %eax,0x4(%esp)
  801337:	c7 04 24 41 23 80 00 	movl   $0x802341,(%esp)
  80133e:	e8 91 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801343:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801348:	eb 24                	jmp    80136e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80134a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134d:	8b 52 0c             	mov    0xc(%edx),%edx
  801350:	85 d2                	test   %edx,%edx
  801352:	74 15                	je     801369 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801354:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801357:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801362:	89 04 24             	mov    %eax,(%esp)
  801365:	ff d2                	call   *%edx
  801367:	eb 05                	jmp    80136e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801369:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80136e:	83 c4 24             	add    $0x24,%esp
  801371:	5b                   	pop    %ebx
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <seek>:

int
seek(int fdnum, off_t offset)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80137d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	89 04 24             	mov    %eax,(%esp)
  801387:	e8 e6 fb ff ff       	call   800f72 <fd_lookup>
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 0e                	js     80139e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801390:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801393:	8b 55 0c             	mov    0xc(%ebp),%edx
  801396:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 24             	sub    $0x24,%esp
  8013a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b1:	89 1c 24             	mov    %ebx,(%esp)
  8013b4:	e8 b9 fb ff ff       	call   800f72 <fd_lookup>
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 61                	js     80141e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c7:	8b 00                	mov    (%eax),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 f7 fb ff ff       	call   800fc8 <dev_lookup>
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 49                	js     80141e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013dc:	75 23                	jne    801401 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013de:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013e3:	8b 40 48             	mov    0x48(%eax),%eax
  8013e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ee:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  8013f5:	e8 da ed ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ff:	eb 1d                	jmp    80141e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801401:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801404:	8b 52 18             	mov    0x18(%edx),%edx
  801407:	85 d2                	test   %edx,%edx
  801409:	74 0e                	je     801419 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80140b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	ff d2                	call   *%edx
  801417:	eb 05                	jmp    80141e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801419:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80141e:	83 c4 24             	add    $0x24,%esp
  801421:	5b                   	pop    %ebx
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	53                   	push   %ebx
  801428:	83 ec 24             	sub    $0x24,%esp
  80142b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801431:	89 44 24 04          	mov    %eax,0x4(%esp)
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
  801438:	89 04 24             	mov    %eax,(%esp)
  80143b:	e8 32 fb ff ff       	call   800f72 <fd_lookup>
  801440:	85 c0                	test   %eax,%eax
  801442:	78 52                	js     801496 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144e:	8b 00                	mov    (%eax),%eax
  801450:	89 04 24             	mov    %eax,(%esp)
  801453:	e8 70 fb ff ff       	call   800fc8 <dev_lookup>
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 3a                	js     801496 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80145c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801463:	74 2c                	je     801491 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801465:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801468:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80146f:	00 00 00 
	stat->st_isdir = 0;
  801472:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801479:	00 00 00 
	stat->st_dev = dev;
  80147c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801482:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801486:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801489:	89 14 24             	mov    %edx,(%esp)
  80148c:	ff 50 14             	call   *0x14(%eax)
  80148f:	eb 05                	jmp    801496 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801491:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801496:	83 c4 24             	add    $0x24,%esp
  801499:	5b                   	pop    %ebx
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    

0080149c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014ab:	00 
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	89 04 24             	mov    %eax,(%esp)
  8014b2:	e8 fe 01 00 00       	call   8016b5 <open>
  8014b7:	89 c3                	mov    %eax,%ebx
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 1b                	js     8014d8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c4:	89 1c 24             	mov    %ebx,(%esp)
  8014c7:	e8 58 ff ff ff       	call   801424 <fstat>
  8014cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ce:	89 1c 24             	mov    %ebx,(%esp)
  8014d1:	e8 d4 fb ff ff       	call   8010aa <close>
	return r;
  8014d6:	89 f3                	mov    %esi,%ebx
}
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5e                   	pop    %esi
  8014df:	5d                   	pop    %ebp
  8014e0:	c3                   	ret    
  8014e1:	00 00                	add    %al,(%eax)
	...

008014e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 10             	sub    $0x10,%esp
  8014ec:	89 c3                	mov    %eax,%ebx
  8014ee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014f7:	75 11                	jne    80150a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801500:	e8 aa f9 ff ff       	call   800eaf <ipc_find_env>
  801505:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80150a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801511:	00 
  801512:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801519:	00 
  80151a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80151e:	a1 00 40 80 00       	mov    0x804000,%eax
  801523:	89 04 24             	mov    %eax,(%esp)
  801526:	e8 1a f9 ff ff       	call   800e45 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80152b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801532:	00 
  801533:	89 74 24 04          	mov    %esi,0x4(%esp)
  801537:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153e:	e8 99 f8 ff ff       	call   800ddc <ipc_recv>
}
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801550:	8b 45 08             	mov    0x8(%ebp),%eax
  801553:	8b 40 0c             	mov    0xc(%eax),%eax
  801556:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80155b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 02 00 00 00       	mov    $0x2,%eax
  80156d:	e8 72 ff ff ff       	call   8014e4 <fsipc>
}
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80157a:	8b 45 08             	mov    0x8(%ebp),%eax
  80157d:	8b 40 0c             	mov    0xc(%eax),%eax
  801580:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801585:	ba 00 00 00 00       	mov    $0x0,%edx
  80158a:	b8 06 00 00 00       	mov    $0x6,%eax
  80158f:	e8 50 ff ff ff       	call   8014e4 <fsipc>
}
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 14             	sub    $0x14,%esp
  80159d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8015b5:	e8 2a ff ff ff       	call   8014e4 <fsipc>
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 2b                	js     8015e9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015be:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015c5:	00 
  8015c6:	89 1c 24             	mov    %ebx,(%esp)
  8015c9:	e8 b1 f1 ff ff       	call   80077f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ce:	a1 80 50 80 00       	mov    0x805080,%eax
  8015d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015d9:	a1 84 50 80 00       	mov    0x805084,%eax
  8015de:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e9:	83 c4 14             	add    $0x14,%esp
  8015ec:	5b                   	pop    %ebx
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8015f5:	c7 44 24 08 70 23 80 	movl   $0x802370,0x8(%esp)
  8015fc:	00 
  8015fd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801604:	00 
  801605:	c7 04 24 8e 23 80 00 	movl   $0x80238e,(%esp)
  80160c:	e8 5b 06 00 00       	call   801c6c <_panic>

00801611 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	56                   	push   %esi
  801615:	53                   	push   %ebx
  801616:	83 ec 10             	sub    $0x10,%esp
  801619:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80161c:	8b 45 08             	mov    0x8(%ebp),%eax
  80161f:	8b 40 0c             	mov    0xc(%eax),%eax
  801622:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801627:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	b8 03 00 00 00       	mov    $0x3,%eax
  801637:	e8 a8 fe ff ff       	call   8014e4 <fsipc>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 6a                	js     8016ac <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801642:	39 c6                	cmp    %eax,%esi
  801644:	73 24                	jae    80166a <devfile_read+0x59>
  801646:	c7 44 24 0c 99 23 80 	movl   $0x802399,0xc(%esp)
  80164d:	00 
  80164e:	c7 44 24 08 a0 23 80 	movl   $0x8023a0,0x8(%esp)
  801655:	00 
  801656:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80165d:	00 
  80165e:	c7 04 24 8e 23 80 00 	movl   $0x80238e,(%esp)
  801665:	e8 02 06 00 00       	call   801c6c <_panic>
	assert(r <= PGSIZE);
  80166a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80166f:	7e 24                	jle    801695 <devfile_read+0x84>
  801671:	c7 44 24 0c b5 23 80 	movl   $0x8023b5,0xc(%esp)
  801678:	00 
  801679:	c7 44 24 08 a0 23 80 	movl   $0x8023a0,0x8(%esp)
  801680:	00 
  801681:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801688:	00 
  801689:	c7 04 24 8e 23 80 00 	movl   $0x80238e,(%esp)
  801690:	e8 d7 05 00 00       	call   801c6c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801695:	89 44 24 08          	mov    %eax,0x8(%esp)
  801699:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016a0:	00 
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a4:	89 04 24             	mov    %eax,(%esp)
  8016a7:	e8 4c f2 ff ff       	call   8008f8 <memmove>
	return r;
}
  8016ac:	89 d8                	mov    %ebx,%eax
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 20             	sub    $0x20,%esp
  8016bd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016c0:	89 34 24             	mov    %esi,(%esp)
  8016c3:	e8 84 f0 ff ff       	call   80074c <strlen>
  8016c8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016cd:	7f 60                	jg     80172f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d2:	89 04 24             	mov    %eax,(%esp)
  8016d5:	e8 45 f8 ff ff       	call   800f1f <fd_alloc>
  8016da:	89 c3                	mov    %eax,%ebx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 54                	js     801734 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016e4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016eb:	e8 8f f0 ff ff       	call   80077f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801700:	e8 df fd ff ff       	call   8014e4 <fsipc>
  801705:	89 c3                	mov    %eax,%ebx
  801707:	85 c0                	test   %eax,%eax
  801709:	79 15                	jns    801720 <open+0x6b>
		fd_close(fd, 0);
  80170b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801712:	00 
  801713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801716:	89 04 24             	mov    %eax,(%esp)
  801719:	e8 04 f9 ff ff       	call   801022 <fd_close>
		return r;
  80171e:	eb 14                	jmp    801734 <open+0x7f>
	}

	return fd2num(fd);
  801720:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801723:	89 04 24             	mov    %eax,(%esp)
  801726:	e8 c9 f7 ff ff       	call   800ef4 <fd2num>
  80172b:	89 c3                	mov    %eax,%ebx
  80172d:	eb 05                	jmp    801734 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80172f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801734:	89 d8                	mov    %ebx,%eax
  801736:	83 c4 20             	add    $0x20,%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    

0080173d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	b8 08 00 00 00       	mov    $0x8,%eax
  80174d:	e8 92 fd ff ff       	call   8014e4 <fsipc>
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	56                   	push   %esi
  801758:	53                   	push   %ebx
  801759:	83 ec 10             	sub    $0x10,%esp
  80175c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80175f:	8b 45 08             	mov    0x8(%ebp),%eax
  801762:	89 04 24             	mov    %eax,(%esp)
  801765:	e8 9a f7 ff ff       	call   800f04 <fd2data>
  80176a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80176c:	c7 44 24 04 c1 23 80 	movl   $0x8023c1,0x4(%esp)
  801773:	00 
  801774:	89 34 24             	mov    %esi,(%esp)
  801777:	e8 03 f0 ff ff       	call   80077f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80177c:	8b 43 04             	mov    0x4(%ebx),%eax
  80177f:	2b 03                	sub    (%ebx),%eax
  801781:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801787:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80178e:	00 00 00 
	stat->st_dev = &devpipe;
  801791:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801798:	30 80 00 
	return 0;
}
  80179b:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	5b                   	pop    %ebx
  8017a4:	5e                   	pop    %esi
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 14             	sub    $0x14,%esp
  8017ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bc:	e8 57 f4 ff ff       	call   800c18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017c1:	89 1c 24             	mov    %ebx,(%esp)
  8017c4:	e8 3b f7 ff ff       	call   800f04 <fd2data>
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d4:	e8 3f f4 ff ff       	call   800c18 <sys_page_unmap>
}
  8017d9:	83 c4 14             	add    $0x14,%esp
  8017dc:	5b                   	pop    %ebx
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	57                   	push   %edi
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 2c             	sub    $0x2c,%esp
  8017e8:	89 c7                	mov    %eax,%edi
  8017ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017f5:	89 3c 24             	mov    %edi,(%esp)
  8017f8:	e8 c7 04 00 00       	call   801cc4 <pageref>
  8017fd:	89 c6                	mov    %eax,%esi
  8017ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	e8 ba 04 00 00       	call   801cc4 <pageref>
  80180a:	39 c6                	cmp    %eax,%esi
  80180c:	0f 94 c0             	sete   %al
  80180f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801812:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801818:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80181b:	39 cb                	cmp    %ecx,%ebx
  80181d:	75 08                	jne    801827 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80181f:	83 c4 2c             	add    $0x2c,%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5f                   	pop    %edi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801827:	83 f8 01             	cmp    $0x1,%eax
  80182a:	75 c1                	jne    8017ed <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80182c:	8b 42 58             	mov    0x58(%edx),%eax
  80182f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801836:	00 
  801837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183f:	c7 04 24 c8 23 80 00 	movl   $0x8023c8,(%esp)
  801846:	e8 89 e9 ff ff       	call   8001d4 <cprintf>
  80184b:	eb a0                	jmp    8017ed <_pipeisclosed+0xe>

0080184d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	57                   	push   %edi
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	83 ec 1c             	sub    $0x1c,%esp
  801856:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801859:	89 34 24             	mov    %esi,(%esp)
  80185c:	e8 a3 f6 ff ff       	call   800f04 <fd2data>
  801861:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801863:	bf 00 00 00 00       	mov    $0x0,%edi
  801868:	eb 3c                	jmp    8018a6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80186a:	89 da                	mov    %ebx,%edx
  80186c:	89 f0                	mov    %esi,%eax
  80186e:	e8 6c ff ff ff       	call   8017df <_pipeisclosed>
  801873:	85 c0                	test   %eax,%eax
  801875:	75 38                	jne    8018af <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801877:	e8 d6 f2 ff ff       	call   800b52 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80187c:	8b 43 04             	mov    0x4(%ebx),%eax
  80187f:	8b 13                	mov    (%ebx),%edx
  801881:	83 c2 20             	add    $0x20,%edx
  801884:	39 d0                	cmp    %edx,%eax
  801886:	73 e2                	jae    80186a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80188e:	89 c2                	mov    %eax,%edx
  801890:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801896:	79 05                	jns    80189d <devpipe_write+0x50>
  801898:	4a                   	dec    %edx
  801899:	83 ca e0             	or     $0xffffffe0,%edx
  80189c:	42                   	inc    %edx
  80189d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018a1:	40                   	inc    %eax
  8018a2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a5:	47                   	inc    %edi
  8018a6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018a9:	75 d1                	jne    80187c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018ab:	89 f8                	mov    %edi,%eax
  8018ad:	eb 05                	jmp    8018b4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018af:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018b4:	83 c4 1c             	add    $0x1c,%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	5e                   	pop    %esi
  8018b9:	5f                   	pop    %edi
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	57                   	push   %edi
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 1c             	sub    $0x1c,%esp
  8018c5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018c8:	89 3c 24             	mov    %edi,(%esp)
  8018cb:	e8 34 f6 ff ff       	call   800f04 <fd2data>
  8018d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018d2:	be 00 00 00 00       	mov    $0x0,%esi
  8018d7:	eb 3a                	jmp    801913 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018d9:	85 f6                	test   %esi,%esi
  8018db:	74 04                	je     8018e1 <devpipe_read+0x25>
				return i;
  8018dd:	89 f0                	mov    %esi,%eax
  8018df:	eb 40                	jmp    801921 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018e1:	89 da                	mov    %ebx,%edx
  8018e3:	89 f8                	mov    %edi,%eax
  8018e5:	e8 f5 fe ff ff       	call   8017df <_pipeisclosed>
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	75 2e                	jne    80191c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018ee:	e8 5f f2 ff ff       	call   800b52 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018f3:	8b 03                	mov    (%ebx),%eax
  8018f5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018f8:	74 df                	je     8018d9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018fa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018ff:	79 05                	jns    801906 <devpipe_read+0x4a>
  801901:	48                   	dec    %eax
  801902:	83 c8 e0             	or     $0xffffffe0,%eax
  801905:	40                   	inc    %eax
  801906:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80190a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801910:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801912:	46                   	inc    %esi
  801913:	3b 75 10             	cmp    0x10(%ebp),%esi
  801916:	75 db                	jne    8018f3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801918:	89 f0                	mov    %esi,%eax
  80191a:	eb 05                	jmp    801921 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801921:	83 c4 1c             	add    $0x1c,%esp
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5f                   	pop    %edi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	57                   	push   %edi
  80192d:	56                   	push   %esi
  80192e:	53                   	push   %ebx
  80192f:	83 ec 3c             	sub    $0x3c,%esp
  801932:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801935:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801938:	89 04 24             	mov    %eax,(%esp)
  80193b:	e8 df f5 ff ff       	call   800f1f <fd_alloc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	85 c0                	test   %eax,%eax
  801944:	0f 88 45 01 00 00    	js     801a8f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801951:	00 
  801952:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801955:	89 44 24 04          	mov    %eax,0x4(%esp)
  801959:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801960:	e8 0c f2 ff ff       	call   800b71 <sys_page_alloc>
  801965:	89 c3                	mov    %eax,%ebx
  801967:	85 c0                	test   %eax,%eax
  801969:	0f 88 20 01 00 00    	js     801a8f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80196f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801972:	89 04 24             	mov    %eax,(%esp)
  801975:	e8 a5 f5 ff ff       	call   800f1f <fd_alloc>
  80197a:	89 c3                	mov    %eax,%ebx
  80197c:	85 c0                	test   %eax,%eax
  80197e:	0f 88 f8 00 00 00    	js     801a7c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801984:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80198b:	00 
  80198c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80198f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801993:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199a:	e8 d2 f1 ff ff       	call   800b71 <sys_page_alloc>
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	0f 88 d3 00 00 00    	js     801a7c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ac:	89 04 24             	mov    %eax,(%esp)
  8019af:	e8 50 f5 ff ff       	call   800f04 <fd2data>
  8019b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019bd:	00 
  8019be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c9:	e8 a3 f1 ff ff       	call   800b71 <sys_page_alloc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	0f 88 91 00 00 00    	js     801a69 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019db:	89 04 24             	mov    %eax,(%esp)
  8019de:	e8 21 f5 ff ff       	call   800f04 <fd2data>
  8019e3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019ea:	00 
  8019eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f6:	00 
  8019f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a02:	e8 be f1 ff ff       	call   800bc5 <sys_page_map>
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	78 4c                	js     801a59 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a16:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a2b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a30:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a3a:	89 04 24             	mov    %eax,(%esp)
  801a3d:	e8 b2 f4 ff ff       	call   800ef4 <fd2num>
  801a42:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a44:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a47:	89 04 24             	mov    %eax,(%esp)
  801a4a:	e8 a5 f4 ff ff       	call   800ef4 <fd2num>
  801a4f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a57:	eb 36                	jmp    801a8f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801a59:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a64:	e8 af f1 ff ff       	call   800c18 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801a69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a77:	e8 9c f1 ff ff       	call   800c18 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801a7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a8a:	e8 89 f1 ff ff       	call   800c18 <sys_page_unmap>
    err:
	return r;
}
  801a8f:	89 d8                	mov    %ebx,%eax
  801a91:	83 c4 3c             	add    $0x3c,%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5f                   	pop    %edi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	89 04 24             	mov    %eax,(%esp)
  801aac:	e8 c1 f4 ff ff       	call   800f72 <fd_lookup>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 15                	js     801aca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab8:	89 04 24             	mov    %eax,(%esp)
  801abb:	e8 44 f4 ff ff       	call   800f04 <fd2data>
	return _pipeisclosed(fd, p);
  801ac0:	89 c2                	mov    %eax,%edx
  801ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac5:	e8 15 fd ff ff       	call   8017df <_pipeisclosed>
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801adc:	c7 44 24 04 e0 23 80 	movl   $0x8023e0,0x4(%esp)
  801ae3:	00 
  801ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae7:	89 04 24             	mov    %eax,(%esp)
  801aea:	e8 90 ec ff ff       	call   80077f <strcpy>
	return 0;
}
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	57                   	push   %edi
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b02:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b07:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b0d:	eb 30                	jmp    801b3f <devcons_write+0x49>
		m = n - tot;
  801b0f:	8b 75 10             	mov    0x10(%ebp),%esi
  801b12:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b14:	83 fe 7f             	cmp    $0x7f,%esi
  801b17:	76 05                	jbe    801b1e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801b19:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b1e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b22:	03 45 0c             	add    0xc(%ebp),%eax
  801b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b29:	89 3c 24             	mov    %edi,(%esp)
  801b2c:	e8 c7 ed ff ff       	call   8008f8 <memmove>
		sys_cputs(buf, m);
  801b31:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b35:	89 3c 24             	mov    %edi,(%esp)
  801b38:	e8 67 ef ff ff       	call   800aa4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b3d:	01 f3                	add    %esi,%ebx
  801b3f:	89 d8                	mov    %ebx,%eax
  801b41:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b44:	72 c9                	jb     801b0f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b46:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5f                   	pop    %edi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b5b:	75 07                	jne    801b64 <devcons_read+0x13>
  801b5d:	eb 25                	jmp    801b84 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b5f:	e8 ee ef ff ff       	call   800b52 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b64:	e8 59 ef ff ff       	call   800ac2 <sys_cgetc>
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	74 f2                	je     801b5f <devcons_read+0xe>
  801b6d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 1d                	js     801b90 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b73:	83 f8 04             	cmp    $0x4,%eax
  801b76:	74 13                	je     801b8b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7b:	88 10                	mov    %dl,(%eax)
	return 1;
  801b7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b82:	eb 0c                	jmp    801b90 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	eb 05                	jmp    801b90 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ba5:	00 
  801ba6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba9:	89 04 24             	mov    %eax,(%esp)
  801bac:	e8 f3 ee ff ff       	call   800aa4 <sys_cputs>
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <getchar>:

int
getchar(void)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bb9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801bc0:	00 
  801bc1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bcf:	e8 3a f6 ff ff       	call   80120e <read>
	if (r < 0)
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 0f                	js     801be7 <getchar+0x34>
		return r;
	if (r < 1)
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	7e 06                	jle    801be2 <getchar+0x2f>
		return -E_EOF;
	return c;
  801bdc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801be0:	eb 05                	jmp    801be7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801be2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	89 04 24             	mov    %eax,(%esp)
  801bfc:	e8 71 f3 ff ff       	call   800f72 <fd_lookup>
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 11                	js     801c16 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c08:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c0e:	39 10                	cmp    %edx,(%eax)
  801c10:	0f 94 c0             	sete   %al
  801c13:	0f b6 c0             	movzbl %al,%eax
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <opencons>:

int
opencons(void)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c21:	89 04 24             	mov    %eax,(%esp)
  801c24:	e8 f6 f2 ff ff       	call   800f1f <fd_alloc>
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 3c                	js     801c69 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c2d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c34:	00 
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c43:	e8 29 ef ff ff       	call   800b71 <sys_page_alloc>
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	78 1d                	js     801c69 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c4c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c55:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c61:	89 04 24             	mov    %eax,(%esp)
  801c64:	e8 8b f2 ff ff       	call   800ef4 <fd2num>
}
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    
	...

00801c6c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c74:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c77:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801c7d:	e8 b1 ee ff ff       	call   800b33 <sys_getenvid>
  801c82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c85:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c89:	8b 55 08             	mov    0x8(%ebp),%edx
  801c8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c90:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c98:	c7 04 24 ec 23 80 00 	movl   $0x8023ec,(%esp)
  801c9f:	e8 30 e5 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ca4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca8:	8b 45 10             	mov    0x10(%ebp),%eax
  801cab:	89 04 24             	mov    %eax,(%esp)
  801cae:	e8 c0 e4 ff ff       	call   800173 <vcprintf>
	cprintf("\n");
  801cb3:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  801cba:	e8 15 e5 ff ff       	call   8001d4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cbf:	cc                   	int3   
  801cc0:	eb fd                	jmp    801cbf <_panic+0x53>
	...

00801cc4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cca:	89 c2                	mov    %eax,%edx
  801ccc:	c1 ea 16             	shr    $0x16,%edx
  801ccf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cd6:	f6 c2 01             	test   $0x1,%dl
  801cd9:	74 1e                	je     801cf9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cdb:	c1 e8 0c             	shr    $0xc,%eax
  801cde:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ce5:	a8 01                	test   $0x1,%al
  801ce7:	74 17                	je     801d00 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ce9:	c1 e8 0c             	shr    $0xc,%eax
  801cec:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801cf3:	ef 
  801cf4:	0f b7 c0             	movzwl %ax,%eax
  801cf7:	eb 0c                	jmp    801d05 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801cf9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfe:	eb 05                	jmp    801d05 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d00:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    
	...

00801d08 <__udivdi3>:
  801d08:	55                   	push   %ebp
  801d09:	57                   	push   %edi
  801d0a:	56                   	push   %esi
  801d0b:	83 ec 10             	sub    $0x10,%esp
  801d0e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d12:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d1e:	89 cd                	mov    %ecx,%ebp
  801d20:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d24:	85 c0                	test   %eax,%eax
  801d26:	75 2c                	jne    801d54 <__udivdi3+0x4c>
  801d28:	39 f9                	cmp    %edi,%ecx
  801d2a:	77 68                	ja     801d94 <__udivdi3+0x8c>
  801d2c:	85 c9                	test   %ecx,%ecx
  801d2e:	75 0b                	jne    801d3b <__udivdi3+0x33>
  801d30:	b8 01 00 00 00       	mov    $0x1,%eax
  801d35:	31 d2                	xor    %edx,%edx
  801d37:	f7 f1                	div    %ecx
  801d39:	89 c1                	mov    %eax,%ecx
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	89 f8                	mov    %edi,%eax
  801d3f:	f7 f1                	div    %ecx
  801d41:	89 c7                	mov    %eax,%edi
  801d43:	89 f0                	mov    %esi,%eax
  801d45:	f7 f1                	div    %ecx
  801d47:	89 c6                	mov    %eax,%esi
  801d49:	89 f0                	mov    %esi,%eax
  801d4b:	89 fa                	mov    %edi,%edx
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    
  801d54:	39 f8                	cmp    %edi,%eax
  801d56:	77 2c                	ja     801d84 <__udivdi3+0x7c>
  801d58:	0f bd f0             	bsr    %eax,%esi
  801d5b:	83 f6 1f             	xor    $0x1f,%esi
  801d5e:	75 4c                	jne    801dac <__udivdi3+0xa4>
  801d60:	39 f8                	cmp    %edi,%eax
  801d62:	bf 00 00 00 00       	mov    $0x0,%edi
  801d67:	72 0a                	jb     801d73 <__udivdi3+0x6b>
  801d69:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d6d:	0f 87 ad 00 00 00    	ja     801e20 <__udivdi3+0x118>
  801d73:	be 01 00 00 00       	mov    $0x1,%esi
  801d78:	89 f0                	mov    %esi,%eax
  801d7a:	89 fa                	mov    %edi,%edx
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	31 f6                	xor    %esi,%esi
  801d88:	89 f0                	mov    %esi,%eax
  801d8a:	89 fa                	mov    %edi,%edx
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	89 fa                	mov    %edi,%edx
  801d96:	89 f0                	mov    %esi,%eax
  801d98:	f7 f1                	div    %ecx
  801d9a:	89 c6                	mov    %eax,%esi
  801d9c:	31 ff                	xor    %edi,%edi
  801d9e:	89 f0                	mov    %esi,%eax
  801da0:	89 fa                	mov    %edi,%edx
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	5e                   	pop    %esi
  801da6:	5f                   	pop    %edi
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    
  801da9:	8d 76 00             	lea    0x0(%esi),%esi
  801dac:	89 f1                	mov    %esi,%ecx
  801dae:	d3 e0                	shl    %cl,%eax
  801db0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db4:	b8 20 00 00 00       	mov    $0x20,%eax
  801db9:	29 f0                	sub    %esi,%eax
  801dbb:	89 ea                	mov    %ebp,%edx
  801dbd:	88 c1                	mov    %al,%cl
  801dbf:	d3 ea                	shr    %cl,%edx
  801dc1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801dc5:	09 ca                	or     %ecx,%edx
  801dc7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dcb:	89 f1                	mov    %esi,%ecx
  801dcd:	d3 e5                	shl    %cl,%ebp
  801dcf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801dd3:	89 fd                	mov    %edi,%ebp
  801dd5:	88 c1                	mov    %al,%cl
  801dd7:	d3 ed                	shr    %cl,%ebp
  801dd9:	89 fa                	mov    %edi,%edx
  801ddb:	89 f1                	mov    %esi,%ecx
  801ddd:	d3 e2                	shl    %cl,%edx
  801ddf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801de3:	88 c1                	mov    %al,%cl
  801de5:	d3 ef                	shr    %cl,%edi
  801de7:	09 d7                	or     %edx,%edi
  801de9:	89 f8                	mov    %edi,%eax
  801deb:	89 ea                	mov    %ebp,%edx
  801ded:	f7 74 24 08          	divl   0x8(%esp)
  801df1:	89 d1                	mov    %edx,%ecx
  801df3:	89 c7                	mov    %eax,%edi
  801df5:	f7 64 24 0c          	mull   0xc(%esp)
  801df9:	39 d1                	cmp    %edx,%ecx
  801dfb:	72 17                	jb     801e14 <__udivdi3+0x10c>
  801dfd:	74 09                	je     801e08 <__udivdi3+0x100>
  801dff:	89 fe                	mov    %edi,%esi
  801e01:	31 ff                	xor    %edi,%edi
  801e03:	e9 41 ff ff ff       	jmp    801d49 <__udivdi3+0x41>
  801e08:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e0c:	89 f1                	mov    %esi,%ecx
  801e0e:	d3 e2                	shl    %cl,%edx
  801e10:	39 c2                	cmp    %eax,%edx
  801e12:	73 eb                	jae    801dff <__udivdi3+0xf7>
  801e14:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e17:	31 ff                	xor    %edi,%edi
  801e19:	e9 2b ff ff ff       	jmp    801d49 <__udivdi3+0x41>
  801e1e:	66 90                	xchg   %ax,%ax
  801e20:	31 f6                	xor    %esi,%esi
  801e22:	e9 22 ff ff ff       	jmp    801d49 <__udivdi3+0x41>
	...

00801e28 <__umoddi3>:
  801e28:	55                   	push   %ebp
  801e29:	57                   	push   %edi
  801e2a:	56                   	push   %esi
  801e2b:	83 ec 20             	sub    $0x20,%esp
  801e2e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e32:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e36:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e3a:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e42:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e46:	89 c7                	mov    %eax,%edi
  801e48:	89 f2                	mov    %esi,%edx
  801e4a:	85 ed                	test   %ebp,%ebp
  801e4c:	75 16                	jne    801e64 <__umoddi3+0x3c>
  801e4e:	39 f1                	cmp    %esi,%ecx
  801e50:	0f 86 a6 00 00 00    	jbe    801efc <__umoddi3+0xd4>
  801e56:	f7 f1                	div    %ecx
  801e58:	89 d0                	mov    %edx,%eax
  801e5a:	31 d2                	xor    %edx,%edx
  801e5c:	83 c4 20             	add    $0x20,%esp
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    
  801e63:	90                   	nop
  801e64:	39 f5                	cmp    %esi,%ebp
  801e66:	0f 87 ac 00 00 00    	ja     801f18 <__umoddi3+0xf0>
  801e6c:	0f bd c5             	bsr    %ebp,%eax
  801e6f:	83 f0 1f             	xor    $0x1f,%eax
  801e72:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e76:	0f 84 a8 00 00 00    	je     801f24 <__umoddi3+0xfc>
  801e7c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e80:	d3 e5                	shl    %cl,%ebp
  801e82:	bf 20 00 00 00       	mov    $0x20,%edi
  801e87:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e8b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e8f:	89 f9                	mov    %edi,%ecx
  801e91:	d3 e8                	shr    %cl,%eax
  801e93:	09 e8                	or     %ebp,%eax
  801e95:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e99:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e9d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ea1:	d3 e0                	shl    %cl,%eax
  801ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ea7:	89 f2                	mov    %esi,%edx
  801ea9:	d3 e2                	shl    %cl,%edx
  801eab:	8b 44 24 14          	mov    0x14(%esp),%eax
  801eaf:	d3 e0                	shl    %cl,%eax
  801eb1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801eb5:	8b 44 24 14          	mov    0x14(%esp),%eax
  801eb9:	89 f9                	mov    %edi,%ecx
  801ebb:	d3 e8                	shr    %cl,%eax
  801ebd:	09 d0                	or     %edx,%eax
  801ebf:	d3 ee                	shr    %cl,%esi
  801ec1:	89 f2                	mov    %esi,%edx
  801ec3:	f7 74 24 18          	divl   0x18(%esp)
  801ec7:	89 d6                	mov    %edx,%esi
  801ec9:	f7 64 24 0c          	mull   0xc(%esp)
  801ecd:	89 c5                	mov    %eax,%ebp
  801ecf:	89 d1                	mov    %edx,%ecx
  801ed1:	39 d6                	cmp    %edx,%esi
  801ed3:	72 67                	jb     801f3c <__umoddi3+0x114>
  801ed5:	74 75                	je     801f4c <__umoddi3+0x124>
  801ed7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801edb:	29 e8                	sub    %ebp,%eax
  801edd:	19 ce                	sbb    %ecx,%esi
  801edf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ee3:	d3 e8                	shr    %cl,%eax
  801ee5:	89 f2                	mov    %esi,%edx
  801ee7:	89 f9                	mov    %edi,%ecx
  801ee9:	d3 e2                	shl    %cl,%edx
  801eeb:	09 d0                	or     %edx,%eax
  801eed:	89 f2                	mov    %esi,%edx
  801eef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ef3:	d3 ea                	shr    %cl,%edx
  801ef5:	83 c4 20             	add    $0x20,%esp
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    
  801efc:	85 c9                	test   %ecx,%ecx
  801efe:	75 0b                	jne    801f0b <__umoddi3+0xe3>
  801f00:	b8 01 00 00 00       	mov    $0x1,%eax
  801f05:	31 d2                	xor    %edx,%edx
  801f07:	f7 f1                	div    %ecx
  801f09:	89 c1                	mov    %eax,%ecx
  801f0b:	89 f0                	mov    %esi,%eax
  801f0d:	31 d2                	xor    %edx,%edx
  801f0f:	f7 f1                	div    %ecx
  801f11:	89 f8                	mov    %edi,%eax
  801f13:	e9 3e ff ff ff       	jmp    801e56 <__umoddi3+0x2e>
  801f18:	89 f2                	mov    %esi,%edx
  801f1a:	83 c4 20             	add    $0x20,%esp
  801f1d:	5e                   	pop    %esi
  801f1e:	5f                   	pop    %edi
  801f1f:	5d                   	pop    %ebp
  801f20:	c3                   	ret    
  801f21:	8d 76 00             	lea    0x0(%esi),%esi
  801f24:	39 f5                	cmp    %esi,%ebp
  801f26:	72 04                	jb     801f2c <__umoddi3+0x104>
  801f28:	39 f9                	cmp    %edi,%ecx
  801f2a:	77 06                	ja     801f32 <__umoddi3+0x10a>
  801f2c:	89 f2                	mov    %esi,%edx
  801f2e:	29 cf                	sub    %ecx,%edi
  801f30:	19 ea                	sbb    %ebp,%edx
  801f32:	89 f8                	mov    %edi,%eax
  801f34:	83 c4 20             	add    $0x20,%esp
  801f37:	5e                   	pop    %esi
  801f38:	5f                   	pop    %edi
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    
  801f3b:	90                   	nop
  801f3c:	89 d1                	mov    %edx,%ecx
  801f3e:	89 c5                	mov    %eax,%ebp
  801f40:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f44:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f48:	eb 8d                	jmp    801ed7 <__umoddi3+0xaf>
  801f4a:	66 90                	xchg   %ax,%ax
  801f4c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f50:	72 ea                	jb     801f3c <__umoddi3+0x114>
  801f52:	89 f1                	mov    %esi,%ecx
  801f54:	eb 81                	jmp    801ed7 <__umoddi3+0xaf>
