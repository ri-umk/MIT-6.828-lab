
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	c7 04 24 60 23 80 00 	movl   $0x802360,(%esp)
  800042:	e8 79 01 00 00       	call   8001c0 <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 a3 0e 00 00       	call   800eef <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 d8 23 80 00 	movl   $0x8023d8,(%esp)
  800059:	e8 62 01 00 00       	call   8001c0 <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 88 23 80 00 	movl   $0x802388,(%esp)
  800067:	e8 54 01 00 00       	call   8001c0 <cprintf>
	sys_yield();
  80006c:	e8 cd 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  800071:	e8 c8 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  800076:	e8 c3 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  80007b:	e8 be 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  800080:	e8 b9 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  800085:	e8 b4 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  80008a:	e8 af 0a 00 00       	call   800b3e <sys_yield>
	sys_yield();
  80008f:	e8 aa 0a 00 00       	call   800b3e <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 b0 23 80 00 	movl   $0x8023b0,(%esp)
  80009b:	e8 20 01 00 00       	call   8001c0 <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 25 0a 00 00       	call   800acd <sys_env_destroy>
}
  8000a8:	83 c4 14             	add    $0x14,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 10             	sub    $0x10,%esp
  8000b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8000be:	e8 5c 0a 00 00       	call   800b1f <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000cf:	c1 e0 07             	shl    $0x7,%eax
  8000d2:	29 d0                	sub    %edx,%eax
  8000d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000de:	85 f6                	test   %esi,%esi
  8000e0:	7e 07                	jle    8000e9 <libmain+0x39>
		binaryname = argv[0];
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ed:	89 34 24             	mov    %esi,(%esp)
  8000f0:	e8 3f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80010a:	e8 48 12 00 00       	call   801357 <close_all>
	sys_env_destroy(0);
  80010f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800116:	e8 b2 09 00 00       	call   800acd <sys_env_destroy>
}
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    
  80011d:	00 00                	add    %al,(%eax)
	...

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800133:	40                   	inc    %eax
  800134:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 19                	jne    800156 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80013d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800144:	00 
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 40 09 00 00       	call   800a90 <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800156:	ff 43 04             	incl   0x4(%ebx)
}
  800159:	83 c4 14             	add    $0x14,%esp
  80015c:	5b                   	pop    %ebx
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800183:	8b 45 08             	mov    0x8(%ebp),%eax
  800186:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 20 01 80 00 	movl   $0x800120,(%esp)
  80019b:	e8 82 01 00 00       	call   800322 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 d8 08 00 00       	call   800a90 <sys_cputs>

	return b.cnt;
}
  8001b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 87 ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    
	...

008001dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 3c             	sub    $0x3c,%esp
  8001e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e8:	89 d7                	mov    %edx,%edi
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	75 08                	jne    800208 <printnum+0x2c>
  800200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800203:	39 45 10             	cmp    %eax,0x10(%ebp)
  800206:	77 57                	ja     80025f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800208:	89 74 24 10          	mov    %esi,0x10(%esp)
  80020c:	4b                   	dec    %ebx
  80020d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800211:	8b 45 10             	mov    0x10(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80021c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	e8 d6 1e 00 00       	call   802110 <__udivdi3>
  80023a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	89 54 24 04          	mov    %edx,0x4(%esp)
  800249:	89 fa                	mov    %edi,%edx
  80024b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024e:	e8 89 ff ff ff       	call   8001dc <printnum>
  800253:	eb 0f                	jmp    800264 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	4b                   	dec    %ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f f1                	jg     800255 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027a:	00 
  80027b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	e8 a3 1f 00 00       	call   802230 <__umoddi3>
  80028d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800291:	0f be 80 00 24 80 00 	movsbl 0x802400(%eax),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029e:	83 c4 3c             	add    $0x3c,%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a9:	83 fa 01             	cmp    $0x1,%edx
  8002ac:	7e 0e                	jle    8002bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x38>
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 10                	je     8002d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 08                	jae    8002f8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 0a                	mov    %cl,(%edx)
  8002f5:	42                   	inc    %edx
  8002f6:	89 10                	mov    %edx,(%eax)
}
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800300:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 10             	mov    0x10(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800311:	89 44 24 04          	mov    %eax,0x4(%esp)
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 02 00 00 00       	call   800322 <vprintfmt>
	va_end(ap);
}
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 4c             	sub    $0x4c,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032e:	8b 75 10             	mov    0x10(%ebp),%esi
  800331:	eb 12                	jmp    800345 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800333:	85 c0                	test   %eax,%eax
  800335:	0f 84 6b 03 00 00    	je     8006a6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80033b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800345:	0f b6 06             	movzbl (%esi),%eax
  800348:	46                   	inc    %esi
  800349:	83 f8 25             	cmp    $0x25,%eax
  80034c:	75 e5                	jne    800333 <vprintfmt+0x11>
  80034e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800359:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800365:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036a:	eb 26                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800373:	eb 1d                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800378:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80037c:	eb 14                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800381:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800388:	eb 08                	jmp    800392 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80038d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	0f b6 06             	movzbl (%esi),%eax
  800395:	8d 56 01             	lea    0x1(%esi),%edx
  800398:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80039b:	8a 16                	mov    (%esi),%dl
  80039d:	83 ea 23             	sub    $0x23,%edx
  8003a0:	80 fa 55             	cmp    $0x55,%dl
  8003a3:	0f 87 e1 02 00 00    	ja     80068a <vprintfmt+0x368>
  8003a9:	0f b6 d2             	movzbl %dl,%edx
  8003ac:	ff 24 95 40 25 80 00 	jmp    *0x802540(,%edx,4)
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003be:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003c2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c8:	83 fa 09             	cmp    $0x9,%edx
  8003cb:	77 2a                	ja     8003f7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ce:	eb eb                	jmp    8003bb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 50 04             	lea    0x4(%eax),%edx
  8003d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 17                	jmp    8003f7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e4:	78 98                	js     80037e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e9:	eb a7                	jmp    800392 <vprintfmt+0x70>
  8003eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f5:	eb 9b                	jmp    800392 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fb:	79 95                	jns    800392 <vprintfmt+0x70>
  8003fd:	eb 8b                	jmp    80038a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ff:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800403:	eb 8d                	jmp    800392 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041d:	e9 23 ff ff ff       	jmp    800345 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	79 02                	jns    800433 <vprintfmt+0x111>
  800431:	f7 d8                	neg    %eax
  800433:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 0f             	cmp    $0xf,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x123>
  80043a:	8b 04 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	75 23                	jne    800468 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800445:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800449:	c7 44 24 08 18 24 80 	movl   $0x802418,0x8(%esp)
  800450:	00 
  800451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 9a fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 dd fe ff ff       	jmp    800345 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046c:	c7 44 24 08 0a 29 80 	movl   $0x80290a,0x8(%esp)
  800473:	00 
  800474:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800478:	8b 55 08             	mov    0x8(%ebp),%edx
  80047b:	89 14 24             	mov    %edx,(%esp)
  80047e:	e8 77 fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800486:	e9 ba fe ff ff       	jmp    800345 <vprintfmt+0x23>
  80048b:	89 f9                	mov    %edi,%ecx
  80048d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 30                	mov    (%eax),%esi
  80049e:	85 f6                	test   %esi,%esi
  8004a0:	75 05                	jne    8004a7 <vprintfmt+0x185>
				p = "(null)";
  8004a2:	be 11 24 80 00       	mov    $0x802411,%esi
			if (width > 0 && padc != '-')
  8004a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ab:	0f 8e 84 00 00 00    	jle    800535 <vprintfmt+0x213>
  8004b1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b5:	74 7e                	je     800535 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bb:	89 34 24             	mov    %esi,(%esp)
  8004be:	e8 8b 02 00 00       	call   80074e <strnlen>
  8004c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c6:	29 c2                	sub    %eax,%edx
  8004c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004cb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004cf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004d5:	89 de                	mov    %ebx,%esi
  8004d7:	89 d3                	mov    %edx,%ebx
  8004d9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	eb 0b                	jmp    8004e8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e1:	89 3c 24             	mov    %edi,(%esp)
  8004e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	4b                   	dec    %ebx
  8004e8:	85 db                	test   %ebx,%ebx
  8004ea:	7f f1                	jg     8004dd <vprintfmt+0x1bb>
  8004ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004ef:	89 f3                	mov    %esi,%ebx
  8004f1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 05                	jns    800500 <vprintfmt+0x1de>
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800508:	eb 2b                	jmp    800535 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050e:	74 18                	je     800528 <vprintfmt+0x206>
  800510:	8d 50 e0             	lea    -0x20(%eax),%edx
  800513:	83 fa 5e             	cmp    $0x5e,%edx
  800516:	76 10                	jbe    800528 <vprintfmt+0x206>
					putch('?', putdat);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	eb 0a                	jmp    800532 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800528:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	ff 4d e4             	decl   -0x1c(%ebp)
  800535:	0f be 06             	movsbl (%esi),%eax
  800538:	46                   	inc    %esi
  800539:	85 c0                	test   %eax,%eax
  80053b:	74 21                	je     80055e <vprintfmt+0x23c>
  80053d:	85 ff                	test   %edi,%edi
  80053f:	78 c9                	js     80050a <vprintfmt+0x1e8>
  800541:	4f                   	dec    %edi
  800542:	79 c6                	jns    80050a <vprintfmt+0x1e8>
  800544:	8b 7d 08             	mov    0x8(%ebp),%edi
  800547:	89 de                	mov    %ebx,%esi
  800549:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054c:	eb 18                	jmp    800566 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800552:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800559:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055b:	4b                   	dec    %ebx
  80055c:	eb 08                	jmp    800566 <vprintfmt+0x244>
  80055e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800561:	89 de                	mov    %ebx,%esi
  800563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800566:	85 db                	test   %ebx,%ebx
  800568:	7f e4                	jg     80054e <vprintfmt+0x22c>
  80056a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800572:	e9 ce fd ff ff       	jmp    800345 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800577:	83 f9 01             	cmp    $0x1,%ecx
  80057a:	7e 10                	jle    80058c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 08             	lea    0x8(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 30                	mov    (%eax),%esi
  800587:	8b 78 04             	mov    0x4(%eax),%edi
  80058a:	eb 26                	jmp    8005b2 <vprintfmt+0x290>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 12                	je     8005a2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	89 f7                	mov    %esi,%edi
  80059d:	c1 ff 1f             	sar    $0x1f,%edi
  8005a0:	eb 10                	jmp    8005b2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 30                	mov    (%eax),%esi
  8005ad:	89 f7                	mov    %esi,%edi
  8005af:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	78 0a                	js     8005c0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 8c 00 00 00       	jmp    80064c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ce:	f7 de                	neg    %esi
  8005d0:	83 d7 00             	adc    $0x0,%edi
  8005d3:	f7 df                	neg    %edi
			}
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005da:	eb 70                	jmp    80064c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005dc:	89 ca                	mov    %ecx,%edx
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 c0 fc ff ff       	call   8002a6 <getuint>
  8005e6:	89 c6                	mov    %eax,%esi
  8005e8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ef:	eb 5b                	jmp    80064c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005f1:	89 ca                	mov    %ecx,%edx
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 ab fc ff ff       	call   8002a6 <getuint>
  8005fb:	89 c6                	mov    %eax,%esi
  8005fd:	89 d7                	mov    %edx,%edi
			base = 8;
  8005ff:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800604:	eb 46                	jmp    80064c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800606:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062b:	8b 30                	mov    (%eax),%esi
  80062d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800632:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800637:	eb 13                	jmp    80064c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 63 fc ff ff       	call   8002a6 <getuint>
  800643:	89 c6                	mov    %eax,%esi
  800645:	89 d7                	mov    %edx,%edi
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800650:	89 54 24 10          	mov    %edx,0x10(%esp)
  800654:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800657:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065f:	89 34 24             	mov    %esi,(%esp)
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	89 da                	mov    %ebx,%edx
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	e8 6c fb ff ff       	call   8001dc <printnum>
			break;
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800673:	e9 cd fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800685:	e9 bb fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	eb 01                	jmp    80069b <vprintfmt+0x379>
  80069a:	4e                   	dec    %esi
  80069b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069f:	75 f9                	jne    80069a <vprintfmt+0x378>
  8006a1:	e9 9f fc ff ff       	jmp    800345 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006a6:	83 c4 4c             	add    $0x4c,%esp
  8006a9:	5b                   	pop    %ebx
  8006aa:	5e                   	pop    %esi
  8006ab:	5f                   	pop    %edi
  8006ac:	5d                   	pop    %ebp
  8006ad:	c3                   	ret    

008006ae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	83 ec 28             	sub    $0x28,%esp
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 30                	je     8006ff <vsnprintf+0x51>
  8006cf:	85 d2                	test   %edx,%edx
  8006d1:	7e 33                	jle    800706 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006da:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	c7 04 24 e0 02 80 00 	movl   $0x8002e0,(%esp)
  8006ef:	e8 2e fc ff ff       	call   800322 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	eb 0c                	jmp    80070b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800704:	eb 05                	jmp    80070b <vsnprintf+0x5d>
  800706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    

0080070d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800716:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	e8 7b ff ff ff       	call   8006ae <vsnprintf>
	va_end(ap);

	return rc;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    
  800735:	00 00                	add    %al,(%eax)
	...

00800738 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	eb 01                	jmp    800746 <strlen+0xe>
		n++;
  800745:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	75 f9                	jne    800745 <strlen+0xd>
		n++;
	return n;
}
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	eb 01                	jmp    80075f <strnlen+0x11>
		n++;
  80075e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	39 d0                	cmp    %edx,%eax
  800761:	74 06                	je     800769 <strnlen+0x1b>
  800763:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800767:	75 f5                	jne    80075e <strnlen+0x10>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800775:	ba 00 00 00 00       	mov    $0x0,%edx
  80077a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80077d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800780:	42                   	inc    %edx
  800781:	84 c9                	test   %cl,%cl
  800783:	75 f5                	jne    80077a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800792:	89 1c 24             	mov    %ebx,(%esp)
  800795:	e8 9e ff ff ff       	call   800738 <strlen>
	strcpy(dst + len, src);
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a1:	01 d8                	add    %ebx,%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	e8 c0 ff ff ff       	call   80076b <strcpy>
	return dst;
}
  8007ab:	89 d8                	mov    %ebx,%eax
  8007ad:	83 c4 08             	add    $0x8,%esp
  8007b0:	5b                   	pop    %ebx
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	56                   	push   %esi
  8007b7:	53                   	push   %ebx
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007be:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c6:	eb 0c                	jmp    8007d4 <strncpy+0x21>
		*dst++ = *src;
  8007c8:	8a 1a                	mov    (%edx),%bl
  8007ca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d3:	41                   	inc    %ecx
  8007d4:	39 f1                	cmp    %esi,%ecx
  8007d6:	75 f0                	jne    8007c8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	75 0a                	jne    8007f8 <strlcpy+0x1c>
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	eb 1a                	jmp    80080c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f2:	88 18                	mov    %bl,(%eax)
  8007f4:	40                   	inc    %eax
  8007f5:	41                   	inc    %ecx
  8007f6:	eb 02                	jmp    8007fa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007fa:	4a                   	dec    %edx
  8007fb:	74 0a                	je     800807 <strlcpy+0x2b>
  8007fd:	8a 19                	mov    (%ecx),%bl
  8007ff:	84 db                	test   %bl,%bl
  800801:	75 ef                	jne    8007f2 <strlcpy+0x16>
  800803:	89 c2                	mov    %eax,%edx
  800805:	eb 02                	jmp    800809 <strlcpy+0x2d>
  800807:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800809:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80080c:	29 f0                	sub    %esi,%eax
}
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081b:	eb 02                	jmp    80081f <strcmp+0xd>
		p++, q++;
  80081d:	41                   	inc    %ecx
  80081e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081f:	8a 01                	mov    (%ecx),%al
  800821:	84 c0                	test   %al,%al
  800823:	74 04                	je     800829 <strcmp+0x17>
  800825:	3a 02                	cmp    (%edx),%al
  800827:	74 f4                	je     80081d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800829:	0f b6 c0             	movzbl %al,%eax
  80082c:	0f b6 12             	movzbl (%edx),%edx
  80082f:	29 d0                	sub    %edx,%eax
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800840:	eb 03                	jmp    800845 <strncmp+0x12>
		n--, p++, q++;
  800842:	4a                   	dec    %edx
  800843:	40                   	inc    %eax
  800844:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800845:	85 d2                	test   %edx,%edx
  800847:	74 14                	je     80085d <strncmp+0x2a>
  800849:	8a 18                	mov    (%eax),%bl
  80084b:	84 db                	test   %bl,%bl
  80084d:	74 04                	je     800853 <strncmp+0x20>
  80084f:	3a 19                	cmp    (%ecx),%bl
  800851:	74 ef                	je     800842 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 00             	movzbl (%eax),%eax
  800856:	0f b6 11             	movzbl (%ecx),%edx
  800859:	29 d0                	sub    %edx,%eax
  80085b:	eb 05                	jmp    800862 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800862:	5b                   	pop    %ebx
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086e:	eb 05                	jmp    800875 <strchr+0x10>
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 0c                	je     800880 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800874:	40                   	inc    %eax
  800875:	8a 10                	mov    (%eax),%dl
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f5                	jne    800870 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088b:	eb 05                	jmp    800892 <strfind+0x10>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 07                	je     800898 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800891:	40                   	inc    %eax
  800892:	8a 10                	mov    (%eax),%dl
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f5                	jne    80088d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	74 30                	je     8008dd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 25                	jne    8008da <memset+0x40>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 20                	jne    8008da <memset+0x40>
		c &= 0xFF;
  8008ba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bd:	89 d3                	mov    %edx,%ebx
  8008bf:	c1 e3 08             	shl    $0x8,%ebx
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	c1 e6 18             	shl    $0x18,%esi
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	c1 e0 10             	shl    $0x10,%eax
  8008cc:	09 f0                	or     %esi,%eax
  8008ce:	09 d0                	or     %edx,%eax
  8008d0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d5:	fc                   	cld    
  8008d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d8:	eb 03                	jmp    8008dd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008da:	fc                   	cld    
  8008db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008dd:	89 f8                	mov    %edi,%eax
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5f                   	pop    %edi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f2:	39 c6                	cmp    %eax,%esi
  8008f4:	73 34                	jae    80092a <memmove+0x46>
  8008f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f9:	39 d0                	cmp    %edx,%eax
  8008fb:	73 2d                	jae    80092a <memmove+0x46>
		s += n;
		d += n;
  8008fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800900:	f6 c2 03             	test   $0x3,%dl
  800903:	75 1b                	jne    800920 <memmove+0x3c>
  800905:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090b:	75 13                	jne    800920 <memmove+0x3c>
  80090d:	f6 c1 03             	test   $0x3,%cl
  800910:	75 0e                	jne    800920 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 07                	jmp    800927 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	4f                   	dec    %edi
  800921:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800924:	fd                   	std    
  800925:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800927:	fc                   	cld    
  800928:	eb 20                	jmp    80094a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800930:	75 13                	jne    800945 <memmove+0x61>
  800932:	a8 03                	test   $0x3,%al
  800934:	75 0f                	jne    800945 <memmove+0x61>
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 0a                	jne    800945 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 05                	jmp    80094a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800954:	8b 45 10             	mov    0x10(%ebp),%eax
  800957:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	e8 77 ff ff ff       	call   8008e4 <memmove>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	ba 00 00 00 00       	mov    $0x0,%edx
  800983:	eb 16                	jmp    80099b <memcmp+0x2c>
		if (*s1 != *s2)
  800985:	8a 04 17             	mov    (%edi,%edx,1),%al
  800988:	42                   	inc    %edx
  800989:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80098d:	38 c8                	cmp    %cl,%al
  80098f:	74 0a                	je     80099b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 c9             	movzbl %cl,%ecx
  800997:	29 c8                	sub    %ecx,%eax
  800999:	eb 09                	jmp    8009a4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099b:	39 da                	cmp    %ebx,%edx
  80099d:	75 e6                	jne    800985 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5f                   	pop    %edi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b2:	89 c2                	mov    %eax,%edx
  8009b4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b7:	eb 05                	jmp    8009be <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b9:	38 08                	cmp    %cl,(%eax)
  8009bb:	74 05                	je     8009c2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bd:	40                   	inc    %eax
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	72 f7                	jb     8009b9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d0:	eb 01                	jmp    8009d3 <strtol+0xf>
		s++;
  8009d2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d3:	8a 02                	mov    (%edx),%al
  8009d5:	3c 20                	cmp    $0x20,%al
  8009d7:	74 f9                	je     8009d2 <strtol+0xe>
  8009d9:	3c 09                	cmp    $0x9,%al
  8009db:	74 f5                	je     8009d2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009dd:	3c 2b                	cmp    $0x2b,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x25>
		s++;
  8009e1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e7:	eb 13                	jmp    8009fc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e9:	3c 2d                	cmp    $0x2d,%al
  8009eb:	75 0a                	jne    8009f7 <strtol+0x33>
		s++, neg = 1;
  8009ed:	8d 52 01             	lea    0x1(%edx),%edx
  8009f0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f5:	eb 05                	jmp    8009fc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	74 05                	je     800a05 <strtol+0x41>
  800a00:	83 fb 10             	cmp    $0x10,%ebx
  800a03:	75 28                	jne    800a2d <strtol+0x69>
  800a05:	8a 02                	mov    (%edx),%al
  800a07:	3c 30                	cmp    $0x30,%al
  800a09:	75 10                	jne    800a1b <strtol+0x57>
  800a0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a0f:	75 0a                	jne    800a1b <strtol+0x57>
		s += 2, base = 16;
  800a11:	83 c2 02             	add    $0x2,%edx
  800a14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a19:	eb 12                	jmp    800a2d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a1b:	85 db                	test   %ebx,%ebx
  800a1d:	75 0e                	jne    800a2d <strtol+0x69>
  800a1f:	3c 30                	cmp    $0x30,%al
  800a21:	75 05                	jne    800a28 <strtol+0x64>
		s++, base = 8;
  800a23:	42                   	inc    %edx
  800a24:	b3 08                	mov    $0x8,%bl
  800a26:	eb 05                	jmp    800a2d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a28:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a34:	8a 0a                	mov    (%edx),%cl
  800a36:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a39:	80 fb 09             	cmp    $0x9,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x82>
			dig = *s - '0';
  800a3e:	0f be c9             	movsbl %cl,%ecx
  800a41:	83 e9 30             	sub    $0x30,%ecx
  800a44:	eb 1e                	jmp    800a64 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a46:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 08                	ja     800a56 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a4e:	0f be c9             	movsbl %cl,%ecx
  800a51:	83 e9 57             	sub    $0x57,%ecx
  800a54:	eb 0e                	jmp    800a64 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a56:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 12                	ja     800a70 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a5e:	0f be c9             	movsbl %cl,%ecx
  800a61:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a64:	39 f1                	cmp    %esi,%ecx
  800a66:	7d 0c                	jge    800a74 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a68:	42                   	inc    %edx
  800a69:	0f af c6             	imul   %esi,%eax
  800a6c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a6e:	eb c4                	jmp    800a34 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a70:	89 c1                	mov    %eax,%ecx
  800a72:	eb 02                	jmp    800a76 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a74:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7a:	74 05                	je     800a81 <strtol+0xbd>
		*endptr = (char *) s;
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a81:	85 ff                	test   %edi,%edi
  800a83:	74 04                	je     800a89 <strtol+0xc5>
  800a85:	89 c8                	mov    %ecx,%eax
  800a87:	f7 d8                	neg    %eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    
	...

00800a90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	89 c6                	mov    %eax,%esi
  800aa7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <sys_cgetc>:

int
sys_cgetc(void)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab9:	b8 01 00 00 00       	mov    $0x1,%eax
  800abe:	89 d1                	mov    %edx,%ecx
  800ac0:	89 d3                	mov    %edx,%ebx
  800ac2:	89 d7                	mov    %edx,%edi
  800ac4:	89 d6                	mov    %edx,%esi
  800ac6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	89 cb                	mov    %ecx,%ebx
  800ae5:	89 cf                	mov    %ecx,%edi
  800ae7:	89 ce                	mov    %ecx,%esi
  800ae9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	7e 28                	jle    800b17 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800af3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800afa:	00 
  800afb:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800b02:	00 
  800b03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b0a:	00 
  800b0b:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800b12:	e8 d1 13 00 00       	call   801ee8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b17:	83 c4 2c             	add    $0x2c,%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_yield>:

void
sys_yield(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	be 00 00 00 00       	mov    $0x0,%esi
  800b6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	89 f7                	mov    %esi,%edi
  800b7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 28                	jle    800ba9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b85:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800b94:	00 
  800b95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9c:	00 
  800b9d:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800ba4:	e8 3f 13 00 00       	call   801ee8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba9:	83 c4 2c             	add    $0x2c,%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 28                	jle    800bfc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bdf:	00 
  800be0:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800be7:	00 
  800be8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bef:	00 
  800bf0:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800bf7:	e8 ec 12 00 00       	call   801ee8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfc:	83 c4 2c             	add    $0x2c,%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 06 00 00 00       	mov    $0x6,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800c4a:	e8 99 12 00 00       	call   801ee8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800c9d:	e8 46 12 00 00       	call   801ee8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800cf0:	e8 f3 11 00 00       	call   801ee8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800d43:	e8 a0 11 00 00       	call   801ee8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	be 00 00 00 00       	mov    $0x0,%esi
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 28                	jle    800dbd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d99:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800da0:	00 
  800da1:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800da8:	00 
  800da9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db0:	00 
  800db1:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800db8:	e8 2b 11 00 00       	call   801ee8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbd:	83 c4 2c             	add    $0x2c,%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
  800dc5:	00 00                	add    %al,(%eax)
	...

00800dc8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 24             	sub    $0x24,%esp
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800dd4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dd8:	75 2d                	jne    800e07 <pgfault+0x3f>
  800dda:	89 d8                	mov    %ebx,%eax
  800ddc:	c1 e8 0c             	shr    $0xc,%eax
  800ddf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800de6:	f6 c4 08             	test   $0x8,%ah
  800de9:	75 1c                	jne    800e07 <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800deb:	c7 44 24 08 2c 27 80 	movl   $0x80272c,0x8(%esp)
  800df2:	00 
  800df3:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800dfa:	00 
  800dfb:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800e02:	e8 e1 10 00 00       	call   801ee8 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800e07:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e16:	00 
  800e17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e1e:	e8 3a fd ff ff       	call   800b5d <sys_page_alloc>
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 20                	jns    800e47 <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800e27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2b:	c7 44 24 08 9b 27 80 	movl   $0x80279b,0x8(%esp)
  800e32:	00 
  800e33:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800e3a:	00 
  800e3b:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800e42:	e8 a1 10 00 00       	call   801ee8 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e47:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e4d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e54:	00 
  800e55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e59:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e60:	e8 e9 fa ff ff       	call   80094e <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e65:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e6c:	00 
  800e6d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e71:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e78:	00 
  800e79:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e80:	00 
  800e81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e88:	e8 24 fd ff ff       	call   800bb1 <sys_page_map>
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	79 20                	jns    800eb1 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  800e91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e95:	c7 44 24 08 ae 27 80 	movl   $0x8027ae,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800eac:	e8 37 10 00 00       	call   801ee8 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800eb1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec0:	e8 3f fd ff ff       	call   800c04 <sys_page_unmap>
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	79 20                	jns    800ee9 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  800ec9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ecd:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800edc:	00 
  800edd:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800ee4:	e8 ff 0f 00 00       	call   801ee8 <_panic>
}
  800ee9:	83 c4 24             	add    $0x24,%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  800ef8:	c7 04 24 c8 0d 80 00 	movl   $0x800dc8,(%esp)
  800eff:	e8 3c 10 00 00       	call   801f40 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f04:	ba 07 00 00 00       	mov    $0x7,%edx
  800f09:	89 d0                	mov    %edx,%eax
  800f0b:	cd 30                	int    $0x30
  800f0d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f10:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	79 1c                	jns    800f33 <fork+0x44>
		panic("sys_exofork failed\n");
  800f17:	c7 44 24 08 d2 27 80 	movl   $0x8027d2,0x8(%esp)
  800f1e:	00 
  800f1f:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  800f26:	00 
  800f27:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800f2e:	e8 b5 0f 00 00       	call   801ee8 <_panic>
	if(c_envid == 0){
  800f33:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f37:	75 25                	jne    800f5e <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f39:	e8 e1 fb ff ff       	call   800b1f <sys_getenvid>
  800f3e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f4a:	c1 e0 07             	shl    $0x7,%eax
  800f4d:	29 d0                	sub    %edx,%eax
  800f4f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f54:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f59:	e9 e3 01 00 00       	jmp    801141 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  800f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	c1 e8 16             	shr    $0x16,%eax
  800f68:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6f:	a8 01                	test   $0x1,%al
  800f71:	0f 84 0b 01 00 00    	je     801082 <fork+0x193>
  800f77:	89 de                	mov    %ebx,%esi
  800f79:	c1 ee 0c             	shr    $0xc,%esi
  800f7c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f83:	a8 05                	test   $0x5,%al
  800f85:	0f 84 f7 00 00 00    	je     801082 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  800f8b:	89 f7                	mov    %esi,%edi
  800f8d:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  800f90:	e8 8a fb ff ff       	call   800b1f <sys_getenvid>
  800f95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f98:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f9f:	a8 02                	test   $0x2,%al
  800fa1:	75 10                	jne    800fb3 <fork+0xc4>
  800fa3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800faa:	f6 c4 08             	test   $0x8,%ah
  800fad:	0f 84 89 00 00 00    	je     80103c <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  800fb3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fba:	00 
  800fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fcd:	89 04 24             	mov    %eax,(%esp)
  800fd0:	e8 dc fb ff ff       	call   800bb1 <sys_page_map>
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 20                	jns    800ff9 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  800fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fdd:	c7 44 24 08 e6 27 80 	movl   $0x8027e6,0x8(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800ff4:	e8 ef 0e 00 00       	call   801ee8 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  800ff9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801000:	00 
  801001:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801005:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801008:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801010:	89 04 24             	mov    %eax,(%esp)
  801013:	e8 99 fb ff ff       	call   800bb1 <sys_page_map>
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 66                	jns    801082 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  80101c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801020:	c7 44 24 08 e6 27 80 	movl   $0x8027e6,0x8(%esp)
  801027:	00 
  801028:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  80102f:	00 
  801030:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  801037:	e8 ac 0e 00 00       	call   801ee8 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  80103c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801043:	00 
  801044:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801048:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80104b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801056:	89 04 24             	mov    %eax,(%esp)
  801059:	e8 53 fb ff ff       	call   800bb1 <sys_page_map>
  80105e:	85 c0                	test   %eax,%eax
  801060:	79 20                	jns    801082 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  801062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801066:	c7 44 24 08 e6 27 80 	movl   $0x8027e6,0x8(%esp)
  80106d:	00 
  80106e:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801075:	00 
  801076:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  80107d:	e8 66 0e 00 00       	call   801ee8 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  801082:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801088:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80108e:	0f 85 cf fe ff ff    	jne    800f63 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801094:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80109b:	00 
  80109c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010a3:	ee 
  8010a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010a7:	89 04 24             	mov    %eax,(%esp)
  8010aa:	e8 ae fa ff ff       	call   800b5d <sys_page_alloc>
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 20                	jns    8010d3 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  8010b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b7:	c7 44 24 08 f8 27 80 	movl   $0x8027f8,0x8(%esp)
  8010be:	00 
  8010bf:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8010c6:	00 
  8010c7:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  8010ce:	e8 15 0e 00 00       	call   801ee8 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  8010d3:	c7 44 24 04 8c 1f 80 	movl   $0x801f8c,0x4(%esp)
  8010da:	00 
  8010db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010de:	89 04 24             	mov    %eax,(%esp)
  8010e1:	e8 17 fc ff ff       	call   800cfd <sys_env_set_pgfault_upcall>
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	79 20                	jns    80110a <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8010ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ee:	c7 44 24 08 70 27 80 	movl   $0x802770,0x8(%esp)
  8010f5:	00 
  8010f6:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8010fd:	00 
  8010fe:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  801105:	e8 de 0d 00 00       	call   801ee8 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  80110a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801111:	00 
  801112:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	e8 3a fb ff ff       	call   800c57 <sys_env_set_status>
  80111d:	85 c0                	test   %eax,%eax
  80111f:	79 20                	jns    801141 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  801121:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801125:	c7 44 24 08 0c 28 80 	movl   $0x80280c,0x8(%esp)
  80112c:	00 
  80112d:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801134:	00 
  801135:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  80113c:	e8 a7 0d 00 00       	call   801ee8 <_panic>
 
	return c_envid;	
}
  801141:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801144:	83 c4 3c             	add    $0x3c,%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <sfork>:

// Challenge!
int
sfork(void)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801152:	c7 44 24 08 24 28 80 	movl   $0x802824,0x8(%esp)
  801159:	00 
  80115a:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801161:	00 
  801162:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  801169:	e8 7a 0d 00 00       	call   801ee8 <_panic>
	...

00801170 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	05 00 00 00 30       	add    $0x30000000,%eax
  80117b:	c1 e8 0c             	shr    $0xc,%eax
}
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	89 04 24             	mov    %eax,(%esp)
  80118c:	e8 df ff ff ff       	call   801170 <fd2num>
  801191:	05 20 00 0d 00       	add    $0xd0020,%eax
  801196:	c1 e0 0c             	shl    $0xc,%eax
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	53                   	push   %ebx
  80119f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011a2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011a7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	c1 ea 16             	shr    $0x16,%edx
  8011ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b5:	f6 c2 01             	test   $0x1,%dl
  8011b8:	74 11                	je     8011cb <fd_alloc+0x30>
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	c1 ea 0c             	shr    $0xc,%edx
  8011bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c6:	f6 c2 01             	test   $0x1,%dl
  8011c9:	75 09                	jne    8011d4 <fd_alloc+0x39>
			*fd_store = fd;
  8011cb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d2:	eb 17                	jmp    8011eb <fd_alloc+0x50>
  8011d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011de:	75 c7                	jne    8011a7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011eb:	5b                   	pop    %ebx
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f4:	83 f8 1f             	cmp    $0x1f,%eax
  8011f7:	77 36                	ja     80122f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011fe:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801201:	89 c2                	mov    %eax,%edx
  801203:	c1 ea 16             	shr    $0x16,%edx
  801206:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120d:	f6 c2 01             	test   $0x1,%dl
  801210:	74 24                	je     801236 <fd_lookup+0x48>
  801212:	89 c2                	mov    %eax,%edx
  801214:	c1 ea 0c             	shr    $0xc,%edx
  801217:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121e:	f6 c2 01             	test   $0x1,%dl
  801221:	74 1a                	je     80123d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801223:	8b 55 0c             	mov    0xc(%ebp),%edx
  801226:	89 02                	mov    %eax,(%edx)
	return 0;
  801228:	b8 00 00 00 00       	mov    $0x0,%eax
  80122d:	eb 13                	jmp    801242 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801234:	eb 0c                	jmp    801242 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801236:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123b:	eb 05                	jmp    801242 <fd_lookup+0x54>
  80123d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	53                   	push   %ebx
  801248:	83 ec 14             	sub    $0x14,%esp
  80124b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801251:	ba 00 00 00 00       	mov    $0x0,%edx
  801256:	eb 0e                	jmp    801266 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801258:	39 08                	cmp    %ecx,(%eax)
  80125a:	75 09                	jne    801265 <dev_lookup+0x21>
			*dev = devtab[i];
  80125c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	eb 33                	jmp    801298 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801265:	42                   	inc    %edx
  801266:	8b 04 95 b8 28 80 00 	mov    0x8028b8(,%edx,4),%eax
  80126d:	85 c0                	test   %eax,%eax
  80126f:	75 e7                	jne    801258 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801271:	a1 04 40 80 00       	mov    0x804004,%eax
  801276:	8b 40 48             	mov    0x48(%eax),%eax
  801279:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80127d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801281:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801288:	e8 33 ef ff ff       	call   8001c0 <cprintf>
	*dev = 0;
  80128d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801293:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801298:	83 c4 14             	add    $0x14,%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 30             	sub    $0x30,%esp
  8012a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a9:	8a 45 0c             	mov    0xc(%ebp),%al
  8012ac:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012af:	89 34 24             	mov    %esi,(%esp)
  8012b2:	e8 b9 fe ff ff       	call   801170 <fd2num>
  8012b7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012be:	89 04 24             	mov    %eax,(%esp)
  8012c1:	e8 28 ff ff ff       	call   8011ee <fd_lookup>
  8012c6:	89 c3                	mov    %eax,%ebx
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 05                	js     8012d1 <fd_close+0x33>
	    || fd != fd2)
  8012cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012cf:	74 0d                	je     8012de <fd_close+0x40>
		return (must_exist ? r : 0);
  8012d1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012d5:	75 46                	jne    80131d <fd_close+0x7f>
  8012d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012dc:	eb 3f                	jmp    80131d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e5:	8b 06                	mov    (%esi),%eax
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 55 ff ff ff       	call   801244 <dev_lookup>
  8012ef:	89 c3                	mov    %eax,%ebx
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 18                	js     80130d <fd_close+0x6f>
		if (dev->dev_close)
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	8b 40 10             	mov    0x10(%eax),%eax
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	74 09                	je     801308 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ff:	89 34 24             	mov    %esi,(%esp)
  801302:	ff d0                	call   *%eax
  801304:	89 c3                	mov    %eax,%ebx
  801306:	eb 05                	jmp    80130d <fd_close+0x6f>
		else
			r = 0;
  801308:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80130d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801311:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801318:	e8 e7 f8 ff ff       	call   800c04 <sys_page_unmap>
	return r;
}
  80131d:	89 d8                	mov    %ebx,%eax
  80131f:	83 c4 30             	add    $0x30,%esp
  801322:	5b                   	pop    %ebx
  801323:	5e                   	pop    %esi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
  801336:	89 04 24             	mov    %eax,(%esp)
  801339:	e8 b0 fe ff ff       	call   8011ee <fd_lookup>
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 13                	js     801355 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801342:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801349:	00 
  80134a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134d:	89 04 24             	mov    %eax,(%esp)
  801350:	e8 49 ff ff ff       	call   80129e <fd_close>
}
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <close_all>:

void
close_all(void)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	53                   	push   %ebx
  80135b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80135e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801363:	89 1c 24             	mov    %ebx,(%esp)
  801366:	e8 bb ff ff ff       	call   801326 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136b:	43                   	inc    %ebx
  80136c:	83 fb 20             	cmp    $0x20,%ebx
  80136f:	75 f2                	jne    801363 <close_all+0xc>
		close(i);
}
  801371:	83 c4 14             	add    $0x14,%esp
  801374:	5b                   	pop    %ebx
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	57                   	push   %edi
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	83 ec 4c             	sub    $0x4c,%esp
  801380:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801383:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
  80138d:	89 04 24             	mov    %eax,(%esp)
  801390:	e8 59 fe ff ff       	call   8011ee <fd_lookup>
  801395:	89 c3                	mov    %eax,%ebx
  801397:	85 c0                	test   %eax,%eax
  801399:	0f 88 e1 00 00 00    	js     801480 <dup+0x109>
		return r;
	close(newfdnum);
  80139f:	89 3c 24             	mov    %edi,(%esp)
  8013a2:	e8 7f ff ff ff       	call   801326 <close>

	newfd = INDEX2FD(newfdnum);
  8013a7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013ad:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b3:	89 04 24             	mov    %eax,(%esp)
  8013b6:	e8 c5 fd ff ff       	call   801180 <fd2data>
  8013bb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013bd:	89 34 24             	mov    %esi,(%esp)
  8013c0:	e8 bb fd ff ff       	call   801180 <fd2data>
  8013c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c8:	89 d8                	mov    %ebx,%eax
  8013ca:	c1 e8 16             	shr    $0x16,%eax
  8013cd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013d4:	a8 01                	test   $0x1,%al
  8013d6:	74 46                	je     80141e <dup+0xa7>
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	c1 e8 0c             	shr    $0xc,%eax
  8013dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e4:	f6 c2 01             	test   $0x1,%dl
  8013e7:	74 35                	je     80141e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801400:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801407:	00 
  801408:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80140c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801413:	e8 99 f7 ff ff       	call   800bb1 <sys_page_map>
  801418:	89 c3                	mov    %eax,%ebx
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 3b                	js     801459 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801421:	89 c2                	mov    %eax,%edx
  801423:	c1 ea 0c             	shr    $0xc,%edx
  801426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801433:	89 54 24 10          	mov    %edx,0x10(%esp)
  801437:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80143b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801442:	00 
  801443:	89 44 24 04          	mov    %eax,0x4(%esp)
  801447:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144e:	e8 5e f7 ff ff       	call   800bb1 <sys_page_map>
  801453:	89 c3                	mov    %eax,%ebx
  801455:	85 c0                	test   %eax,%eax
  801457:	79 25                	jns    80147e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801459:	89 74 24 04          	mov    %esi,0x4(%esp)
  80145d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801464:	e8 9b f7 ff ff       	call   800c04 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801469:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80146c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801470:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801477:	e8 88 f7 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  80147c:	eb 02                	jmp    801480 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80147e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801480:	89 d8                	mov    %ebx,%eax
  801482:	83 c4 4c             	add    $0x4c,%esp
  801485:	5b                   	pop    %ebx
  801486:	5e                   	pop    %esi
  801487:	5f                   	pop    %edi
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	53                   	push   %ebx
  80148e:	83 ec 24             	sub    $0x24,%esp
  801491:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801494:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149b:	89 1c 24             	mov    %ebx,(%esp)
  80149e:	e8 4b fd ff ff       	call   8011ee <fd_lookup>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 6d                	js     801514 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b1:	8b 00                	mov    (%eax),%eax
  8014b3:	89 04 24             	mov    %eax,(%esp)
  8014b6:	e8 89 fd ff ff       	call   801244 <dev_lookup>
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 55                	js     801514 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c2:	8b 50 08             	mov    0x8(%eax),%edx
  8014c5:	83 e2 03             	and    $0x3,%edx
  8014c8:	83 fa 01             	cmp    $0x1,%edx
  8014cb:	75 23                	jne    8014f0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d2:	8b 40 48             	mov    0x48(%eax),%eax
  8014d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dd:	c7 04 24 7d 28 80 00 	movl   $0x80287d,(%esp)
  8014e4:	e8 d7 ec ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  8014e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ee:	eb 24                	jmp    801514 <read+0x8a>
	}
	if (!dev->dev_read)
  8014f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f3:	8b 52 08             	mov    0x8(%edx),%edx
  8014f6:	85 d2                	test   %edx,%edx
  8014f8:	74 15                	je     80150f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801504:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801508:	89 04 24             	mov    %eax,(%esp)
  80150b:	ff d2                	call   *%edx
  80150d:	eb 05                	jmp    801514 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80150f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801514:	83 c4 24             	add    $0x24,%esp
  801517:	5b                   	pop    %ebx
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	57                   	push   %edi
  80151e:	56                   	push   %esi
  80151f:	53                   	push   %ebx
  801520:	83 ec 1c             	sub    $0x1c,%esp
  801523:	8b 7d 08             	mov    0x8(%ebp),%edi
  801526:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801529:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152e:	eb 23                	jmp    801553 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801530:	89 f0                	mov    %esi,%eax
  801532:	29 d8                	sub    %ebx,%eax
  801534:	89 44 24 08          	mov    %eax,0x8(%esp)
  801538:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153b:	01 d8                	add    %ebx,%eax
  80153d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801541:	89 3c 24             	mov    %edi,(%esp)
  801544:	e8 41 ff ff ff       	call   80148a <read>
		if (m < 0)
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 10                	js     80155d <readn+0x43>
			return m;
		if (m == 0)
  80154d:	85 c0                	test   %eax,%eax
  80154f:	74 0a                	je     80155b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801551:	01 c3                	add    %eax,%ebx
  801553:	39 f3                	cmp    %esi,%ebx
  801555:	72 d9                	jb     801530 <readn+0x16>
  801557:	89 d8                	mov    %ebx,%eax
  801559:	eb 02                	jmp    80155d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80155b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80155d:	83 c4 1c             	add    $0x1c,%esp
  801560:	5b                   	pop    %ebx
  801561:	5e                   	pop    %esi
  801562:	5f                   	pop    %edi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	53                   	push   %ebx
  801569:	83 ec 24             	sub    $0x24,%esp
  80156c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	89 1c 24             	mov    %ebx,(%esp)
  801579:	e8 70 fc ff ff       	call   8011ee <fd_lookup>
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 68                	js     8015ea <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801582:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801585:	89 44 24 04          	mov    %eax,0x4(%esp)
  801589:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158c:	8b 00                	mov    (%eax),%eax
  80158e:	89 04 24             	mov    %eax,(%esp)
  801591:	e8 ae fc ff ff       	call   801244 <dev_lookup>
  801596:	85 c0                	test   %eax,%eax
  801598:	78 50                	js     8015ea <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a1:	75 23                	jne    8015c6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a8:	8b 40 48             	mov    0x48(%eax),%eax
  8015ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b3:	c7 04 24 99 28 80 00 	movl   $0x802899,(%esp)
  8015ba:	e8 01 ec ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  8015bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c4:	eb 24                	jmp    8015ea <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015cc:	85 d2                	test   %edx,%edx
  8015ce:	74 15                	je     8015e5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015da:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	ff d2                	call   *%edx
  8015e3:	eb 05                	jmp    8015ea <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015ea:	83 c4 24             	add    $0x24,%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801600:	89 04 24             	mov    %eax,(%esp)
  801603:	e8 e6 fb ff ff       	call   8011ee <fd_lookup>
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 0e                	js     80161a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80160c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80160f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801612:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801615:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	53                   	push   %ebx
  801620:	83 ec 24             	sub    $0x24,%esp
  801623:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801626:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162d:	89 1c 24             	mov    %ebx,(%esp)
  801630:	e8 b9 fb ff ff       	call   8011ee <fd_lookup>
  801635:	85 c0                	test   %eax,%eax
  801637:	78 61                	js     80169a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801639:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801643:	8b 00                	mov    (%eax),%eax
  801645:	89 04 24             	mov    %eax,(%esp)
  801648:	e8 f7 fb ff ff       	call   801244 <dev_lookup>
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 49                	js     80169a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801651:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801654:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801658:	75 23                	jne    80167d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80165a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80165f:	8b 40 48             	mov    0x48(%eax),%eax
  801662:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166a:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  801671:	e8 4a eb ff ff       	call   8001c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167b:	eb 1d                	jmp    80169a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80167d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801680:	8b 52 18             	mov    0x18(%edx),%edx
  801683:	85 d2                	test   %edx,%edx
  801685:	74 0e                	je     801695 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801687:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80168e:	89 04 24             	mov    %eax,(%esp)
  801691:	ff d2                	call   *%edx
  801693:	eb 05                	jmp    80169a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801695:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80169a:	83 c4 24             	add    $0x24,%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 24             	sub    $0x24,%esp
  8016a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	89 04 24             	mov    %eax,(%esp)
  8016b7:	e8 32 fb ff ff       	call   8011ee <fd_lookup>
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 52                	js     801712 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ca:	8b 00                	mov    (%eax),%eax
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	e8 70 fb ff ff       	call   801244 <dev_lookup>
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 3a                	js     801712 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016db:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016df:	74 2c                	je     80170d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016eb:	00 00 00 
	stat->st_isdir = 0;
  8016ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f5:	00 00 00 
	stat->st_dev = dev;
  8016f8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801702:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801705:	89 14 24             	mov    %edx,(%esp)
  801708:	ff 50 14             	call   *0x14(%eax)
  80170b:	eb 05                	jmp    801712 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80170d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801712:	83 c4 24             	add    $0x24,%esp
  801715:	5b                   	pop    %ebx
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801720:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801727:	00 
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	89 04 24             	mov    %eax,(%esp)
  80172e:	e8 fe 01 00 00       	call   801931 <open>
  801733:	89 c3                	mov    %eax,%ebx
  801735:	85 c0                	test   %eax,%eax
  801737:	78 1b                	js     801754 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801739:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801740:	89 1c 24             	mov    %ebx,(%esp)
  801743:	e8 58 ff ff ff       	call   8016a0 <fstat>
  801748:	89 c6                	mov    %eax,%esi
	close(fd);
  80174a:	89 1c 24             	mov    %ebx,(%esp)
  80174d:	e8 d4 fb ff ff       	call   801326 <close>
	return r;
  801752:	89 f3                	mov    %esi,%ebx
}
  801754:	89 d8                	mov    %ebx,%eax
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    
  80175d:	00 00                	add    %al,(%eax)
	...

00801760 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	83 ec 10             	sub    $0x10,%esp
  801768:	89 c3                	mov    %eax,%ebx
  80176a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80176c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801773:	75 11                	jne    801786 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801775:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80177c:	e8 06 09 00 00       	call   802087 <ipc_find_env>
  801781:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801786:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80178d:	00 
  80178e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801795:	00 
  801796:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80179a:	a1 00 40 80 00       	mov    0x804000,%eax
  80179f:	89 04 24             	mov    %eax,(%esp)
  8017a2:	e8 76 08 00 00       	call   80201d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ae:	00 
  8017af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ba:	e8 f5 07 00 00       	call   801fb4 <ipc_recv>
}
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017da:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e9:	e8 72 ff ff ff       	call   801760 <fsipc>
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801801:	ba 00 00 00 00       	mov    $0x0,%edx
  801806:	b8 06 00 00 00       	mov    $0x6,%eax
  80180b:	e8 50 ff ff ff       	call   801760 <fsipc>
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	53                   	push   %ebx
  801816:	83 ec 14             	sub    $0x14,%esp
  801819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80181c:	8b 45 08             	mov    0x8(%ebp),%eax
  80181f:	8b 40 0c             	mov    0xc(%eax),%eax
  801822:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801827:	ba 00 00 00 00       	mov    $0x0,%edx
  80182c:	b8 05 00 00 00       	mov    $0x5,%eax
  801831:	e8 2a ff ff ff       	call   801760 <fsipc>
  801836:	85 c0                	test   %eax,%eax
  801838:	78 2b                	js     801865 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80183a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801841:	00 
  801842:	89 1c 24             	mov    %ebx,(%esp)
  801845:	e8 21 ef ff ff       	call   80076b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184a:	a1 80 50 80 00       	mov    0x805080,%eax
  80184f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801855:	a1 84 50 80 00       	mov    0x805084,%eax
  80185a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801860:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801865:	83 c4 14             	add    $0x14,%esp
  801868:	5b                   	pop    %ebx
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801871:	c7 44 24 08 c8 28 80 	movl   $0x8028c8,0x8(%esp)
  801878:	00 
  801879:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801880:	00 
  801881:	c7 04 24 e6 28 80 00 	movl   $0x8028e6,(%esp)
  801888:	e8 5b 06 00 00       	call   801ee8 <_panic>

0080188d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
  801892:	83 ec 10             	sub    $0x10,%esp
  801895:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 40 0c             	mov    0xc(%eax),%eax
  80189e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b3:	e8 a8 fe ff ff       	call   801760 <fsipc>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 6a                	js     801928 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018be:	39 c6                	cmp    %eax,%esi
  8018c0:	73 24                	jae    8018e6 <devfile_read+0x59>
  8018c2:	c7 44 24 0c f1 28 80 	movl   $0x8028f1,0xc(%esp)
  8018c9:	00 
  8018ca:	c7 44 24 08 f8 28 80 	movl   $0x8028f8,0x8(%esp)
  8018d1:	00 
  8018d2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8018d9:	00 
  8018da:	c7 04 24 e6 28 80 00 	movl   $0x8028e6,(%esp)
  8018e1:	e8 02 06 00 00       	call   801ee8 <_panic>
	assert(r <= PGSIZE);
  8018e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018eb:	7e 24                	jle    801911 <devfile_read+0x84>
  8018ed:	c7 44 24 0c 0d 29 80 	movl   $0x80290d,0xc(%esp)
  8018f4:	00 
  8018f5:	c7 44 24 08 f8 28 80 	movl   $0x8028f8,0x8(%esp)
  8018fc:	00 
  8018fd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801904:	00 
  801905:	c7 04 24 e6 28 80 00 	movl   $0x8028e6,(%esp)
  80190c:	e8 d7 05 00 00       	call   801ee8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801911:	89 44 24 08          	mov    %eax,0x8(%esp)
  801915:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80191c:	00 
  80191d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801920:	89 04 24             	mov    %eax,(%esp)
  801923:	e8 bc ef ff ff       	call   8008e4 <memmove>
	return r;
}
  801928:	89 d8                	mov    %ebx,%eax
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	5b                   	pop    %ebx
  80192e:	5e                   	pop    %esi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	56                   	push   %esi
  801935:	53                   	push   %ebx
  801936:	83 ec 20             	sub    $0x20,%esp
  801939:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80193c:	89 34 24             	mov    %esi,(%esp)
  80193f:	e8 f4 ed ff ff       	call   800738 <strlen>
  801944:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801949:	7f 60                	jg     8019ab <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	e8 45 f8 ff ff       	call   80119b <fd_alloc>
  801956:	89 c3                	mov    %eax,%ebx
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 54                	js     8019b0 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80195c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801960:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801967:	e8 ff ed ff ff       	call   80076b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801974:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801977:	b8 01 00 00 00       	mov    $0x1,%eax
  80197c:	e8 df fd ff ff       	call   801760 <fsipc>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	85 c0                	test   %eax,%eax
  801985:	79 15                	jns    80199c <open+0x6b>
		fd_close(fd, 0);
  801987:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80198e:	00 
  80198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801992:	89 04 24             	mov    %eax,(%esp)
  801995:	e8 04 f9 ff ff       	call   80129e <fd_close>
		return r;
  80199a:	eb 14                	jmp    8019b0 <open+0x7f>
	}

	return fd2num(fd);
  80199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199f:	89 04 24             	mov    %eax,(%esp)
  8019a2:	e8 c9 f7 ff ff       	call   801170 <fd2num>
  8019a7:	89 c3                	mov    %eax,%ebx
  8019a9:	eb 05                	jmp    8019b0 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ab:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b0:	89 d8                	mov    %ebx,%eax
  8019b2:	83 c4 20             	add    $0x20,%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    

008019b9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c9:	e8 92 fd ff ff       	call   801760 <fsipc>
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	83 ec 10             	sub    $0x10,%esp
  8019d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
  8019de:	89 04 24             	mov    %eax,(%esp)
  8019e1:	e8 9a f7 ff ff       	call   801180 <fd2data>
  8019e6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019e8:	c7 44 24 04 19 29 80 	movl   $0x802919,0x4(%esp)
  8019ef:	00 
  8019f0:	89 34 24             	mov    %esi,(%esp)
  8019f3:	e8 73 ed ff ff       	call   80076b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8019fb:	2b 03                	sub    (%ebx),%eax
  8019fd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a03:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a0a:	00 00 00 
	stat->st_dev = &devpipe;
  801a0d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a14:	30 80 00 
	return 0;
}
  801a17:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5d                   	pop    %ebp
  801a22:	c3                   	ret    

00801a23 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	53                   	push   %ebx
  801a27:	83 ec 14             	sub    $0x14,%esp
  801a2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a38:	e8 c7 f1 ff ff       	call   800c04 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a3d:	89 1c 24             	mov    %ebx,(%esp)
  801a40:	e8 3b f7 ff ff       	call   801180 <fd2data>
  801a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a50:	e8 af f1 ff ff       	call   800c04 <sys_page_unmap>
}
  801a55:	83 c4 14             	add    $0x14,%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	57                   	push   %edi
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	83 ec 2c             	sub    $0x2c,%esp
  801a64:	89 c7                	mov    %eax,%edi
  801a66:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a69:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a71:	89 3c 24             	mov    %edi,(%esp)
  801a74:	e8 53 06 00 00       	call   8020cc <pageref>
  801a79:	89 c6                	mov    %eax,%esi
  801a7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7e:	89 04 24             	mov    %eax,(%esp)
  801a81:	e8 46 06 00 00       	call   8020cc <pageref>
  801a86:	39 c6                	cmp    %eax,%esi
  801a88:	0f 94 c0             	sete   %al
  801a8b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a8e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a94:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a97:	39 cb                	cmp    %ecx,%ebx
  801a99:	75 08                	jne    801aa3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a9b:	83 c4 2c             	add    $0x2c,%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5f                   	pop    %edi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801aa3:	83 f8 01             	cmp    $0x1,%eax
  801aa6:	75 c1                	jne    801a69 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aa8:	8b 42 58             	mov    0x58(%edx),%eax
  801aab:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801ab2:	00 
  801ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801abb:	c7 04 24 20 29 80 00 	movl   $0x802920,(%esp)
  801ac2:	e8 f9 e6 ff ff       	call   8001c0 <cprintf>
  801ac7:	eb a0                	jmp    801a69 <_pipeisclosed+0xe>

00801ac9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	57                   	push   %edi
  801acd:	56                   	push   %esi
  801ace:	53                   	push   %ebx
  801acf:	83 ec 1c             	sub    $0x1c,%esp
  801ad2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ad5:	89 34 24             	mov    %esi,(%esp)
  801ad8:	e8 a3 f6 ff ff       	call   801180 <fd2data>
  801add:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801adf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ae4:	eb 3c                	jmp    801b22 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ae6:	89 da                	mov    %ebx,%edx
  801ae8:	89 f0                	mov    %esi,%eax
  801aea:	e8 6c ff ff ff       	call   801a5b <_pipeisclosed>
  801aef:	85 c0                	test   %eax,%eax
  801af1:	75 38                	jne    801b2b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801af3:	e8 46 f0 ff ff       	call   800b3e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801af8:	8b 43 04             	mov    0x4(%ebx),%eax
  801afb:	8b 13                	mov    (%ebx),%edx
  801afd:	83 c2 20             	add    $0x20,%edx
  801b00:	39 d0                	cmp    %edx,%eax
  801b02:	73 e2                	jae    801ae6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b07:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801b0a:	89 c2                	mov    %eax,%edx
  801b0c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b12:	79 05                	jns    801b19 <devpipe_write+0x50>
  801b14:	4a                   	dec    %edx
  801b15:	83 ca e0             	or     $0xffffffe0,%edx
  801b18:	42                   	inc    %edx
  801b19:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b1d:	40                   	inc    %eax
  801b1e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b21:	47                   	inc    %edi
  801b22:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b25:	75 d1                	jne    801af8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b27:	89 f8                	mov    %edi,%eax
  801b29:	eb 05                	jmp    801b30 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b30:	83 c4 1c             	add    $0x1c,%esp
  801b33:	5b                   	pop    %ebx
  801b34:	5e                   	pop    %esi
  801b35:	5f                   	pop    %edi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	57                   	push   %edi
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 1c             	sub    $0x1c,%esp
  801b41:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b44:	89 3c 24             	mov    %edi,(%esp)
  801b47:	e8 34 f6 ff ff       	call   801180 <fd2data>
  801b4c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4e:	be 00 00 00 00       	mov    $0x0,%esi
  801b53:	eb 3a                	jmp    801b8f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b55:	85 f6                	test   %esi,%esi
  801b57:	74 04                	je     801b5d <devpipe_read+0x25>
				return i;
  801b59:	89 f0                	mov    %esi,%eax
  801b5b:	eb 40                	jmp    801b9d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b5d:	89 da                	mov    %ebx,%edx
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	e8 f5 fe ff ff       	call   801a5b <_pipeisclosed>
  801b66:	85 c0                	test   %eax,%eax
  801b68:	75 2e                	jne    801b98 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b6a:	e8 cf ef ff ff       	call   800b3e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b6f:	8b 03                	mov    (%ebx),%eax
  801b71:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b74:	74 df                	je     801b55 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b76:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b7b:	79 05                	jns    801b82 <devpipe_read+0x4a>
  801b7d:	48                   	dec    %eax
  801b7e:	83 c8 e0             	or     $0xffffffe0,%eax
  801b81:	40                   	inc    %eax
  801b82:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b89:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b8c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8e:	46                   	inc    %esi
  801b8f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b92:	75 db                	jne    801b6f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b94:	89 f0                	mov    %esi,%eax
  801b96:	eb 05                	jmp    801b9d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b98:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b9d:	83 c4 1c             	add    $0x1c,%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	57                   	push   %edi
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	83 ec 3c             	sub    $0x3c,%esp
  801bae:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 df f5 ff ff       	call   80119b <fd_alloc>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 88 45 01 00 00    	js     801d0b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bcd:	00 
  801bce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bdc:	e8 7c ef ff ff       	call   800b5d <sys_page_alloc>
  801be1:	89 c3                	mov    %eax,%ebx
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 20 01 00 00    	js     801d0b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801beb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 a5 f5 ff ff       	call   80119b <fd_alloc>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	0f 88 f8 00 00 00    	js     801cf8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c00:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c07:	00 
  801c08:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c16:	e8 42 ef ff ff       	call   800b5d <sys_page_alloc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	0f 88 d3 00 00 00    	js     801cf8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c28:	89 04 24             	mov    %eax,(%esp)
  801c2b:	e8 50 f5 ff ff       	call   801180 <fd2data>
  801c30:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c32:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c39:	00 
  801c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c45:	e8 13 ef ff ff       	call   800b5d <sys_page_alloc>
  801c4a:	89 c3                	mov    %eax,%ebx
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 91 00 00 00    	js     801ce5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c57:	89 04 24             	mov    %eax,(%esp)
  801c5a:	e8 21 f5 ff ff       	call   801180 <fd2data>
  801c5f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c66:	00 
  801c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c72:	00 
  801c73:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7e:	e8 2e ef ff ff       	call   800bb1 <sys_page_map>
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 4c                	js     801cd5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c92:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c97:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c9e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ca7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cb6:	89 04 24             	mov    %eax,(%esp)
  801cb9:	e8 b2 f4 ff ff       	call   801170 <fd2num>
  801cbe:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801cc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cc3:	89 04 24             	mov    %eax,(%esp)
  801cc6:	e8 a5 f4 ff ff       	call   801170 <fd2num>
  801ccb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd3:	eb 36                	jmp    801d0b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801cd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce0:	e8 1f ef ff ff       	call   800c04 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ce8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf3:	e8 0c ef ff ff       	call   800c04 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801cf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d06:	e8 f9 ee ff ff       	call   800c04 <sys_page_unmap>
    err:
	return r;
}
  801d0b:	89 d8                	mov    %ebx,%eax
  801d0d:	83 c4 3c             	add    $0x3c,%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d22:	8b 45 08             	mov    0x8(%ebp),%eax
  801d25:	89 04 24             	mov    %eax,(%esp)
  801d28:	e8 c1 f4 ff ff       	call   8011ee <fd_lookup>
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	78 15                	js     801d46 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d34:	89 04 24             	mov    %eax,(%esp)
  801d37:	e8 44 f4 ff ff       	call   801180 <fd2data>
	return _pipeisclosed(fd, p);
  801d3c:	89 c2                	mov    %eax,%edx
  801d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d41:	e8 15 fd ff ff       	call   801a5b <_pipeisclosed>
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d58:	c7 44 24 04 38 29 80 	movl   $0x802938,0x4(%esp)
  801d5f:	00 
  801d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d63:	89 04 24             	mov    %eax,(%esp)
  801d66:	e8 00 ea ff ff       	call   80076b <strcpy>
	return 0;
}
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d83:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d89:	eb 30                	jmp    801dbb <devcons_write+0x49>
		m = n - tot;
  801d8b:	8b 75 10             	mov    0x10(%ebp),%esi
  801d8e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d90:	83 fe 7f             	cmp    $0x7f,%esi
  801d93:	76 05                	jbe    801d9a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801d95:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d9a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d9e:	03 45 0c             	add    0xc(%ebp),%eax
  801da1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da5:	89 3c 24             	mov    %edi,(%esp)
  801da8:	e8 37 eb ff ff       	call   8008e4 <memmove>
		sys_cputs(buf, m);
  801dad:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db1:	89 3c 24             	mov    %edi,(%esp)
  801db4:	e8 d7 ec ff ff       	call   800a90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db9:	01 f3                	add    %esi,%ebx
  801dbb:	89 d8                	mov    %ebx,%eax
  801dbd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dc0:	72 c9                	jb     801d8b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    

00801dcd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd7:	75 07                	jne    801de0 <devcons_read+0x13>
  801dd9:	eb 25                	jmp    801e00 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ddb:	e8 5e ed ff ff       	call   800b3e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de0:	e8 c9 ec ff ff       	call   800aae <sys_cgetc>
  801de5:	85 c0                	test   %eax,%eax
  801de7:	74 f2                	je     801ddb <devcons_read+0xe>
  801de9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 1d                	js     801e0c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801def:	83 f8 04             	cmp    $0x4,%eax
  801df2:	74 13                	je     801e07 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801df4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df7:	88 10                	mov    %dl,(%eax)
	return 1;
  801df9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfe:	eb 0c                	jmp    801e0c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
  801e05:	eb 05                	jmp    801e0c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e1a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e21:	00 
  801e22:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e25:	89 04 24             	mov    %eax,(%esp)
  801e28:	e8 63 ec ff ff       	call   800a90 <sys_cputs>
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <getchar>:

int
getchar(void)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e35:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e3c:	00 
  801e3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4b:	e8 3a f6 ff ff       	call   80148a <read>
	if (r < 0)
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 0f                	js     801e63 <getchar+0x34>
		return r;
	if (r < 1)
  801e54:	85 c0                	test   %eax,%eax
  801e56:	7e 06                	jle    801e5e <getchar+0x2f>
		return -E_EOF;
	return c;
  801e58:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e5c:	eb 05                	jmp    801e63 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e5e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e72:	8b 45 08             	mov    0x8(%ebp),%eax
  801e75:	89 04 24             	mov    %eax,(%esp)
  801e78:	e8 71 f3 ff ff       	call   8011ee <fd_lookup>
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 11                	js     801e92 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e84:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8a:	39 10                	cmp    %edx,(%eax)
  801e8c:	0f 94 c0             	sete   %al
  801e8f:	0f b6 c0             	movzbl %al,%eax
}
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    

00801e94 <opencons>:

int
opencons(void)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9d:	89 04 24             	mov    %eax,(%esp)
  801ea0:	e8 f6 f2 ff ff       	call   80119b <fd_alloc>
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	78 3c                	js     801ee5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb0:	00 
  801eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebf:	e8 99 ec ff ff       	call   800b5d <sys_page_alloc>
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 1d                	js     801ee5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ec8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801edd:	89 04 24             	mov    %eax,(%esp)
  801ee0:	e8 8b f2 ff ff       	call   801170 <fd2num>
}
  801ee5:	c9                   	leave  
  801ee6:	c3                   	ret    
	...

00801ee8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801ef0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ef3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ef9:	e8 21 ec ff ff       	call   800b1f <sys_getenvid>
  801efe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f01:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f05:	8b 55 08             	mov    0x8(%ebp),%edx
  801f08:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f0c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f14:	c7 04 24 44 29 80 00 	movl   $0x802944,(%esp)
  801f1b:	e8 a0 e2 ff ff       	call   8001c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f20:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f24:	8b 45 10             	mov    0x10(%ebp),%eax
  801f27:	89 04 24             	mov    %eax,(%esp)
  801f2a:	e8 30 e2 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  801f2f:	c7 04 24 f4 23 80 00 	movl   $0x8023f4,(%esp)
  801f36:	e8 85 e2 ff ff       	call   8001c0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f3b:	cc                   	int3   
  801f3c:	eb fd                	jmp    801f3b <_panic+0x53>
	...

00801f40 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f46:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f4d:	75 32                	jne    801f81 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801f4f:	e8 cb eb ff ff       	call   800b1f <sys_getenvid>
  801f54:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  801f5b:	00 
  801f5c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801f63:	ee 
  801f64:	89 04 24             	mov    %eax,(%esp)
  801f67:	e8 f1 eb ff ff       	call   800b5d <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  801f6c:	e8 ae eb ff ff       	call   800b1f <sys_getenvid>
  801f71:	c7 44 24 04 8c 1f 80 	movl   $0x801f8c,0x4(%esp)
  801f78:	00 
  801f79:	89 04 24             	mov    %eax,(%esp)
  801f7c:	e8 7c ed ff ff       	call   800cfd <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f81:	8b 45 08             	mov    0x8(%ebp),%eax
  801f84:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    
	...

00801f8c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f8c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f8d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f92:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f94:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  801f97:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  801f9b:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  801f9e:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  801fa3:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  801fa7:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  801faa:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  801fab:	83 c4 04             	add    $0x4,%esp
	popfl
  801fae:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  801faf:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  801fb0:	c3                   	ret    
  801fb1:	00 00                	add    %al,(%eax)
	...

00801fb4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	57                   	push   %edi
  801fb8:	56                   	push   %esi
  801fb9:	53                   	push   %ebx
  801fba:	83 ec 1c             	sub    $0x1c,%esp
  801fbd:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fc3:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801fc6:	85 db                	test   %ebx,%ebx
  801fc8:	75 05                	jne    801fcf <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801fca:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801fcf:	89 1c 24             	mov    %ebx,(%esp)
  801fd2:	e8 9c ed ff ff       	call   800d73 <sys_ipc_recv>
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	79 16                	jns    801ff1 <ipc_recv+0x3d>
		*from_env_store = 0;
  801fdb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801fe1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801fe7:	89 1c 24             	mov    %ebx,(%esp)
  801fea:	e8 84 ed ff ff       	call   800d73 <sys_ipc_recv>
  801fef:	eb 24                	jmp    802015 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801ff1:	85 f6                	test   %esi,%esi
  801ff3:	74 0a                	je     801fff <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801ff5:	a1 04 40 80 00       	mov    0x804004,%eax
  801ffa:	8b 40 74             	mov    0x74(%eax),%eax
  801ffd:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801fff:	85 ff                	test   %edi,%edi
  802001:	74 0a                	je     80200d <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802003:	a1 04 40 80 00       	mov    0x804004,%eax
  802008:	8b 40 78             	mov    0x78(%eax),%eax
  80200b:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  80200d:	a1 04 40 80 00       	mov    0x804004,%eax
  802012:	8b 40 70             	mov    0x70(%eax),%eax
}
  802015:	83 c4 1c             	add    $0x1c,%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    

0080201d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	57                   	push   %edi
  802021:	56                   	push   %esi
  802022:	53                   	push   %ebx
  802023:	83 ec 1c             	sub    $0x1c,%esp
  802026:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802029:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80202c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80202f:	85 db                	test   %ebx,%ebx
  802031:	75 05                	jne    802038 <ipc_send+0x1b>
		pg = (void *)-1;
  802033:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802038:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80203c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802040:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802044:	8b 45 08             	mov    0x8(%ebp),%eax
  802047:	89 04 24             	mov    %eax,(%esp)
  80204a:	e8 01 ed ff ff       	call   800d50 <sys_ipc_try_send>
		if (r == 0) {		
  80204f:	85 c0                	test   %eax,%eax
  802051:	74 2c                	je     80207f <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  802053:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802056:	75 07                	jne    80205f <ipc_send+0x42>
			sys_yield();
  802058:	e8 e1 ea ff ff       	call   800b3e <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  80205d:	eb d9                	jmp    802038 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80205f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802063:	c7 44 24 08 68 29 80 	movl   $0x802968,0x8(%esp)
  80206a:	00 
  80206b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  802072:	00 
  802073:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  80207a:	e8 69 fe ff ff       	call   801ee8 <_panic>
		}
	}
}
  80207f:	83 c4 1c             	add    $0x1c,%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5f                   	pop    %edi
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    

00802087 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	53                   	push   %ebx
  80208b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80208e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802093:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80209a:	89 c2                	mov    %eax,%edx
  80209c:	c1 e2 07             	shl    $0x7,%edx
  80209f:	29 ca                	sub    %ecx,%edx
  8020a1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a7:	8b 52 50             	mov    0x50(%edx),%edx
  8020aa:	39 da                	cmp    %ebx,%edx
  8020ac:	75 0f                	jne    8020bd <ipc_find_env+0x36>
			return envs[i].env_id;
  8020ae:	c1 e0 07             	shl    $0x7,%eax
  8020b1:	29 c8                	sub    %ecx,%eax
  8020b3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8020b8:	8b 40 40             	mov    0x40(%eax),%eax
  8020bb:	eb 0c                	jmp    8020c9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020bd:	40                   	inc    %eax
  8020be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c3:	75 ce                	jne    802093 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020c5:	66 b8 00 00          	mov    $0x0,%ax
}
  8020c9:	5b                   	pop    %ebx
  8020ca:	5d                   	pop    %ebp
  8020cb:	c3                   	ret    

008020cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d2:	89 c2                	mov    %eax,%edx
  8020d4:	c1 ea 16             	shr    $0x16,%edx
  8020d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020de:	f6 c2 01             	test   $0x1,%dl
  8020e1:	74 1e                	je     802101 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e3:	c1 e8 0c             	shr    $0xc,%eax
  8020e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020ed:	a8 01                	test   $0x1,%al
  8020ef:	74 17                	je     802108 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f1:	c1 e8 0c             	shr    $0xc,%eax
  8020f4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020fb:	ef 
  8020fc:	0f b7 c0             	movzwl %ax,%eax
  8020ff:	eb 0c                	jmp    80210d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802101:	b8 00 00 00 00       	mov    $0x0,%eax
  802106:	eb 05                	jmp    80210d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802108:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80210d:	5d                   	pop    %ebp
  80210e:	c3                   	ret    
	...

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	83 ec 10             	sub    $0x10,%esp
  802116:	8b 74 24 20          	mov    0x20(%esp),%esi
  80211a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80211e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802122:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802126:	89 cd                	mov    %ecx,%ebp
  802128:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80212c:	85 c0                	test   %eax,%eax
  80212e:	75 2c                	jne    80215c <__udivdi3+0x4c>
  802130:	39 f9                	cmp    %edi,%ecx
  802132:	77 68                	ja     80219c <__udivdi3+0x8c>
  802134:	85 c9                	test   %ecx,%ecx
  802136:	75 0b                	jne    802143 <__udivdi3+0x33>
  802138:	b8 01 00 00 00       	mov    $0x1,%eax
  80213d:	31 d2                	xor    %edx,%edx
  80213f:	f7 f1                	div    %ecx
  802141:	89 c1                	mov    %eax,%ecx
  802143:	31 d2                	xor    %edx,%edx
  802145:	89 f8                	mov    %edi,%eax
  802147:	f7 f1                	div    %ecx
  802149:	89 c7                	mov    %eax,%edi
  80214b:	89 f0                	mov    %esi,%eax
  80214d:	f7 f1                	div    %ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	89 f0                	mov    %esi,%eax
  802153:	89 fa                	mov    %edi,%edx
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	39 f8                	cmp    %edi,%eax
  80215e:	77 2c                	ja     80218c <__udivdi3+0x7c>
  802160:	0f bd f0             	bsr    %eax,%esi
  802163:	83 f6 1f             	xor    $0x1f,%esi
  802166:	75 4c                	jne    8021b4 <__udivdi3+0xa4>
  802168:	39 f8                	cmp    %edi,%eax
  80216a:	bf 00 00 00 00       	mov    $0x0,%edi
  80216f:	72 0a                	jb     80217b <__udivdi3+0x6b>
  802171:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802175:	0f 87 ad 00 00 00    	ja     802228 <__udivdi3+0x118>
  80217b:	be 01 00 00 00       	mov    $0x1,%esi
  802180:	89 f0                	mov    %esi,%eax
  802182:	89 fa                	mov    %edi,%edx
  802184:	83 c4 10             	add    $0x10,%esp
  802187:	5e                   	pop    %esi
  802188:	5f                   	pop    %edi
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    
  80218b:	90                   	nop
  80218c:	31 ff                	xor    %edi,%edi
  80218e:	31 f6                	xor    %esi,%esi
  802190:	89 f0                	mov    %esi,%eax
  802192:	89 fa                	mov    %edi,%edx
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	5e                   	pop    %esi
  802198:	5f                   	pop    %edi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    
  80219b:	90                   	nop
  80219c:	89 fa                	mov    %edi,%edx
  80219e:	89 f0                	mov    %esi,%eax
  8021a0:	f7 f1                	div    %ecx
  8021a2:	89 c6                	mov    %eax,%esi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 f0                	mov    %esi,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	5e                   	pop    %esi
  8021ae:	5f                   	pop    %edi
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    
  8021b1:	8d 76 00             	lea    0x0(%esi),%esi
  8021b4:	89 f1                	mov    %esi,%ecx
  8021b6:	d3 e0                	shl    %cl,%eax
  8021b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8021c1:	29 f0                	sub    %esi,%eax
  8021c3:	89 ea                	mov    %ebp,%edx
  8021c5:	88 c1                	mov    %al,%cl
  8021c7:	d3 ea                	shr    %cl,%edx
  8021c9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8021cd:	09 ca                	or     %ecx,%edx
  8021cf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021d3:	89 f1                	mov    %esi,%ecx
  8021d5:	d3 e5                	shl    %cl,%ebp
  8021d7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8021db:	89 fd                	mov    %edi,%ebp
  8021dd:	88 c1                	mov    %al,%cl
  8021df:	d3 ed                	shr    %cl,%ebp
  8021e1:	89 fa                	mov    %edi,%edx
  8021e3:	89 f1                	mov    %esi,%ecx
  8021e5:	d3 e2                	shl    %cl,%edx
  8021e7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021eb:	88 c1                	mov    %al,%cl
  8021ed:	d3 ef                	shr    %cl,%edi
  8021ef:	09 d7                	or     %edx,%edi
  8021f1:	89 f8                	mov    %edi,%eax
  8021f3:	89 ea                	mov    %ebp,%edx
  8021f5:	f7 74 24 08          	divl   0x8(%esp)
  8021f9:	89 d1                	mov    %edx,%ecx
  8021fb:	89 c7                	mov    %eax,%edi
  8021fd:	f7 64 24 0c          	mull   0xc(%esp)
  802201:	39 d1                	cmp    %edx,%ecx
  802203:	72 17                	jb     80221c <__udivdi3+0x10c>
  802205:	74 09                	je     802210 <__udivdi3+0x100>
  802207:	89 fe                	mov    %edi,%esi
  802209:	31 ff                	xor    %edi,%edi
  80220b:	e9 41 ff ff ff       	jmp    802151 <__udivdi3+0x41>
  802210:	8b 54 24 04          	mov    0x4(%esp),%edx
  802214:	89 f1                	mov    %esi,%ecx
  802216:	d3 e2                	shl    %cl,%edx
  802218:	39 c2                	cmp    %eax,%edx
  80221a:	73 eb                	jae    802207 <__udivdi3+0xf7>
  80221c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80221f:	31 ff                	xor    %edi,%edi
  802221:	e9 2b ff ff ff       	jmp    802151 <__udivdi3+0x41>
  802226:	66 90                	xchg   %ax,%ax
  802228:	31 f6                	xor    %esi,%esi
  80222a:	e9 22 ff ff ff       	jmp    802151 <__udivdi3+0x41>
	...

00802230 <__umoddi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	83 ec 20             	sub    $0x20,%esp
  802236:	8b 44 24 30          	mov    0x30(%esp),%eax
  80223a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80223e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802242:	8b 74 24 34          	mov    0x34(%esp),%esi
  802246:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80224a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80224e:	89 c7                	mov    %eax,%edi
  802250:	89 f2                	mov    %esi,%edx
  802252:	85 ed                	test   %ebp,%ebp
  802254:	75 16                	jne    80226c <__umoddi3+0x3c>
  802256:	39 f1                	cmp    %esi,%ecx
  802258:	0f 86 a6 00 00 00    	jbe    802304 <__umoddi3+0xd4>
  80225e:	f7 f1                	div    %ecx
  802260:	89 d0                	mov    %edx,%eax
  802262:	31 d2                	xor    %edx,%edx
  802264:	83 c4 20             	add    $0x20,%esp
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
  80226b:	90                   	nop
  80226c:	39 f5                	cmp    %esi,%ebp
  80226e:	0f 87 ac 00 00 00    	ja     802320 <__umoddi3+0xf0>
  802274:	0f bd c5             	bsr    %ebp,%eax
  802277:	83 f0 1f             	xor    $0x1f,%eax
  80227a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80227e:	0f 84 a8 00 00 00    	je     80232c <__umoddi3+0xfc>
  802284:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802288:	d3 e5                	shl    %cl,%ebp
  80228a:	bf 20 00 00 00       	mov    $0x20,%edi
  80228f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802293:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802297:	89 f9                	mov    %edi,%ecx
  802299:	d3 e8                	shr    %cl,%eax
  80229b:	09 e8                	or     %ebp,%eax
  80229d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022a5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8022a9:	d3 e0                	shl    %cl,%eax
  8022ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	d3 e2                	shl    %cl,%edx
  8022b3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8022bd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	d3 e8                	shr    %cl,%eax
  8022c5:	09 d0                	or     %edx,%eax
  8022c7:	d3 ee                	shr    %cl,%esi
  8022c9:	89 f2                	mov    %esi,%edx
  8022cb:	f7 74 24 18          	divl   0x18(%esp)
  8022cf:	89 d6                	mov    %edx,%esi
  8022d1:	f7 64 24 0c          	mull   0xc(%esp)
  8022d5:	89 c5                	mov    %eax,%ebp
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	39 d6                	cmp    %edx,%esi
  8022db:	72 67                	jb     802344 <__umoddi3+0x114>
  8022dd:	74 75                	je     802354 <__umoddi3+0x124>
  8022df:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022e3:	29 e8                	sub    %ebp,%eax
  8022e5:	19 ce                	sbb    %ecx,%esi
  8022e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	89 f9                	mov    %edi,%ecx
  8022f1:	d3 e2                	shl    %cl,%edx
  8022f3:	09 d0                	or     %edx,%eax
  8022f5:	89 f2                	mov    %esi,%edx
  8022f7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	83 c4 20             	add    $0x20,%esp
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    
  802304:	85 c9                	test   %ecx,%ecx
  802306:	75 0b                	jne    802313 <__umoddi3+0xe3>
  802308:	b8 01 00 00 00       	mov    $0x1,%eax
  80230d:	31 d2                	xor    %edx,%edx
  80230f:	f7 f1                	div    %ecx
  802311:	89 c1                	mov    %eax,%ecx
  802313:	89 f0                	mov    %esi,%eax
  802315:	31 d2                	xor    %edx,%edx
  802317:	f7 f1                	div    %ecx
  802319:	89 f8                	mov    %edi,%eax
  80231b:	e9 3e ff ff ff       	jmp    80225e <__umoddi3+0x2e>
  802320:	89 f2                	mov    %esi,%edx
  802322:	83 c4 20             	add    $0x20,%esp
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d 76 00             	lea    0x0(%esi),%esi
  80232c:	39 f5                	cmp    %esi,%ebp
  80232e:	72 04                	jb     802334 <__umoddi3+0x104>
  802330:	39 f9                	cmp    %edi,%ecx
  802332:	77 06                	ja     80233a <__umoddi3+0x10a>
  802334:	89 f2                	mov    %esi,%edx
  802336:	29 cf                	sub    %ecx,%edi
  802338:	19 ea                	sbb    %ebp,%edx
  80233a:	89 f8                	mov    %edi,%eax
  80233c:	83 c4 20             	add    $0x20,%esp
  80233f:	5e                   	pop    %esi
  802340:	5f                   	pop    %edi
  802341:	5d                   	pop    %ebp
  802342:	c3                   	ret    
  802343:	90                   	nop
  802344:	89 d1                	mov    %edx,%ecx
  802346:	89 c5                	mov    %eax,%ebp
  802348:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80234c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802350:	eb 8d                	jmp    8022df <__umoddi3+0xaf>
  802352:	66 90                	xchg   %ax,%ax
  802354:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802358:	72 ea                	jb     802344 <__umoddi3+0x114>
  80235a:	89 f1                	mov    %esi,%ecx
  80235c:	eb 81                	jmp    8022df <__umoddi3+0xaf>
