
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 eb 01 00 00       	call   80021c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800044:	00 
  800045:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  80004c:	e8 a4 1a 00 00       	call   801af5 <open>
  800051:	89 c3                	mov    %eax,%ebx
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("open motd: %e", fd);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 45 25 80 	movl   $0x802545,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 53 25 80 00 	movl   $0x802553,(%esp)
  800072:	e8 15 02 00 00       	call   80028c <_panic>
	seek(fd, 0);
  800077:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007e:	00 
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 2d 17 00 00       	call   8017b4 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800087:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 20 42 80 	movl   $0x804220,0x4(%esp)
  800096:	00 
  800097:	89 1c 24             	mov    %ebx,(%esp)
  80009a:	e8 3f 16 00 00       	call   8016de <readn>
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	7f 20                	jg     8000c5 <umain+0x91>
		panic("readn: %e", n);
  8000a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a9:	c7 44 24 08 68 25 80 	movl   $0x802568,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b8:	00 
  8000b9:	c7 04 24 53 25 80 00 	movl   $0x802553,(%esp)
  8000c0:	e8 c7 01 00 00       	call   80028c <_panic>

	if ((r = fork()) < 0)
  8000c5:	e8 e9 0f 00 00       	call   8010b3 <fork>
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	79 20                	jns    8000f0 <umain+0xbc>
		panic("fork: %e", r);
  8000d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d4:	c7 44 24 08 72 25 80 	movl   $0x802572,0x8(%esp)
  8000db:	00 
  8000dc:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e3:	00 
  8000e4:	c7 04 24 53 25 80 00 	movl   $0x802553,(%esp)
  8000eb:	e8 9c 01 00 00       	call   80028c <_panic>
	if (r == 0) {
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	0f 85 bd 00 00 00    	jne    8001b5 <umain+0x181>
		seek(fd, 0);
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	e8 ac 16 00 00       	call   8017b4 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800108:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  80010f:	e8 70 02 00 00       	call   800384 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800114:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011b:	00 
  80011c:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800123:	00 
  800124:	89 1c 24             	mov    %ebx,(%esp)
  800127:	e8 b2 15 00 00       	call   8016de <readn>
  80012c:	39 f8                	cmp    %edi,%eax
  80012e:	74 24                	je     800154 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  800130:	89 44 24 10          	mov    %eax,0x10(%esp)
  800134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800138:	c7 44 24 08 f4 25 80 	movl   $0x8025f4,0x8(%esp)
  80013f:	00 
  800140:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800147:	00 
  800148:	c7 04 24 53 25 80 00 	movl   $0x802553,(%esp)
  80014f:	e8 38 01 00 00       	call   80028c <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800154:	89 44 24 08          	mov    %eax,0x8(%esp)
  800158:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80015f:	00 
  800160:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  800167:	e8 c7 09 00 00       	call   800b33 <memcmp>
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 1c                	je     80018c <umain+0x158>
			panic("read in parent got different bytes from read in child");
  800170:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  800177:	00 
  800178:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017f:	00 
  800180:	c7 04 24 53 25 80 00 	movl   $0x802553,(%esp)
  800187:	e8 00 01 00 00       	call   80028c <_panic>
		cprintf("read in child succeeded\n");
  80018c:	c7 04 24 7b 25 80 00 	movl   $0x80257b,(%esp)
  800193:	e8 ec 01 00 00       	call   800384 <cprintf>
		seek(fd, 0);
  800198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019f:	00 
  8001a0:	89 1c 24             	mov    %ebx,(%esp)
  8001a3:	e8 0c 16 00 00       	call   8017b4 <seek>
		close(fd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 3a 13 00 00       	call   8014ea <close>
		exit();
  8001b0:	e8 bb 00 00 00       	call   800270 <exit>
	}
	wait(r);
  8001b5:	89 34 24             	mov    %esi,(%esp)
  8001b8:	e8 4f 1d 00 00       	call   801f0c <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  8001cc:	00 
  8001cd:	89 1c 24             	mov    %ebx,(%esp)
  8001d0:	e8 09 15 00 00       	call   8016de <readn>
  8001d5:	39 f8                	cmp    %edi,%eax
  8001d7:	74 24                	je     8001fd <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e1:	c7 44 24 08 58 26 80 	movl   $0x802658,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 53 25 80 00 	movl   $0x802553,(%esp)
  8001f8:	e8 8f 00 00 00       	call   80028c <_panic>
	cprintf("read in parent succeeded\n");
  8001fd:	c7 04 24 94 25 80 00 	movl   $0x802594,(%esp)
  800204:	e8 7b 01 00 00       	call   800384 <cprintf>
	close(fd);
  800209:	89 1c 24             	mov    %ebx,(%esp)
  80020c:	e8 d9 12 00 00       	call   8014ea <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800211:	cc                   	int3   

	breakpoint();
}
  800212:	83 c4 2c             	add    $0x2c,%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
	...

0080021c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 10             	sub    $0x10,%esp
  800224:	8b 75 08             	mov    0x8(%ebp),%esi
  800227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  80022a:	e8 b4 0a 00 00       	call   800ce3 <sys_getenvid>
  80022f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800234:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80023b:	c1 e0 07             	shl    $0x7,%eax
  80023e:	29 d0                	sub    %edx,%eax
  800240:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800245:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80024a:	85 f6                	test   %esi,%esi
  80024c:	7e 07                	jle    800255 <libmain+0x39>
		binaryname = argv[0];
  80024e:	8b 03                	mov    (%ebx),%eax
  800250:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800255:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	e8 d3 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800261:	e8 0a 00 00 00       	call   800270 <exit>
}
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800276:	e8 a0 12 00 00       	call   80151b <close_all>
	sys_env_destroy(0);
  80027b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800282:	e8 0a 0a 00 00       	call   800c91 <sys_env_destroy>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    
  800289:	00 00                	add    %al,(%eax)
	...

0080028c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800294:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800297:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80029d:	e8 41 0a 00 00       	call   800ce3 <sys_getenvid>
  8002a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	c7 04 24 88 26 80 00 	movl   $0x802688,(%esp)
  8002bf:	e8 c0 00 00 00       	call   800384 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 50 00 00 00       	call   800323 <vcprintf>
	cprintf("\n");
  8002d3:	c7 04 24 92 25 80 00 	movl   $0x802592,(%esp)
  8002da:	e8 a5 00 00 00       	call   800384 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002df:	cc                   	int3   
  8002e0:	eb fd                	jmp    8002df <_panic+0x53>
	...

008002e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 14             	sub    $0x14,%esp
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ee:	8b 03                	mov    (%ebx),%eax
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002f7:	40                   	inc    %eax
  8002f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ff:	75 19                	jne    80031a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800301:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800308:	00 
  800309:	8d 43 08             	lea    0x8(%ebx),%eax
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	e8 40 09 00 00       	call   800c54 <sys_cputs>
		b->idx = 0;
  800314:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80031a:	ff 43 04             	incl   0x4(%ebx)
}
  80031d:	83 c4 14             	add    $0x14,%esp
  800320:	5b                   	pop    %ebx
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80032c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800333:	00 00 00 
	b.cnt = 0;
  800336:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
  800343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800354:	89 44 24 04          	mov    %eax,0x4(%esp)
  800358:	c7 04 24 e4 02 80 00 	movl   $0x8002e4,(%esp)
  80035f:	e8 82 01 00 00       	call   8004e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800364:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80036a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	e8 d8 08 00 00       	call   800c54 <sys_cputs>

	return b.cnt;
}
  80037c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	e8 87 ff ff ff       	call   800323 <vcprintf>
	va_end(ap);

	return cnt;
}
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    
	...

008003a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 3c             	sub    $0x3c,%esp
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	89 d7                	mov    %edx,%edi
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	75 08                	jne    8003cc <printnum+0x2c>
  8003c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ca:	77 57                	ja     800423 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003d0:	4b                   	dec    %ebx
  8003d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003dc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003eb:	00 
  8003ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f9:	e8 ea 1e 00 00       	call   8022e8 <__udivdi3>
  8003fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800402:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	89 54 24 04          	mov    %edx,0x4(%esp)
  80040d:	89 fa                	mov    %edi,%edx
  80040f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800412:	e8 89 ff ff ff       	call   8003a0 <printnum>
  800417:	eb 0f                	jmp    800428 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800419:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80041d:	89 34 24             	mov    %esi,(%esp)
  800420:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800423:	4b                   	dec    %ebx
  800424:	85 db                	test   %ebx,%ebx
  800426:	7f f1                	jg     800419 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800428:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800430:	8b 45 10             	mov    0x10(%ebp),%eax
  800433:	89 44 24 08          	mov    %eax,0x8(%esp)
  800437:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80043e:	00 
  80043f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044c:	e8 b7 1f 00 00       	call   802408 <__umoddi3>
  800451:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800455:	0f be 80 ab 26 80 00 	movsbl 0x8026ab(%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800462:	83 c4 3c             	add    $0x3c,%esp
  800465:	5b                   	pop    %ebx
  800466:	5e                   	pop    %esi
  800467:	5f                   	pop    %edi
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    

0080046a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046d:	83 fa 01             	cmp    $0x1,%edx
  800470:	7e 0e                	jle    800480 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 08             	lea    0x8(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	8b 52 04             	mov    0x4(%edx),%edx
  80047e:	eb 22                	jmp    8004a2 <getuint+0x38>
	else if (lflag)
  800480:	85 d2                	test   %edx,%edx
  800482:	74 10                	je     800494 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 04             	lea    0x4(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	ba 00 00 00 00       	mov    $0x0,%edx
  800492:	eb 0e                	jmp    8004a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800494:	8b 10                	mov    (%eax),%edx
  800496:	8d 4a 04             	lea    0x4(%edx),%ecx
  800499:	89 08                	mov    %ecx,(%eax)
  80049b:	8b 02                	mov    (%edx),%eax
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a2:	5d                   	pop    %ebp
  8004a3:	c3                   	ret    

008004a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004aa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004ad:	8b 10                	mov    (%eax),%edx
  8004af:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b2:	73 08                	jae    8004bc <sprintputch+0x18>
		*b->buf++ = ch;
  8004b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b7:	88 0a                	mov    %cl,(%edx)
  8004b9:	42                   	inc    %edx
  8004ba:	89 10                	mov    %edx,(%eax)
}
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 02 00 00 00       	call   8004e6 <vprintfmt>
	va_end(ap);
}
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    

008004e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  8004ec:	83 ec 4c             	sub    $0x4c,%esp
  8004ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f5:	eb 12                	jmp    800509 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	0f 84 6b 03 00 00    	je     80086a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800509:	0f b6 06             	movzbl (%esi),%eax
  80050c:	46                   	inc    %esi
  80050d:	83 f8 25             	cmp    $0x25,%eax
  800510:	75 e5                	jne    8004f7 <vprintfmt+0x11>
  800512:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800516:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80051d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800522:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800529:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052e:	eb 26                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800533:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800537:	eb 1d                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80053c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800540:	eb 14                	jmp    800556 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800545:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054c:	eb 08                	jmp    800556 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80054e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800551:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	0f b6 06             	movzbl (%esi),%eax
  800559:	8d 56 01             	lea    0x1(%esi),%edx
  80055c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80055f:	8a 16                	mov    (%esi),%dl
  800561:	83 ea 23             	sub    $0x23,%edx
  800564:	80 fa 55             	cmp    $0x55,%dl
  800567:	0f 87 e1 02 00 00    	ja     80084e <vprintfmt+0x368>
  80056d:	0f b6 d2             	movzbl %dl,%edx
  800570:	ff 24 95 e0 27 80 00 	jmp    *0x8027e0(,%edx,4)
  800577:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80057a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800582:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800586:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800589:	8d 50 d0             	lea    -0x30(%eax),%edx
  80058c:	83 fa 09             	cmp    $0x9,%edx
  80058f:	77 2a                	ja     8005bb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800591:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800592:	eb eb                	jmp    80057f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a2:	eb 17                	jmp    8005bb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a8:	78 98                	js     800542 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ad:	eb a7                	jmp    800556 <vprintfmt+0x70>
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005b9:	eb 9b                	jmp    800556 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bf:	79 95                	jns    800556 <vprintfmt+0x70>
  8005c1:	eb 8b                	jmp    80054e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005c7:	eb 8d                	jmp    800556 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e1:	e9 23 ff ff ff       	jmp    800509 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	85 c0                	test   %eax,%eax
  8005f3:	79 02                	jns    8005f7 <vprintfmt+0x111>
  8005f5:	f7 d8                	neg    %eax
  8005f7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f9:	83 f8 0f             	cmp    $0xf,%eax
  8005fc:	7f 0b                	jg     800609 <vprintfmt+0x123>
  8005fe:	8b 04 85 40 29 80 00 	mov    0x802940(,%eax,4),%eax
  800605:	85 c0                	test   %eax,%eax
  800607:	75 23                	jne    80062c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800609:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060d:	c7 44 24 08 c3 26 80 	movl   $0x8026c3,0x8(%esp)
  800614:	00 
  800615:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800619:	8b 45 08             	mov    0x8(%ebp),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	e8 9a fe ff ff       	call   8004be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800627:	e9 dd fe ff ff       	jmp    800509 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80062c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800630:	c7 44 24 08 ae 2b 80 	movl   $0x802bae,0x8(%esp)
  800637:	00 
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	8b 55 08             	mov    0x8(%ebp),%edx
  80063f:	89 14 24             	mov    %edx,(%esp)
  800642:	e8 77 fe ff ff       	call   8004be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800647:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064a:	e9 ba fe ff ff       	jmp    800509 <vprintfmt+0x23>
  80064f:	89 f9                	mov    %edi,%ecx
  800651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800654:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 30                	mov    (%eax),%esi
  800662:	85 f6                	test   %esi,%esi
  800664:	75 05                	jne    80066b <vprintfmt+0x185>
				p = "(null)";
  800666:	be bc 26 80 00       	mov    $0x8026bc,%esi
			if (width > 0 && padc != '-')
  80066b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80066f:	0f 8e 84 00 00 00    	jle    8006f9 <vprintfmt+0x213>
  800675:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800679:	74 7e                	je     8006f9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80067f:	89 34 24             	mov    %esi,(%esp)
  800682:	e8 8b 02 00 00       	call   800912 <strnlen>
  800687:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80068a:	29 c2                	sub    %eax,%edx
  80068c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80068f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800693:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800696:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800699:	89 de                	mov    %ebx,%esi
  80069b:	89 d3                	mov    %edx,%ebx
  80069d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	eb 0b                	jmp    8006ac <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a5:	89 3c 24             	mov    %edi,(%esp)
  8006a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	4b                   	dec    %ebx
  8006ac:	85 db                	test   %ebx,%ebx
  8006ae:	7f f1                	jg     8006a1 <vprintfmt+0x1bb>
  8006b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006b3:	89 f3                	mov    %esi,%ebx
  8006b5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	79 05                	jns    8006c4 <vprintfmt+0x1de>
  8006bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c7:	29 c2                	sub    %eax,%edx
  8006c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006cc:	eb 2b                	jmp    8006f9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d2:	74 18                	je     8006ec <vprintfmt+0x206>
  8006d4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006d7:	83 fa 5e             	cmp    $0x5e,%edx
  8006da:	76 10                	jbe    8006ec <vprintfmt+0x206>
					putch('?', putdat);
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	eb 0a                	jmp    8006f6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f0:	89 04 24             	mov    %eax,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f6:	ff 4d e4             	decl   -0x1c(%ebp)
  8006f9:	0f be 06             	movsbl (%esi),%eax
  8006fc:	46                   	inc    %esi
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	74 21                	je     800722 <vprintfmt+0x23c>
  800701:	85 ff                	test   %edi,%edi
  800703:	78 c9                	js     8006ce <vprintfmt+0x1e8>
  800705:	4f                   	dec    %edi
  800706:	79 c6                	jns    8006ce <vprintfmt+0x1e8>
  800708:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070b:	89 de                	mov    %ebx,%esi
  80070d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800710:	eb 18                	jmp    80072a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800712:	89 74 24 04          	mov    %esi,0x4(%esp)
  800716:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80071d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071f:	4b                   	dec    %ebx
  800720:	eb 08                	jmp    80072a <vprintfmt+0x244>
  800722:	8b 7d 08             	mov    0x8(%ebp),%edi
  800725:	89 de                	mov    %ebx,%esi
  800727:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80072a:	85 db                	test   %ebx,%ebx
  80072c:	7f e4                	jg     800712 <vprintfmt+0x22c>
  80072e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800731:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800736:	e9 ce fd ff ff       	jmp    800509 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073b:	83 f9 01             	cmp    $0x1,%ecx
  80073e:	7e 10                	jle    800750 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 50 08             	lea    0x8(%eax),%edx
  800746:	89 55 14             	mov    %edx,0x14(%ebp)
  800749:	8b 30                	mov    (%eax),%esi
  80074b:	8b 78 04             	mov    0x4(%eax),%edi
  80074e:	eb 26                	jmp    800776 <vprintfmt+0x290>
	else if (lflag)
  800750:	85 c9                	test   %ecx,%ecx
  800752:	74 12                	je     800766 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 04             	lea    0x4(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 30                	mov    (%eax),%esi
  80075f:	89 f7                	mov    %esi,%edi
  800761:	c1 ff 1f             	sar    $0x1f,%edi
  800764:	eb 10                	jmp    800776 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8d 50 04             	lea    0x4(%eax),%edx
  80076c:	89 55 14             	mov    %edx,0x14(%ebp)
  80076f:	8b 30                	mov    (%eax),%esi
  800771:	89 f7                	mov    %esi,%edi
  800773:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800776:	85 ff                	test   %edi,%edi
  800778:	78 0a                	js     800784 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 8c 00 00 00       	jmp    800810 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800784:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800788:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80078f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800792:	f7 de                	neg    %esi
  800794:	83 d7 00             	adc    $0x0,%edi
  800797:	f7 df                	neg    %edi
			}
			base = 10;
  800799:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079e:	eb 70                	jmp    800810 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a0:	89 ca                	mov    %ecx,%edx
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a5:	e8 c0 fc ff ff       	call   80046a <getuint>
  8007aa:	89 c6                	mov    %eax,%esi
  8007ac:	89 d7                	mov    %edx,%edi
			base = 10;
  8007ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007b3:	eb 5b                	jmp    800810 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007b5:	89 ca                	mov    %ecx,%edx
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ba:	e8 ab fc ff ff       	call   80046a <getuint>
  8007bf:	89 c6                	mov    %eax,%esi
  8007c1:	89 d7                	mov    %edx,%edi
			base = 8;
  8007c3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007c8:	eb 46                	jmp    800810 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ef:	8b 30                	mov    (%eax),%esi
  8007f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007fb:	eb 13                	jmp    800810 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007fd:	89 ca                	mov    %ecx,%edx
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800802:	e8 63 fc ff ff       	call   80046a <getuint>
  800807:	89 c6                	mov    %eax,%esi
  800809:	89 d7                	mov    %edx,%edi
			base = 16;
  80080b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800810:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800814:	89 54 24 10          	mov    %edx,0x10(%esp)
  800818:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80081b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80081f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800823:	89 34 24             	mov    %esi,(%esp)
  800826:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80082a:	89 da                	mov    %ebx,%edx
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	e8 6c fb ff ff       	call   8003a0 <printnum>
			break;
  800834:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800837:	e9 cd fc ff ff       	jmp    800509 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800840:	89 04 24             	mov    %eax,(%esp)
  800843:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800849:	e9 bb fc ff ff       	jmp    800509 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800852:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800859:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085c:	eb 01                	jmp    80085f <vprintfmt+0x379>
  80085e:	4e                   	dec    %esi
  80085f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800863:	75 f9                	jne    80085e <vprintfmt+0x378>
  800865:	e9 9f fc ff ff       	jmp    800509 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80086a:	83 c4 4c             	add    $0x4c,%esp
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5f                   	pop    %edi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 28             	sub    $0x28,%esp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800881:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800885:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800888:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088f:	85 c0                	test   %eax,%eax
  800891:	74 30                	je     8008c3 <vsnprintf+0x51>
  800893:	85 d2                	test   %edx,%edx
  800895:	7e 33                	jle    8008ca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089e:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	c7 04 24 a4 04 80 00 	movl   $0x8004a4,(%esp)
  8008b3:	e8 2e fc ff ff       	call   8004e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c1:	eb 0c                	jmp    8008cf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c8:	eb 05                	jmp    8008cf <vsnprintf+0x5d>
  8008ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008de:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	e8 7b ff ff ff       	call   800872 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    
  8008f9:	00 00                	add    %al,(%eax)
	...

008008fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
  800907:	eb 01                	jmp    80090a <strlen+0xe>
		n++;
  800909:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80090a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80090e:	75 f9                	jne    800909 <strlen+0xd>
		n++;
	return n;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
  800920:	eb 01                	jmp    800923 <strnlen+0x11>
		n++;
  800922:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800923:	39 d0                	cmp    %edx,%eax
  800925:	74 06                	je     80092d <strnlen+0x1b>
  800927:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80092b:	75 f5                	jne    800922 <strnlen+0x10>
		n++;
	return n;
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800939:	ba 00 00 00 00       	mov    $0x0,%edx
  80093e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800941:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800944:	42                   	inc    %edx
  800945:	84 c9                	test   %cl,%cl
  800947:	75 f5                	jne    80093e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800949:	5b                   	pop    %ebx
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	53                   	push   %ebx
  800950:	83 ec 08             	sub    $0x8,%esp
  800953:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800956:	89 1c 24             	mov    %ebx,(%esp)
  800959:	e8 9e ff ff ff       	call   8008fc <strlen>
	strcpy(dst + len, src);
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800961:	89 54 24 04          	mov    %edx,0x4(%esp)
  800965:	01 d8                	add    %ebx,%eax
  800967:	89 04 24             	mov    %eax,(%esp)
  80096a:	e8 c0 ff ff ff       	call   80092f <strcpy>
	return dst;
}
  80096f:	89 d8                	mov    %ebx,%eax
  800971:	83 c4 08             	add    $0x8,%esp
  800974:	5b                   	pop    %ebx
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800982:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800985:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098a:	eb 0c                	jmp    800998 <strncpy+0x21>
		*dst++ = *src;
  80098c:	8a 1a                	mov    (%edx),%bl
  80098e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800991:	80 3a 01             	cmpb   $0x1,(%edx)
  800994:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800997:	41                   	inc    %ecx
  800998:	39 f1                	cmp    %esi,%ecx
  80099a:	75 f0                	jne    80098c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ae:	85 d2                	test   %edx,%edx
  8009b0:	75 0a                	jne    8009bc <strlcpy+0x1c>
  8009b2:	89 f0                	mov    %esi,%eax
  8009b4:	eb 1a                	jmp    8009d0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b6:	88 18                	mov    %bl,(%eax)
  8009b8:	40                   	inc    %eax
  8009b9:	41                   	inc    %ecx
  8009ba:	eb 02                	jmp    8009be <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009be:	4a                   	dec    %edx
  8009bf:	74 0a                	je     8009cb <strlcpy+0x2b>
  8009c1:	8a 19                	mov    (%ecx),%bl
  8009c3:	84 db                	test   %bl,%bl
  8009c5:	75 ef                	jne    8009b6 <strlcpy+0x16>
  8009c7:	89 c2                	mov    %eax,%edx
  8009c9:	eb 02                	jmp    8009cd <strlcpy+0x2d>
  8009cb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009cd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009d0:	29 f0                	sub    %esi,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009df:	eb 02                	jmp    8009e3 <strcmp+0xd>
		p++, q++;
  8009e1:	41                   	inc    %ecx
  8009e2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e3:	8a 01                	mov    (%ecx),%al
  8009e5:	84 c0                	test   %al,%al
  8009e7:	74 04                	je     8009ed <strcmp+0x17>
  8009e9:	3a 02                	cmp    (%edx),%al
  8009eb:	74 f4                	je     8009e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ed:	0f b6 c0             	movzbl %al,%eax
  8009f0:	0f b6 12             	movzbl (%edx),%edx
  8009f3:	29 d0                	sub    %edx,%eax
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a01:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a04:	eb 03                	jmp    800a09 <strncmp+0x12>
		n--, p++, q++;
  800a06:	4a                   	dec    %edx
  800a07:	40                   	inc    %eax
  800a08:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a09:	85 d2                	test   %edx,%edx
  800a0b:	74 14                	je     800a21 <strncmp+0x2a>
  800a0d:	8a 18                	mov    (%eax),%bl
  800a0f:	84 db                	test   %bl,%bl
  800a11:	74 04                	je     800a17 <strncmp+0x20>
  800a13:	3a 19                	cmp    (%ecx),%bl
  800a15:	74 ef                	je     800a06 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a17:	0f b6 00             	movzbl (%eax),%eax
  800a1a:	0f b6 11             	movzbl (%ecx),%edx
  800a1d:	29 d0                	sub    %edx,%eax
  800a1f:	eb 05                	jmp    800a26 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a32:	eb 05                	jmp    800a39 <strchr+0x10>
		if (*s == c)
  800a34:	38 ca                	cmp    %cl,%dl
  800a36:	74 0c                	je     800a44 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a38:	40                   	inc    %eax
  800a39:	8a 10                	mov    (%eax),%dl
  800a3b:	84 d2                	test   %dl,%dl
  800a3d:	75 f5                	jne    800a34 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a4f:	eb 05                	jmp    800a56 <strfind+0x10>
		if (*s == c)
  800a51:	38 ca                	cmp    %cl,%dl
  800a53:	74 07                	je     800a5c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a55:	40                   	inc    %eax
  800a56:	8a 10                	mov    (%eax),%dl
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	75 f5                	jne    800a51 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6d:	85 c9                	test   %ecx,%ecx
  800a6f:	74 30                	je     800aa1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a77:	75 25                	jne    800a9e <memset+0x40>
  800a79:	f6 c1 03             	test   $0x3,%cl
  800a7c:	75 20                	jne    800a9e <memset+0x40>
		c &= 0xFF;
  800a7e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a81:	89 d3                	mov    %edx,%ebx
  800a83:	c1 e3 08             	shl    $0x8,%ebx
  800a86:	89 d6                	mov    %edx,%esi
  800a88:	c1 e6 18             	shl    $0x18,%esi
  800a8b:	89 d0                	mov    %edx,%eax
  800a8d:	c1 e0 10             	shl    $0x10,%eax
  800a90:	09 f0                	or     %esi,%eax
  800a92:	09 d0                	or     %edx,%eax
  800a94:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a96:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a99:	fc                   	cld    
  800a9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9c:	eb 03                	jmp    800aa1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9e:	fc                   	cld    
  800a9f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa1:	89 f8                	mov    %edi,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 34                	jae    800aee <memmove+0x46>
  800aba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abd:	39 d0                	cmp    %edx,%eax
  800abf:	73 2d                	jae    800aee <memmove+0x46>
		s += n;
		d += n;
  800ac1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f6 c2 03             	test   $0x3,%dl
  800ac7:	75 1b                	jne    800ae4 <memmove+0x3c>
  800ac9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acf:	75 13                	jne    800ae4 <memmove+0x3c>
  800ad1:	f6 c1 03             	test   $0x3,%cl
  800ad4:	75 0e                	jne    800ae4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad6:	83 ef 04             	sub    $0x4,%edi
  800ad9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800adc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800adf:	fd                   	std    
  800ae0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae2:	eb 07                	jmp    800aeb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae4:	4f                   	dec    %edi
  800ae5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae8:	fd                   	std    
  800ae9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aeb:	fc                   	cld    
  800aec:	eb 20                	jmp    800b0e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af4:	75 13                	jne    800b09 <memmove+0x61>
  800af6:	a8 03                	test   $0x3,%al
  800af8:	75 0f                	jne    800b09 <memmove+0x61>
  800afa:	f6 c1 03             	test   $0x3,%cl
  800afd:	75 0a                	jne    800b09 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b02:	89 c7                	mov    %eax,%edi
  800b04:	fc                   	cld    
  800b05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b07:	eb 05                	jmp    800b0e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b09:	89 c7                	mov    %eax,%edi
  800b0b:	fc                   	cld    
  800b0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b18:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	89 04 24             	mov    %eax,(%esp)
  800b2c:	e8 77 ff ff ff       	call   800aa8 <memmove>
}
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	eb 16                	jmp    800b5f <memcmp+0x2c>
		if (*s1 != *s2)
  800b49:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b4c:	42                   	inc    %edx
  800b4d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b51:	38 c8                	cmp    %cl,%al
  800b53:	74 0a                	je     800b5f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 c9             	movzbl %cl,%ecx
  800b5b:	29 c8                	sub    %ecx,%eax
  800b5d:	eb 09                	jmp    800b68 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5f:	39 da                	cmp    %ebx,%edx
  800b61:	75 e6                	jne    800b49 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7b:	eb 05                	jmp    800b82 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7d:	38 08                	cmp    %cl,(%eax)
  800b7f:	74 05                	je     800b86 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b81:	40                   	inc    %eax
  800b82:	39 d0                	cmp    %edx,%eax
  800b84:	72 f7                	jb     800b7d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b94:	eb 01                	jmp    800b97 <strtol+0xf>
		s++;
  800b96:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b97:	8a 02                	mov    (%edx),%al
  800b99:	3c 20                	cmp    $0x20,%al
  800b9b:	74 f9                	je     800b96 <strtol+0xe>
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	74 f5                	je     800b96 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba1:	3c 2b                	cmp    $0x2b,%al
  800ba3:	75 08                	jne    800bad <strtol+0x25>
		s++;
  800ba5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bab:	eb 13                	jmp    800bc0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bad:	3c 2d                	cmp    $0x2d,%al
  800baf:	75 0a                	jne    800bbb <strtol+0x33>
		s++, neg = 1;
  800bb1:	8d 52 01             	lea    0x1(%edx),%edx
  800bb4:	bf 01 00 00 00       	mov    $0x1,%edi
  800bb9:	eb 05                	jmp    800bc0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bbb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc0:	85 db                	test   %ebx,%ebx
  800bc2:	74 05                	je     800bc9 <strtol+0x41>
  800bc4:	83 fb 10             	cmp    $0x10,%ebx
  800bc7:	75 28                	jne    800bf1 <strtol+0x69>
  800bc9:	8a 02                	mov    (%edx),%al
  800bcb:	3c 30                	cmp    $0x30,%al
  800bcd:	75 10                	jne    800bdf <strtol+0x57>
  800bcf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd3:	75 0a                	jne    800bdf <strtol+0x57>
		s += 2, base = 16;
  800bd5:	83 c2 02             	add    $0x2,%edx
  800bd8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bdd:	eb 12                	jmp    800bf1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bdf:	85 db                	test   %ebx,%ebx
  800be1:	75 0e                	jne    800bf1 <strtol+0x69>
  800be3:	3c 30                	cmp    $0x30,%al
  800be5:	75 05                	jne    800bec <strtol+0x64>
		s++, base = 8;
  800be7:	42                   	inc    %edx
  800be8:	b3 08                	mov    $0x8,%bl
  800bea:	eb 05                	jmp    800bf1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf8:	8a 0a                	mov    (%edx),%cl
  800bfa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bfd:	80 fb 09             	cmp    $0x9,%bl
  800c00:	77 08                	ja     800c0a <strtol+0x82>
			dig = *s - '0';
  800c02:	0f be c9             	movsbl %cl,%ecx
  800c05:	83 e9 30             	sub    $0x30,%ecx
  800c08:	eb 1e                	jmp    800c28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c0d:	80 fb 19             	cmp    $0x19,%bl
  800c10:	77 08                	ja     800c1a <strtol+0x92>
			dig = *s - 'a' + 10;
  800c12:	0f be c9             	movsbl %cl,%ecx
  800c15:	83 e9 57             	sub    $0x57,%ecx
  800c18:	eb 0e                	jmp    800c28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c1d:	80 fb 19             	cmp    $0x19,%bl
  800c20:	77 12                	ja     800c34 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c22:	0f be c9             	movsbl %cl,%ecx
  800c25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c28:	39 f1                	cmp    %esi,%ecx
  800c2a:	7d 0c                	jge    800c38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c2c:	42                   	inc    %edx
  800c2d:	0f af c6             	imul   %esi,%eax
  800c30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c32:	eb c4                	jmp    800bf8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c34:	89 c1                	mov    %eax,%ecx
  800c36:	eb 02                	jmp    800c3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3e:	74 05                	je     800c45 <strtol+0xbd>
		*endptr = (char *) s;
  800c40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c45:	85 ff                	test   %edi,%edi
  800c47:	74 04                	je     800c4d <strtol+0xc5>
  800c49:	89 c8                	mov    %ecx,%eax
  800c4b:	f7 d8                	neg    %eax
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    
	...

00800c54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 c3                	mov    %eax,%ebx
  800c67:	89 c7                	mov    %eax,%edi
  800c69:	89 c6                	mov    %eax,%esi
  800c6b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c82:	89 d1                	mov    %edx,%ecx
  800c84:	89 d3                	mov    %edx,%ebx
  800c86:	89 d7                	mov    %edx,%edi
  800c88:	89 d6                	mov    %edx,%esi
  800c8a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 cb                	mov    %ecx,%ebx
  800ca9:	89 cf                	mov    %ecx,%edi
  800cab:	89 ce                	mov    %ecx,%esi
  800cad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 28                	jle    800cdb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800cc6:	00 
  800cc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cce:	00 
  800ccf:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800cd6:	e8 b1 f5 ff ff       	call   80028c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdb:	83 c4 2c             	add    $0x2c,%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cee:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf3:	89 d1                	mov    %edx,%ecx
  800cf5:	89 d3                	mov    %edx,%ebx
  800cf7:	89 d7                	mov    %edx,%edi
  800cf9:	89 d6                	mov    %edx,%esi
  800cfb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_yield>:

void
sys_yield(void)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d12:	89 d1                	mov    %edx,%ecx
  800d14:	89 d3                	mov    %edx,%ebx
  800d16:	89 d7                	mov    %edx,%edi
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	be 00 00 00 00       	mov    $0x0,%esi
  800d2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 f7                	mov    %esi,%edi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 28                	jle    800d6d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d49:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d50:	00 
  800d51:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800d58:	00 
  800d59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d60:	00 
  800d61:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800d68:	e8 1f f5 ff ff       	call   80028c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6d:	83 c4 2c             	add    $0x2c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d83:	8b 75 18             	mov    0x18(%ebp),%esi
  800d86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d94:	85 c0                	test   %eax,%eax
  800d96:	7e 28                	jle    800dc0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800da3:	00 
  800da4:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800dab:	00 
  800dac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db3:	00 
  800db4:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800dbb:	e8 cc f4 ff ff       	call   80028c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc0:	83 c4 2c             	add    $0x2c,%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 28                	jle    800e13 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800def:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800df6:	00 
  800df7:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800e0e:	e8 79 f4 ff ff       	call   80028c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e13:	83 c4 2c             	add    $0x2c,%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e29:	b8 08 00 00 00       	mov    $0x8,%eax
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	89 df                	mov    %ebx,%edi
  800e36:	89 de                	mov    %ebx,%esi
  800e38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	7e 28                	jle    800e66 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e42:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e49:	00 
  800e4a:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800e61:	e8 26 f4 ff ff       	call   80028c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e66:	83 c4 2c             	add    $0x2c,%esp
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	89 df                	mov    %ebx,%edi
  800e89:	89 de                	mov    %ebx,%esi
  800e8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	7e 28                	jle    800eb9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e95:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800eb4:	e8 d3 f3 ff ff       	call   80028c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb9:	83 c4 2c             	add    $0x2c,%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	57                   	push   %edi
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
  800ec7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eda:	89 df                	mov    %ebx,%edi
  800edc:	89 de                	mov    %ebx,%esi
  800ede:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	7e 28                	jle    800f0c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eef:	00 
  800ef0:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800ef7:	00 
  800ef8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eff:	00 
  800f00:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800f07:	e8 80 f3 ff ff       	call   80028c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0c:	83 c4 2c             	add    $0x2c,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1a:	be 00 00 00 00       	mov    $0x0,%esi
  800f1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4d:	89 cb                	mov    %ecx,%ebx
  800f4f:	89 cf                	mov    %ecx,%edi
  800f51:	89 ce                	mov    %ecx,%esi
  800f53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	7e 28                	jle    800f81 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f64:	00 
  800f65:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f74:	00 
  800f75:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800f7c:	e8 0b f3 ff ff       	call   80028c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f81:	83 c4 2c             	add    $0x2c,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    
  800f89:	00 00                	add    %al,(%eax)
	...

00800f8c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 24             	sub    $0x24,%esp
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f96:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800f98:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f9c:	75 2d                	jne    800fcb <pgfault+0x3f>
  800f9e:	89 d8                	mov    %ebx,%eax
  800fa0:	c1 e8 0c             	shr    $0xc,%eax
  800fa3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800faa:	f6 c4 08             	test   $0x8,%ah
  800fad:	75 1c                	jne    800fcb <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800faf:	c7 44 24 08 cc 29 80 	movl   $0x8029cc,0x8(%esp)
  800fb6:	00 
  800fb7:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800fbe:	00 
  800fbf:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  800fc6:	e8 c1 f2 ff ff       	call   80028c <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fcb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fda:	00 
  800fdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe2:	e8 3a fd ff ff       	call   800d21 <sys_page_alloc>
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	79 20                	jns    80100b <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800feb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fef:	c7 44 24 08 3b 2a 80 	movl   $0x802a3b,0x8(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800ffe:	00 
  800fff:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801006:	e8 81 f2 ff ff       	call   80028c <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  80100b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  801011:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801018:	00 
  801019:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80101d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801024:	e8 e9 fa ff ff       	call   800b12 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801029:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801030:	00 
  801031:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801035:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80104c:	e8 24 fd ff ff       	call   800d75 <sys_page_map>
  801051:	85 c0                	test   %eax,%eax
  801053:	79 20                	jns    801075 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  801055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801059:	c7 44 24 08 4e 2a 80 	movl   $0x802a4e,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801070:	e8 17 f2 ff ff       	call   80028c <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801075:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80107c:	00 
  80107d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801084:	e8 3f fd ff ff       	call   800dc8 <sys_page_unmap>
  801089:	85 c0                	test   %eax,%eax
  80108b:	79 20                	jns    8010ad <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  80108d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801091:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  8010a8:	e8 df f1 ff ff       	call   80028c <_panic>
}
  8010ad:	83 c4 24             	add    $0x24,%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  8010bc:	c7 04 24 8c 0f 80 00 	movl   $0x800f8c,(%esp)
  8010c3:	e8 50 10 00 00       	call   802118 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010c8:	ba 07 00 00 00       	mov    $0x7,%edx
  8010cd:	89 d0                	mov    %edx,%eax
  8010cf:	cd 30                	int    $0x30
  8010d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	79 1c                	jns    8010f7 <fork+0x44>
		panic("sys_exofork failed\n");
  8010db:	c7 44 24 08 72 2a 80 	movl   $0x802a72,0x8(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8010ea:	00 
  8010eb:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  8010f2:	e8 95 f1 ff ff       	call   80028c <_panic>
	if(c_envid == 0){
  8010f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010fb:	75 25                	jne    801122 <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010fd:	e8 e1 fb ff ff       	call   800ce3 <sys_getenvid>
  801102:	25 ff 03 00 00       	and    $0x3ff,%eax
  801107:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80110e:	c1 e0 07             	shl    $0x7,%eax
  801111:	29 d0                	sub    %edx,%eax
  801113:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801118:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80111d:	e9 e3 01 00 00       	jmp    801305 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  801122:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  801127:	89 d8                	mov    %ebx,%eax
  801129:	c1 e8 16             	shr    $0x16,%eax
  80112c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801133:	a8 01                	test   $0x1,%al
  801135:	0f 84 0b 01 00 00    	je     801246 <fork+0x193>
  80113b:	89 de                	mov    %ebx,%esi
  80113d:	c1 ee 0c             	shr    $0xc,%esi
  801140:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801147:	a8 05                	test   $0x5,%al
  801149:	0f 84 f7 00 00 00    	je     801246 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  80114f:	89 f7                	mov    %esi,%edi
  801151:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  801154:	e8 8a fb ff ff       	call   800ce3 <sys_getenvid>
  801159:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  80115c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801163:	a8 02                	test   $0x2,%al
  801165:	75 10                	jne    801177 <fork+0xc4>
  801167:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116e:	f6 c4 08             	test   $0x8,%ah
  801171:	0f 84 89 00 00 00    	je     801200 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  801177:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80117e:	00 
  80117f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801183:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801186:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80118e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801191:	89 04 24             	mov    %eax,(%esp)
  801194:	e8 dc fb ff ff       	call   800d75 <sys_page_map>
  801199:	85 c0                	test   %eax,%eax
  80119b:	79 20                	jns    8011bd <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  80119d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a1:	c7 44 24 08 86 2a 80 	movl   $0x802a86,0x8(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  8011b0:	00 
  8011b1:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  8011b8:	e8 cf f0 ff ff       	call   80028c <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  8011bd:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011c4:	00 
  8011c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011d4:	89 04 24             	mov    %eax,(%esp)
  8011d7:	e8 99 fb ff ff       	call   800d75 <sys_page_map>
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	79 66                	jns    801246 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8011e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e4:	c7 44 24 08 86 2a 80 	movl   $0x802a86,0x8(%esp)
  8011eb:	00 
  8011ec:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8011f3:	00 
  8011f4:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  8011fb:	e8 8c f0 ff ff       	call   80028c <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  801200:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801207:	00 
  801208:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80120c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80120f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801213:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801217:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80121a:	89 04 24             	mov    %eax,(%esp)
  80121d:	e8 53 fb ff ff       	call   800d75 <sys_page_map>
  801222:	85 c0                	test   %eax,%eax
  801224:	79 20                	jns    801246 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  801226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122a:	c7 44 24 08 86 2a 80 	movl   $0x802a86,0x8(%esp)
  801231:	00 
  801232:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801239:	00 
  80123a:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801241:	e8 46 f0 ff ff       	call   80028c <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  801246:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80124c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801252:	0f 85 cf fe ff ff    	jne    801127 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801258:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80125f:	00 
  801260:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801267:	ee 
  801268:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 ae fa ff ff       	call   800d21 <sys_page_alloc>
  801273:	85 c0                	test   %eax,%eax
  801275:	79 20                	jns    801297 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  801277:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127b:	c7 44 24 08 98 2a 80 	movl   $0x802a98,0x8(%esp)
  801282:	00 
  801283:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80128a:	00 
  80128b:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801292:	e8 f5 ef ff ff       	call   80028c <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801297:	c7 44 24 04 64 21 80 	movl   $0x802164,0x4(%esp)
  80129e:	00 
  80129f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a2:	89 04 24             	mov    %eax,(%esp)
  8012a5:	e8 17 fc ff ff       	call   800ec1 <sys_env_set_pgfault_upcall>
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	79 20                	jns    8012ce <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8012ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b2:	c7 44 24 08 10 2a 80 	movl   $0x802a10,0x8(%esp)
  8012b9:	00 
  8012ba:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8012c1:	00 
  8012c2:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  8012c9:	e8 be ef ff ff       	call   80028c <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  8012ce:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012d5:	00 
  8012d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d9:	89 04 24             	mov    %eax,(%esp)
  8012dc:	e8 3a fb ff ff       	call   800e1b <sys_env_set_status>
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	79 20                	jns    801305 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  8012e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e9:	c7 44 24 08 ac 2a 80 	movl   $0x802aac,0x8(%esp)
  8012f0:	00 
  8012f1:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8012f8:	00 
  8012f9:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801300:	e8 87 ef ff ff       	call   80028c <_panic>
 
	return c_envid;	
}
  801305:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801308:	83 c4 3c             	add    $0x3c,%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5e                   	pop    %esi
  80130d:	5f                   	pop    %edi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <sfork>:

// Challenge!
int
sfork(void)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801316:	c7 44 24 08 c4 2a 80 	movl   $0x802ac4,0x8(%esp)
  80131d:	00 
  80131e:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801325:	00 
  801326:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  80132d:	e8 5a ef ff ff       	call   80028c <_panic>
	...

00801334 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801337:	8b 45 08             	mov    0x8(%ebp),%eax
  80133a:	05 00 00 00 30       	add    $0x30000000,%eax
  80133f:	c1 e8 0c             	shr    $0xc,%eax
}
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80134a:	8b 45 08             	mov    0x8(%ebp),%eax
  80134d:	89 04 24             	mov    %eax,(%esp)
  801350:	e8 df ff ff ff       	call   801334 <fd2num>
  801355:	05 20 00 0d 00       	add    $0xd0020,%eax
  80135a:	c1 e0 0c             	shl    $0xc,%eax
}
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	53                   	push   %ebx
  801363:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801366:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80136b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80136d:	89 c2                	mov    %eax,%edx
  80136f:	c1 ea 16             	shr    $0x16,%edx
  801372:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801379:	f6 c2 01             	test   $0x1,%dl
  80137c:	74 11                	je     80138f <fd_alloc+0x30>
  80137e:	89 c2                	mov    %eax,%edx
  801380:	c1 ea 0c             	shr    $0xc,%edx
  801383:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80138a:	f6 c2 01             	test   $0x1,%dl
  80138d:	75 09                	jne    801398 <fd_alloc+0x39>
			*fd_store = fd;
  80138f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801391:	b8 00 00 00 00       	mov    $0x0,%eax
  801396:	eb 17                	jmp    8013af <fd_alloc+0x50>
  801398:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80139d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013a2:	75 c7                	jne    80136b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013aa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013af:	5b                   	pop    %ebx
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013b8:	83 f8 1f             	cmp    $0x1f,%eax
  8013bb:	77 36                	ja     8013f3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013bd:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013c2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	c1 ea 16             	shr    $0x16,%edx
  8013ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013d1:	f6 c2 01             	test   $0x1,%dl
  8013d4:	74 24                	je     8013fa <fd_lookup+0x48>
  8013d6:	89 c2                	mov    %eax,%edx
  8013d8:	c1 ea 0c             	shr    $0xc,%edx
  8013db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e2:	f6 c2 01             	test   $0x1,%dl
  8013e5:	74 1a                	je     801401 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ea:	89 02                	mov    %eax,(%edx)
	return 0;
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f1:	eb 13                	jmp    801406 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f8:	eb 0c                	jmp    801406 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ff:	eb 05                	jmp    801406 <fd_lookup+0x54>
  801401:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	53                   	push   %ebx
  80140c:	83 ec 14             	sub    $0x14,%esp
  80140f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801412:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801415:	ba 00 00 00 00       	mov    $0x0,%edx
  80141a:	eb 0e                	jmp    80142a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80141c:	39 08                	cmp    %ecx,(%eax)
  80141e:	75 09                	jne    801429 <dev_lookup+0x21>
			*dev = devtab[i];
  801420:	89 03                	mov    %eax,(%ebx)
			return 0;
  801422:	b8 00 00 00 00       	mov    $0x0,%eax
  801427:	eb 33                	jmp    80145c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801429:	42                   	inc    %edx
  80142a:	8b 04 95 5c 2b 80 00 	mov    0x802b5c(,%edx,4),%eax
  801431:	85 c0                	test   %eax,%eax
  801433:	75 e7                	jne    80141c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801435:	a1 20 44 80 00       	mov    0x804420,%eax
  80143a:	8b 40 48             	mov    0x48(%eax),%eax
  80143d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801441:	89 44 24 04          	mov    %eax,0x4(%esp)
  801445:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  80144c:	e8 33 ef ff ff       	call   800384 <cprintf>
	*dev = 0;
  801451:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80145c:	83 c4 14             	add    $0x14,%esp
  80145f:	5b                   	pop    %ebx
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	56                   	push   %esi
  801466:	53                   	push   %ebx
  801467:	83 ec 30             	sub    $0x30,%esp
  80146a:	8b 75 08             	mov    0x8(%ebp),%esi
  80146d:	8a 45 0c             	mov    0xc(%ebp),%al
  801470:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801473:	89 34 24             	mov    %esi,(%esp)
  801476:	e8 b9 fe ff ff       	call   801334 <fd2num>
  80147b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80147e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801482:	89 04 24             	mov    %eax,(%esp)
  801485:	e8 28 ff ff ff       	call   8013b2 <fd_lookup>
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 05                	js     801495 <fd_close+0x33>
	    || fd != fd2)
  801490:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801493:	74 0d                	je     8014a2 <fd_close+0x40>
		return (must_exist ? r : 0);
  801495:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801499:	75 46                	jne    8014e1 <fd_close+0x7f>
  80149b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a0:	eb 3f                	jmp    8014e1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a9:	8b 06                	mov    (%esi),%eax
  8014ab:	89 04 24             	mov    %eax,(%esp)
  8014ae:	e8 55 ff ff ff       	call   801408 <dev_lookup>
  8014b3:	89 c3                	mov    %eax,%ebx
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 18                	js     8014d1 <fd_close+0x6f>
		if (dev->dev_close)
  8014b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bc:	8b 40 10             	mov    0x10(%eax),%eax
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	74 09                	je     8014cc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014c3:	89 34 24             	mov    %esi,(%esp)
  8014c6:	ff d0                	call   *%eax
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	eb 05                	jmp    8014d1 <fd_close+0x6f>
		else
			r = 0;
  8014cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014dc:	e8 e7 f8 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
}
  8014e1:	89 d8                	mov    %ebx,%eax
  8014e3:	83 c4 30             	add    $0x30,%esp
  8014e6:	5b                   	pop    %ebx
  8014e7:	5e                   	pop    %esi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    

008014ea <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fa:	89 04 24             	mov    %eax,(%esp)
  8014fd:	e8 b0 fe ff ff       	call   8013b2 <fd_lookup>
  801502:	85 c0                	test   %eax,%eax
  801504:	78 13                	js     801519 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801506:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80150d:	00 
  80150e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801511:	89 04 24             	mov    %eax,(%esp)
  801514:	e8 49 ff ff ff       	call   801462 <fd_close>
}
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <close_all>:

void
close_all(void)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	53                   	push   %ebx
  80151f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801522:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801527:	89 1c 24             	mov    %ebx,(%esp)
  80152a:	e8 bb ff ff ff       	call   8014ea <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80152f:	43                   	inc    %ebx
  801530:	83 fb 20             	cmp    $0x20,%ebx
  801533:	75 f2                	jne    801527 <close_all+0xc>
		close(i);
}
  801535:	83 c4 14             	add    $0x14,%esp
  801538:	5b                   	pop    %ebx
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	57                   	push   %edi
  80153f:	56                   	push   %esi
  801540:	53                   	push   %ebx
  801541:	83 ec 4c             	sub    $0x4c,%esp
  801544:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80154a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154e:	8b 45 08             	mov    0x8(%ebp),%eax
  801551:	89 04 24             	mov    %eax,(%esp)
  801554:	e8 59 fe ff ff       	call   8013b2 <fd_lookup>
  801559:	89 c3                	mov    %eax,%ebx
  80155b:	85 c0                	test   %eax,%eax
  80155d:	0f 88 e1 00 00 00    	js     801644 <dup+0x109>
		return r;
	close(newfdnum);
  801563:	89 3c 24             	mov    %edi,(%esp)
  801566:	e8 7f ff ff ff       	call   8014ea <close>

	newfd = INDEX2FD(newfdnum);
  80156b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801571:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 c5 fd ff ff       	call   801344 <fd2data>
  80157f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801581:	89 34 24             	mov    %esi,(%esp)
  801584:	e8 bb fd ff ff       	call   801344 <fd2data>
  801589:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	c1 e8 16             	shr    $0x16,%eax
  801591:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801598:	a8 01                	test   $0x1,%al
  80159a:	74 46                	je     8015e2 <dup+0xa7>
  80159c:	89 d8                	mov    %ebx,%eax
  80159e:	c1 e8 0c             	shr    $0xc,%eax
  8015a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015a8:	f6 c2 01             	test   $0x1,%dl
  8015ab:	74 35                	je     8015e2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015cb:	00 
  8015cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d7:	e8 99 f7 ff ff       	call   800d75 <sys_page_map>
  8015dc:	89 c3                	mov    %eax,%ebx
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 3b                	js     80161d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	c1 ea 0c             	shr    $0xc,%edx
  8015ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801606:	00 
  801607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801612:	e8 5e f7 ff ff       	call   800d75 <sys_page_map>
  801617:	89 c3                	mov    %eax,%ebx
  801619:	85 c0                	test   %eax,%eax
  80161b:	79 25                	jns    801642 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80161d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801621:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801628:	e8 9b f7 ff ff       	call   800dc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80162d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163b:	e8 88 f7 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  801640:	eb 02                	jmp    801644 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801642:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801644:	89 d8                	mov    %ebx,%eax
  801646:	83 c4 4c             	add    $0x4c,%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	53                   	push   %ebx
  801652:	83 ec 24             	sub    $0x24,%esp
  801655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165f:	89 1c 24             	mov    %ebx,(%esp)
  801662:	e8 4b fd ff ff       	call   8013b2 <fd_lookup>
  801667:	85 c0                	test   %eax,%eax
  801669:	78 6d                	js     8016d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	8b 00                	mov    (%eax),%eax
  801677:	89 04 24             	mov    %eax,(%esp)
  80167a:	e8 89 fd ff ff       	call   801408 <dev_lookup>
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 55                	js     8016d8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801686:	8b 50 08             	mov    0x8(%eax),%edx
  801689:	83 e2 03             	and    $0x3,%edx
  80168c:	83 fa 01             	cmp    $0x1,%edx
  80168f:	75 23                	jne    8016b4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801691:	a1 20 44 80 00       	mov    0x804420,%eax
  801696:	8b 40 48             	mov    0x48(%eax),%eax
  801699:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80169d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a1:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  8016a8:	e8 d7 ec ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  8016ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b2:	eb 24                	jmp    8016d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b7:	8b 52 08             	mov    0x8(%edx),%edx
  8016ba:	85 d2                	test   %edx,%edx
  8016bc:	74 15                	je     8016d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	ff d2                	call   *%edx
  8016d1:	eb 05                	jmp    8016d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016d8:	83 c4 24             	add    $0x24,%esp
  8016db:	5b                   	pop    %ebx
  8016dc:	5d                   	pop    %ebp
  8016dd:	c3                   	ret    

008016de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	57                   	push   %edi
  8016e2:	56                   	push   %esi
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 1c             	sub    $0x1c,%esp
  8016e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f2:	eb 23                	jmp    801717 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016f4:	89 f0                	mov    %esi,%eax
  8016f6:	29 d8                	sub    %ebx,%eax
  8016f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ff:	01 d8                	add    %ebx,%eax
  801701:	89 44 24 04          	mov    %eax,0x4(%esp)
  801705:	89 3c 24             	mov    %edi,(%esp)
  801708:	e8 41 ff ff ff       	call   80164e <read>
		if (m < 0)
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 10                	js     801721 <readn+0x43>
			return m;
		if (m == 0)
  801711:	85 c0                	test   %eax,%eax
  801713:	74 0a                	je     80171f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801715:	01 c3                	add    %eax,%ebx
  801717:	39 f3                	cmp    %esi,%ebx
  801719:	72 d9                	jb     8016f4 <readn+0x16>
  80171b:	89 d8                	mov    %ebx,%eax
  80171d:	eb 02                	jmp    801721 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80171f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801721:	83 c4 1c             	add    $0x1c,%esp
  801724:	5b                   	pop    %ebx
  801725:	5e                   	pop    %esi
  801726:	5f                   	pop    %edi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	53                   	push   %ebx
  80172d:	83 ec 24             	sub    $0x24,%esp
  801730:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173a:	89 1c 24             	mov    %ebx,(%esp)
  80173d:	e8 70 fc ff ff       	call   8013b2 <fd_lookup>
  801742:	85 c0                	test   %eax,%eax
  801744:	78 68                	js     8017ae <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801746:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801750:	8b 00                	mov    (%eax),%eax
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	e8 ae fc ff ff       	call   801408 <dev_lookup>
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 50                	js     8017ae <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801761:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801765:	75 23                	jne    80178a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801767:	a1 20 44 80 00       	mov    0x804420,%eax
  80176c:	8b 40 48             	mov    0x48(%eax),%eax
  80176f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801773:	89 44 24 04          	mov    %eax,0x4(%esp)
  801777:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  80177e:	e8 01 ec ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  801783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801788:	eb 24                	jmp    8017ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80178a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178d:	8b 52 0c             	mov    0xc(%edx),%edx
  801790:	85 d2                	test   %edx,%edx
  801792:	74 15                	je     8017a9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801794:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801797:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80179b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	ff d2                	call   *%edx
  8017a7:	eb 05                	jmp    8017ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017ae:	83 c4 24             	add    $0x24,%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	89 04 24             	mov    %eax,(%esp)
  8017c7:	e8 e6 fb ff ff       	call   8013b2 <fd_lookup>
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 0e                	js     8017de <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	53                   	push   %ebx
  8017e4:	83 ec 24             	sub    $0x24,%esp
  8017e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	89 1c 24             	mov    %ebx,(%esp)
  8017f4:	e8 b9 fb ff ff       	call   8013b2 <fd_lookup>
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 61                	js     80185e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801800:	89 44 24 04          	mov    %eax,0x4(%esp)
  801804:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801807:	8b 00                	mov    (%eax),%eax
  801809:	89 04 24             	mov    %eax,(%esp)
  80180c:	e8 f7 fb ff ff       	call   801408 <dev_lookup>
  801811:	85 c0                	test   %eax,%eax
  801813:	78 49                	js     80185e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801818:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80181c:	75 23                	jne    801841 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80181e:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801823:	8b 40 48             	mov    0x48(%eax),%eax
  801826:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80182a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182e:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  801835:	e8 4a eb ff ff       	call   800384 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80183a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183f:	eb 1d                	jmp    80185e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801841:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801844:	8b 52 18             	mov    0x18(%edx),%edx
  801847:	85 d2                	test   %edx,%edx
  801849:	74 0e                	je     801859 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80184b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	ff d2                	call   *%edx
  801857:	eb 05                	jmp    80185e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801859:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80185e:	83 c4 24             	add    $0x24,%esp
  801861:	5b                   	pop    %ebx
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	53                   	push   %ebx
  801868:	83 ec 24             	sub    $0x24,%esp
  80186b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801871:	89 44 24 04          	mov    %eax,0x4(%esp)
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	89 04 24             	mov    %eax,(%esp)
  80187b:	e8 32 fb ff ff       	call   8013b2 <fd_lookup>
  801880:	85 c0                	test   %eax,%eax
  801882:	78 52                	js     8018d6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188e:	8b 00                	mov    (%eax),%eax
  801890:	89 04 24             	mov    %eax,(%esp)
  801893:	e8 70 fb ff ff       	call   801408 <dev_lookup>
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 3a                	js     8018d6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80189c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a3:	74 2c                	je     8018d1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018af:	00 00 00 
	stat->st_isdir = 0;
  8018b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b9:	00 00 00 
	stat->st_dev = dev;
  8018bc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018c9:	89 14 24             	mov    %edx,(%esp)
  8018cc:	ff 50 14             	call   *0x14(%eax)
  8018cf:	eb 05                	jmp    8018d6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018d6:	83 c4 24             	add    $0x24,%esp
  8018d9:	5b                   	pop    %ebx
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018eb:	00 
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	e8 fe 01 00 00       	call   801af5 <open>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	78 1b                	js     801918 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8018fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801900:	89 44 24 04          	mov    %eax,0x4(%esp)
  801904:	89 1c 24             	mov    %ebx,(%esp)
  801907:	e8 58 ff ff ff       	call   801864 <fstat>
  80190c:	89 c6                	mov    %eax,%esi
	close(fd);
  80190e:	89 1c 24             	mov    %ebx,(%esp)
  801911:	e8 d4 fb ff ff       	call   8014ea <close>
	return r;
  801916:	89 f3                	mov    %esi,%ebx
}
  801918:	89 d8                	mov    %ebx,%eax
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    
  801921:	00 00                	add    %al,(%eax)
	...

00801924 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	56                   	push   %esi
  801928:	53                   	push   %ebx
  801929:	83 ec 10             	sub    $0x10,%esp
  80192c:	89 c3                	mov    %eax,%ebx
  80192e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801930:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801937:	75 11                	jne    80194a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801939:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801940:	e8 1a 09 00 00       	call   80225f <ipc_find_env>
  801945:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80194a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801951:	00 
  801952:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801959:	00 
  80195a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80195e:	a1 00 40 80 00       	mov    0x804000,%eax
  801963:	89 04 24             	mov    %eax,(%esp)
  801966:	e8 8a 08 00 00       	call   8021f5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80196b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801972:	00 
  801973:	89 74 24 04          	mov    %esi,0x4(%esp)
  801977:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80197e:	e8 09 08 00 00       	call   80218c <ipc_recv>
}
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	5b                   	pop    %ebx
  801987:	5e                   	pop    %esi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	8b 40 0c             	mov    0xc(%eax),%eax
  801996:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80199b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ad:	e8 72 ff ff ff       	call   801924 <fsipc>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8019cf:	e8 50 ff ff ff       	call   801924 <fsipc>
}
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 14             	sub    $0x14,%esp
  8019dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f5:	e8 2a ff ff ff       	call   801924 <fsipc>
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 2b                	js     801a29 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019fe:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a05:	00 
  801a06:	89 1c 24             	mov    %ebx,(%esp)
  801a09:	e8 21 ef ff ff       	call   80092f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a0e:	a1 80 50 80 00       	mov    0x805080,%eax
  801a13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a19:	a1 84 50 80 00       	mov    0x805084,%eax
  801a1e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a29:	83 c4 14             	add    $0x14,%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a35:	c7 44 24 08 6c 2b 80 	movl   $0x802b6c,0x8(%esp)
  801a3c:	00 
  801a3d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a44:	00 
  801a45:	c7 04 24 8a 2b 80 00 	movl   $0x802b8a,(%esp)
  801a4c:	e8 3b e8 ff ff       	call   80028c <_panic>

00801a51 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	83 ec 10             	sub    $0x10,%esp
  801a59:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a62:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a67:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a72:	b8 03 00 00 00       	mov    $0x3,%eax
  801a77:	e8 a8 fe ff ff       	call   801924 <fsipc>
  801a7c:	89 c3                	mov    %eax,%ebx
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	78 6a                	js     801aec <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a82:	39 c6                	cmp    %eax,%esi
  801a84:	73 24                	jae    801aaa <devfile_read+0x59>
  801a86:	c7 44 24 0c 95 2b 80 	movl   $0x802b95,0xc(%esp)
  801a8d:	00 
  801a8e:	c7 44 24 08 9c 2b 80 	movl   $0x802b9c,0x8(%esp)
  801a95:	00 
  801a96:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a9d:	00 
  801a9e:	c7 04 24 8a 2b 80 00 	movl   $0x802b8a,(%esp)
  801aa5:	e8 e2 e7 ff ff       	call   80028c <_panic>
	assert(r <= PGSIZE);
  801aaa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aaf:	7e 24                	jle    801ad5 <devfile_read+0x84>
  801ab1:	c7 44 24 0c b1 2b 80 	movl   $0x802bb1,0xc(%esp)
  801ab8:	00 
  801ab9:	c7 44 24 08 9c 2b 80 	movl   $0x802b9c,0x8(%esp)
  801ac0:	00 
  801ac1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ac8:	00 
  801ac9:	c7 04 24 8a 2b 80 00 	movl   $0x802b8a,(%esp)
  801ad0:	e8 b7 e7 ff ff       	call   80028c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad9:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ae0:	00 
  801ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae4:	89 04 24             	mov    %eax,(%esp)
  801ae7:	e8 bc ef ff ff       	call   800aa8 <memmove>
	return r;
}
  801aec:	89 d8                	mov    %ebx,%eax
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	83 ec 20             	sub    $0x20,%esp
  801afd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b00:	89 34 24             	mov    %esi,(%esp)
  801b03:	e8 f4 ed ff ff       	call   8008fc <strlen>
  801b08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b0d:	7f 60                	jg     801b6f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b12:	89 04 24             	mov    %eax,(%esp)
  801b15:	e8 45 f8 ff ff       	call   80135f <fd_alloc>
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	78 54                	js     801b74 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b20:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b24:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b2b:	e8 ff ed ff ff       	call   80092f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b33:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801b40:	e8 df fd ff ff       	call   801924 <fsipc>
  801b45:	89 c3                	mov    %eax,%ebx
  801b47:	85 c0                	test   %eax,%eax
  801b49:	79 15                	jns    801b60 <open+0x6b>
		fd_close(fd, 0);
  801b4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b52:	00 
  801b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b56:	89 04 24             	mov    %eax,(%esp)
  801b59:	e8 04 f9 ff ff       	call   801462 <fd_close>
		return r;
  801b5e:	eb 14                	jmp    801b74 <open+0x7f>
	}

	return fd2num(fd);
  801b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b63:	89 04 24             	mov    %eax,(%esp)
  801b66:	e8 c9 f7 ff ff       	call   801334 <fd2num>
  801b6b:	89 c3                	mov    %eax,%ebx
  801b6d:	eb 05                	jmp    801b74 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b6f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	83 c4 20             	add    $0x20,%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b83:	ba 00 00 00 00       	mov    $0x0,%edx
  801b88:	b8 08 00 00 00       	mov    $0x8,%eax
  801b8d:	e8 92 fd ff ff       	call   801924 <fsipc>
}
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	83 ec 10             	sub    $0x10,%esp
  801b9c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba2:	89 04 24             	mov    %eax,(%esp)
  801ba5:	e8 9a f7 ff ff       	call   801344 <fd2data>
  801baa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bac:	c7 44 24 04 bd 2b 80 	movl   $0x802bbd,0x4(%esp)
  801bb3:	00 
  801bb4:	89 34 24             	mov    %esi,(%esp)
  801bb7:	e8 73 ed ff ff       	call   80092f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bbc:	8b 43 04             	mov    0x4(%ebx),%eax
  801bbf:	2b 03                	sub    (%ebx),%eax
  801bc1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bc7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bce:	00 00 00 
	stat->st_dev = &devpipe;
  801bd1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801bd8:	30 80 00 
	return 0;
}
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	53                   	push   %ebx
  801beb:	83 ec 14             	sub    $0x14,%esp
  801bee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bf1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfc:	e8 c7 f1 ff ff       	call   800dc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c01:	89 1c 24             	mov    %ebx,(%esp)
  801c04:	e8 3b f7 ff ff       	call   801344 <fd2data>
  801c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c14:	e8 af f1 ff ff       	call   800dc8 <sys_page_unmap>
}
  801c19:	83 c4 14             	add    $0x14,%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	57                   	push   %edi
  801c23:	56                   	push   %esi
  801c24:	53                   	push   %ebx
  801c25:	83 ec 2c             	sub    $0x2c,%esp
  801c28:	89 c7                	mov    %eax,%edi
  801c2a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c2d:	a1 20 44 80 00       	mov    0x804420,%eax
  801c32:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c35:	89 3c 24             	mov    %edi,(%esp)
  801c38:	e8 67 06 00 00       	call   8022a4 <pageref>
  801c3d:	89 c6                	mov    %eax,%esi
  801c3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c42:	89 04 24             	mov    %eax,(%esp)
  801c45:	e8 5a 06 00 00       	call   8022a4 <pageref>
  801c4a:	39 c6                	cmp    %eax,%esi
  801c4c:	0f 94 c0             	sete   %al
  801c4f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c52:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801c58:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c5b:	39 cb                	cmp    %ecx,%ebx
  801c5d:	75 08                	jne    801c67 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c5f:	83 c4 2c             	add    $0x2c,%esp
  801c62:	5b                   	pop    %ebx
  801c63:	5e                   	pop    %esi
  801c64:	5f                   	pop    %edi
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c67:	83 f8 01             	cmp    $0x1,%eax
  801c6a:	75 c1                	jne    801c2d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c6c:	8b 42 58             	mov    0x58(%edx),%eax
  801c6f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c76:	00 
  801c77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c7f:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  801c86:	e8 f9 e6 ff ff       	call   800384 <cprintf>
  801c8b:	eb a0                	jmp    801c2d <_pipeisclosed+0xe>

00801c8d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	57                   	push   %edi
  801c91:	56                   	push   %esi
  801c92:	53                   	push   %ebx
  801c93:	83 ec 1c             	sub    $0x1c,%esp
  801c96:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c99:	89 34 24             	mov    %esi,(%esp)
  801c9c:	e8 a3 f6 ff ff       	call   801344 <fd2data>
  801ca1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ca8:	eb 3c                	jmp    801ce6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801caa:	89 da                	mov    %ebx,%edx
  801cac:	89 f0                	mov    %esi,%eax
  801cae:	e8 6c ff ff ff       	call   801c1f <_pipeisclosed>
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	75 38                	jne    801cef <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cb7:	e8 46 f0 ff ff       	call   800d02 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cbc:	8b 43 04             	mov    0x4(%ebx),%eax
  801cbf:	8b 13                	mov    (%ebx),%edx
  801cc1:	83 c2 20             	add    $0x20,%edx
  801cc4:	39 d0                	cmp    %edx,%eax
  801cc6:	73 e2                	jae    801caa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ccb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801cce:	89 c2                	mov    %eax,%edx
  801cd0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801cd6:	79 05                	jns    801cdd <devpipe_write+0x50>
  801cd8:	4a                   	dec    %edx
  801cd9:	83 ca e0             	or     $0xffffffe0,%edx
  801cdc:	42                   	inc    %edx
  801cdd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ce1:	40                   	inc    %eax
  801ce2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce5:	47                   	inc    %edi
  801ce6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ce9:	75 d1                	jne    801cbc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ceb:	89 f8                	mov    %edi,%eax
  801ced:	eb 05                	jmp    801cf4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cf4:	83 c4 1c             	add    $0x1c,%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5f                   	pop    %edi
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	57                   	push   %edi
  801d00:	56                   	push   %esi
  801d01:	53                   	push   %ebx
  801d02:	83 ec 1c             	sub    $0x1c,%esp
  801d05:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d08:	89 3c 24             	mov    %edi,(%esp)
  801d0b:	e8 34 f6 ff ff       	call   801344 <fd2data>
  801d10:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d12:	be 00 00 00 00       	mov    $0x0,%esi
  801d17:	eb 3a                	jmp    801d53 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d19:	85 f6                	test   %esi,%esi
  801d1b:	74 04                	je     801d21 <devpipe_read+0x25>
				return i;
  801d1d:	89 f0                	mov    %esi,%eax
  801d1f:	eb 40                	jmp    801d61 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d21:	89 da                	mov    %ebx,%edx
  801d23:	89 f8                	mov    %edi,%eax
  801d25:	e8 f5 fe ff ff       	call   801c1f <_pipeisclosed>
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	75 2e                	jne    801d5c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d2e:	e8 cf ef ff ff       	call   800d02 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d33:	8b 03                	mov    (%ebx),%eax
  801d35:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d38:	74 df                	je     801d19 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d3f:	79 05                	jns    801d46 <devpipe_read+0x4a>
  801d41:	48                   	dec    %eax
  801d42:	83 c8 e0             	or     $0xffffffe0,%eax
  801d45:	40                   	inc    %eax
  801d46:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d50:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d52:	46                   	inc    %esi
  801d53:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d56:	75 db                	jne    801d33 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d58:	89 f0                	mov    %esi,%eax
  801d5a:	eb 05                	jmp    801d61 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d5c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	57                   	push   %edi
  801d6d:	56                   	push   %esi
  801d6e:	53                   	push   %ebx
  801d6f:	83 ec 3c             	sub    $0x3c,%esp
  801d72:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d75:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d78:	89 04 24             	mov    %eax,(%esp)
  801d7b:	e8 df f5 ff ff       	call   80135f <fd_alloc>
  801d80:	89 c3                	mov    %eax,%ebx
  801d82:	85 c0                	test   %eax,%eax
  801d84:	0f 88 45 01 00 00    	js     801ecf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d91:	00 
  801d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da0:	e8 7c ef ff ff       	call   800d21 <sys_page_alloc>
  801da5:	89 c3                	mov    %eax,%ebx
  801da7:	85 c0                	test   %eax,%eax
  801da9:	0f 88 20 01 00 00    	js     801ecf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801daf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801db2:	89 04 24             	mov    %eax,(%esp)
  801db5:	e8 a5 f5 ff ff       	call   80135f <fd_alloc>
  801dba:	89 c3                	mov    %eax,%ebx
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	0f 88 f8 00 00 00    	js     801ebc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dcb:	00 
  801dcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dda:	e8 42 ef ff ff       	call   800d21 <sys_page_alloc>
  801ddf:	89 c3                	mov    %eax,%ebx
  801de1:	85 c0                	test   %eax,%eax
  801de3:	0f 88 d3 00 00 00    	js     801ebc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801de9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dec:	89 04 24             	mov    %eax,(%esp)
  801def:	e8 50 f5 ff ff       	call   801344 <fd2data>
  801df4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dfd:	00 
  801dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e09:	e8 13 ef ff ff       	call   800d21 <sys_page_alloc>
  801e0e:	89 c3                	mov    %eax,%ebx
  801e10:	85 c0                	test   %eax,%eax
  801e12:	0f 88 91 00 00 00    	js     801ea9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e1b:	89 04 24             	mov    %eax,(%esp)
  801e1e:	e8 21 f5 ff ff       	call   801344 <fd2data>
  801e23:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e2a:	00 
  801e2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e36:	00 
  801e37:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e42:	e8 2e ef ff ff       	call   800d75 <sys_page_map>
  801e47:	89 c3                	mov    %eax,%ebx
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 4c                	js     801e99 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e56:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e5b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e62:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e68:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e6b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e70:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7a:	89 04 24             	mov    %eax,(%esp)
  801e7d:	e8 b2 f4 ff ff       	call   801334 <fd2num>
  801e82:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e87:	89 04 24             	mov    %eax,(%esp)
  801e8a:	e8 a5 f4 ff ff       	call   801334 <fd2num>
  801e8f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e97:	eb 36                	jmp    801ecf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e99:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea4:	e8 1f ef ff ff       	call   800dc8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ea9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb7:	e8 0c ef ff ff       	call   800dc8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eca:	e8 f9 ee ff ff       	call   800dc8 <sys_page_unmap>
    err:
	return r;
}
  801ecf:	89 d8                	mov    %ebx,%eax
  801ed1:	83 c4 3c             	add    $0x3c,%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801edf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee9:	89 04 24             	mov    %eax,(%esp)
  801eec:	e8 c1 f4 ff ff       	call   8013b2 <fd_lookup>
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 15                	js     801f0a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef8:	89 04 24             	mov    %eax,(%esp)
  801efb:	e8 44 f4 ff ff       	call   801344 <fd2data>
	return _pipeisclosed(fd, p);
  801f00:	89 c2                	mov    %eax,%edx
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	e8 15 fd ff ff       	call   801c1f <_pipeisclosed>
}
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	83 ec 10             	sub    $0x10,%esp
  801f14:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801f17:	85 f6                	test   %esi,%esi
  801f19:	75 24                	jne    801f3f <wait+0x33>
  801f1b:	c7 44 24 0c dc 2b 80 	movl   $0x802bdc,0xc(%esp)
  801f22:	00 
  801f23:	c7 44 24 08 9c 2b 80 	movl   $0x802b9c,0x8(%esp)
  801f2a:	00 
  801f2b:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  801f32:	00 
  801f33:	c7 04 24 e7 2b 80 00 	movl   $0x802be7,(%esp)
  801f3a:	e8 4d e3 ff ff       	call   80028c <_panic>
	e = &envs[ENVX(envid)];
  801f3f:	89 f3                	mov    %esi,%ebx
  801f41:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801f47:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  801f4e:	c1 e3 07             	shl    $0x7,%ebx
  801f51:	29 c3                	sub    %eax,%ebx
  801f53:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f59:	eb 05                	jmp    801f60 <wait+0x54>
		sys_yield();
  801f5b:	e8 a2 ed ff ff       	call   800d02 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f60:	8b 43 48             	mov    0x48(%ebx),%eax
  801f63:	39 f0                	cmp    %esi,%eax
  801f65:	75 07                	jne    801f6e <wait+0x62>
  801f67:	8b 43 54             	mov    0x54(%ebx),%eax
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	75 ed                	jne    801f5b <wait+0x4f>
		sys_yield();
}
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	5b                   	pop    %ebx
  801f72:	5e                   	pop    %esi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    
  801f75:	00 00                	add    %al,(%eax)
	...

00801f78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    

00801f82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f88:	c7 44 24 04 f2 2b 80 	movl   $0x802bf2,0x4(%esp)
  801f8f:	00 
  801f90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f93:	89 04 24             	mov    %eax,(%esp)
  801f96:	e8 94 e9 ff ff       	call   80092f <strcpy>
	return 0;
}
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	57                   	push   %edi
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fae:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fb3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb9:	eb 30                	jmp    801feb <devcons_write+0x49>
		m = n - tot;
  801fbb:	8b 75 10             	mov    0x10(%ebp),%esi
  801fbe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fc0:	83 fe 7f             	cmp    $0x7f,%esi
  801fc3:	76 05                	jbe    801fca <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801fc5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fca:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fce:	03 45 0c             	add    0xc(%ebp),%eax
  801fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd5:	89 3c 24             	mov    %edi,(%esp)
  801fd8:	e8 cb ea ff ff       	call   800aa8 <memmove>
		sys_cputs(buf, m);
  801fdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe1:	89 3c 24             	mov    %edi,(%esp)
  801fe4:	e8 6b ec ff ff       	call   800c54 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe9:	01 f3                	add    %esi,%ebx
  801feb:	89 d8                	mov    %ebx,%eax
  801fed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ff0:	72 c9                	jb     801fbb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ff2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    

00801ffd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802003:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802007:	75 07                	jne    802010 <devcons_read+0x13>
  802009:	eb 25                	jmp    802030 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80200b:	e8 f2 ec ff ff       	call   800d02 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802010:	e8 5d ec ff ff       	call   800c72 <sys_cgetc>
  802015:	85 c0                	test   %eax,%eax
  802017:	74 f2                	je     80200b <devcons_read+0xe>
  802019:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80201b:	85 c0                	test   %eax,%eax
  80201d:	78 1d                	js     80203c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80201f:	83 f8 04             	cmp    $0x4,%eax
  802022:	74 13                	je     802037 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802024:	8b 45 0c             	mov    0xc(%ebp),%eax
  802027:	88 10                	mov    %dl,(%eax)
	return 1;
  802029:	b8 01 00 00 00       	mov    $0x1,%eax
  80202e:	eb 0c                	jmp    80203c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802030:	b8 00 00 00 00       	mov    $0x0,%eax
  802035:	eb 05                	jmp    80203c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802044:	8b 45 08             	mov    0x8(%ebp),%eax
  802047:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80204a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802051:	00 
  802052:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 f7 eb ff ff       	call   800c54 <sys_cputs>
}
  80205d:	c9                   	leave  
  80205e:	c3                   	ret    

0080205f <getchar>:

int
getchar(void)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802065:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80206c:	00 
  80206d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802070:	89 44 24 04          	mov    %eax,0x4(%esp)
  802074:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207b:	e8 ce f5 ff ff       	call   80164e <read>
	if (r < 0)
  802080:	85 c0                	test   %eax,%eax
  802082:	78 0f                	js     802093 <getchar+0x34>
		return r;
	if (r < 1)
  802084:	85 c0                	test   %eax,%eax
  802086:	7e 06                	jle    80208e <getchar+0x2f>
		return -E_EOF;
	return c;
  802088:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80208c:	eb 05                	jmp    802093 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80208e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80209b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 05 f3 ff ff       	call   8013b2 <fd_lookup>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	78 11                	js     8020c2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ba:	39 10                	cmp    %edx,(%eax)
  8020bc:	0f 94 c0             	sete   %al
  8020bf:	0f b6 c0             	movzbl %al,%eax
}
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <opencons>:

int
opencons(void)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cd:	89 04 24             	mov    %eax,(%esp)
  8020d0:	e8 8a f2 ff ff       	call   80135f <fd_alloc>
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	78 3c                	js     802115 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020e0:	00 
  8020e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ef:	e8 2d ec ff ff       	call   800d21 <sys_page_alloc>
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	78 1d                	js     802115 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020f8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802101:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802103:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802106:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80210d:	89 04 24             	mov    %eax,(%esp)
  802110:	e8 1f f2 ff ff       	call   801334 <fd2num>
}
  802115:	c9                   	leave  
  802116:	c3                   	ret    
	...

00802118 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80211e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802125:	75 32                	jne    802159 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802127:	e8 b7 eb ff ff       	call   800ce3 <sys_getenvid>
  80212c:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  802133:	00 
  802134:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80213b:	ee 
  80213c:	89 04 24             	mov    %eax,(%esp)
  80213f:	e8 dd eb ff ff       	call   800d21 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  802144:	e8 9a eb ff ff       	call   800ce3 <sys_getenvid>
  802149:	c7 44 24 04 64 21 80 	movl   $0x802164,0x4(%esp)
  802150:	00 
  802151:	89 04 24             	mov    %eax,(%esp)
  802154:	e8 68 ed ff ff       	call   800ec1 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    
	...

00802164 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802164:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802165:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80216a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80216c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  80216f:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  802173:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  802176:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  80217b:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  80217f:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  802182:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  802183:	83 c4 04             	add    $0x4,%esp
	popfl
  802186:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  802187:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  802188:	c3                   	ret    
  802189:	00 00                	add    %al,(%eax)
	...

0080218c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	57                   	push   %edi
  802190:	56                   	push   %esi
  802191:	53                   	push   %ebx
  802192:	83 ec 1c             	sub    $0x1c,%esp
  802195:	8b 75 08             	mov    0x8(%ebp),%esi
  802198:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80219b:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  80219e:	85 db                	test   %ebx,%ebx
  8021a0:	75 05                	jne    8021a7 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8021a2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8021a7:	89 1c 24             	mov    %ebx,(%esp)
  8021aa:	e8 88 ed ff ff       	call   800f37 <sys_ipc_recv>
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	79 16                	jns    8021c9 <ipc_recv+0x3d>
		*from_env_store = 0;
  8021b3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8021b9:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  8021bf:	89 1c 24             	mov    %ebx,(%esp)
  8021c2:	e8 70 ed ff ff       	call   800f37 <sys_ipc_recv>
  8021c7:	eb 24                	jmp    8021ed <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  8021c9:	85 f6                	test   %esi,%esi
  8021cb:	74 0a                	je     8021d7 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8021cd:	a1 20 44 80 00       	mov    0x804420,%eax
  8021d2:	8b 40 74             	mov    0x74(%eax),%eax
  8021d5:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8021d7:	85 ff                	test   %edi,%edi
  8021d9:	74 0a                	je     8021e5 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8021db:	a1 20 44 80 00       	mov    0x804420,%eax
  8021e0:	8b 40 78             	mov    0x78(%eax),%eax
  8021e3:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8021e5:	a1 20 44 80 00       	mov    0x804420,%eax
  8021ea:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	57                   	push   %edi
  8021f9:	56                   	push   %esi
  8021fa:	53                   	push   %ebx
  8021fb:	83 ec 1c             	sub    $0x1c,%esp
  8021fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802201:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802204:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802207:	85 db                	test   %ebx,%ebx
  802209:	75 05                	jne    802210 <ipc_send+0x1b>
		pg = (void *)-1;
  80220b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802210:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802214:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802218:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80221c:	8b 45 08             	mov    0x8(%ebp),%eax
  80221f:	89 04 24             	mov    %eax,(%esp)
  802222:	e8 ed ec ff ff       	call   800f14 <sys_ipc_try_send>
		if (r == 0) {		
  802227:	85 c0                	test   %eax,%eax
  802229:	74 2c                	je     802257 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80222b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80222e:	75 07                	jne    802237 <ipc_send+0x42>
			sys_yield();
  802230:	e8 cd ea ff ff       	call   800d02 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  802235:	eb d9                	jmp    802210 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  802237:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80223b:	c7 44 24 08 fe 2b 80 	movl   $0x802bfe,0x8(%esp)
  802242:	00 
  802243:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80224a:	00 
  80224b:	c7 04 24 0c 2c 80 00 	movl   $0x802c0c,(%esp)
  802252:	e8 35 e0 ff ff       	call   80028c <_panic>
		}
	}
}
  802257:	83 c4 1c             	add    $0x1c,%esp
  80225a:	5b                   	pop    %ebx
  80225b:	5e                   	pop    %esi
  80225c:	5f                   	pop    %edi
  80225d:	5d                   	pop    %ebp
  80225e:	c3                   	ret    

0080225f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	53                   	push   %ebx
  802263:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802266:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80226b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802272:	89 c2                	mov    %eax,%edx
  802274:	c1 e2 07             	shl    $0x7,%edx
  802277:	29 ca                	sub    %ecx,%edx
  802279:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80227f:	8b 52 50             	mov    0x50(%edx),%edx
  802282:	39 da                	cmp    %ebx,%edx
  802284:	75 0f                	jne    802295 <ipc_find_env+0x36>
			return envs[i].env_id;
  802286:	c1 e0 07             	shl    $0x7,%eax
  802289:	29 c8                	sub    %ecx,%eax
  80228b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802290:	8b 40 40             	mov    0x40(%eax),%eax
  802293:	eb 0c                	jmp    8022a1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802295:	40                   	inc    %eax
  802296:	3d 00 04 00 00       	cmp    $0x400,%eax
  80229b:	75 ce                	jne    80226b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80229d:	66 b8 00 00          	mov    $0x0,%ax
}
  8022a1:	5b                   	pop    %ebx
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    

008022a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022a4:	55                   	push   %ebp
  8022a5:	89 e5                	mov    %esp,%ebp
  8022a7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022aa:	89 c2                	mov    %eax,%edx
  8022ac:	c1 ea 16             	shr    $0x16,%edx
  8022af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022b6:	f6 c2 01             	test   $0x1,%dl
  8022b9:	74 1e                	je     8022d9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022bb:	c1 e8 0c             	shr    $0xc,%eax
  8022be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022c5:	a8 01                	test   $0x1,%al
  8022c7:	74 17                	je     8022e0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022c9:	c1 e8 0c             	shr    $0xc,%eax
  8022cc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022d3:	ef 
  8022d4:	0f b7 c0             	movzwl %ax,%eax
  8022d7:	eb 0c                	jmp    8022e5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8022de:	eb 05                	jmp    8022e5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022e0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    
	...

008022e8 <__udivdi3>:
  8022e8:	55                   	push   %ebp
  8022e9:	57                   	push   %edi
  8022ea:	56                   	push   %esi
  8022eb:	83 ec 10             	sub    $0x10,%esp
  8022ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8022f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022fe:	89 cd                	mov    %ecx,%ebp
  802300:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802304:	85 c0                	test   %eax,%eax
  802306:	75 2c                	jne    802334 <__udivdi3+0x4c>
  802308:	39 f9                	cmp    %edi,%ecx
  80230a:	77 68                	ja     802374 <__udivdi3+0x8c>
  80230c:	85 c9                	test   %ecx,%ecx
  80230e:	75 0b                	jne    80231b <__udivdi3+0x33>
  802310:	b8 01 00 00 00       	mov    $0x1,%eax
  802315:	31 d2                	xor    %edx,%edx
  802317:	f7 f1                	div    %ecx
  802319:	89 c1                	mov    %eax,%ecx
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	89 f8                	mov    %edi,%eax
  80231f:	f7 f1                	div    %ecx
  802321:	89 c7                	mov    %eax,%edi
  802323:	89 f0                	mov    %esi,%eax
  802325:	f7 f1                	div    %ecx
  802327:	89 c6                	mov    %eax,%esi
  802329:	89 f0                	mov    %esi,%eax
  80232b:	89 fa                	mov    %edi,%edx
  80232d:	83 c4 10             	add    $0x10,%esp
  802330:	5e                   	pop    %esi
  802331:	5f                   	pop    %edi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    
  802334:	39 f8                	cmp    %edi,%eax
  802336:	77 2c                	ja     802364 <__udivdi3+0x7c>
  802338:	0f bd f0             	bsr    %eax,%esi
  80233b:	83 f6 1f             	xor    $0x1f,%esi
  80233e:	75 4c                	jne    80238c <__udivdi3+0xa4>
  802340:	39 f8                	cmp    %edi,%eax
  802342:	bf 00 00 00 00       	mov    $0x0,%edi
  802347:	72 0a                	jb     802353 <__udivdi3+0x6b>
  802349:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80234d:	0f 87 ad 00 00 00    	ja     802400 <__udivdi3+0x118>
  802353:	be 01 00 00 00       	mov    $0x1,%esi
  802358:	89 f0                	mov    %esi,%eax
  80235a:	89 fa                	mov    %edi,%edx
  80235c:	83 c4 10             	add    $0x10,%esp
  80235f:	5e                   	pop    %esi
  802360:	5f                   	pop    %edi
  802361:	5d                   	pop    %ebp
  802362:	c3                   	ret    
  802363:	90                   	nop
  802364:	31 ff                	xor    %edi,%edi
  802366:	31 f6                	xor    %esi,%esi
  802368:	89 f0                	mov    %esi,%eax
  80236a:	89 fa                	mov    %edi,%edx
  80236c:	83 c4 10             	add    $0x10,%esp
  80236f:	5e                   	pop    %esi
  802370:	5f                   	pop    %edi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    
  802373:	90                   	nop
  802374:	89 fa                	mov    %edi,%edx
  802376:	89 f0                	mov    %esi,%eax
  802378:	f7 f1                	div    %ecx
  80237a:	89 c6                	mov    %eax,%esi
  80237c:	31 ff                	xor    %edi,%edi
  80237e:	89 f0                	mov    %esi,%eax
  802380:	89 fa                	mov    %edi,%edx
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d 76 00             	lea    0x0(%esi),%esi
  80238c:	89 f1                	mov    %esi,%ecx
  80238e:	d3 e0                	shl    %cl,%eax
  802390:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802394:	b8 20 00 00 00       	mov    $0x20,%eax
  802399:	29 f0                	sub    %esi,%eax
  80239b:	89 ea                	mov    %ebp,%edx
  80239d:	88 c1                	mov    %al,%cl
  80239f:	d3 ea                	shr    %cl,%edx
  8023a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023a5:	09 ca                	or     %ecx,%edx
  8023a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023ab:	89 f1                	mov    %esi,%ecx
  8023ad:	d3 e5                	shl    %cl,%ebp
  8023af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8023b3:	89 fd                	mov    %edi,%ebp
  8023b5:	88 c1                	mov    %al,%cl
  8023b7:	d3 ed                	shr    %cl,%ebp
  8023b9:	89 fa                	mov    %edi,%edx
  8023bb:	89 f1                	mov    %esi,%ecx
  8023bd:	d3 e2                	shl    %cl,%edx
  8023bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023c3:	88 c1                	mov    %al,%cl
  8023c5:	d3 ef                	shr    %cl,%edi
  8023c7:	09 d7                	or     %edx,%edi
  8023c9:	89 f8                	mov    %edi,%eax
  8023cb:	89 ea                	mov    %ebp,%edx
  8023cd:	f7 74 24 08          	divl   0x8(%esp)
  8023d1:	89 d1                	mov    %edx,%ecx
  8023d3:	89 c7                	mov    %eax,%edi
  8023d5:	f7 64 24 0c          	mull   0xc(%esp)
  8023d9:	39 d1                	cmp    %edx,%ecx
  8023db:	72 17                	jb     8023f4 <__udivdi3+0x10c>
  8023dd:	74 09                	je     8023e8 <__udivdi3+0x100>
  8023df:	89 fe                	mov    %edi,%esi
  8023e1:	31 ff                	xor    %edi,%edi
  8023e3:	e9 41 ff ff ff       	jmp    802329 <__udivdi3+0x41>
  8023e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023ec:	89 f1                	mov    %esi,%ecx
  8023ee:	d3 e2                	shl    %cl,%edx
  8023f0:	39 c2                	cmp    %eax,%edx
  8023f2:	73 eb                	jae    8023df <__udivdi3+0xf7>
  8023f4:	8d 77 ff             	lea    -0x1(%edi),%esi
  8023f7:	31 ff                	xor    %edi,%edi
  8023f9:	e9 2b ff ff ff       	jmp    802329 <__udivdi3+0x41>
  8023fe:	66 90                	xchg   %ax,%ax
  802400:	31 f6                	xor    %esi,%esi
  802402:	e9 22 ff ff ff       	jmp    802329 <__udivdi3+0x41>
	...

00802408 <__umoddi3>:
  802408:	55                   	push   %ebp
  802409:	57                   	push   %edi
  80240a:	56                   	push   %esi
  80240b:	83 ec 20             	sub    $0x20,%esp
  80240e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802412:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802416:	89 44 24 14          	mov    %eax,0x14(%esp)
  80241a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80241e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802422:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802426:	89 c7                	mov    %eax,%edi
  802428:	89 f2                	mov    %esi,%edx
  80242a:	85 ed                	test   %ebp,%ebp
  80242c:	75 16                	jne    802444 <__umoddi3+0x3c>
  80242e:	39 f1                	cmp    %esi,%ecx
  802430:	0f 86 a6 00 00 00    	jbe    8024dc <__umoddi3+0xd4>
  802436:	f7 f1                	div    %ecx
  802438:	89 d0                	mov    %edx,%eax
  80243a:	31 d2                	xor    %edx,%edx
  80243c:	83 c4 20             	add    $0x20,%esp
  80243f:	5e                   	pop    %esi
  802440:	5f                   	pop    %edi
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    
  802443:	90                   	nop
  802444:	39 f5                	cmp    %esi,%ebp
  802446:	0f 87 ac 00 00 00    	ja     8024f8 <__umoddi3+0xf0>
  80244c:	0f bd c5             	bsr    %ebp,%eax
  80244f:	83 f0 1f             	xor    $0x1f,%eax
  802452:	89 44 24 10          	mov    %eax,0x10(%esp)
  802456:	0f 84 a8 00 00 00    	je     802504 <__umoddi3+0xfc>
  80245c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802460:	d3 e5                	shl    %cl,%ebp
  802462:	bf 20 00 00 00       	mov    $0x20,%edi
  802467:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80246b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80246f:	89 f9                	mov    %edi,%ecx
  802471:	d3 e8                	shr    %cl,%eax
  802473:	09 e8                	or     %ebp,%eax
  802475:	89 44 24 18          	mov    %eax,0x18(%esp)
  802479:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80247d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802481:	d3 e0                	shl    %cl,%eax
  802483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802487:	89 f2                	mov    %esi,%edx
  802489:	d3 e2                	shl    %cl,%edx
  80248b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80248f:	d3 e0                	shl    %cl,%eax
  802491:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802495:	8b 44 24 14          	mov    0x14(%esp),%eax
  802499:	89 f9                	mov    %edi,%ecx
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	09 d0                	or     %edx,%eax
  80249f:	d3 ee                	shr    %cl,%esi
  8024a1:	89 f2                	mov    %esi,%edx
  8024a3:	f7 74 24 18          	divl   0x18(%esp)
  8024a7:	89 d6                	mov    %edx,%esi
  8024a9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ad:	89 c5                	mov    %eax,%ebp
  8024af:	89 d1                	mov    %edx,%ecx
  8024b1:	39 d6                	cmp    %edx,%esi
  8024b3:	72 67                	jb     80251c <__umoddi3+0x114>
  8024b5:	74 75                	je     80252c <__umoddi3+0x124>
  8024b7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024bb:	29 e8                	sub    %ebp,%eax
  8024bd:	19 ce                	sbb    %ecx,%esi
  8024bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024c3:	d3 e8                	shr    %cl,%eax
  8024c5:	89 f2                	mov    %esi,%edx
  8024c7:	89 f9                	mov    %edi,%ecx
  8024c9:	d3 e2                	shl    %cl,%edx
  8024cb:	09 d0                	or     %edx,%eax
  8024cd:	89 f2                	mov    %esi,%edx
  8024cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024d3:	d3 ea                	shr    %cl,%edx
  8024d5:	83 c4 20             	add    $0x20,%esp
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	85 c9                	test   %ecx,%ecx
  8024de:	75 0b                	jne    8024eb <__umoddi3+0xe3>
  8024e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e5:	31 d2                	xor    %edx,%edx
  8024e7:	f7 f1                	div    %ecx
  8024e9:	89 c1                	mov    %eax,%ecx
  8024eb:	89 f0                	mov    %esi,%eax
  8024ed:	31 d2                	xor    %edx,%edx
  8024ef:	f7 f1                	div    %ecx
  8024f1:	89 f8                	mov    %edi,%eax
  8024f3:	e9 3e ff ff ff       	jmp    802436 <__umoddi3+0x2e>
  8024f8:	89 f2                	mov    %esi,%edx
  8024fa:	83 c4 20             	add    $0x20,%esp
  8024fd:	5e                   	pop    %esi
  8024fe:	5f                   	pop    %edi
  8024ff:	5d                   	pop    %ebp
  802500:	c3                   	ret    
  802501:	8d 76 00             	lea    0x0(%esi),%esi
  802504:	39 f5                	cmp    %esi,%ebp
  802506:	72 04                	jb     80250c <__umoddi3+0x104>
  802508:	39 f9                	cmp    %edi,%ecx
  80250a:	77 06                	ja     802512 <__umoddi3+0x10a>
  80250c:	89 f2                	mov    %esi,%edx
  80250e:	29 cf                	sub    %ecx,%edi
  802510:	19 ea                	sbb    %ebp,%edx
  802512:	89 f8                	mov    %edi,%eax
  802514:	83 c4 20             	add    $0x20,%esp
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	5d                   	pop    %ebp
  80251a:	c3                   	ret    
  80251b:	90                   	nop
  80251c:	89 d1                	mov    %edx,%ecx
  80251e:	89 c5                	mov    %eax,%ebp
  802520:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802524:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802528:	eb 8d                	jmp    8024b7 <__umoddi3+0xaf>
  80252a:	66 90                	xchg   %ax,%ax
  80252c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802530:	72 ea                	jb     80251c <__umoddi3+0x114>
  802532:	89 f1                	mov    %esi,%ecx
  802534:	eb 81                	jmp    8024b7 <__umoddi3+0xaf>
