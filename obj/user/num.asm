
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 8f 01 00 00       	call   8001c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  800043:	8d 5d e7             	lea    -0x19(%ebp),%ebx
  800046:	eb 7f                	jmp    8000c7 <num+0x93>
		if (bol) {
  800048:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004f:	74 25                	je     800076 <num+0x42>
			printf("%5d ", ++line);
  800051:	a1 00 40 80 00       	mov    0x804000,%eax
  800056:	40                   	inc    %eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800060:	c7 04 24 a0 21 80 00 	movl   $0x8021a0,(%esp)
  800067:	e8 39 18 00 00       	call   8018a5 <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 97 12 00 00       	call   801325 <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 24                	je     8000b7 <num+0x83>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80009b:	c7 44 24 08 a5 21 80 	movl   $0x8021a5,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000aa:	00 
  8000ab:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  8000b2:	e8 79 01 00 00       	call   800230 <_panic>
		if (c == '\n')
  8000b7:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8000bb:	75 0a                	jne    8000c7 <num+0x93>
			bol = 1;
  8000bd:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c4:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000ce:	00 
  8000cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d3:	89 34 24             	mov    %esi,(%esp)
  8000d6:	e8 6f 11 00 00       	call   80124a <read>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	0f 8f 65 ff ff ff    	jg     800048 <num+0x14>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	79 24                	jns    80010b <num+0xd7>
		panic("error reading %s: %e", s, n);
  8000e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000ef:	c7 44 24 08 cb 21 80 	movl   $0x8021cb,0x8(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8000fe:	00 
  8000ff:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  800106:	e8 25 01 00 00       	call   800230 <_panic>
}
  80010b:	83 c4 3c             	add    $0x3c,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <umain>:

void
umain(int argc, char **argv)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 3c             	sub    $0x3c,%esp
	int f, i;

	binaryname = "num";
  80011c:	c7 05 04 30 80 00 e0 	movl   $0x8021e0,0x803004
  800123:	21 80 00 
	if (argc == 1)
  800126:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012a:	74 0d                	je     800139 <umain+0x26>
	if (n < 0)
		panic("error reading %s: %e", s, n);
}

void
umain(int argc, char **argv)
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80012f:	83 c3 04             	add    $0x4,%ebx
  800132:	bf 01 00 00 00       	mov    $0x1,%edi
  800137:	eb 74                	jmp    8001ad <umain+0x9a>
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800139:	c7 44 24 04 e4 21 80 	movl   $0x8021e4,0x4(%esp)
  800140:	00 
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <num>
  80014d:	eb 63                	jmp    8001b2 <umain+0x9f>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80014f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800159:	00 
  80015a:	8b 03                	mov    (%ebx),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 8d 15 00 00       	call   8016f1 <open>
  800164:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	79 29                	jns    800193 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800171:	8b 02                	mov    (%edx),%eax
  800173:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800177:	c7 44 24 08 ec 21 80 	movl   $0x8021ec,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  80018e:	e8 9d 00 00 00       	call   800230 <_panic>
			else {
				num(f, argv[i]);
  800193:	8b 03                	mov    (%ebx),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <num>
				close(f);
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 3d 0f 00 00       	call   8010e6 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8001a9:	47                   	inc    %edi
  8001aa:	83 c3 04             	add    $0x4,%ebx
  8001ad:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001b0:	7c 9d                	jl     80014f <umain+0x3c>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  8001b2:	e8 5d 00 00 00       	call   800214 <exit>
}
  8001b7:	83 c4 3c             	add    $0x3c,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    
	...

008001c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 10             	sub    $0x10,%esp
  8001c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8001ce:	e8 b4 0a 00 00       	call   800c87 <sys_getenvid>
  8001d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001df:	c1 e0 07             	shl    $0x7,%eax
  8001e2:	29 d0                	sub    %edx,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 f6                	test   %esi,%esi
  8001f0:	7e 07                	jle    8001f9 <libmain+0x39>
		binaryname = argv[0];
  8001f2:	8b 03                	mov    (%ebx),%eax
  8001f4:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001fd:	89 34 24             	mov    %esi,(%esp)
  800200:	e8 0e ff ff ff       	call   800113 <umain>

	// exit gracefully
	exit();
  800205:	e8 0a 00 00 00       	call   800214 <exit>
}
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    
  800211:	00 00                	add    %al,(%eax)
	...

00800214 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80021a:	e8 f8 0e 00 00       	call   801117 <close_all>
	sys_env_destroy(0);
  80021f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800226:	e8 0a 0a 00 00       	call   800c35 <sys_env_destroy>
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800238:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023b:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800241:	e8 41 0a 00 00       	call   800c87 <sys_getenvid>
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 54 24 10          	mov    %edx,0x10(%esp)
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	c7 04 24 08 22 80 00 	movl   $0x802208,(%esp)
  800263:	e8 c0 00 00 00       	call   800328 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800268:	89 74 24 04          	mov    %esi,0x4(%esp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 50 00 00 00       	call   8002c7 <vcprintf>
	cprintf("\n");
  800277:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80027e:	e8 a5 00 00 00       	call   800328 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800283:	cc                   	int3   
  800284:	eb fd                	jmp    800283 <_panic+0x53>
	...

00800288 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	53                   	push   %ebx
  80028c:	83 ec 14             	sub    $0x14,%esp
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800292:	8b 03                	mov    (%ebx),%eax
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029b:	40                   	inc    %eax
  80029c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a3:	75 19                	jne    8002be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002ac:	00 
  8002ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 40 09 00 00       	call   800bf8 <sys_cputs>
		b->idx = 0;
  8002b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002be:	ff 43 04             	incl   0x4(%ebx)
}
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d7:	00 00 00 
	b.cnt = 0;
  8002da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fc:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  800303:	e8 82 01 00 00       	call   80048a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800308:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 d8 08 00 00       	call   800bf8 <sys_cputs>

	return b.cnt;
}
  800320:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 87 ff ff ff       	call   8002c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    
	...

00800344 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 3c             	sub    $0x3c,%esp
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	89 d7                	mov    %edx,%edi
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800361:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800364:	85 c0                	test   %eax,%eax
  800366:	75 08                	jne    800370 <printnum+0x2c>
  800368:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036e:	77 57                	ja     8003c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800370:	89 74 24 10          	mov    %esi,0x10(%esp)
  800374:	4b                   	dec    %ebx
  800375:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800384:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800388:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038f:	00 
  800390:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	e8 9a 1b 00 00       	call   801f3c <__udivdi3>
  8003a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b1:	89 fa                	mov    %edi,%edx
  8003b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b6:	e8 89 ff ff ff       	call   800344 <printnum>
  8003bb:	eb 0f                	jmp    8003cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c1:	89 34 24             	mov    %esi,(%esp)
  8003c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c7:	4b                   	dec    %ebx
  8003c8:	85 db                	test   %ebx,%ebx
  8003ca:	7f f1                	jg     8003bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e2:	00 
  8003e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	e8 67 1c 00 00       	call   80205c <__umoddi3>
  8003f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f9:	0f be 80 2b 22 80 00 	movsbl 0x80222b(%eax),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800406:	83 c4 3c             	add    $0x3c,%esp
  800409:	5b                   	pop    %ebx
  80040a:	5e                   	pop    %esi
  80040b:	5f                   	pop    %edi
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800411:	83 fa 01             	cmp    $0x1,%edx
  800414:	7e 0e                	jle    800424 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800416:	8b 10                	mov    (%eax),%edx
  800418:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 02                	mov    (%edx),%eax
  80041f:	8b 52 04             	mov    0x4(%edx),%edx
  800422:	eb 22                	jmp    800446 <getuint+0x38>
	else if (lflag)
  800424:	85 d2                	test   %edx,%edx
  800426:	74 10                	je     800438 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800428:	8b 10                	mov    (%eax),%edx
  80042a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042d:	89 08                	mov    %ecx,(%eax)
  80042f:	8b 02                	mov    (%edx),%eax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	eb 0e                	jmp    800446 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800438:	8b 10                	mov    (%eax),%edx
  80043a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043d:	89 08                	mov    %ecx,(%eax)
  80043f:	8b 02                	mov    (%edx),%eax
  800441:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800451:	8b 10                	mov    (%eax),%edx
  800453:	3b 50 04             	cmp    0x4(%eax),%edx
  800456:	73 08                	jae    800460 <sprintputch+0x18>
		*b->buf++ = ch;
  800458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045b:	88 0a                	mov    %cl,(%edx)
  80045d:	42                   	inc    %edx
  80045e:	89 10                	mov    %edx,(%eax)
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046f:	8b 45 10             	mov    0x10(%ebp),%eax
  800472:	89 44 24 08          	mov    %eax,0x8(%esp)
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 02 00 00 00       	call   80048a <vprintfmt>
	va_end(ap);
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	57                   	push   %edi
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
  800490:	83 ec 4c             	sub    $0x4c,%esp
  800493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800496:	8b 75 10             	mov    0x10(%ebp),%esi
  800499:	eb 12                	jmp    8004ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049b:	85 c0                	test   %eax,%eax
  80049d:	0f 84 6b 03 00 00    	je     80080e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ad:	0f b6 06             	movzbl (%esi),%eax
  8004b0:	46                   	inc    %esi
  8004b1:	83 f8 25             	cmp    $0x25,%eax
  8004b4:	75 e5                	jne    80049b <vprintfmt+0x11>
  8004b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d2:	eb 26                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004db:	eb 1d                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e4:	eb 14                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	0f b6 06             	movzbl (%esi),%eax
  8004fd:	8d 56 01             	lea    0x1(%esi),%edx
  800500:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800503:	8a 16                	mov    (%esi),%dl
  800505:	83 ea 23             	sub    $0x23,%edx
  800508:	80 fa 55             	cmp    $0x55,%dl
  80050b:	0f 87 e1 02 00 00    	ja     8007f2 <vprintfmt+0x368>
  800511:	0f b6 d2             	movzbl %dl,%edx
  800514:	ff 24 95 60 23 80 00 	jmp    *0x802360(,%edx,4)
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800523:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800526:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80052a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80052d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800530:	83 fa 09             	cmp    $0x9,%edx
  800533:	77 2a                	ja     80055f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800535:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800536:	eb eb                	jmp    800523 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800546:	eb 17                	jmp    80055f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800548:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054c:	78 98                	js     8004e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800551:	eb a7                	jmp    8004fa <vprintfmt+0x70>
  800553:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800556:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80055d:	eb 9b                	jmp    8004fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80055f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800563:	79 95                	jns    8004fa <vprintfmt+0x70>
  800565:	eb 8b                	jmp    8004f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800567:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056b:	eb 8d                	jmp    8004fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800585:	e9 23 ff ff ff       	jmp    8004ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	79 02                	jns    80059b <vprintfmt+0x111>
  800599:	f7 d8                	neg    %eax
  80059b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059d:	83 f8 0f             	cmp    $0xf,%eax
  8005a0:	7f 0b                	jg     8005ad <vprintfmt+0x123>
  8005a2:	8b 04 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	75 23                	jne    8005d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b1:	c7 44 24 08 43 22 80 	movl   $0x802243,0x8(%esp)
  8005b8:	00 
  8005b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 9a fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cb:	e9 dd fe ff ff       	jmp    8004ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d4:	c7 44 24 08 1e 26 80 	movl   $0x80261e,0x8(%esp)
  8005db:	00 
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e3:	89 14 24             	mov    %edx,(%esp)
  8005e6:	e8 77 fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ee:	e9 ba fe ff ff       	jmp    8004ad <vprintfmt+0x23>
  8005f3:	89 f9                	mov    %edi,%ecx
  8005f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 30                	mov    (%eax),%esi
  800606:	85 f6                	test   %esi,%esi
  800608:	75 05                	jne    80060f <vprintfmt+0x185>
				p = "(null)";
  80060a:	be 3c 22 80 00       	mov    $0x80223c,%esi
			if (width > 0 && padc != '-')
  80060f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800613:	0f 8e 84 00 00 00    	jle    80069d <vprintfmt+0x213>
  800619:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80061d:	74 7e                	je     80069d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	e8 8b 02 00 00       	call   8008b6 <strnlen>
  80062b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062e:	29 c2                	sub    %eax,%edx
  800630:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800633:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800637:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80063a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80063d:	89 de                	mov    %ebx,%esi
  80063f:	89 d3                	mov    %edx,%ebx
  800641:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	eb 0b                	jmp    800650 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800645:	89 74 24 04          	mov    %esi,0x4(%esp)
  800649:	89 3c 24             	mov    %edi,(%esp)
  80064c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	4b                   	dec    %ebx
  800650:	85 db                	test   %ebx,%ebx
  800652:	7f f1                	jg     800645 <vprintfmt+0x1bb>
  800654:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800657:	89 f3                	mov    %esi,%ebx
  800659:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80065c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	79 05                	jns    800668 <vprintfmt+0x1de>
  800663:	b8 00 00 00 00       	mov    $0x0,%eax
  800668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066b:	29 c2                	sub    %eax,%edx
  80066d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800670:	eb 2b                	jmp    80069d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800672:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800676:	74 18                	je     800690 <vprintfmt+0x206>
  800678:	8d 50 e0             	lea    -0x20(%eax),%edx
  80067b:	83 fa 5e             	cmp    $0x5e,%edx
  80067e:	76 10                	jbe    800690 <vprintfmt+0x206>
					putch('?', putdat);
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
  80068e:	eb 0a                	jmp    80069a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	ff 4d e4             	decl   -0x1c(%ebp)
  80069d:	0f be 06             	movsbl (%esi),%eax
  8006a0:	46                   	inc    %esi
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 21                	je     8006c6 <vprintfmt+0x23c>
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	78 c9                	js     800672 <vprintfmt+0x1e8>
  8006a9:	4f                   	dec    %edi
  8006aa:	79 c6                	jns    800672 <vprintfmt+0x1e8>
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	89 de                	mov    %ebx,%esi
  8006b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b4:	eb 18                	jmp    8006ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c3:	4b                   	dec    %ebx
  8006c4:	eb 08                	jmp    8006ce <vprintfmt+0x244>
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	89 de                	mov    %ebx,%esi
  8006cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ce:	85 db                	test   %ebx,%ebx
  8006d0:	7f e4                	jg     8006b6 <vprintfmt+0x22c>
  8006d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006da:	e9 ce fd ff ff       	jmp    8004ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7e 10                	jle    8006f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 08             	lea    0x8(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 30                	mov    (%eax),%esi
  8006ef:	8b 78 04             	mov    0x4(%eax),%edi
  8006f2:	eb 26                	jmp    80071a <vprintfmt+0x290>
	else if (lflag)
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	74 12                	je     80070a <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 30                	mov    (%eax),%esi
  800703:	89 f7                	mov    %esi,%edi
  800705:	c1 ff 1f             	sar    $0x1f,%edi
  800708:	eb 10                	jmp    80071a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 30                	mov    (%eax),%esi
  800715:	89 f7                	mov    %esi,%edi
  800717:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071a:	85 ff                	test   %edi,%edi
  80071c:	78 0a                	js     800728 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800723:	e9 8c 00 00 00       	jmp    8007b4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800733:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800736:	f7 de                	neg    %esi
  800738:	83 d7 00             	adc    $0x0,%edi
  80073b:	f7 df                	neg    %edi
			}
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	eb 70                	jmp    8007b4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 c0 fc ff ff       	call   80040e <getuint>
  80074e:	89 c6                	mov    %eax,%esi
  800750:	89 d7                	mov    %edx,%edi
			base = 10;
  800752:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800757:	eb 5b                	jmp    8007b4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800759:	89 ca                	mov    %ecx,%edx
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 ab fc ff ff       	call   80040e <getuint>
  800763:	89 c6                	mov    %eax,%esi
  800765:	89 d7                	mov    %edx,%edi
			base = 8;
  800767:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80076c:	eb 46                	jmp    8007b4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80076e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800772:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800779:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 50 04             	lea    0x4(%eax),%edx
  800790:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800793:	8b 30                	mov    (%eax),%esi
  800795:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80079f:	eb 13                	jmp    8007b4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a1:	89 ca                	mov    %ecx,%edx
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 63 fc ff ff       	call   80040e <getuint>
  8007ab:	89 c6                	mov    %eax,%esi
  8007ad:	89 d7                	mov    %edx,%edi
			base = 16;
  8007af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007b8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c7:	89 34 24             	mov    %esi,(%esp)
  8007ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ce:	89 da                	mov    %ebx,%edx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	e8 6c fb ff ff       	call   800344 <printnum>
			break;
  8007d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007db:	e9 cd fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ed:	e9 bb fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800800:	eb 01                	jmp    800803 <vprintfmt+0x379>
  800802:	4e                   	dec    %esi
  800803:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800807:	75 f9                	jne    800802 <vprintfmt+0x378>
  800809:	e9 9f fc ff ff       	jmp    8004ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80080e:	83 c4 4c             	add    $0x4c,%esp
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5f                   	pop    %edi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 28             	sub    $0x28,%esp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800822:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800825:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800829:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800833:	85 c0                	test   %eax,%eax
  800835:	74 30                	je     800867 <vsnprintf+0x51>
  800837:	85 d2                	test   %edx,%edx
  800839:	7e 33                	jle    80086e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	c7 04 24 48 04 80 00 	movl   $0x800448,(%esp)
  800857:	e8 2e fc ff ff       	call   80048a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800865:	eb 0c                	jmp    800873 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800867:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086c:	eb 05                	jmp    800873 <vsnprintf+0x5d>
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800882:	8b 45 10             	mov    0x10(%ebp),%eax
  800885:	89 44 24 08          	mov    %eax,0x8(%esp)
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 7b ff ff ff       	call   800816 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    
  80089d:	00 00                	add    %al,(%eax)
	...

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	eb 01                	jmp    8008ae <strlen+0xe>
		n++;
  8008ad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b2:	75 f9                	jne    8008ad <strlen+0xd>
		n++;
	return n;
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 01                	jmp    8008c7 <strnlen+0x11>
		n++;
  8008c6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c7:	39 d0                	cmp    %edx,%eax
  8008c9:	74 06                	je     8008d1 <strnlen+0x1b>
  8008cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cf:	75 f5                	jne    8008c6 <strnlen+0x10>
		n++;
	return n;
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008e5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e8:	42                   	inc    %edx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	75 f5                	jne    8008e2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fa:	89 1c 24             	mov    %ebx,(%esp)
  8008fd:	e8 9e ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	89 54 24 04          	mov    %edx,0x4(%esp)
  800909:	01 d8                	add    %ebx,%eax
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	e8 c0 ff ff ff       	call   8008d3 <strcpy>
	return dst;
}
  800913:	89 d8                	mov    %ebx,%eax
  800915:	83 c4 08             	add    $0x8,%esp
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800929:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092e:	eb 0c                	jmp    80093c <strncpy+0x21>
		*dst++ = *src;
  800930:	8a 1a                	mov    (%edx),%bl
  800932:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800935:	80 3a 01             	cmpb   $0x1,(%edx)
  800938:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093b:	41                   	inc    %ecx
  80093c:	39 f1                	cmp    %esi,%ecx
  80093e:	75 f0                	jne    800930 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 75 08             	mov    0x8(%ebp),%esi
  80094c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800952:	85 d2                	test   %edx,%edx
  800954:	75 0a                	jne    800960 <strlcpy+0x1c>
  800956:	89 f0                	mov    %esi,%eax
  800958:	eb 1a                	jmp    800974 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095a:	88 18                	mov    %bl,(%eax)
  80095c:	40                   	inc    %eax
  80095d:	41                   	inc    %ecx
  80095e:	eb 02                	jmp    800962 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800960:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800962:	4a                   	dec    %edx
  800963:	74 0a                	je     80096f <strlcpy+0x2b>
  800965:	8a 19                	mov    (%ecx),%bl
  800967:	84 db                	test   %bl,%bl
  800969:	75 ef                	jne    80095a <strlcpy+0x16>
  80096b:	89 c2                	mov    %eax,%edx
  80096d:	eb 02                	jmp    800971 <strlcpy+0x2d>
  80096f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800971:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800974:	29 f0                	sub    %esi,%eax
}
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800983:	eb 02                	jmp    800987 <strcmp+0xd>
		p++, q++;
  800985:	41                   	inc    %ecx
  800986:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800987:	8a 01                	mov    (%ecx),%al
  800989:	84 c0                	test   %al,%al
  80098b:	74 04                	je     800991 <strcmp+0x17>
  80098d:	3a 02                	cmp    (%edx),%al
  80098f:	74 f4                	je     800985 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 12             	movzbl (%edx),%edx
  800997:	29 d0                	sub    %edx,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009a8:	eb 03                	jmp    8009ad <strncmp+0x12>
		n--, p++, q++;
  8009aa:	4a                   	dec    %edx
  8009ab:	40                   	inc    %eax
  8009ac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	74 14                	je     8009c5 <strncmp+0x2a>
  8009b1:	8a 18                	mov    (%eax),%bl
  8009b3:	84 db                	test   %bl,%bl
  8009b5:	74 04                	je     8009bb <strncmp+0x20>
  8009b7:	3a 19                	cmp    (%ecx),%bl
  8009b9:	74 ef                	je     8009aa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 00             	movzbl (%eax),%eax
  8009be:	0f b6 11             	movzbl (%ecx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
  8009c3:	eb 05                	jmp    8009ca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009d6:	eb 05                	jmp    8009dd <strchr+0x10>
		if (*s == c)
  8009d8:	38 ca                	cmp    %cl,%dl
  8009da:	74 0c                	je     8009e8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009dc:	40                   	inc    %eax
  8009dd:	8a 10                	mov    (%eax),%dl
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	75 f5                	jne    8009d8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f3:	eb 05                	jmp    8009fa <strfind+0x10>
		if (*s == c)
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	74 07                	je     800a00 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f9:	40                   	inc    %eax
  8009fa:	8a 10                	mov    (%eax),%dl
  8009fc:	84 d2                	test   %dl,%dl
  8009fe:	75 f5                	jne    8009f5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 30                	je     800a45 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 25                	jne    800a42 <memset+0x40>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 20                	jne    800a42 <memset+0x40>
		c &= 0xFF;
  800a22:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a25:	89 d3                	mov    %edx,%ebx
  800a27:	c1 e3 08             	shl    $0x8,%ebx
  800a2a:	89 d6                	mov    %edx,%esi
  800a2c:	c1 e6 18             	shl    $0x18,%esi
  800a2f:	89 d0                	mov    %edx,%eax
  800a31:	c1 e0 10             	shl    $0x10,%eax
  800a34:	09 f0                	or     %esi,%eax
  800a36:	09 d0                	or     %edx,%eax
  800a38:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a3d:	fc                   	cld    
  800a3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a40:	eb 03                	jmp    800a45 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a42:	fc                   	cld    
  800a43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a45:	89 f8                	mov    %edi,%eax
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 34                	jae    800a92 <memmove+0x46>
  800a5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a61:	39 d0                	cmp    %edx,%eax
  800a63:	73 2d                	jae    800a92 <memmove+0x46>
		s += n;
		d += n;
  800a65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a68:	f6 c2 03             	test   $0x3,%dl
  800a6b:	75 1b                	jne    800a88 <memmove+0x3c>
  800a6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a73:	75 13                	jne    800a88 <memmove+0x3c>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 0e                	jne    800a88 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7a:	83 ef 04             	sub    $0x4,%edi
  800a7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a80:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a83:	fd                   	std    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb 07                	jmp    800a8f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a88:	4f                   	dec    %edi
  800a89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8c:	fd                   	std    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8f:	fc                   	cld    
  800a90:	eb 20                	jmp    800ab2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a98:	75 13                	jne    800aad <memmove+0x61>
  800a9a:	a8 03                	test   $0x3,%al
  800a9c:	75 0f                	jne    800aad <memmove+0x61>
  800a9e:	f6 c1 03             	test   $0x3,%cl
  800aa1:	75 0a                	jne    800aad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aab:	eb 05                	jmp    800ab2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aad:	89 c7                	mov    %eax,%edi
  800aaf:	fc                   	cld    
  800ab0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	89 04 24             	mov    %eax,(%esp)
  800ad0:	e8 77 ff ff ff       	call   800a4c <memmove>
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	eb 16                	jmp    800b03 <memcmp+0x2c>
		if (*s1 != *s2)
  800aed:	8a 04 17             	mov    (%edi,%edx,1),%al
  800af0:	42                   	inc    %edx
  800af1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800af5:	38 c8                	cmp    %cl,%al
  800af7:	74 0a                	je     800b03 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 c9             	movzbl %cl,%ecx
  800aff:	29 c8                	sub    %ecx,%eax
  800b01:	eb 09                	jmp    800b0c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b03:	39 da                	cmp    %ebx,%edx
  800b05:	75 e6                	jne    800aed <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1a:	89 c2                	mov    %eax,%edx
  800b1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1f:	eb 05                	jmp    800b26 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b21:	38 08                	cmp    %cl,(%eax)
  800b23:	74 05                	je     800b2a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b25:	40                   	inc    %eax
  800b26:	39 d0                	cmp    %edx,%eax
  800b28:	72 f7                	jb     800b21 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b38:	eb 01                	jmp    800b3b <strtol+0xf>
		s++;
  800b3a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3b:	8a 02                	mov    (%edx),%al
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f9                	je     800b3a <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f5                	je     800b3a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	75 08                	jne    800b51 <strtol+0x25>
		s++;
  800b49:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4f:	eb 13                	jmp    800b64 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b51:	3c 2d                	cmp    $0x2d,%al
  800b53:	75 0a                	jne    800b5f <strtol+0x33>
		s++, neg = 1;
  800b55:	8d 52 01             	lea    0x1(%edx),%edx
  800b58:	bf 01 00 00 00       	mov    $0x1,%edi
  800b5d:	eb 05                	jmp    800b64 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	74 05                	je     800b6d <strtol+0x41>
  800b68:	83 fb 10             	cmp    $0x10,%ebx
  800b6b:	75 28                	jne    800b95 <strtol+0x69>
  800b6d:	8a 02                	mov    (%edx),%al
  800b6f:	3c 30                	cmp    $0x30,%al
  800b71:	75 10                	jne    800b83 <strtol+0x57>
  800b73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b77:	75 0a                	jne    800b83 <strtol+0x57>
		s += 2, base = 16;
  800b79:	83 c2 02             	add    $0x2,%edx
  800b7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b81:	eb 12                	jmp    800b95 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b83:	85 db                	test   %ebx,%ebx
  800b85:	75 0e                	jne    800b95 <strtol+0x69>
  800b87:	3c 30                	cmp    $0x30,%al
  800b89:	75 05                	jne    800b90 <strtol+0x64>
		s++, base = 8;
  800b8b:	42                   	inc    %edx
  800b8c:	b3 08                	mov    $0x8,%bl
  800b8e:	eb 05                	jmp    800b95 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b90:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9c:	8a 0a                	mov    (%edx),%cl
  800b9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba1:	80 fb 09             	cmp    $0x9,%bl
  800ba4:	77 08                	ja     800bae <strtol+0x82>
			dig = *s - '0';
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 30             	sub    $0x30,%ecx
  800bac:	eb 1e                	jmp    800bcc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0x92>
			dig = *s - 'a' + 10;
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 57             	sub    $0x57,%ecx
  800bbc:	eb 0e                	jmp    800bcc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 12                	ja     800bd8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcc:	39 f1                	cmp    %esi,%ecx
  800bce:	7d 0c                	jge    800bdc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bd0:	42                   	inc    %edx
  800bd1:	0f af c6             	imul   %esi,%eax
  800bd4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bd6:	eb c4                	jmp    800b9c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd8:	89 c1                	mov    %eax,%ecx
  800bda:	eb 02                	jmp    800bde <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be2:	74 05                	je     800be9 <strtol+0xbd>
		*endptr = (char *) s;
  800be4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be9:	85 ff                	test   %edi,%edi
  800beb:	74 04                	je     800bf1 <strtol+0xc5>
  800bed:	89 c8                	mov    %ecx,%eax
  800bef:	f7 d8                	neg    %eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
	...

00800bf8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 c3                	mov    %eax,%ebx
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	89 c6                	mov    %eax,%esi
  800c0f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	b8 01 00 00 00       	mov    $0x1,%eax
  800c26:	89 d1                	mov    %edx,%ecx
  800c28:	89 d3                	mov    %edx,%ebx
  800c2a:	89 d7                	mov    %edx,%edi
  800c2c:	89 d6                	mov    %edx,%esi
  800c2e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c43:	b8 03 00 00 00       	mov    $0x3,%eax
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 cb                	mov    %ecx,%ebx
  800c4d:	89 cf                	mov    %ecx,%edi
  800c4f:	89 ce                	mov    %ecx,%esi
  800c51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 28                	jle    800c7f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c62:	00 
  800c63:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c72:	00 
  800c73:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  800c7a:	e8 b1 f5 ff ff       	call   800230 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7f:	83 c4 2c             	add    $0x2c,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 02 00 00 00       	mov    $0x2,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_yield>:

void
sys_yield(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 f7                	mov    %esi,%edi
  800ce3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 28                	jle    800d11 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ced:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  800cfc:	00 
  800cfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d04:	00 
  800d05:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  800d0c:	e8 1f f5 ff ff       	call   800230 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d11:	83 c4 2c             	add    $0x2c,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	b8 05 00 00 00       	mov    $0x5,%eax
  800d27:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 28                	jle    800d64 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d40:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d47:	00 
  800d48:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  800d4f:	00 
  800d50:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d57:	00 
  800d58:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  800d5f:	e8 cc f4 ff ff       	call   800230 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d64:	83 c4 2c             	add    $0x2c,%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 28                	jle    800db7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d93:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  800da2:	00 
  800da3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800daa:	00 
  800dab:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  800db2:	e8 79 f4 ff ff       	call   800230 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db7:	83 c4 2c             	add    $0x2c,%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 28                	jle    800e0a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ded:	00 
  800dee:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  800df5:	00 
  800df6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfd:	00 
  800dfe:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  800e05:	e8 26 f4 ff ff       	call   800230 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0a:	83 c4 2c             	add    $0x2c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	b8 09 00 00 00       	mov    $0x9,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 28                	jle    800e5d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e39:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e40:	00 
  800e41:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  800e48:	00 
  800e49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e50:	00 
  800e51:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  800e58:	e8 d3 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5d:	83 c4 2c             	add    $0x2c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	7e 28                	jle    800eb0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e93:	00 
  800e94:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea3:	00 
  800ea4:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  800eab:	e8 80 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb0:	83 c4 2c             	add    $0x2c,%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	be 00 00 00 00       	mov    $0x0,%esi
  800ec3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 cb                	mov    %ecx,%ebx
  800ef3:	89 cf                	mov    %ecx,%edi
  800ef5:	89 ce                	mov    %ecx,%esi
  800ef7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7e 28                	jle    800f25 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f01:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f08:	00 
  800f09:	c7 44 24 08 1f 25 80 	movl   $0x80251f,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  800f20:	e8 0b f3 ff ff       	call   800230 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f25:	83 c4 2c             	add    $0x2c,%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    
  800f2d:	00 00                	add    %al,(%eax)
	...

00800f30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f33:	8b 45 08             	mov    0x8(%ebp),%eax
  800f36:	05 00 00 00 30       	add    $0x30000000,%eax
  800f3b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
  800f49:	89 04 24             	mov    %eax,(%esp)
  800f4c:	e8 df ff ff ff       	call   800f30 <fd2num>
  800f51:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f56:	c1 e0 0c             	shl    $0xc,%eax
}
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	53                   	push   %ebx
  800f5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f62:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f67:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f69:	89 c2                	mov    %eax,%edx
  800f6b:	c1 ea 16             	shr    $0x16,%edx
  800f6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f75:	f6 c2 01             	test   $0x1,%dl
  800f78:	74 11                	je     800f8b <fd_alloc+0x30>
  800f7a:	89 c2                	mov    %eax,%edx
  800f7c:	c1 ea 0c             	shr    $0xc,%edx
  800f7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f86:	f6 c2 01             	test   $0x1,%dl
  800f89:	75 09                	jne    800f94 <fd_alloc+0x39>
			*fd_store = fd;
  800f8b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f92:	eb 17                	jmp    800fab <fd_alloc+0x50>
  800f94:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f99:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f9e:	75 c7                	jne    800f67 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fa0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fa6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fab:	5b                   	pop    %ebx
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fb4:	83 f8 1f             	cmp    $0x1f,%eax
  800fb7:	77 36                	ja     800fef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb9:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fbe:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fc1:	89 c2                	mov    %eax,%edx
  800fc3:	c1 ea 16             	shr    $0x16,%edx
  800fc6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fcd:	f6 c2 01             	test   $0x1,%dl
  800fd0:	74 24                	je     800ff6 <fd_lookup+0x48>
  800fd2:	89 c2                	mov    %eax,%edx
  800fd4:	c1 ea 0c             	shr    $0xc,%edx
  800fd7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fde:	f6 c2 01             	test   $0x1,%dl
  800fe1:	74 1a                	je     800ffd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fe3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe6:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fed:	eb 13                	jmp    801002 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff4:	eb 0c                	jmp    801002 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ff6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ffb:	eb 05                	jmp    801002 <fd_lookup+0x54>
  800ffd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	53                   	push   %ebx
  801008:	83 ec 14             	sub    $0x14,%esp
  80100b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801011:	ba 00 00 00 00       	mov    $0x0,%edx
  801016:	eb 0e                	jmp    801026 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801018:	39 08                	cmp    %ecx,(%eax)
  80101a:	75 09                	jne    801025 <dev_lookup+0x21>
			*dev = devtab[i];
  80101c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80101e:	b8 00 00 00 00       	mov    $0x0,%eax
  801023:	eb 33                	jmp    801058 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801025:	42                   	inc    %edx
  801026:	8b 04 95 cc 25 80 00 	mov    0x8025cc(,%edx,4),%eax
  80102d:	85 c0                	test   %eax,%eax
  80102f:	75 e7                	jne    801018 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801031:	a1 08 40 80 00       	mov    0x804008,%eax
  801036:	8b 40 48             	mov    0x48(%eax),%eax
  801039:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801041:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  801048:	e8 db f2 ff ff       	call   800328 <cprintf>
	*dev = 0;
  80104d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801053:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801058:	83 c4 14             	add    $0x14,%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    

0080105e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 30             	sub    $0x30,%esp
  801066:	8b 75 08             	mov    0x8(%ebp),%esi
  801069:	8a 45 0c             	mov    0xc(%ebp),%al
  80106c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80106f:	89 34 24             	mov    %esi,(%esp)
  801072:	e8 b9 fe ff ff       	call   800f30 <fd2num>
  801077:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80107a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80107e:	89 04 24             	mov    %eax,(%esp)
  801081:	e8 28 ff ff ff       	call   800fae <fd_lookup>
  801086:	89 c3                	mov    %eax,%ebx
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 05                	js     801091 <fd_close+0x33>
	    || fd != fd2)
  80108c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80108f:	74 0d                	je     80109e <fd_close+0x40>
		return (must_exist ? r : 0);
  801091:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801095:	75 46                	jne    8010dd <fd_close+0x7f>
  801097:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109c:	eb 3f                	jmp    8010dd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80109e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a5:	8b 06                	mov    (%esi),%eax
  8010a7:	89 04 24             	mov    %eax,(%esp)
  8010aa:	e8 55 ff ff ff       	call   801004 <dev_lookup>
  8010af:	89 c3                	mov    %eax,%ebx
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	78 18                	js     8010cd <fd_close+0x6f>
		if (dev->dev_close)
  8010b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b8:	8b 40 10             	mov    0x10(%eax),%eax
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	74 09                	je     8010c8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010bf:	89 34 24             	mov    %esi,(%esp)
  8010c2:	ff d0                	call   *%eax
  8010c4:	89 c3                	mov    %eax,%ebx
  8010c6:	eb 05                	jmp    8010cd <fd_close+0x6f>
		else
			r = 0;
  8010c8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d8:	e8 8f fc ff ff       	call   800d6c <sys_page_unmap>
	return r;
}
  8010dd:	89 d8                	mov    %ebx,%eax
  8010df:	83 c4 30             	add    $0x30,%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	89 04 24             	mov    %eax,(%esp)
  8010f9:	e8 b0 fe ff ff       	call   800fae <fd_lookup>
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 13                	js     801115 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801102:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801109:	00 
  80110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110d:	89 04 24             	mov    %eax,(%esp)
  801110:	e8 49 ff ff ff       	call   80105e <fd_close>
}
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <close_all>:

void
close_all(void)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	53                   	push   %ebx
  80111b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80111e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801123:	89 1c 24             	mov    %ebx,(%esp)
  801126:	e8 bb ff ff ff       	call   8010e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80112b:	43                   	inc    %ebx
  80112c:	83 fb 20             	cmp    $0x20,%ebx
  80112f:	75 f2                	jne    801123 <close_all+0xc>
		close(i);
}
  801131:	83 c4 14             	add    $0x14,%esp
  801134:	5b                   	pop    %ebx
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 4c             	sub    $0x4c,%esp
  801140:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801143:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
  80114d:	89 04 24             	mov    %eax,(%esp)
  801150:	e8 59 fe ff ff       	call   800fae <fd_lookup>
  801155:	89 c3                	mov    %eax,%ebx
  801157:	85 c0                	test   %eax,%eax
  801159:	0f 88 e1 00 00 00    	js     801240 <dup+0x109>
		return r;
	close(newfdnum);
  80115f:	89 3c 24             	mov    %edi,(%esp)
  801162:	e8 7f ff ff ff       	call   8010e6 <close>

	newfd = INDEX2FD(newfdnum);
  801167:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80116d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801170:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801173:	89 04 24             	mov    %eax,(%esp)
  801176:	e8 c5 fd ff ff       	call   800f40 <fd2data>
  80117b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80117d:	89 34 24             	mov    %esi,(%esp)
  801180:	e8 bb fd ff ff       	call   800f40 <fd2data>
  801185:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801188:	89 d8                	mov    %ebx,%eax
  80118a:	c1 e8 16             	shr    $0x16,%eax
  80118d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801194:	a8 01                	test   $0x1,%al
  801196:	74 46                	je     8011de <dup+0xa7>
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	c1 e8 0c             	shr    $0xc,%eax
  80119d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011a4:	f6 c2 01             	test   $0x1,%dl
  8011a7:	74 35                	je     8011de <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c7:	00 
  8011c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d3:	e8 41 fb ff ff       	call   800d19 <sys_page_map>
  8011d8:	89 c3                	mov    %eax,%ebx
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 3b                	js     801219 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	c1 ea 0c             	shr    $0xc,%edx
  8011e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ed:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011f3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801202:	00 
  801203:	89 44 24 04          	mov    %eax,0x4(%esp)
  801207:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120e:	e8 06 fb ff ff       	call   800d19 <sys_page_map>
  801213:	89 c3                	mov    %eax,%ebx
  801215:	85 c0                	test   %eax,%eax
  801217:	79 25                	jns    80123e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801219:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801224:	e8 43 fb ff ff       	call   800d6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801229:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80122c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801230:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801237:	e8 30 fb ff ff       	call   800d6c <sys_page_unmap>
	return r;
  80123c:	eb 02                	jmp    801240 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80123e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801240:	89 d8                	mov    %ebx,%eax
  801242:	83 c4 4c             	add    $0x4c,%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	53                   	push   %ebx
  80124e:	83 ec 24             	sub    $0x24,%esp
  801251:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801254:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125b:	89 1c 24             	mov    %ebx,(%esp)
  80125e:	e8 4b fd ff ff       	call   800fae <fd_lookup>
  801263:	85 c0                	test   %eax,%eax
  801265:	78 6d                	js     8012d4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801271:	8b 00                	mov    (%eax),%eax
  801273:	89 04 24             	mov    %eax,(%esp)
  801276:	e8 89 fd ff ff       	call   801004 <dev_lookup>
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 55                	js     8012d4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80127f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801282:	8b 50 08             	mov    0x8(%eax),%edx
  801285:	83 e2 03             	and    $0x3,%edx
  801288:	83 fa 01             	cmp    $0x1,%edx
  80128b:	75 23                	jne    8012b0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80128d:	a1 08 40 80 00       	mov    0x804008,%eax
  801292:	8b 40 48             	mov    0x48(%eax),%eax
  801295:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129d:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  8012a4:	e8 7f f0 ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  8012a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ae:	eb 24                	jmp    8012d4 <read+0x8a>
	}
	if (!dev->dev_read)
  8012b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b3:	8b 52 08             	mov    0x8(%edx),%edx
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	74 15                	je     8012cf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012c8:	89 04 24             	mov    %eax,(%esp)
  8012cb:	ff d2                	call   *%edx
  8012cd:	eb 05                	jmp    8012d4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012d4:	83 c4 24             	add    $0x24,%esp
  8012d7:	5b                   	pop    %ebx
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	57                   	push   %edi
  8012de:	56                   	push   %esi
  8012df:	53                   	push   %ebx
  8012e0:	83 ec 1c             	sub    $0x1c,%esp
  8012e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ee:	eb 23                	jmp    801313 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012f0:	89 f0                	mov    %esi,%eax
  8012f2:	29 d8                	sub    %ebx,%eax
  8012f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fb:	01 d8                	add    %ebx,%eax
  8012fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801301:	89 3c 24             	mov    %edi,(%esp)
  801304:	e8 41 ff ff ff       	call   80124a <read>
		if (m < 0)
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 10                	js     80131d <readn+0x43>
			return m;
		if (m == 0)
  80130d:	85 c0                	test   %eax,%eax
  80130f:	74 0a                	je     80131b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801311:	01 c3                	add    %eax,%ebx
  801313:	39 f3                	cmp    %esi,%ebx
  801315:	72 d9                	jb     8012f0 <readn+0x16>
  801317:	89 d8                	mov    %ebx,%eax
  801319:	eb 02                	jmp    80131d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80131b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80131d:	83 c4 1c             	add    $0x1c,%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5f                   	pop    %edi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	53                   	push   %ebx
  801329:	83 ec 24             	sub    $0x24,%esp
  80132c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801332:	89 44 24 04          	mov    %eax,0x4(%esp)
  801336:	89 1c 24             	mov    %ebx,(%esp)
  801339:	e8 70 fc ff ff       	call   800fae <fd_lookup>
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 68                	js     8013aa <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801342:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801345:	89 44 24 04          	mov    %eax,0x4(%esp)
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	8b 00                	mov    (%eax),%eax
  80134e:	89 04 24             	mov    %eax,(%esp)
  801351:	e8 ae fc ff ff       	call   801004 <dev_lookup>
  801356:	85 c0                	test   %eax,%eax
  801358:	78 50                	js     8013aa <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801361:	75 23                	jne    801386 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801363:	a1 08 40 80 00       	mov    0x804008,%eax
  801368:	8b 40 48             	mov    0x48(%eax),%eax
  80136b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801373:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  80137a:	e8 a9 ef ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  80137f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801384:	eb 24                	jmp    8013aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801386:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801389:	8b 52 0c             	mov    0xc(%edx),%edx
  80138c:	85 d2                	test   %edx,%edx
  80138e:	74 15                	je     8013a5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801390:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801393:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801397:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80139e:	89 04 24             	mov    %eax,(%esp)
  8013a1:	ff d2                	call   *%edx
  8013a3:	eb 05                	jmp    8013aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013aa:	83 c4 24             	add    $0x24,%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c0:	89 04 24             	mov    %eax,(%esp)
  8013c3:	e8 e6 fb ff ff       	call   800fae <fd_lookup>
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 0e                	js     8013da <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 24             	sub    $0x24,%esp
  8013e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ed:	89 1c 24             	mov    %ebx,(%esp)
  8013f0:	e8 b9 fb ff ff       	call   800fae <fd_lookup>
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 61                	js     80145a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801400:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801403:	8b 00                	mov    (%eax),%eax
  801405:	89 04 24             	mov    %eax,(%esp)
  801408:	e8 f7 fb ff ff       	call   801004 <dev_lookup>
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 49                	js     80145a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801411:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801414:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801418:	75 23                	jne    80143d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80141a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80141f:	8b 40 48             	mov    0x48(%eax),%eax
  801422:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801426:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142a:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  801431:	e8 f2 ee ff ff       	call   800328 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801436:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143b:	eb 1d                	jmp    80145a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80143d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801440:	8b 52 18             	mov    0x18(%edx),%edx
  801443:	85 d2                	test   %edx,%edx
  801445:	74 0e                	je     801455 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801447:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80144e:	89 04 24             	mov    %eax,(%esp)
  801451:	ff d2                	call   *%edx
  801453:	eb 05                	jmp    80145a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801455:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80145a:	83 c4 24             	add    $0x24,%esp
  80145d:	5b                   	pop    %ebx
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	53                   	push   %ebx
  801464:	83 ec 24             	sub    $0x24,%esp
  801467:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801471:	8b 45 08             	mov    0x8(%ebp),%eax
  801474:	89 04 24             	mov    %eax,(%esp)
  801477:	e8 32 fb ff ff       	call   800fae <fd_lookup>
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 52                	js     8014d2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801480:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801483:	89 44 24 04          	mov    %eax,0x4(%esp)
  801487:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148a:	8b 00                	mov    (%eax),%eax
  80148c:	89 04 24             	mov    %eax,(%esp)
  80148f:	e8 70 fb ff ff       	call   801004 <dev_lookup>
  801494:	85 c0                	test   %eax,%eax
  801496:	78 3a                	js     8014d2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801498:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80149f:	74 2c                	je     8014cd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014ab:	00 00 00 
	stat->st_isdir = 0;
  8014ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014b5:	00 00 00 
	stat->st_dev = dev;
  8014b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c5:	89 14 24             	mov    %edx,(%esp)
  8014c8:	ff 50 14             	call   *0x14(%eax)
  8014cb:	eb 05                	jmp    8014d2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014d2:	83 c4 24             	add    $0x24,%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	56                   	push   %esi
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014e7:	00 
  8014e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014eb:	89 04 24             	mov    %eax,(%esp)
  8014ee:	e8 fe 01 00 00       	call   8016f1 <open>
  8014f3:	89 c3                	mov    %eax,%ebx
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 1b                	js     801514 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801500:	89 1c 24             	mov    %ebx,(%esp)
  801503:	e8 58 ff ff ff       	call   801460 <fstat>
  801508:	89 c6                	mov    %eax,%esi
	close(fd);
  80150a:	89 1c 24             	mov    %ebx,(%esp)
  80150d:	e8 d4 fb ff ff       	call   8010e6 <close>
	return r;
  801512:	89 f3                	mov    %esi,%ebx
}
  801514:	89 d8                	mov    %ebx,%eax
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	5b                   	pop    %ebx
  80151a:	5e                   	pop    %esi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    
  80151d:	00 00                	add    %al,(%eax)
	...

00801520 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	56                   	push   %esi
  801524:	53                   	push   %ebx
  801525:	83 ec 10             	sub    $0x10,%esp
  801528:	89 c3                	mov    %eax,%ebx
  80152a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80152c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801533:	75 11                	jne    801546 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801535:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80153c:	e8 72 09 00 00       	call   801eb3 <ipc_find_env>
  801541:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801546:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80154d:	00 
  80154e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801555:	00 
  801556:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80155a:	a1 04 40 80 00       	mov    0x804004,%eax
  80155f:	89 04 24             	mov    %eax,(%esp)
  801562:	e8 e2 08 00 00       	call   801e49 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801567:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80156e:	00 
  80156f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801573:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80157a:	e8 61 08 00 00       	call   801de0 <ipc_recv>
}
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	5b                   	pop    %ebx
  801583:	5e                   	pop    %esi
  801584:	5d                   	pop    %ebp
  801585:	c3                   	ret    

00801586 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80158c:	8b 45 08             	mov    0x8(%ebp),%eax
  80158f:	8b 40 0c             	mov    0xc(%eax),%eax
  801592:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801597:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80159f:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8015a9:	e8 72 ff ff ff       	call   801520 <fsipc>
}
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015bc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8015cb:	e8 50 ff ff ff       	call   801520 <fsipc>
}
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 14             	sub    $0x14,%esp
  8015d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015df:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8015f1:	e8 2a ff ff ff       	call   801520 <fsipc>
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 2b                	js     801625 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015fa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801601:	00 
  801602:	89 1c 24             	mov    %ebx,(%esp)
  801605:	e8 c9 f2 ff ff       	call   8008d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80160a:	a1 80 50 80 00       	mov    0x805080,%eax
  80160f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801615:	a1 84 50 80 00       	mov    0x805084,%eax
  80161a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801620:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801625:	83 c4 14             	add    $0x14,%esp
  801628:	5b                   	pop    %ebx
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801631:	c7 44 24 08 dc 25 80 	movl   $0x8025dc,0x8(%esp)
  801638:	00 
  801639:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801640:	00 
  801641:	c7 04 24 fa 25 80 00 	movl   $0x8025fa,(%esp)
  801648:	e8 e3 eb ff ff       	call   800230 <_panic>

0080164d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
  801652:	83 ec 10             	sub    $0x10,%esp
  801655:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801658:	8b 45 08             	mov    0x8(%ebp),%eax
  80165b:	8b 40 0c             	mov    0xc(%eax),%eax
  80165e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801663:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801669:	ba 00 00 00 00       	mov    $0x0,%edx
  80166e:	b8 03 00 00 00       	mov    $0x3,%eax
  801673:	e8 a8 fe ff ff       	call   801520 <fsipc>
  801678:	89 c3                	mov    %eax,%ebx
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 6a                	js     8016e8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80167e:	39 c6                	cmp    %eax,%esi
  801680:	73 24                	jae    8016a6 <devfile_read+0x59>
  801682:	c7 44 24 0c 05 26 80 	movl   $0x802605,0xc(%esp)
  801689:	00 
  80168a:	c7 44 24 08 0c 26 80 	movl   $0x80260c,0x8(%esp)
  801691:	00 
  801692:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801699:	00 
  80169a:	c7 04 24 fa 25 80 00 	movl   $0x8025fa,(%esp)
  8016a1:	e8 8a eb ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  8016a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016ab:	7e 24                	jle    8016d1 <devfile_read+0x84>
  8016ad:	c7 44 24 0c 21 26 80 	movl   $0x802621,0xc(%esp)
  8016b4:	00 
  8016b5:	c7 44 24 08 0c 26 80 	movl   $0x80260c,0x8(%esp)
  8016bc:	00 
  8016bd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016c4:	00 
  8016c5:	c7 04 24 fa 25 80 00 	movl   $0x8025fa,(%esp)
  8016cc:	e8 5f eb ff ff       	call   800230 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016dc:	00 
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e0:	89 04 24             	mov    %eax,(%esp)
  8016e3:	e8 64 f3 ff ff       	call   800a4c <memmove>
	return r;
}
  8016e8:	89 d8                	mov    %ebx,%eax
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 20             	sub    $0x20,%esp
  8016f9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016fc:	89 34 24             	mov    %esi,(%esp)
  8016ff:	e8 9c f1 ff ff       	call   8008a0 <strlen>
  801704:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801709:	7f 60                	jg     80176b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80170b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	e8 45 f8 ff ff       	call   800f5b <fd_alloc>
  801716:	89 c3                	mov    %eax,%ebx
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 54                	js     801770 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80171c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801720:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801727:	e8 a7 f1 ff ff       	call   8008d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80172c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80172f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801734:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801737:	b8 01 00 00 00       	mov    $0x1,%eax
  80173c:	e8 df fd ff ff       	call   801520 <fsipc>
  801741:	89 c3                	mov    %eax,%ebx
  801743:	85 c0                	test   %eax,%eax
  801745:	79 15                	jns    80175c <open+0x6b>
		fd_close(fd, 0);
  801747:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80174e:	00 
  80174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	e8 04 f9 ff ff       	call   80105e <fd_close>
		return r;
  80175a:	eb 14                	jmp    801770 <open+0x7f>
	}

	return fd2num(fd);
  80175c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175f:	89 04 24             	mov    %eax,(%esp)
  801762:	e8 c9 f7 ff ff       	call   800f30 <fd2num>
  801767:	89 c3                	mov    %eax,%ebx
  801769:	eb 05                	jmp    801770 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80176b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	83 c4 20             	add    $0x20,%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	b8 08 00 00 00       	mov    $0x8,%eax
  801789:	e8 92 fd ff ff       	call   801520 <fsipc>
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	83 ec 14             	sub    $0x14,%esp
  801797:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801799:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80179d:	7e 32                	jle    8017d1 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80179f:	8b 40 04             	mov    0x4(%eax),%eax
  8017a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a6:	8d 43 10             	lea    0x10(%ebx),%eax
  8017a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ad:	8b 03                	mov    (%ebx),%eax
  8017af:	89 04 24             	mov    %eax,(%esp)
  8017b2:	e8 6e fb ff ff       	call   801325 <write>
		if (result > 0)
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	7e 03                	jle    8017be <writebuf+0x2e>
			b->result += result;
  8017bb:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017be:	39 43 04             	cmp    %eax,0x4(%ebx)
  8017c1:	74 0e                	je     8017d1 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8017c3:	89 c2                	mov    %eax,%edx
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	7e 05                	jle    8017ce <writebuf+0x3e>
  8017c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ce:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8017d1:	83 c4 14             	add    $0x14,%esp
  8017d4:	5b                   	pop    %ebx
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <putch>:

static void
putch(int ch, void *thunk)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017e1:	8b 43 04             	mov    0x4(%ebx),%eax
  8017e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e7:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8017eb:	40                   	inc    %eax
  8017ec:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8017ef:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017f4:	75 0e                	jne    801804 <putch+0x2d>
		writebuf(b);
  8017f6:	89 d8                	mov    %ebx,%eax
  8017f8:	e8 93 ff ff ff       	call   801790 <writebuf>
		b->idx = 0;
  8017fd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801804:	83 c4 04             	add    $0x4,%esp
  801807:	5b                   	pop    %ebx
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80181c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801823:	00 00 00 
	b.result = 0;
  801826:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80182d:	00 00 00 
	b.error = 1;
  801830:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801837:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80183a:	8b 45 10             	mov    0x10(%ebp),%eax
  80183d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801841:	8b 45 0c             	mov    0xc(%ebp),%eax
  801844:	89 44 24 08          	mov    %eax,0x8(%esp)
  801848:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80184e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801852:	c7 04 24 d7 17 80 00 	movl   $0x8017d7,(%esp)
  801859:	e8 2c ec ff ff       	call   80048a <vprintfmt>
	if (b.idx > 0)
  80185e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801865:	7e 0b                	jle    801872 <vfprintf+0x68>
		writebuf(&b);
  801867:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80186d:	e8 1e ff ff ff       	call   801790 <writebuf>

	return (b.result ? b.result : b.error);
  801872:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801878:	85 c0                	test   %eax,%eax
  80187a:	75 06                	jne    801882 <vfprintf+0x78>
  80187c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80188a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80188d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801891:	8b 45 0c             	mov    0xc(%ebp),%eax
  801894:	89 44 24 04          	mov    %eax,0x4(%esp)
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	89 04 24             	mov    %eax,(%esp)
  80189e:	e8 67 ff ff ff       	call   80180a <vfprintf>
	va_end(ap);

	return cnt;
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <printf>:

int
printf(const char *fmt, ...)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018c0:	e8 45 ff ff ff       	call   80180a <vfprintf>
	va_end(ap);

	return cnt;
}
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    
	...

008018c8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 10             	sub    $0x10,%esp
  8018d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 62 f6 ff ff       	call   800f40 <fd2data>
  8018de:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8018e0:	c7 44 24 04 2d 26 80 	movl   $0x80262d,0x4(%esp)
  8018e7:	00 
  8018e8:	89 34 24             	mov    %esi,(%esp)
  8018eb:	e8 e3 ef ff ff       	call   8008d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8018f3:	2b 03                	sub    (%ebx),%eax
  8018f5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8018fb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801902:	00 00 00 
	stat->st_dev = &devpipe;
  801905:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  80190c:	30 80 00 
	return 0;
}
  80190f:	b8 00 00 00 00       	mov    $0x0,%eax
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	5b                   	pop    %ebx
  801918:	5e                   	pop    %esi
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	53                   	push   %ebx
  80191f:	83 ec 14             	sub    $0x14,%esp
  801922:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801925:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801929:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801930:	e8 37 f4 ff ff       	call   800d6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801935:	89 1c 24             	mov    %ebx,(%esp)
  801938:	e8 03 f6 ff ff       	call   800f40 <fd2data>
  80193d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801941:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801948:	e8 1f f4 ff ff       	call   800d6c <sys_page_unmap>
}
  80194d:	83 c4 14             	add    $0x14,%esp
  801950:	5b                   	pop    %ebx
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    

00801953 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	57                   	push   %edi
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	83 ec 2c             	sub    $0x2c,%esp
  80195c:	89 c7                	mov    %eax,%edi
  80195e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801961:	a1 08 40 80 00       	mov    0x804008,%eax
  801966:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801969:	89 3c 24             	mov    %edi,(%esp)
  80196c:	e8 87 05 00 00       	call   801ef8 <pageref>
  801971:	89 c6                	mov    %eax,%esi
  801973:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 7a 05 00 00       	call   801ef8 <pageref>
  80197e:	39 c6                	cmp    %eax,%esi
  801980:	0f 94 c0             	sete   %al
  801983:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801986:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80198c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80198f:	39 cb                	cmp    %ecx,%ebx
  801991:	75 08                	jne    80199b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801993:	83 c4 2c             	add    $0x2c,%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5f                   	pop    %edi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80199b:	83 f8 01             	cmp    $0x1,%eax
  80199e:	75 c1                	jne    801961 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019a0:	8b 42 58             	mov    0x58(%edx),%eax
  8019a3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8019aa:	00 
  8019ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019b3:	c7 04 24 34 26 80 00 	movl   $0x802634,(%esp)
  8019ba:	e8 69 e9 ff ff       	call   800328 <cprintf>
  8019bf:	eb a0                	jmp    801961 <_pipeisclosed+0xe>

008019c1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	57                   	push   %edi
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 1c             	sub    $0x1c,%esp
  8019ca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019cd:	89 34 24             	mov    %esi,(%esp)
  8019d0:	e8 6b f5 ff ff       	call   800f40 <fd2data>
  8019d5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019dc:	eb 3c                	jmp    801a1a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019de:	89 da                	mov    %ebx,%edx
  8019e0:	89 f0                	mov    %esi,%eax
  8019e2:	e8 6c ff ff ff       	call   801953 <_pipeisclosed>
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	75 38                	jne    801a23 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019eb:	e8 b6 f2 ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f3:	8b 13                	mov    (%ebx),%edx
  8019f5:	83 c2 20             	add    $0x20,%edx
  8019f8:	39 d0                	cmp    %edx,%eax
  8019fa:	73 e2                	jae    8019de <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ff:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801a02:	89 c2                	mov    %eax,%edx
  801a04:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a0a:	79 05                	jns    801a11 <devpipe_write+0x50>
  801a0c:	4a                   	dec    %edx
  801a0d:	83 ca e0             	or     $0xffffffe0,%edx
  801a10:	42                   	inc    %edx
  801a11:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a15:	40                   	inc    %eax
  801a16:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a19:	47                   	inc    %edi
  801a1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a1d:	75 d1                	jne    8019f0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a1f:	89 f8                	mov    %edi,%eax
  801a21:	eb 05                	jmp    801a28 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a28:	83 c4 1c             	add    $0x1c,%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5f                   	pop    %edi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	83 ec 1c             	sub    $0x1c,%esp
  801a39:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a3c:	89 3c 24             	mov    %edi,(%esp)
  801a3f:	e8 fc f4 ff ff       	call   800f40 <fd2data>
  801a44:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a46:	be 00 00 00 00       	mov    $0x0,%esi
  801a4b:	eb 3a                	jmp    801a87 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a4d:	85 f6                	test   %esi,%esi
  801a4f:	74 04                	je     801a55 <devpipe_read+0x25>
				return i;
  801a51:	89 f0                	mov    %esi,%eax
  801a53:	eb 40                	jmp    801a95 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a55:	89 da                	mov    %ebx,%edx
  801a57:	89 f8                	mov    %edi,%eax
  801a59:	e8 f5 fe ff ff       	call   801953 <_pipeisclosed>
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	75 2e                	jne    801a90 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a62:	e8 3f f2 ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a67:	8b 03                	mov    (%ebx),%eax
  801a69:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a6c:	74 df                	je     801a4d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a6e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a73:	79 05                	jns    801a7a <devpipe_read+0x4a>
  801a75:	48                   	dec    %eax
  801a76:	83 c8 e0             	or     $0xffffffe0,%eax
  801a79:	40                   	inc    %eax
  801a7a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a81:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a84:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a86:	46                   	inc    %esi
  801a87:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a8a:	75 db                	jne    801a67 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a8c:	89 f0                	mov    %esi,%eax
  801a8e:	eb 05                	jmp    801a95 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a95:	83 c4 1c             	add    $0x1c,%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5f                   	pop    %edi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	57                   	push   %edi
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 3c             	sub    $0x3c,%esp
  801aa6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aa9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801aac:	89 04 24             	mov    %eax,(%esp)
  801aaf:	e8 a7 f4 ff ff       	call   800f5b <fd_alloc>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	0f 88 45 01 00 00    	js     801c03 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abe:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ac5:	00 
  801ac6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad4:	e8 ec f1 ff ff       	call   800cc5 <sys_page_alloc>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	85 c0                	test   %eax,%eax
  801add:	0f 88 20 01 00 00    	js     801c03 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ae3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ae6:	89 04 24             	mov    %eax,(%esp)
  801ae9:	e8 6d f4 ff ff       	call   800f5b <fd_alloc>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	85 c0                	test   %eax,%eax
  801af2:	0f 88 f8 00 00 00    	js     801bf0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aff:	00 
  801b00:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b0e:	e8 b2 f1 ff ff       	call   800cc5 <sys_page_alloc>
  801b13:	89 c3                	mov    %eax,%ebx
  801b15:	85 c0                	test   %eax,%eax
  801b17:	0f 88 d3 00 00 00    	js     801bf0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b20:	89 04 24             	mov    %eax,(%esp)
  801b23:	e8 18 f4 ff ff       	call   800f40 <fd2data>
  801b28:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b31:	00 
  801b32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3d:	e8 83 f1 ff ff       	call   800cc5 <sys_page_alloc>
  801b42:	89 c3                	mov    %eax,%ebx
  801b44:	85 c0                	test   %eax,%eax
  801b46:	0f 88 91 00 00 00    	js     801bdd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b4f:	89 04 24             	mov    %eax,(%esp)
  801b52:	e8 e9 f3 ff ff       	call   800f40 <fd2data>
  801b57:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b5e:	00 
  801b5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b6a:	00 
  801b6b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b76:	e8 9e f1 ff ff       	call   800d19 <sys_page_map>
  801b7b:	89 c3                	mov    %eax,%ebx
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	78 4c                	js     801bcd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b81:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b96:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b9f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ba1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ba4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bae:	89 04 24             	mov    %eax,(%esp)
  801bb1:	e8 7a f3 ff ff       	call   800f30 <fd2num>
  801bb6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801bb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bbb:	89 04 24             	mov    %eax,(%esp)
  801bbe:	e8 6d f3 ff ff       	call   800f30 <fd2num>
  801bc3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801bc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bcb:	eb 36                	jmp    801c03 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801bcd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd8:	e8 8f f1 ff ff       	call   800d6c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801bdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801beb:	e8 7c f1 ff ff       	call   800d6c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801bf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfe:	e8 69 f1 ff ff       	call   800d6c <sys_page_unmap>
    err:
	return r;
}
  801c03:	89 d8                	mov    %ebx,%eax
  801c05:	83 c4 3c             	add    $0x3c,%esp
  801c08:	5b                   	pop    %ebx
  801c09:	5e                   	pop    %esi
  801c0a:	5f                   	pop    %edi
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    

00801c0d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	89 04 24             	mov    %eax,(%esp)
  801c20:	e8 89 f3 ff ff       	call   800fae <fd_lookup>
  801c25:	85 c0                	test   %eax,%eax
  801c27:	78 15                	js     801c3e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2c:	89 04 24             	mov    %eax,(%esp)
  801c2f:	e8 0c f3 ff ff       	call   800f40 <fd2data>
	return _pipeisclosed(fd, p);
  801c34:	89 c2                	mov    %eax,%edx
  801c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c39:	e8 15 fd ff ff       	call   801953 <_pipeisclosed>
}
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c50:	c7 44 24 04 4c 26 80 	movl   $0x80264c,0x4(%esp)
  801c57:	00 
  801c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5b:	89 04 24             	mov    %eax,(%esp)
  801c5e:	e8 70 ec ff ff       	call   8008d3 <strcpy>
	return 0;
}
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
  801c68:	c9                   	leave  
  801c69:	c3                   	ret    

00801c6a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	57                   	push   %edi
  801c6e:	56                   	push   %esi
  801c6f:	53                   	push   %ebx
  801c70:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c76:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c7b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c81:	eb 30                	jmp    801cb3 <devcons_write+0x49>
		m = n - tot;
  801c83:	8b 75 10             	mov    0x10(%ebp),%esi
  801c86:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801c88:	83 fe 7f             	cmp    $0x7f,%esi
  801c8b:	76 05                	jbe    801c92 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801c8d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c92:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c96:	03 45 0c             	add    0xc(%ebp),%eax
  801c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9d:	89 3c 24             	mov    %edi,(%esp)
  801ca0:	e8 a7 ed ff ff       	call   800a4c <memmove>
		sys_cputs(buf, m);
  801ca5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca9:	89 3c 24             	mov    %edi,(%esp)
  801cac:	e8 47 ef ff ff       	call   800bf8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb1:	01 f3                	add    %esi,%ebx
  801cb3:	89 d8                	mov    %ebx,%eax
  801cb5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb8:	72 c9                	jb     801c83 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cba:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ccb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ccf:	75 07                	jne    801cd8 <devcons_read+0x13>
  801cd1:	eb 25                	jmp    801cf8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cd3:	e8 ce ef ff ff       	call   800ca6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cd8:	e8 39 ef ff ff       	call   800c16 <sys_cgetc>
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	74 f2                	je     801cd3 <devcons_read+0xe>
  801ce1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 1d                	js     801d04 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ce7:	83 f8 04             	cmp    $0x4,%eax
  801cea:	74 13                	je     801cff <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cef:	88 10                	mov    %dl,(%eax)
	return 1;
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	eb 0c                	jmp    801d04 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfd:	eb 05                	jmp    801d04 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d12:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d19:	00 
  801d1a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d1d:	89 04 24             	mov    %eax,(%esp)
  801d20:	e8 d3 ee ff ff       	call   800bf8 <sys_cputs>
}
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    

00801d27 <getchar>:

int
getchar(void)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d2d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d34:	00 
  801d35:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d43:	e8 02 f5 ff ff       	call   80124a <read>
	if (r < 0)
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 0f                	js     801d5b <getchar+0x34>
		return r;
	if (r < 1)
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	7e 06                	jle    801d56 <getchar+0x2f>
		return -E_EOF;
	return c;
  801d50:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d54:	eb 05                	jmp    801d5b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d56:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6d:	89 04 24             	mov    %eax,(%esp)
  801d70:	e8 39 f2 ff ff       	call   800fae <fd_lookup>
  801d75:	85 c0                	test   %eax,%eax
  801d77:	78 11                	js     801d8a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801d82:	39 10                	cmp    %edx,(%eax)
  801d84:	0f 94 c0             	sete   %al
  801d87:	0f b6 c0             	movzbl %al,%eax
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <opencons>:

int
opencons(void)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d95:	89 04 24             	mov    %eax,(%esp)
  801d98:	e8 be f1 ff ff       	call   800f5b <fd_alloc>
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 3c                	js     801ddd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801da1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801da8:	00 
  801da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db7:	e8 09 ef ff ff       	call   800cc5 <sys_page_alloc>
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 1d                	js     801ddd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dc0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dd5:	89 04 24             	mov    %eax,(%esp)
  801dd8:	e8 53 f1 ff ff       	call   800f30 <fd2num>
}
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    
	...

00801de0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	83 ec 1c             	sub    $0x1c,%esp
  801de9:	8b 75 08             	mov    0x8(%ebp),%esi
  801dec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801def:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801df2:	85 db                	test   %ebx,%ebx
  801df4:	75 05                	jne    801dfb <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801df6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801dfb:	89 1c 24             	mov    %ebx,(%esp)
  801dfe:	e8 d8 f0 ff ff       	call   800edb <sys_ipc_recv>
  801e03:	85 c0                	test   %eax,%eax
  801e05:	79 16                	jns    801e1d <ipc_recv+0x3d>
		*from_env_store = 0;
  801e07:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801e0d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801e13:	89 1c 24             	mov    %ebx,(%esp)
  801e16:	e8 c0 f0 ff ff       	call   800edb <sys_ipc_recv>
  801e1b:	eb 24                	jmp    801e41 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801e1d:	85 f6                	test   %esi,%esi
  801e1f:	74 0a                	je     801e2b <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801e21:	a1 08 40 80 00       	mov    0x804008,%eax
  801e26:	8b 40 74             	mov    0x74(%eax),%eax
  801e29:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801e2b:	85 ff                	test   %edi,%edi
  801e2d:	74 0a                	je     801e39 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801e2f:	a1 08 40 80 00       	mov    0x804008,%eax
  801e34:	8b 40 78             	mov    0x78(%eax),%eax
  801e37:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801e39:	a1 08 40 80 00       	mov    0x804008,%eax
  801e3e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e41:	83 c4 1c             	add    $0x1c,%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	57                   	push   %edi
  801e4d:	56                   	push   %esi
  801e4e:	53                   	push   %ebx
  801e4f:	83 ec 1c             	sub    $0x1c,%esp
  801e52:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e58:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801e5b:	85 db                	test   %ebx,%ebx
  801e5d:	75 05                	jne    801e64 <ipc_send+0x1b>
		pg = (void *)-1;
  801e5f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e64:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e6c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e70:	8b 45 08             	mov    0x8(%ebp),%eax
  801e73:	89 04 24             	mov    %eax,(%esp)
  801e76:	e8 3d f0 ff ff       	call   800eb8 <sys_ipc_try_send>
		if (r == 0) {		
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	74 2c                	je     801eab <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801e7f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e82:	75 07                	jne    801e8b <ipc_send+0x42>
			sys_yield();
  801e84:	e8 1d ee ff ff       	call   800ca6 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801e89:	eb d9                	jmp    801e64 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801e8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8f:	c7 44 24 08 58 26 80 	movl   $0x802658,0x8(%esp)
  801e96:	00 
  801e97:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801e9e:	00 
  801e9f:	c7 04 24 66 26 80 00 	movl   $0x802666,(%esp)
  801ea6:	e8 85 e3 ff ff       	call   800230 <_panic>
		}
	}
}
  801eab:	83 c4 1c             	add    $0x1c,%esp
  801eae:	5b                   	pop    %ebx
  801eaf:	5e                   	pop    %esi
  801eb0:	5f                   	pop    %edi
  801eb1:	5d                   	pop    %ebp
  801eb2:	c3                   	ret    

00801eb3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	53                   	push   %ebx
  801eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801eba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ebf:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ec6:	89 c2                	mov    %eax,%edx
  801ec8:	c1 e2 07             	shl    $0x7,%edx
  801ecb:	29 ca                	sub    %ecx,%edx
  801ecd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ed3:	8b 52 50             	mov    0x50(%edx),%edx
  801ed6:	39 da                	cmp    %ebx,%edx
  801ed8:	75 0f                	jne    801ee9 <ipc_find_env+0x36>
			return envs[i].env_id;
  801eda:	c1 e0 07             	shl    $0x7,%eax
  801edd:	29 c8                	sub    %ecx,%eax
  801edf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ee4:	8b 40 40             	mov    0x40(%eax),%eax
  801ee7:	eb 0c                	jmp    801ef5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee9:	40                   	inc    %eax
  801eea:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eef:	75 ce                	jne    801ebf <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef1:	66 b8 00 00          	mov    $0x0,%ax
}
  801ef5:	5b                   	pop    %ebx
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efe:	89 c2                	mov    %eax,%edx
  801f00:	c1 ea 16             	shr    $0x16,%edx
  801f03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f0a:	f6 c2 01             	test   $0x1,%dl
  801f0d:	74 1e                	je     801f2d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f0f:	c1 e8 0c             	shr    $0xc,%eax
  801f12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f19:	a8 01                	test   $0x1,%al
  801f1b:	74 17                	je     801f34 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f1d:	c1 e8 0c             	shr    $0xc,%eax
  801f20:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f27:	ef 
  801f28:	0f b7 c0             	movzwl %ax,%eax
  801f2b:	eb 0c                	jmp    801f39 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f32:	eb 05                	jmp    801f39 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f34:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    
	...

00801f3c <__udivdi3>:
  801f3c:	55                   	push   %ebp
  801f3d:	57                   	push   %edi
  801f3e:	56                   	push   %esi
  801f3f:	83 ec 10             	sub    $0x10,%esp
  801f42:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f46:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f4e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f52:	89 cd                	mov    %ecx,%ebp
  801f54:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	75 2c                	jne    801f88 <__udivdi3+0x4c>
  801f5c:	39 f9                	cmp    %edi,%ecx
  801f5e:	77 68                	ja     801fc8 <__udivdi3+0x8c>
  801f60:	85 c9                	test   %ecx,%ecx
  801f62:	75 0b                	jne    801f6f <__udivdi3+0x33>
  801f64:	b8 01 00 00 00       	mov    $0x1,%eax
  801f69:	31 d2                	xor    %edx,%edx
  801f6b:	f7 f1                	div    %ecx
  801f6d:	89 c1                	mov    %eax,%ecx
  801f6f:	31 d2                	xor    %edx,%edx
  801f71:	89 f8                	mov    %edi,%eax
  801f73:	f7 f1                	div    %ecx
  801f75:	89 c7                	mov    %eax,%edi
  801f77:	89 f0                	mov    %esi,%eax
  801f79:	f7 f1                	div    %ecx
  801f7b:	89 c6                	mov    %eax,%esi
  801f7d:	89 f0                	mov    %esi,%eax
  801f7f:	89 fa                	mov    %edi,%edx
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	39 f8                	cmp    %edi,%eax
  801f8a:	77 2c                	ja     801fb8 <__udivdi3+0x7c>
  801f8c:	0f bd f0             	bsr    %eax,%esi
  801f8f:	83 f6 1f             	xor    $0x1f,%esi
  801f92:	75 4c                	jne    801fe0 <__udivdi3+0xa4>
  801f94:	39 f8                	cmp    %edi,%eax
  801f96:	bf 00 00 00 00       	mov    $0x0,%edi
  801f9b:	72 0a                	jb     801fa7 <__udivdi3+0x6b>
  801f9d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801fa1:	0f 87 ad 00 00 00    	ja     802054 <__udivdi3+0x118>
  801fa7:	be 01 00 00 00       	mov    $0x1,%esi
  801fac:	89 f0                	mov    %esi,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	5e                   	pop    %esi
  801fb4:	5f                   	pop    %edi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    
  801fb7:	90                   	nop
  801fb8:	31 ff                	xor    %edi,%edi
  801fba:	31 f6                	xor    %esi,%esi
  801fbc:	89 f0                	mov    %esi,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	5e                   	pop    %esi
  801fc4:	5f                   	pop    %edi
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    
  801fc7:	90                   	nop
  801fc8:	89 fa                	mov    %edi,%edx
  801fca:	89 f0                	mov    %esi,%eax
  801fcc:	f7 f1                	div    %ecx
  801fce:	89 c6                	mov    %eax,%esi
  801fd0:	31 ff                	xor    %edi,%edi
  801fd2:	89 f0                	mov    %esi,%eax
  801fd4:	89 fa                	mov    %edi,%edx
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    
  801fdd:	8d 76 00             	lea    0x0(%esi),%esi
  801fe0:	89 f1                	mov    %esi,%ecx
  801fe2:	d3 e0                	shl    %cl,%eax
  801fe4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fe8:	b8 20 00 00 00       	mov    $0x20,%eax
  801fed:	29 f0                	sub    %esi,%eax
  801fef:	89 ea                	mov    %ebp,%edx
  801ff1:	88 c1                	mov    %al,%cl
  801ff3:	d3 ea                	shr    %cl,%edx
  801ff5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801ff9:	09 ca                	or     %ecx,%edx
  801ffb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fff:	89 f1                	mov    %esi,%ecx
  802001:	d3 e5                	shl    %cl,%ebp
  802003:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802007:	89 fd                	mov    %edi,%ebp
  802009:	88 c1                	mov    %al,%cl
  80200b:	d3 ed                	shr    %cl,%ebp
  80200d:	89 fa                	mov    %edi,%edx
  80200f:	89 f1                	mov    %esi,%ecx
  802011:	d3 e2                	shl    %cl,%edx
  802013:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802017:	88 c1                	mov    %al,%cl
  802019:	d3 ef                	shr    %cl,%edi
  80201b:	09 d7                	or     %edx,%edi
  80201d:	89 f8                	mov    %edi,%eax
  80201f:	89 ea                	mov    %ebp,%edx
  802021:	f7 74 24 08          	divl   0x8(%esp)
  802025:	89 d1                	mov    %edx,%ecx
  802027:	89 c7                	mov    %eax,%edi
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d1                	cmp    %edx,%ecx
  80202f:	72 17                	jb     802048 <__udivdi3+0x10c>
  802031:	74 09                	je     80203c <__udivdi3+0x100>
  802033:	89 fe                	mov    %edi,%esi
  802035:	31 ff                	xor    %edi,%edi
  802037:	e9 41 ff ff ff       	jmp    801f7d <__udivdi3+0x41>
  80203c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802040:	89 f1                	mov    %esi,%ecx
  802042:	d3 e2                	shl    %cl,%edx
  802044:	39 c2                	cmp    %eax,%edx
  802046:	73 eb                	jae    802033 <__udivdi3+0xf7>
  802048:	8d 77 ff             	lea    -0x1(%edi),%esi
  80204b:	31 ff                	xor    %edi,%edi
  80204d:	e9 2b ff ff ff       	jmp    801f7d <__udivdi3+0x41>
  802052:	66 90                	xchg   %ax,%ax
  802054:	31 f6                	xor    %esi,%esi
  802056:	e9 22 ff ff ff       	jmp    801f7d <__udivdi3+0x41>
	...

0080205c <__umoddi3>:
  80205c:	55                   	push   %ebp
  80205d:	57                   	push   %edi
  80205e:	56                   	push   %esi
  80205f:	83 ec 20             	sub    $0x20,%esp
  802062:	8b 44 24 30          	mov    0x30(%esp),%eax
  802066:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80206a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80206e:	8b 74 24 34          	mov    0x34(%esp),%esi
  802072:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802076:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80207a:	89 c7                	mov    %eax,%edi
  80207c:	89 f2                	mov    %esi,%edx
  80207e:	85 ed                	test   %ebp,%ebp
  802080:	75 16                	jne    802098 <__umoddi3+0x3c>
  802082:	39 f1                	cmp    %esi,%ecx
  802084:	0f 86 a6 00 00 00    	jbe    802130 <__umoddi3+0xd4>
  80208a:	f7 f1                	div    %ecx
  80208c:	89 d0                	mov    %edx,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	83 c4 20             	add    $0x20,%esp
  802093:	5e                   	pop    %esi
  802094:	5f                   	pop    %edi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    
  802097:	90                   	nop
  802098:	39 f5                	cmp    %esi,%ebp
  80209a:	0f 87 ac 00 00 00    	ja     80214c <__umoddi3+0xf0>
  8020a0:	0f bd c5             	bsr    %ebp,%eax
  8020a3:	83 f0 1f             	xor    $0x1f,%eax
  8020a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020aa:	0f 84 a8 00 00 00    	je     802158 <__umoddi3+0xfc>
  8020b0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020b4:	d3 e5                	shl    %cl,%ebp
  8020b6:	bf 20 00 00 00       	mov    $0x20,%edi
  8020bb:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8020bf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020c3:	89 f9                	mov    %edi,%ecx
  8020c5:	d3 e8                	shr    %cl,%eax
  8020c7:	09 e8                	or     %ebp,%eax
  8020c9:	89 44 24 18          	mov    %eax,0x18(%esp)
  8020cd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020d1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020d5:	d3 e0                	shl    %cl,%eax
  8020d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020db:	89 f2                	mov    %esi,%edx
  8020dd:	d3 e2                	shl    %cl,%edx
  8020df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8020e9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020ed:	89 f9                	mov    %edi,%ecx
  8020ef:	d3 e8                	shr    %cl,%eax
  8020f1:	09 d0                	or     %edx,%eax
  8020f3:	d3 ee                	shr    %cl,%esi
  8020f5:	89 f2                	mov    %esi,%edx
  8020f7:	f7 74 24 18          	divl   0x18(%esp)
  8020fb:	89 d6                	mov    %edx,%esi
  8020fd:	f7 64 24 0c          	mull   0xc(%esp)
  802101:	89 c5                	mov    %eax,%ebp
  802103:	89 d1                	mov    %edx,%ecx
  802105:	39 d6                	cmp    %edx,%esi
  802107:	72 67                	jb     802170 <__umoddi3+0x114>
  802109:	74 75                	je     802180 <__umoddi3+0x124>
  80210b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80210f:	29 e8                	sub    %ebp,%eax
  802111:	19 ce                	sbb    %ecx,%esi
  802113:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802117:	d3 e8                	shr    %cl,%eax
  802119:	89 f2                	mov    %esi,%edx
  80211b:	89 f9                	mov    %edi,%ecx
  80211d:	d3 e2                	shl    %cl,%edx
  80211f:	09 d0                	or     %edx,%eax
  802121:	89 f2                	mov    %esi,%edx
  802123:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802127:	d3 ea                	shr    %cl,%edx
  802129:	83 c4 20             	add    $0x20,%esp
  80212c:	5e                   	pop    %esi
  80212d:	5f                   	pop    %edi
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    
  802130:	85 c9                	test   %ecx,%ecx
  802132:	75 0b                	jne    80213f <__umoddi3+0xe3>
  802134:	b8 01 00 00 00       	mov    $0x1,%eax
  802139:	31 d2                	xor    %edx,%edx
  80213b:	f7 f1                	div    %ecx
  80213d:	89 c1                	mov    %eax,%ecx
  80213f:	89 f0                	mov    %esi,%eax
  802141:	31 d2                	xor    %edx,%edx
  802143:	f7 f1                	div    %ecx
  802145:	89 f8                	mov    %edi,%eax
  802147:	e9 3e ff ff ff       	jmp    80208a <__umoddi3+0x2e>
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	83 c4 20             	add    $0x20,%esp
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	39 f5                	cmp    %esi,%ebp
  80215a:	72 04                	jb     802160 <__umoddi3+0x104>
  80215c:	39 f9                	cmp    %edi,%ecx
  80215e:	77 06                	ja     802166 <__umoddi3+0x10a>
  802160:	89 f2                	mov    %esi,%edx
  802162:	29 cf                	sub    %ecx,%edi
  802164:	19 ea                	sbb    %ebp,%edx
  802166:	89 f8                	mov    %edi,%eax
  802168:	83 c4 20             	add    $0x20,%esp
  80216b:	5e                   	pop    %esi
  80216c:	5f                   	pop    %edi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    
  80216f:	90                   	nop
  802170:	89 d1                	mov    %edx,%ecx
  802172:	89 c5                	mov    %eax,%ebp
  802174:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802178:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80217c:	eb 8d                	jmp    80210b <__umoddi3+0xaf>
  80217e:	66 90                	xchg   %ax,%ax
  802180:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802184:	72 ea                	jb     802170 <__umoddi3+0x114>
  802186:	89 f1                	mov    %esi,%ecx
  802188:	eb 81                	jmp    80210b <__umoddi3+0xaf>
