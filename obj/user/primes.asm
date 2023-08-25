
obj/user/primes.debug:     file format elf32-i386


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

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 08 12 00 00       	call   801260 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  800071:	e8 3a 02 00 00       	call   8002b0 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 64 0f 00 00       	call   800fdf <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 0c 24 80 	movl   $0x80240c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 15 24 80 00 	movl   $0x802415,(%esp)
  80009c:	e8 17 01 00 00       	call   8001b8 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 a0 11 00 00       	call   801260 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	99                   	cltd   
  8000c3:	f7 fb                	idiv   %ebx
  8000c5:	85 d2                	test   %edx,%edx
  8000c7:	74 df                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d8:	00 
  8000d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dd:	89 3c 24             	mov    %edi,(%esp)
  8000e0:	e8 e4 11 00 00       	call   8012c9 <ipc_send>
  8000e5:	eb c1                	jmp    8000a8 <primeproc+0x74>

008000e7 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ef:	e8 eb 0e 00 00       	call   800fdf <fork>
  8000f4:	89 c6                	mov    %eax,%esi
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	79 20                	jns    80011a <umain+0x33>
		panic("fork: %e", id);
  8000fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fe:	c7 44 24 08 0c 24 80 	movl   $0x80240c,0x8(%esp)
  800105:	00 
  800106:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010d:	00 
  80010e:	c7 04 24 15 24 80 00 	movl   $0x802415,(%esp)
  800115:	e8 9e 00 00 00       	call   8001b8 <_panic>
	if (id == 0)
  80011a:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011f:	85 c0                	test   %eax,%eax
  800121:	75 05                	jne    800128 <umain+0x41>
		primeproc();
  800123:	e8 0c ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800128:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012f:	00 
  800130:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800137:	00 
  800138:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013c:	89 34 24             	mov    %esi,(%esp)
  80013f:	e8 85 11 00 00       	call   8012c9 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800144:	43                   	inc    %ebx
  800145:	eb e1                	jmp    800128 <umain+0x41>
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
  800156:	e8 b4 0a 00 00       	call   800c0f <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800188:	e8 5a ff ff ff       	call   8000e7 <umain>

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
  8001a2:	e8 b8 13 00 00       	call   80155f <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 0a 0a 00 00       	call   800bbd <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001c9:	e8 41 0a 00 00       	call   800c0f <sys_getenvid>
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  8001eb:	e8 c0 00 00 00       	call   8002b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	e8 50 00 00 00       	call   80024f <vcprintf>
	cprintf("\n");
  8001ff:	c7 04 24 ad 29 80 00 	movl   $0x8029ad,(%esp)
  800206:	e8 a5 00 00 00       	call   8002b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020b:	cc                   	int3   
  80020c:	eb fd                	jmp    80020b <_panic+0x53>
	...

00800210 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	53                   	push   %ebx
  800214:	83 ec 14             	sub    $0x14,%esp
  800217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80021a:	8b 03                	mov    (%ebx),%eax
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800223:	40                   	inc    %eax
  800224:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800226:	3d ff 00 00 00       	cmp    $0xff,%eax
  80022b:	75 19                	jne    800246 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80022d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800234:	00 
  800235:	8d 43 08             	lea    0x8(%ebx),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 40 09 00 00       	call   800b80 <sys_cputs>
		b->idx = 0;
  800240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800246:	ff 43 04             	incl   0x4(%ebx)
}
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800258:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025f:	00 00 00 
	b.cnt = 0;
  800262:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800269:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 10 02 80 00 	movl   $0x800210,(%esp)
  80028b:	e8 82 01 00 00       	call   800412 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800290:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 d8 08 00 00       	call   800b80 <sys_cputs>

	return b.cnt;
}
  8002a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 87 ff ff ff       	call   80024f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    
	...

008002cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 3c             	sub    $0x3c,%esp
  8002d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d8:	89 d7                	mov    %edx,%edi
  8002da:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	75 08                	jne    8002f8 <printnum+0x2c>
  8002f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f6:	77 57                	ja     80034f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002fc:	4b                   	dec    %ebx
  8002fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800301:	8b 45 10             	mov    0x10(%ebp),%eax
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80030c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800310:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800317:	00 
  800318:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	e8 7e 1e 00 00       	call   8021a8 <__udivdi3>
  80032a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	89 54 24 04          	mov    %edx,0x4(%esp)
  800339:	89 fa                	mov    %edi,%edx
  80033b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033e:	e8 89 ff ff ff       	call   8002cc <printnum>
  800343:	eb 0f                	jmp    800354 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800345:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800349:	89 34 24             	mov    %esi,(%esp)
  80034c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034f:	4b                   	dec    %ebx
  800350:	85 db                	test   %ebx,%ebx
  800352:	7f f1                	jg     800345 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036a:	00 
  80036b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036e:	89 04 24             	mov    %eax,(%esp)
  800371:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800374:	89 44 24 04          	mov    %eax,0x4(%esp)
  800378:	e8 4b 1f 00 00       	call   8022c8 <__umoddi3>
  80037d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800381:	0f be 80 53 24 80 00 	movsbl 0x802453(%eax),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80038e:	83 c4 3c             	add    $0x3c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800399:	83 fa 01             	cmp    $0x1,%edx
  80039c:	7e 0e                	jle    8003ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	8b 52 04             	mov    0x4(%edx),%edx
  8003aa:	eb 22                	jmp    8003ce <getuint+0x38>
	else if (lflag)
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 10                	je     8003c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b5:	89 08                	mov    %ecx,(%eax)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003be:	eb 0e                	jmp    8003ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 08                	jae    8003e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	88 0a                	mov    %cl,(%edx)
  8003e5:	42                   	inc    %edx
  8003e6:	89 10                	mov    %edx,(%eax)
}
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800401:	89 44 24 04          	mov    %eax,0x4(%esp)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 02 00 00 00       	call   800412 <vprintfmt>
	va_end(ap);
}
  800410:	c9                   	leave  
  800411:	c3                   	ret    

00800412 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	57                   	push   %edi
  800416:	56                   	push   %esi
  800417:	53                   	push   %ebx
  800418:	83 ec 4c             	sub    $0x4c,%esp
  80041b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041e:	8b 75 10             	mov    0x10(%ebp),%esi
  800421:	eb 12                	jmp    800435 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800423:	85 c0                	test   %eax,%eax
  800425:	0f 84 6b 03 00 00    	je     800796 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80042b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042f:	89 04 24             	mov    %eax,(%esp)
  800432:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800435:	0f b6 06             	movzbl (%esi),%eax
  800438:	46                   	inc    %esi
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e5                	jne    800423 <vprintfmt+0x11>
  80043e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800442:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800449:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80044e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800455:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045a:	eb 26                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80045f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800463:	eb 1d                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800468:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80046c:	eb 14                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800471:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800478:	eb 08                	jmp    800482 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80047a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80047d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	0f b6 06             	movzbl (%esi),%eax
  800485:	8d 56 01             	lea    0x1(%esi),%edx
  800488:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048b:	8a 16                	mov    (%esi),%dl
  80048d:	83 ea 23             	sub    $0x23,%edx
  800490:	80 fa 55             	cmp    $0x55,%dl
  800493:	0f 87 e1 02 00 00    	ja     80077a <vprintfmt+0x368>
  800499:	0f b6 d2             	movzbl %dl,%edx
  80049c:	ff 24 95 a0 25 80 00 	jmp    *0x8025a0(,%edx,4)
  8004a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b8:	83 fa 09             	cmp    $0x9,%edx
  8004bb:	77 2a                	ja     8004e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004be:	eb eb                	jmp    8004ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ce:	eb 17                	jmp    8004e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d4:	78 98                	js     80046e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d9:	eb a7                	jmp    800482 <vprintfmt+0x70>
  8004db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004e5:	eb 9b                	jmp    800482 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004eb:	79 95                	jns    800482 <vprintfmt+0x70>
  8004ed:	eb 8b                	jmp    80047a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f3:	eb 8d                	jmp    800482 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8d 50 04             	lea    0x4(%eax),%edx
  8004fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050d:	e9 23 ff ff ff       	jmp    800435 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	85 c0                	test   %eax,%eax
  80051f:	79 02                	jns    800523 <vprintfmt+0x111>
  800521:	f7 d8                	neg    %eax
  800523:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800525:	83 f8 0f             	cmp    $0xf,%eax
  800528:	7f 0b                	jg     800535 <vprintfmt+0x123>
  80052a:	8b 04 85 00 27 80 00 	mov    0x802700(,%eax,4),%eax
  800531:	85 c0                	test   %eax,%eax
  800533:	75 23                	jne    800558 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800535:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800539:	c7 44 24 08 6b 24 80 	movl   $0x80246b,0x8(%esp)
  800540:	00 
  800541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800545:	8b 45 08             	mov    0x8(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	e8 9a fe ff ff       	call   8003ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800553:	e9 dd fe ff ff       	jmp    800435 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800558:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055c:	c7 44 24 08 86 29 80 	movl   $0x802986,0x8(%esp)
  800563:	00 
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	8b 55 08             	mov    0x8(%ebp),%edx
  80056b:	89 14 24             	mov    %edx,(%esp)
  80056e:	e8 77 fe ff ff       	call   8003ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800576:	e9 ba fe ff ff       	jmp    800435 <vprintfmt+0x23>
  80057b:	89 f9                	mov    %edi,%ecx
  80057d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800580:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 30                	mov    (%eax),%esi
  80058e:	85 f6                	test   %esi,%esi
  800590:	75 05                	jne    800597 <vprintfmt+0x185>
				p = "(null)";
  800592:	be 64 24 80 00       	mov    $0x802464,%esi
			if (width > 0 && padc != '-')
  800597:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059b:	0f 8e 84 00 00 00    	jle    800625 <vprintfmt+0x213>
  8005a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005a5:	74 7e                	je     800625 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ab:	89 34 24             	mov    %esi,(%esp)
  8005ae:	e8 8b 02 00 00       	call   80083e <strnlen>
  8005b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005b6:	29 c2                	sub    %eax,%edx
  8005b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005c5:	89 de                	mov    %ebx,%esi
  8005c7:	89 d3                	mov    %edx,%ebx
  8005c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	eb 0b                	jmp    8005d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d1:	89 3c 24             	mov    %edi,(%esp)
  8005d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	4b                   	dec    %ebx
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f f1                	jg     8005cd <vprintfmt+0x1bb>
  8005dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005df:	89 f3                	mov    %esi,%ebx
  8005e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	79 05                	jns    8005f0 <vprintfmt+0x1de>
  8005eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f8:	eb 2b                	jmp    800625 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fe:	74 18                	je     800618 <vprintfmt+0x206>
  800600:	8d 50 e0             	lea    -0x20(%eax),%edx
  800603:	83 fa 5e             	cmp    $0x5e,%edx
  800606:	76 10                	jbe    800618 <vprintfmt+0x206>
					putch('?', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
  800616:	eb 0a                	jmp    800622 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800622:	ff 4d e4             	decl   -0x1c(%ebp)
  800625:	0f be 06             	movsbl (%esi),%eax
  800628:	46                   	inc    %esi
  800629:	85 c0                	test   %eax,%eax
  80062b:	74 21                	je     80064e <vprintfmt+0x23c>
  80062d:	85 ff                	test   %edi,%edi
  80062f:	78 c9                	js     8005fa <vprintfmt+0x1e8>
  800631:	4f                   	dec    %edi
  800632:	79 c6                	jns    8005fa <vprintfmt+0x1e8>
  800634:	8b 7d 08             	mov    0x8(%ebp),%edi
  800637:	89 de                	mov    %ebx,%esi
  800639:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80063c:	eb 18                	jmp    800656 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80063e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800642:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800649:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064b:	4b                   	dec    %ebx
  80064c:	eb 08                	jmp    800656 <vprintfmt+0x244>
  80064e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800651:	89 de                	mov    %ebx,%esi
  800653:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800656:	85 db                	test   %ebx,%ebx
  800658:	7f e4                	jg     80063e <vprintfmt+0x22c>
  80065a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80065d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	e9 ce fd ff ff       	jmp    800435 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7e 10                	jle    80067c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 08             	lea    0x8(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 30                	mov    (%eax),%esi
  800677:	8b 78 04             	mov    0x4(%eax),%edi
  80067a:	eb 26                	jmp    8006a2 <vprintfmt+0x290>
	else if (lflag)
  80067c:	85 c9                	test   %ecx,%ecx
  80067e:	74 12                	je     800692 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 30                	mov    (%eax),%esi
  80068b:	89 f7                	mov    %esi,%edi
  80068d:	c1 ff 1f             	sar    $0x1f,%edi
  800690:	eb 10                	jmp    8006a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 30                	mov    (%eax),%esi
  80069d:	89 f7                	mov    %esi,%edi
  80069f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	78 0a                	js     8006b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ab:	e9 8c 00 00 00       	jmp    80073c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006be:	f7 de                	neg    %esi
  8006c0:	83 d7 00             	adc    $0x0,%edi
  8006c3:	f7 df                	neg    %edi
			}
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	eb 70                	jmp    80073c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cc:	89 ca                	mov    %ecx,%edx
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d1:	e8 c0 fc ff ff       	call   800396 <getuint>
  8006d6:	89 c6                	mov    %eax,%esi
  8006d8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006df:	eb 5b                	jmp    80073c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 ab fc ff ff       	call   800396 <getuint>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	89 d7                	mov    %edx,%edi
			base = 8;
  8006ef:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006f4:	eb 46                	jmp    80073c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800701:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 04             	lea    0x4(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071b:	8b 30                	mov    (%eax),%esi
  80071d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800727:	eb 13                	jmp    80073c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800729:	89 ca                	mov    %ecx,%edx
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 63 fc ff ff       	call   800396 <getuint>
  800733:	89 c6                	mov    %eax,%esi
  800735:	89 d7                	mov    %edx,%edi
			base = 16;
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800740:	89 54 24 10          	mov    %edx,0x10(%esp)
  800744:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800747:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	89 34 24             	mov    %esi,(%esp)
  800752:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800756:	89 da                	mov    %ebx,%edx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	e8 6c fb ff ff       	call   8002cc <printnum>
			break;
  800760:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800763:	e9 cd fc ff ff       	jmp    800435 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800775:	e9 bb fc ff ff       	jmp    800435 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800785:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800788:	eb 01                	jmp    80078b <vprintfmt+0x379>
  80078a:	4e                   	dec    %esi
  80078b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80078f:	75 f9                	jne    80078a <vprintfmt+0x378>
  800791:	e9 9f fc ff ff       	jmp    800435 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800796:	83 c4 4c             	add    $0x4c,%esp
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	5f                   	pop    %edi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 28             	sub    $0x28,%esp
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	74 30                	je     8007ef <vsnprintf+0x51>
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	7e 33                	jle    8007f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	c7 04 24 d0 03 80 00 	movl   $0x8003d0,(%esp)
  8007df:	e8 2e fc ff ff       	call   800412 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ed:	eb 0c                	jmp    8007fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f4:	eb 05                	jmp    8007fb <vsnprintf+0x5d>
  8007f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080a:	8b 45 10             	mov    0x10(%ebp),%eax
  80080d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 7b ff ff ff       	call   80079e <vsnprintf>
	va_end(ap);

	return rc;
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    
  800825:	00 00                	add    %al,(%eax)
	...

00800828 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
  800833:	eb 01                	jmp    800836 <strlen+0xe>
		n++;
  800835:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80083a:	75 f9                	jne    800835 <strlen+0xd>
		n++;
	return n;
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	eb 01                	jmp    80084f <strnlen+0x11>
		n++;
  80084e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	39 d0                	cmp    %edx,%eax
  800851:	74 06                	je     800859 <strnlen+0x1b>
  800853:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800857:	75 f5                	jne    80084e <strnlen+0x10>
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800865:	ba 00 00 00 00       	mov    $0x0,%edx
  80086a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80086d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800870:	42                   	inc    %edx
  800871:	84 c9                	test   %cl,%cl
  800873:	75 f5                	jne    80086a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800875:	5b                   	pop    %ebx
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800882:	89 1c 24             	mov    %ebx,(%esp)
  800885:	e8 9e ff ff ff       	call   800828 <strlen>
	strcpy(dst + len, src);
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800891:	01 d8                	add    %ebx,%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 c0 ff ff ff       	call   80085b <strcpy>
	return dst;
}
  80089b:	89 d8                	mov    %ebx,%eax
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	5b                   	pop    %ebx
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b6:	eb 0c                	jmp    8008c4 <strncpy+0x21>
		*dst++ = *src;
  8008b8:	8a 1a                	mov    (%edx),%bl
  8008ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c3:	41                   	inc    %ecx
  8008c4:	39 f1                	cmp    %esi,%ecx
  8008c6:	75 f0                	jne    8008b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008da:	85 d2                	test   %edx,%edx
  8008dc:	75 0a                	jne    8008e8 <strlcpy+0x1c>
  8008de:	89 f0                	mov    %esi,%eax
  8008e0:	eb 1a                	jmp    8008fc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e2:	88 18                	mov    %bl,(%eax)
  8008e4:	40                   	inc    %eax
  8008e5:	41                   	inc    %ecx
  8008e6:	eb 02                	jmp    8008ea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008ea:	4a                   	dec    %edx
  8008eb:	74 0a                	je     8008f7 <strlcpy+0x2b>
  8008ed:	8a 19                	mov    (%ecx),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	75 ef                	jne    8008e2 <strlcpy+0x16>
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	eb 02                	jmp    8008f9 <strlcpy+0x2d>
  8008f7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008f9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008fc:	29 f0                	sub    %esi,%eax
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090b:	eb 02                	jmp    80090f <strcmp+0xd>
		p++, q++;
  80090d:	41                   	inc    %ecx
  80090e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090f:	8a 01                	mov    (%ecx),%al
  800911:	84 c0                	test   %al,%al
  800913:	74 04                	je     800919 <strcmp+0x17>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	74 f4                	je     80090d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800919:	0f b6 c0             	movzbl %al,%eax
  80091c:	0f b6 12             	movzbl (%edx),%edx
  80091f:	29 d0                	sub    %edx,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800930:	eb 03                	jmp    800935 <strncmp+0x12>
		n--, p++, q++;
  800932:	4a                   	dec    %edx
  800933:	40                   	inc    %eax
  800934:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800935:	85 d2                	test   %edx,%edx
  800937:	74 14                	je     80094d <strncmp+0x2a>
  800939:	8a 18                	mov    (%eax),%bl
  80093b:	84 db                	test   %bl,%bl
  80093d:	74 04                	je     800943 <strncmp+0x20>
  80093f:	3a 19                	cmp    (%ecx),%bl
  800941:	74 ef                	je     800932 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800943:	0f b6 00             	movzbl (%eax),%eax
  800946:	0f b6 11             	movzbl (%ecx),%edx
  800949:	29 d0                	sub    %edx,%eax
  80094b:	eb 05                	jmp    800952 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800952:	5b                   	pop    %ebx
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80095e:	eb 05                	jmp    800965 <strchr+0x10>
		if (*s == c)
  800960:	38 ca                	cmp    %cl,%dl
  800962:	74 0c                	je     800970 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800964:	40                   	inc    %eax
  800965:	8a 10                	mov    (%eax),%dl
  800967:	84 d2                	test   %dl,%dl
  800969:	75 f5                	jne    800960 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097b:	eb 05                	jmp    800982 <strfind+0x10>
		if (*s == c)
  80097d:	38 ca                	cmp    %cl,%dl
  80097f:	74 07                	je     800988 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800981:	40                   	inc    %eax
  800982:	8a 10                	mov    (%eax),%dl
  800984:	84 d2                	test   %dl,%dl
  800986:	75 f5                	jne    80097d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 7d 08             	mov    0x8(%ebp),%edi
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800999:	85 c9                	test   %ecx,%ecx
  80099b:	74 30                	je     8009cd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a3:	75 25                	jne    8009ca <memset+0x40>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 20                	jne    8009ca <memset+0x40>
		c &= 0xFF;
  8009aa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ad:	89 d3                	mov    %edx,%ebx
  8009af:	c1 e3 08             	shl    $0x8,%ebx
  8009b2:	89 d6                	mov    %edx,%esi
  8009b4:	c1 e6 18             	shl    $0x18,%esi
  8009b7:	89 d0                	mov    %edx,%eax
  8009b9:	c1 e0 10             	shl    $0x10,%eax
  8009bc:	09 f0                	or     %esi,%eax
  8009be:	09 d0                	or     %edx,%eax
  8009c0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c5:	fc                   	cld    
  8009c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c8:	eb 03                	jmp    8009cd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ca:	fc                   	cld    
  8009cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cd:	89 f8                	mov    %edi,%eax
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e2:	39 c6                	cmp    %eax,%esi
  8009e4:	73 34                	jae    800a1a <memmove+0x46>
  8009e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 2d                	jae    800a1a <memmove+0x46>
		s += n;
		d += n;
  8009ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f0:	f6 c2 03             	test   $0x3,%dl
  8009f3:	75 1b                	jne    800a10 <memmove+0x3c>
  8009f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fb:	75 13                	jne    800a10 <memmove+0x3c>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0e                	jne    800a10 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a02:	83 ef 04             	sub    $0x4,%edi
  800a05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a08:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0b:	fd                   	std    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 07                	jmp    800a17 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a10:	4f                   	dec    %edi
  800a11:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a14:	fd                   	std    
  800a15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a17:	fc                   	cld    
  800a18:	eb 20                	jmp    800a3a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a20:	75 13                	jne    800a35 <memmove+0x61>
  800a22:	a8 03                	test   $0x3,%al
  800a24:	75 0f                	jne    800a35 <memmove+0x61>
  800a26:	f6 c1 03             	test   $0x3,%cl
  800a29:	75 0a                	jne    800a35 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a2e:	89 c7                	mov    %eax,%edi
  800a30:	fc                   	cld    
  800a31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a33:	eb 05                	jmp    800a3a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	fc                   	cld    
  800a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a44:	8b 45 10             	mov    0x10(%ebp),%eax
  800a47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	89 04 24             	mov    %eax,(%esp)
  800a58:	e8 77 ff ff ff       	call   8009d4 <memmove>
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	eb 16                	jmp    800a8b <memcmp+0x2c>
		if (*s1 != *s2)
  800a75:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a78:	42                   	inc    %edx
  800a79:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a7d:	38 c8                	cmp    %cl,%al
  800a7f:	74 0a                	je     800a8b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a81:	0f b6 c0             	movzbl %al,%eax
  800a84:	0f b6 c9             	movzbl %cl,%ecx
  800a87:	29 c8                	sub    %ecx,%eax
  800a89:	eb 09                	jmp    800a94 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8b:	39 da                	cmp    %ebx,%edx
  800a8d:	75 e6                	jne    800a75 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa2:	89 c2                	mov    %eax,%edx
  800aa4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa7:	eb 05                	jmp    800aae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa9:	38 08                	cmp    %cl,(%eax)
  800aab:	74 05                	je     800ab2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aad:	40                   	inc    %eax
  800aae:	39 d0                	cmp    %edx,%eax
  800ab0:	72 f7                	jb     800aa9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac0:	eb 01                	jmp    800ac3 <strtol+0xf>
		s++;
  800ac2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac3:	8a 02                	mov    (%edx),%al
  800ac5:	3c 20                	cmp    $0x20,%al
  800ac7:	74 f9                	je     800ac2 <strtol+0xe>
  800ac9:	3c 09                	cmp    $0x9,%al
  800acb:	74 f5                	je     800ac2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800acd:	3c 2b                	cmp    $0x2b,%al
  800acf:	75 08                	jne    800ad9 <strtol+0x25>
		s++;
  800ad1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad7:	eb 13                	jmp    800aec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad9:	3c 2d                	cmp    $0x2d,%al
  800adb:	75 0a                	jne    800ae7 <strtol+0x33>
		s++, neg = 1;
  800add:	8d 52 01             	lea    0x1(%edx),%edx
  800ae0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae5:	eb 05                	jmp    800aec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	74 05                	je     800af5 <strtol+0x41>
  800af0:	83 fb 10             	cmp    $0x10,%ebx
  800af3:	75 28                	jne    800b1d <strtol+0x69>
  800af5:	8a 02                	mov    (%edx),%al
  800af7:	3c 30                	cmp    $0x30,%al
  800af9:	75 10                	jne    800b0b <strtol+0x57>
  800afb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aff:	75 0a                	jne    800b0b <strtol+0x57>
		s += 2, base = 16;
  800b01:	83 c2 02             	add    $0x2,%edx
  800b04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b09:	eb 12                	jmp    800b1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b0b:	85 db                	test   %ebx,%ebx
  800b0d:	75 0e                	jne    800b1d <strtol+0x69>
  800b0f:	3c 30                	cmp    $0x30,%al
  800b11:	75 05                	jne    800b18 <strtol+0x64>
		s++, base = 8;
  800b13:	42                   	inc    %edx
  800b14:	b3 08                	mov    $0x8,%bl
  800b16:	eb 05                	jmp    800b1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b24:	8a 0a                	mov    (%edx),%cl
  800b26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b29:	80 fb 09             	cmp    $0x9,%bl
  800b2c:	77 08                	ja     800b36 <strtol+0x82>
			dig = *s - '0';
  800b2e:	0f be c9             	movsbl %cl,%ecx
  800b31:	83 e9 30             	sub    $0x30,%ecx
  800b34:	eb 1e                	jmp    800b54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b39:	80 fb 19             	cmp    $0x19,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b3e:	0f be c9             	movsbl %cl,%ecx
  800b41:	83 e9 57             	sub    $0x57,%ecx
  800b44:	eb 0e                	jmp    800b54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b49:	80 fb 19             	cmp    $0x19,%bl
  800b4c:	77 12                	ja     800b60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b4e:	0f be c9             	movsbl %cl,%ecx
  800b51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b54:	39 f1                	cmp    %esi,%ecx
  800b56:	7d 0c                	jge    800b64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b58:	42                   	inc    %edx
  800b59:	0f af c6             	imul   %esi,%eax
  800b5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b5e:	eb c4                	jmp    800b24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b60:	89 c1                	mov    %eax,%ecx
  800b62:	eb 02                	jmp    800b66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 05                	je     800b71 <strtol+0xbd>
		*endptr = (char *) s;
  800b6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b71:	85 ff                	test   %edi,%edi
  800b73:	74 04                	je     800b79 <strtol+0xc5>
  800b75:	89 c8                	mov    %ecx,%eax
  800b77:	f7 d8                	neg    %eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    
	...

00800b80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	89 c6                	mov    %eax,%esi
  800b97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	89 cb                	mov    %ecx,%ebx
  800bd5:	89 cf                	mov    %ecx,%edi
  800bd7:	89 ce                	mov    %ecx,%esi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 28                	jle    800c07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bea:	00 
  800beb:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfa:	00 
  800bfb:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800c02:	e8 b1 f5 ff ff       	call   8001b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c07:	83 c4 2c             	add    $0x2c,%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1f:	89 d1                	mov    %edx,%ecx
  800c21:	89 d3                	mov    %edx,%ebx
  800c23:	89 d7                	mov    %edx,%edi
  800c25:	89 d6                	mov    %edx,%esi
  800c27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_yield>:

void
sys_yield(void)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	ba 00 00 00 00       	mov    $0x0,%edx
  800c39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3e:	89 d1                	mov    %edx,%ecx
  800c40:	89 d3                	mov    %edx,%ebx
  800c42:	89 d7                	mov    %edx,%edi
  800c44:	89 d6                	mov    %edx,%esi
  800c46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	be 00 00 00 00       	mov    $0x0,%esi
  800c5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 f7                	mov    %esi,%edi
  800c6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7e 28                	jle    800c99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800c84:	00 
  800c85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8c:	00 
  800c8d:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800c94:	e8 1f f5 ff ff       	call   8001b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c99:	83 c4 2c             	add    $0x2c,%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	b8 05 00 00 00       	mov    $0x5,%eax
  800caf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 28                	jle    800cec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdf:	00 
  800ce0:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800ce7:	e8 cc f4 ff ff       	call   8001b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cec:	83 c4 2c             	add    $0x2c,%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	b8 06 00 00 00       	mov    $0x6,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 28                	jle    800d3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d22:	00 
  800d23:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800d3a:	e8 79 f4 ff ff       	call   8001b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d3f:	83 c4 2c             	add    $0x2c,%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 28                	jle    800d92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d75:	00 
  800d76:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d85:	00 
  800d86:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800d8d:	e8 26 f4 ff ff       	call   8001b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d92:	83 c4 2c             	add    $0x2c,%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800de0:	e8 d3 f3 ff ff       	call   8001b8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de5:	83 c4 2c             	add    $0x2c,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 28                	jle    800e38 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e14:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800e33:	e8 80 f3 ff ff       	call   8001b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e38:	83 c4 2c             	add    $0x2c,%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	be 00 00 00 00       	mov    $0x0,%esi
  800e4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	89 cb                	mov    %ecx,%ebx
  800e7b:	89 cf                	mov    %ecx,%edi
  800e7d:	89 ce                	mov    %ecx,%esi
  800e7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	7e 28                	jle    800ead <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e89:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e90:	00 
  800e91:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800e98:	00 
  800e99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea0:	00 
  800ea1:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  800ea8:	e8 0b f3 ff ff       	call   8001b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ead:	83 c4 2c             	add    $0x2c,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
  800eb5:	00 00                	add    %al,(%eax)
	...

00800eb8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	53                   	push   %ebx
  800ebc:	83 ec 24             	sub    $0x24,%esp
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ec2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800ec4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ec8:	75 2d                	jne    800ef7 <pgfault+0x3f>
  800eca:	89 d8                	mov    %ebx,%eax
  800ecc:	c1 e8 0c             	shr    $0xc,%eax
  800ecf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed6:	f6 c4 08             	test   $0x8,%ah
  800ed9:	75 1c                	jne    800ef7 <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800edb:	c7 44 24 08 8c 27 80 	movl   $0x80278c,0x8(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800eea:	00 
  800eeb:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800ef2:	e8 c1 f2 ff ff       	call   8001b8 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800ef7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800efe:	00 
  800eff:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f06:	00 
  800f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0e:	e8 3a fd ff ff       	call   800c4d <sys_page_alloc>
  800f13:	85 c0                	test   %eax,%eax
  800f15:	79 20                	jns    800f37 <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800f17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1b:	c7 44 24 08 fb 27 80 	movl   $0x8027fb,0x8(%esp)
  800f22:	00 
  800f23:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f2a:	00 
  800f2b:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800f32:	e8 81 f2 ff ff       	call   8001b8 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800f37:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800f3d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f44:	00 
  800f45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f49:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f50:	e8 e9 fa ff ff       	call   800a3e <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f55:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f5c:	00 
  800f5d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f61:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f68:	00 
  800f69:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f70:	00 
  800f71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f78:	e8 24 fd ff ff       	call   800ca1 <sys_page_map>
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 20                	jns    800fa1 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  800f81:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f85:	c7 44 24 08 0e 28 80 	movl   $0x80280e,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800f9c:	e8 17 f2 ff ff       	call   8001b8 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fa1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fb0:	e8 3f fd ff ff       	call   800cf4 <sys_page_unmap>
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 20                	jns    800fd9 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  800fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fbd:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800fc4:	00 
  800fc5:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800fcc:	00 
  800fcd:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  800fd4:	e8 df f1 ff ff       	call   8001b8 <_panic>
}
  800fd9:	83 c4 24             	add    $0x24,%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  800fe8:	c7 04 24 b8 0e 80 00 	movl   $0x800eb8,(%esp)
  800fef:	e8 fc 10 00 00       	call   8020f0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ff4:	ba 07 00 00 00       	mov    $0x7,%edx
  800ff9:	89 d0                	mov    %edx,%eax
  800ffb:	cd 30                	int    $0x30
  800ffd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801000:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  801003:	85 c0                	test   %eax,%eax
  801005:	79 1c                	jns    801023 <fork+0x44>
		panic("sys_exofork failed\n");
  801007:	c7 44 24 08 32 28 80 	movl   $0x802832,0x8(%esp)
  80100e:	00 
  80100f:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801016:	00 
  801017:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  80101e:	e8 95 f1 ff ff       	call   8001b8 <_panic>
	if(c_envid == 0){
  801023:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801027:	75 25                	jne    80104e <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  801029:	e8 e1 fb ff ff       	call   800c0f <sys_getenvid>
  80102e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801033:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80103a:	c1 e0 07             	shl    $0x7,%eax
  80103d:	29 d0                	sub    %edx,%eax
  80103f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801044:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801049:	e9 e3 01 00 00       	jmp    801231 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  80104e:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  801053:	89 d8                	mov    %ebx,%eax
  801055:	c1 e8 16             	shr    $0x16,%eax
  801058:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105f:	a8 01                	test   $0x1,%al
  801061:	0f 84 0b 01 00 00    	je     801172 <fork+0x193>
  801067:	89 de                	mov    %ebx,%esi
  801069:	c1 ee 0c             	shr    $0xc,%esi
  80106c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801073:	a8 05                	test   $0x5,%al
  801075:	0f 84 f7 00 00 00    	je     801172 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  80107b:	89 f7                	mov    %esi,%edi
  80107d:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  801080:	e8 8a fb ff ff       	call   800c0f <sys_getenvid>
  801085:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801088:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80108f:	a8 02                	test   $0x2,%al
  801091:	75 10                	jne    8010a3 <fork+0xc4>
  801093:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109a:	f6 c4 08             	test   $0x8,%ah
  80109d:	0f 84 89 00 00 00    	je     80112c <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  8010a3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010aa:	00 
  8010ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010bd:	89 04 24             	mov    %eax,(%esp)
  8010c0:	e8 dc fb ff ff       	call   800ca1 <sys_page_map>
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	79 20                	jns    8010e9 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8010c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010cd:	c7 44 24 08 46 28 80 	movl   $0x802846,0x8(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  8010dc:	00 
  8010dd:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  8010e4:	e8 cf f0 ff ff       	call   8001b8 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  8010e9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010f0:	00 
  8010f1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801100:	89 04 24             	mov    %eax,(%esp)
  801103:	e8 99 fb ff ff       	call   800ca1 <sys_page_map>
  801108:	85 c0                	test   %eax,%eax
  80110a:	79 66                	jns    801172 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  80110c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801110:	c7 44 24 08 46 28 80 	movl   $0x802846,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  801127:	e8 8c f0 ff ff       	call   8001b8 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  80112c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801133:	00 
  801134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801138:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80113b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801146:	89 04 24             	mov    %eax,(%esp)
  801149:	e8 53 fb ff ff       	call   800ca1 <sys_page_map>
  80114e:	85 c0                	test   %eax,%eax
  801150:	79 20                	jns    801172 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  801152:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801156:	c7 44 24 08 46 28 80 	movl   $0x802846,0x8(%esp)
  80115d:	00 
  80115e:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  80116d:	e8 46 f0 ff ff       	call   8001b8 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  801172:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801178:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80117e:	0f 85 cf fe ff ff    	jne    801053 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801184:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80118b:	00 
  80118c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801193:	ee 
  801194:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801197:	89 04 24             	mov    %eax,(%esp)
  80119a:	e8 ae fa ff ff       	call   800c4d <sys_page_alloc>
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	79 20                	jns    8011c3 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  8011a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a7:	c7 44 24 08 58 28 80 	movl   $0x802858,0x8(%esp)
  8011ae:	00 
  8011af:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8011b6:	00 
  8011b7:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  8011be:	e8 f5 ef ff ff       	call   8001b8 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  8011c3:	c7 44 24 04 3c 21 80 	movl   $0x80213c,0x4(%esp)
  8011ca:	00 
  8011cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011ce:	89 04 24             	mov    %eax,(%esp)
  8011d1:	e8 17 fc ff ff       	call   800ded <sys_env_set_pgfault_upcall>
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	79 20                	jns    8011fa <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8011da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011de:	c7 44 24 08 d0 27 80 	movl   $0x8027d0,0x8(%esp)
  8011e5:	00 
  8011e6:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8011ed:	00 
  8011ee:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  8011f5:	e8 be ef ff ff       	call   8001b8 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  8011fa:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801201:	00 
  801202:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801205:	89 04 24             	mov    %eax,(%esp)
  801208:	e8 3a fb ff ff       	call   800d47 <sys_env_set_status>
  80120d:	85 c0                	test   %eax,%eax
  80120f:	79 20                	jns    801231 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  801211:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801215:	c7 44 24 08 6c 28 80 	movl   $0x80286c,0x8(%esp)
  80121c:	00 
  80121d:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801224:	00 
  801225:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  80122c:	e8 87 ef ff ff       	call   8001b8 <_panic>
 
	return c_envid;	
}
  801231:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801234:	83 c4 3c             	add    $0x3c,%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <sfork>:

// Challenge!
int
sfork(void)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801242:	c7 44 24 08 84 28 80 	movl   $0x802884,0x8(%esp)
  801249:	00 
  80124a:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801251:	00 
  801252:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  801259:	e8 5a ef ff ff       	call   8001b8 <_panic>
	...

00801260 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
  801266:	83 ec 1c             	sub    $0x1c,%esp
  801269:	8b 75 08             	mov    0x8(%ebp),%esi
  80126c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126f:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801272:	85 db                	test   %ebx,%ebx
  801274:	75 05                	jne    80127b <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801276:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  80127b:	89 1c 24             	mov    %ebx,(%esp)
  80127e:	e8 e0 fb ff ff       	call   800e63 <sys_ipc_recv>
  801283:	85 c0                	test   %eax,%eax
  801285:	79 16                	jns    80129d <ipc_recv+0x3d>
		*from_env_store = 0;
  801287:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  80128d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801293:	89 1c 24             	mov    %ebx,(%esp)
  801296:	e8 c8 fb ff ff       	call   800e63 <sys_ipc_recv>
  80129b:	eb 24                	jmp    8012c1 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  80129d:	85 f6                	test   %esi,%esi
  80129f:	74 0a                	je     8012ab <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8012a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a6:	8b 40 74             	mov    0x74(%eax),%eax
  8012a9:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8012ab:	85 ff                	test   %edi,%edi
  8012ad:	74 0a                	je     8012b9 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8012af:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b4:	8b 40 78             	mov    0x78(%eax),%eax
  8012b7:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8012b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012be:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012c1:	83 c4 1c             	add    $0x1c,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 1c             	sub    $0x1c,%esp
  8012d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8012db:	85 db                	test   %ebx,%ebx
  8012dd:	75 05                	jne    8012e4 <ipc_send+0x1b>
		pg = (void *)-1;
  8012df:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8012e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f3:	89 04 24             	mov    %eax,(%esp)
  8012f6:	e8 45 fb ff ff       	call   800e40 <sys_ipc_try_send>
		if (r == 0) {		
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	74 2c                	je     80132b <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  8012ff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801302:	75 07                	jne    80130b <ipc_send+0x42>
			sys_yield();
  801304:	e8 25 f9 ff ff       	call   800c2e <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801309:	eb d9                	jmp    8012e4 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80130b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130f:	c7 44 24 08 9a 28 80 	movl   $0x80289a,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 a8 28 80 00 	movl   $0x8028a8,(%esp)
  801326:	e8 8d ee ff ff       	call   8001b8 <_panic>
		}
	}
}
  80132b:	83 c4 1c             	add    $0x1c,%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	53                   	push   %ebx
  801337:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80133f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801346:	89 c2                	mov    %eax,%edx
  801348:	c1 e2 07             	shl    $0x7,%edx
  80134b:	29 ca                	sub    %ecx,%edx
  80134d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801353:	8b 52 50             	mov    0x50(%edx),%edx
  801356:	39 da                	cmp    %ebx,%edx
  801358:	75 0f                	jne    801369 <ipc_find_env+0x36>
			return envs[i].env_id;
  80135a:	c1 e0 07             	shl    $0x7,%eax
  80135d:	29 c8                	sub    %ecx,%eax
  80135f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801364:	8b 40 40             	mov    0x40(%eax),%eax
  801367:	eb 0c                	jmp    801375 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801369:	40                   	inc    %eax
  80136a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80136f:	75 ce                	jne    80133f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801371:	66 b8 00 00          	mov    $0x0,%ax
}
  801375:	5b                   	pop    %ebx
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
  80137e:	05 00 00 00 30       	add    $0x30000000,%eax
  801383:	c1 e8 0c             	shr    $0xc,%eax
}
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
  801391:	89 04 24             	mov    %eax,(%esp)
  801394:	e8 df ff ff ff       	call   801378 <fd2num>
  801399:	05 20 00 0d 00       	add    $0xd0020,%eax
  80139e:	c1 e0 0c             	shl    $0xc,%eax
}
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	53                   	push   %ebx
  8013a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013af:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	c1 ea 16             	shr    $0x16,%edx
  8013b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013bd:	f6 c2 01             	test   $0x1,%dl
  8013c0:	74 11                	je     8013d3 <fd_alloc+0x30>
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	c1 ea 0c             	shr    $0xc,%edx
  8013c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	75 09                	jne    8013dc <fd_alloc+0x39>
			*fd_store = fd;
  8013d3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	eb 17                	jmp    8013f3 <fd_alloc+0x50>
  8013dc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013e1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013e6:	75 c7                	jne    8013af <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013ee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013f3:	5b                   	pop    %ebx
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013fc:	83 f8 1f             	cmp    $0x1f,%eax
  8013ff:	77 36                	ja     801437 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801401:	05 00 00 0d 00       	add    $0xd0000,%eax
  801406:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801409:	89 c2                	mov    %eax,%edx
  80140b:	c1 ea 16             	shr    $0x16,%edx
  80140e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801415:	f6 c2 01             	test   $0x1,%dl
  801418:	74 24                	je     80143e <fd_lookup+0x48>
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	c1 ea 0c             	shr    $0xc,%edx
  80141f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801426:	f6 c2 01             	test   $0x1,%dl
  801429:	74 1a                	je     801445 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80142b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142e:	89 02                	mov    %eax,(%edx)
	return 0;
  801430:	b8 00 00 00 00       	mov    $0x0,%eax
  801435:	eb 13                	jmp    80144a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143c:	eb 0c                	jmp    80144a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80143e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801443:	eb 05                	jmp    80144a <fd_lookup+0x54>
  801445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	53                   	push   %ebx
  801450:	83 ec 14             	sub    $0x14,%esp
  801453:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801459:	ba 00 00 00 00       	mov    $0x0,%edx
  80145e:	eb 0e                	jmp    80146e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801460:	39 08                	cmp    %ecx,(%eax)
  801462:	75 09                	jne    80146d <dev_lookup+0x21>
			*dev = devtab[i];
  801464:	89 03                	mov    %eax,(%ebx)
			return 0;
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
  80146b:	eb 33                	jmp    8014a0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80146d:	42                   	inc    %edx
  80146e:	8b 04 95 34 29 80 00 	mov    0x802934(,%edx,4),%eax
  801475:	85 c0                	test   %eax,%eax
  801477:	75 e7                	jne    801460 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801479:	a1 04 40 80 00       	mov    0x804004,%eax
  80147e:	8b 40 48             	mov    0x48(%eax),%eax
  801481:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801485:	89 44 24 04          	mov    %eax,0x4(%esp)
  801489:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  801490:	e8 1b ee ff ff       	call   8002b0 <cprintf>
	*dev = 0;
  801495:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80149b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014a0:	83 c4 14             	add    $0x14,%esp
  8014a3:	5b                   	pop    %ebx
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	56                   	push   %esi
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 30             	sub    $0x30,%esp
  8014ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b1:	8a 45 0c             	mov    0xc(%ebp),%al
  8014b4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014b7:	89 34 24             	mov    %esi,(%esp)
  8014ba:	e8 b9 fe ff ff       	call   801378 <fd2num>
  8014bf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014c6:	89 04 24             	mov    %eax,(%esp)
  8014c9:	e8 28 ff ff ff       	call   8013f6 <fd_lookup>
  8014ce:	89 c3                	mov    %eax,%ebx
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 05                	js     8014d9 <fd_close+0x33>
	    || fd != fd2)
  8014d4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014d7:	74 0d                	je     8014e6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8014d9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014dd:	75 46                	jne    801525 <fd_close+0x7f>
  8014df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e4:	eb 3f                	jmp    801525 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ed:	8b 06                	mov    (%esi),%eax
  8014ef:	89 04 24             	mov    %eax,(%esp)
  8014f2:	e8 55 ff ff ff       	call   80144c <dev_lookup>
  8014f7:	89 c3                	mov    %eax,%ebx
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 18                	js     801515 <fd_close+0x6f>
		if (dev->dev_close)
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	8b 40 10             	mov    0x10(%eax),%eax
  801503:	85 c0                	test   %eax,%eax
  801505:	74 09                	je     801510 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801507:	89 34 24             	mov    %esi,(%esp)
  80150a:	ff d0                	call   *%eax
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	eb 05                	jmp    801515 <fd_close+0x6f>
		else
			r = 0;
  801510:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801515:	89 74 24 04          	mov    %esi,0x4(%esp)
  801519:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801520:	e8 cf f7 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
}
  801525:	89 d8                	mov    %ebx,%eax
  801527:	83 c4 30             	add    $0x30,%esp
  80152a:	5b                   	pop    %ebx
  80152b:	5e                   	pop    %esi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
  80153e:	89 04 24             	mov    %eax,(%esp)
  801541:	e8 b0 fe ff ff       	call   8013f6 <fd_lookup>
  801546:	85 c0                	test   %eax,%eax
  801548:	78 13                	js     80155d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80154a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801551:	00 
  801552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	e8 49 ff ff ff       	call   8014a6 <fd_close>
}
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <close_all>:

void
close_all(void)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	53                   	push   %ebx
  801563:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801566:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80156b:	89 1c 24             	mov    %ebx,(%esp)
  80156e:	e8 bb ff ff ff       	call   80152e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801573:	43                   	inc    %ebx
  801574:	83 fb 20             	cmp    $0x20,%ebx
  801577:	75 f2                	jne    80156b <close_all+0xc>
		close(i);
}
  801579:	83 c4 14             	add    $0x14,%esp
  80157c:	5b                   	pop    %ebx
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    

0080157f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	57                   	push   %edi
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	83 ec 4c             	sub    $0x4c,%esp
  801588:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80158b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80158e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	e8 59 fe ff ff       	call   8013f6 <fd_lookup>
  80159d:	89 c3                	mov    %eax,%ebx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	0f 88 e1 00 00 00    	js     801688 <dup+0x109>
		return r;
	close(newfdnum);
  8015a7:	89 3c 24             	mov    %edi,(%esp)
  8015aa:	e8 7f ff ff ff       	call   80152e <close>

	newfd = INDEX2FD(newfdnum);
  8015af:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015b5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015bb:	89 04 24             	mov    %eax,(%esp)
  8015be:	e8 c5 fd ff ff       	call   801388 <fd2data>
  8015c3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015c5:	89 34 24             	mov    %esi,(%esp)
  8015c8:	e8 bb fd ff ff       	call   801388 <fd2data>
  8015cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015d0:	89 d8                	mov    %ebx,%eax
  8015d2:	c1 e8 16             	shr    $0x16,%eax
  8015d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015dc:	a8 01                	test   $0x1,%al
  8015de:	74 46                	je     801626 <dup+0xa7>
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	c1 e8 0c             	shr    $0xc,%eax
  8015e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ec:	f6 c2 01             	test   $0x1,%dl
  8015ef:	74 35                	je     801626 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8015fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801601:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801604:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801608:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80160f:	00 
  801610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801614:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80161b:	e8 81 f6 ff ff       	call   800ca1 <sys_page_map>
  801620:	89 c3                	mov    %eax,%ebx
  801622:	85 c0                	test   %eax,%eax
  801624:	78 3b                	js     801661 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801629:	89 c2                	mov    %eax,%edx
  80162b:	c1 ea 0c             	shr    $0xc,%edx
  80162e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801635:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80163b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80163f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801643:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164a:	00 
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801656:	e8 46 f6 ff ff       	call   800ca1 <sys_page_map>
  80165b:	89 c3                	mov    %eax,%ebx
  80165d:	85 c0                	test   %eax,%eax
  80165f:	79 25                	jns    801686 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801661:	89 74 24 04          	mov    %esi,0x4(%esp)
  801665:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166c:	e8 83 f6 ff ff       	call   800cf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801671:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801674:	89 44 24 04          	mov    %eax,0x4(%esp)
  801678:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167f:	e8 70 f6 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  801684:	eb 02                	jmp    801688 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801686:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801688:	89 d8                	mov    %ebx,%eax
  80168a:	83 c4 4c             	add    $0x4c,%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5f                   	pop    %edi
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	53                   	push   %ebx
  801696:	83 ec 24             	sub    $0x24,%esp
  801699:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a3:	89 1c 24             	mov    %ebx,(%esp)
  8016a6:	e8 4b fd ff ff       	call   8013f6 <fd_lookup>
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 6d                	js     80171c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b9:	8b 00                	mov    (%eax),%eax
  8016bb:	89 04 24             	mov    %eax,(%esp)
  8016be:	e8 89 fd ff ff       	call   80144c <dev_lookup>
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 55                	js     80171c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ca:	8b 50 08             	mov    0x8(%eax),%edx
  8016cd:	83 e2 03             	and    $0x3,%edx
  8016d0:	83 fa 01             	cmp    $0x1,%edx
  8016d3:	75 23                	jne    8016f8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8016da:	8b 40 48             	mov    0x48(%eax),%eax
  8016dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e5:	c7 04 24 f8 28 80 00 	movl   $0x8028f8,(%esp)
  8016ec:	e8 bf eb ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  8016f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f6:	eb 24                	jmp    80171c <read+0x8a>
	}
	if (!dev->dev_read)
  8016f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fb:	8b 52 08             	mov    0x8(%edx),%edx
  8016fe:	85 d2                	test   %edx,%edx
  801700:	74 15                	je     801717 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801702:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801705:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801710:	89 04 24             	mov    %eax,(%esp)
  801713:	ff d2                	call   *%edx
  801715:	eb 05                	jmp    80171c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801717:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80171c:	83 c4 24             	add    $0x24,%esp
  80171f:	5b                   	pop    %ebx
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	57                   	push   %edi
  801726:	56                   	push   %esi
  801727:	53                   	push   %ebx
  801728:	83 ec 1c             	sub    $0x1c,%esp
  80172b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80172e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801731:	bb 00 00 00 00       	mov    $0x0,%ebx
  801736:	eb 23                	jmp    80175b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801738:	89 f0                	mov    %esi,%eax
  80173a:	29 d8                	sub    %ebx,%eax
  80173c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801740:	8b 45 0c             	mov    0xc(%ebp),%eax
  801743:	01 d8                	add    %ebx,%eax
  801745:	89 44 24 04          	mov    %eax,0x4(%esp)
  801749:	89 3c 24             	mov    %edi,(%esp)
  80174c:	e8 41 ff ff ff       	call   801692 <read>
		if (m < 0)
  801751:	85 c0                	test   %eax,%eax
  801753:	78 10                	js     801765 <readn+0x43>
			return m;
		if (m == 0)
  801755:	85 c0                	test   %eax,%eax
  801757:	74 0a                	je     801763 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801759:	01 c3                	add    %eax,%ebx
  80175b:	39 f3                	cmp    %esi,%ebx
  80175d:	72 d9                	jb     801738 <readn+0x16>
  80175f:	89 d8                	mov    %ebx,%eax
  801761:	eb 02                	jmp    801765 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801763:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801765:	83 c4 1c             	add    $0x1c,%esp
  801768:	5b                   	pop    %ebx
  801769:	5e                   	pop    %esi
  80176a:	5f                   	pop    %edi
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	53                   	push   %ebx
  801771:	83 ec 24             	sub    $0x24,%esp
  801774:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801777:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177e:	89 1c 24             	mov    %ebx,(%esp)
  801781:	e8 70 fc ff ff       	call   8013f6 <fd_lookup>
  801786:	85 c0                	test   %eax,%eax
  801788:	78 68                	js     8017f2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801791:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801794:	8b 00                	mov    (%eax),%eax
  801796:	89 04 24             	mov    %eax,(%esp)
  801799:	e8 ae fc ff ff       	call   80144c <dev_lookup>
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 50                	js     8017f2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a9:	75 23                	jne    8017ce <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8017b0:	8b 40 48             	mov    0x48(%eax),%eax
  8017b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bb:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  8017c2:	e8 e9 ea ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  8017c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017cc:	eb 24                	jmp    8017f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d4:	85 d2                	test   %edx,%edx
  8017d6:	74 15                	je     8017ed <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017e6:	89 04 24             	mov    %eax,(%esp)
  8017e9:	ff d2                	call   *%edx
  8017eb:	eb 05                	jmp    8017f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017f2:	83 c4 24             	add    $0x24,%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801801:	89 44 24 04          	mov    %eax,0x4(%esp)
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	e8 e6 fb ff ff       	call   8013f6 <fd_lookup>
  801810:	85 c0                	test   %eax,%eax
  801812:	78 0e                	js     801822 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801814:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80181d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	53                   	push   %ebx
  801828:	83 ec 24             	sub    $0x24,%esp
  80182b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801831:	89 44 24 04          	mov    %eax,0x4(%esp)
  801835:	89 1c 24             	mov    %ebx,(%esp)
  801838:	e8 b9 fb ff ff       	call   8013f6 <fd_lookup>
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 61                	js     8018a2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801841:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801844:	89 44 24 04          	mov    %eax,0x4(%esp)
  801848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184b:	8b 00                	mov    (%eax),%eax
  80184d:	89 04 24             	mov    %eax,(%esp)
  801850:	e8 f7 fb ff ff       	call   80144c <dev_lookup>
  801855:	85 c0                	test   %eax,%eax
  801857:	78 49                	js     8018a2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801859:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801860:	75 23                	jne    801885 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801862:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801867:	8b 40 48             	mov    0x48(%eax),%eax
  80186a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801872:	c7 04 24 d4 28 80 00 	movl   $0x8028d4,(%esp)
  801879:	e8 32 ea ff ff       	call   8002b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80187e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801883:	eb 1d                	jmp    8018a2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801885:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801888:	8b 52 18             	mov    0x18(%edx),%edx
  80188b:	85 d2                	test   %edx,%edx
  80188d:	74 0e                	je     80189d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80188f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801892:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801896:	89 04 24             	mov    %eax,(%esp)
  801899:	ff d2                	call   *%edx
  80189b:	eb 05                	jmp    8018a2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80189d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018a2:	83 c4 24             	add    $0x24,%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 24             	sub    $0x24,%esp
  8018af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	89 04 24             	mov    %eax,(%esp)
  8018bf:	e8 32 fb ff ff       	call   8013f6 <fd_lookup>
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 52                	js     80191a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d2:	8b 00                	mov    (%eax),%eax
  8018d4:	89 04 24             	mov    %eax,(%esp)
  8018d7:	e8 70 fb ff ff       	call   80144c <dev_lookup>
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 3a                	js     80191a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018e7:	74 2c                	je     801915 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018f3:	00 00 00 
	stat->st_isdir = 0;
  8018f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018fd:	00 00 00 
	stat->st_dev = dev;
  801900:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801906:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80190a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80190d:	89 14 24             	mov    %edx,(%esp)
  801910:	ff 50 14             	call   *0x14(%eax)
  801913:	eb 05                	jmp    80191a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801915:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80191a:	83 c4 24             	add    $0x24,%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801928:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80192f:	00 
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	89 04 24             	mov    %eax,(%esp)
  801936:	e8 fe 01 00 00       	call   801b39 <open>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 1b                	js     80195c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801941:	8b 45 0c             	mov    0xc(%ebp),%eax
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	89 1c 24             	mov    %ebx,(%esp)
  80194b:	e8 58 ff ff ff       	call   8018a8 <fstat>
  801950:	89 c6                	mov    %eax,%esi
	close(fd);
  801952:	89 1c 24             	mov    %ebx,(%esp)
  801955:	e8 d4 fb ff ff       	call   80152e <close>
	return r;
  80195a:	89 f3                	mov    %esi,%ebx
}
  80195c:	89 d8                	mov    %ebx,%eax
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    
  801965:	00 00                	add    %al,(%eax)
	...

00801968 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	83 ec 10             	sub    $0x10,%esp
  801970:	89 c3                	mov    %eax,%ebx
  801972:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801974:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80197b:	75 11                	jne    80198e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80197d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801984:	e8 aa f9 ff ff       	call   801333 <ipc_find_env>
  801989:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80198e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801995:	00 
  801996:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80199d:	00 
  80199e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8019a7:	89 04 24             	mov    %eax,(%esp)
  8019aa:	e8 1a f9 ff ff       	call   8012c9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019b6:	00 
  8019b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c2:	e8 99 f8 ff ff       	call   801260 <ipc_recv>
}
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5e                   	pop    %esi
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8019f1:	e8 72 ff ff ff       	call   801968 <fsipc>
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	8b 40 0c             	mov    0xc(%eax),%eax
  801a04:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a09:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0e:	b8 06 00 00 00       	mov    $0x6,%eax
  801a13:	e8 50 ff ff ff       	call   801968 <fsipc>
}
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	53                   	push   %ebx
  801a1e:	83 ec 14             	sub    $0x14,%esp
  801a21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a24:	8b 45 08             	mov    0x8(%ebp),%eax
  801a27:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a34:	b8 05 00 00 00       	mov    $0x5,%eax
  801a39:	e8 2a ff ff ff       	call   801968 <fsipc>
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 2b                	js     801a6d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a42:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a49:	00 
  801a4a:	89 1c 24             	mov    %ebx,(%esp)
  801a4d:	e8 09 ee ff ff       	call   80085b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a52:	a1 80 50 80 00       	mov    0x805080,%eax
  801a57:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a5d:	a1 84 50 80 00       	mov    0x805084,%eax
  801a62:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a6d:	83 c4 14             	add    $0x14,%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    

00801a73 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a79:	c7 44 24 08 44 29 80 	movl   $0x802944,0x8(%esp)
  801a80:	00 
  801a81:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a88:	00 
  801a89:	c7 04 24 62 29 80 00 	movl   $0x802962,(%esp)
  801a90:	e8 23 e7 ff ff       	call   8001b8 <_panic>

00801a95 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 10             	sub    $0x10,%esp
  801a9d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aab:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab6:	b8 03 00 00 00       	mov    $0x3,%eax
  801abb:	e8 a8 fe ff ff       	call   801968 <fsipc>
  801ac0:	89 c3                	mov    %eax,%ebx
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 6a                	js     801b30 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ac6:	39 c6                	cmp    %eax,%esi
  801ac8:	73 24                	jae    801aee <devfile_read+0x59>
  801aca:	c7 44 24 0c 6d 29 80 	movl   $0x80296d,0xc(%esp)
  801ad1:	00 
  801ad2:	c7 44 24 08 74 29 80 	movl   $0x802974,0x8(%esp)
  801ad9:	00 
  801ada:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ae1:	00 
  801ae2:	c7 04 24 62 29 80 00 	movl   $0x802962,(%esp)
  801ae9:	e8 ca e6 ff ff       	call   8001b8 <_panic>
	assert(r <= PGSIZE);
  801aee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af3:	7e 24                	jle    801b19 <devfile_read+0x84>
  801af5:	c7 44 24 0c 89 29 80 	movl   $0x802989,0xc(%esp)
  801afc:	00 
  801afd:	c7 44 24 08 74 29 80 	movl   $0x802974,0x8(%esp)
  801b04:	00 
  801b05:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b0c:	00 
  801b0d:	c7 04 24 62 29 80 00 	movl   $0x802962,(%esp)
  801b14:	e8 9f e6 ff ff       	call   8001b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b19:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b1d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b24:	00 
  801b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b28:	89 04 24             	mov    %eax,(%esp)
  801b2b:	e8 a4 ee ff ff       	call   8009d4 <memmove>
	return r;
}
  801b30:	89 d8                	mov    %ebx,%eax
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 20             	sub    $0x20,%esp
  801b41:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b44:	89 34 24             	mov    %esi,(%esp)
  801b47:	e8 dc ec ff ff       	call   800828 <strlen>
  801b4c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b51:	7f 60                	jg     801bb3 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b56:	89 04 24             	mov    %eax,(%esp)
  801b59:	e8 45 f8 ff ff       	call   8013a3 <fd_alloc>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 54                	js     801bb8 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b68:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b6f:	e8 e7 ec ff ff       	call   80085b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b77:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b84:	e8 df fd ff ff       	call   801968 <fsipc>
  801b89:	89 c3                	mov    %eax,%ebx
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	79 15                	jns    801ba4 <open+0x6b>
		fd_close(fd, 0);
  801b8f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b96:	00 
  801b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9a:	89 04 24             	mov    %eax,(%esp)
  801b9d:	e8 04 f9 ff ff       	call   8014a6 <fd_close>
		return r;
  801ba2:	eb 14                	jmp    801bb8 <open+0x7f>
	}

	return fd2num(fd);
  801ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba7:	89 04 24             	mov    %eax,(%esp)
  801baa:	e8 c9 f7 ff ff       	call   801378 <fd2num>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	eb 05                	jmp    801bb8 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bb3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bb8:	89 d8                	mov    %ebx,%eax
  801bba:	83 c4 20             	add    $0x20,%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcc:	b8 08 00 00 00       	mov    $0x8,%eax
  801bd1:	e8 92 fd ff ff       	call   801968 <fsipc>
}
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 10             	sub    $0x10,%esp
  801be0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	89 04 24             	mov    %eax,(%esp)
  801be9:	e8 9a f7 ff ff       	call   801388 <fd2data>
  801bee:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bf0:	c7 44 24 04 95 29 80 	movl   $0x802995,0x4(%esp)
  801bf7:	00 
  801bf8:	89 34 24             	mov    %esi,(%esp)
  801bfb:	e8 5b ec ff ff       	call   80085b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c00:	8b 43 04             	mov    0x4(%ebx),%eax
  801c03:	2b 03                	sub    (%ebx),%eax
  801c05:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c0b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c12:	00 00 00 
	stat->st_dev = &devpipe;
  801c15:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c1c:	30 80 00 
	return 0;
}
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	53                   	push   %ebx
  801c2f:	83 ec 14             	sub    $0x14,%esp
  801c32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c35:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c40:	e8 af f0 ff ff       	call   800cf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c45:	89 1c 24             	mov    %ebx,(%esp)
  801c48:	e8 3b f7 ff ff       	call   801388 <fd2data>
  801c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c58:	e8 97 f0 ff ff       	call   800cf4 <sys_page_unmap>
}
  801c5d:	83 c4 14             	add    $0x14,%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5d                   	pop    %ebp
  801c62:	c3                   	ret    

00801c63 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	57                   	push   %edi
  801c67:	56                   	push   %esi
  801c68:	53                   	push   %ebx
  801c69:	83 ec 2c             	sub    $0x2c,%esp
  801c6c:	89 c7                	mov    %eax,%edi
  801c6e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c71:	a1 04 40 80 00       	mov    0x804004,%eax
  801c76:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c79:	89 3c 24             	mov    %edi,(%esp)
  801c7c:	e8 e3 04 00 00       	call   802164 <pageref>
  801c81:	89 c6                	mov    %eax,%esi
  801c83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c86:	89 04 24             	mov    %eax,(%esp)
  801c89:	e8 d6 04 00 00       	call   802164 <pageref>
  801c8e:	39 c6                	cmp    %eax,%esi
  801c90:	0f 94 c0             	sete   %al
  801c93:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c96:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c9c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c9f:	39 cb                	cmp    %ecx,%ebx
  801ca1:	75 08                	jne    801cab <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ca3:	83 c4 2c             	add    $0x2c,%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5e                   	pop    %esi
  801ca8:	5f                   	pop    %edi
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cab:	83 f8 01             	cmp    $0x1,%eax
  801cae:	75 c1                	jne    801c71 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cb0:	8b 42 58             	mov    0x58(%edx),%eax
  801cb3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801cba:	00 
  801cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cbf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc3:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  801cca:	e8 e1 e5 ff ff       	call   8002b0 <cprintf>
  801ccf:	eb a0                	jmp    801c71 <_pipeisclosed+0xe>

00801cd1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	57                   	push   %edi
  801cd5:	56                   	push   %esi
  801cd6:	53                   	push   %ebx
  801cd7:	83 ec 1c             	sub    $0x1c,%esp
  801cda:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cdd:	89 34 24             	mov    %esi,(%esp)
  801ce0:	e8 a3 f6 ff ff       	call   801388 <fd2data>
  801ce5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce7:	bf 00 00 00 00       	mov    $0x0,%edi
  801cec:	eb 3c                	jmp    801d2a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cee:	89 da                	mov    %ebx,%edx
  801cf0:	89 f0                	mov    %esi,%eax
  801cf2:	e8 6c ff ff ff       	call   801c63 <_pipeisclosed>
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	75 38                	jne    801d33 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cfb:	e8 2e ef ff ff       	call   800c2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d00:	8b 43 04             	mov    0x4(%ebx),%eax
  801d03:	8b 13                	mov    (%ebx),%edx
  801d05:	83 c2 20             	add    $0x20,%edx
  801d08:	39 d0                	cmp    %edx,%eax
  801d0a:	73 e2                	jae    801cee <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d1a:	79 05                	jns    801d21 <devpipe_write+0x50>
  801d1c:	4a                   	dec    %edx
  801d1d:	83 ca e0             	or     $0xffffffe0,%edx
  801d20:	42                   	inc    %edx
  801d21:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d25:	40                   	inc    %eax
  801d26:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d29:	47                   	inc    %edi
  801d2a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d2d:	75 d1                	jne    801d00 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d2f:	89 f8                	mov    %edi,%eax
  801d31:	eb 05                	jmp    801d38 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d38:	83 c4 1c             	add    $0x1c,%esp
  801d3b:	5b                   	pop    %ebx
  801d3c:	5e                   	pop    %esi
  801d3d:	5f                   	pop    %edi
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	57                   	push   %edi
  801d44:	56                   	push   %esi
  801d45:	53                   	push   %ebx
  801d46:	83 ec 1c             	sub    $0x1c,%esp
  801d49:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d4c:	89 3c 24             	mov    %edi,(%esp)
  801d4f:	e8 34 f6 ff ff       	call   801388 <fd2data>
  801d54:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d56:	be 00 00 00 00       	mov    $0x0,%esi
  801d5b:	eb 3a                	jmp    801d97 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d5d:	85 f6                	test   %esi,%esi
  801d5f:	74 04                	je     801d65 <devpipe_read+0x25>
				return i;
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	eb 40                	jmp    801da5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d65:	89 da                	mov    %ebx,%edx
  801d67:	89 f8                	mov    %edi,%eax
  801d69:	e8 f5 fe ff ff       	call   801c63 <_pipeisclosed>
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	75 2e                	jne    801da0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d72:	e8 b7 ee ff ff       	call   800c2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d77:	8b 03                	mov    (%ebx),%eax
  801d79:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d7c:	74 df                	je     801d5d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d7e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d83:	79 05                	jns    801d8a <devpipe_read+0x4a>
  801d85:	48                   	dec    %eax
  801d86:	83 c8 e0             	or     $0xffffffe0,%eax
  801d89:	40                   	inc    %eax
  801d8a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d91:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d94:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d96:	46                   	inc    %esi
  801d97:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d9a:	75 db                	jne    801d77 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d9c:	89 f0                	mov    %esi,%eax
  801d9e:	eb 05                	jmp    801da5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801da5:	83 c4 1c             	add    $0x1c,%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	57                   	push   %edi
  801db1:	56                   	push   %esi
  801db2:	53                   	push   %ebx
  801db3:	83 ec 3c             	sub    $0x3c,%esp
  801db6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801db9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dbc:	89 04 24             	mov    %eax,(%esp)
  801dbf:	e8 df f5 ff ff       	call   8013a3 <fd_alloc>
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	0f 88 45 01 00 00    	js     801f13 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dce:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dd5:	00 
  801dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de4:	e8 64 ee ff ff       	call   800c4d <sys_page_alloc>
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	85 c0                	test   %eax,%eax
  801ded:	0f 88 20 01 00 00    	js     801f13 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801df3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801df6:	89 04 24             	mov    %eax,(%esp)
  801df9:	e8 a5 f5 ff ff       	call   8013a3 <fd_alloc>
  801dfe:	89 c3                	mov    %eax,%ebx
  801e00:	85 c0                	test   %eax,%eax
  801e02:	0f 88 f8 00 00 00    	js     801f00 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e08:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e0f:	00 
  801e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1e:	e8 2a ee ff ff       	call   800c4d <sys_page_alloc>
  801e23:	89 c3                	mov    %eax,%ebx
  801e25:	85 c0                	test   %eax,%eax
  801e27:	0f 88 d3 00 00 00    	js     801f00 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e30:	89 04 24             	mov    %eax,(%esp)
  801e33:	e8 50 f5 ff ff       	call   801388 <fd2data>
  801e38:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e41:	00 
  801e42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4d:	e8 fb ed ff ff       	call   800c4d <sys_page_alloc>
  801e52:	89 c3                	mov    %eax,%ebx
  801e54:	85 c0                	test   %eax,%eax
  801e56:	0f 88 91 00 00 00    	js     801eed <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e5f:	89 04 24             	mov    %eax,(%esp)
  801e62:	e8 21 f5 ff ff       	call   801388 <fd2data>
  801e67:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e6e:	00 
  801e6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e7a:	00 
  801e7b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e86:	e8 16 ee ff ff       	call   800ca1 <sys_page_map>
  801e8b:	89 c3                	mov    %eax,%ebx
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 4c                	js     801edd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e91:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e9a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e9f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ea6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eaf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eb4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ebb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ebe:	89 04 24             	mov    %eax,(%esp)
  801ec1:	e8 b2 f4 ff ff       	call   801378 <fd2num>
  801ec6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ecb:	89 04 24             	mov    %eax,(%esp)
  801ece:	e8 a5 f4 ff ff       	call   801378 <fd2num>
  801ed3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801edb:	eb 36                	jmp    801f13 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801edd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee8:	e8 07 ee ff ff       	call   800cf4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801eed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efb:	e8 f4 ed ff ff       	call   800cf4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0e:	e8 e1 ed ff ff       	call   800cf4 <sys_page_unmap>
    err:
	return r;
}
  801f13:	89 d8                	mov    %ebx,%eax
  801f15:	83 c4 3c             	add    $0x3c,%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    

00801f1d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f26:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2d:	89 04 24             	mov    %eax,(%esp)
  801f30:	e8 c1 f4 ff ff       	call   8013f6 <fd_lookup>
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 15                	js     801f4e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3c:	89 04 24             	mov    %eax,(%esp)
  801f3f:	e8 44 f4 ff ff       	call   801388 <fd2data>
	return _pipeisclosed(fd, p);
  801f44:	89 c2                	mov    %eax,%edx
  801f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f49:	e8 15 fd ff ff       	call   801c63 <_pipeisclosed>
}
  801f4e:	c9                   	leave  
  801f4f:	c3                   	ret    

00801f50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f60:	c7 44 24 04 b4 29 80 	movl   $0x8029b4,0x4(%esp)
  801f67:	00 
  801f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6b:	89 04 24             	mov    %eax,(%esp)
  801f6e:	e8 e8 e8 ff ff       	call   80085b <strcpy>
	return 0;
}
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
  801f78:	c9                   	leave  
  801f79:	c3                   	ret    

00801f7a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	57                   	push   %edi
  801f7e:	56                   	push   %esi
  801f7f:	53                   	push   %ebx
  801f80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f86:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f91:	eb 30                	jmp    801fc3 <devcons_write+0x49>
		m = n - tot;
  801f93:	8b 75 10             	mov    0x10(%ebp),%esi
  801f96:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f98:	83 fe 7f             	cmp    $0x7f,%esi
  801f9b:	76 05                	jbe    801fa2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f9d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fa2:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fa6:	03 45 0c             	add    0xc(%ebp),%eax
  801fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fad:	89 3c 24             	mov    %edi,(%esp)
  801fb0:	e8 1f ea ff ff       	call   8009d4 <memmove>
		sys_cputs(buf, m);
  801fb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fb9:	89 3c 24             	mov    %edi,(%esp)
  801fbc:	e8 bf eb ff ff       	call   800b80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc1:	01 f3                	add    %esi,%ebx
  801fc3:	89 d8                	mov    %ebx,%eax
  801fc5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fc8:	72 c9                	jb     801f93 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fca:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fdb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fdf:	75 07                	jne    801fe8 <devcons_read+0x13>
  801fe1:	eb 25                	jmp    802008 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fe3:	e8 46 ec ff ff       	call   800c2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fe8:	e8 b1 eb ff ff       	call   800b9e <sys_cgetc>
  801fed:	85 c0                	test   %eax,%eax
  801fef:	74 f2                	je     801fe3 <devcons_read+0xe>
  801ff1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	78 1d                	js     802014 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ff7:	83 f8 04             	cmp    $0x4,%eax
  801ffa:	74 13                	je     80200f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fff:	88 10                	mov    %dl,(%eax)
	return 1;
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	eb 0c                	jmp    802014 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802008:	b8 00 00 00 00       	mov    $0x0,%eax
  80200d:	eb 05                	jmp    802014 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80201c:	8b 45 08             	mov    0x8(%ebp),%eax
  80201f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802022:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802029:	00 
  80202a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80202d:	89 04 24             	mov    %eax,(%esp)
  802030:	e8 4b eb ff ff       	call   800b80 <sys_cputs>
}
  802035:	c9                   	leave  
  802036:	c3                   	ret    

00802037 <getchar>:

int
getchar(void)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80203d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802044:	00 
  802045:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802053:	e8 3a f6 ff ff       	call   801692 <read>
	if (r < 0)
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 0f                	js     80206b <getchar+0x34>
		return r;
	if (r < 1)
  80205c:	85 c0                	test   %eax,%eax
  80205e:	7e 06                	jle    802066 <getchar+0x2f>
		return -E_EOF;
	return c;
  802060:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802064:	eb 05                	jmp    80206b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802066:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    

0080206d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802076:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207a:	8b 45 08             	mov    0x8(%ebp),%eax
  80207d:	89 04 24             	mov    %eax,(%esp)
  802080:	e8 71 f3 ff ff       	call   8013f6 <fd_lookup>
  802085:	85 c0                	test   %eax,%eax
  802087:	78 11                	js     80209a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802092:	39 10                	cmp    %edx,(%eax)
  802094:	0f 94 c0             	sete   %al
  802097:	0f b6 c0             	movzbl %al,%eax
}
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <opencons>:

int
opencons(void)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 f6 f2 ff ff       	call   8013a3 <fd_alloc>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	78 3c                	js     8020ed <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020b8:	00 
  8020b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c7:	e8 81 eb ff ff       	call   800c4d <sys_page_alloc>
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	78 1d                	js     8020ed <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020d0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020de:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 8b f2 ff ff       	call   801378 <fd2num>
}
  8020ed:	c9                   	leave  
  8020ee:	c3                   	ret    
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
  8020ff:	e8 0b eb ff ff       	call   800c0f <sys_getenvid>
  802104:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  80210b:	00 
  80210c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802113:	ee 
  802114:	89 04 24             	mov    %eax,(%esp)
  802117:	e8 31 eb ff ff       	call   800c4d <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  80211c:	e8 ee ea ff ff       	call   800c0f <sys_getenvid>
  802121:	c7 44 24 04 3c 21 80 	movl   $0x80213c,0x4(%esp)
  802128:	00 
  802129:	89 04 24             	mov    %eax,(%esp)
  80212c:	e8 bc ec ff ff       	call   800ded <sys_env_set_pgfault_upcall>

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
