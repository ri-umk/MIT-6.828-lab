
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 ab 01 00 00       	call   8001dc <libmain>
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
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003d:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  800044:	e8 fb 02 00 00       	call   800344 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 d5 1c 00 00       	call   801d29 <pipe>
  800054:	85 c0                	test   %eax,%eax
  800056:	79 20                	jns    800078 <umain+0x44>
		panic("pipe: %e", r);
  800058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005c:	c7 44 24 08 ee 24 80 	movl   $0x8024ee,0x8(%esp)
  800063:	00 
  800064:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006b:	00 
  80006c:	c7 04 24 f7 24 80 00 	movl   $0x8024f7,(%esp)
  800073:	e8 d4 01 00 00       	call   80024c <_panic>
	if ((r = fork()) < 0)
  800078:	e8 f6 0f 00 00       	call   801073 <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <umain+0x6f>
		panic("fork: %e", r);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 0c 25 80 	movl   $0x80250c,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 f7 24 80 00 	movl   $0x8024f7,(%esp)
  80009e:	e8 a9 01 00 00       	call   80024c <_panic>
	if (r == 0) {
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 5d                	jne    800104 <umain+0xd0>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 f8 13 00 00       	call   8014aa <close>
		for (i = 0; i < 200; i++) {
  8000b2:	be 00 00 00 00       	mov    $0x0,%esi
			if (i % 10 == 0)
  8000b7:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8000bc:	89 f0                	mov    %esi,%eax
  8000be:	99                   	cltd   
  8000bf:	f7 fb                	idiv   %ebx
  8000c1:	85 d2                	test   %edx,%edx
  8000c3:	75 10                	jne    8000d5 <umain+0xa1>
				cprintf("%d.", i);
  8000c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c9:	c7 04 24 15 25 80 00 	movl   $0x802515,(%esp)
  8000d0:	e8 6f 02 00 00       	call   800344 <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000dc:	89 04 24             	mov    %eax,(%esp)
  8000df:	e8 17 14 00 00       	call   8014fb <dup>
			sys_yield();
  8000e4:	e8 d9 0b 00 00       	call   800cc2 <sys_yield>
			close(10);
  8000e9:	89 1c 24             	mov    %ebx,(%esp)
  8000ec:	e8 b9 13 00 00       	call   8014aa <close>
			sys_yield();
  8000f1:	e8 cc 0b 00 00       	call   800cc2 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000f6:	46                   	inc    %esi
  8000f7:	81 fe c8 00 00 00    	cmp    $0xc8,%esi
  8000fd:	75 bd                	jne    8000bc <umain+0x88>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000ff:	e8 2c 01 00 00       	call   800230 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800104:	89 f8                	mov    %edi,%eax
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800112:	c1 e0 07             	shl    $0x7,%eax
  800115:	29 d0                	sub    %edx,%eax
  800117:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80011d:	eb 28                	jmp    800147 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  80011f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 6f 1d 00 00       	call   801e99 <pipeisclosed>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	74 19                	je     800147 <umain+0x113>
			cprintf("\nRACE: pipe appears closed\n");
  80012e:	c7 04 24 19 25 80 00 	movl   $0x802519,(%esp)
  800135:	e8 0a 02 00 00       	call   800344 <cprintf>
			sys_env_destroy(r);
  80013a:	89 3c 24             	mov    %edi,(%esp)
  80013d:	e8 0f 0b 00 00       	call   800c51 <sys_env_destroy>
			exit();
  800142:	e8 e9 00 00 00       	call   800230 <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800147:	8b 43 54             	mov    0x54(%ebx),%eax
  80014a:	83 f8 02             	cmp    $0x2,%eax
  80014d:	74 d0                	je     80011f <umain+0xeb>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80014f:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  800156:	e8 e9 01 00 00       	call   800344 <cprintf>
	if (pipeisclosed(p[0]))
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 33 1d 00 00       	call   801e99 <pipeisclosed>
  800166:	85 c0                	test   %eax,%eax
  800168:	74 1c                	je     800186 <umain+0x152>
		panic("somehow the other end of p[0] got closed!");
  80016a:	c7 44 24 08 c4 24 80 	movl   $0x8024c4,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 f7 24 80 00 	movl   $0x8024f7,(%esp)
  800181:	e8 c6 00 00 00       	call   80024c <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800186:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 da 11 00 00       	call   801372 <fd_lookup>
  800198:	85 c0                	test   %eax,%eax
  80019a:	79 20                	jns    8001bc <umain+0x188>
		panic("cannot look up p[0]: %e", r);
  80019c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a0:	c7 44 24 08 4b 25 80 	movl   $0x80254b,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 f7 24 80 00 	movl   $0x8024f7,(%esp)
  8001b7:	e8 90 00 00 00       	call   80024c <_panic>
	(void) fd2data(fd);
  8001bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 3d 11 00 00       	call   801304 <fd2data>
	cprintf("race didn't happen\n");
  8001c7:	c7 04 24 63 25 80 00 	movl   $0x802563,(%esp)
  8001ce:	e8 71 01 00 00       	call   800344 <cprintf>
}
  8001d3:	83 c4 2c             	add    $0x2c,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    
	...

008001dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 10             	sub    $0x10,%esp
  8001e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8001ea:	e8 b4 0a 00 00       	call   800ca3 <sys_getenvid>
  8001ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001fb:	c1 e0 07             	shl    $0x7,%eax
  8001fe:	29 d0                	sub    %edx,%eax
  800200:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800205:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020a:	85 f6                	test   %esi,%esi
  80020c:	7e 07                	jle    800215 <libmain+0x39>
		binaryname = argv[0];
  80020e:	8b 03                	mov    (%ebx),%eax
  800210:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800215:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800219:	89 34 24             	mov    %esi,(%esp)
  80021c:	e8 13 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800221:	e8 0a 00 00 00       	call   800230 <exit>
}
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800236:	e8 a0 12 00 00       	call   8014db <close_all>
	sys_env_destroy(0);
  80023b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800242:	e8 0a 0a 00 00       	call   800c51 <sys_env_destroy>
}
  800247:	c9                   	leave  
  800248:	c3                   	ret    
  800249:	00 00                	add    %al,(%eax)
	...

0080024c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800254:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800257:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80025d:	e8 41 0a 00 00       	call   800ca3 <sys_getenvid>
  800262:	8b 55 0c             	mov    0xc(%ebp),%edx
  800265:	89 54 24 10          	mov    %edx,0x10(%esp)
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800270:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  80027f:	e8 c0 00 00 00       	call   800344 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800284:	89 74 24 04          	mov    %esi,0x4(%esp)
  800288:	8b 45 10             	mov    0x10(%ebp),%eax
  80028b:	89 04 24             	mov    %eax,(%esp)
  80028e:	e8 50 00 00 00       	call   8002e3 <vcprintf>
	cprintf("\n");
  800293:	c7 04 24 d5 2a 80 00 	movl   $0x802ad5,(%esp)
  80029a:	e8 a5 00 00 00       	call   800344 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80029f:	cc                   	int3   
  8002a0:	eb fd                	jmp    80029f <_panic+0x53>
	...

008002a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 14             	sub    $0x14,%esp
  8002ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ae:	8b 03                	mov    (%ebx),%eax
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b7:	40                   	inc    %eax
  8002b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bf:	75 19                	jne    8002da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c8:	00 
  8002c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	e8 40 09 00 00       	call   800c14 <sys_cputs>
		b->idx = 0;
  8002d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002da:	ff 43 04             	incl   0x4(%ebx)
}
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f3:	00 00 00 
	b.cnt = 0;
  8002f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	c7 04 24 a4 02 80 00 	movl   $0x8002a4,(%esp)
  80031f:	e8 82 01 00 00       	call   8004a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800324:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 d8 08 00 00       	call   800c14 <sys_cputs>

	return b.cnt;
}
  80033c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 87 ff ff ff       	call   8002e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    
	...

00800360 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 3c             	sub    $0x3c,%esp
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	89 d7                	mov    %edx,%edi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
  800377:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80037d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800380:	85 c0                	test   %eax,%eax
  800382:	75 08                	jne    80038c <printnum+0x2c>
  800384:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800387:	39 45 10             	cmp    %eax,0x10(%ebp)
  80038a:	77 57                	ja     8003e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80038c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800390:	4b                   	dec    %ebx
  800391:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800395:	8b 45 10             	mov    0x10(%ebp),%eax
  800398:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ab:	00 
  8003ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	e8 7e 1e 00 00       	call   80223c <__udivdi3>
  8003be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003cd:	89 fa                	mov    %edi,%edx
  8003cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003d2:	e8 89 ff ff ff       	call   800360 <printnum>
  8003d7:	eb 0f                	jmp    8003e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003dd:	89 34 24             	mov    %esi,(%esp)
  8003e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e3:	4b                   	dec    %ebx
  8003e4:	85 db                	test   %ebx,%ebx
  8003e6:	7f f1                	jg     8003d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003fe:	00 
  8003ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040c:	e8 4b 1f 00 00       	call   80235c <__umoddi3>
  800411:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800415:	0f be 80 a7 25 80 00 	movsbl 0x8025a7(%eax),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800422:	83 c4 3c             	add    $0x3c,%esp
  800425:	5b                   	pop    %ebx
  800426:	5e                   	pop    %esi
  800427:	5f                   	pop    %edi
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042d:	83 fa 01             	cmp    $0x1,%edx
  800430:	7e 0e                	jle    800440 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800432:	8b 10                	mov    (%eax),%edx
  800434:	8d 4a 08             	lea    0x8(%edx),%ecx
  800437:	89 08                	mov    %ecx,(%eax)
  800439:	8b 02                	mov    (%edx),%eax
  80043b:	8b 52 04             	mov    0x4(%edx),%edx
  80043e:	eb 22                	jmp    800462 <getuint+0x38>
	else if (lflag)
  800440:	85 d2                	test   %edx,%edx
  800442:	74 10                	je     800454 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 4a 04             	lea    0x4(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
  800452:	eb 0e                	jmp    800462 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800454:	8b 10                	mov    (%eax),%edx
  800456:	8d 4a 04             	lea    0x4(%edx),%ecx
  800459:	89 08                	mov    %ecx,(%eax)
  80045b:	8b 02                	mov    (%edx),%eax
  80045d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800462:	5d                   	pop    %ebp
  800463:	c3                   	ret    

00800464 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80046d:	8b 10                	mov    (%eax),%edx
  80046f:	3b 50 04             	cmp    0x4(%eax),%edx
  800472:	73 08                	jae    80047c <sprintputch+0x18>
		*b->buf++ = ch;
  800474:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800477:	88 0a                	mov    %cl,(%edx)
  800479:	42                   	inc    %edx
  80047a:	89 10                	mov    %edx,(%eax)
}
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800484:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048b:	8b 45 10             	mov    0x10(%ebp),%eax
  80048e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800492:	8b 45 0c             	mov    0xc(%ebp),%eax
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 02 00 00 00       	call   8004a6 <vprintfmt>
	va_end(ap);
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	57                   	push   %edi
  8004aa:	56                   	push   %esi
  8004ab:	53                   	push   %ebx
  8004ac:	83 ec 4c             	sub    $0x4c,%esp
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004b5:	eb 12                	jmp    8004c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	0f 84 6b 03 00 00    	je     80082a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c9:	0f b6 06             	movzbl (%esi),%eax
  8004cc:	46                   	inc    %esi
  8004cd:	83 f8 25             	cmp    $0x25,%eax
  8004d0:	75 e5                	jne    8004b7 <vprintfmt+0x11>
  8004d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ee:	eb 26                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004f7:	eb 1d                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800500:	eb 14                	jmp    800516 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800505:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80050c:	eb 08                	jmp    800516 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80050e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800511:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	0f b6 06             	movzbl (%esi),%eax
  800519:	8d 56 01             	lea    0x1(%esi),%edx
  80051c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051f:	8a 16                	mov    (%esi),%dl
  800521:	83 ea 23             	sub    $0x23,%edx
  800524:	80 fa 55             	cmp    $0x55,%dl
  800527:	0f 87 e1 02 00 00    	ja     80080e <vprintfmt+0x368>
  80052d:	0f b6 d2             	movzbl %dl,%edx
  800530:	ff 24 95 e0 26 80 00 	jmp    *0x8026e0(,%edx,4)
  800537:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80053f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800542:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800546:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800549:	8d 50 d0             	lea    -0x30(%eax),%edx
  80054c:	83 fa 09             	cmp    $0x9,%edx
  80054f:	77 2a                	ja     80057b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800551:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800552:	eb eb                	jmp    80053f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800562:	eb 17                	jmp    80057b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800564:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800568:	78 98                	js     800502 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80056d:	eb a7                	jmp    800516 <vprintfmt+0x70>
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800572:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800579:	eb 9b                	jmp    800516 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80057b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057f:	79 95                	jns    800516 <vprintfmt+0x70>
  800581:	eb 8b                	jmp    80050e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800583:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800587:	eb 8d                	jmp    800516 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 04 24             	mov    %eax,(%esp)
  80059b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005a1:	e9 23 ff ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	79 02                	jns    8005b7 <vprintfmt+0x111>
  8005b5:	f7 d8                	neg    %eax
  8005b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b9:	83 f8 0f             	cmp    $0xf,%eax
  8005bc:	7f 0b                	jg     8005c9 <vprintfmt+0x123>
  8005be:	8b 04 85 40 28 80 00 	mov    0x802840(,%eax,4),%eax
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	75 23                	jne    8005ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cd:	c7 44 24 08 bf 25 80 	movl   $0x8025bf,0x8(%esp)
  8005d4:	00 
  8005d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 9a fe ff ff       	call   80047e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e7:	e9 dd fe ff ff       	jmp    8004c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f0:	c7 44 24 08 ae 2a 80 	movl   $0x802aae,0x8(%esp)
  8005f7:	00 
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ff:	89 14 24             	mov    %edx,(%esp)
  800602:	e8 77 fe ff ff       	call   80047e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060a:	e9 ba fe ff ff       	jmp    8004c9 <vprintfmt+0x23>
  80060f:	89 f9                	mov    %edi,%ecx
  800611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800614:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 30                	mov    (%eax),%esi
  800622:	85 f6                	test   %esi,%esi
  800624:	75 05                	jne    80062b <vprintfmt+0x185>
				p = "(null)";
  800626:	be b8 25 80 00       	mov    $0x8025b8,%esi
			if (width > 0 && padc != '-')
  80062b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80062f:	0f 8e 84 00 00 00    	jle    8006b9 <vprintfmt+0x213>
  800635:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800639:	74 7e                	je     8006b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80063f:	89 34 24             	mov    %esi,(%esp)
  800642:	e8 8b 02 00 00       	call   8008d2 <strnlen>
  800647:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80064a:	29 c2                	sub    %eax,%edx
  80064c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80064f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800653:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800656:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800659:	89 de                	mov    %ebx,%esi
  80065b:	89 d3                	mov    %edx,%ebx
  80065d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065f:	eb 0b                	jmp    80066c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800661:	89 74 24 04          	mov    %esi,0x4(%esp)
  800665:	89 3c 24             	mov    %edi,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066b:	4b                   	dec    %ebx
  80066c:	85 db                	test   %ebx,%ebx
  80066e:	7f f1                	jg     800661 <vprintfmt+0x1bb>
  800670:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800673:	89 f3                	mov    %esi,%ebx
  800675:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80067b:	85 c0                	test   %eax,%eax
  80067d:	79 05                	jns    800684 <vprintfmt+0x1de>
  80067f:	b8 00 00 00 00       	mov    $0x0,%eax
  800684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800687:	29 c2                	sub    %eax,%edx
  800689:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80068c:	eb 2b                	jmp    8006b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80068e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800692:	74 18                	je     8006ac <vprintfmt+0x206>
  800694:	8d 50 e0             	lea    -0x20(%eax),%edx
  800697:	83 fa 5e             	cmp    $0x5e,%edx
  80069a:	76 10                	jbe    8006ac <vprintfmt+0x206>
					putch('?', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
  8006aa:	eb 0a                	jmp    8006b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8006b9:	0f be 06             	movsbl (%esi),%eax
  8006bc:	46                   	inc    %esi
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	74 21                	je     8006e2 <vprintfmt+0x23c>
  8006c1:	85 ff                	test   %edi,%edi
  8006c3:	78 c9                	js     80068e <vprintfmt+0x1e8>
  8006c5:	4f                   	dec    %edi
  8006c6:	79 c6                	jns    80068e <vprintfmt+0x1e8>
  8006c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cb:	89 de                	mov    %ebx,%esi
  8006cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006d0:	eb 18                	jmp    8006ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006df:	4b                   	dec    %ebx
  8006e0:	eb 08                	jmp    8006ea <vprintfmt+0x244>
  8006e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e5:	89 de                	mov    %ebx,%esi
  8006e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ea:	85 db                	test   %ebx,%ebx
  8006ec:	7f e4                	jg     8006d2 <vprintfmt+0x22c>
  8006ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f6:	e9 ce fd ff ff       	jmp    8004c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fb:	83 f9 01             	cmp    $0x1,%ecx
  8006fe:	7e 10                	jle    800710 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 50 08             	lea    0x8(%eax),%edx
  800706:	89 55 14             	mov    %edx,0x14(%ebp)
  800709:	8b 30                	mov    (%eax),%esi
  80070b:	8b 78 04             	mov    0x4(%eax),%edi
  80070e:	eb 26                	jmp    800736 <vprintfmt+0x290>
	else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	74 12                	je     800726 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 30                	mov    (%eax),%esi
  80071f:	89 f7                	mov    %esi,%edi
  800721:	c1 ff 1f             	sar    $0x1f,%edi
  800724:	eb 10                	jmp    800736 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 30                	mov    (%eax),%esi
  800731:	89 f7                	mov    %esi,%edi
  800733:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800736:	85 ff                	test   %edi,%edi
  800738:	78 0a                	js     800744 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073f:	e9 8c 00 00 00       	jmp    8007d0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800752:	f7 de                	neg    %esi
  800754:	83 d7 00             	adc    $0x0,%edi
  800757:	f7 df                	neg    %edi
			}
			base = 10;
  800759:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075e:	eb 70                	jmp    8007d0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800760:	89 ca                	mov    %ecx,%edx
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 c0 fc ff ff       	call   80042a <getuint>
  80076a:	89 c6                	mov    %eax,%esi
  80076c:	89 d7                	mov    %edx,%edi
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800773:	eb 5b                	jmp    8007d0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800775:	89 ca                	mov    %ecx,%edx
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
  80077a:	e8 ab fc ff ff       	call   80042a <getuint>
  80077f:	89 c6                	mov    %eax,%esi
  800781:	89 d7                	mov    %edx,%edi
			base = 8;
  800783:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800788:	eb 46                	jmp    8007d0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80078a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800795:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007af:	8b 30                	mov    (%eax),%esi
  8007b1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007bb:	eb 13                	jmp    8007d0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007bd:	89 ca                	mov    %ecx,%edx
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c2:	e8 63 fc ff ff       	call   80042a <getuint>
  8007c7:	89 c6                	mov    %eax,%esi
  8007c9:	89 d7                	mov    %edx,%edi
			base = 16;
  8007cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	89 34 24             	mov    %esi,(%esp)
  8007e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ea:	89 da                	mov    %ebx,%edx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	e8 6c fb ff ff       	call   800360 <printnum>
			break;
  8007f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007f7:	e9 cd fc ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	89 04 24             	mov    %eax,(%esp)
  800803:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800806:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800809:	e9 bb fc ff ff       	jmp    8004c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80080e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800812:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800819:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081c:	eb 01                	jmp    80081f <vprintfmt+0x379>
  80081e:	4e                   	dec    %esi
  80081f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800823:	75 f9                	jne    80081e <vprintfmt+0x378>
  800825:	e9 9f fc ff ff       	jmp    8004c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80082a:	83 c4 4c             	add    $0x4c,%esp
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5f                   	pop    %edi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 28             	sub    $0x28,%esp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800841:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800845:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800848:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084f:	85 c0                	test   %eax,%eax
  800851:	74 30                	je     800883 <vsnprintf+0x51>
  800853:	85 d2                	test   %edx,%edx
  800855:	7e 33                	jle    80088a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085e:	8b 45 10             	mov    0x10(%ebp),%eax
  800861:	89 44 24 08          	mov    %eax,0x8(%esp)
  800865:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086c:	c7 04 24 64 04 80 00 	movl   $0x800464,(%esp)
  800873:	e8 2e fc ff ff       	call   8004a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	eb 0c                	jmp    80088f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800888:	eb 05                	jmp    80088f <vsnprintf+0x5d>
  80088a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80088f:	c9                   	leave  
  800890:	c3                   	ret    

00800891 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089e:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	89 04 24             	mov    %eax,(%esp)
  8008b2:	e8 7b ff ff ff       	call   800832 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    
  8008b9:	00 00                	add    %al,(%eax)
	...

008008bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb 01                	jmp    8008ca <strlen+0xe>
		n++;
  8008c9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ce:	75 f9                	jne    8008c9 <strlen+0xd>
		n++;
	return n;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e0:	eb 01                	jmp    8008e3 <strnlen+0x11>
		n++;
  8008e2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e3:	39 d0                	cmp    %edx,%eax
  8008e5:	74 06                	je     8008ed <strnlen+0x1b>
  8008e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008eb:	75 f5                	jne    8008e2 <strnlen+0x10>
		n++;
	return n;
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	53                   	push   %ebx
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800901:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800904:	42                   	inc    %edx
  800905:	84 c9                	test   %cl,%cl
  800907:	75 f5                	jne    8008fe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800909:	5b                   	pop    %ebx
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800916:	89 1c 24             	mov    %ebx,(%esp)
  800919:	e8 9e ff ff ff       	call   8008bc <strlen>
	strcpy(dst + len, src);
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	89 54 24 04          	mov    %edx,0x4(%esp)
  800925:	01 d8                	add    %ebx,%eax
  800927:	89 04 24             	mov    %eax,(%esp)
  80092a:	e8 c0 ff ff ff       	call   8008ef <strcpy>
	return dst;
}
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	83 c4 08             	add    $0x8,%esp
  800934:	5b                   	pop    %ebx
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800942:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800945:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094a:	eb 0c                	jmp    800958 <strncpy+0x21>
		*dst++ = *src;
  80094c:	8a 1a                	mov    (%edx),%bl
  80094e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800951:	80 3a 01             	cmpb   $0x1,(%edx)
  800954:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800957:	41                   	inc    %ecx
  800958:	39 f1                	cmp    %esi,%ecx
  80095a:	75 f0                	jne    80094c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 75 08             	mov    0x8(%ebp),%esi
  800968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096e:	85 d2                	test   %edx,%edx
  800970:	75 0a                	jne    80097c <strlcpy+0x1c>
  800972:	89 f0                	mov    %esi,%eax
  800974:	eb 1a                	jmp    800990 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800976:	88 18                	mov    %bl,(%eax)
  800978:	40                   	inc    %eax
  800979:	41                   	inc    %ecx
  80097a:	eb 02                	jmp    80097e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80097e:	4a                   	dec    %edx
  80097f:	74 0a                	je     80098b <strlcpy+0x2b>
  800981:	8a 19                	mov    (%ecx),%bl
  800983:	84 db                	test   %bl,%bl
  800985:	75 ef                	jne    800976 <strlcpy+0x16>
  800987:	89 c2                	mov    %eax,%edx
  800989:	eb 02                	jmp    80098d <strlcpy+0x2d>
  80098b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80098d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800990:	29 f0                	sub    %esi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099f:	eb 02                	jmp    8009a3 <strcmp+0xd>
		p++, q++;
  8009a1:	41                   	inc    %ecx
  8009a2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a3:	8a 01                	mov    (%ecx),%al
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 04                	je     8009ad <strcmp+0x17>
  8009a9:	3a 02                	cmp    (%edx),%al
  8009ab:	74 f4                	je     8009a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ad:	0f b6 c0             	movzbl %al,%eax
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	29 d0                	sub    %edx,%eax
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009c4:	eb 03                	jmp    8009c9 <strncmp+0x12>
		n--, p++, q++;
  8009c6:	4a                   	dec    %edx
  8009c7:	40                   	inc    %eax
  8009c8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c9:	85 d2                	test   %edx,%edx
  8009cb:	74 14                	je     8009e1 <strncmp+0x2a>
  8009cd:	8a 18                	mov    (%eax),%bl
  8009cf:	84 db                	test   %bl,%bl
  8009d1:	74 04                	je     8009d7 <strncmp+0x20>
  8009d3:	3a 19                	cmp    (%ecx),%bl
  8009d5:	74 ef                	je     8009c6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d7:	0f b6 00             	movzbl (%eax),%eax
  8009da:	0f b6 11             	movzbl (%ecx),%edx
  8009dd:	29 d0                	sub    %edx,%eax
  8009df:	eb 05                	jmp    8009e6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f2:	eb 05                	jmp    8009f9 <strchr+0x10>
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 0c                	je     800a04 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f8:	40                   	inc    %eax
  8009f9:	8a 10                	mov    (%eax),%dl
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	75 f5                	jne    8009f4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a0f:	eb 05                	jmp    800a16 <strfind+0x10>
		if (*s == c)
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 07                	je     800a1c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a15:	40                   	inc    %eax
  800a16:	8a 10                	mov    (%eax),%dl
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	75 f5                	jne    800a11 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2d:	85 c9                	test   %ecx,%ecx
  800a2f:	74 30                	je     800a61 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a37:	75 25                	jne    800a5e <memset+0x40>
  800a39:	f6 c1 03             	test   $0x3,%cl
  800a3c:	75 20                	jne    800a5e <memset+0x40>
		c &= 0xFF;
  800a3e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a41:	89 d3                	mov    %edx,%ebx
  800a43:	c1 e3 08             	shl    $0x8,%ebx
  800a46:	89 d6                	mov    %edx,%esi
  800a48:	c1 e6 18             	shl    $0x18,%esi
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	c1 e0 10             	shl    $0x10,%eax
  800a50:	09 f0                	or     %esi,%eax
  800a52:	09 d0                	or     %edx,%eax
  800a54:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a56:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a59:	fc                   	cld    
  800a5a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5c:	eb 03                	jmp    800a61 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5e:	fc                   	cld    
  800a5f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a61:	89 f8                	mov    %edi,%eax
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a76:	39 c6                	cmp    %eax,%esi
  800a78:	73 34                	jae    800aae <memmove+0x46>
  800a7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7d:	39 d0                	cmp    %edx,%eax
  800a7f:	73 2d                	jae    800aae <memmove+0x46>
		s += n;
		d += n;
  800a81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a84:	f6 c2 03             	test   $0x3,%dl
  800a87:	75 1b                	jne    800aa4 <memmove+0x3c>
  800a89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8f:	75 13                	jne    800aa4 <memmove+0x3c>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 0e                	jne    800aa4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a96:	83 ef 04             	sub    $0x4,%edi
  800a99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a9f:	fd                   	std    
  800aa0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa2:	eb 07                	jmp    800aab <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa4:	4f                   	dec    %edi
  800aa5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa8:	fd                   	std    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aab:	fc                   	cld    
  800aac:	eb 20                	jmp    800ace <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab4:	75 13                	jne    800ac9 <memmove+0x61>
  800ab6:	a8 03                	test   $0x3,%al
  800ab8:	75 0f                	jne    800ac9 <memmove+0x61>
  800aba:	f6 c1 03             	test   $0x3,%cl
  800abd:	75 0a                	jne    800ac9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ac2:	89 c7                	mov    %eax,%edi
  800ac4:	fc                   	cld    
  800ac5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac7:	eb 05                	jmp    800ace <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac9:	89 c7                	mov    %eax,%edi
  800acb:	fc                   	cld    
  800acc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad8:	8b 45 10             	mov    0x10(%ebp),%eax
  800adb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	89 04 24             	mov    %eax,(%esp)
  800aec:	e8 77 ff ff ff       	call   800a68 <memmove>
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	eb 16                	jmp    800b1f <memcmp+0x2c>
		if (*s1 != *s2)
  800b09:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b0c:	42                   	inc    %edx
  800b0d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b11:	38 c8                	cmp    %cl,%al
  800b13:	74 0a                	je     800b1f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b15:	0f b6 c0             	movzbl %al,%eax
  800b18:	0f b6 c9             	movzbl %cl,%ecx
  800b1b:	29 c8                	sub    %ecx,%eax
  800b1d:	eb 09                	jmp    800b28 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1f:	39 da                	cmp    %ebx,%edx
  800b21:	75 e6                	jne    800b09 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3b:	eb 05                	jmp    800b42 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3d:	38 08                	cmp    %cl,(%eax)
  800b3f:	74 05                	je     800b46 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b41:	40                   	inc    %eax
  800b42:	39 d0                	cmp    %edx,%eax
  800b44:	72 f7                	jb     800b3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b54:	eb 01                	jmp    800b57 <strtol+0xf>
		s++;
  800b56:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b57:	8a 02                	mov    (%edx),%al
  800b59:	3c 20                	cmp    $0x20,%al
  800b5b:	74 f9                	je     800b56 <strtol+0xe>
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	74 f5                	je     800b56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b61:	3c 2b                	cmp    $0x2b,%al
  800b63:	75 08                	jne    800b6d <strtol+0x25>
		s++;
  800b65:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b66:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6b:	eb 13                	jmp    800b80 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b6d:	3c 2d                	cmp    $0x2d,%al
  800b6f:	75 0a                	jne    800b7b <strtol+0x33>
		s++, neg = 1;
  800b71:	8d 52 01             	lea    0x1(%edx),%edx
  800b74:	bf 01 00 00 00       	mov    $0x1,%edi
  800b79:	eb 05                	jmp    800b80 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	74 05                	je     800b89 <strtol+0x41>
  800b84:	83 fb 10             	cmp    $0x10,%ebx
  800b87:	75 28                	jne    800bb1 <strtol+0x69>
  800b89:	8a 02                	mov    (%edx),%al
  800b8b:	3c 30                	cmp    $0x30,%al
  800b8d:	75 10                	jne    800b9f <strtol+0x57>
  800b8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b93:	75 0a                	jne    800b9f <strtol+0x57>
		s += 2, base = 16;
  800b95:	83 c2 02             	add    $0x2,%edx
  800b98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9d:	eb 12                	jmp    800bb1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	75 0e                	jne    800bb1 <strtol+0x69>
  800ba3:	3c 30                	cmp    $0x30,%al
  800ba5:	75 05                	jne    800bac <strtol+0x64>
		s++, base = 8;
  800ba7:	42                   	inc    %edx
  800ba8:	b3 08                	mov    $0x8,%bl
  800baa:	eb 05                	jmp    800bb1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bac:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb8:	8a 0a                	mov    (%edx),%cl
  800bba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bbd:	80 fb 09             	cmp    $0x9,%bl
  800bc0:	77 08                	ja     800bca <strtol+0x82>
			dig = *s - '0';
  800bc2:	0f be c9             	movsbl %cl,%ecx
  800bc5:	83 e9 30             	sub    $0x30,%ecx
  800bc8:	eb 1e                	jmp    800be8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bca:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 08                	ja     800bda <strtol+0x92>
			dig = *s - 'a' + 10;
  800bd2:	0f be c9             	movsbl %cl,%ecx
  800bd5:	83 e9 57             	sub    $0x57,%ecx
  800bd8:	eb 0e                	jmp    800be8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bdd:	80 fb 19             	cmp    $0x19,%bl
  800be0:	77 12                	ja     800bf4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800be2:	0f be c9             	movsbl %cl,%ecx
  800be5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800be8:	39 f1                	cmp    %esi,%ecx
  800bea:	7d 0c                	jge    800bf8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bec:	42                   	inc    %edx
  800bed:	0f af c6             	imul   %esi,%eax
  800bf0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bf2:	eb c4                	jmp    800bb8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bf4:	89 c1                	mov    %eax,%ecx
  800bf6:	eb 02                	jmp    800bfa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bfa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfe:	74 05                	je     800c05 <strtol+0xbd>
		*endptr = (char *) s;
  800c00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c03:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c05:	85 ff                	test   %edi,%edi
  800c07:	74 04                	je     800c0d <strtol+0xc5>
  800c09:	89 c8                	mov    %ecx,%eax
  800c0b:	f7 d8                	neg    %eax
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
	...

00800c14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 c3                	mov    %eax,%ebx
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	89 c6                	mov    %eax,%esi
  800c2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c42:	89 d1                	mov    %edx,%ecx
  800c44:	89 d3                	mov    %edx,%ebx
  800c46:	89 d7                	mov    %edx,%edi
  800c48:	89 d6                	mov    %edx,%esi
  800c4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 cb                	mov    %ecx,%ebx
  800c69:	89 cf                	mov    %ecx,%edi
  800c6b:	89 ce                	mov    %ecx,%esi
  800c6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7e 28                	jle    800c9b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800c86:	00 
  800c87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8e:	00 
  800c8f:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800c96:	e8 b1 f5 ff ff       	call   80024c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9b:	83 c4 2c             	add    $0x2c,%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_yield>:

void
sys_yield(void)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	be 00 00 00 00       	mov    $0x0,%esi
  800cef:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 f7                	mov    %esi,%edi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 28                	jle    800d2d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d09:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d10:	00 
  800d11:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800d18:	00 
  800d19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d20:	00 
  800d21:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800d28:	e8 1f f5 ff ff       	call   80024c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2d:	83 c4 2c             	add    $0x2c,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d43:	8b 75 18             	mov    0x18(%ebp),%esi
  800d46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7e 28                	jle    800d80 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d63:	00 
  800d64:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800d6b:	00 
  800d6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d73:	00 
  800d74:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800d7b:	e8 cc f4 ff ff       	call   80024c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d80:	83 c4 2c             	add    $0x2c,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d96:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 df                	mov    %ebx,%edi
  800da3:	89 de                	mov    %ebx,%esi
  800da5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 28                	jle    800dd3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800db6:	00 
  800db7:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc6:	00 
  800dc7:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800dce:	e8 79 f4 ff ff       	call   80024c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd3:	83 c4 2c             	add    $0x2c,%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
  800de1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 df                	mov    %ebx,%edi
  800df6:	89 de                	mov    %ebx,%esi
  800df8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	7e 28                	jle    800e26 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e02:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e09:	00 
  800e0a:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e19:	00 
  800e1a:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800e21:	e8 26 f4 ff ff       	call   80024c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e26:	83 c4 2c             	add    $0x2c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	89 de                	mov    %ebx,%esi
  800e4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 28                	jle    800e79 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e55:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800e64:	00 
  800e65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6c:	00 
  800e6d:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800e74:	e8 d3 f3 ff ff       	call   80024c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e79:	83 c4 2c             	add    $0x2c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	89 de                	mov    %ebx,%esi
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 28                	jle    800ecc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800ec7:	e8 80 f3 ff ff       	call   80024c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ecc:	83 c4 2c             	add    $0x2c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eda:	be 00 00 00 00       	mov    $0x0,%esi
  800edf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f05:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0d:	89 cb                	mov    %ecx,%ebx
  800f0f:	89 cf                	mov    %ecx,%edi
  800f11:	89 ce                	mov    %ecx,%esi
  800f13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	7e 28                	jle    800f41 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f24:	00 
  800f25:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800f3c:	e8 0b f3 ff ff       	call   80024c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f41:	83 c4 2c             	add    $0x2c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	00 00                	add    %al,(%eax)
	...

00800f4c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 24             	sub    $0x24,%esp
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f56:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800f58:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f5c:	75 2d                	jne    800f8b <pgfault+0x3f>
  800f5e:	89 d8                	mov    %ebx,%eax
  800f60:	c1 e8 0c             	shr    $0xc,%eax
  800f63:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6a:	f6 c4 08             	test   $0x8,%ah
  800f6d:	75 1c                	jne    800f8b <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800f6f:	c7 44 24 08 cc 28 80 	movl   $0x8028cc,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  800f86:	e8 c1 f2 ff ff       	call   80024c <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f8b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f92:	00 
  800f93:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f9a:	00 
  800f9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa2:	e8 3a fd ff ff       	call   800ce1 <sys_page_alloc>
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	79 20                	jns    800fcb <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800fab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800faf:	c7 44 24 08 3b 29 80 	movl   $0x80293b,0x8(%esp)
  800fb6:	00 
  800fb7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fbe:	00 
  800fbf:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  800fc6:	e8 81 f2 ff ff       	call   80024c <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800fcb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800fd1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fd8:	00 
  800fd9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fdd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fe4:	e8 e9 fa ff ff       	call   800ad2 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800fe9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ff0:	00 
  800ff1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ff5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100c:	e8 24 fd ff ff       	call   800d35 <sys_page_map>
  801011:	85 c0                	test   %eax,%eax
  801013:	79 20                	jns    801035 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  801015:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801019:	c7 44 24 08 4e 29 80 	movl   $0x80294e,0x8(%esp)
  801020:	00 
  801021:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801028:	00 
  801029:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  801030:	e8 17 f2 ff ff       	call   80024c <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801035:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80103c:	00 
  80103d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801044:	e8 3f fd ff ff       	call   800d88 <sys_page_unmap>
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 20                	jns    80106d <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  80104d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801051:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801058:	00 
  801059:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801060:	00 
  801061:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  801068:	e8 df f1 ff ff       	call   80024c <_panic>
}
  80106d:	83 c4 24             	add    $0x24,%esp
  801070:	5b                   	pop    %ebx
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  80107c:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  801083:	e8 e4 0f 00 00       	call   80206c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801088:	ba 07 00 00 00       	mov    $0x7,%edx
  80108d:	89 d0                	mov    %edx,%eax
  80108f:	cd 30                	int    $0x30
  801091:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801094:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  801097:	85 c0                	test   %eax,%eax
  801099:	79 1c                	jns    8010b7 <fork+0x44>
		panic("sys_exofork failed\n");
  80109b:	c7 44 24 08 72 29 80 	movl   $0x802972,0x8(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8010aa:	00 
  8010ab:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  8010b2:	e8 95 f1 ff ff       	call   80024c <_panic>
	if(c_envid == 0){
  8010b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010bb:	75 25                	jne    8010e2 <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010bd:	e8 e1 fb ff ff       	call   800ca3 <sys_getenvid>
  8010c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010c7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010ce:	c1 e0 07             	shl    $0x7,%eax
  8010d1:	29 d0                	sub    %edx,%eax
  8010d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010dd:	e9 e3 01 00 00       	jmp    8012c5 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  8010e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  8010e7:	89 d8                	mov    %ebx,%eax
  8010e9:	c1 e8 16             	shr    $0x16,%eax
  8010ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f3:	a8 01                	test   $0x1,%al
  8010f5:	0f 84 0b 01 00 00    	je     801206 <fork+0x193>
  8010fb:	89 de                	mov    %ebx,%esi
  8010fd:	c1 ee 0c             	shr    $0xc,%esi
  801100:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801107:	a8 05                	test   $0x5,%al
  801109:	0f 84 f7 00 00 00    	je     801206 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  80110f:	89 f7                	mov    %esi,%edi
  801111:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  801114:	e8 8a fb ff ff       	call   800ca3 <sys_getenvid>
  801119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  80111c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801123:	a8 02                	test   $0x2,%al
  801125:	75 10                	jne    801137 <fork+0xc4>
  801127:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80112e:	f6 c4 08             	test   $0x8,%ah
  801131:	0f 84 89 00 00 00    	je     8011c0 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  801137:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80113e:	00 
  80113f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801143:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80114e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 dc fb ff ff       	call   800d35 <sys_page_map>
  801159:	85 c0                	test   %eax,%eax
  80115b:	79 20                	jns    80117d <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  80115d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801161:	c7 44 24 08 86 29 80 	movl   $0x802986,0x8(%esp)
  801168:	00 
  801169:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  801170:	00 
  801171:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  801178:	e8 cf f0 ff ff       	call   80024c <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  80117d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801184:	00 
  801185:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801189:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801190:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801194:	89 04 24             	mov    %eax,(%esp)
  801197:	e8 99 fb ff ff       	call   800d35 <sys_page_map>
  80119c:	85 c0                	test   %eax,%eax
  80119e:	79 66                	jns    801206 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8011a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a4:	c7 44 24 08 86 29 80 	movl   $0x802986,0x8(%esp)
  8011ab:	00 
  8011ac:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8011b3:	00 
  8011b4:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  8011bb:	e8 8c f0 ff ff       	call   80024c <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  8011c0:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011c7:	00 
  8011c8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011da:	89 04 24             	mov    %eax,(%esp)
  8011dd:	e8 53 fb ff ff       	call   800d35 <sys_page_map>
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	79 20                	jns    801206 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  8011e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ea:	c7 44 24 08 86 29 80 	movl   $0x802986,0x8(%esp)
  8011f1:	00 
  8011f2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8011f9:	00 
  8011fa:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  801201:	e8 46 f0 ff ff       	call   80024c <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  801206:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80120c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801212:	0f 85 cf fe ff ff    	jne    8010e7 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801218:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80121f:	00 
  801220:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801227:	ee 
  801228:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80122b:	89 04 24             	mov    %eax,(%esp)
  80122e:	e8 ae fa ff ff       	call   800ce1 <sys_page_alloc>
  801233:	85 c0                	test   %eax,%eax
  801235:	79 20                	jns    801257 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  801237:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123b:	c7 44 24 08 98 29 80 	movl   $0x802998,0x8(%esp)
  801242:	00 
  801243:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80124a:	00 
  80124b:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  801252:	e8 f5 ef ff ff       	call   80024c <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801257:	c7 44 24 04 b8 20 80 	movl   $0x8020b8,0x4(%esp)
  80125e:	00 
  80125f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801262:	89 04 24             	mov    %eax,(%esp)
  801265:	e8 17 fc ff ff       	call   800e81 <sys_env_set_pgfault_upcall>
  80126a:	85 c0                	test   %eax,%eax
  80126c:	79 20                	jns    80128e <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80126e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801272:	c7 44 24 08 10 29 80 	movl   $0x802910,0x8(%esp)
  801279:	00 
  80127a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801281:	00 
  801282:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  801289:	e8 be ef ff ff       	call   80024c <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  80128e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801295:	00 
  801296:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801299:	89 04 24             	mov    %eax,(%esp)
  80129c:	e8 3a fb ff ff       	call   800ddb <sys_env_set_status>
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	79 20                	jns    8012c5 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  8012a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a9:	c7 44 24 08 ac 29 80 	movl   $0x8029ac,0x8(%esp)
  8012b0:	00 
  8012b1:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8012b8:	00 
  8012b9:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  8012c0:	e8 87 ef ff ff       	call   80024c <_panic>
 
	return c_envid;	
}
  8012c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c8:	83 c4 3c             	add    $0x3c,%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5e                   	pop    %esi
  8012cd:	5f                   	pop    %edi
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <sfork>:

// Challenge!
int
sfork(void)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012d6:	c7 44 24 08 c4 29 80 	movl   $0x8029c4,0x8(%esp)
  8012dd:	00 
  8012de:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8012e5:	00 
  8012e6:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  8012ed:	e8 5a ef ff ff       	call   80024c <_panic>
	...

008012f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80130a:	8b 45 08             	mov    0x8(%ebp),%eax
  80130d:	89 04 24             	mov    %eax,(%esp)
  801310:	e8 df ff ff ff       	call   8012f4 <fd2num>
  801315:	05 20 00 0d 00       	add    $0xd0020,%eax
  80131a:	c1 e0 0c             	shl    $0xc,%eax
}
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801326:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80132b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	c1 ea 16             	shr    $0x16,%edx
  801332:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801339:	f6 c2 01             	test   $0x1,%dl
  80133c:	74 11                	je     80134f <fd_alloc+0x30>
  80133e:	89 c2                	mov    %eax,%edx
  801340:	c1 ea 0c             	shr    $0xc,%edx
  801343:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134a:	f6 c2 01             	test   $0x1,%dl
  80134d:	75 09                	jne    801358 <fd_alloc+0x39>
			*fd_store = fd;
  80134f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801351:	b8 00 00 00 00       	mov    $0x0,%eax
  801356:	eb 17                	jmp    80136f <fd_alloc+0x50>
  801358:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80135d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801362:	75 c7                	jne    80132b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801364:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80136a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80136f:	5b                   	pop    %ebx
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801378:	83 f8 1f             	cmp    $0x1f,%eax
  80137b:	77 36                	ja     8013b3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80137d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801382:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801385:	89 c2                	mov    %eax,%edx
  801387:	c1 ea 16             	shr    $0x16,%edx
  80138a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801391:	f6 c2 01             	test   $0x1,%dl
  801394:	74 24                	je     8013ba <fd_lookup+0x48>
  801396:	89 c2                	mov    %eax,%edx
  801398:	c1 ea 0c             	shr    $0xc,%edx
  80139b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a2:	f6 c2 01             	test   $0x1,%dl
  8013a5:	74 1a                	je     8013c1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013aa:	89 02                	mov    %eax,(%edx)
	return 0;
  8013ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b1:	eb 13                	jmp    8013c6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b8:	eb 0c                	jmp    8013c6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013bf:	eb 05                	jmp    8013c6 <fd_lookup+0x54>
  8013c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 14             	sub    $0x14,%esp
  8013cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8013d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013da:	eb 0e                	jmp    8013ea <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8013dc:	39 08                	cmp    %ecx,(%eax)
  8013de:	75 09                	jne    8013e9 <dev_lookup+0x21>
			*dev = devtab[i];
  8013e0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8013e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e7:	eb 33                	jmp    80141c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013e9:	42                   	inc    %edx
  8013ea:	8b 04 95 5c 2a 80 00 	mov    0x802a5c(,%edx,4),%eax
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	75 e7                	jne    8013dc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8013fa:	8b 40 48             	mov    0x48(%eax),%eax
  8013fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801401:	89 44 24 04          	mov    %eax,0x4(%esp)
  801405:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  80140c:	e8 33 ef ff ff       	call   800344 <cprintf>
	*dev = 0;
  801411:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80141c:	83 c4 14             	add    $0x14,%esp
  80141f:	5b                   	pop    %ebx
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	56                   	push   %esi
  801426:	53                   	push   %ebx
  801427:	83 ec 30             	sub    $0x30,%esp
  80142a:	8b 75 08             	mov    0x8(%ebp),%esi
  80142d:	8a 45 0c             	mov    0xc(%ebp),%al
  801430:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801433:	89 34 24             	mov    %esi,(%esp)
  801436:	e8 b9 fe ff ff       	call   8012f4 <fd2num>
  80143b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80143e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801442:	89 04 24             	mov    %eax,(%esp)
  801445:	e8 28 ff ff ff       	call   801372 <fd_lookup>
  80144a:	89 c3                	mov    %eax,%ebx
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 05                	js     801455 <fd_close+0x33>
	    || fd != fd2)
  801450:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801453:	74 0d                	je     801462 <fd_close+0x40>
		return (must_exist ? r : 0);
  801455:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801459:	75 46                	jne    8014a1 <fd_close+0x7f>
  80145b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801460:	eb 3f                	jmp    8014a1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801462:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801465:	89 44 24 04          	mov    %eax,0x4(%esp)
  801469:	8b 06                	mov    (%esi),%eax
  80146b:	89 04 24             	mov    %eax,(%esp)
  80146e:	e8 55 ff ff ff       	call   8013c8 <dev_lookup>
  801473:	89 c3                	mov    %eax,%ebx
  801475:	85 c0                	test   %eax,%eax
  801477:	78 18                	js     801491 <fd_close+0x6f>
		if (dev->dev_close)
  801479:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147c:	8b 40 10             	mov    0x10(%eax),%eax
  80147f:	85 c0                	test   %eax,%eax
  801481:	74 09                	je     80148c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801483:	89 34 24             	mov    %esi,(%esp)
  801486:	ff d0                	call   *%eax
  801488:	89 c3                	mov    %eax,%ebx
  80148a:	eb 05                	jmp    801491 <fd_close+0x6f>
		else
			r = 0;
  80148c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801491:	89 74 24 04          	mov    %esi,0x4(%esp)
  801495:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80149c:	e8 e7 f8 ff ff       	call   800d88 <sys_page_unmap>
	return r;
}
  8014a1:	89 d8                	mov    %ebx,%eax
  8014a3:	83 c4 30             	add    $0x30,%esp
  8014a6:	5b                   	pop    %ebx
  8014a7:	5e                   	pop    %esi
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	89 04 24             	mov    %eax,(%esp)
  8014bd:	e8 b0 fe ff ff       	call   801372 <fd_lookup>
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 13                	js     8014d9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014cd:	00 
  8014ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d1:	89 04 24             	mov    %eax,(%esp)
  8014d4:	e8 49 ff ff ff       	call   801422 <fd_close>
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <close_all>:

void
close_all(void)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014e7:	89 1c 24             	mov    %ebx,(%esp)
  8014ea:	e8 bb ff ff ff       	call   8014aa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ef:	43                   	inc    %ebx
  8014f0:	83 fb 20             	cmp    $0x20,%ebx
  8014f3:	75 f2                	jne    8014e7 <close_all+0xc>
		close(i);
}
  8014f5:	83 c4 14             	add    $0x14,%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	57                   	push   %edi
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	83 ec 4c             	sub    $0x4c,%esp
  801504:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801507:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80150a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150e:	8b 45 08             	mov    0x8(%ebp),%eax
  801511:	89 04 24             	mov    %eax,(%esp)
  801514:	e8 59 fe ff ff       	call   801372 <fd_lookup>
  801519:	89 c3                	mov    %eax,%ebx
  80151b:	85 c0                	test   %eax,%eax
  80151d:	0f 88 e1 00 00 00    	js     801604 <dup+0x109>
		return r;
	close(newfdnum);
  801523:	89 3c 24             	mov    %edi,(%esp)
  801526:	e8 7f ff ff ff       	call   8014aa <close>

	newfd = INDEX2FD(newfdnum);
  80152b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801531:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801537:	89 04 24             	mov    %eax,(%esp)
  80153a:	e8 c5 fd ff ff       	call   801304 <fd2data>
  80153f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801541:	89 34 24             	mov    %esi,(%esp)
  801544:	e8 bb fd ff ff       	call   801304 <fd2data>
  801549:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80154c:	89 d8                	mov    %ebx,%eax
  80154e:	c1 e8 16             	shr    $0x16,%eax
  801551:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801558:	a8 01                	test   $0x1,%al
  80155a:	74 46                	je     8015a2 <dup+0xa7>
  80155c:	89 d8                	mov    %ebx,%eax
  80155e:	c1 e8 0c             	shr    $0xc,%eax
  801561:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801568:	f6 c2 01             	test   $0x1,%dl
  80156b:	74 35                	je     8015a2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80156d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801574:	25 07 0e 00 00       	and    $0xe07,%eax
  801579:	89 44 24 10          	mov    %eax,0x10(%esp)
  80157d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801584:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80158b:	00 
  80158c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801590:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801597:	e8 99 f7 ff ff       	call   800d35 <sys_page_map>
  80159c:	89 c3                	mov    %eax,%ebx
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 3b                	js     8015dd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015a5:	89 c2                	mov    %eax,%edx
  8015a7:	c1 ea 0c             	shr    $0xc,%edx
  8015aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015b1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015c6:	00 
  8015c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d2:	e8 5e f7 ff ff       	call   800d35 <sys_page_map>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	79 25                	jns    801602 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e8:	e8 9b f7 ff ff       	call   800d88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fb:	e8 88 f7 ff ff       	call   800d88 <sys_page_unmap>
	return r;
  801600:	eb 02                	jmp    801604 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801602:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801604:	89 d8                	mov    %ebx,%eax
  801606:	83 c4 4c             	add    $0x4c,%esp
  801609:	5b                   	pop    %ebx
  80160a:	5e                   	pop    %esi
  80160b:	5f                   	pop    %edi
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	53                   	push   %ebx
  801612:	83 ec 24             	sub    $0x24,%esp
  801615:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801618:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161f:	89 1c 24             	mov    %ebx,(%esp)
  801622:	e8 4b fd ff ff       	call   801372 <fd_lookup>
  801627:	85 c0                	test   %eax,%eax
  801629:	78 6d                	js     801698 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	8b 00                	mov    (%eax),%eax
  801637:	89 04 24             	mov    %eax,(%esp)
  80163a:	e8 89 fd ff ff       	call   8013c8 <dev_lookup>
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 55                	js     801698 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	8b 50 08             	mov    0x8(%eax),%edx
  801649:	83 e2 03             	and    $0x3,%edx
  80164c:	83 fa 01             	cmp    $0x1,%edx
  80164f:	75 23                	jne    801674 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801651:	a1 04 40 80 00       	mov    0x804004,%eax
  801656:	8b 40 48             	mov    0x48(%eax),%eax
  801659:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80165d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801661:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  801668:	e8 d7 ec ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  80166d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801672:	eb 24                	jmp    801698 <read+0x8a>
	}
	if (!dev->dev_read)
  801674:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801677:	8b 52 08             	mov    0x8(%edx),%edx
  80167a:	85 d2                	test   %edx,%edx
  80167c:	74 15                	je     801693 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80167e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801681:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801685:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801688:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	ff d2                	call   *%edx
  801691:	eb 05                	jmp    801698 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801693:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801698:	83 c4 24             	add    $0x24,%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	57                   	push   %edi
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 1c             	sub    $0x1c,%esp
  8016a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b2:	eb 23                	jmp    8016d7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016b4:	89 f0                	mov    %esi,%eax
  8016b6:	29 d8                	sub    %ebx,%eax
  8016b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016bf:	01 d8                	add    %ebx,%eax
  8016c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c5:	89 3c 24             	mov    %edi,(%esp)
  8016c8:	e8 41 ff ff ff       	call   80160e <read>
		if (m < 0)
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 10                	js     8016e1 <readn+0x43>
			return m;
		if (m == 0)
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	74 0a                	je     8016df <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d5:	01 c3                	add    %eax,%ebx
  8016d7:	39 f3                	cmp    %esi,%ebx
  8016d9:	72 d9                	jb     8016b4 <readn+0x16>
  8016db:	89 d8                	mov    %ebx,%eax
  8016dd:	eb 02                	jmp    8016e1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016df:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016e1:	83 c4 1c             	add    $0x1c,%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5e                   	pop    %esi
  8016e6:	5f                   	pop    %edi
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 24             	sub    $0x24,%esp
  8016f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fa:	89 1c 24             	mov    %ebx,(%esp)
  8016fd:	e8 70 fc ff ff       	call   801372 <fd_lookup>
  801702:	85 c0                	test   %eax,%eax
  801704:	78 68                	js     80176e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	8b 00                	mov    (%eax),%eax
  801712:	89 04 24             	mov    %eax,(%esp)
  801715:	e8 ae fc ff ff       	call   8013c8 <dev_lookup>
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 50                	js     80176e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801721:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801725:	75 23                	jne    80174a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801727:	a1 04 40 80 00       	mov    0x804004,%eax
  80172c:	8b 40 48             	mov    0x48(%eax),%eax
  80172f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801733:	89 44 24 04          	mov    %eax,0x4(%esp)
  801737:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  80173e:	e8 01 ec ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  801743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801748:	eb 24                	jmp    80176e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80174a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174d:	8b 52 0c             	mov    0xc(%edx),%edx
  801750:	85 d2                	test   %edx,%edx
  801752:	74 15                	je     801769 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801754:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801757:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80175b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801762:	89 04 24             	mov    %eax,(%esp)
  801765:	ff d2                	call   *%edx
  801767:	eb 05                	jmp    80176e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801769:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80176e:	83 c4 24             	add    $0x24,%esp
  801771:	5b                   	pop    %ebx
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <seek>:

int
seek(int fdnum, off_t offset)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80177a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	89 04 24             	mov    %eax,(%esp)
  801787:	e8 e6 fb ff ff       	call   801372 <fd_lookup>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 0e                	js     80179e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801790:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801793:	8b 55 0c             	mov    0xc(%ebp),%edx
  801796:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801799:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 24             	sub    $0x24,%esp
  8017a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	89 1c 24             	mov    %ebx,(%esp)
  8017b4:	e8 b9 fb ff ff       	call   801372 <fd_lookup>
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 61                	js     80181e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c7:	8b 00                	mov    (%eax),%eax
  8017c9:	89 04 24             	mov    %eax,(%esp)
  8017cc:	e8 f7 fb ff ff       	call   8013c8 <dev_lookup>
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 49                	js     80181e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017dc:	75 23                	jne    801801 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017de:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017e3:	8b 40 48             	mov    0x48(%eax),%eax
  8017e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ee:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8017f5:	e8 4a eb ff ff       	call   800344 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ff:	eb 1d                	jmp    80181e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801801:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801804:	8b 52 18             	mov    0x18(%edx),%edx
  801807:	85 d2                	test   %edx,%edx
  801809:	74 0e                	je     801819 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80180b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80180e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	ff d2                	call   *%edx
  801817:	eb 05                	jmp    80181e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801819:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80181e:	83 c4 24             	add    $0x24,%esp
  801821:	5b                   	pop    %ebx
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	53                   	push   %ebx
  801828:	83 ec 24             	sub    $0x24,%esp
  80182b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801831:	89 44 24 04          	mov    %eax,0x4(%esp)
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	89 04 24             	mov    %eax,(%esp)
  80183b:	e8 32 fb ff ff       	call   801372 <fd_lookup>
  801840:	85 c0                	test   %eax,%eax
  801842:	78 52                	js     801896 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184e:	8b 00                	mov    (%eax),%eax
  801850:	89 04 24             	mov    %eax,(%esp)
  801853:	e8 70 fb ff ff       	call   8013c8 <dev_lookup>
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 3a                	js     801896 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80185c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801863:	74 2c                	je     801891 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801865:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801868:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80186f:	00 00 00 
	stat->st_isdir = 0;
  801872:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801879:	00 00 00 
	stat->st_dev = dev;
  80187c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801882:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801886:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801889:	89 14 24             	mov    %edx,(%esp)
  80188c:	ff 50 14             	call   *0x14(%eax)
  80188f:	eb 05                	jmp    801896 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801891:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801896:	83 c4 24             	add    $0x24,%esp
  801899:	5b                   	pop    %ebx
  80189a:	5d                   	pop    %ebp
  80189b:	c3                   	ret    

0080189c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ab:	00 
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	89 04 24             	mov    %eax,(%esp)
  8018b2:	e8 fe 01 00 00       	call   801ab5 <open>
  8018b7:	89 c3                	mov    %eax,%ebx
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 1b                	js     8018d8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8018bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c4:	89 1c 24             	mov    %ebx,(%esp)
  8018c7:	e8 58 ff ff ff       	call   801824 <fstat>
  8018cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8018ce:	89 1c 24             	mov    %ebx,(%esp)
  8018d1:	e8 d4 fb ff ff       	call   8014aa <close>
	return r;
  8018d6:	89 f3                	mov    %esi,%ebx
}
  8018d8:	89 d8                	mov    %ebx,%eax
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5e                   	pop    %esi
  8018df:	5d                   	pop    %ebp
  8018e0:	c3                   	ret    
  8018e1:	00 00                	add    %al,(%eax)
	...

008018e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 10             	sub    $0x10,%esp
  8018ec:	89 c3                	mov    %eax,%ebx
  8018ee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018f7:	75 11                	jne    80190a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801900:	e8 ae 08 00 00       	call   8021b3 <ipc_find_env>
  801905:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80190a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801911:	00 
  801912:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801919:	00 
  80191a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80191e:	a1 00 40 80 00       	mov    0x804000,%eax
  801923:	89 04 24             	mov    %eax,(%esp)
  801926:	e8 1e 08 00 00       	call   802149 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80192b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801932:	00 
  801933:	89 74 24 04          	mov    %esi,0x4(%esp)
  801937:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193e:	e8 9d 07 00 00       	call   8020e0 <ipc_recv>
}
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801950:	8b 45 08             	mov    0x8(%ebp),%eax
  801953:	8b 40 0c             	mov    0xc(%eax),%eax
  801956:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80195b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801963:	ba 00 00 00 00       	mov    $0x0,%edx
  801968:	b8 02 00 00 00       	mov    $0x2,%eax
  80196d:	e8 72 ff ff ff       	call   8018e4 <fsipc>
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	8b 40 0c             	mov    0xc(%eax),%eax
  801980:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801985:	ba 00 00 00 00       	mov    $0x0,%edx
  80198a:	b8 06 00 00 00       	mov    $0x6,%eax
  80198f:	e8 50 ff ff ff       	call   8018e4 <fsipc>
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	53                   	push   %ebx
  80199a:	83 ec 14             	sub    $0x14,%esp
  80199d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8019b5:	e8 2a ff ff ff       	call   8018e4 <fsipc>
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 2b                	js     8019e9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019be:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019c5:	00 
  8019c6:	89 1c 24             	mov    %ebx,(%esp)
  8019c9:	e8 21 ef ff ff       	call   8008ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019ce:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019d9:	a1 84 50 80 00       	mov    0x805084,%eax
  8019de:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019e9:	83 c4 14             	add    $0x14,%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019f5:	c7 44 24 08 6c 2a 80 	movl   $0x802a6c,0x8(%esp)
  8019fc:	00 
  8019fd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a04:	00 
  801a05:	c7 04 24 8a 2a 80 00 	movl   $0x802a8a,(%esp)
  801a0c:	e8 3b e8 ff ff       	call   80024c <_panic>

00801a11 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 10             	sub    $0x10,%esp
  801a19:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a27:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a32:	b8 03 00 00 00       	mov    $0x3,%eax
  801a37:	e8 a8 fe ff ff       	call   8018e4 <fsipc>
  801a3c:	89 c3                	mov    %eax,%ebx
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 6a                	js     801aac <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a42:	39 c6                	cmp    %eax,%esi
  801a44:	73 24                	jae    801a6a <devfile_read+0x59>
  801a46:	c7 44 24 0c 95 2a 80 	movl   $0x802a95,0xc(%esp)
  801a4d:	00 
  801a4e:	c7 44 24 08 9c 2a 80 	movl   $0x802a9c,0x8(%esp)
  801a55:	00 
  801a56:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a5d:	00 
  801a5e:	c7 04 24 8a 2a 80 00 	movl   $0x802a8a,(%esp)
  801a65:	e8 e2 e7 ff ff       	call   80024c <_panic>
	assert(r <= PGSIZE);
  801a6a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a6f:	7e 24                	jle    801a95 <devfile_read+0x84>
  801a71:	c7 44 24 0c b1 2a 80 	movl   $0x802ab1,0xc(%esp)
  801a78:	00 
  801a79:	c7 44 24 08 9c 2a 80 	movl   $0x802a9c,0x8(%esp)
  801a80:	00 
  801a81:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a88:	00 
  801a89:	c7 04 24 8a 2a 80 00 	movl   $0x802a8a,(%esp)
  801a90:	e8 b7 e7 ff ff       	call   80024c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a99:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801aa0:	00 
  801aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa4:	89 04 24             	mov    %eax,(%esp)
  801aa7:	e8 bc ef ff ff       	call   800a68 <memmove>
	return r;
}
  801aac:	89 d8                	mov    %ebx,%eax
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	56                   	push   %esi
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 20             	sub    $0x20,%esp
  801abd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ac0:	89 34 24             	mov    %esi,(%esp)
  801ac3:	e8 f4 ed ff ff       	call   8008bc <strlen>
  801ac8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801acd:	7f 60                	jg     801b2f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801acf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad2:	89 04 24             	mov    %eax,(%esp)
  801ad5:	e8 45 f8 ff ff       	call   80131f <fd_alloc>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 54                	js     801b34 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ae0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801aeb:	e8 ff ed ff ff       	call   8008ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  801af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801af8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801afb:	b8 01 00 00 00       	mov    $0x1,%eax
  801b00:	e8 df fd ff ff       	call   8018e4 <fsipc>
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	85 c0                	test   %eax,%eax
  801b09:	79 15                	jns    801b20 <open+0x6b>
		fd_close(fd, 0);
  801b0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b12:	00 
  801b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b16:	89 04 24             	mov    %eax,(%esp)
  801b19:	e8 04 f9 ff ff       	call   801422 <fd_close>
		return r;
  801b1e:	eb 14                	jmp    801b34 <open+0x7f>
	}

	return fd2num(fd);
  801b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b23:	89 04 24             	mov    %eax,(%esp)
  801b26:	e8 c9 f7 ff ff       	call   8012f4 <fd2num>
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	eb 05                	jmp    801b34 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b2f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b34:	89 d8                	mov    %ebx,%eax
  801b36:	83 c4 20             	add    $0x20,%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b43:	ba 00 00 00 00       	mov    $0x0,%edx
  801b48:	b8 08 00 00 00       	mov    $0x8,%eax
  801b4d:	e8 92 fd ff ff       	call   8018e4 <fsipc>
}
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	83 ec 10             	sub    $0x10,%esp
  801b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	89 04 24             	mov    %eax,(%esp)
  801b65:	e8 9a f7 ff ff       	call   801304 <fd2data>
  801b6a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b6c:	c7 44 24 04 bd 2a 80 	movl   $0x802abd,0x4(%esp)
  801b73:	00 
  801b74:	89 34 24             	mov    %esi,(%esp)
  801b77:	e8 73 ed ff ff       	call   8008ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7f:	2b 03                	sub    (%ebx),%eax
  801b81:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b87:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b8e:	00 00 00 
	stat->st_dev = &devpipe;
  801b91:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801b98:	30 80 00 
	return 0;
}
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5d                   	pop    %ebp
  801ba6:	c3                   	ret    

00801ba7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	53                   	push   %ebx
  801bab:	83 ec 14             	sub    $0x14,%esp
  801bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbc:	e8 c7 f1 ff ff       	call   800d88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc1:	89 1c 24             	mov    %ebx,(%esp)
  801bc4:	e8 3b f7 ff ff       	call   801304 <fd2data>
  801bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd4:	e8 af f1 ff ff       	call   800d88 <sys_page_unmap>
}
  801bd9:	83 c4 14             	add    $0x14,%esp
  801bdc:	5b                   	pop    %ebx
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	57                   	push   %edi
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 2c             	sub    $0x2c,%esp
  801be8:	89 c7                	mov    %eax,%edi
  801bea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bed:	a1 04 40 80 00       	mov    0x804004,%eax
  801bf2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bf5:	89 3c 24             	mov    %edi,(%esp)
  801bf8:	e8 fb 05 00 00       	call   8021f8 <pageref>
  801bfd:	89 c6                	mov    %eax,%esi
  801bff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c02:	89 04 24             	mov    %eax,(%esp)
  801c05:	e8 ee 05 00 00       	call   8021f8 <pageref>
  801c0a:	39 c6                	cmp    %eax,%esi
  801c0c:	0f 94 c0             	sete   %al
  801c0f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c12:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c18:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c1b:	39 cb                	cmp    %ecx,%ebx
  801c1d:	75 08                	jne    801c27 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c1f:	83 c4 2c             	add    $0x2c,%esp
  801c22:	5b                   	pop    %ebx
  801c23:	5e                   	pop    %esi
  801c24:	5f                   	pop    %edi
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c27:	83 f8 01             	cmp    $0x1,%eax
  801c2a:	75 c1                	jne    801bed <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c2c:	8b 42 58             	mov    0x58(%edx),%eax
  801c2f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c36:	00 
  801c37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3f:	c7 04 24 c4 2a 80 00 	movl   $0x802ac4,(%esp)
  801c46:	e8 f9 e6 ff ff       	call   800344 <cprintf>
  801c4b:	eb a0                	jmp    801bed <_pipeisclosed+0xe>

00801c4d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	57                   	push   %edi
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	83 ec 1c             	sub    $0x1c,%esp
  801c56:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c59:	89 34 24             	mov    %esi,(%esp)
  801c5c:	e8 a3 f6 ff ff       	call   801304 <fd2data>
  801c61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c63:	bf 00 00 00 00       	mov    $0x0,%edi
  801c68:	eb 3c                	jmp    801ca6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c6a:	89 da                	mov    %ebx,%edx
  801c6c:	89 f0                	mov    %esi,%eax
  801c6e:	e8 6c ff ff ff       	call   801bdf <_pipeisclosed>
  801c73:	85 c0                	test   %eax,%eax
  801c75:	75 38                	jne    801caf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c77:	e8 46 f0 ff ff       	call   800cc2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c7f:	8b 13                	mov    (%ebx),%edx
  801c81:	83 c2 20             	add    $0x20,%edx
  801c84:	39 d0                	cmp    %edx,%eax
  801c86:	73 e2                	jae    801c6a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801c8e:	89 c2                	mov    %eax,%edx
  801c90:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c96:	79 05                	jns    801c9d <devpipe_write+0x50>
  801c98:	4a                   	dec    %edx
  801c99:	83 ca e0             	or     $0xffffffe0,%edx
  801c9c:	42                   	inc    %edx
  801c9d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca1:	40                   	inc    %eax
  801ca2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca5:	47                   	inc    %edi
  801ca6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ca9:	75 d1                	jne    801c7c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cab:	89 f8                	mov    %edi,%eax
  801cad:	eb 05                	jmp    801cb4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801caf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cb4:	83 c4 1c             	add    $0x1c,%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	57                   	push   %edi
  801cc0:	56                   	push   %esi
  801cc1:	53                   	push   %ebx
  801cc2:	83 ec 1c             	sub    $0x1c,%esp
  801cc5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cc8:	89 3c 24             	mov    %edi,(%esp)
  801ccb:	e8 34 f6 ff ff       	call   801304 <fd2data>
  801cd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd2:	be 00 00 00 00       	mov    $0x0,%esi
  801cd7:	eb 3a                	jmp    801d13 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cd9:	85 f6                	test   %esi,%esi
  801cdb:	74 04                	je     801ce1 <devpipe_read+0x25>
				return i;
  801cdd:	89 f0                	mov    %esi,%eax
  801cdf:	eb 40                	jmp    801d21 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ce1:	89 da                	mov    %ebx,%edx
  801ce3:	89 f8                	mov    %edi,%eax
  801ce5:	e8 f5 fe ff ff       	call   801bdf <_pipeisclosed>
  801cea:	85 c0                	test   %eax,%eax
  801cec:	75 2e                	jne    801d1c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cee:	e8 cf ef ff ff       	call   800cc2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cf3:	8b 03                	mov    (%ebx),%eax
  801cf5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cf8:	74 df                	je     801cd9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cfa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801cff:	79 05                	jns    801d06 <devpipe_read+0x4a>
  801d01:	48                   	dec    %eax
  801d02:	83 c8 e0             	or     $0xffffffe0,%eax
  801d05:	40                   	inc    %eax
  801d06:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d10:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d12:	46                   	inc    %esi
  801d13:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d16:	75 db                	jne    801cf3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d18:	89 f0                	mov    %esi,%eax
  801d1a:	eb 05                	jmp    801d21 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d1c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	57                   	push   %edi
  801d2d:	56                   	push   %esi
  801d2e:	53                   	push   %ebx
  801d2f:	83 ec 3c             	sub    $0x3c,%esp
  801d32:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d35:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d38:	89 04 24             	mov    %eax,(%esp)
  801d3b:	e8 df f5 ff ff       	call   80131f <fd_alloc>
  801d40:	89 c3                	mov    %eax,%ebx
  801d42:	85 c0                	test   %eax,%eax
  801d44:	0f 88 45 01 00 00    	js     801e8f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d51:	00 
  801d52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d60:	e8 7c ef ff ff       	call   800ce1 <sys_page_alloc>
  801d65:	89 c3                	mov    %eax,%ebx
  801d67:	85 c0                	test   %eax,%eax
  801d69:	0f 88 20 01 00 00    	js     801e8f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d6f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d72:	89 04 24             	mov    %eax,(%esp)
  801d75:	e8 a5 f5 ff ff       	call   80131f <fd_alloc>
  801d7a:	89 c3                	mov    %eax,%ebx
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	0f 88 f8 00 00 00    	js     801e7c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d84:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d8b:	00 
  801d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d9a:	e8 42 ef ff ff       	call   800ce1 <sys_page_alloc>
  801d9f:	89 c3                	mov    %eax,%ebx
  801da1:	85 c0                	test   %eax,%eax
  801da3:	0f 88 d3 00 00 00    	js     801e7c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dac:	89 04 24             	mov    %eax,(%esp)
  801daf:	e8 50 f5 ff ff       	call   801304 <fd2data>
  801db4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dbd:	00 
  801dbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc9:	e8 13 ef ff ff       	call   800ce1 <sys_page_alloc>
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	0f 88 91 00 00 00    	js     801e69 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ddb:	89 04 24             	mov    %eax,(%esp)
  801dde:	e8 21 f5 ff ff       	call   801304 <fd2data>
  801de3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801dea:	00 
  801deb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801def:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801df6:	00 
  801df7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e02:	e8 2e ef ff ff       	call   800d35 <sys_page_map>
  801e07:	89 c3                	mov    %eax,%ebx
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 4c                	js     801e59 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e16:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e2b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e30:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e3a:	89 04 24             	mov    %eax,(%esp)
  801e3d:	e8 b2 f4 ff ff       	call   8012f4 <fd2num>
  801e42:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e44:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e47:	89 04 24             	mov    %eax,(%esp)
  801e4a:	e8 a5 f4 ff ff       	call   8012f4 <fd2num>
  801e4f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e57:	eb 36                	jmp    801e8f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e59:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e64:	e8 1f ef ff ff       	call   800d88 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e77:	e8 0c ef ff ff       	call   800d88 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801e7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8a:	e8 f9 ee ff ff       	call   800d88 <sys_page_unmap>
    err:
	return r;
}
  801e8f:	89 d8                	mov    %ebx,%eax
  801e91:	83 c4 3c             	add    $0x3c,%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5f                   	pop    %edi
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea9:	89 04 24             	mov    %eax,(%esp)
  801eac:	e8 c1 f4 ff ff       	call   801372 <fd_lookup>
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 15                	js     801eca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb8:	89 04 24             	mov    %eax,(%esp)
  801ebb:	e8 44 f4 ff ff       	call   801304 <fd2data>
	return _pipeisclosed(fd, p);
  801ec0:	89 c2                	mov    %eax,%edx
  801ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec5:	e8 15 fd ff ff       	call   801bdf <_pipeisclosed>
}
  801eca:	c9                   	leave  
  801ecb:	c3                   	ret    

00801ecc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    

00801ed6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801edc:	c7 44 24 04 dc 2a 80 	movl   $0x802adc,0x4(%esp)
  801ee3:	00 
  801ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee7:	89 04 24             	mov    %eax,(%esp)
  801eea:	e8 00 ea ff ff       	call   8008ef <strcpy>
	return 0;
}
  801eef:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	57                   	push   %edi
  801efa:	56                   	push   %esi
  801efb:	53                   	push   %ebx
  801efc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f02:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f07:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f0d:	eb 30                	jmp    801f3f <devcons_write+0x49>
		m = n - tot;
  801f0f:	8b 75 10             	mov    0x10(%ebp),%esi
  801f12:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f14:	83 fe 7f             	cmp    $0x7f,%esi
  801f17:	76 05                	jbe    801f1e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f19:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f1e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f22:	03 45 0c             	add    0xc(%ebp),%eax
  801f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f29:	89 3c 24             	mov    %edi,(%esp)
  801f2c:	e8 37 eb ff ff       	call   800a68 <memmove>
		sys_cputs(buf, m);
  801f31:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f35:	89 3c 24             	mov    %edi,(%esp)
  801f38:	e8 d7 ec ff ff       	call   800c14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f3d:	01 f3                	add    %esi,%ebx
  801f3f:	89 d8                	mov    %ebx,%eax
  801f41:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f44:	72 c9                	jb     801f0f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f46:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f4c:	5b                   	pop    %ebx
  801f4d:	5e                   	pop    %esi
  801f4e:	5f                   	pop    %edi
  801f4f:	5d                   	pop    %ebp
  801f50:	c3                   	ret    

00801f51 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f5b:	75 07                	jne    801f64 <devcons_read+0x13>
  801f5d:	eb 25                	jmp    801f84 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f5f:	e8 5e ed ff ff       	call   800cc2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f64:	e8 c9 ec ff ff       	call   800c32 <sys_cgetc>
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	74 f2                	je     801f5f <devcons_read+0xe>
  801f6d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	78 1d                	js     801f90 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f73:	83 f8 04             	cmp    $0x4,%eax
  801f76:	74 13                	je     801f8b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7b:	88 10                	mov    %dl,(%eax)
	return 1;
  801f7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f82:	eb 0c                	jmp    801f90 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f84:	b8 00 00 00 00       	mov    $0x0,%eax
  801f89:	eb 05                	jmp    801f90 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801f98:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fa5:	00 
  801fa6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa9:	89 04 24             	mov    %eax,(%esp)
  801fac:	e8 63 ec ff ff       	call   800c14 <sys_cputs>
}
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    

00801fb3 <getchar>:

int
getchar(void)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fb9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801fc0:	00 
  801fc1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fcf:	e8 3a f6 ff ff       	call   80160e <read>
	if (r < 0)
  801fd4:	85 c0                	test   %eax,%eax
  801fd6:	78 0f                	js     801fe7 <getchar+0x34>
		return r;
	if (r < 1)
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	7e 06                	jle    801fe2 <getchar+0x2f>
		return -E_EOF;
	return c;
  801fdc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fe0:	eb 05                	jmp    801fe7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fe2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fe7:	c9                   	leave  
  801fe8:	c3                   	ret    

00801fe9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff9:	89 04 24             	mov    %eax,(%esp)
  801ffc:	e8 71 f3 ff ff       	call   801372 <fd_lookup>
  802001:	85 c0                	test   %eax,%eax
  802003:	78 11                	js     802016 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802008:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80200e:	39 10                	cmp    %edx,(%eax)
  802010:	0f 94 c0             	sete   %al
  802013:	0f b6 c0             	movzbl %al,%eax
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <opencons>:

int
opencons(void)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80201e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802021:	89 04 24             	mov    %eax,(%esp)
  802024:	e8 f6 f2 ff ff       	call   80131f <fd_alloc>
  802029:	85 c0                	test   %eax,%eax
  80202b:	78 3c                	js     802069 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80202d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802034:	00 
  802035:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802038:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802043:	e8 99 ec ff ff       	call   800ce1 <sys_page_alloc>
  802048:	85 c0                	test   %eax,%eax
  80204a:	78 1d                	js     802069 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80204c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802055:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802061:	89 04 24             	mov    %eax,(%esp)
  802064:	e8 8b f2 ff ff       	call   8012f4 <fd2num>
}
  802069:	c9                   	leave  
  80206a:	c3                   	ret    
	...

0080206c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802072:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802079:	75 32                	jne    8020ad <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80207b:	e8 23 ec ff ff       	call   800ca3 <sys_getenvid>
  802080:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  802087:	00 
  802088:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80208f:	ee 
  802090:	89 04 24             	mov    %eax,(%esp)
  802093:	e8 49 ec ff ff       	call   800ce1 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  802098:	e8 06 ec ff ff       	call   800ca3 <sys_getenvid>
  80209d:	c7 44 24 04 b8 20 80 	movl   $0x8020b8,0x4(%esp)
  8020a4:	00 
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 d4 ed ff ff       	call   800e81 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    
	...

008020b8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020b8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020b9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020be:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020c0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  8020c3:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  8020c7:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  8020ca:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  8020cf:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  8020d3:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  8020d6:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  8020d7:	83 c4 04             	add    $0x4,%esp
	popfl
  8020da:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  8020db:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  8020dc:	c3                   	ret    
  8020dd:	00 00                	add    %al,(%eax)
	...

008020e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	57                   	push   %edi
  8020e4:	56                   	push   %esi
  8020e5:	53                   	push   %ebx
  8020e6:	83 ec 1c             	sub    $0x1c,%esp
  8020e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020ef:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8020f2:	85 db                	test   %ebx,%ebx
  8020f4:	75 05                	jne    8020fb <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8020f6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8020fb:	89 1c 24             	mov    %ebx,(%esp)
  8020fe:	e8 f4 ed ff ff       	call   800ef7 <sys_ipc_recv>
  802103:	85 c0                	test   %eax,%eax
  802105:	79 16                	jns    80211d <ipc_recv+0x3d>
		*from_env_store = 0;
  802107:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  80210d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  802113:	89 1c 24             	mov    %ebx,(%esp)
  802116:	e8 dc ed ff ff       	call   800ef7 <sys_ipc_recv>
  80211b:	eb 24                	jmp    802141 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  80211d:	85 f6                	test   %esi,%esi
  80211f:	74 0a                	je     80212b <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802121:	a1 04 40 80 00       	mov    0x804004,%eax
  802126:	8b 40 74             	mov    0x74(%eax),%eax
  802129:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80212b:	85 ff                	test   %edi,%edi
  80212d:	74 0a                	je     802139 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  80212f:	a1 04 40 80 00       	mov    0x804004,%eax
  802134:	8b 40 78             	mov    0x78(%eax),%eax
  802137:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  802139:	a1 04 40 80 00       	mov    0x804004,%eax
  80213e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    

00802149 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	57                   	push   %edi
  80214d:	56                   	push   %esi
  80214e:	53                   	push   %ebx
  80214f:	83 ec 1c             	sub    $0x1c,%esp
  802152:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802155:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802158:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80215b:	85 db                	test   %ebx,%ebx
  80215d:	75 05                	jne    802164 <ipc_send+0x1b>
		pg = (void *)-1;
  80215f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802164:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802168:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80216c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802170:	8b 45 08             	mov    0x8(%ebp),%eax
  802173:	89 04 24             	mov    %eax,(%esp)
  802176:	e8 59 ed ff ff       	call   800ed4 <sys_ipc_try_send>
		if (r == 0) {		
  80217b:	85 c0                	test   %eax,%eax
  80217d:	74 2c                	je     8021ab <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80217f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802182:	75 07                	jne    80218b <ipc_send+0x42>
			sys_yield();
  802184:	e8 39 eb ff ff       	call   800cc2 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  802189:	eb d9                	jmp    802164 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80218b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218f:	c7 44 24 08 e8 2a 80 	movl   $0x802ae8,0x8(%esp)
  802196:	00 
  802197:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80219e:	00 
  80219f:	c7 04 24 f6 2a 80 00 	movl   $0x802af6,(%esp)
  8021a6:	e8 a1 e0 ff ff       	call   80024c <_panic>
		}
	}
}
  8021ab:	83 c4 1c             	add    $0x1c,%esp
  8021ae:	5b                   	pop    %ebx
  8021af:	5e                   	pop    %esi
  8021b0:	5f                   	pop    %edi
  8021b1:	5d                   	pop    %ebp
  8021b2:	c3                   	ret    

008021b3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	53                   	push   %ebx
  8021b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021ba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021bf:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021c6:	89 c2                	mov    %eax,%edx
  8021c8:	c1 e2 07             	shl    $0x7,%edx
  8021cb:	29 ca                	sub    %ecx,%edx
  8021cd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021d3:	8b 52 50             	mov    0x50(%edx),%edx
  8021d6:	39 da                	cmp    %ebx,%edx
  8021d8:	75 0f                	jne    8021e9 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021da:	c1 e0 07             	shl    $0x7,%eax
  8021dd:	29 c8                	sub    %ecx,%eax
  8021df:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021e4:	8b 40 40             	mov    0x40(%eax),%eax
  8021e7:	eb 0c                	jmp    8021f5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021e9:	40                   	inc    %eax
  8021ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021ef:	75 ce                	jne    8021bf <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021f1:	66 b8 00 00          	mov    $0x0,%ax
}
  8021f5:	5b                   	pop    %ebx
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    

008021f8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021fe:	89 c2                	mov    %eax,%edx
  802200:	c1 ea 16             	shr    $0x16,%edx
  802203:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80220a:	f6 c2 01             	test   $0x1,%dl
  80220d:	74 1e                	je     80222d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80220f:	c1 e8 0c             	shr    $0xc,%eax
  802212:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802219:	a8 01                	test   $0x1,%al
  80221b:	74 17                	je     802234 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80221d:	c1 e8 0c             	shr    $0xc,%eax
  802220:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802227:	ef 
  802228:	0f b7 c0             	movzwl %ax,%eax
  80222b:	eb 0c                	jmp    802239 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
  802232:	eb 05                	jmp    802239 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802234:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802239:	5d                   	pop    %ebp
  80223a:	c3                   	ret    
	...

0080223c <__udivdi3>:
  80223c:	55                   	push   %ebp
  80223d:	57                   	push   %edi
  80223e:	56                   	push   %esi
  80223f:	83 ec 10             	sub    $0x10,%esp
  802242:	8b 74 24 20          	mov    0x20(%esp),%esi
  802246:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80224a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802252:	89 cd                	mov    %ecx,%ebp
  802254:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802258:	85 c0                	test   %eax,%eax
  80225a:	75 2c                	jne    802288 <__udivdi3+0x4c>
  80225c:	39 f9                	cmp    %edi,%ecx
  80225e:	77 68                	ja     8022c8 <__udivdi3+0x8c>
  802260:	85 c9                	test   %ecx,%ecx
  802262:	75 0b                	jne    80226f <__udivdi3+0x33>
  802264:	b8 01 00 00 00       	mov    $0x1,%eax
  802269:	31 d2                	xor    %edx,%edx
  80226b:	f7 f1                	div    %ecx
  80226d:	89 c1                	mov    %eax,%ecx
  80226f:	31 d2                	xor    %edx,%edx
  802271:	89 f8                	mov    %edi,%eax
  802273:	f7 f1                	div    %ecx
  802275:	89 c7                	mov    %eax,%edi
  802277:	89 f0                	mov    %esi,%eax
  802279:	f7 f1                	div    %ecx
  80227b:	89 c6                	mov    %eax,%esi
  80227d:	89 f0                	mov    %esi,%eax
  80227f:	89 fa                	mov    %edi,%edx
  802281:	83 c4 10             	add    $0x10,%esp
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	39 f8                	cmp    %edi,%eax
  80228a:	77 2c                	ja     8022b8 <__udivdi3+0x7c>
  80228c:	0f bd f0             	bsr    %eax,%esi
  80228f:	83 f6 1f             	xor    $0x1f,%esi
  802292:	75 4c                	jne    8022e0 <__udivdi3+0xa4>
  802294:	39 f8                	cmp    %edi,%eax
  802296:	bf 00 00 00 00       	mov    $0x0,%edi
  80229b:	72 0a                	jb     8022a7 <__udivdi3+0x6b>
  80229d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022a1:	0f 87 ad 00 00 00    	ja     802354 <__udivdi3+0x118>
  8022a7:	be 01 00 00 00       	mov    $0x1,%esi
  8022ac:	89 f0                	mov    %esi,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 10             	add    $0x10,%esp
  8022b3:	5e                   	pop    %esi
  8022b4:	5f                   	pop    %edi
  8022b5:	5d                   	pop    %ebp
  8022b6:	c3                   	ret    
  8022b7:	90                   	nop
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 f6                	xor    %esi,%esi
  8022bc:	89 f0                	mov    %esi,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 10             	add    $0x10,%esp
  8022c3:	5e                   	pop    %esi
  8022c4:	5f                   	pop    %edi
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    
  8022c7:	90                   	nop
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	89 f0                	mov    %esi,%eax
  8022cc:	f7 f1                	div    %ecx
  8022ce:	89 c6                	mov    %eax,%esi
  8022d0:	31 ff                	xor    %edi,%edi
  8022d2:	89 f0                	mov    %esi,%eax
  8022d4:	89 fa                	mov    %edi,%edx
  8022d6:	83 c4 10             	add    $0x10,%esp
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	89 f1                	mov    %esi,%ecx
  8022e2:	d3 e0                	shl    %cl,%eax
  8022e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022e8:	b8 20 00 00 00       	mov    $0x20,%eax
  8022ed:	29 f0                	sub    %esi,%eax
  8022ef:	89 ea                	mov    %ebp,%edx
  8022f1:	88 c1                	mov    %al,%cl
  8022f3:	d3 ea                	shr    %cl,%edx
  8022f5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022f9:	09 ca                	or     %ecx,%edx
  8022fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022ff:	89 f1                	mov    %esi,%ecx
  802301:	d3 e5                	shl    %cl,%ebp
  802303:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802307:	89 fd                	mov    %edi,%ebp
  802309:	88 c1                	mov    %al,%cl
  80230b:	d3 ed                	shr    %cl,%ebp
  80230d:	89 fa                	mov    %edi,%edx
  80230f:	89 f1                	mov    %esi,%ecx
  802311:	d3 e2                	shl    %cl,%edx
  802313:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802317:	88 c1                	mov    %al,%cl
  802319:	d3 ef                	shr    %cl,%edi
  80231b:	09 d7                	or     %edx,%edi
  80231d:	89 f8                	mov    %edi,%eax
  80231f:	89 ea                	mov    %ebp,%edx
  802321:	f7 74 24 08          	divl   0x8(%esp)
  802325:	89 d1                	mov    %edx,%ecx
  802327:	89 c7                	mov    %eax,%edi
  802329:	f7 64 24 0c          	mull   0xc(%esp)
  80232d:	39 d1                	cmp    %edx,%ecx
  80232f:	72 17                	jb     802348 <__udivdi3+0x10c>
  802331:	74 09                	je     80233c <__udivdi3+0x100>
  802333:	89 fe                	mov    %edi,%esi
  802335:	31 ff                	xor    %edi,%edi
  802337:	e9 41 ff ff ff       	jmp    80227d <__udivdi3+0x41>
  80233c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802340:	89 f1                	mov    %esi,%ecx
  802342:	d3 e2                	shl    %cl,%edx
  802344:	39 c2                	cmp    %eax,%edx
  802346:	73 eb                	jae    802333 <__udivdi3+0xf7>
  802348:	8d 77 ff             	lea    -0x1(%edi),%esi
  80234b:	31 ff                	xor    %edi,%edi
  80234d:	e9 2b ff ff ff       	jmp    80227d <__udivdi3+0x41>
  802352:	66 90                	xchg   %ax,%ax
  802354:	31 f6                	xor    %esi,%esi
  802356:	e9 22 ff ff ff       	jmp    80227d <__udivdi3+0x41>
	...

0080235c <__umoddi3>:
  80235c:	55                   	push   %ebp
  80235d:	57                   	push   %edi
  80235e:	56                   	push   %esi
  80235f:	83 ec 20             	sub    $0x20,%esp
  802362:	8b 44 24 30          	mov    0x30(%esp),%eax
  802366:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80236a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80236e:	8b 74 24 34          	mov    0x34(%esp),%esi
  802372:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802376:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80237a:	89 c7                	mov    %eax,%edi
  80237c:	89 f2                	mov    %esi,%edx
  80237e:	85 ed                	test   %ebp,%ebp
  802380:	75 16                	jne    802398 <__umoddi3+0x3c>
  802382:	39 f1                	cmp    %esi,%ecx
  802384:	0f 86 a6 00 00 00    	jbe    802430 <__umoddi3+0xd4>
  80238a:	f7 f1                	div    %ecx
  80238c:	89 d0                	mov    %edx,%eax
  80238e:	31 d2                	xor    %edx,%edx
  802390:	83 c4 20             	add    $0x20,%esp
  802393:	5e                   	pop    %esi
  802394:	5f                   	pop    %edi
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    
  802397:	90                   	nop
  802398:	39 f5                	cmp    %esi,%ebp
  80239a:	0f 87 ac 00 00 00    	ja     80244c <__umoddi3+0xf0>
  8023a0:	0f bd c5             	bsr    %ebp,%eax
  8023a3:	83 f0 1f             	xor    $0x1f,%eax
  8023a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023aa:	0f 84 a8 00 00 00    	je     802458 <__umoddi3+0xfc>
  8023b0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023b4:	d3 e5                	shl    %cl,%ebp
  8023b6:	bf 20 00 00 00       	mov    $0x20,%edi
  8023bb:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8023bf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	d3 e8                	shr    %cl,%eax
  8023c7:	09 e8                	or     %ebp,%eax
  8023c9:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023cd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023d1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023d5:	d3 e0                	shl    %cl,%eax
  8023d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023db:	89 f2                	mov    %esi,%edx
  8023dd:	d3 e2                	shl    %cl,%edx
  8023df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e3:	d3 e0                	shl    %cl,%eax
  8023e5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8023e9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023ed:	89 f9                	mov    %edi,%ecx
  8023ef:	d3 e8                	shr    %cl,%eax
  8023f1:	09 d0                	or     %edx,%eax
  8023f3:	d3 ee                	shr    %cl,%esi
  8023f5:	89 f2                	mov    %esi,%edx
  8023f7:	f7 74 24 18          	divl   0x18(%esp)
  8023fb:	89 d6                	mov    %edx,%esi
  8023fd:	f7 64 24 0c          	mull   0xc(%esp)
  802401:	89 c5                	mov    %eax,%ebp
  802403:	89 d1                	mov    %edx,%ecx
  802405:	39 d6                	cmp    %edx,%esi
  802407:	72 67                	jb     802470 <__umoddi3+0x114>
  802409:	74 75                	je     802480 <__umoddi3+0x124>
  80240b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80240f:	29 e8                	sub    %ebp,%eax
  802411:	19 ce                	sbb    %ecx,%esi
  802413:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 f2                	mov    %esi,%edx
  80241b:	89 f9                	mov    %edi,%ecx
  80241d:	d3 e2                	shl    %cl,%edx
  80241f:	09 d0                	or     %edx,%eax
  802421:	89 f2                	mov    %esi,%edx
  802423:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802427:	d3 ea                	shr    %cl,%edx
  802429:	83 c4 20             	add    $0x20,%esp
  80242c:	5e                   	pop    %esi
  80242d:	5f                   	pop    %edi
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    
  802430:	85 c9                	test   %ecx,%ecx
  802432:	75 0b                	jne    80243f <__umoddi3+0xe3>
  802434:	b8 01 00 00 00       	mov    $0x1,%eax
  802439:	31 d2                	xor    %edx,%edx
  80243b:	f7 f1                	div    %ecx
  80243d:	89 c1                	mov    %eax,%ecx
  80243f:	89 f0                	mov    %esi,%eax
  802441:	31 d2                	xor    %edx,%edx
  802443:	f7 f1                	div    %ecx
  802445:	89 f8                	mov    %edi,%eax
  802447:	e9 3e ff ff ff       	jmp    80238a <__umoddi3+0x2e>
  80244c:	89 f2                	mov    %esi,%edx
  80244e:	83 c4 20             	add    $0x20,%esp
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    
  802455:	8d 76 00             	lea    0x0(%esi),%esi
  802458:	39 f5                	cmp    %esi,%ebp
  80245a:	72 04                	jb     802460 <__umoddi3+0x104>
  80245c:	39 f9                	cmp    %edi,%ecx
  80245e:	77 06                	ja     802466 <__umoddi3+0x10a>
  802460:	89 f2                	mov    %esi,%edx
  802462:	29 cf                	sub    %ecx,%edi
  802464:	19 ea                	sbb    %ebp,%edx
  802466:	89 f8                	mov    %edi,%eax
  802468:	83 c4 20             	add    $0x20,%esp
  80246b:	5e                   	pop    %esi
  80246c:	5f                   	pop    %edi
  80246d:	5d                   	pop    %ebp
  80246e:	c3                   	ret    
  80246f:	90                   	nop
  802470:	89 d1                	mov    %edx,%ecx
  802472:	89 c5                	mov    %eax,%ebp
  802474:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802478:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80247c:	eb 8d                	jmp    80240b <__umoddi3+0xaf>
  80247e:	66 90                	xchg   %ax,%ax
  802480:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802484:	72 ea                	jb     802470 <__umoddi3+0x114>
  802486:	89 f1                	mov    %esi,%ecx
  802488:	eb 81                	jmp    80240b <__umoddi3+0xaf>
