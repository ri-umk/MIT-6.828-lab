
obj/user/pingpong.debug:     file format elf32-i386


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

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 f5 0e 00 00       	call   800f37 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 17 0b 00 00       	call   800b67 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 c0 23 80 00 	movl   $0x8023c0,(%esp)
  80005f:	e8 a4 01 00 00       	call   800208 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 9a 11 00 00       	call   801221 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 16 11 00 00       	call   8011b8 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 bb 0a 00 00       	call   800b67 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 d6 23 80 00 	movl   $0x8023d6,(%esp)
  8000bf:	e8 44 01 00 00       	call   800208 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 25                	je     8000ee <umain+0xba>
			return;
		i++;
  8000c9:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d1:	00 
  8000d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d9:	00 
  8000da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 38 11 00 00       	call   801221 <ipc_send>
		if (i == 10)
  8000e9:	83 fb 0a             	cmp    $0xa,%ebx
  8000ec:	75 9c                	jne    80008a <umain+0x56>
			return;
	}

}
  8000ee:	83 c4 2c             	add    $0x2c,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
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
  800106:	e8 5c 0a 00 00       	call   800b67 <sys_getenvid>
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
  800138:	e8 f7 fe ff ff       	call   800034 <umain>

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
  800152:	e8 60 13 00 00       	call   8014b7 <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 b2 09 00 00       	call   800b15 <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 14             	sub    $0x14,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	40                   	inc    %eax
  80017c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 19                	jne    80019e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800185:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018c:	00 
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 40 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019e:	ff 43 04             	incl   0x4(%ebx)
}
  8001a1:	83 c4 14             	add    $0x14,%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	c7 04 24 68 01 80 00 	movl   $0x800168,(%esp)
  8001e3:	e8 82 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 d8 08 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	89 44 24 04          	mov    %eax,0x4(%esp)
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	e8 87 ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800220:	c9                   	leave  
  800221:	c3                   	ret    
	...

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 3c             	sub    $0x3c,%esp
  80022d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800230:	89 d7                	mov    %edx,%edi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800241:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	85 c0                	test   %eax,%eax
  800246:	75 08                	jne    800250 <printnum+0x2c>
  800248:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024e:	77 57                	ja     8002a7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	89 74 24 10          	mov    %esi,0x10(%esp)
  800254:	4b                   	dec    %ebx
  800255:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800259:	8b 45 10             	mov    0x10(%ebp),%eax
  80025c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800260:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800264:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026f:	00 
  800270:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	e8 d6 1e 00 00       	call   802158 <__udivdi3>
  800282:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800286:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800291:	89 fa                	mov    %edi,%edx
  800293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800296:	e8 89 ff ff ff       	call   800224 <printnum>
  80029b:	eb 0f                	jmp    8002ac <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a1:	89 34 24             	mov    %esi,(%esp)
  8002a4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a7:	4b                   	dec    %ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f f1                	jg     80029d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c2:	00 
  8002c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	e8 a3 1f 00 00       	call   802278 <__umoddi3>
  8002d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d9:	0f be 80 f3 23 80 00 	movsbl 0x8023f3(%eax),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e6:	83 c4 3c             	add    $0x3c,%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5e                   	pop    %esi
  8002eb:	5f                   	pop    %edi
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f1:	83 fa 01             	cmp    $0x1,%edx
  8002f4:	7e 0e                	jle    800304 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	8b 52 04             	mov    0x4(%edx),%edx
  800302:	eb 22                	jmp    800326 <getuint+0x38>
	else if (lflag)
  800304:	85 d2                	test   %edx,%edx
  800306:	74 10                	je     800318 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 0e                	jmp    800326 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800331:	8b 10                	mov    (%eax),%edx
  800333:	3b 50 04             	cmp    0x4(%eax),%edx
  800336:	73 08                	jae    800340 <sprintputch+0x18>
		*b->buf++ = ch;
  800338:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033b:	88 0a                	mov    %cl,(%edx)
  80033d:	42                   	inc    %edx
  80033e:	89 10                	mov    %edx,(%eax)
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800348:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034f:	8b 45 10             	mov    0x10(%ebp),%eax
  800352:	89 44 24 08          	mov    %eax,0x8(%esp)
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	8b 45 08             	mov    0x8(%ebp),%eax
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	e8 02 00 00 00       	call   80036a <vprintfmt>
	va_end(ap);
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 4c             	sub    $0x4c,%esp
  800373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800376:	8b 75 10             	mov    0x10(%ebp),%esi
  800379:	eb 12                	jmp    80038d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037b:	85 c0                	test   %eax,%eax
  80037d:	0f 84 6b 03 00 00    	je     8006ee <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800383:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038d:	0f b6 06             	movzbl (%esi),%eax
  800390:	46                   	inc    %esi
  800391:	83 f8 25             	cmp    $0x25,%eax
  800394:	75 e5                	jne    80037b <vprintfmt+0x11>
  800396:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80039a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b2:	eb 26                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003bb:	eb 1d                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c4:	eb 14                	jmp    8003da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d0:	eb 08                	jmp    8003da <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	0f b6 06             	movzbl (%esi),%eax
  8003dd:	8d 56 01             	lea    0x1(%esi),%edx
  8003e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003e3:	8a 16                	mov    (%esi),%dl
  8003e5:	83 ea 23             	sub    $0x23,%edx
  8003e8:	80 fa 55             	cmp    $0x55,%dl
  8003eb:	0f 87 e1 02 00 00    	ja     8006d2 <vprintfmt+0x368>
  8003f1:	0f b6 d2             	movzbl %dl,%edx
  8003f4:	ff 24 95 40 25 80 00 	jmp    *0x802540(,%edx,4)
  8003fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003fe:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800403:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800406:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80040a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80040d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800410:	83 fa 09             	cmp    $0x9,%edx
  800413:	77 2a                	ja     80043f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800415:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800416:	eb eb                	jmp    800403 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800426:	eb 17                	jmp    80043f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800428:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042c:	78 98                	js     8003c6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800431:	eb a7                	jmp    8003da <vprintfmt+0x70>
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800436:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80043d:	eb 9b                	jmp    8003da <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80043f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800443:	79 95                	jns    8003da <vprintfmt+0x70>
  800445:	eb 8b                	jmp    8003d2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044b:	eb 8d                	jmp    8003da <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800465:	e9 23 ff ff ff       	jmp    80038d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	85 c0                	test   %eax,%eax
  800477:	79 02                	jns    80047b <vprintfmt+0x111>
  800479:	f7 d8                	neg    %eax
  80047b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047d:	83 f8 0f             	cmp    $0xf,%eax
  800480:	7f 0b                	jg     80048d <vprintfmt+0x123>
  800482:	8b 04 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%eax
  800489:	85 c0                	test   %eax,%eax
  80048b:	75 23                	jne    8004b0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80048d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800491:	c7 44 24 08 0b 24 80 	movl   $0x80240b,0x8(%esp)
  800498:	00 
  800499:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 9a fe ff ff       	call   800342 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ab:	e9 dd fe ff ff       	jmp    80038d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b4:	c7 44 24 08 22 29 80 	movl   $0x802922,0x8(%esp)
  8004bb:	00 
  8004bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c3:	89 14 24             	mov    %edx,(%esp)
  8004c6:	e8 77 fe ff ff       	call   800342 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ce:	e9 ba fe ff ff       	jmp    80038d <vprintfmt+0x23>
  8004d3:	89 f9                	mov    %edi,%ecx
  8004d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 30                	mov    (%eax),%esi
  8004e6:	85 f6                	test   %esi,%esi
  8004e8:	75 05                	jne    8004ef <vprintfmt+0x185>
				p = "(null)";
  8004ea:	be 04 24 80 00       	mov    $0x802404,%esi
			if (width > 0 && padc != '-')
  8004ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f3:	0f 8e 84 00 00 00    	jle    80057d <vprintfmt+0x213>
  8004f9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004fd:	74 7e                	je     80057d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800503:	89 34 24             	mov    %esi,(%esp)
  800506:	e8 8b 02 00 00       	call   800796 <strnlen>
  80050b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050e:	29 c2                	sub    %eax,%edx
  800510:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800513:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800517:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80051a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80051d:	89 de                	mov    %ebx,%esi
  80051f:	89 d3                	mov    %edx,%ebx
  800521:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	eb 0b                	jmp    800530 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800525:	89 74 24 04          	mov    %esi,0x4(%esp)
  800529:	89 3c 24             	mov    %edi,(%esp)
  80052c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <vprintfmt+0x1bb>
  800534:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800537:	89 f3                	mov    %esi,%ebx
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80053c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053f:	85 c0                	test   %eax,%eax
  800541:	79 05                	jns    800548 <vprintfmt+0x1de>
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054b:	29 c2                	sub    %eax,%edx
  80054d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800550:	eb 2b                	jmp    80057d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800556:	74 18                	je     800570 <vprintfmt+0x206>
  800558:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055b:	83 fa 5e             	cmp    $0x5e,%edx
  80055e:	76 10                	jbe    800570 <vprintfmt+0x206>
					putch('?', putdat);
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	eb 0a                	jmp    80057a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	ff 4d e4             	decl   -0x1c(%ebp)
  80057d:	0f be 06             	movsbl (%esi),%eax
  800580:	46                   	inc    %esi
  800581:	85 c0                	test   %eax,%eax
  800583:	74 21                	je     8005a6 <vprintfmt+0x23c>
  800585:	85 ff                	test   %edi,%edi
  800587:	78 c9                	js     800552 <vprintfmt+0x1e8>
  800589:	4f                   	dec    %edi
  80058a:	79 c6                	jns    800552 <vprintfmt+0x1e8>
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	89 de                	mov    %ebx,%esi
  800591:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800594:	eb 18                	jmp    8005ae <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800596:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a3:	4b                   	dec    %ebx
  8005a4:	eb 08                	jmp    8005ae <vprintfmt+0x244>
  8005a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a9:	89 de                	mov    %ebx,%esi
  8005ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7f e4                	jg     800596 <vprintfmt+0x22c>
  8005b2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ba:	e9 ce fd ff ff       	jmp    80038d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bf:	83 f9 01             	cmp    $0x1,%ecx
  8005c2:	7e 10                	jle    8005d4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 30                	mov    (%eax),%esi
  8005cf:	8b 78 04             	mov    0x4(%eax),%edi
  8005d2:	eb 26                	jmp    8005fa <vprintfmt+0x290>
	else if (lflag)
  8005d4:	85 c9                	test   %ecx,%ecx
  8005d6:	74 12                	je     8005ea <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 30                	mov    (%eax),%esi
  8005e3:	89 f7                	mov    %esi,%edi
  8005e5:	c1 ff 1f             	sar    $0x1f,%edi
  8005e8:	eb 10                	jmp    8005fa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 30                	mov    (%eax),%esi
  8005f5:	89 f7                	mov    %esi,%edi
  8005f7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	78 0a                	js     800608 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800603:	e9 8c 00 00 00       	jmp    800694 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800616:	f7 de                	neg    %esi
  800618:	83 d7 00             	adc    $0x0,%edi
  80061b:	f7 df                	neg    %edi
			}
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800622:	eb 70                	jmp    800694 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 c0 fc ff ff       	call   8002ee <getuint>
  80062e:	89 c6                	mov    %eax,%esi
  800630:	89 d7                	mov    %edx,%edi
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800637:	eb 5b                	jmp    800694 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 ab fc ff ff       	call   8002ee <getuint>
  800643:	89 c6                	mov    %eax,%esi
  800645:	89 d7                	mov    %edx,%edi
			base = 8;
  800647:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80064c:	eb 46                	jmp    800694 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80064e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800652:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800659:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800673:	8b 30                	mov    (%eax),%esi
  800675:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067f:	eb 13                	jmp    800694 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 63 fc ff ff       	call   8002ee <getuint>
  80068b:	89 c6                	mov    %eax,%esi
  80068d:	89 d7                	mov    %edx,%edi
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800694:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800698:	89 54 24 10          	mov    %edx,0x10(%esp)
  80069c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80069f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a7:	89 34 24             	mov    %esi,(%esp)
  8006aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ae:	89 da                	mov    %ebx,%edx
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	e8 6c fb ff ff       	call   800224 <printnum>
			break;
  8006b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006bb:	e9 cd fc ff ff       	jmp    80038d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cd:	e9 bb fc ff ff       	jmp    80038d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e0:	eb 01                	jmp    8006e3 <vprintfmt+0x379>
  8006e2:	4e                   	dec    %esi
  8006e3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e7:	75 f9                	jne    8006e2 <vprintfmt+0x378>
  8006e9:	e9 9f fc ff ff       	jmp    80038d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	83 c4 4c             	add    $0x4c,%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 28             	sub    $0x28,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 30                	je     800747 <vsnprintf+0x51>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 33                	jle    80074e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800722:	8b 45 10             	mov    0x10(%ebp),%eax
  800725:	89 44 24 08          	mov    %eax,0x8(%esp)
  800729:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800730:	c7 04 24 28 03 80 00 	movl   $0x800328,(%esp)
  800737:	e8 2e fc ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800745:	eb 0c                	jmp    800753 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800747:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074c:	eb 05                	jmp    800753 <vsnprintf+0x5d>
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 7b ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
  80077d:	00 00                	add    %al,(%eax)
	...

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 01                	jmp    80078e <strlen+0xe>
		n++;
  80078d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f9                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 01                	jmp    8007a7 <strnlen+0x11>
		n++;
  8007a6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 d0                	cmp    %edx,%eax
  8007a9:	74 06                	je     8007b1 <strnlen+0x1b>
  8007ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007af:	75 f5                	jne    8007a6 <strnlen+0x10>
		n++;
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c8:	42                   	inc    %edx
  8007c9:	84 c9                	test   %cl,%cl
  8007cb:	75 f5                	jne    8007c2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007da:	89 1c 24             	mov    %ebx,(%esp)
  8007dd:	e8 9e ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	89 04 24             	mov    %eax,(%esp)
  8007ee:	e8 c0 ff ff ff       	call   8007b3 <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080e:	eb 0c                	jmp    80081c <strncpy+0x21>
		*dst++ = *src;
  800810:	8a 1a                	mov    (%edx),%bl
  800812:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 3a 01             	cmpb   $0x1,(%edx)
  800818:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	41                   	inc    %ecx
  80081c:	39 f1                	cmp    %esi,%ecx
  80081e:	75 f0                	jne    800810 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800832:	85 d2                	test   %edx,%edx
  800834:	75 0a                	jne    800840 <strlcpy+0x1c>
  800836:	89 f0                	mov    %esi,%eax
  800838:	eb 1a                	jmp    800854 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083a:	88 18                	mov    %bl,(%eax)
  80083c:	40                   	inc    %eax
  80083d:	41                   	inc    %ecx
  80083e:	eb 02                	jmp    800842 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800840:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800842:	4a                   	dec    %edx
  800843:	74 0a                	je     80084f <strlcpy+0x2b>
  800845:	8a 19                	mov    (%ecx),%bl
  800847:	84 db                	test   %bl,%bl
  800849:	75 ef                	jne    80083a <strlcpy+0x16>
  80084b:	89 c2                	mov    %eax,%edx
  80084d:	eb 02                	jmp    800851 <strlcpy+0x2d>
  80084f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800851:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800854:	29 f0                	sub    %esi,%eax
}
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800863:	eb 02                	jmp    800867 <strcmp+0xd>
		p++, q++;
  800865:	41                   	inc    %ecx
  800866:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800867:	8a 01                	mov    (%ecx),%al
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x17>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 f4                	je     800865 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800885:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800888:	eb 03                	jmp    80088d <strncmp+0x12>
		n--, p++, q++;
  80088a:	4a                   	dec    %edx
  80088b:	40                   	inc    %eax
  80088c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088d:	85 d2                	test   %edx,%edx
  80088f:	74 14                	je     8008a5 <strncmp+0x2a>
  800891:	8a 18                	mov    (%eax),%bl
  800893:	84 db                	test   %bl,%bl
  800895:	74 04                	je     80089b <strncmp+0x20>
  800897:	3a 19                	cmp    (%ecx),%bl
  800899:	74 ef                	je     80088a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089b:	0f b6 00             	movzbl (%eax),%eax
  80089e:	0f b6 11             	movzbl (%ecx),%edx
  8008a1:	29 d0                	sub    %edx,%eax
  8008a3:	eb 05                	jmp    8008aa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b6:	eb 05                	jmp    8008bd <strchr+0x10>
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 0c                	je     8008c8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bc:	40                   	inc    %eax
  8008bd:	8a 10                	mov    (%eax),%dl
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f5                	jne    8008b8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d3:	eb 05                	jmp    8008da <strfind+0x10>
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 07                	je     8008e0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d9:	40                   	inc    %eax
  8008da:	8a 10                	mov    (%eax),%dl
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f5                	jne    8008d5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	57                   	push   %edi
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f1:	85 c9                	test   %ecx,%ecx
  8008f3:	74 30                	je     800925 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fb:	75 25                	jne    800922 <memset+0x40>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 20                	jne    800922 <memset+0x40>
		c &= 0xFF;
  800902:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800905:	89 d3                	mov    %edx,%ebx
  800907:	c1 e3 08             	shl    $0x8,%ebx
  80090a:	89 d6                	mov    %edx,%esi
  80090c:	c1 e6 18             	shl    $0x18,%esi
  80090f:	89 d0                	mov    %edx,%eax
  800911:	c1 e0 10             	shl    $0x10,%eax
  800914:	09 f0                	or     %esi,%eax
  800916:	09 d0                	or     %edx,%eax
  800918:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091d:	fc                   	cld    
  80091e:	f3 ab                	rep stos %eax,%es:(%edi)
  800920:	eb 03                	jmp    800925 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093a:	39 c6                	cmp    %eax,%esi
  80093c:	73 34                	jae    800972 <memmove+0x46>
  80093e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800941:	39 d0                	cmp    %edx,%eax
  800943:	73 2d                	jae    800972 <memmove+0x46>
		s += n;
		d += n;
  800945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	f6 c2 03             	test   $0x3,%dl
  80094b:	75 1b                	jne    800968 <memmove+0x3c>
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 13                	jne    800968 <memmove+0x3c>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0e                	jne    800968 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095a:	83 ef 04             	sub    $0x4,%edi
  80095d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800960:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800963:	fd                   	std    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 07                	jmp    80096f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800968:	4f                   	dec    %edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 20                	jmp    800992 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800978:	75 13                	jne    80098d <memmove+0x61>
  80097a:	a8 03                	test   $0x3,%al
  80097c:	75 0f                	jne    80098d <memmove+0x61>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	75 0a                	jne    80098d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800983:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 05                	jmp    800992 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80099c:	8b 45 10             	mov    0x10(%ebp),%eax
  80099f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	89 04 24             	mov    %eax,(%esp)
  8009b0:	e8 77 ff ff ff       	call   80092c <memmove>
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	eb 16                	jmp    8009e3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cd:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009d0:	42                   	inc    %edx
  8009d1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009d5:	38 c8                	cmp    %cl,%al
  8009d7:	74 0a                	je     8009e3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 c9             	movzbl %cl,%ecx
  8009df:	29 c8                	sub    %ecx,%eax
  8009e1:	eb 09                	jmp    8009ec <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e3:	39 da                	cmp    %ebx,%edx
  8009e5:	75 e6                	jne    8009cd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ff:	eb 05                	jmp    800a06 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a01:	38 08                	cmp    %cl,(%eax)
  800a03:	74 05                	je     800a0a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a05:	40                   	inc    %eax
  800a06:	39 d0                	cmp    %edx,%eax
  800a08:	72 f7                	jb     800a01 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	eb 01                	jmp    800a1b <strtol+0xf>
		s++;
  800a1a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1b:	8a 02                	mov    (%edx),%al
  800a1d:	3c 20                	cmp    $0x20,%al
  800a1f:	74 f9                	je     800a1a <strtol+0xe>
  800a21:	3c 09                	cmp    $0x9,%al
  800a23:	74 f5                	je     800a1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a25:	3c 2b                	cmp    $0x2b,%al
  800a27:	75 08                	jne    800a31 <strtol+0x25>
		s++;
  800a29:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2f:	eb 13                	jmp    800a44 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	75 0a                	jne    800a3f <strtol+0x33>
		s++, neg = 1;
  800a35:	8d 52 01             	lea    0x1(%edx),%edx
  800a38:	bf 01 00 00 00       	mov    $0x1,%edi
  800a3d:	eb 05                	jmp    800a44 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	74 05                	je     800a4d <strtol+0x41>
  800a48:	83 fb 10             	cmp    $0x10,%ebx
  800a4b:	75 28                	jne    800a75 <strtol+0x69>
  800a4d:	8a 02                	mov    (%edx),%al
  800a4f:	3c 30                	cmp    $0x30,%al
  800a51:	75 10                	jne    800a63 <strtol+0x57>
  800a53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a57:	75 0a                	jne    800a63 <strtol+0x57>
		s += 2, base = 16;
  800a59:	83 c2 02             	add    $0x2,%edx
  800a5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a61:	eb 12                	jmp    800a75 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a63:	85 db                	test   %ebx,%ebx
  800a65:	75 0e                	jne    800a75 <strtol+0x69>
  800a67:	3c 30                	cmp    $0x30,%al
  800a69:	75 05                	jne    800a70 <strtol+0x64>
		s++, base = 8;
  800a6b:	42                   	inc    %edx
  800a6c:	b3 08                	mov    $0x8,%bl
  800a6e:	eb 05                	jmp    800a75 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7c:	8a 0a                	mov    (%edx),%cl
  800a7e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a81:	80 fb 09             	cmp    $0x9,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x82>
			dig = *s - '0';
  800a86:	0f be c9             	movsbl %cl,%ecx
  800a89:	83 e9 30             	sub    $0x30,%ecx
  800a8c:	eb 1e                	jmp    800aac <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a8e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a96:	0f be c9             	movsbl %cl,%ecx
  800a99:	83 e9 57             	sub    $0x57,%ecx
  800a9c:	eb 0e                	jmp    800aac <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 12                	ja     800ab8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aa6:	0f be c9             	movsbl %cl,%ecx
  800aa9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aac:	39 f1                	cmp    %esi,%ecx
  800aae:	7d 0c                	jge    800abc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ab0:	42                   	inc    %edx
  800ab1:	0f af c6             	imul   %esi,%eax
  800ab4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab6:	eb c4                	jmp    800a7c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab8:	89 c1                	mov    %eax,%ecx
  800aba:	eb 02                	jmp    800abe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800abe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac2:	74 05                	je     800ac9 <strtol+0xbd>
		*endptr = (char *) s;
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac9:	85 ff                	test   %edi,%edi
  800acb:	74 04                	je     800ad1 <strtol+0xc5>
  800acd:	89 c8                	mov    %ecx,%eax
  800acf:	f7 d8                	neg    %eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
	...

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	89 c6                	mov    %eax,%esi
  800aef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 cb                	mov    %ecx,%ebx
  800b2d:	89 cf                	mov    %ecx,%edi
  800b2f:	89 ce                	mov    %ecx,%esi
  800b31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 28                	jle    800b5f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b42:	00 
  800b43:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800b4a:	00 
  800b4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b52:	00 
  800b53:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800b5a:	e8 e9 14 00 00       	call   802048 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5f:	83 c4 2c             	add    $0x2c,%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 02 00 00 00       	mov    $0x2,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_yield>:

void
sys_yield(void)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b96:	89 d1                	mov    %edx,%ecx
  800b98:	89 d3                	mov    %edx,%ebx
  800b9a:	89 d7                	mov    %edx,%edi
  800b9c:	89 d6                	mov    %edx,%esi
  800b9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	be 00 00 00 00       	mov    $0x0,%esi
  800bb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	89 f7                	mov    %esi,%edi
  800bc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7e 28                	jle    800bf1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd4:	00 
  800bd5:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800bdc:	00 
  800bdd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be4:	00 
  800be5:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800bec:	e8 57 14 00 00       	call   802048 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf1:	83 c4 2c             	add    $0x2c,%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 05 00 00 00       	mov    $0x5,%eax
  800c07:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 28                	jle    800c44 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c20:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c27:	00 
  800c28:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800c2f:	00 
  800c30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c37:	00 
  800c38:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800c3f:	e8 04 14 00 00       	call   802048 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c44:	83 c4 2c             	add    $0x2c,%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7e 28                	jle    800c97 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c73:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800c82:	00 
  800c83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8a:	00 
  800c8b:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800c92:	e8 b1 13 00 00       	call   802048 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c97:	83 c4 2c             	add    $0x2c,%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cad:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	89 df                	mov    %ebx,%edi
  800cba:	89 de                	mov    %ebx,%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 28                	jle    800cea <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ccd:	00 
  800cce:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800cd5:	00 
  800cd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdd:	00 
  800cde:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800ce5:	e8 5e 13 00 00       	call   802048 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cea:	83 c4 2c             	add    $0x2c,%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	b8 09 00 00 00       	mov    $0x9,%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	89 df                	mov    %ebx,%edi
  800d0d:	89 de                	mov    %ebx,%esi
  800d0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 28                	jle    800d3d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d19:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d20:	00 
  800d21:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800d28:	00 
  800d29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d30:	00 
  800d31:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800d38:	e8 0b 13 00 00       	call   802048 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3d:	83 c4 2c             	add    $0x2c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7e 28                	jle    800d90 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d73:	00 
  800d74:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d83:	00 
  800d84:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800d8b:	e8 b8 12 00 00       	call   802048 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d90:	83 c4 2c             	add    $0x2c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	be 00 00 00 00       	mov    $0x0,%esi
  800da3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 cb                	mov    %ecx,%ebx
  800dd3:	89 cf                	mov    %ecx,%edi
  800dd5:	89 ce                	mov    %ecx,%esi
  800dd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 ff 26 80 	movl   $0x8026ff,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  800e00:	e8 43 12 00 00       	call   802048 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    
  800e0d:	00 00                	add    %al,(%eax)
	...

00800e10 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	53                   	push   %ebx
  800e14:	83 ec 24             	sub    $0x24,%esp
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e1a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800e1c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e20:	75 2d                	jne    800e4f <pgfault+0x3f>
  800e22:	89 d8                	mov    %ebx,%eax
  800e24:	c1 e8 0c             	shr    $0xc,%eax
  800e27:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2e:	f6 c4 08             	test   $0x8,%ah
  800e31:	75 1c                	jne    800e4f <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800e33:	c7 44 24 08 2c 27 80 	movl   $0x80272c,0x8(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800e42:	00 
  800e43:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800e4a:	e8 f9 11 00 00       	call   802048 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800e4f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e56:	00 
  800e57:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e5e:	00 
  800e5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e66:	e8 3a fd ff ff       	call   800ba5 <sys_page_alloc>
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	79 20                	jns    800e8f <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800e6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e73:	c7 44 24 08 9b 27 80 	movl   $0x80279b,0x8(%esp)
  800e7a:	00 
  800e7b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800e82:	00 
  800e83:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800e8a:	e8 b9 11 00 00       	call   802048 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e8f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e95:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e9c:	00 
  800e9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ea1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ea8:	e8 e9 fa ff ff       	call   800996 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800ead:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800eb4:	00 
  800eb5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eb9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ec8:	00 
  800ec9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed0:	e8 24 fd ff ff       	call   800bf9 <sys_page_map>
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	79 20                	jns    800ef9 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  800ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edd:	c7 44 24 08 ae 27 80 	movl   $0x8027ae,0x8(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800ef4:	e8 4f 11 00 00       	call   802048 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ef9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f00:	00 
  800f01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f08:	e8 3f fd ff ff       	call   800c4c <sys_page_unmap>
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	79 20                	jns    800f31 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  800f11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f15:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f24:	00 
  800f25:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800f2c:	e8 17 11 00 00       	call   802048 <_panic>
}
  800f31:	83 c4 24             	add    $0x24,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  800f40:	c7 04 24 10 0e 80 00 	movl   $0x800e10,(%esp)
  800f47:	e8 54 11 00 00       	call   8020a0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f4c:	ba 07 00 00 00       	mov    $0x7,%edx
  800f51:	89 d0                	mov    %edx,%eax
  800f53:	cd 30                	int    $0x30
  800f55:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f58:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	79 1c                	jns    800f7b <fork+0x44>
		panic("sys_exofork failed\n");
  800f5f:	c7 44 24 08 d2 27 80 	movl   $0x8027d2,0x8(%esp)
  800f66:	00 
  800f67:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  800f6e:	00 
  800f6f:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  800f76:	e8 cd 10 00 00       	call   802048 <_panic>
	if(c_envid == 0){
  800f7b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f7f:	75 25                	jne    800fa6 <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f81:	e8 e1 fb ff ff       	call   800b67 <sys_getenvid>
  800f86:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f92:	c1 e0 07             	shl    $0x7,%eax
  800f95:	29 d0                	sub    %edx,%eax
  800f97:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fa1:	e9 e3 01 00 00       	jmp    801189 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  800fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	c1 e8 16             	shr    $0x16,%eax
  800fb0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb7:	a8 01                	test   $0x1,%al
  800fb9:	0f 84 0b 01 00 00    	je     8010ca <fork+0x193>
  800fbf:	89 de                	mov    %ebx,%esi
  800fc1:	c1 ee 0c             	shr    $0xc,%esi
  800fc4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fcb:	a8 05                	test   $0x5,%al
  800fcd:	0f 84 f7 00 00 00    	je     8010ca <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  800fd3:	89 f7                	mov    %esi,%edi
  800fd5:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  800fd8:	e8 8a fb ff ff       	call   800b67 <sys_getenvid>
  800fdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800fe0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe7:	a8 02                	test   $0x2,%al
  800fe9:	75 10                	jne    800ffb <fork+0xc4>
  800feb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff2:	f6 c4 08             	test   $0x8,%ah
  800ff5:	0f 84 89 00 00 00    	je     801084 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  800ffb:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801002:	00 
  801003:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801007:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80100a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801012:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801015:	89 04 24             	mov    %eax,(%esp)
  801018:	e8 dc fb ff ff       	call   800bf9 <sys_page_map>
  80101d:	85 c0                	test   %eax,%eax
  80101f:	79 20                	jns    801041 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801021:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801025:	c7 44 24 08 e6 27 80 	movl   $0x8027e6,0x8(%esp)
  80102c:	00 
  80102d:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  801034:	00 
  801035:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  80103c:	e8 07 10 00 00       	call   802048 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  801041:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801048:	00 
  801049:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80104d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801050:	89 44 24 08          	mov    %eax,0x8(%esp)
  801054:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801058:	89 04 24             	mov    %eax,(%esp)
  80105b:	e8 99 fb ff ff       	call   800bf9 <sys_page_map>
  801060:	85 c0                	test   %eax,%eax
  801062:	79 66                	jns    8010ca <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801064:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801068:	c7 44 24 08 e6 27 80 	movl   $0x8027e6,0x8(%esp)
  80106f:	00 
  801070:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  80107f:	e8 c4 0f 00 00       	call   802048 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  801084:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80108b:	00 
  80108c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801090:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801093:	89 44 24 08          	mov    %eax,0x8(%esp)
  801097:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80109b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80109e:	89 04 24             	mov    %eax,(%esp)
  8010a1:	e8 53 fb ff ff       	call   800bf9 <sys_page_map>
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 20                	jns    8010ca <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  8010aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ae:	c7 44 24 08 e6 27 80 	movl   $0x8027e6,0x8(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8010bd:	00 
  8010be:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  8010c5:	e8 7e 0f 00 00       	call   802048 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  8010ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d6:	0f 85 cf fe ff ff    	jne    800fab <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  8010dc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010e3:	00 
  8010e4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010eb:	ee 
  8010ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010ef:	89 04 24             	mov    %eax,(%esp)
  8010f2:	e8 ae fa ff ff       	call   800ba5 <sys_page_alloc>
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	79 20                	jns    80111b <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  8010fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ff:	c7 44 24 08 f8 27 80 	movl   $0x8027f8,0x8(%esp)
  801106:	00 
  801107:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80110e:	00 
  80110f:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  801116:	e8 2d 0f 00 00       	call   802048 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  80111b:	c7 44 24 04 ec 20 80 	movl   $0x8020ec,0x4(%esp)
  801122:	00 
  801123:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801126:	89 04 24             	mov    %eax,(%esp)
  801129:	e8 17 fc ff ff       	call   800d45 <sys_env_set_pgfault_upcall>
  80112e:	85 c0                	test   %eax,%eax
  801130:	79 20                	jns    801152 <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801136:	c7 44 24 08 70 27 80 	movl   $0x802770,0x8(%esp)
  80113d:	00 
  80113e:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801145:	00 
  801146:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  80114d:	e8 f6 0e 00 00       	call   802048 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  801152:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801159:	00 
  80115a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80115d:	89 04 24             	mov    %eax,(%esp)
  801160:	e8 3a fb ff ff       	call   800c9f <sys_env_set_status>
  801165:	85 c0                	test   %eax,%eax
  801167:	79 20                	jns    801189 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  801169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116d:	c7 44 24 08 0c 28 80 	movl   $0x80280c,0x8(%esp)
  801174:	00 
  801175:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  80117c:	00 
  80117d:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  801184:	e8 bf 0e 00 00       	call   802048 <_panic>
 
	return c_envid;	
}
  801189:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80118c:	83 c4 3c             	add    $0x3c,%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <sfork>:

// Challenge!
int
sfork(void)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80119a:	c7 44 24 08 24 28 80 	movl   $0x802824,0x8(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8011a9:	00 
  8011aa:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  8011b1:	e8 92 0e 00 00       	call   802048 <_panic>
	...

008011b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	57                   	push   %edi
  8011bc:	56                   	push   %esi
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 1c             	sub    $0x1c,%esp
  8011c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011c7:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8011ca:	85 db                	test   %ebx,%ebx
  8011cc:	75 05                	jne    8011d3 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8011ce:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8011d3:	89 1c 24             	mov    %ebx,(%esp)
  8011d6:	e8 e0 fb ff ff       	call   800dbb <sys_ipc_recv>
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	79 16                	jns    8011f5 <ipc_recv+0x3d>
		*from_env_store = 0;
  8011df:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8011e5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  8011eb:	89 1c 24             	mov    %ebx,(%esp)
  8011ee:	e8 c8 fb ff ff       	call   800dbb <sys_ipc_recv>
  8011f3:	eb 24                	jmp    801219 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  8011f5:	85 f6                	test   %esi,%esi
  8011f7:	74 0a                	je     801203 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8011f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fe:	8b 40 74             	mov    0x74(%eax),%eax
  801201:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801203:	85 ff                	test   %edi,%edi
  801205:	74 0a                	je     801211 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801207:	a1 04 40 80 00       	mov    0x804004,%eax
  80120c:	8b 40 78             	mov    0x78(%eax),%eax
  80120f:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801211:	a1 04 40 80 00       	mov    0x804004,%eax
  801216:	8b 40 70             	mov    0x70(%eax),%eax
}
  801219:	83 c4 1c             	add    $0x1c,%esp
  80121c:	5b                   	pop    %ebx
  80121d:	5e                   	pop    %esi
  80121e:	5f                   	pop    %edi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	57                   	push   %edi
  801225:	56                   	push   %esi
  801226:	53                   	push   %ebx
  801227:	83 ec 1c             	sub    $0x1c,%esp
  80122a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80122d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801230:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801233:	85 db                	test   %ebx,%ebx
  801235:	75 05                	jne    80123c <ipc_send+0x1b>
		pg = (void *)-1;
  801237:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80123c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801240:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801244:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801248:	8b 45 08             	mov    0x8(%ebp),%eax
  80124b:	89 04 24             	mov    %eax,(%esp)
  80124e:	e8 45 fb ff ff       	call   800d98 <sys_ipc_try_send>
		if (r == 0) {		
  801253:	85 c0                	test   %eax,%eax
  801255:	74 2c                	je     801283 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801257:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80125a:	75 07                	jne    801263 <ipc_send+0x42>
			sys_yield();
  80125c:	e8 25 f9 ff ff       	call   800b86 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801261:	eb d9                	jmp    80123c <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801267:	c7 44 24 08 3a 28 80 	movl   $0x80283a,0x8(%esp)
  80126e:	00 
  80126f:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801276:	00 
  801277:	c7 04 24 48 28 80 00 	movl   $0x802848,(%esp)
  80127e:	e8 c5 0d 00 00       	call   802048 <_panic>
		}
	}
}
  801283:	83 c4 1c             	add    $0x1c,%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801297:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80129e:	89 c2                	mov    %eax,%edx
  8012a0:	c1 e2 07             	shl    $0x7,%edx
  8012a3:	29 ca                	sub    %ecx,%edx
  8012a5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012ab:	8b 52 50             	mov    0x50(%edx),%edx
  8012ae:	39 da                	cmp    %ebx,%edx
  8012b0:	75 0f                	jne    8012c1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8012b2:	c1 e0 07             	shl    $0x7,%eax
  8012b5:	29 c8                	sub    %ecx,%eax
  8012b7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8012bc:	8b 40 40             	mov    0x40(%eax),%eax
  8012bf:	eb 0c                	jmp    8012cd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012c1:	40                   	inc    %eax
  8012c2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012c7:	75 ce                	jne    801297 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012c9:	66 b8 00 00          	mov    $0x0,%ax
}
  8012cd:	5b                   	pop    %ebx
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012db:	c1 e8 0c             	shr    $0xc,%eax
}
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e9:	89 04 24             	mov    %eax,(%esp)
  8012ec:	e8 df ff ff ff       	call   8012d0 <fd2num>
  8012f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	53                   	push   %ebx
  8012ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801302:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801307:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801309:	89 c2                	mov    %eax,%edx
  80130b:	c1 ea 16             	shr    $0x16,%edx
  80130e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801315:	f6 c2 01             	test   $0x1,%dl
  801318:	74 11                	je     80132b <fd_alloc+0x30>
  80131a:	89 c2                	mov    %eax,%edx
  80131c:	c1 ea 0c             	shr    $0xc,%edx
  80131f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801326:	f6 c2 01             	test   $0x1,%dl
  801329:	75 09                	jne    801334 <fd_alloc+0x39>
			*fd_store = fd;
  80132b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80132d:	b8 00 00 00 00       	mov    $0x0,%eax
  801332:	eb 17                	jmp    80134b <fd_alloc+0x50>
  801334:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801339:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80133e:	75 c7                	jne    801307 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801340:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801346:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80134b:	5b                   	pop    %ebx
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801354:	83 f8 1f             	cmp    $0x1f,%eax
  801357:	77 36                	ja     80138f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801359:	05 00 00 0d 00       	add    $0xd0000,%eax
  80135e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801361:	89 c2                	mov    %eax,%edx
  801363:	c1 ea 16             	shr    $0x16,%edx
  801366:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80136d:	f6 c2 01             	test   $0x1,%dl
  801370:	74 24                	je     801396 <fd_lookup+0x48>
  801372:	89 c2                	mov    %eax,%edx
  801374:	c1 ea 0c             	shr    $0xc,%edx
  801377:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137e:	f6 c2 01             	test   $0x1,%dl
  801381:	74 1a                	je     80139d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801383:	8b 55 0c             	mov    0xc(%ebp),%edx
  801386:	89 02                	mov    %eax,(%edx)
	return 0;
  801388:	b8 00 00 00 00       	mov    $0x0,%eax
  80138d:	eb 13                	jmp    8013a2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801394:	eb 0c                	jmp    8013a2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801396:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139b:	eb 05                	jmp    8013a2 <fd_lookup+0x54>
  80139d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 14             	sub    $0x14,%esp
  8013ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8013b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b6:	eb 0e                	jmp    8013c6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8013b8:	39 08                	cmp    %ecx,(%eax)
  8013ba:	75 09                	jne    8013c5 <dev_lookup+0x21>
			*dev = devtab[i];
  8013bc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c3:	eb 33                	jmp    8013f8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013c5:	42                   	inc    %edx
  8013c6:	8b 04 95 d0 28 80 00 	mov    0x8028d0(,%edx,4),%eax
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	75 e7                	jne    8013b8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d6:	8b 40 48             	mov    0x48(%eax),%eax
  8013d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e1:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  8013e8:	e8 1b ee ff ff       	call   800208 <cprintf>
	*dev = 0;
  8013ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f8:	83 c4 14             	add    $0x14,%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 30             	sub    $0x30,%esp
  801406:	8b 75 08             	mov    0x8(%ebp),%esi
  801409:	8a 45 0c             	mov    0xc(%ebp),%al
  80140c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80140f:	89 34 24             	mov    %esi,(%esp)
  801412:	e8 b9 fe ff ff       	call   8012d0 <fd2num>
  801417:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80141a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80141e:	89 04 24             	mov    %eax,(%esp)
  801421:	e8 28 ff ff ff       	call   80134e <fd_lookup>
  801426:	89 c3                	mov    %eax,%ebx
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 05                	js     801431 <fd_close+0x33>
	    || fd != fd2)
  80142c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80142f:	74 0d                	je     80143e <fd_close+0x40>
		return (must_exist ? r : 0);
  801431:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801435:	75 46                	jne    80147d <fd_close+0x7f>
  801437:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143c:	eb 3f                	jmp    80147d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80143e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801441:	89 44 24 04          	mov    %eax,0x4(%esp)
  801445:	8b 06                	mov    (%esi),%eax
  801447:	89 04 24             	mov    %eax,(%esp)
  80144a:	e8 55 ff ff ff       	call   8013a4 <dev_lookup>
  80144f:	89 c3                	mov    %eax,%ebx
  801451:	85 c0                	test   %eax,%eax
  801453:	78 18                	js     80146d <fd_close+0x6f>
		if (dev->dev_close)
  801455:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801458:	8b 40 10             	mov    0x10(%eax),%eax
  80145b:	85 c0                	test   %eax,%eax
  80145d:	74 09                	je     801468 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80145f:	89 34 24             	mov    %esi,(%esp)
  801462:	ff d0                	call   *%eax
  801464:	89 c3                	mov    %eax,%ebx
  801466:	eb 05                	jmp    80146d <fd_close+0x6f>
		else
			r = 0;
  801468:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80146d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801471:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801478:	e8 cf f7 ff ff       	call   800c4c <sys_page_unmap>
	return r;
}
  80147d:	89 d8                	mov    %ebx,%eax
  80147f:	83 c4 30             	add    $0x30,%esp
  801482:	5b                   	pop    %ebx
  801483:	5e                   	pop    %esi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80148c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	e8 b0 fe ff ff       	call   80134e <fd_lookup>
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 13                	js     8014b5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014a9:	00 
  8014aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	e8 49 ff ff ff       	call   8013fe <fd_close>
}
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <close_all>:

void
close_all(void)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014be:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014c3:	89 1c 24             	mov    %ebx,(%esp)
  8014c6:	e8 bb ff ff ff       	call   801486 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014cb:	43                   	inc    %ebx
  8014cc:	83 fb 20             	cmp    $0x20,%ebx
  8014cf:	75 f2                	jne    8014c3 <close_all+0xc>
		close(i);
}
  8014d1:	83 c4 14             	add    $0x14,%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	57                   	push   %edi
  8014db:	56                   	push   %esi
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 4c             	sub    $0x4c,%esp
  8014e0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	89 04 24             	mov    %eax,(%esp)
  8014f0:	e8 59 fe ff ff       	call   80134e <fd_lookup>
  8014f5:	89 c3                	mov    %eax,%ebx
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	0f 88 e1 00 00 00    	js     8015e0 <dup+0x109>
		return r;
	close(newfdnum);
  8014ff:	89 3c 24             	mov    %edi,(%esp)
  801502:	e8 7f ff ff ff       	call   801486 <close>

	newfd = INDEX2FD(newfdnum);
  801507:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80150d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801510:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801513:	89 04 24             	mov    %eax,(%esp)
  801516:	e8 c5 fd ff ff       	call   8012e0 <fd2data>
  80151b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80151d:	89 34 24             	mov    %esi,(%esp)
  801520:	e8 bb fd ff ff       	call   8012e0 <fd2data>
  801525:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801528:	89 d8                	mov    %ebx,%eax
  80152a:	c1 e8 16             	shr    $0x16,%eax
  80152d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801534:	a8 01                	test   $0x1,%al
  801536:	74 46                	je     80157e <dup+0xa7>
  801538:	89 d8                	mov    %ebx,%eax
  80153a:	c1 e8 0c             	shr    $0xc,%eax
  80153d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801544:	f6 c2 01             	test   $0x1,%dl
  801547:	74 35                	je     80157e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801549:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801550:	25 07 0e 00 00       	and    $0xe07,%eax
  801555:	89 44 24 10          	mov    %eax,0x10(%esp)
  801559:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80155c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801560:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801567:	00 
  801568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80156c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801573:	e8 81 f6 ff ff       	call   800bf9 <sys_page_map>
  801578:	89 c3                	mov    %eax,%ebx
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 3b                	js     8015b9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801581:	89 c2                	mov    %eax,%edx
  801583:	c1 ea 0c             	shr    $0xc,%edx
  801586:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801593:	89 54 24 10          	mov    %edx,0x10(%esp)
  801597:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80159b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a2:	00 
  8015a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ae:	e8 46 f6 ff ff       	call   800bf9 <sys_page_map>
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	79 25                	jns    8015de <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c4:	e8 83 f6 ff ff       	call   800c4c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d7:	e8 70 f6 ff ff       	call   800c4c <sys_page_unmap>
	return r;
  8015dc:	eb 02                	jmp    8015e0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015de:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	83 c4 4c             	add    $0x4c,%esp
  8015e5:	5b                   	pop    %ebx
  8015e6:	5e                   	pop    %esi
  8015e7:	5f                   	pop    %edi
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 24             	sub    $0x24,%esp
  8015f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fb:	89 1c 24             	mov    %ebx,(%esp)
  8015fe:	e8 4b fd ff ff       	call   80134e <fd_lookup>
  801603:	85 c0                	test   %eax,%eax
  801605:	78 6d                	js     801674 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801607:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	8b 00                	mov    (%eax),%eax
  801613:	89 04 24             	mov    %eax,(%esp)
  801616:	e8 89 fd ff ff       	call   8013a4 <dev_lookup>
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 55                	js     801674 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80161f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801622:	8b 50 08             	mov    0x8(%eax),%edx
  801625:	83 e2 03             	and    $0x3,%edx
  801628:	83 fa 01             	cmp    $0x1,%edx
  80162b:	75 23                	jne    801650 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80162d:	a1 04 40 80 00       	mov    0x804004,%eax
  801632:	8b 40 48             	mov    0x48(%eax),%eax
  801635:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	c7 04 24 95 28 80 00 	movl   $0x802895,(%esp)
  801644:	e8 bf eb ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  801649:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164e:	eb 24                	jmp    801674 <read+0x8a>
	}
	if (!dev->dev_read)
  801650:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801653:	8b 52 08             	mov    0x8(%edx),%edx
  801656:	85 d2                	test   %edx,%edx
  801658:	74 15                	je     80166f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80165a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80165d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801661:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801664:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801668:	89 04 24             	mov    %eax,(%esp)
  80166b:	ff d2                	call   *%edx
  80166d:	eb 05                	jmp    801674 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80166f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801674:	83 c4 24             	add    $0x24,%esp
  801677:	5b                   	pop    %ebx
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    

0080167a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	57                   	push   %edi
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
  801680:	83 ec 1c             	sub    $0x1c,%esp
  801683:	8b 7d 08             	mov    0x8(%ebp),%edi
  801686:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801689:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168e:	eb 23                	jmp    8016b3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801690:	89 f0                	mov    %esi,%eax
  801692:	29 d8                	sub    %ebx,%eax
  801694:	89 44 24 08          	mov    %eax,0x8(%esp)
  801698:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169b:	01 d8                	add    %ebx,%eax
  80169d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a1:	89 3c 24             	mov    %edi,(%esp)
  8016a4:	e8 41 ff ff ff       	call   8015ea <read>
		if (m < 0)
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 10                	js     8016bd <readn+0x43>
			return m;
		if (m == 0)
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	74 0a                	je     8016bb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b1:	01 c3                	add    %eax,%ebx
  8016b3:	39 f3                	cmp    %esi,%ebx
  8016b5:	72 d9                	jb     801690 <readn+0x16>
  8016b7:	89 d8                	mov    %ebx,%eax
  8016b9:	eb 02                	jmp    8016bd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016bb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016bd:	83 c4 1c             	add    $0x1c,%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5e                   	pop    %esi
  8016c2:	5f                   	pop    %edi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 24             	sub    $0x24,%esp
  8016cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d6:	89 1c 24             	mov    %ebx,(%esp)
  8016d9:	e8 70 fc ff ff       	call   80134e <fd_lookup>
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 68                	js     80174a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ec:	8b 00                	mov    (%eax),%eax
  8016ee:	89 04 24             	mov    %eax,(%esp)
  8016f1:	e8 ae fc ff ff       	call   8013a4 <dev_lookup>
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 50                	js     80174a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801701:	75 23                	jne    801726 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801703:	a1 04 40 80 00       	mov    0x804004,%eax
  801708:	8b 40 48             	mov    0x48(%eax),%eax
  80170b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80170f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801713:	c7 04 24 b1 28 80 00 	movl   $0x8028b1,(%esp)
  80171a:	e8 e9 ea ff ff       	call   800208 <cprintf>
		return -E_INVAL;
  80171f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801724:	eb 24                	jmp    80174a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801726:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801729:	8b 52 0c             	mov    0xc(%edx),%edx
  80172c:	85 d2                	test   %edx,%edx
  80172e:	74 15                	je     801745 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801730:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801733:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	ff d2                	call   *%edx
  801743:	eb 05                	jmp    80174a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801745:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80174a:	83 c4 24             	add    $0x24,%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <seek>:

int
seek(int fdnum, off_t offset)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801756:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175d:	8b 45 08             	mov    0x8(%ebp),%eax
  801760:	89 04 24             	mov    %eax,(%esp)
  801763:	e8 e6 fb ff ff       	call   80134e <fd_lookup>
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 0e                	js     80177a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80176c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80176f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801772:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801775:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 24             	sub    $0x24,%esp
  801783:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801786:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178d:	89 1c 24             	mov    %ebx,(%esp)
  801790:	e8 b9 fb ff ff       	call   80134e <fd_lookup>
  801795:	85 c0                	test   %eax,%eax
  801797:	78 61                	js     8017fa <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801799:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a3:	8b 00                	mov    (%eax),%eax
  8017a5:	89 04 24             	mov    %eax,(%esp)
  8017a8:	e8 f7 fb ff ff       	call   8013a4 <dev_lookup>
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 49                	js     8017fa <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b8:	75 23                	jne    8017dd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017ba:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017bf:	8b 40 48             	mov    0x48(%eax),%eax
  8017c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ca:	c7 04 24 74 28 80 00 	movl   $0x802874,(%esp)
  8017d1:	e8 32 ea ff ff       	call   800208 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017db:	eb 1d                	jmp    8017fa <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e0:	8b 52 18             	mov    0x18(%edx),%edx
  8017e3:	85 d2                	test   %edx,%edx
  8017e5:	74 0e                	je     8017f5 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ea:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ee:	89 04 24             	mov    %eax,(%esp)
  8017f1:	ff d2                	call   *%edx
  8017f3:	eb 05                	jmp    8017fa <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017fa:	83 c4 24             	add    $0x24,%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 24             	sub    $0x24,%esp
  801807:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	89 04 24             	mov    %eax,(%esp)
  801817:	e8 32 fb ff ff       	call   80134e <fd_lookup>
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 52                	js     801872 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801820:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182a:	8b 00                	mov    (%eax),%eax
  80182c:	89 04 24             	mov    %eax,(%esp)
  80182f:	e8 70 fb ff ff       	call   8013a4 <dev_lookup>
  801834:	85 c0                	test   %eax,%eax
  801836:	78 3a                	js     801872 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801838:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80183f:	74 2c                	je     80186d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801841:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801844:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80184b:	00 00 00 
	stat->st_isdir = 0;
  80184e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801855:	00 00 00 
	stat->st_dev = dev;
  801858:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80185e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801862:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801865:	89 14 24             	mov    %edx,(%esp)
  801868:	ff 50 14             	call   *0x14(%eax)
  80186b:	eb 05                	jmp    801872 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80186d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801872:	83 c4 24             	add    $0x24,%esp
  801875:	5b                   	pop    %ebx
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801880:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801887:	00 
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 fe 01 00 00       	call   801a91 <open>
  801893:	89 c3                	mov    %eax,%ebx
  801895:	85 c0                	test   %eax,%eax
  801897:	78 1b                	js     8018b4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a0:	89 1c 24             	mov    %ebx,(%esp)
  8018a3:	e8 58 ff ff ff       	call   801800 <fstat>
  8018a8:	89 c6                	mov    %eax,%esi
	close(fd);
  8018aa:	89 1c 24             	mov    %ebx,(%esp)
  8018ad:	e8 d4 fb ff ff       	call   801486 <close>
	return r;
  8018b2:	89 f3                	mov    %esi,%ebx
}
  8018b4:	89 d8                	mov    %ebx,%eax
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5e                   	pop    %esi
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    
  8018bd:	00 00                	add    %al,(%eax)
	...

008018c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	56                   	push   %esi
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 10             	sub    $0x10,%esp
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018d3:	75 11                	jne    8018e6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018dc:	e8 aa f9 ff ff       	call   80128b <ipc_find_env>
  8018e1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018ed:	00 
  8018ee:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018f5:	00 
  8018f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018fa:	a1 00 40 80 00       	mov    0x804000,%eax
  8018ff:	89 04 24             	mov    %eax,(%esp)
  801902:	e8 1a f9 ff ff       	call   801221 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801907:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80190e:	00 
  80190f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801913:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191a:	e8 99 f8 ff ff       	call   8011b8 <ipc_recv>
}
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	8b 40 0c             	mov    0xc(%eax),%eax
  801932:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80193f:	ba 00 00 00 00       	mov    $0x0,%edx
  801944:	b8 02 00 00 00       	mov    $0x2,%eax
  801949:	e8 72 ff ff ff       	call   8018c0 <fsipc>
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	8b 40 0c             	mov    0xc(%eax),%eax
  80195c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801961:	ba 00 00 00 00       	mov    $0x0,%edx
  801966:	b8 06 00 00 00       	mov    $0x6,%eax
  80196b:	e8 50 ff ff ff       	call   8018c0 <fsipc>
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	53                   	push   %ebx
  801976:	83 ec 14             	sub    $0x14,%esp
  801979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	8b 40 0c             	mov    0xc(%eax),%eax
  801982:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801987:	ba 00 00 00 00       	mov    $0x0,%edx
  80198c:	b8 05 00 00 00       	mov    $0x5,%eax
  801991:	e8 2a ff ff ff       	call   8018c0 <fsipc>
  801996:	85 c0                	test   %eax,%eax
  801998:	78 2b                	js     8019c5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80199a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019a1:	00 
  8019a2:	89 1c 24             	mov    %ebx,(%esp)
  8019a5:	e8 09 ee ff ff       	call   8007b3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8019af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c5:	83 c4 14             	add    $0x14,%esp
  8019c8:	5b                   	pop    %ebx
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019d1:	c7 44 24 08 e0 28 80 	movl   $0x8028e0,0x8(%esp)
  8019d8:	00 
  8019d9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8019e0:	00 
  8019e1:	c7 04 24 fe 28 80 00 	movl   $0x8028fe,(%esp)
  8019e8:	e8 5b 06 00 00       	call   802048 <_panic>

008019ed <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 10             	sub    $0x10,%esp
  8019f5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a03:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a09:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a13:	e8 a8 fe ff ff       	call   8018c0 <fsipc>
  801a18:	89 c3                	mov    %eax,%ebx
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 6a                	js     801a88 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a1e:	39 c6                	cmp    %eax,%esi
  801a20:	73 24                	jae    801a46 <devfile_read+0x59>
  801a22:	c7 44 24 0c 09 29 80 	movl   $0x802909,0xc(%esp)
  801a29:	00 
  801a2a:	c7 44 24 08 10 29 80 	movl   $0x802910,0x8(%esp)
  801a31:	00 
  801a32:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a39:	00 
  801a3a:	c7 04 24 fe 28 80 00 	movl   $0x8028fe,(%esp)
  801a41:	e8 02 06 00 00       	call   802048 <_panic>
	assert(r <= PGSIZE);
  801a46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4b:	7e 24                	jle    801a71 <devfile_read+0x84>
  801a4d:	c7 44 24 0c 25 29 80 	movl   $0x802925,0xc(%esp)
  801a54:	00 
  801a55:	c7 44 24 08 10 29 80 	movl   $0x802910,0x8(%esp)
  801a5c:	00 
  801a5d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a64:	00 
  801a65:	c7 04 24 fe 28 80 00 	movl   $0x8028fe,(%esp)
  801a6c:	e8 d7 05 00 00       	call   802048 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a75:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a7c:	00 
  801a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a80:	89 04 24             	mov    %eax,(%esp)
  801a83:	e8 a4 ee ff ff       	call   80092c <memmove>
	return r;
}
  801a88:	89 d8                	mov    %ebx,%eax
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 20             	sub    $0x20,%esp
  801a99:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a9c:	89 34 24             	mov    %esi,(%esp)
  801a9f:	e8 dc ec ff ff       	call   800780 <strlen>
  801aa4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aa9:	7f 60                	jg     801b0b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aae:	89 04 24             	mov    %eax,(%esp)
  801ab1:	e8 45 f8 ff ff       	call   8012fb <fd_alloc>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	78 54                	js     801b10 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801abc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ac7:	e8 e7 ec ff ff       	call   8007b3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ad4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad7:	b8 01 00 00 00       	mov    $0x1,%eax
  801adc:	e8 df fd ff ff       	call   8018c0 <fsipc>
  801ae1:	89 c3                	mov    %eax,%ebx
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	79 15                	jns    801afc <open+0x6b>
		fd_close(fd, 0);
  801ae7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aee:	00 
  801aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af2:	89 04 24             	mov    %eax,(%esp)
  801af5:	e8 04 f9 ff ff       	call   8013fe <fd_close>
		return r;
  801afa:	eb 14                	jmp    801b10 <open+0x7f>
	}

	return fd2num(fd);
  801afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aff:	89 04 24             	mov    %eax,(%esp)
  801b02:	e8 c9 f7 ff ff       	call   8012d0 <fd2num>
  801b07:	89 c3                	mov    %eax,%ebx
  801b09:	eb 05                	jmp    801b10 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b0b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b10:	89 d8                	mov    %ebx,%eax
  801b12:	83 c4 20             	add    $0x20,%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b24:	b8 08 00 00 00       	mov    $0x8,%eax
  801b29:	e8 92 fd ff ff       	call   8018c0 <fsipc>
}
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	56                   	push   %esi
  801b34:	53                   	push   %ebx
  801b35:	83 ec 10             	sub    $0x10,%esp
  801b38:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	89 04 24             	mov    %eax,(%esp)
  801b41:	e8 9a f7 ff ff       	call   8012e0 <fd2data>
  801b46:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b48:	c7 44 24 04 31 29 80 	movl   $0x802931,0x4(%esp)
  801b4f:	00 
  801b50:	89 34 24             	mov    %esi,(%esp)
  801b53:	e8 5b ec ff ff       	call   8007b3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b58:	8b 43 04             	mov    0x4(%ebx),%eax
  801b5b:	2b 03                	sub    (%ebx),%eax
  801b5d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b63:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b6a:	00 00 00 
	stat->st_dev = &devpipe;
  801b6d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801b74:	30 80 00 
	return 0;
}
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	53                   	push   %ebx
  801b87:	83 ec 14             	sub    $0x14,%esp
  801b8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b98:	e8 af f0 ff ff       	call   800c4c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b9d:	89 1c 24             	mov    %ebx,(%esp)
  801ba0:	e8 3b f7 ff ff       	call   8012e0 <fd2data>
  801ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb0:	e8 97 f0 ff ff       	call   800c4c <sys_page_unmap>
}
  801bb5:	83 c4 14             	add    $0x14,%esp
  801bb8:	5b                   	pop    %ebx
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	57                   	push   %edi
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 2c             	sub    $0x2c,%esp
  801bc4:	89 c7                	mov    %eax,%edi
  801bc6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bc9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bce:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bd1:	89 3c 24             	mov    %edi,(%esp)
  801bd4:	e8 3b 05 00 00       	call   802114 <pageref>
  801bd9:	89 c6                	mov    %eax,%esi
  801bdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bde:	89 04 24             	mov    %eax,(%esp)
  801be1:	e8 2e 05 00 00       	call   802114 <pageref>
  801be6:	39 c6                	cmp    %eax,%esi
  801be8:	0f 94 c0             	sete   %al
  801beb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801bee:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bf4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bf7:	39 cb                	cmp    %ecx,%ebx
  801bf9:	75 08                	jne    801c03 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801bfb:	83 c4 2c             	add    $0x2c,%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5f                   	pop    %edi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c03:	83 f8 01             	cmp    $0x1,%eax
  801c06:	75 c1                	jne    801bc9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c08:	8b 42 58             	mov    0x58(%edx),%eax
  801c0b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c12:	00 
  801c13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c1b:	c7 04 24 38 29 80 00 	movl   $0x802938,(%esp)
  801c22:	e8 e1 e5 ff ff       	call   800208 <cprintf>
  801c27:	eb a0                	jmp    801bc9 <_pipeisclosed+0xe>

00801c29 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	57                   	push   %edi
  801c2d:	56                   	push   %esi
  801c2e:	53                   	push   %ebx
  801c2f:	83 ec 1c             	sub    $0x1c,%esp
  801c32:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c35:	89 34 24             	mov    %esi,(%esp)
  801c38:	e8 a3 f6 ff ff       	call   8012e0 <fd2data>
  801c3d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c44:	eb 3c                	jmp    801c82 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c46:	89 da                	mov    %ebx,%edx
  801c48:	89 f0                	mov    %esi,%eax
  801c4a:	e8 6c ff ff ff       	call   801bbb <_pipeisclosed>
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	75 38                	jne    801c8b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c53:	e8 2e ef ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c58:	8b 43 04             	mov    0x4(%ebx),%eax
  801c5b:	8b 13                	mov    (%ebx),%edx
  801c5d:	83 c2 20             	add    $0x20,%edx
  801c60:	39 d0                	cmp    %edx,%eax
  801c62:	73 e2                	jae    801c46 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c67:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801c6a:	89 c2                	mov    %eax,%edx
  801c6c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c72:	79 05                	jns    801c79 <devpipe_write+0x50>
  801c74:	4a                   	dec    %edx
  801c75:	83 ca e0             	or     $0xffffffe0,%edx
  801c78:	42                   	inc    %edx
  801c79:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c7d:	40                   	inc    %eax
  801c7e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c81:	47                   	inc    %edi
  801c82:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c85:	75 d1                	jne    801c58 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c87:	89 f8                	mov    %edi,%eax
  801c89:	eb 05                	jmp    801c90 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c8b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	57                   	push   %edi
  801c9c:	56                   	push   %esi
  801c9d:	53                   	push   %ebx
  801c9e:	83 ec 1c             	sub    $0x1c,%esp
  801ca1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ca4:	89 3c 24             	mov    %edi,(%esp)
  801ca7:	e8 34 f6 ff ff       	call   8012e0 <fd2data>
  801cac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cae:	be 00 00 00 00       	mov    $0x0,%esi
  801cb3:	eb 3a                	jmp    801cef <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cb5:	85 f6                	test   %esi,%esi
  801cb7:	74 04                	je     801cbd <devpipe_read+0x25>
				return i;
  801cb9:	89 f0                	mov    %esi,%eax
  801cbb:	eb 40                	jmp    801cfd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cbd:	89 da                	mov    %ebx,%edx
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	e8 f5 fe ff ff       	call   801bbb <_pipeisclosed>
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	75 2e                	jne    801cf8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cca:	e8 b7 ee ff ff       	call   800b86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ccf:	8b 03                	mov    (%ebx),%eax
  801cd1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cd4:	74 df                	je     801cb5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801cdb:	79 05                	jns    801ce2 <devpipe_read+0x4a>
  801cdd:	48                   	dec    %eax
  801cde:	83 c8 e0             	or     $0xffffffe0,%eax
  801ce1:	40                   	inc    %eax
  801ce2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801cec:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cee:	46                   	inc    %esi
  801cef:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cf2:	75 db                	jne    801ccf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf4:	89 f0                	mov    %esi,%eax
  801cf6:	eb 05                	jmp    801cfd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cfd:	83 c4 1c             	add    $0x1c,%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	57                   	push   %edi
  801d09:	56                   	push   %esi
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 3c             	sub    $0x3c,%esp
  801d0e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d14:	89 04 24             	mov    %eax,(%esp)
  801d17:	e8 df f5 ff ff       	call   8012fb <fd_alloc>
  801d1c:	89 c3                	mov    %eax,%ebx
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	0f 88 45 01 00 00    	js     801e6b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d2d:	00 
  801d2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d3c:	e8 64 ee ff ff       	call   800ba5 <sys_page_alloc>
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	85 c0                	test   %eax,%eax
  801d45:	0f 88 20 01 00 00    	js     801e6b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d4b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d4e:	89 04 24             	mov    %eax,(%esp)
  801d51:	e8 a5 f5 ff ff       	call   8012fb <fd_alloc>
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	0f 88 f8 00 00 00    	js     801e58 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d60:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d67:	00 
  801d68:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d76:	e8 2a ee ff ff       	call   800ba5 <sys_page_alloc>
  801d7b:	89 c3                	mov    %eax,%ebx
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	0f 88 d3 00 00 00    	js     801e58 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d88:	89 04 24             	mov    %eax,(%esp)
  801d8b:	e8 50 f5 ff ff       	call   8012e0 <fd2data>
  801d90:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d99:	00 
  801d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da5:	e8 fb ed ff ff       	call   800ba5 <sys_page_alloc>
  801daa:	89 c3                	mov    %eax,%ebx
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 91 00 00 00    	js     801e45 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801db7:	89 04 24             	mov    %eax,(%esp)
  801dba:	e8 21 f5 ff ff       	call   8012e0 <fd2data>
  801dbf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801dc6:	00 
  801dc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dd2:	00 
  801dd3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dde:	e8 16 ee ff ff       	call   800bf9 <sys_page_map>
  801de3:	89 c3                	mov    %eax,%ebx
  801de5:	85 c0                	test   %eax,%eax
  801de7:	78 4c                	js     801e35 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801def:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dfe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e07:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e0c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e16:	89 04 24             	mov    %eax,(%esp)
  801e19:	e8 b2 f4 ff ff       	call   8012d0 <fd2num>
  801e1e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e20:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e23:	89 04 24             	mov    %eax,(%esp)
  801e26:	e8 a5 f4 ff ff       	call   8012d0 <fd2num>
  801e2b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e33:	eb 36                	jmp    801e6b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e35:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e40:	e8 07 ee ff ff       	call   800c4c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e45:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e53:	e8 f4 ed ff ff       	call   800c4c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e66:	e8 e1 ed ff ff       	call   800c4c <sys_page_unmap>
    err:
	return r;
}
  801e6b:	89 d8                	mov    %ebx,%eax
  801e6d:	83 c4 3c             	add    $0x3c,%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    

00801e75 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e82:	8b 45 08             	mov    0x8(%ebp),%eax
  801e85:	89 04 24             	mov    %eax,(%esp)
  801e88:	e8 c1 f4 ff ff       	call   80134e <fd_lookup>
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 15                	js     801ea6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e94:	89 04 24             	mov    %eax,(%esp)
  801e97:	e8 44 f4 ff ff       	call   8012e0 <fd2data>
	return _pipeisclosed(fd, p);
  801e9c:	89 c2                	mov    %eax,%edx
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	e8 15 fd ff ff       	call   801bbb <_pipeisclosed>
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eab:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    

00801eb2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801eb8:	c7 44 24 04 50 29 80 	movl   $0x802950,0x4(%esp)
  801ebf:	00 
  801ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec3:	89 04 24             	mov    %eax,(%esp)
  801ec6:	e8 e8 e8 ff ff       	call   8007b3 <strcpy>
	return 0;
}
  801ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ede:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee9:	eb 30                	jmp    801f1b <devcons_write+0x49>
		m = n - tot;
  801eeb:	8b 75 10             	mov    0x10(%ebp),%esi
  801eee:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801ef0:	83 fe 7f             	cmp    $0x7f,%esi
  801ef3:	76 05                	jbe    801efa <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801ef5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801efa:	89 74 24 08          	mov    %esi,0x8(%esp)
  801efe:	03 45 0c             	add    0xc(%ebp),%eax
  801f01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f05:	89 3c 24             	mov    %edi,(%esp)
  801f08:	e8 1f ea ff ff       	call   80092c <memmove>
		sys_cputs(buf, m);
  801f0d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f11:	89 3c 24             	mov    %edi,(%esp)
  801f14:	e8 bf eb ff ff       	call   800ad8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f19:	01 f3                	add    %esi,%ebx
  801f1b:	89 d8                	mov    %ebx,%eax
  801f1d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f20:	72 c9                	jb     801eeb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f22:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5f                   	pop    %edi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    

00801f2d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f37:	75 07                	jne    801f40 <devcons_read+0x13>
  801f39:	eb 25                	jmp    801f60 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f3b:	e8 46 ec ff ff       	call   800b86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f40:	e8 b1 eb ff ff       	call   800af6 <sys_cgetc>
  801f45:	85 c0                	test   %eax,%eax
  801f47:	74 f2                	je     801f3b <devcons_read+0xe>
  801f49:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 1d                	js     801f6c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f4f:	83 f8 04             	cmp    $0x4,%eax
  801f52:	74 13                	je     801f67 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f57:	88 10                	mov    %dl,(%eax)
	return 1;
  801f59:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5e:	eb 0c                	jmp    801f6c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
  801f65:	eb 05                	jmp    801f6c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f6c:	c9                   	leave  
  801f6d:	c3                   	ret    

00801f6e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801f74:	8b 45 08             	mov    0x8(%ebp),%eax
  801f77:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f81:	00 
  801f82:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 4b eb ff ff       	call   800ad8 <sys_cputs>
}
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    

00801f8f <getchar>:

int
getchar(void)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f95:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801f9c:	00 
  801f9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fab:	e8 3a f6 ff ff       	call   8015ea <read>
	if (r < 0)
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 0f                	js     801fc3 <getchar+0x34>
		return r;
	if (r < 1)
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	7e 06                	jle    801fbe <getchar+0x2f>
		return -E_EOF;
	return c;
  801fb8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fbc:	eb 05                	jmp    801fc3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fbe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd5:	89 04 24             	mov    %eax,(%esp)
  801fd8:	e8 71 f3 ff ff       	call   80134e <fd_lookup>
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 11                	js     801ff2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fea:	39 10                	cmp    %edx,(%eax)
  801fec:	0f 94 c0             	sete   %al
  801fef:	0f b6 c0             	movzbl %al,%eax
}
  801ff2:	c9                   	leave  
  801ff3:	c3                   	ret    

00801ff4 <opencons>:

int
opencons(void)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffd:	89 04 24             	mov    %eax,(%esp)
  802000:	e8 f6 f2 ff ff       	call   8012fb <fd_alloc>
  802005:	85 c0                	test   %eax,%eax
  802007:	78 3c                	js     802045 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802009:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802010:	00 
  802011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802014:	89 44 24 04          	mov    %eax,0x4(%esp)
  802018:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80201f:	e8 81 eb ff ff       	call   800ba5 <sys_page_alloc>
  802024:	85 c0                	test   %eax,%eax
  802026:	78 1d                	js     802045 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802028:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80202e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802031:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802033:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802036:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80203d:	89 04 24             	mov    %eax,(%esp)
  802040:	e8 8b f2 ff ff       	call   8012d0 <fd2num>
}
  802045:	c9                   	leave  
  802046:	c3                   	ret    
	...

00802048 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	56                   	push   %esi
  80204c:	53                   	push   %ebx
  80204d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802050:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802053:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802059:	e8 09 eb ff ff       	call   800b67 <sys_getenvid>
  80205e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802061:	89 54 24 10          	mov    %edx,0x10(%esp)
  802065:	8b 55 08             	mov    0x8(%ebp),%edx
  802068:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80206c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802070:	89 44 24 04          	mov    %eax,0x4(%esp)
  802074:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  80207b:	e8 88 e1 ff ff       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802080:	89 74 24 04          	mov    %esi,0x4(%esp)
  802084:	8b 45 10             	mov    0x10(%ebp),%eax
  802087:	89 04 24             	mov    %eax,(%esp)
  80208a:	e8 18 e1 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  80208f:	c7 04 24 49 29 80 00 	movl   $0x802949,(%esp)
  802096:	e8 6d e1 ff ff       	call   800208 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80209b:	cc                   	int3   
  80209c:	eb fd                	jmp    80209b <_panic+0x53>
	...

008020a0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020a6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020ad:	75 32                	jne    8020e1 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8020af:	e8 b3 ea ff ff       	call   800b67 <sys_getenvid>
  8020b4:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  8020bb:	00 
  8020bc:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8020c3:	ee 
  8020c4:	89 04 24             	mov    %eax,(%esp)
  8020c7:	e8 d9 ea ff ff       	call   800ba5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  8020cc:	e8 96 ea ff ff       	call   800b67 <sys_getenvid>
  8020d1:	c7 44 24 04 ec 20 80 	movl   $0x8020ec,0x4(%esp)
  8020d8:	00 
  8020d9:	89 04 24             	mov    %eax,(%esp)
  8020dc:	e8 64 ec ff ff       	call   800d45 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e4:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    
	...

008020ec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020ec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020ed:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020f2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020f4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  8020f7:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  8020fb:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  8020fe:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  802103:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  802107:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  80210a:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  80210b:	83 c4 04             	add    $0x4,%esp
	popfl
  80210e:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  80210f:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  802110:	c3                   	ret    
  802111:	00 00                	add    %al,(%eax)
	...

00802114 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211a:	89 c2                	mov    %eax,%edx
  80211c:	c1 ea 16             	shr    $0x16,%edx
  80211f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802126:	f6 c2 01             	test   $0x1,%dl
  802129:	74 1e                	je     802149 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80212b:	c1 e8 0c             	shr    $0xc,%eax
  80212e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802135:	a8 01                	test   $0x1,%al
  802137:	74 17                	je     802150 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802139:	c1 e8 0c             	shr    $0xc,%eax
  80213c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802143:	ef 
  802144:	0f b7 c0             	movzwl %ax,%eax
  802147:	eb 0c                	jmp    802155 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802149:	b8 00 00 00 00       	mov    $0x0,%eax
  80214e:	eb 05                	jmp    802155 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802150:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802155:	5d                   	pop    %ebp
  802156:	c3                   	ret    
	...

00802158 <__udivdi3>:
  802158:	55                   	push   %ebp
  802159:	57                   	push   %edi
  80215a:	56                   	push   %esi
  80215b:	83 ec 10             	sub    $0x10,%esp
  80215e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802162:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802166:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80216e:	89 cd                	mov    %ecx,%ebp
  802170:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802174:	85 c0                	test   %eax,%eax
  802176:	75 2c                	jne    8021a4 <__udivdi3+0x4c>
  802178:	39 f9                	cmp    %edi,%ecx
  80217a:	77 68                	ja     8021e4 <__udivdi3+0x8c>
  80217c:	85 c9                	test   %ecx,%ecx
  80217e:	75 0b                	jne    80218b <__udivdi3+0x33>
  802180:	b8 01 00 00 00       	mov    $0x1,%eax
  802185:	31 d2                	xor    %edx,%edx
  802187:	f7 f1                	div    %ecx
  802189:	89 c1                	mov    %eax,%ecx
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	89 f8                	mov    %edi,%eax
  80218f:	f7 f1                	div    %ecx
  802191:	89 c7                	mov    %eax,%edi
  802193:	89 f0                	mov    %esi,%eax
  802195:	f7 f1                	div    %ecx
  802197:	89 c6                	mov    %eax,%esi
  802199:	89 f0                	mov    %esi,%eax
  80219b:	89 fa                	mov    %edi,%edx
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	39 f8                	cmp    %edi,%eax
  8021a6:	77 2c                	ja     8021d4 <__udivdi3+0x7c>
  8021a8:	0f bd f0             	bsr    %eax,%esi
  8021ab:	83 f6 1f             	xor    $0x1f,%esi
  8021ae:	75 4c                	jne    8021fc <__udivdi3+0xa4>
  8021b0:	39 f8                	cmp    %edi,%eax
  8021b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8021b7:	72 0a                	jb     8021c3 <__udivdi3+0x6b>
  8021b9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021bd:	0f 87 ad 00 00 00    	ja     802270 <__udivdi3+0x118>
  8021c3:	be 01 00 00 00       	mov    $0x1,%esi
  8021c8:	89 f0                	mov    %esi,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 10             	add    $0x10,%esp
  8021cf:	5e                   	pop    %esi
  8021d0:	5f                   	pop    %edi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    
  8021d3:	90                   	nop
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	31 f6                	xor    %esi,%esi
  8021d8:	89 f0                	mov    %esi,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 10             	add    $0x10,%esp
  8021df:	5e                   	pop    %esi
  8021e0:	5f                   	pop    %edi
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    
  8021e3:	90                   	nop
  8021e4:	89 fa                	mov    %edi,%edx
  8021e6:	89 f0                	mov    %esi,%eax
  8021e8:	f7 f1                	div    %ecx
  8021ea:	89 c6                	mov    %eax,%esi
  8021ec:	31 ff                	xor    %edi,%edi
  8021ee:	89 f0                	mov    %esi,%eax
  8021f0:	89 fa                	mov    %edi,%edx
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d 76 00             	lea    0x0(%esi),%esi
  8021fc:	89 f1                	mov    %esi,%ecx
  8021fe:	d3 e0                	shl    %cl,%eax
  802200:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802204:	b8 20 00 00 00       	mov    $0x20,%eax
  802209:	29 f0                	sub    %esi,%eax
  80220b:	89 ea                	mov    %ebp,%edx
  80220d:	88 c1                	mov    %al,%cl
  80220f:	d3 ea                	shr    %cl,%edx
  802211:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802215:	09 ca                	or     %ecx,%edx
  802217:	89 54 24 08          	mov    %edx,0x8(%esp)
  80221b:	89 f1                	mov    %esi,%ecx
  80221d:	d3 e5                	shl    %cl,%ebp
  80221f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802223:	89 fd                	mov    %edi,%ebp
  802225:	88 c1                	mov    %al,%cl
  802227:	d3 ed                	shr    %cl,%ebp
  802229:	89 fa                	mov    %edi,%edx
  80222b:	89 f1                	mov    %esi,%ecx
  80222d:	d3 e2                	shl    %cl,%edx
  80222f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802233:	88 c1                	mov    %al,%cl
  802235:	d3 ef                	shr    %cl,%edi
  802237:	09 d7                	or     %edx,%edi
  802239:	89 f8                	mov    %edi,%eax
  80223b:	89 ea                	mov    %ebp,%edx
  80223d:	f7 74 24 08          	divl   0x8(%esp)
  802241:	89 d1                	mov    %edx,%ecx
  802243:	89 c7                	mov    %eax,%edi
  802245:	f7 64 24 0c          	mull   0xc(%esp)
  802249:	39 d1                	cmp    %edx,%ecx
  80224b:	72 17                	jb     802264 <__udivdi3+0x10c>
  80224d:	74 09                	je     802258 <__udivdi3+0x100>
  80224f:	89 fe                	mov    %edi,%esi
  802251:	31 ff                	xor    %edi,%edi
  802253:	e9 41 ff ff ff       	jmp    802199 <__udivdi3+0x41>
  802258:	8b 54 24 04          	mov    0x4(%esp),%edx
  80225c:	89 f1                	mov    %esi,%ecx
  80225e:	d3 e2                	shl    %cl,%edx
  802260:	39 c2                	cmp    %eax,%edx
  802262:	73 eb                	jae    80224f <__udivdi3+0xf7>
  802264:	8d 77 ff             	lea    -0x1(%edi),%esi
  802267:	31 ff                	xor    %edi,%edi
  802269:	e9 2b ff ff ff       	jmp    802199 <__udivdi3+0x41>
  80226e:	66 90                	xchg   %ax,%ax
  802270:	31 f6                	xor    %esi,%esi
  802272:	e9 22 ff ff ff       	jmp    802199 <__udivdi3+0x41>
	...

00802278 <__umoddi3>:
  802278:	55                   	push   %ebp
  802279:	57                   	push   %edi
  80227a:	56                   	push   %esi
  80227b:	83 ec 20             	sub    $0x20,%esp
  80227e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802282:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802286:	89 44 24 14          	mov    %eax,0x14(%esp)
  80228a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80228e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802292:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802296:	89 c7                	mov    %eax,%edi
  802298:	89 f2                	mov    %esi,%edx
  80229a:	85 ed                	test   %ebp,%ebp
  80229c:	75 16                	jne    8022b4 <__umoddi3+0x3c>
  80229e:	39 f1                	cmp    %esi,%ecx
  8022a0:	0f 86 a6 00 00 00    	jbe    80234c <__umoddi3+0xd4>
  8022a6:	f7 f1                	div    %ecx
  8022a8:	89 d0                	mov    %edx,%eax
  8022aa:	31 d2                	xor    %edx,%edx
  8022ac:	83 c4 20             	add    $0x20,%esp
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    
  8022b3:	90                   	nop
  8022b4:	39 f5                	cmp    %esi,%ebp
  8022b6:	0f 87 ac 00 00 00    	ja     802368 <__umoddi3+0xf0>
  8022bc:	0f bd c5             	bsr    %ebp,%eax
  8022bf:	83 f0 1f             	xor    $0x1f,%eax
  8022c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022c6:	0f 84 a8 00 00 00    	je     802374 <__umoddi3+0xfc>
  8022cc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8022d0:	d3 e5                	shl    %cl,%ebp
  8022d2:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8022db:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022df:	89 f9                	mov    %edi,%ecx
  8022e1:	d3 e8                	shr    %cl,%eax
  8022e3:	09 e8                	or     %ebp,%eax
  8022e5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022e9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022ed:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8022f1:	d3 e0                	shl    %cl,%eax
  8022f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022f7:	89 f2                	mov    %esi,%edx
  8022f9:	d3 e2                	shl    %cl,%edx
  8022fb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022ff:	d3 e0                	shl    %cl,%eax
  802301:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802305:	8b 44 24 14          	mov    0x14(%esp),%eax
  802309:	89 f9                	mov    %edi,%ecx
  80230b:	d3 e8                	shr    %cl,%eax
  80230d:	09 d0                	or     %edx,%eax
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	89 f2                	mov    %esi,%edx
  802313:	f7 74 24 18          	divl   0x18(%esp)
  802317:	89 d6                	mov    %edx,%esi
  802319:	f7 64 24 0c          	mull   0xc(%esp)
  80231d:	89 c5                	mov    %eax,%ebp
  80231f:	89 d1                	mov    %edx,%ecx
  802321:	39 d6                	cmp    %edx,%esi
  802323:	72 67                	jb     80238c <__umoddi3+0x114>
  802325:	74 75                	je     80239c <__umoddi3+0x124>
  802327:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80232b:	29 e8                	sub    %ebp,%eax
  80232d:	19 ce                	sbb    %ecx,%esi
  80232f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802333:	d3 e8                	shr    %cl,%eax
  802335:	89 f2                	mov    %esi,%edx
  802337:	89 f9                	mov    %edi,%ecx
  802339:	d3 e2                	shl    %cl,%edx
  80233b:	09 d0                	or     %edx,%eax
  80233d:	89 f2                	mov    %esi,%edx
  80233f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802343:	d3 ea                	shr    %cl,%edx
  802345:	83 c4 20             	add    $0x20,%esp
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	85 c9                	test   %ecx,%ecx
  80234e:	75 0b                	jne    80235b <__umoddi3+0xe3>
  802350:	b8 01 00 00 00       	mov    $0x1,%eax
  802355:	31 d2                	xor    %edx,%edx
  802357:	f7 f1                	div    %ecx
  802359:	89 c1                	mov    %eax,%ecx
  80235b:	89 f0                	mov    %esi,%eax
  80235d:	31 d2                	xor    %edx,%edx
  80235f:	f7 f1                	div    %ecx
  802361:	89 f8                	mov    %edi,%eax
  802363:	e9 3e ff ff ff       	jmp    8022a6 <__umoddi3+0x2e>
  802368:	89 f2                	mov    %esi,%edx
  80236a:	83 c4 20             	add    $0x20,%esp
  80236d:	5e                   	pop    %esi
  80236e:	5f                   	pop    %edi
  80236f:	5d                   	pop    %ebp
  802370:	c3                   	ret    
  802371:	8d 76 00             	lea    0x0(%esi),%esi
  802374:	39 f5                	cmp    %esi,%ebp
  802376:	72 04                	jb     80237c <__umoddi3+0x104>
  802378:	39 f9                	cmp    %edi,%ecx
  80237a:	77 06                	ja     802382 <__umoddi3+0x10a>
  80237c:	89 f2                	mov    %esi,%edx
  80237e:	29 cf                	sub    %ecx,%edi
  802380:	19 ea                	sbb    %ebp,%edx
  802382:	89 f8                	mov    %edi,%eax
  802384:	83 c4 20             	add    $0x20,%esp
  802387:	5e                   	pop    %esi
  802388:	5f                   	pop    %edi
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    
  80238b:	90                   	nop
  80238c:	89 d1                	mov    %edx,%ecx
  80238e:	89 c5                	mov    %eax,%ebp
  802390:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802394:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802398:	eb 8d                	jmp    802327 <__umoddi3+0xaf>
  80239a:	66 90                	xchg   %ax,%ax
  80239c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8023a0:	72 ea                	jb     80238c <__umoddi3+0x114>
  8023a2:	89 f1                	mov    %esi,%ecx
  8023a4:	eb 81                	jmp    802327 <__umoddi3+0xaf>
