
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 33 01 00 00       	call   800164 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800043:	eb 40                	jmp    800085 <cat+0x51>
		if ((r = write(1, buf, n)) != n)
  800045:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800049:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800050:	00 
  800051:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800058:	e8 6c 12 00 00       	call   8012c9 <write>
  80005d:	39 d8                	cmp    %ebx,%eax
  80005f:	74 24                	je     800085 <cat+0x51>
			panic("write error copying %s: %e", s, r);
  800061:	89 44 24 10          	mov    %eax,0x10(%esp)
  800065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800069:	c7 44 24 08 40 21 80 	movl   $0x802140,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 5b 21 80 00 	movl   $0x80215b,(%esp)
  800080:	e8 4f 01 00 00       	call   8001d4 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800085:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800094:	00 
  800095:	89 34 24             	mov    %esi,(%esp)
  800098:	e8 51 11 00 00       	call   8011ee <read>
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	85 c0                	test   %eax,%eax
  8000a1:	7f a2                	jg     800045 <cat+0x11>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 24                	jns    8000cb <cat+0x97>
		panic("error reading %s: %e", s, n);
  8000a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000af:	c7 44 24 08 66 21 80 	movl   $0x802166,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 5b 21 80 00 	movl   $0x80215b,(%esp)
  8000c6:	e8 09 01 00 00       	call   8001d4 <_panic>
}
  8000cb:	83 c4 2c             	add    $0x2c,%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 7b 	movl   $0x80217b,0x803000
  8000e6:	21 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	75 62                	jne    800151 <umain+0x7e>
		cat(0, "<stdin>");
  8000ef:	c7 44 24 04 7f 21 80 	movl   $0x80217f,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fe:	e8 31 ff ff ff       	call   800034 <cat>
  800103:	eb 56                	jmp    80015b <umain+0x88>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010c:	00 
  80010d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800110:	89 04 24             	mov    %eax,(%esp)
  800113:	e8 7d 15 00 00       	call   801695 <open>
  800118:	89 c7                	mov    %eax,%edi
			if (f < 0)
  80011a:	85 c0                	test   %eax,%eax
  80011c:	79 19                	jns    800137 <umain+0x64>
				printf("can't open %s: %e\n", argv[i], f);
  80011e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800122:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	c7 04 24 87 21 80 00 	movl   $0x802187,(%esp)
  800130:	e8 14 17 00 00       	call   801849 <printf>
  800135:	eb 17                	jmp    80014e <umain+0x7b>
			else {
				cat(f, argv[i]);
  800137:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	89 3c 24             	mov    %edi,(%esp)
  800141:	e8 ee fe ff ff       	call   800034 <cat>
				close(f);
  800146:	89 3c 24             	mov    %edi,(%esp)
  800149:	e8 3c 0f 00 00       	call   80108a <close>

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80014e:	43                   	inc    %ebx
  80014f:	eb 05                	jmp    800156 <umain+0x83>
umain(int argc, char **argv)
{
	int f, i;

	binaryname = "cat";
	if (argc == 1)
  800151:	bb 01 00 00 00       	mov    $0x1,%ebx
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800156:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800159:	7c aa                	jl     800105 <umain+0x32>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80015b:	83 c4 1c             	add    $0x1c,%esp
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    
	...

00800164 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 10             	sub    $0x10,%esp
  80016c:	8b 75 08             	mov    0x8(%ebp),%esi
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800172:	e8 b4 0a 00 00       	call   800c2b <sys_getenvid>
  800177:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800183:	c1 e0 07             	shl    $0x7,%eax
  800186:	29 d0                	sub    %edx,%eax
  800188:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80018d:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800192:	85 f6                	test   %esi,%esi
  800194:	7e 07                	jle    80019d <libmain+0x39>
		binaryname = argv[0];
  800196:	8b 03                	mov    (%ebx),%eax
  800198:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80019d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 2a ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001a9:	e8 0a 00 00 00       	call   8001b8 <exit>
}
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001be:	e8 f8 0e 00 00       	call   8010bb <close_all>
	sys_env_destroy(0);
  8001c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ca:	e8 0a 0a 00 00       	call   800bd9 <sys_env_destroy>
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    
  8001d1:	00 00                	add    %al,(%eax)
	...

008001d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001dc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001df:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e5:	e8 41 0a 00 00       	call   800c2b <sys_getenvid>
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800200:	c7 04 24 a4 21 80 00 	movl   $0x8021a4,(%esp)
  800207:	e8 c0 00 00 00       	call   8002cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 50 00 00 00       	call   80026b <vcprintf>
	cprintf("\n");
  80021b:	c7 04 24 e5 25 80 00 	movl   $0x8025e5,(%esp)
  800222:	e8 a5 00 00 00       	call   8002cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800227:	cc                   	int3   
  800228:	eb fd                	jmp    800227 <_panic+0x53>
	...

0080022c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	53                   	push   %ebx
  800230:	83 ec 14             	sub    $0x14,%esp
  800233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800236:	8b 03                	mov    (%ebx),%eax
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80023f:	40                   	inc    %eax
  800240:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800242:	3d ff 00 00 00       	cmp    $0xff,%eax
  800247:	75 19                	jne    800262 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800249:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800250:	00 
  800251:	8d 43 08             	lea    0x8(%ebx),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 40 09 00 00       	call   800b9c <sys_cputs>
		b->idx = 0;
  80025c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800262:	ff 43 04             	incl   0x4(%ebx)
}
  800265:	83 c4 14             	add    $0x14,%esp
  800268:	5b                   	pop    %ebx
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800274:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027b:	00 00 00 
	b.cnt = 0;
  80027e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800285:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	89 44 24 08          	mov    %eax,0x8(%esp)
  800296:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	c7 04 24 2c 02 80 00 	movl   $0x80022c,(%esp)
  8002a7:	e8 82 01 00 00       	call   80042e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 d8 08 00 00       	call   800b9c <sys_cputs>

	return b.cnt;
}
  8002c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	e8 87 ff ff ff       	call   80026b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    
	...

008002e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 3c             	sub    $0x3c,%esp
  8002f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f4:	89 d7                	mov    %edx,%edi
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800302:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800305:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800308:	85 c0                	test   %eax,%eax
  80030a:	75 08                	jne    800314 <printnum+0x2c>
  80030c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800312:	77 57                	ja     80036b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	89 74 24 10          	mov    %esi,0x10(%esp)
  800318:	4b                   	dec    %ebx
  800319:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80031d:	8b 45 10             	mov    0x10(%ebp),%eax
  800320:	89 44 24 08          	mov    %eax,0x8(%esp)
  800324:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800328:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80032c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800333:	00 
  800334:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	e8 9a 1b 00 00       	call   801ee0 <__udivdi3>
  800346:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80034a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	89 54 24 04          	mov    %edx,0x4(%esp)
  800355:	89 fa                	mov    %edi,%edx
  800357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035a:	e8 89 ff ff ff       	call   8002e8 <printnum>
  80035f:	eb 0f                	jmp    800370 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800361:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800365:	89 34 24             	mov    %esi,(%esp)
  800368:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036b:	4b                   	dec    %ebx
  80036c:	85 db                	test   %ebx,%ebx
  80036e:	7f f1                	jg     800361 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800370:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800374:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800378:	8b 45 10             	mov    0x10(%ebp),%eax
  80037b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800386:	00 
  800387:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800390:	89 44 24 04          	mov    %eax,0x4(%esp)
  800394:	e8 67 1c 00 00       	call   802000 <__umoddi3>
  800399:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039d:	0f be 80 c7 21 80 00 	movsbl 0x8021c7(%eax),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003aa:	83 c4 3c             	add    $0x3c,%esp
  8003ad:	5b                   	pop    %ebx
  8003ae:	5e                   	pop    %esi
  8003af:	5f                   	pop    %edi
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b5:	83 fa 01             	cmp    $0x1,%edx
  8003b8:	7e 0e                	jle    8003c8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bf:	89 08                	mov    %ecx,(%eax)
  8003c1:	8b 02                	mov    (%edx),%eax
  8003c3:	8b 52 04             	mov    0x4(%edx),%edx
  8003c6:	eb 22                	jmp    8003ea <getuint+0x38>
	else if (lflag)
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	74 10                	je     8003dc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d1:	89 08                	mov    %ecx,(%eax)
  8003d3:	8b 02                	mov    (%edx),%eax
  8003d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003da:	eb 0e                	jmp    8003ea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fa:	73 08                	jae    800404 <sprintputch+0x18>
		*b->buf++ = ch;
  8003fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ff:	88 0a                	mov    %cl,(%edx)
  800401:	42                   	inc    %edx
  800402:	89 10                	mov    %edx,(%eax)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800413:	8b 45 10             	mov    0x10(%ebp),%eax
  800416:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	e8 02 00 00 00       	call   80042e <vprintfmt>
	va_end(ap);
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	83 ec 4c             	sub    $0x4c,%esp
  800437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043a:	8b 75 10             	mov    0x10(%ebp),%esi
  80043d:	eb 12                	jmp    800451 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043f:	85 c0                	test   %eax,%eax
  800441:	0f 84 6b 03 00 00    	je     8007b2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800447:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044b:	89 04 24             	mov    %eax,(%esp)
  80044e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800451:	0f b6 06             	movzbl (%esi),%eax
  800454:	46                   	inc    %esi
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e5                	jne    80043f <vprintfmt+0x11>
  80045a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80045e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800465:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80046a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800471:	b9 00 00 00 00       	mov    $0x0,%ecx
  800476:	eb 26                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80047f:	eb 1d                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800484:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800488:	eb 14                	jmp    80049e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80048d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800494:	eb 08                	jmp    80049e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800496:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800499:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	0f b6 06             	movzbl (%esi),%eax
  8004a1:	8d 56 01             	lea    0x1(%esi),%edx
  8004a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a7:	8a 16                	mov    (%esi),%dl
  8004a9:	83 ea 23             	sub    $0x23,%edx
  8004ac:	80 fa 55             	cmp    $0x55,%dl
  8004af:	0f 87 e1 02 00 00    	ja     800796 <vprintfmt+0x368>
  8004b5:	0f b6 d2             	movzbl %dl,%edx
  8004b8:	ff 24 95 00 23 80 00 	jmp    *0x802300(,%edx,4)
  8004bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ca:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ce:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d4:	83 fa 09             	cmp    $0x9,%edx
  8004d7:	77 2a                	ja     800503 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004da:	eb eb                	jmp    8004c7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ea:	eb 17                	jmp    800503 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f0:	78 98                	js     80048a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f5:	eb a7                	jmp    80049e <vprintfmt+0x70>
  8004f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004fa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800501:	eb 9b                	jmp    80049e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800503:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800507:	79 95                	jns    80049e <vprintfmt+0x70>
  800509:	eb 8b                	jmp    800496 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050f:	eb 8d                	jmp    80049e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 04 24             	mov    %eax,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800529:	e9 23 ff ff ff       	jmp    800451 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	85 c0                	test   %eax,%eax
  80053b:	79 02                	jns    80053f <vprintfmt+0x111>
  80053d:	f7 d8                	neg    %eax
  80053f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800541:	83 f8 0f             	cmp    $0xf,%eax
  800544:	7f 0b                	jg     800551 <vprintfmt+0x123>
  800546:	8b 04 85 60 24 80 00 	mov    0x802460(,%eax,4),%eax
  80054d:	85 c0                	test   %eax,%eax
  80054f:	75 23                	jne    800574 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800551:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800555:	c7 44 24 08 df 21 80 	movl   $0x8021df,0x8(%esp)
  80055c:	00 
  80055d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800561:	8b 45 08             	mov    0x8(%ebp),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	e8 9a fe ff ff       	call   800406 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056f:	e9 dd fe ff ff       	jmp    800451 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800574:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800578:	c7 44 24 08 be 25 80 	movl   $0x8025be,0x8(%esp)
  80057f:	00 
  800580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800584:	8b 55 08             	mov    0x8(%ebp),%edx
  800587:	89 14 24             	mov    %edx,(%esp)
  80058a:	e8 77 fe ff ff       	call   800406 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800592:	e9 ba fe ff ff       	jmp    800451 <vprintfmt+0x23>
  800597:	89 f9                	mov    %edi,%ecx
  800599:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 30                	mov    (%eax),%esi
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	75 05                	jne    8005b3 <vprintfmt+0x185>
				p = "(null)";
  8005ae:	be d8 21 80 00       	mov    $0x8021d8,%esi
			if (width > 0 && padc != '-')
  8005b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b7:	0f 8e 84 00 00 00    	jle    800641 <vprintfmt+0x213>
  8005bd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005c1:	74 7e                	je     800641 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c7:	89 34 24             	mov    %esi,(%esp)
  8005ca:	e8 8b 02 00 00       	call   80085a <strnlen>
  8005cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d2:	29 c2                	sub    %eax,%edx
  8005d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005d7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005db:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005de:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005e1:	89 de                	mov    %ebx,%esi
  8005e3:	89 d3                	mov    %edx,%ebx
  8005e5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e7:	eb 0b                	jmp    8005f4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ed:	89 3c 24             	mov    %edi,(%esp)
  8005f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	4b                   	dec    %ebx
  8005f4:	85 db                	test   %ebx,%ebx
  8005f6:	7f f1                	jg     8005e9 <vprintfmt+0x1bb>
  8005f8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005fb:	89 f3                	mov    %esi,%ebx
  8005fd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800603:	85 c0                	test   %eax,%eax
  800605:	79 05                	jns    80060c <vprintfmt+0x1de>
  800607:	b8 00 00 00 00       	mov    $0x0,%eax
  80060c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060f:	29 c2                	sub    %eax,%edx
  800611:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800614:	eb 2b                	jmp    800641 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	74 18                	je     800634 <vprintfmt+0x206>
  80061c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80061f:	83 fa 5e             	cmp    $0x5e,%edx
  800622:	76 10                	jbe    800634 <vprintfmt+0x206>
					putch('?', putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
  800632:	eb 0a                	jmp    80063e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063e:	ff 4d e4             	decl   -0x1c(%ebp)
  800641:	0f be 06             	movsbl (%esi),%eax
  800644:	46                   	inc    %esi
  800645:	85 c0                	test   %eax,%eax
  800647:	74 21                	je     80066a <vprintfmt+0x23c>
  800649:	85 ff                	test   %edi,%edi
  80064b:	78 c9                	js     800616 <vprintfmt+0x1e8>
  80064d:	4f                   	dec    %edi
  80064e:	79 c6                	jns    800616 <vprintfmt+0x1e8>
  800650:	8b 7d 08             	mov    0x8(%ebp),%edi
  800653:	89 de                	mov    %ebx,%esi
  800655:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800658:	eb 18                	jmp    800672 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800665:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800667:	4b                   	dec    %ebx
  800668:	eb 08                	jmp    800672 <vprintfmt+0x244>
  80066a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066d:	89 de                	mov    %ebx,%esi
  80066f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800672:	85 db                	test   %ebx,%ebx
  800674:	7f e4                	jg     80065a <vprintfmt+0x22c>
  800676:	89 7d 08             	mov    %edi,0x8(%ebp)
  800679:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067e:	e9 ce fd ff ff       	jmp    800451 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800683:	83 f9 01             	cmp    $0x1,%ecx
  800686:	7e 10                	jle    800698 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 08             	lea    0x8(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 30                	mov    (%eax),%esi
  800693:	8b 78 04             	mov    0x4(%eax),%edi
  800696:	eb 26                	jmp    8006be <vprintfmt+0x290>
	else if (lflag)
  800698:	85 c9                	test   %ecx,%ecx
  80069a:	74 12                	je     8006ae <vprintfmt+0x280>
		return va_arg(*ap, long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 30                	mov    (%eax),%esi
  8006a7:	89 f7                	mov    %esi,%edi
  8006a9:	c1 ff 1f             	sar    $0x1f,%edi
  8006ac:	eb 10                	jmp    8006be <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 30                	mov    (%eax),%esi
  8006b9:	89 f7                	mov    %esi,%edi
  8006bb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	78 0a                	js     8006cc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c7:	e9 8c 00 00 00       	jmp    800758 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006da:	f7 de                	neg    %esi
  8006dc:	83 d7 00             	adc    $0x0,%edi
  8006df:	f7 df                	neg    %edi
			}
			base = 10;
  8006e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e6:	eb 70                	jmp    800758 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e8:	89 ca                	mov    %ecx,%edx
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 c0 fc ff ff       	call   8003b2 <getuint>
  8006f2:	89 c6                	mov    %eax,%esi
  8006f4:	89 d7                	mov    %edx,%edi
			base = 10;
  8006f6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006fb:	eb 5b                	jmp    800758 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006fd:	89 ca                	mov    %ecx,%edx
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	e8 ab fc ff ff       	call   8003b2 <getuint>
  800707:	89 c6                	mov    %eax,%esi
  800709:	89 d7                	mov    %edx,%edi
			base = 8;
  80070b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800710:	eb 46                	jmp    800758 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800712:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800716:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 04             	lea    0x4(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800737:	8b 30                	mov    (%eax),%esi
  800739:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800743:	eb 13                	jmp    800758 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800745:	89 ca                	mov    %ecx,%edx
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 63 fc ff ff       	call   8003b2 <getuint>
  80074f:	89 c6                	mov    %eax,%esi
  800751:	89 d7                	mov    %edx,%edi
			base = 16;
  800753:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800758:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80075c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800760:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800763:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	89 34 24             	mov    %esi,(%esp)
  80076e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800772:	89 da                	mov    %ebx,%edx
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	e8 6c fb ff ff       	call   8002e8 <printnum>
			break;
  80077c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80077f:	e9 cd fc ff ff       	jmp    800451 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800784:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800791:	e9 bb fc ff ff       	jmp    800451 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800796:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a4:	eb 01                	jmp    8007a7 <vprintfmt+0x379>
  8007a6:	4e                   	dec    %esi
  8007a7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ab:	75 f9                	jne    8007a6 <vprintfmt+0x378>
  8007ad:	e9 9f fc ff ff       	jmp    800451 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007b2:	83 c4 4c             	add    $0x4c,%esp
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	5f                   	pop    %edi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 28             	sub    $0x28,%esp
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	74 30                	je     80080b <vsnprintf+0x51>
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	7e 33                	jle    800812 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f4:	c7 04 24 ec 03 80 00 	movl   $0x8003ec,(%esp)
  8007fb:	e8 2e fc ff ff       	call   80042e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800800:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800803:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800809:	eb 0c                	jmp    800817 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800810:	eb 05                	jmp    800817 <vsnprintf+0x5d>
  800812:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800822:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800826:	8b 45 10             	mov    0x10(%ebp),%eax
  800829:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800830:	89 44 24 04          	mov    %eax,0x4(%esp)
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	89 04 24             	mov    %eax,(%esp)
  80083a:	e8 7b ff ff ff       	call   8007ba <vsnprintf>
	va_end(ap);

	return rc;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    
  800841:	00 00                	add    %al,(%eax)
	...

00800844 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
  80084f:	eb 01                	jmp    800852 <strlen+0xe>
		n++;
  800851:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800852:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800856:	75 f9                	jne    800851 <strlen+0xd>
		n++;
	return n;
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb 01                	jmp    80086b <strnlen+0x11>
		n++;
  80086a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086b:	39 d0                	cmp    %edx,%eax
  80086d:	74 06                	je     800875 <strnlen+0x1b>
  80086f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800873:	75 f5                	jne    80086a <strnlen+0x10>
		n++;
	return n;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800881:	ba 00 00 00 00       	mov    $0x0,%edx
  800886:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800889:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80088c:	42                   	inc    %edx
  80088d:	84 c9                	test   %cl,%cl
  80088f:	75 f5                	jne    800886 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800891:	5b                   	pop    %ebx
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089e:	89 1c 24             	mov    %ebx,(%esp)
  8008a1:	e8 9e ff ff ff       	call   800844 <strlen>
	strcpy(dst + len, src);
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ad:	01 d8                	add    %ebx,%eax
  8008af:	89 04 24             	mov    %eax,(%esp)
  8008b2:	e8 c0 ff ff ff       	call   800877 <strcpy>
	return dst;
}
  8008b7:	89 d8                	mov    %ebx,%eax
  8008b9:	83 c4 08             	add    $0x8,%esp
  8008bc:	5b                   	pop    %ebx
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d2:	eb 0c                	jmp    8008e0 <strncpy+0x21>
		*dst++ = *src;
  8008d4:	8a 1a                	mov    (%edx),%bl
  8008d6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d9:	80 3a 01             	cmpb   $0x1,(%edx)
  8008dc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008df:	41                   	inc    %ecx
  8008e0:	39 f1                	cmp    %esi,%ecx
  8008e2:	75 f0                	jne    8008d4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f6:	85 d2                	test   %edx,%edx
  8008f8:	75 0a                	jne    800904 <strlcpy+0x1c>
  8008fa:	89 f0                	mov    %esi,%eax
  8008fc:	eb 1a                	jmp    800918 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fe:	88 18                	mov    %bl,(%eax)
  800900:	40                   	inc    %eax
  800901:	41                   	inc    %ecx
  800902:	eb 02                	jmp    800906 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800904:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800906:	4a                   	dec    %edx
  800907:	74 0a                	je     800913 <strlcpy+0x2b>
  800909:	8a 19                	mov    (%ecx),%bl
  80090b:	84 db                	test   %bl,%bl
  80090d:	75 ef                	jne    8008fe <strlcpy+0x16>
  80090f:	89 c2                	mov    %eax,%edx
  800911:	eb 02                	jmp    800915 <strlcpy+0x2d>
  800913:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800915:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800918:	29 f0                	sub    %esi,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800927:	eb 02                	jmp    80092b <strcmp+0xd>
		p++, q++;
  800929:	41                   	inc    %ecx
  80092a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092b:	8a 01                	mov    (%ecx),%al
  80092d:	84 c0                	test   %al,%al
  80092f:	74 04                	je     800935 <strcmp+0x17>
  800931:	3a 02                	cmp    (%edx),%al
  800933:	74 f4                	je     800929 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800935:	0f b6 c0             	movzbl %al,%eax
  800938:	0f b6 12             	movzbl (%edx),%edx
  80093b:	29 d0                	sub    %edx,%eax
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	53                   	push   %ebx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800949:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80094c:	eb 03                	jmp    800951 <strncmp+0x12>
		n--, p++, q++;
  80094e:	4a                   	dec    %edx
  80094f:	40                   	inc    %eax
  800950:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800951:	85 d2                	test   %edx,%edx
  800953:	74 14                	je     800969 <strncmp+0x2a>
  800955:	8a 18                	mov    (%eax),%bl
  800957:	84 db                	test   %bl,%bl
  800959:	74 04                	je     80095f <strncmp+0x20>
  80095b:	3a 19                	cmp    (%ecx),%bl
  80095d:	74 ef                	je     80094e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	0f b6 00             	movzbl (%eax),%eax
  800962:	0f b6 11             	movzbl (%ecx),%edx
  800965:	29 d0                	sub    %edx,%eax
  800967:	eb 05                	jmp    80096e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800969:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096e:	5b                   	pop    %ebx
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097a:	eb 05                	jmp    800981 <strchr+0x10>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	74 0c                	je     80098c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800980:	40                   	inc    %eax
  800981:	8a 10                	mov    (%eax),%dl
  800983:	84 d2                	test   %dl,%dl
  800985:	75 f5                	jne    80097c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800997:	eb 05                	jmp    80099e <strfind+0x10>
		if (*s == c)
  800999:	38 ca                	cmp    %cl,%dl
  80099b:	74 07                	je     8009a4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80099d:	40                   	inc    %eax
  80099e:	8a 10                	mov    (%eax),%dl
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f5                	jne    800999 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b5:	85 c9                	test   %ecx,%ecx
  8009b7:	74 30                	je     8009e9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bf:	75 25                	jne    8009e6 <memset+0x40>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 20                	jne    8009e6 <memset+0x40>
		c &= 0xFF;
  8009c6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c9:	89 d3                	mov    %edx,%ebx
  8009cb:	c1 e3 08             	shl    $0x8,%ebx
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	c1 e6 18             	shl    $0x18,%esi
  8009d3:	89 d0                	mov    %edx,%eax
  8009d5:	c1 e0 10             	shl    $0x10,%eax
  8009d8:	09 f0                	or     %esi,%eax
  8009da:	09 d0                	or     %edx,%eax
  8009dc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009de:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e1:	fc                   	cld    
  8009e2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e4:	eb 03                	jmp    8009e9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e6:	fc                   	cld    
  8009e7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e9:	89 f8                	mov    %edi,%eax
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5f                   	pop    %edi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fe:	39 c6                	cmp    %eax,%esi
  800a00:	73 34                	jae    800a36 <memmove+0x46>
  800a02:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a05:	39 d0                	cmp    %edx,%eax
  800a07:	73 2d                	jae    800a36 <memmove+0x46>
		s += n;
		d += n;
  800a09:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0c:	f6 c2 03             	test   $0x3,%dl
  800a0f:	75 1b                	jne    800a2c <memmove+0x3c>
  800a11:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a17:	75 13                	jne    800a2c <memmove+0x3c>
  800a19:	f6 c1 03             	test   $0x3,%cl
  800a1c:	75 0e                	jne    800a2c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1e:	83 ef 04             	sub    $0x4,%edi
  800a21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a24:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a27:	fd                   	std    
  800a28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2a:	eb 07                	jmp    800a33 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2c:	4f                   	dec    %edi
  800a2d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a30:	fd                   	std    
  800a31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a33:	fc                   	cld    
  800a34:	eb 20                	jmp    800a56 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3c:	75 13                	jne    800a51 <memmove+0x61>
  800a3e:	a8 03                	test   $0x3,%al
  800a40:	75 0f                	jne    800a51 <memmove+0x61>
  800a42:	f6 c1 03             	test   $0x3,%cl
  800a45:	75 0a                	jne    800a51 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a47:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	fc                   	cld    
  800a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4f:	eb 05                	jmp    800a56 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a60:	8b 45 10             	mov    0x10(%ebp),%eax
  800a63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	89 04 24             	mov    %eax,(%esp)
  800a74:	e8 77 ff ff ff       	call   8009f0 <memmove>
}
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8f:	eb 16                	jmp    800aa7 <memcmp+0x2c>
		if (*s1 != *s2)
  800a91:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a94:	42                   	inc    %edx
  800a95:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a99:	38 c8                	cmp    %cl,%al
  800a9b:	74 0a                	je     800aa7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a9d:	0f b6 c0             	movzbl %al,%eax
  800aa0:	0f b6 c9             	movzbl %cl,%ecx
  800aa3:	29 c8                	sub    %ecx,%eax
  800aa5:	eb 09                	jmp    800ab0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	39 da                	cmp    %ebx,%edx
  800aa9:	75 e6                	jne    800a91 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac3:	eb 05                	jmp    800aca <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac5:	38 08                	cmp    %cl,(%eax)
  800ac7:	74 05                	je     800ace <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac9:	40                   	inc    %eax
  800aca:	39 d0                	cmp    %edx,%eax
  800acc:	72 f7                	jb     800ac5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adc:	eb 01                	jmp    800adf <strtol+0xf>
		s++;
  800ade:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adf:	8a 02                	mov    (%edx),%al
  800ae1:	3c 20                	cmp    $0x20,%al
  800ae3:	74 f9                	je     800ade <strtol+0xe>
  800ae5:	3c 09                	cmp    $0x9,%al
  800ae7:	74 f5                	je     800ade <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae9:	3c 2b                	cmp    $0x2b,%al
  800aeb:	75 08                	jne    800af5 <strtol+0x25>
		s++;
  800aed:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aee:	bf 00 00 00 00       	mov    $0x0,%edi
  800af3:	eb 13                	jmp    800b08 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af5:	3c 2d                	cmp    $0x2d,%al
  800af7:	75 0a                	jne    800b03 <strtol+0x33>
		s++, neg = 1;
  800af9:	8d 52 01             	lea    0x1(%edx),%edx
  800afc:	bf 01 00 00 00       	mov    $0x1,%edi
  800b01:	eb 05                	jmp    800b08 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b08:	85 db                	test   %ebx,%ebx
  800b0a:	74 05                	je     800b11 <strtol+0x41>
  800b0c:	83 fb 10             	cmp    $0x10,%ebx
  800b0f:	75 28                	jne    800b39 <strtol+0x69>
  800b11:	8a 02                	mov    (%edx),%al
  800b13:	3c 30                	cmp    $0x30,%al
  800b15:	75 10                	jne    800b27 <strtol+0x57>
  800b17:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b1b:	75 0a                	jne    800b27 <strtol+0x57>
		s += 2, base = 16;
  800b1d:	83 c2 02             	add    $0x2,%edx
  800b20:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b25:	eb 12                	jmp    800b39 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b27:	85 db                	test   %ebx,%ebx
  800b29:	75 0e                	jne    800b39 <strtol+0x69>
  800b2b:	3c 30                	cmp    $0x30,%al
  800b2d:	75 05                	jne    800b34 <strtol+0x64>
		s++, base = 8;
  800b2f:	42                   	inc    %edx
  800b30:	b3 08                	mov    $0x8,%bl
  800b32:	eb 05                	jmp    800b39 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b34:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b40:	8a 0a                	mov    (%edx),%cl
  800b42:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b45:	80 fb 09             	cmp    $0x9,%bl
  800b48:	77 08                	ja     800b52 <strtol+0x82>
			dig = *s - '0';
  800b4a:	0f be c9             	movsbl %cl,%ecx
  800b4d:	83 e9 30             	sub    $0x30,%ecx
  800b50:	eb 1e                	jmp    800b70 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b52:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b55:	80 fb 19             	cmp    $0x19,%bl
  800b58:	77 08                	ja     800b62 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b5a:	0f be c9             	movsbl %cl,%ecx
  800b5d:	83 e9 57             	sub    $0x57,%ecx
  800b60:	eb 0e                	jmp    800b70 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b62:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b65:	80 fb 19             	cmp    $0x19,%bl
  800b68:	77 12                	ja     800b7c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b6a:	0f be c9             	movsbl %cl,%ecx
  800b6d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b70:	39 f1                	cmp    %esi,%ecx
  800b72:	7d 0c                	jge    800b80 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b74:	42                   	inc    %edx
  800b75:	0f af c6             	imul   %esi,%eax
  800b78:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b7a:	eb c4                	jmp    800b40 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	89 c1                	mov    %eax,%ecx
  800b7e:	eb 02                	jmp    800b82 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b80:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b86:	74 05                	je     800b8d <strtol+0xbd>
		*endptr = (char *) s;
  800b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b8d:	85 ff                	test   %edi,%edi
  800b8f:	74 04                	je     800b95 <strtol+0xc5>
  800b91:	89 c8                	mov    %ecx,%eax
  800b93:	f7 d8                	neg    %eax
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
	...

00800b9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	89 c3                	mov    %eax,%ebx
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	89 c6                	mov    %eax,%esi
  800bb3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_cgetc>:

int
sys_cgetc(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	89 cb                	mov    %ecx,%ebx
  800bf1:	89 cf                	mov    %ecx,%edi
  800bf3:	89 ce                	mov    %ecx,%esi
  800bf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 28                	jle    800c23 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c06:	00 
  800c07:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c16:	00 
  800c17:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800c1e:	e8 b1 f5 ff ff       	call   8001d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c23:	83 c4 2c             	add    $0x2c,%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	ba 00 00 00 00       	mov    $0x0,%edx
  800c36:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3b:	89 d1                	mov    %edx,%ecx
  800c3d:	89 d3                	mov    %edx,%ebx
  800c3f:	89 d7                	mov    %edx,%edi
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_yield>:

void
sys_yield(void)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	be 00 00 00 00       	mov    $0x0,%esi
  800c77:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 f7                	mov    %esi,%edi
  800c87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 28                	jle    800cb5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c91:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c98:	00 
  800c99:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca8:	00 
  800ca9:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800cb0:	e8 1f f5 ff ff       	call   8001d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb5:	83 c4 2c             	add    $0x2c,%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 28                	jle    800d08 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ceb:	00 
  800cec:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800cf3:	00 
  800cf4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfb:	00 
  800cfc:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800d03:	e8 cc f4 ff ff       	call   8001d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d08:	83 c4 2c             	add    $0x2c,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 df                	mov    %ebx,%edi
  800d2b:	89 de                	mov    %ebx,%esi
  800d2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	7e 28                	jle    800d5b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d37:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800d46:	00 
  800d47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4e:	00 
  800d4f:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800d56:	e8 79 f4 ff ff       	call   8001d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	83 c4 2c             	add    $0x2c,%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 28                	jle    800dae <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d91:	00 
  800d92:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800d99:	00 
  800d9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da1:	00 
  800da2:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800da9:	e8 26 f4 ff ff       	call   8001d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dae:	83 c4 2c             	add    $0x2c,%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 28                	jle    800e01 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800dfc:	e8 d3 f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e01:	83 c4 2c             	add    $0x2c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	89 df                	mov    %ebx,%edi
  800e24:	89 de                	mov    %ebx,%esi
  800e26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	7e 28                	jle    800e54 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e30:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e37:	00 
  800e38:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800e3f:	00 
  800e40:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e47:	00 
  800e48:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800e4f:	e8 80 f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e54:	83 c4 2c             	add    $0x2c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e62:	be 00 00 00 00       	mov    $0x0,%esi
  800e67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e6c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	57                   	push   %edi
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 cb                	mov    %ecx,%ebx
  800e97:	89 cf                	mov    %ecx,%edi
  800e99:	89 ce                	mov    %ecx,%esi
  800e9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	7e 28                	jle    800ec9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eac:	00 
  800ead:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800ec4:	e8 0b f3 ff ff       	call   8001d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec9:	83 c4 2c             	add    $0x2c,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
  800ed1:	00 00                	add    %al,(%eax)
	...

00800ed4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eda:	05 00 00 00 30       	add    $0x30000000,%eax
  800edf:	c1 e8 0c             	shr    $0xc,%eax
}
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800eea:	8b 45 08             	mov    0x8(%ebp),%eax
  800eed:	89 04 24             	mov    %eax,(%esp)
  800ef0:	e8 df ff ff ff       	call   800ed4 <fd2num>
  800ef5:	05 20 00 0d 00       	add    $0xd0020,%eax
  800efa:	c1 e0 0c             	shl    $0xc,%eax
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	53                   	push   %ebx
  800f03:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f06:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f0b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f0d:	89 c2                	mov    %eax,%edx
  800f0f:	c1 ea 16             	shr    $0x16,%edx
  800f12:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f19:	f6 c2 01             	test   $0x1,%dl
  800f1c:	74 11                	je     800f2f <fd_alloc+0x30>
  800f1e:	89 c2                	mov    %eax,%edx
  800f20:	c1 ea 0c             	shr    $0xc,%edx
  800f23:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2a:	f6 c2 01             	test   $0x1,%dl
  800f2d:	75 09                	jne    800f38 <fd_alloc+0x39>
			*fd_store = fd;
  800f2f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	eb 17                	jmp    800f4f <fd_alloc+0x50>
  800f38:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f3d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f42:	75 c7                	jne    800f0b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f44:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f4a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f4f:	5b                   	pop    %ebx
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f58:	83 f8 1f             	cmp    $0x1f,%eax
  800f5b:	77 36                	ja     800f93 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f5d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f62:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f65:	89 c2                	mov    %eax,%edx
  800f67:	c1 ea 16             	shr    $0x16,%edx
  800f6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f71:	f6 c2 01             	test   $0x1,%dl
  800f74:	74 24                	je     800f9a <fd_lookup+0x48>
  800f76:	89 c2                	mov    %eax,%edx
  800f78:	c1 ea 0c             	shr    $0xc,%edx
  800f7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f82:	f6 c2 01             	test   $0x1,%dl
  800f85:	74 1a                	je     800fa1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	eb 13                	jmp    800fa6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f98:	eb 0c                	jmp    800fa6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9f:	eb 05                	jmp    800fa6 <fd_lookup+0x54>
  800fa1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 14             	sub    $0x14,%esp
  800faf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fba:	eb 0e                	jmp    800fca <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fbc:	39 08                	cmp    %ecx,(%eax)
  800fbe:	75 09                	jne    800fc9 <dev_lookup+0x21>
			*dev = devtab[i];
  800fc0:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc7:	eb 33                	jmp    800ffc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc9:	42                   	inc    %edx
  800fca:	8b 04 95 6c 25 80 00 	mov    0x80256c(,%edx,4),%eax
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	75 e7                	jne    800fbc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd5:	a1 20 60 80 00       	mov    0x806020,%eax
  800fda:	8b 40 48             	mov    0x48(%eax),%eax
  800fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe5:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  800fec:	e8 db f2 ff ff       	call   8002cc <cprintf>
	*dev = 0;
  800ff1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ff7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ffc:	83 c4 14             	add    $0x14,%esp
  800fff:	5b                   	pop    %ebx
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	83 ec 30             	sub    $0x30,%esp
  80100a:	8b 75 08             	mov    0x8(%ebp),%esi
  80100d:	8a 45 0c             	mov    0xc(%ebp),%al
  801010:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801013:	89 34 24             	mov    %esi,(%esp)
  801016:	e8 b9 fe ff ff       	call   800ed4 <fd2num>
  80101b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80101e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801022:	89 04 24             	mov    %eax,(%esp)
  801025:	e8 28 ff ff ff       	call   800f52 <fd_lookup>
  80102a:	89 c3                	mov    %eax,%ebx
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 05                	js     801035 <fd_close+0x33>
	    || fd != fd2)
  801030:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801033:	74 0d                	je     801042 <fd_close+0x40>
		return (must_exist ? r : 0);
  801035:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801039:	75 46                	jne    801081 <fd_close+0x7f>
  80103b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801040:	eb 3f                	jmp    801081 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801042:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801045:	89 44 24 04          	mov    %eax,0x4(%esp)
  801049:	8b 06                	mov    (%esi),%eax
  80104b:	89 04 24             	mov    %eax,(%esp)
  80104e:	e8 55 ff ff ff       	call   800fa8 <dev_lookup>
  801053:	89 c3                	mov    %eax,%ebx
  801055:	85 c0                	test   %eax,%eax
  801057:	78 18                	js     801071 <fd_close+0x6f>
		if (dev->dev_close)
  801059:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105c:	8b 40 10             	mov    0x10(%eax),%eax
  80105f:	85 c0                	test   %eax,%eax
  801061:	74 09                	je     80106c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801063:	89 34 24             	mov    %esi,(%esp)
  801066:	ff d0                	call   *%eax
  801068:	89 c3                	mov    %eax,%ebx
  80106a:	eb 05                	jmp    801071 <fd_close+0x6f>
		else
			r = 0;
  80106c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801071:	89 74 24 04          	mov    %esi,0x4(%esp)
  801075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107c:	e8 8f fc ff ff       	call   800d10 <sys_page_unmap>
	return r;
}
  801081:	89 d8                	mov    %ebx,%eax
  801083:	83 c4 30             	add    $0x30,%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801093:	89 44 24 04          	mov    %eax,0x4(%esp)
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
  80109a:	89 04 24             	mov    %eax,(%esp)
  80109d:	e8 b0 fe ff ff       	call   800f52 <fd_lookup>
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	78 13                	js     8010b9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010a6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ad:	00 
  8010ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b1:	89 04 24             	mov    %eax,(%esp)
  8010b4:	e8 49 ff ff ff       	call   801002 <fd_close>
}
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <close_all>:

void
close_all(void)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c7:	89 1c 24             	mov    %ebx,(%esp)
  8010ca:	e8 bb ff ff ff       	call   80108a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010cf:	43                   	inc    %ebx
  8010d0:	83 fb 20             	cmp    $0x20,%ebx
  8010d3:	75 f2                	jne    8010c7 <close_all+0xc>
		close(i);
}
  8010d5:	83 c4 14             	add    $0x14,%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 4c             	sub    $0x4c,%esp
  8010e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f1:	89 04 24             	mov    %eax,(%esp)
  8010f4:	e8 59 fe ff ff       	call   800f52 <fd_lookup>
  8010f9:	89 c3                	mov    %eax,%ebx
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	0f 88 e1 00 00 00    	js     8011e4 <dup+0x109>
		return r;
	close(newfdnum);
  801103:	89 3c 24             	mov    %edi,(%esp)
  801106:	e8 7f ff ff ff       	call   80108a <close>

	newfd = INDEX2FD(newfdnum);
  80110b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801111:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801114:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801117:	89 04 24             	mov    %eax,(%esp)
  80111a:	e8 c5 fd ff ff       	call   800ee4 <fd2data>
  80111f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801121:	89 34 24             	mov    %esi,(%esp)
  801124:	e8 bb fd ff ff       	call   800ee4 <fd2data>
  801129:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112c:	89 d8                	mov    %ebx,%eax
  80112e:	c1 e8 16             	shr    $0x16,%eax
  801131:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801138:	a8 01                	test   $0x1,%al
  80113a:	74 46                	je     801182 <dup+0xa7>
  80113c:	89 d8                	mov    %ebx,%eax
  80113e:	c1 e8 0c             	shr    $0xc,%eax
  801141:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801148:	f6 c2 01             	test   $0x1,%dl
  80114b:	74 35                	je     801182 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801154:	25 07 0e 00 00       	and    $0xe07,%eax
  801159:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801160:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801164:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80116b:	00 
  80116c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801177:	e8 41 fb ff ff       	call   800cbd <sys_page_map>
  80117c:	89 c3                	mov    %eax,%ebx
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 3b                	js     8011bd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801182:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801185:	89 c2                	mov    %eax,%edx
  801187:	c1 ea 0c             	shr    $0xc,%edx
  80118a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801191:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801197:	89 54 24 10          	mov    %edx,0x10(%esp)
  80119b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80119f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a6:	00 
  8011a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b2:	e8 06 fb ff ff       	call   800cbd <sys_page_map>
  8011b7:	89 c3                	mov    %eax,%ebx
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	79 25                	jns    8011e2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c8:	e8 43 fb ff ff       	call   800d10 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011db:	e8 30 fb ff ff       	call   800d10 <sys_page_unmap>
	return r;
  8011e0:	eb 02                	jmp    8011e4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011e2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011e4:	89 d8                	mov    %ebx,%eax
  8011e6:	83 c4 4c             	add    $0x4c,%esp
  8011e9:	5b                   	pop    %ebx
  8011ea:	5e                   	pop    %esi
  8011eb:	5f                   	pop    %edi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 24             	sub    $0x24,%esp
  8011f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ff:	89 1c 24             	mov    %ebx,(%esp)
  801202:	e8 4b fd ff ff       	call   800f52 <fd_lookup>
  801207:	85 c0                	test   %eax,%eax
  801209:	78 6d                	js     801278 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801212:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801215:	8b 00                	mov    (%eax),%eax
  801217:	89 04 24             	mov    %eax,(%esp)
  80121a:	e8 89 fd ff ff       	call   800fa8 <dev_lookup>
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 55                	js     801278 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801223:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801226:	8b 50 08             	mov    0x8(%eax),%edx
  801229:	83 e2 03             	and    $0x3,%edx
  80122c:	83 fa 01             	cmp    $0x1,%edx
  80122f:	75 23                	jne    801254 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801231:	a1 20 60 80 00       	mov    0x806020,%eax
  801236:	8b 40 48             	mov    0x48(%eax),%eax
  801239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80123d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801241:	c7 04 24 30 25 80 00 	movl   $0x802530,(%esp)
  801248:	e8 7f f0 ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801252:	eb 24                	jmp    801278 <read+0x8a>
	}
	if (!dev->dev_read)
  801254:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801257:	8b 52 08             	mov    0x8(%edx),%edx
  80125a:	85 d2                	test   %edx,%edx
  80125c:	74 15                	je     801273 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80125e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801261:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801265:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801268:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80126c:	89 04 24             	mov    %eax,(%esp)
  80126f:	ff d2                	call   *%edx
  801271:	eb 05                	jmp    801278 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801273:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801278:	83 c4 24             	add    $0x24,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 1c             	sub    $0x1c,%esp
  801287:	8b 7d 08             	mov    0x8(%ebp),%edi
  80128a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801292:	eb 23                	jmp    8012b7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801294:	89 f0                	mov    %esi,%eax
  801296:	29 d8                	sub    %ebx,%eax
  801298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80129c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129f:	01 d8                	add    %ebx,%eax
  8012a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a5:	89 3c 24             	mov    %edi,(%esp)
  8012a8:	e8 41 ff ff ff       	call   8011ee <read>
		if (m < 0)
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 10                	js     8012c1 <readn+0x43>
			return m;
		if (m == 0)
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	74 0a                	je     8012bf <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b5:	01 c3                	add    %eax,%ebx
  8012b7:	39 f3                	cmp    %esi,%ebx
  8012b9:	72 d9                	jb     801294 <readn+0x16>
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	eb 02                	jmp    8012c1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012bf:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012c1:	83 c4 1c             	add    $0x1c,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 24             	sub    $0x24,%esp
  8012d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012da:	89 1c 24             	mov    %ebx,(%esp)
  8012dd:	e8 70 fc ff ff       	call   800f52 <fd_lookup>
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 68                	js     80134e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f0:	8b 00                	mov    (%eax),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 ae fc ff ff       	call   800fa8 <dev_lookup>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 50                	js     80134e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801301:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801305:	75 23                	jne    80132a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801307:	a1 20 60 80 00       	mov    0x806020,%eax
  80130c:	8b 40 48             	mov    0x48(%eax),%eax
  80130f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801313:	89 44 24 04          	mov    %eax,0x4(%esp)
  801317:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  80131e:	e8 a9 ef ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  801323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801328:	eb 24                	jmp    80134e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80132a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132d:	8b 52 0c             	mov    0xc(%edx),%edx
  801330:	85 d2                	test   %edx,%edx
  801332:	74 15                	je     801349 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801334:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801337:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801342:	89 04 24             	mov    %eax,(%esp)
  801345:	ff d2                	call   *%edx
  801347:	eb 05                	jmp    80134e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801349:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80134e:	83 c4 24             	add    $0x24,%esp
  801351:	5b                   	pop    %ebx
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <seek>:

int
seek(int fdnum, off_t offset)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80135d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801361:	8b 45 08             	mov    0x8(%ebp),%eax
  801364:	89 04 24             	mov    %eax,(%esp)
  801367:	e8 e6 fb ff ff       	call   800f52 <fd_lookup>
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 0e                	js     80137e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801370:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801373:	8b 55 0c             	mov    0xc(%ebp),%edx
  801376:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 24             	sub    $0x24,%esp
  801387:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801391:	89 1c 24             	mov    %ebx,(%esp)
  801394:	e8 b9 fb ff ff       	call   800f52 <fd_lookup>
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 61                	js     8013fe <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a7:	8b 00                	mov    (%eax),%eax
  8013a9:	89 04 24             	mov    %eax,(%esp)
  8013ac:	e8 f7 fb ff ff       	call   800fa8 <dev_lookup>
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 49                	js     8013fe <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013bc:	75 23                	jne    8013e1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013be:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c3:	8b 40 48             	mov    0x48(%eax),%eax
  8013c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ce:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  8013d5:	e8 f2 ee ff ff       	call   8002cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013df:	eb 1d                	jmp    8013fe <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8013e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e4:	8b 52 18             	mov    0x18(%edx),%edx
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	74 0e                	je     8013f9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013f2:	89 04 24             	mov    %eax,(%esp)
  8013f5:	ff d2                	call   *%edx
  8013f7:	eb 05                	jmp    8013fe <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013fe:	83 c4 24             	add    $0x24,%esp
  801401:	5b                   	pop    %ebx
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	53                   	push   %ebx
  801408:	83 ec 24             	sub    $0x24,%esp
  80140b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801411:	89 44 24 04          	mov    %eax,0x4(%esp)
  801415:	8b 45 08             	mov    0x8(%ebp),%eax
  801418:	89 04 24             	mov    %eax,(%esp)
  80141b:	e8 32 fb ff ff       	call   800f52 <fd_lookup>
  801420:	85 c0                	test   %eax,%eax
  801422:	78 52                	js     801476 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801424:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801427:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142e:	8b 00                	mov    (%eax),%eax
  801430:	89 04 24             	mov    %eax,(%esp)
  801433:	e8 70 fb ff ff       	call   800fa8 <dev_lookup>
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 3a                	js     801476 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80143c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801443:	74 2c                	je     801471 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801445:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801448:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80144f:	00 00 00 
	stat->st_isdir = 0;
  801452:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801459:	00 00 00 
	stat->st_dev = dev;
  80145c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801462:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801466:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801469:	89 14 24             	mov    %edx,(%esp)
  80146c:	ff 50 14             	call   *0x14(%eax)
  80146f:	eb 05                	jmp    801476 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801471:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801476:	83 c4 24             	add    $0x24,%esp
  801479:	5b                   	pop    %ebx
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801484:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80148b:	00 
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
  80148f:	89 04 24             	mov    %eax,(%esp)
  801492:	e8 fe 01 00 00       	call   801695 <open>
  801497:	89 c3                	mov    %eax,%ebx
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 1b                	js     8014b8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80149d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a4:	89 1c 24             	mov    %ebx,(%esp)
  8014a7:	e8 58 ff ff ff       	call   801404 <fstat>
  8014ac:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ae:	89 1c 24             	mov    %ebx,(%esp)
  8014b1:	e8 d4 fb ff ff       	call   80108a <close>
	return r;
  8014b6:	89 f3                	mov    %esi,%ebx
}
  8014b8:	89 d8                	mov    %ebx,%eax
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	5b                   	pop    %ebx
  8014be:	5e                   	pop    %esi
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    
  8014c1:	00 00                	add    %al,(%eax)
	...

008014c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 10             	sub    $0x10,%esp
  8014cc:	89 c3                	mov    %eax,%ebx
  8014ce:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014d0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014d7:	75 11                	jne    8014ea <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014e0:	e8 72 09 00 00       	call   801e57 <ipc_find_env>
  8014e5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014ea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014f1:	00 
  8014f2:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8014f9:	00 
  8014fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014fe:	a1 00 40 80 00       	mov    0x804000,%eax
  801503:	89 04 24             	mov    %eax,(%esp)
  801506:	e8 e2 08 00 00       	call   801ded <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80150b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801512:	00 
  801513:	89 74 24 04          	mov    %esi,0x4(%esp)
  801517:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151e:	e8 61 08 00 00       	call   801d84 <ipc_recv>
}
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	8b 40 0c             	mov    0xc(%eax),%eax
  801536:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80153b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153e:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801543:	ba 00 00 00 00       	mov    $0x0,%edx
  801548:	b8 02 00 00 00       	mov    $0x2,%eax
  80154d:	e8 72 ff ff ff       	call   8014c4 <fsipc>
}
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80155a:	8b 45 08             	mov    0x8(%ebp),%eax
  80155d:	8b 40 0c             	mov    0xc(%eax),%eax
  801560:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801565:	ba 00 00 00 00       	mov    $0x0,%edx
  80156a:	b8 06 00 00 00       	mov    $0x6,%eax
  80156f:	e8 50 ff ff ff       	call   8014c4 <fsipc>
}
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	53                   	push   %ebx
  80157a:	83 ec 14             	sub    $0x14,%esp
  80157d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801580:	8b 45 08             	mov    0x8(%ebp),%eax
  801583:	8b 40 0c             	mov    0xc(%eax),%eax
  801586:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80158b:	ba 00 00 00 00       	mov    $0x0,%edx
  801590:	b8 05 00 00 00       	mov    $0x5,%eax
  801595:	e8 2a ff ff ff       	call   8014c4 <fsipc>
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 2b                	js     8015c9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80159e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8015a5:	00 
  8015a6:	89 1c 24             	mov    %ebx,(%esp)
  8015a9:	e8 c9 f2 ff ff       	call   800877 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ae:	a1 80 70 80 00       	mov    0x807080,%eax
  8015b3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015b9:	a1 84 70 80 00       	mov    0x807084,%eax
  8015be:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c9:	83 c4 14             	add    $0x14,%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8015d5:	c7 44 24 08 7c 25 80 	movl   $0x80257c,0x8(%esp)
  8015dc:	00 
  8015dd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8015e4:	00 
  8015e5:	c7 04 24 9a 25 80 00 	movl   $0x80259a,(%esp)
  8015ec:	e8 e3 eb ff ff       	call   8001d4 <_panic>

008015f1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	56                   	push   %esi
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 10             	sub    $0x10,%esp
  8015f9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801602:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801607:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80160d:	ba 00 00 00 00       	mov    $0x0,%edx
  801612:	b8 03 00 00 00       	mov    $0x3,%eax
  801617:	e8 a8 fe ff ff       	call   8014c4 <fsipc>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 6a                	js     80168c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801622:	39 c6                	cmp    %eax,%esi
  801624:	73 24                	jae    80164a <devfile_read+0x59>
  801626:	c7 44 24 0c a5 25 80 	movl   $0x8025a5,0xc(%esp)
  80162d:	00 
  80162e:	c7 44 24 08 ac 25 80 	movl   $0x8025ac,0x8(%esp)
  801635:	00 
  801636:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80163d:	00 
  80163e:	c7 04 24 9a 25 80 00 	movl   $0x80259a,(%esp)
  801645:	e8 8a eb ff ff       	call   8001d4 <_panic>
	assert(r <= PGSIZE);
  80164a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80164f:	7e 24                	jle    801675 <devfile_read+0x84>
  801651:	c7 44 24 0c c1 25 80 	movl   $0x8025c1,0xc(%esp)
  801658:	00 
  801659:	c7 44 24 08 ac 25 80 	movl   $0x8025ac,0x8(%esp)
  801660:	00 
  801661:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801668:	00 
  801669:	c7 04 24 9a 25 80 00 	movl   $0x80259a,(%esp)
  801670:	e8 5f eb ff ff       	call   8001d4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801675:	89 44 24 08          	mov    %eax,0x8(%esp)
  801679:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801680:	00 
  801681:	8b 45 0c             	mov    0xc(%ebp),%eax
  801684:	89 04 24             	mov    %eax,(%esp)
  801687:	e8 64 f3 ff ff       	call   8009f0 <memmove>
	return r;
}
  80168c:	89 d8                	mov    %ebx,%eax
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	5b                   	pop    %ebx
  801692:	5e                   	pop    %esi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	56                   	push   %esi
  801699:	53                   	push   %ebx
  80169a:	83 ec 20             	sub    $0x20,%esp
  80169d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016a0:	89 34 24             	mov    %esi,(%esp)
  8016a3:	e8 9c f1 ff ff       	call   800844 <strlen>
  8016a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016ad:	7f 60                	jg     80170f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 45 f8 ff ff       	call   800eff <fd_alloc>
  8016ba:	89 c3                	mov    %eax,%ebx
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 54                	js     801714 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c4:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  8016cb:	e8 a7 f1 ff ff       	call   800877 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d3:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016db:	b8 01 00 00 00       	mov    $0x1,%eax
  8016e0:	e8 df fd ff ff       	call   8014c4 <fsipc>
  8016e5:	89 c3                	mov    %eax,%ebx
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	79 15                	jns    801700 <open+0x6b>
		fd_close(fd, 0);
  8016eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016f2:	00 
  8016f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f6:	89 04 24             	mov    %eax,(%esp)
  8016f9:	e8 04 f9 ff ff       	call   801002 <fd_close>
		return r;
  8016fe:	eb 14                	jmp    801714 <open+0x7f>
	}

	return fd2num(fd);
  801700:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801703:	89 04 24             	mov    %eax,(%esp)
  801706:	e8 c9 f7 ff ff       	call   800ed4 <fd2num>
  80170b:	89 c3                	mov    %eax,%ebx
  80170d:	eb 05                	jmp    801714 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80170f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801714:	89 d8                	mov    %ebx,%eax
  801716:	83 c4 20             	add    $0x20,%esp
  801719:	5b                   	pop    %ebx
  80171a:	5e                   	pop    %esi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 08 00 00 00       	mov    $0x8,%eax
  80172d:	e8 92 fd ff ff       	call   8014c4 <fsipc>
}
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 14             	sub    $0x14,%esp
  80173b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80173d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801741:	7e 32                	jle    801775 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801743:	8b 40 04             	mov    0x4(%eax),%eax
  801746:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174a:	8d 43 10             	lea    0x10(%ebx),%eax
  80174d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801751:	8b 03                	mov    (%ebx),%eax
  801753:	89 04 24             	mov    %eax,(%esp)
  801756:	e8 6e fb ff ff       	call   8012c9 <write>
		if (result > 0)
  80175b:	85 c0                	test   %eax,%eax
  80175d:	7e 03                	jle    801762 <writebuf+0x2e>
			b->result += result;
  80175f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801762:	39 43 04             	cmp    %eax,0x4(%ebx)
  801765:	74 0e                	je     801775 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801767:	89 c2                	mov    %eax,%edx
  801769:	85 c0                	test   %eax,%eax
  80176b:	7e 05                	jle    801772 <writebuf+0x3e>
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801775:	83 c4 14             	add    $0x14,%esp
  801778:	5b                   	pop    %ebx
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <putch>:

static void
putch(int ch, void *thunk)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801785:	8b 43 04             	mov    0x4(%ebx),%eax
  801788:	8b 55 08             	mov    0x8(%ebp),%edx
  80178b:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80178f:	40                   	inc    %eax
  801790:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801793:	3d 00 01 00 00       	cmp    $0x100,%eax
  801798:	75 0e                	jne    8017a8 <putch+0x2d>
		writebuf(b);
  80179a:	89 d8                	mov    %ebx,%eax
  80179c:	e8 93 ff ff ff       	call   801734 <writebuf>
		b->idx = 0;
  8017a1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017a8:	83 c4 04             	add    $0x4,%esp
  8017ab:	5b                   	pop    %ebx
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017c0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017c7:	00 00 00 
	b.result = 0;
  8017ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017d1:	00 00 00 
	b.error = 1;
  8017d4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017db:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017de:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ec:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f6:	c7 04 24 7b 17 80 00 	movl   $0x80177b,(%esp)
  8017fd:	e8 2c ec ff ff       	call   80042e <vprintfmt>
	if (b.idx > 0)
  801802:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801809:	7e 0b                	jle    801816 <vfprintf+0x68>
		writebuf(&b);
  80180b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801811:	e8 1e ff ff ff       	call   801734 <writebuf>

	return (b.result ? b.result : b.error);
  801816:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80181c:	85 c0                	test   %eax,%eax
  80181e:	75 06                	jne    801826 <vfprintf+0x78>
  801820:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80182e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801831:	89 44 24 08          	mov    %eax,0x8(%esp)
  801835:	8b 45 0c             	mov    0xc(%ebp),%eax
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 67 ff ff ff       	call   8017ae <vfprintf>
	va_end(ap);

	return cnt;
}
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <printf>:

int
printf(const char *fmt, ...)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80184f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801852:	89 44 24 08          	mov    %eax,0x8(%esp)
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801864:	e8 45 ff ff ff       	call   8017ae <vfprintf>
	va_end(ap);

	return cnt;
}
  801869:	c9                   	leave  
  80186a:	c3                   	ret    
	...

0080186c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	83 ec 10             	sub    $0x10,%esp
  801874:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	89 04 24             	mov    %eax,(%esp)
  80187d:	e8 62 f6 ff ff       	call   800ee4 <fd2data>
  801882:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801884:	c7 44 24 04 cd 25 80 	movl   $0x8025cd,0x4(%esp)
  80188b:	00 
  80188c:	89 34 24             	mov    %esi,(%esp)
  80188f:	e8 e3 ef ff ff       	call   800877 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801894:	8b 43 04             	mov    0x4(%ebx),%eax
  801897:	2b 03                	sub    (%ebx),%eax
  801899:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80189f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8018a6:	00 00 00 
	stat->st_dev = &devpipe;
  8018a9:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8018b0:	30 80 00 
	return 0;
}
  8018b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 14             	sub    $0x14,%esp
  8018c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d4:	e8 37 f4 ff ff       	call   800d10 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018d9:	89 1c 24             	mov    %ebx,(%esp)
  8018dc:	e8 03 f6 ff ff       	call   800ee4 <fd2data>
  8018e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ec:	e8 1f f4 ff ff       	call   800d10 <sys_page_unmap>
}
  8018f1:	83 c4 14             	add    $0x14,%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	57                   	push   %edi
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
  8018fd:	83 ec 2c             	sub    $0x2c,%esp
  801900:	89 c7                	mov    %eax,%edi
  801902:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801905:	a1 20 60 80 00       	mov    0x806020,%eax
  80190a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80190d:	89 3c 24             	mov    %edi,(%esp)
  801910:	e8 87 05 00 00       	call   801e9c <pageref>
  801915:	89 c6                	mov    %eax,%esi
  801917:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80191a:	89 04 24             	mov    %eax,(%esp)
  80191d:	e8 7a 05 00 00       	call   801e9c <pageref>
  801922:	39 c6                	cmp    %eax,%esi
  801924:	0f 94 c0             	sete   %al
  801927:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80192a:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801930:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801933:	39 cb                	cmp    %ecx,%ebx
  801935:	75 08                	jne    80193f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801937:	83 c4 2c             	add    $0x2c,%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80193f:	83 f8 01             	cmp    $0x1,%eax
  801942:	75 c1                	jne    801905 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801944:	8b 42 58             	mov    0x58(%edx),%eax
  801947:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80194e:	00 
  80194f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801953:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801957:	c7 04 24 d4 25 80 00 	movl   $0x8025d4,(%esp)
  80195e:	e8 69 e9 ff ff       	call   8002cc <cprintf>
  801963:	eb a0                	jmp    801905 <_pipeisclosed+0xe>

00801965 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	57                   	push   %edi
  801969:	56                   	push   %esi
  80196a:	53                   	push   %ebx
  80196b:	83 ec 1c             	sub    $0x1c,%esp
  80196e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801971:	89 34 24             	mov    %esi,(%esp)
  801974:	e8 6b f5 ff ff       	call   800ee4 <fd2data>
  801979:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197b:	bf 00 00 00 00       	mov    $0x0,%edi
  801980:	eb 3c                	jmp    8019be <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801982:	89 da                	mov    %ebx,%edx
  801984:	89 f0                	mov    %esi,%eax
  801986:	e8 6c ff ff ff       	call   8018f7 <_pipeisclosed>
  80198b:	85 c0                	test   %eax,%eax
  80198d:	75 38                	jne    8019c7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80198f:	e8 b6 f2 ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801994:	8b 43 04             	mov    0x4(%ebx),%eax
  801997:	8b 13                	mov    (%ebx),%edx
  801999:	83 c2 20             	add    $0x20,%edx
  80199c:	39 d0                	cmp    %edx,%eax
  80199e:	73 e2                	jae    801982 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8019a6:	89 c2                	mov    %eax,%edx
  8019a8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019ae:	79 05                	jns    8019b5 <devpipe_write+0x50>
  8019b0:	4a                   	dec    %edx
  8019b1:	83 ca e0             	or     $0xffffffe0,%edx
  8019b4:	42                   	inc    %edx
  8019b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019b9:	40                   	inc    %eax
  8019ba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019bd:	47                   	inc    %edi
  8019be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019c1:	75 d1                	jne    801994 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019c3:	89 f8                	mov    %edi,%eax
  8019c5:	eb 05                	jmp    8019cc <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019c7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019cc:	83 c4 1c             	add    $0x1c,%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5f                   	pop    %edi
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	57                   	push   %edi
  8019d8:	56                   	push   %esi
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 1c             	sub    $0x1c,%esp
  8019dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019e0:	89 3c 24             	mov    %edi,(%esp)
  8019e3:	e8 fc f4 ff ff       	call   800ee4 <fd2data>
  8019e8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ea:	be 00 00 00 00       	mov    $0x0,%esi
  8019ef:	eb 3a                	jmp    801a2b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019f1:	85 f6                	test   %esi,%esi
  8019f3:	74 04                	je     8019f9 <devpipe_read+0x25>
				return i;
  8019f5:	89 f0                	mov    %esi,%eax
  8019f7:	eb 40                	jmp    801a39 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019f9:	89 da                	mov    %ebx,%edx
  8019fb:	89 f8                	mov    %edi,%eax
  8019fd:	e8 f5 fe ff ff       	call   8018f7 <_pipeisclosed>
  801a02:	85 c0                	test   %eax,%eax
  801a04:	75 2e                	jne    801a34 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a06:	e8 3f f2 ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a0b:	8b 03                	mov    (%ebx),%eax
  801a0d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a10:	74 df                	je     8019f1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a12:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a17:	79 05                	jns    801a1e <devpipe_read+0x4a>
  801a19:	48                   	dec    %eax
  801a1a:	83 c8 e0             	or     $0xffffffe0,%eax
  801a1d:	40                   	inc    %eax
  801a1e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a22:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a25:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a28:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a2a:	46                   	inc    %esi
  801a2b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a2e:	75 db                	jne    801a0b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a30:	89 f0                	mov    %esi,%eax
  801a32:	eb 05                	jmp    801a39 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a39:	83 c4 1c             	add    $0x1c,%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5f                   	pop    %edi
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	57                   	push   %edi
  801a45:	56                   	push   %esi
  801a46:	53                   	push   %ebx
  801a47:	83 ec 3c             	sub    $0x3c,%esp
  801a4a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a4d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a50:	89 04 24             	mov    %eax,(%esp)
  801a53:	e8 a7 f4 ff ff       	call   800eff <fd_alloc>
  801a58:	89 c3                	mov    %eax,%ebx
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	0f 88 45 01 00 00    	js     801ba7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a69:	00 
  801a6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a78:	e8 ec f1 ff ff       	call   800c69 <sys_page_alloc>
  801a7d:	89 c3                	mov    %eax,%ebx
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	0f 88 20 01 00 00    	js     801ba7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a87:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a8a:	89 04 24             	mov    %eax,(%esp)
  801a8d:	e8 6d f4 ff ff       	call   800eff <fd_alloc>
  801a92:	89 c3                	mov    %eax,%ebx
  801a94:	85 c0                	test   %eax,%eax
  801a96:	0f 88 f8 00 00 00    	js     801b94 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aa3:	00 
  801aa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab2:	e8 b2 f1 ff ff       	call   800c69 <sys_page_alloc>
  801ab7:	89 c3                	mov    %eax,%ebx
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	0f 88 d3 00 00 00    	js     801b94 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ac1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac4:	89 04 24             	mov    %eax,(%esp)
  801ac7:	e8 18 f4 ff ff       	call   800ee4 <fd2data>
  801acc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ace:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ad5:	00 
  801ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ada:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae1:	e8 83 f1 ff ff       	call   800c69 <sys_page_alloc>
  801ae6:	89 c3                	mov    %eax,%ebx
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	0f 88 91 00 00 00    	js     801b81 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801af3:	89 04 24             	mov    %eax,(%esp)
  801af6:	e8 e9 f3 ff ff       	call   800ee4 <fd2data>
  801afb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b02:	00 
  801b03:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b0e:	00 
  801b0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1a:	e8 9e f1 ff ff       	call   800cbd <sys_page_map>
  801b1f:	89 c3                	mov    %eax,%ebx
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 4c                	js     801b71 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b25:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b33:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b3a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b40:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b43:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b45:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b48:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b52:	89 04 24             	mov    %eax,(%esp)
  801b55:	e8 7a f3 ff ff       	call   800ed4 <fd2num>
  801b5a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b5f:	89 04 24             	mov    %eax,(%esp)
  801b62:	e8 6d f3 ff ff       	call   800ed4 <fd2num>
  801b67:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b6f:	eb 36                	jmp    801ba7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801b71:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7c:	e8 8f f1 ff ff       	call   800d10 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801b81:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b8f:	e8 7c f1 ff ff       	call   800d10 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801b94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba2:	e8 69 f1 ff ff       	call   800d10 <sys_page_unmap>
    err:
	return r;
}
  801ba7:	89 d8                	mov    %ebx,%eax
  801ba9:	83 c4 3c             	add    $0x3c,%esp
  801bac:	5b                   	pop    %ebx
  801bad:	5e                   	pop    %esi
  801bae:	5f                   	pop    %edi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc1:	89 04 24             	mov    %eax,(%esp)
  801bc4:	e8 89 f3 ff ff       	call   800f52 <fd_lookup>
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 15                	js     801be2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd0:	89 04 24             	mov    %eax,(%esp)
  801bd3:	e8 0c f3 ff ff       	call   800ee4 <fd2data>
	return _pipeisclosed(fd, p);
  801bd8:	89 c2                	mov    %eax,%edx
  801bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdd:	e8 15 fd ff ff       	call   8018f7 <_pipeisclosed>
}
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801bf4:	c7 44 24 04 ec 25 80 	movl   $0x8025ec,0x4(%esp)
  801bfb:	00 
  801bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bff:	89 04 24             	mov    %eax,(%esp)
  801c02:	e8 70 ec ff ff       	call   800877 <strcpy>
	return 0;
}
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    

00801c0e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c1f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c25:	eb 30                	jmp    801c57 <devcons_write+0x49>
		m = n - tot;
  801c27:	8b 75 10             	mov    0x10(%ebp),%esi
  801c2a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801c2c:	83 fe 7f             	cmp    $0x7f,%esi
  801c2f:	76 05                	jbe    801c36 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801c31:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c36:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c3a:	03 45 0c             	add    0xc(%ebp),%eax
  801c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c41:	89 3c 24             	mov    %edi,(%esp)
  801c44:	e8 a7 ed ff ff       	call   8009f0 <memmove>
		sys_cputs(buf, m);
  801c49:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4d:	89 3c 24             	mov    %edi,(%esp)
  801c50:	e8 47 ef ff ff       	call   800b9c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c55:	01 f3                	add    %esi,%ebx
  801c57:	89 d8                	mov    %ebx,%eax
  801c59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c5c:	72 c9                	jb     801c27 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c5e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5f                   	pop    %edi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c73:	75 07                	jne    801c7c <devcons_read+0x13>
  801c75:	eb 25                	jmp    801c9c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c77:	e8 ce ef ff ff       	call   800c4a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c7c:	e8 39 ef ff ff       	call   800bba <sys_cgetc>
  801c81:	85 c0                	test   %eax,%eax
  801c83:	74 f2                	je     801c77 <devcons_read+0xe>
  801c85:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c87:	85 c0                	test   %eax,%eax
  801c89:	78 1d                	js     801ca8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c8b:	83 f8 04             	cmp    $0x4,%eax
  801c8e:	74 13                	je     801ca3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c93:	88 10                	mov    %dl,(%eax)
	return 1;
  801c95:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9a:	eb 0c                	jmp    801ca8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca1:	eb 05                	jmp    801ca8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cb6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801cbd:	00 
  801cbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cc1:	89 04 24             	mov    %eax,(%esp)
  801cc4:	e8 d3 ee ff ff       	call   800b9c <sys_cputs>
}
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <getchar>:

int
getchar(void)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cd1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801cd8:	00 
  801cd9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce7:	e8 02 f5 ff ff       	call   8011ee <read>
	if (r < 0)
  801cec:	85 c0                	test   %eax,%eax
  801cee:	78 0f                	js     801cff <getchar+0x34>
		return r;
	if (r < 1)
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	7e 06                	jle    801cfa <getchar+0x2f>
		return -E_EOF;
	return c;
  801cf4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cf8:	eb 05                	jmp    801cff <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cfa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d11:	89 04 24             	mov    %eax,(%esp)
  801d14:	e8 39 f2 ff ff       	call   800f52 <fd_lookup>
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	78 11                	js     801d2e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d20:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d26:	39 10                	cmp    %edx,(%eax)
  801d28:	0f 94 c0             	sete   %al
  801d2b:	0f b6 c0             	movzbl %al,%eax
}
  801d2e:	c9                   	leave  
  801d2f:	c3                   	ret    

00801d30 <opencons>:

int
opencons(void)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d39:	89 04 24             	mov    %eax,(%esp)
  801d3c:	e8 be f1 ff ff       	call   800eff <fd_alloc>
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 3c                	js     801d81 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d45:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d4c:	00 
  801d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5b:	e8 09 ef ff ff       	call   800c69 <sys_page_alloc>
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 1d                	js     801d81 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d64:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d79:	89 04 24             	mov    %eax,(%esp)
  801d7c:	e8 53 f1 ff ff       	call   800ed4 <fd2num>
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    
	...

00801d84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	57                   	push   %edi
  801d88:	56                   	push   %esi
  801d89:	53                   	push   %ebx
  801d8a:	83 ec 1c             	sub    $0x1c,%esp
  801d8d:	8b 75 08             	mov    0x8(%ebp),%esi
  801d90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d93:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801d96:	85 db                	test   %ebx,%ebx
  801d98:	75 05                	jne    801d9f <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801d9a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801d9f:	89 1c 24             	mov    %ebx,(%esp)
  801da2:	e8 d8 f0 ff ff       	call   800e7f <sys_ipc_recv>
  801da7:	85 c0                	test   %eax,%eax
  801da9:	79 16                	jns    801dc1 <ipc_recv+0x3d>
		*from_env_store = 0;
  801dab:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801db1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801db7:	89 1c 24             	mov    %ebx,(%esp)
  801dba:	e8 c0 f0 ff ff       	call   800e7f <sys_ipc_recv>
  801dbf:	eb 24                	jmp    801de5 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801dc1:	85 f6                	test   %esi,%esi
  801dc3:	74 0a                	je     801dcf <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801dc5:	a1 20 60 80 00       	mov    0x806020,%eax
  801dca:	8b 40 74             	mov    0x74(%eax),%eax
  801dcd:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801dcf:	85 ff                	test   %edi,%edi
  801dd1:	74 0a                	je     801ddd <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801dd3:	a1 20 60 80 00       	mov    0x806020,%eax
  801dd8:	8b 40 78             	mov    0x78(%eax),%eax
  801ddb:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801ddd:	a1 20 60 80 00       	mov    0x806020,%eax
  801de2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    

00801ded <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	57                   	push   %edi
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	83 ec 1c             	sub    $0x1c,%esp
  801df6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dfc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801dff:	85 db                	test   %ebx,%ebx
  801e01:	75 05                	jne    801e08 <ipc_send+0x1b>
		pg = (void *)-1;
  801e03:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e08:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e0c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e10:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	89 04 24             	mov    %eax,(%esp)
  801e1a:	e8 3d f0 ff ff       	call   800e5c <sys_ipc_try_send>
		if (r == 0) {		
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	74 2c                	je     801e4f <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801e23:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e26:	75 07                	jne    801e2f <ipc_send+0x42>
			sys_yield();
  801e28:	e8 1d ee ff ff       	call   800c4a <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801e2d:	eb d9                	jmp    801e08 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801e2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e33:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  801e3a:	00 
  801e3b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801e42:	00 
  801e43:	c7 04 24 06 26 80 00 	movl   $0x802606,(%esp)
  801e4a:	e8 85 e3 ff ff       	call   8001d4 <_panic>
		}
	}
}
  801e4f:	83 c4 1c             	add    $0x1c,%esp
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5f                   	pop    %edi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	53                   	push   %ebx
  801e5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e63:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801e6a:	89 c2                	mov    %eax,%edx
  801e6c:	c1 e2 07             	shl    $0x7,%edx
  801e6f:	29 ca                	sub    %ecx,%edx
  801e71:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e77:	8b 52 50             	mov    0x50(%edx),%edx
  801e7a:	39 da                	cmp    %ebx,%edx
  801e7c:	75 0f                	jne    801e8d <ipc_find_env+0x36>
			return envs[i].env_id;
  801e7e:	c1 e0 07             	shl    $0x7,%eax
  801e81:	29 c8                	sub    %ecx,%eax
  801e83:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e88:	8b 40 40             	mov    0x40(%eax),%eax
  801e8b:	eb 0c                	jmp    801e99 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e8d:	40                   	inc    %eax
  801e8e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e93:	75 ce                	jne    801e63 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e95:	66 b8 00 00          	mov    $0x0,%ax
}
  801e99:	5b                   	pop    %ebx
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ea2:	89 c2                	mov    %eax,%edx
  801ea4:	c1 ea 16             	shr    $0x16,%edx
  801ea7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801eae:	f6 c2 01             	test   $0x1,%dl
  801eb1:	74 1e                	je     801ed1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eb3:	c1 e8 0c             	shr    $0xc,%eax
  801eb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ebd:	a8 01                	test   $0x1,%al
  801ebf:	74 17                	je     801ed8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ec1:	c1 e8 0c             	shr    $0xc,%eax
  801ec4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ecb:	ef 
  801ecc:	0f b7 c0             	movzwl %ax,%eax
  801ecf:	eb 0c                	jmp    801edd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed6:	eb 05                	jmp    801edd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ed8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    
	...

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	83 ec 10             	sub    $0x10,%esp
  801ee6:	8b 74 24 20          	mov    0x20(%esp),%esi
  801eea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801eee:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801ef6:	89 cd                	mov    %ecx,%ebp
  801ef8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801efc:	85 c0                	test   %eax,%eax
  801efe:	75 2c                	jne    801f2c <__udivdi3+0x4c>
  801f00:	39 f9                	cmp    %edi,%ecx
  801f02:	77 68                	ja     801f6c <__udivdi3+0x8c>
  801f04:	85 c9                	test   %ecx,%ecx
  801f06:	75 0b                	jne    801f13 <__udivdi3+0x33>
  801f08:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0d:	31 d2                	xor    %edx,%edx
  801f0f:	f7 f1                	div    %ecx
  801f11:	89 c1                	mov    %eax,%ecx
  801f13:	31 d2                	xor    %edx,%edx
  801f15:	89 f8                	mov    %edi,%eax
  801f17:	f7 f1                	div    %ecx
  801f19:	89 c7                	mov    %eax,%edi
  801f1b:	89 f0                	mov    %esi,%eax
  801f1d:	f7 f1                	div    %ecx
  801f1f:	89 c6                	mov    %eax,%esi
  801f21:	89 f0                	mov    %esi,%eax
  801f23:	89 fa                	mov    %edi,%edx
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	5e                   	pop    %esi
  801f29:	5f                   	pop    %edi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    
  801f2c:	39 f8                	cmp    %edi,%eax
  801f2e:	77 2c                	ja     801f5c <__udivdi3+0x7c>
  801f30:	0f bd f0             	bsr    %eax,%esi
  801f33:	83 f6 1f             	xor    $0x1f,%esi
  801f36:	75 4c                	jne    801f84 <__udivdi3+0xa4>
  801f38:	39 f8                	cmp    %edi,%eax
  801f3a:	bf 00 00 00 00       	mov    $0x0,%edi
  801f3f:	72 0a                	jb     801f4b <__udivdi3+0x6b>
  801f41:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801f45:	0f 87 ad 00 00 00    	ja     801ff8 <__udivdi3+0x118>
  801f4b:	be 01 00 00 00       	mov    $0x1,%esi
  801f50:	89 f0                	mov    %esi,%eax
  801f52:	89 fa                	mov    %edi,%edx
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	5e                   	pop    %esi
  801f58:	5f                   	pop    %edi
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    
  801f5b:	90                   	nop
  801f5c:	31 ff                	xor    %edi,%edi
  801f5e:	31 f6                	xor    %esi,%esi
  801f60:	89 f0                	mov    %esi,%eax
  801f62:	89 fa                	mov    %edi,%edx
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	5e                   	pop    %esi
  801f68:	5f                   	pop    %edi
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    
  801f6b:	90                   	nop
  801f6c:	89 fa                	mov    %edi,%edx
  801f6e:	89 f0                	mov    %esi,%eax
  801f70:	f7 f1                	div    %ecx
  801f72:	89 c6                	mov    %eax,%esi
  801f74:	31 ff                	xor    %edi,%edi
  801f76:	89 f0                	mov    %esi,%eax
  801f78:	89 fa                	mov    %edi,%edx
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	5e                   	pop    %esi
  801f7e:	5f                   	pop    %edi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    
  801f81:	8d 76 00             	lea    0x0(%esi),%esi
  801f84:	89 f1                	mov    %esi,%ecx
  801f86:	d3 e0                	shl    %cl,%eax
  801f88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8c:	b8 20 00 00 00       	mov    $0x20,%eax
  801f91:	29 f0                	sub    %esi,%eax
  801f93:	89 ea                	mov    %ebp,%edx
  801f95:	88 c1                	mov    %al,%cl
  801f97:	d3 ea                	shr    %cl,%edx
  801f99:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801f9d:	09 ca                	or     %ecx,%edx
  801f9f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fa3:	89 f1                	mov    %esi,%ecx
  801fa5:	d3 e5                	shl    %cl,%ebp
  801fa7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801fab:	89 fd                	mov    %edi,%ebp
  801fad:	88 c1                	mov    %al,%cl
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 fa                	mov    %edi,%edx
  801fb3:	89 f1                	mov    %esi,%ecx
  801fb5:	d3 e2                	shl    %cl,%edx
  801fb7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fbb:	88 c1                	mov    %al,%cl
  801fbd:	d3 ef                	shr    %cl,%edi
  801fbf:	09 d7                	or     %edx,%edi
  801fc1:	89 f8                	mov    %edi,%eax
  801fc3:	89 ea                	mov    %ebp,%edx
  801fc5:	f7 74 24 08          	divl   0x8(%esp)
  801fc9:	89 d1                	mov    %edx,%ecx
  801fcb:	89 c7                	mov    %eax,%edi
  801fcd:	f7 64 24 0c          	mull   0xc(%esp)
  801fd1:	39 d1                	cmp    %edx,%ecx
  801fd3:	72 17                	jb     801fec <__udivdi3+0x10c>
  801fd5:	74 09                	je     801fe0 <__udivdi3+0x100>
  801fd7:	89 fe                	mov    %edi,%esi
  801fd9:	31 ff                	xor    %edi,%edi
  801fdb:	e9 41 ff ff ff       	jmp    801f21 <__udivdi3+0x41>
  801fe0:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fe4:	89 f1                	mov    %esi,%ecx
  801fe6:	d3 e2                	shl    %cl,%edx
  801fe8:	39 c2                	cmp    %eax,%edx
  801fea:	73 eb                	jae    801fd7 <__udivdi3+0xf7>
  801fec:	8d 77 ff             	lea    -0x1(%edi),%esi
  801fef:	31 ff                	xor    %edi,%edi
  801ff1:	e9 2b ff ff ff       	jmp    801f21 <__udivdi3+0x41>
  801ff6:	66 90                	xchg   %ax,%ax
  801ff8:	31 f6                	xor    %esi,%esi
  801ffa:	e9 22 ff ff ff       	jmp    801f21 <__udivdi3+0x41>
	...

00802000 <__umoddi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	83 ec 20             	sub    $0x20,%esp
  802006:	8b 44 24 30          	mov    0x30(%esp),%eax
  80200a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80200e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802012:	8b 74 24 34          	mov    0x34(%esp),%esi
  802016:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80201a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80201e:	89 c7                	mov    %eax,%edi
  802020:	89 f2                	mov    %esi,%edx
  802022:	85 ed                	test   %ebp,%ebp
  802024:	75 16                	jne    80203c <__umoddi3+0x3c>
  802026:	39 f1                	cmp    %esi,%ecx
  802028:	0f 86 a6 00 00 00    	jbe    8020d4 <__umoddi3+0xd4>
  80202e:	f7 f1                	div    %ecx
  802030:	89 d0                	mov    %edx,%eax
  802032:	31 d2                	xor    %edx,%edx
  802034:	83 c4 20             	add    $0x20,%esp
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
  80203b:	90                   	nop
  80203c:	39 f5                	cmp    %esi,%ebp
  80203e:	0f 87 ac 00 00 00    	ja     8020f0 <__umoddi3+0xf0>
  802044:	0f bd c5             	bsr    %ebp,%eax
  802047:	83 f0 1f             	xor    $0x1f,%eax
  80204a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80204e:	0f 84 a8 00 00 00    	je     8020fc <__umoddi3+0xfc>
  802054:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802058:	d3 e5                	shl    %cl,%ebp
  80205a:	bf 20 00 00 00       	mov    $0x20,%edi
  80205f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802063:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802067:	89 f9                	mov    %edi,%ecx
  802069:	d3 e8                	shr    %cl,%eax
  80206b:	09 e8                	or     %ebp,%eax
  80206d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802071:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802075:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802079:	d3 e0                	shl    %cl,%eax
  80207b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207f:	89 f2                	mov    %esi,%edx
  802081:	d3 e2                	shl    %cl,%edx
  802083:	8b 44 24 14          	mov    0x14(%esp),%eax
  802087:	d3 e0                	shl    %cl,%eax
  802089:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80208d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802091:	89 f9                	mov    %edi,%ecx
  802093:	d3 e8                	shr    %cl,%eax
  802095:	09 d0                	or     %edx,%eax
  802097:	d3 ee                	shr    %cl,%esi
  802099:	89 f2                	mov    %esi,%edx
  80209b:	f7 74 24 18          	divl   0x18(%esp)
  80209f:	89 d6                	mov    %edx,%esi
  8020a1:	f7 64 24 0c          	mull   0xc(%esp)
  8020a5:	89 c5                	mov    %eax,%ebp
  8020a7:	89 d1                	mov    %edx,%ecx
  8020a9:	39 d6                	cmp    %edx,%esi
  8020ab:	72 67                	jb     802114 <__umoddi3+0x114>
  8020ad:	74 75                	je     802124 <__umoddi3+0x124>
  8020af:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8020b3:	29 e8                	sub    %ebp,%eax
  8020b5:	19 ce                	sbb    %ecx,%esi
  8020b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	89 f2                	mov    %esi,%edx
  8020bf:	89 f9                	mov    %edi,%ecx
  8020c1:	d3 e2                	shl    %cl,%edx
  8020c3:	09 d0                	or     %edx,%eax
  8020c5:	89 f2                	mov    %esi,%edx
  8020c7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020cb:	d3 ea                	shr    %cl,%edx
  8020cd:	83 c4 20             	add    $0x20,%esp
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	85 c9                	test   %ecx,%ecx
  8020d6:	75 0b                	jne    8020e3 <__umoddi3+0xe3>
  8020d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8020dd:	31 d2                	xor    %edx,%edx
  8020df:	f7 f1                	div    %ecx
  8020e1:	89 c1                	mov    %eax,%ecx
  8020e3:	89 f0                	mov    %esi,%eax
  8020e5:	31 d2                	xor    %edx,%edx
  8020e7:	f7 f1                	div    %ecx
  8020e9:	89 f8                	mov    %edi,%eax
  8020eb:	e9 3e ff ff ff       	jmp    80202e <__umoddi3+0x2e>
  8020f0:	89 f2                	mov    %esi,%edx
  8020f2:	83 c4 20             	add    $0x20,%esp
  8020f5:	5e                   	pop    %esi
  8020f6:	5f                   	pop    %edi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    
  8020f9:	8d 76 00             	lea    0x0(%esi),%esi
  8020fc:	39 f5                	cmp    %esi,%ebp
  8020fe:	72 04                	jb     802104 <__umoddi3+0x104>
  802100:	39 f9                	cmp    %edi,%ecx
  802102:	77 06                	ja     80210a <__umoddi3+0x10a>
  802104:	89 f2                	mov    %esi,%edx
  802106:	29 cf                	sub    %ecx,%edi
  802108:	19 ea                	sbb    %ebp,%edx
  80210a:	89 f8                	mov    %edi,%eax
  80210c:	83 c4 20             	add    $0x20,%esp
  80210f:	5e                   	pop    %esi
  802110:	5f                   	pop    %edi
  802111:	5d                   	pop    %ebp
  802112:	c3                   	ret    
  802113:	90                   	nop
  802114:	89 d1                	mov    %edx,%ecx
  802116:	89 c5                	mov    %eax,%ebp
  802118:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80211c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802120:	eb 8d                	jmp    8020af <__umoddi3+0xaf>
  802122:	66 90                	xchg   %ax,%ax
  802124:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802128:	72 ea                	jb     802114 <__umoddi3+0x114>
  80212a:	89 f1                	mov    %esi,%ecx
  80212c:	eb 81                	jmp    8020af <__umoddi3+0xaf>
