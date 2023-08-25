
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 a0 1f 80 00 	movl   $0x801fa0,(%esp)
  800041:	e8 1e 02 00 00       	call   800264 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 1b 20 80 	movl   $0x80201b,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 38 20 80 00 	movl   $0x802038,(%esp)
  800070:	e8 f7 00 00 00       	call   80016c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 c0 1f 80 	movl   $0x801fc0,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 38 20 80 00 	movl   $0x802038,(%esp)
  8000ba:	e8 ad 00 00 00       	call   80016c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 e8 1f 80 00 	movl   $0x801fe8,(%esp)
  8000ce:	e8 91 01 00 00       	call   800264 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 47 20 80 	movl   $0x802047,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 38 20 80 00 	movl   $0x802038,(%esp)
  8000f4:	e8 73 00 00 00       	call   80016c <_panic>
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 10             	sub    $0x10,%esp
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  80010a:	e8 b4 0a 00 00       	call   800bc3 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011b:	c1 e0 07             	shl    $0x7,%eax
  80011e:	29 d0                	sub    %edx,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	85 f6                	test   %esi,%esi
  80012c:	7e 07                	jle    800135 <libmain+0x39>
		binaryname = argv[0];
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800135:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 f3 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800141:	e8 0a 00 00 00       	call   800150 <exit>
}
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800156:	e8 f8 0e 00 00       	call   801053 <close_all>
	sys_env_destroy(0);
  80015b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800162:	e8 0a 0a 00 00       	call   800b71 <sys_env_destroy>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800174:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800177:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80017d:	e8 41 0a 00 00       	call   800bc3 <sys_getenvid>
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 54 24 10          	mov    %edx,0x10(%esp)
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  80019f:	e8 c0 00 00 00       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 50 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  8001b3:	c7 04 24 36 20 80 00 	movl   $0x802036,(%esp)
  8001ba:	e8 a5 00 00 00       	call   800264 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x53>
	...

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 14             	sub    $0x14,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 03                	mov    (%ebx),%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d7:	40                   	inc    %eax
  8001d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 19                	jne    8001fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e8:	00 
  8001e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 40 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fa:	ff 43 04             	incl   0x4(%ebx)
}
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	5b                   	pop    %ebx
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800213:	00 00 00 
	b.cnt = 0;
  800216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  80023f:	e8 82 01 00 00       	call   8003c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800244:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 d8 08 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 87 ff ff ff       	call   800203 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	75 08                	jne    8002ac <printnum+0x2c>
  8002a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002aa:	77 57                	ja     800303 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b0:	4b                   	dec    %ebx
  8002b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cb:	00 
  8002cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	e8 62 1a 00 00       	call   801d40 <__udivdi3>
  8002de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	89 fa                	mov    %edi,%edx
  8002ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f2:	e8 89 ff ff ff       	call   800280 <printnum>
  8002f7:	eb 0f                	jmp    800308 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fd:	89 34 24             	mov    %esi,(%esp)
  800300:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800303:	4b                   	dec    %ebx
  800304:	85 db                	test   %ebx,%ebx
  800306:	7f f1                	jg     8002f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800310:	8b 45 10             	mov    0x10(%ebp),%eax
  800313:	89 44 24 08          	mov    %eax,0x8(%esp)
  800317:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031e:	00 
  80031f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	e8 2f 1b 00 00       	call   801e60 <__umoddi3>
  800331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800335:	0f be 80 8b 20 80 00 	movsbl 0x80208b(%eax),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800342:	83 c4 3c             	add    $0x3c,%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034d:	83 fa 01             	cmp    $0x1,%edx
  800350:	7e 0e                	jle    800360 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 08             	lea    0x8(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	8b 52 04             	mov    0x4(%edx),%edx
  80035e:	eb 22                	jmp    800382 <getuint+0x38>
	else if (lflag)
  800360:	85 d2                	test   %edx,%edx
  800362:	74 10                	je     800374 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	eb 0e                	jmp    800382 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 04             	lea    0x4(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	3b 50 04             	cmp    0x4(%eax),%edx
  800392:	73 08                	jae    80039c <sprintputch+0x18>
		*b->buf++ = ch;
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 0a                	mov    %cl,(%edx)
  800399:	42                   	inc    %edx
  80039a:	89 10                	mov    %edx,(%eax)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 02 00 00 00       	call   8003c6 <vprintfmt>
	va_end(ap);
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	57                   	push   %edi
  8003ca:	56                   	push   %esi
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 4c             	sub    $0x4c,%esp
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 6b 03 00 00    	je     80074a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e3:	89 04 24             	mov    %eax,(%esp)
  8003e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 06             	movzbl (%esi),%eax
  8003ec:	46                   	inc    %esi
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 e5                	jne    8003d7 <vprintfmt+0x11>
  8003f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800402:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	eb 26                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800413:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800417:	eb 1d                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800420:	eb 14                	jmp    800436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800425:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042c:	eb 08                	jmp    800436 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800431:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	0f b6 06             	movzbl (%esi),%eax
  800439:	8d 56 01             	lea    0x1(%esi),%edx
  80043c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043f:	8a 16                	mov    (%esi),%dl
  800441:	83 ea 23             	sub    $0x23,%edx
  800444:	80 fa 55             	cmp    $0x55,%dl
  800447:	0f 87 e1 02 00 00    	ja     80072e <vprintfmt+0x368>
  80044d:	0f b6 d2             	movzbl %dl,%edx
  800450:	ff 24 95 c0 21 80 00 	jmp    *0x8021c0(,%edx,4)
  800457:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800462:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800466:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800469:	8d 50 d0             	lea    -0x30(%eax),%edx
  80046c:	83 fa 09             	cmp    $0x9,%edx
  80046f:	77 2a                	ja     80049b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800471:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800472:	eb eb                	jmp    80045f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800482:	eb 17                	jmp    80049b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800484:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800488:	78 98                	js     800422 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80048d:	eb a7                	jmp    800436 <vprintfmt+0x70>
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800492:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800499:	eb 9b                	jmp    800436 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049f:	79 95                	jns    800436 <vprintfmt+0x70>
  8004a1:	eb 8b                	jmp    80042e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a7:	eb 8d                	jmp    800436 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b6:	8b 00                	mov    (%eax),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 23 ff ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	79 02                	jns    8004d7 <vprintfmt+0x111>
  8004d5:	f7 d8                	neg    %eax
  8004d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d9:	83 f8 0f             	cmp    $0xf,%eax
  8004dc:	7f 0b                	jg     8004e9 <vprintfmt+0x123>
  8004de:	8b 04 85 20 23 80 00 	mov    0x802320(,%eax,4),%eax
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 23                	jne    80050c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ed:	c7 44 24 08 a3 20 80 	movl   $0x8020a3,0x8(%esp)
  8004f4:	00 
  8004f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	e8 9a fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800507:	e9 dd fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	c7 44 24 08 7e 24 80 	movl   $0x80247e,0x8(%esp)
  800517:	00 
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 55 08             	mov    0x8(%ebp),%edx
  80051f:	89 14 24             	mov    %edx,(%esp)
  800522:	e8 77 fe ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052a:	e9 ba fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
  80052f:	89 f9                	mov    %edi,%ecx
  800531:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800534:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 30                	mov    (%eax),%esi
  800542:	85 f6                	test   %esi,%esi
  800544:	75 05                	jne    80054b <vprintfmt+0x185>
				p = "(null)";
  800546:	be 9c 20 80 00       	mov    $0x80209c,%esi
			if (width > 0 && padc != '-')
  80054b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054f:	0f 8e 84 00 00 00    	jle    8005d9 <vprintfmt+0x213>
  800555:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800559:	74 7e                	je     8005d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 8b 02 00 00       	call   8007f2 <strnlen>
  800567:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800573:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800576:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800579:	89 de                	mov    %ebx,%esi
  80057b:	89 d3                	mov    %edx,%ebx
  80057d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0b                	jmp    80058c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	89 3c 24             	mov    %edi,(%esp)
  800588:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	4b                   	dec    %ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f f1                	jg     800581 <vprintfmt+0x1bb>
  800590:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800593:	89 f3                	mov    %esi,%ebx
  800595:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059b:	85 c0                	test   %eax,%eax
  80059d:	79 05                	jns    8005a4 <vprintfmt+0x1de>
  80059f:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a7:	29 c2                	sub    %eax,%edx
  8005a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ac:	eb 2b                	jmp    8005d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b2:	74 18                	je     8005cc <vprintfmt+0x206>
  8005b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b7:	83 fa 5e             	cmp    $0x5e,%edx
  8005ba:	76 10                	jbe    8005cc <vprintfmt+0x206>
					putch('?', putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
  8005ca:	eb 0a                	jmp    8005d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d9:	0f be 06             	movsbl (%esi),%eax
  8005dc:	46                   	inc    %esi
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	74 21                	je     800602 <vprintfmt+0x23c>
  8005e1:	85 ff                	test   %edi,%edi
  8005e3:	78 c9                	js     8005ae <vprintfmt+0x1e8>
  8005e5:	4f                   	dec    %edi
  8005e6:	79 c6                	jns    8005ae <vprintfmt+0x1e8>
  8005e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005eb:	89 de                	mov    %ebx,%esi
  8005ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f0:	eb 18                	jmp    80060a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ff:	4b                   	dec    %ebx
  800600:	eb 08                	jmp    80060a <vprintfmt+0x244>
  800602:	8b 7d 08             	mov    0x8(%ebp),%edi
  800605:	89 de                	mov    %ebx,%esi
  800607:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060a:	85 db                	test   %ebx,%ebx
  80060c:	7f e4                	jg     8005f2 <vprintfmt+0x22c>
  80060e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800611:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800616:	e9 ce fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061b:	83 f9 01             	cmp    $0x1,%ecx
  80061e:	7e 10                	jle    800630 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 08             	lea    0x8(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	8b 78 04             	mov    0x4(%eax),%edi
  80062e:	eb 26                	jmp    800656 <vprintfmt+0x290>
	else if (lflag)
  800630:	85 c9                	test   %ecx,%ecx
  800632:	74 12                	je     800646 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 30                	mov    (%eax),%esi
  80063f:	89 f7                	mov    %esi,%edi
  800641:	c1 ff 1f             	sar    $0x1f,%edi
  800644:	eb 10                	jmp    800656 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 30                	mov    (%eax),%esi
  800651:	89 f7                	mov    %esi,%edi
  800653:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800656:	85 ff                	test   %edi,%edi
  800658:	78 0a                	js     800664 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065f:	e9 8c 00 00 00       	jmp    8006f0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800672:	f7 de                	neg    %esi
  800674:	83 d7 00             	adc    $0x0,%edi
  800677:	f7 df                	neg    %edi
			}
			base = 10;
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067e:	eb 70                	jmp    8006f0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 c0 fc ff ff       	call   80034a <getuint>
  80068a:	89 c6                	mov    %eax,%esi
  80068c:	89 d7                	mov    %edx,%edi
			base = 10;
  80068e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800693:	eb 5b                	jmp    8006f0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800695:	89 ca                	mov    %ecx,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 ab fc ff ff       	call   80034a <getuint>
  80069f:	89 c6                	mov    %eax,%esi
  8006a1:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a8:	eb 46                	jmp    8006f0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006db:	eb 13                	jmp    8006f0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	89 ca                	mov    %ecx,%edx
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 63 fc ff ff       	call   80034a <getuint>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800703:	89 34 24             	mov    %esi,(%esp)
  800706:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	e8 6c fb ff ff       	call   800280 <printnum>
			break;
  800714:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800717:	e9 cd fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 bb fc ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	eb 01                	jmp    80073f <vprintfmt+0x379>
  80073e:	4e                   	dec    %esi
  80073f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800743:	75 f9                	jne    80073e <vprintfmt+0x378>
  800745:	e9 9f fc ff ff       	jmp    8003e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 4c             	add    $0x4c,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 28             	sub    $0x28,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 30                	je     8007a3 <vsnprintf+0x51>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 33                	jle    8007aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800793:	e8 2e fc ff ff       	call   8003c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	eb 0c                	jmp    8007af <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a8:	eb 05                	jmp    8007af <vsnprintf+0x5d>
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007be:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 7b ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
	...

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800821:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f5                	jne    80081e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	89 1c 24             	mov    %ebx,(%esp)
  800839:	e8 9e ff ff ff       	call   8007dc <strlen>
	strcpy(dst + len, src);
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 54 24 04          	mov    %edx,0x4(%esp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 c0 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086a:	eb 0c                	jmp    800878 <strncpy+0x21>
		*dst++ = *src;
  80086c:	8a 1a                	mov    (%edx),%bl
  80086e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 3a 01             	cmpb   $0x1,(%edx)
  800874:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	41                   	inc    %ecx
  800878:	39 f1                	cmp    %esi,%ecx
  80087a:	75 f0                	jne    80086c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 0a                	jne    80089c <strlcpy+0x1c>
  800892:	89 f0                	mov    %esi,%eax
  800894:	eb 1a                	jmp    8008b0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800896:	88 18                	mov    %bl,(%eax)
  800898:	40                   	inc    %eax
  800899:	41                   	inc    %ecx
  80089a:	eb 02                	jmp    80089e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089e:	4a                   	dec    %edx
  80089f:	74 0a                	je     8008ab <strlcpy+0x2b>
  8008a1:	8a 19                	mov    (%ecx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ef                	jne    800896 <strlcpy+0x16>
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	eb 02                	jmp    8008ad <strlcpy+0x2d>
  8008ab:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ad:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b0:	29 f0                	sub    %esi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bf:	eb 02                	jmp    8008c3 <strcmp+0xd>
		p++, q++;
  8008c1:	41                   	inc    %ecx
  8008c2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	8a 01                	mov    (%ecx),%al
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x17>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 f4                	je     8008c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 03                	jmp    8008e9 <strncmp+0x12>
		n--, p++, q++;
  8008e6:	4a                   	dec    %edx
  8008e7:	40                   	inc    %eax
  8008e8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 14                	je     800901 <strncmp+0x2a>
  8008ed:	8a 18                	mov    (%eax),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	74 04                	je     8008f7 <strncmp+0x20>
  8008f3:	3a 19                	cmp    (%ecx),%bl
  8008f5:	74 ef                	je     8008e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 00             	movzbl (%eax),%eax
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
  8008ff:	eb 05                	jmp    800906 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	eb 05                	jmp    800919 <strchr+0x10>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0c                	je     800924 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	40                   	inc    %eax
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f5                	jne    800914 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092f:	eb 05                	jmp    800936 <strfind+0x10>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 07                	je     80093c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800935:	40                   	inc    %eax
  800936:	8a 10                	mov    (%eax),%dl
  800938:	84 d2                	test   %dl,%dl
  80093a:	75 f5                	jne    800931 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 7d 08             	mov    0x8(%ebp),%edi
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 30                	je     800981 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 25                	jne    80097e <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 20                	jne    80097e <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 d0                	or     %edx,%eax
  800974:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800976:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800979:	fc                   	cld    
  80097a:	f3 ab                	rep stos %eax,%es:(%edi)
  80097c:	eb 03                	jmp    800981 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097e:	fc                   	cld    
  80097f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 34                	jae    8009ce <memmove+0x46>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	73 2d                	jae    8009ce <memmove+0x46>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 1b                	jne    8009c4 <memmove+0x3c>
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 13                	jne    8009c4 <memmove+0x3c>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0e                	jne    8009c4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 07                	jmp    8009cb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	4f                   	dec    %edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 20                	jmp    8009ee <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d4:	75 13                	jne    8009e9 <memmove+0x61>
  8009d6:	a8 03                	test   $0x3,%al
  8009d8:	75 0f                	jne    8009e9 <memmove+0x61>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009df:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 77 ff ff ff       	call   800988 <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	eb 16                	jmp    800a3f <memcmp+0x2c>
		if (*s1 != *s2)
  800a29:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a2c:	42                   	inc    %edx
  800a2d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a31:	38 c8                	cmp    %cl,%al
  800a33:	74 0a                	je     800a3f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 c9             	movzbl %cl,%ecx
  800a3b:	29 c8                	sub    %ecx,%eax
  800a3d:	eb 09                	jmp    800a48 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	75 e6                	jne    800a29 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5b:	eb 05                	jmp    800a62 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 05                	je     800a66 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	40                   	inc    %eax
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	72 f7                	jb     800a5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	eb 01                	jmp    800a77 <strtol+0xf>
		s++;
  800a76:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f9                	je     800a76 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f5                	je     800a76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	75 08                	jne    800a8d <strtol+0x25>
		s++;
  800a85:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 13                	jmp    800aa0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 0a                	jne    800a9b <strtol+0x33>
		s++, neg = 1;
  800a91:	8d 52 01             	lea    0x1(%edx),%edx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi
  800a99:	eb 05                	jmp    800aa0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	74 05                	je     800aa9 <strtol+0x41>
  800aa4:	83 fb 10             	cmp    $0x10,%ebx
  800aa7:	75 28                	jne    800ad1 <strtol+0x69>
  800aa9:	8a 02                	mov    (%edx),%al
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 10                	jne    800abf <strtol+0x57>
  800aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab3:	75 0a                	jne    800abf <strtol+0x57>
		s += 2, base = 16;
  800ab5:	83 c2 02             	add    $0x2,%edx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb 12                	jmp    800ad1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 0e                	jne    800ad1 <strtol+0x69>
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 05                	jne    800acc <strtol+0x64>
		s++, base = 8;
  800ac7:	42                   	inc    %edx
  800ac8:	b3 08                	mov    $0x8,%bl
  800aca:	eb 05                	jmp    800ad1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad8:	8a 0a                	mov    (%edx),%cl
  800ada:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800add:	80 fb 09             	cmp    $0x9,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x82>
			dig = *s - '0';
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 30             	sub    $0x30,%ecx
  800ae8:	eb 1e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aea:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0x92>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0e                	jmp    800b08 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 12                	ja     800b14 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b08:	39 f1                	cmp    %esi,%ecx
  800b0a:	7d 0c                	jge    800b18 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b0c:	42                   	inc    %edx
  800b0d:	0f af c6             	imul   %esi,%eax
  800b10:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b12:	eb c4                	jmp    800ad8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	89 c1                	mov    %eax,%ecx
  800b16:	eb 02                	jmp    800b1a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b18:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1e:	74 05                	je     800b25 <strtol+0xbd>
		*endptr = (char *) s;
  800b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b23:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b25:	85 ff                	test   %edi,%edi
  800b27:	74 04                	je     800b2d <strtol+0xc5>
  800b29:	89 c8                	mov    %ecx,%eax
  800b2b:	f7 d8                	neg    %eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
	...

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 28                	jle    800bbb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bae:	00 
  800baf:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800bb6:	e8 b1 f5 ff ff       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	83 c4 2c             	add    $0x2c,%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800c48:	e8 1f f5 ff ff       	call   80016c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	8b 75 18             	mov    0x18(%ebp),%esi
  800c66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 28                	jle    800ca0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c83:	00 
  800c84:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800c8b:	00 
  800c8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c93:	00 
  800c94:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800c9b:	e8 cc f4 ff ff       	call   80016c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca0:	83 c4 2c             	add    $0x2c,%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800cee:	e8 79 f4 ff ff       	call   80016c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	83 c4 2c             	add    $0x2c,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	89 de                	mov    %ebx,%esi
  800d18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 28                	jle    800d46 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d22:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d29:	00 
  800d2a:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800d31:	00 
  800d32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d39:	00 
  800d3a:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800d41:	e8 26 f4 ff ff       	call   80016c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d46:	83 c4 2c             	add    $0x2c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800d94:	e8 d3 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 df                	mov    %ebx,%edi
  800dbc:	89 de                	mov    %ebx,%esi
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 28                	jle    800dec <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800de7:	e8 80 f3 ff ff       	call   80016c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dec:	83 c4 2c             	add    $0x2c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	be 00 00 00 00       	mov    $0x0,%esi
  800dff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 cb                	mov    %ecx,%ebx
  800e2f:	89 cf                	mov    %ecx,%edi
  800e31:	89 ce                	mov    %ecx,%esi
  800e33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800e5c:	e8 0b f3 ff ff       	call   80016c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	00 00                	add    %al,(%eax)
	...

00800e6c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	05 00 00 00 30       	add    $0x30000000,%eax
  800e77:	c1 e8 0c             	shr    $0xc,%eax
}
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e82:	8b 45 08             	mov    0x8(%ebp),%eax
  800e85:	89 04 24             	mov    %eax,(%esp)
  800e88:	e8 df ff ff ff       	call   800e6c <fd2num>
  800e8d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e92:	c1 e0 0c             	shl    $0xc,%eax
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	53                   	push   %ebx
  800e9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e9e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ea3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	c1 ea 16             	shr    $0x16,%edx
  800eaa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb1:	f6 c2 01             	test   $0x1,%dl
  800eb4:	74 11                	je     800ec7 <fd_alloc+0x30>
  800eb6:	89 c2                	mov    %eax,%edx
  800eb8:	c1 ea 0c             	shr    $0xc,%edx
  800ebb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec2:	f6 c2 01             	test   $0x1,%dl
  800ec5:	75 09                	jne    800ed0 <fd_alloc+0x39>
			*fd_store = fd;
  800ec7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ece:	eb 17                	jmp    800ee7 <fd_alloc+0x50>
  800ed0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ed5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eda:	75 c7                	jne    800ea3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800edc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800ee2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ee7:	5b                   	pop    %ebx
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ef0:	83 f8 1f             	cmp    $0x1f,%eax
  800ef3:	77 36                	ja     800f2b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ef5:	05 00 00 0d 00       	add    $0xd0000,%eax
  800efa:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800efd:	89 c2                	mov    %eax,%edx
  800eff:	c1 ea 16             	shr    $0x16,%edx
  800f02:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f09:	f6 c2 01             	test   $0x1,%dl
  800f0c:	74 24                	je     800f32 <fd_lookup+0x48>
  800f0e:	89 c2                	mov    %eax,%edx
  800f10:	c1 ea 0c             	shr    $0xc,%edx
  800f13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1a:	f6 c2 01             	test   $0x1,%dl
  800f1d:	74 1a                	je     800f39 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f22:	89 02                	mov    %eax,(%edx)
	return 0;
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
  800f29:	eb 13                	jmp    800f3e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f30:	eb 0c                	jmp    800f3e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f37:	eb 05                	jmp    800f3e <fd_lookup+0x54>
  800f39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	53                   	push   %ebx
  800f44:	83 ec 14             	sub    $0x14,%esp
  800f47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800f4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f52:	eb 0e                	jmp    800f62 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f54:	39 08                	cmp    %ecx,(%eax)
  800f56:	75 09                	jne    800f61 <dev_lookup+0x21>
			*dev = devtab[i];
  800f58:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5f:	eb 33                	jmp    800f94 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f61:	42                   	inc    %edx
  800f62:	8b 04 95 2c 24 80 00 	mov    0x80242c(,%edx,4),%eax
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	75 e7                	jne    800f54 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f6d:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f72:	8b 40 48             	mov    0x48(%eax),%eax
  800f75:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7d:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  800f84:	e8 db f2 ff ff       	call   800264 <cprintf>
	*dev = 0;
  800f89:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f94:	83 c4 14             	add    $0x14,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 30             	sub    $0x30,%esp
  800fa2:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa5:	8a 45 0c             	mov    0xc(%ebp),%al
  800fa8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fab:	89 34 24             	mov    %esi,(%esp)
  800fae:	e8 b9 fe ff ff       	call   800e6c <fd2num>
  800fb3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fb6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fba:	89 04 24             	mov    %eax,(%esp)
  800fbd:	e8 28 ff ff ff       	call   800eea <fd_lookup>
  800fc2:	89 c3                	mov    %eax,%ebx
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 05                	js     800fcd <fd_close+0x33>
	    || fd != fd2)
  800fc8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fcb:	74 0d                	je     800fda <fd_close+0x40>
		return (must_exist ? r : 0);
  800fcd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fd1:	75 46                	jne    801019 <fd_close+0x7f>
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	eb 3f                	jmp    801019 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe1:	8b 06                	mov    (%esi),%eax
  800fe3:	89 04 24             	mov    %eax,(%esp)
  800fe6:	e8 55 ff ff ff       	call   800f40 <dev_lookup>
  800feb:	89 c3                	mov    %eax,%ebx
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 18                	js     801009 <fd_close+0x6f>
		if (dev->dev_close)
  800ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff4:	8b 40 10             	mov    0x10(%eax),%eax
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	74 09                	je     801004 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ffb:	89 34 24             	mov    %esi,(%esp)
  800ffe:	ff d0                	call   *%eax
  801000:	89 c3                	mov    %eax,%ebx
  801002:	eb 05                	jmp    801009 <fd_close+0x6f>
		else
			r = 0;
  801004:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801009:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801014:	e8 8f fc ff ff       	call   800ca8 <sys_page_unmap>
	return r;
}
  801019:	89 d8                	mov    %ebx,%eax
  80101b:	83 c4 30             	add    $0x30,%esp
  80101e:	5b                   	pop    %ebx
  80101f:	5e                   	pop    %esi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801028:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102f:	8b 45 08             	mov    0x8(%ebp),%eax
  801032:	89 04 24             	mov    %eax,(%esp)
  801035:	e8 b0 fe ff ff       	call   800eea <fd_lookup>
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 13                	js     801051 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80103e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801045:	00 
  801046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801049:	89 04 24             	mov    %eax,(%esp)
  80104c:	e8 49 ff ff ff       	call   800f9a <fd_close>
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <close_all>:

void
close_all(void)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80105f:	89 1c 24             	mov    %ebx,(%esp)
  801062:	e8 bb ff ff ff       	call   801022 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801067:	43                   	inc    %ebx
  801068:	83 fb 20             	cmp    $0x20,%ebx
  80106b:	75 f2                	jne    80105f <close_all+0xc>
		close(i);
}
  80106d:	83 c4 14             	add    $0x14,%esp
  801070:	5b                   	pop    %ebx
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 4c             	sub    $0x4c,%esp
  80107c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801082:	89 44 24 04          	mov    %eax,0x4(%esp)
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	89 04 24             	mov    %eax,(%esp)
  80108c:	e8 59 fe ff ff       	call   800eea <fd_lookup>
  801091:	89 c3                	mov    %eax,%ebx
  801093:	85 c0                	test   %eax,%eax
  801095:	0f 88 e1 00 00 00    	js     80117c <dup+0x109>
		return r;
	close(newfdnum);
  80109b:	89 3c 24             	mov    %edi,(%esp)
  80109e:	e8 7f ff ff ff       	call   801022 <close>

	newfd = INDEX2FD(newfdnum);
  8010a3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010a9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 c5 fd ff ff       	call   800e7c <fd2data>
  8010b7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010b9:	89 34 24             	mov    %esi,(%esp)
  8010bc:	e8 bb fd ff ff       	call   800e7c <fd2data>
  8010c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c4:	89 d8                	mov    %ebx,%eax
  8010c6:	c1 e8 16             	shr    $0x16,%eax
  8010c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d0:	a8 01                	test   $0x1,%al
  8010d2:	74 46                	je     80111a <dup+0xa7>
  8010d4:	89 d8                	mov    %ebx,%eax
  8010d6:	c1 e8 0c             	shr    $0xc,%eax
  8010d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e0:	f6 c2 01             	test   $0x1,%dl
  8010e3:	74 35                	je     80111a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801103:	00 
  801104:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801108:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80110f:	e8 41 fb ff ff       	call   800c55 <sys_page_map>
  801114:	89 c3                	mov    %eax,%ebx
  801116:	85 c0                	test   %eax,%eax
  801118:	78 3b                	js     801155 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80111a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111d:	89 c2                	mov    %eax,%edx
  80111f:	c1 ea 0c             	shr    $0xc,%edx
  801122:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801129:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80112f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801133:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801137:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80113e:	00 
  80113f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80114a:	e8 06 fb ff ff       	call   800c55 <sys_page_map>
  80114f:	89 c3                	mov    %eax,%ebx
  801151:	85 c0                	test   %eax,%eax
  801153:	79 25                	jns    80117a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801155:	89 74 24 04          	mov    %esi,0x4(%esp)
  801159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801160:	e8 43 fb ff ff       	call   800ca8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801165:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801173:	e8 30 fb ff ff       	call   800ca8 <sys_page_unmap>
	return r;
  801178:	eb 02                	jmp    80117c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80117a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80117c:	89 d8                	mov    %ebx,%eax
  80117e:	83 c4 4c             	add    $0x4c,%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	83 ec 24             	sub    $0x24,%esp
  80118d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801190:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801193:	89 44 24 04          	mov    %eax,0x4(%esp)
  801197:	89 1c 24             	mov    %ebx,(%esp)
  80119a:	e8 4b fd ff ff       	call   800eea <fd_lookup>
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 6d                	js     801210 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ad:	8b 00                	mov    (%eax),%eax
  8011af:	89 04 24             	mov    %eax,(%esp)
  8011b2:	e8 89 fd ff ff       	call   800f40 <dev_lookup>
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 55                	js     801210 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011be:	8b 50 08             	mov    0x8(%eax),%edx
  8011c1:	83 e2 03             	and    $0x3,%edx
  8011c4:	83 fa 01             	cmp    $0x1,%edx
  8011c7:	75 23                	jne    8011ec <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011ce:	8b 40 48             	mov    0x48(%eax),%eax
  8011d1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d9:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  8011e0:	e8 7f f0 ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  8011e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ea:	eb 24                	jmp    801210 <read+0x8a>
	}
	if (!dev->dev_read)
  8011ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ef:	8b 52 08             	mov    0x8(%edx),%edx
  8011f2:	85 d2                	test   %edx,%edx
  8011f4:	74 15                	je     80120b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801200:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801204:	89 04 24             	mov    %eax,(%esp)
  801207:	ff d2                	call   *%edx
  801209:	eb 05                	jmp    801210 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80120b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801210:	83 c4 24             	add    $0x24,%esp
  801213:	5b                   	pop    %ebx
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	57                   	push   %edi
  80121a:	56                   	push   %esi
  80121b:	53                   	push   %ebx
  80121c:	83 ec 1c             	sub    $0x1c,%esp
  80121f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801222:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122a:	eb 23                	jmp    80124f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122c:	89 f0                	mov    %esi,%eax
  80122e:	29 d8                	sub    %ebx,%eax
  801230:	89 44 24 08          	mov    %eax,0x8(%esp)
  801234:	8b 45 0c             	mov    0xc(%ebp),%eax
  801237:	01 d8                	add    %ebx,%eax
  801239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123d:	89 3c 24             	mov    %edi,(%esp)
  801240:	e8 41 ff ff ff       	call   801186 <read>
		if (m < 0)
  801245:	85 c0                	test   %eax,%eax
  801247:	78 10                	js     801259 <readn+0x43>
			return m;
		if (m == 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	74 0a                	je     801257 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124d:	01 c3                	add    %eax,%ebx
  80124f:	39 f3                	cmp    %esi,%ebx
  801251:	72 d9                	jb     80122c <readn+0x16>
  801253:	89 d8                	mov    %ebx,%eax
  801255:	eb 02                	jmp    801259 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801257:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801259:	83 c4 1c             	add    $0x1c,%esp
  80125c:	5b                   	pop    %ebx
  80125d:	5e                   	pop    %esi
  80125e:	5f                   	pop    %edi
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	53                   	push   %ebx
  801265:	83 ec 24             	sub    $0x24,%esp
  801268:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801272:	89 1c 24             	mov    %ebx,(%esp)
  801275:	e8 70 fc ff ff       	call   800eea <fd_lookup>
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 68                	js     8012e6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801281:	89 44 24 04          	mov    %eax,0x4(%esp)
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	8b 00                	mov    (%eax),%eax
  80128a:	89 04 24             	mov    %eax,(%esp)
  80128d:	e8 ae fc ff ff       	call   800f40 <dev_lookup>
  801292:	85 c0                	test   %eax,%eax
  801294:	78 50                	js     8012e6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801296:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801299:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129d:	75 23                	jne    8012c2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80129f:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8012a4:	8b 40 48             	mov    0x48(%eax),%eax
  8012a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012af:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  8012b6:	e8 a9 ef ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  8012bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c0:	eb 24                	jmp    8012e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8012c8:	85 d2                	test   %edx,%edx
  8012ca:	74 15                	je     8012e1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012da:	89 04 24             	mov    %eax,(%esp)
  8012dd:	ff d2                	call   *%edx
  8012df:	eb 05                	jmp    8012e6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012e6:	83 c4 24             	add    $0x24,%esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fc:	89 04 24             	mov    %eax,(%esp)
  8012ff:	e8 e6 fb ff ff       	call   800eea <fd_lookup>
  801304:	85 c0                	test   %eax,%eax
  801306:	78 0e                	js     801316 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801308:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80130b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 24             	sub    $0x24,%esp
  80131f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801322:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801325:	89 44 24 04          	mov    %eax,0x4(%esp)
  801329:	89 1c 24             	mov    %ebx,(%esp)
  80132c:	e8 b9 fb ff ff       	call   800eea <fd_lookup>
  801331:	85 c0                	test   %eax,%eax
  801333:	78 61                	js     801396 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133f:	8b 00                	mov    (%eax),%eax
  801341:	89 04 24             	mov    %eax,(%esp)
  801344:	e8 f7 fb ff ff       	call   800f40 <dev_lookup>
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 49                	js     801396 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80134d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801350:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801354:	75 23                	jne    801379 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801356:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80135b:	8b 40 48             	mov    0x48(%eax),%eax
  80135e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801362:	89 44 24 04          	mov    %eax,0x4(%esp)
  801366:	c7 04 24 cc 23 80 00 	movl   $0x8023cc,(%esp)
  80136d:	e8 f2 ee ff ff       	call   800264 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801372:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801377:	eb 1d                	jmp    801396 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801379:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80137c:	8b 52 18             	mov    0x18(%edx),%edx
  80137f:	85 d2                	test   %edx,%edx
  801381:	74 0e                	je     801391 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801383:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801386:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80138a:	89 04 24             	mov    %eax,(%esp)
  80138d:	ff d2                	call   *%edx
  80138f:	eb 05                	jmp    801396 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801391:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801396:	83 c4 24             	add    $0x24,%esp
  801399:	5b                   	pop    %ebx
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 24             	sub    $0x24,%esp
  8013a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	89 04 24             	mov    %eax,(%esp)
  8013b3:	e8 32 fb ff ff       	call   800eea <fd_lookup>
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 52                	js     80140e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	8b 00                	mov    (%eax),%eax
  8013c8:	89 04 24             	mov    %eax,(%esp)
  8013cb:	e8 70 fb ff ff       	call   800f40 <dev_lookup>
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 3a                	js     80140e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8013d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013db:	74 2c                	je     801409 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e7:	00 00 00 
	stat->st_isdir = 0;
  8013ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f1:	00 00 00 
	stat->st_dev = dev;
  8013f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801401:	89 14 24             	mov    %edx,(%esp)
  801404:	ff 50 14             	call   *0x14(%eax)
  801407:	eb 05                	jmp    80140e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801409:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80140e:	83 c4 24             	add    $0x24,%esp
  801411:	5b                   	pop    %ebx
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801423:	00 
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	89 04 24             	mov    %eax,(%esp)
  80142a:	e8 fe 01 00 00       	call   80162d <open>
  80142f:	89 c3                	mov    %eax,%ebx
  801431:	85 c0                	test   %eax,%eax
  801433:	78 1b                	js     801450 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801435:	8b 45 0c             	mov    0xc(%ebp),%eax
  801438:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143c:	89 1c 24             	mov    %ebx,(%esp)
  80143f:	e8 58 ff ff ff       	call   80139c <fstat>
  801444:	89 c6                	mov    %eax,%esi
	close(fd);
  801446:	89 1c 24             	mov    %ebx,(%esp)
  801449:	e8 d4 fb ff ff       	call   801022 <close>
	return r;
  80144e:	89 f3                	mov    %esi,%ebx
}
  801450:	89 d8                	mov    %ebx,%eax
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    
  801459:	00 00                	add    %al,(%eax)
	...

0080145c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	83 ec 10             	sub    $0x10,%esp
  801464:	89 c3                	mov    %eax,%ebx
  801466:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801468:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80146f:	75 11                	jne    801482 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801471:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801478:	e8 3a 08 00 00       	call   801cb7 <ipc_find_env>
  80147d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801482:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801489:	00 
  80148a:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  801491:	00 
  801492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801496:	a1 00 40 80 00       	mov    0x804000,%eax
  80149b:	89 04 24             	mov    %eax,(%esp)
  80149e:	e8 aa 07 00 00       	call   801c4d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014aa:	00 
  8014ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b6:	e8 29 07 00 00       	call   801be4 <ipc_recv>
}
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5e                   	pop    %esi
  8014c0:	5d                   	pop    %ebp
  8014c1:	c3                   	ret    

008014c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ce:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8014d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d6:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014db:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e5:	e8 72 ff ff ff       	call   80145c <fsipc>
}
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f8:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8014fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801502:	b8 06 00 00 00       	mov    $0x6,%eax
  801507:	e8 50 ff ff ff       	call   80145c <fsipc>
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	53                   	push   %ebx
  801512:	83 ec 14             	sub    $0x14,%esp
  801515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801518:	8b 45 08             	mov    0x8(%ebp),%eax
  80151b:	8b 40 0c             	mov    0xc(%eax),%eax
  80151e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801523:	ba 00 00 00 00       	mov    $0x0,%edx
  801528:	b8 05 00 00 00       	mov    $0x5,%eax
  80152d:	e8 2a ff ff ff       	call   80145c <fsipc>
  801532:	85 c0                	test   %eax,%eax
  801534:	78 2b                	js     801561 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801536:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  80153d:	00 
  80153e:	89 1c 24             	mov    %ebx,(%esp)
  801541:	e8 c9 f2 ff ff       	call   80080f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801546:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80154b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801551:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801556:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801561:	83 c4 14             	add    $0x14,%esp
  801564:	5b                   	pop    %ebx
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80156d:	c7 44 24 08 3c 24 80 	movl   $0x80243c,0x8(%esp)
  801574:	00 
  801575:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80157c:	00 
  80157d:	c7 04 24 5a 24 80 00 	movl   $0x80245a,(%esp)
  801584:	e8 e3 eb ff ff       	call   80016c <_panic>

00801589 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	83 ec 10             	sub    $0x10,%esp
  801591:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801594:	8b 45 08             	mov    0x8(%ebp),%eax
  801597:	8b 40 0c             	mov    0xc(%eax),%eax
  80159a:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  80159f:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	b8 03 00 00 00       	mov    $0x3,%eax
  8015af:	e8 a8 fe ff ff       	call   80145c <fsipc>
  8015b4:	89 c3                	mov    %eax,%ebx
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 6a                	js     801624 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8015ba:	39 c6                	cmp    %eax,%esi
  8015bc:	73 24                	jae    8015e2 <devfile_read+0x59>
  8015be:	c7 44 24 0c 65 24 80 	movl   $0x802465,0xc(%esp)
  8015c5:	00 
  8015c6:	c7 44 24 08 6c 24 80 	movl   $0x80246c,0x8(%esp)
  8015cd:	00 
  8015ce:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015d5:	00 
  8015d6:	c7 04 24 5a 24 80 00 	movl   $0x80245a,(%esp)
  8015dd:	e8 8a eb ff ff       	call   80016c <_panic>
	assert(r <= PGSIZE);
  8015e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015e7:	7e 24                	jle    80160d <devfile_read+0x84>
  8015e9:	c7 44 24 0c 81 24 80 	movl   $0x802481,0xc(%esp)
  8015f0:	00 
  8015f1:	c7 44 24 08 6c 24 80 	movl   $0x80246c,0x8(%esp)
  8015f8:	00 
  8015f9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801600:	00 
  801601:	c7 04 24 5a 24 80 00 	movl   $0x80245a,(%esp)
  801608:	e8 5f eb ff ff       	call   80016c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80160d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801611:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801618:	00 
  801619:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161c:	89 04 24             	mov    %eax,(%esp)
  80161f:	e8 64 f3 ff ff       	call   800988 <memmove>
	return r;
}
  801624:	89 d8                	mov    %ebx,%eax
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	5b                   	pop    %ebx
  80162a:	5e                   	pop    %esi
  80162b:	5d                   	pop    %ebp
  80162c:	c3                   	ret    

0080162d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	56                   	push   %esi
  801631:	53                   	push   %ebx
  801632:	83 ec 20             	sub    $0x20,%esp
  801635:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801638:	89 34 24             	mov    %esi,(%esp)
  80163b:	e8 9c f1 ff ff       	call   8007dc <strlen>
  801640:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801645:	7f 60                	jg     8016a7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164a:	89 04 24             	mov    %eax,(%esp)
  80164d:	e8 45 f8 ff ff       	call   800e97 <fd_alloc>
  801652:	89 c3                	mov    %eax,%ebx
  801654:	85 c0                	test   %eax,%eax
  801656:	78 54                	js     8016ac <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801658:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165c:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  801663:	e8 a7 f1 ff ff       	call   80080f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166b:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801670:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801673:	b8 01 00 00 00       	mov    $0x1,%eax
  801678:	e8 df fd ff ff       	call   80145c <fsipc>
  80167d:	89 c3                	mov    %eax,%ebx
  80167f:	85 c0                	test   %eax,%eax
  801681:	79 15                	jns    801698 <open+0x6b>
		fd_close(fd, 0);
  801683:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80168a:	00 
  80168b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168e:	89 04 24             	mov    %eax,(%esp)
  801691:	e8 04 f9 ff ff       	call   800f9a <fd_close>
		return r;
  801696:	eb 14                	jmp    8016ac <open+0x7f>
	}

	return fd2num(fd);
  801698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169b:	89 04 24             	mov    %eax,(%esp)
  80169e:	e8 c9 f7 ff ff       	call   800e6c <fd2num>
  8016a3:	89 c3                	mov    %eax,%ebx
  8016a5:	eb 05                	jmp    8016ac <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016ac:	89 d8                	mov    %ebx,%eax
  8016ae:	83 c4 20             	add    $0x20,%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c5:	e8 92 fd ff ff       	call   80145c <fsipc>
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 10             	sub    $0x10,%esp
  8016d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	89 04 24             	mov    %eax,(%esp)
  8016dd:	e8 9a f7 ff ff       	call   800e7c <fd2data>
  8016e2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8016e4:	c7 44 24 04 8d 24 80 	movl   $0x80248d,0x4(%esp)
  8016eb:	00 
  8016ec:	89 34 24             	mov    %esi,(%esp)
  8016ef:	e8 1b f1 ff ff       	call   80080f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016f4:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f7:	2b 03                	sub    (%ebx),%eax
  8016f9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8016ff:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801706:	00 00 00 
	stat->st_dev = &devpipe;
  801709:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801710:	30 80 00 
	return 0;
}
  801713:	b8 00 00 00 00       	mov    $0x0,%eax
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5e                   	pop    %esi
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    

0080171f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	53                   	push   %ebx
  801723:	83 ec 14             	sub    $0x14,%esp
  801726:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801729:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80172d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801734:	e8 6f f5 ff ff       	call   800ca8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801739:	89 1c 24             	mov    %ebx,(%esp)
  80173c:	e8 3b f7 ff ff       	call   800e7c <fd2data>
  801741:	89 44 24 04          	mov    %eax,0x4(%esp)
  801745:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80174c:	e8 57 f5 ff ff       	call   800ca8 <sys_page_unmap>
}
  801751:	83 c4 14             	add    $0x14,%esp
  801754:	5b                   	pop    %ebx
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	57                   	push   %edi
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	83 ec 2c             	sub    $0x2c,%esp
  801760:	89 c7                	mov    %eax,%edi
  801762:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801765:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80176a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80176d:	89 3c 24             	mov    %edi,(%esp)
  801770:	e8 87 05 00 00       	call   801cfc <pageref>
  801775:	89 c6                	mov    %eax,%esi
  801777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80177a:	89 04 24             	mov    %eax,(%esp)
  80177d:	e8 7a 05 00 00       	call   801cfc <pageref>
  801782:	39 c6                	cmp    %eax,%esi
  801784:	0f 94 c0             	sete   %al
  801787:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80178a:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801790:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801793:	39 cb                	cmp    %ecx,%ebx
  801795:	75 08                	jne    80179f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801797:	83 c4 2c             	add    $0x2c,%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5f                   	pop    %edi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80179f:	83 f8 01             	cmp    $0x1,%eax
  8017a2:	75 c1                	jne    801765 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017a4:	8b 42 58             	mov    0x58(%edx),%eax
  8017a7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8017ae:	00 
  8017af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b7:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  8017be:	e8 a1 ea ff ff       	call   800264 <cprintf>
  8017c3:	eb a0                	jmp    801765 <_pipeisclosed+0xe>

008017c5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	57                   	push   %edi
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 1c             	sub    $0x1c,%esp
  8017ce:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017d1:	89 34 24             	mov    %esi,(%esp)
  8017d4:	e8 a3 f6 ff ff       	call   800e7c <fd2data>
  8017d9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017db:	bf 00 00 00 00       	mov    $0x0,%edi
  8017e0:	eb 3c                	jmp    80181e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017e2:	89 da                	mov    %ebx,%edx
  8017e4:	89 f0                	mov    %esi,%eax
  8017e6:	e8 6c ff ff ff       	call   801757 <_pipeisclosed>
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	75 38                	jne    801827 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017ef:	e8 ee f3 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017f4:	8b 43 04             	mov    0x4(%ebx),%eax
  8017f7:	8b 13                	mov    (%ebx),%edx
  8017f9:	83 c2 20             	add    $0x20,%edx
  8017fc:	39 d0                	cmp    %edx,%eax
  8017fe:	73 e2                	jae    8017e2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801800:	8b 55 0c             	mov    0xc(%ebp),%edx
  801803:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801806:	89 c2                	mov    %eax,%edx
  801808:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80180e:	79 05                	jns    801815 <devpipe_write+0x50>
  801810:	4a                   	dec    %edx
  801811:	83 ca e0             	or     $0xffffffe0,%edx
  801814:	42                   	inc    %edx
  801815:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801819:	40                   	inc    %eax
  80181a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80181d:	47                   	inc    %edi
  80181e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801821:	75 d1                	jne    8017f4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801823:	89 f8                	mov    %edi,%eax
  801825:	eb 05                	jmp    80182c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80182c:	83 c4 1c             	add    $0x1c,%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5f                   	pop    %edi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	57                   	push   %edi
  801838:	56                   	push   %esi
  801839:	53                   	push   %ebx
  80183a:	83 ec 1c             	sub    $0x1c,%esp
  80183d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801840:	89 3c 24             	mov    %edi,(%esp)
  801843:	e8 34 f6 ff ff       	call   800e7c <fd2data>
  801848:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80184a:	be 00 00 00 00       	mov    $0x0,%esi
  80184f:	eb 3a                	jmp    80188b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801851:	85 f6                	test   %esi,%esi
  801853:	74 04                	je     801859 <devpipe_read+0x25>
				return i;
  801855:	89 f0                	mov    %esi,%eax
  801857:	eb 40                	jmp    801899 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801859:	89 da                	mov    %ebx,%edx
  80185b:	89 f8                	mov    %edi,%eax
  80185d:	e8 f5 fe ff ff       	call   801757 <_pipeisclosed>
  801862:	85 c0                	test   %eax,%eax
  801864:	75 2e                	jne    801894 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801866:	e8 77 f3 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80186b:	8b 03                	mov    (%ebx),%eax
  80186d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801870:	74 df                	je     801851 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801872:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801877:	79 05                	jns    80187e <devpipe_read+0x4a>
  801879:	48                   	dec    %eax
  80187a:	83 c8 e0             	or     $0xffffffe0,%eax
  80187d:	40                   	inc    %eax
  80187e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801882:	8b 55 0c             	mov    0xc(%ebp),%edx
  801885:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801888:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80188a:	46                   	inc    %esi
  80188b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80188e:	75 db                	jne    80186b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801890:	89 f0                	mov    %esi,%eax
  801892:	eb 05                	jmp    801899 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801894:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801899:	83 c4 1c             	add    $0x1c,%esp
  80189c:	5b                   	pop    %ebx
  80189d:	5e                   	pop    %esi
  80189e:	5f                   	pop    %edi
  80189f:	5d                   	pop    %ebp
  8018a0:	c3                   	ret    

008018a1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	57                   	push   %edi
  8018a5:	56                   	push   %esi
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 3c             	sub    $0x3c,%esp
  8018aa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018b0:	89 04 24             	mov    %eax,(%esp)
  8018b3:	e8 df f5 ff ff       	call   800e97 <fd_alloc>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	0f 88 45 01 00 00    	js     801a07 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018c9:	00 
  8018ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d8:	e8 24 f3 ff ff       	call   800c01 <sys_page_alloc>
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	0f 88 20 01 00 00    	js     801a07 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8018ea:	89 04 24             	mov    %eax,(%esp)
  8018ed:	e8 a5 f5 ff ff       	call   800e97 <fd_alloc>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	0f 88 f8 00 00 00    	js     8019f4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018fc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801903:	00 
  801904:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801912:	e8 ea f2 ff ff       	call   800c01 <sys_page_alloc>
  801917:	89 c3                	mov    %eax,%ebx
  801919:	85 c0                	test   %eax,%eax
  80191b:	0f 88 d3 00 00 00    	js     8019f4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801921:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801924:	89 04 24             	mov    %eax,(%esp)
  801927:	e8 50 f5 ff ff       	call   800e7c <fd2data>
  80192c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80192e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801935:	00 
  801936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801941:	e8 bb f2 ff ff       	call   800c01 <sys_page_alloc>
  801946:	89 c3                	mov    %eax,%ebx
  801948:	85 c0                	test   %eax,%eax
  80194a:	0f 88 91 00 00 00    	js     8019e1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801953:	89 04 24             	mov    %eax,(%esp)
  801956:	e8 21 f5 ff ff       	call   800e7c <fd2data>
  80195b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801962:	00 
  801963:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801967:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80196e:	00 
  80196f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801973:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80197a:	e8 d6 f2 ff ff       	call   800c55 <sys_page_map>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	85 c0                	test   %eax,%eax
  801983:	78 4c                	js     8019d1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801985:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80198b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80198e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801990:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801993:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80199a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019a3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019a8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b2:	89 04 24             	mov    %eax,(%esp)
  8019b5:	e8 b2 f4 ff ff       	call   800e6c <fd2num>
  8019ba:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019bf:	89 04 24             	mov    %eax,(%esp)
  8019c2:	e8 a5 f4 ff ff       	call   800e6c <fd2num>
  8019c7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8019ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019cf:	eb 36                	jmp    801a07 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8019d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019dc:	e8 c7 f2 ff ff       	call   800ca8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8019e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ef:	e8 b4 f2 ff ff       	call   800ca8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8019f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a02:	e8 a1 f2 ff ff       	call   800ca8 <sys_page_unmap>
    err:
	return r;
}
  801a07:	89 d8                	mov    %ebx,%eax
  801a09:	83 c4 3c             	add    $0x3c,%esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5f                   	pop    %edi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 c1 f4 ff ff       	call   800eea <fd_lookup>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 15                	js     801a42 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a30:	89 04 24             	mov    %eax,(%esp)
  801a33:	e8 44 f4 ff ff       	call   800e7c <fd2data>
	return _pipeisclosed(fd, p);
  801a38:	89 c2                	mov    %eax,%edx
  801a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3d:	e8 15 fd ff ff       	call   801757 <_pipeisclosed>
}
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a47:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801a54:	c7 44 24 04 ac 24 80 	movl   $0x8024ac,0x4(%esp)
  801a5b:	00 
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	89 04 24             	mov    %eax,(%esp)
  801a62:	e8 a8 ed ff ff       	call   80080f <strcpy>
	return 0;
}
  801a67:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	57                   	push   %edi
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a7a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a7f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a85:	eb 30                	jmp    801ab7 <devcons_write+0x49>
		m = n - tot;
  801a87:	8b 75 10             	mov    0x10(%ebp),%esi
  801a8a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a8c:	83 fe 7f             	cmp    $0x7f,%esi
  801a8f:	76 05                	jbe    801a96 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801a91:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a96:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a9a:	03 45 0c             	add    0xc(%ebp),%eax
  801a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa1:	89 3c 24             	mov    %edi,(%esp)
  801aa4:	e8 df ee ff ff       	call   800988 <memmove>
		sys_cputs(buf, m);
  801aa9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aad:	89 3c 24             	mov    %edi,(%esp)
  801ab0:	e8 7f f0 ff ff       	call   800b34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab5:	01 f3                	add    %esi,%ebx
  801ab7:	89 d8                	mov    %ebx,%eax
  801ab9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801abc:	72 c9                	jb     801a87 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801abe:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5f                   	pop    %edi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801acf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ad3:	75 07                	jne    801adc <devcons_read+0x13>
  801ad5:	eb 25                	jmp    801afc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ad7:	e8 06 f1 ff ff       	call   800be2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801adc:	e8 71 f0 ff ff       	call   800b52 <sys_cgetc>
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	74 f2                	je     801ad7 <devcons_read+0xe>
  801ae5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 1d                	js     801b08 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801aeb:	83 f8 04             	cmp    $0x4,%eax
  801aee:	74 13                	je     801b03 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af3:	88 10                	mov    %dl,(%eax)
	return 1;
  801af5:	b8 01 00 00 00       	mov    $0x1,%eax
  801afa:	eb 0c                	jmp    801b08 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
  801b01:	eb 05                	jmp    801b08 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b10:	8b 45 08             	mov    0x8(%ebp),%eax
  801b13:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b16:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b1d:	00 
  801b1e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b21:	89 04 24             	mov    %eax,(%esp)
  801b24:	e8 0b f0 ff ff       	call   800b34 <sys_cputs>
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <getchar>:

int
getchar(void)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b31:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801b38:	00 
  801b39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b47:	e8 3a f6 ff ff       	call   801186 <read>
	if (r < 0)
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	78 0f                	js     801b5f <getchar+0x34>
		return r;
	if (r < 1)
  801b50:	85 c0                	test   %eax,%eax
  801b52:	7e 06                	jle    801b5a <getchar+0x2f>
		return -E_EOF;
	return c;
  801b54:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b58:	eb 05                	jmp    801b5f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b5a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b5f:	c9                   	leave  
  801b60:	c3                   	ret    

00801b61 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	89 04 24             	mov    %eax,(%esp)
  801b74:	e8 71 f3 ff ff       	call   800eea <fd_lookup>
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	78 11                	js     801b8e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b86:	39 10                	cmp    %edx,(%eax)
  801b88:	0f 94 c0             	sete   %al
  801b8b:	0f b6 c0             	movzbl %al,%eax
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <opencons>:

int
opencons(void)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b99:	89 04 24             	mov    %eax,(%esp)
  801b9c:	e8 f6 f2 ff ff       	call   800e97 <fd_alloc>
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 3c                	js     801be1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ba5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bac:	00 
  801bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbb:	e8 41 f0 ff ff       	call   800c01 <sys_page_alloc>
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 1d                	js     801be1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bc4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bd9:	89 04 24             	mov    %eax,(%esp)
  801bdc:	e8 8b f2 ff ff       	call   800e6c <fd2num>
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    
	...

00801be4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	57                   	push   %edi
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	83 ec 1c             	sub    $0x1c,%esp
  801bed:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bf3:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801bf6:	85 db                	test   %ebx,%ebx
  801bf8:	75 05                	jne    801bff <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801bfa:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801bff:	89 1c 24             	mov    %ebx,(%esp)
  801c02:	e8 10 f2 ff ff       	call   800e17 <sys_ipc_recv>
  801c07:	85 c0                	test   %eax,%eax
  801c09:	79 16                	jns    801c21 <ipc_recv+0x3d>
		*from_env_store = 0;
  801c0b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801c11:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801c17:	89 1c 24             	mov    %ebx,(%esp)
  801c1a:	e8 f8 f1 ff ff       	call   800e17 <sys_ipc_recv>
  801c1f:	eb 24                	jmp    801c45 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801c21:	85 f6                	test   %esi,%esi
  801c23:	74 0a                	je     801c2f <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801c25:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c2a:	8b 40 74             	mov    0x74(%eax),%eax
  801c2d:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801c2f:	85 ff                	test   %edi,%edi
  801c31:	74 0a                	je     801c3d <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801c33:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c38:	8b 40 78             	mov    0x78(%eax),%eax
  801c3b:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801c3d:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c42:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c45:	83 c4 1c             	add    $0x1c,%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5e                   	pop    %esi
  801c4a:	5f                   	pop    %edi
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	57                   	push   %edi
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	83 ec 1c             	sub    $0x1c,%esp
  801c56:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c5c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801c5f:	85 db                	test   %ebx,%ebx
  801c61:	75 05                	jne    801c68 <ipc_send+0x1b>
		pg = (void *)-1;
  801c63:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c68:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c70:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	89 04 24             	mov    %eax,(%esp)
  801c7a:	e8 75 f1 ff ff       	call   800df4 <sys_ipc_try_send>
		if (r == 0) {		
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	74 2c                	je     801caf <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801c83:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c86:	75 07                	jne    801c8f <ipc_send+0x42>
			sys_yield();
  801c88:	e8 55 ef ff ff       	call   800be2 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801c8d:	eb d9                	jmp    801c68 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801c8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c93:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  801c9a:	00 
  801c9b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801ca2:	00 
  801ca3:	c7 04 24 c6 24 80 00 	movl   $0x8024c6,(%esp)
  801caa:	e8 bd e4 ff ff       	call   80016c <_panic>
		}
	}
}
  801caf:	83 c4 1c             	add    $0x1c,%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5e                   	pop    %esi
  801cb4:	5f                   	pop    %edi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	53                   	push   %ebx
  801cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cc3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cca:	89 c2                	mov    %eax,%edx
  801ccc:	c1 e2 07             	shl    $0x7,%edx
  801ccf:	29 ca                	sub    %ecx,%edx
  801cd1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cd7:	8b 52 50             	mov    0x50(%edx),%edx
  801cda:	39 da                	cmp    %ebx,%edx
  801cdc:	75 0f                	jne    801ced <ipc_find_env+0x36>
			return envs[i].env_id;
  801cde:	c1 e0 07             	shl    $0x7,%eax
  801ce1:	29 c8                	sub    %ecx,%eax
  801ce3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ce8:	8b 40 40             	mov    0x40(%eax),%eax
  801ceb:	eb 0c                	jmp    801cf9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ced:	40                   	inc    %eax
  801cee:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cf3:	75 ce                	jne    801cc3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cf5:	66 b8 00 00          	mov    $0x0,%ax
}
  801cf9:	5b                   	pop    %ebx
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	c1 ea 16             	shr    $0x16,%edx
  801d07:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d0e:	f6 c2 01             	test   $0x1,%dl
  801d11:	74 1e                	je     801d31 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d13:	c1 e8 0c             	shr    $0xc,%eax
  801d16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d1d:	a8 01                	test   $0x1,%al
  801d1f:	74 17                	je     801d38 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d21:	c1 e8 0c             	shr    $0xc,%eax
  801d24:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d2b:	ef 
  801d2c:	0f b7 c0             	movzwl %ax,%eax
  801d2f:	eb 0c                	jmp    801d3d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
  801d36:	eb 05                	jmp    801d3d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    
	...

00801d40 <__udivdi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	83 ec 10             	sub    $0x10,%esp
  801d46:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d4a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d52:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d56:	89 cd                	mov    %ecx,%ebp
  801d58:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	75 2c                	jne    801d8c <__udivdi3+0x4c>
  801d60:	39 f9                	cmp    %edi,%ecx
  801d62:	77 68                	ja     801dcc <__udivdi3+0x8c>
  801d64:	85 c9                	test   %ecx,%ecx
  801d66:	75 0b                	jne    801d73 <__udivdi3+0x33>
  801d68:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	f7 f1                	div    %ecx
  801d71:	89 c1                	mov    %eax,%ecx
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	89 f8                	mov    %edi,%eax
  801d77:	f7 f1                	div    %ecx
  801d79:	89 c7                	mov    %eax,%edi
  801d7b:	89 f0                	mov    %esi,%eax
  801d7d:	f7 f1                	div    %ecx
  801d7f:	89 c6                	mov    %eax,%esi
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	89 fa                	mov    %edi,%edx
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	39 f8                	cmp    %edi,%eax
  801d8e:	77 2c                	ja     801dbc <__udivdi3+0x7c>
  801d90:	0f bd f0             	bsr    %eax,%esi
  801d93:	83 f6 1f             	xor    $0x1f,%esi
  801d96:	75 4c                	jne    801de4 <__udivdi3+0xa4>
  801d98:	39 f8                	cmp    %edi,%eax
  801d9a:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9f:	72 0a                	jb     801dab <__udivdi3+0x6b>
  801da1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801da5:	0f 87 ad 00 00 00    	ja     801e58 <__udivdi3+0x118>
  801dab:	be 01 00 00 00       	mov    $0x1,%esi
  801db0:	89 f0                	mov    %esi,%eax
  801db2:	89 fa                	mov    %edi,%edx
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    
  801dbb:	90                   	nop
  801dbc:	31 ff                	xor    %edi,%edi
  801dbe:	31 f6                	xor    %esi,%esi
  801dc0:	89 f0                	mov    %esi,%eax
  801dc2:	89 fa                	mov    %edi,%edx
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	5e                   	pop    %esi
  801dc8:	5f                   	pop    %edi
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    
  801dcb:	90                   	nop
  801dcc:	89 fa                	mov    %edi,%edx
  801dce:	89 f0                	mov    %esi,%eax
  801dd0:	f7 f1                	div    %ecx
  801dd2:	89 c6                	mov    %eax,%esi
  801dd4:	31 ff                	xor    %edi,%edi
  801dd6:	89 f0                	mov    %esi,%eax
  801dd8:	89 fa                	mov    %edi,%edx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	5e                   	pop    %esi
  801dde:	5f                   	pop    %edi
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    
  801de1:	8d 76 00             	lea    0x0(%esi),%esi
  801de4:	89 f1                	mov    %esi,%ecx
  801de6:	d3 e0                	shl    %cl,%eax
  801de8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dec:	b8 20 00 00 00       	mov    $0x20,%eax
  801df1:	29 f0                	sub    %esi,%eax
  801df3:	89 ea                	mov    %ebp,%edx
  801df5:	88 c1                	mov    %al,%cl
  801df7:	d3 ea                	shr    %cl,%edx
  801df9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801dfd:	09 ca                	or     %ecx,%edx
  801dff:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e03:	89 f1                	mov    %esi,%ecx
  801e05:	d3 e5                	shl    %cl,%ebp
  801e07:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801e0b:	89 fd                	mov    %edi,%ebp
  801e0d:	88 c1                	mov    %al,%cl
  801e0f:	d3 ed                	shr    %cl,%ebp
  801e11:	89 fa                	mov    %edi,%edx
  801e13:	89 f1                	mov    %esi,%ecx
  801e15:	d3 e2                	shl    %cl,%edx
  801e17:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e1b:	88 c1                	mov    %al,%cl
  801e1d:	d3 ef                	shr    %cl,%edi
  801e1f:	09 d7                	or     %edx,%edi
  801e21:	89 f8                	mov    %edi,%eax
  801e23:	89 ea                	mov    %ebp,%edx
  801e25:	f7 74 24 08          	divl   0x8(%esp)
  801e29:	89 d1                	mov    %edx,%ecx
  801e2b:	89 c7                	mov    %eax,%edi
  801e2d:	f7 64 24 0c          	mull   0xc(%esp)
  801e31:	39 d1                	cmp    %edx,%ecx
  801e33:	72 17                	jb     801e4c <__udivdi3+0x10c>
  801e35:	74 09                	je     801e40 <__udivdi3+0x100>
  801e37:	89 fe                	mov    %edi,%esi
  801e39:	31 ff                	xor    %edi,%edi
  801e3b:	e9 41 ff ff ff       	jmp    801d81 <__udivdi3+0x41>
  801e40:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e44:	89 f1                	mov    %esi,%ecx
  801e46:	d3 e2                	shl    %cl,%edx
  801e48:	39 c2                	cmp    %eax,%edx
  801e4a:	73 eb                	jae    801e37 <__udivdi3+0xf7>
  801e4c:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e4f:	31 ff                	xor    %edi,%edi
  801e51:	e9 2b ff ff ff       	jmp    801d81 <__udivdi3+0x41>
  801e56:	66 90                	xchg   %ax,%ax
  801e58:	31 f6                	xor    %esi,%esi
  801e5a:	e9 22 ff ff ff       	jmp    801d81 <__udivdi3+0x41>
	...

00801e60 <__umoddi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	83 ec 20             	sub    $0x20,%esp
  801e66:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e6a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e6e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e72:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e76:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e7a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e7e:	89 c7                	mov    %eax,%edi
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	85 ed                	test   %ebp,%ebp
  801e84:	75 16                	jne    801e9c <__umoddi3+0x3c>
  801e86:	39 f1                	cmp    %esi,%ecx
  801e88:	0f 86 a6 00 00 00    	jbe    801f34 <__umoddi3+0xd4>
  801e8e:	f7 f1                	div    %ecx
  801e90:	89 d0                	mov    %edx,%eax
  801e92:	31 d2                	xor    %edx,%edx
  801e94:	83 c4 20             	add    $0x20,%esp
  801e97:	5e                   	pop    %esi
  801e98:	5f                   	pop    %edi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    
  801e9b:	90                   	nop
  801e9c:	39 f5                	cmp    %esi,%ebp
  801e9e:	0f 87 ac 00 00 00    	ja     801f50 <__umoddi3+0xf0>
  801ea4:	0f bd c5             	bsr    %ebp,%eax
  801ea7:	83 f0 1f             	xor    $0x1f,%eax
  801eaa:	89 44 24 10          	mov    %eax,0x10(%esp)
  801eae:	0f 84 a8 00 00 00    	je     801f5c <__umoddi3+0xfc>
  801eb4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eb8:	d3 e5                	shl    %cl,%ebp
  801eba:	bf 20 00 00 00       	mov    $0x20,%edi
  801ebf:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801ec3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ec7:	89 f9                	mov    %edi,%ecx
  801ec9:	d3 e8                	shr    %cl,%eax
  801ecb:	09 e8                	or     %ebp,%eax
  801ecd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801ed1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ed5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ed9:	d3 e0                	shl    %cl,%eax
  801edb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801edf:	89 f2                	mov    %esi,%edx
  801ee1:	d3 e2                	shl    %cl,%edx
  801ee3:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801eed:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ef1:	89 f9                	mov    %edi,%ecx
  801ef3:	d3 e8                	shr    %cl,%eax
  801ef5:	09 d0                	or     %edx,%eax
  801ef7:	d3 ee                	shr    %cl,%esi
  801ef9:	89 f2                	mov    %esi,%edx
  801efb:	f7 74 24 18          	divl   0x18(%esp)
  801eff:	89 d6                	mov    %edx,%esi
  801f01:	f7 64 24 0c          	mull   0xc(%esp)
  801f05:	89 c5                	mov    %eax,%ebp
  801f07:	89 d1                	mov    %edx,%ecx
  801f09:	39 d6                	cmp    %edx,%esi
  801f0b:	72 67                	jb     801f74 <__umoddi3+0x114>
  801f0d:	74 75                	je     801f84 <__umoddi3+0x124>
  801f0f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f13:	29 e8                	sub    %ebp,%eax
  801f15:	19 ce                	sbb    %ecx,%esi
  801f17:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1b:	d3 e8                	shr    %cl,%eax
  801f1d:	89 f2                	mov    %esi,%edx
  801f1f:	89 f9                	mov    %edi,%ecx
  801f21:	d3 e2                	shl    %cl,%edx
  801f23:	09 d0                	or     %edx,%eax
  801f25:	89 f2                	mov    %esi,%edx
  801f27:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f2b:	d3 ea                	shr    %cl,%edx
  801f2d:	83 c4 20             	add    $0x20,%esp
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    
  801f34:	85 c9                	test   %ecx,%ecx
  801f36:	75 0b                	jne    801f43 <__umoddi3+0xe3>
  801f38:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3d:	31 d2                	xor    %edx,%edx
  801f3f:	f7 f1                	div    %ecx
  801f41:	89 c1                	mov    %eax,%ecx
  801f43:	89 f0                	mov    %esi,%eax
  801f45:	31 d2                	xor    %edx,%edx
  801f47:	f7 f1                	div    %ecx
  801f49:	89 f8                	mov    %edi,%eax
  801f4b:	e9 3e ff ff ff       	jmp    801e8e <__umoddi3+0x2e>
  801f50:	89 f2                	mov    %esi,%edx
  801f52:	83 c4 20             	add    $0x20,%esp
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    
  801f59:	8d 76 00             	lea    0x0(%esi),%esi
  801f5c:	39 f5                	cmp    %esi,%ebp
  801f5e:	72 04                	jb     801f64 <__umoddi3+0x104>
  801f60:	39 f9                	cmp    %edi,%ecx
  801f62:	77 06                	ja     801f6a <__umoddi3+0x10a>
  801f64:	89 f2                	mov    %esi,%edx
  801f66:	29 cf                	sub    %ecx,%edi
  801f68:	19 ea                	sbb    %ebp,%edx
  801f6a:	89 f8                	mov    %edi,%eax
  801f6c:	83 c4 20             	add    $0x20,%esp
  801f6f:	5e                   	pop    %esi
  801f70:	5f                   	pop    %edi
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    
  801f73:	90                   	nop
  801f74:	89 d1                	mov    %edx,%ecx
  801f76:	89 c5                	mov    %eax,%ebp
  801f78:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f7c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f80:	eb 8d                	jmp    801f0f <__umoddi3+0xaf>
  801f82:	66 90                	xchg   %ax,%ax
  801f84:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f88:	72 ea                	jb     801f74 <__umoddi3+0x114>
  801f8a:	89 f1                	mov    %esi,%ecx
  801f8c:	eb 81                	jmp    801f0f <__umoddi3+0xaf>
