
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 8b 01 00 00       	call   8001bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  80003a:	a1 00 40 80 00       	mov    0x804000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80004a:	e8 80 08 00 00       	call   8008cf <strcpy>
	exit();
  80004f:	e8 bc 01 00 00       	call   800210 <exit>
}
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	53                   	push   %ebx
  80005a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (argc != 0)
  80005d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800061:	74 05                	je     800068 <umain+0x12>
		childofspawn();
  800063:	e8 cc ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800068:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006f:	00 
  800070:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800077:	a0 
  800078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007f:	e8 3d 0c 00 00       	call   800cc1 <sys_page_alloc>
  800084:	85 c0                	test   %eax,%eax
  800086:	79 20                	jns    8000a8 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800088:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008c:	c7 44 24 08 cc 2a 80 	movl   $0x802acc,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009b:	00 
  80009c:	c7 04 24 df 2a 80 00 	movl   $0x802adf,(%esp)
  8000a3:	e8 84 01 00 00       	call   80022c <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a8:	e8 a6 0f 00 00       	call   801053 <fork>
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	79 20                	jns    8000d3 <umain+0x7d>
		panic("fork: %e", r);
  8000b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b7:	c7 44 24 08 f3 2a 80 	movl   $0x802af3,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 df 2a 80 00 	movl   $0x802adf,(%esp)
  8000ce:	e8 59 01 00 00       	call   80022c <_panic>
	if (r == 0) {
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	75 1a                	jne    8000f1 <umain+0x9b>
		strcpy(VA, msg);
  8000d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e7:	e8 e3 07 00 00       	call   8008cf <strcpy>
		exit();
  8000ec:	e8 1f 01 00 00       	call   800210 <exit>
	}
	wait(r);
  8000f1:	89 1c 24             	mov    %ebx,(%esp)
  8000f4:	e8 7f 23 00 00       	call   802478 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800109:	e8 68 08 00 00       	call   800976 <strcmp>
  80010e:	85 c0                	test   %eax,%eax
  800110:	75 07                	jne    800119 <umain+0xc3>
  800112:	b8 c0 2a 80 00       	mov    $0x802ac0,%eax
  800117:	eb 05                	jmp    80011e <umain+0xc8>
  800119:	b8 c6 2a 80 00       	mov    $0x802ac6,%eax
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  800129:	e8 f6 01 00 00       	call   800324 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800135:	00 
  800136:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 1c 2b 80 	movl   $0x802b1c,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 1b 2b 80 00 	movl   $0x802b1b,(%esp)
  80014d:	e8 3e 1f 00 00       	call   802090 <spawnl>
  800152:	85 c0                	test   %eax,%eax
  800154:	79 20                	jns    800176 <umain+0x120>
		panic("spawn: %e", r);
  800156:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015a:	c7 44 24 08 29 2b 80 	movl   $0x802b29,0x8(%esp)
  800161:	00 
  800162:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800169:	00 
  80016a:	c7 04 24 df 2a 80 00 	movl   $0x802adf,(%esp)
  800171:	e8 b6 00 00 00       	call   80022c <_panic>
	wait(r);
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 fa 22 00 00       	call   802478 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017e:	a1 00 40 80 00       	mov    0x804000,%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018e:	e8 e3 07 00 00       	call   800976 <strcmp>
  800193:	85 c0                	test   %eax,%eax
  800195:	75 07                	jne    80019e <umain+0x148>
  800197:	b8 c0 2a 80 00       	mov    $0x802ac0,%eax
  80019c:	eb 05                	jmp    8001a3 <umain+0x14d>
  80019e:	b8 c6 2a 80 00       	mov    $0x802ac6,%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	c7 04 24 33 2b 80 00 	movl   $0x802b33,(%esp)
  8001ae:	e8 71 01 00 00       	call   800324 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001b3:	cc                   	int3   

	breakpoint();
}
  8001b4:	83 c4 14             	add    $0x14,%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5d                   	pop    %ebp
  8001b9:	c3                   	ret    
	...

008001bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 10             	sub    $0x10,%esp
  8001c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8001ca:	e8 b4 0a 00 00       	call   800c83 <sys_getenvid>
  8001cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001db:	c1 e0 07             	shl    $0x7,%eax
  8001de:	29 d0                	sub    %edx,%eax
  8001e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e5:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ea:	85 f6                	test   %esi,%esi
  8001ec:	7e 07                	jle    8001f5 <libmain+0x39>
		binaryname = argv[0];
  8001ee:	8b 03                	mov    (%ebx),%eax
  8001f0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f9:	89 34 24             	mov    %esi,(%esp)
  8001fc:	e8 55 fe ff ff       	call   800056 <umain>

	// exit gracefully
	exit();
  800201:	e8 0a 00 00 00       	call   800210 <exit>
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5d                   	pop    %ebp
  80020c:	c3                   	ret    
  80020d:	00 00                	add    %al,(%eax)
	...

00800210 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800216:	e8 a0 12 00 00       	call   8014bb <close_all>
	sys_env_destroy(0);
  80021b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800222:	e8 0a 0a 00 00       	call   800c31 <sys_env_destroy>
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    
  800229:	00 00                	add    %al,(%eax)
	...

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800234:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800237:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80023d:	e8 41 0a 00 00       	call   800c83 <sys_getenvid>
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 54 24 10          	mov    %edx,0x10(%esp)
  800249:	8b 55 08             	mov    0x8(%ebp),%edx
  80024c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800250:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	c7 04 24 78 2b 80 00 	movl   $0x802b78,(%esp)
  80025f:	e8 c0 00 00 00       	call   800324 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800264:	89 74 24 04          	mov    %esi,0x4(%esp)
  800268:	8b 45 10             	mov    0x10(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 50 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  800273:	c7 04 24 5c 31 80 00 	movl   $0x80315c,(%esp)
  80027a:	e8 a5 00 00 00       	call   800324 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027f:	cc                   	int3   
  800280:	eb fd                	jmp    80027f <_panic+0x53>
	...

00800284 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	53                   	push   %ebx
  800288:	83 ec 14             	sub    $0x14,%esp
  80028b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028e:	8b 03                	mov    (%ebx),%eax
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800297:	40                   	inc    %eax
  800298:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029f:	75 19                	jne    8002ba <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002a8:	00 
  8002a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	e8 40 09 00 00       	call   800bf4 <sys_cputs>
		b->idx = 0;
  8002b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002ba:	ff 43 04             	incl   0x4(%ebx)
}
  8002bd:	83 c4 14             	add    $0x14,%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	c7 04 24 84 02 80 00 	movl   $0x800284,(%esp)
  8002ff:	e8 82 01 00 00       	call   800486 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800304:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	e8 d8 08 00 00       	call   800bf4 <sys_cputs>

	return b.cnt;
}
  80031c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 87 ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    
	...

00800340 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 3c             	sub    $0x3c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d7                	mov    %edx,%edi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800360:	85 c0                	test   %eax,%eax
  800362:	75 08                	jne    80036c <printnum+0x2c>
  800364:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800367:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036a:	77 57                	ja     8003c3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800370:	4b                   	dec    %ebx
  800371:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800375:	8b 45 10             	mov    0x10(%ebp),%eax
  800378:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800380:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800384:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038b:	00 
  80038c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	e8 b6 24 00 00       	call   802854 <__udivdi3>
  80039e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ad:	89 fa                	mov    %edi,%edx
  8003af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b2:	e8 89 ff ff ff       	call   800340 <printnum>
  8003b7:	eb 0f                	jmp    8003c8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003bd:	89 34 24             	mov    %esi,(%esp)
  8003c0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c3:	4b                   	dec    %ebx
  8003c4:	85 db                	test   %ebx,%ebx
  8003c6:	7f f1                	jg     8003b9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003cc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003de:	00 
  8003df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e2:	89 04 24             	mov    %eax,(%esp)
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ec:	e8 83 25 00 00       	call   802974 <__umoddi3>
  8003f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f5:	0f be 80 9b 2b 80 00 	movsbl 0x802b9b(%eax),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800402:	83 c4 3c             	add    $0x3c,%esp
  800405:	5b                   	pop    %ebx
  800406:	5e                   	pop    %esi
  800407:	5f                   	pop    %edi
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80040d:	83 fa 01             	cmp    $0x1,%edx
  800410:	7e 0e                	jle    800420 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800412:	8b 10                	mov    (%eax),%edx
  800414:	8d 4a 08             	lea    0x8(%edx),%ecx
  800417:	89 08                	mov    %ecx,(%eax)
  800419:	8b 02                	mov    (%edx),%eax
  80041b:	8b 52 04             	mov    0x4(%edx),%edx
  80041e:	eb 22                	jmp    800442 <getuint+0x38>
	else if (lflag)
  800420:	85 d2                	test   %edx,%edx
  800422:	74 10                	je     800434 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800424:	8b 10                	mov    (%eax),%edx
  800426:	8d 4a 04             	lea    0x4(%edx),%ecx
  800429:	89 08                	mov    %ecx,(%eax)
  80042b:	8b 02                	mov    (%edx),%eax
  80042d:	ba 00 00 00 00       	mov    $0x0,%edx
  800432:	eb 0e                	jmp    800442 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 4a 04             	lea    0x4(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80044d:	8b 10                	mov    (%eax),%edx
  80044f:	3b 50 04             	cmp    0x4(%eax),%edx
  800452:	73 08                	jae    80045c <sprintputch+0x18>
		*b->buf++ = ch;
  800454:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800457:	88 0a                	mov    %cl,(%edx)
  800459:	42                   	inc    %edx
  80045a:	89 10                	mov    %edx,(%eax)
}
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    

0080045e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800464:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800467:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046b:	8b 45 10             	mov    0x10(%ebp),%eax
  80046e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	89 44 24 04          	mov    %eax,0x4(%esp)
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 02 00 00 00       	call   800486 <vprintfmt>
	va_end(ap);
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	57                   	push   %edi
  80048a:	56                   	push   %esi
  80048b:	53                   	push   %ebx
  80048c:	83 ec 4c             	sub    $0x4c,%esp
  80048f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800492:	8b 75 10             	mov    0x10(%ebp),%esi
  800495:	eb 12                	jmp    8004a9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800497:	85 c0                	test   %eax,%eax
  800499:	0f 84 6b 03 00 00    	je     80080a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80049f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a9:	0f b6 06             	movzbl (%esi),%eax
  8004ac:	46                   	inc    %esi
  8004ad:	83 f8 25             	cmp    $0x25,%eax
  8004b0:	75 e5                	jne    800497 <vprintfmt+0x11>
  8004b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ce:	eb 26                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004d7:	eb 1d                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004dc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e0:	eb 14                	jmp    8004f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004ec:	eb 08                	jmp    8004f6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ee:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	0f b6 06             	movzbl (%esi),%eax
  8004f9:	8d 56 01             	lea    0x1(%esi),%edx
  8004fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ff:	8a 16                	mov    (%esi),%dl
  800501:	83 ea 23             	sub    $0x23,%edx
  800504:	80 fa 55             	cmp    $0x55,%dl
  800507:	0f 87 e1 02 00 00    	ja     8007ee <vprintfmt+0x368>
  80050d:	0f b6 d2             	movzbl %dl,%edx
  800510:	ff 24 95 e0 2c 80 00 	jmp    *0x802ce0(,%edx,4)
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80051f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800522:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800526:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800529:	8d 50 d0             	lea    -0x30(%eax),%edx
  80052c:	83 fa 09             	cmp    $0x9,%edx
  80052f:	77 2a                	ja     80055b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800531:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800532:	eb eb                	jmp    80051f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800542:	eb 17                	jmp    80055b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800548:	78 98                	js     8004e2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054d:	eb a7                	jmp    8004f6 <vprintfmt+0x70>
  80054f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800552:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800559:	eb 9b                	jmp    8004f6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80055b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055f:	79 95                	jns    8004f6 <vprintfmt+0x70>
  800561:	eb 8b                	jmp    8004ee <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800563:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800567:	eb 8d                	jmp    8004f6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 04 24             	mov    %eax,(%esp)
  80057b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800581:	e9 23 ff ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	79 02                	jns    800597 <vprintfmt+0x111>
  800595:	f7 d8                	neg    %eax
  800597:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800599:	83 f8 0f             	cmp    $0xf,%eax
  80059c:	7f 0b                	jg     8005a9 <vprintfmt+0x123>
  80059e:	8b 04 85 40 2e 80 00 	mov    0x802e40(,%eax,4),%eax
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	75 23                	jne    8005cc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ad:	c7 44 24 08 b3 2b 80 	movl   $0x802bb3,0x8(%esp)
  8005b4:	00 
  8005b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	e8 9a fe ff ff       	call   80045e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c7:	e9 dd fe ff ff       	jmp    8004a9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d0:	c7 44 24 08 96 30 80 	movl   $0x803096,0x8(%esp)
  8005d7:	00 
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8005df:	89 14 24             	mov    %edx,(%esp)
  8005e2:	e8 77 fe ff ff       	call   80045e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ea:	e9 ba fe ff ff       	jmp    8004a9 <vprintfmt+0x23>
  8005ef:	89 f9                	mov    %edi,%ecx
  8005f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 30                	mov    (%eax),%esi
  800602:	85 f6                	test   %esi,%esi
  800604:	75 05                	jne    80060b <vprintfmt+0x185>
				p = "(null)";
  800606:	be ac 2b 80 00       	mov    $0x802bac,%esi
			if (width > 0 && padc != '-')
  80060b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060f:	0f 8e 84 00 00 00    	jle    800699 <vprintfmt+0x213>
  800615:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800619:	74 7e                	je     800699 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80061f:	89 34 24             	mov    %esi,(%esp)
  800622:	e8 8b 02 00 00       	call   8008b2 <strnlen>
  800627:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062a:	29 c2                	sub    %eax,%edx
  80062c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80062f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800633:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800636:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800639:	89 de                	mov    %ebx,%esi
  80063b:	89 d3                	mov    %edx,%ebx
  80063d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063f:	eb 0b                	jmp    80064c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800641:	89 74 24 04          	mov    %esi,0x4(%esp)
  800645:	89 3c 24             	mov    %edi,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064b:	4b                   	dec    %ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f f1                	jg     800641 <vprintfmt+0x1bb>
  800650:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800653:	89 f3                	mov    %esi,%ebx
  800655:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065b:	85 c0                	test   %eax,%eax
  80065d:	79 05                	jns    800664 <vprintfmt+0x1de>
  80065f:	b8 00 00 00 00       	mov    $0x0,%eax
  800664:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800667:	29 c2                	sub    %eax,%edx
  800669:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80066c:	eb 2b                	jmp    800699 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800672:	74 18                	je     80068c <vprintfmt+0x206>
  800674:	8d 50 e0             	lea    -0x20(%eax),%edx
  800677:	83 fa 5e             	cmp    $0x5e,%edx
  80067a:	76 10                	jbe    80068c <vprintfmt+0x206>
					putch('?', putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
  80068a:	eb 0a                	jmp    800696 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800696:	ff 4d e4             	decl   -0x1c(%ebp)
  800699:	0f be 06             	movsbl (%esi),%eax
  80069c:	46                   	inc    %esi
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 21                	je     8006c2 <vprintfmt+0x23c>
  8006a1:	85 ff                	test   %edi,%edi
  8006a3:	78 c9                	js     80066e <vprintfmt+0x1e8>
  8006a5:	4f                   	dec    %edi
  8006a6:	79 c6                	jns    80066e <vprintfmt+0x1e8>
  8006a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ab:	89 de                	mov    %ebx,%esi
  8006ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b0:	eb 18                	jmp    8006ca <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006bd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bf:	4b                   	dec    %ebx
  8006c0:	eb 08                	jmp    8006ca <vprintfmt+0x244>
  8006c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c5:	89 de                	mov    %ebx,%esi
  8006c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ca:	85 db                	test   %ebx,%ebx
  8006cc:	7f e4                	jg     8006b2 <vprintfmt+0x22c>
  8006ce:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d6:	e9 ce fd ff ff       	jmp    8004a9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 f9 01             	cmp    $0x1,%ecx
  8006de:	7e 10                	jle    8006f0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 08             	lea    0x8(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 30                	mov    (%eax),%esi
  8006eb:	8b 78 04             	mov    0x4(%eax),%edi
  8006ee:	eb 26                	jmp    800716 <vprintfmt+0x290>
	else if (lflag)
  8006f0:	85 c9                	test   %ecx,%ecx
  8006f2:	74 12                	je     800706 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 30                	mov    (%eax),%esi
  8006ff:	89 f7                	mov    %esi,%edi
  800701:	c1 ff 1f             	sar    $0x1f,%edi
  800704:	eb 10                	jmp    800716 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 30                	mov    (%eax),%esi
  800711:	89 f7                	mov    %esi,%edi
  800713:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800716:	85 ff                	test   %edi,%edi
  800718:	78 0a                	js     800724 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071f:	e9 8c 00 00 00       	jmp    8007b0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800732:	f7 de                	neg    %esi
  800734:	83 d7 00             	adc    $0x0,%edi
  800737:	f7 df                	neg    %edi
			}
			base = 10;
  800739:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073e:	eb 70                	jmp    8007b0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800740:	89 ca                	mov    %ecx,%edx
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
  800745:	e8 c0 fc ff ff       	call   80040a <getuint>
  80074a:	89 c6                	mov    %eax,%esi
  80074c:	89 d7                	mov    %edx,%edi
			base = 10;
  80074e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800753:	eb 5b                	jmp    8007b0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800755:	89 ca                	mov    %ecx,%edx
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	e8 ab fc ff ff       	call   80040a <getuint>
  80075f:	89 c6                	mov    %eax,%esi
  800761:	89 d7                	mov    %edx,%edi
			base = 8;
  800763:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800768:	eb 46                	jmp    8007b0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800775:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 50 04             	lea    0x4(%eax),%edx
  80078c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078f:	8b 30                	mov    (%eax),%esi
  800791:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800796:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80079b:	eb 13                	jmp    8007b0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079d:	89 ca                	mov    %ecx,%edx
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a2:	e8 63 fc ff ff       	call   80040a <getuint>
  8007a7:	89 c6                	mov    %eax,%esi
  8007a9:	89 d7                	mov    %edx,%edi
			base = 16;
  8007ab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007b4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c3:	89 34 24             	mov    %esi,(%esp)
  8007c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ca:	89 da                	mov    %ebx,%edx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	e8 6c fb ff ff       	call   800340 <printnum>
			break;
  8007d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d7:	e9 cd fc ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e9:	e9 bb fc ff ff       	jmp    8004a9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fc:	eb 01                	jmp    8007ff <vprintfmt+0x379>
  8007fe:	4e                   	dec    %esi
  8007ff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800803:	75 f9                	jne    8007fe <vprintfmt+0x378>
  800805:	e9 9f fc ff ff       	jmp    8004a9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80080a:	83 c4 4c             	add    $0x4c,%esp
  80080d:	5b                   	pop    %ebx
  80080e:	5e                   	pop    %esi
  80080f:	5f                   	pop    %edi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 28             	sub    $0x28,%esp
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800821:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800825:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800828:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082f:	85 c0                	test   %eax,%eax
  800831:	74 30                	je     800863 <vsnprintf+0x51>
  800833:	85 d2                	test   %edx,%edx
  800835:	7e 33                	jle    80086a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083e:	8b 45 10             	mov    0x10(%ebp),%eax
  800841:	89 44 24 08          	mov    %eax,0x8(%esp)
  800845:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084c:	c7 04 24 44 04 80 00 	movl   $0x800444,(%esp)
  800853:	e8 2e fc ff ff       	call   800486 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	eb 0c                	jmp    80086f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800863:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800868:	eb 05                	jmp    80086f <vsnprintf+0x5d>
  80086a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800877:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087e:	8b 45 10             	mov    0x10(%ebp),%eax
  800881:	89 44 24 08          	mov    %eax,0x8(%esp)
  800885:	8b 45 0c             	mov    0xc(%ebp),%eax
  800888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	89 04 24             	mov    %eax,(%esp)
  800892:	e8 7b ff ff ff       	call   800812 <vsnprintf>
	va_end(ap);

	return rc;
}
  800897:	c9                   	leave  
  800898:	c3                   	ret    
  800899:	00 00                	add    %al,(%eax)
	...

0080089c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a7:	eb 01                	jmp    8008aa <strlen+0xe>
		n++;
  8008a9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ae:	75 f9                	jne    8008a9 <strlen+0xd>
		n++;
	return n;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	eb 01                	jmp    8008c3 <strnlen+0x11>
		n++;
  8008c2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c3:	39 d0                	cmp    %edx,%eax
  8008c5:	74 06                	je     8008cd <strnlen+0x1b>
  8008c7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cb:	75 f5                	jne    8008c2 <strnlen+0x10>
		n++;
	return n;
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008e1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e4:	42                   	inc    %edx
  8008e5:	84 c9                	test   %cl,%cl
  8008e7:	75 f5                	jne    8008de <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 9e ff ff ff       	call   80089c <strlen>
	strcpy(dst + len, src);
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	89 54 24 04          	mov    %edx,0x4(%esp)
  800905:	01 d8                	add    %ebx,%eax
  800907:	89 04 24             	mov    %eax,(%esp)
  80090a:	e8 c0 ff ff ff       	call   8008cf <strcpy>
	return dst;
}
  80090f:	89 d8                	mov    %ebx,%eax
  800911:	83 c4 08             	add    $0x8,%esp
  800914:	5b                   	pop    %ebx
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800922:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800925:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092a:	eb 0c                	jmp    800938 <strncpy+0x21>
		*dst++ = *src;
  80092c:	8a 1a                	mov    (%edx),%bl
  80092e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800931:	80 3a 01             	cmpb   $0x1,(%edx)
  800934:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800937:	41                   	inc    %ecx
  800938:	39 f1                	cmp    %esi,%ecx
  80093a:	75 f0                	jne    80092c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 75 08             	mov    0x8(%ebp),%esi
  800948:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094e:	85 d2                	test   %edx,%edx
  800950:	75 0a                	jne    80095c <strlcpy+0x1c>
  800952:	89 f0                	mov    %esi,%eax
  800954:	eb 1a                	jmp    800970 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800956:	88 18                	mov    %bl,(%eax)
  800958:	40                   	inc    %eax
  800959:	41                   	inc    %ecx
  80095a:	eb 02                	jmp    80095e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80095e:	4a                   	dec    %edx
  80095f:	74 0a                	je     80096b <strlcpy+0x2b>
  800961:	8a 19                	mov    (%ecx),%bl
  800963:	84 db                	test   %bl,%bl
  800965:	75 ef                	jne    800956 <strlcpy+0x16>
  800967:	89 c2                	mov    %eax,%edx
  800969:	eb 02                	jmp    80096d <strlcpy+0x2d>
  80096b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80096d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800970:	29 f0                	sub    %esi,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097f:	eb 02                	jmp    800983 <strcmp+0xd>
		p++, q++;
  800981:	41                   	inc    %ecx
  800982:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800983:	8a 01                	mov    (%ecx),%al
  800985:	84 c0                	test   %al,%al
  800987:	74 04                	je     80098d <strcmp+0x17>
  800989:	3a 02                	cmp    (%edx),%al
  80098b:	74 f4                	je     800981 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098d:	0f b6 c0             	movzbl %al,%eax
  800990:	0f b6 12             	movzbl (%edx),%edx
  800993:	29 d0                	sub    %edx,%eax
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009a4:	eb 03                	jmp    8009a9 <strncmp+0x12>
		n--, p++, q++;
  8009a6:	4a                   	dec    %edx
  8009a7:	40                   	inc    %eax
  8009a8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	74 14                	je     8009c1 <strncmp+0x2a>
  8009ad:	8a 18                	mov    (%eax),%bl
  8009af:	84 db                	test   %bl,%bl
  8009b1:	74 04                	je     8009b7 <strncmp+0x20>
  8009b3:	3a 19                	cmp    (%ecx),%bl
  8009b5:	74 ef                	je     8009a6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b7:	0f b6 00             	movzbl (%eax),%eax
  8009ba:	0f b6 11             	movzbl (%ecx),%edx
  8009bd:	29 d0                	sub    %edx,%eax
  8009bf:	eb 05                	jmp    8009c6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009d2:	eb 05                	jmp    8009d9 <strchr+0x10>
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 0c                	je     8009e4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d8:	40                   	inc    %eax
  8009d9:	8a 10                	mov    (%eax),%dl
  8009db:	84 d2                	test   %dl,%dl
  8009dd:	75 f5                	jne    8009d4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ef:	eb 05                	jmp    8009f6 <strfind+0x10>
		if (*s == c)
  8009f1:	38 ca                	cmp    %cl,%dl
  8009f3:	74 07                	je     8009fc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f5:	40                   	inc    %eax
  8009f6:	8a 10                	mov    (%eax),%dl
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 f5                	jne    8009f1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0d:	85 c9                	test   %ecx,%ecx
  800a0f:	74 30                	je     800a41 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a11:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a17:	75 25                	jne    800a3e <memset+0x40>
  800a19:	f6 c1 03             	test   $0x3,%cl
  800a1c:	75 20                	jne    800a3e <memset+0x40>
		c &= 0xFF;
  800a1e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a21:	89 d3                	mov    %edx,%ebx
  800a23:	c1 e3 08             	shl    $0x8,%ebx
  800a26:	89 d6                	mov    %edx,%esi
  800a28:	c1 e6 18             	shl    $0x18,%esi
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	c1 e0 10             	shl    $0x10,%eax
  800a30:	09 f0                	or     %esi,%eax
  800a32:	09 d0                	or     %edx,%eax
  800a34:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a36:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a39:	fc                   	cld    
  800a3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3c:	eb 03                	jmp    800a41 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3e:	fc                   	cld    
  800a3f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a41:	89 f8                	mov    %edi,%eax
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5f                   	pop    %edi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a56:	39 c6                	cmp    %eax,%esi
  800a58:	73 34                	jae    800a8e <memmove+0x46>
  800a5a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5d:	39 d0                	cmp    %edx,%eax
  800a5f:	73 2d                	jae    800a8e <memmove+0x46>
		s += n;
		d += n;
  800a61:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a64:	f6 c2 03             	test   $0x3,%dl
  800a67:	75 1b                	jne    800a84 <memmove+0x3c>
  800a69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6f:	75 13                	jne    800a84 <memmove+0x3c>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 0e                	jne    800a84 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a76:	83 ef 04             	sub    $0x4,%edi
  800a79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a7f:	fd                   	std    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 07                	jmp    800a8b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a84:	4f                   	dec    %edi
  800a85:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a88:	fd                   	std    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8b:	fc                   	cld    
  800a8c:	eb 20                	jmp    800aae <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a94:	75 13                	jne    800aa9 <memmove+0x61>
  800a96:	a8 03                	test   $0x3,%al
  800a98:	75 0f                	jne    800aa9 <memmove+0x61>
  800a9a:	f6 c1 03             	test   $0x3,%cl
  800a9d:	75 0a                	jne    800aa9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb 05                	jmp    800aae <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa9:	89 c7                	mov    %eax,%edi
  800aab:	fc                   	cld    
  800aac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab8:	8b 45 10             	mov    0x10(%ebp),%eax
  800abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	89 04 24             	mov    %eax,(%esp)
  800acc:	e8 77 ff ff ff       	call   800a48 <memmove>
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	eb 16                	jmp    800aff <memcmp+0x2c>
		if (*s1 != *s2)
  800ae9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800aec:	42                   	inc    %edx
  800aed:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800af1:	38 c8                	cmp    %cl,%al
  800af3:	74 0a                	je     800aff <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800af5:	0f b6 c0             	movzbl %al,%eax
  800af8:	0f b6 c9             	movzbl %cl,%ecx
  800afb:	29 c8                	sub    %ecx,%eax
  800afd:	eb 09                	jmp    800b08 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aff:	39 da                	cmp    %ebx,%edx
  800b01:	75 e6                	jne    800ae9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b16:	89 c2                	mov    %eax,%edx
  800b18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1b:	eb 05                	jmp    800b22 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1d:	38 08                	cmp    %cl,(%eax)
  800b1f:	74 05                	je     800b26 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b21:	40                   	inc    %eax
  800b22:	39 d0                	cmp    %edx,%eax
  800b24:	72 f7                	jb     800b1d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b34:	eb 01                	jmp    800b37 <strtol+0xf>
		s++;
  800b36:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b37:	8a 02                	mov    (%edx),%al
  800b39:	3c 20                	cmp    $0x20,%al
  800b3b:	74 f9                	je     800b36 <strtol+0xe>
  800b3d:	3c 09                	cmp    $0x9,%al
  800b3f:	74 f5                	je     800b36 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b41:	3c 2b                	cmp    $0x2b,%al
  800b43:	75 08                	jne    800b4d <strtol+0x25>
		s++;
  800b45:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4b:	eb 13                	jmp    800b60 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4d:	3c 2d                	cmp    $0x2d,%al
  800b4f:	75 0a                	jne    800b5b <strtol+0x33>
		s++, neg = 1;
  800b51:	8d 52 01             	lea    0x1(%edx),%edx
  800b54:	bf 01 00 00 00       	mov    $0x1,%edi
  800b59:	eb 05                	jmp    800b60 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b60:	85 db                	test   %ebx,%ebx
  800b62:	74 05                	je     800b69 <strtol+0x41>
  800b64:	83 fb 10             	cmp    $0x10,%ebx
  800b67:	75 28                	jne    800b91 <strtol+0x69>
  800b69:	8a 02                	mov    (%edx),%al
  800b6b:	3c 30                	cmp    $0x30,%al
  800b6d:	75 10                	jne    800b7f <strtol+0x57>
  800b6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b73:	75 0a                	jne    800b7f <strtol+0x57>
		s += 2, base = 16;
  800b75:	83 c2 02             	add    $0x2,%edx
  800b78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7d:	eb 12                	jmp    800b91 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b7f:	85 db                	test   %ebx,%ebx
  800b81:	75 0e                	jne    800b91 <strtol+0x69>
  800b83:	3c 30                	cmp    $0x30,%al
  800b85:	75 05                	jne    800b8c <strtol+0x64>
		s++, base = 8;
  800b87:	42                   	inc    %edx
  800b88:	b3 08                	mov    $0x8,%bl
  800b8a:	eb 05                	jmp    800b91 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b98:	8a 0a                	mov    (%edx),%cl
  800b9a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b9d:	80 fb 09             	cmp    $0x9,%bl
  800ba0:	77 08                	ja     800baa <strtol+0x82>
			dig = *s - '0';
  800ba2:	0f be c9             	movsbl %cl,%ecx
  800ba5:	83 e9 30             	sub    $0x30,%ecx
  800ba8:	eb 1e                	jmp    800bc8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800baa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 08                	ja     800bba <strtol+0x92>
			dig = *s - 'a' + 10;
  800bb2:	0f be c9             	movsbl %cl,%ecx
  800bb5:	83 e9 57             	sub    $0x57,%ecx
  800bb8:	eb 0e                	jmp    800bc8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bbd:	80 fb 19             	cmp    $0x19,%bl
  800bc0:	77 12                	ja     800bd4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bc2:	0f be c9             	movsbl %cl,%ecx
  800bc5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc8:	39 f1                	cmp    %esi,%ecx
  800bca:	7d 0c                	jge    800bd8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bcc:	42                   	inc    %edx
  800bcd:	0f af c6             	imul   %esi,%eax
  800bd0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bd2:	eb c4                	jmp    800b98 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd4:	89 c1                	mov    %eax,%ecx
  800bd6:	eb 02                	jmp    800bda <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bde:	74 05                	je     800be5 <strtol+0xbd>
		*endptr = (char *) s;
  800be0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be5:	85 ff                	test   %edi,%edi
  800be7:	74 04                	je     800bed <strtol+0xc5>
  800be9:	89 c8                	mov    %ecx,%eax
  800beb:	f7 d8                	neg    %eax
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
	...

00800bf4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 c3                	mov    %eax,%ebx
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	89 c6                	mov    %eax,%esi
  800c0b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c22:	89 d1                	mov    %edx,%ecx
  800c24:	89 d3                	mov    %edx,%ebx
  800c26:	89 d7                	mov    %edx,%edi
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 cb                	mov    %ecx,%ebx
  800c49:	89 cf                	mov    %ecx,%edi
  800c4b:	89 ce                	mov    %ecx,%esi
  800c4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 28                	jle    800c7b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c57:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c5e:	00 
  800c5f:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800c66:	00 
  800c67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6e:	00 
  800c6f:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  800c76:	e8 b1 f5 ff ff       	call   80022c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7b:	83 c4 2c             	add    $0x2c,%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	89 d3                	mov    %edx,%ebx
  800c97:	89 d7                	mov    %edx,%edi
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_yield>:

void
sys_yield(void)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	89 d7                	mov    %edx,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
  800ccf:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 f7                	mov    %esi,%edi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 28                	jle    800d0d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d00:	00 
  800d01:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  800d08:	e8 1f f5 ff ff       	call   80022c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0d:	83 c4 2c             	add    $0x2c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d23:	8b 75 18             	mov    0x18(%ebp),%esi
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 28                	jle    800d60 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d43:	00 
  800d44:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d53:	00 
  800d54:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  800d5b:	e8 cc f4 ff ff       	call   80022c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d60:	83 c4 2c             	add    $0x2c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 28                	jle    800db3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d96:	00 
  800d97:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da6:	00 
  800da7:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  800dae:	e8 79 f4 ff ff       	call   80022c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db3:	83 c4 2c             	add    $0x2c,%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800dc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 df                	mov    %ebx,%edi
  800dd6:	89 de                	mov    %ebx,%esi
  800dd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7e 28                	jle    800e06 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800de9:	00 
  800dea:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800df1:	00 
  800df2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df9:	00 
  800dfa:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  800e01:	e8 26 f4 ff ff       	call   80022c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e06:	83 c4 2c             	add    $0x2c,%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	89 de                	mov    %ebx,%esi
  800e2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 28                	jle    800e59 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e35:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e3c:	00 
  800e3d:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800e44:	00 
  800e45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4c:	00 
  800e4d:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  800e54:	e8 d3 f3 ff ff       	call   80022c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e59:	83 c4 2c             	add    $0x2c,%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 df                	mov    %ebx,%edi
  800e7c:	89 de                	mov    %ebx,%esi
  800e7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 28                	jle    800eac <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e88:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e8f:	00 
  800e90:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800e97:	00 
  800e98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9f:	00 
  800ea0:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  800ea7:	e8 80 f3 ff ff       	call   80022c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eac:	83 c4 2c             	add    $0x2c,%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	be 00 00 00 00       	mov    $0x0,%esi
  800ebf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	89 cb                	mov    %ecx,%ebx
  800eef:	89 cf                	mov    %ecx,%edi
  800ef1:	89 ce                	mov    %ecx,%esi
  800ef3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	7e 28                	jle    800f21 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f04:	00 
  800f05:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  800f1c:	e8 0b f3 ff ff       	call   80022c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f21:	83 c4 2c             	add    $0x2c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	00 00                	add    %al,(%eax)
	...

00800f2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 24             	sub    $0x24,%esp
  800f33:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f36:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800f38:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f3c:	75 2d                	jne    800f6b <pgfault+0x3f>
  800f3e:	89 d8                	mov    %ebx,%eax
  800f40:	c1 e8 0c             	shr    $0xc,%eax
  800f43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4a:	f6 c4 08             	test   $0x8,%ah
  800f4d:	75 1c                	jne    800f6b <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800f4f:	c7 44 24 08 cc 2e 80 	movl   $0x802ecc,0x8(%esp)
  800f56:	00 
  800f57:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800f5e:	00 
  800f5f:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  800f66:	e8 c1 f2 ff ff       	call   80022c <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f6b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f72:	00 
  800f73:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f7a:	00 
  800f7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f82:	e8 3a fd ff ff       	call   800cc1 <sys_page_alloc>
  800f87:	85 c0                	test   %eax,%eax
  800f89:	79 20                	jns    800fab <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800f8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f8f:	c7 44 24 08 cc 2a 80 	movl   $0x802acc,0x8(%esp)
  800f96:	00 
  800f97:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f9e:	00 
  800f9f:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  800fa6:	e8 81 f2 ff ff       	call   80022c <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800fab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800fb1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fb8:	00 
  800fb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fbd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fc4:	e8 e9 fa ff ff       	call   800ab2 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800fc9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fd0:	00 
  800fd1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fd5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fdc:	00 
  800fdd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe4:	00 
  800fe5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fec:	e8 24 fd ff ff       	call   800d15 <sys_page_map>
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	79 20                	jns    801015 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  800ff5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff9:	c7 44 24 08 3b 2f 80 	movl   $0x802f3b,0x8(%esp)
  801000:	00 
  801001:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801008:	00 
  801009:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801010:	e8 17 f2 ff ff       	call   80022c <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801015:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80101c:	00 
  80101d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801024:	e8 3f fd ff ff       	call   800d68 <sys_page_unmap>
  801029:	85 c0                	test   %eax,%eax
  80102b:	79 20                	jns    80104d <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  80102d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801031:	c7 44 24 08 4c 2f 80 	movl   $0x802f4c,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801048:	e8 df f1 ff ff       	call   80022c <_panic>
}
  80104d:	83 c4 24             	add    $0x24,%esp
  801050:	5b                   	pop    %ebx
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  80105c:	c7 04 24 2c 0f 80 00 	movl   $0x800f2c,(%esp)
  801063:	e8 1c 16 00 00       	call   802684 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801068:	ba 07 00 00 00       	mov    $0x7,%edx
  80106d:	89 d0                	mov    %edx,%eax
  80106f:	cd 30                	int    $0x30
  801071:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801074:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	79 1c                	jns    801097 <fork+0x44>
		panic("sys_exofork failed\n");
  80107b:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  801082:	00 
  801083:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80108a:	00 
  80108b:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801092:	e8 95 f1 ff ff       	call   80022c <_panic>
	if(c_envid == 0){
  801097:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80109b:	75 25                	jne    8010c2 <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  80109d:	e8 e1 fb ff ff       	call   800c83 <sys_getenvid>
  8010a2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010ae:	c1 e0 07             	shl    $0x7,%eax
  8010b1:	29 d0                	sub    %edx,%eax
  8010b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b8:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  8010bd:	e9 e3 01 00 00       	jmp    8012a5 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  8010c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  8010c7:	89 d8                	mov    %ebx,%eax
  8010c9:	c1 e8 16             	shr    $0x16,%eax
  8010cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d3:	a8 01                	test   $0x1,%al
  8010d5:	0f 84 0b 01 00 00    	je     8011e6 <fork+0x193>
  8010db:	89 de                	mov    %ebx,%esi
  8010dd:	c1 ee 0c             	shr    $0xc,%esi
  8010e0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e7:	a8 05                	test   $0x5,%al
  8010e9:	0f 84 f7 00 00 00    	je     8011e6 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  8010ef:	89 f7                	mov    %esi,%edi
  8010f1:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  8010f4:	e8 8a fb ff ff       	call   800c83 <sys_getenvid>
  8010f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  8010fc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801103:	a8 02                	test   $0x2,%al
  801105:	75 10                	jne    801117 <fork+0xc4>
  801107:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80110e:	f6 c4 08             	test   $0x8,%ah
  801111:	0f 84 89 00 00 00    	je     8011a0 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  801117:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80111e:	00 
  80111f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801123:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801126:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80112e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801131:	89 04 24             	mov    %eax,(%esp)
  801134:	e8 dc fb ff ff       	call   800d15 <sys_page_map>
  801139:	85 c0                	test   %eax,%eax
  80113b:	79 20                	jns    80115d <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  80113d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801141:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  801148:	00 
  801149:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  801150:	00 
  801151:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801158:	e8 cf f0 ff ff       	call   80022c <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  80115d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801164:	00 
  801165:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801169:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80116c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801170:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801174:	89 04 24             	mov    %eax,(%esp)
  801177:	e8 99 fb ff ff       	call   800d15 <sys_page_map>
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 66                	jns    8011e6 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801184:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  80118b:	00 
  80118c:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801193:	00 
  801194:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  80119b:	e8 8c f0 ff ff       	call   80022c <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  8011a0:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8011a7:	00 
  8011a8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ba:	89 04 24             	mov    %eax,(%esp)
  8011bd:	e8 53 fb ff ff       	call   800d15 <sys_page_map>
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	79 20                	jns    8011e6 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  8011c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ca:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8011d9:	00 
  8011da:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  8011e1:	e8 46 f0 ff ff       	call   80022c <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  8011e6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011ec:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011f2:	0f 85 cf fe ff ff    	jne    8010c7 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  8011f8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011ff:	00 
  801200:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801207:	ee 
  801208:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80120b:	89 04 24             	mov    %eax,(%esp)
  80120e:	e8 ae fa ff ff       	call   800cc1 <sys_page_alloc>
  801213:	85 c0                	test   %eax,%eax
  801215:	79 20                	jns    801237 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  801217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121b:	c7 44 24 08 85 2f 80 	movl   $0x802f85,0x8(%esp)
  801222:	00 
  801223:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80122a:	00 
  80122b:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801232:	e8 f5 ef ff ff       	call   80022c <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801237:	c7 44 24 04 d0 26 80 	movl   $0x8026d0,0x4(%esp)
  80123e:	00 
  80123f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801242:	89 04 24             	mov    %eax,(%esp)
  801245:	e8 17 fc ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
  80124a:	85 c0                	test   %eax,%eax
  80124c:	79 20                	jns    80126e <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80124e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801252:	c7 44 24 08 10 2f 80 	movl   $0x802f10,0x8(%esp)
  801259:	00 
  80125a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801261:	00 
  801262:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801269:	e8 be ef ff ff       	call   80022c <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  80126e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801275:	00 
  801276:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801279:	89 04 24             	mov    %eax,(%esp)
  80127c:	e8 3a fb ff ff       	call   800dbb <sys_env_set_status>
  801281:	85 c0                	test   %eax,%eax
  801283:	79 20                	jns    8012a5 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  801285:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801289:	c7 44 24 08 99 2f 80 	movl   $0x802f99,0x8(%esp)
  801290:	00 
  801291:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801298:	00 
  801299:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  8012a0:	e8 87 ef ff ff       	call   80022c <_panic>
 
	return c_envid;	
}
  8012a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a8:	83 c4 3c             	add    $0x3c,%esp
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5f                   	pop    %edi
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <sfork>:

// Challenge!
int
sfork(void)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012b6:	c7 44 24 08 b1 2f 80 	movl   $0x802fb1,0x8(%esp)
  8012bd:	00 
  8012be:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8012c5:	00 
  8012c6:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  8012cd:	e8 5a ef ff ff       	call   80022c <_panic>
	...

008012d4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012da:	05 00 00 00 30       	add    $0x30000000,%eax
  8012df:	c1 e8 0c             	shr    $0xc,%eax
}
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ed:	89 04 24             	mov    %eax,(%esp)
  8012f0:	e8 df ff ff ff       	call   8012d4 <fd2num>
  8012f5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012fa:	c1 e0 0c             	shl    $0xc,%eax
}
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    

008012ff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801306:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80130b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	c1 ea 16             	shr    $0x16,%edx
  801312:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801319:	f6 c2 01             	test   $0x1,%dl
  80131c:	74 11                	je     80132f <fd_alloc+0x30>
  80131e:	89 c2                	mov    %eax,%edx
  801320:	c1 ea 0c             	shr    $0xc,%edx
  801323:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132a:	f6 c2 01             	test   $0x1,%dl
  80132d:	75 09                	jne    801338 <fd_alloc+0x39>
			*fd_store = fd;
  80132f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	eb 17                	jmp    80134f <fd_alloc+0x50>
  801338:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80133d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801342:	75 c7                	jne    80130b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801344:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80134a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80134f:	5b                   	pop    %ebx
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801358:	83 f8 1f             	cmp    $0x1f,%eax
  80135b:	77 36                	ja     801393 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80135d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801362:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801365:	89 c2                	mov    %eax,%edx
  801367:	c1 ea 16             	shr    $0x16,%edx
  80136a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801371:	f6 c2 01             	test   $0x1,%dl
  801374:	74 24                	je     80139a <fd_lookup+0x48>
  801376:	89 c2                	mov    %eax,%edx
  801378:	c1 ea 0c             	shr    $0xc,%edx
  80137b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801382:	f6 c2 01             	test   $0x1,%dl
  801385:	74 1a                	je     8013a1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801387:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138a:	89 02                	mov    %eax,(%edx)
	return 0;
  80138c:	b8 00 00 00 00       	mov    $0x0,%eax
  801391:	eb 13                	jmp    8013a6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801398:	eb 0c                	jmp    8013a6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80139a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139f:	eb 05                	jmp    8013a6 <fd_lookup+0x54>
  8013a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 14             	sub    $0x14,%esp
  8013af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8013b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ba:	eb 0e                	jmp    8013ca <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8013bc:	39 08                	cmp    %ecx,(%eax)
  8013be:	75 09                	jne    8013c9 <dev_lookup+0x21>
			*dev = devtab[i];
  8013c0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c7:	eb 33                	jmp    8013fc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013c9:	42                   	inc    %edx
  8013ca:	8b 04 95 44 30 80 00 	mov    0x803044(,%edx,4),%eax
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	75 e7                	jne    8013bc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d5:	a1 04 50 80 00       	mov    0x805004,%eax
  8013da:	8b 40 48             	mov    0x48(%eax),%eax
  8013dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e5:	c7 04 24 c8 2f 80 00 	movl   $0x802fc8,(%esp)
  8013ec:	e8 33 ef ff ff       	call   800324 <cprintf>
	*dev = 0;
  8013f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013fc:	83 c4 14             	add    $0x14,%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	83 ec 30             	sub    $0x30,%esp
  80140a:	8b 75 08             	mov    0x8(%ebp),%esi
  80140d:	8a 45 0c             	mov    0xc(%ebp),%al
  801410:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801413:	89 34 24             	mov    %esi,(%esp)
  801416:	e8 b9 fe ff ff       	call   8012d4 <fd2num>
  80141b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80141e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801422:	89 04 24             	mov    %eax,(%esp)
  801425:	e8 28 ff ff ff       	call   801352 <fd_lookup>
  80142a:	89 c3                	mov    %eax,%ebx
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 05                	js     801435 <fd_close+0x33>
	    || fd != fd2)
  801430:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801433:	74 0d                	je     801442 <fd_close+0x40>
		return (must_exist ? r : 0);
  801435:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801439:	75 46                	jne    801481 <fd_close+0x7f>
  80143b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801440:	eb 3f                	jmp    801481 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801442:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801445:	89 44 24 04          	mov    %eax,0x4(%esp)
  801449:	8b 06                	mov    (%esi),%eax
  80144b:	89 04 24             	mov    %eax,(%esp)
  80144e:	e8 55 ff ff ff       	call   8013a8 <dev_lookup>
  801453:	89 c3                	mov    %eax,%ebx
  801455:	85 c0                	test   %eax,%eax
  801457:	78 18                	js     801471 <fd_close+0x6f>
		if (dev->dev_close)
  801459:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145c:	8b 40 10             	mov    0x10(%eax),%eax
  80145f:	85 c0                	test   %eax,%eax
  801461:	74 09                	je     80146c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801463:	89 34 24             	mov    %esi,(%esp)
  801466:	ff d0                	call   *%eax
  801468:	89 c3                	mov    %eax,%ebx
  80146a:	eb 05                	jmp    801471 <fd_close+0x6f>
		else
			r = 0;
  80146c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801471:	89 74 24 04          	mov    %esi,0x4(%esp)
  801475:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80147c:	e8 e7 f8 ff ff       	call   800d68 <sys_page_unmap>
	return r;
}
  801481:	89 d8                	mov    %ebx,%eax
  801483:	83 c4 30             	add    $0x30,%esp
  801486:	5b                   	pop    %ebx
  801487:	5e                   	pop    %esi
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801490:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801493:	89 44 24 04          	mov    %eax,0x4(%esp)
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
  80149a:	89 04 24             	mov    %eax,(%esp)
  80149d:	e8 b0 fe ff ff       	call   801352 <fd_lookup>
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 13                	js     8014b9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014a6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014ad:	00 
  8014ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b1:	89 04 24             	mov    %eax,(%esp)
  8014b4:	e8 49 ff ff ff       	call   801402 <fd_close>
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <close_all>:

void
close_all(void)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014c7:	89 1c 24             	mov    %ebx,(%esp)
  8014ca:	e8 bb ff ff ff       	call   80148a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014cf:	43                   	inc    %ebx
  8014d0:	83 fb 20             	cmp    $0x20,%ebx
  8014d3:	75 f2                	jne    8014c7 <close_all+0xc>
		close(i);
}
  8014d5:	83 c4 14             	add    $0x14,%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	57                   	push   %edi
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 4c             	sub    $0x4c,%esp
  8014e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f1:	89 04 24             	mov    %eax,(%esp)
  8014f4:	e8 59 fe ff ff       	call   801352 <fd_lookup>
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	0f 88 e1 00 00 00    	js     8015e4 <dup+0x109>
		return r;
	close(newfdnum);
  801503:	89 3c 24             	mov    %edi,(%esp)
  801506:	e8 7f ff ff ff       	call   80148a <close>

	newfd = INDEX2FD(newfdnum);
  80150b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801511:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 c5 fd ff ff       	call   8012e4 <fd2data>
  80151f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801521:	89 34 24             	mov    %esi,(%esp)
  801524:	e8 bb fd ff ff       	call   8012e4 <fd2data>
  801529:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80152c:	89 d8                	mov    %ebx,%eax
  80152e:	c1 e8 16             	shr    $0x16,%eax
  801531:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801538:	a8 01                	test   $0x1,%al
  80153a:	74 46                	je     801582 <dup+0xa7>
  80153c:	89 d8                	mov    %ebx,%eax
  80153e:	c1 e8 0c             	shr    $0xc,%eax
  801541:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801548:	f6 c2 01             	test   $0x1,%dl
  80154b:	74 35                	je     801582 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80154d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801554:	25 07 0e 00 00       	and    $0xe07,%eax
  801559:	89 44 24 10          	mov    %eax,0x10(%esp)
  80155d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801560:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801564:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80156b:	00 
  80156c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801577:	e8 99 f7 ff ff       	call   800d15 <sys_page_map>
  80157c:	89 c3                	mov    %eax,%ebx
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 3b                	js     8015bd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801585:	89 c2                	mov    %eax,%edx
  801587:	c1 ea 0c             	shr    $0xc,%edx
  80158a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801591:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801597:	89 54 24 10          	mov    %edx,0x10(%esp)
  80159b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80159f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a6:	00 
  8015a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b2:	e8 5e f7 ff ff       	call   800d15 <sys_page_map>
  8015b7:	89 c3                	mov    %eax,%ebx
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	79 25                	jns    8015e2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c8:	e8 9b f7 ff ff       	call   800d68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015db:	e8 88 f7 ff ff       	call   800d68 <sys_page_unmap>
	return r;
  8015e0:	eb 02                	jmp    8015e4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015e2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015e4:	89 d8                	mov    %ebx,%eax
  8015e6:	83 c4 4c             	add    $0x4c,%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 24             	sub    $0x24,%esp
  8015f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ff:	89 1c 24             	mov    %ebx,(%esp)
  801602:	e8 4b fd ff ff       	call   801352 <fd_lookup>
  801607:	85 c0                	test   %eax,%eax
  801609:	78 6d                	js     801678 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	8b 00                	mov    (%eax),%eax
  801617:	89 04 24             	mov    %eax,(%esp)
  80161a:	e8 89 fd ff ff       	call   8013a8 <dev_lookup>
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 55                	js     801678 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	8b 50 08             	mov    0x8(%eax),%edx
  801629:	83 e2 03             	and    $0x3,%edx
  80162c:	83 fa 01             	cmp    $0x1,%edx
  80162f:	75 23                	jne    801654 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801631:	a1 04 50 80 00       	mov    0x805004,%eax
  801636:	8b 40 48             	mov    0x48(%eax),%eax
  801639:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80163d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801641:	c7 04 24 09 30 80 00 	movl   $0x803009,(%esp)
  801648:	e8 d7 ec ff ff       	call   800324 <cprintf>
		return -E_INVAL;
  80164d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801652:	eb 24                	jmp    801678 <read+0x8a>
	}
	if (!dev->dev_read)
  801654:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801657:	8b 52 08             	mov    0x8(%edx),%edx
  80165a:	85 d2                	test   %edx,%edx
  80165c:	74 15                	je     801673 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80165e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801661:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801665:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801668:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80166c:	89 04 24             	mov    %eax,(%esp)
  80166f:	ff d2                	call   *%edx
  801671:	eb 05                	jmp    801678 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801673:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801678:	83 c4 24             	add    $0x24,%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 1c             	sub    $0x1c,%esp
  801687:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80168d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801692:	eb 23                	jmp    8016b7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801694:	89 f0                	mov    %esi,%eax
  801696:	29 d8                	sub    %ebx,%eax
  801698:	89 44 24 08          	mov    %eax,0x8(%esp)
  80169c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169f:	01 d8                	add    %ebx,%eax
  8016a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a5:	89 3c 24             	mov    %edi,(%esp)
  8016a8:	e8 41 ff ff ff       	call   8015ee <read>
		if (m < 0)
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 10                	js     8016c1 <readn+0x43>
			return m;
		if (m == 0)
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	74 0a                	je     8016bf <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b5:	01 c3                	add    %eax,%ebx
  8016b7:	39 f3                	cmp    %esi,%ebx
  8016b9:	72 d9                	jb     801694 <readn+0x16>
  8016bb:	89 d8                	mov    %ebx,%eax
  8016bd:	eb 02                	jmp    8016c1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016bf:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016c1:	83 c4 1c             	add    $0x1c,%esp
  8016c4:	5b                   	pop    %ebx
  8016c5:	5e                   	pop    %esi
  8016c6:	5f                   	pop    %edi
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 24             	sub    $0x24,%esp
  8016d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016da:	89 1c 24             	mov    %ebx,(%esp)
  8016dd:	e8 70 fc ff ff       	call   801352 <fd_lookup>
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 68                	js     80174e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f0:	8b 00                	mov    (%eax),%eax
  8016f2:	89 04 24             	mov    %eax,(%esp)
  8016f5:	e8 ae fc ff ff       	call   8013a8 <dev_lookup>
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 50                	js     80174e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801705:	75 23                	jne    80172a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801707:	a1 04 50 80 00       	mov    0x805004,%eax
  80170c:	8b 40 48             	mov    0x48(%eax),%eax
  80170f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801713:	89 44 24 04          	mov    %eax,0x4(%esp)
  801717:	c7 04 24 25 30 80 00 	movl   $0x803025,(%esp)
  80171e:	e8 01 ec ff ff       	call   800324 <cprintf>
		return -E_INVAL;
  801723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801728:	eb 24                	jmp    80174e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172d:	8b 52 0c             	mov    0xc(%edx),%edx
  801730:	85 d2                	test   %edx,%edx
  801732:	74 15                	je     801749 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801734:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801737:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80173b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801742:	89 04 24             	mov    %eax,(%esp)
  801745:	ff d2                	call   *%edx
  801747:	eb 05                	jmp    80174e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801749:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80174e:	83 c4 24             	add    $0x24,%esp
  801751:	5b                   	pop    %ebx
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <seek>:

int
seek(int fdnum, off_t offset)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80175d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801761:	8b 45 08             	mov    0x8(%ebp),%eax
  801764:	89 04 24             	mov    %eax,(%esp)
  801767:	e8 e6 fb ff ff       	call   801352 <fd_lookup>
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 0e                	js     80177e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801770:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801773:	8b 55 0c             	mov    0xc(%ebp),%edx
  801776:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	83 ec 24             	sub    $0x24,%esp
  801787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801791:	89 1c 24             	mov    %ebx,(%esp)
  801794:	e8 b9 fb ff ff       	call   801352 <fd_lookup>
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 61                	js     8017fe <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a7:	8b 00                	mov    (%eax),%eax
  8017a9:	89 04 24             	mov    %eax,(%esp)
  8017ac:	e8 f7 fb ff ff       	call   8013a8 <dev_lookup>
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 49                	js     8017fe <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bc:	75 23                	jne    8017e1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017be:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c3:	8b 40 48             	mov    0x48(%eax),%eax
  8017c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ce:	c7 04 24 e8 2f 80 00 	movl   $0x802fe8,(%esp)
  8017d5:	e8 4a eb ff ff       	call   800324 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017df:	eb 1d                	jmp    8017fe <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e4:	8b 52 18             	mov    0x18(%edx),%edx
  8017e7:	85 d2                	test   %edx,%edx
  8017e9:	74 0e                	je     8017f9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	ff d2                	call   *%edx
  8017f7:	eb 05                	jmp    8017fe <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017fe:	83 c4 24             	add    $0x24,%esp
  801801:	5b                   	pop    %ebx
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 24             	sub    $0x24,%esp
  80180b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801811:	89 44 24 04          	mov    %eax,0x4(%esp)
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	e8 32 fb ff ff       	call   801352 <fd_lookup>
  801820:	85 c0                	test   %eax,%eax
  801822:	78 52                	js     801876 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801824:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182e:	8b 00                	mov    (%eax),%eax
  801830:	89 04 24             	mov    %eax,(%esp)
  801833:	e8 70 fb ff ff       	call   8013a8 <dev_lookup>
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 3a                	js     801876 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80183c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801843:	74 2c                	je     801871 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801845:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801848:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80184f:	00 00 00 
	stat->st_isdir = 0;
  801852:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801859:	00 00 00 
	stat->st_dev = dev;
  80185c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801862:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801866:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801869:	89 14 24             	mov    %edx,(%esp)
  80186c:	ff 50 14             	call   *0x14(%eax)
  80186f:	eb 05                	jmp    801876 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801876:	83 c4 24             	add    $0x24,%esp
  801879:	5b                   	pop    %ebx
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801884:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80188b:	00 
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 fe 01 00 00       	call   801a95 <open>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 1b                	js     8018b8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80189d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a4:	89 1c 24             	mov    %ebx,(%esp)
  8018a7:	e8 58 ff ff ff       	call   801804 <fstat>
  8018ac:	89 c6                	mov    %eax,%esi
	close(fd);
  8018ae:	89 1c 24             	mov    %ebx,(%esp)
  8018b1:	e8 d4 fb ff ff       	call   80148a <close>
	return r;
  8018b6:	89 f3                	mov    %esi,%ebx
}
  8018b8:	89 d8                	mov    %ebx,%eax
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	5b                   	pop    %ebx
  8018be:	5e                   	pop    %esi
  8018bf:	5d                   	pop    %ebp
  8018c0:	c3                   	ret    
  8018c1:	00 00                	add    %al,(%eax)
	...

008018c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 10             	sub    $0x10,%esp
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018d0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8018d7:	75 11                	jne    8018ea <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018e0:	e8 e6 0e 00 00       	call   8027cb <ipc_find_env>
  8018e5:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018f1:	00 
  8018f2:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8018f9:	00 
  8018fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018fe:	a1 00 50 80 00       	mov    0x805000,%eax
  801903:	89 04 24             	mov    %eax,(%esp)
  801906:	e8 56 0e 00 00       	call   802761 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80190b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801912:	00 
  801913:	89 74 24 04          	mov    %esi,0x4(%esp)
  801917:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191e:	e8 d5 0d 00 00       	call   8026f8 <ipc_recv>
}
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	8b 40 0c             	mov    0xc(%eax),%eax
  801936:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80193b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801943:	ba 00 00 00 00       	mov    $0x0,%edx
  801948:	b8 02 00 00 00       	mov    $0x2,%eax
  80194d:	e8 72 ff ff ff       	call   8018c4 <fsipc>
}
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
  801960:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801965:	ba 00 00 00 00       	mov    $0x0,%edx
  80196a:	b8 06 00 00 00       	mov    $0x6,%eax
  80196f:	e8 50 ff ff ff       	call   8018c4 <fsipc>
}
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	53                   	push   %ebx
  80197a:	83 ec 14             	sub    $0x14,%esp
  80197d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801980:	8b 45 08             	mov    0x8(%ebp),%eax
  801983:	8b 40 0c             	mov    0xc(%eax),%eax
  801986:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80198b:	ba 00 00 00 00       	mov    $0x0,%edx
  801990:	b8 05 00 00 00       	mov    $0x5,%eax
  801995:	e8 2a ff ff ff       	call   8018c4 <fsipc>
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 2b                	js     8019c9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80199e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8019a5:	00 
  8019a6:	89 1c 24             	mov    %ebx,(%esp)
  8019a9:	e8 21 ef ff ff       	call   8008cf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019ae:	a1 80 60 80 00       	mov    0x806080,%eax
  8019b3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019b9:	a1 84 60 80 00       	mov    0x806084,%eax
  8019be:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c9:	83 c4 14             	add    $0x14,%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5d                   	pop    %ebp
  8019ce:	c3                   	ret    

008019cf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019d5:	c7 44 24 08 54 30 80 	movl   $0x803054,0x8(%esp)
  8019dc:	00 
  8019dd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8019e4:	00 
  8019e5:	c7 04 24 72 30 80 00 	movl   $0x803072,(%esp)
  8019ec:	e8 3b e8 ff ff       	call   80022c <_panic>

008019f1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 10             	sub    $0x10,%esp
  8019f9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801a02:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a07:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a12:	b8 03 00 00 00       	mov    $0x3,%eax
  801a17:	e8 a8 fe ff ff       	call   8018c4 <fsipc>
  801a1c:	89 c3                	mov    %eax,%ebx
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 6a                	js     801a8c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a22:	39 c6                	cmp    %eax,%esi
  801a24:	73 24                	jae    801a4a <devfile_read+0x59>
  801a26:	c7 44 24 0c 7d 30 80 	movl   $0x80307d,0xc(%esp)
  801a2d:	00 
  801a2e:	c7 44 24 08 84 30 80 	movl   $0x803084,0x8(%esp)
  801a35:	00 
  801a36:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a3d:	00 
  801a3e:	c7 04 24 72 30 80 00 	movl   $0x803072,(%esp)
  801a45:	e8 e2 e7 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  801a4a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4f:	7e 24                	jle    801a75 <devfile_read+0x84>
  801a51:	c7 44 24 0c 99 30 80 	movl   $0x803099,0xc(%esp)
  801a58:	00 
  801a59:	c7 44 24 08 84 30 80 	movl   $0x803084,0x8(%esp)
  801a60:	00 
  801a61:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a68:	00 
  801a69:	c7 04 24 72 30 80 00 	movl   $0x803072,(%esp)
  801a70:	e8 b7 e7 ff ff       	call   80022c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a79:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a80:	00 
  801a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a84:	89 04 24             	mov    %eax,(%esp)
  801a87:	e8 bc ef ff ff       	call   800a48 <memmove>
	return r;
}
  801a8c:	89 d8                	mov    %ebx,%eax
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 20             	sub    $0x20,%esp
  801a9d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801aa0:	89 34 24             	mov    %esi,(%esp)
  801aa3:	e8 f4 ed ff ff       	call   80089c <strlen>
  801aa8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aad:	7f 60                	jg     801b0f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab2:	89 04 24             	mov    %eax,(%esp)
  801ab5:	e8 45 f8 ff ff       	call   8012ff <fd_alloc>
  801aba:	89 c3                	mov    %eax,%ebx
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 54                	js     801b14 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ac0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac4:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801acb:	e8 ff ed ff ff       	call   8008cf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad3:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ad8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801adb:	b8 01 00 00 00       	mov    $0x1,%eax
  801ae0:	e8 df fd ff ff       	call   8018c4 <fsipc>
  801ae5:	89 c3                	mov    %eax,%ebx
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	79 15                	jns    801b00 <open+0x6b>
		fd_close(fd, 0);
  801aeb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801af2:	00 
  801af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af6:	89 04 24             	mov    %eax,(%esp)
  801af9:	e8 04 f9 ff ff       	call   801402 <fd_close>
		return r;
  801afe:	eb 14                	jmp    801b14 <open+0x7f>
	}

	return fd2num(fd);
  801b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b03:	89 04 24             	mov    %eax,(%esp)
  801b06:	e8 c9 f7 ff ff       	call   8012d4 <fd2num>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	eb 05                	jmp    801b14 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b0f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b14:	89 d8                	mov    %ebx,%eax
  801b16:	83 c4 20             	add    $0x20,%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b23:	ba 00 00 00 00       	mov    $0x0,%edx
  801b28:	b8 08 00 00 00       	mov    $0x8,%eax
  801b2d:	e8 92 fd ff ff       	call   8018c4 <fsipc>
}
  801b32:	c9                   	leave  
  801b33:	c3                   	ret    

00801b34 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	57                   	push   %edi
  801b38:	56                   	push   %esi
  801b39:	53                   	push   %ebx
  801b3a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801b40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b47:	00 
  801b48:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4b:	89 04 24             	mov    %eax,(%esp)
  801b4e:	e8 42 ff ff ff       	call   801a95 <open>
  801b53:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	0f 88 05 05 00 00    	js     802066 <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801b61:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801b68:	00 
  801b69:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b73:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b79:	89 04 24             	mov    %eax,(%esp)
  801b7c:	e8 fd fa ff ff       	call   80167e <readn>
  801b81:	3d 00 02 00 00       	cmp    $0x200,%eax
  801b86:	75 0c                	jne    801b94 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801b88:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801b8f:	45 4c 46 
  801b92:	74 3b                	je     801bcf <spawn+0x9b>
		close(fd);
  801b94:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b9a:	89 04 24             	mov    %eax,(%esp)
  801b9d:	e8 e8 f8 ff ff       	call   80148a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ba2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801ba9:	46 
  801baa:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb4:	c7 04 24 a5 30 80 00 	movl   $0x8030a5,(%esp)
  801bbb:	e8 64 e7 ff ff       	call   800324 <cprintf>
		return -E_NOT_EXEC;
  801bc0:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801bc7:	ff ff ff 
  801bca:	e9 a3 04 00 00       	jmp    802072 <spawn+0x53e>
  801bcf:	ba 07 00 00 00       	mov    $0x7,%edx
  801bd4:	89 d0                	mov    %edx,%eax
  801bd6:	cd 30                	int    $0x30
  801bd8:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801bde:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801be4:	85 c0                	test   %eax,%eax
  801be6:	0f 88 86 04 00 00    	js     802072 <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801bec:	25 ff 03 00 00       	and    $0x3ff,%eax
  801bf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801bf8:	c1 e0 07             	shl    $0x7,%eax
  801bfb:	29 d0                	sub    %edx,%eax
  801bfd:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801c03:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c09:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c10:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c16:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c1c:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c21:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c26:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c29:	eb 0d                	jmp    801c38 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c2b:	89 04 24             	mov    %eax,(%esp)
  801c2e:	e8 69 ec ff ff       	call   80089c <strlen>
  801c33:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c37:	46                   	inc    %esi
  801c38:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801c3a:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c41:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801c44:	85 c0                	test   %eax,%eax
  801c46:	75 e3                	jne    801c2b <spawn+0xf7>
  801c48:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801c4e:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801c54:	bf 00 10 40 00       	mov    $0x401000,%edi
  801c59:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801c5b:	89 f8                	mov    %edi,%eax
  801c5d:	83 e0 fc             	and    $0xfffffffc,%eax
  801c60:	f7 d2                	not    %edx
  801c62:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801c65:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801c6b:	89 d0                	mov    %edx,%eax
  801c6d:	83 e8 08             	sub    $0x8,%eax
  801c70:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801c75:	0f 86 08 04 00 00    	jbe    802083 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c7b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c82:	00 
  801c83:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c8a:	00 
  801c8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c92:	e8 2a f0 ff ff       	call   800cc1 <sys_page_alloc>
  801c97:	85 c0                	test   %eax,%eax
  801c99:	0f 88 e9 03 00 00    	js     802088 <spawn+0x554>
  801c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca4:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801caa:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cad:	eb 2e                	jmp    801cdd <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801caf:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801cb5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801cbb:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801cbe:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc5:	89 3c 24             	mov    %edi,(%esp)
  801cc8:	e8 02 ec ff ff       	call   8008cf <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ccd:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801cd0:	89 04 24             	mov    %eax,(%esp)
  801cd3:	e8 c4 eb ff ff       	call   80089c <strlen>
  801cd8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801cdc:	43                   	inc    %ebx
  801cdd:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801ce3:	7c ca                	jl     801caf <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ce5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801ceb:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801cf1:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801cf8:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801cfe:	74 24                	je     801d24 <spawn+0x1f0>
  801d00:	c7 44 24 0c 1c 31 80 	movl   $0x80311c,0xc(%esp)
  801d07:	00 
  801d08:	c7 44 24 08 84 30 80 	movl   $0x803084,0x8(%esp)
  801d0f:	00 
  801d10:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801d17:	00 
  801d18:	c7 04 24 bf 30 80 00 	movl   $0x8030bf,(%esp)
  801d1f:	e8 08 e5 ff ff       	call   80022c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d24:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d2a:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d2f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d35:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801d38:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d3e:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d41:	89 d0                	mov    %edx,%eax
  801d43:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801d48:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801d4e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801d55:	00 
  801d56:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801d5d:	ee 
  801d5e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d64:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d68:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d6f:	00 
  801d70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d77:	e8 99 ef ff ff       	call   800d15 <sys_page_map>
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 1a                	js     801d9c <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801d82:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d89:	00 
  801d8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d91:	e8 d2 ef ff ff       	call   800d68 <sys_page_unmap>
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	79 1f                	jns    801dbb <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801d9c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801da3:	00 
  801da4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dab:	e8 b8 ef ff ff       	call   800d68 <sys_page_unmap>
	return r;
  801db0:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801db6:	e9 b7 02 00 00       	jmp    802072 <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801dbb:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801dc1:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801dc7:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801dcd:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801dd4:	00 00 00 
  801dd7:	e9 bb 01 00 00       	jmp    801f97 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801ddc:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801de2:	83 38 01             	cmpl   $0x1,(%eax)
  801de5:	0f 85 9f 01 00 00    	jne    801f8a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801deb:	89 c2                	mov    %eax,%edx
  801ded:	8b 40 18             	mov    0x18(%eax),%eax
  801df0:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801df3:	83 f8 01             	cmp    $0x1,%eax
  801df6:	19 c0                	sbb    %eax,%eax
  801df8:	83 e0 fe             	and    $0xfffffffe,%eax
  801dfb:	83 c0 07             	add    $0x7,%eax
  801dfe:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e04:	8b 52 04             	mov    0x4(%edx),%edx
  801e07:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801e0d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e13:	8b 40 10             	mov    0x10(%eax),%eax
  801e16:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e1c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801e22:	8b 52 14             	mov    0x14(%edx),%edx
  801e25:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801e2b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e31:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e34:	89 f8                	mov    %edi,%eax
  801e36:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e3b:	74 16                	je     801e53 <spawn+0x31f>
		va -= i;
  801e3d:	29 c7                	sub    %eax,%edi
		memsz += i;
  801e3f:	01 c2                	add    %eax,%edx
  801e41:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801e47:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801e4d:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e58:	e9 1f 01 00 00       	jmp    801f7c <spawn+0x448>
		if (i >= filesz) {
  801e5d:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801e63:	77 2b                	ja     801e90 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e65:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801e6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e6f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e73:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e79:	89 04 24             	mov    %eax,(%esp)
  801e7c:	e8 40 ee ff ff       	call   800cc1 <sys_page_alloc>
  801e81:	85 c0                	test   %eax,%eax
  801e83:	0f 89 e7 00 00 00    	jns    801f70 <spawn+0x43c>
  801e89:	89 c6                	mov    %eax,%esi
  801e8b:	e9 b2 01 00 00       	jmp    802042 <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e90:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e97:	00 
  801e98:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e9f:	00 
  801ea0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea7:	e8 15 ee ff ff       	call   800cc1 <sys_page_alloc>
  801eac:	85 c0                	test   %eax,%eax
  801eae:	0f 88 84 01 00 00    	js     802038 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801eb4:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801eba:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ebc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ec6:	89 04 24             	mov    %eax,(%esp)
  801ec9:	e8 86 f8 ff ff       	call   801754 <seek>
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	0f 88 66 01 00 00    	js     80203c <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801ed6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801edc:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ede:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ee3:	76 05                	jbe    801eea <spawn+0x3b6>
  801ee5:	b8 00 10 00 00       	mov    $0x1000,%eax
  801eea:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eee:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ef5:	00 
  801ef6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801efc:	89 04 24             	mov    %eax,(%esp)
  801eff:	e8 7a f7 ff ff       	call   80167e <readn>
  801f04:	85 c0                	test   %eax,%eax
  801f06:	0f 88 34 01 00 00    	js     802040 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f0c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801f12:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f16:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f1a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f20:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f24:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f2b:	00 
  801f2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f33:	e8 dd ed ff ff       	call   800d15 <sys_page_map>
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	79 20                	jns    801f5c <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801f3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f40:	c7 44 24 08 cb 30 80 	movl   $0x8030cb,0x8(%esp)
  801f47:	00 
  801f48:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801f4f:	00 
  801f50:	c7 04 24 bf 30 80 00 	movl   $0x8030bf,(%esp)
  801f57:	e8 d0 e2 ff ff       	call   80022c <_panic>
			sys_page_unmap(0, UTEMP);
  801f5c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f63:	00 
  801f64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6b:	e8 f8 ed ff ff       	call   800d68 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f70:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f76:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801f7c:	89 de                	mov    %ebx,%esi
  801f7e:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801f84:	0f 87 d3 fe ff ff    	ja     801e5d <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f8a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801f90:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801f97:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f9e:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801fa4:	0f 8c 32 fe ff ff    	jl     801ddc <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801faa:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801fb0:	89 04 24             	mov    %eax,(%esp)
  801fb3:	e8 d2 f4 ff ff       	call   80148a <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801fb8:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801fbf:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801fc2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcc:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fd2:	89 04 24             	mov    %eax,(%esp)
  801fd5:	e8 34 ee ff ff       	call   800e0e <sys_env_set_trapframe>
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	79 20                	jns    801ffe <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  801fde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fe2:	c7 44 24 08 e8 30 80 	movl   $0x8030e8,0x8(%esp)
  801fe9:	00 
  801fea:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801ff1:	00 
  801ff2:	c7 04 24 bf 30 80 00 	movl   $0x8030bf,(%esp)
  801ff9:	e8 2e e2 ff ff       	call   80022c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ffe:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802005:	00 
  802006:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80200c:	89 04 24             	mov    %eax,(%esp)
  80200f:	e8 a7 ed ff ff       	call   800dbb <sys_env_set_status>
  802014:	85 c0                	test   %eax,%eax
  802016:	79 5a                	jns    802072 <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  802018:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201c:	c7 44 24 08 02 31 80 	movl   $0x803102,0x8(%esp)
  802023:	00 
  802024:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  80202b:	00 
  80202c:	c7 04 24 bf 30 80 00 	movl   $0x8030bf,(%esp)
  802033:	e8 f4 e1 ff ff       	call   80022c <_panic>
  802038:	89 c6                	mov    %eax,%esi
  80203a:	eb 06                	jmp    802042 <spawn+0x50e>
  80203c:	89 c6                	mov    %eax,%esi
  80203e:	eb 02                	jmp    802042 <spawn+0x50e>
  802040:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802042:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802048:	89 04 24             	mov    %eax,(%esp)
  80204b:	e8 e1 eb ff ff       	call   800c31 <sys_env_destroy>
	close(fd);
  802050:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802056:	89 04 24             	mov    %eax,(%esp)
  802059:	e8 2c f4 ff ff       	call   80148a <close>
	return r;
  80205e:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  802064:	eb 0c                	jmp    802072 <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802066:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80206c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802072:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802078:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  80207e:	5b                   	pop    %ebx
  80207f:	5e                   	pop    %esi
  802080:	5f                   	pop    %edi
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802083:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802088:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  80208e:	eb e2                	jmp    802072 <spawn+0x53e>

00802090 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	57                   	push   %edi
  802094:	56                   	push   %esi
  802095:	53                   	push   %ebx
  802096:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802099:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80209c:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020a1:	eb 03                	jmp    8020a6 <spawnl+0x16>
		argc++;
  8020a3:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020a4:	89 d0                	mov    %edx,%eax
  8020a6:	8d 50 04             	lea    0x4(%eax),%edx
  8020a9:	83 38 00             	cmpl   $0x0,(%eax)
  8020ac:	75 f5                	jne    8020a3 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8020ae:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8020b5:	83 e0 f0             	and    $0xfffffff0,%eax
  8020b8:	29 c4                	sub    %eax,%esp
  8020ba:	8d 7c 24 17          	lea    0x17(%esp),%edi
  8020be:	83 e7 f0             	and    $0xfffffff0,%edi
  8020c1:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  8020c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c6:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  8020c8:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  8020cf:	00 

	va_start(vl, arg0);
  8020d0:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8020d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d8:	eb 09                	jmp    8020e3 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  8020da:	40                   	inc    %eax
  8020db:	8b 1a                	mov    (%edx),%ebx
  8020dd:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  8020e0:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8020e3:	39 c8                	cmp    %ecx,%eax
  8020e5:	75 f3                	jne    8020da <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8020e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ee:	89 04 24             	mov    %eax,(%esp)
  8020f1:	e8 3e fa ff ff       	call   801b34 <spawn>
}
  8020f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f9:	5b                   	pop    %ebx
  8020fa:	5e                   	pop    %esi
  8020fb:	5f                   	pop    %edi
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    
	...

00802100 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	56                   	push   %esi
  802104:	53                   	push   %ebx
  802105:	83 ec 10             	sub    $0x10,%esp
  802108:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80210b:	8b 45 08             	mov    0x8(%ebp),%eax
  80210e:	89 04 24             	mov    %eax,(%esp)
  802111:	e8 ce f1 ff ff       	call   8012e4 <fd2data>
  802116:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802118:	c7 44 24 04 44 31 80 	movl   $0x803144,0x4(%esp)
  80211f:	00 
  802120:	89 34 24             	mov    %esi,(%esp)
  802123:	e8 a7 e7 ff ff       	call   8008cf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802128:	8b 43 04             	mov    0x4(%ebx),%eax
  80212b:	2b 03                	sub    (%ebx),%eax
  80212d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802133:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80213a:	00 00 00 
	stat->st_dev = &devpipe;
  80213d:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  802144:	40 80 00 
	return 0;
}
  802147:	b8 00 00 00 00       	mov    $0x0,%eax
  80214c:	83 c4 10             	add    $0x10,%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	53                   	push   %ebx
  802157:	83 ec 14             	sub    $0x14,%esp
  80215a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80215d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802168:	e8 fb eb ff ff       	call   800d68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80216d:	89 1c 24             	mov    %ebx,(%esp)
  802170:	e8 6f f1 ff ff       	call   8012e4 <fd2data>
  802175:	89 44 24 04          	mov    %eax,0x4(%esp)
  802179:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802180:	e8 e3 eb ff ff       	call   800d68 <sys_page_unmap>
}
  802185:	83 c4 14             	add    $0x14,%esp
  802188:	5b                   	pop    %ebx
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    

0080218b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	57                   	push   %edi
  80218f:	56                   	push   %esi
  802190:	53                   	push   %ebx
  802191:	83 ec 2c             	sub    $0x2c,%esp
  802194:	89 c7                	mov    %eax,%edi
  802196:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802199:	a1 04 50 80 00       	mov    0x805004,%eax
  80219e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021a1:	89 3c 24             	mov    %edi,(%esp)
  8021a4:	e8 67 06 00 00       	call   802810 <pageref>
  8021a9:	89 c6                	mov    %eax,%esi
  8021ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ae:	89 04 24             	mov    %eax,(%esp)
  8021b1:	e8 5a 06 00 00       	call   802810 <pageref>
  8021b6:	39 c6                	cmp    %eax,%esi
  8021b8:	0f 94 c0             	sete   %al
  8021bb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021be:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8021c4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021c7:	39 cb                	cmp    %ecx,%ebx
  8021c9:	75 08                	jne    8021d3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8021cb:	83 c4 2c             	add    $0x2c,%esp
  8021ce:	5b                   	pop    %ebx
  8021cf:	5e                   	pop    %esi
  8021d0:	5f                   	pop    %edi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8021d3:	83 f8 01             	cmp    $0x1,%eax
  8021d6:	75 c1                	jne    802199 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021d8:	8b 42 58             	mov    0x58(%edx),%eax
  8021db:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8021e2:	00 
  8021e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021eb:	c7 04 24 4b 31 80 00 	movl   $0x80314b,(%esp)
  8021f2:	e8 2d e1 ff ff       	call   800324 <cprintf>
  8021f7:	eb a0                	jmp    802199 <_pipeisclosed+0xe>

008021f9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	57                   	push   %edi
  8021fd:	56                   	push   %esi
  8021fe:	53                   	push   %ebx
  8021ff:	83 ec 1c             	sub    $0x1c,%esp
  802202:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802205:	89 34 24             	mov    %esi,(%esp)
  802208:	e8 d7 f0 ff ff       	call   8012e4 <fd2data>
  80220d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80220f:	bf 00 00 00 00       	mov    $0x0,%edi
  802214:	eb 3c                	jmp    802252 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802216:	89 da                	mov    %ebx,%edx
  802218:	89 f0                	mov    %esi,%eax
  80221a:	e8 6c ff ff ff       	call   80218b <_pipeisclosed>
  80221f:	85 c0                	test   %eax,%eax
  802221:	75 38                	jne    80225b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802223:	e8 7a ea ff ff       	call   800ca2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802228:	8b 43 04             	mov    0x4(%ebx),%eax
  80222b:	8b 13                	mov    (%ebx),%edx
  80222d:	83 c2 20             	add    $0x20,%edx
  802230:	39 d0                	cmp    %edx,%eax
  802232:	73 e2                	jae    802216 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802234:	8b 55 0c             	mov    0xc(%ebp),%edx
  802237:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80223a:	89 c2                	mov    %eax,%edx
  80223c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802242:	79 05                	jns    802249 <devpipe_write+0x50>
  802244:	4a                   	dec    %edx
  802245:	83 ca e0             	or     $0xffffffe0,%edx
  802248:	42                   	inc    %edx
  802249:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80224d:	40                   	inc    %eax
  80224e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802251:	47                   	inc    %edi
  802252:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802255:	75 d1                	jne    802228 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802257:	89 f8                	mov    %edi,%eax
  802259:	eb 05                	jmp    802260 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80225b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    

00802268 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	57                   	push   %edi
  80226c:	56                   	push   %esi
  80226d:	53                   	push   %ebx
  80226e:	83 ec 1c             	sub    $0x1c,%esp
  802271:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802274:	89 3c 24             	mov    %edi,(%esp)
  802277:	e8 68 f0 ff ff       	call   8012e4 <fd2data>
  80227c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80227e:	be 00 00 00 00       	mov    $0x0,%esi
  802283:	eb 3a                	jmp    8022bf <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802285:	85 f6                	test   %esi,%esi
  802287:	74 04                	je     80228d <devpipe_read+0x25>
				return i;
  802289:	89 f0                	mov    %esi,%eax
  80228b:	eb 40                	jmp    8022cd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80228d:	89 da                	mov    %ebx,%edx
  80228f:	89 f8                	mov    %edi,%eax
  802291:	e8 f5 fe ff ff       	call   80218b <_pipeisclosed>
  802296:	85 c0                	test   %eax,%eax
  802298:	75 2e                	jne    8022c8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80229a:	e8 03 ea ff ff       	call   800ca2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80229f:	8b 03                	mov    (%ebx),%eax
  8022a1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022a4:	74 df                	je     802285 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022a6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8022ab:	79 05                	jns    8022b2 <devpipe_read+0x4a>
  8022ad:	48                   	dec    %eax
  8022ae:	83 c8 e0             	or     $0xffffffe0,%eax
  8022b1:	40                   	inc    %eax
  8022b2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022b9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022bc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022be:	46                   	inc    %esi
  8022bf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022c2:	75 db                	jne    80229f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022c4:	89 f0                	mov    %esi,%eax
  8022c6:	eb 05                	jmp    8022cd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022c8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    

008022d5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	57                   	push   %edi
  8022d9:	56                   	push   %esi
  8022da:	53                   	push   %ebx
  8022db:	83 ec 3c             	sub    $0x3c,%esp
  8022de:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8022e4:	89 04 24             	mov    %eax,(%esp)
  8022e7:	e8 13 f0 ff ff       	call   8012ff <fd_alloc>
  8022ec:	89 c3                	mov    %eax,%ebx
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	0f 88 45 01 00 00    	js     80243b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022f6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022fd:	00 
  8022fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802301:	89 44 24 04          	mov    %eax,0x4(%esp)
  802305:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80230c:	e8 b0 e9 ff ff       	call   800cc1 <sys_page_alloc>
  802311:	89 c3                	mov    %eax,%ebx
  802313:	85 c0                	test   %eax,%eax
  802315:	0f 88 20 01 00 00    	js     80243b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80231b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80231e:	89 04 24             	mov    %eax,(%esp)
  802321:	e8 d9 ef ff ff       	call   8012ff <fd_alloc>
  802326:	89 c3                	mov    %eax,%ebx
  802328:	85 c0                	test   %eax,%eax
  80232a:	0f 88 f8 00 00 00    	js     802428 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802330:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802337:	00 
  802338:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80233b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802346:	e8 76 e9 ff ff       	call   800cc1 <sys_page_alloc>
  80234b:	89 c3                	mov    %eax,%ebx
  80234d:	85 c0                	test   %eax,%eax
  80234f:	0f 88 d3 00 00 00    	js     802428 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802355:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802358:	89 04 24             	mov    %eax,(%esp)
  80235b:	e8 84 ef ff ff       	call   8012e4 <fd2data>
  802360:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802362:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802369:	00 
  80236a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802375:	e8 47 e9 ff ff       	call   800cc1 <sys_page_alloc>
  80237a:	89 c3                	mov    %eax,%ebx
  80237c:	85 c0                	test   %eax,%eax
  80237e:	0f 88 91 00 00 00    	js     802415 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802384:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802387:	89 04 24             	mov    %eax,(%esp)
  80238a:	e8 55 ef ff ff       	call   8012e4 <fd2data>
  80238f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802396:	00 
  802397:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80239b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023a2:	00 
  8023a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ae:	e8 62 e9 ff ff       	call   800d15 <sys_page_map>
  8023b3:	89 c3                	mov    %eax,%ebx
  8023b5:	85 c0                	test   %eax,%eax
  8023b7:	78 4c                	js     802405 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023b9:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8023bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023c2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023c7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023ce:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8023d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023d7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023dc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e6:	89 04 24             	mov    %eax,(%esp)
  8023e9:	e8 e6 ee ff ff       	call   8012d4 <fd2num>
  8023ee:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8023f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023f3:	89 04 24             	mov    %eax,(%esp)
  8023f6:	e8 d9 ee ff ff       	call   8012d4 <fd2num>
  8023fb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8023fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  802403:	eb 36                	jmp    80243b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802405:	89 74 24 04          	mov    %esi,0x4(%esp)
  802409:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802410:	e8 53 e9 ff ff       	call   800d68 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802418:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802423:	e8 40 e9 ff ff       	call   800d68 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80242b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80242f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802436:	e8 2d e9 ff ff       	call   800d68 <sys_page_unmap>
    err:
	return r;
}
  80243b:	89 d8                	mov    %ebx,%eax
  80243d:	83 c4 3c             	add    $0x3c,%esp
  802440:	5b                   	pop    %ebx
  802441:	5e                   	pop    %esi
  802442:	5f                   	pop    %edi
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    

00802445 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802445:	55                   	push   %ebp
  802446:	89 e5                	mov    %esp,%ebp
  802448:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80244b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80244e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802452:	8b 45 08             	mov    0x8(%ebp),%eax
  802455:	89 04 24             	mov    %eax,(%esp)
  802458:	e8 f5 ee ff ff       	call   801352 <fd_lookup>
  80245d:	85 c0                	test   %eax,%eax
  80245f:	78 15                	js     802476 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802461:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802464:	89 04 24             	mov    %eax,(%esp)
  802467:	e8 78 ee ff ff       	call   8012e4 <fd2data>
	return _pipeisclosed(fd, p);
  80246c:	89 c2                	mov    %eax,%edx
  80246e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802471:	e8 15 fd ff ff       	call   80218b <_pipeisclosed>
}
  802476:	c9                   	leave  
  802477:	c3                   	ret    

00802478 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	56                   	push   %esi
  80247c:	53                   	push   %ebx
  80247d:	83 ec 10             	sub    $0x10,%esp
  802480:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802483:	85 f6                	test   %esi,%esi
  802485:	75 24                	jne    8024ab <wait+0x33>
  802487:	c7 44 24 0c 63 31 80 	movl   $0x803163,0xc(%esp)
  80248e:	00 
  80248f:	c7 44 24 08 84 30 80 	movl   $0x803084,0x8(%esp)
  802496:	00 
  802497:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80249e:	00 
  80249f:	c7 04 24 6e 31 80 00 	movl   $0x80316e,(%esp)
  8024a6:	e8 81 dd ff ff       	call   80022c <_panic>
	e = &envs[ENVX(envid)];
  8024ab:	89 f3                	mov    %esi,%ebx
  8024ad:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8024b3:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  8024ba:	c1 e3 07             	shl    $0x7,%ebx
  8024bd:	29 c3                	sub    %eax,%ebx
  8024bf:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024c5:	eb 05                	jmp    8024cc <wait+0x54>
		sys_yield();
  8024c7:	e8 d6 e7 ff ff       	call   800ca2 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024cc:	8b 43 48             	mov    0x48(%ebx),%eax
  8024cf:	39 f0                	cmp    %esi,%eax
  8024d1:	75 07                	jne    8024da <wait+0x62>
  8024d3:	8b 43 54             	mov    0x54(%ebx),%eax
  8024d6:	85 c0                	test   %eax,%eax
  8024d8:	75 ed                	jne    8024c7 <wait+0x4f>
		sys_yield();
}
  8024da:	83 c4 10             	add    $0x10,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5d                   	pop    %ebp
  8024e0:	c3                   	ret    
  8024e1:	00 00                	add    %al,(%eax)
	...

008024e4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024e4:	55                   	push   %ebp
  8024e5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8024ec:	5d                   	pop    %ebp
  8024ed:	c3                   	ret    

008024ee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
  8024f1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024f4:	c7 44 24 04 79 31 80 	movl   $0x803179,0x4(%esp)
  8024fb:	00 
  8024fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ff:	89 04 24             	mov    %eax,(%esp)
  802502:	e8 c8 e3 ff ff       	call   8008cf <strcpy>
	return 0;
}
  802507:	b8 00 00 00 00       	mov    $0x0,%eax
  80250c:	c9                   	leave  
  80250d:	c3                   	ret    

0080250e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80251a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80251f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802525:	eb 30                	jmp    802557 <devcons_write+0x49>
		m = n - tot;
  802527:	8b 75 10             	mov    0x10(%ebp),%esi
  80252a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80252c:	83 fe 7f             	cmp    $0x7f,%esi
  80252f:	76 05                	jbe    802536 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802531:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802536:	89 74 24 08          	mov    %esi,0x8(%esp)
  80253a:	03 45 0c             	add    0xc(%ebp),%eax
  80253d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802541:	89 3c 24             	mov    %edi,(%esp)
  802544:	e8 ff e4 ff ff       	call   800a48 <memmove>
		sys_cputs(buf, m);
  802549:	89 74 24 04          	mov    %esi,0x4(%esp)
  80254d:	89 3c 24             	mov    %edi,(%esp)
  802550:	e8 9f e6 ff ff       	call   800bf4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802555:	01 f3                	add    %esi,%ebx
  802557:	89 d8                	mov    %ebx,%eax
  802559:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80255c:	72 c9                	jb     802527 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80255e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    

00802569 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802569:	55                   	push   %ebp
  80256a:	89 e5                	mov    %esp,%ebp
  80256c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80256f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802573:	75 07                	jne    80257c <devcons_read+0x13>
  802575:	eb 25                	jmp    80259c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802577:	e8 26 e7 ff ff       	call   800ca2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80257c:	e8 91 e6 ff ff       	call   800c12 <sys_cgetc>
  802581:	85 c0                	test   %eax,%eax
  802583:	74 f2                	je     802577 <devcons_read+0xe>
  802585:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802587:	85 c0                	test   %eax,%eax
  802589:	78 1d                	js     8025a8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80258b:	83 f8 04             	cmp    $0x4,%eax
  80258e:	74 13                	je     8025a3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802590:	8b 45 0c             	mov    0xc(%ebp),%eax
  802593:	88 10                	mov    %dl,(%eax)
	return 1;
  802595:	b8 01 00 00 00       	mov    $0x1,%eax
  80259a:	eb 0c                	jmp    8025a8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80259c:	b8 00 00 00 00       	mov    $0x0,%eax
  8025a1:	eb 05                	jmp    8025a8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8025a3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025a8:	c9                   	leave  
  8025a9:	c3                   	ret    

008025aa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025aa:	55                   	push   %ebp
  8025ab:	89 e5                	mov    %esp,%ebp
  8025ad:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8025b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8025bd:	00 
  8025be:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025c1:	89 04 24             	mov    %eax,(%esp)
  8025c4:	e8 2b e6 ff ff       	call   800bf4 <sys_cputs>
}
  8025c9:	c9                   	leave  
  8025ca:	c3                   	ret    

008025cb <getchar>:

int
getchar(void)
{
  8025cb:	55                   	push   %ebp
  8025cc:	89 e5                	mov    %esp,%ebp
  8025ce:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8025d8:	00 
  8025d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025e7:	e8 02 f0 ff ff       	call   8015ee <read>
	if (r < 0)
  8025ec:	85 c0                	test   %eax,%eax
  8025ee:	78 0f                	js     8025ff <getchar+0x34>
		return r;
	if (r < 1)
  8025f0:	85 c0                	test   %eax,%eax
  8025f2:	7e 06                	jle    8025fa <getchar+0x2f>
		return -E_EOF;
	return c;
  8025f4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025f8:	eb 05                	jmp    8025ff <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025fa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025ff:	c9                   	leave  
  802600:	c3                   	ret    

00802601 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802601:	55                   	push   %ebp
  802602:	89 e5                	mov    %esp,%ebp
  802604:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802607:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80260a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80260e:	8b 45 08             	mov    0x8(%ebp),%eax
  802611:	89 04 24             	mov    %eax,(%esp)
  802614:	e8 39 ed ff ff       	call   801352 <fd_lookup>
  802619:	85 c0                	test   %eax,%eax
  80261b:	78 11                	js     80262e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80261d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802620:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802626:	39 10                	cmp    %edx,(%eax)
  802628:	0f 94 c0             	sete   %al
  80262b:	0f b6 c0             	movzbl %al,%eax
}
  80262e:	c9                   	leave  
  80262f:	c3                   	ret    

00802630 <opencons>:

int
opencons(void)
{
  802630:	55                   	push   %ebp
  802631:	89 e5                	mov    %esp,%ebp
  802633:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802639:	89 04 24             	mov    %eax,(%esp)
  80263c:	e8 be ec ff ff       	call   8012ff <fd_alloc>
  802641:	85 c0                	test   %eax,%eax
  802643:	78 3c                	js     802681 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802645:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80264c:	00 
  80264d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802650:	89 44 24 04          	mov    %eax,0x4(%esp)
  802654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80265b:	e8 61 e6 ff ff       	call   800cc1 <sys_page_alloc>
  802660:	85 c0                	test   %eax,%eax
  802662:	78 1d                	js     802681 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802664:	8b 15 44 40 80 00    	mov    0x804044,%edx
  80266a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80266d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80266f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802672:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802679:	89 04 24             	mov    %eax,(%esp)
  80267c:	e8 53 ec ff ff       	call   8012d4 <fd2num>
}
  802681:	c9                   	leave  
  802682:	c3                   	ret    
	...

00802684 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802684:	55                   	push   %ebp
  802685:	89 e5                	mov    %esp,%ebp
  802687:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80268a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802691:	75 32                	jne    8026c5 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802693:	e8 eb e5 ff ff       	call   800c83 <sys_getenvid>
  802698:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  80269f:	00 
  8026a0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8026a7:	ee 
  8026a8:	89 04 24             	mov    %eax,(%esp)
  8026ab:	e8 11 e6 ff ff       	call   800cc1 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  8026b0:	e8 ce e5 ff ff       	call   800c83 <sys_getenvid>
  8026b5:	c7 44 24 04 d0 26 80 	movl   $0x8026d0,0x4(%esp)
  8026bc:	00 
  8026bd:	89 04 24             	mov    %eax,(%esp)
  8026c0:	e8 9c e7 ff ff       	call   800e61 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c8:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8026cd:	c9                   	leave  
  8026ce:	c3                   	ret    
	...

008026d0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026d0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026d1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026d6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026d8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  8026db:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  8026df:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  8026e2:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  8026e7:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  8026eb:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  8026ee:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  8026ef:	83 c4 04             	add    $0x4,%esp
	popfl
  8026f2:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  8026f3:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  8026f4:	c3                   	ret    
  8026f5:	00 00                	add    %al,(%eax)
	...

008026f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026f8:	55                   	push   %ebp
  8026f9:	89 e5                	mov    %esp,%ebp
  8026fb:	57                   	push   %edi
  8026fc:	56                   	push   %esi
  8026fd:	53                   	push   %ebx
  8026fe:	83 ec 1c             	sub    $0x1c,%esp
  802701:	8b 75 08             	mov    0x8(%ebp),%esi
  802704:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802707:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  80270a:	85 db                	test   %ebx,%ebx
  80270c:	75 05                	jne    802713 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  80270e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  802713:	89 1c 24             	mov    %ebx,(%esp)
  802716:	e8 bc e7 ff ff       	call   800ed7 <sys_ipc_recv>
  80271b:	85 c0                	test   %eax,%eax
  80271d:	79 16                	jns    802735 <ipc_recv+0x3d>
		*from_env_store = 0;
  80271f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  802725:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  80272b:	89 1c 24             	mov    %ebx,(%esp)
  80272e:	e8 a4 e7 ff ff       	call   800ed7 <sys_ipc_recv>
  802733:	eb 24                	jmp    802759 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  802735:	85 f6                	test   %esi,%esi
  802737:	74 0a                	je     802743 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802739:	a1 04 50 80 00       	mov    0x805004,%eax
  80273e:	8b 40 74             	mov    0x74(%eax),%eax
  802741:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802743:	85 ff                	test   %edi,%edi
  802745:	74 0a                	je     802751 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802747:	a1 04 50 80 00       	mov    0x805004,%eax
  80274c:	8b 40 78             	mov    0x78(%eax),%eax
  80274f:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  802751:	a1 04 50 80 00       	mov    0x805004,%eax
  802756:	8b 40 70             	mov    0x70(%eax),%eax
}
  802759:	83 c4 1c             	add    $0x1c,%esp
  80275c:	5b                   	pop    %ebx
  80275d:	5e                   	pop    %esi
  80275e:	5f                   	pop    %edi
  80275f:	5d                   	pop    %ebp
  802760:	c3                   	ret    

00802761 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802761:	55                   	push   %ebp
  802762:	89 e5                	mov    %esp,%ebp
  802764:	57                   	push   %edi
  802765:	56                   	push   %esi
  802766:	53                   	push   %ebx
  802767:	83 ec 1c             	sub    $0x1c,%esp
  80276a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80276d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802770:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802773:	85 db                	test   %ebx,%ebx
  802775:	75 05                	jne    80277c <ipc_send+0x1b>
		pg = (void *)-1;
  802777:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80277c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802780:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802784:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802788:	8b 45 08             	mov    0x8(%ebp),%eax
  80278b:	89 04 24             	mov    %eax,(%esp)
  80278e:	e8 21 e7 ff ff       	call   800eb4 <sys_ipc_try_send>
		if (r == 0) {		
  802793:	85 c0                	test   %eax,%eax
  802795:	74 2c                	je     8027c3 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  802797:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80279a:	75 07                	jne    8027a3 <ipc_send+0x42>
			sys_yield();
  80279c:	e8 01 e5 ff ff       	call   800ca2 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  8027a1:	eb d9                	jmp    80277c <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  8027a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027a7:	c7 44 24 08 85 31 80 	movl   $0x803185,0x8(%esp)
  8027ae:	00 
  8027af:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8027b6:	00 
  8027b7:	c7 04 24 93 31 80 00 	movl   $0x803193,(%esp)
  8027be:	e8 69 da ff ff       	call   80022c <_panic>
		}
	}
}
  8027c3:	83 c4 1c             	add    $0x1c,%esp
  8027c6:	5b                   	pop    %ebx
  8027c7:	5e                   	pop    %esi
  8027c8:	5f                   	pop    %edi
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    

008027cb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027cb:	55                   	push   %ebp
  8027cc:	89 e5                	mov    %esp,%ebp
  8027ce:	53                   	push   %ebx
  8027cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8027d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027d7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8027de:	89 c2                	mov    %eax,%edx
  8027e0:	c1 e2 07             	shl    $0x7,%edx
  8027e3:	29 ca                	sub    %ecx,%edx
  8027e5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027eb:	8b 52 50             	mov    0x50(%edx),%edx
  8027ee:	39 da                	cmp    %ebx,%edx
  8027f0:	75 0f                	jne    802801 <ipc_find_env+0x36>
			return envs[i].env_id;
  8027f2:	c1 e0 07             	shl    $0x7,%eax
  8027f5:	29 c8                	sub    %ecx,%eax
  8027f7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8027fc:	8b 40 40             	mov    0x40(%eax),%eax
  8027ff:	eb 0c                	jmp    80280d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802801:	40                   	inc    %eax
  802802:	3d 00 04 00 00       	cmp    $0x400,%eax
  802807:	75 ce                	jne    8027d7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802809:	66 b8 00 00          	mov    $0x0,%ax
}
  80280d:	5b                   	pop    %ebx
  80280e:	5d                   	pop    %ebp
  80280f:	c3                   	ret    

00802810 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802810:	55                   	push   %ebp
  802811:	89 e5                	mov    %esp,%ebp
  802813:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802816:	89 c2                	mov    %eax,%edx
  802818:	c1 ea 16             	shr    $0x16,%edx
  80281b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802822:	f6 c2 01             	test   $0x1,%dl
  802825:	74 1e                	je     802845 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802827:	c1 e8 0c             	shr    $0xc,%eax
  80282a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802831:	a8 01                	test   $0x1,%al
  802833:	74 17                	je     80284c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802835:	c1 e8 0c             	shr    $0xc,%eax
  802838:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80283f:	ef 
  802840:	0f b7 c0             	movzwl %ax,%eax
  802843:	eb 0c                	jmp    802851 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802845:	b8 00 00 00 00       	mov    $0x0,%eax
  80284a:	eb 05                	jmp    802851 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80284c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802851:	5d                   	pop    %ebp
  802852:	c3                   	ret    
	...

00802854 <__udivdi3>:
  802854:	55                   	push   %ebp
  802855:	57                   	push   %edi
  802856:	56                   	push   %esi
  802857:	83 ec 10             	sub    $0x10,%esp
  80285a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80285e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802862:	89 74 24 04          	mov    %esi,0x4(%esp)
  802866:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80286a:	89 cd                	mov    %ecx,%ebp
  80286c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802870:	85 c0                	test   %eax,%eax
  802872:	75 2c                	jne    8028a0 <__udivdi3+0x4c>
  802874:	39 f9                	cmp    %edi,%ecx
  802876:	77 68                	ja     8028e0 <__udivdi3+0x8c>
  802878:	85 c9                	test   %ecx,%ecx
  80287a:	75 0b                	jne    802887 <__udivdi3+0x33>
  80287c:	b8 01 00 00 00       	mov    $0x1,%eax
  802881:	31 d2                	xor    %edx,%edx
  802883:	f7 f1                	div    %ecx
  802885:	89 c1                	mov    %eax,%ecx
  802887:	31 d2                	xor    %edx,%edx
  802889:	89 f8                	mov    %edi,%eax
  80288b:	f7 f1                	div    %ecx
  80288d:	89 c7                	mov    %eax,%edi
  80288f:	89 f0                	mov    %esi,%eax
  802891:	f7 f1                	div    %ecx
  802893:	89 c6                	mov    %eax,%esi
  802895:	89 f0                	mov    %esi,%eax
  802897:	89 fa                	mov    %edi,%edx
  802899:	83 c4 10             	add    $0x10,%esp
  80289c:	5e                   	pop    %esi
  80289d:	5f                   	pop    %edi
  80289e:	5d                   	pop    %ebp
  80289f:	c3                   	ret    
  8028a0:	39 f8                	cmp    %edi,%eax
  8028a2:	77 2c                	ja     8028d0 <__udivdi3+0x7c>
  8028a4:	0f bd f0             	bsr    %eax,%esi
  8028a7:	83 f6 1f             	xor    $0x1f,%esi
  8028aa:	75 4c                	jne    8028f8 <__udivdi3+0xa4>
  8028ac:	39 f8                	cmp    %edi,%eax
  8028ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8028b3:	72 0a                	jb     8028bf <__udivdi3+0x6b>
  8028b5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8028b9:	0f 87 ad 00 00 00    	ja     80296c <__udivdi3+0x118>
  8028bf:	be 01 00 00 00       	mov    $0x1,%esi
  8028c4:	89 f0                	mov    %esi,%eax
  8028c6:	89 fa                	mov    %edi,%edx
  8028c8:	83 c4 10             	add    $0x10,%esp
  8028cb:	5e                   	pop    %esi
  8028cc:	5f                   	pop    %edi
  8028cd:	5d                   	pop    %ebp
  8028ce:	c3                   	ret    
  8028cf:	90                   	nop
  8028d0:	31 ff                	xor    %edi,%edi
  8028d2:	31 f6                	xor    %esi,%esi
  8028d4:	89 f0                	mov    %esi,%eax
  8028d6:	89 fa                	mov    %edi,%edx
  8028d8:	83 c4 10             	add    $0x10,%esp
  8028db:	5e                   	pop    %esi
  8028dc:	5f                   	pop    %edi
  8028dd:	5d                   	pop    %ebp
  8028de:	c3                   	ret    
  8028df:	90                   	nop
  8028e0:	89 fa                	mov    %edi,%edx
  8028e2:	89 f0                	mov    %esi,%eax
  8028e4:	f7 f1                	div    %ecx
  8028e6:	89 c6                	mov    %eax,%esi
  8028e8:	31 ff                	xor    %edi,%edi
  8028ea:	89 f0                	mov    %esi,%eax
  8028ec:	89 fa                	mov    %edi,%edx
  8028ee:	83 c4 10             	add    $0x10,%esp
  8028f1:	5e                   	pop    %esi
  8028f2:	5f                   	pop    %edi
  8028f3:	5d                   	pop    %ebp
  8028f4:	c3                   	ret    
  8028f5:	8d 76 00             	lea    0x0(%esi),%esi
  8028f8:	89 f1                	mov    %esi,%ecx
  8028fa:	d3 e0                	shl    %cl,%eax
  8028fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802900:	b8 20 00 00 00       	mov    $0x20,%eax
  802905:	29 f0                	sub    %esi,%eax
  802907:	89 ea                	mov    %ebp,%edx
  802909:	88 c1                	mov    %al,%cl
  80290b:	d3 ea                	shr    %cl,%edx
  80290d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802911:	09 ca                	or     %ecx,%edx
  802913:	89 54 24 08          	mov    %edx,0x8(%esp)
  802917:	89 f1                	mov    %esi,%ecx
  802919:	d3 e5                	shl    %cl,%ebp
  80291b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80291f:	89 fd                	mov    %edi,%ebp
  802921:	88 c1                	mov    %al,%cl
  802923:	d3 ed                	shr    %cl,%ebp
  802925:	89 fa                	mov    %edi,%edx
  802927:	89 f1                	mov    %esi,%ecx
  802929:	d3 e2                	shl    %cl,%edx
  80292b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80292f:	88 c1                	mov    %al,%cl
  802931:	d3 ef                	shr    %cl,%edi
  802933:	09 d7                	or     %edx,%edi
  802935:	89 f8                	mov    %edi,%eax
  802937:	89 ea                	mov    %ebp,%edx
  802939:	f7 74 24 08          	divl   0x8(%esp)
  80293d:	89 d1                	mov    %edx,%ecx
  80293f:	89 c7                	mov    %eax,%edi
  802941:	f7 64 24 0c          	mull   0xc(%esp)
  802945:	39 d1                	cmp    %edx,%ecx
  802947:	72 17                	jb     802960 <__udivdi3+0x10c>
  802949:	74 09                	je     802954 <__udivdi3+0x100>
  80294b:	89 fe                	mov    %edi,%esi
  80294d:	31 ff                	xor    %edi,%edi
  80294f:	e9 41 ff ff ff       	jmp    802895 <__udivdi3+0x41>
  802954:	8b 54 24 04          	mov    0x4(%esp),%edx
  802958:	89 f1                	mov    %esi,%ecx
  80295a:	d3 e2                	shl    %cl,%edx
  80295c:	39 c2                	cmp    %eax,%edx
  80295e:	73 eb                	jae    80294b <__udivdi3+0xf7>
  802960:	8d 77 ff             	lea    -0x1(%edi),%esi
  802963:	31 ff                	xor    %edi,%edi
  802965:	e9 2b ff ff ff       	jmp    802895 <__udivdi3+0x41>
  80296a:	66 90                	xchg   %ax,%ax
  80296c:	31 f6                	xor    %esi,%esi
  80296e:	e9 22 ff ff ff       	jmp    802895 <__udivdi3+0x41>
	...

00802974 <__umoddi3>:
  802974:	55                   	push   %ebp
  802975:	57                   	push   %edi
  802976:	56                   	push   %esi
  802977:	83 ec 20             	sub    $0x20,%esp
  80297a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80297e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802982:	89 44 24 14          	mov    %eax,0x14(%esp)
  802986:	8b 74 24 34          	mov    0x34(%esp),%esi
  80298a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80298e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802992:	89 c7                	mov    %eax,%edi
  802994:	89 f2                	mov    %esi,%edx
  802996:	85 ed                	test   %ebp,%ebp
  802998:	75 16                	jne    8029b0 <__umoddi3+0x3c>
  80299a:	39 f1                	cmp    %esi,%ecx
  80299c:	0f 86 a6 00 00 00    	jbe    802a48 <__umoddi3+0xd4>
  8029a2:	f7 f1                	div    %ecx
  8029a4:	89 d0                	mov    %edx,%eax
  8029a6:	31 d2                	xor    %edx,%edx
  8029a8:	83 c4 20             	add    $0x20,%esp
  8029ab:	5e                   	pop    %esi
  8029ac:	5f                   	pop    %edi
  8029ad:	5d                   	pop    %ebp
  8029ae:	c3                   	ret    
  8029af:	90                   	nop
  8029b0:	39 f5                	cmp    %esi,%ebp
  8029b2:	0f 87 ac 00 00 00    	ja     802a64 <__umoddi3+0xf0>
  8029b8:	0f bd c5             	bsr    %ebp,%eax
  8029bb:	83 f0 1f             	xor    $0x1f,%eax
  8029be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029c2:	0f 84 a8 00 00 00    	je     802a70 <__umoddi3+0xfc>
  8029c8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029cc:	d3 e5                	shl    %cl,%ebp
  8029ce:	bf 20 00 00 00       	mov    $0x20,%edi
  8029d3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8029d7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029db:	89 f9                	mov    %edi,%ecx
  8029dd:	d3 e8                	shr    %cl,%eax
  8029df:	09 e8                	or     %ebp,%eax
  8029e1:	89 44 24 18          	mov    %eax,0x18(%esp)
  8029e5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029e9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029ed:	d3 e0                	shl    %cl,%eax
  8029ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029f3:	89 f2                	mov    %esi,%edx
  8029f5:	d3 e2                	shl    %cl,%edx
  8029f7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029fb:	d3 e0                	shl    %cl,%eax
  8029fd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802a01:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a05:	89 f9                	mov    %edi,%ecx
  802a07:	d3 e8                	shr    %cl,%eax
  802a09:	09 d0                	or     %edx,%eax
  802a0b:	d3 ee                	shr    %cl,%esi
  802a0d:	89 f2                	mov    %esi,%edx
  802a0f:	f7 74 24 18          	divl   0x18(%esp)
  802a13:	89 d6                	mov    %edx,%esi
  802a15:	f7 64 24 0c          	mull   0xc(%esp)
  802a19:	89 c5                	mov    %eax,%ebp
  802a1b:	89 d1                	mov    %edx,%ecx
  802a1d:	39 d6                	cmp    %edx,%esi
  802a1f:	72 67                	jb     802a88 <__umoddi3+0x114>
  802a21:	74 75                	je     802a98 <__umoddi3+0x124>
  802a23:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802a27:	29 e8                	sub    %ebp,%eax
  802a29:	19 ce                	sbb    %ecx,%esi
  802a2b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a2f:	d3 e8                	shr    %cl,%eax
  802a31:	89 f2                	mov    %esi,%edx
  802a33:	89 f9                	mov    %edi,%ecx
  802a35:	d3 e2                	shl    %cl,%edx
  802a37:	09 d0                	or     %edx,%eax
  802a39:	89 f2                	mov    %esi,%edx
  802a3b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a3f:	d3 ea                	shr    %cl,%edx
  802a41:	83 c4 20             	add    $0x20,%esp
  802a44:	5e                   	pop    %esi
  802a45:	5f                   	pop    %edi
  802a46:	5d                   	pop    %ebp
  802a47:	c3                   	ret    
  802a48:	85 c9                	test   %ecx,%ecx
  802a4a:	75 0b                	jne    802a57 <__umoddi3+0xe3>
  802a4c:	b8 01 00 00 00       	mov    $0x1,%eax
  802a51:	31 d2                	xor    %edx,%edx
  802a53:	f7 f1                	div    %ecx
  802a55:	89 c1                	mov    %eax,%ecx
  802a57:	89 f0                	mov    %esi,%eax
  802a59:	31 d2                	xor    %edx,%edx
  802a5b:	f7 f1                	div    %ecx
  802a5d:	89 f8                	mov    %edi,%eax
  802a5f:	e9 3e ff ff ff       	jmp    8029a2 <__umoddi3+0x2e>
  802a64:	89 f2                	mov    %esi,%edx
  802a66:	83 c4 20             	add    $0x20,%esp
  802a69:	5e                   	pop    %esi
  802a6a:	5f                   	pop    %edi
  802a6b:	5d                   	pop    %ebp
  802a6c:	c3                   	ret    
  802a6d:	8d 76 00             	lea    0x0(%esi),%esi
  802a70:	39 f5                	cmp    %esi,%ebp
  802a72:	72 04                	jb     802a78 <__umoddi3+0x104>
  802a74:	39 f9                	cmp    %edi,%ecx
  802a76:	77 06                	ja     802a7e <__umoddi3+0x10a>
  802a78:	89 f2                	mov    %esi,%edx
  802a7a:	29 cf                	sub    %ecx,%edi
  802a7c:	19 ea                	sbb    %ebp,%edx
  802a7e:	89 f8                	mov    %edi,%eax
  802a80:	83 c4 20             	add    $0x20,%esp
  802a83:	5e                   	pop    %esi
  802a84:	5f                   	pop    %edi
  802a85:	5d                   	pop    %ebp
  802a86:	c3                   	ret    
  802a87:	90                   	nop
  802a88:	89 d1                	mov    %edx,%ecx
  802a8a:	89 c5                	mov    %eax,%ebp
  802a8c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802a90:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802a94:	eb 8d                	jmp    802a23 <__umoddi3+0xaf>
  802a96:	66 90                	xchg   %ax,%ax
  802a98:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802a9c:	72 ea                	jb     802a88 <__umoddi3+0x114>
  802a9e:	89 f1                	mov    %esi,%ecx
  802aa0:	eb 81                	jmp    802a23 <__umoddi3+0xaf>
