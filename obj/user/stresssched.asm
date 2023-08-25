
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 8e 0b 00 00       	call   800bcf <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 52 0f 00 00       	call   800f9f <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 08                	je     800059 <umain+0x25>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800051:	43                   	inc    %ebx
  800052:	83 fb 14             	cmp    $0x14,%ebx
  800055:	75 f1                	jne    800048 <umain+0x14>
  800057:	eb 05                	jmp    80005e <umain+0x2a>
		if (fork() == 0)
			break;
	if (i == 20) {
  800059:	83 fb 14             	cmp    $0x14,%ebx
  80005c:	75 0e                	jne    80006c <umain+0x38>
		sys_yield();
  80005e:	e8 8b 0b 00 00       	call   800bee <sys_yield>
		return;
  800063:	e9 97 00 00 00       	jmp    8000ff <umain+0xcb>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800068:	f3 90                	pause  
  80006a:	eb 1a                	jmp    800086 <umain+0x52>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800079:	89 f2                	mov    %esi,%edx
  80007b:	c1 e2 07             	shl    $0x7,%edx
  80007e:	29 c2                	sub    %eax,%edx
  800080:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800086:	8b 42 50             	mov    0x50(%edx),%eax
  800089:	85 c0                	test   %eax,%eax
  80008b:	75 db                	jne    800068 <umain+0x34>
  80008d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800092:	e8 57 0b 00 00       	call   800bee <sys_yield>
  800097:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  80009c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000a2:	42                   	inc    %edx
  8000a3:	89 15 04 40 80 00    	mov    %edx,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a9:	48                   	dec    %eax
  8000aa:	75 f0                	jne    80009c <umain+0x68>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ac:	4b                   	dec    %ebx
  8000ad:	75 e3                	jne    800092 <umain+0x5e>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000af:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b9:	74 25                	je     8000e0 <umain+0xac>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 e8 23 80 00 	movl   $0x8023e8,(%esp)
  8000db:	e8 98 00 00 00       	call   800178 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8000e5:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000e8:	8b 40 48             	mov    0x48(%eax),%eax
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 fb 23 80 00 	movl   $0x8023fb,(%esp)
  8000fa:	e8 71 01 00 00       	call   800270 <cprintf>

}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    
	...

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	83 ec 10             	sub    $0x10,%esp
  800110:	8b 75 08             	mov    0x8(%ebp),%esi
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800116:	e8 b4 0a 00 00       	call   800bcf <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 f6                	test   %esi,%esi
  800138:	7e 07                	jle    800141 <libmain+0x39>
		binaryname = argv[0];
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800145:	89 34 24             	mov    %esi,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014d:	e8 0a 00 00 00       	call   80015c <exit>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800162:	e8 a0 12 00 00       	call   801407 <close_all>
	sys_env_destroy(0);
  800167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016e:	e8 0a 0a 00 00       	call   800b7d <sys_env_destroy>
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
  800175:	00 00                	add    %al,(%eax)
	...

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800180:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800183:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800189:	e8 41 0a 00 00       	call   800bcf <sys_getenvid>
  80018e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800191:	89 54 24 10          	mov    %edx,0x10(%esp)
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80019c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 24 24 80 00 	movl   $0x802424,(%esp)
  8001ab:	e8 c0 00 00 00       	call   800270 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 50 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 17 24 80 00 	movl   $0x802417,(%esp)
  8001c6:	e8 a5 00 00 00       	call   800270 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cb:	cc                   	int3   
  8001cc:	eb fd                	jmp    8001cb <_panic+0x53>
	...

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 14             	sub    $0x14,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	40                   	inc    %eax
  8001e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001eb:	75 19                	jne    800206 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f4:	00 
  8001f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 40 09 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  800200:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800206:	ff 43 04             	incl   0x4(%ebx)
}
  800209:	83 c4 14             	add    $0x14,%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	c7 04 24 d0 01 80 00 	movl   $0x8001d0,(%esp)
  80024b:	e8 82 01 00 00       	call   8003d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 d8 08 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  800268:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800276:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	e8 87 ff ff ff       	call   80020f <vcprintf>
	va_end(ap);

	return cnt;
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    
	...

0080028c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800298:	89 d7                	mov    %edx,%edi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ac:	85 c0                	test   %eax,%eax
  8002ae:	75 08                	jne    8002b8 <printnum+0x2c>
  8002b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b6:	77 57                	ja     80030f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002bc:	4b                   	dec    %ebx
  8002bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d7:	00 
  8002d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	e8 7e 1e 00 00       	call   802168 <__udivdi3>
  8002ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f9:	89 fa                	mov    %edi,%edx
  8002fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fe:	e8 89 ff ff ff       	call   80028c <printnum>
  800303:	eb 0f                	jmp    800314 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800309:	89 34 24             	mov    %esi,(%esp)
  80030c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030f:	4b                   	dec    %ebx
  800310:	85 db                	test   %ebx,%ebx
  800312:	7f f1                	jg     800305 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800314:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800318:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032a:	00 
  80032b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032e:	89 04 24             	mov    %eax,(%esp)
  800331:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800334:	89 44 24 04          	mov    %eax,0x4(%esp)
  800338:	e8 4b 1f 00 00       	call   802288 <__umoddi3>
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  800348:	89 04 24             	mov    %eax,(%esp)
  80034b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034e:	83 c4 3c             	add    $0x3c,%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800359:	83 fa 01             	cmp    $0x1,%edx
  80035c:	7e 0e                	jle    80036c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	8d 4a 08             	lea    0x8(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 02                	mov    (%edx),%eax
  800367:	8b 52 04             	mov    0x4(%edx),%edx
  80036a:	eb 22                	jmp    80038e <getuint+0x38>
	else if (lflag)
  80036c:	85 d2                	test   %edx,%edx
  80036e:	74 10                	je     800380 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	eb 0e                	jmp    80038e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 04             	lea    0x4(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800396:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	3b 50 04             	cmp    0x4(%eax),%edx
  80039e:	73 08                	jae    8003a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a3:	88 0a                	mov    %cl,(%edx)
  8003a5:	42                   	inc    %edx
  8003a6:	89 10                	mov    %edx,(%eax)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	e8 02 00 00 00       	call   8003d2 <vprintfmt>
	va_end(ap);
}
  8003d0:	c9                   	leave  
  8003d1:	c3                   	ret    

008003d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 4c             	sub    $0x4c,%esp
  8003db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003de:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e1:	eb 12                	jmp    8003f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	0f 84 6b 03 00 00    	je     800756 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f5:	0f b6 06             	movzbl (%esi),%eax
  8003f8:	46                   	inc    %esi
  8003f9:	83 f8 25             	cmp    $0x25,%eax
  8003fc:	75 e5                	jne    8003e3 <vprintfmt+0x11>
  8003fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800402:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800409:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	eb 26                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800423:	eb 1d                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800428:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80042c:	eb 14                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800431:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800438:	eb 08                	jmp    800442 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80043d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	0f b6 06             	movzbl (%esi),%eax
  800445:	8d 56 01             	lea    0x1(%esi),%edx
  800448:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80044b:	8a 16                	mov    (%esi),%dl
  80044d:	83 ea 23             	sub    $0x23,%edx
  800450:	80 fa 55             	cmp    $0x55,%dl
  800453:	0f 87 e1 02 00 00    	ja     80073a <vprintfmt+0x368>
  800459:	0f b6 d2             	movzbl %dl,%edx
  80045c:	ff 24 95 80 25 80 00 	jmp    *0x802580(,%edx,4)
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800466:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80046e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800472:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800475:	8d 50 d0             	lea    -0x30(%eax),%edx
  800478:	83 fa 09             	cmp    $0x9,%edx
  80047b:	77 2a                	ja     8004a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047e:	eb eb                	jmp    80046b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048e:	eb 17                	jmp    8004a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800490:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800494:	78 98                	js     80042e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800499:	eb a7                	jmp    800442 <vprintfmt+0x70>
  80049b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a5:	eb 9b                	jmp    800442 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ab:	79 95                	jns    800442 <vprintfmt+0x70>
  8004ad:	eb 8b                	jmp    80043a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b3:	eb 8d                	jmp    800442 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004cd:	e9 23 ff ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	79 02                	jns    8004e3 <vprintfmt+0x111>
  8004e1:	f7 d8                	neg    %eax
  8004e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e5:	83 f8 0f             	cmp    $0xf,%eax
  8004e8:	7f 0b                	jg     8004f5 <vprintfmt+0x123>
  8004ea:	8b 04 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%eax
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	75 23                	jne    800518 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f9:	c7 44 24 08 5f 24 80 	movl   $0x80245f,0x8(%esp)
  800500:	00 
  800501:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 9a fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800513:	e9 dd fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800518:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051c:	c7 44 24 08 4e 29 80 	movl   $0x80294e,0x8(%esp)
  800523:	00 
  800524:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800528:	8b 55 08             	mov    0x8(%ebp),%edx
  80052b:	89 14 24             	mov    %edx,(%esp)
  80052e:	e8 77 fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800536:	e9 ba fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
  80053b:	89 f9                	mov    %edi,%ecx
  80053d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800540:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 30                	mov    (%eax),%esi
  80054e:	85 f6                	test   %esi,%esi
  800550:	75 05                	jne    800557 <vprintfmt+0x185>
				p = "(null)";
  800552:	be 58 24 80 00       	mov    $0x802458,%esi
			if (width > 0 && padc != '-')
  800557:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055b:	0f 8e 84 00 00 00    	jle    8005e5 <vprintfmt+0x213>
  800561:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800565:	74 7e                	je     8005e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056b:	89 34 24             	mov    %esi,(%esp)
  80056e:	e8 8b 02 00 00       	call   8007fe <strnlen>
  800573:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800576:	29 c2                	sub    %eax,%edx
  800578:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80057b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80057f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800582:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800585:	89 de                	mov    %ebx,%esi
  800587:	89 d3                	mov    %edx,%ebx
  800589:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	eb 0b                	jmp    800598 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80058d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800591:	89 3c 24             	mov    %edi,(%esp)
  800594:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	4b                   	dec    %ebx
  800598:	85 db                	test   %ebx,%ebx
  80059a:	7f f1                	jg     80058d <vprintfmt+0x1bb>
  80059c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059f:	89 f3                	mov    %esi,%ebx
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	79 05                	jns    8005b0 <vprintfmt+0x1de>
  8005ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b3:	29 c2                	sub    %eax,%edx
  8005b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b8:	eb 2b                	jmp    8005e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005be:	74 18                	je     8005d8 <vprintfmt+0x206>
  8005c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c3:	83 fa 5e             	cmp    $0x5e,%edx
  8005c6:	76 10                	jbe    8005d8 <vprintfmt+0x206>
					putch('?', putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
  8005d6:	eb 0a                	jmp    8005e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e5:	0f be 06             	movsbl (%esi),%eax
  8005e8:	46                   	inc    %esi
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	74 21                	je     80060e <vprintfmt+0x23c>
  8005ed:	85 ff                	test   %edi,%edi
  8005ef:	78 c9                	js     8005ba <vprintfmt+0x1e8>
  8005f1:	4f                   	dec    %edi
  8005f2:	79 c6                	jns    8005ba <vprintfmt+0x1e8>
  8005f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f7:	89 de                	mov    %ebx,%esi
  8005f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fc:	eb 18                	jmp    800616 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800602:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800609:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	4b                   	dec    %ebx
  80060c:	eb 08                	jmp    800616 <vprintfmt+0x244>
  80060e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800611:	89 de                	mov    %ebx,%esi
  800613:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800616:	85 db                	test   %ebx,%ebx
  800618:	7f e4                	jg     8005fe <vprintfmt+0x22c>
  80061a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80061d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800622:	e9 ce fd ff ff       	jmp    8003f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 f9 01             	cmp    $0x1,%ecx
  80062a:	7e 10                	jle    80063c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 30                	mov    (%eax),%esi
  800637:	8b 78 04             	mov    0x4(%eax),%edi
  80063a:	eb 26                	jmp    800662 <vprintfmt+0x290>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	74 12                	je     800652 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 30                	mov    (%eax),%esi
  80064b:	89 f7                	mov    %esi,%edi
  80064d:	c1 ff 1f             	sar    $0x1f,%edi
  800650:	eb 10                	jmp    800662 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 30                	mov    (%eax),%esi
  80065d:	89 f7                	mov    %esi,%edi
  80065f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800662:	85 ff                	test   %edi,%edi
  800664:	78 0a                	js     800670 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 8c 00 00 00       	jmp    8006fc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80067e:	f7 de                	neg    %esi
  800680:	83 d7 00             	adc    $0x0,%edi
  800683:	f7 df                	neg    %edi
			}
			base = 10;
  800685:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068a:	eb 70                	jmp    8006fc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068c:	89 ca                	mov    %ecx,%edx
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 c0 fc ff ff       	call   800356 <getuint>
  800696:	89 c6                	mov    %eax,%esi
  800698:	89 d7                	mov    %edx,%edi
			base = 10;
  80069a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069f:	eb 5b                	jmp    8006fc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 ab fc ff ff       	call   800356 <getuint>
  8006ab:	89 c6                	mov    %eax,%esi
  8006ad:	89 d7                	mov    %edx,%edi
			base = 8;
  8006af:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006b4:	eb 46                	jmp    8006fc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006db:	8b 30                	mov    (%eax),%esi
  8006dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e7:	eb 13                	jmp    8006fc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 63 fc ff ff       	call   800356 <getuint>
  8006f3:	89 c6                	mov    %eax,%esi
  8006f5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800700:	89 54 24 10          	mov    %edx,0x10(%esp)
  800704:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800707:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070f:	89 34 24             	mov    %esi,(%esp)
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	89 da                	mov    %ebx,%edx
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	e8 6c fb ff ff       	call   80028c <printnum>
			break;
  800720:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800723:	e9 cd fc ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800735:	e9 bb fc ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800745:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800748:	eb 01                	jmp    80074b <vprintfmt+0x379>
  80074a:	4e                   	dec    %esi
  80074b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074f:	75 f9                	jne    80074a <vprintfmt+0x378>
  800751:	e9 9f fc ff ff       	jmp    8003f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800756:	83 c4 4c             	add    $0x4c,%esp
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5f                   	pop    %edi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 28             	sub    $0x28,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 30                	je     8007af <vsnprintf+0x51>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 33                	jle    8007b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	c7 04 24 90 03 80 00 	movl   $0x800390,(%esp)
  80079f:	e8 2e fc ff ff       	call   8003d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ad:	eb 0c                	jmp    8007bb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb 05                	jmp    8007bb <vsnprintf+0x5d>
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	89 04 24             	mov    %eax,(%esp)
  8007de:	e8 7b ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
  8007e5:	00 00                	add    %al,(%eax)
	...

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 01                	jmp    8007f6 <strlen+0xe>
		n++;
  8007f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fa:	75 f9                	jne    8007f5 <strlen+0xd>
		n++;
	return n;
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb 01                	jmp    80080f <strnlen+0x11>
		n++;
  80080e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 d0                	cmp    %edx,%eax
  800811:	74 06                	je     800819 <strnlen+0x1b>
  800813:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800817:	75 f5                	jne    80080e <strnlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	ba 00 00 00 00       	mov    $0x0,%edx
  80082a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80082d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800830:	42                   	inc    %edx
  800831:	84 c9                	test   %cl,%cl
  800833:	75 f5                	jne    80082a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800842:	89 1c 24             	mov    %ebx,(%esp)
  800845:	e8 9e ff ff ff       	call   8007e8 <strlen>
	strcpy(dst + len, src);
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800851:	01 d8                	add    %ebx,%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 c0 ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80085b:	89 d8                	mov    %ebx,%eax
  80085d:	83 c4 08             	add    $0x8,%esp
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
  800876:	eb 0c                	jmp    800884 <strncpy+0x21>
		*dst++ = *src;
  800878:	8a 1a                	mov    (%edx),%bl
  80087a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087d:	80 3a 01             	cmpb   $0x1,(%edx)
  800880:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800883:	41                   	inc    %ecx
  800884:	39 f1                	cmp    %esi,%ecx
  800886:	75 f0                	jne    800878 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 75 08             	mov    0x8(%ebp),%esi
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089a:	85 d2                	test   %edx,%edx
  80089c:	75 0a                	jne    8008a8 <strlcpy+0x1c>
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	eb 1a                	jmp    8008bc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a2:	88 18                	mov    %bl,(%eax)
  8008a4:	40                   	inc    %eax
  8008a5:	41                   	inc    %ecx
  8008a6:	eb 02                	jmp    8008aa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008aa:	4a                   	dec    %edx
  8008ab:	74 0a                	je     8008b7 <strlcpy+0x2b>
  8008ad:	8a 19                	mov    (%ecx),%bl
  8008af:	84 db                	test   %bl,%bl
  8008b1:	75 ef                	jne    8008a2 <strlcpy+0x16>
  8008b3:	89 c2                	mov    %eax,%edx
  8008b5:	eb 02                	jmp    8008b9 <strlcpy+0x2d>
  8008b7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008bc:	29 f0                	sub    %esi,%eax
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cb:	eb 02                	jmp    8008cf <strcmp+0xd>
		p++, q++;
  8008cd:	41                   	inc    %ecx
  8008ce:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cf:	8a 01                	mov    (%ecx),%al
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x17>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 f4                	je     8008cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 03                	jmp    8008f5 <strncmp+0x12>
		n--, p++, q++;
  8008f2:	4a                   	dec    %edx
  8008f3:	40                   	inc    %eax
  8008f4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 14                	je     80090d <strncmp+0x2a>
  8008f9:	8a 18                	mov    (%eax),%bl
  8008fb:	84 db                	test   %bl,%bl
  8008fd:	74 04                	je     800903 <strncmp+0x20>
  8008ff:	3a 19                	cmp    (%ecx),%bl
  800901:	74 ef                	je     8008f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800903:	0f b6 00             	movzbl (%eax),%eax
  800906:	0f b6 11             	movzbl (%ecx),%edx
  800909:	29 d0                	sub    %edx,%eax
  80090b:	eb 05                	jmp    800912 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091e:	eb 05                	jmp    800925 <strchr+0x10>
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 0c                	je     800930 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800924:	40                   	inc    %eax
  800925:	8a 10                	mov    (%eax),%dl
  800927:	84 d2                	test   %dl,%dl
  800929:	75 f5                	jne    800920 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093b:	eb 05                	jmp    800942 <strfind+0x10>
		if (*s == c)
  80093d:	38 ca                	cmp    %cl,%dl
  80093f:	74 07                	je     800948 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800941:	40                   	inc    %eax
  800942:	8a 10                	mov    (%eax),%dl
  800944:	84 d2                	test   %dl,%dl
  800946:	75 f5                	jne    80093d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 7d 08             	mov    0x8(%ebp),%edi
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	74 30                	je     80098d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800963:	75 25                	jne    80098a <memset+0x40>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 20                	jne    80098a <memset+0x40>
		c &= 0xFF;
  80096a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 d0                	or     %edx,%eax
  800980:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800982:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800985:	fc                   	cld    
  800986:	f3 ab                	rep stos %eax,%es:(%edi)
  800988:	eb 03                	jmp    80098d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098a:	fc                   	cld    
  80098b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a2:	39 c6                	cmp    %eax,%esi
  8009a4:	73 34                	jae    8009da <memmove+0x46>
  8009a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a9:	39 d0                	cmp    %edx,%eax
  8009ab:	73 2d                	jae    8009da <memmove+0x46>
		s += n;
		d += n;
  8009ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	f6 c2 03             	test   $0x3,%dl
  8009b3:	75 1b                	jne    8009d0 <memmove+0x3c>
  8009b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bb:	75 13                	jne    8009d0 <memmove+0x3c>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 0e                	jne    8009d0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c2:	83 ef 04             	sub    $0x4,%edi
  8009c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009cb:	fd                   	std    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 07                	jmp    8009d7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d0:	4f                   	dec    %edi
  8009d1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d4:	fd                   	std    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d7:	fc                   	cld    
  8009d8:	eb 20                	jmp    8009fa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e0:	75 13                	jne    8009f5 <memmove+0x61>
  8009e2:	a8 03                	test   $0x3,%al
  8009e4:	75 0f                	jne    8009f5 <memmove+0x61>
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 0a                	jne    8009f5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ee:	89 c7                	mov    %eax,%edi
  8009f0:	fc                   	cld    
  8009f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f3:	eb 05                	jmp    8009fa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a04:	8b 45 10             	mov    0x10(%ebp),%eax
  800a07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 77 ff ff ff       	call   800994 <memmove>
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a33:	eb 16                	jmp    800a4b <memcmp+0x2c>
		if (*s1 != *s2)
  800a35:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a38:	42                   	inc    %edx
  800a39:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a3d:	38 c8                	cmp    %cl,%al
  800a3f:	74 0a                	je     800a4b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a41:	0f b6 c0             	movzbl %al,%eax
  800a44:	0f b6 c9             	movzbl %cl,%ecx
  800a47:	29 c8                	sub    %ecx,%eax
  800a49:	eb 09                	jmp    800a54 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	39 da                	cmp    %ebx,%edx
  800a4d:	75 e6                	jne    800a35 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a62:	89 c2                	mov    %eax,%edx
  800a64:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a67:	eb 05                	jmp    800a6e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	38 08                	cmp    %cl,(%eax)
  800a6b:	74 05                	je     800a72 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6d:	40                   	inc    %eax
  800a6e:	39 d0                	cmp    %edx,%eax
  800a70:	72 f7                	jb     800a69 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a80:	eb 01                	jmp    800a83 <strtol+0xf>
		s++;
  800a82:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a83:	8a 02                	mov    (%edx),%al
  800a85:	3c 20                	cmp    $0x20,%al
  800a87:	74 f9                	je     800a82 <strtol+0xe>
  800a89:	3c 09                	cmp    $0x9,%al
  800a8b:	74 f5                	je     800a82 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8d:	3c 2b                	cmp    $0x2b,%al
  800a8f:	75 08                	jne    800a99 <strtol+0x25>
		s++;
  800a91:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a92:	bf 00 00 00 00       	mov    $0x0,%edi
  800a97:	eb 13                	jmp    800aac <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a99:	3c 2d                	cmp    $0x2d,%al
  800a9b:	75 0a                	jne    800aa7 <strtol+0x33>
		s++, neg = 1;
  800a9d:	8d 52 01             	lea    0x1(%edx),%edx
  800aa0:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa5:	eb 05                	jmp    800aac <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	74 05                	je     800ab5 <strtol+0x41>
  800ab0:	83 fb 10             	cmp    $0x10,%ebx
  800ab3:	75 28                	jne    800add <strtol+0x69>
  800ab5:	8a 02                	mov    (%edx),%al
  800ab7:	3c 30                	cmp    $0x30,%al
  800ab9:	75 10                	jne    800acb <strtol+0x57>
  800abb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abf:	75 0a                	jne    800acb <strtol+0x57>
		s += 2, base = 16;
  800ac1:	83 c2 02             	add    $0x2,%edx
  800ac4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac9:	eb 12                	jmp    800add <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	75 0e                	jne    800add <strtol+0x69>
  800acf:	3c 30                	cmp    $0x30,%al
  800ad1:	75 05                	jne    800ad8 <strtol+0x64>
		s++, base = 8;
  800ad3:	42                   	inc    %edx
  800ad4:	b3 08                	mov    $0x8,%bl
  800ad6:	eb 05                	jmp    800add <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae4:	8a 0a                	mov    (%edx),%cl
  800ae6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae9:	80 fb 09             	cmp    $0x9,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x82>
			dig = *s - '0';
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 30             	sub    $0x30,%ecx
  800af4:	eb 1e                	jmp    800b14 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afe:	0f be c9             	movsbl %cl,%ecx
  800b01:	83 e9 57             	sub    $0x57,%ecx
  800b04:	eb 0e                	jmp    800b14 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 12                	ja     800b20 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0e:	0f be c9             	movsbl %cl,%ecx
  800b11:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b14:	39 f1                	cmp    %esi,%ecx
  800b16:	7d 0c                	jge    800b24 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b18:	42                   	inc    %edx
  800b19:	0f af c6             	imul   %esi,%eax
  800b1c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1e:	eb c4                	jmp    800ae4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b20:	89 c1                	mov    %eax,%ecx
  800b22:	eb 02                	jmp    800b26 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b24:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2a:	74 05                	je     800b31 <strtol+0xbd>
		*endptr = (char *) s;
  800b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b31:	85 ff                	test   %edi,%edi
  800b33:	74 04                	je     800b39 <strtol+0xc5>
  800b35:	89 c8                	mov    %ecx,%eax
  800b37:	f7 d8                	neg    %eax
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    
	...

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 cb                	mov    %ecx,%ebx
  800b95:	89 cf                	mov    %ecx,%edi
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 28                	jle    800bc7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800baa:	00 
  800bab:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bba:	00 
  800bbb:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800bc2:	e8 b1 f5 ff ff       	call   800178 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc7:	83 c4 2c             	add    $0x2c,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdf:	89 d1                	mov    %edx,%ecx
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	89 d7                	mov    %edx,%edi
  800be5:	89 d6                	mov    %edx,%esi
  800be7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_yield>:

void
sys_yield(void)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfe:	89 d1                	mov    %edx,%ecx
  800c00:	89 d3                	mov    %edx,%ebx
  800c02:	89 d7                	mov    %edx,%edi
  800c04:	89 d6                	mov    %edx,%esi
  800c06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	be 00 00 00 00       	mov    $0x0,%esi
  800c1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 f7                	mov    %esi,%edi
  800c2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	7e 28                	jle    800c59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800c44:	00 
  800c45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4c:	00 
  800c4d:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800c54:	e8 1f f5 ff ff       	call   800178 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c59:	83 c4 2c             	add    $0x2c,%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 28                	jle    800cac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c8f:	00 
  800c90:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800c97:	00 
  800c98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9f:	00 
  800ca0:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800ca7:	e8 cc f4 ff ff       	call   800178 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cac:	83 c4 2c             	add    $0x2c,%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800cfa:	e8 79 f4 ff ff       	call   800178 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800d4d:	e8 26 f4 ff ff       	call   800178 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800da0:	e8 d3 f3 ff ff       	call   800178 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800df3:	e8 80 f3 ff ff       	call   800178 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df8:	83 c4 2c             	add    $0x2c,%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	be 00 00 00 00       	mov    $0x0,%esi
  800e0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 cb                	mov    %ecx,%ebx
  800e3b:	89 cf                	mov    %ecx,%edi
  800e3d:	89 ce                	mov    %ecx,%esi
  800e3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 28                	jle    800e6d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e49:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e50:	00 
  800e51:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e58:	00 
  800e59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e60:	00 
  800e61:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e68:	e8 0b f3 ff ff       	call   800178 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6d:	83 c4 2c             	add    $0x2c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	00 00                	add    %al,(%eax)
	...

00800e78 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 24             	sub    $0x24,%esp
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e82:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800e84:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e88:	75 2d                	jne    800eb7 <pgfault+0x3f>
  800e8a:	89 d8                	mov    %ebx,%eax
  800e8c:	c1 e8 0c             	shr    $0xc,%eax
  800e8f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e96:	f6 c4 08             	test   $0x8,%ah
  800e99:	75 1c                	jne    800eb7 <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800e9b:	c7 44 24 08 6c 27 80 	movl   $0x80276c,0x8(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800eaa:	00 
  800eab:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  800eb2:	e8 c1 f2 ff ff       	call   800178 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800eb7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ec6:	00 
  800ec7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ece:	e8 3a fd ff ff       	call   800c0d <sys_page_alloc>
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 20                	jns    800ef7 <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800ed7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edb:	c7 44 24 08 db 27 80 	movl   $0x8027db,0x8(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800eea:	00 
  800eeb:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  800ef2:	e8 81 f2 ff ff       	call   800178 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800ef7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800efd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f04:	00 
  800f05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f09:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f10:	e8 e9 fa ff ff       	call   8009fe <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f15:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f1c:	00 
  800f1d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f38:	e8 24 fd ff ff       	call   800c61 <sys_page_map>
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 20                	jns    800f61 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  800f41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f45:	c7 44 24 08 ee 27 80 	movl   $0x8027ee,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  800f5c:	e8 17 f2 ff ff       	call   800178 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f61:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f68:	00 
  800f69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f70:	e8 3f fd ff ff       	call   800cb4 <sys_page_unmap>
  800f75:	85 c0                	test   %eax,%eax
  800f77:	79 20                	jns    800f99 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  800f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7d:	c7 44 24 08 ff 27 80 	movl   $0x8027ff,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  800f94:	e8 df f1 ff ff       	call   800178 <_panic>
}
  800f99:	83 c4 24             	add    $0x24,%esp
  800f9c:	5b                   	pop    %ebx
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  800fa8:	c7 04 24 78 0e 80 00 	movl   $0x800e78,(%esp)
  800faf:	e8 e4 0f 00 00       	call   801f98 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb4:	ba 07 00 00 00       	mov    $0x7,%edx
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	cd 30                	int    $0x30
  800fbd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	79 1c                	jns    800fe3 <fork+0x44>
		panic("sys_exofork failed\n");
  800fc7:	c7 44 24 08 12 28 80 	movl   $0x802812,0x8(%esp)
  800fce:	00 
  800fcf:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  800fd6:	00 
  800fd7:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  800fde:	e8 95 f1 ff ff       	call   800178 <_panic>
	if(c_envid == 0){
  800fe3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fe7:	75 25                	jne    80100e <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe9:	e8 e1 fb ff ff       	call   800bcf <sys_getenvid>
  800fee:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ffa:	c1 e0 07             	shl    $0x7,%eax
  800ffd:	29 d0                	sub    %edx,%eax
  800fff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801004:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801009:	e9 e3 01 00 00       	jmp    8011f1 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  80100e:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  801013:	89 d8                	mov    %ebx,%eax
  801015:	c1 e8 16             	shr    $0x16,%eax
  801018:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101f:	a8 01                	test   $0x1,%al
  801021:	0f 84 0b 01 00 00    	je     801132 <fork+0x193>
  801027:	89 de                	mov    %ebx,%esi
  801029:	c1 ee 0c             	shr    $0xc,%esi
  80102c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801033:	a8 05                	test   $0x5,%al
  801035:	0f 84 f7 00 00 00    	je     801132 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  80103b:	89 f7                	mov    %esi,%edi
  80103d:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  801040:	e8 8a fb ff ff       	call   800bcf <sys_getenvid>
  801045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801048:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80104f:	a8 02                	test   $0x2,%al
  801051:	75 10                	jne    801063 <fork+0xc4>
  801053:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80105a:	f6 c4 08             	test   $0x8,%ah
  80105d:	0f 84 89 00 00 00    	je     8010ec <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  801063:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80106a:	00 
  80106b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80106f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801072:	89 44 24 08          	mov    %eax,0x8(%esp)
  801076:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80107a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	e8 dc fb ff ff       	call   800c61 <sys_page_map>
  801085:	85 c0                	test   %eax,%eax
  801087:	79 20                	jns    8010a9 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801089:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108d:	c7 44 24 08 26 28 80 	movl   $0x802826,0x8(%esp)
  801094:	00 
  801095:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  80109c:	00 
  80109d:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  8010a4:	e8 cf f0 ff ff       	call   800178 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  8010a9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010b0:	00 
  8010b1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010c0:	89 04 24             	mov    %eax,(%esp)
  8010c3:	e8 99 fb ff ff       	call   800c61 <sys_page_map>
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	79 66                	jns    801132 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8010cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d0:	c7 44 24 08 26 28 80 	movl   $0x802826,0x8(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  8010e7:	e8 8c f0 ff ff       	call   800178 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  8010ec:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010f3:	00 
  8010f4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801103:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801106:	89 04 24             	mov    %eax,(%esp)
  801109:	e8 53 fb ff ff       	call   800c61 <sys_page_map>
  80110e:	85 c0                	test   %eax,%eax
  801110:	79 20                	jns    801132 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  801112:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801116:	c7 44 24 08 26 28 80 	movl   $0x802826,0x8(%esp)
  80111d:	00 
  80111e:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801125:	00 
  801126:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  80112d:	e8 46 f0 ff ff       	call   800178 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  801132:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801138:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80113e:	0f 85 cf fe ff ff    	jne    801013 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801144:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80114b:	00 
  80114c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801153:	ee 
  801154:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	e8 ae fa ff ff       	call   800c0d <sys_page_alloc>
  80115f:	85 c0                	test   %eax,%eax
  801161:	79 20                	jns    801183 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  801163:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801167:	c7 44 24 08 38 28 80 	movl   $0x802838,0x8(%esp)
  80116e:	00 
  80116f:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801176:	00 
  801177:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  80117e:	e8 f5 ef ff ff       	call   800178 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801183:	c7 44 24 04 e4 1f 80 	movl   $0x801fe4,0x4(%esp)
  80118a:	00 
  80118b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80118e:	89 04 24             	mov    %eax,(%esp)
  801191:	e8 17 fc ff ff       	call   800dad <sys_env_set_pgfault_upcall>
  801196:	85 c0                	test   %eax,%eax
  801198:	79 20                	jns    8011ba <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80119a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80119e:	c7 44 24 08 b0 27 80 	movl   $0x8027b0,0x8(%esp)
  8011a5:	00 
  8011a6:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8011ad:	00 
  8011ae:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  8011b5:	e8 be ef ff ff       	call   800178 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  8011ba:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011c1:	00 
  8011c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 3a fb ff ff       	call   800d07 <sys_env_set_status>
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	79 20                	jns    8011f1 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  8011d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011d5:	c7 44 24 08 4c 28 80 	movl   $0x80284c,0x8(%esp)
  8011dc:	00 
  8011dd:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8011e4:	00 
  8011e5:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  8011ec:	e8 87 ef ff ff       	call   800178 <_panic>
 
	return c_envid;	
}
  8011f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011f4:	83 c4 3c             	add    $0x3c,%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5f                   	pop    %edi
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <sfork>:

// Challenge!
int
sfork(void)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801202:	c7 44 24 08 64 28 80 	movl   $0x802864,0x8(%esp)
  801209:	00 
  80120a:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801211:	00 
  801212:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  801219:	e8 5a ef ff ff       	call   800178 <_panic>
	...

00801220 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	05 00 00 00 30       	add    $0x30000000,%eax
  80122b:	c1 e8 0c             	shr    $0xc,%eax
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	89 04 24             	mov    %eax,(%esp)
  80123c:	e8 df ff ff ff       	call   801220 <fd2num>
  801241:	05 20 00 0d 00       	add    $0xd0020,%eax
  801246:	c1 e0 0c             	shl    $0xc,%eax
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	53                   	push   %ebx
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801252:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801257:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801259:	89 c2                	mov    %eax,%edx
  80125b:	c1 ea 16             	shr    $0x16,%edx
  80125e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801265:	f6 c2 01             	test   $0x1,%dl
  801268:	74 11                	je     80127b <fd_alloc+0x30>
  80126a:	89 c2                	mov    %eax,%edx
  80126c:	c1 ea 0c             	shr    $0xc,%edx
  80126f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801276:	f6 c2 01             	test   $0x1,%dl
  801279:	75 09                	jne    801284 <fd_alloc+0x39>
			*fd_store = fd;
  80127b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
  801282:	eb 17                	jmp    80129b <fd_alloc+0x50>
  801284:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801289:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80128e:	75 c7                	jne    801257 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801290:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801296:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80129b:	5b                   	pop    %ebx
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a4:	83 f8 1f             	cmp    $0x1f,%eax
  8012a7:	77 36                	ja     8012df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012ae:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	c1 ea 16             	shr    $0x16,%edx
  8012b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012bd:	f6 c2 01             	test   $0x1,%dl
  8012c0:	74 24                	je     8012e6 <fd_lookup+0x48>
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	c1 ea 0c             	shr    $0xc,%edx
  8012c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ce:	f6 c2 01             	test   $0x1,%dl
  8012d1:	74 1a                	je     8012ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d6:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012dd:	eb 13                	jmp    8012f2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e4:	eb 0c                	jmp    8012f2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012eb:	eb 05                	jmp    8012f2 <fd_lookup+0x54>
  8012ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    

008012f4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 14             	sub    $0x14,%esp
  8012fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801301:	ba 00 00 00 00       	mov    $0x0,%edx
  801306:	eb 0e                	jmp    801316 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801308:	39 08                	cmp    %ecx,(%eax)
  80130a:	75 09                	jne    801315 <dev_lookup+0x21>
			*dev = devtab[i];
  80130c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
  801313:	eb 33                	jmp    801348 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801315:	42                   	inc    %edx
  801316:	8b 04 95 fc 28 80 00 	mov    0x8028fc(,%edx,4),%eax
  80131d:	85 c0                	test   %eax,%eax
  80131f:	75 e7                	jne    801308 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801321:	a1 08 40 80 00       	mov    0x804008,%eax
  801326:	8b 40 48             	mov    0x48(%eax),%eax
  801329:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801331:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  801338:	e8 33 ef ff ff       	call   800270 <cprintf>
	*dev = 0;
  80133d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801343:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801348:	83 c4 14             	add    $0x14,%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	56                   	push   %esi
  801352:	53                   	push   %ebx
  801353:	83 ec 30             	sub    $0x30,%esp
  801356:	8b 75 08             	mov    0x8(%ebp),%esi
  801359:	8a 45 0c             	mov    0xc(%ebp),%al
  80135c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80135f:	89 34 24             	mov    %esi,(%esp)
  801362:	e8 b9 fe ff ff       	call   801220 <fd2num>
  801367:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80136a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80136e:	89 04 24             	mov    %eax,(%esp)
  801371:	e8 28 ff ff ff       	call   80129e <fd_lookup>
  801376:	89 c3                	mov    %eax,%ebx
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 05                	js     801381 <fd_close+0x33>
	    || fd != fd2)
  80137c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80137f:	74 0d                	je     80138e <fd_close+0x40>
		return (must_exist ? r : 0);
  801381:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801385:	75 46                	jne    8013cd <fd_close+0x7f>
  801387:	bb 00 00 00 00       	mov    $0x0,%ebx
  80138c:	eb 3f                	jmp    8013cd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80138e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801391:	89 44 24 04          	mov    %eax,0x4(%esp)
  801395:	8b 06                	mov    (%esi),%eax
  801397:	89 04 24             	mov    %eax,(%esp)
  80139a:	e8 55 ff ff ff       	call   8012f4 <dev_lookup>
  80139f:	89 c3                	mov    %eax,%ebx
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 18                	js     8013bd <fd_close+0x6f>
		if (dev->dev_close)
  8013a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a8:	8b 40 10             	mov    0x10(%eax),%eax
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	74 09                	je     8013b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013af:	89 34 24             	mov    %esi,(%esp)
  8013b2:	ff d0                	call   *%eax
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	eb 05                	jmp    8013bd <fd_close+0x6f>
		else
			r = 0;
  8013b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c8:	e8 e7 f8 ff ff       	call   800cb4 <sys_page_unmap>
	return r;
}
  8013cd:	89 d8                	mov    %ebx,%eax
  8013cf:	83 c4 30             	add    $0x30,%esp
  8013d2:	5b                   	pop    %ebx
  8013d3:	5e                   	pop    %esi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e6:	89 04 24             	mov    %eax,(%esp)
  8013e9:	e8 b0 fe ff ff       	call   80129e <fd_lookup>
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 13                	js     801405 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013f9:	00 
  8013fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fd:	89 04 24             	mov    %eax,(%esp)
  801400:	e8 49 ff ff ff       	call   80134e <fd_close>
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <close_all>:

void
close_all(void)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801413:	89 1c 24             	mov    %ebx,(%esp)
  801416:	e8 bb ff ff ff       	call   8013d6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80141b:	43                   	inc    %ebx
  80141c:	83 fb 20             	cmp    $0x20,%ebx
  80141f:	75 f2                	jne    801413 <close_all+0xc>
		close(i);
}
  801421:	83 c4 14             	add    $0x14,%esp
  801424:	5b                   	pop    %ebx
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	57                   	push   %edi
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	83 ec 4c             	sub    $0x4c,%esp
  801430:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801433:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801436:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143a:	8b 45 08             	mov    0x8(%ebp),%eax
  80143d:	89 04 24             	mov    %eax,(%esp)
  801440:	e8 59 fe ff ff       	call   80129e <fd_lookup>
  801445:	89 c3                	mov    %eax,%ebx
  801447:	85 c0                	test   %eax,%eax
  801449:	0f 88 e1 00 00 00    	js     801530 <dup+0x109>
		return r;
	close(newfdnum);
  80144f:	89 3c 24             	mov    %edi,(%esp)
  801452:	e8 7f ff ff ff       	call   8013d6 <close>

	newfd = INDEX2FD(newfdnum);
  801457:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80145d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801460:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801463:	89 04 24             	mov    %eax,(%esp)
  801466:	e8 c5 fd ff ff       	call   801230 <fd2data>
  80146b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80146d:	89 34 24             	mov    %esi,(%esp)
  801470:	e8 bb fd ff ff       	call   801230 <fd2data>
  801475:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	c1 e8 16             	shr    $0x16,%eax
  80147d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801484:	a8 01                	test   $0x1,%al
  801486:	74 46                	je     8014ce <dup+0xa7>
  801488:	89 d8                	mov    %ebx,%eax
  80148a:	c1 e8 0c             	shr    $0xc,%eax
  80148d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801494:	f6 c2 01             	test   $0x1,%dl
  801497:	74 35                	je     8014ce <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801499:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b7:	00 
  8014b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c3:	e8 99 f7 ff ff       	call   800c61 <sys_page_map>
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 3b                	js     801509 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	c1 ea 0c             	shr    $0xc,%edx
  8014d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014dd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014e3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014f2:	00 
  8014f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fe:	e8 5e f7 ff ff       	call   800c61 <sys_page_map>
  801503:	89 c3                	mov    %eax,%ebx
  801505:	85 c0                	test   %eax,%eax
  801507:	79 25                	jns    80152e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801509:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801514:	e8 9b f7 ff ff       	call   800cb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801519:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80151c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801520:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801527:	e8 88 f7 ff ff       	call   800cb4 <sys_page_unmap>
	return r;
  80152c:	eb 02                	jmp    801530 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80152e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801530:	89 d8                	mov    %ebx,%eax
  801532:	83 c4 4c             	add    $0x4c,%esp
  801535:	5b                   	pop    %ebx
  801536:	5e                   	pop    %esi
  801537:	5f                   	pop    %edi
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	53                   	push   %ebx
  80153e:	83 ec 24             	sub    $0x24,%esp
  801541:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801544:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	89 1c 24             	mov    %ebx,(%esp)
  80154e:	e8 4b fd ff ff       	call   80129e <fd_lookup>
  801553:	85 c0                	test   %eax,%eax
  801555:	78 6d                	js     8015c4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801561:	8b 00                	mov    (%eax),%eax
  801563:	89 04 24             	mov    %eax,(%esp)
  801566:	e8 89 fd ff ff       	call   8012f4 <dev_lookup>
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 55                	js     8015c4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80156f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801572:	8b 50 08             	mov    0x8(%eax),%edx
  801575:	83 e2 03             	and    $0x3,%edx
  801578:	83 fa 01             	cmp    $0x1,%edx
  80157b:	75 23                	jne    8015a0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80157d:	a1 08 40 80 00       	mov    0x804008,%eax
  801582:	8b 40 48             	mov    0x48(%eax),%eax
  801585:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158d:	c7 04 24 c0 28 80 00 	movl   $0x8028c0,(%esp)
  801594:	e8 d7 ec ff ff       	call   800270 <cprintf>
		return -E_INVAL;
  801599:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159e:	eb 24                	jmp    8015c4 <read+0x8a>
	}
	if (!dev->dev_read)
  8015a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a3:	8b 52 08             	mov    0x8(%edx),%edx
  8015a6:	85 d2                	test   %edx,%edx
  8015a8:	74 15                	je     8015bf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015b8:	89 04 24             	mov    %eax,(%esp)
  8015bb:	ff d2                	call   *%edx
  8015bd:	eb 05                	jmp    8015c4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015c4:	83 c4 24             	add    $0x24,%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	57                   	push   %edi
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 1c             	sub    $0x1c,%esp
  8015d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015de:	eb 23                	jmp    801603 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e0:	89 f0                	mov    %esi,%eax
  8015e2:	29 d8                	sub    %ebx,%eax
  8015e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015eb:	01 d8                	add    %ebx,%eax
  8015ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f1:	89 3c 24             	mov    %edi,(%esp)
  8015f4:	e8 41 ff ff ff       	call   80153a <read>
		if (m < 0)
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 10                	js     80160d <readn+0x43>
			return m;
		if (m == 0)
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	74 0a                	je     80160b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801601:	01 c3                	add    %eax,%ebx
  801603:	39 f3                	cmp    %esi,%ebx
  801605:	72 d9                	jb     8015e0 <readn+0x16>
  801607:	89 d8                	mov    %ebx,%eax
  801609:	eb 02                	jmp    80160d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80160b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80160d:	83 c4 1c             	add    $0x1c,%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5f                   	pop    %edi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	53                   	push   %ebx
  801619:	83 ec 24             	sub    $0x24,%esp
  80161c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801622:	89 44 24 04          	mov    %eax,0x4(%esp)
  801626:	89 1c 24             	mov    %ebx,(%esp)
  801629:	e8 70 fc ff ff       	call   80129e <fd_lookup>
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 68                	js     80169a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	89 44 24 04          	mov    %eax,0x4(%esp)
  801639:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163c:	8b 00                	mov    (%eax),%eax
  80163e:	89 04 24             	mov    %eax,(%esp)
  801641:	e8 ae fc ff ff       	call   8012f4 <dev_lookup>
  801646:	85 c0                	test   %eax,%eax
  801648:	78 50                	js     80169a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801651:	75 23                	jne    801676 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801653:	a1 08 40 80 00       	mov    0x804008,%eax
  801658:	8b 40 48             	mov    0x48(%eax),%eax
  80165b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80165f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801663:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  80166a:	e8 01 ec ff ff       	call   800270 <cprintf>
		return -E_INVAL;
  80166f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801674:	eb 24                	jmp    80169a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801676:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801679:	8b 52 0c             	mov    0xc(%edx),%edx
  80167c:	85 d2                	test   %edx,%edx
  80167e:	74 15                	je     801695 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801680:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801683:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801687:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80168e:	89 04 24             	mov    %eax,(%esp)
  801691:	ff d2                	call   *%edx
  801693:	eb 05                	jmp    80169a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801695:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80169a:	83 c4 24             	add    $0x24,%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 e6 fb ff ff       	call   80129e <fd_lookup>
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 0e                	js     8016ca <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 24             	sub    $0x24,%esp
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dd:	89 1c 24             	mov    %ebx,(%esp)
  8016e0:	e8 b9 fb ff ff       	call   80129e <fd_lookup>
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 61                	js     80174a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	8b 00                	mov    (%eax),%eax
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	e8 f7 fb ff ff       	call   8012f4 <dev_lookup>
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 49                	js     80174a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801708:	75 23                	jne    80172d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80170a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80170f:	8b 40 48             	mov    0x48(%eax),%eax
  801712:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171a:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  801721:	e8 4a eb ff ff       	call   800270 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172b:	eb 1d                	jmp    80174a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80172d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801730:	8b 52 18             	mov    0x18(%edx),%edx
  801733:	85 d2                	test   %edx,%edx
  801735:	74 0e                	je     801745 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80173e:	89 04 24             	mov    %eax,(%esp)
  801741:	ff d2                	call   *%edx
  801743:	eb 05                	jmp    80174a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801745:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80174a:	83 c4 24             	add    $0x24,%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	53                   	push   %ebx
  801754:	83 ec 24             	sub    $0x24,%esp
  801757:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801761:	8b 45 08             	mov    0x8(%ebp),%eax
  801764:	89 04 24             	mov    %eax,(%esp)
  801767:	e8 32 fb ff ff       	call   80129e <fd_lookup>
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 52                	js     8017c2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801770:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801773:	89 44 24 04          	mov    %eax,0x4(%esp)
  801777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177a:	8b 00                	mov    (%eax),%eax
  80177c:	89 04 24             	mov    %eax,(%esp)
  80177f:	e8 70 fb ff ff       	call   8012f4 <dev_lookup>
  801784:	85 c0                	test   %eax,%eax
  801786:	78 3a                	js     8017c2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80178f:	74 2c                	je     8017bd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801791:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801794:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80179b:	00 00 00 
	stat->st_isdir = 0;
  80179e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a5:	00 00 00 
	stat->st_dev = dev;
  8017a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017b5:	89 14 24             	mov    %edx,(%esp)
  8017b8:	ff 50 14             	call   *0x14(%eax)
  8017bb:	eb 05                	jmp    8017c2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c2:	83 c4 24             	add    $0x24,%esp
  8017c5:	5b                   	pop    %ebx
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017d7:	00 
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	89 04 24             	mov    %eax,(%esp)
  8017de:	e8 fe 01 00 00       	call   8019e1 <open>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 1b                	js     801804 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f0:	89 1c 24             	mov    %ebx,(%esp)
  8017f3:	e8 58 ff ff ff       	call   801750 <fstat>
  8017f8:	89 c6                	mov    %eax,%esi
	close(fd);
  8017fa:	89 1c 24             	mov    %ebx,(%esp)
  8017fd:	e8 d4 fb ff ff       	call   8013d6 <close>
	return r;
  801802:	89 f3                	mov    %esi,%ebx
}
  801804:	89 d8                	mov    %ebx,%eax
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    
  80180d:	00 00                	add    %al,(%eax)
	...

00801810 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	83 ec 10             	sub    $0x10,%esp
  801818:	89 c3                	mov    %eax,%ebx
  80181a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80181c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801823:	75 11                	jne    801836 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801825:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80182c:	e8 ae 08 00 00       	call   8020df <ipc_find_env>
  801831:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801836:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80183d:	00 
  80183e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801845:	00 
  801846:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80184a:	a1 00 40 80 00       	mov    0x804000,%eax
  80184f:	89 04 24             	mov    %eax,(%esp)
  801852:	e8 1e 08 00 00       	call   802075 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801857:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80185e:	00 
  80185f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801863:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186a:	e8 9d 07 00 00       	call   80200c <ipc_recv>
}
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	8b 40 0c             	mov    0xc(%eax),%eax
  801882:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801887:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80188f:	ba 00 00 00 00       	mov    $0x0,%edx
  801894:	b8 02 00 00 00       	mov    $0x2,%eax
  801899:	e8 72 ff ff ff       	call   801810 <fsipc>
}
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ac:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8018bb:	e8 50 ff ff ff       	call   801810 <fsipc>
}
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	53                   	push   %ebx
  8018c6:	83 ec 14             	sub    $0x14,%esp
  8018c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dc:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e1:	e8 2a ff ff ff       	call   801810 <fsipc>
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 2b                	js     801915 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ea:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018f1:	00 
  8018f2:	89 1c 24             	mov    %ebx,(%esp)
  8018f5:	e8 21 ef ff ff       	call   80081b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018fa:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801905:	a1 84 50 80 00       	mov    0x805084,%eax
  80190a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801915:	83 c4 14             	add    $0x14,%esp
  801918:	5b                   	pop    %ebx
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801921:	c7 44 24 08 0c 29 80 	movl   $0x80290c,0x8(%esp)
  801928:	00 
  801929:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801930:	00 
  801931:	c7 04 24 2a 29 80 00 	movl   $0x80292a,(%esp)
  801938:	e8 3b e8 ff ff       	call   800178 <_panic>

0080193d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	83 ec 10             	sub    $0x10,%esp
  801945:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	8b 40 0c             	mov    0xc(%eax),%eax
  80194e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801953:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801959:	ba 00 00 00 00       	mov    $0x0,%edx
  80195e:	b8 03 00 00 00       	mov    $0x3,%eax
  801963:	e8 a8 fe ff ff       	call   801810 <fsipc>
  801968:	89 c3                	mov    %eax,%ebx
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 6a                	js     8019d8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80196e:	39 c6                	cmp    %eax,%esi
  801970:	73 24                	jae    801996 <devfile_read+0x59>
  801972:	c7 44 24 0c 35 29 80 	movl   $0x802935,0xc(%esp)
  801979:	00 
  80197a:	c7 44 24 08 3c 29 80 	movl   $0x80293c,0x8(%esp)
  801981:	00 
  801982:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801989:	00 
  80198a:	c7 04 24 2a 29 80 00 	movl   $0x80292a,(%esp)
  801991:	e8 e2 e7 ff ff       	call   800178 <_panic>
	assert(r <= PGSIZE);
  801996:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80199b:	7e 24                	jle    8019c1 <devfile_read+0x84>
  80199d:	c7 44 24 0c 51 29 80 	movl   $0x802951,0xc(%esp)
  8019a4:	00 
  8019a5:	c7 44 24 08 3c 29 80 	movl   $0x80293c,0x8(%esp)
  8019ac:	00 
  8019ad:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019b4:	00 
  8019b5:	c7 04 24 2a 29 80 00 	movl   $0x80292a,(%esp)
  8019bc:	e8 b7 e7 ff ff       	call   800178 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019cc:	00 
  8019cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d0:	89 04 24             	mov    %eax,(%esp)
  8019d3:	e8 bc ef ff ff       	call   800994 <memmove>
	return r;
}
  8019d8:	89 d8                	mov    %ebx,%eax
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5e                   	pop    %esi
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	56                   	push   %esi
  8019e5:	53                   	push   %ebx
  8019e6:	83 ec 20             	sub    $0x20,%esp
  8019e9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019ec:	89 34 24             	mov    %esi,(%esp)
  8019ef:	e8 f4 ed ff ff       	call   8007e8 <strlen>
  8019f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f9:	7f 60                	jg     801a5b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	e8 45 f8 ff ff       	call   80124b <fd_alloc>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 54                	js     801a60 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a10:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a17:	e8 ff ed ff ff       	call   80081b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a27:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2c:	e8 df fd ff ff       	call   801810 <fsipc>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	85 c0                	test   %eax,%eax
  801a35:	79 15                	jns    801a4c <open+0x6b>
		fd_close(fd, 0);
  801a37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a3e:	00 
  801a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a42:	89 04 24             	mov    %eax,(%esp)
  801a45:	e8 04 f9 ff ff       	call   80134e <fd_close>
		return r;
  801a4a:	eb 14                	jmp    801a60 <open+0x7f>
	}

	return fd2num(fd);
  801a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4f:	89 04 24             	mov    %eax,(%esp)
  801a52:	e8 c9 f7 ff ff       	call   801220 <fd2num>
  801a57:	89 c3                	mov    %eax,%ebx
  801a59:	eb 05                	jmp    801a60 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a5b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a60:	89 d8                	mov    %ebx,%eax
  801a62:	83 c4 20             	add    $0x20,%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a74:	b8 08 00 00 00       	mov    $0x8,%eax
  801a79:	e8 92 fd ff ff       	call   801810 <fsipc>
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	83 ec 10             	sub    $0x10,%esp
  801a88:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	89 04 24             	mov    %eax,(%esp)
  801a91:	e8 9a f7 ff ff       	call   801230 <fd2data>
  801a96:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a98:	c7 44 24 04 5d 29 80 	movl   $0x80295d,0x4(%esp)
  801a9f:	00 
  801aa0:	89 34 24             	mov    %esi,(%esp)
  801aa3:	e8 73 ed ff ff       	call   80081b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa8:	8b 43 04             	mov    0x4(%ebx),%eax
  801aab:	2b 03                	sub    (%ebx),%eax
  801aad:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ab3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801aba:	00 00 00 
	stat->st_dev = &devpipe;
  801abd:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801ac4:	30 80 00 
	return 0;
}
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 14             	sub    $0x14,%esp
  801ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801add:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae8:	e8 c7 f1 ff ff       	call   800cb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aed:	89 1c 24             	mov    %ebx,(%esp)
  801af0:	e8 3b f7 ff ff       	call   801230 <fd2data>
  801af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b00:	e8 af f1 ff ff       	call   800cb4 <sys_page_unmap>
}
  801b05:	83 c4 14             	add    $0x14,%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	57                   	push   %edi
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	83 ec 2c             	sub    $0x2c,%esp
  801b14:	89 c7                	mov    %eax,%edi
  801b16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b19:	a1 08 40 80 00       	mov    0x804008,%eax
  801b1e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b21:	89 3c 24             	mov    %edi,(%esp)
  801b24:	e8 fb 05 00 00       	call   802124 <pageref>
  801b29:	89 c6                	mov    %eax,%esi
  801b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2e:	89 04 24             	mov    %eax,(%esp)
  801b31:	e8 ee 05 00 00       	call   802124 <pageref>
  801b36:	39 c6                	cmp    %eax,%esi
  801b38:	0f 94 c0             	sete   %al
  801b3b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b3e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b44:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b47:	39 cb                	cmp    %ecx,%ebx
  801b49:	75 08                	jne    801b53 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b4b:	83 c4 2c             	add    $0x2c,%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b53:	83 f8 01             	cmp    $0x1,%eax
  801b56:	75 c1                	jne    801b19 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b58:	8b 42 58             	mov    0x58(%edx),%eax
  801b5b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801b62:	00 
  801b63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b6b:	c7 04 24 64 29 80 00 	movl   $0x802964,(%esp)
  801b72:	e8 f9 e6 ff ff       	call   800270 <cprintf>
  801b77:	eb a0                	jmp    801b19 <_pipeisclosed+0xe>

00801b79 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	57                   	push   %edi
  801b7d:	56                   	push   %esi
  801b7e:	53                   	push   %ebx
  801b7f:	83 ec 1c             	sub    $0x1c,%esp
  801b82:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b85:	89 34 24             	mov    %esi,(%esp)
  801b88:	e8 a3 f6 ff ff       	call   801230 <fd2data>
  801b8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b94:	eb 3c                	jmp    801bd2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b96:	89 da                	mov    %ebx,%edx
  801b98:	89 f0                	mov    %esi,%eax
  801b9a:	e8 6c ff ff ff       	call   801b0b <_pipeisclosed>
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	75 38                	jne    801bdb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ba3:	e8 46 f0 ff ff       	call   800bee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ba8:	8b 43 04             	mov    0x4(%ebx),%eax
  801bab:	8b 13                	mov    (%ebx),%edx
  801bad:	83 c2 20             	add    $0x20,%edx
  801bb0:	39 d0                	cmp    %edx,%eax
  801bb2:	73 e2                	jae    801b96 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801bba:	89 c2                	mov    %eax,%edx
  801bbc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801bc2:	79 05                	jns    801bc9 <devpipe_write+0x50>
  801bc4:	4a                   	dec    %edx
  801bc5:	83 ca e0             	or     $0xffffffe0,%edx
  801bc8:	42                   	inc    %edx
  801bc9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bcd:	40                   	inc    %eax
  801bce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd1:	47                   	inc    %edi
  801bd2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bd5:	75 d1                	jne    801ba8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bd7:	89 f8                	mov    %edi,%eax
  801bd9:	eb 05                	jmp    801be0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	57                   	push   %edi
  801bec:	56                   	push   %esi
  801bed:	53                   	push   %ebx
  801bee:	83 ec 1c             	sub    $0x1c,%esp
  801bf1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bf4:	89 3c 24             	mov    %edi,(%esp)
  801bf7:	e8 34 f6 ff ff       	call   801230 <fd2data>
  801bfc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfe:	be 00 00 00 00       	mov    $0x0,%esi
  801c03:	eb 3a                	jmp    801c3f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c05:	85 f6                	test   %esi,%esi
  801c07:	74 04                	je     801c0d <devpipe_read+0x25>
				return i;
  801c09:	89 f0                	mov    %esi,%eax
  801c0b:	eb 40                	jmp    801c4d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c0d:	89 da                	mov    %ebx,%edx
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	e8 f5 fe ff ff       	call   801b0b <_pipeisclosed>
  801c16:	85 c0                	test   %eax,%eax
  801c18:	75 2e                	jne    801c48 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c1a:	e8 cf ef ff ff       	call   800bee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c1f:	8b 03                	mov    (%ebx),%eax
  801c21:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c24:	74 df                	je     801c05 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c26:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c2b:	79 05                	jns    801c32 <devpipe_read+0x4a>
  801c2d:	48                   	dec    %eax
  801c2e:	83 c8 e0             	or     $0xffffffe0,%eax
  801c31:	40                   	inc    %eax
  801c32:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c39:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c3c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3e:	46                   	inc    %esi
  801c3f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c42:	75 db                	jne    801c1f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c44:	89 f0                	mov    %esi,%eax
  801c46:	eb 05                	jmp    801c4d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c48:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c4d:	83 c4 1c             	add    $0x1c,%esp
  801c50:	5b                   	pop    %ebx
  801c51:	5e                   	pop    %esi
  801c52:	5f                   	pop    %edi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	57                   	push   %edi
  801c59:	56                   	push   %esi
  801c5a:	53                   	push   %ebx
  801c5b:	83 ec 3c             	sub    $0x3c,%esp
  801c5e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c64:	89 04 24             	mov    %eax,(%esp)
  801c67:	e8 df f5 ff ff       	call   80124b <fd_alloc>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	0f 88 45 01 00 00    	js     801dbb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c7d:	00 
  801c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8c:	e8 7c ef ff ff       	call   800c0d <sys_page_alloc>
  801c91:	89 c3                	mov    %eax,%ebx
  801c93:	85 c0                	test   %eax,%eax
  801c95:	0f 88 20 01 00 00    	js     801dbb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c9b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c9e:	89 04 24             	mov    %eax,(%esp)
  801ca1:	e8 a5 f5 ff ff       	call   80124b <fd_alloc>
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	0f 88 f8 00 00 00    	js     801da8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cb7:	00 
  801cb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc6:	e8 42 ef ff ff       	call   800c0d <sys_page_alloc>
  801ccb:	89 c3                	mov    %eax,%ebx
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	0f 88 d3 00 00 00    	js     801da8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cd8:	89 04 24             	mov    %eax,(%esp)
  801cdb:	e8 50 f5 ff ff       	call   801230 <fd2data>
  801ce0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ce9:	00 
  801cea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf5:	e8 13 ef ff ff       	call   800c0d <sys_page_alloc>
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	0f 88 91 00 00 00    	js     801d95 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d07:	89 04 24             	mov    %eax,(%esp)
  801d0a:	e8 21 f5 ff ff       	call   801230 <fd2data>
  801d0f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d16:	00 
  801d17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d22:	00 
  801d23:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2e:	e8 2e ef ff ff       	call   800c61 <sys_page_map>
  801d33:	89 c3                	mov    %eax,%ebx
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 4c                	js     801d85 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d42:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d47:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d57:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d5c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d66:	89 04 24             	mov    %eax,(%esp)
  801d69:	e8 b2 f4 ff ff       	call   801220 <fd2num>
  801d6e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d70:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d73:	89 04 24             	mov    %eax,(%esp)
  801d76:	e8 a5 f4 ff ff       	call   801220 <fd2num>
  801d7b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d83:	eb 36                	jmp    801dbb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801d85:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d90:	e8 1f ef ff ff       	call   800cb4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801d95:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da3:	e8 0c ef ff ff       	call   800cb4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801da8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801daf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db6:	e8 f9 ee ff ff       	call   800cb4 <sys_page_unmap>
    err:
	return r;
}
  801dbb:	89 d8                	mov    %ebx,%eax
  801dbd:	83 c4 3c             	add    $0x3c,%esp
  801dc0:	5b                   	pop    %ebx
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd5:	89 04 24             	mov    %eax,(%esp)
  801dd8:	e8 c1 f4 ff ff       	call   80129e <fd_lookup>
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 15                	js     801df6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de4:	89 04 24             	mov    %eax,(%esp)
  801de7:	e8 44 f4 ff ff       	call   801230 <fd2data>
	return _pipeisclosed(fd, p);
  801dec:	89 c2                	mov    %eax,%edx
  801dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df1:	e8 15 fd ff ff       	call   801b0b <_pipeisclosed>
}
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801e08:	c7 44 24 04 7c 29 80 	movl   $0x80297c,0x4(%esp)
  801e0f:	00 
  801e10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e13:	89 04 24             	mov    %eax,(%esp)
  801e16:	e8 00 ea ff ff       	call   80081b <strcpy>
	return 0;
}
  801e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	57                   	push   %edi
  801e26:	56                   	push   %esi
  801e27:	53                   	push   %ebx
  801e28:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e33:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e39:	eb 30                	jmp    801e6b <devcons_write+0x49>
		m = n - tot;
  801e3b:	8b 75 10             	mov    0x10(%ebp),%esi
  801e3e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801e40:	83 fe 7f             	cmp    $0x7f,%esi
  801e43:	76 05                	jbe    801e4a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801e45:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e4a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801e4e:	03 45 0c             	add    0xc(%ebp),%eax
  801e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e55:	89 3c 24             	mov    %edi,(%esp)
  801e58:	e8 37 eb ff ff       	call   800994 <memmove>
		sys_cputs(buf, m);
  801e5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e61:	89 3c 24             	mov    %edi,(%esp)
  801e64:	e8 d7 ec ff ff       	call   800b40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e69:	01 f3                	add    %esi,%ebx
  801e6b:	89 d8                	mov    %ebx,%eax
  801e6d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e70:	72 c9                	jb     801e3b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e72:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e87:	75 07                	jne    801e90 <devcons_read+0x13>
  801e89:	eb 25                	jmp    801eb0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e8b:	e8 5e ed ff ff       	call   800bee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e90:	e8 c9 ec ff ff       	call   800b5e <sys_cgetc>
  801e95:	85 c0                	test   %eax,%eax
  801e97:	74 f2                	je     801e8b <devcons_read+0xe>
  801e99:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 1d                	js     801ebc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e9f:	83 f8 04             	cmp    $0x4,%eax
  801ea2:	74 13                	je     801eb7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea7:	88 10                	mov    %dl,(%eax)
	return 1;
  801ea9:	b8 01 00 00 00       	mov    $0x1,%eax
  801eae:	eb 0c                	jmp    801ebc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb5:	eb 05                	jmp    801ebc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ed1:	00 
  801ed2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed5:	89 04 24             	mov    %eax,(%esp)
  801ed8:	e8 63 ec ff ff       	call   800b40 <sys_cputs>
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <getchar>:

int
getchar(void)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ee5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801eec:	00 
  801eed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efb:	e8 3a f6 ff ff       	call   80153a <read>
	if (r < 0)
  801f00:	85 c0                	test   %eax,%eax
  801f02:	78 0f                	js     801f13 <getchar+0x34>
		return r;
	if (r < 1)
  801f04:	85 c0                	test   %eax,%eax
  801f06:	7e 06                	jle    801f0e <getchar+0x2f>
		return -E_EOF;
	return c;
  801f08:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f0c:	eb 05                	jmp    801f13 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f0e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	89 04 24             	mov    %eax,(%esp)
  801f28:	e8 71 f3 ff ff       	call   80129e <fd_lookup>
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	78 11                	js     801f42 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f34:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f3a:	39 10                	cmp    %edx,(%eax)
  801f3c:	0f 94 c0             	sete   %al
  801f3f:	0f b6 c0             	movzbl %al,%eax
}
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <opencons>:

int
opencons(void)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4d:	89 04 24             	mov    %eax,(%esp)
  801f50:	e8 f6 f2 ff ff       	call   80124b <fd_alloc>
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 3c                	js     801f95 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f59:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f60:	00 
  801f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6f:	e8 99 ec ff ff       	call   800c0d <sys_page_alloc>
  801f74:	85 c0                	test   %eax,%eax
  801f76:	78 1d                	js     801f95 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f78:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f81:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f86:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f8d:	89 04 24             	mov    %eax,(%esp)
  801f90:	e8 8b f2 ff ff       	call   801220 <fd2num>
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    
	...

00801f98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f9e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa5:	75 32                	jne    801fd9 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801fa7:	e8 23 ec ff ff       	call   800bcf <sys_getenvid>
  801fac:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  801fb3:	00 
  801fb4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801fbb:	ee 
  801fbc:	89 04 24             	mov    %eax,(%esp)
  801fbf:	e8 49 ec ff ff       	call   800c0d <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  801fc4:	e8 06 ec ff ff       	call   800bcf <sys_getenvid>
  801fc9:	c7 44 24 04 e4 1f 80 	movl   $0x801fe4,0x4(%esp)
  801fd0:	00 
  801fd1:	89 04 24             	mov    %eax,(%esp)
  801fd4:	e8 d4 ed ff ff       	call   800dad <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdc:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    
	...

00801fe4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fe4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fec:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  801fef:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  801ff3:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  801ff6:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  801ffb:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  801fff:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  802002:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  802003:	83 c4 04             	add    $0x4,%esp
	popfl
  802006:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  802007:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  802008:	c3                   	ret    
  802009:	00 00                	add    %al,(%eax)
	...

0080200c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	57                   	push   %edi
  802010:	56                   	push   %esi
  802011:	53                   	push   %ebx
  802012:	83 ec 1c             	sub    $0x1c,%esp
  802015:	8b 75 08             	mov    0x8(%ebp),%esi
  802018:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80201b:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  80201e:	85 db                	test   %ebx,%ebx
  802020:	75 05                	jne    802027 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  802022:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  802027:	89 1c 24             	mov    %ebx,(%esp)
  80202a:	e8 f4 ed ff ff       	call   800e23 <sys_ipc_recv>
  80202f:	85 c0                	test   %eax,%eax
  802031:	79 16                	jns    802049 <ipc_recv+0x3d>
		*from_env_store = 0;
  802033:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  802039:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  80203f:	89 1c 24             	mov    %ebx,(%esp)
  802042:	e8 dc ed ff ff       	call   800e23 <sys_ipc_recv>
  802047:	eb 24                	jmp    80206d <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  802049:	85 f6                	test   %esi,%esi
  80204b:	74 0a                	je     802057 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  80204d:	a1 08 40 80 00       	mov    0x804008,%eax
  802052:	8b 40 74             	mov    0x74(%eax),%eax
  802055:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802057:	85 ff                	test   %edi,%edi
  802059:	74 0a                	je     802065 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  80205b:	a1 08 40 80 00       	mov    0x804008,%eax
  802060:	8b 40 78             	mov    0x78(%eax),%eax
  802063:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  802065:	a1 08 40 80 00       	mov    0x804008,%eax
  80206a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80206d:	83 c4 1c             	add    $0x1c,%esp
  802070:	5b                   	pop    %ebx
  802071:	5e                   	pop    %esi
  802072:	5f                   	pop    %edi
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    

00802075 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	57                   	push   %edi
  802079:	56                   	push   %esi
  80207a:	53                   	push   %ebx
  80207b:	83 ec 1c             	sub    $0x1c,%esp
  80207e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802081:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802084:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802087:	85 db                	test   %ebx,%ebx
  802089:	75 05                	jne    802090 <ipc_send+0x1b>
		pg = (void *)-1;
  80208b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802090:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802094:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802098:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	89 04 24             	mov    %eax,(%esp)
  8020a2:	e8 59 ed ff ff       	call   800e00 <sys_ipc_try_send>
		if (r == 0) {		
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	74 2c                	je     8020d7 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  8020ab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ae:	75 07                	jne    8020b7 <ipc_send+0x42>
			sys_yield();
  8020b0:	e8 39 eb ff ff       	call   800bee <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  8020b5:	eb d9                	jmp    802090 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  8020b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bb:	c7 44 24 08 88 29 80 	movl   $0x802988,0x8(%esp)
  8020c2:	00 
  8020c3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8020ca:	00 
  8020cb:	c7 04 24 96 29 80 00 	movl   $0x802996,(%esp)
  8020d2:	e8 a1 e0 ff ff       	call   800178 <_panic>
		}
	}
}
  8020d7:	83 c4 1c             	add    $0x1c,%esp
  8020da:	5b                   	pop    %ebx
  8020db:	5e                   	pop    %esi
  8020dc:	5f                   	pop    %edi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    

008020df <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	53                   	push   %ebx
  8020e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8020e6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020eb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8020f2:	89 c2                	mov    %eax,%edx
  8020f4:	c1 e2 07             	shl    $0x7,%edx
  8020f7:	29 ca                	sub    %ecx,%edx
  8020f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ff:	8b 52 50             	mov    0x50(%edx),%edx
  802102:	39 da                	cmp    %ebx,%edx
  802104:	75 0f                	jne    802115 <ipc_find_env+0x36>
			return envs[i].env_id;
  802106:	c1 e0 07             	shl    $0x7,%eax
  802109:	29 c8                	sub    %ecx,%eax
  80210b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802110:	8b 40 40             	mov    0x40(%eax),%eax
  802113:	eb 0c                	jmp    802121 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802115:	40                   	inc    %eax
  802116:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211b:	75 ce                	jne    8020eb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80211d:	66 b8 00 00          	mov    $0x0,%ax
}
  802121:	5b                   	pop    %ebx
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212a:	89 c2                	mov    %eax,%edx
  80212c:	c1 ea 16             	shr    $0x16,%edx
  80212f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802136:	f6 c2 01             	test   $0x1,%dl
  802139:	74 1e                	je     802159 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80213b:	c1 e8 0c             	shr    $0xc,%eax
  80213e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802145:	a8 01                	test   $0x1,%al
  802147:	74 17                	je     802160 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802149:	c1 e8 0c             	shr    $0xc,%eax
  80214c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802153:	ef 
  802154:	0f b7 c0             	movzwl %ax,%eax
  802157:	eb 0c                	jmp    802165 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802159:	b8 00 00 00 00       	mov    $0x0,%eax
  80215e:	eb 05                	jmp    802165 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802160:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802165:	5d                   	pop    %ebp
  802166:	c3                   	ret    
	...

00802168 <__udivdi3>:
  802168:	55                   	push   %ebp
  802169:	57                   	push   %edi
  80216a:	56                   	push   %esi
  80216b:	83 ec 10             	sub    $0x10,%esp
  80216e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802172:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80217e:	89 cd                	mov    %ecx,%ebp
  802180:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802184:	85 c0                	test   %eax,%eax
  802186:	75 2c                	jne    8021b4 <__udivdi3+0x4c>
  802188:	39 f9                	cmp    %edi,%ecx
  80218a:	77 68                	ja     8021f4 <__udivdi3+0x8c>
  80218c:	85 c9                	test   %ecx,%ecx
  80218e:	75 0b                	jne    80219b <__udivdi3+0x33>
  802190:	b8 01 00 00 00       	mov    $0x1,%eax
  802195:	31 d2                	xor    %edx,%edx
  802197:	f7 f1                	div    %ecx
  802199:	89 c1                	mov    %eax,%ecx
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	89 f8                	mov    %edi,%eax
  80219f:	f7 f1                	div    %ecx
  8021a1:	89 c7                	mov    %eax,%edi
  8021a3:	89 f0                	mov    %esi,%eax
  8021a5:	f7 f1                	div    %ecx
  8021a7:	89 c6                	mov    %eax,%esi
  8021a9:	89 f0                	mov    %esi,%eax
  8021ab:	89 fa                	mov    %edi,%edx
  8021ad:	83 c4 10             	add    $0x10,%esp
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	39 f8                	cmp    %edi,%eax
  8021b6:	77 2c                	ja     8021e4 <__udivdi3+0x7c>
  8021b8:	0f bd f0             	bsr    %eax,%esi
  8021bb:	83 f6 1f             	xor    $0x1f,%esi
  8021be:	75 4c                	jne    80220c <__udivdi3+0xa4>
  8021c0:	39 f8                	cmp    %edi,%eax
  8021c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8021c7:	72 0a                	jb     8021d3 <__udivdi3+0x6b>
  8021c9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021cd:	0f 87 ad 00 00 00    	ja     802280 <__udivdi3+0x118>
  8021d3:	be 01 00 00 00       	mov    $0x1,%esi
  8021d8:	89 f0                	mov    %esi,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 10             	add    $0x10,%esp
  8021df:	5e                   	pop    %esi
  8021e0:	5f                   	pop    %edi
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    
  8021e3:	90                   	nop
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	31 f6                	xor    %esi,%esi
  8021e8:	89 f0                	mov    %esi,%eax
  8021ea:	89 fa                	mov    %edi,%edx
  8021ec:	83 c4 10             	add    $0x10,%esp
  8021ef:	5e                   	pop    %esi
  8021f0:	5f                   	pop    %edi
  8021f1:	5d                   	pop    %ebp
  8021f2:	c3                   	ret    
  8021f3:	90                   	nop
  8021f4:	89 fa                	mov    %edi,%edx
  8021f6:	89 f0                	mov    %esi,%eax
  8021f8:	f7 f1                	div    %ecx
  8021fa:	89 c6                	mov    %eax,%esi
  8021fc:	31 ff                	xor    %edi,%edi
  8021fe:	89 f0                	mov    %esi,%eax
  802200:	89 fa                	mov    %edi,%edx
  802202:	83 c4 10             	add    $0x10,%esp
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d 76 00             	lea    0x0(%esi),%esi
  80220c:	89 f1                	mov    %esi,%ecx
  80220e:	d3 e0                	shl    %cl,%eax
  802210:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802214:	b8 20 00 00 00       	mov    $0x20,%eax
  802219:	29 f0                	sub    %esi,%eax
  80221b:	89 ea                	mov    %ebp,%edx
  80221d:	88 c1                	mov    %al,%cl
  80221f:	d3 ea                	shr    %cl,%edx
  802221:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802225:	09 ca                	or     %ecx,%edx
  802227:	89 54 24 08          	mov    %edx,0x8(%esp)
  80222b:	89 f1                	mov    %esi,%ecx
  80222d:	d3 e5                	shl    %cl,%ebp
  80222f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802233:	89 fd                	mov    %edi,%ebp
  802235:	88 c1                	mov    %al,%cl
  802237:	d3 ed                	shr    %cl,%ebp
  802239:	89 fa                	mov    %edi,%edx
  80223b:	89 f1                	mov    %esi,%ecx
  80223d:	d3 e2                	shl    %cl,%edx
  80223f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802243:	88 c1                	mov    %al,%cl
  802245:	d3 ef                	shr    %cl,%edi
  802247:	09 d7                	or     %edx,%edi
  802249:	89 f8                	mov    %edi,%eax
  80224b:	89 ea                	mov    %ebp,%edx
  80224d:	f7 74 24 08          	divl   0x8(%esp)
  802251:	89 d1                	mov    %edx,%ecx
  802253:	89 c7                	mov    %eax,%edi
  802255:	f7 64 24 0c          	mull   0xc(%esp)
  802259:	39 d1                	cmp    %edx,%ecx
  80225b:	72 17                	jb     802274 <__udivdi3+0x10c>
  80225d:	74 09                	je     802268 <__udivdi3+0x100>
  80225f:	89 fe                	mov    %edi,%esi
  802261:	31 ff                	xor    %edi,%edi
  802263:	e9 41 ff ff ff       	jmp    8021a9 <__udivdi3+0x41>
  802268:	8b 54 24 04          	mov    0x4(%esp),%edx
  80226c:	89 f1                	mov    %esi,%ecx
  80226e:	d3 e2                	shl    %cl,%edx
  802270:	39 c2                	cmp    %eax,%edx
  802272:	73 eb                	jae    80225f <__udivdi3+0xf7>
  802274:	8d 77 ff             	lea    -0x1(%edi),%esi
  802277:	31 ff                	xor    %edi,%edi
  802279:	e9 2b ff ff ff       	jmp    8021a9 <__udivdi3+0x41>
  80227e:	66 90                	xchg   %ax,%ax
  802280:	31 f6                	xor    %esi,%esi
  802282:	e9 22 ff ff ff       	jmp    8021a9 <__udivdi3+0x41>
	...

00802288 <__umoddi3>:
  802288:	55                   	push   %ebp
  802289:	57                   	push   %edi
  80228a:	56                   	push   %esi
  80228b:	83 ec 20             	sub    $0x20,%esp
  80228e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802292:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802296:	89 44 24 14          	mov    %eax,0x14(%esp)
  80229a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80229e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022a2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8022a6:	89 c7                	mov    %eax,%edi
  8022a8:	89 f2                	mov    %esi,%edx
  8022aa:	85 ed                	test   %ebp,%ebp
  8022ac:	75 16                	jne    8022c4 <__umoddi3+0x3c>
  8022ae:	39 f1                	cmp    %esi,%ecx
  8022b0:	0f 86 a6 00 00 00    	jbe    80235c <__umoddi3+0xd4>
  8022b6:	f7 f1                	div    %ecx
  8022b8:	89 d0                	mov    %edx,%eax
  8022ba:	31 d2                	xor    %edx,%edx
  8022bc:	83 c4 20             	add    $0x20,%esp
  8022bf:	5e                   	pop    %esi
  8022c0:	5f                   	pop    %edi
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    
  8022c3:	90                   	nop
  8022c4:	39 f5                	cmp    %esi,%ebp
  8022c6:	0f 87 ac 00 00 00    	ja     802378 <__umoddi3+0xf0>
  8022cc:	0f bd c5             	bsr    %ebp,%eax
  8022cf:	83 f0 1f             	xor    $0x1f,%eax
  8022d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022d6:	0f 84 a8 00 00 00    	je     802384 <__umoddi3+0xfc>
  8022dc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8022e0:	d3 e5                	shl    %cl,%ebp
  8022e2:	bf 20 00 00 00       	mov    $0x20,%edi
  8022e7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8022eb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022ef:	89 f9                	mov    %edi,%ecx
  8022f1:	d3 e8                	shr    %cl,%eax
  8022f3:	09 e8                	or     %ebp,%eax
  8022f5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022f9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022fd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802301:	d3 e0                	shl    %cl,%eax
  802303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802307:	89 f2                	mov    %esi,%edx
  802309:	d3 e2                	shl    %cl,%edx
  80230b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80230f:	d3 e0                	shl    %cl,%eax
  802311:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802315:	8b 44 24 14          	mov    0x14(%esp),%eax
  802319:	89 f9                	mov    %edi,%ecx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	09 d0                	or     %edx,%eax
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	89 f2                	mov    %esi,%edx
  802323:	f7 74 24 18          	divl   0x18(%esp)
  802327:	89 d6                	mov    %edx,%esi
  802329:	f7 64 24 0c          	mull   0xc(%esp)
  80232d:	89 c5                	mov    %eax,%ebp
  80232f:	89 d1                	mov    %edx,%ecx
  802331:	39 d6                	cmp    %edx,%esi
  802333:	72 67                	jb     80239c <__umoddi3+0x114>
  802335:	74 75                	je     8023ac <__umoddi3+0x124>
  802337:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80233b:	29 e8                	sub    %ebp,%eax
  80233d:	19 ce                	sbb    %ecx,%esi
  80233f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802343:	d3 e8                	shr    %cl,%eax
  802345:	89 f2                	mov    %esi,%edx
  802347:	89 f9                	mov    %edi,%ecx
  802349:	d3 e2                	shl    %cl,%edx
  80234b:	09 d0                	or     %edx,%eax
  80234d:	89 f2                	mov    %esi,%edx
  80234f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802353:	d3 ea                	shr    %cl,%edx
  802355:	83 c4 20             	add    $0x20,%esp
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	85 c9                	test   %ecx,%ecx
  80235e:	75 0b                	jne    80236b <__umoddi3+0xe3>
  802360:	b8 01 00 00 00       	mov    $0x1,%eax
  802365:	31 d2                	xor    %edx,%edx
  802367:	f7 f1                	div    %ecx
  802369:	89 c1                	mov    %eax,%ecx
  80236b:	89 f0                	mov    %esi,%eax
  80236d:	31 d2                	xor    %edx,%edx
  80236f:	f7 f1                	div    %ecx
  802371:	89 f8                	mov    %edi,%eax
  802373:	e9 3e ff ff ff       	jmp    8022b6 <__umoddi3+0x2e>
  802378:	89 f2                	mov    %esi,%edx
  80237a:	83 c4 20             	add    $0x20,%esp
  80237d:	5e                   	pop    %esi
  80237e:	5f                   	pop    %edi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    
  802381:	8d 76 00             	lea    0x0(%esi),%esi
  802384:	39 f5                	cmp    %esi,%ebp
  802386:	72 04                	jb     80238c <__umoddi3+0x104>
  802388:	39 f9                	cmp    %edi,%ecx
  80238a:	77 06                	ja     802392 <__umoddi3+0x10a>
  80238c:	89 f2                	mov    %esi,%edx
  80238e:	29 cf                	sub    %ecx,%edi
  802390:	19 ea                	sbb    %ebp,%edx
  802392:	89 f8                	mov    %edi,%eax
  802394:	83 c4 20             	add    $0x20,%esp
  802397:	5e                   	pop    %esi
  802398:	5f                   	pop    %edi
  802399:	5d                   	pop    %ebp
  80239a:	c3                   	ret    
  80239b:	90                   	nop
  80239c:	89 d1                	mov    %edx,%ecx
  80239e:	89 c5                	mov    %eax,%ebp
  8023a0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8023a4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8023a8:	eb 8d                	jmp    802337 <__umoddi3+0xaf>
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8023b0:	72 ea                	jb     80239c <__umoddi3+0x114>
  8023b2:	89 f1                	mov    %esi,%ecx
  8023b4:	eb 81                	jmp    802337 <__umoddi3+0xaf>
