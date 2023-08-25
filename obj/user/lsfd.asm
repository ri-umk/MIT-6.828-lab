
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  80003a:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  800041:	e8 fe 01 00 00       	call   800244 <cprintf>
	exit();
  800046:	e8 3d 01 00 00       	call   800188 <exit>
}
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800063:	8b 45 0c             	mov    0xc(%ebp),%eax
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	8d 45 08             	lea    0x8(%ebp),%eax
  80006d:	89 04 24             	mov    %eax,(%esp)
  800070:	e8 d7 0d 00 00       	call   800e4c <argstart>
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800075:	bf 00 00 00 00       	mov    $0x0,%edi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80007a:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  800080:	eb 11                	jmp    800093 <umain+0x46>
		if (i == '1')
  800082:	83 f8 31             	cmp    $0x31,%eax
  800085:	74 07                	je     80008e <umain+0x41>
			usefprint = 1;
		else
			usage();
  800087:	e8 a8 ff ff ff       	call   800034 <usage>
  80008c:	eb 05                	jmp    800093 <umain+0x46>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  80008e:	bf 01 00 00 00       	mov    $0x1,%edi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800093:	89 1c 24             	mov    %ebx,(%esp)
  800096:	e8 ea 0d 00 00       	call   800e85 <argnext>
  80009b:	85 c0                	test   %eax,%eax
  80009d:	79 e3                	jns    800082 <umain+0x35>
  80009f:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a4:	8d b5 5c ff ff ff    	lea    -0xa4(%ebp),%esi
  8000aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	e8 1e 14 00 00       	call   8014d4 <fstat>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	78 66                	js     800120 <umain+0xd3>
			if (usefprint)
  8000ba:	85 ff                	test   %edi,%edi
  8000bc:	74 36                	je     8000f4 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000c1:	8b 40 04             	mov    0x4(%eax),%eax
  8000c4:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000cb:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000d2:	89 44 24 10          	mov    %eax,0x10(%esp)
					i, st.st_name, st.st_isdir,
  8000d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000de:	c7 44 24 04 74 22 80 	movl   $0x802274,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ed:	e8 06 18 00 00       	call   8018f8 <fprintf>
  8000f2:	eb 2c                	jmp    800120 <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000f7:	8b 40 04             	mov    0x4(%eax),%eax
  8000fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800101:	89 44 24 10          	mov    %eax,0x10(%esp)
  800105:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800108:	89 44 24 0c          	mov    %eax,0xc(%esp)
					i, st.st_name, st.st_isdir,
  80010c:	89 74 24 08          	mov    %esi,0x8(%esp)
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  800110:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800114:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  80011b:	e8 24 01 00 00       	call   800244 <cprintf>
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  800120:	43                   	inc    %ebx
  800121:	83 fb 20             	cmp    $0x20,%ebx
  800124:	75 84                	jne    8000aa <umain+0x5d>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800126:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	83 ec 10             	sub    $0x10,%esp
  80013c:	8b 75 08             	mov    0x8(%ebp),%esi
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800142:	e8 5c 0a 00 00       	call   800ba3 <sys_getenvid>
  800147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800153:	c1 e0 07             	shl    $0x7,%eax
  800156:	29 d0                	sub    %edx,%eax
  800158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800162:	85 f6                	test   %esi,%esi
  800164:	7e 07                	jle    80016d <libmain+0x39>
		binaryname = argv[0];
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800171:	89 34 24             	mov    %esi,(%esp)
  800174:	e8 d4 fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800179:	e8 0a 00 00 00       	call   800188 <exit>
}
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    
  800185:	00 00                	add    %al,(%eax)
	...

00800188 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80018e:	e8 f8 0f 00 00       	call   80118b <close_all>
	sys_env_destroy(0);
  800193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019a:	e8 b2 09 00 00       	call   800b51 <sys_env_destroy>
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    
  8001a1:	00 00                	add    %al,(%eax)
	...

008001a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 14             	sub    $0x14,%esp
  8001ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ae:	8b 03                	mov    (%ebx),%eax
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b7:	40                   	inc    %eax
  8001b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	75 19                	jne    8001da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c8:	00 
  8001c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 40 09 00 00       	call   800b14 <sys_cputs>
		b->idx = 0;
  8001d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001da:	ff 43 04             	incl   0x4(%ebx)
}
  8001dd:	83 c4 14             	add    $0x14,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	8b 45 0c             	mov    0xc(%ebp),%eax
  800203:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 a4 01 80 00 	movl   $0x8001a4,(%esp)
  80021f:	e8 82 01 00 00       	call   8003a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800224:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	e8 d8 08 00 00       	call   800b14 <sys_cputs>

	return b.cnt;
}
  80023c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 87 ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	85 c0                	test   %eax,%eax
  800282:	75 08                	jne    80028c <printnum+0x2c>
  800284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800287:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028a:	77 57                	ja     8002e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800290:	4b                   	dec    %ebx
  800291:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800295:	8b 45 10             	mov    0x10(%ebp),%eax
  800298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ab:	00 
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	e8 4a 1d 00 00       	call   802008 <__udivdi3>
  8002be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	89 fa                	mov    %edi,%edx
  8002cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d2:	e8 89 ff ff ff       	call   800260 <printnum>
  8002d7:	eb 0f                	jmp    8002e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002dd:	89 34 24             	mov    %esi,(%esp)
  8002e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e3:	4b                   	dec    %ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f f1                	jg     8002d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fe:	00 
  8002ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030c:	e8 17 1e 00 00       	call   802128 <__umoddi3>
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	0f be 80 a6 22 80 00 	movsbl 0x8022a6(%eax),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800322:	83 c4 3c             	add    $0x3c,%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032d:	83 fa 01             	cmp    $0x1,%edx
  800330:	7e 0e                	jle    800340 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 08             	lea    0x8(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 22                	jmp    800362 <getuint+0x38>
	else if (lflag)
  800340:	85 d2                	test   %edx,%edx
  800342:	74 10                	je     800354 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 0e                	jmp    800362 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	3b 50 04             	cmp    0x4(%eax),%edx
  800372:	73 08                	jae    80037c <sprintputch+0x18>
		*b->buf++ = ch;
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	88 0a                	mov    %cl,(%edx)
  800379:	42                   	inc    %edx
  80037a:	89 10                	mov    %edx,(%eax)
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800384:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800387:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038b:	8b 45 10             	mov    0x10(%ebp),%eax
  80038e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 02 00 00 00       	call   8003a6 <vprintfmt>
	va_end(ap);
}
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	57                   	push   %edi
  8003aa:	56                   	push   %esi
  8003ab:	53                   	push   %ebx
  8003ac:	83 ec 4c             	sub    $0x4c,%esp
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 6b 03 00 00    	je     80072a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	0f b6 06             	movzbl (%esi),%eax
  8003cc:	46                   	inc    %esi
  8003cd:	83 f8 25             	cmp    $0x25,%eax
  8003d0:	75 e5                	jne    8003b7 <vprintfmt+0x11>
  8003d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ee:	eb 26                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003f7:	eb 1d                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800400:	eb 14                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800405:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80040c:	eb 08                	jmp    800416 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80040e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800411:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	0f b6 06             	movzbl (%esi),%eax
  800419:	8d 56 01             	lea    0x1(%esi),%edx
  80041c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80041f:	8a 16                	mov    (%esi),%dl
  800421:	83 ea 23             	sub    $0x23,%edx
  800424:	80 fa 55             	cmp    $0x55,%dl
  800427:	0f 87 e1 02 00 00    	ja     80070e <vprintfmt+0x368>
  80042d:	0f b6 d2             	movzbl %dl,%edx
  800430:	ff 24 95 e0 23 80 00 	jmp    *0x8023e0(,%edx,4)
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800442:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800446:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800449:	8d 50 d0             	lea    -0x30(%eax),%edx
  80044c:	83 fa 09             	cmp    $0x9,%edx
  80044f:	77 2a                	ja     80047b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800451:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800452:	eb eb                	jmp    80043f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800462:	eb 17                	jmp    80047b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800464:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800468:	78 98                	js     800402 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046d:	eb a7                	jmp    800416 <vprintfmt+0x70>
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800472:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800479:	eb 9b                	jmp    800416 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80047b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047f:	79 95                	jns    800416 <vprintfmt+0x70>
  800481:	eb 8b                	jmp    80040e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800483:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800487:	eb 8d                	jmp    800416 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a1:	e9 23 ff ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	79 02                	jns    8004b7 <vprintfmt+0x111>
  8004b5:	f7 d8                	neg    %eax
  8004b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 0f             	cmp    $0xf,%eax
  8004bc:	7f 0b                	jg     8004c9 <vprintfmt+0x123>
  8004be:	8b 04 85 40 25 80 00 	mov    0x802540(,%eax,4),%eax
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	75 23                	jne    8004ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004cd:	c7 44 24 08 be 22 80 	movl   $0x8022be,0x8(%esp)
  8004d4:	00 
  8004d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 9a fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e7:	e9 dd fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f0:	c7 44 24 08 9a 26 80 	movl   $0x80269a,0x8(%esp)
  8004f7:	00 
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ff:	89 14 24             	mov    %edx,(%esp)
  800502:	e8 77 fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050a:	e9 ba fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
  80050f:	89 f9                	mov    %edi,%ecx
  800511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800514:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 30                	mov    (%eax),%esi
  800522:	85 f6                	test   %esi,%esi
  800524:	75 05                	jne    80052b <vprintfmt+0x185>
				p = "(null)";
  800526:	be b7 22 80 00       	mov    $0x8022b7,%esi
			if (width > 0 && padc != '-')
  80052b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052f:	0f 8e 84 00 00 00    	jle    8005b9 <vprintfmt+0x213>
  800535:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800539:	74 7e                	je     8005b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053f:	89 34 24             	mov    %esi,(%esp)
  800542:	e8 8b 02 00 00       	call   8007d2 <strnlen>
  800547:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80054a:	29 c2                	sub    %eax,%edx
  80054c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80054f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800553:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800556:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800559:	89 de                	mov    %ebx,%esi
  80055b:	89 d3                	mov    %edx,%ebx
  80055d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	eb 0b                	jmp    80056c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800561:	89 74 24 04          	mov    %esi,0x4(%esp)
  800565:	89 3c 24             	mov    %edi,(%esp)
  800568:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	4b                   	dec    %ebx
  80056c:	85 db                	test   %ebx,%ebx
  80056e:	7f f1                	jg     800561 <vprintfmt+0x1bb>
  800570:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800573:	89 f3                	mov    %esi,%ebx
  800575:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057b:	85 c0                	test   %eax,%eax
  80057d:	79 05                	jns    800584 <vprintfmt+0x1de>
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800587:	29 c2                	sub    %eax,%edx
  800589:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80058c:	eb 2b                	jmp    8005b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800592:	74 18                	je     8005ac <vprintfmt+0x206>
  800594:	8d 50 e0             	lea    -0x20(%eax),%edx
  800597:	83 fa 5e             	cmp    $0x5e,%edx
  80059a:	76 10                	jbe    8005ac <vprintfmt+0x206>
					putch('?', putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
  8005aa:	eb 0a                	jmp    8005b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b9:	0f be 06             	movsbl (%esi),%eax
  8005bc:	46                   	inc    %esi
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	74 21                	je     8005e2 <vprintfmt+0x23c>
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	78 c9                	js     80058e <vprintfmt+0x1e8>
  8005c5:	4f                   	dec    %edi
  8005c6:	79 c6                	jns    80058e <vprintfmt+0x1e8>
  8005c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d0:	eb 18                	jmp    8005ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005df:	4b                   	dec    %ebx
  8005e0:	eb 08                	jmp    8005ea <vprintfmt+0x244>
  8005e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ea:	85 db                	test   %ebx,%ebx
  8005ec:	7f e4                	jg     8005d2 <vprintfmt+0x22c>
  8005ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f6:	e9 ce fd ff ff       	jmp    8003c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 f9 01             	cmp    $0x1,%ecx
  8005fe:	7e 10                	jle    800610 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 08             	lea    0x8(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 30                	mov    (%eax),%esi
  80060b:	8b 78 04             	mov    0x4(%eax),%edi
  80060e:	eb 26                	jmp    800636 <vprintfmt+0x290>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	74 12                	je     800626 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	89 f7                	mov    %esi,%edi
  800621:	c1 ff 1f             	sar    $0x1f,%edi
  800624:	eb 10                	jmp    800636 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 30                	mov    (%eax),%esi
  800631:	89 f7                	mov    %esi,%edi
  800633:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800636:	85 ff                	test   %edi,%edi
  800638:	78 0a                	js     800644 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	e9 8c 00 00 00       	jmp    8006d0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800652:	f7 de                	neg    %esi
  800654:	83 d7 00             	adc    $0x0,%edi
  800657:	f7 df                	neg    %edi
			}
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	eb 70                	jmp    8006d0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800660:	89 ca                	mov    %ecx,%edx
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 c0 fc ff ff       	call   80032a <getuint>
  80066a:	89 c6                	mov    %eax,%esi
  80066c:	89 d7                	mov    %edx,%edi
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800673:	eb 5b                	jmp    8006d0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800675:	89 ca                	mov    %ecx,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 ab fc ff ff       	call   80032a <getuint>
  80067f:	89 c6                	mov    %eax,%esi
  800681:	89 d7                	mov    %edx,%edi
			base = 8;
  800683:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800688:	eb 46                	jmp    8006d0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006af:	8b 30                	mov    (%eax),%esi
  8006b1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bb:	eb 13                	jmp    8006d0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bd:	89 ca                	mov    %ecx,%edx
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	e8 63 fc ff ff       	call   80032a <getuint>
  8006c7:	89 c6                	mov    %eax,%esi
  8006c9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e3:	89 34 24             	mov    %esi,(%esp)
  8006e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ea:	89 da                	mov    %ebx,%edx
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	e8 6c fb ff ff       	call   800260 <printnum>
			break;
  8006f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f7:	e9 cd fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800709:	e9 bb fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800712:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	eb 01                	jmp    80071f <vprintfmt+0x379>
  80071e:	4e                   	dec    %esi
  80071f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800723:	75 f9                	jne    80071e <vprintfmt+0x378>
  800725:	e9 9f fc ff ff       	jmp    8003c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80072a:	83 c4 4c             	add    $0x4c,%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 28             	sub    $0x28,%esp
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800741:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800745:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800748:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 30                	je     800783 <vsnprintf+0x51>
  800753:	85 d2                	test   %edx,%edx
  800755:	7e 33                	jle    80078a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	8b 45 10             	mov    0x10(%ebp),%eax
  800761:	89 44 24 08          	mov    %eax,0x8(%esp)
  800765:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	c7 04 24 64 03 80 00 	movl   $0x800364,(%esp)
  800773:	e8 2e fc ff ff       	call   8003a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800778:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800781:	eb 0c                	jmp    80078f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800788:	eb 05                	jmp    80078f <vsnprintf+0x5d>
  80078a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079e:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	89 04 24             	mov    %eax,(%esp)
  8007b2:	e8 7b ff ff ff       	call   800732 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    
  8007b9:	00 00                	add    %al,(%eax)
	...

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	eb 01                	jmp    8007ca <strlen+0xe>
		n++;
  8007c9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ce:	75 f9                	jne    8007c9 <strlen+0xd>
		n++;
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e0:	eb 01                	jmp    8007e3 <strnlen+0x11>
		n++;
  8007e2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 d0                	cmp    %edx,%eax
  8007e5:	74 06                	je     8007ed <strnlen+0x1b>
  8007e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007eb:	75 f5                	jne    8007e2 <strnlen+0x10>
		n++;
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800801:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800804:	42                   	inc    %edx
  800805:	84 c9                	test   %cl,%cl
  800807:	75 f5                	jne    8007fe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800809:	5b                   	pop    %ebx
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	89 1c 24             	mov    %ebx,(%esp)
  800819:	e8 9e ff ff ff       	call   8007bc <strlen>
	strcpy(dst + len, src);
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800821:	89 54 24 04          	mov    %edx,0x4(%esp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	e8 c0 ff ff ff       	call   8007ef <strcpy>
	return dst;
}
  80082f:	89 d8                	mov    %ebx,%eax
  800831:	83 c4 08             	add    $0x8,%esp
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800842:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084a:	eb 0c                	jmp    800858 <strncpy+0x21>
		*dst++ = *src;
  80084c:	8a 1a                	mov    (%edx),%bl
  80084e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 3a 01             	cmpb   $0x1,(%edx)
  800854:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	41                   	inc    %ecx
  800858:	39 f1                	cmp    %esi,%ecx
  80085a:	75 f0                	jne    80084c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086e:	85 d2                	test   %edx,%edx
  800870:	75 0a                	jne    80087c <strlcpy+0x1c>
  800872:	89 f0                	mov    %esi,%eax
  800874:	eb 1a                	jmp    800890 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800876:	88 18                	mov    %bl,(%eax)
  800878:	40                   	inc    %eax
  800879:	41                   	inc    %ecx
  80087a:	eb 02                	jmp    80087e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80087e:	4a                   	dec    %edx
  80087f:	74 0a                	je     80088b <strlcpy+0x2b>
  800881:	8a 19                	mov    (%ecx),%bl
  800883:	84 db                	test   %bl,%bl
  800885:	75 ef                	jne    800876 <strlcpy+0x16>
  800887:	89 c2                	mov    %eax,%edx
  800889:	eb 02                	jmp    80088d <strlcpy+0x2d>
  80088b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80088d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800890:	29 f0                	sub    %esi,%eax
}
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089f:	eb 02                	jmp    8008a3 <strcmp+0xd>
		p++, q++;
  8008a1:	41                   	inc    %ecx
  8008a2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a3:	8a 01                	mov    (%ecx),%al
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 04                	je     8008ad <strcmp+0x17>
  8008a9:	3a 02                	cmp    (%edx),%al
  8008ab:	74 f4                	je     8008a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 c0             	movzbl %al,%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008c4:	eb 03                	jmp    8008c9 <strncmp+0x12>
		n--, p++, q++;
  8008c6:	4a                   	dec    %edx
  8008c7:	40                   	inc    %eax
  8008c8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	74 14                	je     8008e1 <strncmp+0x2a>
  8008cd:	8a 18                	mov    (%eax),%bl
  8008cf:	84 db                	test   %bl,%bl
  8008d1:	74 04                	je     8008d7 <strncmp+0x20>
  8008d3:	3a 19                	cmp    (%ecx),%bl
  8008d5:	74 ef                	je     8008c6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 00             	movzbl (%eax),%eax
  8008da:	0f b6 11             	movzbl (%ecx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
  8008df:	eb 05                	jmp    8008e6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f2:	eb 05                	jmp    8008f9 <strchr+0x10>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 0c                	je     800904 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f8:	40                   	inc    %eax
  8008f9:	8a 10                	mov    (%eax),%dl
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	75 f5                	jne    8008f4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090f:	eb 05                	jmp    800916 <strfind+0x10>
		if (*s == c)
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 07                	je     80091c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800915:	40                   	inc    %eax
  800916:	8a 10                	mov    (%eax),%dl
  800918:	84 d2                	test   %dl,%dl
  80091a:	75 f5                	jne    800911 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 7d 08             	mov    0x8(%ebp),%edi
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 30                	je     800961 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 25                	jne    80095e <memset+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 20                	jne    80095e <memset+0x40>
		c &= 0xFF;
  80093e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800941:	89 d3                	mov    %edx,%ebx
  800943:	c1 e3 08             	shl    $0x8,%ebx
  800946:	89 d6                	mov    %edx,%esi
  800948:	c1 e6 18             	shl    $0x18,%esi
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	c1 e0 10             	shl    $0x10,%eax
  800950:	09 f0                	or     %esi,%eax
  800952:	09 d0                	or     %edx,%eax
  800954:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800956:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800959:	fc                   	cld    
  80095a:	f3 ab                	rep stos %eax,%es:(%edi)
  80095c:	eb 03                	jmp    800961 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095e:	fc                   	cld    
  80095f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800961:	89 f8                	mov    %edi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 34                	jae    8009ae <memmove+0x46>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 d0                	cmp    %edx,%eax
  80097f:	73 2d                	jae    8009ae <memmove+0x46>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f6 c2 03             	test   $0x3,%dl
  800987:	75 1b                	jne    8009a4 <memmove+0x3c>
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 13                	jne    8009a4 <memmove+0x3c>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 07                	jmp    8009ab <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a4:	4f                   	dec    %edi
  8009a5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a8:	fd                   	std    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ab:	fc                   	cld    
  8009ac:	eb 20                	jmp    8009ce <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b4:	75 13                	jne    8009c9 <memmove+0x61>
  8009b6:	a8 03                	test   $0x3,%al
  8009b8:	75 0f                	jne    8009c9 <memmove+0x61>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	89 04 24             	mov    %eax,(%esp)
  8009ec:	e8 77 ff ff ff       	call   800968 <memmove>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	eb 16                	jmp    800a1f <memcmp+0x2c>
		if (*s1 != *s2)
  800a09:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a0c:	42                   	inc    %edx
  800a0d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a11:	38 c8                	cmp    %cl,%al
  800a13:	74 0a                	je     800a1f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a15:	0f b6 c0             	movzbl %al,%eax
  800a18:	0f b6 c9             	movzbl %cl,%ecx
  800a1b:	29 c8                	sub    %ecx,%eax
  800a1d:	eb 09                	jmp    800a28 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	39 da                	cmp    %ebx,%edx
  800a21:	75 e6                	jne    800a09 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a36:	89 c2                	mov    %eax,%edx
  800a38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3b:	eb 05                	jmp    800a42 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	38 08                	cmp    %cl,(%eax)
  800a3f:	74 05                	je     800a46 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a41:	40                   	inc    %eax
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	72 f7                	jb     800a3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a54:	eb 01                	jmp    800a57 <strtol+0xf>
		s++;
  800a56:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a57:	8a 02                	mov    (%edx),%al
  800a59:	3c 20                	cmp    $0x20,%al
  800a5b:	74 f9                	je     800a56 <strtol+0xe>
  800a5d:	3c 09                	cmp    $0x9,%al
  800a5f:	74 f5                	je     800a56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	3c 2b                	cmp    $0x2b,%al
  800a63:	75 08                	jne    800a6d <strtol+0x25>
		s++;
  800a65:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	eb 13                	jmp    800a80 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6d:	3c 2d                	cmp    $0x2d,%al
  800a6f:	75 0a                	jne    800a7b <strtol+0x33>
		s++, neg = 1;
  800a71:	8d 52 01             	lea    0x1(%edx),%edx
  800a74:	bf 01 00 00 00       	mov    $0x1,%edi
  800a79:	eb 05                	jmp    800a80 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	74 05                	je     800a89 <strtol+0x41>
  800a84:	83 fb 10             	cmp    $0x10,%ebx
  800a87:	75 28                	jne    800ab1 <strtol+0x69>
  800a89:	8a 02                	mov    (%edx),%al
  800a8b:	3c 30                	cmp    $0x30,%al
  800a8d:	75 10                	jne    800a9f <strtol+0x57>
  800a8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a93:	75 0a                	jne    800a9f <strtol+0x57>
		s += 2, base = 16;
  800a95:	83 c2 02             	add    $0x2,%edx
  800a98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9d:	eb 12                	jmp    800ab1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	75 0e                	jne    800ab1 <strtol+0x69>
  800aa3:	3c 30                	cmp    $0x30,%al
  800aa5:	75 05                	jne    800aac <strtol+0x64>
		s++, base = 8;
  800aa7:	42                   	inc    %edx
  800aa8:	b3 08                	mov    $0x8,%bl
  800aaa:	eb 05                	jmp    800ab1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aac:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab8:	8a 0a                	mov    (%edx),%cl
  800aba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800abd:	80 fb 09             	cmp    $0x9,%bl
  800ac0:	77 08                	ja     800aca <strtol+0x82>
			dig = *s - '0';
  800ac2:	0f be c9             	movsbl %cl,%ecx
  800ac5:	83 e9 30             	sub    $0x30,%ecx
  800ac8:	eb 1e                	jmp    800ae8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aca:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 08                	ja     800ada <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 57             	sub    $0x57,%ecx
  800ad8:	eb 0e                	jmp    800ae8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 12                	ja     800af4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae8:	39 f1                	cmp    %esi,%ecx
  800aea:	7d 0c                	jge    800af8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aec:	42                   	inc    %edx
  800aed:	0f af c6             	imul   %esi,%eax
  800af0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af2:	eb c4                	jmp    800ab8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af4:	89 c1                	mov    %eax,%ecx
  800af6:	eb 02                	jmp    800afa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afe:	74 05                	je     800b05 <strtol+0xbd>
		*endptr = (char *) s;
  800b00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b03:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b05:	85 ff                	test   %edi,%edi
  800b07:	74 04                	je     800b0d <strtol+0xc5>
  800b09:	89 c8                	mov    %ecx,%eax
  800b0b:	f7 d8                	neg    %eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    
	...

00800b14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	89 c7                	mov    %eax,%edi
  800b29:	89 c6                	mov    %eax,%esi
  800b2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	89 d1                	mov    %edx,%ecx
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 cb                	mov    %ecx,%ebx
  800b69:	89 cf                	mov    %ecx,%edi
  800b6b:	89 ce                	mov    %ecx,%esi
  800b6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 28                	jle    800b9b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b7e:	00 
  800b7f:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800b86:	00 
  800b87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8e:	00 
  800b8f:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800b96:	e8 b9 12 00 00       	call   801e54 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9b:	83 c4 2c             	add    $0x2c,%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_yield>:

void
sys_yield(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	be 00 00 00 00       	mov    $0x0,%esi
  800bef:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 f7                	mov    %esi,%edi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 28                	jle    800c2d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c09:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c10:	00 
  800c11:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800c18:	00 
  800c19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c20:	00 
  800c21:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800c28:	e8 27 12 00 00       	call   801e54 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2d:	83 c4 2c             	add    $0x2c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c43:	8b 75 18             	mov    0x18(%ebp),%esi
  800c46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 28                	jle    800c80 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c63:	00 
  800c64:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800c6b:	00 
  800c6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c73:	00 
  800c74:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800c7b:	e8 d4 11 00 00       	call   801e54 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c80:	83 c4 2c             	add    $0x2c,%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 28                	jle    800cd3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800caf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cb6:	00 
  800cb7:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc6:	00 
  800cc7:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800cce:	e8 81 11 00 00       	call   801e54 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	83 c4 2c             	add    $0x2c,%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 28                	jle    800d26 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d02:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d09:	00 
  800d0a:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800d11:	00 
  800d12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d19:	00 
  800d1a:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800d21:	e8 2e 11 00 00       	call   801e54 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d26:	83 c4 2c             	add    $0x2c,%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 df                	mov    %ebx,%edi
  800d49:	89 de                	mov    %ebx,%esi
  800d4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 28                	jle    800d79 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d55:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800d64:	00 
  800d65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6c:	00 
  800d6d:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800d74:	e8 db 10 00 00       	call   801e54 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d79:	83 c4 2c             	add    $0x2c,%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 df                	mov    %ebx,%edi
  800d9c:	89 de                	mov    %ebx,%esi
  800d9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 28                	jle    800dcc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800daf:	00 
  800db0:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800db7:	00 
  800db8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbf:	00 
  800dc0:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800dc7:	e8 88 10 00 00       	call   801e54 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dcc:	83 c4 2c             	add    $0x2c,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	be 00 00 00 00       	mov    $0x0,%esi
  800ddf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e05:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	89 cb                	mov    %ecx,%ebx
  800e0f:	89 cf                	mov    %ecx,%edi
  800e11:	89 ce                	mov    %ecx,%esi
  800e13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e15:	85 c0                	test   %eax,%eax
  800e17:	7e 28                	jle    800e41 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e24:	00 
  800e25:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e34:	00 
  800e35:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  800e3c:	e8 13 10 00 00       	call   801e54 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e41:	83 c4 2c             	add    $0x2c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	00 00                	add    %al,(%eax)
	...

00800e4c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e58:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e5a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e5d:	83 3a 01             	cmpl   $0x1,(%edx)
  800e60:	7e 0b                	jle    800e6d <argstart+0x21>
  800e62:	85 c9                	test   %ecx,%ecx
  800e64:	75 0e                	jne    800e74 <argstart+0x28>
  800e66:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6b:	eb 0c                	jmp    800e79 <argstart+0x2d>
  800e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e72:	eb 05                	jmp    800e79 <argstart+0x2d>
  800e74:	ba 71 22 80 00       	mov    $0x802271,%edx
  800e79:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e7c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <argnext>:

int
argnext(struct Argstate *args)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	53                   	push   %ebx
  800e89:	83 ec 14             	sub    $0x14,%esp
  800e8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e8f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e96:	8b 43 08             	mov    0x8(%ebx),%eax
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	74 6c                	je     800f09 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  800e9d:	80 38 00             	cmpb   $0x0,(%eax)
  800ea0:	75 4d                	jne    800eef <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800ea2:	8b 0b                	mov    (%ebx),%ecx
  800ea4:	83 39 01             	cmpl   $0x1,(%ecx)
  800ea7:	74 52                	je     800efb <argnext+0x76>
		    || args->argv[1][0] != '-'
  800ea9:	8b 53 04             	mov    0x4(%ebx),%edx
  800eac:	8b 42 04             	mov    0x4(%edx),%eax
  800eaf:	80 38 2d             	cmpb   $0x2d,(%eax)
  800eb2:	75 47                	jne    800efb <argnext+0x76>
		    || args->argv[1][1] == '\0')
  800eb4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eb8:	74 41                	je     800efb <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800eba:	40                   	inc    %eax
  800ebb:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ebe:	8b 01                	mov    (%ecx),%eax
  800ec0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800ec7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ecb:	8d 42 08             	lea    0x8(%edx),%eax
  800ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed2:	83 c2 04             	add    $0x4,%edx
  800ed5:	89 14 24             	mov    %edx,(%esp)
  800ed8:	e8 8b fa ff ff       	call   800968 <memmove>
		(*args->argc)--;
  800edd:	8b 03                	mov    (%ebx),%eax
  800edf:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800ee1:	8b 43 08             	mov    0x8(%ebx),%eax
  800ee4:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ee7:	75 06                	jne    800eef <argnext+0x6a>
  800ee9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eed:	74 0c                	je     800efb <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800eef:	8b 53 08             	mov    0x8(%ebx),%edx
  800ef2:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800ef5:	42                   	inc    %edx
  800ef6:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800ef9:	eb 13                	jmp    800f0e <argnext+0x89>

    endofargs:
	args->curarg = 0;
  800efb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800f07:	eb 05                	jmp    800f0e <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800f09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800f0e:	83 c4 14             	add    $0x14,%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	53                   	push   %ebx
  800f18:	83 ec 14             	sub    $0x14,%esp
  800f1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f1e:	8b 43 08             	mov    0x8(%ebx),%eax
  800f21:	85 c0                	test   %eax,%eax
  800f23:	74 59                	je     800f7e <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  800f25:	80 38 00             	cmpb   $0x0,(%eax)
  800f28:	74 0c                	je     800f36 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f2a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f2d:	c7 43 08 71 22 80 00 	movl   $0x802271,0x8(%ebx)
  800f34:	eb 43                	jmp    800f79 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  800f36:	8b 03                	mov    (%ebx),%eax
  800f38:	83 38 01             	cmpl   $0x1,(%eax)
  800f3b:	7e 2e                	jle    800f6b <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  800f3d:	8b 53 04             	mov    0x4(%ebx),%edx
  800f40:	8b 4a 04             	mov    0x4(%edx),%ecx
  800f43:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f46:	8b 00                	mov    (%eax),%eax
  800f48:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f53:	8d 42 08             	lea    0x8(%edx),%eax
  800f56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5a:	83 c2 04             	add    $0x4,%edx
  800f5d:	89 14 24             	mov    %edx,(%esp)
  800f60:	e8 03 fa ff ff       	call   800968 <memmove>
		(*args->argc)--;
  800f65:	8b 03                	mov    (%ebx),%eax
  800f67:	ff 08                	decl   (%eax)
  800f69:	eb 0e                	jmp    800f79 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  800f6b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f72:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f79:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f7c:	eb 05                	jmp    800f83 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f7e:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f83:	83 c4 14             	add    $0x14,%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	83 ec 18             	sub    $0x18,%esp
  800f8f:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f92:	8b 42 0c             	mov    0xc(%edx),%eax
  800f95:	85 c0                	test   %eax,%eax
  800f97:	75 08                	jne    800fa1 <argvalue+0x18>
  800f99:	89 14 24             	mov    %edx,(%esp)
  800f9c:	e8 73 ff ff ff       	call   800f14 <argnextvalue>
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    
	...

00800fa4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	05 00 00 00 30       	add    $0x30000000,%eax
  800faf:	c1 e8 0c             	shr    $0xc,%eax
}
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	89 04 24             	mov    %eax,(%esp)
  800fc0:	e8 df ff ff ff       	call   800fa4 <fd2num>
  800fc5:	05 20 00 0d 00       	add    $0xd0020,%eax
  800fca:	c1 e0 0c             	shl    $0xc,%eax
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	53                   	push   %ebx
  800fd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fd6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800fdb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fdd:	89 c2                	mov    %eax,%edx
  800fdf:	c1 ea 16             	shr    $0x16,%edx
  800fe2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fe9:	f6 c2 01             	test   $0x1,%dl
  800fec:	74 11                	je     800fff <fd_alloc+0x30>
  800fee:	89 c2                	mov    %eax,%edx
  800ff0:	c1 ea 0c             	shr    $0xc,%edx
  800ff3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ffa:	f6 c2 01             	test   $0x1,%dl
  800ffd:	75 09                	jne    801008 <fd_alloc+0x39>
			*fd_store = fd;
  800fff:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801001:	b8 00 00 00 00       	mov    $0x0,%eax
  801006:	eb 17                	jmp    80101f <fd_alloc+0x50>
  801008:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80100d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801012:	75 c7                	jne    800fdb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801014:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80101a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80101f:	5b                   	pop    %ebx
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801028:	83 f8 1f             	cmp    $0x1f,%eax
  80102b:	77 36                	ja     801063 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80102d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801032:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801035:	89 c2                	mov    %eax,%edx
  801037:	c1 ea 16             	shr    $0x16,%edx
  80103a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801041:	f6 c2 01             	test   $0x1,%dl
  801044:	74 24                	je     80106a <fd_lookup+0x48>
  801046:	89 c2                	mov    %eax,%edx
  801048:	c1 ea 0c             	shr    $0xc,%edx
  80104b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801052:	f6 c2 01             	test   $0x1,%dl
  801055:	74 1a                	je     801071 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801057:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105a:	89 02                	mov    %eax,(%edx)
	return 0;
  80105c:	b8 00 00 00 00       	mov    $0x0,%eax
  801061:	eb 13                	jmp    801076 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801063:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801068:	eb 0c                	jmp    801076 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80106a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80106f:	eb 05                	jmp    801076 <fd_lookup+0x54>
  801071:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	53                   	push   %ebx
  80107c:	83 ec 14             	sub    $0x14,%esp
  80107f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801082:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801085:	ba 00 00 00 00       	mov    $0x0,%edx
  80108a:	eb 0e                	jmp    80109a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80108c:	39 08                	cmp    %ecx,(%eax)
  80108e:	75 09                	jne    801099 <dev_lookup+0x21>
			*dev = devtab[i];
  801090:	89 03                	mov    %eax,(%ebx)
			return 0;
  801092:	b8 00 00 00 00       	mov    $0x0,%eax
  801097:	eb 33                	jmp    8010cc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801099:	42                   	inc    %edx
  80109a:	8b 04 95 48 26 80 00 	mov    0x802648(,%edx,4),%eax
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	75 e7                	jne    80108c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010aa:	8b 40 48             	mov    0x48(%eax),%eax
  8010ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b5:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  8010bc:	e8 83 f1 ff ff       	call   800244 <cprintf>
	*dev = 0;
  8010c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010cc:	83 c4 14             	add    $0x14,%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 30             	sub    $0x30,%esp
  8010da:	8b 75 08             	mov    0x8(%ebp),%esi
  8010dd:	8a 45 0c             	mov    0xc(%ebp),%al
  8010e0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010e3:	89 34 24             	mov    %esi,(%esp)
  8010e6:	e8 b9 fe ff ff       	call   800fa4 <fd2num>
  8010eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8010ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010f2:	89 04 24             	mov    %eax,(%esp)
  8010f5:	e8 28 ff ff ff       	call   801022 <fd_lookup>
  8010fa:	89 c3                	mov    %eax,%ebx
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	78 05                	js     801105 <fd_close+0x33>
	    || fd != fd2)
  801100:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801103:	74 0d                	je     801112 <fd_close+0x40>
		return (must_exist ? r : 0);
  801105:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801109:	75 46                	jne    801151 <fd_close+0x7f>
  80110b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801110:	eb 3f                	jmp    801151 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801112:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801115:	89 44 24 04          	mov    %eax,0x4(%esp)
  801119:	8b 06                	mov    (%esi),%eax
  80111b:	89 04 24             	mov    %eax,(%esp)
  80111e:	e8 55 ff ff ff       	call   801078 <dev_lookup>
  801123:	89 c3                	mov    %eax,%ebx
  801125:	85 c0                	test   %eax,%eax
  801127:	78 18                	js     801141 <fd_close+0x6f>
		if (dev->dev_close)
  801129:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112c:	8b 40 10             	mov    0x10(%eax),%eax
  80112f:	85 c0                	test   %eax,%eax
  801131:	74 09                	je     80113c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801133:	89 34 24             	mov    %esi,(%esp)
  801136:	ff d0                	call   *%eax
  801138:	89 c3                	mov    %eax,%ebx
  80113a:	eb 05                	jmp    801141 <fd_close+0x6f>
		else
			r = 0;
  80113c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801141:	89 74 24 04          	mov    %esi,0x4(%esp)
  801145:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80114c:	e8 37 fb ff ff       	call   800c88 <sys_page_unmap>
	return r;
}
  801151:	89 d8                	mov    %ebx,%eax
  801153:	83 c4 30             	add    $0x30,%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801160:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801163:	89 44 24 04          	mov    %eax,0x4(%esp)
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	89 04 24             	mov    %eax,(%esp)
  80116d:	e8 b0 fe ff ff       	call   801022 <fd_lookup>
  801172:	85 c0                	test   %eax,%eax
  801174:	78 13                	js     801189 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801176:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80117d:	00 
  80117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801181:	89 04 24             	mov    %eax,(%esp)
  801184:	e8 49 ff ff ff       	call   8010d2 <fd_close>
}
  801189:	c9                   	leave  
  80118a:	c3                   	ret    

0080118b <close_all>:

void
close_all(void)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	53                   	push   %ebx
  80118f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801192:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801197:	89 1c 24             	mov    %ebx,(%esp)
  80119a:	e8 bb ff ff ff       	call   80115a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80119f:	43                   	inc    %ebx
  8011a0:	83 fb 20             	cmp    $0x20,%ebx
  8011a3:	75 f2                	jne    801197 <close_all+0xc>
		close(i);
}
  8011a5:	83 c4 14             	add    $0x14,%esp
  8011a8:	5b                   	pop    %ebx
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	57                   	push   %edi
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	83 ec 4c             	sub    $0x4c,%esp
  8011b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011be:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c1:	89 04 24             	mov    %eax,(%esp)
  8011c4:	e8 59 fe ff ff       	call   801022 <fd_lookup>
  8011c9:	89 c3                	mov    %eax,%ebx
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	0f 88 e1 00 00 00    	js     8012b4 <dup+0x109>
		return r;
	close(newfdnum);
  8011d3:	89 3c 24             	mov    %edi,(%esp)
  8011d6:	e8 7f ff ff ff       	call   80115a <close>

	newfd = INDEX2FD(newfdnum);
  8011db:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8011e1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8011e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e7:	89 04 24             	mov    %eax,(%esp)
  8011ea:	e8 c5 fd ff ff       	call   800fb4 <fd2data>
  8011ef:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011f1:	89 34 24             	mov    %esi,(%esp)
  8011f4:	e8 bb fd ff ff       	call   800fb4 <fd2data>
  8011f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011fc:	89 d8                	mov    %ebx,%eax
  8011fe:	c1 e8 16             	shr    $0x16,%eax
  801201:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801208:	a8 01                	test   $0x1,%al
  80120a:	74 46                	je     801252 <dup+0xa7>
  80120c:	89 d8                	mov    %ebx,%eax
  80120e:	c1 e8 0c             	shr    $0xc,%eax
  801211:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801218:	f6 c2 01             	test   $0x1,%dl
  80121b:	74 35                	je     801252 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80121d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801224:	25 07 0e 00 00       	and    $0xe07,%eax
  801229:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801230:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801234:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80123b:	00 
  80123c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801247:	e8 e9 f9 ff ff       	call   800c35 <sys_page_map>
  80124c:	89 c3                	mov    %eax,%ebx
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 3b                	js     80128d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801255:	89 c2                	mov    %eax,%edx
  801257:	c1 ea 0c             	shr    $0xc,%edx
  80125a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801261:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801267:	89 54 24 10          	mov    %edx,0x10(%esp)
  80126b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80126f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801276:	00 
  801277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801282:	e8 ae f9 ff ff       	call   800c35 <sys_page_map>
  801287:	89 c3                	mov    %eax,%ebx
  801289:	85 c0                	test   %eax,%eax
  80128b:	79 25                	jns    8012b2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80128d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801298:	e8 eb f9 ff ff       	call   800c88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80129d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ab:	e8 d8 f9 ff ff       	call   800c88 <sys_page_unmap>
	return r;
  8012b0:	eb 02                	jmp    8012b4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012b2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	83 c4 4c             	add    $0x4c,%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5f                   	pop    %edi
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 24             	sub    $0x24,%esp
  8012c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	89 1c 24             	mov    %ebx,(%esp)
  8012d2:	e8 4b fd ff ff       	call   801022 <fd_lookup>
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 6d                	js     801348 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e5:	8b 00                	mov    (%eax),%eax
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 89 fd ff ff       	call   801078 <dev_lookup>
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 55                	js     801348 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	8b 50 08             	mov    0x8(%eax),%edx
  8012f9:	83 e2 03             	and    $0x3,%edx
  8012fc:	83 fa 01             	cmp    $0x1,%edx
  8012ff:	75 23                	jne    801324 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801301:	a1 04 40 80 00       	mov    0x804004,%eax
  801306:	8b 40 48             	mov    0x48(%eax),%eax
  801309:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	c7 04 24 0d 26 80 00 	movl   $0x80260d,(%esp)
  801318:	e8 27 ef ff ff       	call   800244 <cprintf>
		return -E_INVAL;
  80131d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801322:	eb 24                	jmp    801348 <read+0x8a>
	}
	if (!dev->dev_read)
  801324:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801327:	8b 52 08             	mov    0x8(%edx),%edx
  80132a:	85 d2                	test   %edx,%edx
  80132c:	74 15                	je     801343 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80132e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801331:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801335:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801338:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80133c:	89 04 24             	mov    %eax,(%esp)
  80133f:	ff d2                	call   *%edx
  801341:	eb 05                	jmp    801348 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801343:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801348:	83 c4 24             	add    $0x24,%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	57                   	push   %edi
  801352:	56                   	push   %esi
  801353:	53                   	push   %ebx
  801354:	83 ec 1c             	sub    $0x1c,%esp
  801357:	8b 7d 08             	mov    0x8(%ebp),%edi
  80135a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80135d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801362:	eb 23                	jmp    801387 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801364:	89 f0                	mov    %esi,%eax
  801366:	29 d8                	sub    %ebx,%eax
  801368:	89 44 24 08          	mov    %eax,0x8(%esp)
  80136c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136f:	01 d8                	add    %ebx,%eax
  801371:	89 44 24 04          	mov    %eax,0x4(%esp)
  801375:	89 3c 24             	mov    %edi,(%esp)
  801378:	e8 41 ff ff ff       	call   8012be <read>
		if (m < 0)
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 10                	js     801391 <readn+0x43>
			return m;
		if (m == 0)
  801381:	85 c0                	test   %eax,%eax
  801383:	74 0a                	je     80138f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801385:	01 c3                	add    %eax,%ebx
  801387:	39 f3                	cmp    %esi,%ebx
  801389:	72 d9                	jb     801364 <readn+0x16>
  80138b:	89 d8                	mov    %ebx,%eax
  80138d:	eb 02                	jmp    801391 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80138f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801391:	83 c4 1c             	add    $0x1c,%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	53                   	push   %ebx
  80139d:	83 ec 24             	sub    $0x24,%esp
  8013a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013aa:	89 1c 24             	mov    %ebx,(%esp)
  8013ad:	e8 70 fc ff ff       	call   801022 <fd_lookup>
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 68                	js     80141e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	8b 00                	mov    (%eax),%eax
  8013c2:	89 04 24             	mov    %eax,(%esp)
  8013c5:	e8 ae fc ff ff       	call   801078 <dev_lookup>
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 50                	js     80141e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d5:	75 23                	jne    8013fa <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8013dc:	8b 40 48             	mov    0x48(%eax),%eax
  8013df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e7:	c7 04 24 29 26 80 00 	movl   $0x802629,(%esp)
  8013ee:	e8 51 ee ff ff       	call   800244 <cprintf>
		return -E_INVAL;
  8013f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f8:	eb 24                	jmp    80141e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801400:	85 d2                	test   %edx,%edx
  801402:	74 15                	je     801419 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801404:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801407:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	ff d2                	call   *%edx
  801417:	eb 05                	jmp    80141e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801419:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80141e:	83 c4 24             	add    $0x24,%esp
  801421:	5b                   	pop    %ebx
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <seek>:

int
seek(int fdnum, off_t offset)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80142d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
  801434:	89 04 24             	mov    %eax,(%esp)
  801437:	e8 e6 fb ff ff       	call   801022 <fd_lookup>
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 0e                	js     80144e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801440:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801443:	8b 55 0c             	mov    0xc(%ebp),%edx
  801446:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801449:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	53                   	push   %ebx
  801454:	83 ec 24             	sub    $0x24,%esp
  801457:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801461:	89 1c 24             	mov    %ebx,(%esp)
  801464:	e8 b9 fb ff ff       	call   801022 <fd_lookup>
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 61                	js     8014ce <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801470:	89 44 24 04          	mov    %eax,0x4(%esp)
  801474:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801477:	8b 00                	mov    (%eax),%eax
  801479:	89 04 24             	mov    %eax,(%esp)
  80147c:	e8 f7 fb ff ff       	call   801078 <dev_lookup>
  801481:	85 c0                	test   %eax,%eax
  801483:	78 49                	js     8014ce <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801485:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801488:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80148c:	75 23                	jne    8014b1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80148e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801493:	8b 40 48             	mov    0x48(%eax),%eax
  801496:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80149a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149e:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  8014a5:	e8 9a ed ff ff       	call   800244 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014af:	eb 1d                	jmp    8014ce <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8014b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b4:	8b 52 18             	mov    0x18(%edx),%edx
  8014b7:	85 d2                	test   %edx,%edx
  8014b9:	74 0e                	je     8014c9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014c2:	89 04 24             	mov    %eax,(%esp)
  8014c5:	ff d2                	call   *%edx
  8014c7:	eb 05                	jmp    8014ce <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014ce:	83 c4 24             	add    $0x24,%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    

008014d4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	53                   	push   %ebx
  8014d8:	83 ec 24             	sub    $0x24,%esp
  8014db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e8:	89 04 24             	mov    %eax,(%esp)
  8014eb:	e8 32 fb ff ff       	call   801022 <fd_lookup>
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 52                	js     801546 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fe:	8b 00                	mov    (%eax),%eax
  801500:	89 04 24             	mov    %eax,(%esp)
  801503:	e8 70 fb ff ff       	call   801078 <dev_lookup>
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 3a                	js     801546 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80150c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801513:	74 2c                	je     801541 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801515:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801518:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80151f:	00 00 00 
	stat->st_isdir = 0;
  801522:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801529:	00 00 00 
	stat->st_dev = dev;
  80152c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801532:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801536:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801539:	89 14 24             	mov    %edx,(%esp)
  80153c:	ff 50 14             	call   *0x14(%eax)
  80153f:	eb 05                	jmp    801546 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801541:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801546:	83 c4 24             	add    $0x24,%esp
  801549:	5b                   	pop    %ebx
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	56                   	push   %esi
  801550:	53                   	push   %ebx
  801551:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801554:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80155b:	00 
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
  80155f:	89 04 24             	mov    %eax,(%esp)
  801562:	e8 fe 01 00 00       	call   801765 <open>
  801567:	89 c3                	mov    %eax,%ebx
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 1b                	js     801588 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80156d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801570:	89 44 24 04          	mov    %eax,0x4(%esp)
  801574:	89 1c 24             	mov    %ebx,(%esp)
  801577:	e8 58 ff ff ff       	call   8014d4 <fstat>
  80157c:	89 c6                	mov    %eax,%esi
	close(fd);
  80157e:	89 1c 24             	mov    %ebx,(%esp)
  801581:	e8 d4 fb ff ff       	call   80115a <close>
	return r;
  801586:	89 f3                	mov    %esi,%ebx
}
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    
  801591:	00 00                	add    %al,(%eax)
	...

00801594 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	56                   	push   %esi
  801598:	53                   	push   %ebx
  801599:	83 ec 10             	sub    $0x10,%esp
  80159c:	89 c3                	mov    %eax,%ebx
  80159e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015a0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015a7:	75 11                	jne    8015ba <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015b0:	e8 ca 09 00 00       	call   801f7f <ipc_find_env>
  8015b5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015ba:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015c1:	00 
  8015c2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015c9:	00 
  8015ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ce:	a1 00 40 80 00       	mov    0x804000,%eax
  8015d3:	89 04 24             	mov    %eax,(%esp)
  8015d6:	e8 3a 09 00 00       	call   801f15 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015e2:	00 
  8015e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ee:	e8 b9 08 00 00       	call   801eac <ipc_recv>
}
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	5b                   	pop    %ebx
  8015f7:	5e                   	pop    %esi
  8015f8:	5d                   	pop    %ebp
  8015f9:	c3                   	ret    

008015fa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801600:	8b 45 08             	mov    0x8(%ebp),%eax
  801603:	8b 40 0c             	mov    0xc(%eax),%eax
  801606:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80160b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801613:	ba 00 00 00 00       	mov    $0x0,%edx
  801618:	b8 02 00 00 00       	mov    $0x2,%eax
  80161d:	e8 72 ff ff ff       	call   801594 <fsipc>
}
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80162a:	8b 45 08             	mov    0x8(%ebp),%eax
  80162d:	8b 40 0c             	mov    0xc(%eax),%eax
  801630:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801635:	ba 00 00 00 00       	mov    $0x0,%edx
  80163a:	b8 06 00 00 00       	mov    $0x6,%eax
  80163f:	e8 50 ff ff ff       	call   801594 <fsipc>
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 14             	sub    $0x14,%esp
  80164d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	8b 40 0c             	mov    0xc(%eax),%eax
  801656:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80165b:	ba 00 00 00 00       	mov    $0x0,%edx
  801660:	b8 05 00 00 00       	mov    $0x5,%eax
  801665:	e8 2a ff ff ff       	call   801594 <fsipc>
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 2b                	js     801699 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80166e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801675:	00 
  801676:	89 1c 24             	mov    %ebx,(%esp)
  801679:	e8 71 f1 ff ff       	call   8007ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80167e:	a1 80 50 80 00       	mov    0x805080,%eax
  801683:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801689:	a1 84 50 80 00       	mov    0x805084,%eax
  80168e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801694:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801699:	83 c4 14             	add    $0x14,%esp
  80169c:	5b                   	pop    %ebx
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8016a5:	c7 44 24 08 58 26 80 	movl   $0x802658,0x8(%esp)
  8016ac:	00 
  8016ad:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016b4:	00 
  8016b5:	c7 04 24 76 26 80 00 	movl   $0x802676,(%esp)
  8016bc:	e8 93 07 00 00       	call   801e54 <_panic>

008016c1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 10             	sub    $0x10,%esp
  8016c9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016d7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8016e7:	e8 a8 fe ff ff       	call   801594 <fsipc>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 6a                	js     80175c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016f2:	39 c6                	cmp    %eax,%esi
  8016f4:	73 24                	jae    80171a <devfile_read+0x59>
  8016f6:	c7 44 24 0c 81 26 80 	movl   $0x802681,0xc(%esp)
  8016fd:	00 
  8016fe:	c7 44 24 08 88 26 80 	movl   $0x802688,0x8(%esp)
  801705:	00 
  801706:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80170d:	00 
  80170e:	c7 04 24 76 26 80 00 	movl   $0x802676,(%esp)
  801715:	e8 3a 07 00 00       	call   801e54 <_panic>
	assert(r <= PGSIZE);
  80171a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80171f:	7e 24                	jle    801745 <devfile_read+0x84>
  801721:	c7 44 24 0c 9d 26 80 	movl   $0x80269d,0xc(%esp)
  801728:	00 
  801729:	c7 44 24 08 88 26 80 	movl   $0x802688,0x8(%esp)
  801730:	00 
  801731:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801738:	00 
  801739:	c7 04 24 76 26 80 00 	movl   $0x802676,(%esp)
  801740:	e8 0f 07 00 00       	call   801e54 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801745:	89 44 24 08          	mov    %eax,0x8(%esp)
  801749:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801750:	00 
  801751:	8b 45 0c             	mov    0xc(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 0c f2 ff ff       	call   800968 <memmove>
	return r;
}
  80175c:	89 d8                	mov    %ebx,%eax
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
  80176a:	83 ec 20             	sub    $0x20,%esp
  80176d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801770:	89 34 24             	mov    %esi,(%esp)
  801773:	e8 44 f0 ff ff       	call   8007bc <strlen>
  801778:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80177d:	7f 60                	jg     8017df <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801782:	89 04 24             	mov    %eax,(%esp)
  801785:	e8 45 f8 ff ff       	call   800fcf <fd_alloc>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 54                	js     8017e4 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801790:	89 74 24 04          	mov    %esi,0x4(%esp)
  801794:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80179b:	e8 4f f0 ff ff       	call   8007ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8017b0:	e8 df fd ff ff       	call   801594 <fsipc>
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	79 15                	jns    8017d0 <open+0x6b>
		fd_close(fd, 0);
  8017bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017c2:	00 
  8017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c6:	89 04 24             	mov    %eax,(%esp)
  8017c9:	e8 04 f9 ff ff       	call   8010d2 <fd_close>
		return r;
  8017ce:	eb 14                	jmp    8017e4 <open+0x7f>
	}

	return fd2num(fd);
  8017d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d3:	89 04 24             	mov    %eax,(%esp)
  8017d6:	e8 c9 f7 ff ff       	call   800fa4 <fd2num>
  8017db:	89 c3                	mov    %eax,%ebx
  8017dd:	eb 05                	jmp    8017e4 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017df:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017e4:	89 d8                	mov    %ebx,%eax
  8017e6:	83 c4 20             	add    $0x20,%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8017fd:	e8 92 fd ff ff       	call   801594 <fsipc>
}
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 14             	sub    $0x14,%esp
  80180b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80180d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801811:	7e 32                	jle    801845 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801813:	8b 40 04             	mov    0x4(%eax),%eax
  801816:	89 44 24 08          	mov    %eax,0x8(%esp)
  80181a:	8d 43 10             	lea    0x10(%ebx),%eax
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	8b 03                	mov    (%ebx),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 6e fb ff ff       	call   801399 <write>
		if (result > 0)
  80182b:	85 c0                	test   %eax,%eax
  80182d:	7e 03                	jle    801832 <writebuf+0x2e>
			b->result += result;
  80182f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801832:	39 43 04             	cmp    %eax,0x4(%ebx)
  801835:	74 0e                	je     801845 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801837:	89 c2                	mov    %eax,%edx
  801839:	85 c0                	test   %eax,%eax
  80183b:	7e 05                	jle    801842 <writebuf+0x3e>
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801845:	83 c4 14             	add    $0x14,%esp
  801848:	5b                   	pop    %ebx
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <putch>:

static void
putch(int ch, void *thunk)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 04             	sub    $0x4,%esp
  801852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801855:	8b 43 04             	mov    0x4(%ebx),%eax
  801858:	8b 55 08             	mov    0x8(%ebp),%edx
  80185b:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80185f:	40                   	inc    %eax
  801860:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801863:	3d 00 01 00 00       	cmp    $0x100,%eax
  801868:	75 0e                	jne    801878 <putch+0x2d>
		writebuf(b);
  80186a:	89 d8                	mov    %ebx,%eax
  80186c:	e8 93 ff ff ff       	call   801804 <writebuf>
		b->idx = 0;
  801871:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801878:	83 c4 04             	add    $0x4,%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801890:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801897:	00 00 00 
	b.result = 0;
  80189a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018a1:	00 00 00 
	b.error = 1;
  8018a4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018ab:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018bc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c6:	c7 04 24 4b 18 80 00 	movl   $0x80184b,(%esp)
  8018cd:	e8 d4 ea ff ff       	call   8003a6 <vprintfmt>
	if (b.idx > 0)
  8018d2:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018d9:	7e 0b                	jle    8018e6 <vfprintf+0x68>
		writebuf(&b);
  8018db:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018e1:	e8 1e ff ff ff       	call   801804 <writebuf>

	return (b.result ? b.result : b.error);
  8018e6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	75 06                	jne    8018f6 <vfprintf+0x78>
  8018f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018fe:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801901:	89 44 24 08          	mov    %eax,0x8(%esp)
  801905:	8b 45 0c             	mov    0xc(%ebp),%eax
  801908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 67 ff ff ff       	call   80187e <vfprintf>
	va_end(ap);

	return cnt;
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <printf>:

int
printf(const char *fmt, ...)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80191f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801922:	89 44 24 08          	mov    %eax,0x8(%esp)
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801934:	e8 45 ff ff ff       	call   80187e <vfprintf>
	va_end(ap);

	return cnt;
}
  801939:	c9                   	leave  
  80193a:	c3                   	ret    
	...

0080193c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 10             	sub    $0x10,%esp
  801944:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	89 04 24             	mov    %eax,(%esp)
  80194d:	e8 62 f6 ff ff       	call   800fb4 <fd2data>
  801952:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801954:	c7 44 24 04 a9 26 80 	movl   $0x8026a9,0x4(%esp)
  80195b:	00 
  80195c:	89 34 24             	mov    %esi,(%esp)
  80195f:	e8 8b ee ff ff       	call   8007ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801964:	8b 43 04             	mov    0x4(%ebx),%eax
  801967:	2b 03                	sub    (%ebx),%eax
  801969:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80196f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801976:	00 00 00 
	stat->st_dev = &devpipe;
  801979:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801980:	30 80 00 
	return 0;
}
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	53                   	push   %ebx
  801993:	83 ec 14             	sub    $0x14,%esp
  801996:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801999:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a4:	e8 df f2 ff ff       	call   800c88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019a9:	89 1c 24             	mov    %ebx,(%esp)
  8019ac:	e8 03 f6 ff ff       	call   800fb4 <fd2data>
  8019b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019bc:	e8 c7 f2 ff ff       	call   800c88 <sys_page_unmap>
}
  8019c1:	83 c4 14             	add    $0x14,%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5d                   	pop    %ebp
  8019c6:	c3                   	ret    

008019c7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	57                   	push   %edi
  8019cb:	56                   	push   %esi
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 2c             	sub    $0x2c,%esp
  8019d0:	89 c7                	mov    %eax,%edi
  8019d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8019da:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019dd:	89 3c 24             	mov    %edi,(%esp)
  8019e0:	e8 df 05 00 00       	call   801fc4 <pageref>
  8019e5:	89 c6                	mov    %eax,%esi
  8019e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ea:	89 04 24             	mov    %eax,(%esp)
  8019ed:	e8 d2 05 00 00       	call   801fc4 <pageref>
  8019f2:	39 c6                	cmp    %eax,%esi
  8019f4:	0f 94 c0             	sete   %al
  8019f7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019fa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a00:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a03:	39 cb                	cmp    %ecx,%ebx
  801a05:	75 08                	jne    801a0f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a07:	83 c4 2c             	add    $0x2c,%esp
  801a0a:	5b                   	pop    %ebx
  801a0b:	5e                   	pop    %esi
  801a0c:	5f                   	pop    %edi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a0f:	83 f8 01             	cmp    $0x1,%eax
  801a12:	75 c1                	jne    8019d5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a14:	8b 42 58             	mov    0x58(%edx),%eax
  801a17:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801a1e:	00 
  801a1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a27:	c7 04 24 b0 26 80 00 	movl   $0x8026b0,(%esp)
  801a2e:	e8 11 e8 ff ff       	call   800244 <cprintf>
  801a33:	eb a0                	jmp    8019d5 <_pipeisclosed+0xe>

00801a35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	57                   	push   %edi
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 1c             	sub    $0x1c,%esp
  801a3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a41:	89 34 24             	mov    %esi,(%esp)
  801a44:	e8 6b f5 ff ff       	call   800fb4 <fd2data>
  801a49:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4b:	bf 00 00 00 00       	mov    $0x0,%edi
  801a50:	eb 3c                	jmp    801a8e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a52:	89 da                	mov    %ebx,%edx
  801a54:	89 f0                	mov    %esi,%eax
  801a56:	e8 6c ff ff ff       	call   8019c7 <_pipeisclosed>
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	75 38                	jne    801a97 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a5f:	e8 5e f1 ff ff       	call   800bc2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a64:	8b 43 04             	mov    0x4(%ebx),%eax
  801a67:	8b 13                	mov    (%ebx),%edx
  801a69:	83 c2 20             	add    $0x20,%edx
  801a6c:	39 d0                	cmp    %edx,%eax
  801a6e:	73 e2                	jae    801a52 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a70:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a73:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801a76:	89 c2                	mov    %eax,%edx
  801a78:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a7e:	79 05                	jns    801a85 <devpipe_write+0x50>
  801a80:	4a                   	dec    %edx
  801a81:	83 ca e0             	or     $0xffffffe0,%edx
  801a84:	42                   	inc    %edx
  801a85:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a89:	40                   	inc    %eax
  801a8a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8d:	47                   	inc    %edi
  801a8e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a91:	75 d1                	jne    801a64 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a93:	89 f8                	mov    %edi,%eax
  801a95:	eb 05                	jmp    801a9c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a97:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a9c:	83 c4 1c             	add    $0x1c,%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5f                   	pop    %edi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 1c             	sub    $0x1c,%esp
  801aad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ab0:	89 3c 24             	mov    %edi,(%esp)
  801ab3:	e8 fc f4 ff ff       	call   800fb4 <fd2data>
  801ab8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aba:	be 00 00 00 00       	mov    $0x0,%esi
  801abf:	eb 3a                	jmp    801afb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ac1:	85 f6                	test   %esi,%esi
  801ac3:	74 04                	je     801ac9 <devpipe_read+0x25>
				return i;
  801ac5:	89 f0                	mov    %esi,%eax
  801ac7:	eb 40                	jmp    801b09 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ac9:	89 da                	mov    %ebx,%edx
  801acb:	89 f8                	mov    %edi,%eax
  801acd:	e8 f5 fe ff ff       	call   8019c7 <_pipeisclosed>
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	75 2e                	jne    801b04 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ad6:	e8 e7 f0 ff ff       	call   800bc2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801adb:	8b 03                	mov    (%ebx),%eax
  801add:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ae0:	74 df                	je     801ac1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ae2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ae7:	79 05                	jns    801aee <devpipe_read+0x4a>
  801ae9:	48                   	dec    %eax
  801aea:	83 c8 e0             	or     $0xffffffe0,%eax
  801aed:	40                   	inc    %eax
  801aee:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801af2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801af5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801af8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afa:	46                   	inc    %esi
  801afb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801afe:	75 db                	jne    801adb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b00:	89 f0                	mov    %esi,%eax
  801b02:	eb 05                	jmp    801b09 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b04:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b09:	83 c4 1c             	add    $0x1c,%esp
  801b0c:	5b                   	pop    %ebx
  801b0d:	5e                   	pop    %esi
  801b0e:	5f                   	pop    %edi
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	57                   	push   %edi
  801b15:	56                   	push   %esi
  801b16:	53                   	push   %ebx
  801b17:	83 ec 3c             	sub    $0x3c,%esp
  801b1a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b1d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b20:	89 04 24             	mov    %eax,(%esp)
  801b23:	e8 a7 f4 ff ff       	call   800fcf <fd_alloc>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	0f 88 45 01 00 00    	js     801c77 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b32:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b39:	00 
  801b3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b48:	e8 94 f0 ff ff       	call   800be1 <sys_page_alloc>
  801b4d:	89 c3                	mov    %eax,%ebx
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	0f 88 20 01 00 00    	js     801c77 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b57:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b5a:	89 04 24             	mov    %eax,(%esp)
  801b5d:	e8 6d f4 ff ff       	call   800fcf <fd_alloc>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	85 c0                	test   %eax,%eax
  801b66:	0f 88 f8 00 00 00    	js     801c64 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b73:	00 
  801b74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b82:	e8 5a f0 ff ff       	call   800be1 <sys_page_alloc>
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	0f 88 d3 00 00 00    	js     801c64 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b94:	89 04 24             	mov    %eax,(%esp)
  801b97:	e8 18 f4 ff ff       	call   800fb4 <fd2data>
  801b9c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ba5:	00 
  801ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801baa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb1:	e8 2b f0 ff ff       	call   800be1 <sys_page_alloc>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	0f 88 91 00 00 00    	js     801c51 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bc3:	89 04 24             	mov    %eax,(%esp)
  801bc6:	e8 e9 f3 ff ff       	call   800fb4 <fd2data>
  801bcb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801bd2:	00 
  801bd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bd7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bde:	00 
  801bdf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801be3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bea:	e8 46 f0 ff ff       	call   800c35 <sys_page_map>
  801bef:	89 c3                	mov    %eax,%ebx
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	78 4c                	js     801c41 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bf5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bfe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c0a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c13:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c22:	89 04 24             	mov    %eax,(%esp)
  801c25:	e8 7a f3 ff ff       	call   800fa4 <fd2num>
  801c2a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c2f:	89 04 24             	mov    %eax,(%esp)
  801c32:	e8 6d f3 ff ff       	call   800fa4 <fd2num>
  801c37:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c3f:	eb 36                	jmp    801c77 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801c41:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4c:	e8 37 f0 ff ff       	call   800c88 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c51:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5f:	e8 24 f0 ff ff       	call   800c88 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c72:	e8 11 f0 ff ff       	call   800c88 <sys_page_unmap>
    err:
	return r;
}
  801c77:	89 d8                	mov    %ebx,%eax
  801c79:	83 c4 3c             	add    $0x3c,%esp
  801c7c:	5b                   	pop    %ebx
  801c7d:	5e                   	pop    %esi
  801c7e:	5f                   	pop    %edi
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    

00801c81 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c91:	89 04 24             	mov    %eax,(%esp)
  801c94:	e8 89 f3 ff ff       	call   801022 <fd_lookup>
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	78 15                	js     801cb2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca0:	89 04 24             	mov    %eax,(%esp)
  801ca3:	e8 0c f3 ff ff       	call   800fb4 <fd2data>
	return _pipeisclosed(fd, p);
  801ca8:	89 c2                	mov    %eax,%edx
  801caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cad:	e8 15 fd ff ff       	call   8019c7 <_pipeisclosed>
}
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    

00801cbe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801cc4:	c7 44 24 04 c8 26 80 	movl   $0x8026c8,0x4(%esp)
  801ccb:	00 
  801ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccf:	89 04 24             	mov    %eax,(%esp)
  801cd2:	e8 18 eb ff ff       	call   8007ef <strcpy>
	return 0;
}
  801cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cea:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf5:	eb 30                	jmp    801d27 <devcons_write+0x49>
		m = n - tot;
  801cf7:	8b 75 10             	mov    0x10(%ebp),%esi
  801cfa:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801cfc:	83 fe 7f             	cmp    $0x7f,%esi
  801cff:	76 05                	jbe    801d06 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801d01:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d06:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d0a:	03 45 0c             	add    0xc(%ebp),%eax
  801d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d11:	89 3c 24             	mov    %edi,(%esp)
  801d14:	e8 4f ec ff ff       	call   800968 <memmove>
		sys_cputs(buf, m);
  801d19:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1d:	89 3c 24             	mov    %edi,(%esp)
  801d20:	e8 ef ed ff ff       	call   800b14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d25:	01 f3                	add    %esi,%ebx
  801d27:	89 d8                	mov    %ebx,%eax
  801d29:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d2c:	72 c9                	jb     801cf7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d2e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d43:	75 07                	jne    801d4c <devcons_read+0x13>
  801d45:	eb 25                	jmp    801d6c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d47:	e8 76 ee ff ff       	call   800bc2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d4c:	e8 e1 ed ff ff       	call   800b32 <sys_cgetc>
  801d51:	85 c0                	test   %eax,%eax
  801d53:	74 f2                	je     801d47 <devcons_read+0xe>
  801d55:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d57:	85 c0                	test   %eax,%eax
  801d59:	78 1d                	js     801d78 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d5b:	83 f8 04             	cmp    $0x4,%eax
  801d5e:	74 13                	je     801d73 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d63:	88 10                	mov    %dl,(%eax)
	return 1;
  801d65:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6a:	eb 0c                	jmp    801d78 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d71:	eb 05                	jmp    801d78 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d80:	8b 45 08             	mov    0x8(%ebp),%eax
  801d83:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d86:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d8d:	00 
  801d8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d91:	89 04 24             	mov    %eax,(%esp)
  801d94:	e8 7b ed ff ff       	call   800b14 <sys_cputs>
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <getchar>:

int
getchar(void)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801da1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801da8:	00 
  801da9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db7:	e8 02 f5 ff ff       	call   8012be <read>
	if (r < 0)
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 0f                	js     801dcf <getchar+0x34>
		return r;
	if (r < 1)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	7e 06                	jle    801dca <getchar+0x2f>
		return -E_EOF;
	return c;
  801dc4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dc8:	eb 05                	jmp    801dcf <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dca:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    

00801dd1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dde:	8b 45 08             	mov    0x8(%ebp),%eax
  801de1:	89 04 24             	mov    %eax,(%esp)
  801de4:	e8 39 f2 ff ff       	call   801022 <fd_lookup>
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 11                	js     801dfe <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df6:	39 10                	cmp    %edx,(%eax)
  801df8:	0f 94 c0             	sete   %al
  801dfb:	0f b6 c0             	movzbl %al,%eax
}
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <opencons>:

int
opencons(void)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e09:	89 04 24             	mov    %eax,(%esp)
  801e0c:	e8 be f1 ff ff       	call   800fcf <fd_alloc>
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 3c                	js     801e51 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e15:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e1c:	00 
  801e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2b:	e8 b1 ed ff ff       	call   800be1 <sys_page_alloc>
  801e30:	85 c0                	test   %eax,%eax
  801e32:	78 1d                	js     801e51 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e34:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e42:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e49:	89 04 24             	mov    %eax,(%esp)
  801e4c:	e8 53 f1 ff ff       	call   800fa4 <fd2num>
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    
	...

00801e54 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
  801e59:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801e5c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e5f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e65:	e8 39 ed ff ff       	call   800ba3 <sys_getenvid>
  801e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e71:	8b 55 08             	mov    0x8(%ebp),%edx
  801e74:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e78:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e80:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  801e87:	e8 b8 e3 ff ff       	call   800244 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e90:	8b 45 10             	mov    0x10(%ebp),%eax
  801e93:	89 04 24             	mov    %eax,(%esp)
  801e96:	e8 48 e3 ff ff       	call   8001e3 <vcprintf>
	cprintf("\n");
  801e9b:	c7 04 24 70 22 80 00 	movl   $0x802270,(%esp)
  801ea2:	e8 9d e3 ff ff       	call   800244 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ea7:	cc                   	int3   
  801ea8:	eb fd                	jmp    801ea7 <_panic+0x53>
	...

00801eac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	57                   	push   %edi
  801eb0:	56                   	push   %esi
  801eb1:	53                   	push   %ebx
  801eb2:	83 ec 1c             	sub    $0x1c,%esp
  801eb5:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ebb:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801ebe:	85 db                	test   %ebx,%ebx
  801ec0:	75 05                	jne    801ec7 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801ec2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801ec7:	89 1c 24             	mov    %ebx,(%esp)
  801eca:	e8 28 ef ff ff       	call   800df7 <sys_ipc_recv>
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	79 16                	jns    801ee9 <ipc_recv+0x3d>
		*from_env_store = 0;
  801ed3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801ed9:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801edf:	89 1c 24             	mov    %ebx,(%esp)
  801ee2:	e8 10 ef ff ff       	call   800df7 <sys_ipc_recv>
  801ee7:	eb 24                	jmp    801f0d <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801ee9:	85 f6                	test   %esi,%esi
  801eeb:	74 0a                	je     801ef7 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801eed:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef2:	8b 40 74             	mov    0x74(%eax),%eax
  801ef5:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ef7:	85 ff                	test   %edi,%edi
  801ef9:	74 0a                	je     801f05 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801efb:	a1 04 40 80 00       	mov    0x804004,%eax
  801f00:	8b 40 78             	mov    0x78(%eax),%eax
  801f03:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801f05:	a1 04 40 80 00       	mov    0x804004,%eax
  801f0a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f0d:	83 c4 1c             	add    $0x1c,%esp
  801f10:	5b                   	pop    %ebx
  801f11:	5e                   	pop    %esi
  801f12:	5f                   	pop    %edi
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    

00801f15 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	57                   	push   %edi
  801f19:	56                   	push   %esi
  801f1a:	53                   	push   %ebx
  801f1b:	83 ec 1c             	sub    $0x1c,%esp
  801f1e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f24:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801f27:	85 db                	test   %ebx,%ebx
  801f29:	75 05                	jne    801f30 <ipc_send+0x1b>
		pg = (void *)-1;
  801f2b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f30:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f34:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3f:	89 04 24             	mov    %eax,(%esp)
  801f42:	e8 8d ee ff ff       	call   800dd4 <sys_ipc_try_send>
		if (r == 0) {		
  801f47:	85 c0                	test   %eax,%eax
  801f49:	74 2c                	je     801f77 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801f4b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f4e:	75 07                	jne    801f57 <ipc_send+0x42>
			sys_yield();
  801f50:	e8 6d ec ff ff       	call   800bc2 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801f55:	eb d9                	jmp    801f30 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f5b:	c7 44 24 08 f8 26 80 	movl   $0x8026f8,0x8(%esp)
  801f62:	00 
  801f63:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801f6a:	00 
  801f6b:	c7 04 24 06 27 80 00 	movl   $0x802706,(%esp)
  801f72:	e8 dd fe ff ff       	call   801e54 <_panic>
		}
	}
}
  801f77:	83 c4 1c             	add    $0x1c,%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	53                   	push   %ebx
  801f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f8b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f92:	89 c2                	mov    %eax,%edx
  801f94:	c1 e2 07             	shl    $0x7,%edx
  801f97:	29 ca                	sub    %ecx,%edx
  801f99:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f9f:	8b 52 50             	mov    0x50(%edx),%edx
  801fa2:	39 da                	cmp    %ebx,%edx
  801fa4:	75 0f                	jne    801fb5 <ipc_find_env+0x36>
			return envs[i].env_id;
  801fa6:	c1 e0 07             	shl    $0x7,%eax
  801fa9:	29 c8                	sub    %ecx,%eax
  801fab:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801fb0:	8b 40 40             	mov    0x40(%eax),%eax
  801fb3:	eb 0c                	jmp    801fc1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fb5:	40                   	inc    %eax
  801fb6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fbb:	75 ce                	jne    801f8b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fbd:	66 b8 00 00          	mov    $0x0,%ax
}
  801fc1:	5b                   	pop    %ebx
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fca:	89 c2                	mov    %eax,%edx
  801fcc:	c1 ea 16             	shr    $0x16,%edx
  801fcf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801fd6:	f6 c2 01             	test   $0x1,%dl
  801fd9:	74 1e                	je     801ff9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fdb:	c1 e8 0c             	shr    $0xc,%eax
  801fde:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fe5:	a8 01                	test   $0x1,%al
  801fe7:	74 17                	je     802000 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe9:	c1 e8 0c             	shr    $0xc,%eax
  801fec:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ff3:	ef 
  801ff4:	0f b7 c0             	movzwl %ax,%eax
  801ff7:	eb 0c                	jmp    802005 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ffe:	eb 05                	jmp    802005 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802000:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    
	...

00802008 <__udivdi3>:
  802008:	55                   	push   %ebp
  802009:	57                   	push   %edi
  80200a:	56                   	push   %esi
  80200b:	83 ec 10             	sub    $0x10,%esp
  80200e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802012:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802016:	89 74 24 04          	mov    %esi,0x4(%esp)
  80201a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80201e:	89 cd                	mov    %ecx,%ebp
  802020:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802024:	85 c0                	test   %eax,%eax
  802026:	75 2c                	jne    802054 <__udivdi3+0x4c>
  802028:	39 f9                	cmp    %edi,%ecx
  80202a:	77 68                	ja     802094 <__udivdi3+0x8c>
  80202c:	85 c9                	test   %ecx,%ecx
  80202e:	75 0b                	jne    80203b <__udivdi3+0x33>
  802030:	b8 01 00 00 00       	mov    $0x1,%eax
  802035:	31 d2                	xor    %edx,%edx
  802037:	f7 f1                	div    %ecx
  802039:	89 c1                	mov    %eax,%ecx
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	89 f8                	mov    %edi,%eax
  80203f:	f7 f1                	div    %ecx
  802041:	89 c7                	mov    %eax,%edi
  802043:	89 f0                	mov    %esi,%eax
  802045:	f7 f1                	div    %ecx
  802047:	89 c6                	mov    %eax,%esi
  802049:	89 f0                	mov    %esi,%eax
  80204b:	89 fa                	mov    %edi,%edx
  80204d:	83 c4 10             	add    $0x10,%esp
  802050:	5e                   	pop    %esi
  802051:	5f                   	pop    %edi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    
  802054:	39 f8                	cmp    %edi,%eax
  802056:	77 2c                	ja     802084 <__udivdi3+0x7c>
  802058:	0f bd f0             	bsr    %eax,%esi
  80205b:	83 f6 1f             	xor    $0x1f,%esi
  80205e:	75 4c                	jne    8020ac <__udivdi3+0xa4>
  802060:	39 f8                	cmp    %edi,%eax
  802062:	bf 00 00 00 00       	mov    $0x0,%edi
  802067:	72 0a                	jb     802073 <__udivdi3+0x6b>
  802069:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80206d:	0f 87 ad 00 00 00    	ja     802120 <__udivdi3+0x118>
  802073:	be 01 00 00 00       	mov    $0x1,%esi
  802078:	89 f0                	mov    %esi,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	5e                   	pop    %esi
  802080:	5f                   	pop    %edi
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    
  802083:	90                   	nop
  802084:	31 ff                	xor    %edi,%edi
  802086:	31 f6                	xor    %esi,%esi
  802088:	89 f0                	mov    %esi,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	5e                   	pop    %esi
  802090:	5f                   	pop    %edi
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    
  802093:	90                   	nop
  802094:	89 fa                	mov    %edi,%edx
  802096:	89 f0                	mov    %esi,%eax
  802098:	f7 f1                	div    %ecx
  80209a:	89 c6                	mov    %eax,%esi
  80209c:	31 ff                	xor    %edi,%edi
  80209e:	89 f0                	mov    %esi,%eax
  8020a0:	89 fa                	mov    %edi,%edx
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d 76 00             	lea    0x0(%esi),%esi
  8020ac:	89 f1                	mov    %esi,%ecx
  8020ae:	d3 e0                	shl    %cl,%eax
  8020b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020b4:	b8 20 00 00 00       	mov    $0x20,%eax
  8020b9:	29 f0                	sub    %esi,%eax
  8020bb:	89 ea                	mov    %ebp,%edx
  8020bd:	88 c1                	mov    %al,%cl
  8020bf:	d3 ea                	shr    %cl,%edx
  8020c1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8020c5:	09 ca                	or     %ecx,%edx
  8020c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020cb:	89 f1                	mov    %esi,%ecx
  8020cd:	d3 e5                	shl    %cl,%ebp
  8020cf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8020d3:	89 fd                	mov    %edi,%ebp
  8020d5:	88 c1                	mov    %al,%cl
  8020d7:	d3 ed                	shr    %cl,%ebp
  8020d9:	89 fa                	mov    %edi,%edx
  8020db:	89 f1                	mov    %esi,%ecx
  8020dd:	d3 e2                	shl    %cl,%edx
  8020df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8020e3:	88 c1                	mov    %al,%cl
  8020e5:	d3 ef                	shr    %cl,%edi
  8020e7:	09 d7                	or     %edx,%edi
  8020e9:	89 f8                	mov    %edi,%eax
  8020eb:	89 ea                	mov    %ebp,%edx
  8020ed:	f7 74 24 08          	divl   0x8(%esp)
  8020f1:	89 d1                	mov    %edx,%ecx
  8020f3:	89 c7                	mov    %eax,%edi
  8020f5:	f7 64 24 0c          	mull   0xc(%esp)
  8020f9:	39 d1                	cmp    %edx,%ecx
  8020fb:	72 17                	jb     802114 <__udivdi3+0x10c>
  8020fd:	74 09                	je     802108 <__udivdi3+0x100>
  8020ff:	89 fe                	mov    %edi,%esi
  802101:	31 ff                	xor    %edi,%edi
  802103:	e9 41 ff ff ff       	jmp    802049 <__udivdi3+0x41>
  802108:	8b 54 24 04          	mov    0x4(%esp),%edx
  80210c:	89 f1                	mov    %esi,%ecx
  80210e:	d3 e2                	shl    %cl,%edx
  802110:	39 c2                	cmp    %eax,%edx
  802112:	73 eb                	jae    8020ff <__udivdi3+0xf7>
  802114:	8d 77 ff             	lea    -0x1(%edi),%esi
  802117:	31 ff                	xor    %edi,%edi
  802119:	e9 2b ff ff ff       	jmp    802049 <__udivdi3+0x41>
  80211e:	66 90                	xchg   %ax,%ax
  802120:	31 f6                	xor    %esi,%esi
  802122:	e9 22 ff ff ff       	jmp    802049 <__udivdi3+0x41>
	...

00802128 <__umoddi3>:
  802128:	55                   	push   %ebp
  802129:	57                   	push   %edi
  80212a:	56                   	push   %esi
  80212b:	83 ec 20             	sub    $0x20,%esp
  80212e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802132:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802136:	89 44 24 14          	mov    %eax,0x14(%esp)
  80213a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80213e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802142:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802146:	89 c7                	mov    %eax,%edi
  802148:	89 f2                	mov    %esi,%edx
  80214a:	85 ed                	test   %ebp,%ebp
  80214c:	75 16                	jne    802164 <__umoddi3+0x3c>
  80214e:	39 f1                	cmp    %esi,%ecx
  802150:	0f 86 a6 00 00 00    	jbe    8021fc <__umoddi3+0xd4>
  802156:	f7 f1                	div    %ecx
  802158:	89 d0                	mov    %edx,%eax
  80215a:	31 d2                	xor    %edx,%edx
  80215c:	83 c4 20             	add    $0x20,%esp
  80215f:	5e                   	pop    %esi
  802160:	5f                   	pop    %edi
  802161:	5d                   	pop    %ebp
  802162:	c3                   	ret    
  802163:	90                   	nop
  802164:	39 f5                	cmp    %esi,%ebp
  802166:	0f 87 ac 00 00 00    	ja     802218 <__umoddi3+0xf0>
  80216c:	0f bd c5             	bsr    %ebp,%eax
  80216f:	83 f0 1f             	xor    $0x1f,%eax
  802172:	89 44 24 10          	mov    %eax,0x10(%esp)
  802176:	0f 84 a8 00 00 00    	je     802224 <__umoddi3+0xfc>
  80217c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802180:	d3 e5                	shl    %cl,%ebp
  802182:	bf 20 00 00 00       	mov    $0x20,%edi
  802187:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80218b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80218f:	89 f9                	mov    %edi,%ecx
  802191:	d3 e8                	shr    %cl,%eax
  802193:	09 e8                	or     %ebp,%eax
  802195:	89 44 24 18          	mov    %eax,0x18(%esp)
  802199:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80219d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021a1:	d3 e0                	shl    %cl,%eax
  8021a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021a7:	89 f2                	mov    %esi,%edx
  8021a9:	d3 e2                	shl    %cl,%edx
  8021ab:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021af:	d3 e0                	shl    %cl,%eax
  8021b1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8021b5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021b9:	89 f9                	mov    %edi,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 d0                	or     %edx,%eax
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	89 f2                	mov    %esi,%edx
  8021c3:	f7 74 24 18          	divl   0x18(%esp)
  8021c7:	89 d6                	mov    %edx,%esi
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	89 c5                	mov    %eax,%ebp
  8021cf:	89 d1                	mov    %edx,%ecx
  8021d1:	39 d6                	cmp    %edx,%esi
  8021d3:	72 67                	jb     80223c <__umoddi3+0x114>
  8021d5:	74 75                	je     80224c <__umoddi3+0x124>
  8021d7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8021db:	29 e8                	sub    %ebp,%eax
  8021dd:	19 ce                	sbb    %ecx,%esi
  8021df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021e3:	d3 e8                	shr    %cl,%eax
  8021e5:	89 f2                	mov    %esi,%edx
  8021e7:	89 f9                	mov    %edi,%ecx
  8021e9:	d3 e2                	shl    %cl,%edx
  8021eb:	09 d0                	or     %edx,%eax
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8021f3:	d3 ea                	shr    %cl,%edx
  8021f5:	83 c4 20             	add    $0x20,%esp
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	85 c9                	test   %ecx,%ecx
  8021fe:	75 0b                	jne    80220b <__umoddi3+0xe3>
  802200:	b8 01 00 00 00       	mov    $0x1,%eax
  802205:	31 d2                	xor    %edx,%edx
  802207:	f7 f1                	div    %ecx
  802209:	89 c1                	mov    %eax,%ecx
  80220b:	89 f0                	mov    %esi,%eax
  80220d:	31 d2                	xor    %edx,%edx
  80220f:	f7 f1                	div    %ecx
  802211:	89 f8                	mov    %edi,%eax
  802213:	e9 3e ff ff ff       	jmp    802156 <__umoddi3+0x2e>
  802218:	89 f2                	mov    %esi,%edx
  80221a:	83 c4 20             	add    $0x20,%esp
  80221d:	5e                   	pop    %esi
  80221e:	5f                   	pop    %edi
  80221f:	5d                   	pop    %ebp
  802220:	c3                   	ret    
  802221:	8d 76 00             	lea    0x0(%esi),%esi
  802224:	39 f5                	cmp    %esi,%ebp
  802226:	72 04                	jb     80222c <__umoddi3+0x104>
  802228:	39 f9                	cmp    %edi,%ecx
  80222a:	77 06                	ja     802232 <__umoddi3+0x10a>
  80222c:	89 f2                	mov    %esi,%edx
  80222e:	29 cf                	sub    %ecx,%edi
  802230:	19 ea                	sbb    %ebp,%edx
  802232:	89 f8                	mov    %edi,%eax
  802234:	83 c4 20             	add    $0x20,%esp
  802237:	5e                   	pop    %esi
  802238:	5f                   	pop    %edi
  802239:	5d                   	pop    %ebp
  80223a:	c3                   	ret    
  80223b:	90                   	nop
  80223c:	89 d1                	mov    %edx,%ecx
  80223e:	89 c5                	mov    %eax,%ebp
  802240:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802244:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802248:	eb 8d                	jmp    8021d7 <__umoddi3+0xaf>
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802250:	72 ea                	jb     80223c <__umoddi3+0x114>
  802252:	89 f1                	mov    %esi,%ecx
  802254:	eb 81                	jmp    8021d7 <__umoddi3+0xaf>
