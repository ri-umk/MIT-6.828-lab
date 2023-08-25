
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 20 0b 00 00       	call   800b63 <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 c0 23 80 00 	movl   $0x8023c0,(%esp)
  800052:	e8 ad 01 00 00       	call   800204 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	53                   	push   %ebx
  800081:	83 ec 44             	sub    $0x44,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8a 45 0c             	mov    0xc(%ebp),%al
  80008a:	88 45 e7             	mov    %al,-0x19(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 e7 06 00 00       	call   80077c <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 d1 23 80 	movl   $0x8023d1,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 90 06 00 00       	call   800751 <snprintf>
	if (fork() == 0) {
  8000c1:	e8 6d 0e 00 00       	call   800f33 <fork>
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 10                	jne    8000da <forkchild+0x5d>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5f ff ff ff       	call   800034 <forktree>
		exit();
  8000d5:	e8 6e 00 00 00       	call   800148 <exit>
	}
}
  8000da:	83 c4 44             	add    $0x44,%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e6:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <forktree>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800102:	e8 5c 0a 00 00       	call   800b63 <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800113:	c1 e0 07             	shl    $0x7,%eax
  800116:	29 d0                	sub    %edx,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800122:	85 f6                	test   %esi,%esi
  800124:	7e 07                	jle    80012d <libmain+0x39>
		binaryname = argv[0];
  800126:	8b 03                	mov    (%ebx),%eax
  800128:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800131:	89 34 24             	mov    %esi,(%esp)
  800134:	e8 a7 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    
  800145:	00 00                	add    %al,(%eax)
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014e:	e8 48 12 00 00       	call   80139b <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 b2 09 00 00       	call   800b11 <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	00 00                	add    %al,(%eax)
	...

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 14             	sub    $0x14,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 03                	mov    (%ebx),%eax
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800177:	40                   	inc    %eax
  800178:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017f:	75 19                	jne    80019a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800181:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800188:	00 
  800189:	8d 43 08             	lea    0x8(%ebx),%eax
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 40 09 00 00       	call   800ad4 <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019a:	ff 43 04             	incl   0x4(%ebx)
}
  80019d:	83 c4 14             	add    $0x14,%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	c7 04 24 64 01 80 00 	movl   $0x800164,(%esp)
  8001df:	e8 82 01 00 00       	call   800366 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 d8 08 00 00       	call   800ad4 <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	89 04 24             	mov    %eax,(%esp)
  800217:	e8 87 ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	85 c0                	test   %eax,%eax
  800242:	75 08                	jne    80024c <printnum+0x2c>
  800244:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800247:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024a:	77 57                	ja     8002a3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800250:	4b                   	dec    %ebx
  800251:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800255:	8b 45 10             	mov    0x10(%ebp),%eax
  800258:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800260:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800264:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026b:	00 
  80026c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	e8 d6 1e 00 00       	call   802154 <__udivdi3>
  80027e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800282:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800286:	89 04 24             	mov    %eax,(%esp)
  800289:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028d:	89 fa                	mov    %edi,%edx
  80028f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800292:	e8 89 ff ff ff       	call   800220 <printnum>
  800297:	eb 0f                	jmp    8002a8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029d:	89 34 24             	mov    %esi,(%esp)
  8002a0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a3:	4b                   	dec    %ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f f1                	jg     800299 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002be:	00 
  8002bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	e8 a3 1f 00 00       	call   802274 <__umoddi3>
  8002d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d5:	0f be 80 e0 23 80 00 	movsbl 0x8023e0(%eax),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e2:	83 c4 3c             	add    $0x3c,%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7e 0e                	jle    800300 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	8b 52 04             	mov    0x4(%edx),%edx
  8002fe:	eb 22                	jmp    800322 <getuint+0x38>
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 10                	je     800314 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	eb 0e                	jmp    800322 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 08                	jae    80033c <sprintputch+0x18>
		*b->buf++ = ch;
  800334:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800337:	88 0a                	mov    %cl,(%edx)
  800339:	42                   	inc    %edx
  80033a:	89 10                	mov    %edx,(%eax)
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034b:	8b 45 10             	mov    0x10(%ebp),%eax
  80034e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
  800355:	89 44 24 04          	mov    %eax,0x4(%esp)
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	89 04 24             	mov    %eax,(%esp)
  80035f:	e8 02 00 00 00       	call   800366 <vprintfmt>
	va_end(ap);
}
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
  80036c:	83 ec 4c             	sub    $0x4c,%esp
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800372:	8b 75 10             	mov    0x10(%ebp),%esi
  800375:	eb 12                	jmp    800389 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800377:	85 c0                	test   %eax,%eax
  800379:	0f 84 6b 03 00 00    	je     8006ea <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80037f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800389:	0f b6 06             	movzbl (%esi),%eax
  80038c:	46                   	inc    %esi
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e5                	jne    800377 <vprintfmt+0x11>
  800392:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800396:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80039d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ae:	eb 26                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003b7:	eb 1d                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c0:	eb 14                	jmp    8003d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cc:	eb 08                	jmp    8003d6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	0f b6 06             	movzbl (%esi),%eax
  8003d9:	8d 56 01             	lea    0x1(%esi),%edx
  8003dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003df:	8a 16                	mov    (%esi),%dl
  8003e1:	83 ea 23             	sub    $0x23,%edx
  8003e4:	80 fa 55             	cmp    $0x55,%dl
  8003e7:	0f 87 e1 02 00 00    	ja     8006ce <vprintfmt+0x368>
  8003ed:	0f b6 d2             	movzbl %dl,%edx
  8003f0:	ff 24 95 20 25 80 00 	jmp    *0x802520(,%edx,4)
  8003f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800402:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800406:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800409:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040c:	83 fa 09             	cmp    $0x9,%edx
  80040f:	77 2a                	ja     80043b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800412:	eb eb                	jmp    8003ff <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800422:	eb 17                	jmp    80043b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800424:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800428:	78 98                	js     8003c2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042d:	eb a7                	jmp    8003d6 <vprintfmt+0x70>
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800432:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800439:	eb 9b                	jmp    8003d6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80043b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043f:	79 95                	jns    8003d6 <vprintfmt+0x70>
  800441:	eb 8b                	jmp    8003ce <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800443:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800447:	eb 8d                	jmp    8003d6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800461:	e9 23 ff ff ff       	jmp    800389 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	85 c0                	test   %eax,%eax
  800473:	79 02                	jns    800477 <vprintfmt+0x111>
  800475:	f7 d8                	neg    %eax
  800477:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800479:	83 f8 0f             	cmp    $0xf,%eax
  80047c:	7f 0b                	jg     800489 <vprintfmt+0x123>
  80047e:	8b 04 85 80 26 80 00 	mov    0x802680(,%eax,4),%eax
  800485:	85 c0                	test   %eax,%eax
  800487:	75 23                	jne    8004ac <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800489:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048d:	c7 44 24 08 f8 23 80 	movl   $0x8023f8,0x8(%esp)
  800494:	00 
  800495:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 9a fe ff ff       	call   80033e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a7:	e9 dd fe ff ff       	jmp    800389 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b0:	c7 44 24 08 ea 28 80 	movl   $0x8028ea,0x8(%esp)
  8004b7:	00 
  8004b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	89 14 24             	mov    %edx,(%esp)
  8004c2:	e8 77 fe ff ff       	call   80033e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ca:	e9 ba fe ff ff       	jmp    800389 <vprintfmt+0x23>
  8004cf:	89 f9                	mov    %edi,%ecx
  8004d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 50 04             	lea    0x4(%eax),%edx
  8004dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e0:	8b 30                	mov    (%eax),%esi
  8004e2:	85 f6                	test   %esi,%esi
  8004e4:	75 05                	jne    8004eb <vprintfmt+0x185>
				p = "(null)";
  8004e6:	be f1 23 80 00       	mov    $0x8023f1,%esi
			if (width > 0 && padc != '-')
  8004eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ef:	0f 8e 84 00 00 00    	jle    800579 <vprintfmt+0x213>
  8004f5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f9:	74 7e                	je     800579 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ff:	89 34 24             	mov    %esi,(%esp)
  800502:	e8 8b 02 00 00       	call   800792 <strnlen>
  800507:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050a:	29 c2                	sub    %eax,%edx
  80050c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80050f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800513:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800516:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800519:	89 de                	mov    %ebx,%esi
  80051b:	89 d3                	mov    %edx,%ebx
  80051d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	eb 0b                	jmp    80052c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800521:	89 74 24 04          	mov    %esi,0x4(%esp)
  800525:	89 3c 24             	mov    %edi,(%esp)
  800528:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	4b                   	dec    %ebx
  80052c:	85 db                	test   %ebx,%ebx
  80052e:	7f f1                	jg     800521 <vprintfmt+0x1bb>
  800530:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800533:	89 f3                	mov    %esi,%ebx
  800535:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800538:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053b:	85 c0                	test   %eax,%eax
  80053d:	79 05                	jns    800544 <vprintfmt+0x1de>
  80053f:	b8 00 00 00 00       	mov    $0x0,%eax
  800544:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800547:	29 c2                	sub    %eax,%edx
  800549:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054c:	eb 2b                	jmp    800579 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800552:	74 18                	je     80056c <vprintfmt+0x206>
  800554:	8d 50 e0             	lea    -0x20(%eax),%edx
  800557:	83 fa 5e             	cmp    $0x5e,%edx
  80055a:	76 10                	jbe    80056c <vprintfmt+0x206>
					putch('?', putdat);
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
  80056a:	eb 0a                	jmp    800576 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	ff 4d e4             	decl   -0x1c(%ebp)
  800579:	0f be 06             	movsbl (%esi),%eax
  80057c:	46                   	inc    %esi
  80057d:	85 c0                	test   %eax,%eax
  80057f:	74 21                	je     8005a2 <vprintfmt+0x23c>
  800581:	85 ff                	test   %edi,%edi
  800583:	78 c9                	js     80054e <vprintfmt+0x1e8>
  800585:	4f                   	dec    %edi
  800586:	79 c6                	jns    80054e <vprintfmt+0x1e8>
  800588:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058b:	89 de                	mov    %ebx,%esi
  80058d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800590:	eb 18                	jmp    8005aa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800592:	89 74 24 04          	mov    %esi,0x4(%esp)
  800596:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	4b                   	dec    %ebx
  8005a0:	eb 08                	jmp    8005aa <vprintfmt+0x244>
  8005a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a5:	89 de                	mov    %ebx,%esi
  8005a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005aa:	85 db                	test   %ebx,%ebx
  8005ac:	7f e4                	jg     800592 <vprintfmt+0x22c>
  8005ae:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b6:	e9 ce fd ff ff       	jmp    800389 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 f9 01             	cmp    $0x1,%ecx
  8005be:	7e 10                	jle    8005d0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 30                	mov    (%eax),%esi
  8005cb:	8b 78 04             	mov    0x4(%eax),%edi
  8005ce:	eb 26                	jmp    8005f6 <vprintfmt+0x290>
	else if (lflag)
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	74 12                	je     8005e6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 30                	mov    (%eax),%esi
  8005df:	89 f7                	mov    %esi,%edi
  8005e1:	c1 ff 1f             	sar    $0x1f,%edi
  8005e4:	eb 10                	jmp    8005f6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 30                	mov    (%eax),%esi
  8005f1:	89 f7                	mov    %esi,%edi
  8005f3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f6:	85 ff                	test   %edi,%edi
  8005f8:	78 0a                	js     800604 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ff:	e9 8c 00 00 00       	jmp    800690 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800612:	f7 de                	neg    %esi
  800614:	83 d7 00             	adc    $0x0,%edi
  800617:	f7 df                	neg    %edi
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	eb 70                	jmp    800690 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 c0 fc ff ff       	call   8002ea <getuint>
  80062a:	89 c6                	mov    %eax,%esi
  80062c:	89 d7                	mov    %edx,%edi
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800633:	eb 5b                	jmp    800690 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800635:	89 ca                	mov    %ecx,%edx
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 ab fc ff ff       	call   8002ea <getuint>
  80063f:	89 c6                	mov    %eax,%esi
  800641:	89 d7                	mov    %edx,%edi
			base = 8;
  800643:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800648:	eb 46                	jmp    800690 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800655:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066f:	8b 30                	mov    (%eax),%esi
  800671:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800676:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067b:	eb 13                	jmp    800690 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 63 fc ff ff       	call   8002ea <getuint>
  800687:	89 c6                	mov    %eax,%esi
  800689:	89 d7                	mov    %edx,%edi
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800694:	89 54 24 10          	mov    %edx,0x10(%esp)
  800698:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a3:	89 34 24             	mov    %esi,(%esp)
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	e8 6c fb ff ff       	call   800220 <printnum>
			break;
  8006b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b7:	e9 cd fc ff ff       	jmp    800389 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c9:	e9 bb fc ff ff       	jmp    800389 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	eb 01                	jmp    8006df <vprintfmt+0x379>
  8006de:	4e                   	dec    %esi
  8006df:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e3:	75 f9                	jne    8006de <vprintfmt+0x378>
  8006e5:	e9 9f fc ff ff       	jmp    800389 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ea:	83 c4 4c             	add    $0x4c,%esp
  8006ed:	5b                   	pop    %ebx
  8006ee:	5e                   	pop    %esi
  8006ef:	5f                   	pop    %edi
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 28             	sub    $0x28,%esp
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800701:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800705:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800708:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 30                	je     800743 <vsnprintf+0x51>
  800713:	85 d2                	test   %edx,%edx
  800715:	7e 33                	jle    80074a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071e:	8b 45 10             	mov    0x10(%ebp),%eax
  800721:	89 44 24 08          	mov    %eax,0x8(%esp)
  800725:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072c:	c7 04 24 24 03 80 00 	movl   $0x800324,(%esp)
  800733:	e8 2e fc ff ff       	call   800366 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	eb 0c                	jmp    80074f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800748:	eb 05                	jmp    80074f <vsnprintf+0x5d>
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074f:	c9                   	leave  
  800750:	c3                   	ret    

00800751 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	8b 45 10             	mov    0x10(%ebp),%eax
  800761:	89 44 24 08          	mov    %eax,0x8(%esp)
  800765:	8b 45 0c             	mov    0xc(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 7b ff ff ff       	call   8006f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800777:	c9                   	leave  
  800778:	c3                   	ret    
  800779:	00 00                	add    %al,(%eax)
	...

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	eb 01                	jmp    80078a <strlen+0xe>
		n++;
  800789:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078e:	75 f9                	jne    800789 <strlen+0xd>
		n++;
	return n;
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a0:	eb 01                	jmp    8007a3 <strnlen+0x11>
		n++;
  8007a2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	39 d0                	cmp    %edx,%eax
  8007a5:	74 06                	je     8007ad <strnlen+0x1b>
  8007a7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ab:	75 f5                	jne    8007a2 <strnlen+0x10>
		n++;
	return n;
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007be:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c4:	42                   	inc    %edx
  8007c5:	84 c9                	test   %cl,%cl
  8007c7:	75 f5                	jne    8007be <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d6:	89 1c 24             	mov    %ebx,(%esp)
  8007d9:	e8 9e ff ff ff       	call   80077c <strlen>
	strcpy(dst + len, src);
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e5:	01 d8                	add    %ebx,%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	e8 c0 ff ff ff       	call   8007af <strcpy>
	return dst;
}
  8007ef:	89 d8                	mov    %ebx,%eax
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800805:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080a:	eb 0c                	jmp    800818 <strncpy+0x21>
		*dst++ = *src;
  80080c:	8a 1a                	mov    (%edx),%bl
  80080e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800811:	80 3a 01             	cmpb   $0x1,(%edx)
  800814:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800817:	41                   	inc    %ecx
  800818:	39 f1                	cmp    %esi,%ecx
  80081a:	75 f0                	jne    80080c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	56                   	push   %esi
  800824:	53                   	push   %ebx
  800825:	8b 75 08             	mov    0x8(%ebp),%esi
  800828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082e:	85 d2                	test   %edx,%edx
  800830:	75 0a                	jne    80083c <strlcpy+0x1c>
  800832:	89 f0                	mov    %esi,%eax
  800834:	eb 1a                	jmp    800850 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	88 18                	mov    %bl,(%eax)
  800838:	40                   	inc    %eax
  800839:	41                   	inc    %ecx
  80083a:	eb 02                	jmp    80083e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80083e:	4a                   	dec    %edx
  80083f:	74 0a                	je     80084b <strlcpy+0x2b>
  800841:	8a 19                	mov    (%ecx),%bl
  800843:	84 db                	test   %bl,%bl
  800845:	75 ef                	jne    800836 <strlcpy+0x16>
  800847:	89 c2                	mov    %eax,%edx
  800849:	eb 02                	jmp    80084d <strlcpy+0x2d>
  80084b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085f:	eb 02                	jmp    800863 <strcmp+0xd>
		p++, q++;
  800861:	41                   	inc    %ecx
  800862:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800863:	8a 01                	mov    (%ecx),%al
  800865:	84 c0                	test   %al,%al
  800867:	74 04                	je     80086d <strcmp+0x17>
  800869:	3a 02                	cmp    (%edx),%al
  80086b:	74 f4                	je     800861 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 c0             	movzbl %al,%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800884:	eb 03                	jmp    800889 <strncmp+0x12>
		n--, p++, q++;
  800886:	4a                   	dec    %edx
  800887:	40                   	inc    %eax
  800888:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 14                	je     8008a1 <strncmp+0x2a>
  80088d:	8a 18                	mov    (%eax),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	74 04                	je     800897 <strncmp+0x20>
  800893:	3a 19                	cmp    (%ecx),%bl
  800895:	74 ef                	je     800886 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 00             	movzbl (%eax),%eax
  80089a:	0f b6 11             	movzbl (%ecx),%edx
  80089d:	29 d0                	sub    %edx,%eax
  80089f:	eb 05                	jmp    8008a6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b2:	eb 05                	jmp    8008b9 <strchr+0x10>
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 0c                	je     8008c4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b8:	40                   	inc    %eax
  8008b9:	8a 10                	mov    (%eax),%dl
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	75 f5                	jne    8008b4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cf:	eb 05                	jmp    8008d6 <strfind+0x10>
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 07                	je     8008dc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d5:	40                   	inc    %eax
  8008d6:	8a 10                	mov    (%eax),%dl
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 f5                	jne    8008d1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	57                   	push   %edi
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 30                	je     800921 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f7:	75 25                	jne    80091e <memset+0x40>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 20                	jne    80091e <memset+0x40>
		c &= 0xFF;
  8008fe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800901:	89 d3                	mov    %edx,%ebx
  800903:	c1 e3 08             	shl    $0x8,%ebx
  800906:	89 d6                	mov    %edx,%esi
  800908:	c1 e6 18             	shl    $0x18,%esi
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	c1 e0 10             	shl    $0x10,%eax
  800910:	09 f0                	or     %esi,%eax
  800912:	09 d0                	or     %edx,%eax
  800914:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800916:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800919:	fc                   	cld    
  80091a:	f3 ab                	rep stos %eax,%es:(%edi)
  80091c:	eb 03                	jmp    800921 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 34                	jae    80096e <memmove+0x46>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 d0                	cmp    %edx,%eax
  80093f:	73 2d                	jae    80096e <memmove+0x46>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	f6 c2 03             	test   $0x3,%dl
  800947:	75 1b                	jne    800964 <memmove+0x3c>
  800949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094f:	75 13                	jne    800964 <memmove+0x3c>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0e                	jne    800964 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 07                	jmp    80096b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800964:	4f                   	dec    %edi
  800965:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800968:	fd                   	std    
  800969:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096b:	fc                   	cld    
  80096c:	eb 20                	jmp    80098e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800974:	75 13                	jne    800989 <memmove+0x61>
  800976:	a8 03                	test   $0x3,%al
  800978:	75 0f                	jne    800989 <memmove+0x61>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0a                	jne    800989 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800998:	8b 45 10             	mov    0x10(%ebp),%eax
  80099b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 77 ff ff ff       	call   800928 <memmove>
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c7:	eb 16                	jmp    8009df <memcmp+0x2c>
		if (*s1 != *s2)
  8009c9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009cc:	42                   	inc    %edx
  8009cd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009d1:	38 c8                	cmp    %cl,%al
  8009d3:	74 0a                	je     8009df <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c0             	movzbl %al,%eax
  8009d8:	0f b6 c9             	movzbl %cl,%ecx
  8009db:	29 c8                	sub    %ecx,%eax
  8009dd:	eb 09                	jmp    8009e8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009df:	39 da                	cmp    %ebx,%edx
  8009e1:	75 e6                	jne    8009c9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f6:	89 c2                	mov    %eax,%edx
  8009f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fb:	eb 05                	jmp    800a02 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	38 08                	cmp    %cl,(%eax)
  8009ff:	74 05                	je     800a06 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	40                   	inc    %eax
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	72 f7                	jb     8009fd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	eb 01                	jmp    800a17 <strtol+0xf>
		s++;
  800a16:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a17:	8a 02                	mov    (%edx),%al
  800a19:	3c 20                	cmp    $0x20,%al
  800a1b:	74 f9                	je     800a16 <strtol+0xe>
  800a1d:	3c 09                	cmp    $0x9,%al
  800a1f:	74 f5                	je     800a16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a21:	3c 2b                	cmp    $0x2b,%al
  800a23:	75 08                	jne    800a2d <strtol+0x25>
		s++;
  800a25:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2b:	eb 13                	jmp    800a40 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2d:	3c 2d                	cmp    $0x2d,%al
  800a2f:	75 0a                	jne    800a3b <strtol+0x33>
		s++, neg = 1;
  800a31:	8d 52 01             	lea    0x1(%edx),%edx
  800a34:	bf 01 00 00 00       	mov    $0x1,%edi
  800a39:	eb 05                	jmp    800a40 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a40:	85 db                	test   %ebx,%ebx
  800a42:	74 05                	je     800a49 <strtol+0x41>
  800a44:	83 fb 10             	cmp    $0x10,%ebx
  800a47:	75 28                	jne    800a71 <strtol+0x69>
  800a49:	8a 02                	mov    (%edx),%al
  800a4b:	3c 30                	cmp    $0x30,%al
  800a4d:	75 10                	jne    800a5f <strtol+0x57>
  800a4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a53:	75 0a                	jne    800a5f <strtol+0x57>
		s += 2, base = 16;
  800a55:	83 c2 02             	add    $0x2,%edx
  800a58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5d:	eb 12                	jmp    800a71 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	75 0e                	jne    800a71 <strtol+0x69>
  800a63:	3c 30                	cmp    $0x30,%al
  800a65:	75 05                	jne    800a6c <strtol+0x64>
		s++, base = 8;
  800a67:	42                   	inc    %edx
  800a68:	b3 08                	mov    $0x8,%bl
  800a6a:	eb 05                	jmp    800a71 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a78:	8a 0a                	mov    (%edx),%cl
  800a7a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a7d:	80 fb 09             	cmp    $0x9,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x82>
			dig = *s - '0';
  800a82:	0f be c9             	movsbl %cl,%ecx
  800a85:	83 e9 30             	sub    $0x30,%ecx
  800a88:	eb 1e                	jmp    800aa8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a8a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a92:	0f be c9             	movsbl %cl,%ecx
  800a95:	83 e9 57             	sub    $0x57,%ecx
  800a98:	eb 0e                	jmp    800aa8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a9d:	80 fb 19             	cmp    $0x19,%bl
  800aa0:	77 12                	ja     800ab4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aa2:	0f be c9             	movsbl %cl,%ecx
  800aa5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa8:	39 f1                	cmp    %esi,%ecx
  800aaa:	7d 0c                	jge    800ab8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aac:	42                   	inc    %edx
  800aad:	0f af c6             	imul   %esi,%eax
  800ab0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab2:	eb c4                	jmp    800a78 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab4:	89 c1                	mov    %eax,%ecx
  800ab6:	eb 02                	jmp    800aba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abe:	74 05                	je     800ac5 <strtol+0xbd>
		*endptr = (char *) s;
  800ac0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	74 04                	je     800acd <strtol+0xc5>
  800ac9:	89 c8                	mov    %ecx,%eax
  800acb:	f7 d8                	neg    %eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    
	...

00800ad4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	89 c6                	mov    %eax,%esi
  800aeb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cgetc>:

int
sys_cgetc(void)
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
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 cb                	mov    %ecx,%ebx
  800b29:	89 cf                	mov    %ecx,%edi
  800b2b:	89 ce                	mov    %ecx,%esi
  800b2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	7e 28                	jle    800b5b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b37:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800b46:	00 
  800b47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4e:	00 
  800b4f:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800b56:	e8 d1 13 00 00       	call   801f2c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5b:	83 c4 2c             	add    $0x2c,%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b73:	89 d1                	mov    %edx,%ecx
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	89 d7                	mov    %edx,%edi
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_yield>:

void
sys_yield(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800baa:	be 00 00 00 00       	mov    $0x0,%esi
  800baf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	89 f7                	mov    %esi,%edi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 28                	jle    800bed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800bd8:	00 
  800bd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be0:	00 
  800be1:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800be8:	e8 3f 13 00 00       	call   801f2c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bed:	83 c4 2c             	add    $0x2c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800c03:	8b 75 18             	mov    0x18(%ebp),%esi
  800c06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 28                	jle    800c40 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c23:	00 
  800c24:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800c2b:	00 
  800c2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c33:	00 
  800c34:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800c3b:	e8 ec 12 00 00       	call   801f2c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c40:	83 c4 2c             	add    $0x2c,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 28                	jle    800c93 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c76:	00 
  800c77:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c86:	00 
  800c87:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800c8e:	e8 99 12 00 00       	call   801f2c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c93:	83 c4 2c             	add    $0x2c,%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 df                	mov    %ebx,%edi
  800cb6:	89 de                	mov    %ebx,%esi
  800cb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 28                	jle    800ce6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc9:	00 
  800cca:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800cd1:	00 
  800cd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd9:	00 
  800cda:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800ce1:	e8 46 12 00 00       	call   801f2c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce6:	83 c4 2c             	add    $0x2c,%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 09 00 00 00       	mov    $0x9,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 28                	jle    800d39 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d15:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800d24:	00 
  800d25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2c:	00 
  800d2d:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800d34:	e8 f3 11 00 00       	call   801f2c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d39:	83 c4 2c             	add    $0x2c,%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 df                	mov    %ebx,%edi
  800d5c:	89 de                	mov    %ebx,%esi
  800d5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7e 28                	jle    800d8c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d68:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d6f:	00 
  800d70:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800d77:	00 
  800d78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7f:	00 
  800d80:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800d87:	e8 a0 11 00 00       	call   801f2c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8c:	83 c4 2c             	add    $0x2c,%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	be 00 00 00 00       	mov    $0x0,%esi
  800d9f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 cb                	mov    %ecx,%ebx
  800dcf:	89 cf                	mov    %ecx,%edi
  800dd1:	89 ce                	mov    %ecx,%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 28                	jle    800e01 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800dfc:	e8 2b 11 00 00       	call   801f2c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e01:	83 c4 2c             	add    $0x2c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    
  800e09:	00 00                	add    %al,(%eax)
	...

00800e0c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 24             	sub    $0x24,%esp
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e16:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800e18:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e1c:	75 2d                	jne    800e4b <pgfault+0x3f>
  800e1e:	89 d8                	mov    %ebx,%eax
  800e20:	c1 e8 0c             	shr    $0xc,%eax
  800e23:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2a:	f6 c4 08             	test   $0x8,%ah
  800e2d:	75 1c                	jne    800e4b <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800e2f:	c7 44 24 08 0c 27 80 	movl   $0x80270c,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  800e46:	e8 e1 10 00 00       	call   801f2c <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800e4b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e52:	00 
  800e53:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e5a:	00 
  800e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e62:	e8 3a fd ff ff       	call   800ba1 <sys_page_alloc>
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 20                	jns    800e8b <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800e6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e6f:	c7 44 24 08 7b 27 80 	movl   $0x80277b,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800e7e:	00 
  800e7f:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  800e86:	e8 a1 10 00 00       	call   801f2c <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e8b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e91:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e98:	00 
  800e99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e9d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ea4:	e8 e9 fa ff ff       	call   800992 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800ea9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800eb0:	00 
  800eb1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eb5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ec4:	00 
  800ec5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ecc:	e8 24 fd ff ff       	call   800bf5 <sys_page_map>
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	79 20                	jns    800ef5 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  800ed5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed9:	c7 44 24 08 8e 27 80 	movl   $0x80278e,0x8(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ee8:	00 
  800ee9:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  800ef0:	e8 37 10 00 00       	call   801f2c <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ef5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800efc:	00 
  800efd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f04:	e8 3f fd ff ff       	call   800c48 <sys_page_unmap>
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	79 20                	jns    800f2d <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  800f0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f11:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  800f28:	e8 ff 0f 00 00       	call   801f2c <_panic>
}
  800f2d:	83 c4 24             	add    $0x24,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  800f3c:	c7 04 24 0c 0e 80 00 	movl   $0x800e0c,(%esp)
  800f43:	e8 3c 10 00 00       	call   801f84 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f48:	ba 07 00 00 00       	mov    $0x7,%edx
  800f4d:	89 d0                	mov    %edx,%eax
  800f4f:	cd 30                	int    $0x30
  800f51:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f54:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  800f57:	85 c0                	test   %eax,%eax
  800f59:	79 1c                	jns    800f77 <fork+0x44>
		panic("sys_exofork failed\n");
  800f5b:	c7 44 24 08 b2 27 80 	movl   $0x8027b2,0x8(%esp)
  800f62:	00 
  800f63:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  800f6a:	00 
  800f6b:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  800f72:	e8 b5 0f 00 00       	call   801f2c <_panic>
	if(c_envid == 0){
  800f77:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f7b:	75 25                	jne    800fa2 <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f7d:	e8 e1 fb ff ff       	call   800b63 <sys_getenvid>
  800f82:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f8e:	c1 e0 07             	shl    $0x7,%eax
  800f91:	29 d0                	sub    %edx,%eax
  800f93:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f98:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f9d:	e9 e3 01 00 00       	jmp    801185 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  800fa2:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	c1 e8 16             	shr    $0x16,%eax
  800fac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb3:	a8 01                	test   $0x1,%al
  800fb5:	0f 84 0b 01 00 00    	je     8010c6 <fork+0x193>
  800fbb:	89 de                	mov    %ebx,%esi
  800fbd:	c1 ee 0c             	shr    $0xc,%esi
  800fc0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc7:	a8 05                	test   $0x5,%al
  800fc9:	0f 84 f7 00 00 00    	je     8010c6 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  800fcf:	89 f7                	mov    %esi,%edi
  800fd1:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  800fd4:	e8 8a fb ff ff       	call   800b63 <sys_getenvid>
  800fd9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800fdc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe3:	a8 02                	test   $0x2,%al
  800fe5:	75 10                	jne    800ff7 <fork+0xc4>
  800fe7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fee:	f6 c4 08             	test   $0x8,%ah
  800ff1:	0f 84 89 00 00 00    	je     801080 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  800ff7:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800ffe:	00 
  800fff:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801003:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801006:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80100e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801011:	89 04 24             	mov    %eax,(%esp)
  801014:	e8 dc fb ff ff       	call   800bf5 <sys_page_map>
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 20                	jns    80103d <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  80101d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801021:	c7 44 24 08 c6 27 80 	movl   $0x8027c6,0x8(%esp)
  801028:	00 
  801029:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  801030:	00 
  801031:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  801038:	e8 ef 0e 00 00       	call   801f2c <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  80103d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801044:	00 
  801045:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801049:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80104c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801050:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801054:	89 04 24             	mov    %eax,(%esp)
  801057:	e8 99 fb ff ff       	call   800bf5 <sys_page_map>
  80105c:	85 c0                	test   %eax,%eax
  80105e:	79 66                	jns    8010c6 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801060:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801064:	c7 44 24 08 c6 27 80 	movl   $0x8027c6,0x8(%esp)
  80106b:	00 
  80106c:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801073:	00 
  801074:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  80107b:	e8 ac 0e 00 00       	call   801f2c <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  801080:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801087:	00 
  801088:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80108c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80108f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801093:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801097:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80109a:	89 04 24             	mov    %eax,(%esp)
  80109d:	e8 53 fb ff ff       	call   800bf5 <sys_page_map>
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	79 20                	jns    8010c6 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  8010a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010aa:	c7 44 24 08 c6 27 80 	movl   $0x8027c6,0x8(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8010b9:	00 
  8010ba:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  8010c1:	e8 66 0e 00 00       	call   801f2c <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  8010c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010cc:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d2:	0f 85 cf fe ff ff    	jne    800fa7 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  8010d8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010df:	00 
  8010e0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010e7:	ee 
  8010e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010eb:	89 04 24             	mov    %eax,(%esp)
  8010ee:	e8 ae fa ff ff       	call   800ba1 <sys_page_alloc>
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 20                	jns    801117 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  8010f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010fb:	c7 44 24 08 d8 27 80 	movl   $0x8027d8,0x8(%esp)
  801102:	00 
  801103:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80110a:	00 
  80110b:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  801112:	e8 15 0e 00 00       	call   801f2c <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801117:	c7 44 24 04 d0 1f 80 	movl   $0x801fd0,0x4(%esp)
  80111e:	00 
  80111f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801122:	89 04 24             	mov    %eax,(%esp)
  801125:	e8 17 fc ff ff       	call   800d41 <sys_env_set_pgfault_upcall>
  80112a:	85 c0                	test   %eax,%eax
  80112c:	79 20                	jns    80114e <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80112e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801132:	c7 44 24 08 50 27 80 	movl   $0x802750,0x8(%esp)
  801139:	00 
  80113a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801141:	00 
  801142:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  801149:	e8 de 0d 00 00       	call   801f2c <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  80114e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801155:	00 
  801156:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801159:	89 04 24             	mov    %eax,(%esp)
  80115c:	e8 3a fb ff ff       	call   800c9b <sys_env_set_status>
  801161:	85 c0                	test   %eax,%eax
  801163:	79 20                	jns    801185 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  801165:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801169:	c7 44 24 08 ec 27 80 	movl   $0x8027ec,0x8(%esp)
  801170:	00 
  801171:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801178:	00 
  801179:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  801180:	e8 a7 0d 00 00       	call   801f2c <_panic>
 
	return c_envid;	
}
  801185:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801188:	83 c4 3c             	add    $0x3c,%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <sfork>:

// Challenge!
int
sfork(void)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801196:	c7 44 24 08 04 28 80 	movl   $0x802804,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  8011ad:	e8 7a 0d 00 00       	call   801f2c <_panic>
	...

008011b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	89 04 24             	mov    %eax,(%esp)
  8011d0:	e8 df ff ff ff       	call   8011b4 <fd2num>
  8011d5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011da:	c1 e0 0c             	shl    $0xc,%eax
}
  8011dd:	c9                   	leave  
  8011de:	c3                   	ret    

008011df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	53                   	push   %ebx
  8011e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011eb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	c1 ea 16             	shr    $0x16,%edx
  8011f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f9:	f6 c2 01             	test   $0x1,%dl
  8011fc:	74 11                	je     80120f <fd_alloc+0x30>
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	c1 ea 0c             	shr    $0xc,%edx
  801203:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120a:	f6 c2 01             	test   $0x1,%dl
  80120d:	75 09                	jne    801218 <fd_alloc+0x39>
			*fd_store = fd;
  80120f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
  801216:	eb 17                	jmp    80122f <fd_alloc+0x50>
  801218:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80121d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801222:	75 c7                	jne    8011eb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801224:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80122a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80122f:	5b                   	pop    %ebx
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801238:	83 f8 1f             	cmp    $0x1f,%eax
  80123b:	77 36                	ja     801273 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801242:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801245:	89 c2                	mov    %eax,%edx
  801247:	c1 ea 16             	shr    $0x16,%edx
  80124a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 24                	je     80127a <fd_lookup+0x48>
  801256:	89 c2                	mov    %eax,%edx
  801258:	c1 ea 0c             	shr    $0xc,%edx
  80125b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	74 1a                	je     801281 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126a:	89 02                	mov    %eax,(%edx)
	return 0;
  80126c:	b8 00 00 00 00       	mov    $0x0,%eax
  801271:	eb 13                	jmp    801286 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801278:	eb 0c                	jmp    801286 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127f:	eb 05                	jmp    801286 <fd_lookup+0x54>
  801281:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	53                   	push   %ebx
  80128c:	83 ec 14             	sub    $0x14,%esp
  80128f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801295:	ba 00 00 00 00       	mov    $0x0,%edx
  80129a:	eb 0e                	jmp    8012aa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80129c:	39 08                	cmp    %ecx,(%eax)
  80129e:	75 09                	jne    8012a9 <dev_lookup+0x21>
			*dev = devtab[i];
  8012a0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a7:	eb 33                	jmp    8012dc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a9:	42                   	inc    %edx
  8012aa:	8b 04 95 98 28 80 00 	mov    0x802898(,%edx,4),%eax
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	75 e7                	jne    80129c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ba:	8b 40 48             	mov    0x48(%eax),%eax
  8012bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c5:	c7 04 24 1c 28 80 00 	movl   $0x80281c,(%esp)
  8012cc:	e8 33 ef ff ff       	call   800204 <cprintf>
	*dev = 0;
  8012d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012dc:	83 c4 14             	add    $0x14,%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 30             	sub    $0x30,%esp
  8012ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ed:	8a 45 0c             	mov    0xc(%ebp),%al
  8012f0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f3:	89 34 24             	mov    %esi,(%esp)
  8012f6:	e8 b9 fe ff ff       	call   8011b4 <fd2num>
  8012fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801302:	89 04 24             	mov    %eax,(%esp)
  801305:	e8 28 ff ff ff       	call   801232 <fd_lookup>
  80130a:	89 c3                	mov    %eax,%ebx
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 05                	js     801315 <fd_close+0x33>
	    || fd != fd2)
  801310:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801313:	74 0d                	je     801322 <fd_close+0x40>
		return (must_exist ? r : 0);
  801315:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801319:	75 46                	jne    801361 <fd_close+0x7f>
  80131b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801320:	eb 3f                	jmp    801361 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801322:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801325:	89 44 24 04          	mov    %eax,0x4(%esp)
  801329:	8b 06                	mov    (%esi),%eax
  80132b:	89 04 24             	mov    %eax,(%esp)
  80132e:	e8 55 ff ff ff       	call   801288 <dev_lookup>
  801333:	89 c3                	mov    %eax,%ebx
  801335:	85 c0                	test   %eax,%eax
  801337:	78 18                	js     801351 <fd_close+0x6f>
		if (dev->dev_close)
  801339:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133c:	8b 40 10             	mov    0x10(%eax),%eax
  80133f:	85 c0                	test   %eax,%eax
  801341:	74 09                	je     80134c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801343:	89 34 24             	mov    %esi,(%esp)
  801346:	ff d0                	call   *%eax
  801348:	89 c3                	mov    %eax,%ebx
  80134a:	eb 05                	jmp    801351 <fd_close+0x6f>
		else
			r = 0;
  80134c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801351:	89 74 24 04          	mov    %esi,0x4(%esp)
  801355:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135c:	e8 e7 f8 ff ff       	call   800c48 <sys_page_unmap>
	return r;
}
  801361:	89 d8                	mov    %ebx,%eax
  801363:	83 c4 30             	add    $0x30,%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	89 44 24 04          	mov    %eax,0x4(%esp)
  801377:	8b 45 08             	mov    0x8(%ebp),%eax
  80137a:	89 04 24             	mov    %eax,(%esp)
  80137d:	e8 b0 fe ff ff       	call   801232 <fd_lookup>
  801382:	85 c0                	test   %eax,%eax
  801384:	78 13                	js     801399 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801386:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80138d:	00 
  80138e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801391:	89 04 24             	mov    %eax,(%esp)
  801394:	e8 49 ff ff ff       	call   8012e2 <fd_close>
}
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <close_all>:

void
close_all(void)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	53                   	push   %ebx
  80139f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a7:	89 1c 24             	mov    %ebx,(%esp)
  8013aa:	e8 bb ff ff ff       	call   80136a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013af:	43                   	inc    %ebx
  8013b0:	83 fb 20             	cmp    $0x20,%ebx
  8013b3:	75 f2                	jne    8013a7 <close_all+0xc>
		close(i);
}
  8013b5:	83 c4 14             	add    $0x14,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	57                   	push   %edi
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 4c             	sub    $0x4c,%esp
  8013c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 59 fe ff ff       	call   801232 <fd_lookup>
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	0f 88 e1 00 00 00    	js     8014c4 <dup+0x109>
		return r;
	close(newfdnum);
  8013e3:	89 3c 24             	mov    %edi,(%esp)
  8013e6:	e8 7f ff ff ff       	call   80136a <close>

	newfd = INDEX2FD(newfdnum);
  8013eb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013f1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013f7:	89 04 24             	mov    %eax,(%esp)
  8013fa:	e8 c5 fd ff ff       	call   8011c4 <fd2data>
  8013ff:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801401:	89 34 24             	mov    %esi,(%esp)
  801404:	e8 bb fd ff ff       	call   8011c4 <fd2data>
  801409:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80140c:	89 d8                	mov    %ebx,%eax
  80140e:	c1 e8 16             	shr    $0x16,%eax
  801411:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801418:	a8 01                	test   $0x1,%al
  80141a:	74 46                	je     801462 <dup+0xa7>
  80141c:	89 d8                	mov    %ebx,%eax
  80141e:	c1 e8 0c             	shr    $0xc,%eax
  801421:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801428:	f6 c2 01             	test   $0x1,%dl
  80142b:	74 35                	je     801462 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80142d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801434:	25 07 0e 00 00       	and    $0xe07,%eax
  801439:	89 44 24 10          	mov    %eax,0x10(%esp)
  80143d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801444:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80144b:	00 
  80144c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801450:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801457:	e8 99 f7 ff ff       	call   800bf5 <sys_page_map>
  80145c:	89 c3                	mov    %eax,%ebx
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 3b                	js     80149d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801462:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801465:	89 c2                	mov    %eax,%edx
  801467:	c1 ea 0c             	shr    $0xc,%edx
  80146a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801471:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801477:	89 54 24 10          	mov    %edx,0x10(%esp)
  80147b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80147f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801486:	00 
  801487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801492:	e8 5e f7 ff ff       	call   800bf5 <sys_page_map>
  801497:	89 c3                	mov    %eax,%ebx
  801499:	85 c0                	test   %eax,%eax
  80149b:	79 25                	jns    8014c2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80149d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a8:	e8 9b f7 ff ff       	call   800c48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014bb:	e8 88 f7 ff ff       	call   800c48 <sys_page_unmap>
	return r;
  8014c0:	eb 02                	jmp    8014c4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014c2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014c4:	89 d8                	mov    %ebx,%eax
  8014c6:	83 c4 4c             	add    $0x4c,%esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5e                   	pop    %esi
  8014cb:	5f                   	pop    %edi
  8014cc:	5d                   	pop    %ebp
  8014cd:	c3                   	ret    

008014ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 24             	sub    $0x24,%esp
  8014d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014df:	89 1c 24             	mov    %ebx,(%esp)
  8014e2:	e8 4b fd ff ff       	call   801232 <fd_lookup>
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 6d                	js     801558 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f5:	8b 00                	mov    (%eax),%eax
  8014f7:	89 04 24             	mov    %eax,(%esp)
  8014fa:	e8 89 fd ff ff       	call   801288 <dev_lookup>
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 55                	js     801558 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801503:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801506:	8b 50 08             	mov    0x8(%eax),%edx
  801509:	83 e2 03             	and    $0x3,%edx
  80150c:	83 fa 01             	cmp    $0x1,%edx
  80150f:	75 23                	jne    801534 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801511:	a1 04 40 80 00       	mov    0x804004,%eax
  801516:	8b 40 48             	mov    0x48(%eax),%eax
  801519:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80151d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801521:	c7 04 24 5d 28 80 00 	movl   $0x80285d,(%esp)
  801528:	e8 d7 ec ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  80152d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801532:	eb 24                	jmp    801558 <read+0x8a>
	}
	if (!dev->dev_read)
  801534:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801537:	8b 52 08             	mov    0x8(%edx),%edx
  80153a:	85 d2                	test   %edx,%edx
  80153c:	74 15                	je     801553 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80153e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801541:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801545:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801548:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	ff d2                	call   *%edx
  801551:	eb 05                	jmp    801558 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801553:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801558:	83 c4 24             	add    $0x24,%esp
  80155b:	5b                   	pop    %ebx
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	57                   	push   %edi
  801562:	56                   	push   %esi
  801563:	53                   	push   %ebx
  801564:	83 ec 1c             	sub    $0x1c,%esp
  801567:	8b 7d 08             	mov    0x8(%ebp),%edi
  80156a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801572:	eb 23                	jmp    801597 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801574:	89 f0                	mov    %esi,%eax
  801576:	29 d8                	sub    %ebx,%eax
  801578:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157f:	01 d8                	add    %ebx,%eax
  801581:	89 44 24 04          	mov    %eax,0x4(%esp)
  801585:	89 3c 24             	mov    %edi,(%esp)
  801588:	e8 41 ff ff ff       	call   8014ce <read>
		if (m < 0)
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 10                	js     8015a1 <readn+0x43>
			return m;
		if (m == 0)
  801591:	85 c0                	test   %eax,%eax
  801593:	74 0a                	je     80159f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801595:	01 c3                	add    %eax,%ebx
  801597:	39 f3                	cmp    %esi,%ebx
  801599:	72 d9                	jb     801574 <readn+0x16>
  80159b:	89 d8                	mov    %ebx,%eax
  80159d:	eb 02                	jmp    8015a1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80159f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015a1:	83 c4 1c             	add    $0x1c,%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5e                   	pop    %esi
  8015a6:	5f                   	pop    %edi
  8015a7:	5d                   	pop    %ebp
  8015a8:	c3                   	ret    

008015a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 24             	sub    $0x24,%esp
  8015b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ba:	89 1c 24             	mov    %ebx,(%esp)
  8015bd:	e8 70 fc ff ff       	call   801232 <fd_lookup>
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 68                	js     80162e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d0:	8b 00                	mov    (%eax),%eax
  8015d2:	89 04 24             	mov    %eax,(%esp)
  8015d5:	e8 ae fc ff ff       	call   801288 <dev_lookup>
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 50                	js     80162e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e5:	75 23                	jne    80160a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ec:	8b 40 48             	mov    0x48(%eax),%eax
  8015ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f7:	c7 04 24 79 28 80 00 	movl   $0x802879,(%esp)
  8015fe:	e8 01 ec ff ff       	call   800204 <cprintf>
		return -E_INVAL;
  801603:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801608:	eb 24                	jmp    80162e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80160a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160d:	8b 52 0c             	mov    0xc(%edx),%edx
  801610:	85 d2                	test   %edx,%edx
  801612:	74 15                	je     801629 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801614:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801617:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80161b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80161e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801622:	89 04 24             	mov    %eax,(%esp)
  801625:	ff d2                	call   *%edx
  801627:	eb 05                	jmp    80162e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801629:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80162e:	83 c4 24             	add    $0x24,%esp
  801631:	5b                   	pop    %ebx
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    

00801634 <seek>:

int
seek(int fdnum, off_t offset)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80163a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80163d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	89 04 24             	mov    %eax,(%esp)
  801647:	e8 e6 fb ff ff       	call   801232 <fd_lookup>
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 0e                	js     80165e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801650:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801653:	8b 55 0c             	mov    0xc(%ebp),%edx
  801656:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	53                   	push   %ebx
  801664:	83 ec 24             	sub    $0x24,%esp
  801667:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801671:	89 1c 24             	mov    %ebx,(%esp)
  801674:	e8 b9 fb ff ff       	call   801232 <fd_lookup>
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 61                	js     8016de <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801680:	89 44 24 04          	mov    %eax,0x4(%esp)
  801684:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801687:	8b 00                	mov    (%eax),%eax
  801689:	89 04 24             	mov    %eax,(%esp)
  80168c:	e8 f7 fb ff ff       	call   801288 <dev_lookup>
  801691:	85 c0                	test   %eax,%eax
  801693:	78 49                	js     8016de <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801695:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801698:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169c:	75 23                	jne    8016c1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80169e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a3:	8b 40 48             	mov    0x48(%eax),%eax
  8016a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ae:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  8016b5:	e8 4a eb ff ff       	call   800204 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bf:	eb 1d                	jmp    8016de <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c4:	8b 52 18             	mov    0x18(%edx),%edx
  8016c7:	85 d2                	test   %edx,%edx
  8016c9:	74 0e                	je     8016d9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016d2:	89 04 24             	mov    %eax,(%esp)
  8016d5:	ff d2                	call   *%edx
  8016d7:	eb 05                	jmp    8016de <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016de:	83 c4 24             	add    $0x24,%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 24             	sub    $0x24,%esp
  8016eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f8:	89 04 24             	mov    %eax,(%esp)
  8016fb:	e8 32 fb ff ff       	call   801232 <fd_lookup>
  801700:	85 c0                	test   %eax,%eax
  801702:	78 52                	js     801756 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801704:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	8b 00                	mov    (%eax),%eax
  801710:	89 04 24             	mov    %eax,(%esp)
  801713:	e8 70 fb ff ff       	call   801288 <dev_lookup>
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 3a                	js     801756 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80171c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801723:	74 2c                	je     801751 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801725:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801728:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172f:	00 00 00 
	stat->st_isdir = 0;
  801732:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801739:	00 00 00 
	stat->st_dev = dev;
  80173c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801742:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801746:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801749:	89 14 24             	mov    %edx,(%esp)
  80174c:	ff 50 14             	call   *0x14(%eax)
  80174f:	eb 05                	jmp    801756 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801751:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801756:	83 c4 24             	add    $0x24,%esp
  801759:	5b                   	pop    %ebx
  80175a:	5d                   	pop    %ebp
  80175b:	c3                   	ret    

0080175c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801764:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80176b:	00 
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
  80176f:	89 04 24             	mov    %eax,(%esp)
  801772:	e8 fe 01 00 00       	call   801975 <open>
  801777:	89 c3                	mov    %eax,%ebx
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 1b                	js     801798 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80177d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801780:	89 44 24 04          	mov    %eax,0x4(%esp)
  801784:	89 1c 24             	mov    %ebx,(%esp)
  801787:	e8 58 ff ff ff       	call   8016e4 <fstat>
  80178c:	89 c6                	mov    %eax,%esi
	close(fd);
  80178e:	89 1c 24             	mov    %ebx,(%esp)
  801791:	e8 d4 fb ff ff       	call   80136a <close>
	return r;
  801796:	89 f3                	mov    %esi,%ebx
}
  801798:	89 d8                	mov    %ebx,%eax
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    
  8017a1:	00 00                	add    %al,(%eax)
	...

008017a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	56                   	push   %esi
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 10             	sub    $0x10,%esp
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017b0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017b7:	75 11                	jne    8017ca <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017c0:	e8 06 09 00 00       	call   8020cb <ipc_find_env>
  8017c5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017d1:	00 
  8017d2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017d9:	00 
  8017da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017de:	a1 00 40 80 00       	mov    0x804000,%eax
  8017e3:	89 04 24             	mov    %eax,(%esp)
  8017e6:	e8 76 08 00 00       	call   802061 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017f2:	00 
  8017f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fe:	e8 f5 07 00 00       	call   801ff8 <ipc_recv>
}
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	5b                   	pop    %ebx
  801807:	5e                   	pop    %esi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	8b 40 0c             	mov    0xc(%eax),%eax
  801816:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 02 00 00 00       	mov    $0x2,%eax
  80182d:	e8 72 ff ff ff       	call   8017a4 <fsipc>
}
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	b8 06 00 00 00       	mov    $0x6,%eax
  80184f:	e8 50 ff ff ff       	call   8017a4 <fsipc>
}
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 14             	sub    $0x14,%esp
  80185d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801860:	8b 45 08             	mov    0x8(%ebp),%eax
  801863:	8b 40 0c             	mov    0xc(%eax),%eax
  801866:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	b8 05 00 00 00       	mov    $0x5,%eax
  801875:	e8 2a ff ff ff       	call   8017a4 <fsipc>
  80187a:	85 c0                	test   %eax,%eax
  80187c:	78 2b                	js     8018a9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80187e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801885:	00 
  801886:	89 1c 24             	mov    %ebx,(%esp)
  801889:	e8 21 ef ff ff       	call   8007af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80188e:	a1 80 50 80 00       	mov    0x805080,%eax
  801893:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801899:	a1 84 50 80 00       	mov    0x805084,%eax
  80189e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a9:	83 c4 14             	add    $0x14,%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018b5:	c7 44 24 08 a8 28 80 	movl   $0x8028a8,0x8(%esp)
  8018bc:	00 
  8018bd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8018c4:	00 
  8018c5:	c7 04 24 c6 28 80 00 	movl   $0x8028c6,(%esp)
  8018cc:	e8 5b 06 00 00       	call   801f2c <_panic>

008018d1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 10             	sub    $0x10,%esp
  8018d9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f7:	e8 a8 fe ff ff       	call   8017a4 <fsipc>
  8018fc:	89 c3                	mov    %eax,%ebx
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 6a                	js     80196c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801902:	39 c6                	cmp    %eax,%esi
  801904:	73 24                	jae    80192a <devfile_read+0x59>
  801906:	c7 44 24 0c d1 28 80 	movl   $0x8028d1,0xc(%esp)
  80190d:	00 
  80190e:	c7 44 24 08 d8 28 80 	movl   $0x8028d8,0x8(%esp)
  801915:	00 
  801916:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80191d:	00 
  80191e:	c7 04 24 c6 28 80 00 	movl   $0x8028c6,(%esp)
  801925:	e8 02 06 00 00       	call   801f2c <_panic>
	assert(r <= PGSIZE);
  80192a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80192f:	7e 24                	jle    801955 <devfile_read+0x84>
  801931:	c7 44 24 0c ed 28 80 	movl   $0x8028ed,0xc(%esp)
  801938:	00 
  801939:	c7 44 24 08 d8 28 80 	movl   $0x8028d8,0x8(%esp)
  801940:	00 
  801941:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801948:	00 
  801949:	c7 04 24 c6 28 80 00 	movl   $0x8028c6,(%esp)
  801950:	e8 d7 05 00 00       	call   801f2c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801955:	89 44 24 08          	mov    %eax,0x8(%esp)
  801959:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801960:	00 
  801961:	8b 45 0c             	mov    0xc(%ebp),%eax
  801964:	89 04 24             	mov    %eax,(%esp)
  801967:	e8 bc ef ff ff       	call   800928 <memmove>
	return r;
}
  80196c:	89 d8                	mov    %ebx,%eax
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	5b                   	pop    %ebx
  801972:	5e                   	pop    %esi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    

00801975 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	56                   	push   %esi
  801979:	53                   	push   %ebx
  80197a:	83 ec 20             	sub    $0x20,%esp
  80197d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801980:	89 34 24             	mov    %esi,(%esp)
  801983:	e8 f4 ed ff ff       	call   80077c <strlen>
  801988:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80198d:	7f 60                	jg     8019ef <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80198f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801992:	89 04 24             	mov    %eax,(%esp)
  801995:	e8 45 f8 ff ff       	call   8011df <fd_alloc>
  80199a:	89 c3                	mov    %eax,%ebx
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 54                	js     8019f4 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019a4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019ab:	e8 ff ed ff ff       	call   8007af <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c0:	e8 df fd ff ff       	call   8017a4 <fsipc>
  8019c5:	89 c3                	mov    %eax,%ebx
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	79 15                	jns    8019e0 <open+0x6b>
		fd_close(fd, 0);
  8019cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019d2:	00 
  8019d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d6:	89 04 24             	mov    %eax,(%esp)
  8019d9:	e8 04 f9 ff ff       	call   8012e2 <fd_close>
		return r;
  8019de:	eb 14                	jmp    8019f4 <open+0x7f>
	}

	return fd2num(fd);
  8019e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e3:	89 04 24             	mov    %eax,(%esp)
  8019e6:	e8 c9 f7 ff ff       	call   8011b4 <fd2num>
  8019eb:	89 c3                	mov    %eax,%ebx
  8019ed:	eb 05                	jmp    8019f4 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ef:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019f4:	89 d8                	mov    %ebx,%eax
  8019f6:	83 c4 20             	add    $0x20,%esp
  8019f9:	5b                   	pop    %ebx
  8019fa:	5e                   	pop    %esi
  8019fb:	5d                   	pop    %ebp
  8019fc:	c3                   	ret    

008019fd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a03:	ba 00 00 00 00       	mov    $0x0,%edx
  801a08:	b8 08 00 00 00       	mov    $0x8,%eax
  801a0d:	e8 92 fd ff ff       	call   8017a4 <fsipc>
}
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
  801a19:	83 ec 10             	sub    $0x10,%esp
  801a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a22:	89 04 24             	mov    %eax,(%esp)
  801a25:	e8 9a f7 ff ff       	call   8011c4 <fd2data>
  801a2a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a2c:	c7 44 24 04 f9 28 80 	movl   $0x8028f9,0x4(%esp)
  801a33:	00 
  801a34:	89 34 24             	mov    %esi,(%esp)
  801a37:	e8 73 ed ff ff       	call   8007af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a3f:	2b 03                	sub    (%ebx),%eax
  801a41:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a47:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a4e:	00 00 00 
	stat->st_dev = &devpipe;
  801a51:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a58:	30 80 00 
	return 0;
}
  801a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	53                   	push   %ebx
  801a6b:	83 ec 14             	sub    $0x14,%esp
  801a6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7c:	e8 c7 f1 ff ff       	call   800c48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a81:	89 1c 24             	mov    %ebx,(%esp)
  801a84:	e8 3b f7 ff ff       	call   8011c4 <fd2data>
  801a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a94:	e8 af f1 ff ff       	call   800c48 <sys_page_unmap>
}
  801a99:	83 c4 14             	add    $0x14,%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	57                   	push   %edi
  801aa3:	56                   	push   %esi
  801aa4:	53                   	push   %ebx
  801aa5:	83 ec 2c             	sub    $0x2c,%esp
  801aa8:	89 c7                	mov    %eax,%edi
  801aaa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aad:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ab5:	89 3c 24             	mov    %edi,(%esp)
  801ab8:	e8 53 06 00 00       	call   802110 <pageref>
  801abd:	89 c6                	mov    %eax,%esi
  801abf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 46 06 00 00       	call   802110 <pageref>
  801aca:	39 c6                	cmp    %eax,%esi
  801acc:	0f 94 c0             	sete   %al
  801acf:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ad2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ad8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801adb:	39 cb                	cmp    %ecx,%ebx
  801add:	75 08                	jne    801ae7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801adf:	83 c4 2c             	add    $0x2c,%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5f                   	pop    %edi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ae7:	83 f8 01             	cmp    $0x1,%eax
  801aea:	75 c1                	jne    801aad <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aec:	8b 42 58             	mov    0x58(%edx),%eax
  801aef:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801af6:	00 
  801af7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801afb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aff:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
  801b06:	e8 f9 e6 ff ff       	call   800204 <cprintf>
  801b0b:	eb a0                	jmp    801aad <_pipeisclosed+0xe>

00801b0d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	57                   	push   %edi
  801b11:	56                   	push   %esi
  801b12:	53                   	push   %ebx
  801b13:	83 ec 1c             	sub    $0x1c,%esp
  801b16:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b19:	89 34 24             	mov    %esi,(%esp)
  801b1c:	e8 a3 f6 ff ff       	call   8011c4 <fd2data>
  801b21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b23:	bf 00 00 00 00       	mov    $0x0,%edi
  801b28:	eb 3c                	jmp    801b66 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b2a:	89 da                	mov    %ebx,%edx
  801b2c:	89 f0                	mov    %esi,%eax
  801b2e:	e8 6c ff ff ff       	call   801a9f <_pipeisclosed>
  801b33:	85 c0                	test   %eax,%eax
  801b35:	75 38                	jne    801b6f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b37:	e8 46 f0 ff ff       	call   800b82 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3f:	8b 13                	mov    (%ebx),%edx
  801b41:	83 c2 20             	add    $0x20,%edx
  801b44:	39 d0                	cmp    %edx,%eax
  801b46:	73 e2                	jae    801b2a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b4b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b56:	79 05                	jns    801b5d <devpipe_write+0x50>
  801b58:	4a                   	dec    %edx
  801b59:	83 ca e0             	or     $0xffffffe0,%edx
  801b5c:	42                   	inc    %edx
  801b5d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b61:	40                   	inc    %eax
  801b62:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b65:	47                   	inc    %edi
  801b66:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b69:	75 d1                	jne    801b3c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b6b:	89 f8                	mov    %edi,%eax
  801b6d:	eb 05                	jmp    801b74 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b74:	83 c4 1c             	add    $0x1c,%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5f                   	pop    %edi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 1c             	sub    $0x1c,%esp
  801b85:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b88:	89 3c 24             	mov    %edi,(%esp)
  801b8b:	e8 34 f6 ff ff       	call   8011c4 <fd2data>
  801b90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b92:	be 00 00 00 00       	mov    $0x0,%esi
  801b97:	eb 3a                	jmp    801bd3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b99:	85 f6                	test   %esi,%esi
  801b9b:	74 04                	je     801ba1 <devpipe_read+0x25>
				return i;
  801b9d:	89 f0                	mov    %esi,%eax
  801b9f:	eb 40                	jmp    801be1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba1:	89 da                	mov    %ebx,%edx
  801ba3:	89 f8                	mov    %edi,%eax
  801ba5:	e8 f5 fe ff ff       	call   801a9f <_pipeisclosed>
  801baa:	85 c0                	test   %eax,%eax
  801bac:	75 2e                	jne    801bdc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bae:	e8 cf ef ff ff       	call   800b82 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb3:	8b 03                	mov    (%ebx),%eax
  801bb5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bb8:	74 df                	je     801b99 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bba:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bbf:	79 05                	jns    801bc6 <devpipe_read+0x4a>
  801bc1:	48                   	dec    %eax
  801bc2:	83 c8 e0             	or     $0xffffffe0,%eax
  801bc5:	40                   	inc    %eax
  801bc6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801bca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bcd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801bd0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd2:	46                   	inc    %esi
  801bd3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bd6:	75 db                	jne    801bb3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bd8:	89 f0                	mov    %esi,%eax
  801bda:	eb 05                	jmp    801be1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801be1:	83 c4 1c             	add    $0x1c,%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	57                   	push   %edi
  801bed:	56                   	push   %esi
  801bee:	53                   	push   %ebx
  801bef:	83 ec 3c             	sub    $0x3c,%esp
  801bf2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bf5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bf8:	89 04 24             	mov    %eax,(%esp)
  801bfb:	e8 df f5 ff ff       	call   8011df <fd_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	85 c0                	test   %eax,%eax
  801c04:	0f 88 45 01 00 00    	js     801d4f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c11:	00 
  801c12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c20:	e8 7c ef ff ff       	call   800ba1 <sys_page_alloc>
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	85 c0                	test   %eax,%eax
  801c29:	0f 88 20 01 00 00    	js     801d4f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c2f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c32:	89 04 24             	mov    %eax,(%esp)
  801c35:	e8 a5 f5 ff ff       	call   8011df <fd_alloc>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	0f 88 f8 00 00 00    	js     801d3c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c44:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c4b:	00 
  801c4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5a:	e8 42 ef ff ff       	call   800ba1 <sys_page_alloc>
  801c5f:	89 c3                	mov    %eax,%ebx
  801c61:	85 c0                	test   %eax,%eax
  801c63:	0f 88 d3 00 00 00    	js     801d3c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c6c:	89 04 24             	mov    %eax,(%esp)
  801c6f:	e8 50 f5 ff ff       	call   8011c4 <fd2data>
  801c74:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c7d:	00 
  801c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c89:	e8 13 ef ff ff       	call   800ba1 <sys_page_alloc>
  801c8e:	89 c3                	mov    %eax,%ebx
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 91 00 00 00    	js     801d29 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c98:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 21 f5 ff ff       	call   8011c4 <fd2data>
  801ca3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801caa:	00 
  801cab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801caf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cb6:	00 
  801cb7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc2:	e8 2e ef ff ff       	call   800bf5 <sys_page_map>
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 4c                	js     801d19 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ccd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cd6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cdb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ceb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cfa:	89 04 24             	mov    %eax,(%esp)
  801cfd:	e8 b2 f4 ff ff       	call   8011b4 <fd2num>
  801d02:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d07:	89 04 24             	mov    %eax,(%esp)
  801d0a:	e8 a5 f4 ff ff       	call   8011b4 <fd2num>
  801d0f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d17:	eb 36                	jmp    801d4f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801d19:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d24:	e8 1f ef ff ff       	call   800c48 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801d29:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d37:	e8 0c ef ff ff       	call   800c48 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801d3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4a:	e8 f9 ee ff ff       	call   800c48 <sys_page_unmap>
    err:
	return r;
}
  801d4f:	89 d8                	mov    %ebx,%eax
  801d51:	83 c4 3c             	add    $0x3c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    

00801d59 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
  801d69:	89 04 24             	mov    %eax,(%esp)
  801d6c:	e8 c1 f4 ff ff       	call   801232 <fd_lookup>
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 15                	js     801d8a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d78:	89 04 24             	mov    %eax,(%esp)
  801d7b:	e8 44 f4 ff ff       	call   8011c4 <fd2data>
	return _pipeisclosed(fd, p);
  801d80:	89 c2                	mov    %eax,%edx
  801d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d85:	e8 15 fd ff ff       	call   801a9f <_pipeisclosed>
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d9c:	c7 44 24 04 18 29 80 	movl   $0x802918,0x4(%esp)
  801da3:	00 
  801da4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da7:	89 04 24             	mov    %eax,(%esp)
  801daa:	e8 00 ea ff ff       	call   8007af <strcpy>
	return 0;
}
  801daf:	b8 00 00 00 00       	mov    $0x0,%eax
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	57                   	push   %edi
  801dba:	56                   	push   %esi
  801dbb:	53                   	push   %ebx
  801dbc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcd:	eb 30                	jmp    801dff <devcons_write+0x49>
		m = n - tot;
  801dcf:	8b 75 10             	mov    0x10(%ebp),%esi
  801dd2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801dd4:	83 fe 7f             	cmp    $0x7f,%esi
  801dd7:	76 05                	jbe    801dde <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801dd9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801dde:	89 74 24 08          	mov    %esi,0x8(%esp)
  801de2:	03 45 0c             	add    0xc(%ebp),%eax
  801de5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de9:	89 3c 24             	mov    %edi,(%esp)
  801dec:	e8 37 eb ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  801df1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df5:	89 3c 24             	mov    %edi,(%esp)
  801df8:	e8 d7 ec ff ff       	call   800ad4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfd:	01 f3                	add    %esi,%ebx
  801dff:	89 d8                	mov    %ebx,%eax
  801e01:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e04:	72 c9                	jb     801dcf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e06:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5f                   	pop    %edi
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    

00801e11 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e1b:	75 07                	jne    801e24 <devcons_read+0x13>
  801e1d:	eb 25                	jmp    801e44 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e1f:	e8 5e ed ff ff       	call   800b82 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e24:	e8 c9 ec ff ff       	call   800af2 <sys_cgetc>
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	74 f2                	je     801e1f <devcons_read+0xe>
  801e2d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 1d                	js     801e50 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e33:	83 f8 04             	cmp    $0x4,%eax
  801e36:	74 13                	je     801e4b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3b:	88 10                	mov    %dl,(%eax)
	return 1;
  801e3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e42:	eb 0c                	jmp    801e50 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e44:	b8 00 00 00 00       	mov    $0x0,%eax
  801e49:	eb 05                	jmp    801e50 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e4b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e58:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e5e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e65:	00 
  801e66:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e69:	89 04 24             	mov    %eax,(%esp)
  801e6c:	e8 63 ec ff ff       	call   800ad4 <sys_cputs>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <getchar>:

int
getchar(void)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e79:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e80:	00 
  801e81:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8f:	e8 3a f6 ff ff       	call   8014ce <read>
	if (r < 0)
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 0f                	js     801ea7 <getchar+0x34>
		return r;
	if (r < 1)
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	7e 06                	jle    801ea2 <getchar+0x2f>
		return -E_EOF;
	return c;
  801e9c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ea0:	eb 05                	jmp    801ea7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ea2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb9:	89 04 24             	mov    %eax,(%esp)
  801ebc:	e8 71 f3 ff ff       	call   801232 <fd_lookup>
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 11                	js     801ed6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ece:	39 10                	cmp    %edx,(%eax)
  801ed0:	0f 94 c0             	sete   %al
  801ed3:	0f b6 c0             	movzbl %al,%eax
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <opencons>:

int
opencons(void)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ede:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee1:	89 04 24             	mov    %eax,(%esp)
  801ee4:	e8 f6 f2 ff ff       	call   8011df <fd_alloc>
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	78 3c                	js     801f29 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eed:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ef4:	00 
  801ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f03:	e8 99 ec ff ff       	call   800ba1 <sys_page_alloc>
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 1d                	js     801f29 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f0c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f15:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f21:	89 04 24             	mov    %eax,(%esp)
  801f24:	e8 8b f2 ff ff       	call   8011b4 <fd2num>
}
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    
	...

00801f2c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	56                   	push   %esi
  801f30:	53                   	push   %ebx
  801f31:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801f34:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f37:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801f3d:	e8 21 ec ff ff       	call   800b63 <sys_getenvid>
  801f42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f45:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f49:	8b 55 08             	mov    0x8(%ebp),%edx
  801f4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f58:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  801f5f:	e8 a0 e2 ff ff       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f68:	8b 45 10             	mov    0x10(%ebp),%eax
  801f6b:	89 04 24             	mov    %eax,(%esp)
  801f6e:	e8 30 e2 ff ff       	call   8001a3 <vcprintf>
	cprintf("\n");
  801f73:	c7 04 24 cf 23 80 00 	movl   $0x8023cf,(%esp)
  801f7a:	e8 85 e2 ff ff       	call   800204 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f7f:	cc                   	int3   
  801f80:	eb fd                	jmp    801f7f <_panic+0x53>
	...

00801f84 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f8a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f91:	75 32                	jne    801fc5 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801f93:	e8 cb eb ff ff       	call   800b63 <sys_getenvid>
  801f98:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  801f9f:	00 
  801fa0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801fa7:	ee 
  801fa8:	89 04 24             	mov    %eax,(%esp)
  801fab:	e8 f1 eb ff ff       	call   800ba1 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  801fb0:	e8 ae eb ff ff       	call   800b63 <sys_getenvid>
  801fb5:	c7 44 24 04 d0 1f 80 	movl   $0x801fd0,0x4(%esp)
  801fbc:	00 
  801fbd:	89 04 24             	mov    %eax,(%esp)
  801fc0:	e8 7c ed ff ff       	call   800d41 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    
	...

00801fd0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fd0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fd1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fd6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fd8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  801fdb:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  801fdf:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  801fe2:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  801fe7:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  801feb:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  801fee:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  801fef:	83 c4 04             	add    $0x4,%esp
	popfl
  801ff2:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  801ff3:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  801ff4:	c3                   	ret    
  801ff5:	00 00                	add    %al,(%eax)
	...

00801ff8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	57                   	push   %edi
  801ffc:	56                   	push   %esi
  801ffd:	53                   	push   %ebx
  801ffe:	83 ec 1c             	sub    $0x1c,%esp
  802001:	8b 75 08             	mov    0x8(%ebp),%esi
  802004:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802007:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  80200a:	85 db                	test   %ebx,%ebx
  80200c:	75 05                	jne    802013 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  80200e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  802013:	89 1c 24             	mov    %ebx,(%esp)
  802016:	e8 9c ed ff ff       	call   800db7 <sys_ipc_recv>
  80201b:	85 c0                	test   %eax,%eax
  80201d:	79 16                	jns    802035 <ipc_recv+0x3d>
		*from_env_store = 0;
  80201f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  802025:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  80202b:	89 1c 24             	mov    %ebx,(%esp)
  80202e:	e8 84 ed ff ff       	call   800db7 <sys_ipc_recv>
  802033:	eb 24                	jmp    802059 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  802035:	85 f6                	test   %esi,%esi
  802037:	74 0a                	je     802043 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802039:	a1 04 40 80 00       	mov    0x804004,%eax
  80203e:	8b 40 74             	mov    0x74(%eax),%eax
  802041:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802043:	85 ff                	test   %edi,%edi
  802045:	74 0a                	je     802051 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802047:	a1 04 40 80 00       	mov    0x804004,%eax
  80204c:	8b 40 78             	mov    0x78(%eax),%eax
  80204f:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  802051:	a1 04 40 80 00       	mov    0x804004,%eax
  802056:	8b 40 70             	mov    0x70(%eax),%eax
}
  802059:	83 c4 1c             	add    $0x1c,%esp
  80205c:	5b                   	pop    %ebx
  80205d:	5e                   	pop    %esi
  80205e:	5f                   	pop    %edi
  80205f:	5d                   	pop    %ebp
  802060:	c3                   	ret    

00802061 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	57                   	push   %edi
  802065:	56                   	push   %esi
  802066:	53                   	push   %ebx
  802067:	83 ec 1c             	sub    $0x1c,%esp
  80206a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80206d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802070:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802073:	85 db                	test   %ebx,%ebx
  802075:	75 05                	jne    80207c <ipc_send+0x1b>
		pg = (void *)-1;
  802077:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80207c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802080:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802084:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802088:	8b 45 08             	mov    0x8(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 01 ed ff ff       	call   800d94 <sys_ipc_try_send>
		if (r == 0) {		
  802093:	85 c0                	test   %eax,%eax
  802095:	74 2c                	je     8020c3 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  802097:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80209a:	75 07                	jne    8020a3 <ipc_send+0x42>
			sys_yield();
  80209c:	e8 e1 ea ff ff       	call   800b82 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  8020a1:	eb d9                	jmp    80207c <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  8020a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020a7:	c7 44 24 08 48 29 80 	movl   $0x802948,0x8(%esp)
  8020ae:	00 
  8020af:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8020b6:	00 
  8020b7:	c7 04 24 56 29 80 00 	movl   $0x802956,(%esp)
  8020be:	e8 69 fe ff ff       	call   801f2c <_panic>
		}
	}
}
  8020c3:	83 c4 1c             	add    $0x1c,%esp
  8020c6:	5b                   	pop    %ebx
  8020c7:	5e                   	pop    %esi
  8020c8:	5f                   	pop    %edi
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	53                   	push   %ebx
  8020cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8020d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020d7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8020de:	89 c2                	mov    %eax,%edx
  8020e0:	c1 e2 07             	shl    $0x7,%edx
  8020e3:	29 ca                	sub    %ecx,%edx
  8020e5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020eb:	8b 52 50             	mov    0x50(%edx),%edx
  8020ee:	39 da                	cmp    %ebx,%edx
  8020f0:	75 0f                	jne    802101 <ipc_find_env+0x36>
			return envs[i].env_id;
  8020f2:	c1 e0 07             	shl    $0x7,%eax
  8020f5:	29 c8                	sub    %ecx,%eax
  8020f7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8020fc:	8b 40 40             	mov    0x40(%eax),%eax
  8020ff:	eb 0c                	jmp    80210d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802101:	40                   	inc    %eax
  802102:	3d 00 04 00 00       	cmp    $0x400,%eax
  802107:	75 ce                	jne    8020d7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802109:	66 b8 00 00          	mov    $0x0,%ax
}
  80210d:	5b                   	pop    %ebx
  80210e:	5d                   	pop    %ebp
  80210f:	c3                   	ret    

00802110 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802116:	89 c2                	mov    %eax,%edx
  802118:	c1 ea 16             	shr    $0x16,%edx
  80211b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802122:	f6 c2 01             	test   $0x1,%dl
  802125:	74 1e                	je     802145 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802127:	c1 e8 0c             	shr    $0xc,%eax
  80212a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802131:	a8 01                	test   $0x1,%al
  802133:	74 17                	je     80214c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802135:	c1 e8 0c             	shr    $0xc,%eax
  802138:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80213f:	ef 
  802140:	0f b7 c0             	movzwl %ax,%eax
  802143:	eb 0c                	jmp    802151 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802145:	b8 00 00 00 00       	mov    $0x0,%eax
  80214a:	eb 05                	jmp    802151 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80214c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    
	...

00802154 <__udivdi3>:
  802154:	55                   	push   %ebp
  802155:	57                   	push   %edi
  802156:	56                   	push   %esi
  802157:	83 ec 10             	sub    $0x10,%esp
  80215a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80215e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802162:	89 74 24 04          	mov    %esi,0x4(%esp)
  802166:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80216a:	89 cd                	mov    %ecx,%ebp
  80216c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802170:	85 c0                	test   %eax,%eax
  802172:	75 2c                	jne    8021a0 <__udivdi3+0x4c>
  802174:	39 f9                	cmp    %edi,%ecx
  802176:	77 68                	ja     8021e0 <__udivdi3+0x8c>
  802178:	85 c9                	test   %ecx,%ecx
  80217a:	75 0b                	jne    802187 <__udivdi3+0x33>
  80217c:	b8 01 00 00 00       	mov    $0x1,%eax
  802181:	31 d2                	xor    %edx,%edx
  802183:	f7 f1                	div    %ecx
  802185:	89 c1                	mov    %eax,%ecx
  802187:	31 d2                	xor    %edx,%edx
  802189:	89 f8                	mov    %edi,%eax
  80218b:	f7 f1                	div    %ecx
  80218d:	89 c7                	mov    %eax,%edi
  80218f:	89 f0                	mov    %esi,%eax
  802191:	f7 f1                	div    %ecx
  802193:	89 c6                	mov    %eax,%esi
  802195:	89 f0                	mov    %esi,%eax
  802197:	89 fa                	mov    %edi,%edx
  802199:	83 c4 10             	add    $0x10,%esp
  80219c:	5e                   	pop    %esi
  80219d:	5f                   	pop    %edi
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    
  8021a0:	39 f8                	cmp    %edi,%eax
  8021a2:	77 2c                	ja     8021d0 <__udivdi3+0x7c>
  8021a4:	0f bd f0             	bsr    %eax,%esi
  8021a7:	83 f6 1f             	xor    $0x1f,%esi
  8021aa:	75 4c                	jne    8021f8 <__udivdi3+0xa4>
  8021ac:	39 f8                	cmp    %edi,%eax
  8021ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8021b3:	72 0a                	jb     8021bf <__udivdi3+0x6b>
  8021b5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021b9:	0f 87 ad 00 00 00    	ja     80226c <__udivdi3+0x118>
  8021bf:	be 01 00 00 00       	mov    $0x1,%esi
  8021c4:	89 f0                	mov    %esi,%eax
  8021c6:	89 fa                	mov    %edi,%edx
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	5e                   	pop    %esi
  8021cc:	5f                   	pop    %edi
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    
  8021cf:	90                   	nop
  8021d0:	31 ff                	xor    %edi,%edi
  8021d2:	31 f6                	xor    %esi,%esi
  8021d4:	89 f0                	mov    %esi,%eax
  8021d6:	89 fa                	mov    %edi,%edx
  8021d8:	83 c4 10             	add    $0x10,%esp
  8021db:	5e                   	pop    %esi
  8021dc:	5f                   	pop    %edi
  8021dd:	5d                   	pop    %ebp
  8021de:	c3                   	ret    
  8021df:	90                   	nop
  8021e0:	89 fa                	mov    %edi,%edx
  8021e2:	89 f0                	mov    %esi,%eax
  8021e4:	f7 f1                	div    %ecx
  8021e6:	89 c6                	mov    %eax,%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	89 f0                	mov    %esi,%eax
  8021ec:	89 fa                	mov    %edi,%edx
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	89 f1                	mov    %esi,%ecx
  8021fa:	d3 e0                	shl    %cl,%eax
  8021fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802200:	b8 20 00 00 00       	mov    $0x20,%eax
  802205:	29 f0                	sub    %esi,%eax
  802207:	89 ea                	mov    %ebp,%edx
  802209:	88 c1                	mov    %al,%cl
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802211:	09 ca                	or     %ecx,%edx
  802213:	89 54 24 08          	mov    %edx,0x8(%esp)
  802217:	89 f1                	mov    %esi,%ecx
  802219:	d3 e5                	shl    %cl,%ebp
  80221b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80221f:	89 fd                	mov    %edi,%ebp
  802221:	88 c1                	mov    %al,%cl
  802223:	d3 ed                	shr    %cl,%ebp
  802225:	89 fa                	mov    %edi,%edx
  802227:	89 f1                	mov    %esi,%ecx
  802229:	d3 e2                	shl    %cl,%edx
  80222b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80222f:	88 c1                	mov    %al,%cl
  802231:	d3 ef                	shr    %cl,%edi
  802233:	09 d7                	or     %edx,%edi
  802235:	89 f8                	mov    %edi,%eax
  802237:	89 ea                	mov    %ebp,%edx
  802239:	f7 74 24 08          	divl   0x8(%esp)
  80223d:	89 d1                	mov    %edx,%ecx
  80223f:	89 c7                	mov    %eax,%edi
  802241:	f7 64 24 0c          	mull   0xc(%esp)
  802245:	39 d1                	cmp    %edx,%ecx
  802247:	72 17                	jb     802260 <__udivdi3+0x10c>
  802249:	74 09                	je     802254 <__udivdi3+0x100>
  80224b:	89 fe                	mov    %edi,%esi
  80224d:	31 ff                	xor    %edi,%edi
  80224f:	e9 41 ff ff ff       	jmp    802195 <__udivdi3+0x41>
  802254:	8b 54 24 04          	mov    0x4(%esp),%edx
  802258:	89 f1                	mov    %esi,%ecx
  80225a:	d3 e2                	shl    %cl,%edx
  80225c:	39 c2                	cmp    %eax,%edx
  80225e:	73 eb                	jae    80224b <__udivdi3+0xf7>
  802260:	8d 77 ff             	lea    -0x1(%edi),%esi
  802263:	31 ff                	xor    %edi,%edi
  802265:	e9 2b ff ff ff       	jmp    802195 <__udivdi3+0x41>
  80226a:	66 90                	xchg   %ax,%ax
  80226c:	31 f6                	xor    %esi,%esi
  80226e:	e9 22 ff ff ff       	jmp    802195 <__udivdi3+0x41>
	...

00802274 <__umoddi3>:
  802274:	55                   	push   %ebp
  802275:	57                   	push   %edi
  802276:	56                   	push   %esi
  802277:	83 ec 20             	sub    $0x20,%esp
  80227a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80227e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802282:	89 44 24 14          	mov    %eax,0x14(%esp)
  802286:	8b 74 24 34          	mov    0x34(%esp),%esi
  80228a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80228e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802292:	89 c7                	mov    %eax,%edi
  802294:	89 f2                	mov    %esi,%edx
  802296:	85 ed                	test   %ebp,%ebp
  802298:	75 16                	jne    8022b0 <__umoddi3+0x3c>
  80229a:	39 f1                	cmp    %esi,%ecx
  80229c:	0f 86 a6 00 00 00    	jbe    802348 <__umoddi3+0xd4>
  8022a2:	f7 f1                	div    %ecx
  8022a4:	89 d0                	mov    %edx,%eax
  8022a6:	31 d2                	xor    %edx,%edx
  8022a8:	83 c4 20             	add    $0x20,%esp
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    
  8022af:	90                   	nop
  8022b0:	39 f5                	cmp    %esi,%ebp
  8022b2:	0f 87 ac 00 00 00    	ja     802364 <__umoddi3+0xf0>
  8022b8:	0f bd c5             	bsr    %ebp,%eax
  8022bb:	83 f0 1f             	xor    $0x1f,%eax
  8022be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022c2:	0f 84 a8 00 00 00    	je     802370 <__umoddi3+0xfc>
  8022c8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8022cc:	d3 e5                	shl    %cl,%ebp
  8022ce:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8022d7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022db:	89 f9                	mov    %edi,%ecx
  8022dd:	d3 e8                	shr    %cl,%eax
  8022df:	09 e8                	or     %ebp,%eax
  8022e1:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022e5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022e9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8022ed:	d3 e0                	shl    %cl,%eax
  8022ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	d3 e2                	shl    %cl,%edx
  8022f7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022fb:	d3 e0                	shl    %cl,%eax
  8022fd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802301:	8b 44 24 14          	mov    0x14(%esp),%eax
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e8                	shr    %cl,%eax
  802309:	09 d0                	or     %edx,%eax
  80230b:	d3 ee                	shr    %cl,%esi
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	f7 74 24 18          	divl   0x18(%esp)
  802313:	89 d6                	mov    %edx,%esi
  802315:	f7 64 24 0c          	mull   0xc(%esp)
  802319:	89 c5                	mov    %eax,%ebp
  80231b:	89 d1                	mov    %edx,%ecx
  80231d:	39 d6                	cmp    %edx,%esi
  80231f:	72 67                	jb     802388 <__umoddi3+0x114>
  802321:	74 75                	je     802398 <__umoddi3+0x124>
  802323:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802327:	29 e8                	sub    %ebp,%eax
  802329:	19 ce                	sbb    %ecx,%esi
  80232b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80232f:	d3 e8                	shr    %cl,%eax
  802331:	89 f2                	mov    %esi,%edx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	d3 e2                	shl    %cl,%edx
  802337:	09 d0                	or     %edx,%eax
  802339:	89 f2                	mov    %esi,%edx
  80233b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80233f:	d3 ea                	shr    %cl,%edx
  802341:	83 c4 20             	add    $0x20,%esp
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	85 c9                	test   %ecx,%ecx
  80234a:	75 0b                	jne    802357 <__umoddi3+0xe3>
  80234c:	b8 01 00 00 00       	mov    $0x1,%eax
  802351:	31 d2                	xor    %edx,%edx
  802353:	f7 f1                	div    %ecx
  802355:	89 c1                	mov    %eax,%ecx
  802357:	89 f0                	mov    %esi,%eax
  802359:	31 d2                	xor    %edx,%edx
  80235b:	f7 f1                	div    %ecx
  80235d:	89 f8                	mov    %edi,%eax
  80235f:	e9 3e ff ff ff       	jmp    8022a2 <__umoddi3+0x2e>
  802364:	89 f2                	mov    %esi,%edx
  802366:	83 c4 20             	add    $0x20,%esp
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	39 f5                	cmp    %esi,%ebp
  802372:	72 04                	jb     802378 <__umoddi3+0x104>
  802374:	39 f9                	cmp    %edi,%ecx
  802376:	77 06                	ja     80237e <__umoddi3+0x10a>
  802378:	89 f2                	mov    %esi,%edx
  80237a:	29 cf                	sub    %ecx,%edi
  80237c:	19 ea                	sbb    %ebp,%edx
  80237e:	89 f8                	mov    %edi,%eax
  802380:	83 c4 20             	add    $0x20,%esp
  802383:	5e                   	pop    %esi
  802384:	5f                   	pop    %edi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    
  802387:	90                   	nop
  802388:	89 d1                	mov    %edx,%ecx
  80238a:	89 c5                	mov    %eax,%ebp
  80238c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802390:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802394:	eb 8d                	jmp    802323 <__umoddi3+0xaf>
  802396:	66 90                	xchg   %ax,%ax
  802398:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80239c:	72 ea                	jb     802388 <__umoddi3+0x114>
  80239e:	89 f1                	mov    %esi,%ecx
  8023a0:	eb 81                	jmp    802323 <__umoddi3+0xaf>
