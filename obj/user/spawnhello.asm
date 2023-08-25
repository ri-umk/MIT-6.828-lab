
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  80004d:	e8 aa 01 00 00       	call   8001fc <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 1e 25 80 	movl   $0x80251e,0x4(%esp)
  800061:	00 
  800062:	c7 04 24 1e 25 80 00 	movl   $0x80251e,(%esp)
  800069:	e8 52 1b 00 00       	call   801bc0 <spawnl>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 20                	jns    800092 <umain+0x5e>
		panic("spawn(hello) failed: %e", r);
  800072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800076:	c7 44 24 08 24 25 80 	movl   $0x802524,0x8(%esp)
  80007d:	00 
  80007e:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 3c 25 80 00 	movl   $0x80253c,(%esp)
  80008d:	e8 72 00 00 00       	call   800104 <_panic>
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	56                   	push   %esi
  800098:	53                   	push   %ebx
  800099:	83 ec 10             	sub    $0x10,%esp
  80009c:	8b 75 08             	mov    0x8(%ebp),%esi
  80009f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8000a2:	e8 b4 0a 00 00       	call   800b5b <sys_getenvid>
  8000a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b3:	c1 e0 07             	shl    $0x7,%eax
  8000b6:	29 d0                	sub    %edx,%eax
  8000b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000bd:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c2:	85 f6                	test   %esi,%esi
  8000c4:	7e 07                	jle    8000cd <libmain+0x39>
		binaryname = argv[0];
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 5b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d9:	e8 0a 00 00 00       	call   8000e8 <exit>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    
  8000e5:	00 00                	add    %al,(%eax)
	...

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ee:	e8 f8 0e 00 00       	call   800feb <close_all>
	sys_env_destroy(0);
  8000f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fa:	e8 0a 0a 00 00       	call   800b09 <sys_env_destroy>
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80010c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80010f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800115:	e8 41 0a 00 00       	call   800b5b <sys_getenvid>
  80011a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800128:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 58 25 80 00 	movl   $0x802558,(%esp)
  800137:	e8 c0 00 00 00       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800140:	8b 45 10             	mov    0x10(%ebp),%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 50 00 00 00       	call   80019b <vcprintf>
	cprintf("\n");
  80014b:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  800152:	e8 a5 00 00 00       	call   8001fc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800157:	cc                   	int3   
  800158:	eb fd                	jmp    800157 <_panic+0x53>
	...

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 14             	sub    $0x14,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016f:	40                   	inc    %eax
  800170:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	75 19                	jne    800192 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800179:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800180:	00 
  800181:	8d 43 08             	lea    0x8(%ebx),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 40 09 00 00       	call   800acc <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800192:	ff 43 04             	incl   0x4(%ebx)
}
  800195:	83 c4 14             	add    $0x14,%esp
  800198:	5b                   	pop    %ebx
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 5c 01 80 00 	movl   $0x80015c,(%esp)
  8001d7:	e8 82 01 00 00       	call   80035e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001dc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 d8 08 00 00       	call   800acc <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	89 44 24 04          	mov    %eax,0x4(%esp)
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	89 04 24             	mov    %eax,(%esp)
  80020f:	e8 87 ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  800214:	c9                   	leave  
  800215:	c3                   	ret    
	...

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 3c             	sub    $0x3c,%esp
  800221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800224:	89 d7                	mov    %edx,%edi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800235:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	85 c0                	test   %eax,%eax
  80023a:	75 08                	jne    800244 <printnum+0x2c>
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 57                	ja     80029b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	89 74 24 10          	mov    %esi,0x10(%esp)
  800248:	4b                   	dec    %ebx
  800249:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024d:	8b 45 10             	mov    0x10(%ebp),%eax
  800250:	89 44 24 08          	mov    %eax,0x8(%esp)
  800254:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800258:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80025c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800263:	00 
  800264:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	e8 2e 20 00 00       	call   8022a4 <__udivdi3>
  800276:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	89 54 24 04          	mov    %edx,0x4(%esp)
  800285:	89 fa                	mov    %edi,%edx
  800287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028a:	e8 89 ff ff ff       	call   800218 <printnum>
  80028f:	eb 0f                	jmp    8002a0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800295:	89 34 24             	mov    %esi,(%esp)
  800298:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	4b                   	dec    %ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f f1                	jg     800291 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b6:	00 
  8002b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	e8 fb 20 00 00       	call   8023c4 <__umoddi3>
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	0f be 80 7b 25 80 00 	movsbl 0x80257b(%eax),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002da:	83 c4 3c             	add    $0x3c,%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getuint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 0e                	jmp    80031a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800322:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800325:	8b 10                	mov    (%eax),%edx
  800327:	3b 50 04             	cmp    0x4(%eax),%edx
  80032a:	73 08                	jae    800334 <sprintputch+0x18>
		*b->buf++ = ch;
  80032c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032f:	88 0a                	mov    %cl,(%edx)
  800331:	42                   	inc    %edx
  800332:	89 10                	mov    %edx,(%eax)
}
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80033c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800343:	8b 45 10             	mov    0x10(%ebp),%eax
  800346:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 02 00 00 00       	call   80035e <vprintfmt>
	va_end(ap);
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 4c             	sub    $0x4c,%esp
  800367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036a:	8b 75 10             	mov    0x10(%ebp),%esi
  80036d:	eb 12                	jmp    800381 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036f:	85 c0                	test   %eax,%eax
  800371:	0f 84 6b 03 00 00    	je     8006e2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800377:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	0f b6 06             	movzbl (%esi),%eax
  800384:	46                   	inc    %esi
  800385:	83 f8 25             	cmp    $0x25,%eax
  800388:	75 e5                	jne    80036f <vprintfmt+0x11>
  80038a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80038e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800395:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80039a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a6:	eb 26                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003af:	eb 1d                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003b8:	eb 14                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c4:	eb 08                	jmp    8003ce <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	0f b6 06             	movzbl (%esi),%eax
  8003d1:	8d 56 01             	lea    0x1(%esi),%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003d7:	8a 16                	mov    (%esi),%dl
  8003d9:	83 ea 23             	sub    $0x23,%edx
  8003dc:	80 fa 55             	cmp    $0x55,%dl
  8003df:	0f 87 e1 02 00 00    	ja     8006c6 <vprintfmt+0x368>
  8003e5:	0f b6 d2             	movzbl %dl,%edx
  8003e8:	ff 24 95 c0 26 80 00 	jmp    *0x8026c0(,%edx,4)
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003fa:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003fe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800401:	8d 50 d0             	lea    -0x30(%eax),%edx
  800404:	83 fa 09             	cmp    $0x9,%edx
  800407:	77 2a                	ja     800433 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040a:	eb eb                	jmp    8003f7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041a:	eb 17                	jmp    800433 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80041c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800420:	78 98                	js     8003ba <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800425:	eb a7                	jmp    8003ce <vprintfmt+0x70>
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800431:	eb 9b                	jmp    8003ce <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800437:	79 95                	jns    8003ce <vprintfmt+0x70>
  800439:	eb 8b                	jmp    8003c6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043f:	eb 8d                	jmp    8003ce <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800459:	e9 23 ff ff ff       	jmp    800381 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	85 c0                	test   %eax,%eax
  80046b:	79 02                	jns    80046f <vprintfmt+0x111>
  80046d:	f7 d8                	neg    %eax
  80046f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800471:	83 f8 0f             	cmp    $0xf,%eax
  800474:	7f 0b                	jg     800481 <vprintfmt+0x123>
  800476:	8b 04 85 20 28 80 00 	mov    0x802820(,%eax,4),%eax
  80047d:	85 c0                	test   %eax,%eax
  80047f:	75 23                	jne    8004a4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800481:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800485:	c7 44 24 08 93 25 80 	movl   $0x802593,0x8(%esp)
  80048c:	00 
  80048d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 9a fe ff ff       	call   800336 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049f:	e9 dd fe ff ff       	jmp    800381 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a8:	c7 44 24 08 7a 29 80 	movl   $0x80297a,0x8(%esp)
  8004af:	00 
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	89 14 24             	mov    %edx,(%esp)
  8004ba:	e8 77 fe ff ff       	call   800336 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c2:	e9 ba fe ff ff       	jmp    800381 <vprintfmt+0x23>
  8004c7:	89 f9                	mov    %edi,%ecx
  8004c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 30                	mov    (%eax),%esi
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	75 05                	jne    8004e3 <vprintfmt+0x185>
				p = "(null)";
  8004de:	be 8c 25 80 00       	mov    $0x80258c,%esi
			if (width > 0 && padc != '-')
  8004e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e7:	0f 8e 84 00 00 00    	jle    800571 <vprintfmt+0x213>
  8004ed:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f1:	74 7e                	je     800571 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f7:	89 34 24             	mov    %esi,(%esp)
  8004fa:	e8 8b 02 00 00       	call   80078a <strnlen>
  8004ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800502:	29 c2                	sub    %eax,%edx
  800504:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800507:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80050b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80050e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800511:	89 de                	mov    %ebx,%esi
  800513:	89 d3                	mov    %edx,%ebx
  800515:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	eb 0b                	jmp    800524 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800519:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051d:	89 3c 24             	mov    %edi,(%esp)
  800520:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	4b                   	dec    %ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f f1                	jg     800519 <vprintfmt+0x1bb>
  800528:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80052b:	89 f3                	mov    %esi,%ebx
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	79 05                	jns    80053c <vprintfmt+0x1de>
  800537:	b8 00 00 00 00       	mov    $0x0,%eax
  80053c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80053f:	29 c2                	sub    %eax,%edx
  800541:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800544:	eb 2b                	jmp    800571 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800546:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054a:	74 18                	je     800564 <vprintfmt+0x206>
  80054c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054f:	83 fa 5e             	cmp    $0x5e,%edx
  800552:	76 10                	jbe    800564 <vprintfmt+0x206>
					putch('?', putdat);
  800554:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800558:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055f:	ff 55 08             	call   *0x8(%ebp)
  800562:	eb 0a                	jmp    80056e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	ff 4d e4             	decl   -0x1c(%ebp)
  800571:	0f be 06             	movsbl (%esi),%eax
  800574:	46                   	inc    %esi
  800575:	85 c0                	test   %eax,%eax
  800577:	74 21                	je     80059a <vprintfmt+0x23c>
  800579:	85 ff                	test   %edi,%edi
  80057b:	78 c9                	js     800546 <vprintfmt+0x1e8>
  80057d:	4f                   	dec    %edi
  80057e:	79 c6                	jns    800546 <vprintfmt+0x1e8>
  800580:	8b 7d 08             	mov    0x8(%ebp),%edi
  800583:	89 de                	mov    %ebx,%esi
  800585:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800588:	eb 18                	jmp    8005a2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800595:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	4b                   	dec    %ebx
  800598:	eb 08                	jmp    8005a2 <vprintfmt+0x244>
  80059a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059d:	89 de                	mov    %ebx,%esi
  80059f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	7f e4                	jg     80058a <vprintfmt+0x22c>
  8005a6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005a9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ae:	e9 ce fd ff ff       	jmp    800381 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b3:	83 f9 01             	cmp    $0x1,%ecx
  8005b6:	7e 10                	jle    8005c8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 08             	lea    0x8(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 30                	mov    (%eax),%esi
  8005c3:	8b 78 04             	mov    0x4(%eax),%edi
  8005c6:	eb 26                	jmp    8005ee <vprintfmt+0x290>
	else if (lflag)
  8005c8:	85 c9                	test   %ecx,%ecx
  8005ca:	74 12                	je     8005de <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 30                	mov    (%eax),%esi
  8005d7:	89 f7                	mov    %esi,%edi
  8005d9:	c1 ff 1f             	sar    $0x1f,%edi
  8005dc:	eb 10                	jmp    8005ee <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 30                	mov    (%eax),%esi
  8005e9:	89 f7                	mov    %esi,%edi
  8005eb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	78 0a                	js     8005fc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	e9 8c 00 00 00       	jmp    800688 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800600:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060a:	f7 de                	neg    %esi
  80060c:	83 d7 00             	adc    $0x0,%edi
  80060f:	f7 df                	neg    %edi
			}
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
  800616:	eb 70                	jmp    800688 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800618:	89 ca                	mov    %ecx,%edx
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 c0 fc ff ff       	call   8002e2 <getuint>
  800622:	89 c6                	mov    %eax,%esi
  800624:	89 d7                	mov    %edx,%edi
			base = 10;
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062b:	eb 5b                	jmp    800688 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80062d:	89 ca                	mov    %ecx,%edx
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 ab fc ff ff       	call   8002e2 <getuint>
  800637:	89 c6                	mov    %eax,%esi
  800639:	89 d7                	mov    %edx,%edi
			base = 8;
  80063b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800640:	eb 46                	jmp    800688 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800646:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800667:	8b 30                	mov    (%eax),%esi
  800669:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800673:	eb 13                	jmp    800688 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800675:	89 ca                	mov    %ecx,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 63 fc ff ff       	call   8002e2 <getuint>
  80067f:	89 c6                	mov    %eax,%esi
  800681:	89 d7                	mov    %edx,%edi
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80068c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800690:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800693:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800697:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069b:	89 34 24             	mov    %esi,(%esp)
  80069e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a2:	89 da                	mov    %ebx,%edx
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	e8 6c fb ff ff       	call   800218 <printnum>
			break;
  8006ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006af:	e9 cd fc ff ff       	jmp    800381 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	89 04 24             	mov    %eax,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c1:	e9 bb fc ff ff       	jmp    800381 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ca:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d4:	eb 01                	jmp    8006d7 <vprintfmt+0x379>
  8006d6:	4e                   	dec    %esi
  8006d7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006db:	75 f9                	jne    8006d6 <vprintfmt+0x378>
  8006dd:	e9 9f fc ff ff       	jmp    800381 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006e2:	83 c4 4c             	add    $0x4c,%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5f                   	pop    %edi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 28             	sub    $0x28,%esp
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800700:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800707:	85 c0                	test   %eax,%eax
  800709:	74 30                	je     80073b <vsnprintf+0x51>
  80070b:	85 d2                	test   %edx,%edx
  80070d:	7e 33                	jle    800742 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800716:	8b 45 10             	mov    0x10(%ebp),%eax
  800719:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800720:	89 44 24 04          	mov    %eax,0x4(%esp)
  800724:	c7 04 24 1c 03 80 00 	movl   $0x80031c,(%esp)
  80072b:	e8 2e fc ff ff       	call   80035e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	eb 0c                	jmp    800747 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800740:	eb 05                	jmp    800747 <vsnprintf+0x5d>
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800752:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800756:	8b 45 10             	mov    0x10(%ebp),%eax
  800759:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	e8 7b ff ff ff       	call   8006ea <vsnprintf>
	va_end(ap);

	return rc;
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    
  800771:	00 00                	add    %al,(%eax)
	...

00800774 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	eb 01                	jmp    800782 <strlen+0xe>
		n++;
  800781:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f9                	jne    800781 <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800790:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
  800798:	eb 01                	jmp    80079b <strnlen+0x11>
		n++;
  80079a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 d0                	cmp    %edx,%eax
  80079d:	74 06                	je     8007a5 <strnlen+0x1b>
  80079f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a3:	75 f5                	jne    80079a <strnlen+0x10>
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007b9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007bc:	42                   	inc    %edx
  8007bd:	84 c9                	test   %cl,%cl
  8007bf:	75 f5                	jne    8007b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ce:	89 1c 24             	mov    %ebx,(%esp)
  8007d1:	e8 9e ff ff ff       	call   800774 <strlen>
	strcpy(dst + len, src);
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007dd:	01 d8                	add    %ebx,%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	e8 c0 ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800802:	eb 0c                	jmp    800810 <strncpy+0x21>
		*dst++ = *src;
  800804:	8a 1a                	mov    (%edx),%bl
  800806:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800809:	80 3a 01             	cmpb   $0x1,(%edx)
  80080c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080f:	41                   	inc    %ecx
  800810:	39 f1                	cmp    %esi,%ecx
  800812:	75 f0                	jne    800804 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800823:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800826:	85 d2                	test   %edx,%edx
  800828:	75 0a                	jne    800834 <strlcpy+0x1c>
  80082a:	89 f0                	mov    %esi,%eax
  80082c:	eb 1a                	jmp    800848 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082e:	88 18                	mov    %bl,(%eax)
  800830:	40                   	inc    %eax
  800831:	41                   	inc    %ecx
  800832:	eb 02                	jmp    800836 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800836:	4a                   	dec    %edx
  800837:	74 0a                	je     800843 <strlcpy+0x2b>
  800839:	8a 19                	mov    (%ecx),%bl
  80083b:	84 db                	test   %bl,%bl
  80083d:	75 ef                	jne    80082e <strlcpy+0x16>
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 02                	jmp    800845 <strlcpy+0x2d>
  800843:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800845:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800848:	29 f0                	sub    %esi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800857:	eb 02                	jmp    80085b <strcmp+0xd>
		p++, q++;
  800859:	41                   	inc    %ecx
  80085a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085b:	8a 01                	mov    (%ecx),%al
  80085d:	84 c0                	test   %al,%al
  80085f:	74 04                	je     800865 <strcmp+0x17>
  800861:	3a 02                	cmp    (%edx),%al
  800863:	74 f4                	je     800859 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 c0             	movzbl %al,%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80087c:	eb 03                	jmp    800881 <strncmp+0x12>
		n--, p++, q++;
  80087e:	4a                   	dec    %edx
  80087f:	40                   	inc    %eax
  800880:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	85 d2                	test   %edx,%edx
  800883:	74 14                	je     800899 <strncmp+0x2a>
  800885:	8a 18                	mov    (%eax),%bl
  800887:	84 db                	test   %bl,%bl
  800889:	74 04                	je     80088f <strncmp+0x20>
  80088b:	3a 19                	cmp    (%ecx),%bl
  80088d:	74 ef                	je     80087e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 11             	movzbl (%ecx),%edx
  800895:	29 d0                	sub    %edx,%eax
  800897:	eb 05                	jmp    80089e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008aa:	eb 05                	jmp    8008b1 <strchr+0x10>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0c                	je     8008bc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	40                   	inc    %eax
  8008b1:	8a 10                	mov    (%eax),%dl
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f5                	jne    8008ac <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c7:	eb 05                	jmp    8008ce <strfind+0x10>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 07                	je     8008d4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008cd:	40                   	inc    %eax
  8008ce:	8a 10                	mov    (%eax),%dl
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f5                	jne    8008c9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 30                	je     800919 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 25                	jne    800916 <memset+0x40>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 20                	jne    800916 <memset+0x40>
		c &= 0xFF;
  8008f6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f9:	89 d3                	mov    %edx,%ebx
  8008fb:	c1 e3 08             	shl    $0x8,%ebx
  8008fe:	89 d6                	mov    %edx,%esi
  800900:	c1 e6 18             	shl    $0x18,%esi
  800903:	89 d0                	mov    %edx,%eax
  800905:	c1 e0 10             	shl    $0x10,%eax
  800908:	09 f0                	or     %esi,%eax
  80090a:	09 d0                	or     %edx,%eax
  80090c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800911:	fc                   	cld    
  800912:	f3 ab                	rep stos %eax,%es:(%edi)
  800914:	eb 03                	jmp    800919 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	89 f8                	mov    %edi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092e:	39 c6                	cmp    %eax,%esi
  800930:	73 34                	jae    800966 <memmove+0x46>
  800932:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800935:	39 d0                	cmp    %edx,%eax
  800937:	73 2d                	jae    800966 <memmove+0x46>
		s += n;
		d += n;
  800939:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	f6 c2 03             	test   $0x3,%dl
  80093f:	75 1b                	jne    80095c <memmove+0x3c>
  800941:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800947:	75 13                	jne    80095c <memmove+0x3c>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 0e                	jne    80095c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094e:	83 ef 04             	sub    $0x4,%edi
  800951:	8d 72 fc             	lea    -0x4(%edx),%esi
  800954:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800957:	fd                   	std    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 07                	jmp    800963 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095c:	4f                   	dec    %edi
  80095d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800960:	fd                   	std    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800963:	fc                   	cld    
  800964:	eb 20                	jmp    800986 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096c:	75 13                	jne    800981 <memmove+0x61>
  80096e:	a8 03                	test   $0x3,%al
  800970:	75 0f                	jne    800981 <memmove+0x61>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0a                	jne    800981 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800977:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097a:	89 c7                	mov    %eax,%edi
  80097c:	fc                   	cld    
  80097d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097f:	eb 05                	jmp    800986 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800990:	8b 45 10             	mov    0x10(%ebp),%eax
  800993:	89 44 24 08          	mov    %eax,0x8(%esp)
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	89 04 24             	mov    %eax,(%esp)
  8009a4:	e8 77 ff ff ff       	call   800920 <memmove>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	eb 16                	jmp    8009d7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009c4:	42                   	inc    %edx
  8009c5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009c9:	38 c8                	cmp    %cl,%al
  8009cb:	74 0a                	je     8009d7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009cd:	0f b6 c0             	movzbl %al,%eax
  8009d0:	0f b6 c9             	movzbl %cl,%ecx
  8009d3:	29 c8                	sub    %ecx,%eax
  8009d5:	eb 09                	jmp    8009e0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	39 da                	cmp    %ebx,%edx
  8009d9:	75 e6                	jne    8009c1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ee:	89 c2                	mov    %eax,%edx
  8009f0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f3:	eb 05                	jmp    8009fa <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	38 08                	cmp    %cl,(%eax)
  8009f7:	74 05                	je     8009fe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	40                   	inc    %eax
  8009fa:	39 d0                	cmp    %edx,%eax
  8009fc:	72 f7                	jb     8009f5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 55 08             	mov    0x8(%ebp),%edx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 01                	jmp    800a0f <strtol+0xf>
		s++;
  800a0e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	8a 02                	mov    (%edx),%al
  800a11:	3c 20                	cmp    $0x20,%al
  800a13:	74 f9                	je     800a0e <strtol+0xe>
  800a15:	3c 09                	cmp    $0x9,%al
  800a17:	74 f5                	je     800a0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a19:	3c 2b                	cmp    $0x2b,%al
  800a1b:	75 08                	jne    800a25 <strtol+0x25>
		s++;
  800a1d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a23:	eb 13                	jmp    800a38 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a25:	3c 2d                	cmp    $0x2d,%al
  800a27:	75 0a                	jne    800a33 <strtol+0x33>
		s++, neg = 1;
  800a29:	8d 52 01             	lea    0x1(%edx),%edx
  800a2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a31:	eb 05                	jmp    800a38 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	74 05                	je     800a41 <strtol+0x41>
  800a3c:	83 fb 10             	cmp    $0x10,%ebx
  800a3f:	75 28                	jne    800a69 <strtol+0x69>
  800a41:	8a 02                	mov    (%edx),%al
  800a43:	3c 30                	cmp    $0x30,%al
  800a45:	75 10                	jne    800a57 <strtol+0x57>
  800a47:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4b:	75 0a                	jne    800a57 <strtol+0x57>
		s += 2, base = 16;
  800a4d:	83 c2 02             	add    $0x2,%edx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb 12                	jmp    800a69 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	75 0e                	jne    800a69 <strtol+0x69>
  800a5b:	3c 30                	cmp    $0x30,%al
  800a5d:	75 05                	jne    800a64 <strtol+0x64>
		s++, base = 8;
  800a5f:	42                   	inc    %edx
  800a60:	b3 08                	mov    $0x8,%bl
  800a62:	eb 05                	jmp    800a69 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a64:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a70:	8a 0a                	mov    (%edx),%cl
  800a72:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a75:	80 fb 09             	cmp    $0x9,%bl
  800a78:	77 08                	ja     800a82 <strtol+0x82>
			dig = *s - '0';
  800a7a:	0f be c9             	movsbl %cl,%ecx
  800a7d:	83 e9 30             	sub    $0x30,%ecx
  800a80:	eb 1e                	jmp    800aa0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a82:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a8a:	0f be c9             	movsbl %cl,%ecx
  800a8d:	83 e9 57             	sub    $0x57,%ecx
  800a90:	eb 0e                	jmp    800aa0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a92:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 12                	ja     800aac <strtol+0xac>
			dig = *s - 'A' + 10;
  800a9a:	0f be c9             	movsbl %cl,%ecx
  800a9d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa0:	39 f1                	cmp    %esi,%ecx
  800aa2:	7d 0c                	jge    800ab0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aa4:	42                   	inc    %edx
  800aa5:	0f af c6             	imul   %esi,%eax
  800aa8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aaa:	eb c4                	jmp    800a70 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aac:	89 c1                	mov    %eax,%ecx
  800aae:	eb 02                	jmp    800ab2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab6:	74 05                	je     800abd <strtol+0xbd>
		*endptr = (char *) s;
  800ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800abd:	85 ff                	test   %edi,%edi
  800abf:	74 04                	je     800ac5 <strtol+0xc5>
  800ac1:	89 c8                	mov    %ecx,%eax
  800ac3:	f7 d8                	neg    %eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    
	...

00800acc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	89 c6                	mov    %eax,%esi
  800ae3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cgetc>:

int
sys_cgetc(void)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	89 cb                	mov    %ecx,%ebx
  800b21:	89 cf                	mov    %ecx,%edi
  800b23:	89 ce                	mov    %ecx,%esi
  800b25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 28                	jle    800b53 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b2f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b36:	00 
  800b37:	c7 44 24 08 7f 28 80 	movl   $0x80287f,0x8(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b46:	00 
  800b47:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800b4e:	e8 b1 f5 ff ff       	call   800104 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b53:	83 c4 2c             	add    $0x2c,%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_yield>:

void
sys_yield(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	be 00 00 00 00       	mov    $0x0,%esi
  800ba7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	89 f7                	mov    %esi,%edi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 28                	jle    800be5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bc8:	00 
  800bc9:	c7 44 24 08 7f 28 80 	movl   $0x80287f,0x8(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd8:	00 
  800bd9:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800be0:	e8 1f f5 ff ff       	call   800104 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be5:	83 c4 2c             	add    $0x2c,%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 28                	jle    800c38 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 08 7f 28 80 	movl   $0x80287f,0x8(%esp)
  800c23:	00 
  800c24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2b:	00 
  800c2c:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800c33:	e8 cc f4 ff ff       	call   800104 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c38:	83 c4 2c             	add    $0x2c,%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 28                	jle    800c8b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 08 7f 28 80 	movl   $0x80287f,0x8(%esp)
  800c76:	00 
  800c77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7e:	00 
  800c7f:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800c86:	e8 79 f4 ff ff       	call   800104 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8b:	83 c4 2c             	add    $0x2c,%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 28                	jle    800cde <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 08 7f 28 80 	movl   $0x80287f,0x8(%esp)
  800cc9:	00 
  800cca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd1:	00 
  800cd2:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800cd9:	e8 26 f4 ff ff       	call   800104 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cde:	83 c4 2c             	add    $0x2c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 28                	jle    800d31 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d14:	00 
  800d15:	c7 44 24 08 7f 28 80 	movl   $0x80287f,0x8(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d24:	00 
  800d25:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800d2c:	e8 d3 f3 ff ff       	call   800104 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d31:	83 c4 2c             	add    $0x2c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	89 df                	mov    %ebx,%edi
  800d54:	89 de                	mov    %ebx,%esi
  800d56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7e 28                	jle    800d84 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d60:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d67:	00 
  800d68:	c7 44 24 08 7f 28 80 	movl   $0x80287f,0x8(%esp)
  800d6f:	00 
  800d70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d77:	00 
  800d78:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800d7f:	e8 80 f3 ff ff       	call   800104 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d84:	83 c4 2c             	add    $0x2c,%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	be 00 00 00 00       	mov    $0x0,%esi
  800d97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	89 cb                	mov    %ecx,%ebx
  800dc7:	89 cf                	mov    %ecx,%edi
  800dc9:	89 ce                	mov    %ecx,%esi
  800dcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 28                	jle    800df9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 08 7f 28 80 	movl   $0x80287f,0x8(%esp)
  800de4:	00 
  800de5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dec:	00 
  800ded:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800df4:	e8 0b f3 ff ff       	call   800104 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df9:	83 c4 2c             	add    $0x2c,%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    
  800e01:	00 00                	add    %al,(%eax)
	...

00800e04 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	89 04 24             	mov    %eax,(%esp)
  800e20:	e8 df ff ff ff       	call   800e04 <fd2num>
  800e25:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e2a:	c1 e0 0c             	shl    $0xc,%eax
}
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	53                   	push   %ebx
  800e33:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e36:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e3b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	c1 ea 16             	shr    $0x16,%edx
  800e42:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e49:	f6 c2 01             	test   $0x1,%dl
  800e4c:	74 11                	je     800e5f <fd_alloc+0x30>
  800e4e:	89 c2                	mov    %eax,%edx
  800e50:	c1 ea 0c             	shr    $0xc,%edx
  800e53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5a:	f6 c2 01             	test   $0x1,%dl
  800e5d:	75 09                	jne    800e68 <fd_alloc+0x39>
			*fd_store = fd;
  800e5f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	eb 17                	jmp    800e7f <fd_alloc+0x50>
  800e68:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e6d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e72:	75 c7                	jne    800e3b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e74:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e7a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e7f:	5b                   	pop    %ebx
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e88:	83 f8 1f             	cmp    $0x1f,%eax
  800e8b:	77 36                	ja     800ec3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e92:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e95:	89 c2                	mov    %eax,%edx
  800e97:	c1 ea 16             	shr    $0x16,%edx
  800e9a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea1:	f6 c2 01             	test   $0x1,%dl
  800ea4:	74 24                	je     800eca <fd_lookup+0x48>
  800ea6:	89 c2                	mov    %eax,%edx
  800ea8:	c1 ea 0c             	shr    $0xc,%edx
  800eab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb2:	f6 c2 01             	test   $0x1,%dl
  800eb5:	74 1a                	je     800ed1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eba:	89 02                	mov    %eax,(%edx)
	return 0;
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec1:	eb 13                	jmp    800ed6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec8:	eb 0c                	jmp    800ed6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecf:	eb 05                	jmp    800ed6 <fd_lookup+0x54>
  800ed1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	53                   	push   %ebx
  800edc:	83 ec 14             	sub    $0x14,%esp
  800edf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eea:	eb 0e                	jmp    800efa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800eec:	39 08                	cmp    %ecx,(%eax)
  800eee:	75 09                	jne    800ef9 <dev_lookup+0x21>
			*dev = devtab[i];
  800ef0:	89 03                	mov    %eax,(%ebx)
			return 0;
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef7:	eb 33                	jmp    800f2c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef9:	42                   	inc    %edx
  800efa:	8b 04 95 28 29 80 00 	mov    0x802928(,%edx,4),%eax
  800f01:	85 c0                	test   %eax,%eax
  800f03:	75 e7                	jne    800eec <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f05:	a1 04 40 80 00       	mov    0x804004,%eax
  800f0a:	8b 40 48             	mov    0x48(%eax),%eax
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f15:	c7 04 24 ac 28 80 00 	movl   $0x8028ac,(%esp)
  800f1c:	e8 db f2 ff ff       	call   8001fc <cprintf>
	*dev = 0;
  800f21:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2c:	83 c4 14             	add    $0x14,%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 30             	sub    $0x30,%esp
  800f3a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3d:	8a 45 0c             	mov    0xc(%ebp),%al
  800f40:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f43:	89 34 24             	mov    %esi,(%esp)
  800f46:	e8 b9 fe ff ff       	call   800e04 <fd2num>
  800f4b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f52:	89 04 24             	mov    %eax,(%esp)
  800f55:	e8 28 ff ff ff       	call   800e82 <fd_lookup>
  800f5a:	89 c3                	mov    %eax,%ebx
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 05                	js     800f65 <fd_close+0x33>
	    || fd != fd2)
  800f60:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f63:	74 0d                	je     800f72 <fd_close+0x40>
		return (must_exist ? r : 0);
  800f65:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f69:	75 46                	jne    800fb1 <fd_close+0x7f>
  800f6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f70:	eb 3f                	jmp    800fb1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f72:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f79:	8b 06                	mov    (%esi),%eax
  800f7b:	89 04 24             	mov    %eax,(%esp)
  800f7e:	e8 55 ff ff ff       	call   800ed8 <dev_lookup>
  800f83:	89 c3                	mov    %eax,%ebx
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 18                	js     800fa1 <fd_close+0x6f>
		if (dev->dev_close)
  800f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f8c:	8b 40 10             	mov    0x10(%eax),%eax
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	74 09                	je     800f9c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f93:	89 34 24             	mov    %esi,(%esp)
  800f96:	ff d0                	call   *%eax
  800f98:	89 c3                	mov    %eax,%ebx
  800f9a:	eb 05                	jmp    800fa1 <fd_close+0x6f>
		else
			r = 0;
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fa1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fac:	e8 8f fc ff ff       	call   800c40 <sys_page_unmap>
	return r;
}
  800fb1:	89 d8                	mov    %ebx,%eax
  800fb3:	83 c4 30             	add    $0x30,%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fca:	89 04 24             	mov    %eax,(%esp)
  800fcd:	e8 b0 fe ff ff       	call   800e82 <fd_lookup>
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 13                	js     800fe9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800fd6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fdd:	00 
  800fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe1:	89 04 24             	mov    %eax,(%esp)
  800fe4:	e8 49 ff ff ff       	call   800f32 <fd_close>
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <close_all>:

void
close_all(void)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	53                   	push   %ebx
  800fef:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff7:	89 1c 24             	mov    %ebx,(%esp)
  800ffa:	e8 bb ff ff ff       	call   800fba <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fff:	43                   	inc    %ebx
  801000:	83 fb 20             	cmp    $0x20,%ebx
  801003:	75 f2                	jne    800ff7 <close_all+0xc>
		close(i);
}
  801005:	83 c4 14             	add    $0x14,%esp
  801008:	5b                   	pop    %ebx
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	83 ec 4c             	sub    $0x4c,%esp
  801014:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801017:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80101a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
  801021:	89 04 24             	mov    %eax,(%esp)
  801024:	e8 59 fe ff ff       	call   800e82 <fd_lookup>
  801029:	89 c3                	mov    %eax,%ebx
  80102b:	85 c0                	test   %eax,%eax
  80102d:	0f 88 e1 00 00 00    	js     801114 <dup+0x109>
		return r;
	close(newfdnum);
  801033:	89 3c 24             	mov    %edi,(%esp)
  801036:	e8 7f ff ff ff       	call   800fba <close>

	newfd = INDEX2FD(newfdnum);
  80103b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801041:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801047:	89 04 24             	mov    %eax,(%esp)
  80104a:	e8 c5 fd ff ff       	call   800e14 <fd2data>
  80104f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801051:	89 34 24             	mov    %esi,(%esp)
  801054:	e8 bb fd ff ff       	call   800e14 <fd2data>
  801059:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80105c:	89 d8                	mov    %ebx,%eax
  80105e:	c1 e8 16             	shr    $0x16,%eax
  801061:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801068:	a8 01                	test   $0x1,%al
  80106a:	74 46                	je     8010b2 <dup+0xa7>
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	c1 e8 0c             	shr    $0xc,%eax
  801071:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801078:	f6 c2 01             	test   $0x1,%dl
  80107b:	74 35                	je     8010b2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801084:	25 07 0e 00 00       	and    $0xe07,%eax
  801089:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801090:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801094:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80109b:	00 
  80109c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a7:	e8 41 fb ff ff       	call   800bed <sys_page_map>
  8010ac:	89 c3                	mov    %eax,%ebx
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 3b                	js     8010ed <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b5:	89 c2                	mov    %eax,%edx
  8010b7:	c1 ea 0c             	shr    $0xc,%edx
  8010ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010c7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010cb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010d6:	00 
  8010d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e2:	e8 06 fb ff ff       	call   800bed <sys_page_map>
  8010e7:	89 c3                	mov    %eax,%ebx
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	79 25                	jns    801112 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f8:	e8 43 fb ff ff       	call   800c40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801100:	89 44 24 04          	mov    %eax,0x4(%esp)
  801104:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80110b:	e8 30 fb ff ff       	call   800c40 <sys_page_unmap>
	return r;
  801110:	eb 02                	jmp    801114 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801112:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801114:	89 d8                	mov    %ebx,%eax
  801116:	83 c4 4c             	add    $0x4c,%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	53                   	push   %ebx
  801122:	83 ec 24             	sub    $0x24,%esp
  801125:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801128:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112f:	89 1c 24             	mov    %ebx,(%esp)
  801132:	e8 4b fd ff ff       	call   800e82 <fd_lookup>
  801137:	85 c0                	test   %eax,%eax
  801139:	78 6d                	js     8011a8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801142:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801145:	8b 00                	mov    (%eax),%eax
  801147:	89 04 24             	mov    %eax,(%esp)
  80114a:	e8 89 fd ff ff       	call   800ed8 <dev_lookup>
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 55                	js     8011a8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801153:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801156:	8b 50 08             	mov    0x8(%eax),%edx
  801159:	83 e2 03             	and    $0x3,%edx
  80115c:	83 fa 01             	cmp    $0x1,%edx
  80115f:	75 23                	jne    801184 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801161:	a1 04 40 80 00       	mov    0x804004,%eax
  801166:	8b 40 48             	mov    0x48(%eax),%eax
  801169:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80116d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801171:	c7 04 24 ed 28 80 00 	movl   $0x8028ed,(%esp)
  801178:	e8 7f f0 ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  80117d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801182:	eb 24                	jmp    8011a8 <read+0x8a>
	}
	if (!dev->dev_read)
  801184:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801187:	8b 52 08             	mov    0x8(%edx),%edx
  80118a:	85 d2                	test   %edx,%edx
  80118c:	74 15                	je     8011a3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80118e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801191:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801198:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80119c:	89 04 24             	mov    %eax,(%esp)
  80119f:	ff d2                	call   *%edx
  8011a1:	eb 05                	jmp    8011a8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011a8:	83 c4 24             	add    $0x24,%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	57                   	push   %edi
  8011b2:	56                   	push   %esi
  8011b3:	53                   	push   %ebx
  8011b4:	83 ec 1c             	sub    $0x1c,%esp
  8011b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c2:	eb 23                	jmp    8011e7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c4:	89 f0                	mov    %esi,%eax
  8011c6:	29 d8                	sub    %ebx,%eax
  8011c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cf:	01 d8                	add    %ebx,%eax
  8011d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d5:	89 3c 24             	mov    %edi,(%esp)
  8011d8:	e8 41 ff ff ff       	call   80111e <read>
		if (m < 0)
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 10                	js     8011f1 <readn+0x43>
			return m;
		if (m == 0)
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	74 0a                	je     8011ef <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e5:	01 c3                	add    %eax,%ebx
  8011e7:	39 f3                	cmp    %esi,%ebx
  8011e9:	72 d9                	jb     8011c4 <readn+0x16>
  8011eb:	89 d8                	mov    %ebx,%eax
  8011ed:	eb 02                	jmp    8011f1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011ef:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011f1:	83 c4 1c             	add    $0x1c,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 24             	sub    $0x24,%esp
  801200:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801203:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120a:	89 1c 24             	mov    %ebx,(%esp)
  80120d:	e8 70 fc ff ff       	call   800e82 <fd_lookup>
  801212:	85 c0                	test   %eax,%eax
  801214:	78 68                	js     80127e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801220:	8b 00                	mov    (%eax),%eax
  801222:	89 04 24             	mov    %eax,(%esp)
  801225:	e8 ae fc ff ff       	call   800ed8 <dev_lookup>
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 50                	js     80127e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801231:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801235:	75 23                	jne    80125a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801237:	a1 04 40 80 00       	mov    0x804004,%eax
  80123c:	8b 40 48             	mov    0x48(%eax),%eax
  80123f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801243:	89 44 24 04          	mov    %eax,0x4(%esp)
  801247:	c7 04 24 09 29 80 00 	movl   $0x802909,(%esp)
  80124e:	e8 a9 ef ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  801253:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801258:	eb 24                	jmp    80127e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80125a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125d:	8b 52 0c             	mov    0xc(%edx),%edx
  801260:	85 d2                	test   %edx,%edx
  801262:	74 15                	je     801279 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801264:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801267:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801272:	89 04 24             	mov    %eax,(%esp)
  801275:	ff d2                	call   *%edx
  801277:	eb 05                	jmp    80127e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801279:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80127e:	83 c4 24             	add    $0x24,%esp
  801281:	5b                   	pop    %ebx
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <seek>:

int
seek(int fdnum, off_t offset)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80128d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801291:	8b 45 08             	mov    0x8(%ebp),%eax
  801294:	89 04 24             	mov    %eax,(%esp)
  801297:	e8 e6 fb ff ff       	call   800e82 <fd_lookup>
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 0e                	js     8012ae <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ae:	c9                   	leave  
  8012af:	c3                   	ret    

008012b0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 24             	sub    $0x24,%esp
  8012b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c1:	89 1c 24             	mov    %ebx,(%esp)
  8012c4:	e8 b9 fb ff ff       	call   800e82 <fd_lookup>
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	78 61                	js     80132e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d7:	8b 00                	mov    (%eax),%eax
  8012d9:	89 04 24             	mov    %eax,(%esp)
  8012dc:	e8 f7 fb ff ff       	call   800ed8 <dev_lookup>
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 49                	js     80132e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ec:	75 23                	jne    801311 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ee:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f3:	8b 40 48             	mov    0x48(%eax),%eax
  8012f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fe:	c7 04 24 cc 28 80 00 	movl   $0x8028cc,(%esp)
  801305:	e8 f2 ee ff ff       	call   8001fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80130a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130f:	eb 1d                	jmp    80132e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801311:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801314:	8b 52 18             	mov    0x18(%edx),%edx
  801317:	85 d2                	test   %edx,%edx
  801319:	74 0e                	je     801329 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80131b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801322:	89 04 24             	mov    %eax,(%esp)
  801325:	ff d2                	call   *%edx
  801327:	eb 05                	jmp    80132e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801329:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80132e:	83 c4 24             	add    $0x24,%esp
  801331:	5b                   	pop    %ebx
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	53                   	push   %ebx
  801338:	83 ec 24             	sub    $0x24,%esp
  80133b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801341:	89 44 24 04          	mov    %eax,0x4(%esp)
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	e8 32 fb ff ff       	call   800e82 <fd_lookup>
  801350:	85 c0                	test   %eax,%eax
  801352:	78 52                	js     8013a6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135e:	8b 00                	mov    (%eax),%eax
  801360:	89 04 24             	mov    %eax,(%esp)
  801363:	e8 70 fb ff ff       	call   800ed8 <dev_lookup>
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 3a                	js     8013a6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80136c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801373:	74 2c                	je     8013a1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801375:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801378:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137f:	00 00 00 
	stat->st_isdir = 0;
  801382:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801389:	00 00 00 
	stat->st_dev = dev;
  80138c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801392:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801396:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801399:	89 14 24             	mov    %edx,(%esp)
  80139c:	ff 50 14             	call   *0x14(%eax)
  80139f:	eb 05                	jmp    8013a6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013a6:	83 c4 24             	add    $0x24,%esp
  8013a9:	5b                   	pop    %ebx
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013bb:	00 
  8013bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bf:	89 04 24             	mov    %eax,(%esp)
  8013c2:	e8 fe 01 00 00       	call   8015c5 <open>
  8013c7:	89 c3                	mov    %eax,%ebx
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 1b                	js     8013e8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d4:	89 1c 24             	mov    %ebx,(%esp)
  8013d7:	e8 58 ff ff ff       	call   801334 <fstat>
  8013dc:	89 c6                	mov    %eax,%esi
	close(fd);
  8013de:	89 1c 24             	mov    %ebx,(%esp)
  8013e1:	e8 d4 fb ff ff       	call   800fba <close>
	return r;
  8013e6:	89 f3                	mov    %esi,%ebx
}
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    
  8013f1:	00 00                	add    %al,(%eax)
	...

008013f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
  8013f9:	83 ec 10             	sub    $0x10,%esp
  8013fc:	89 c3                	mov    %eax,%ebx
  8013fe:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801400:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801407:	75 11                	jne    80141a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801409:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801410:	e8 06 0e 00 00       	call   80221b <ipc_find_env>
  801415:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80141a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801421:	00 
  801422:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801429:	00 
  80142a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80142e:	a1 00 40 80 00       	mov    0x804000,%eax
  801433:	89 04 24             	mov    %eax,(%esp)
  801436:	e8 76 0d 00 00       	call   8021b1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80143b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801442:	00 
  801443:	89 74 24 04          	mov    %esi,0x4(%esp)
  801447:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144e:	e8 f5 0c 00 00       	call   802148 <ipc_recv>
}
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	5b                   	pop    %ebx
  801457:	5e                   	pop    %esi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801460:	8b 45 08             	mov    0x8(%ebp),%eax
  801463:	8b 40 0c             	mov    0xc(%eax),%eax
  801466:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80146b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801473:	ba 00 00 00 00       	mov    $0x0,%edx
  801478:	b8 02 00 00 00       	mov    $0x2,%eax
  80147d:	e8 72 ff ff ff       	call   8013f4 <fsipc>
}
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	8b 40 0c             	mov    0xc(%eax),%eax
  801490:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	b8 06 00 00 00       	mov    $0x6,%eax
  80149f:	e8 50 ff ff ff       	call   8013f4 <fsipc>
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 14             	sub    $0x14,%esp
  8014ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c5:	e8 2a ff ff ff       	call   8013f4 <fsipc>
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 2b                	js     8014f9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ce:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014d5:	00 
  8014d6:	89 1c 24             	mov    %ebx,(%esp)
  8014d9:	e8 c9 f2 ff ff       	call   8007a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014de:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f9:	83 c4 14             	add    $0x14,%esp
  8014fc:	5b                   	pop    %ebx
  8014fd:	5d                   	pop    %ebp
  8014fe:	c3                   	ret    

008014ff <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801505:	c7 44 24 08 38 29 80 	movl   $0x802938,0x8(%esp)
  80150c:	00 
  80150d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801514:	00 
  801515:	c7 04 24 56 29 80 00 	movl   $0x802956,(%esp)
  80151c:	e8 e3 eb ff ff       	call   800104 <_panic>

00801521 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	56                   	push   %esi
  801525:	53                   	push   %ebx
  801526:	83 ec 10             	sub    $0x10,%esp
  801529:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152c:	8b 45 08             	mov    0x8(%ebp),%eax
  80152f:	8b 40 0c             	mov    0xc(%eax),%eax
  801532:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801537:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153d:	ba 00 00 00 00       	mov    $0x0,%edx
  801542:	b8 03 00 00 00       	mov    $0x3,%eax
  801547:	e8 a8 fe ff ff       	call   8013f4 <fsipc>
  80154c:	89 c3                	mov    %eax,%ebx
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 6a                	js     8015bc <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801552:	39 c6                	cmp    %eax,%esi
  801554:	73 24                	jae    80157a <devfile_read+0x59>
  801556:	c7 44 24 0c 61 29 80 	movl   $0x802961,0xc(%esp)
  80155d:	00 
  80155e:	c7 44 24 08 68 29 80 	movl   $0x802968,0x8(%esp)
  801565:	00 
  801566:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80156d:	00 
  80156e:	c7 04 24 56 29 80 00 	movl   $0x802956,(%esp)
  801575:	e8 8a eb ff ff       	call   800104 <_panic>
	assert(r <= PGSIZE);
  80157a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80157f:	7e 24                	jle    8015a5 <devfile_read+0x84>
  801581:	c7 44 24 0c 7d 29 80 	movl   $0x80297d,0xc(%esp)
  801588:	00 
  801589:	c7 44 24 08 68 29 80 	movl   $0x802968,0x8(%esp)
  801590:	00 
  801591:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801598:	00 
  801599:	c7 04 24 56 29 80 00 	movl   $0x802956,(%esp)
  8015a0:	e8 5f eb ff ff       	call   800104 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015a9:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015b0:	00 
  8015b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b4:	89 04 24             	mov    %eax,(%esp)
  8015b7:	e8 64 f3 ff ff       	call   800920 <memmove>
	return r;
}
  8015bc:	89 d8                	mov    %ebx,%eax
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5d                   	pop    %ebp
  8015c4:	c3                   	ret    

008015c5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	56                   	push   %esi
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 20             	sub    $0x20,%esp
  8015cd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d0:	89 34 24             	mov    %esi,(%esp)
  8015d3:	e8 9c f1 ff ff       	call   800774 <strlen>
  8015d8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015dd:	7f 60                	jg     80163f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	89 04 24             	mov    %eax,(%esp)
  8015e5:	e8 45 f8 ff ff       	call   800e2f <fd_alloc>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 54                	js     801644 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015fb:	e8 a7 f1 ff ff       	call   8007a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801600:	8b 45 0c             	mov    0xc(%ebp),%eax
  801603:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801608:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160b:	b8 01 00 00 00       	mov    $0x1,%eax
  801610:	e8 df fd ff ff       	call   8013f4 <fsipc>
  801615:	89 c3                	mov    %eax,%ebx
  801617:	85 c0                	test   %eax,%eax
  801619:	79 15                	jns    801630 <open+0x6b>
		fd_close(fd, 0);
  80161b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801622:	00 
  801623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801626:	89 04 24             	mov    %eax,(%esp)
  801629:	e8 04 f9 ff ff       	call   800f32 <fd_close>
		return r;
  80162e:	eb 14                	jmp    801644 <open+0x7f>
	}

	return fd2num(fd);
  801630:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801633:	89 04 24             	mov    %eax,(%esp)
  801636:	e8 c9 f7 ff ff       	call   800e04 <fd2num>
  80163b:	89 c3                	mov    %eax,%ebx
  80163d:	eb 05                	jmp    801644 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801644:	89 d8                	mov    %ebx,%eax
  801646:	83 c4 20             	add    $0x20,%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    

0080164d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801653:	ba 00 00 00 00       	mov    $0x0,%edx
  801658:	b8 08 00 00 00       	mov    $0x8,%eax
  80165d:	e8 92 fd ff ff       	call   8013f4 <fsipc>
}
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	57                   	push   %edi
  801668:	56                   	push   %esi
  801669:	53                   	push   %ebx
  80166a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801670:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801677:	00 
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 42 ff ff ff       	call   8015c5 <open>
  801683:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801689:	85 c0                	test   %eax,%eax
  80168b:	0f 88 05 05 00 00    	js     801b96 <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801691:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801698:	00 
  801699:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80169f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8016a9:	89 04 24             	mov    %eax,(%esp)
  8016ac:	e8 fd fa ff ff       	call   8011ae <readn>
  8016b1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016b6:	75 0c                	jne    8016c4 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8016b8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016bf:	45 4c 46 
  8016c2:	74 3b                	je     8016ff <spawn+0x9b>
		close(fd);
  8016c4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8016ca:	89 04 24             	mov    %eax,(%esp)
  8016cd:	e8 e8 f8 ff ff       	call   800fba <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016d2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8016d9:	46 
  8016da:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  8016e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e4:	c7 04 24 89 29 80 00 	movl   $0x802989,(%esp)
  8016eb:	e8 0c eb ff ff       	call   8001fc <cprintf>
		return -E_NOT_EXEC;
  8016f0:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  8016f7:	ff ff ff 
  8016fa:	e9 a3 04 00 00       	jmp    801ba2 <spawn+0x53e>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016ff:	ba 07 00 00 00       	mov    $0x7,%edx
  801704:	89 d0                	mov    %edx,%eax
  801706:	cd 30                	int    $0x30
  801708:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80170e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801714:	85 c0                	test   %eax,%eax
  801716:	0f 88 86 04 00 00    	js     801ba2 <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80171c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801721:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801728:	c1 e0 07             	shl    $0x7,%eax
  80172b:	29 d0                	sub    %edx,%eax
  80172d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801733:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801739:	b9 11 00 00 00       	mov    $0x11,%ecx
  80173e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801740:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801746:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80174c:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801751:	bb 00 00 00 00       	mov    $0x0,%ebx
  801756:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801759:	eb 0d                	jmp    801768 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80175b:	89 04 24             	mov    %eax,(%esp)
  80175e:	e8 11 f0 ff ff       	call   800774 <strlen>
  801763:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801767:	46                   	inc    %esi
  801768:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80176a:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801771:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801774:	85 c0                	test   %eax,%eax
  801776:	75 e3                	jne    80175b <spawn+0xf7>
  801778:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80177e:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801784:	bf 00 10 40 00       	mov    $0x401000,%edi
  801789:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80178b:	89 f8                	mov    %edi,%eax
  80178d:	83 e0 fc             	and    $0xfffffffc,%eax
  801790:	f7 d2                	not    %edx
  801792:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801795:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80179b:	89 d0                	mov    %edx,%eax
  80179d:	83 e8 08             	sub    $0x8,%eax
  8017a0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017a5:	0f 86 08 04 00 00    	jbe    801bb3 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017b2:	00 
  8017b3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8017ba:	00 
  8017bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c2:	e8 d2 f3 ff ff       	call   800b99 <sys_page_alloc>
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	0f 88 e9 03 00 00    	js     801bb8 <spawn+0x554>
  8017cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d4:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8017da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017dd:	eb 2e                	jmp    80180d <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8017df:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017e5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8017eb:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8017ee:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f5:	89 3c 24             	mov    %edi,(%esp)
  8017f8:	e8 aa ef ff ff       	call   8007a7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017fd:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801800:	89 04 24             	mov    %eax,(%esp)
  801803:	e8 6c ef ff ff       	call   800774 <strlen>
  801808:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80180c:	43                   	inc    %ebx
  80180d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801813:	7c ca                	jl     8017df <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801815:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80181b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801821:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801828:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80182e:	74 24                	je     801854 <spawn+0x1f0>
  801830:	c7 44 24 0c 00 2a 80 	movl   $0x802a00,0xc(%esp)
  801837:	00 
  801838:	c7 44 24 08 68 29 80 	movl   $0x802968,0x8(%esp)
  80183f:	00 
  801840:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801847:	00 
  801848:	c7 04 24 a3 29 80 00 	movl   $0x8029a3,(%esp)
  80184f:	e8 b0 e8 ff ff       	call   800104 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801854:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80185a:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80185f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801865:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801868:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80186e:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801871:	89 d0                	mov    %edx,%eax
  801873:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801878:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80187e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801885:	00 
  801886:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  80188d:	ee 
  80188e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801894:	89 44 24 08          	mov    %eax,0x8(%esp)
  801898:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80189f:	00 
  8018a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a7:	e8 41 f3 ff ff       	call   800bed <sys_page_map>
  8018ac:	89 c3                	mov    %eax,%ebx
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 1a                	js     8018cc <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018b2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018b9:	00 
  8018ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c1:	e8 7a f3 ff ff       	call   800c40 <sys_page_unmap>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	79 1f                	jns    8018eb <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8018cc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018d3:	00 
  8018d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018db:	e8 60 f3 ff ff       	call   800c40 <sys_page_unmap>
	return r;
  8018e0:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8018e6:	e9 b7 02 00 00       	jmp    801ba2 <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018eb:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8018f1:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8018f7:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018fd:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801904:	00 00 00 
  801907:	e9 bb 01 00 00       	jmp    801ac7 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  80190c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801912:	83 38 01             	cmpl   $0x1,(%eax)
  801915:	0f 85 9f 01 00 00    	jne    801aba <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80191b:	89 c2                	mov    %eax,%edx
  80191d:	8b 40 18             	mov    0x18(%eax),%eax
  801920:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801923:	83 f8 01             	cmp    $0x1,%eax
  801926:	19 c0                	sbb    %eax,%eax
  801928:	83 e0 fe             	and    $0xfffffffe,%eax
  80192b:	83 c0 07             	add    $0x7,%eax
  80192e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801934:	8b 52 04             	mov    0x4(%edx),%edx
  801937:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  80193d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801943:	8b 40 10             	mov    0x10(%eax),%eax
  801946:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80194c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801952:	8b 52 14             	mov    0x14(%edx),%edx
  801955:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  80195b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801961:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801964:	89 f8                	mov    %edi,%eax
  801966:	25 ff 0f 00 00       	and    $0xfff,%eax
  80196b:	74 16                	je     801983 <spawn+0x31f>
		va -= i;
  80196d:	29 c7                	sub    %eax,%edi
		memsz += i;
  80196f:	01 c2                	add    %eax,%edx
  801971:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801977:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  80197d:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801983:	bb 00 00 00 00       	mov    $0x0,%ebx
  801988:	e9 1f 01 00 00       	jmp    801aac <spawn+0x448>
		if (i >= filesz) {
  80198d:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801993:	77 2b                	ja     8019c0 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801995:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80199b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80199f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019a3:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8019a9:	89 04 24             	mov    %eax,(%esp)
  8019ac:	e8 e8 f1 ff ff       	call   800b99 <sys_page_alloc>
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	0f 89 e7 00 00 00    	jns    801aa0 <spawn+0x43c>
  8019b9:	89 c6                	mov    %eax,%esi
  8019bb:	e9 b2 01 00 00       	jmp    801b72 <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019c0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019c7:	00 
  8019c8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019cf:	00 
  8019d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d7:	e8 bd f1 ff ff       	call   800b99 <sys_page_alloc>
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	0f 88 84 01 00 00    	js     801b68 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8019e4:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8019ea:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8019f6:	89 04 24             	mov    %eax,(%esp)
  8019f9:	e8 86 f8 ff ff       	call   801284 <seek>
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	0f 88 66 01 00 00    	js     801b6c <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801a06:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a0c:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a0e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a13:	76 05                	jbe    801a1a <spawn+0x3b6>
  801a15:	b8 00 10 00 00       	mov    $0x1000,%eax
  801a1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a25:	00 
  801a26:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a2c:	89 04 24             	mov    %eax,(%esp)
  801a2f:	e8 7a f7 ff ff       	call   8011ae <readn>
  801a34:	85 c0                	test   %eax,%eax
  801a36:	0f 88 34 01 00 00    	js     801b70 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a3c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801a42:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a46:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a4a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a50:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a54:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a5b:	00 
  801a5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a63:	e8 85 f1 ff ff       	call   800bed <sys_page_map>
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	79 20                	jns    801a8c <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801a6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a70:	c7 44 24 08 af 29 80 	movl   $0x8029af,0x8(%esp)
  801a77:	00 
  801a78:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801a7f:	00 
  801a80:	c7 04 24 a3 29 80 00 	movl   $0x8029a3,(%esp)
  801a87:	e8 78 e6 ff ff       	call   800104 <_panic>
			sys_page_unmap(0, UTEMP);
  801a8c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a93:	00 
  801a94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9b:	e8 a0 f1 ff ff       	call   800c40 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801aa0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aa6:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801aac:	89 de                	mov    %ebx,%esi
  801aae:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801ab4:	0f 87 d3 fe ff ff    	ja     80198d <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aba:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801ac0:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801ac7:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801ace:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801ad4:	0f 8c 32 fe ff ff    	jl     80190c <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ada:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ae0:	89 04 24             	mov    %eax,(%esp)
  801ae3:	e8 d2 f4 ff ff       	call   800fba <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ae8:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801aef:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801af2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801af8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afc:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b02:	89 04 24             	mov    %eax,(%esp)
  801b05:	e8 dc f1 ff ff       	call   800ce6 <sys_env_set_trapframe>
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	79 20                	jns    801b2e <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  801b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b12:	c7 44 24 08 cc 29 80 	movl   $0x8029cc,0x8(%esp)
  801b19:	00 
  801b1a:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801b21:	00 
  801b22:	c7 04 24 a3 29 80 00 	movl   $0x8029a3,(%esp)
  801b29:	e8 d6 e5 ff ff       	call   800104 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b2e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801b35:	00 
  801b36:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b3c:	89 04 24             	mov    %eax,(%esp)
  801b3f:	e8 4f f1 ff ff       	call   800c93 <sys_env_set_status>
  801b44:	85 c0                	test   %eax,%eax
  801b46:	79 5a                	jns    801ba2 <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  801b48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b4c:	c7 44 24 08 e6 29 80 	movl   $0x8029e6,0x8(%esp)
  801b53:	00 
  801b54:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801b5b:	00 
  801b5c:	c7 04 24 a3 29 80 00 	movl   $0x8029a3,(%esp)
  801b63:	e8 9c e5 ff ff       	call   800104 <_panic>
  801b68:	89 c6                	mov    %eax,%esi
  801b6a:	eb 06                	jmp    801b72 <spawn+0x50e>
  801b6c:	89 c6                	mov    %eax,%esi
  801b6e:	eb 02                	jmp    801b72 <spawn+0x50e>
  801b70:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801b72:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b78:	89 04 24             	mov    %eax,(%esp)
  801b7b:	e8 89 ef ff ff       	call   800b09 <sys_env_destroy>
	close(fd);
  801b80:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b86:	89 04 24             	mov    %eax,(%esp)
  801b89:	e8 2c f4 ff ff       	call   800fba <close>
	return r;
  801b8e:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801b94:	eb 0c                	jmp    801ba2 <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b96:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b9c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ba2:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ba8:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5f                   	pop    %edi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801bb3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801bb8:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801bbe:	eb e2                	jmp    801ba2 <spawn+0x53e>

00801bc0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	57                   	push   %edi
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801bc9:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bd1:	eb 03                	jmp    801bd6 <spawnl+0x16>
		argc++;
  801bd3:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bd4:	89 d0                	mov    %edx,%eax
  801bd6:	8d 50 04             	lea    0x4(%eax),%edx
  801bd9:	83 38 00             	cmpl   $0x0,(%eax)
  801bdc:	75 f5                	jne    801bd3 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801bde:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801be5:	83 e0 f0             	and    $0xfffffff0,%eax
  801be8:	29 c4                	sub    %eax,%esp
  801bea:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801bee:	83 e7 f0             	and    $0xfffffff0,%edi
  801bf1:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf6:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801bf8:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801bff:	00 

	va_start(vl, arg0);
  801c00:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
  801c08:	eb 09                	jmp    801c13 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801c0a:	40                   	inc    %eax
  801c0b:	8b 1a                	mov    (%edx),%ebx
  801c0d:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801c10:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c13:	39 c8                	cmp    %ecx,%eax
  801c15:	75 f3                	jne    801c0a <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c17:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	89 04 24             	mov    %eax,(%esp)
  801c21:	e8 3e fa ff ff       	call   801664 <spawn>
}
  801c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c29:	5b                   	pop    %ebx
  801c2a:	5e                   	pop    %esi
  801c2b:	5f                   	pop    %edi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    
	...

00801c30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	83 ec 10             	sub    $0x10,%esp
  801c38:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 ce f1 ff ff       	call   800e14 <fd2data>
  801c46:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c48:	c7 44 24 04 28 2a 80 	movl   $0x802a28,0x4(%esp)
  801c4f:	00 
  801c50:	89 34 24             	mov    %esi,(%esp)
  801c53:	e8 4f eb ff ff       	call   8007a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c58:	8b 43 04             	mov    0x4(%ebx),%eax
  801c5b:	2b 03                	sub    (%ebx),%eax
  801c5d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c63:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c6a:	00 00 00 
	stat->st_dev = &devpipe;
  801c6d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c74:	30 80 00 
	return 0;
}
  801c77:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	53                   	push   %ebx
  801c87:	83 ec 14             	sub    $0x14,%esp
  801c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c98:	e8 a3 ef ff ff       	call   800c40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c9d:	89 1c 24             	mov    %ebx,(%esp)
  801ca0:	e8 6f f1 ff ff       	call   800e14 <fd2data>
  801ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb0:	e8 8b ef ff ff       	call   800c40 <sys_page_unmap>
}
  801cb5:	83 c4 14             	add    $0x14,%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	57                   	push   %edi
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
  801cc1:	83 ec 2c             	sub    $0x2c,%esp
  801cc4:	89 c7                	mov    %eax,%edi
  801cc6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cc9:	a1 04 40 80 00       	mov    0x804004,%eax
  801cce:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cd1:	89 3c 24             	mov    %edi,(%esp)
  801cd4:	e8 87 05 00 00       	call   802260 <pageref>
  801cd9:	89 c6                	mov    %eax,%esi
  801cdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 7a 05 00 00       	call   802260 <pageref>
  801ce6:	39 c6                	cmp    %eax,%esi
  801ce8:	0f 94 c0             	sete   %al
  801ceb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cee:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cf4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cf7:	39 cb                	cmp    %ecx,%ebx
  801cf9:	75 08                	jne    801d03 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801cfb:	83 c4 2c             	add    $0x2c,%esp
  801cfe:	5b                   	pop    %ebx
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d03:	83 f8 01             	cmp    $0x1,%eax
  801d06:	75 c1                	jne    801cc9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d08:	8b 42 58             	mov    0x58(%edx),%eax
  801d0b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d12:	00 
  801d13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d1b:	c7 04 24 2f 2a 80 00 	movl   $0x802a2f,(%esp)
  801d22:	e8 d5 e4 ff ff       	call   8001fc <cprintf>
  801d27:	eb a0                	jmp    801cc9 <_pipeisclosed+0xe>

00801d29 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	57                   	push   %edi
  801d2d:	56                   	push   %esi
  801d2e:	53                   	push   %ebx
  801d2f:	83 ec 1c             	sub    $0x1c,%esp
  801d32:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d35:	89 34 24             	mov    %esi,(%esp)
  801d38:	e8 d7 f0 ff ff       	call   800e14 <fd2data>
  801d3d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d3f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d44:	eb 3c                	jmp    801d82 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d46:	89 da                	mov    %ebx,%edx
  801d48:	89 f0                	mov    %esi,%eax
  801d4a:	e8 6c ff ff ff       	call   801cbb <_pipeisclosed>
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	75 38                	jne    801d8b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d53:	e8 22 ee ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d58:	8b 43 04             	mov    0x4(%ebx),%eax
  801d5b:	8b 13                	mov    (%ebx),%edx
  801d5d:	83 c2 20             	add    $0x20,%edx
  801d60:	39 d0                	cmp    %edx,%eax
  801d62:	73 e2                	jae    801d46 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d67:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d6a:	89 c2                	mov    %eax,%edx
  801d6c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d72:	79 05                	jns    801d79 <devpipe_write+0x50>
  801d74:	4a                   	dec    %edx
  801d75:	83 ca e0             	or     $0xffffffe0,%edx
  801d78:	42                   	inc    %edx
  801d79:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d7d:	40                   	inc    %eax
  801d7e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d81:	47                   	inc    %edi
  801d82:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d85:	75 d1                	jne    801d58 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d87:	89 f8                	mov    %edi,%eax
  801d89:	eb 05                	jmp    801d90 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d90:	83 c4 1c             	add    $0x1c,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	57                   	push   %edi
  801d9c:	56                   	push   %esi
  801d9d:	53                   	push   %ebx
  801d9e:	83 ec 1c             	sub    $0x1c,%esp
  801da1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801da4:	89 3c 24             	mov    %edi,(%esp)
  801da7:	e8 68 f0 ff ff       	call   800e14 <fd2data>
  801dac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dae:	be 00 00 00 00       	mov    $0x0,%esi
  801db3:	eb 3a                	jmp    801def <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801db5:	85 f6                	test   %esi,%esi
  801db7:	74 04                	je     801dbd <devpipe_read+0x25>
				return i;
  801db9:	89 f0                	mov    %esi,%eax
  801dbb:	eb 40                	jmp    801dfd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dbd:	89 da                	mov    %ebx,%edx
  801dbf:	89 f8                	mov    %edi,%eax
  801dc1:	e8 f5 fe ff ff       	call   801cbb <_pipeisclosed>
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	75 2e                	jne    801df8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dca:	e8 ab ed ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dcf:	8b 03                	mov    (%ebx),%eax
  801dd1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dd4:	74 df                	je     801db5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dd6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ddb:	79 05                	jns    801de2 <devpipe_read+0x4a>
  801ddd:	48                   	dec    %eax
  801dde:	83 c8 e0             	or     $0xffffffe0,%eax
  801de1:	40                   	inc    %eax
  801de2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801de6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dec:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dee:	46                   	inc    %esi
  801def:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df2:	75 db                	jne    801dcf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801df4:	89 f0                	mov    %esi,%eax
  801df6:	eb 05                	jmp    801dfd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dfd:	83 c4 1c             	add    $0x1c,%esp
  801e00:	5b                   	pop    %ebx
  801e01:	5e                   	pop    %esi
  801e02:	5f                   	pop    %edi
  801e03:	5d                   	pop    %ebp
  801e04:	c3                   	ret    

00801e05 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	57                   	push   %edi
  801e09:	56                   	push   %esi
  801e0a:	53                   	push   %ebx
  801e0b:	83 ec 3c             	sub    $0x3c,%esp
  801e0e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e14:	89 04 24             	mov    %eax,(%esp)
  801e17:	e8 13 f0 ff ff       	call   800e2f <fd_alloc>
  801e1c:	89 c3                	mov    %eax,%ebx
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	0f 88 45 01 00 00    	js     801f6b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e2d:	00 
  801e2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3c:	e8 58 ed ff ff       	call   800b99 <sys_page_alloc>
  801e41:	89 c3                	mov    %eax,%ebx
  801e43:	85 c0                	test   %eax,%eax
  801e45:	0f 88 20 01 00 00    	js     801f6b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e4b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e4e:	89 04 24             	mov    %eax,(%esp)
  801e51:	e8 d9 ef ff ff       	call   800e2f <fd_alloc>
  801e56:	89 c3                	mov    %eax,%ebx
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	0f 88 f8 00 00 00    	js     801f58 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e60:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e67:	00 
  801e68:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e76:	e8 1e ed ff ff       	call   800b99 <sys_page_alloc>
  801e7b:	89 c3                	mov    %eax,%ebx
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	0f 88 d3 00 00 00    	js     801f58 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e88:	89 04 24             	mov    %eax,(%esp)
  801e8b:	e8 84 ef ff ff       	call   800e14 <fd2data>
  801e90:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e99:	00 
  801e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea5:	e8 ef ec ff ff       	call   800b99 <sys_page_alloc>
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	85 c0                	test   %eax,%eax
  801eae:	0f 88 91 00 00 00    	js     801f45 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eb7:	89 04 24             	mov    %eax,(%esp)
  801eba:	e8 55 ef ff ff       	call   800e14 <fd2data>
  801ebf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ec6:	00 
  801ec7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ed2:	00 
  801ed3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ede:	e8 0a ed ff ff       	call   800bed <sys_page_map>
  801ee3:	89 c3                	mov    %eax,%ebx
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 4c                	js     801f35 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ee9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ef2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ef7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801efe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f07:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f0c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f16:	89 04 24             	mov    %eax,(%esp)
  801f19:	e8 e6 ee ff ff       	call   800e04 <fd2num>
  801f1e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f23:	89 04 24             	mov    %eax,(%esp)
  801f26:	e8 d9 ee ff ff       	call   800e04 <fd2num>
  801f2b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f33:	eb 36                	jmp    801f6b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f35:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f40:	e8 fb ec ff ff       	call   800c40 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f45:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f53:	e8 e8 ec ff ff       	call   800c40 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f66:	e8 d5 ec ff ff       	call   800c40 <sys_page_unmap>
    err:
	return r;
}
  801f6b:	89 d8                	mov    %ebx,%eax
  801f6d:	83 c4 3c             	add    $0x3c,%esp
  801f70:	5b                   	pop    %ebx
  801f71:	5e                   	pop    %esi
  801f72:	5f                   	pop    %edi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    

00801f75 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f82:	8b 45 08             	mov    0x8(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 f5 ee ff ff       	call   800e82 <fd_lookup>
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 15                	js     801fa6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f94:	89 04 24             	mov    %eax,(%esp)
  801f97:	e8 78 ee ff ff       	call   800e14 <fd2data>
	return _pipeisclosed(fd, p);
  801f9c:	89 c2                	mov    %eax,%edx
  801f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa1:	e8 15 fd ff ff       	call   801cbb <_pipeisclosed>
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fb8:	c7 44 24 04 47 2a 80 	movl   $0x802a47,0x4(%esp)
  801fbf:	00 
  801fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc3:	89 04 24             	mov    %eax,(%esp)
  801fc6:	e8 dc e7 ff ff       	call   8007a7 <strcpy>
	return 0;
}
  801fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	57                   	push   %edi
  801fd6:	56                   	push   %esi
  801fd7:	53                   	push   %ebx
  801fd8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fde:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fe3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe9:	eb 30                	jmp    80201b <devcons_write+0x49>
		m = n - tot;
  801feb:	8b 75 10             	mov    0x10(%ebp),%esi
  801fee:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801ff0:	83 fe 7f             	cmp    $0x7f,%esi
  801ff3:	76 05                	jbe    801ffa <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801ff5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ffa:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ffe:	03 45 0c             	add    0xc(%ebp),%eax
  802001:	89 44 24 04          	mov    %eax,0x4(%esp)
  802005:	89 3c 24             	mov    %edi,(%esp)
  802008:	e8 13 e9 ff ff       	call   800920 <memmove>
		sys_cputs(buf, m);
  80200d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802011:	89 3c 24             	mov    %edi,(%esp)
  802014:	e8 b3 ea ff ff       	call   800acc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802019:	01 f3                	add    %esi,%ebx
  80201b:	89 d8                	mov    %ebx,%eax
  80201d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802020:	72 c9                	jb     801feb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802022:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802028:	5b                   	pop    %ebx
  802029:	5e                   	pop    %esi
  80202a:	5f                   	pop    %edi
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    

0080202d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802033:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802037:	75 07                	jne    802040 <devcons_read+0x13>
  802039:	eb 25                	jmp    802060 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80203b:	e8 3a eb ff ff       	call   800b7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802040:	e8 a5 ea ff ff       	call   800aea <sys_cgetc>
  802045:	85 c0                	test   %eax,%eax
  802047:	74 f2                	je     80203b <devcons_read+0xe>
  802049:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 1d                	js     80206c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80204f:	83 f8 04             	cmp    $0x4,%eax
  802052:	74 13                	je     802067 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802054:	8b 45 0c             	mov    0xc(%ebp),%eax
  802057:	88 10                	mov    %dl,(%eax)
	return 1;
  802059:	b8 01 00 00 00       	mov    $0x1,%eax
  80205e:	eb 0c                	jmp    80206c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802060:	b8 00 00 00 00       	mov    $0x0,%eax
  802065:	eb 05                	jmp    80206c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802074:	8b 45 08             	mov    0x8(%ebp),%eax
  802077:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80207a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802081:	00 
  802082:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802085:	89 04 24             	mov    %eax,(%esp)
  802088:	e8 3f ea ff ff       	call   800acc <sys_cputs>
}
  80208d:	c9                   	leave  
  80208e:	c3                   	ret    

0080208f <getchar>:

int
getchar(void)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802095:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80209c:	00 
  80209d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ab:	e8 6e f0 ff ff       	call   80111e <read>
	if (r < 0)
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	78 0f                	js     8020c3 <getchar+0x34>
		return r;
	if (r < 1)
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	7e 06                	jle    8020be <getchar+0x2f>
		return -E_EOF;
	return c;
  8020b8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020bc:	eb 05                	jmp    8020c3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020be:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020c3:	c9                   	leave  
  8020c4:	c3                   	ret    

008020c5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d5:	89 04 24             	mov    %eax,(%esp)
  8020d8:	e8 a5 ed ff ff       	call   800e82 <fd_lookup>
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	78 11                	js     8020f2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ea:	39 10                	cmp    %edx,(%eax)
  8020ec:	0f 94 c0             	sete   %al
  8020ef:	0f b6 c0             	movzbl %al,%eax
}
  8020f2:	c9                   	leave  
  8020f3:	c3                   	ret    

008020f4 <opencons>:

int
opencons(void)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fd:	89 04 24             	mov    %eax,(%esp)
  802100:	e8 2a ed ff ff       	call   800e2f <fd_alloc>
  802105:	85 c0                	test   %eax,%eax
  802107:	78 3c                	js     802145 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802109:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802110:	00 
  802111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802114:	89 44 24 04          	mov    %eax,0x4(%esp)
  802118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211f:	e8 75 ea ff ff       	call   800b99 <sys_page_alloc>
  802124:	85 c0                	test   %eax,%eax
  802126:	78 1d                	js     802145 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802128:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802131:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802133:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802136:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80213d:	89 04 24             	mov    %eax,(%esp)
  802140:	e8 bf ec ff ff       	call   800e04 <fd2num>
}
  802145:	c9                   	leave  
  802146:	c3                   	ret    
	...

00802148 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	57                   	push   %edi
  80214c:	56                   	push   %esi
  80214d:	53                   	push   %ebx
  80214e:	83 ec 1c             	sub    $0x1c,%esp
  802151:	8b 75 08             	mov    0x8(%ebp),%esi
  802154:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802157:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  80215a:	85 db                	test   %ebx,%ebx
  80215c:	75 05                	jne    802163 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  80215e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  802163:	89 1c 24             	mov    %ebx,(%esp)
  802166:	e8 44 ec ff ff       	call   800daf <sys_ipc_recv>
  80216b:	85 c0                	test   %eax,%eax
  80216d:	79 16                	jns    802185 <ipc_recv+0x3d>
		*from_env_store = 0;
  80216f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  802175:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  80217b:	89 1c 24             	mov    %ebx,(%esp)
  80217e:	e8 2c ec ff ff       	call   800daf <sys_ipc_recv>
  802183:	eb 24                	jmp    8021a9 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  802185:	85 f6                	test   %esi,%esi
  802187:	74 0a                	je     802193 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802189:	a1 04 40 80 00       	mov    0x804004,%eax
  80218e:	8b 40 74             	mov    0x74(%eax),%eax
  802191:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802193:	85 ff                	test   %edi,%edi
  802195:	74 0a                	je     8021a1 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802197:	a1 04 40 80 00       	mov    0x804004,%eax
  80219c:	8b 40 78             	mov    0x78(%eax),%eax
  80219f:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8021a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8021a6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021a9:	83 c4 1c             	add    $0x1c,%esp
  8021ac:	5b                   	pop    %ebx
  8021ad:	5e                   	pop    %esi
  8021ae:	5f                   	pop    %edi
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	57                   	push   %edi
  8021b5:	56                   	push   %esi
  8021b6:	53                   	push   %ebx
  8021b7:	83 ec 1c             	sub    $0x1c,%esp
  8021ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021c0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8021c3:	85 db                	test   %ebx,%ebx
  8021c5:	75 05                	jne    8021cc <ipc_send+0x1b>
		pg = (void *)-1;
  8021c7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8021d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021db:	89 04 24             	mov    %eax,(%esp)
  8021de:	e8 a9 eb ff ff       	call   800d8c <sys_ipc_try_send>
		if (r == 0) {		
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	74 2c                	je     802213 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  8021e7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ea:	75 07                	jne    8021f3 <ipc_send+0x42>
			sys_yield();
  8021ec:	e8 89 e9 ff ff       	call   800b7a <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  8021f1:	eb d9                	jmp    8021cc <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  8021f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021f7:	c7 44 24 08 53 2a 80 	movl   $0x802a53,0x8(%esp)
  8021fe:	00 
  8021ff:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  802206:	00 
  802207:	c7 04 24 61 2a 80 00 	movl   $0x802a61,(%esp)
  80220e:	e8 f1 de ff ff       	call   800104 <_panic>
		}
	}
}
  802213:	83 c4 1c             	add    $0x1c,%esp
  802216:	5b                   	pop    %ebx
  802217:	5e                   	pop    %esi
  802218:	5f                   	pop    %edi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    

0080221b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	53                   	push   %ebx
  80221f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802222:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802227:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80222e:	89 c2                	mov    %eax,%edx
  802230:	c1 e2 07             	shl    $0x7,%edx
  802233:	29 ca                	sub    %ecx,%edx
  802235:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80223b:	8b 52 50             	mov    0x50(%edx),%edx
  80223e:	39 da                	cmp    %ebx,%edx
  802240:	75 0f                	jne    802251 <ipc_find_env+0x36>
			return envs[i].env_id;
  802242:	c1 e0 07             	shl    $0x7,%eax
  802245:	29 c8                	sub    %ecx,%eax
  802247:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80224c:	8b 40 40             	mov    0x40(%eax),%eax
  80224f:	eb 0c                	jmp    80225d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802251:	40                   	inc    %eax
  802252:	3d 00 04 00 00       	cmp    $0x400,%eax
  802257:	75 ce                	jne    802227 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802259:	66 b8 00 00          	mov    $0x0,%ax
}
  80225d:	5b                   	pop    %ebx
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    

00802260 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802266:	89 c2                	mov    %eax,%edx
  802268:	c1 ea 16             	shr    $0x16,%edx
  80226b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802272:	f6 c2 01             	test   $0x1,%dl
  802275:	74 1e                	je     802295 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802277:	c1 e8 0c             	shr    $0xc,%eax
  80227a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802281:	a8 01                	test   $0x1,%al
  802283:	74 17                	je     80229c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802285:	c1 e8 0c             	shr    $0xc,%eax
  802288:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80228f:	ef 
  802290:	0f b7 c0             	movzwl %ax,%eax
  802293:	eb 0c                	jmp    8022a1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802295:	b8 00 00 00 00       	mov    $0x0,%eax
  80229a:	eb 05                	jmp    8022a1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80229c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    
	...

008022a4 <__udivdi3>:
  8022a4:	55                   	push   %ebp
  8022a5:	57                   	push   %edi
  8022a6:	56                   	push   %esi
  8022a7:	83 ec 10             	sub    $0x10,%esp
  8022aa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022ae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8022b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022ba:	89 cd                	mov    %ecx,%ebp
  8022bc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	75 2c                	jne    8022f0 <__udivdi3+0x4c>
  8022c4:	39 f9                	cmp    %edi,%ecx
  8022c6:	77 68                	ja     802330 <__udivdi3+0x8c>
  8022c8:	85 c9                	test   %ecx,%ecx
  8022ca:	75 0b                	jne    8022d7 <__udivdi3+0x33>
  8022cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d1:	31 d2                	xor    %edx,%edx
  8022d3:	f7 f1                	div    %ecx
  8022d5:	89 c1                	mov    %eax,%ecx
  8022d7:	31 d2                	xor    %edx,%edx
  8022d9:	89 f8                	mov    %edi,%eax
  8022db:	f7 f1                	div    %ecx
  8022dd:	89 c7                	mov    %eax,%edi
  8022df:	89 f0                	mov    %esi,%eax
  8022e1:	f7 f1                	div    %ecx
  8022e3:	89 c6                	mov    %eax,%esi
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	89 fa                	mov    %edi,%edx
  8022e9:	83 c4 10             	add    $0x10,%esp
  8022ec:	5e                   	pop    %esi
  8022ed:	5f                   	pop    %edi
  8022ee:	5d                   	pop    %ebp
  8022ef:	c3                   	ret    
  8022f0:	39 f8                	cmp    %edi,%eax
  8022f2:	77 2c                	ja     802320 <__udivdi3+0x7c>
  8022f4:	0f bd f0             	bsr    %eax,%esi
  8022f7:	83 f6 1f             	xor    $0x1f,%esi
  8022fa:	75 4c                	jne    802348 <__udivdi3+0xa4>
  8022fc:	39 f8                	cmp    %edi,%eax
  8022fe:	bf 00 00 00 00       	mov    $0x0,%edi
  802303:	72 0a                	jb     80230f <__udivdi3+0x6b>
  802305:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802309:	0f 87 ad 00 00 00    	ja     8023bc <__udivdi3+0x118>
  80230f:	be 01 00 00 00       	mov    $0x1,%esi
  802314:	89 f0                	mov    %esi,%eax
  802316:	89 fa                	mov    %edi,%edx
  802318:	83 c4 10             	add    $0x10,%esp
  80231b:	5e                   	pop    %esi
  80231c:	5f                   	pop    %edi
  80231d:	5d                   	pop    %ebp
  80231e:	c3                   	ret    
  80231f:	90                   	nop
  802320:	31 ff                	xor    %edi,%edi
  802322:	31 f6                	xor    %esi,%esi
  802324:	89 f0                	mov    %esi,%eax
  802326:	89 fa                	mov    %edi,%edx
  802328:	83 c4 10             	add    $0x10,%esp
  80232b:	5e                   	pop    %esi
  80232c:	5f                   	pop    %edi
  80232d:	5d                   	pop    %ebp
  80232e:	c3                   	ret    
  80232f:	90                   	nop
  802330:	89 fa                	mov    %edi,%edx
  802332:	89 f0                	mov    %esi,%eax
  802334:	f7 f1                	div    %ecx
  802336:	89 c6                	mov    %eax,%esi
  802338:	31 ff                	xor    %edi,%edi
  80233a:	89 f0                	mov    %esi,%eax
  80233c:	89 fa                	mov    %edi,%edx
  80233e:	83 c4 10             	add    $0x10,%esp
  802341:	5e                   	pop    %esi
  802342:	5f                   	pop    %edi
  802343:	5d                   	pop    %ebp
  802344:	c3                   	ret    
  802345:	8d 76 00             	lea    0x0(%esi),%esi
  802348:	89 f1                	mov    %esi,%ecx
  80234a:	d3 e0                	shl    %cl,%eax
  80234c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802350:	b8 20 00 00 00       	mov    $0x20,%eax
  802355:	29 f0                	sub    %esi,%eax
  802357:	89 ea                	mov    %ebp,%edx
  802359:	88 c1                	mov    %al,%cl
  80235b:	d3 ea                	shr    %cl,%edx
  80235d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802361:	09 ca                	or     %ecx,%edx
  802363:	89 54 24 08          	mov    %edx,0x8(%esp)
  802367:	89 f1                	mov    %esi,%ecx
  802369:	d3 e5                	shl    %cl,%ebp
  80236b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80236f:	89 fd                	mov    %edi,%ebp
  802371:	88 c1                	mov    %al,%cl
  802373:	d3 ed                	shr    %cl,%ebp
  802375:	89 fa                	mov    %edi,%edx
  802377:	89 f1                	mov    %esi,%ecx
  802379:	d3 e2                	shl    %cl,%edx
  80237b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80237f:	88 c1                	mov    %al,%cl
  802381:	d3 ef                	shr    %cl,%edi
  802383:	09 d7                	or     %edx,%edi
  802385:	89 f8                	mov    %edi,%eax
  802387:	89 ea                	mov    %ebp,%edx
  802389:	f7 74 24 08          	divl   0x8(%esp)
  80238d:	89 d1                	mov    %edx,%ecx
  80238f:	89 c7                	mov    %eax,%edi
  802391:	f7 64 24 0c          	mull   0xc(%esp)
  802395:	39 d1                	cmp    %edx,%ecx
  802397:	72 17                	jb     8023b0 <__udivdi3+0x10c>
  802399:	74 09                	je     8023a4 <__udivdi3+0x100>
  80239b:	89 fe                	mov    %edi,%esi
  80239d:	31 ff                	xor    %edi,%edi
  80239f:	e9 41 ff ff ff       	jmp    8022e5 <__udivdi3+0x41>
  8023a4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a8:	89 f1                	mov    %esi,%ecx
  8023aa:	d3 e2                	shl    %cl,%edx
  8023ac:	39 c2                	cmp    %eax,%edx
  8023ae:	73 eb                	jae    80239b <__udivdi3+0xf7>
  8023b0:	8d 77 ff             	lea    -0x1(%edi),%esi
  8023b3:	31 ff                	xor    %edi,%edi
  8023b5:	e9 2b ff ff ff       	jmp    8022e5 <__udivdi3+0x41>
  8023ba:	66 90                	xchg   %ax,%ax
  8023bc:	31 f6                	xor    %esi,%esi
  8023be:	e9 22 ff ff ff       	jmp    8022e5 <__udivdi3+0x41>
	...

008023c4 <__umoddi3>:
  8023c4:	55                   	push   %ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	83 ec 20             	sub    $0x20,%esp
  8023ca:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023ce:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8023d2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023d6:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023da:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023de:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8023e2:	89 c7                	mov    %eax,%edi
  8023e4:	89 f2                	mov    %esi,%edx
  8023e6:	85 ed                	test   %ebp,%ebp
  8023e8:	75 16                	jne    802400 <__umoddi3+0x3c>
  8023ea:	39 f1                	cmp    %esi,%ecx
  8023ec:	0f 86 a6 00 00 00    	jbe    802498 <__umoddi3+0xd4>
  8023f2:	f7 f1                	div    %ecx
  8023f4:	89 d0                	mov    %edx,%eax
  8023f6:	31 d2                	xor    %edx,%edx
  8023f8:	83 c4 20             	add    $0x20,%esp
  8023fb:	5e                   	pop    %esi
  8023fc:	5f                   	pop    %edi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    
  8023ff:	90                   	nop
  802400:	39 f5                	cmp    %esi,%ebp
  802402:	0f 87 ac 00 00 00    	ja     8024b4 <__umoddi3+0xf0>
  802408:	0f bd c5             	bsr    %ebp,%eax
  80240b:	83 f0 1f             	xor    $0x1f,%eax
  80240e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802412:	0f 84 a8 00 00 00    	je     8024c0 <__umoddi3+0xfc>
  802418:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80241c:	d3 e5                	shl    %cl,%ebp
  80241e:	bf 20 00 00 00       	mov    $0x20,%edi
  802423:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802427:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80242b:	89 f9                	mov    %edi,%ecx
  80242d:	d3 e8                	shr    %cl,%eax
  80242f:	09 e8                	or     %ebp,%eax
  802431:	89 44 24 18          	mov    %eax,0x18(%esp)
  802435:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802439:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80243d:	d3 e0                	shl    %cl,%eax
  80243f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802443:	89 f2                	mov    %esi,%edx
  802445:	d3 e2                	shl    %cl,%edx
  802447:	8b 44 24 14          	mov    0x14(%esp),%eax
  80244b:	d3 e0                	shl    %cl,%eax
  80244d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802451:	8b 44 24 14          	mov    0x14(%esp),%eax
  802455:	89 f9                	mov    %edi,%ecx
  802457:	d3 e8                	shr    %cl,%eax
  802459:	09 d0                	or     %edx,%eax
  80245b:	d3 ee                	shr    %cl,%esi
  80245d:	89 f2                	mov    %esi,%edx
  80245f:	f7 74 24 18          	divl   0x18(%esp)
  802463:	89 d6                	mov    %edx,%esi
  802465:	f7 64 24 0c          	mull   0xc(%esp)
  802469:	89 c5                	mov    %eax,%ebp
  80246b:	89 d1                	mov    %edx,%ecx
  80246d:	39 d6                	cmp    %edx,%esi
  80246f:	72 67                	jb     8024d8 <__umoddi3+0x114>
  802471:	74 75                	je     8024e8 <__umoddi3+0x124>
  802473:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802477:	29 e8                	sub    %ebp,%eax
  802479:	19 ce                	sbb    %ecx,%esi
  80247b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80247f:	d3 e8                	shr    %cl,%eax
  802481:	89 f2                	mov    %esi,%edx
  802483:	89 f9                	mov    %edi,%ecx
  802485:	d3 e2                	shl    %cl,%edx
  802487:	09 d0                	or     %edx,%eax
  802489:	89 f2                	mov    %esi,%edx
  80248b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80248f:	d3 ea                	shr    %cl,%edx
  802491:	83 c4 20             	add    $0x20,%esp
  802494:	5e                   	pop    %esi
  802495:	5f                   	pop    %edi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    
  802498:	85 c9                	test   %ecx,%ecx
  80249a:	75 0b                	jne    8024a7 <__umoddi3+0xe3>
  80249c:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a1:	31 d2                	xor    %edx,%edx
  8024a3:	f7 f1                	div    %ecx
  8024a5:	89 c1                	mov    %eax,%ecx
  8024a7:	89 f0                	mov    %esi,%eax
  8024a9:	31 d2                	xor    %edx,%edx
  8024ab:	f7 f1                	div    %ecx
  8024ad:	89 f8                	mov    %edi,%eax
  8024af:	e9 3e ff ff ff       	jmp    8023f2 <__umoddi3+0x2e>
  8024b4:	89 f2                	mov    %esi,%edx
  8024b6:	83 c4 20             	add    $0x20,%esp
  8024b9:	5e                   	pop    %esi
  8024ba:	5f                   	pop    %edi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    
  8024bd:	8d 76 00             	lea    0x0(%esi),%esi
  8024c0:	39 f5                	cmp    %esi,%ebp
  8024c2:	72 04                	jb     8024c8 <__umoddi3+0x104>
  8024c4:	39 f9                	cmp    %edi,%ecx
  8024c6:	77 06                	ja     8024ce <__umoddi3+0x10a>
  8024c8:	89 f2                	mov    %esi,%edx
  8024ca:	29 cf                	sub    %ecx,%edi
  8024cc:	19 ea                	sbb    %ebp,%edx
  8024ce:	89 f8                	mov    %edi,%eax
  8024d0:	83 c4 20             	add    $0x20,%esp
  8024d3:	5e                   	pop    %esi
  8024d4:	5f                   	pop    %edi
  8024d5:	5d                   	pop    %ebp
  8024d6:	c3                   	ret    
  8024d7:	90                   	nop
  8024d8:	89 d1                	mov    %edx,%ecx
  8024da:	89 c5                	mov    %eax,%ebp
  8024dc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024e0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024e4:	eb 8d                	jmp    802473 <__umoddi3+0xaf>
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024ec:	72 ea                	jb     8024d8 <__umoddi3+0x114>
  8024ee:	89 f1                	mov    %esi,%ecx
  8024f0:	eb 81                	jmp    802473 <__umoddi3+0xaf>
