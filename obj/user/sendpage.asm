
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 e0 0f 00 00       	call   80101f <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bb 00 00 00    	jne    800105 <umain+0xd1>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 3b 12 00 00       	call   8012a0 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  80007b:	e8 70 02 00 00       	call   8002f0 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 30 80 00       	mov    0x803004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 db 07 00 00       	call   800868 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 30 80 00       	mov    0x803004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 bd 08 00 00       	call   800963 <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  8000b1:	e8 3a 02 00 00       	call   8002f0 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 30 80 00       	mov    0x803000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 a5 07 00 00       	call   800868 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 30 80 00       	mov    0x803000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 a1 09 00 00       	call   800a7e <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 09 12 00 00       	call   801309 <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 04 40 80 00       	mov    0x804004,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 68 0b 00 00       	call   800c8d <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 30 80 00       	mov    0x803004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 36 07 00 00       	call   800868 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 30 80 00       	mov    0x803004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 32 09 00 00       	call   800a7e <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 9a 11 00 00       	call   801309 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 16 11 00 00       	call   8012a0 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  8001a0:	e8 4b 01 00 00       	call   8002f0 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 30 80 00       	mov    0x803000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 b6 06 00 00       	call   800868 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 30 80 00       	mov    0x803000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 98 07 00 00       	call   800963 <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 d4 24 80 00 	movl   $0x8024d4,(%esp)
  8001d6:	e8 15 01 00 00       	call   8002f0 <cprintf>
	return;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	00 00                	add    %al,(%eax)
	...

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8001ee:	e8 5c 0a 00 00       	call   800c4f <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ff:	c1 e0 07             	shl    $0x7,%eax
  800202:	29 d0                	sub    %edx,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 f6                	test   %esi,%esi
  800210:	7e 07                	jle    800219 <libmain+0x39>
		binaryname = argv[0];
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  800219:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021d:	89 34 24             	mov    %esi,(%esp)
  800220:	e8 0f fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800225:	e8 0a 00 00 00       	call   800234 <exit>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
  800231:	00 00                	add    %al,(%eax)
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80023a:	e8 60 13 00 00       	call   80159f <close_all>
	sys_env_destroy(0);
  80023f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800246:	e8 b2 09 00 00       	call   800bfd <sys_env_destroy>
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    
  80024d:	00 00                	add    %al,(%eax)
	...

00800250 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	53                   	push   %ebx
  800254:	83 ec 14             	sub    $0x14,%esp
  800257:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025a:	8b 03                	mov    (%ebx),%eax
  80025c:	8b 55 08             	mov    0x8(%ebp),%edx
  80025f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800263:	40                   	inc    %eax
  800264:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800266:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026b:	75 19                	jne    800286 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80026d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800274:	00 
  800275:	8d 43 08             	lea    0x8(%ebx),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 40 09 00 00       	call   800bc0 <sys_cputs>
		b->idx = 0;
  800280:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800286:	ff 43 04             	incl   0x4(%ebx)
}
  800289:	83 c4 14             	add    $0x14,%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800298:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80029f:	00 00 00 
	b.cnt = 0;
  8002a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	c7 04 24 50 02 80 00 	movl   $0x800250,(%esp)
  8002cb:	e8 82 01 00 00       	call   800452 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	e8 d8 08 00 00       	call   800bc0 <sys_cputs>

	return b.cnt;
}
  8002e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	e8 87 ff ff ff       	call   80028f <vcprintf>
	va_end(ap);

	return cnt;
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    
	...

0080030c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 3c             	sub    $0x3c,%esp
  800315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800318:	89 d7                	mov    %edx,%edi
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
  800323:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800326:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800329:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80032c:	85 c0                	test   %eax,%eax
  80032e:	75 08                	jne    800338 <printnum+0x2c>
  800330:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800333:	39 45 10             	cmp    %eax,0x10(%ebp)
  800336:	77 57                	ja     80038f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800338:	89 74 24 10          	mov    %esi,0x10(%esp)
  80033c:	4b                   	dec    %ebx
  80033d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80034c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800350:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800357:	00 
  800358:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035b:	89 04 24             	mov    %eax,(%esp)
  80035e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800361:	89 44 24 04          	mov    %eax,0x4(%esp)
  800365:	e8 d6 1e 00 00       	call   802240 <__udivdi3>
  80036a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80036e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800372:	89 04 24             	mov    %eax,(%esp)
  800375:	89 54 24 04          	mov    %edx,0x4(%esp)
  800379:	89 fa                	mov    %edi,%edx
  80037b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037e:	e8 89 ff ff ff       	call   80030c <printnum>
  800383:	eb 0f                	jmp    800394 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800385:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800389:	89 34 24             	mov    %esi,(%esp)
  80038c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80038f:	4b                   	dec    %ebx
  800390:	85 db                	test   %ebx,%ebx
  800392:	7f f1                	jg     800385 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800398:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80039c:	8b 45 10             	mov    0x10(%ebp),%eax
  80039f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003aa:	00 
  8003ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	e8 a3 1f 00 00       	call   802360 <__umoddi3>
  8003bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c1:	0f be 80 4c 25 80 00 	movsbl 0x80254c(%eax),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ce:	83 c4 3c             	add    $0x3c,%esp
  8003d1:	5b                   	pop    %ebx
  8003d2:	5e                   	pop    %esi
  8003d3:	5f                   	pop    %edi
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d9:	83 fa 01             	cmp    $0x1,%edx
  8003dc:	7e 0e                	jle    8003ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ea:	eb 22                	jmp    80040e <getuint+0x38>
	else if (lflag)
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	74 10                	je     800400 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f5:	89 08                	mov    %ecx,(%eax)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fe:	eb 0e                	jmp    80040e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 04             	lea    0x4(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800416:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	3b 50 04             	cmp    0x4(%eax),%edx
  80041e:	73 08                	jae    800428 <sprintputch+0x18>
		*b->buf++ = ch;
  800420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800423:	88 0a                	mov    %cl,(%edx)
  800425:	42                   	inc    %edx
  800426:	89 10                	mov    %edx,(%eax)
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800430:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	8b 45 10             	mov    0x10(%ebp),%eax
  80043a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	89 44 24 04          	mov    %eax,0x4(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 02 00 00 00       	call   800452 <vprintfmt>
	va_end(ap);
}
  800450:	c9                   	leave  
  800451:	c3                   	ret    

00800452 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	57                   	push   %edi
  800456:	56                   	push   %esi
  800457:	53                   	push   %ebx
  800458:	83 ec 4c             	sub    $0x4c,%esp
  80045b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045e:	8b 75 10             	mov    0x10(%ebp),%esi
  800461:	eb 12                	jmp    800475 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800463:	85 c0                	test   %eax,%eax
  800465:	0f 84 6b 03 00 00    	je     8007d6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80046b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800475:	0f b6 06             	movzbl (%esi),%eax
  800478:	46                   	inc    %esi
  800479:	83 f8 25             	cmp    $0x25,%eax
  80047c:	75 e5                	jne    800463 <vprintfmt+0x11>
  80047e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800482:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800489:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80048e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800495:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049a:	eb 26                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004a3:	eb 1d                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004ac:	eb 14                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b8:	eb 08                	jmp    8004c2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ba:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	0f b6 06             	movzbl (%esi),%eax
  8004c5:	8d 56 01             	lea    0x1(%esi),%edx
  8004c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004cb:	8a 16                	mov    (%esi),%dl
  8004cd:	83 ea 23             	sub    $0x23,%edx
  8004d0:	80 fa 55             	cmp    $0x55,%dl
  8004d3:	0f 87 e1 02 00 00    	ja     8007ba <vprintfmt+0x368>
  8004d9:	0f b6 d2             	movzbl %dl,%edx
  8004dc:	ff 24 95 80 26 80 00 	jmp    *0x802680(,%edx,4)
  8004e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004e6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004eb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ee:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004f2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004f5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f8:	83 fa 09             	cmp    $0x9,%edx
  8004fb:	77 2a                	ja     800527 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004fd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004fe:	eb eb                	jmp    8004eb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050e:	eb 17                	jmp    800527 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	78 98                	js     8004ae <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800519:	eb a7                	jmp    8004c2 <vprintfmt+0x70>
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800525:	eb 9b                	jmp    8004c2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052b:	79 95                	jns    8004c2 <vprintfmt+0x70>
  80052d:	eb 8b                	jmp    8004ba <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800533:	eb 8d                	jmp    8004c2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80054d:	e9 23 ff ff ff       	jmp    800475 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	85 c0                	test   %eax,%eax
  80055f:	79 02                	jns    800563 <vprintfmt+0x111>
  800561:	f7 d8                	neg    %eax
  800563:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800565:	83 f8 0f             	cmp    $0xf,%eax
  800568:	7f 0b                	jg     800575 <vprintfmt+0x123>
  80056a:	8b 04 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%eax
  800571:	85 c0                	test   %eax,%eax
  800573:	75 23                	jne    800598 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800575:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800579:	c7 44 24 08 64 25 80 	movl   $0x802564,0x8(%esp)
  800580:	00 
  800581:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800585:	8b 45 08             	mov    0x8(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	e8 9a fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800593:	e9 dd fe ff ff       	jmp    800475 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800598:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059c:	c7 44 24 08 62 2a 80 	movl   $0x802a62,0x8(%esp)
  8005a3:	00 
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ab:	89 14 24             	mov    %edx,(%esp)
  8005ae:	e8 77 fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b6:	e9 ba fe ff ff       	jmp    800475 <vprintfmt+0x23>
  8005bb:	89 f9                	mov    %edi,%ecx
  8005bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 04             	lea    0x4(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 30                	mov    (%eax),%esi
  8005ce:	85 f6                	test   %esi,%esi
  8005d0:	75 05                	jne    8005d7 <vprintfmt+0x185>
				p = "(null)";
  8005d2:	be 5d 25 80 00       	mov    $0x80255d,%esi
			if (width > 0 && padc != '-')
  8005d7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005db:	0f 8e 84 00 00 00    	jle    800665 <vprintfmt+0x213>
  8005e1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005e5:	74 7e                	je     800665 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005eb:	89 34 24             	mov    %esi,(%esp)
  8005ee:	e8 8b 02 00 00       	call   80087e <strnlen>
  8005f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005f6:	29 c2                	sub    %eax,%edx
  8005f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005fb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005ff:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800602:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800605:	89 de                	mov    %ebx,%esi
  800607:	89 d3                	mov    %edx,%ebx
  800609:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060b:	eb 0b                	jmp    800618 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80060d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800611:	89 3c 24             	mov    %edi,(%esp)
  800614:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800617:	4b                   	dec    %ebx
  800618:	85 db                	test   %ebx,%ebx
  80061a:	7f f1                	jg     80060d <vprintfmt+0x1bb>
  80061c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80061f:	89 f3                	mov    %esi,%ebx
  800621:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800627:	85 c0                	test   %eax,%eax
  800629:	79 05                	jns    800630 <vprintfmt+0x1de>
  80062b:	b8 00 00 00 00       	mov    $0x0,%eax
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800633:	29 c2                	sub    %eax,%edx
  800635:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800638:	eb 2b                	jmp    800665 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063e:	74 18                	je     800658 <vprintfmt+0x206>
  800640:	8d 50 e0             	lea    -0x20(%eax),%edx
  800643:	83 fa 5e             	cmp    $0x5e,%edx
  800646:	76 10                	jbe    800658 <vprintfmt+0x206>
					putch('?', putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
  800656:	eb 0a                	jmp    800662 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800662:	ff 4d e4             	decl   -0x1c(%ebp)
  800665:	0f be 06             	movsbl (%esi),%eax
  800668:	46                   	inc    %esi
  800669:	85 c0                	test   %eax,%eax
  80066b:	74 21                	je     80068e <vprintfmt+0x23c>
  80066d:	85 ff                	test   %edi,%edi
  80066f:	78 c9                	js     80063a <vprintfmt+0x1e8>
  800671:	4f                   	dec    %edi
  800672:	79 c6                	jns    80063a <vprintfmt+0x1e8>
  800674:	8b 7d 08             	mov    0x8(%ebp),%edi
  800677:	89 de                	mov    %ebx,%esi
  800679:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80067c:	eb 18                	jmp    800696 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800682:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800689:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068b:	4b                   	dec    %ebx
  80068c:	eb 08                	jmp    800696 <vprintfmt+0x244>
  80068e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800691:	89 de                	mov    %ebx,%esi
  800693:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800696:	85 db                	test   %ebx,%ebx
  800698:	7f e4                	jg     80067e <vprintfmt+0x22c>
  80069a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80069d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a2:	e9 ce fd ff ff       	jmp    800475 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a7:	83 f9 01             	cmp    $0x1,%ecx
  8006aa:	7e 10                	jle    8006bc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 08             	lea    0x8(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 30                	mov    (%eax),%esi
  8006b7:	8b 78 04             	mov    0x4(%eax),%edi
  8006ba:	eb 26                	jmp    8006e2 <vprintfmt+0x290>
	else if (lflag)
  8006bc:	85 c9                	test   %ecx,%ecx
  8006be:	74 12                	je     8006d2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 50 04             	lea    0x4(%eax),%edx
  8006c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c9:	8b 30                	mov    (%eax),%esi
  8006cb:	89 f7                	mov    %esi,%edi
  8006cd:	c1 ff 1f             	sar    $0x1f,%edi
  8006d0:	eb 10                	jmp    8006e2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006db:	8b 30                	mov    (%eax),%esi
  8006dd:	89 f7                	mov    %esi,%edi
  8006df:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e2:	85 ff                	test   %edi,%edi
  8006e4:	78 0a                	js     8006f0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006eb:	e9 8c 00 00 00       	jmp    80077c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006fe:	f7 de                	neg    %esi
  800700:	83 d7 00             	adc    $0x0,%edi
  800703:	f7 df                	neg    %edi
			}
			base = 10;
  800705:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070a:	eb 70                	jmp    80077c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070c:	89 ca                	mov    %ecx,%edx
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
  800711:	e8 c0 fc ff ff       	call   8003d6 <getuint>
  800716:	89 c6                	mov    %eax,%esi
  800718:	89 d7                	mov    %edx,%edi
			base = 10;
  80071a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80071f:	eb 5b                	jmp    80077c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800721:	89 ca                	mov    %ecx,%edx
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	e8 ab fc ff ff       	call   8003d6 <getuint>
  80072b:	89 c6                	mov    %eax,%esi
  80072d:	89 d7                	mov    %edx,%edi
			base = 8;
  80072f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800734:	eb 46                	jmp    80077c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8d 50 04             	lea    0x4(%eax),%edx
  800758:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075b:	8b 30                	mov    (%eax),%esi
  80075d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800762:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800767:	eb 13                	jmp    80077c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800769:	89 ca                	mov    %ecx,%edx
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	e8 63 fc ff ff       	call   8003d6 <getuint>
  800773:	89 c6                	mov    %eax,%esi
  800775:	89 d7                	mov    %edx,%edi
			base = 16;
  800777:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800780:	89 54 24 10          	mov    %edx,0x10(%esp)
  800784:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800787:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80078b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078f:	89 34 24             	mov    %esi,(%esp)
  800792:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800796:	89 da                	mov    %ebx,%edx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	e8 6c fb ff ff       	call   80030c <printnum>
			break;
  8007a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007a3:	e9 cd fc ff ff       	jmp    800475 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ac:	89 04 24             	mov    %eax,(%esp)
  8007af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b5:	e9 bb fc ff ff       	jmp    800475 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c8:	eb 01                	jmp    8007cb <vprintfmt+0x379>
  8007ca:	4e                   	dec    %esi
  8007cb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007cf:	75 f9                	jne    8007ca <vprintfmt+0x378>
  8007d1:	e9 9f fc ff ff       	jmp    800475 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007d6:	83 c4 4c             	add    $0x4c,%esp
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	5f                   	pop    %edi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	83 ec 28             	sub    $0x28,%esp
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fb:	85 c0                	test   %eax,%eax
  8007fd:	74 30                	je     80082f <vsnprintf+0x51>
  8007ff:	85 d2                	test   %edx,%edx
  800801:	7e 33                	jle    800836 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080a:	8b 45 10             	mov    0x10(%ebp),%eax
  80080d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800811:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	c7 04 24 10 04 80 00 	movl   $0x800410,(%esp)
  80081f:	e8 2e fc ff ff       	call   800452 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800824:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800827:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082d:	eb 0c                	jmp    80083b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800834:	eb 05                	jmp    80083b <vsnprintf+0x5d>
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800846:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084a:	8b 45 10             	mov    0x10(%ebp),%eax
  80084d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800851:	8b 45 0c             	mov    0xc(%ebp),%eax
  800854:	89 44 24 04          	mov    %eax,0x4(%esp)
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	89 04 24             	mov    %eax,(%esp)
  80085e:	e8 7b ff ff ff       	call   8007de <vsnprintf>
	va_end(ap);

	return rc;
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    
  800865:	00 00                	add    %al,(%eax)
	...

00800868 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
  800873:	eb 01                	jmp    800876 <strlen+0xe>
		n++;
  800875:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087a:	75 f9                	jne    800875 <strlen+0xd>
		n++;
	return n;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	eb 01                	jmp    80088f <strnlen+0x11>
		n++;
  80088e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088f:	39 d0                	cmp    %edx,%eax
  800891:	74 06                	je     800899 <strnlen+0x1b>
  800893:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800897:	75 f5                	jne    80088e <strnlen+0x10>
		n++;
	return n;
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008aa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b0:	42                   	inc    %edx
  8008b1:	84 c9                	test   %cl,%cl
  8008b3:	75 f5                	jne    8008aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	83 ec 08             	sub    $0x8,%esp
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c2:	89 1c 24             	mov    %ebx,(%esp)
  8008c5:	e8 9e ff ff ff       	call   800868 <strlen>
	strcpy(dst + len, src);
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d1:	01 d8                	add    %ebx,%eax
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	e8 c0 ff ff ff       	call   80089b <strcpy>
	return dst;
}
  8008db:	89 d8                	mov    %ebx,%eax
  8008dd:	83 c4 08             	add    $0x8,%esp
  8008e0:	5b                   	pop    %ebx
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f6:	eb 0c                	jmp    800904 <strncpy+0x21>
		*dst++ = *src;
  8008f8:	8a 1a                	mov    (%edx),%bl
  8008fa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008fd:	80 3a 01             	cmpb   $0x1,(%edx)
  800900:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800903:	41                   	inc    %ecx
  800904:	39 f1                	cmp    %esi,%ecx
  800906:	75 f0                	jne    8008f8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	8b 75 08             	mov    0x8(%ebp),%esi
  800914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800917:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091a:	85 d2                	test   %edx,%edx
  80091c:	75 0a                	jne    800928 <strlcpy+0x1c>
  80091e:	89 f0                	mov    %esi,%eax
  800920:	eb 1a                	jmp    80093c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800922:	88 18                	mov    %bl,(%eax)
  800924:	40                   	inc    %eax
  800925:	41                   	inc    %ecx
  800926:	eb 02                	jmp    80092a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800928:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80092a:	4a                   	dec    %edx
  80092b:	74 0a                	je     800937 <strlcpy+0x2b>
  80092d:	8a 19                	mov    (%ecx),%bl
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ef                	jne    800922 <strlcpy+0x16>
  800933:	89 c2                	mov    %eax,%edx
  800935:	eb 02                	jmp    800939 <strlcpy+0x2d>
  800937:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800939:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80093c:	29 f0                	sub    %esi,%eax
}
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094b:	eb 02                	jmp    80094f <strcmp+0xd>
		p++, q++;
  80094d:	41                   	inc    %ecx
  80094e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	8a 01                	mov    (%ecx),%al
  800951:	84 c0                	test   %al,%al
  800953:	74 04                	je     800959 <strcmp+0x17>
  800955:	3a 02                	cmp    (%edx),%al
  800957:	74 f4                	je     80094d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800959:	0f b6 c0             	movzbl %al,%eax
  80095c:	0f b6 12             	movzbl (%edx),%edx
  80095f:	29 d0                	sub    %edx,%eax
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800970:	eb 03                	jmp    800975 <strncmp+0x12>
		n--, p++, q++;
  800972:	4a                   	dec    %edx
  800973:	40                   	inc    %eax
  800974:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800975:	85 d2                	test   %edx,%edx
  800977:	74 14                	je     80098d <strncmp+0x2a>
  800979:	8a 18                	mov    (%eax),%bl
  80097b:	84 db                	test   %bl,%bl
  80097d:	74 04                	je     800983 <strncmp+0x20>
  80097f:	3a 19                	cmp    (%ecx),%bl
  800981:	74 ef                	je     800972 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800983:	0f b6 00             	movzbl (%eax),%eax
  800986:	0f b6 11             	movzbl (%ecx),%edx
  800989:	29 d0                	sub    %edx,%eax
  80098b:	eb 05                	jmp    800992 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80099e:	eb 05                	jmp    8009a5 <strchr+0x10>
		if (*s == c)
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	74 0c                	je     8009b0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a4:	40                   	inc    %eax
  8009a5:	8a 10                	mov    (%eax),%dl
  8009a7:	84 d2                	test   %dl,%dl
  8009a9:	75 f5                	jne    8009a0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009bb:	eb 05                	jmp    8009c2 <strfind+0x10>
		if (*s == c)
  8009bd:	38 ca                	cmp    %cl,%dl
  8009bf:	74 07                	je     8009c8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009c1:	40                   	inc    %eax
  8009c2:	8a 10                	mov    (%eax),%dl
  8009c4:	84 d2                	test   %dl,%dl
  8009c6:	75 f5                	jne    8009bd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d9:	85 c9                	test   %ecx,%ecx
  8009db:	74 30                	je     800a0d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e3:	75 25                	jne    800a0a <memset+0x40>
  8009e5:	f6 c1 03             	test   $0x3,%cl
  8009e8:	75 20                	jne    800a0a <memset+0x40>
		c &= 0xFF;
  8009ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ed:	89 d3                	mov    %edx,%ebx
  8009ef:	c1 e3 08             	shl    $0x8,%ebx
  8009f2:	89 d6                	mov    %edx,%esi
  8009f4:	c1 e6 18             	shl    $0x18,%esi
  8009f7:	89 d0                	mov    %edx,%eax
  8009f9:	c1 e0 10             	shl    $0x10,%eax
  8009fc:	09 f0                	or     %esi,%eax
  8009fe:	09 d0                	or     %edx,%eax
  800a00:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a02:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a05:	fc                   	cld    
  800a06:	f3 ab                	rep stos %eax,%es:(%edi)
  800a08:	eb 03                	jmp    800a0d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a22:	39 c6                	cmp    %eax,%esi
  800a24:	73 34                	jae    800a5a <memmove+0x46>
  800a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a29:	39 d0                	cmp    %edx,%eax
  800a2b:	73 2d                	jae    800a5a <memmove+0x46>
		s += n;
		d += n;
  800a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a30:	f6 c2 03             	test   $0x3,%dl
  800a33:	75 1b                	jne    800a50 <memmove+0x3c>
  800a35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3b:	75 13                	jne    800a50 <memmove+0x3c>
  800a3d:	f6 c1 03             	test   $0x3,%cl
  800a40:	75 0e                	jne    800a50 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a42:	83 ef 04             	sub    $0x4,%edi
  800a45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a48:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a4b:	fd                   	std    
  800a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4e:	eb 07                	jmp    800a57 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a50:	4f                   	dec    %edi
  800a51:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a54:	fd                   	std    
  800a55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a57:	fc                   	cld    
  800a58:	eb 20                	jmp    800a7a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a60:	75 13                	jne    800a75 <memmove+0x61>
  800a62:	a8 03                	test   $0x3,%al
  800a64:	75 0f                	jne    800a75 <memmove+0x61>
  800a66:	f6 c1 03             	test   $0x3,%cl
  800a69:	75 0a                	jne    800a75 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a6e:	89 c7                	mov    %eax,%edi
  800a70:	fc                   	cld    
  800a71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a73:	eb 05                	jmp    800a7a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a75:	89 c7                	mov    %eax,%edi
  800a77:	fc                   	cld    
  800a78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a84:	8b 45 10             	mov    0x10(%ebp),%eax
  800a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	89 04 24             	mov    %eax,(%esp)
  800a98:	e8 77 ff ff ff       	call   800a14 <memmove>
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aae:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab3:	eb 16                	jmp    800acb <memcmp+0x2c>
		if (*s1 != *s2)
  800ab5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ab8:	42                   	inc    %edx
  800ab9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800abd:	38 c8                	cmp    %cl,%al
  800abf:	74 0a                	je     800acb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ac1:	0f b6 c0             	movzbl %al,%eax
  800ac4:	0f b6 c9             	movzbl %cl,%ecx
  800ac7:	29 c8                	sub    %ecx,%eax
  800ac9:	eb 09                	jmp    800ad4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acb:	39 da                	cmp    %ebx,%edx
  800acd:	75 e6                	jne    800ab5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae7:	eb 05                	jmp    800aee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae9:	38 08                	cmp    %cl,(%eax)
  800aeb:	74 05                	je     800af2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aed:	40                   	inc    %eax
  800aee:	39 d0                	cmp    %edx,%eax
  800af0:	72 f7                	jb     800ae9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b00:	eb 01                	jmp    800b03 <strtol+0xf>
		s++;
  800b02:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b03:	8a 02                	mov    (%edx),%al
  800b05:	3c 20                	cmp    $0x20,%al
  800b07:	74 f9                	je     800b02 <strtol+0xe>
  800b09:	3c 09                	cmp    $0x9,%al
  800b0b:	74 f5                	je     800b02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0d:	3c 2b                	cmp    $0x2b,%al
  800b0f:	75 08                	jne    800b19 <strtol+0x25>
		s++;
  800b11:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b12:	bf 00 00 00 00       	mov    $0x0,%edi
  800b17:	eb 13                	jmp    800b2c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b19:	3c 2d                	cmp    $0x2d,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x33>
		s++, neg = 1;
  800b1d:	8d 52 01             	lea    0x1(%edx),%edx
  800b20:	bf 01 00 00 00       	mov    $0x1,%edi
  800b25:	eb 05                	jmp    800b2c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2c:	85 db                	test   %ebx,%ebx
  800b2e:	74 05                	je     800b35 <strtol+0x41>
  800b30:	83 fb 10             	cmp    $0x10,%ebx
  800b33:	75 28                	jne    800b5d <strtol+0x69>
  800b35:	8a 02                	mov    (%edx),%al
  800b37:	3c 30                	cmp    $0x30,%al
  800b39:	75 10                	jne    800b4b <strtol+0x57>
  800b3b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b3f:	75 0a                	jne    800b4b <strtol+0x57>
		s += 2, base = 16;
  800b41:	83 c2 02             	add    $0x2,%edx
  800b44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b49:	eb 12                	jmp    800b5d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b4b:	85 db                	test   %ebx,%ebx
  800b4d:	75 0e                	jne    800b5d <strtol+0x69>
  800b4f:	3c 30                	cmp    $0x30,%al
  800b51:	75 05                	jne    800b58 <strtol+0x64>
		s++, base = 8;
  800b53:	42                   	inc    %edx
  800b54:	b3 08                	mov    $0x8,%bl
  800b56:	eb 05                	jmp    800b5d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b58:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b62:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b64:	8a 0a                	mov    (%edx),%cl
  800b66:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b69:	80 fb 09             	cmp    $0x9,%bl
  800b6c:	77 08                	ja     800b76 <strtol+0x82>
			dig = *s - '0';
  800b6e:	0f be c9             	movsbl %cl,%ecx
  800b71:	83 e9 30             	sub    $0x30,%ecx
  800b74:	eb 1e                	jmp    800b94 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b76:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b79:	80 fb 19             	cmp    $0x19,%bl
  800b7c:	77 08                	ja     800b86 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b7e:	0f be c9             	movsbl %cl,%ecx
  800b81:	83 e9 57             	sub    $0x57,%ecx
  800b84:	eb 0e                	jmp    800b94 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b86:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b89:	80 fb 19             	cmp    $0x19,%bl
  800b8c:	77 12                	ja     800ba0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b8e:	0f be c9             	movsbl %cl,%ecx
  800b91:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b94:	39 f1                	cmp    %esi,%ecx
  800b96:	7d 0c                	jge    800ba4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b98:	42                   	inc    %edx
  800b99:	0f af c6             	imul   %esi,%eax
  800b9c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b9e:	eb c4                	jmp    800b64 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ba0:	89 c1                	mov    %eax,%ecx
  800ba2:	eb 02                	jmp    800ba6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800baa:	74 05                	je     800bb1 <strtol+0xbd>
		*endptr = (char *) s;
  800bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800baf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bb1:	85 ff                	test   %edi,%edi
  800bb3:	74 04                	je     800bb9 <strtol+0xc5>
  800bb5:	89 c8                	mov    %ecx,%eax
  800bb7:	f7 d8                	neg    %eax
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    
	...

00800bc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	89 c3                	mov    %eax,%ebx
  800bd3:	89 c7                	mov    %eax,%edi
  800bd5:	89 c6                	mov    %eax,%esi
  800bd7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_cgetc>:

int
sys_cgetc(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	89 cb                	mov    %ecx,%ebx
  800c15:	89 cf                	mov    %ecx,%edi
  800c17:	89 ce                	mov    %ecx,%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 28                	jle    800c47 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c23:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800c32:	00 
  800c33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3a:	00 
  800c3b:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800c42:	e8 e9 14 00 00       	call   802130 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c47:	83 c4 2c             	add    $0x2c,%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5f:	89 d1                	mov    %edx,%ecx
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	89 d6                	mov    %edx,%esi
  800c67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_yield>:

void
sys_yield(void)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	ba 00 00 00 00       	mov    $0x0,%edx
  800c79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	89 d7                	mov    %edx,%edi
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	be 00 00 00 00       	mov    $0x0,%esi
  800c9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 f7                	mov    %esi,%edi
  800cab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 28                	jle    800cd9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800cc4:	00 
  800cc5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ccc:	00 
  800ccd:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800cd4:	e8 57 14 00 00       	call   802130 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd9:	83 c4 2c             	add    $0x2c,%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800cea:	b8 05 00 00 00       	mov    $0x5,%eax
  800cef:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7e 28                	jle    800d2c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d08:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d0f:	00 
  800d10:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800d17:	00 
  800d18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1f:	00 
  800d20:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800d27:	e8 04 14 00 00       	call   802130 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2c:	83 c4 2c             	add    $0x2c,%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d42:	b8 06 00 00 00       	mov    $0x6,%eax
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	89 df                	mov    %ebx,%edi
  800d4f:	89 de                	mov    %ebx,%esi
  800d51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 28                	jle    800d7f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d62:	00 
  800d63:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800d7a:	e8 b1 13 00 00       	call   802130 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7f:	83 c4 2c             	add    $0x2c,%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d95:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	89 df                	mov    %ebx,%edi
  800da2:	89 de                	mov    %ebx,%esi
  800da4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da6:	85 c0                	test   %eax,%eax
  800da8:	7e 28                	jle    800dd2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800db5:	00 
  800db6:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800dbd:	00 
  800dbe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc5:	00 
  800dc6:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800dcd:	e8 5e 13 00 00       	call   802130 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd2:	83 c4 2c             	add    $0x2c,%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 df                	mov    %ebx,%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7e 28                	jle    800e25 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e01:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e08:	00 
  800e09:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800e10:	00 
  800e11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e18:	00 
  800e19:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800e20:	e8 0b 13 00 00       	call   802130 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e25:	83 c4 2c             	add    $0x2c,%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 28                	jle    800e78 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e54:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800e63:	00 
  800e64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6b:	00 
  800e6c:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800e73:	e8 b8 12 00 00       	call   802130 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e78:	83 c4 2c             	add    $0x2c,%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e86:	be 00 00 00 00       	mov    $0x0,%esi
  800e8b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e90:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	89 cb                	mov    %ecx,%ebx
  800ebb:	89 cf                	mov    %ecx,%edi
  800ebd:	89 ce                	mov    %ecx,%esi
  800ebf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	7e 28                	jle    800eed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800ee8:	e8 43 12 00 00       	call   802130 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eed:	83 c4 2c             	add    $0x2c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	00 00                	add    %al,(%eax)
	...

00800ef8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	53                   	push   %ebx
  800efc:	83 ec 24             	sub    $0x24,%esp
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f02:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800f04:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f08:	75 2d                	jne    800f37 <pgfault+0x3f>
  800f0a:	89 d8                	mov    %ebx,%eax
  800f0c:	c1 e8 0c             	shr    $0xc,%eax
  800f0f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f16:	f6 c4 08             	test   $0x8,%ah
  800f19:	75 1c                	jne    800f37 <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800f1b:	c7 44 24 08 6c 28 80 	movl   $0x80286c,0x8(%esp)
  800f22:	00 
  800f23:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800f2a:	00 
  800f2b:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  800f32:	e8 f9 11 00 00       	call   802130 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f37:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f4e:	e8 3a fd ff ff       	call   800c8d <sys_page_alloc>
  800f53:	85 c0                	test   %eax,%eax
  800f55:	79 20                	jns    800f77 <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800f57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f5b:	c7 44 24 08 db 28 80 	movl   $0x8028db,0x8(%esp)
  800f62:	00 
  800f63:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f6a:	00 
  800f6b:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  800f72:	e8 b9 11 00 00       	call   802130 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  800f77:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800f7d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f84:	00 
  800f85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f89:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f90:	e8 e9 fa ff ff       	call   800a7e <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f95:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f9c:	00 
  800f9d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fa1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fb0:	00 
  800fb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fb8:	e8 24 fd ff ff       	call   800ce1 <sys_page_map>
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	79 20                	jns    800fe1 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  800fc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc5:	c7 44 24 08 ee 28 80 	movl   $0x8028ee,0x8(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800fd4:	00 
  800fd5:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  800fdc:	e8 4f 11 00 00       	call   802130 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fe1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe8:	00 
  800fe9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff0:	e8 3f fd ff ff       	call   800d34 <sys_page_unmap>
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 20                	jns    801019 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  800ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ffd:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  801014:	e8 17 11 00 00       	call   802130 <_panic>
}
  801019:	83 c4 24             	add    $0x24,%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  801028:	c7 04 24 f8 0e 80 00 	movl   $0x800ef8,(%esp)
  80102f:	e8 54 11 00 00       	call   802188 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801034:	ba 07 00 00 00       	mov    $0x7,%edx
  801039:	89 d0                	mov    %edx,%eax
  80103b:	cd 30                	int    $0x30
  80103d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801040:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  801043:	85 c0                	test   %eax,%eax
  801045:	79 1c                	jns    801063 <fork+0x44>
		panic("sys_exofork failed\n");
  801047:	c7 44 24 08 12 29 80 	movl   $0x802912,0x8(%esp)
  80104e:	00 
  80104f:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801056:	00 
  801057:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  80105e:	e8 cd 10 00 00       	call   802130 <_panic>
	if(c_envid == 0){
  801063:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801067:	75 25                	jne    80108e <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  801069:	e8 e1 fb ff ff       	call   800c4f <sys_getenvid>
  80106e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801073:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80107a:	c1 e0 07             	shl    $0x7,%eax
  80107d:	29 d0                	sub    %edx,%eax
  80107f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801084:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801089:	e9 e3 01 00 00       	jmp    801271 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  80108e:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  801093:	89 d8                	mov    %ebx,%eax
  801095:	c1 e8 16             	shr    $0x16,%eax
  801098:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109f:	a8 01                	test   $0x1,%al
  8010a1:	0f 84 0b 01 00 00    	je     8011b2 <fork+0x193>
  8010a7:	89 de                	mov    %ebx,%esi
  8010a9:	c1 ee 0c             	shr    $0xc,%esi
  8010ac:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b3:	a8 05                	test   $0x5,%al
  8010b5:	0f 84 f7 00 00 00    	je     8011b2 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  8010bb:	89 f7                	mov    %esi,%edi
  8010bd:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  8010c0:	e8 8a fb ff ff       	call   800c4f <sys_getenvid>
  8010c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  8010c8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010cf:	a8 02                	test   $0x2,%al
  8010d1:	75 10                	jne    8010e3 <fork+0xc4>
  8010d3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010da:	f6 c4 08             	test   $0x8,%ah
  8010dd:	0f 84 89 00 00 00    	je     80116c <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  8010e3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010ea:	00 
  8010eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010fd:	89 04 24             	mov    %eax,(%esp)
  801100:	e8 dc fb ff ff       	call   800ce1 <sys_page_map>
  801105:	85 c0                	test   %eax,%eax
  801107:	79 20                	jns    801129 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80110d:	c7 44 24 08 26 29 80 	movl   $0x802926,0x8(%esp)
  801114:	00 
  801115:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  80111c:	00 
  80111d:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  801124:	e8 07 10 00 00       	call   802130 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  801129:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801130:	00 
  801131:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801138:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801140:	89 04 24             	mov    %eax,(%esp)
  801143:	e8 99 fb ff ff       	call   800ce1 <sys_page_map>
  801148:	85 c0                	test   %eax,%eax
  80114a:	79 66                	jns    8011b2 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  80114c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801150:	c7 44 24 08 26 29 80 	movl   $0x802926,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  80115f:	00 
  801160:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  801167:	e8 c4 0f 00 00       	call   802130 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  80116c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801173:	00 
  801174:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801178:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80117b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801183:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801186:	89 04 24             	mov    %eax,(%esp)
  801189:	e8 53 fb ff ff       	call   800ce1 <sys_page_map>
  80118e:	85 c0                	test   %eax,%eax
  801190:	79 20                	jns    8011b2 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  801192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801196:	c7 44 24 08 26 29 80 	movl   $0x802926,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  8011ad:	e8 7e 0f 00 00       	call   802130 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  8011b2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011b8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011be:	0f 85 cf fe ff ff    	jne    801093 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  8011c4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011cb:	00 
  8011cc:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011d3:	ee 
  8011d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011d7:	89 04 24             	mov    %eax,(%esp)
  8011da:	e8 ae fa ff ff       	call   800c8d <sys_page_alloc>
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	79 20                	jns    801203 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  8011e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e7:	c7 44 24 08 38 29 80 	movl   $0x802938,0x8(%esp)
  8011ee:	00 
  8011ef:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8011f6:	00 
  8011f7:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  8011fe:	e8 2d 0f 00 00       	call   802130 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801203:	c7 44 24 04 d4 21 80 	movl   $0x8021d4,0x4(%esp)
  80120a:	00 
  80120b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80120e:	89 04 24             	mov    %eax,(%esp)
  801211:	e8 17 fc ff ff       	call   800e2d <sys_env_set_pgfault_upcall>
  801216:	85 c0                	test   %eax,%eax
  801218:	79 20                	jns    80123a <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80121a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121e:	c7 44 24 08 b0 28 80 	movl   $0x8028b0,0x8(%esp)
  801225:	00 
  801226:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80122d:	00 
  80122e:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  801235:	e8 f6 0e 00 00       	call   802130 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  80123a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801241:	00 
  801242:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801245:	89 04 24             	mov    %eax,(%esp)
  801248:	e8 3a fb ff ff       	call   800d87 <sys_env_set_status>
  80124d:	85 c0                	test   %eax,%eax
  80124f:	79 20                	jns    801271 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  801251:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801255:	c7 44 24 08 4c 29 80 	movl   $0x80294c,0x8(%esp)
  80125c:	00 
  80125d:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801264:	00 
  801265:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  80126c:	e8 bf 0e 00 00       	call   802130 <_panic>
 
	return c_envid;	
}
  801271:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801274:	83 c4 3c             	add    $0x3c,%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5f                   	pop    %edi
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <sfork>:

// Challenge!
int
sfork(void)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801282:	c7 44 24 08 64 29 80 	movl   $0x802964,0x8(%esp)
  801289:	00 
  80128a:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801291:	00 
  801292:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  801299:	e8 92 0e 00 00       	call   802130 <_panic>
	...

008012a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 1c             	sub    $0x1c,%esp
  8012a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012af:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8012b2:	85 db                	test   %ebx,%ebx
  8012b4:	75 05                	jne    8012bb <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8012b6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8012bb:	89 1c 24             	mov    %ebx,(%esp)
  8012be:	e8 e0 fb ff ff       	call   800ea3 <sys_ipc_recv>
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	79 16                	jns    8012dd <ipc_recv+0x3d>
		*from_env_store = 0;
  8012c7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8012cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  8012d3:	89 1c 24             	mov    %ebx,(%esp)
  8012d6:	e8 c8 fb ff ff       	call   800ea3 <sys_ipc_recv>
  8012db:	eb 24                	jmp    801301 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  8012dd:	85 f6                	test   %esi,%esi
  8012df:	74 0a                	je     8012eb <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8012e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012e6:	8b 40 74             	mov    0x74(%eax),%eax
  8012e9:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8012eb:	85 ff                	test   %edi,%edi
  8012ed:	74 0a                	je     8012f9 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8012ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f4:	8b 40 78             	mov    0x78(%eax),%eax
  8012f7:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8012f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012fe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801301:	83 c4 1c             	add    $0x1c,%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	57                   	push   %edi
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
  80130f:	83 ec 1c             	sub    $0x1c,%esp
  801312:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801315:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801318:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80131b:	85 db                	test   %ebx,%ebx
  80131d:	75 05                	jne    801324 <ipc_send+0x1b>
		pg = (void *)-1;
  80131f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801324:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801328:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80132c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	89 04 24             	mov    %eax,(%esp)
  801336:	e8 45 fb ff ff       	call   800e80 <sys_ipc_try_send>
		if (r == 0) {		
  80133b:	85 c0                	test   %eax,%eax
  80133d:	74 2c                	je     80136b <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80133f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801342:	75 07                	jne    80134b <ipc_send+0x42>
			sys_yield();
  801344:	e8 25 f9 ff ff       	call   800c6e <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801349:	eb d9                	jmp    801324 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80134b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134f:	c7 44 24 08 7a 29 80 	movl   $0x80297a,0x8(%esp)
  801356:	00 
  801357:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80135e:	00 
  80135f:	c7 04 24 88 29 80 00 	movl   $0x802988,(%esp)
  801366:	e8 c5 0d 00 00       	call   802130 <_panic>
		}
	}
}
  80136b:	83 c4 1c             	add    $0x1c,%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80137f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801386:	89 c2                	mov    %eax,%edx
  801388:	c1 e2 07             	shl    $0x7,%edx
  80138b:	29 ca                	sub    %ecx,%edx
  80138d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801393:	8b 52 50             	mov    0x50(%edx),%edx
  801396:	39 da                	cmp    %ebx,%edx
  801398:	75 0f                	jne    8013a9 <ipc_find_env+0x36>
			return envs[i].env_id;
  80139a:	c1 e0 07             	shl    $0x7,%eax
  80139d:	29 c8                	sub    %ecx,%eax
  80139f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013a4:	8b 40 40             	mov    0x40(%eax),%eax
  8013a7:	eb 0c                	jmp    8013b5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013a9:	40                   	inc    %eax
  8013aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013af:	75 ce                	jne    80137f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013b1:	66 b8 00 00          	mov    $0x0,%ax
}
  8013b5:	5b                   	pop    %ebx
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 df ff ff ff       	call   8013b8 <fd2num>
  8013d9:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013de:	c1 e0 0c             	shl    $0xc,%eax
}
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	53                   	push   %ebx
  8013e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013ea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013ef:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	c1 ea 16             	shr    $0x16,%edx
  8013f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fd:	f6 c2 01             	test   $0x1,%dl
  801400:	74 11                	je     801413 <fd_alloc+0x30>
  801402:	89 c2                	mov    %eax,%edx
  801404:	c1 ea 0c             	shr    $0xc,%edx
  801407:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140e:	f6 c2 01             	test   $0x1,%dl
  801411:	75 09                	jne    80141c <fd_alloc+0x39>
			*fd_store = fd;
  801413:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801415:	b8 00 00 00 00       	mov    $0x0,%eax
  80141a:	eb 17                	jmp    801433 <fd_alloc+0x50>
  80141c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801421:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801426:	75 c7                	jne    8013ef <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801428:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80142e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801433:	5b                   	pop    %ebx
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80143c:	83 f8 1f             	cmp    $0x1f,%eax
  80143f:	77 36                	ja     801477 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801441:	05 00 00 0d 00       	add    $0xd0000,%eax
  801446:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801449:	89 c2                	mov    %eax,%edx
  80144b:	c1 ea 16             	shr    $0x16,%edx
  80144e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801455:	f6 c2 01             	test   $0x1,%dl
  801458:	74 24                	je     80147e <fd_lookup+0x48>
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	c1 ea 0c             	shr    $0xc,%edx
  80145f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801466:	f6 c2 01             	test   $0x1,%dl
  801469:	74 1a                	je     801485 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80146b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146e:	89 02                	mov    %eax,(%edx)
	return 0;
  801470:	b8 00 00 00 00       	mov    $0x0,%eax
  801475:	eb 13                	jmp    80148a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801477:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147c:	eb 0c                	jmp    80148a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80147e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801483:	eb 05                	jmp    80148a <fd_lookup+0x54>
  801485:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	53                   	push   %ebx
  801490:	83 ec 14             	sub    $0x14,%esp
  801493:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801496:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801499:	ba 00 00 00 00       	mov    $0x0,%edx
  80149e:	eb 0e                	jmp    8014ae <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8014a0:	39 08                	cmp    %ecx,(%eax)
  8014a2:	75 09                	jne    8014ad <dev_lookup+0x21>
			*dev = devtab[i];
  8014a4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ab:	eb 33                	jmp    8014e0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ad:	42                   	inc    %edx
  8014ae:	8b 04 95 10 2a 80 00 	mov    0x802a10(,%edx,4),%eax
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	75 e7                	jne    8014a0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014be:	8b 40 48             	mov    0x48(%eax),%eax
  8014c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	c7 04 24 94 29 80 00 	movl   $0x802994,(%esp)
  8014d0:	e8 1b ee ff ff       	call   8002f0 <cprintf>
	*dev = 0;
  8014d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014e0:	83 c4 14             	add    $0x14,%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    

008014e6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 30             	sub    $0x30,%esp
  8014ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f1:	8a 45 0c             	mov    0xc(%ebp),%al
  8014f4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014f7:	89 34 24             	mov    %esi,(%esp)
  8014fa:	e8 b9 fe ff ff       	call   8013b8 <fd2num>
  8014ff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801502:	89 54 24 04          	mov    %edx,0x4(%esp)
  801506:	89 04 24             	mov    %eax,(%esp)
  801509:	e8 28 ff ff ff       	call   801436 <fd_lookup>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	85 c0                	test   %eax,%eax
  801512:	78 05                	js     801519 <fd_close+0x33>
	    || fd != fd2)
  801514:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801517:	74 0d                	je     801526 <fd_close+0x40>
		return (must_exist ? r : 0);
  801519:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80151d:	75 46                	jne    801565 <fd_close+0x7f>
  80151f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801524:	eb 3f                	jmp    801565 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801526:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	8b 06                	mov    (%esi),%eax
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	e8 55 ff ff ff       	call   80148c <dev_lookup>
  801537:	89 c3                	mov    %eax,%ebx
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 18                	js     801555 <fd_close+0x6f>
		if (dev->dev_close)
  80153d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801540:	8b 40 10             	mov    0x10(%eax),%eax
  801543:	85 c0                	test   %eax,%eax
  801545:	74 09                	je     801550 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801547:	89 34 24             	mov    %esi,(%esp)
  80154a:	ff d0                	call   *%eax
  80154c:	89 c3                	mov    %eax,%ebx
  80154e:	eb 05                	jmp    801555 <fd_close+0x6f>
		else
			r = 0;
  801550:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801555:	89 74 24 04          	mov    %esi,0x4(%esp)
  801559:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801560:	e8 cf f7 ff ff       	call   800d34 <sys_page_unmap>
	return r;
}
  801565:	89 d8                	mov    %ebx,%eax
  801567:	83 c4 30             	add    $0x30,%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801574:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801577:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157b:	8b 45 08             	mov    0x8(%ebp),%eax
  80157e:	89 04 24             	mov    %eax,(%esp)
  801581:	e8 b0 fe ff ff       	call   801436 <fd_lookup>
  801586:	85 c0                	test   %eax,%eax
  801588:	78 13                	js     80159d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80158a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801591:	00 
  801592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	e8 49 ff ff ff       	call   8014e6 <fd_close>
}
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <close_all>:

void
close_all(void)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015ab:	89 1c 24             	mov    %ebx,(%esp)
  8015ae:	e8 bb ff ff ff       	call   80156e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b3:	43                   	inc    %ebx
  8015b4:	83 fb 20             	cmp    $0x20,%ebx
  8015b7:	75 f2                	jne    8015ab <close_all+0xc>
		close(i);
}
  8015b9:	83 c4 14             	add    $0x14,%esp
  8015bc:	5b                   	pop    %ebx
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    

008015bf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	57                   	push   %edi
  8015c3:	56                   	push   %esi
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 4c             	sub    $0x4c,%esp
  8015c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d5:	89 04 24             	mov    %eax,(%esp)
  8015d8:	e8 59 fe ff ff       	call   801436 <fd_lookup>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	0f 88 e1 00 00 00    	js     8016c8 <dup+0x109>
		return r;
	close(newfdnum);
  8015e7:	89 3c 24             	mov    %edi,(%esp)
  8015ea:	e8 7f ff ff ff       	call   80156e <close>

	newfd = INDEX2FD(newfdnum);
  8015ef:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015f5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fb:	89 04 24             	mov    %eax,(%esp)
  8015fe:	e8 c5 fd ff ff       	call   8013c8 <fd2data>
  801603:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801605:	89 34 24             	mov    %esi,(%esp)
  801608:	e8 bb fd ff ff       	call   8013c8 <fd2data>
  80160d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801610:	89 d8                	mov    %ebx,%eax
  801612:	c1 e8 16             	shr    $0x16,%eax
  801615:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80161c:	a8 01                	test   $0x1,%al
  80161e:	74 46                	je     801666 <dup+0xa7>
  801620:	89 d8                	mov    %ebx,%eax
  801622:	c1 e8 0c             	shr    $0xc,%eax
  801625:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80162c:	f6 c2 01             	test   $0x1,%dl
  80162f:	74 35                	je     801666 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801631:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801638:	25 07 0e 00 00       	and    $0xe07,%eax
  80163d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801641:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801644:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801648:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164f:	00 
  801650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165b:	e8 81 f6 ff ff       	call   800ce1 <sys_page_map>
  801660:	89 c3                	mov    %eax,%ebx
  801662:	85 c0                	test   %eax,%eax
  801664:	78 3b                	js     8016a1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801666:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801669:	89 c2                	mov    %eax,%edx
  80166b:	c1 ea 0c             	shr    $0xc,%edx
  80166e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801675:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80167b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80167f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801683:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80168a:	00 
  80168b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801696:	e8 46 f6 ff ff       	call   800ce1 <sys_page_map>
  80169b:	89 c3                	mov    %eax,%ebx
  80169d:	85 c0                	test   %eax,%eax
  80169f:	79 25                	jns    8016c6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ac:	e8 83 f6 ff ff       	call   800d34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bf:	e8 70 f6 ff ff       	call   800d34 <sys_page_unmap>
	return r;
  8016c4:	eb 02                	jmp    8016c8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016c6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016c8:	89 d8                	mov    %ebx,%eax
  8016ca:	83 c4 4c             	add    $0x4c,%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	53                   	push   %ebx
  8016d6:	83 ec 24             	sub    $0x24,%esp
  8016d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e3:	89 1c 24             	mov    %ebx,(%esp)
  8016e6:	e8 4b fd ff ff       	call   801436 <fd_lookup>
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 6d                	js     80175c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	8b 00                	mov    (%eax),%eax
  8016fb:	89 04 24             	mov    %eax,(%esp)
  8016fe:	e8 89 fd ff ff       	call   80148c <dev_lookup>
  801703:	85 c0                	test   %eax,%eax
  801705:	78 55                	js     80175c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801707:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170a:	8b 50 08             	mov    0x8(%eax),%edx
  80170d:	83 e2 03             	and    $0x3,%edx
  801710:	83 fa 01             	cmp    $0x1,%edx
  801713:	75 23                	jne    801738 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801715:	a1 04 40 80 00       	mov    0x804004,%eax
  80171a:	8b 40 48             	mov    0x48(%eax),%eax
  80171d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801721:	89 44 24 04          	mov    %eax,0x4(%esp)
  801725:	c7 04 24 d5 29 80 00 	movl   $0x8029d5,(%esp)
  80172c:	e8 bf eb ff ff       	call   8002f0 <cprintf>
		return -E_INVAL;
  801731:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801736:	eb 24                	jmp    80175c <read+0x8a>
	}
	if (!dev->dev_read)
  801738:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173b:	8b 52 08             	mov    0x8(%edx),%edx
  80173e:	85 d2                	test   %edx,%edx
  801740:	74 15                	je     801757 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801742:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801745:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801749:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801750:	89 04 24             	mov    %eax,(%esp)
  801753:	ff d2                	call   *%edx
  801755:	eb 05                	jmp    80175c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801757:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80175c:	83 c4 24             	add    $0x24,%esp
  80175f:	5b                   	pop    %ebx
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	57                   	push   %edi
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	83 ec 1c             	sub    $0x1c,%esp
  80176b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80176e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801771:	bb 00 00 00 00       	mov    $0x0,%ebx
  801776:	eb 23                	jmp    80179b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801778:	89 f0                	mov    %esi,%eax
  80177a:	29 d8                	sub    %ebx,%eax
  80177c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801780:	8b 45 0c             	mov    0xc(%ebp),%eax
  801783:	01 d8                	add    %ebx,%eax
  801785:	89 44 24 04          	mov    %eax,0x4(%esp)
  801789:	89 3c 24             	mov    %edi,(%esp)
  80178c:	e8 41 ff ff ff       	call   8016d2 <read>
		if (m < 0)
  801791:	85 c0                	test   %eax,%eax
  801793:	78 10                	js     8017a5 <readn+0x43>
			return m;
		if (m == 0)
  801795:	85 c0                	test   %eax,%eax
  801797:	74 0a                	je     8017a3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801799:	01 c3                	add    %eax,%ebx
  80179b:	39 f3                	cmp    %esi,%ebx
  80179d:	72 d9                	jb     801778 <readn+0x16>
  80179f:	89 d8                	mov    %ebx,%eax
  8017a1:	eb 02                	jmp    8017a5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017a3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017a5:	83 c4 1c             	add    $0x1c,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 24             	sub    $0x24,%esp
  8017b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017be:	89 1c 24             	mov    %ebx,(%esp)
  8017c1:	e8 70 fc ff ff       	call   801436 <fd_lookup>
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 68                	js     801832 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d4:	8b 00                	mov    (%eax),%eax
  8017d6:	89 04 24             	mov    %eax,(%esp)
  8017d9:	e8 ae fc ff ff       	call   80148c <dev_lookup>
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 50                	js     801832 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e9:	75 23                	jne    80180e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f0:	8b 40 48             	mov    0x48(%eax),%eax
  8017f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fb:	c7 04 24 f1 29 80 00 	movl   $0x8029f1,(%esp)
  801802:	e8 e9 ea ff ff       	call   8002f0 <cprintf>
		return -E_INVAL;
  801807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80180c:	eb 24                	jmp    801832 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80180e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801811:	8b 52 0c             	mov    0xc(%edx),%edx
  801814:	85 d2                	test   %edx,%edx
  801816:	74 15                	je     80182d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801818:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80181b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80181f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801822:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801826:	89 04 24             	mov    %eax,(%esp)
  801829:	ff d2                	call   *%edx
  80182b:	eb 05                	jmp    801832 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80182d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801832:	83 c4 24             	add    $0x24,%esp
  801835:	5b                   	pop    %ebx
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <seek>:

int
seek(int fdnum, off_t offset)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801841:	89 44 24 04          	mov    %eax,0x4(%esp)
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	89 04 24             	mov    %eax,(%esp)
  80184b:	e8 e6 fb ff ff       	call   801436 <fd_lookup>
  801850:	85 c0                	test   %eax,%eax
  801852:	78 0e                	js     801862 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801854:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80185d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	53                   	push   %ebx
  801868:	83 ec 24             	sub    $0x24,%esp
  80186b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801871:	89 44 24 04          	mov    %eax,0x4(%esp)
  801875:	89 1c 24             	mov    %ebx,(%esp)
  801878:	e8 b9 fb ff ff       	call   801436 <fd_lookup>
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 61                	js     8018e2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801881:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801884:	89 44 24 04          	mov    %eax,0x4(%esp)
  801888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188b:	8b 00                	mov    (%eax),%eax
  80188d:	89 04 24             	mov    %eax,(%esp)
  801890:	e8 f7 fb ff ff       	call   80148c <dev_lookup>
  801895:	85 c0                	test   %eax,%eax
  801897:	78 49                	js     8018e2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801899:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a0:	75 23                	jne    8018c5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018a7:	8b 40 48             	mov    0x48(%eax),%eax
  8018aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b2:	c7 04 24 b4 29 80 00 	movl   $0x8029b4,(%esp)
  8018b9:	e8 32 ea ff ff       	call   8002f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c3:	eb 1d                	jmp    8018e2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c8:	8b 52 18             	mov    0x18(%edx),%edx
  8018cb:	85 d2                	test   %edx,%edx
  8018cd:	74 0e                	je     8018dd <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	ff d2                	call   *%edx
  8018db:	eb 05                	jmp    8018e2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018e2:	83 c4 24             	add    $0x24,%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 24             	sub    $0x24,%esp
  8018ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	e8 32 fb ff ff       	call   801436 <fd_lookup>
  801904:	85 c0                	test   %eax,%eax
  801906:	78 52                	js     80195a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801908:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801912:	8b 00                	mov    (%eax),%eax
  801914:	89 04 24             	mov    %eax,(%esp)
  801917:	e8 70 fb ff ff       	call   80148c <dev_lookup>
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 3a                	js     80195a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801923:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801927:	74 2c                	je     801955 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801929:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80192c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801933:	00 00 00 
	stat->st_isdir = 0;
  801936:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80193d:	00 00 00 
	stat->st_dev = dev;
  801940:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801946:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80194d:	89 14 24             	mov    %edx,(%esp)
  801950:	ff 50 14             	call   *0x14(%eax)
  801953:	eb 05                	jmp    80195a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801955:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80195a:	83 c4 24             	add    $0x24,%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801968:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80196f:	00 
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	89 04 24             	mov    %eax,(%esp)
  801976:	e8 fe 01 00 00       	call   801b79 <open>
  80197b:	89 c3                	mov    %eax,%ebx
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 1b                	js     80199c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801981:	8b 45 0c             	mov    0xc(%ebp),%eax
  801984:	89 44 24 04          	mov    %eax,0x4(%esp)
  801988:	89 1c 24             	mov    %ebx,(%esp)
  80198b:	e8 58 ff ff ff       	call   8018e8 <fstat>
  801990:	89 c6                	mov    %eax,%esi
	close(fd);
  801992:	89 1c 24             	mov    %ebx,(%esp)
  801995:	e8 d4 fb ff ff       	call   80156e <close>
	return r;
  80199a:	89 f3                	mov    %esi,%ebx
}
  80199c:	89 d8                	mov    %ebx,%eax
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	5b                   	pop    %ebx
  8019a2:	5e                   	pop    %esi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    
  8019a5:	00 00                	add    %al,(%eax)
	...

008019a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 10             	sub    $0x10,%esp
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019b4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019bb:	75 11                	jne    8019ce <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019c4:	e8 aa f9 ff ff       	call   801373 <ipc_find_env>
  8019c9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019ce:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019d5:	00 
  8019d6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019dd:	00 
  8019de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e2:	a1 00 40 80 00       	mov    0x804000,%eax
  8019e7:	89 04 24             	mov    %eax,(%esp)
  8019ea:	e8 1a f9 ff ff       	call   801309 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f6:	00 
  8019f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a02:	e8 99 f8 ff ff       	call   8012a0 <ipc_recv>
}
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	5b                   	pop    %ebx
  801a0b:	5e                   	pop    %esi
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a14:	8b 45 08             	mov    0x8(%ebp),%eax
  801a17:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a22:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a27:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2c:	b8 02 00 00 00       	mov    $0x2,%eax
  801a31:	e8 72 ff ff ff       	call   8019a8 <fsipc>
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	8b 40 0c             	mov    0xc(%eax),%eax
  801a44:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a49:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4e:	b8 06 00 00 00       	mov    $0x6,%eax
  801a53:	e8 50 ff ff ff       	call   8019a8 <fsipc>
}
  801a58:	c9                   	leave  
  801a59:	c3                   	ret    

00801a5a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 14             	sub    $0x14,%esp
  801a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a74:	b8 05 00 00 00       	mov    $0x5,%eax
  801a79:	e8 2a ff ff ff       	call   8019a8 <fsipc>
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	78 2b                	js     801aad <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a82:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a89:	00 
  801a8a:	89 1c 24             	mov    %ebx,(%esp)
  801a8d:	e8 09 ee ff ff       	call   80089b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a92:	a1 80 50 80 00       	mov    0x805080,%eax
  801a97:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a9d:	a1 84 50 80 00       	mov    0x805084,%eax
  801aa2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aad:	83 c4 14             	add    $0x14,%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801ab9:	c7 44 24 08 20 2a 80 	movl   $0x802a20,0x8(%esp)
  801ac0:	00 
  801ac1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801ac8:	00 
  801ac9:	c7 04 24 3e 2a 80 00 	movl   $0x802a3e,(%esp)
  801ad0:	e8 5b 06 00 00       	call   802130 <_panic>

00801ad5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	56                   	push   %esi
  801ad9:	53                   	push   %ebx
  801ada:	83 ec 10             	sub    $0x10,%esp
  801add:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aeb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801af1:	ba 00 00 00 00       	mov    $0x0,%edx
  801af6:	b8 03 00 00 00       	mov    $0x3,%eax
  801afb:	e8 a8 fe ff ff       	call   8019a8 <fsipc>
  801b00:	89 c3                	mov    %eax,%ebx
  801b02:	85 c0                	test   %eax,%eax
  801b04:	78 6a                	js     801b70 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b06:	39 c6                	cmp    %eax,%esi
  801b08:	73 24                	jae    801b2e <devfile_read+0x59>
  801b0a:	c7 44 24 0c 49 2a 80 	movl   $0x802a49,0xc(%esp)
  801b11:	00 
  801b12:	c7 44 24 08 50 2a 80 	movl   $0x802a50,0x8(%esp)
  801b19:	00 
  801b1a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b21:	00 
  801b22:	c7 04 24 3e 2a 80 00 	movl   $0x802a3e,(%esp)
  801b29:	e8 02 06 00 00       	call   802130 <_panic>
	assert(r <= PGSIZE);
  801b2e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b33:	7e 24                	jle    801b59 <devfile_read+0x84>
  801b35:	c7 44 24 0c 65 2a 80 	movl   $0x802a65,0xc(%esp)
  801b3c:	00 
  801b3d:	c7 44 24 08 50 2a 80 	movl   $0x802a50,0x8(%esp)
  801b44:	00 
  801b45:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b4c:	00 
  801b4d:	c7 04 24 3e 2a 80 00 	movl   $0x802a3e,(%esp)
  801b54:	e8 d7 05 00 00       	call   802130 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b59:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b5d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b64:	00 
  801b65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b68:	89 04 24             	mov    %eax,(%esp)
  801b6b:	e8 a4 ee ff ff       	call   800a14 <memmove>
	return r;
}
  801b70:	89 d8                	mov    %ebx,%eax
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	56                   	push   %esi
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 20             	sub    $0x20,%esp
  801b81:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b84:	89 34 24             	mov    %esi,(%esp)
  801b87:	e8 dc ec ff ff       	call   800868 <strlen>
  801b8c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b91:	7f 60                	jg     801bf3 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b96:	89 04 24             	mov    %eax,(%esp)
  801b99:	e8 45 f8 ff ff       	call   8013e3 <fd_alloc>
  801b9e:	89 c3                	mov    %eax,%ebx
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 54                	js     801bf8 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ba4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ba8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801baf:	e8 e7 ec ff ff       	call   80089b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bbf:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc4:	e8 df fd ff ff       	call   8019a8 <fsipc>
  801bc9:	89 c3                	mov    %eax,%ebx
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	79 15                	jns    801be4 <open+0x6b>
		fd_close(fd, 0);
  801bcf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bd6:	00 
  801bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bda:	89 04 24             	mov    %eax,(%esp)
  801bdd:	e8 04 f9 ff ff       	call   8014e6 <fd_close>
		return r;
  801be2:	eb 14                	jmp    801bf8 <open+0x7f>
	}

	return fd2num(fd);
  801be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be7:	89 04 24             	mov    %eax,(%esp)
  801bea:	e8 c9 f7 ff ff       	call   8013b8 <fd2num>
  801bef:	89 c3                	mov    %eax,%ebx
  801bf1:	eb 05                	jmp    801bf8 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bf3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	83 c4 20             	add    $0x20,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c07:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c11:	e8 92 fd ff ff       	call   8019a8 <fsipc>
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	56                   	push   %esi
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 10             	sub    $0x10,%esp
  801c20:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c23:	8b 45 08             	mov    0x8(%ebp),%eax
  801c26:	89 04 24             	mov    %eax,(%esp)
  801c29:	e8 9a f7 ff ff       	call   8013c8 <fd2data>
  801c2e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c30:	c7 44 24 04 71 2a 80 	movl   $0x802a71,0x4(%esp)
  801c37:	00 
  801c38:	89 34 24             	mov    %esi,(%esp)
  801c3b:	e8 5b ec ff ff       	call   80089b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c40:	8b 43 04             	mov    0x4(%ebx),%eax
  801c43:	2b 03                	sub    (%ebx),%eax
  801c45:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c4b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c52:	00 00 00 
	stat->st_dev = &devpipe;
  801c55:	c7 86 88 00 00 00 28 	movl   $0x803028,0x88(%esi)
  801c5c:	30 80 00 
	return 0;
}
  801c5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5e                   	pop    %esi
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    

00801c6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 14             	sub    $0x14,%esp
  801c72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c80:	e8 af f0 ff ff       	call   800d34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c85:	89 1c 24             	mov    %ebx,(%esp)
  801c88:	e8 3b f7 ff ff       	call   8013c8 <fd2data>
  801c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c98:	e8 97 f0 ff ff       	call   800d34 <sys_page_unmap>
}
  801c9d:	83 c4 14             	add    $0x14,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	57                   	push   %edi
  801ca7:	56                   	push   %esi
  801ca8:	53                   	push   %ebx
  801ca9:	83 ec 2c             	sub    $0x2c,%esp
  801cac:	89 c7                	mov    %eax,%edi
  801cae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cb1:	a1 04 40 80 00       	mov    0x804004,%eax
  801cb6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cb9:	89 3c 24             	mov    %edi,(%esp)
  801cbc:	e8 3b 05 00 00       	call   8021fc <pageref>
  801cc1:	89 c6                	mov    %eax,%esi
  801cc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc6:	89 04 24             	mov    %eax,(%esp)
  801cc9:	e8 2e 05 00 00       	call   8021fc <pageref>
  801cce:	39 c6                	cmp    %eax,%esi
  801cd0:	0f 94 c0             	sete   %al
  801cd3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cd6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cdc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cdf:	39 cb                	cmp    %ecx,%ebx
  801ce1:	75 08                	jne    801ceb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ce3:	83 c4 2c             	add    $0x2c,%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5f                   	pop    %edi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ceb:	83 f8 01             	cmp    $0x1,%eax
  801cee:	75 c1                	jne    801cb1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cf0:	8b 42 58             	mov    0x58(%edx),%eax
  801cf3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801cfa:	00 
  801cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d03:	c7 04 24 78 2a 80 00 	movl   $0x802a78,(%esp)
  801d0a:	e8 e1 e5 ff ff       	call   8002f0 <cprintf>
  801d0f:	eb a0                	jmp    801cb1 <_pipeisclosed+0xe>

00801d11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	57                   	push   %edi
  801d15:	56                   	push   %esi
  801d16:	53                   	push   %ebx
  801d17:	83 ec 1c             	sub    $0x1c,%esp
  801d1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d1d:	89 34 24             	mov    %esi,(%esp)
  801d20:	e8 a3 f6 ff ff       	call   8013c8 <fd2data>
  801d25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d27:	bf 00 00 00 00       	mov    $0x0,%edi
  801d2c:	eb 3c                	jmp    801d6a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d2e:	89 da                	mov    %ebx,%edx
  801d30:	89 f0                	mov    %esi,%eax
  801d32:	e8 6c ff ff ff       	call   801ca3 <_pipeisclosed>
  801d37:	85 c0                	test   %eax,%eax
  801d39:	75 38                	jne    801d73 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d3b:	e8 2e ef ff ff       	call   800c6e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d40:	8b 43 04             	mov    0x4(%ebx),%eax
  801d43:	8b 13                	mov    (%ebx),%edx
  801d45:	83 c2 20             	add    $0x20,%edx
  801d48:	39 d0                	cmp    %edx,%eax
  801d4a:	73 e2                	jae    801d2e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d52:	89 c2                	mov    %eax,%edx
  801d54:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d5a:	79 05                	jns    801d61 <devpipe_write+0x50>
  801d5c:	4a                   	dec    %edx
  801d5d:	83 ca e0             	or     $0xffffffe0,%edx
  801d60:	42                   	inc    %edx
  801d61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d65:	40                   	inc    %eax
  801d66:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d69:	47                   	inc    %edi
  801d6a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d6d:	75 d1                	jne    801d40 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d6f:	89 f8                	mov    %edi,%eax
  801d71:	eb 05                	jmp    801d78 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d78:	83 c4 1c             	add    $0x1c,%esp
  801d7b:	5b                   	pop    %ebx
  801d7c:	5e                   	pop    %esi
  801d7d:	5f                   	pop    %edi
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	57                   	push   %edi
  801d84:	56                   	push   %esi
  801d85:	53                   	push   %ebx
  801d86:	83 ec 1c             	sub    $0x1c,%esp
  801d89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d8c:	89 3c 24             	mov    %edi,(%esp)
  801d8f:	e8 34 f6 ff ff       	call   8013c8 <fd2data>
  801d94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d96:	be 00 00 00 00       	mov    $0x0,%esi
  801d9b:	eb 3a                	jmp    801dd7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d9d:	85 f6                	test   %esi,%esi
  801d9f:	74 04                	je     801da5 <devpipe_read+0x25>
				return i;
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	eb 40                	jmp    801de5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801da5:	89 da                	mov    %ebx,%edx
  801da7:	89 f8                	mov    %edi,%eax
  801da9:	e8 f5 fe ff ff       	call   801ca3 <_pipeisclosed>
  801dae:	85 c0                	test   %eax,%eax
  801db0:	75 2e                	jne    801de0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801db2:	e8 b7 ee ff ff       	call   800c6e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801db7:	8b 03                	mov    (%ebx),%eax
  801db9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dbc:	74 df                	je     801d9d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dbe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dc3:	79 05                	jns    801dca <devpipe_read+0x4a>
  801dc5:	48                   	dec    %eax
  801dc6:	83 c8 e0             	or     $0xffffffe0,%eax
  801dc9:	40                   	inc    %eax
  801dca:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801dce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dd4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd6:	46                   	inc    %esi
  801dd7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dda:	75 db                	jne    801db7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ddc:	89 f0                	mov    %esi,%eax
  801dde:	eb 05                	jmp    801de5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    

00801ded <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	57                   	push   %edi
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	83 ec 3c             	sub    $0x3c,%esp
  801df6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801df9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dfc:	89 04 24             	mov    %eax,(%esp)
  801dff:	e8 df f5 ff ff       	call   8013e3 <fd_alloc>
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	85 c0                	test   %eax,%eax
  801e08:	0f 88 45 01 00 00    	js     801f53 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e15:	00 
  801e16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e24:	e8 64 ee ff ff       	call   800c8d <sys_page_alloc>
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	0f 88 20 01 00 00    	js     801f53 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e33:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e36:	89 04 24             	mov    %eax,(%esp)
  801e39:	e8 a5 f5 ff ff       	call   8013e3 <fd_alloc>
  801e3e:	89 c3                	mov    %eax,%ebx
  801e40:	85 c0                	test   %eax,%eax
  801e42:	0f 88 f8 00 00 00    	js     801f40 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e48:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e4f:	00 
  801e50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5e:	e8 2a ee ff ff       	call   800c8d <sys_page_alloc>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	85 c0                	test   %eax,%eax
  801e67:	0f 88 d3 00 00 00    	js     801f40 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e70:	89 04 24             	mov    %eax,(%esp)
  801e73:	e8 50 f5 ff ff       	call   8013c8 <fd2data>
  801e78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e81:	00 
  801e82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8d:	e8 fb ed ff ff       	call   800c8d <sys_page_alloc>
  801e92:	89 c3                	mov    %eax,%ebx
  801e94:	85 c0                	test   %eax,%eax
  801e96:	0f 88 91 00 00 00    	js     801f2d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e9f:	89 04 24             	mov    %eax,(%esp)
  801ea2:	e8 21 f5 ff ff       	call   8013c8 <fd2data>
  801ea7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801eae:	00 
  801eaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eba:	00 
  801ebb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec6:	e8 16 ee ff ff       	call   800ce1 <sys_page_map>
  801ecb:	89 c3                	mov    %eax,%ebx
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 4c                	js     801f1d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ed1:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eda:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801edf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ee6:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801eec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ef1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801efb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801efe:	89 04 24             	mov    %eax,(%esp)
  801f01:	e8 b2 f4 ff ff       	call   8013b8 <fd2num>
  801f06:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f08:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f0b:	89 04 24             	mov    %eax,(%esp)
  801f0e:	e8 a5 f4 ff ff       	call   8013b8 <fd2num>
  801f13:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f16:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f1b:	eb 36                	jmp    801f53 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f28:	e8 07 ee ff ff       	call   800d34 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3b:	e8 f4 ed ff ff       	call   800d34 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4e:	e8 e1 ed ff ff       	call   800d34 <sys_page_unmap>
    err:
	return r;
}
  801f53:	89 d8                	mov    %ebx,%eax
  801f55:	83 c4 3c             	add    $0x3c,%esp
  801f58:	5b                   	pop    %ebx
  801f59:	5e                   	pop    %esi
  801f5a:	5f                   	pop    %edi
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    

00801f5d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6d:	89 04 24             	mov    %eax,(%esp)
  801f70:	e8 c1 f4 ff ff       	call   801436 <fd_lookup>
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 15                	js     801f8e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7c:	89 04 24             	mov    %eax,(%esp)
  801f7f:	e8 44 f4 ff ff       	call   8013c8 <fd2data>
	return _pipeisclosed(fd, p);
  801f84:	89 c2                	mov    %eax,%edx
  801f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f89:	e8 15 fd ff ff       	call   801ca3 <_pipeisclosed>
}
  801f8e:	c9                   	leave  
  801f8f:	c3                   	ret    

00801f90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fa0:	c7 44 24 04 90 2a 80 	movl   $0x802a90,0x4(%esp)
  801fa7:	00 
  801fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fab:	89 04 24             	mov    %eax,(%esp)
  801fae:	e8 e8 e8 ff ff       	call   80089b <strcpy>
	return 0;
}
  801fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	57                   	push   %edi
  801fbe:	56                   	push   %esi
  801fbf:	53                   	push   %ebx
  801fc0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fcb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fd1:	eb 30                	jmp    802003 <devcons_write+0x49>
		m = n - tot;
  801fd3:	8b 75 10             	mov    0x10(%ebp),%esi
  801fd6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fd8:	83 fe 7f             	cmp    $0x7f,%esi
  801fdb:	76 05                	jbe    801fe2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801fdd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fe2:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fe6:	03 45 0c             	add    0xc(%ebp),%eax
  801fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fed:	89 3c 24             	mov    %edi,(%esp)
  801ff0:	e8 1f ea ff ff       	call   800a14 <memmove>
		sys_cputs(buf, m);
  801ff5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ff9:	89 3c 24             	mov    %edi,(%esp)
  801ffc:	e8 bf eb ff ff       	call   800bc0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802001:	01 f3                	add    %esi,%ebx
  802003:	89 d8                	mov    %ebx,%eax
  802005:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802008:	72 c9                	jb     801fd3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80200a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80201b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80201f:	75 07                	jne    802028 <devcons_read+0x13>
  802021:	eb 25                	jmp    802048 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802023:	e8 46 ec ff ff       	call   800c6e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802028:	e8 b1 eb ff ff       	call   800bde <sys_cgetc>
  80202d:	85 c0                	test   %eax,%eax
  80202f:	74 f2                	je     802023 <devcons_read+0xe>
  802031:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802033:	85 c0                	test   %eax,%eax
  802035:	78 1d                	js     802054 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802037:	83 f8 04             	cmp    $0x4,%eax
  80203a:	74 13                	je     80204f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80203c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203f:	88 10                	mov    %dl,(%eax)
	return 1;
  802041:	b8 01 00 00 00       	mov    $0x1,%eax
  802046:	eb 0c                	jmp    802054 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802048:	b8 00 00 00 00       	mov    $0x0,%eax
  80204d:	eb 05                	jmp    802054 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80204f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802054:	c9                   	leave  
  802055:	c3                   	ret    

00802056 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80205c:	8b 45 08             	mov    0x8(%ebp),%eax
  80205f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802062:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802069:	00 
  80206a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80206d:	89 04 24             	mov    %eax,(%esp)
  802070:	e8 4b eb ff ff       	call   800bc0 <sys_cputs>
}
  802075:	c9                   	leave  
  802076:	c3                   	ret    

00802077 <getchar>:

int
getchar(void)
{
  802077:	55                   	push   %ebp
  802078:	89 e5                	mov    %esp,%ebp
  80207a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80207d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802084:	00 
  802085:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802093:	e8 3a f6 ff ff       	call   8016d2 <read>
	if (r < 0)
  802098:	85 c0                	test   %eax,%eax
  80209a:	78 0f                	js     8020ab <getchar+0x34>
		return r;
	if (r < 1)
  80209c:	85 c0                	test   %eax,%eax
  80209e:	7e 06                	jle    8020a6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020a0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020a4:	eb 05                	jmp    8020ab <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020a6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020ab:	c9                   	leave  
  8020ac:	c3                   	ret    

008020ad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bd:	89 04 24             	mov    %eax,(%esp)
  8020c0:	e8 71 f3 ff ff       	call   801436 <fd_lookup>
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	78 11                	js     8020da <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cc:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8020d2:	39 10                	cmp    %edx,(%eax)
  8020d4:	0f 94 c0             	sete   %al
  8020d7:	0f b6 c0             	movzbl %al,%eax
}
  8020da:	c9                   	leave  
  8020db:	c3                   	ret    

008020dc <opencons>:

int
opencons(void)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 f6 f2 ff ff       	call   8013e3 <fd_alloc>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 3c                	js     80212d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020f1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020f8:	00 
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802100:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802107:	e8 81 eb ff ff       	call   800c8d <sys_page_alloc>
  80210c:	85 c0                	test   %eax,%eax
  80210e:	78 1d                	js     80212d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802110:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802116:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802119:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80211b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 8b f2 ff ff       	call   8013b8 <fd2num>
}
  80212d:	c9                   	leave  
  80212e:	c3                   	ret    
	...

00802130 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	56                   	push   %esi
  802134:	53                   	push   %ebx
  802135:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802138:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80213b:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  802141:	e8 09 eb ff ff       	call   800c4f <sys_getenvid>
  802146:	8b 55 0c             	mov    0xc(%ebp),%edx
  802149:	89 54 24 10          	mov    %edx,0x10(%esp)
  80214d:	8b 55 08             	mov    0x8(%ebp),%edx
  802150:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802154:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215c:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  802163:	e8 88 e1 ff ff       	call   8002f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802168:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216c:	8b 45 10             	mov    0x10(%ebp),%eax
  80216f:	89 04 24             	mov    %eax,(%esp)
  802172:	e8 18 e1 ff ff       	call   80028f <vcprintf>
	cprintf("\n");
  802177:	c7 04 24 89 2a 80 00 	movl   $0x802a89,(%esp)
  80217e:	e8 6d e1 ff ff       	call   8002f0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802183:	cc                   	int3   
  802184:	eb fd                	jmp    802183 <_panic+0x53>
	...

00802188 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80218e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802195:	75 32                	jne    8021c9 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802197:	e8 b3 ea ff ff       	call   800c4f <sys_getenvid>
  80219c:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  8021a3:	00 
  8021a4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021ab:	ee 
  8021ac:	89 04 24             	mov    %eax,(%esp)
  8021af:	e8 d9 ea ff ff       	call   800c8d <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  8021b4:	e8 96 ea ff ff       	call   800c4f <sys_getenvid>
  8021b9:	c7 44 24 04 d4 21 80 	movl   $0x8021d4,0x4(%esp)
  8021c0:	00 
  8021c1:	89 04 24             	mov    %eax,(%esp)
  8021c4:	e8 64 ec ff ff       	call   800e2d <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cc:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    
	...

008021d4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021d4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021d5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021da:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021dc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  8021df:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  8021e3:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  8021e6:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  8021eb:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  8021ef:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  8021f2:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  8021f3:	83 c4 04             	add    $0x4,%esp
	popfl
  8021f6:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  8021f7:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  8021f8:	c3                   	ret    
  8021f9:	00 00                	add    %al,(%eax)
	...

008021fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021fc:	55                   	push   %ebp
  8021fd:	89 e5                	mov    %esp,%ebp
  8021ff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802202:	89 c2                	mov    %eax,%edx
  802204:	c1 ea 16             	shr    $0x16,%edx
  802207:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80220e:	f6 c2 01             	test   $0x1,%dl
  802211:	74 1e                	je     802231 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802213:	c1 e8 0c             	shr    $0xc,%eax
  802216:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80221d:	a8 01                	test   $0x1,%al
  80221f:	74 17                	je     802238 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802221:	c1 e8 0c             	shr    $0xc,%eax
  802224:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80222b:	ef 
  80222c:	0f b7 c0             	movzwl %ax,%eax
  80222f:	eb 0c                	jmp    80223d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
  802236:	eb 05                	jmp    80223d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802238:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    
	...

00802240 <__udivdi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	83 ec 10             	sub    $0x10,%esp
  802246:	8b 74 24 20          	mov    0x20(%esp),%esi
  80224a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80224e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802252:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802256:	89 cd                	mov    %ecx,%ebp
  802258:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80225c:	85 c0                	test   %eax,%eax
  80225e:	75 2c                	jne    80228c <__udivdi3+0x4c>
  802260:	39 f9                	cmp    %edi,%ecx
  802262:	77 68                	ja     8022cc <__udivdi3+0x8c>
  802264:	85 c9                	test   %ecx,%ecx
  802266:	75 0b                	jne    802273 <__udivdi3+0x33>
  802268:	b8 01 00 00 00       	mov    $0x1,%eax
  80226d:	31 d2                	xor    %edx,%edx
  80226f:	f7 f1                	div    %ecx
  802271:	89 c1                	mov    %eax,%ecx
  802273:	31 d2                	xor    %edx,%edx
  802275:	89 f8                	mov    %edi,%eax
  802277:	f7 f1                	div    %ecx
  802279:	89 c7                	mov    %eax,%edi
  80227b:	89 f0                	mov    %esi,%eax
  80227d:	f7 f1                	div    %ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	89 f0                	mov    %esi,%eax
  802283:	89 fa                	mov    %edi,%edx
  802285:	83 c4 10             	add    $0x10,%esp
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	39 f8                	cmp    %edi,%eax
  80228e:	77 2c                	ja     8022bc <__udivdi3+0x7c>
  802290:	0f bd f0             	bsr    %eax,%esi
  802293:	83 f6 1f             	xor    $0x1f,%esi
  802296:	75 4c                	jne    8022e4 <__udivdi3+0xa4>
  802298:	39 f8                	cmp    %edi,%eax
  80229a:	bf 00 00 00 00       	mov    $0x0,%edi
  80229f:	72 0a                	jb     8022ab <__udivdi3+0x6b>
  8022a1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022a5:	0f 87 ad 00 00 00    	ja     802358 <__udivdi3+0x118>
  8022ab:	be 01 00 00 00       	mov    $0x1,%esi
  8022b0:	89 f0                	mov    %esi,%eax
  8022b2:	89 fa                	mov    %edi,%edx
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    
  8022bb:	90                   	nop
  8022bc:	31 ff                	xor    %edi,%edi
  8022be:	31 f6                	xor    %esi,%esi
  8022c0:	89 f0                	mov    %esi,%eax
  8022c2:	89 fa                	mov    %edi,%edx
  8022c4:	83 c4 10             	add    $0x10,%esp
  8022c7:	5e                   	pop    %esi
  8022c8:	5f                   	pop    %edi
  8022c9:	5d                   	pop    %ebp
  8022ca:	c3                   	ret    
  8022cb:	90                   	nop
  8022cc:	89 fa                	mov    %edi,%edx
  8022ce:	89 f0                	mov    %esi,%eax
  8022d0:	f7 f1                	div    %ecx
  8022d2:	89 c6                	mov    %eax,%esi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 f0                	mov    %esi,%eax
  8022d8:	89 fa                	mov    %edi,%edx
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	5e                   	pop    %esi
  8022de:	5f                   	pop    %edi
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    
  8022e1:	8d 76 00             	lea    0x0(%esi),%esi
  8022e4:	89 f1                	mov    %esi,%ecx
  8022e6:	d3 e0                	shl    %cl,%eax
  8022e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8022f1:	29 f0                	sub    %esi,%eax
  8022f3:	89 ea                	mov    %ebp,%edx
  8022f5:	88 c1                	mov    %al,%cl
  8022f7:	d3 ea                	shr    %cl,%edx
  8022f9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022fd:	09 ca                	or     %ecx,%edx
  8022ff:	89 54 24 08          	mov    %edx,0x8(%esp)
  802303:	89 f1                	mov    %esi,%ecx
  802305:	d3 e5                	shl    %cl,%ebp
  802307:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80230b:	89 fd                	mov    %edi,%ebp
  80230d:	88 c1                	mov    %al,%cl
  80230f:	d3 ed                	shr    %cl,%ebp
  802311:	89 fa                	mov    %edi,%edx
  802313:	89 f1                	mov    %esi,%ecx
  802315:	d3 e2                	shl    %cl,%edx
  802317:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80231b:	88 c1                	mov    %al,%cl
  80231d:	d3 ef                	shr    %cl,%edi
  80231f:	09 d7                	or     %edx,%edi
  802321:	89 f8                	mov    %edi,%eax
  802323:	89 ea                	mov    %ebp,%edx
  802325:	f7 74 24 08          	divl   0x8(%esp)
  802329:	89 d1                	mov    %edx,%ecx
  80232b:	89 c7                	mov    %eax,%edi
  80232d:	f7 64 24 0c          	mull   0xc(%esp)
  802331:	39 d1                	cmp    %edx,%ecx
  802333:	72 17                	jb     80234c <__udivdi3+0x10c>
  802335:	74 09                	je     802340 <__udivdi3+0x100>
  802337:	89 fe                	mov    %edi,%esi
  802339:	31 ff                	xor    %edi,%edi
  80233b:	e9 41 ff ff ff       	jmp    802281 <__udivdi3+0x41>
  802340:	8b 54 24 04          	mov    0x4(%esp),%edx
  802344:	89 f1                	mov    %esi,%ecx
  802346:	d3 e2                	shl    %cl,%edx
  802348:	39 c2                	cmp    %eax,%edx
  80234a:	73 eb                	jae    802337 <__udivdi3+0xf7>
  80234c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80234f:	31 ff                	xor    %edi,%edi
  802351:	e9 2b ff ff ff       	jmp    802281 <__udivdi3+0x41>
  802356:	66 90                	xchg   %ax,%ax
  802358:	31 f6                	xor    %esi,%esi
  80235a:	e9 22 ff ff ff       	jmp    802281 <__udivdi3+0x41>
	...

00802360 <__umoddi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	83 ec 20             	sub    $0x20,%esp
  802366:	8b 44 24 30          	mov    0x30(%esp),%eax
  80236a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80236e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802372:	8b 74 24 34          	mov    0x34(%esp),%esi
  802376:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80237a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80237e:	89 c7                	mov    %eax,%edi
  802380:	89 f2                	mov    %esi,%edx
  802382:	85 ed                	test   %ebp,%ebp
  802384:	75 16                	jne    80239c <__umoddi3+0x3c>
  802386:	39 f1                	cmp    %esi,%ecx
  802388:	0f 86 a6 00 00 00    	jbe    802434 <__umoddi3+0xd4>
  80238e:	f7 f1                	div    %ecx
  802390:	89 d0                	mov    %edx,%eax
  802392:	31 d2                	xor    %edx,%edx
  802394:	83 c4 20             	add    $0x20,%esp
  802397:	5e                   	pop    %esi
  802398:	5f                   	pop    %edi
  802399:	5d                   	pop    %ebp
  80239a:	c3                   	ret    
  80239b:	90                   	nop
  80239c:	39 f5                	cmp    %esi,%ebp
  80239e:	0f 87 ac 00 00 00    	ja     802450 <__umoddi3+0xf0>
  8023a4:	0f bd c5             	bsr    %ebp,%eax
  8023a7:	83 f0 1f             	xor    $0x1f,%eax
  8023aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023ae:	0f 84 a8 00 00 00    	je     80245c <__umoddi3+0xfc>
  8023b4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023b8:	d3 e5                	shl    %cl,%ebp
  8023ba:	bf 20 00 00 00       	mov    $0x20,%edi
  8023bf:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8023c3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023c7:	89 f9                	mov    %edi,%ecx
  8023c9:	d3 e8                	shr    %cl,%eax
  8023cb:	09 e8                	or     %ebp,%eax
  8023cd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023d5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023d9:	d3 e0                	shl    %cl,%eax
  8023db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023df:	89 f2                	mov    %esi,%edx
  8023e1:	d3 e2                	shl    %cl,%edx
  8023e3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e7:	d3 e0                	shl    %cl,%eax
  8023e9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8023ed:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	d3 e8                	shr    %cl,%eax
  8023f5:	09 d0                	or     %edx,%eax
  8023f7:	d3 ee                	shr    %cl,%esi
  8023f9:	89 f2                	mov    %esi,%edx
  8023fb:	f7 74 24 18          	divl   0x18(%esp)
  8023ff:	89 d6                	mov    %edx,%esi
  802401:	f7 64 24 0c          	mull   0xc(%esp)
  802405:	89 c5                	mov    %eax,%ebp
  802407:	89 d1                	mov    %edx,%ecx
  802409:	39 d6                	cmp    %edx,%esi
  80240b:	72 67                	jb     802474 <__umoddi3+0x114>
  80240d:	74 75                	je     802484 <__umoddi3+0x124>
  80240f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802413:	29 e8                	sub    %ebp,%eax
  802415:	19 ce                	sbb    %ecx,%esi
  802417:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	89 f9                	mov    %edi,%ecx
  802421:	d3 e2                	shl    %cl,%edx
  802423:	09 d0                	or     %edx,%eax
  802425:	89 f2                	mov    %esi,%edx
  802427:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	83 c4 20             	add    $0x20,%esp
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
  802434:	85 c9                	test   %ecx,%ecx
  802436:	75 0b                	jne    802443 <__umoddi3+0xe3>
  802438:	b8 01 00 00 00       	mov    $0x1,%eax
  80243d:	31 d2                	xor    %edx,%edx
  80243f:	f7 f1                	div    %ecx
  802441:	89 c1                	mov    %eax,%ecx
  802443:	89 f0                	mov    %esi,%eax
  802445:	31 d2                	xor    %edx,%edx
  802447:	f7 f1                	div    %ecx
  802449:	89 f8                	mov    %edi,%eax
  80244b:	e9 3e ff ff ff       	jmp    80238e <__umoddi3+0x2e>
  802450:	89 f2                	mov    %esi,%edx
  802452:	83 c4 20             	add    $0x20,%esp
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    
  802459:	8d 76 00             	lea    0x0(%esi),%esi
  80245c:	39 f5                	cmp    %esi,%ebp
  80245e:	72 04                	jb     802464 <__umoddi3+0x104>
  802460:	39 f9                	cmp    %edi,%ecx
  802462:	77 06                	ja     80246a <__umoddi3+0x10a>
  802464:	89 f2                	mov    %esi,%edx
  802466:	29 cf                	sub    %ecx,%edi
  802468:	19 ea                	sbb    %ebp,%edx
  80246a:	89 f8                	mov    %edi,%eax
  80246c:	83 c4 20             	add    $0x20,%esp
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
  802473:	90                   	nop
  802474:	89 d1                	mov    %edx,%ecx
  802476:	89 c5                	mov    %eax,%ebp
  802478:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80247c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802480:	eb 8d                	jmp    80240f <__umoddi3+0xaf>
  802482:	66 90                	xchg   %ax,%ax
  802484:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802488:	72 ea                	jb     802474 <__umoddi3+0x114>
  80248a:	89 f1                	mov    %esi,%ecx
  80248c:	eb 81                	jmp    80240f <__umoddi3+0xaf>
