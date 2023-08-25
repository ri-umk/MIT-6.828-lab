
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 a2 11 00 00       	call   8011e4 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 63 0b 00 00       	call   800bb7 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  800063:	e8 f0 01 00 00       	call   800258 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 47 0b 00 00       	call   800bb7 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 1a 24 80 00 	movl   $0x80241a,(%esp)
  80007f:	e8 d4 01 00 00       	call   800258 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 ca 11 00 00       	call   801271 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 46 11 00 00       	call   801208 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 db 0a 00 00       	call   800bb7 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  8000fa:	e8 59 01 00 00       	call   800258 <cprintf>
		if (val == 10)
  8000ff:	a1 04 40 80 00       	mov    0x804004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 36                	je     80013f <umain+0x10b>
			return;
		++val;
  800109:	40                   	inc    %eax
  80010a:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 3f 11 00 00       	call   801271 <ipc_send>
		if (val == 10)
  800132:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  800139:	0f 85 68 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 4c             	add    $0x4c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800156:	e8 5c 0a 00 00       	call   800bb7 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800181:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800185:	89 34 24             	mov    %esi,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018d:	e8 0a 00 00 00       	call   80019c <exit>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a2:	e8 60 13 00 00       	call   801507 <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 b2 09 00 00       	call   800b65 <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 14             	sub    $0x14,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 03                	mov    (%ebx),%eax
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cb:	40                   	inc    %eax
  8001cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d3:	75 19                	jne    8001ee <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001dc:	00 
  8001dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 40 09 00 00       	call   800b28 <sys_cputs>
		b->idx = 0;
  8001e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ee:	ff 43 04             	incl   0x4(%ebx)
}
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800222:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	c7 04 24 b8 01 80 00 	movl   $0x8001b8,(%esp)
  800233:	e8 82 01 00 00       	call   8003ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800238:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 d8 08 00 00       	call   800b28 <sys_cputs>

	return b.cnt;
}
  800250:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 87 ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    
	...

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 3c             	sub    $0x3c,%esp
  80027d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800280:	89 d7                	mov    %edx,%edi
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800291:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800294:	85 c0                	test   %eax,%eax
  800296:	75 08                	jne    8002a0 <printnum+0x2c>
  800298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029e:	77 57                	ja     8002f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a4:	4b                   	dec    %ebx
  8002a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bf:	00 
  8002c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	e8 d6 1e 00 00       	call   8021a8 <__udivdi3>
  8002d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e1:	89 fa                	mov    %edi,%edx
  8002e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e6:	e8 89 ff ff ff       	call   800274 <printnum>
  8002eb:	eb 0f                	jmp    8002fc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f1:	89 34 24             	mov    %esi,(%esp)
  8002f4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f7:	4b                   	dec    %ebx
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7f f1                	jg     8002ed <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 10             	mov    0x10(%ebp),%eax
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800312:	00 
  800313:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800320:	e8 a3 1f 00 00       	call   8022c8 <__umoddi3>
  800325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800329:	0f be 80 60 24 80 00 	movsbl 0x802460(%eax),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800336:	83 c4 3c             	add    $0x3c,%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800341:	83 fa 01             	cmp    $0x1,%edx
  800344:	7e 0e                	jle    800354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	8b 52 04             	mov    0x4(%edx),%edx
  800352:	eb 22                	jmp    800376 <getuint+0x38>
	else if (lflag)
  800354:	85 d2                	test   %edx,%edx
  800356:	74 10                	je     800368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb 0e                	jmp    800376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800381:	8b 10                	mov    (%eax),%edx
  800383:	3b 50 04             	cmp    0x4(%eax),%edx
  800386:	73 08                	jae    800390 <sprintputch+0x18>
		*b->buf++ = ch;
  800388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038b:	88 0a                	mov    %cl,(%edx)
  80038d:	42                   	inc    %edx
  80038e:	89 10                	mov    %edx,(%eax)
}
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800398:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80039f:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 02 00 00 00       	call   8003ba <vprintfmt>
	va_end(ap);
}
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	57                   	push   %edi
  8003be:	56                   	push   %esi
  8003bf:	53                   	push   %ebx
  8003c0:	83 ec 4c             	sub    $0x4c,%esp
  8003c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c9:	eb 12                	jmp    8003dd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cb:	85 c0                	test   %eax,%eax
  8003cd:	0f 84 6b 03 00 00    	je     80073e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003dd:	0f b6 06             	movzbl (%esi),%eax
  8003e0:	46                   	inc    %esi
  8003e1:	83 f8 25             	cmp    $0x25,%eax
  8003e4:	75 e5                	jne    8003cb <vprintfmt+0x11>
  8003e6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800402:	eb 26                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800407:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80040b:	eb 1d                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800410:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800414:	eb 14                	jmp    80042a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800419:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800420:	eb 08                	jmp    80042a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800422:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800425:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	0f b6 06             	movzbl (%esi),%eax
  80042d:	8d 56 01             	lea    0x1(%esi),%edx
  800430:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800433:	8a 16                	mov    (%esi),%dl
  800435:	83 ea 23             	sub    $0x23,%edx
  800438:	80 fa 55             	cmp    $0x55,%dl
  80043b:	0f 87 e1 02 00 00    	ja     800722 <vprintfmt+0x368>
  800441:	0f b6 d2             	movzbl %dl,%edx
  800444:	ff 24 95 a0 25 80 00 	jmp    *0x8025a0(,%edx,4)
  80044b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80044e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800453:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800456:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80045a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80045d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800460:	83 fa 09             	cmp    $0x9,%edx
  800463:	77 2a                	ja     80048f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800465:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb eb                	jmp    800453 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800476:	eb 17                	jmp    80048f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800478:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047c:	78 98                	js     800416 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800481:	eb a7                	jmp    80042a <vprintfmt+0x70>
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800486:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80048d:	eb 9b                	jmp    80042a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80048f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800493:	79 95                	jns    80042a <vprintfmt+0x70>
  800495:	eb 8b                	jmp    800422 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800497:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049b:	eb 8d                	jmp    80042a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b5:	e9 23 ff ff ff       	jmp    8003dd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 00                	mov    (%eax),%eax
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	79 02                	jns    8004cb <vprintfmt+0x111>
  8004c9:	f7 d8                	neg    %eax
  8004cb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cd:	83 f8 0f             	cmp    $0xf,%eax
  8004d0:	7f 0b                	jg     8004dd <vprintfmt+0x123>
  8004d2:	8b 04 85 00 27 80 00 	mov    0x802700(,%eax,4),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	75 23                	jne    800500 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e1:	c7 44 24 08 78 24 80 	movl   $0x802478,0x8(%esp)
  8004e8:	00 
  8004e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 9a fe ff ff       	call   800392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004fb:	e9 dd fe ff ff       	jmp    8003dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800500:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800504:	c7 44 24 08 82 29 80 	movl   $0x802982,0x8(%esp)
  80050b:	00 
  80050c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800510:	8b 55 08             	mov    0x8(%ebp),%edx
  800513:	89 14 24             	mov    %edx,(%esp)
  800516:	e8 77 fe ff ff       	call   800392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	e9 ba fe ff ff       	jmp    8003dd <vprintfmt+0x23>
  800523:	89 f9                	mov    %edi,%ecx
  800525:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800528:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 30                	mov    (%eax),%esi
  800536:	85 f6                	test   %esi,%esi
  800538:	75 05                	jne    80053f <vprintfmt+0x185>
				p = "(null)";
  80053a:	be 71 24 80 00       	mov    $0x802471,%esi
			if (width > 0 && padc != '-')
  80053f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800543:	0f 8e 84 00 00 00    	jle    8005cd <vprintfmt+0x213>
  800549:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80054d:	74 7e                	je     8005cd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800553:	89 34 24             	mov    %esi,(%esp)
  800556:	e8 8b 02 00 00       	call   8007e6 <strnlen>
  80055b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80055e:	29 c2                	sub    %eax,%edx
  800560:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800563:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800567:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80056a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80056d:	89 de                	mov    %ebx,%esi
  80056f:	89 d3                	mov    %edx,%ebx
  800571:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	eb 0b                	jmp    800580 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800575:	89 74 24 04          	mov    %esi,0x4(%esp)
  800579:	89 3c 24             	mov    %edi,(%esp)
  80057c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	4b                   	dec    %ebx
  800580:	85 db                	test   %ebx,%ebx
  800582:	7f f1                	jg     800575 <vprintfmt+0x1bb>
  800584:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800587:	89 f3                	mov    %esi,%ebx
  800589:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80058c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058f:	85 c0                	test   %eax,%eax
  800591:	79 05                	jns    800598 <vprintfmt+0x1de>
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059b:	29 c2                	sub    %eax,%edx
  80059d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a0:	eb 2b                	jmp    8005cd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a6:	74 18                	je     8005c0 <vprintfmt+0x206>
  8005a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ab:	83 fa 5e             	cmp    $0x5e,%edx
  8005ae:	76 10                	jbe    8005c0 <vprintfmt+0x206>
					putch('?', putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	eb 0a                	jmp    8005ca <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	ff 4d e4             	decl   -0x1c(%ebp)
  8005cd:	0f be 06             	movsbl (%esi),%eax
  8005d0:	46                   	inc    %esi
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	74 21                	je     8005f6 <vprintfmt+0x23c>
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	78 c9                	js     8005a2 <vprintfmt+0x1e8>
  8005d9:	4f                   	dec    %edi
  8005da:	79 c6                	jns    8005a2 <vprintfmt+0x1e8>
  8005dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005df:	89 de                	mov    %ebx,%esi
  8005e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e4:	eb 18                	jmp    8005fe <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f3:	4b                   	dec    %ebx
  8005f4:	eb 08                	jmp    8005fe <vprintfmt+0x244>
  8005f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f9:	89 de                	mov    %ebx,%esi
  8005fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fe:	85 db                	test   %ebx,%ebx
  800600:	7f e4                	jg     8005e6 <vprintfmt+0x22c>
  800602:	89 7d 08             	mov    %edi,0x8(%ebp)
  800605:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060a:	e9 ce fd ff ff       	jmp    8003dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060f:	83 f9 01             	cmp    $0x1,%ecx
  800612:	7e 10                	jle    800624 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 08             	lea    0x8(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	8b 78 04             	mov    0x4(%eax),%edi
  800622:	eb 26                	jmp    80064a <vprintfmt+0x290>
	else if (lflag)
  800624:	85 c9                	test   %ecx,%ecx
  800626:	74 12                	je     80063a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 30                	mov    (%eax),%esi
  800633:	89 f7                	mov    %esi,%edi
  800635:	c1 ff 1f             	sar    $0x1f,%edi
  800638:	eb 10                	jmp    80064a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 30                	mov    (%eax),%esi
  800645:	89 f7                	mov    %esi,%edi
  800647:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064a:	85 ff                	test   %edi,%edi
  80064c:	78 0a                	js     800658 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800653:	e9 8c 00 00 00       	jmp    8006e4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800666:	f7 de                	neg    %esi
  800668:	83 d7 00             	adc    $0x0,%edi
  80066b:	f7 df                	neg    %edi
			}
			base = 10;
  80066d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800672:	eb 70                	jmp    8006e4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	89 ca                	mov    %ecx,%edx
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 c0 fc ff ff       	call   80033e <getuint>
  80067e:	89 c6                	mov    %eax,%esi
  800680:	89 d7                	mov    %edx,%edi
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800687:	eb 5b                	jmp    8006e4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 ab fc ff ff       	call   80033e <getuint>
  800693:	89 c6                	mov    %eax,%esi
  800695:	89 d7                	mov    %edx,%edi
			base = 8;
  800697:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80069c:	eb 46                	jmp    8006e4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c3:	8b 30                	mov    (%eax),%esi
  8006c5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cf:	eb 13                	jmp    8006e4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d1:	89 ca                	mov    %ecx,%edx
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 63 fc ff ff       	call   80033e <getuint>
  8006db:	89 c6                	mov    %eax,%esi
  8006dd:	89 d7                	mov    %edx,%edi
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006e8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f7:	89 34 24             	mov    %esi,(%esp)
  8006fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fe:	89 da                	mov    %ebx,%edx
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	e8 6c fb ff ff       	call   800274 <printnum>
			break;
  800708:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80070b:	e9 cd fc ff ff       	jmp    8003dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071d:	e9 bb fc ff ff       	jmp    8003dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800722:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800726:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800730:	eb 01                	jmp    800733 <vprintfmt+0x379>
  800732:	4e                   	dec    %esi
  800733:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800737:	75 f9                	jne    800732 <vprintfmt+0x378>
  800739:	e9 9f fc ff ff       	jmp    8003dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80073e:	83 c4 4c             	add    $0x4c,%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5f                   	pop    %edi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 28             	sub    $0x28,%esp
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800752:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800755:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800759:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800763:	85 c0                	test   %eax,%eax
  800765:	74 30                	je     800797 <vsnprintf+0x51>
  800767:	85 d2                	test   %edx,%edx
  800769:	7e 33                	jle    80079e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800772:	8b 45 10             	mov    0x10(%ebp),%eax
  800775:	89 44 24 08          	mov    %eax,0x8(%esp)
  800779:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800780:	c7 04 24 78 03 80 00 	movl   $0x800378,(%esp)
  800787:	e8 2e fc ff ff       	call   8003ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800795:	eb 0c                	jmp    8007a3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb 05                	jmp    8007a3 <vsnprintf+0x5d>
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 7b ff ff ff       	call   800746 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    
  8007cd:	00 00                	add    %al,(%eax)
	...

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 01                	jmp    8007de <strlen+0xe>
		n++;
  8007dd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f9                	jne    8007dd <strlen+0xd>
		n++;
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	eb 01                	jmp    8007f7 <strnlen+0x11>
		n++;
  8007f6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	39 d0                	cmp    %edx,%eax
  8007f9:	74 06                	je     800801 <strnlen+0x1b>
  8007fb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ff:	75 f5                	jne    8007f6 <strnlen+0x10>
		n++;
	return n;
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080d:	ba 00 00 00 00       	mov    $0x0,%edx
  800812:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800815:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800818:	42                   	inc    %edx
  800819:	84 c9                	test   %cl,%cl
  80081b:	75 f5                	jne    800812 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082a:	89 1c 24             	mov    %ebx,(%esp)
  80082d:	e8 9e ff ff ff       	call   8007d0 <strlen>
	strcpy(dst + len, src);
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
  800835:	89 54 24 04          	mov    %edx,0x4(%esp)
  800839:	01 d8                	add    %ebx,%eax
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	e8 c0 ff ff ff       	call   800803 <strcpy>
	return dst;
}
  800843:	89 d8                	mov    %ebx,%eax
  800845:	83 c4 08             	add    $0x8,%esp
  800848:	5b                   	pop    %ebx
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085e:	eb 0c                	jmp    80086c <strncpy+0x21>
		*dst++ = *src;
  800860:	8a 1a                	mov    (%edx),%bl
  800862:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800865:	80 3a 01             	cmpb   $0x1,(%edx)
  800868:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086b:	41                   	inc    %ecx
  80086c:	39 f1                	cmp    %esi,%ecx
  80086e:	75 f0                	jne    800860 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 75 08             	mov    0x8(%ebp),%esi
  80087c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800882:	85 d2                	test   %edx,%edx
  800884:	75 0a                	jne    800890 <strlcpy+0x1c>
  800886:	89 f0                	mov    %esi,%eax
  800888:	eb 1a                	jmp    8008a4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088a:	88 18                	mov    %bl,(%eax)
  80088c:	40                   	inc    %eax
  80088d:	41                   	inc    %ecx
  80088e:	eb 02                	jmp    800892 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800892:	4a                   	dec    %edx
  800893:	74 0a                	je     80089f <strlcpy+0x2b>
  800895:	8a 19                	mov    (%ecx),%bl
  800897:	84 db                	test   %bl,%bl
  800899:	75 ef                	jne    80088a <strlcpy+0x16>
  80089b:	89 c2                	mov    %eax,%edx
  80089d:	eb 02                	jmp    8008a1 <strlcpy+0x2d>
  80089f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008a4:	29 f0                	sub    %esi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b3:	eb 02                	jmp    8008b7 <strcmp+0xd>
		p++, q++;
  8008b5:	41                   	inc    %ecx
  8008b6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b7:	8a 01                	mov    (%ecx),%al
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 04                	je     8008c1 <strcmp+0x17>
  8008bd:	3a 02                	cmp    (%edx),%al
  8008bf:	74 f4                	je     8008b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c1:	0f b6 c0             	movzbl %al,%eax
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	29 d0                	sub    %edx,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d8:	eb 03                	jmp    8008dd <strncmp+0x12>
		n--, p++, q++;
  8008da:	4a                   	dec    %edx
  8008db:	40                   	inc    %eax
  8008dc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	74 14                	je     8008f5 <strncmp+0x2a>
  8008e1:	8a 18                	mov    (%eax),%bl
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	74 04                	je     8008eb <strncmp+0x20>
  8008e7:	3a 19                	cmp    (%ecx),%bl
  8008e9:	74 ef                	je     8008da <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 11             	movzbl (%ecx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
  8008f3:	eb 05                	jmp    8008fa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800906:	eb 05                	jmp    80090d <strchr+0x10>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 0c                	je     800918 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090c:	40                   	inc    %eax
  80090d:	8a 10                	mov    (%eax),%dl
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f5                	jne    800908 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800923:	eb 05                	jmp    80092a <strfind+0x10>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 07                	je     800930 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800929:	40                   	inc    %eax
  80092a:	8a 10                	mov    (%eax),%dl
  80092c:	84 d2                	test   %dl,%dl
  80092e:	75 f5                	jne    800925 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	57                   	push   %edi
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	74 30                	je     800975 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800945:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094b:	75 25                	jne    800972 <memset+0x40>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 20                	jne    800972 <memset+0x40>
		c &= 0xFF;
  800952:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800955:	89 d3                	mov    %edx,%ebx
  800957:	c1 e3 08             	shl    $0x8,%ebx
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	c1 e6 18             	shl    $0x18,%esi
  80095f:	89 d0                	mov    %edx,%eax
  800961:	c1 e0 10             	shl    $0x10,%eax
  800964:	09 f0                	or     %esi,%eax
  800966:	09 d0                	or     %edx,%eax
  800968:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80096d:	fc                   	cld    
  80096e:	f3 ab                	rep stos %eax,%es:(%edi)
  800970:	eb 03                	jmp    800975 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800972:	fc                   	cld    
  800973:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800975:	89 f8                	mov    %edi,%eax
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098a:	39 c6                	cmp    %eax,%esi
  80098c:	73 34                	jae    8009c2 <memmove+0x46>
  80098e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800991:	39 d0                	cmp    %edx,%eax
  800993:	73 2d                	jae    8009c2 <memmove+0x46>
		s += n;
		d += n;
  800995:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800998:	f6 c2 03             	test   $0x3,%dl
  80099b:	75 1b                	jne    8009b8 <memmove+0x3c>
  80099d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a3:	75 13                	jne    8009b8 <memmove+0x3c>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 0e                	jne    8009b8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009aa:	83 ef 04             	sub    $0x4,%edi
  8009ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b6:	eb 07                	jmp    8009bf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b8:	4f                   	dec    %edi
  8009b9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bc:	fd                   	std    
  8009bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bf:	fc                   	cld    
  8009c0:	eb 20                	jmp    8009e2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c8:	75 13                	jne    8009dd <memmove+0x61>
  8009ca:	a8 03                	test   $0x3,%al
  8009cc:	75 0f                	jne    8009dd <memmove+0x61>
  8009ce:	f6 c1 03             	test   $0x3,%cl
  8009d1:	75 0a                	jne    8009dd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009db:	eb 05                	jmp    8009e2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 77 ff ff ff       	call   80097c <memmove>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1b:	eb 16                	jmp    800a33 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a20:	42                   	inc    %edx
  800a21:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a25:	38 c8                	cmp    %cl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 c9             	movzbl %cl,%ecx
  800a2f:	29 c8                	sub    %ecx,%eax
  800a31:	eb 09                	jmp    800a3c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	75 e6                	jne    800a1d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4a:	89 c2                	mov    %eax,%edx
  800a4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4f:	eb 05                	jmp    800a56 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a51:	38 08                	cmp    %cl,(%eax)
  800a53:	74 05                	je     800a5a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a55:	40                   	inc    %eax
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	72 f7                	jb     800a51 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a68:	eb 01                	jmp    800a6b <strtol+0xf>
		s++;
  800a6a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6b:	8a 02                	mov    (%edx),%al
  800a6d:	3c 20                	cmp    $0x20,%al
  800a6f:	74 f9                	je     800a6a <strtol+0xe>
  800a71:	3c 09                	cmp    $0x9,%al
  800a73:	74 f5                	je     800a6a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a75:	3c 2b                	cmp    $0x2b,%al
  800a77:	75 08                	jne    800a81 <strtol+0x25>
		s++;
  800a79:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7f:	eb 13                	jmp    800a94 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a81:	3c 2d                	cmp    $0x2d,%al
  800a83:	75 0a                	jne    800a8f <strtol+0x33>
		s++, neg = 1;
  800a85:	8d 52 01             	lea    0x1(%edx),%edx
  800a88:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8d:	eb 05                	jmp    800a94 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	74 05                	je     800a9d <strtol+0x41>
  800a98:	83 fb 10             	cmp    $0x10,%ebx
  800a9b:	75 28                	jne    800ac5 <strtol+0x69>
  800a9d:	8a 02                	mov    (%edx),%al
  800a9f:	3c 30                	cmp    $0x30,%al
  800aa1:	75 10                	jne    800ab3 <strtol+0x57>
  800aa3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa7:	75 0a                	jne    800ab3 <strtol+0x57>
		s += 2, base = 16;
  800aa9:	83 c2 02             	add    $0x2,%edx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 12                	jmp    800ac5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 0e                	jne    800ac5 <strtol+0x69>
  800ab7:	3c 30                	cmp    $0x30,%al
  800ab9:	75 05                	jne    800ac0 <strtol+0x64>
		s++, base = 8;
  800abb:	42                   	inc    %edx
  800abc:	b3 08                	mov    $0x8,%bl
  800abe:	eb 05                	jmp    800ac5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aca:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800acc:	8a 0a                	mov    (%edx),%cl
  800ace:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x82>
			dig = *s - '0';
  800ad6:	0f be c9             	movsbl %cl,%ecx
  800ad9:	83 e9 30             	sub    $0x30,%ecx
  800adc:	eb 1e                	jmp    800afc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ade:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x92>
			dig = *s - 'a' + 10;
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 57             	sub    $0x57,%ecx
  800aec:	eb 0e                	jmp    800afc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aee:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 12                	ja     800b08 <strtol+0xac>
			dig = *s - 'A' + 10;
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800afc:	39 f1                	cmp    %esi,%ecx
  800afe:	7d 0c                	jge    800b0c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b00:	42                   	inc    %edx
  800b01:	0f af c6             	imul   %esi,%eax
  800b04:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b06:	eb c4                	jmp    800acc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b08:	89 c1                	mov    %eax,%ecx
  800b0a:	eb 02                	jmp    800b0e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b12:	74 05                	je     800b19 <strtol+0xbd>
		*endptr = (char *) s;
  800b14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b17:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	74 04                	je     800b21 <strtol+0xc5>
  800b1d:	89 c8                	mov    %ecx,%eax
  800b1f:	f7 d8                	neg    %eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
	...

00800b28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 c3                	mov    %eax,%ebx
  800b3b:	89 c7                	mov    %eax,%edi
  800b3d:	89 c6                	mov    %eax,%esi
  800b3f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 01 00 00 00       	mov    $0x1,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b73:	b8 03 00 00 00       	mov    $0x3,%eax
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	89 cb                	mov    %ecx,%ebx
  800b7d:	89 cf                	mov    %ecx,%edi
  800b7f:	89 ce                	mov    %ecx,%esi
  800b81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7e 28                	jle    800baf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b8b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b92:	00 
  800b93:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800b9a:	00 
  800b9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba2:	00 
  800ba3:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800baa:	e8 e9 14 00 00       	call   802098 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	83 c4 2c             	add    $0x2c,%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 28                	jle    800c41 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c24:	00 
  800c25:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800c2c:	00 
  800c2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c34:	00 
  800c35:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800c3c:	e8 57 14 00 00       	call   802098 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c41:	83 c4 2c             	add    $0x2c,%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	b8 05 00 00 00       	mov    $0x5,%eax
  800c57:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 28                	jle    800c94 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c70:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c77:	00 
  800c78:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800c7f:	00 
  800c80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c87:	00 
  800c88:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800c8f:	e8 04 14 00 00       	call   802098 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c94:	83 c4 2c             	add    $0x2c,%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	b8 06 00 00 00       	mov    $0x6,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 df                	mov    %ebx,%edi
  800cb7:	89 de                	mov    %ebx,%esi
  800cb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 28                	jle    800ce7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cca:	00 
  800ccb:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cda:	00 
  800cdb:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800ce2:	e8 b1 13 00 00       	call   802098 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce7:	83 c4 2c             	add    $0x2c,%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	b8 08 00 00 00       	mov    $0x8,%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	89 df                	mov    %ebx,%edi
  800d0a:	89 de                	mov    %ebx,%esi
  800d0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 28                	jle    800d3a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d16:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800d25:	00 
  800d26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2d:	00 
  800d2e:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800d35:	e8 5e 13 00 00       	call   802098 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3a:	83 c4 2c             	add    $0x2c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 28                	jle    800d8d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d69:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d70:	00 
  800d71:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800d78:	00 
  800d79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d80:	00 
  800d81:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800d88:	e8 0b 13 00 00       	call   802098 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d8d:	83 c4 2c             	add    $0x2c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	89 df                	mov    %ebx,%edi
  800db0:	89 de                	mov    %ebx,%esi
  800db2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db4:	85 c0                	test   %eax,%eax
  800db6:	7e 28                	jle    800de0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd3:	00 
  800dd4:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800ddb:	e8 b8 12 00 00       	call   802098 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de0:	83 c4 2c             	add    $0x2c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	be 00 00 00 00       	mov    $0x0,%esi
  800df3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e19:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 cb                	mov    %ecx,%ebx
  800e23:	89 cf                	mov    %ecx,%edi
  800e25:	89 ce                	mov    %ecx,%esi
  800e27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800e50:	e8 43 12 00 00       	call   802098 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    
  800e5d:	00 00                	add    %al,(%eax)
	...

00800e60 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	53                   	push   %ebx
  800e64:	83 ec 24             	sub    $0x24,%esp
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e6a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800e6c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e70:	75 2d                	jne    800e9f <pgfault+0x3f>
  800e72:	89 d8                	mov    %ebx,%eax
  800e74:	c1 e8 0c             	shr    $0xc,%eax
  800e77:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e7e:	f6 c4 08             	test   $0x8,%ah
  800e81:	75 1c                	jne    800e9f <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800e83:	c7 44 24 08 8c 27 80 	movl   $0x80278c,0x8(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800e92:	00 
  800e93:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800e9a:	e8 f9 11 00 00       	call   802098 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800e9f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eae:	00 
  800eaf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb6:	e8 3a fd ff ff       	call   800bf5 <sys_page_alloc>
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	79 20                	jns    800edf <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800ebf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec3:	c7 44 24 08 fb 27 80 	movl   $0x8027fb,0x8(%esp)
  800eca:	00 
  800ecb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800ed2:	00 
  800ed3:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800eda:	e8 b9 11 00 00       	call   802098 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800edf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800ee5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800eec:	00 
  800eed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ef1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ef8:	e8 e9 fa ff ff       	call   8009e6 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800efd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f04:	00 
  800f05:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f09:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f20:	e8 24 fd ff ff       	call   800c49 <sys_page_map>
  800f25:	85 c0                	test   %eax,%eax
  800f27:	79 20                	jns    800f49 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  800f29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f2d:	c7 44 24 08 0e 28 80 	movl   $0x80280e,0x8(%esp)
  800f34:	00 
  800f35:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800f3c:	00 
  800f3d:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800f44:	e8 4f 11 00 00       	call   802098 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f49:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f58:	e8 3f fd ff ff       	call   800c9c <sys_page_unmap>
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	79 20                	jns    800f81 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  800f61:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f65:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f74:	00 
  800f75:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800f7c:	e8 17 11 00 00       	call   802098 <_panic>
}
  800f81:	83 c4 24             	add    $0x24,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  800f90:	c7 04 24 60 0e 80 00 	movl   $0x800e60,(%esp)
  800f97:	e8 54 11 00 00       	call   8020f0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f9c:	ba 07 00 00 00       	mov    $0x7,%edx
  800fa1:	89 d0                	mov    %edx,%eax
  800fa3:	cd 30                	int    $0x30
  800fa5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fa8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	79 1c                	jns    800fcb <fork+0x44>
		panic("sys_exofork failed\n");
  800faf:	c7 44 24 08 32 28 80 	movl   $0x802832,0x8(%esp)
  800fb6:	00 
  800fb7:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  800fbe:	00 
  800fbf:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800fc6:	e8 cd 10 00 00       	call   802098 <_panic>
	if(c_envid == 0){
  800fcb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fcf:	75 25                	jne    800ff6 <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd1:	e8 e1 fb ff ff       	call   800bb7 <sys_getenvid>
  800fd6:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fdb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fe2:	c1 e0 07             	shl    $0x7,%eax
  800fe5:	29 d0                	sub    %edx,%eax
  800fe7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fec:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ff1:	e9 e3 01 00 00       	jmp    8011d9 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  800ffb:	89 d8                	mov    %ebx,%eax
  800ffd:	c1 e8 16             	shr    $0x16,%eax
  801000:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801007:	a8 01                	test   $0x1,%al
  801009:	0f 84 0b 01 00 00    	je     80111a <fork+0x193>
  80100f:	89 de                	mov    %ebx,%esi
  801011:	c1 ee 0c             	shr    $0xc,%esi
  801014:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101b:	a8 05                	test   $0x5,%al
  80101d:	0f 84 f7 00 00 00    	je     80111a <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  801023:	89 f7                	mov    %esi,%edi
  801025:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  801028:	e8 8a fb ff ff       	call   800bb7 <sys_getenvid>
  80102d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801030:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801037:	a8 02                	test   $0x2,%al
  801039:	75 10                	jne    80104b <fork+0xc4>
  80103b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801042:	f6 c4 08             	test   $0x8,%ah
  801045:	0f 84 89 00 00 00    	je     8010d4 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  80104b:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801052:	00 
  801053:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801057:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80105a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801065:	89 04 24             	mov    %eax,(%esp)
  801068:	e8 dc fb ff ff       	call   800c49 <sys_page_map>
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 20                	jns    801091 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801075:	c7 44 24 08 46 28 80 	movl   $0x802846,0x8(%esp)
  80107c:	00 
  80107d:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  801084:	00 
  801085:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  80108c:	e8 07 10 00 00       	call   802098 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  801091:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801098:	00 
  801099:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80109d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010a8:	89 04 24             	mov    %eax,(%esp)
  8010ab:	e8 99 fb ff ff       	call   800c49 <sys_page_map>
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	79 66                	jns    80111a <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8010b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b8:	c7 44 24 08 46 28 80 	movl   $0x802846,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  8010cf:	e8 c4 0f 00 00       	call   802098 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  8010d4:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010db:	00 
  8010dc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ee:	89 04 24             	mov    %eax,(%esp)
  8010f1:	e8 53 fb ff ff       	call   800c49 <sys_page_map>
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	79 20                	jns    80111a <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  8010fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010fe:	c7 44 24 08 46 28 80 	movl   $0x802846,0x8(%esp)
  801105:	00 
  801106:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80110d:	00 
  80110e:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  801115:	e8 7e 0f 00 00       	call   802098 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  80111a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801120:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801126:	0f 85 cf fe ff ff    	jne    800ffb <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  80112c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801133:	00 
  801134:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80113b:	ee 
  80113c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80113f:	89 04 24             	mov    %eax,(%esp)
  801142:	e8 ae fa ff ff       	call   800bf5 <sys_page_alloc>
  801147:	85 c0                	test   %eax,%eax
  801149:	79 20                	jns    80116b <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  80114b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114f:	c7 44 24 08 58 28 80 	movl   $0x802858,0x8(%esp)
  801156:	00 
  801157:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80115e:	00 
  80115f:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  801166:	e8 2d 0f 00 00       	call   802098 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  80116b:	c7 44 24 04 3c 21 80 	movl   $0x80213c,0x4(%esp)
  801172:	00 
  801173:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801176:	89 04 24             	mov    %eax,(%esp)
  801179:	e8 17 fc ff ff       	call   800d95 <sys_env_set_pgfault_upcall>
  80117e:	85 c0                	test   %eax,%eax
  801180:	79 20                	jns    8011a2 <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801182:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801186:	c7 44 24 08 d0 27 80 	movl   $0x8027d0,0x8(%esp)
  80118d:	00 
  80118e:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801195:	00 
  801196:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  80119d:	e8 f6 0e 00 00       	call   802098 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  8011a2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011a9:	00 
  8011aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011ad:	89 04 24             	mov    %eax,(%esp)
  8011b0:	e8 3a fb ff ff       	call   800cef <sys_env_set_status>
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	79 20                	jns    8011d9 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  8011b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bd:	c7 44 24 08 6c 28 80 	movl   $0x80286c,0x8(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8011cc:	00 
  8011cd:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  8011d4:	e8 bf 0e 00 00       	call   802098 <_panic>
 
	return c_envid;	
}
  8011d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011dc:	83 c4 3c             	add    $0x3c,%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <sfork>:

// Challenge!
int
sfork(void)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011ea:	c7 44 24 08 84 28 80 	movl   $0x802884,0x8(%esp)
  8011f1:	00 
  8011f2:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8011f9:	00 
  8011fa:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  801201:	e8 92 0e 00 00       	call   802098 <_panic>
	...

00801208 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 1c             	sub    $0x1c,%esp
  801211:	8b 75 08             	mov    0x8(%ebp),%esi
  801214:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801217:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  80121a:	85 db                	test   %ebx,%ebx
  80121c:	75 05                	jne    801223 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  80121e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801223:	89 1c 24             	mov    %ebx,(%esp)
  801226:	e8 e0 fb ff ff       	call   800e0b <sys_ipc_recv>
  80122b:	85 c0                	test   %eax,%eax
  80122d:	79 16                	jns    801245 <ipc_recv+0x3d>
		*from_env_store = 0;
  80122f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801235:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  80123b:	89 1c 24             	mov    %ebx,(%esp)
  80123e:	e8 c8 fb ff ff       	call   800e0b <sys_ipc_recv>
  801243:	eb 24                	jmp    801269 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801245:	85 f6                	test   %esi,%esi
  801247:	74 0a                	je     801253 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801249:	a1 08 40 80 00       	mov    0x804008,%eax
  80124e:	8b 40 74             	mov    0x74(%eax),%eax
  801251:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801253:	85 ff                	test   %edi,%edi
  801255:	74 0a                	je     801261 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801257:	a1 08 40 80 00       	mov    0x804008,%eax
  80125c:	8b 40 78             	mov    0x78(%eax),%eax
  80125f:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801261:	a1 08 40 80 00       	mov    0x804008,%eax
  801266:	8b 40 70             	mov    0x70(%eax),%eax
}
  801269:	83 c4 1c             	add    $0x1c,%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	57                   	push   %edi
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
  801277:	83 ec 1c             	sub    $0x1c,%esp
  80127a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80127d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801280:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801283:	85 db                	test   %ebx,%ebx
  801285:	75 05                	jne    80128c <ipc_send+0x1b>
		pg = (void *)-1;
  801287:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80128c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801290:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801294:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801298:	8b 45 08             	mov    0x8(%ebp),%eax
  80129b:	89 04 24             	mov    %eax,(%esp)
  80129e:	e8 45 fb ff ff       	call   800de8 <sys_ipc_try_send>
		if (r == 0) {		
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	74 2c                	je     8012d3 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  8012a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012aa:	75 07                	jne    8012b3 <ipc_send+0x42>
			sys_yield();
  8012ac:	e8 25 f9 ff ff       	call   800bd6 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  8012b1:	eb d9                	jmp    80128c <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  8012b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b7:	c7 44 24 08 9a 28 80 	movl   $0x80289a,0x8(%esp)
  8012be:	00 
  8012bf:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8012c6:	00 
  8012c7:	c7 04 24 a8 28 80 00 	movl   $0x8028a8,(%esp)
  8012ce:	e8 c5 0d 00 00       	call   802098 <_panic>
		}
	}
}
  8012d3:	83 c4 1c             	add    $0x1c,%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5f                   	pop    %edi
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	53                   	push   %ebx
  8012df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012e7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8012ee:	89 c2                	mov    %eax,%edx
  8012f0:	c1 e2 07             	shl    $0x7,%edx
  8012f3:	29 ca                	sub    %ecx,%edx
  8012f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012fb:	8b 52 50             	mov    0x50(%edx),%edx
  8012fe:	39 da                	cmp    %ebx,%edx
  801300:	75 0f                	jne    801311 <ipc_find_env+0x36>
			return envs[i].env_id;
  801302:	c1 e0 07             	shl    $0x7,%eax
  801305:	29 c8                	sub    %ecx,%eax
  801307:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80130c:	8b 40 40             	mov    0x40(%eax),%eax
  80130f:	eb 0c                	jmp    80131d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801311:	40                   	inc    %eax
  801312:	3d 00 04 00 00       	cmp    $0x400,%eax
  801317:	75 ce                	jne    8012e7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801319:	66 b8 00 00          	mov    $0x0,%ax
}
  80131d:	5b                   	pop    %ebx
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	05 00 00 00 30       	add    $0x30000000,%eax
  80132b:	c1 e8 0c             	shr    $0xc,%eax
}
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801336:	8b 45 08             	mov    0x8(%ebp),%eax
  801339:	89 04 24             	mov    %eax,(%esp)
  80133c:	e8 df ff ff ff       	call   801320 <fd2num>
  801341:	05 20 00 0d 00       	add    $0xd0020,%eax
  801346:	c1 e0 0c             	shl    $0xc,%eax
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	53                   	push   %ebx
  80134f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801352:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801357:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801359:	89 c2                	mov    %eax,%edx
  80135b:	c1 ea 16             	shr    $0x16,%edx
  80135e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801365:	f6 c2 01             	test   $0x1,%dl
  801368:	74 11                	je     80137b <fd_alloc+0x30>
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	c1 ea 0c             	shr    $0xc,%edx
  80136f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801376:	f6 c2 01             	test   $0x1,%dl
  801379:	75 09                	jne    801384 <fd_alloc+0x39>
			*fd_store = fd;
  80137b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80137d:	b8 00 00 00 00       	mov    $0x0,%eax
  801382:	eb 17                	jmp    80139b <fd_alloc+0x50>
  801384:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801389:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80138e:	75 c7                	jne    801357 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801390:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801396:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80139b:	5b                   	pop    %ebx
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013a4:	83 f8 1f             	cmp    $0x1f,%eax
  8013a7:	77 36                	ja     8013df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013a9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013ae:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	c1 ea 16             	shr    $0x16,%edx
  8013b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013bd:	f6 c2 01             	test   $0x1,%dl
  8013c0:	74 24                	je     8013e6 <fd_lookup+0x48>
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	c1 ea 0c             	shr    $0xc,%edx
  8013c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	74 1a                	je     8013ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d6:	89 02                	mov    %eax,(%edx)
	return 0;
  8013d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013dd:	eb 13                	jmp    8013f2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e4:	eb 0c                	jmp    8013f2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013eb:	eb 05                	jmp    8013f2 <fd_lookup+0x54>
  8013ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 14             	sub    $0x14,%esp
  8013fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801401:	ba 00 00 00 00       	mov    $0x0,%edx
  801406:	eb 0e                	jmp    801416 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801408:	39 08                	cmp    %ecx,(%eax)
  80140a:	75 09                	jne    801415 <dev_lookup+0x21>
			*dev = devtab[i];
  80140c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80140e:	b8 00 00 00 00       	mov    $0x0,%eax
  801413:	eb 33                	jmp    801448 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801415:	42                   	inc    %edx
  801416:	8b 04 95 30 29 80 00 	mov    0x802930(,%edx,4),%eax
  80141d:	85 c0                	test   %eax,%eax
  80141f:	75 e7                	jne    801408 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801421:	a1 08 40 80 00       	mov    0x804008,%eax
  801426:	8b 40 48             	mov    0x48(%eax),%eax
  801429:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80142d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801431:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  801438:	e8 1b ee ff ff       	call   800258 <cprintf>
	*dev = 0;
  80143d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801448:	83 c4 14             	add    $0x14,%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	56                   	push   %esi
  801452:	53                   	push   %ebx
  801453:	83 ec 30             	sub    $0x30,%esp
  801456:	8b 75 08             	mov    0x8(%ebp),%esi
  801459:	8a 45 0c             	mov    0xc(%ebp),%al
  80145c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80145f:	89 34 24             	mov    %esi,(%esp)
  801462:	e8 b9 fe ff ff       	call   801320 <fd2num>
  801467:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80146a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80146e:	89 04 24             	mov    %eax,(%esp)
  801471:	e8 28 ff ff ff       	call   80139e <fd_lookup>
  801476:	89 c3                	mov    %eax,%ebx
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 05                	js     801481 <fd_close+0x33>
	    || fd != fd2)
  80147c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80147f:	74 0d                	je     80148e <fd_close+0x40>
		return (must_exist ? r : 0);
  801481:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801485:	75 46                	jne    8014cd <fd_close+0x7f>
  801487:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148c:	eb 3f                	jmp    8014cd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80148e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801491:	89 44 24 04          	mov    %eax,0x4(%esp)
  801495:	8b 06                	mov    (%esi),%eax
  801497:	89 04 24             	mov    %eax,(%esp)
  80149a:	e8 55 ff ff ff       	call   8013f4 <dev_lookup>
  80149f:	89 c3                	mov    %eax,%ebx
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 18                	js     8014bd <fd_close+0x6f>
		if (dev->dev_close)
  8014a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a8:	8b 40 10             	mov    0x10(%eax),%eax
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	74 09                	je     8014b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014af:	89 34 24             	mov    %esi,(%esp)
  8014b2:	ff d0                	call   *%eax
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	eb 05                	jmp    8014bd <fd_close+0x6f>
		else
			r = 0;
  8014b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c8:	e8 cf f7 ff ff       	call   800c9c <sys_page_unmap>
	return r;
}
  8014cd:	89 d8                	mov    %ebx,%eax
  8014cf:	83 c4 30             	add    $0x30,%esp
  8014d2:	5b                   	pop    %ebx
  8014d3:	5e                   	pop    %esi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	89 04 24             	mov    %eax,(%esp)
  8014e9:	e8 b0 fe ff ff       	call   80139e <fd_lookup>
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 13                	js     801505 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014f9:	00 
  8014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fd:	89 04 24             	mov    %eax,(%esp)
  801500:	e8 49 ff ff ff       	call   80144e <fd_close>
}
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <close_all>:

void
close_all(void)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	53                   	push   %ebx
  80150b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80150e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801513:	89 1c 24             	mov    %ebx,(%esp)
  801516:	e8 bb ff ff ff       	call   8014d6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80151b:	43                   	inc    %ebx
  80151c:	83 fb 20             	cmp    $0x20,%ebx
  80151f:	75 f2                	jne    801513 <close_all+0xc>
		close(i);
}
  801521:	83 c4 14             	add    $0x14,%esp
  801524:	5b                   	pop    %ebx
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	57                   	push   %edi
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 4c             	sub    $0x4c,%esp
  801530:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801533:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	89 04 24             	mov    %eax,(%esp)
  801540:	e8 59 fe ff ff       	call   80139e <fd_lookup>
  801545:	89 c3                	mov    %eax,%ebx
  801547:	85 c0                	test   %eax,%eax
  801549:	0f 88 e1 00 00 00    	js     801630 <dup+0x109>
		return r;
	close(newfdnum);
  80154f:	89 3c 24             	mov    %edi,(%esp)
  801552:	e8 7f ff ff ff       	call   8014d6 <close>

	newfd = INDEX2FD(newfdnum);
  801557:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80155d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801560:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801563:	89 04 24             	mov    %eax,(%esp)
  801566:	e8 c5 fd ff ff       	call   801330 <fd2data>
  80156b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80156d:	89 34 24             	mov    %esi,(%esp)
  801570:	e8 bb fd ff ff       	call   801330 <fd2data>
  801575:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801578:	89 d8                	mov    %ebx,%eax
  80157a:	c1 e8 16             	shr    $0x16,%eax
  80157d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801584:	a8 01                	test   $0x1,%al
  801586:	74 46                	je     8015ce <dup+0xa7>
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	c1 e8 0c             	shr    $0xc,%eax
  80158d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801594:	f6 c2 01             	test   $0x1,%dl
  801597:	74 35                	je     8015ce <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801599:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8015a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015b7:	00 
  8015b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c3:	e8 81 f6 ff ff       	call   800c49 <sys_page_map>
  8015c8:	89 c3                	mov    %eax,%ebx
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 3b                	js     801609 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	c1 ea 0c             	shr    $0xc,%edx
  8015d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015dd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015e3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f2:	00 
  8015f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fe:	e8 46 f6 ff ff       	call   800c49 <sys_page_map>
  801603:	89 c3                	mov    %eax,%ebx
  801605:	85 c0                	test   %eax,%eax
  801607:	79 25                	jns    80162e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801609:	89 74 24 04          	mov    %esi,0x4(%esp)
  80160d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801614:	e8 83 f6 ff ff       	call   800c9c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801619:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80161c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801627:	e8 70 f6 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  80162c:	eb 02                	jmp    801630 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80162e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801630:	89 d8                	mov    %ebx,%eax
  801632:	83 c4 4c             	add    $0x4c,%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5f                   	pop    %edi
  801638:	5d                   	pop    %ebp
  801639:	c3                   	ret    

0080163a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	53                   	push   %ebx
  80163e:	83 ec 24             	sub    $0x24,%esp
  801641:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801644:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	89 1c 24             	mov    %ebx,(%esp)
  80164e:	e8 4b fd ff ff       	call   80139e <fd_lookup>
  801653:	85 c0                	test   %eax,%eax
  801655:	78 6d                	js     8016c4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801661:	8b 00                	mov    (%eax),%eax
  801663:	89 04 24             	mov    %eax,(%esp)
  801666:	e8 89 fd ff ff       	call   8013f4 <dev_lookup>
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 55                	js     8016c4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801672:	8b 50 08             	mov    0x8(%eax),%edx
  801675:	83 e2 03             	and    $0x3,%edx
  801678:	83 fa 01             	cmp    $0x1,%edx
  80167b:	75 23                	jne    8016a0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80167d:	a1 08 40 80 00       	mov    0x804008,%eax
  801682:	8b 40 48             	mov    0x48(%eax),%eax
  801685:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168d:	c7 04 24 f5 28 80 00 	movl   $0x8028f5,(%esp)
  801694:	e8 bf eb ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  801699:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169e:	eb 24                	jmp    8016c4 <read+0x8a>
	}
	if (!dev->dev_read)
  8016a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a3:	8b 52 08             	mov    0x8(%edx),%edx
  8016a6:	85 d2                	test   %edx,%edx
  8016a8:	74 15                	je     8016bf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016b8:	89 04 24             	mov    %eax,(%esp)
  8016bb:	ff d2                	call   *%edx
  8016bd:	eb 05                	jmp    8016c4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016c4:	83 c4 24             	add    $0x24,%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	57                   	push   %edi
  8016ce:	56                   	push   %esi
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 1c             	sub    $0x1c,%esp
  8016d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016de:	eb 23                	jmp    801703 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016e0:	89 f0                	mov    %esi,%eax
  8016e2:	29 d8                	sub    %ebx,%eax
  8016e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016eb:	01 d8                	add    %ebx,%eax
  8016ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f1:	89 3c 24             	mov    %edi,(%esp)
  8016f4:	e8 41 ff ff ff       	call   80163a <read>
		if (m < 0)
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 10                	js     80170d <readn+0x43>
			return m;
		if (m == 0)
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	74 0a                	je     80170b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801701:	01 c3                	add    %eax,%ebx
  801703:	39 f3                	cmp    %esi,%ebx
  801705:	72 d9                	jb     8016e0 <readn+0x16>
  801707:	89 d8                	mov    %ebx,%eax
  801709:	eb 02                	jmp    80170d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80170b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80170d:	83 c4 1c             	add    $0x1c,%esp
  801710:	5b                   	pop    %ebx
  801711:	5e                   	pop    %esi
  801712:	5f                   	pop    %edi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	83 ec 24             	sub    $0x24,%esp
  80171c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801722:	89 44 24 04          	mov    %eax,0x4(%esp)
  801726:	89 1c 24             	mov    %ebx,(%esp)
  801729:	e8 70 fc ff ff       	call   80139e <fd_lookup>
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 68                	js     80179a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801732:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801735:	89 44 24 04          	mov    %eax,0x4(%esp)
  801739:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173c:	8b 00                	mov    (%eax),%eax
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	e8 ae fc ff ff       	call   8013f4 <dev_lookup>
  801746:	85 c0                	test   %eax,%eax
  801748:	78 50                	js     80179a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801751:	75 23                	jne    801776 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801753:	a1 08 40 80 00       	mov    0x804008,%eax
  801758:	8b 40 48             	mov    0x48(%eax),%eax
  80175b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80175f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801763:	c7 04 24 11 29 80 00 	movl   $0x802911,(%esp)
  80176a:	e8 e9 ea ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  80176f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801774:	eb 24                	jmp    80179a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801776:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801779:	8b 52 0c             	mov    0xc(%edx),%edx
  80177c:	85 d2                	test   %edx,%edx
  80177e:	74 15                	je     801795 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801780:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801783:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80178e:	89 04 24             	mov    %eax,(%esp)
  801791:	ff d2                	call   *%edx
  801793:	eb 05                	jmp    80179a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801795:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80179a:	83 c4 24             	add    $0x24,%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017a6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	89 04 24             	mov    %eax,(%esp)
  8017b3:	e8 e6 fb ff ff       	call   80139e <fd_lookup>
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 0e                	js     8017ca <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 24             	sub    $0x24,%esp
  8017d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dd:	89 1c 24             	mov    %ebx,(%esp)
  8017e0:	e8 b9 fb ff ff       	call   80139e <fd_lookup>
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 61                	js     80184a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f3:	8b 00                	mov    (%eax),%eax
  8017f5:	89 04 24             	mov    %eax,(%esp)
  8017f8:	e8 f7 fb ff ff       	call   8013f4 <dev_lookup>
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 49                	js     80184a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801804:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801808:	75 23                	jne    80182d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80180a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80180f:	8b 40 48             	mov    0x48(%eax),%eax
  801812:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801816:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181a:	c7 04 24 d4 28 80 00 	movl   $0x8028d4,(%esp)
  801821:	e8 32 ea ff ff       	call   800258 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801826:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182b:	eb 1d                	jmp    80184a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80182d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801830:	8b 52 18             	mov    0x18(%edx),%edx
  801833:	85 d2                	test   %edx,%edx
  801835:	74 0e                	je     801845 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	ff d2                	call   *%edx
  801843:	eb 05                	jmp    80184a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801845:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80184a:	83 c4 24             	add    $0x24,%esp
  80184d:	5b                   	pop    %ebx
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	53                   	push   %ebx
  801854:	83 ec 24             	sub    $0x24,%esp
  801857:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	89 04 24             	mov    %eax,(%esp)
  801867:	e8 32 fb ff ff       	call   80139e <fd_lookup>
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 52                	js     8018c2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801870:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801873:	89 44 24 04          	mov    %eax,0x4(%esp)
  801877:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187a:	8b 00                	mov    (%eax),%eax
  80187c:	89 04 24             	mov    %eax,(%esp)
  80187f:	e8 70 fb ff ff       	call   8013f4 <dev_lookup>
  801884:	85 c0                	test   %eax,%eax
  801886:	78 3a                	js     8018c2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80188f:	74 2c                	je     8018bd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801891:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801894:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80189b:	00 00 00 
	stat->st_isdir = 0;
  80189e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a5:	00 00 00 
	stat->st_dev = dev;
  8018a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018b5:	89 14 24             	mov    %edx,(%esp)
  8018b8:	ff 50 14             	call   *0x14(%eax)
  8018bb:	eb 05                	jmp    8018c2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018c2:	83 c4 24             	add    $0x24,%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018d7:	00 
  8018d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018db:	89 04 24             	mov    %eax,(%esp)
  8018de:	e8 fe 01 00 00       	call   801ae1 <open>
  8018e3:	89 c3                	mov    %eax,%ebx
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 1b                	js     801904 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8018e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f0:	89 1c 24             	mov    %ebx,(%esp)
  8018f3:	e8 58 ff ff ff       	call   801850 <fstat>
  8018f8:	89 c6                	mov    %eax,%esi
	close(fd);
  8018fa:	89 1c 24             	mov    %ebx,(%esp)
  8018fd:	e8 d4 fb ff ff       	call   8014d6 <close>
	return r;
  801902:	89 f3                	mov    %esi,%ebx
}
  801904:	89 d8                	mov    %ebx,%eax
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	5b                   	pop    %ebx
  80190a:	5e                   	pop    %esi
  80190b:	5d                   	pop    %ebp
  80190c:	c3                   	ret    
  80190d:	00 00                	add    %al,(%eax)
	...

00801910 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	83 ec 10             	sub    $0x10,%esp
  801918:	89 c3                	mov    %eax,%ebx
  80191a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80191c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801923:	75 11                	jne    801936 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801925:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80192c:	e8 aa f9 ff ff       	call   8012db <ipc_find_env>
  801931:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801936:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80193d:	00 
  80193e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801945:	00 
  801946:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194a:	a1 00 40 80 00       	mov    0x804000,%eax
  80194f:	89 04 24             	mov    %eax,(%esp)
  801952:	e8 1a f9 ff ff       	call   801271 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801957:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80195e:	00 
  80195f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801963:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196a:	e8 99 f8 ff ff       	call   801208 <ipc_recv>
}
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	5b                   	pop    %ebx
  801973:	5e                   	pop    %esi
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    

00801976 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	8b 40 0c             	mov    0xc(%eax),%eax
  801982:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	b8 02 00 00 00       	mov    $0x2,%eax
  801999:	e8 72 ff ff ff       	call   801910 <fsipc>
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ac:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8019bb:	e8 50 ff ff ff       	call   801910 <fsipc>
}
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 14             	sub    $0x14,%esp
  8019c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e1:	e8 2a ff ff ff       	call   801910 <fsipc>
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	78 2b                	js     801a15 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ea:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019f1:	00 
  8019f2:	89 1c 24             	mov    %ebx,(%esp)
  8019f5:	e8 09 ee ff ff       	call   800803 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019fa:	a1 80 50 80 00       	mov    0x805080,%eax
  8019ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a05:	a1 84 50 80 00       	mov    0x805084,%eax
  801a0a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a15:	83 c4 14             	add    $0x14,%esp
  801a18:	5b                   	pop    %ebx
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a21:	c7 44 24 08 40 29 80 	movl   $0x802940,0x8(%esp)
  801a28:	00 
  801a29:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a30:	00 
  801a31:	c7 04 24 5e 29 80 00 	movl   $0x80295e,(%esp)
  801a38:	e8 5b 06 00 00       	call   802098 <_panic>

00801a3d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	83 ec 10             	sub    $0x10,%esp
  801a45:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a53:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a59:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a63:	e8 a8 fe ff ff       	call   801910 <fsipc>
  801a68:	89 c3                	mov    %eax,%ebx
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 6a                	js     801ad8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a6e:	39 c6                	cmp    %eax,%esi
  801a70:	73 24                	jae    801a96 <devfile_read+0x59>
  801a72:	c7 44 24 0c 69 29 80 	movl   $0x802969,0xc(%esp)
  801a79:	00 
  801a7a:	c7 44 24 08 70 29 80 	movl   $0x802970,0x8(%esp)
  801a81:	00 
  801a82:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a89:	00 
  801a8a:	c7 04 24 5e 29 80 00 	movl   $0x80295e,(%esp)
  801a91:	e8 02 06 00 00       	call   802098 <_panic>
	assert(r <= PGSIZE);
  801a96:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a9b:	7e 24                	jle    801ac1 <devfile_read+0x84>
  801a9d:	c7 44 24 0c 85 29 80 	movl   $0x802985,0xc(%esp)
  801aa4:	00 
  801aa5:	c7 44 24 08 70 29 80 	movl   $0x802970,0x8(%esp)
  801aac:	00 
  801aad:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ab4:	00 
  801ab5:	c7 04 24 5e 29 80 00 	movl   $0x80295e,(%esp)
  801abc:	e8 d7 05 00 00       	call   802098 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ac1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801acc:	00 
  801acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad0:	89 04 24             	mov    %eax,(%esp)
  801ad3:	e8 a4 ee ff ff       	call   80097c <memmove>
	return r;
}
  801ad8:	89 d8                	mov    %ebx,%eax
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 20             	sub    $0x20,%esp
  801ae9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801aec:	89 34 24             	mov    %esi,(%esp)
  801aef:	e8 dc ec ff ff       	call   8007d0 <strlen>
  801af4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801af9:	7f 60                	jg     801b5b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801afb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afe:	89 04 24             	mov    %eax,(%esp)
  801b01:	e8 45 f8 ff ff       	call   80134b <fd_alloc>
  801b06:	89 c3                	mov    %eax,%ebx
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	78 54                	js     801b60 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b10:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b17:	e8 e7 ec ff ff       	call   800803 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b27:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2c:	e8 df fd ff ff       	call   801910 <fsipc>
  801b31:	89 c3                	mov    %eax,%ebx
  801b33:	85 c0                	test   %eax,%eax
  801b35:	79 15                	jns    801b4c <open+0x6b>
		fd_close(fd, 0);
  801b37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b3e:	00 
  801b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 04 f9 ff ff       	call   80144e <fd_close>
		return r;
  801b4a:	eb 14                	jmp    801b60 <open+0x7f>
	}

	return fd2num(fd);
  801b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4f:	89 04 24             	mov    %eax,(%esp)
  801b52:	e8 c9 f7 ff ff       	call   801320 <fd2num>
  801b57:	89 c3                	mov    %eax,%ebx
  801b59:	eb 05                	jmp    801b60 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b5b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b60:	89 d8                	mov    %ebx,%eax
  801b62:	83 c4 20             	add    $0x20,%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b74:	b8 08 00 00 00       	mov    $0x8,%eax
  801b79:	e8 92 fd ff ff       	call   801910 <fsipc>
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 10             	sub    $0x10,%esp
  801b88:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	89 04 24             	mov    %eax,(%esp)
  801b91:	e8 9a f7 ff ff       	call   801330 <fd2data>
  801b96:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b98:	c7 44 24 04 91 29 80 	movl   $0x802991,0x4(%esp)
  801b9f:	00 
  801ba0:	89 34 24             	mov    %esi,(%esp)
  801ba3:	e8 5b ec ff ff       	call   800803 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba8:	8b 43 04             	mov    0x4(%ebx),%eax
  801bab:	2b 03                	sub    (%ebx),%eax
  801bad:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bb3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bba:	00 00 00 
	stat->st_dev = &devpipe;
  801bbd:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801bc4:	30 80 00 
	return 0;
}
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 14             	sub    $0x14,%esp
  801bda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be8:	e8 af f0 ff ff       	call   800c9c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bed:	89 1c 24             	mov    %ebx,(%esp)
  801bf0:	e8 3b f7 ff ff       	call   801330 <fd2data>
  801bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c00:	e8 97 f0 ff ff       	call   800c9c <sys_page_unmap>
}
  801c05:	83 c4 14             	add    $0x14,%esp
  801c08:	5b                   	pop    %ebx
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	57                   	push   %edi
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	83 ec 2c             	sub    $0x2c,%esp
  801c14:	89 c7                	mov    %eax,%edi
  801c16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c19:	a1 08 40 80 00       	mov    0x804008,%eax
  801c1e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c21:	89 3c 24             	mov    %edi,(%esp)
  801c24:	e8 3b 05 00 00       	call   802164 <pageref>
  801c29:	89 c6                	mov    %eax,%esi
  801c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2e:	89 04 24             	mov    %eax,(%esp)
  801c31:	e8 2e 05 00 00       	call   802164 <pageref>
  801c36:	39 c6                	cmp    %eax,%esi
  801c38:	0f 94 c0             	sete   %al
  801c3b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c3e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c44:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c47:	39 cb                	cmp    %ecx,%ebx
  801c49:	75 08                	jne    801c53 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c4b:	83 c4 2c             	add    $0x2c,%esp
  801c4e:	5b                   	pop    %ebx
  801c4f:	5e                   	pop    %esi
  801c50:	5f                   	pop    %edi
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c53:	83 f8 01             	cmp    $0x1,%eax
  801c56:	75 c1                	jne    801c19 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c58:	8b 42 58             	mov    0x58(%edx),%eax
  801c5b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c62:	00 
  801c63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c6b:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  801c72:	e8 e1 e5 ff ff       	call   800258 <cprintf>
  801c77:	eb a0                	jmp    801c19 <_pipeisclosed+0xe>

00801c79 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	57                   	push   %edi
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	83 ec 1c             	sub    $0x1c,%esp
  801c82:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c85:	89 34 24             	mov    %esi,(%esp)
  801c88:	e8 a3 f6 ff ff       	call   801330 <fd2data>
  801c8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c94:	eb 3c                	jmp    801cd2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c96:	89 da                	mov    %ebx,%edx
  801c98:	89 f0                	mov    %esi,%eax
  801c9a:	e8 6c ff ff ff       	call   801c0b <_pipeisclosed>
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	75 38                	jne    801cdb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ca3:	e8 2e ef ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ca8:	8b 43 04             	mov    0x4(%ebx),%eax
  801cab:	8b 13                	mov    (%ebx),%edx
  801cad:	83 c2 20             	add    $0x20,%edx
  801cb0:	39 d0                	cmp    %edx,%eax
  801cb2:	73 e2                	jae    801c96 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801cba:	89 c2                	mov    %eax,%edx
  801cbc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801cc2:	79 05                	jns    801cc9 <devpipe_write+0x50>
  801cc4:	4a                   	dec    %edx
  801cc5:	83 ca e0             	or     $0xffffffe0,%edx
  801cc8:	42                   	inc    %edx
  801cc9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ccd:	40                   	inc    %eax
  801cce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd1:	47                   	inc    %edi
  801cd2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cd5:	75 d1                	jne    801ca8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cd7:	89 f8                	mov    %edi,%eax
  801cd9:	eb 05                	jmp    801ce0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	57                   	push   %edi
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	83 ec 1c             	sub    $0x1c,%esp
  801cf1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cf4:	89 3c 24             	mov    %edi,(%esp)
  801cf7:	e8 34 f6 ff ff       	call   801330 <fd2data>
  801cfc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfe:	be 00 00 00 00       	mov    $0x0,%esi
  801d03:	eb 3a                	jmp    801d3f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d05:	85 f6                	test   %esi,%esi
  801d07:	74 04                	je     801d0d <devpipe_read+0x25>
				return i;
  801d09:	89 f0                	mov    %esi,%eax
  801d0b:	eb 40                	jmp    801d4d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d0d:	89 da                	mov    %ebx,%edx
  801d0f:	89 f8                	mov    %edi,%eax
  801d11:	e8 f5 fe ff ff       	call   801c0b <_pipeisclosed>
  801d16:	85 c0                	test   %eax,%eax
  801d18:	75 2e                	jne    801d48 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d1a:	e8 b7 ee ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d1f:	8b 03                	mov    (%ebx),%eax
  801d21:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d24:	74 df                	je     801d05 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d26:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d2b:	79 05                	jns    801d32 <devpipe_read+0x4a>
  801d2d:	48                   	dec    %eax
  801d2e:	83 c8 e0             	or     $0xffffffe0,%eax
  801d31:	40                   	inc    %eax
  801d32:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d39:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d3c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d3e:	46                   	inc    %esi
  801d3f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d42:	75 db                	jne    801d1f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d44:	89 f0                	mov    %esi,%eax
  801d46:	eb 05                	jmp    801d4d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d48:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d4d:	83 c4 1c             	add    $0x1c,%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5e                   	pop    %esi
  801d52:	5f                   	pop    %edi
  801d53:	5d                   	pop    %ebp
  801d54:	c3                   	ret    

00801d55 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	57                   	push   %edi
  801d59:	56                   	push   %esi
  801d5a:	53                   	push   %ebx
  801d5b:	83 ec 3c             	sub    $0x3c,%esp
  801d5e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d64:	89 04 24             	mov    %eax,(%esp)
  801d67:	e8 df f5 ff ff       	call   80134b <fd_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	0f 88 45 01 00 00    	js     801ebb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d7d:	00 
  801d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d8c:	e8 64 ee ff ff       	call   800bf5 <sys_page_alloc>
  801d91:	89 c3                	mov    %eax,%ebx
  801d93:	85 c0                	test   %eax,%eax
  801d95:	0f 88 20 01 00 00    	js     801ebb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d9b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	e8 a5 f5 ff ff       	call   80134b <fd_alloc>
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	85 c0                	test   %eax,%eax
  801daa:	0f 88 f8 00 00 00    	js     801ea8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801db7:	00 
  801db8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc6:	e8 2a ee ff ff       	call   800bf5 <sys_page_alloc>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	0f 88 d3 00 00 00    	js     801ea8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd8:	89 04 24             	mov    %eax,(%esp)
  801ddb:	e8 50 f5 ff ff       	call   801330 <fd2data>
  801de0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801de9:	00 
  801dea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df5:	e8 fb ed ff ff       	call   800bf5 <sys_page_alloc>
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	0f 88 91 00 00 00    	js     801e95 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e07:	89 04 24             	mov    %eax,(%esp)
  801e0a:	e8 21 f5 ff ff       	call   801330 <fd2data>
  801e0f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e16:	00 
  801e17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e22:	00 
  801e23:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2e:	e8 16 ee ff ff       	call   800c49 <sys_page_map>
  801e33:	89 c3                	mov    %eax,%ebx
  801e35:	85 c0                	test   %eax,%eax
  801e37:	78 4c                	js     801e85 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e42:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e47:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e57:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e5c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e66:	89 04 24             	mov    %eax,(%esp)
  801e69:	e8 b2 f4 ff ff       	call   801320 <fd2num>
  801e6e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e70:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e73:	89 04 24             	mov    %eax,(%esp)
  801e76:	e8 a5 f4 ff ff       	call   801320 <fd2num>
  801e7b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e83:	eb 36                	jmp    801ebb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e85:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e90:	e8 07 ee ff ff       	call   800c9c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e95:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea3:	e8 f4 ed ff ff       	call   800c9c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eaf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb6:	e8 e1 ed ff ff       	call   800c9c <sys_page_unmap>
    err:
	return r;
}
  801ebb:	89 d8                	mov    %ebx,%eax
  801ebd:	83 c4 3c             	add    $0x3c,%esp
  801ec0:	5b                   	pop    %ebx
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    

00801ec5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ecb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed5:	89 04 24             	mov    %eax,(%esp)
  801ed8:	e8 c1 f4 ff ff       	call   80139e <fd_lookup>
  801edd:	85 c0                	test   %eax,%eax
  801edf:	78 15                	js     801ef6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee4:	89 04 24             	mov    %eax,(%esp)
  801ee7:	e8 44 f4 ff ff       	call   801330 <fd2data>
	return _pipeisclosed(fd, p);
  801eec:	89 c2                	mov    %eax,%edx
  801eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef1:	e8 15 fd ff ff       	call   801c0b <_pipeisclosed>
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    

00801f02 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f08:	c7 44 24 04 b0 29 80 	movl   $0x8029b0,0x4(%esp)
  801f0f:	00 
  801f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f13:	89 04 24             	mov    %eax,(%esp)
  801f16:	e8 e8 e8 ff ff       	call   800803 <strcpy>
	return 0;
}
  801f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f20:	c9                   	leave  
  801f21:	c3                   	ret    

00801f22 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	57                   	push   %edi
  801f26:	56                   	push   %esi
  801f27:	53                   	push   %ebx
  801f28:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f2e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f33:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f39:	eb 30                	jmp    801f6b <devcons_write+0x49>
		m = n - tot;
  801f3b:	8b 75 10             	mov    0x10(%ebp),%esi
  801f3e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f40:	83 fe 7f             	cmp    $0x7f,%esi
  801f43:	76 05                	jbe    801f4a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f45:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f4a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f4e:	03 45 0c             	add    0xc(%ebp),%eax
  801f51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f55:	89 3c 24             	mov    %edi,(%esp)
  801f58:	e8 1f ea ff ff       	call   80097c <memmove>
		sys_cputs(buf, m);
  801f5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f61:	89 3c 24             	mov    %edi,(%esp)
  801f64:	e8 bf eb ff ff       	call   800b28 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f69:	01 f3                	add    %esi,%ebx
  801f6b:	89 d8                	mov    %ebx,%eax
  801f6d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f70:	72 c9                	jb     801f3b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f72:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5e                   	pop    %esi
  801f7a:	5f                   	pop    %edi
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    

00801f7d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f87:	75 07                	jne    801f90 <devcons_read+0x13>
  801f89:	eb 25                	jmp    801fb0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f8b:	e8 46 ec ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f90:	e8 b1 eb ff ff       	call   800b46 <sys_cgetc>
  801f95:	85 c0                	test   %eax,%eax
  801f97:	74 f2                	je     801f8b <devcons_read+0xe>
  801f99:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 1d                	js     801fbc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f9f:	83 f8 04             	cmp    $0x4,%eax
  801fa2:	74 13                	je     801fb7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa7:	88 10                	mov    %dl,(%eax)
	return 1;
  801fa9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fae:	eb 0c                	jmp    801fbc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb5:	eb 05                	jmp    801fbc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    

00801fbe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fd1:	00 
  801fd2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd5:	89 04 24             	mov    %eax,(%esp)
  801fd8:	e8 4b eb ff ff       	call   800b28 <sys_cputs>
}
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <getchar>:

int
getchar(void)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fe5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801fec:	00 
  801fed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ffb:	e8 3a f6 ff ff       	call   80163a <read>
	if (r < 0)
  802000:	85 c0                	test   %eax,%eax
  802002:	78 0f                	js     802013 <getchar+0x34>
		return r;
	if (r < 1)
  802004:	85 c0                	test   %eax,%eax
  802006:	7e 06                	jle    80200e <getchar+0x2f>
		return -E_EOF;
	return c;
  802008:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80200c:	eb 05                	jmp    802013 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80200e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802013:	c9                   	leave  
  802014:	c3                   	ret    

00802015 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80201b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802022:	8b 45 08             	mov    0x8(%ebp),%eax
  802025:	89 04 24             	mov    %eax,(%esp)
  802028:	e8 71 f3 ff ff       	call   80139e <fd_lookup>
  80202d:	85 c0                	test   %eax,%eax
  80202f:	78 11                	js     802042 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802031:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802034:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80203a:	39 10                	cmp    %edx,(%eax)
  80203c:	0f 94 c0             	sete   %al
  80203f:	0f b6 c0             	movzbl %al,%eax
}
  802042:	c9                   	leave  
  802043:	c3                   	ret    

00802044 <opencons>:

int
opencons(void)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80204a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204d:	89 04 24             	mov    %eax,(%esp)
  802050:	e8 f6 f2 ff ff       	call   80134b <fd_alloc>
  802055:	85 c0                	test   %eax,%eax
  802057:	78 3c                	js     802095 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802059:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802060:	00 
  802061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802064:	89 44 24 04          	mov    %eax,0x4(%esp)
  802068:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206f:	e8 81 eb ff ff       	call   800bf5 <sys_page_alloc>
  802074:	85 c0                	test   %eax,%eax
  802076:	78 1d                	js     802095 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802078:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80207e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802081:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802086:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80208d:	89 04 24             	mov    %eax,(%esp)
  802090:	e8 8b f2 ff ff       	call   801320 <fd2num>
}
  802095:	c9                   	leave  
  802096:	c3                   	ret    
	...

00802098 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	56                   	push   %esi
  80209c:	53                   	push   %ebx
  80209d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8020a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020a3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8020a9:	e8 09 eb ff ff       	call   800bb7 <sys_getenvid>
  8020ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8020b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c4:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  8020cb:	e8 88 e1 ff ff       	call   800258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d7:	89 04 24             	mov    %eax,(%esp)
  8020da:	e8 18 e1 ff ff       	call   8001f7 <vcprintf>
	cprintf("\n");
  8020df:	c7 04 24 a9 29 80 00 	movl   $0x8029a9,(%esp)
  8020e6:	e8 6d e1 ff ff       	call   800258 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020eb:	cc                   	int3   
  8020ec:	eb fd                	jmp    8020eb <_panic+0x53>
	...

008020f0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020f6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020fd:	75 32                	jne    802131 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8020ff:	e8 b3 ea ff ff       	call   800bb7 <sys_getenvid>
  802104:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  80210b:	00 
  80210c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802113:	ee 
  802114:	89 04 24             	mov    %eax,(%esp)
  802117:	e8 d9 ea ff ff       	call   800bf5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  80211c:	e8 96 ea ff ff       	call   800bb7 <sys_getenvid>
  802121:	c7 44 24 04 3c 21 80 	movl   $0x80213c,0x4(%esp)
  802128:	00 
  802129:	89 04 24             	mov    %eax,(%esp)
  80212c:	e8 64 ec ff ff       	call   800d95 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802131:	8b 45 08             	mov    0x8(%ebp),%eax
  802134:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802139:	c9                   	leave  
  80213a:	c3                   	ret    
	...

0080213c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80213c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80213d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802142:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802144:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  802147:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  80214b:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  80214e:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  802153:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  802157:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  80215a:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  80215b:	83 c4 04             	add    $0x4,%esp
	popfl
  80215e:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  80215f:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  802160:	c3                   	ret    
  802161:	00 00                	add    %al,(%eax)
	...

00802164 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80216a:	89 c2                	mov    %eax,%edx
  80216c:	c1 ea 16             	shr    $0x16,%edx
  80216f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802176:	f6 c2 01             	test   $0x1,%dl
  802179:	74 1e                	je     802199 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80217b:	c1 e8 0c             	shr    $0xc,%eax
  80217e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802185:	a8 01                	test   $0x1,%al
  802187:	74 17                	je     8021a0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802189:	c1 e8 0c             	shr    $0xc,%eax
  80218c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802193:	ef 
  802194:	0f b7 c0             	movzwl %ax,%eax
  802197:	eb 0c                	jmp    8021a5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
  80219e:	eb 05                	jmp    8021a5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8021a0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    
	...

008021a8 <__udivdi3>:
  8021a8:	55                   	push   %ebp
  8021a9:	57                   	push   %edi
  8021aa:	56                   	push   %esi
  8021ab:	83 ec 10             	sub    $0x10,%esp
  8021ae:	8b 74 24 20          	mov    0x20(%esp),%esi
  8021b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8021be:	89 cd                	mov    %ecx,%ebp
  8021c0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	75 2c                	jne    8021f4 <__udivdi3+0x4c>
  8021c8:	39 f9                	cmp    %edi,%ecx
  8021ca:	77 68                	ja     802234 <__udivdi3+0x8c>
  8021cc:	85 c9                	test   %ecx,%ecx
  8021ce:	75 0b                	jne    8021db <__udivdi3+0x33>
  8021d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d5:	31 d2                	xor    %edx,%edx
  8021d7:	f7 f1                	div    %ecx
  8021d9:	89 c1                	mov    %eax,%ecx
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	89 f8                	mov    %edi,%eax
  8021df:	f7 f1                	div    %ecx
  8021e1:	89 c7                	mov    %eax,%edi
  8021e3:	89 f0                	mov    %esi,%eax
  8021e5:	f7 f1                	div    %ecx
  8021e7:	89 c6                	mov    %eax,%esi
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	89 fa                	mov    %edi,%edx
  8021ed:	83 c4 10             	add    $0x10,%esp
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
  8021f4:	39 f8                	cmp    %edi,%eax
  8021f6:	77 2c                	ja     802224 <__udivdi3+0x7c>
  8021f8:	0f bd f0             	bsr    %eax,%esi
  8021fb:	83 f6 1f             	xor    $0x1f,%esi
  8021fe:	75 4c                	jne    80224c <__udivdi3+0xa4>
  802200:	39 f8                	cmp    %edi,%eax
  802202:	bf 00 00 00 00       	mov    $0x0,%edi
  802207:	72 0a                	jb     802213 <__udivdi3+0x6b>
  802209:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80220d:	0f 87 ad 00 00 00    	ja     8022c0 <__udivdi3+0x118>
  802213:	be 01 00 00 00       	mov    $0x1,%esi
  802218:	89 f0                	mov    %esi,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 10             	add    $0x10,%esp
  80221f:	5e                   	pop    %esi
  802220:	5f                   	pop    %edi
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    
  802223:	90                   	nop
  802224:	31 ff                	xor    %edi,%edi
  802226:	31 f6                	xor    %esi,%esi
  802228:	89 f0                	mov    %esi,%eax
  80222a:	89 fa                	mov    %edi,%edx
  80222c:	83 c4 10             	add    $0x10,%esp
  80222f:	5e                   	pop    %esi
  802230:	5f                   	pop    %edi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    
  802233:	90                   	nop
  802234:	89 fa                	mov    %edi,%edx
  802236:	89 f0                	mov    %esi,%eax
  802238:	f7 f1                	div    %ecx
  80223a:	89 c6                	mov    %eax,%esi
  80223c:	31 ff                	xor    %edi,%edi
  80223e:	89 f0                	mov    %esi,%eax
  802240:	89 fa                	mov    %edi,%edx
  802242:	83 c4 10             	add    $0x10,%esp
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d 76 00             	lea    0x0(%esi),%esi
  80224c:	89 f1                	mov    %esi,%ecx
  80224e:	d3 e0                	shl    %cl,%eax
  802250:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802254:	b8 20 00 00 00       	mov    $0x20,%eax
  802259:	29 f0                	sub    %esi,%eax
  80225b:	89 ea                	mov    %ebp,%edx
  80225d:	88 c1                	mov    %al,%cl
  80225f:	d3 ea                	shr    %cl,%edx
  802261:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802265:	09 ca                	or     %ecx,%edx
  802267:	89 54 24 08          	mov    %edx,0x8(%esp)
  80226b:	89 f1                	mov    %esi,%ecx
  80226d:	d3 e5                	shl    %cl,%ebp
  80226f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802273:	89 fd                	mov    %edi,%ebp
  802275:	88 c1                	mov    %al,%cl
  802277:	d3 ed                	shr    %cl,%ebp
  802279:	89 fa                	mov    %edi,%edx
  80227b:	89 f1                	mov    %esi,%ecx
  80227d:	d3 e2                	shl    %cl,%edx
  80227f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802283:	88 c1                	mov    %al,%cl
  802285:	d3 ef                	shr    %cl,%edi
  802287:	09 d7                	or     %edx,%edi
  802289:	89 f8                	mov    %edi,%eax
  80228b:	89 ea                	mov    %ebp,%edx
  80228d:	f7 74 24 08          	divl   0x8(%esp)
  802291:	89 d1                	mov    %edx,%ecx
  802293:	89 c7                	mov    %eax,%edi
  802295:	f7 64 24 0c          	mull   0xc(%esp)
  802299:	39 d1                	cmp    %edx,%ecx
  80229b:	72 17                	jb     8022b4 <__udivdi3+0x10c>
  80229d:	74 09                	je     8022a8 <__udivdi3+0x100>
  80229f:	89 fe                	mov    %edi,%esi
  8022a1:	31 ff                	xor    %edi,%edi
  8022a3:	e9 41 ff ff ff       	jmp    8021e9 <__udivdi3+0x41>
  8022a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022ac:	89 f1                	mov    %esi,%ecx
  8022ae:	d3 e2                	shl    %cl,%edx
  8022b0:	39 c2                	cmp    %eax,%edx
  8022b2:	73 eb                	jae    80229f <__udivdi3+0xf7>
  8022b4:	8d 77 ff             	lea    -0x1(%edi),%esi
  8022b7:	31 ff                	xor    %edi,%edi
  8022b9:	e9 2b ff ff ff       	jmp    8021e9 <__udivdi3+0x41>
  8022be:	66 90                	xchg   %ax,%ax
  8022c0:	31 f6                	xor    %esi,%esi
  8022c2:	e9 22 ff ff ff       	jmp    8021e9 <__udivdi3+0x41>
	...

008022c8 <__umoddi3>:
  8022c8:	55                   	push   %ebp
  8022c9:	57                   	push   %edi
  8022ca:	56                   	push   %esi
  8022cb:	83 ec 20             	sub    $0x20,%esp
  8022ce:	8b 44 24 30          	mov    0x30(%esp),%eax
  8022d2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8022d6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8022da:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022e2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8022e6:	89 c7                	mov    %eax,%edi
  8022e8:	89 f2                	mov    %esi,%edx
  8022ea:	85 ed                	test   %ebp,%ebp
  8022ec:	75 16                	jne    802304 <__umoddi3+0x3c>
  8022ee:	39 f1                	cmp    %esi,%ecx
  8022f0:	0f 86 a6 00 00 00    	jbe    80239c <__umoddi3+0xd4>
  8022f6:	f7 f1                	div    %ecx
  8022f8:	89 d0                	mov    %edx,%eax
  8022fa:	31 d2                	xor    %edx,%edx
  8022fc:	83 c4 20             	add    $0x20,%esp
  8022ff:	5e                   	pop    %esi
  802300:	5f                   	pop    %edi
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    
  802303:	90                   	nop
  802304:	39 f5                	cmp    %esi,%ebp
  802306:	0f 87 ac 00 00 00    	ja     8023b8 <__umoddi3+0xf0>
  80230c:	0f bd c5             	bsr    %ebp,%eax
  80230f:	83 f0 1f             	xor    $0x1f,%eax
  802312:	89 44 24 10          	mov    %eax,0x10(%esp)
  802316:	0f 84 a8 00 00 00    	je     8023c4 <__umoddi3+0xfc>
  80231c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802320:	d3 e5                	shl    %cl,%ebp
  802322:	bf 20 00 00 00       	mov    $0x20,%edi
  802327:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80232b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80232f:	89 f9                	mov    %edi,%ecx
  802331:	d3 e8                	shr    %cl,%eax
  802333:	09 e8                	or     %ebp,%eax
  802335:	89 44 24 18          	mov    %eax,0x18(%esp)
  802339:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80233d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802341:	d3 e0                	shl    %cl,%eax
  802343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802347:	89 f2                	mov    %esi,%edx
  802349:	d3 e2                	shl    %cl,%edx
  80234b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80234f:	d3 e0                	shl    %cl,%eax
  802351:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802355:	8b 44 24 14          	mov    0x14(%esp),%eax
  802359:	89 f9                	mov    %edi,%ecx
  80235b:	d3 e8                	shr    %cl,%eax
  80235d:	09 d0                	or     %edx,%eax
  80235f:	d3 ee                	shr    %cl,%esi
  802361:	89 f2                	mov    %esi,%edx
  802363:	f7 74 24 18          	divl   0x18(%esp)
  802367:	89 d6                	mov    %edx,%esi
  802369:	f7 64 24 0c          	mull   0xc(%esp)
  80236d:	89 c5                	mov    %eax,%ebp
  80236f:	89 d1                	mov    %edx,%ecx
  802371:	39 d6                	cmp    %edx,%esi
  802373:	72 67                	jb     8023dc <__umoddi3+0x114>
  802375:	74 75                	je     8023ec <__umoddi3+0x124>
  802377:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80237b:	29 e8                	sub    %ebp,%eax
  80237d:	19 ce                	sbb    %ecx,%esi
  80237f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802383:	d3 e8                	shr    %cl,%eax
  802385:	89 f2                	mov    %esi,%edx
  802387:	89 f9                	mov    %edi,%ecx
  802389:	d3 e2                	shl    %cl,%edx
  80238b:	09 d0                	or     %edx,%eax
  80238d:	89 f2                	mov    %esi,%edx
  80238f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802393:	d3 ea                	shr    %cl,%edx
  802395:	83 c4 20             	add    $0x20,%esp
  802398:	5e                   	pop    %esi
  802399:	5f                   	pop    %edi
  80239a:	5d                   	pop    %ebp
  80239b:	c3                   	ret    
  80239c:	85 c9                	test   %ecx,%ecx
  80239e:	75 0b                	jne    8023ab <__umoddi3+0xe3>
  8023a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a5:	31 d2                	xor    %edx,%edx
  8023a7:	f7 f1                	div    %ecx
  8023a9:	89 c1                	mov    %eax,%ecx
  8023ab:	89 f0                	mov    %esi,%eax
  8023ad:	31 d2                	xor    %edx,%edx
  8023af:	f7 f1                	div    %ecx
  8023b1:	89 f8                	mov    %edi,%eax
  8023b3:	e9 3e ff ff ff       	jmp    8022f6 <__umoddi3+0x2e>
  8023b8:	89 f2                	mov    %esi,%edx
  8023ba:	83 c4 20             	add    $0x20,%esp
  8023bd:	5e                   	pop    %esi
  8023be:	5f                   	pop    %edi
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    
  8023c1:	8d 76 00             	lea    0x0(%esi),%esi
  8023c4:	39 f5                	cmp    %esi,%ebp
  8023c6:	72 04                	jb     8023cc <__umoddi3+0x104>
  8023c8:	39 f9                	cmp    %edi,%ecx
  8023ca:	77 06                	ja     8023d2 <__umoddi3+0x10a>
  8023cc:	89 f2                	mov    %esi,%edx
  8023ce:	29 cf                	sub    %ecx,%edi
  8023d0:	19 ea                	sbb    %ebp,%edx
  8023d2:	89 f8                	mov    %edi,%eax
  8023d4:	83 c4 20             	add    $0x20,%esp
  8023d7:	5e                   	pop    %esi
  8023d8:	5f                   	pop    %edi
  8023d9:	5d                   	pop    %ebp
  8023da:	c3                   	ret    
  8023db:	90                   	nop
  8023dc:	89 d1                	mov    %edx,%ecx
  8023de:	89 c5                	mov    %eax,%ebp
  8023e0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8023e4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8023e8:	eb 8d                	jmp    802377 <__umoddi3+0xaf>
  8023ea:	66 90                	xchg   %ax,%ax
  8023ec:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8023f0:	72 ea                	jb     8023dc <__umoddi3+0x114>
  8023f2:	89 f1                	mov    %esi,%ecx
  8023f4:	eb 81                	jmp    802377 <__umoddi3+0xaf>
