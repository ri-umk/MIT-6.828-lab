
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 97 02 00 00       	call   8002c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800040:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800043:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800046:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004d:	00 
  80004e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800052:	89 1c 24             	mov    %ebx,(%esp)
  800055:	e8 30 17 00 00       	call   80178a <readn>
  80005a:	83 f8 04             	cmp    $0x4,%eax
  80005d:	74 30                	je     80008f <primeproc+0x5b>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005f:	85 c0                	test   %eax,%eax
  800061:	0f 9e c2             	setle  %dl
  800064:	0f b6 d2             	movzbl %dl,%edx
  800067:	f7 da                	neg    %edx
  800069:	21 c2                	and    %eax,%edx
  80006b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800073:	c7 44 24 08 80 25 80 	movl   $0x802580,0x8(%esp)
  80007a:	00 
  80007b:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800082:	00 
  800083:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  80008a:	e8 a9 02 00 00       	call   800338 <_panic>

	cprintf("%d\n", p);
  80008f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800092:	89 44 24 04          	mov    %eax,0x4(%esp)
  800096:	c7 04 24 c1 25 80 00 	movl   $0x8025c1,(%esp)
  80009d:	e8 8e 03 00 00       	call   800430 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  8000a2:	89 3c 24             	mov    %edi,(%esp)
  8000a5:	e8 6b 1d 00 00       	call   801e15 <pipe>
  8000aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	79 20                	jns    8000d1 <primeproc+0x9d>
		panic("pipe: %e", i);
  8000b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b5:	c7 44 24 08 c5 25 80 	movl   $0x8025c5,0x8(%esp)
  8000bc:	00 
  8000bd:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  8000cc:	e8 67 02 00 00       	call   800338 <_panic>
	if ((id = fork()) < 0)
  8000d1:	e8 89 10 00 00       	call   80115f <fork>
  8000d6:	85 c0                	test   %eax,%eax
  8000d8:	79 20                	jns    8000fa <primeproc+0xc6>
		panic("fork: %e", id);
  8000da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000de:	c7 44 24 08 ce 25 80 	movl   $0x8025ce,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  8000f5:	e8 3e 02 00 00       	call   800338 <_panic>
	if (id == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1b                	jne    800119 <primeproc+0xe5>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 90 14 00 00       	call   801596 <close>
		close(pfd[1]);
  800106:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 85 14 00 00       	call   801596 <close>
		fd = pfd[0];
  800111:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800114:	e9 2d ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  800119:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 72 14 00 00       	call   801596 <close>
	wfd = pfd[1];
  800124:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800127:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80012a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800131:	00 
  800132:	89 74 24 04          	mov    %esi,0x4(%esp)
  800136:	89 1c 24             	mov    %ebx,(%esp)
  800139:	e8 4c 16 00 00       	call   80178a <readn>
  80013e:	83 f8 04             	cmp    $0x4,%eax
  800141:	74 3b                	je     80017e <primeproc+0x14a>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800143:	85 c0                	test   %eax,%eax
  800145:	0f 9e c2             	setle  %dl
  800148:	0f b6 d2             	movzbl %dl,%edx
  80014b:	f7 da                	neg    %edx
  80014d:	21 c2                	and    %eax,%edx
  80014f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800153:	89 44 24 14          	mov    %eax,0x14(%esp)
  800157:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 d7 25 80 	movl   $0x8025d7,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  800179:	e8 ba 01 00 00       	call   800338 <_panic>
		if (i%p)
  80017e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800181:	99                   	cltd   
  800182:	f7 7d e0             	idivl  -0x20(%ebp)
  800185:	85 d2                	test   %edx,%edx
  800187:	74 a1                	je     80012a <primeproc+0xf6>
			if ((r=write(wfd, &i, 4)) != 4)
  800189:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800190:	00 
  800191:	89 74 24 04          	mov    %esi,0x4(%esp)
  800195:	89 3c 24             	mov    %edi,(%esp)
  800198:	e8 38 16 00 00       	call   8017d5 <write>
  80019d:	83 f8 04             	cmp    $0x4,%eax
  8001a0:	74 88                	je     80012a <primeproc+0xf6>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	0f 9e c2             	setle  %dl
  8001a7:	0f b6 d2             	movzbl %dl,%edx
  8001aa:	f7 da                	neg    %edx
  8001ac:	21 c2                	and    %eax,%edx
  8001ae:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bd:	c7 44 24 08 f3 25 80 	movl   $0x8025f3,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  8001d4:	e8 5f 01 00 00       	call   800338 <_panic>

008001d9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001e0:	c7 05 00 30 80 00 0d 	movl   $0x80260d,0x803000
  8001e7:	26 80 00 

	if ((i=pipe(p)) < 0)
  8001ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 20 1c 00 00       	call   801e15 <pipe>
  8001f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	79 20                	jns    80021c <umain+0x43>
		panic("pipe: %e", i);
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	c7 44 24 08 c5 25 80 	movl   $0x8025c5,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  800217:	e8 1c 01 00 00       	call   800338 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80021c:	e8 3e 0f 00 00       	call   80115f <fork>
  800221:	85 c0                	test   %eax,%eax
  800223:	79 20                	jns    800245 <umain+0x6c>
		panic("fork: %e", id);
  800225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800229:	c7 44 24 08 ce 25 80 	movl   $0x8025ce,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  800240:	e8 f3 00 00 00       	call   800338 <_panic>

	if (id == 0) {
  800245:	85 c0                	test   %eax,%eax
  800247:	75 16                	jne    80025f <umain+0x86>
		close(p[1]);
  800249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 42 13 00 00       	call   801596 <close>
		primeproc(p[0]);
  800254:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 d5 fd ff ff       	call   800034 <primeproc>
	}

	close(p[0]);
  80025f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	e8 2c 13 00 00       	call   801596 <close>

	// feed all the integers through
	for (i=2;; i++)
  80026a:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800271:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800274:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80027b:	00 
  80027c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 4a 15 00 00       	call   8017d5 <write>
  80028b:	83 f8 04             	cmp    $0x4,%eax
  80028e:	74 30                	je     8002c0 <umain+0xe7>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800290:	85 c0                	test   %eax,%eax
  800292:	0f 9e c2             	setle  %dl
  800295:	0f b6 d2             	movzbl %dl,%edx
  800298:	f7 da                	neg    %edx
  80029a:	21 c2                	and    %eax,%edx
  80029c:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a4:	c7 44 24 08 18 26 80 	movl   $0x802618,0x8(%esp)
  8002ab:	00 
  8002ac:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002b3:	00 
  8002b4:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  8002bb:	e8 78 00 00 00       	call   800338 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  8002c0:	ff 45 f4             	incl   -0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  8002c3:	eb af                	jmp    800274 <umain+0x9b>
  8002c5:	00 00                	add    %al,(%eax)
	...

008002c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 10             	sub    $0x10,%esp
  8002d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8002d6:	e8 b4 0a 00 00       	call   800d8f <sys_getenvid>
  8002db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002e7:	c1 e0 07             	shl    $0x7,%eax
  8002ea:	29 d0                	sub    %edx,%eax
  8002ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f6:	85 f6                	test   %esi,%esi
  8002f8:	7e 07                	jle    800301 <libmain+0x39>
		binaryname = argv[0];
  8002fa:	8b 03                	mov    (%ebx),%eax
  8002fc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800301:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800305:	89 34 24             	mov    %esi,(%esp)
  800308:	e8 cc fe ff ff       	call   8001d9 <umain>

	// exit gracefully
	exit();
  80030d:	e8 0a 00 00 00       	call   80031c <exit>
}
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    
  800319:	00 00                	add    %al,(%eax)
	...

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800322:	e8 a0 12 00 00       	call   8015c7 <close_all>
	sys_env_destroy(0);
  800327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80032e:	e8 0a 0a 00 00       	call   800d3d <sys_env_destroy>
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    
  800335:	00 00                	add    %al,(%eax)
	...

00800338 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800343:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800349:	e8 41 0a 00 00       	call   800d8f <sys_getenvid>
  80034e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800351:	89 54 24 10          	mov    %edx,0x10(%esp)
  800355:	8b 55 08             	mov    0x8(%ebp),%edx
  800358:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80035c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800360:	89 44 24 04          	mov    %eax,0x4(%esp)
  800364:	c7 04 24 3c 26 80 00 	movl   $0x80263c,(%esp)
  80036b:	e8 c0 00 00 00       	call   800430 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800370:	89 74 24 04          	mov    %esi,0x4(%esp)
  800374:	8b 45 10             	mov    0x10(%ebp),%eax
  800377:	89 04 24             	mov    %eax,(%esp)
  80037a:	e8 50 00 00 00       	call   8003cf <vcprintf>
	cprintf("\n");
  80037f:	c7 04 24 c3 25 80 00 	movl   $0x8025c3,(%esp)
  800386:	e8 a5 00 00 00       	call   800430 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038b:	cc                   	int3   
  80038c:	eb fd                	jmp    80038b <_panic+0x53>
	...

00800390 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	53                   	push   %ebx
  800394:	83 ec 14             	sub    $0x14,%esp
  800397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039a:	8b 03                	mov    (%ebx),%eax
  80039c:	8b 55 08             	mov    0x8(%ebp),%edx
  80039f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003a3:	40                   	inc    %eax
  8003a4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ab:	75 19                	jne    8003c6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003ad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003b4:	00 
  8003b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 40 09 00 00       	call   800d00 <sys_cputs>
		b->idx = 0;
  8003c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003c6:	ff 43 04             	incl   0x4(%ebx)
}
  8003c9:	83 c4 14             	add    $0x14,%esp
  8003cc:	5b                   	pop    %ebx
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003df:	00 00 00 
	b.cnt = 0;
  8003e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800400:	89 44 24 04          	mov    %eax,0x4(%esp)
  800404:	c7 04 24 90 03 80 00 	movl   $0x800390,(%esp)
  80040b:	e8 82 01 00 00       	call   800592 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800410:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800416:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	e8 d8 08 00 00       	call   800d00 <sys_cputs>

	return b.cnt;
}
  800428:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800436:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 87 ff ff ff       	call   8003cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800448:	c9                   	leave  
  800449:	c3                   	ret    
	...

0080044c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	83 ec 3c             	sub    $0x3c,%esp
  800455:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800458:	89 d7                	mov    %edx,%edi
  80045a:	8b 45 08             	mov    0x8(%ebp),%eax
  80045d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800469:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80046c:	85 c0                	test   %eax,%eax
  80046e:	75 08                	jne    800478 <printnum+0x2c>
  800470:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800473:	39 45 10             	cmp    %eax,0x10(%ebp)
  800476:	77 57                	ja     8004cf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800478:	89 74 24 10          	mov    %esi,0x10(%esp)
  80047c:	4b                   	dec    %ebx
  80047d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800481:	8b 45 10             	mov    0x10(%ebp),%eax
  800484:	89 44 24 08          	mov    %eax,0x8(%esp)
  800488:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80048c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800490:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800497:	00 
  800498:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a5:	e8 7e 1e 00 00       	call   802328 <__udivdi3>
  8004aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004b2:	89 04 24             	mov    %eax,(%esp)
  8004b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b9:	89 fa                	mov    %edi,%edx
  8004bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004be:	e8 89 ff ff ff       	call   80044c <printnum>
  8004c3:	eb 0f                	jmp    8004d4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c9:	89 34 24             	mov    %esi,(%esp)
  8004cc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004cf:	4b                   	dec    %ebx
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	7f f1                	jg     8004c5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ea:	00 
  8004eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f8:	e8 4b 1f 00 00       	call   802448 <__umoddi3>
  8004fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800501:	0f be 80 5f 26 80 00 	movsbl 0x80265f(%eax),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80050e:	83 c4 3c             	add    $0x3c,%esp
  800511:	5b                   	pop    %ebx
  800512:	5e                   	pop    %esi
  800513:	5f                   	pop    %edi
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800519:	83 fa 01             	cmp    $0x1,%edx
  80051c:	7e 0e                	jle    80052c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80051e:	8b 10                	mov    (%eax),%edx
  800520:	8d 4a 08             	lea    0x8(%edx),%ecx
  800523:	89 08                	mov    %ecx,(%eax)
  800525:	8b 02                	mov    (%edx),%eax
  800527:	8b 52 04             	mov    0x4(%edx),%edx
  80052a:	eb 22                	jmp    80054e <getuint+0x38>
	else if (lflag)
  80052c:	85 d2                	test   %edx,%edx
  80052e:	74 10                	je     800540 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800530:	8b 10                	mov    (%eax),%edx
  800532:	8d 4a 04             	lea    0x4(%edx),%ecx
  800535:	89 08                	mov    %ecx,(%eax)
  800537:	8b 02                	mov    (%edx),%eax
  800539:	ba 00 00 00 00       	mov    $0x0,%edx
  80053e:	eb 0e                	jmp    80054e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800540:	8b 10                	mov    (%eax),%edx
  800542:	8d 4a 04             	lea    0x4(%edx),%ecx
  800545:	89 08                	mov    %ecx,(%eax)
  800547:	8b 02                	mov    (%edx),%eax
  800549:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800556:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800559:	8b 10                	mov    (%eax),%edx
  80055b:	3b 50 04             	cmp    0x4(%eax),%edx
  80055e:	73 08                	jae    800568 <sprintputch+0x18>
		*b->buf++ = ch;
  800560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800563:	88 0a                	mov    %cl,(%edx)
  800565:	42                   	inc    %edx
  800566:	89 10                	mov    %edx,(%eax)
}
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    

0080056a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800570:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800573:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800577:	8b 45 10             	mov    0x10(%ebp),%eax
  80057a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	8b 45 08             	mov    0x8(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	e8 02 00 00 00       	call   800592 <vprintfmt>
	va_end(ap);
}
  800590:	c9                   	leave  
  800591:	c3                   	ret    

00800592 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800592:	55                   	push   %ebp
  800593:	89 e5                	mov    %esp,%ebp
  800595:	57                   	push   %edi
  800596:	56                   	push   %esi
  800597:	53                   	push   %ebx
  800598:	83 ec 4c             	sub    $0x4c,%esp
  80059b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059e:	8b 75 10             	mov    0x10(%ebp),%esi
  8005a1:	eb 12                	jmp    8005b5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	0f 84 6b 03 00 00    	je     800916 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b5:	0f b6 06             	movzbl (%esi),%eax
  8005b8:	46                   	inc    %esi
  8005b9:	83 f8 25             	cmp    $0x25,%eax
  8005bc:	75 e5                	jne    8005a3 <vprintfmt+0x11>
  8005be:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005c2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005ce:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005da:	eb 26                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005df:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005e3:	eb 1d                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005e8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005ec:	eb 14                	jmp    800602 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f8:	eb 08                	jmp    800602 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005fa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800602:	0f b6 06             	movzbl (%esi),%eax
  800605:	8d 56 01             	lea    0x1(%esi),%edx
  800608:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80060b:	8a 16                	mov    (%esi),%dl
  80060d:	83 ea 23             	sub    $0x23,%edx
  800610:	80 fa 55             	cmp    $0x55,%dl
  800613:	0f 87 e1 02 00 00    	ja     8008fa <vprintfmt+0x368>
  800619:	0f b6 d2             	movzbl %dl,%edx
  80061c:	ff 24 95 a0 27 80 00 	jmp    *0x8027a0(,%edx,4)
  800623:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800626:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80062b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80062e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800632:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800635:	8d 50 d0             	lea    -0x30(%eax),%edx
  800638:	83 fa 09             	cmp    $0x9,%edx
  80063b:	77 2a                	ja     800667 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80063d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80063e:	eb eb                	jmp    80062b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80064e:	eb 17                	jmp    800667 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800650:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800654:	78 98                	js     8005ee <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800659:	eb a7                	jmp    800602 <vprintfmt+0x70>
  80065b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800665:	eb 9b                	jmp    800602 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066b:	79 95                	jns    800602 <vprintfmt+0x70>
  80066d:	eb 8b                	jmp    8005fa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80066f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800673:	eb 8d                	jmp    800602 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800682:	8b 00                	mov    (%eax),%eax
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80068d:	e9 23 ff ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	79 02                	jns    8006a3 <vprintfmt+0x111>
  8006a1:	f7 d8                	neg    %eax
  8006a3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a5:	83 f8 0f             	cmp    $0xf,%eax
  8006a8:	7f 0b                	jg     8006b5 <vprintfmt+0x123>
  8006aa:	8b 04 85 00 29 80 00 	mov    0x802900(,%eax,4),%eax
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	75 23                	jne    8006d8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b9:	c7 44 24 08 77 26 80 	movl   $0x802677,0x8(%esp)
  8006c0:	00 
  8006c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	e8 9a fe ff ff       	call   80056a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d3:	e9 dd fe ff ff       	jmp    8005b5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006dc:	c7 44 24 08 6e 2b 80 	movl   $0x802b6e,0x8(%esp)
  8006e3:	00 
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006eb:	89 14 24             	mov    %edx,(%esp)
  8006ee:	e8 77 fe ff ff       	call   80056a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f6:	e9 ba fe ff ff       	jmp    8005b5 <vprintfmt+0x23>
  8006fb:	89 f9                	mov    %edi,%ecx
  8006fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800700:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	8b 30                	mov    (%eax),%esi
  80070e:	85 f6                	test   %esi,%esi
  800710:	75 05                	jne    800717 <vprintfmt+0x185>
				p = "(null)";
  800712:	be 70 26 80 00       	mov    $0x802670,%esi
			if (width > 0 && padc != '-')
  800717:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071b:	0f 8e 84 00 00 00    	jle    8007a5 <vprintfmt+0x213>
  800721:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800725:	74 7e                	je     8007a5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800727:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80072b:	89 34 24             	mov    %esi,(%esp)
  80072e:	e8 8b 02 00 00       	call   8009be <strnlen>
  800733:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800736:	29 c2                	sub    %eax,%edx
  800738:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80073b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80073f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800742:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800745:	89 de                	mov    %ebx,%esi
  800747:	89 d3                	mov    %edx,%ebx
  800749:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074b:	eb 0b                	jmp    800758 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80074d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800751:	89 3c 24             	mov    %edi,(%esp)
  800754:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800757:	4b                   	dec    %ebx
  800758:	85 db                	test   %ebx,%ebx
  80075a:	7f f1                	jg     80074d <vprintfmt+0x1bb>
  80075c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80075f:	89 f3                	mov    %esi,%ebx
  800761:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800764:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800767:	85 c0                	test   %eax,%eax
  800769:	79 05                	jns    800770 <vprintfmt+0x1de>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800773:	29 c2                	sub    %eax,%edx
  800775:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800778:	eb 2b                	jmp    8007a5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80077a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80077e:	74 18                	je     800798 <vprintfmt+0x206>
  800780:	8d 50 e0             	lea    -0x20(%eax),%edx
  800783:	83 fa 5e             	cmp    $0x5e,%edx
  800786:	76 10                	jbe    800798 <vprintfmt+0x206>
					putch('?', putdat);
  800788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
  800796:	eb 0a                	jmp    8007a2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	89 04 24             	mov    %eax,(%esp)
  80079f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a2:	ff 4d e4             	decl   -0x1c(%ebp)
  8007a5:	0f be 06             	movsbl (%esi),%eax
  8007a8:	46                   	inc    %esi
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	74 21                	je     8007ce <vprintfmt+0x23c>
  8007ad:	85 ff                	test   %edi,%edi
  8007af:	78 c9                	js     80077a <vprintfmt+0x1e8>
  8007b1:	4f                   	dec    %edi
  8007b2:	79 c6                	jns    80077a <vprintfmt+0x1e8>
  8007b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b7:	89 de                	mov    %ebx,%esi
  8007b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007bc:	eb 18                	jmp    8007d6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cb:	4b                   	dec    %ebx
  8007cc:	eb 08                	jmp    8007d6 <vprintfmt+0x244>
  8007ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d1:	89 de                	mov    %ebx,%esi
  8007d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007d6:	85 db                	test   %ebx,%ebx
  8007d8:	7f e4                	jg     8007be <vprintfmt+0x22c>
  8007da:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007dd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007e2:	e9 ce fd ff ff       	jmp    8005b5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e7:	83 f9 01             	cmp    $0x1,%ecx
  8007ea:	7e 10                	jle    8007fc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8d 50 08             	lea    0x8(%eax),%edx
  8007f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f5:	8b 30                	mov    (%eax),%esi
  8007f7:	8b 78 04             	mov    0x4(%eax),%edi
  8007fa:	eb 26                	jmp    800822 <vprintfmt+0x290>
	else if (lflag)
  8007fc:	85 c9                	test   %ecx,%ecx
  8007fe:	74 12                	je     800812 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 30                	mov    (%eax),%esi
  80080b:	89 f7                	mov    %esi,%edi
  80080d:	c1 ff 1f             	sar    $0x1f,%edi
  800810:	eb 10                	jmp    800822 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)
  80081b:	8b 30                	mov    (%eax),%esi
  80081d:	89 f7                	mov    %esi,%edi
  80081f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800822:	85 ff                	test   %edi,%edi
  800824:	78 0a                	js     800830 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800826:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082b:	e9 8c 00 00 00       	jmp    8008bc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800834:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80083b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80083e:	f7 de                	neg    %esi
  800840:	83 d7 00             	adc    $0x0,%edi
  800843:	f7 df                	neg    %edi
			}
			base = 10;
  800845:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084a:	eb 70                	jmp    8008bc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084c:	89 ca                	mov    %ecx,%edx
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
  800851:	e8 c0 fc ff ff       	call   800516 <getuint>
  800856:	89 c6                	mov    %eax,%esi
  800858:	89 d7                	mov    %edx,%edi
			base = 10;
  80085a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80085f:	eb 5b                	jmp    8008bc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800861:	89 ca                	mov    %ecx,%edx
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
  800866:	e8 ab fc ff ff       	call   800516 <getuint>
  80086b:	89 c6                	mov    %eax,%esi
  80086d:	89 d7                	mov    %edx,%edi
			base = 8;
  80086f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800874:	eb 46                	jmp    8008bc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800876:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800881:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800884:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800888:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8d 50 04             	lea    0x4(%eax),%edx
  800898:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80089b:	8b 30                	mov    (%eax),%esi
  80089d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008a7:	eb 13                	jmp    8008bc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a9:	89 ca                	mov    %ecx,%edx
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ae:	e8 63 fc ff ff       	call   800516 <getuint>
  8008b3:	89 c6                	mov    %eax,%esi
  8008b5:	89 d7                	mov    %edx,%edi
			base = 16;
  8008b7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008bc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008c0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008cf:	89 34 24             	mov    %esi,(%esp)
  8008d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d6:	89 da                	mov    %ebx,%edx
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	e8 6c fb ff ff       	call   80044c <printnum>
			break;
  8008e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008e3:	e9 cd fc ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ec:	89 04 24             	mov    %eax,(%esp)
  8008ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008f5:	e9 bb fc ff ff       	jmp    8005b5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800905:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800908:	eb 01                	jmp    80090b <vprintfmt+0x379>
  80090a:	4e                   	dec    %esi
  80090b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80090f:	75 f9                	jne    80090a <vprintfmt+0x378>
  800911:	e9 9f fc ff ff       	jmp    8005b5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800916:	83 c4 4c             	add    $0x4c,%esp
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 28             	sub    $0x28,%esp
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800931:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800934:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093b:	85 c0                	test   %eax,%eax
  80093d:	74 30                	je     80096f <vsnprintf+0x51>
  80093f:	85 d2                	test   %edx,%edx
  800941:	7e 33                	jle    800976 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800943:	8b 45 14             	mov    0x14(%ebp),%eax
  800946:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80094a:	8b 45 10             	mov    0x10(%ebp),%eax
  80094d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800951:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800954:	89 44 24 04          	mov    %eax,0x4(%esp)
  800958:	c7 04 24 50 05 80 00 	movl   $0x800550,(%esp)
  80095f:	e8 2e fc ff ff       	call   800592 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800964:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800967:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096d:	eb 0c                	jmp    80097b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80096f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800974:	eb 05                	jmp    80097b <vsnprintf+0x5d>
  800976:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800983:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800986:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098a:	8b 45 10             	mov    0x10(%ebp),%eax
  80098d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	89 44 24 04          	mov    %eax,0x4(%esp)
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	89 04 24             	mov    %eax,(%esp)
  80099e:	e8 7b ff ff ff       	call   80091e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    
  8009a5:	00 00                	add    %al,(%eax)
	...

008009a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	eb 01                	jmp    8009b6 <strlen+0xe>
		n++;
  8009b5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ba:	75 f9                	jne    8009b5 <strlen+0xd>
		n++;
	return n;
}
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8009c4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cc:	eb 01                	jmp    8009cf <strnlen+0x11>
		n++;
  8009ce:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cf:	39 d0                	cmp    %edx,%eax
  8009d1:	74 06                	je     8009d9 <strnlen+0x1b>
  8009d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009d7:	75 f5                	jne    8009ce <strnlen+0x10>
		n++;
	return n;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f0:	42                   	inc    %edx
  8009f1:	84 c9                	test   %cl,%cl
  8009f3:	75 f5                	jne    8009ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	53                   	push   %ebx
  8009fc:	83 ec 08             	sub    $0x8,%esp
  8009ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a02:	89 1c 24             	mov    %ebx,(%esp)
  800a05:	e8 9e ff ff ff       	call   8009a8 <strlen>
	strcpy(dst + len, src);
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a11:	01 d8                	add    %ebx,%eax
  800a13:	89 04 24             	mov    %eax,(%esp)
  800a16:	e8 c0 ff ff ff       	call   8009db <strcpy>
	return dst;
}
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	83 c4 08             	add    $0x8,%esp
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a36:	eb 0c                	jmp    800a44 <strncpy+0x21>
		*dst++ = *src;
  800a38:	8a 1a                	mov    (%edx),%bl
  800a3a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3d:	80 3a 01             	cmpb   $0x1,(%edx)
  800a40:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a43:	41                   	inc    %ecx
  800a44:	39 f1                	cmp    %esi,%ecx
  800a46:	75 f0                	jne    800a38 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	8b 75 08             	mov    0x8(%ebp),%esi
  800a54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a57:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5a:	85 d2                	test   %edx,%edx
  800a5c:	75 0a                	jne    800a68 <strlcpy+0x1c>
  800a5e:	89 f0                	mov    %esi,%eax
  800a60:	eb 1a                	jmp    800a7c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a62:	88 18                	mov    %bl,(%eax)
  800a64:	40                   	inc    %eax
  800a65:	41                   	inc    %ecx
  800a66:	eb 02                	jmp    800a6a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a68:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800a6a:	4a                   	dec    %edx
  800a6b:	74 0a                	je     800a77 <strlcpy+0x2b>
  800a6d:	8a 19                	mov    (%ecx),%bl
  800a6f:	84 db                	test   %bl,%bl
  800a71:	75 ef                	jne    800a62 <strlcpy+0x16>
  800a73:	89 c2                	mov    %eax,%edx
  800a75:	eb 02                	jmp    800a79 <strlcpy+0x2d>
  800a77:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a79:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a7c:	29 f0                	sub    %esi,%eax
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a88:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8b:	eb 02                	jmp    800a8f <strcmp+0xd>
		p++, q++;
  800a8d:	41                   	inc    %ecx
  800a8e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8f:	8a 01                	mov    (%ecx),%al
  800a91:	84 c0                	test   %al,%al
  800a93:	74 04                	je     800a99 <strcmp+0x17>
  800a95:	3a 02                	cmp    (%edx),%al
  800a97:	74 f4                	je     800a8d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a99:	0f b6 c0             	movzbl %al,%eax
  800a9c:	0f b6 12             	movzbl (%edx),%edx
  800a9f:	29 d0                	sub    %edx,%eax
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	53                   	push   %ebx
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aad:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800ab0:	eb 03                	jmp    800ab5 <strncmp+0x12>
		n--, p++, q++;
  800ab2:	4a                   	dec    %edx
  800ab3:	40                   	inc    %eax
  800ab4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab5:	85 d2                	test   %edx,%edx
  800ab7:	74 14                	je     800acd <strncmp+0x2a>
  800ab9:	8a 18                	mov    (%eax),%bl
  800abb:	84 db                	test   %bl,%bl
  800abd:	74 04                	je     800ac3 <strncmp+0x20>
  800abf:	3a 19                	cmp    (%ecx),%bl
  800ac1:	74 ef                	je     800ab2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac3:	0f b6 00             	movzbl (%eax),%eax
  800ac6:	0f b6 11             	movzbl (%ecx),%edx
  800ac9:	29 d0                	sub    %edx,%eax
  800acb:	eb 05                	jmp    800ad2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ade:	eb 05                	jmp    800ae5 <strchr+0x10>
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 0c                	je     800af0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae4:	40                   	inc    %eax
  800ae5:	8a 10                	mov    (%eax),%dl
  800ae7:	84 d2                	test   %dl,%dl
  800ae9:	75 f5                	jne    800ae0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800afb:	eb 05                	jmp    800b02 <strfind+0x10>
		if (*s == c)
  800afd:	38 ca                	cmp    %cl,%dl
  800aff:	74 07                	je     800b08 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b01:	40                   	inc    %eax
  800b02:	8a 10                	mov    (%eax),%dl
  800b04:	84 d2                	test   %dl,%dl
  800b06:	75 f5                	jne    800afd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b19:	85 c9                	test   %ecx,%ecx
  800b1b:	74 30                	je     800b4d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b23:	75 25                	jne    800b4a <memset+0x40>
  800b25:	f6 c1 03             	test   $0x3,%cl
  800b28:	75 20                	jne    800b4a <memset+0x40>
		c &= 0xFF;
  800b2a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	c1 e3 08             	shl    $0x8,%ebx
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	c1 e6 18             	shl    $0x18,%esi
  800b37:	89 d0                	mov    %edx,%eax
  800b39:	c1 e0 10             	shl    $0x10,%eax
  800b3c:	09 f0                	or     %esi,%eax
  800b3e:	09 d0                	or     %edx,%eax
  800b40:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b42:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b45:	fc                   	cld    
  800b46:	f3 ab                	rep stos %eax,%es:(%edi)
  800b48:	eb 03                	jmp    800b4d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4a:	fc                   	cld    
  800b4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4d:	89 f8                	mov    %edi,%eax
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b62:	39 c6                	cmp    %eax,%esi
  800b64:	73 34                	jae    800b9a <memmove+0x46>
  800b66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b69:	39 d0                	cmp    %edx,%eax
  800b6b:	73 2d                	jae    800b9a <memmove+0x46>
		s += n;
		d += n;
  800b6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b70:	f6 c2 03             	test   $0x3,%dl
  800b73:	75 1b                	jne    800b90 <memmove+0x3c>
  800b75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7b:	75 13                	jne    800b90 <memmove+0x3c>
  800b7d:	f6 c1 03             	test   $0x3,%cl
  800b80:	75 0e                	jne    800b90 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b82:	83 ef 04             	sub    $0x4,%edi
  800b85:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b88:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b8b:	fd                   	std    
  800b8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8e:	eb 07                	jmp    800b97 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b90:	4f                   	dec    %edi
  800b91:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b94:	fd                   	std    
  800b95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b97:	fc                   	cld    
  800b98:	eb 20                	jmp    800bba <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba0:	75 13                	jne    800bb5 <memmove+0x61>
  800ba2:	a8 03                	test   $0x3,%al
  800ba4:	75 0f                	jne    800bb5 <memmove+0x61>
  800ba6:	f6 c1 03             	test   $0x3,%cl
  800ba9:	75 0a                	jne    800bb5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bab:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bae:	89 c7                	mov    %eax,%edi
  800bb0:	fc                   	cld    
  800bb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb3:	eb 05                	jmp    800bba <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb5:	89 c7                	mov    %eax,%edi
  800bb7:	fc                   	cld    
  800bb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	89 04 24             	mov    %eax,(%esp)
  800bd8:	e8 77 ff ff ff       	call   800b54 <memmove>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	eb 16                	jmp    800c0b <memcmp+0x2c>
		if (*s1 != *s2)
  800bf5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800bf8:	42                   	inc    %edx
  800bf9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800bfd:	38 c8                	cmp    %cl,%al
  800bff:	74 0a                	je     800c0b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c01:	0f b6 c0             	movzbl %al,%eax
  800c04:	0f b6 c9             	movzbl %cl,%ecx
  800c07:	29 c8                	sub    %ecx,%eax
  800c09:	eb 09                	jmp    800c14 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0b:	39 da                	cmp    %ebx,%edx
  800c0d:	75 e6                	jne    800bf5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c22:	89 c2                	mov    %eax,%edx
  800c24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c27:	eb 05                	jmp    800c2e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c29:	38 08                	cmp    %cl,(%eax)
  800c2b:	74 05                	je     800c32 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2d:	40                   	inc    %eax
  800c2e:	39 d0                	cmp    %edx,%eax
  800c30:	72 f7                	jb     800c29 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c40:	eb 01                	jmp    800c43 <strtol+0xf>
		s++;
  800c42:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c43:	8a 02                	mov    (%edx),%al
  800c45:	3c 20                	cmp    $0x20,%al
  800c47:	74 f9                	je     800c42 <strtol+0xe>
  800c49:	3c 09                	cmp    $0x9,%al
  800c4b:	74 f5                	je     800c42 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4d:	3c 2b                	cmp    $0x2b,%al
  800c4f:	75 08                	jne    800c59 <strtol+0x25>
		s++;
  800c51:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c52:	bf 00 00 00 00       	mov    $0x0,%edi
  800c57:	eb 13                	jmp    800c6c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c59:	3c 2d                	cmp    $0x2d,%al
  800c5b:	75 0a                	jne    800c67 <strtol+0x33>
		s++, neg = 1;
  800c5d:	8d 52 01             	lea    0x1(%edx),%edx
  800c60:	bf 01 00 00 00       	mov    $0x1,%edi
  800c65:	eb 05                	jmp    800c6c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6c:	85 db                	test   %ebx,%ebx
  800c6e:	74 05                	je     800c75 <strtol+0x41>
  800c70:	83 fb 10             	cmp    $0x10,%ebx
  800c73:	75 28                	jne    800c9d <strtol+0x69>
  800c75:	8a 02                	mov    (%edx),%al
  800c77:	3c 30                	cmp    $0x30,%al
  800c79:	75 10                	jne    800c8b <strtol+0x57>
  800c7b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c7f:	75 0a                	jne    800c8b <strtol+0x57>
		s += 2, base = 16;
  800c81:	83 c2 02             	add    $0x2,%edx
  800c84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c89:	eb 12                	jmp    800c9d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c8b:	85 db                	test   %ebx,%ebx
  800c8d:	75 0e                	jne    800c9d <strtol+0x69>
  800c8f:	3c 30                	cmp    $0x30,%al
  800c91:	75 05                	jne    800c98 <strtol+0x64>
		s++, base = 8;
  800c93:	42                   	inc    %edx
  800c94:	b3 08                	mov    $0x8,%bl
  800c96:	eb 05                	jmp    800c9d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c98:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca4:	8a 0a                	mov    (%edx),%cl
  800ca6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ca9:	80 fb 09             	cmp    $0x9,%bl
  800cac:	77 08                	ja     800cb6 <strtol+0x82>
			dig = *s - '0';
  800cae:	0f be c9             	movsbl %cl,%ecx
  800cb1:	83 e9 30             	sub    $0x30,%ecx
  800cb4:	eb 1e                	jmp    800cd4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cb6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cb9:	80 fb 19             	cmp    $0x19,%bl
  800cbc:	77 08                	ja     800cc6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800cbe:	0f be c9             	movsbl %cl,%ecx
  800cc1:	83 e9 57             	sub    $0x57,%ecx
  800cc4:	eb 0e                	jmp    800cd4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cc6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cc9:	80 fb 19             	cmp    $0x19,%bl
  800ccc:	77 12                	ja     800ce0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800cce:	0f be c9             	movsbl %cl,%ecx
  800cd1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cd4:	39 f1                	cmp    %esi,%ecx
  800cd6:	7d 0c                	jge    800ce4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800cd8:	42                   	inc    %edx
  800cd9:	0f af c6             	imul   %esi,%eax
  800cdc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cde:	eb c4                	jmp    800ca4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ce0:	89 c1                	mov    %eax,%ecx
  800ce2:	eb 02                	jmp    800ce6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ce4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ce6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cea:	74 05                	je     800cf1 <strtol+0xbd>
		*endptr = (char *) s;
  800cec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cef:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cf1:	85 ff                	test   %edi,%edi
  800cf3:	74 04                	je     800cf9 <strtol+0xc5>
  800cf5:	89 c8                	mov    %ecx,%eax
  800cf7:	f7 d8                	neg    %eax
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
	...

00800d00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	89 c3                	mov    %eax,%ebx
  800d13:	89 c7                	mov    %eax,%edi
  800d15:	89 c6                	mov    %eax,%esi
  800d17:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	ba 00 00 00 00       	mov    $0x0,%edx
  800d29:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2e:	89 d1                	mov    %edx,%ecx
  800d30:	89 d3                	mov    %edx,%ebx
  800d32:	89 d7                	mov    %edx,%edi
  800d34:	89 d6                	mov    %edx,%esi
  800d36:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 cb                	mov    %ecx,%ebx
  800d55:	89 cf                	mov    %ecx,%edi
  800d57:	89 ce                	mov    %ecx,%esi
  800d59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 28                	jle    800d87 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d63:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d72:	00 
  800d73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7a:	00 
  800d7b:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d82:	e8 b1 f5 ff ff       	call   800338 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d87:	83 c4 2c             	add    $0x2c,%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 d3                	mov    %edx,%ebx
  800da3:	89 d7                	mov    %edx,%edi
  800da5:	89 d6                	mov    %edx,%esi
  800da7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_yield>:

void
sys_yield(void)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	ba 00 00 00 00       	mov    $0x0,%edx
  800db9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dbe:	89 d1                	mov    %edx,%ecx
  800dc0:	89 d3                	mov    %edx,%ebx
  800dc2:	89 d7                	mov    %edx,%edi
  800dc4:	89 d6                	mov    %edx,%esi
  800dc6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	be 00 00 00 00       	mov    $0x0,%esi
  800ddb:	b8 04 00 00 00       	mov    $0x4,%eax
  800de0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 f7                	mov    %esi,%edi
  800deb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 28                	jle    800e19 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e04:	00 
  800e05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0c:	00 
  800e0d:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e14:	e8 1f f5 ff ff       	call   800338 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e19:	83 c4 2c             	add    $0x2c,%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e2f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 28                	jle    800e6c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e48:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e4f:	00 
  800e50:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800e57:	00 
  800e58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5f:	00 
  800e60:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800e67:	e8 cc f4 ff ff       	call   800338 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e6c:	83 c4 2c             	add    $0x2c,%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e82:	b8 06 00 00 00       	mov    $0x6,%eax
  800e87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	89 df                	mov    %ebx,%edi
  800e8f:	89 de                	mov    %ebx,%esi
  800e91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e93:	85 c0                	test   %eax,%eax
  800e95:	7e 28                	jle    800ebf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800eaa:	00 
  800eab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb2:	00 
  800eb3:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800eba:	e8 79 f4 ff ff       	call   800338 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ebf:	83 c4 2c             	add    $0x2c,%esp
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed5:	b8 08 00 00 00       	mov    $0x8,%eax
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 df                	mov    %ebx,%edi
  800ee2:	89 de                	mov    %ebx,%esi
  800ee4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	7e 28                	jle    800f12 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eee:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800efd:	00 
  800efe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f05:	00 
  800f06:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f0d:	e8 26 f4 ff ff       	call   800338 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f12:	83 c4 2c             	add    $0x2c,%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f28:	b8 09 00 00 00       	mov    $0x9,%eax
  800f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	89 df                	mov    %ebx,%edi
  800f35:	89 de                	mov    %ebx,%esi
  800f37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	7e 28                	jle    800f65 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f41:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f48:	00 
  800f49:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800f50:	00 
  800f51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f58:	00 
  800f59:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800f60:	e8 d3 f3 ff ff       	call   800338 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f65:	83 c4 2c             	add    $0x2c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
  800f86:	89 df                	mov    %ebx,%edi
  800f88:	89 de                	mov    %ebx,%esi
  800f8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	7e 28                	jle    800fb8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f94:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800fb3:	e8 80 f3 ff ff       	call   800338 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fb8:	83 c4 2c             	add    $0x2c,%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	be 00 00 00 00       	mov    $0x0,%esi
  800fcb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ff6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff9:	89 cb                	mov    %ecx,%ebx
  800ffb:	89 cf                	mov    %ecx,%edi
  800ffd:	89 ce                	mov    %ecx,%esi
  800fff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	7e 28                	jle    80102d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801005:	89 44 24 10          	mov    %eax,0x10(%esp)
  801009:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801010:	00 
  801011:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  801028:	e8 0b f3 ff ff       	call   800338 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80102d:	83 c4 2c             	add    $0x2c,%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    
  801035:	00 00                	add    %al,(%eax)
	...

00801038 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	53                   	push   %ebx
  80103c:	83 ec 24             	sub    $0x24,%esp
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801042:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  801044:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801048:	75 2d                	jne    801077 <pgfault+0x3f>
  80104a:	89 d8                	mov    %ebx,%eax
  80104c:	c1 e8 0c             	shr    $0xc,%eax
  80104f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801056:	f6 c4 08             	test   $0x8,%ah
  801059:	75 1c                	jne    801077 <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  80105b:	c7 44 24 08 8c 29 80 	movl   $0x80298c,0x8(%esp)
  801062:	00 
  801063:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80106a:	00 
  80106b:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  801072:	e8 c1 f2 ff ff       	call   800338 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801077:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80107e:	00 
  80107f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801086:	00 
  801087:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108e:	e8 3a fd ff ff       	call   800dcd <sys_page_alloc>
  801093:	85 c0                	test   %eax,%eax
  801095:	79 20                	jns    8010b7 <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  801097:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109b:	c7 44 24 08 fb 29 80 	movl   $0x8029fb,0x8(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010aa:	00 
  8010ab:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8010b2:	e8 81 f2 ff ff       	call   800338 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  8010b7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  8010bd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010c4:	00 
  8010c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010d0:	e8 e9 fa ff ff       	call   800bbe <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  8010d5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010dc:	00 
  8010dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f8:	e8 24 fd ff ff       	call   800e21 <sys_page_map>
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	79 20                	jns    801121 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  801101:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801105:	c7 44 24 08 0e 2a 80 	movl   $0x802a0e,0x8(%esp)
  80110c:	00 
  80110d:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801114:	00 
  801115:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  80111c:	e8 17 f2 ff ff       	call   800338 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801121:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801128:	00 
  801129:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801130:	e8 3f fd ff ff       	call   800e74 <sys_page_unmap>
  801135:	85 c0                	test   %eax,%eax
  801137:	79 20                	jns    801159 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  801139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80113d:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  801144:	00 
  801145:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80114c:	00 
  80114d:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  801154:	e8 df f1 ff ff       	call   800338 <_panic>
}
  801159:	83 c4 24             	add    $0x24,%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	57                   	push   %edi
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
  801165:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  801168:	c7 04 24 38 10 80 00 	movl   $0x801038,(%esp)
  80116f:	e8 e4 0f 00 00       	call   802158 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801174:	ba 07 00 00 00       	mov    $0x7,%edx
  801179:	89 d0                	mov    %edx,%eax
  80117b:	cd 30                	int    $0x30
  80117d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801180:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  801183:	85 c0                	test   %eax,%eax
  801185:	79 1c                	jns    8011a3 <fork+0x44>
		panic("sys_exofork failed\n");
  801187:	c7 44 24 08 32 2a 80 	movl   $0x802a32,0x8(%esp)
  80118e:	00 
  80118f:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801196:	00 
  801197:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  80119e:	e8 95 f1 ff ff       	call   800338 <_panic>
	if(c_envid == 0){
  8011a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011a7:	75 25                	jne    8011ce <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011a9:	e8 e1 fb ff ff       	call   800d8f <sys_getenvid>
  8011ae:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011ba:	c1 e0 07             	shl    $0x7,%eax
  8011bd:	29 d0                	sub    %edx,%eax
  8011bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c4:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011c9:	e9 e3 01 00 00       	jmp    8013b1 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  8011ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  8011d3:	89 d8                	mov    %ebx,%eax
  8011d5:	c1 e8 16             	shr    $0x16,%eax
  8011d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011df:	a8 01                	test   $0x1,%al
  8011e1:	0f 84 0b 01 00 00    	je     8012f2 <fork+0x193>
  8011e7:	89 de                	mov    %ebx,%esi
  8011e9:	c1 ee 0c             	shr    $0xc,%esi
  8011ec:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011f3:	a8 05                	test   $0x5,%al
  8011f5:	0f 84 f7 00 00 00    	je     8012f2 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  8011fb:	89 f7                	mov    %esi,%edi
  8011fd:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  801200:	e8 8a fb ff ff       	call   800d8f <sys_getenvid>
  801205:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801208:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80120f:	a8 02                	test   $0x2,%al
  801211:	75 10                	jne    801223 <fork+0xc4>
  801213:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80121a:	f6 c4 08             	test   $0x8,%ah
  80121d:	0f 84 89 00 00 00    	je     8012ac <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  801223:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80122a:	00 
  80122b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801232:	89 44 24 08          	mov    %eax,0x8(%esp)
  801236:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80123a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80123d:	89 04 24             	mov    %eax,(%esp)
  801240:	e8 dc fb ff ff       	call   800e21 <sys_page_map>
  801245:	85 c0                	test   %eax,%eax
  801247:	79 20                	jns    801269 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124d:	c7 44 24 08 46 2a 80 	movl   $0x802a46,0x8(%esp)
  801254:	00 
  801255:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  80125c:	00 
  80125d:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  801264:	e8 cf f0 ff ff       	call   800338 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  801269:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801270:	00 
  801271:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801278:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801280:	89 04 24             	mov    %eax,(%esp)
  801283:	e8 99 fb ff ff       	call   800e21 <sys_page_map>
  801288:	85 c0                	test   %eax,%eax
  80128a:	79 66                	jns    8012f2 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  80128c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801290:	c7 44 24 08 46 2a 80 	movl   $0x802a46,0x8(%esp)
  801297:	00 
  801298:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  80129f:	00 
  8012a0:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8012a7:	e8 8c f0 ff ff       	call   800338 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  8012ac:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012b3:	00 
  8012b4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	e8 53 fb ff ff       	call   800e21 <sys_page_map>
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	79 20                	jns    8012f2 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  8012d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d6:	c7 44 24 08 46 2a 80 	movl   $0x802a46,0x8(%esp)
  8012dd:	00 
  8012de:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8012e5:	00 
  8012e6:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8012ed:	e8 46 f0 ff ff       	call   800338 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  8012f2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012f8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8012fe:	0f 85 cf fe ff ff    	jne    8011d3 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801304:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80130b:	00 
  80130c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801313:	ee 
  801314:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801317:	89 04 24             	mov    %eax,(%esp)
  80131a:	e8 ae fa ff ff       	call   800dcd <sys_page_alloc>
  80131f:	85 c0                	test   %eax,%eax
  801321:	79 20                	jns    801343 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  801323:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801327:	c7 44 24 08 58 2a 80 	movl   $0x802a58,0x8(%esp)
  80132e:	00 
  80132f:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801336:	00 
  801337:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  80133e:	e8 f5 ef ff ff       	call   800338 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801343:	c7 44 24 04 a4 21 80 	movl   $0x8021a4,0x4(%esp)
  80134a:	00 
  80134b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80134e:	89 04 24             	mov    %eax,(%esp)
  801351:	e8 17 fc ff ff       	call   800f6d <sys_env_set_pgfault_upcall>
  801356:	85 c0                	test   %eax,%eax
  801358:	79 20                	jns    80137a <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80135a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80135e:	c7 44 24 08 d0 29 80 	movl   $0x8029d0,0x8(%esp)
  801365:	00 
  801366:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80136d:	00 
  80136e:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  801375:	e8 be ef ff ff       	call   800338 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  80137a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801381:	00 
  801382:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801385:	89 04 24             	mov    %eax,(%esp)
  801388:	e8 3a fb ff ff       	call   800ec7 <sys_env_set_status>
  80138d:	85 c0                	test   %eax,%eax
  80138f:	79 20                	jns    8013b1 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  801391:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801395:	c7 44 24 08 6c 2a 80 	movl   $0x802a6c,0x8(%esp)
  80139c:	00 
  80139d:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8013a4:	00 
  8013a5:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8013ac:	e8 87 ef ff ff       	call   800338 <_panic>
 
	return c_envid;	
}
  8013b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013b4:	83 c4 3c             	add    $0x3c,%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5f                   	pop    %edi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <sfork>:

// Challenge!
int
sfork(void)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013c2:	c7 44 24 08 84 2a 80 	movl   $0x802a84,0x8(%esp)
  8013c9:	00 
  8013ca:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8013d1:	00 
  8013d2:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8013d9:	e8 5a ef ff ff       	call   800338 <_panic>
	...

008013e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f9:	89 04 24             	mov    %eax,(%esp)
  8013fc:	e8 df ff ff ff       	call   8013e0 <fd2num>
  801401:	05 20 00 0d 00       	add    $0xd0020,%eax
  801406:	c1 e0 0c             	shl    $0xc,%eax
}
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801412:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801417:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801419:	89 c2                	mov    %eax,%edx
  80141b:	c1 ea 16             	shr    $0x16,%edx
  80141e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801425:	f6 c2 01             	test   $0x1,%dl
  801428:	74 11                	je     80143b <fd_alloc+0x30>
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	c1 ea 0c             	shr    $0xc,%edx
  80142f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801436:	f6 c2 01             	test   $0x1,%dl
  801439:	75 09                	jne    801444 <fd_alloc+0x39>
			*fd_store = fd;
  80143b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
  801442:	eb 17                	jmp    80145b <fd_alloc+0x50>
  801444:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801449:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80144e:	75 c7                	jne    801417 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801450:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801456:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80145b:	5b                   	pop    %ebx
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801464:	83 f8 1f             	cmp    $0x1f,%eax
  801467:	77 36                	ja     80149f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801469:	05 00 00 0d 00       	add    $0xd0000,%eax
  80146e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801471:	89 c2                	mov    %eax,%edx
  801473:	c1 ea 16             	shr    $0x16,%edx
  801476:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147d:	f6 c2 01             	test   $0x1,%dl
  801480:	74 24                	je     8014a6 <fd_lookup+0x48>
  801482:	89 c2                	mov    %eax,%edx
  801484:	c1 ea 0c             	shr    $0xc,%edx
  801487:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148e:	f6 c2 01             	test   $0x1,%dl
  801491:	74 1a                	je     8014ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801493:	8b 55 0c             	mov    0xc(%ebp),%edx
  801496:	89 02                	mov    %eax,(%edx)
	return 0;
  801498:	b8 00 00 00 00       	mov    $0x0,%eax
  80149d:	eb 13                	jmp    8014b2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80149f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a4:	eb 0c                	jmp    8014b2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ab:	eb 05                	jmp    8014b2 <fd_lookup+0x54>
  8014ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 14             	sub    $0x14,%esp
  8014bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8014c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c6:	eb 0e                	jmp    8014d6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8014c8:	39 08                	cmp    %ecx,(%eax)
  8014ca:	75 09                	jne    8014d5 <dev_lookup+0x21>
			*dev = devtab[i];
  8014cc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d3:	eb 33                	jmp    801508 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014d5:	42                   	inc    %edx
  8014d6:	8b 04 95 1c 2b 80 00 	mov    0x802b1c(,%edx,4),%eax
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	75 e7                	jne    8014c8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e6:	8b 40 48             	mov    0x48(%eax),%eax
  8014e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f1:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  8014f8:	e8 33 ef ff ff       	call   800430 <cprintf>
	*dev = 0;
  8014fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801503:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801508:	83 c4 14             	add    $0x14,%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5d                   	pop    %ebp
  80150d:	c3                   	ret    

0080150e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
  801513:	83 ec 30             	sub    $0x30,%esp
  801516:	8b 75 08             	mov    0x8(%ebp),%esi
  801519:	8a 45 0c             	mov    0xc(%ebp),%al
  80151c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80151f:	89 34 24             	mov    %esi,(%esp)
  801522:	e8 b9 fe ff ff       	call   8013e0 <fd2num>
  801527:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80152a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	e8 28 ff ff ff       	call   80145e <fd_lookup>
  801536:	89 c3                	mov    %eax,%ebx
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 05                	js     801541 <fd_close+0x33>
	    || fd != fd2)
  80153c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80153f:	74 0d                	je     80154e <fd_close+0x40>
		return (must_exist ? r : 0);
  801541:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801545:	75 46                	jne    80158d <fd_close+0x7f>
  801547:	bb 00 00 00 00       	mov    $0x0,%ebx
  80154c:	eb 3f                	jmp    80158d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	89 44 24 04          	mov    %eax,0x4(%esp)
  801555:	8b 06                	mov    (%esi),%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 55 ff ff ff       	call   8014b4 <dev_lookup>
  80155f:	89 c3                	mov    %eax,%ebx
  801561:	85 c0                	test   %eax,%eax
  801563:	78 18                	js     80157d <fd_close+0x6f>
		if (dev->dev_close)
  801565:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801568:	8b 40 10             	mov    0x10(%eax),%eax
  80156b:	85 c0                	test   %eax,%eax
  80156d:	74 09                	je     801578 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80156f:	89 34 24             	mov    %esi,(%esp)
  801572:	ff d0                	call   *%eax
  801574:	89 c3                	mov    %eax,%ebx
  801576:	eb 05                	jmp    80157d <fd_close+0x6f>
		else
			r = 0;
  801578:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80157d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801581:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801588:	e8 e7 f8 ff ff       	call   800e74 <sys_page_unmap>
	return r;
}
  80158d:	89 d8                	mov    %ebx,%eax
  80158f:	83 c4 30             	add    $0x30,%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	89 04 24             	mov    %eax,(%esp)
  8015a9:	e8 b0 fe ff ff       	call   80145e <fd_lookup>
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 13                	js     8015c5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015b9:	00 
  8015ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bd:	89 04 24             	mov    %eax,(%esp)
  8015c0:	e8 49 ff ff ff       	call   80150e <fd_close>
}
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <close_all>:

void
close_all(void)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015d3:	89 1c 24             	mov    %ebx,(%esp)
  8015d6:	e8 bb ff ff ff       	call   801596 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015db:	43                   	inc    %ebx
  8015dc:	83 fb 20             	cmp    $0x20,%ebx
  8015df:	75 f2                	jne    8015d3 <close_all+0xc>
		close(i);
}
  8015e1:	83 c4 14             	add    $0x14,%esp
  8015e4:	5b                   	pop    %ebx
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	57                   	push   %edi
  8015eb:	56                   	push   %esi
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 4c             	sub    $0x4c,%esp
  8015f0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	89 04 24             	mov    %eax,(%esp)
  801600:	e8 59 fe ff ff       	call   80145e <fd_lookup>
  801605:	89 c3                	mov    %eax,%ebx
  801607:	85 c0                	test   %eax,%eax
  801609:	0f 88 e1 00 00 00    	js     8016f0 <dup+0x109>
		return r;
	close(newfdnum);
  80160f:	89 3c 24             	mov    %edi,(%esp)
  801612:	e8 7f ff ff ff       	call   801596 <close>

	newfd = INDEX2FD(newfdnum);
  801617:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80161d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801623:	89 04 24             	mov    %eax,(%esp)
  801626:	e8 c5 fd ff ff       	call   8013f0 <fd2data>
  80162b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80162d:	89 34 24             	mov    %esi,(%esp)
  801630:	e8 bb fd ff ff       	call   8013f0 <fd2data>
  801635:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801638:	89 d8                	mov    %ebx,%eax
  80163a:	c1 e8 16             	shr    $0x16,%eax
  80163d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801644:	a8 01                	test   $0x1,%al
  801646:	74 46                	je     80168e <dup+0xa7>
  801648:	89 d8                	mov    %ebx,%eax
  80164a:	c1 e8 0c             	shr    $0xc,%eax
  80164d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801654:	f6 c2 01             	test   $0x1,%dl
  801657:	74 35                	je     80168e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801659:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801660:	25 07 0e 00 00       	and    $0xe07,%eax
  801665:	89 44 24 10          	mov    %eax,0x10(%esp)
  801669:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80166c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801670:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801677:	00 
  801678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80167c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801683:	e8 99 f7 ff ff       	call   800e21 <sys_page_map>
  801688:	89 c3                	mov    %eax,%ebx
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 3b                	js     8016c9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80168e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801691:	89 c2                	mov    %eax,%edx
  801693:	c1 ea 0c             	shr    $0xc,%edx
  801696:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80169d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016a3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016a7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016b2:	00 
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016be:	e8 5e f7 ff ff       	call   800e21 <sys_page_map>
  8016c3:	89 c3                	mov    %eax,%ebx
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	79 25                	jns    8016ee <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d4:	e8 9b f7 ff ff       	call   800e74 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e7:	e8 88 f7 ff ff       	call   800e74 <sys_page_unmap>
	return r;
  8016ec:	eb 02                	jmp    8016f0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016ee:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	83 c4 4c             	add    $0x4c,%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 24             	sub    $0x24,%esp
  801701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	89 1c 24             	mov    %ebx,(%esp)
  80170e:	e8 4b fd ff ff       	call   80145e <fd_lookup>
  801713:	85 c0                	test   %eax,%eax
  801715:	78 6d                	js     801784 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801717:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801721:	8b 00                	mov    (%eax),%eax
  801723:	89 04 24             	mov    %eax,(%esp)
  801726:	e8 89 fd ff ff       	call   8014b4 <dev_lookup>
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 55                	js     801784 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801732:	8b 50 08             	mov    0x8(%eax),%edx
  801735:	83 e2 03             	and    $0x3,%edx
  801738:	83 fa 01             	cmp    $0x1,%edx
  80173b:	75 23                	jne    801760 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80173d:	a1 04 40 80 00       	mov    0x804004,%eax
  801742:	8b 40 48             	mov    0x48(%eax),%eax
  801745:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174d:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801754:	e8 d7 ec ff ff       	call   800430 <cprintf>
		return -E_INVAL;
  801759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175e:	eb 24                	jmp    801784 <read+0x8a>
	}
	if (!dev->dev_read)
  801760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801763:	8b 52 08             	mov    0x8(%edx),%edx
  801766:	85 d2                	test   %edx,%edx
  801768:	74 15                	je     80177f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80176a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80176d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801774:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801778:	89 04 24             	mov    %eax,(%esp)
  80177b:	ff d2                	call   *%edx
  80177d:	eb 05                	jmp    801784 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80177f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801784:	83 c4 24             	add    $0x24,%esp
  801787:	5b                   	pop    %ebx
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	57                   	push   %edi
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	83 ec 1c             	sub    $0x1c,%esp
  801793:	8b 7d 08             	mov    0x8(%ebp),%edi
  801796:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801799:	bb 00 00 00 00       	mov    $0x0,%ebx
  80179e:	eb 23                	jmp    8017c3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a0:	89 f0                	mov    %esi,%eax
  8017a2:	29 d8                	sub    %ebx,%eax
  8017a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ab:	01 d8                	add    %ebx,%eax
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	89 3c 24             	mov    %edi,(%esp)
  8017b4:	e8 41 ff ff ff       	call   8016fa <read>
		if (m < 0)
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 10                	js     8017cd <readn+0x43>
			return m;
		if (m == 0)
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	74 0a                	je     8017cb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c1:	01 c3                	add    %eax,%ebx
  8017c3:	39 f3                	cmp    %esi,%ebx
  8017c5:	72 d9                	jb     8017a0 <readn+0x16>
  8017c7:	89 d8                	mov    %ebx,%eax
  8017c9:	eb 02                	jmp    8017cd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017cb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017cd:	83 c4 1c             	add    $0x1c,%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5f                   	pop    %edi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 24             	sub    $0x24,%esp
  8017dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e6:	89 1c 24             	mov    %ebx,(%esp)
  8017e9:	e8 70 fc ff ff       	call   80145e <fd_lookup>
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 68                	js     80185a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fc:	8b 00                	mov    (%eax),%eax
  8017fe:	89 04 24             	mov    %eax,(%esp)
  801801:	e8 ae fc ff ff       	call   8014b4 <dev_lookup>
  801806:	85 c0                	test   %eax,%eax
  801808:	78 50                	js     80185a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801811:	75 23                	jne    801836 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801813:	a1 04 40 80 00       	mov    0x804004,%eax
  801818:	8b 40 48             	mov    0x48(%eax),%eax
  80181b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  80182a:	e8 01 ec ff ff       	call   800430 <cprintf>
		return -E_INVAL;
  80182f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801834:	eb 24                	jmp    80185a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801836:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801839:	8b 52 0c             	mov    0xc(%edx),%edx
  80183c:	85 d2                	test   %edx,%edx
  80183e:	74 15                	je     801855 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801840:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801843:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80184e:	89 04 24             	mov    %eax,(%esp)
  801851:	ff d2                	call   *%edx
  801853:	eb 05                	jmp    80185a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801855:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80185a:	83 c4 24             	add    $0x24,%esp
  80185d:	5b                   	pop    %ebx
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <seek>:

int
seek(int fdnum, off_t offset)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801866:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	89 04 24             	mov    %eax,(%esp)
  801873:	e8 e6 fb ff ff       	call   80145e <fd_lookup>
  801878:	85 c0                	test   %eax,%eax
  80187a:	78 0e                	js     80188a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80187c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80187f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801882:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801885:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	53                   	push   %ebx
  801890:	83 ec 24             	sub    $0x24,%esp
  801893:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801896:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189d:	89 1c 24             	mov    %ebx,(%esp)
  8018a0:	e8 b9 fb ff ff       	call   80145e <fd_lookup>
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 61                	js     80190a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b3:	8b 00                	mov    (%eax),%eax
  8018b5:	89 04 24             	mov    %eax,(%esp)
  8018b8:	e8 f7 fb ff ff       	call   8014b4 <dev_lookup>
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 49                	js     80190a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c8:	75 23                	jne    8018ed <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018ca:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018cf:	8b 40 48             	mov    0x48(%eax),%eax
  8018d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018da:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  8018e1:	e8 4a eb ff ff       	call   800430 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018eb:	eb 1d                	jmp    80190a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f0:	8b 52 18             	mov    0x18(%edx),%edx
  8018f3:	85 d2                	test   %edx,%edx
  8018f5:	74 0e                	je     801905 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	ff d2                	call   *%edx
  801903:	eb 05                	jmp    80190a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801905:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80190a:	83 c4 24             	add    $0x24,%esp
  80190d:	5b                   	pop    %ebx
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	53                   	push   %ebx
  801914:	83 ec 24             	sub    $0x24,%esp
  801917:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	89 04 24             	mov    %eax,(%esp)
  801927:	e8 32 fb ff ff       	call   80145e <fd_lookup>
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 52                	js     801982 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801930:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801933:	89 44 24 04          	mov    %eax,0x4(%esp)
  801937:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193a:	8b 00                	mov    (%eax),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 70 fb ff ff       	call   8014b4 <dev_lookup>
  801944:	85 c0                	test   %eax,%eax
  801946:	78 3a                	js     801982 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80194f:	74 2c                	je     80197d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801951:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801954:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80195b:	00 00 00 
	stat->st_isdir = 0;
  80195e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801965:	00 00 00 
	stat->st_dev = dev;
  801968:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80196e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801972:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801975:	89 14 24             	mov    %edx,(%esp)
  801978:	ff 50 14             	call   *0x14(%eax)
  80197b:	eb 05                	jmp    801982 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80197d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801982:	83 c4 24             	add    $0x24,%esp
  801985:	5b                   	pop    %ebx
  801986:	5d                   	pop    %ebp
  801987:	c3                   	ret    

00801988 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801990:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801997:	00 
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	89 04 24             	mov    %eax,(%esp)
  80199e:	e8 fe 01 00 00       	call   801ba1 <open>
  8019a3:	89 c3                	mov    %eax,%ebx
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 1b                	js     8019c4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b0:	89 1c 24             	mov    %ebx,(%esp)
  8019b3:	e8 58 ff ff ff       	call   801910 <fstat>
  8019b8:	89 c6                	mov    %eax,%esi
	close(fd);
  8019ba:	89 1c 24             	mov    %ebx,(%esp)
  8019bd:	e8 d4 fb ff ff       	call   801596 <close>
	return r;
  8019c2:	89 f3                	mov    %esi,%ebx
}
  8019c4:	89 d8                	mov    %ebx,%eax
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	5b                   	pop    %ebx
  8019ca:	5e                   	pop    %esi
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    
  8019cd:	00 00                	add    %al,(%eax)
	...

008019d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	83 ec 10             	sub    $0x10,%esp
  8019d8:	89 c3                	mov    %eax,%ebx
  8019da:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019dc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019e3:	75 11                	jne    8019f6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019ec:	e8 ae 08 00 00       	call   80229f <ipc_find_env>
  8019f1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019f6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019fd:	00 
  8019fe:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a05:	00 
  801a06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a0f:	89 04 24             	mov    %eax,(%esp)
  801a12:	e8 1e 08 00 00       	call   802235 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a1e:	00 
  801a1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a2a:	e8 9d 07 00 00       	call   8021cc <ipc_recv>
}
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	5b                   	pop    %ebx
  801a33:	5e                   	pop    %esi
  801a34:	5d                   	pop    %ebp
  801a35:	c3                   	ret    

00801a36 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a54:	b8 02 00 00 00       	mov    $0x2,%eax
  801a59:	e8 72 ff ff ff       	call   8019d0 <fsipc>
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a66:	8b 45 08             	mov    0x8(%ebp),%eax
  801a69:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 06 00 00 00       	mov    $0x6,%eax
  801a7b:	e8 50 ff ff ff       	call   8019d0 <fsipc>
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	83 ec 14             	sub    $0x14,%esp
  801a89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a92:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a97:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9c:	b8 05 00 00 00       	mov    $0x5,%eax
  801aa1:	e8 2a ff ff ff       	call   8019d0 <fsipc>
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	78 2b                	js     801ad5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aaa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ab1:	00 
  801ab2:	89 1c 24             	mov    %ebx,(%esp)
  801ab5:	e8 21 ef ff ff       	call   8009db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aba:	a1 80 50 80 00       	mov    0x805080,%eax
  801abf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ac5:	a1 84 50 80 00       	mov    0x805084,%eax
  801aca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad5:	83 c4 14             	add    $0x14,%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801ae1:	c7 44 24 08 2c 2b 80 	movl   $0x802b2c,0x8(%esp)
  801ae8:	00 
  801ae9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801af0:	00 
  801af1:	c7 04 24 4a 2b 80 00 	movl   $0x802b4a,(%esp)
  801af8:	e8 3b e8 ff ff       	call   800338 <_panic>

00801afd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 10             	sub    $0x10,%esp
  801b05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b08:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b23:	e8 a8 fe ff ff       	call   8019d0 <fsipc>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	78 6a                	js     801b98 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b2e:	39 c6                	cmp    %eax,%esi
  801b30:	73 24                	jae    801b56 <devfile_read+0x59>
  801b32:	c7 44 24 0c 55 2b 80 	movl   $0x802b55,0xc(%esp)
  801b39:	00 
  801b3a:	c7 44 24 08 5c 2b 80 	movl   $0x802b5c,0x8(%esp)
  801b41:	00 
  801b42:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b49:	00 
  801b4a:	c7 04 24 4a 2b 80 00 	movl   $0x802b4a,(%esp)
  801b51:	e8 e2 e7 ff ff       	call   800338 <_panic>
	assert(r <= PGSIZE);
  801b56:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b5b:	7e 24                	jle    801b81 <devfile_read+0x84>
  801b5d:	c7 44 24 0c 71 2b 80 	movl   $0x802b71,0xc(%esp)
  801b64:	00 
  801b65:	c7 44 24 08 5c 2b 80 	movl   $0x802b5c,0x8(%esp)
  801b6c:	00 
  801b6d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b74:	00 
  801b75:	c7 04 24 4a 2b 80 00 	movl   $0x802b4a,(%esp)
  801b7c:	e8 b7 e7 ff ff       	call   800338 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b81:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b85:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b8c:	00 
  801b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b90:	89 04 24             	mov    %eax,(%esp)
  801b93:	e8 bc ef ff ff       	call   800b54 <memmove>
	return r;
}
  801b98:	89 d8                	mov    %ebx,%eax
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 20             	sub    $0x20,%esp
  801ba9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bac:	89 34 24             	mov    %esi,(%esp)
  801baf:	e8 f4 ed ff ff       	call   8009a8 <strlen>
  801bb4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bb9:	7f 60                	jg     801c1b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbe:	89 04 24             	mov    %eax,(%esp)
  801bc1:	e8 45 f8 ff ff       	call   80140b <fd_alloc>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 54                	js     801c20 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bcc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bd0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bd7:	e8 ff ed ff ff       	call   8009db <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bec:	e8 df fd ff ff       	call   8019d0 <fsipc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	79 15                	jns    801c0c <open+0x6b>
		fd_close(fd, 0);
  801bf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bfe:	00 
  801bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c02:	89 04 24             	mov    %eax,(%esp)
  801c05:	e8 04 f9 ff ff       	call   80150e <fd_close>
		return r;
  801c0a:	eb 14                	jmp    801c20 <open+0x7f>
	}

	return fd2num(fd);
  801c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0f:	89 04 24             	mov    %eax,(%esp)
  801c12:	e8 c9 f7 ff ff       	call   8013e0 <fd2num>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	eb 05                	jmp    801c20 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c1b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	83 c4 20             	add    $0x20,%esp
  801c25:	5b                   	pop    %ebx
  801c26:	5e                   	pop    %esi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c34:	b8 08 00 00 00       	mov    $0x8,%eax
  801c39:	e8 92 fd ff ff       	call   8019d0 <fsipc>
}
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	56                   	push   %esi
  801c44:	53                   	push   %ebx
  801c45:	83 ec 10             	sub    $0x10,%esp
  801c48:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	89 04 24             	mov    %eax,(%esp)
  801c51:	e8 9a f7 ff ff       	call   8013f0 <fd2data>
  801c56:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c58:	c7 44 24 04 7d 2b 80 	movl   $0x802b7d,0x4(%esp)
  801c5f:	00 
  801c60:	89 34 24             	mov    %esi,(%esp)
  801c63:	e8 73 ed ff ff       	call   8009db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c68:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6b:	2b 03                	sub    (%ebx),%eax
  801c6d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c73:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c7a:	00 00 00 
	stat->st_dev = &devpipe;
  801c7d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c84:	30 80 00 
	return 0;
}
  801c87:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	53                   	push   %ebx
  801c97:	83 ec 14             	sub    $0x14,%esp
  801c9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca8:	e8 c7 f1 ff ff       	call   800e74 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cad:	89 1c 24             	mov    %ebx,(%esp)
  801cb0:	e8 3b f7 ff ff       	call   8013f0 <fd2data>
  801cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc0:	e8 af f1 ff ff       	call   800e74 <sys_page_unmap>
}
  801cc5:	83 c4 14             	add    $0x14,%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	57                   	push   %edi
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
  801cd1:	83 ec 2c             	sub    $0x2c,%esp
  801cd4:	89 c7                	mov    %eax,%edi
  801cd6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cd9:	a1 04 40 80 00       	mov    0x804004,%eax
  801cde:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ce1:	89 3c 24             	mov    %edi,(%esp)
  801ce4:	e8 fb 05 00 00       	call   8022e4 <pageref>
  801ce9:	89 c6                	mov    %eax,%esi
  801ceb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cee:	89 04 24             	mov    %eax,(%esp)
  801cf1:	e8 ee 05 00 00       	call   8022e4 <pageref>
  801cf6:	39 c6                	cmp    %eax,%esi
  801cf8:	0f 94 c0             	sete   %al
  801cfb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cfe:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d07:	39 cb                	cmp    %ecx,%ebx
  801d09:	75 08                	jne    801d13 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d0b:	83 c4 2c             	add    $0x2c,%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d13:	83 f8 01             	cmp    $0x1,%eax
  801d16:	75 c1                	jne    801cd9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d18:	8b 42 58             	mov    0x58(%edx),%eax
  801d1b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d22:	00 
  801d23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d2b:	c7 04 24 84 2b 80 00 	movl   $0x802b84,(%esp)
  801d32:	e8 f9 e6 ff ff       	call   800430 <cprintf>
  801d37:	eb a0                	jmp    801cd9 <_pipeisclosed+0xe>

00801d39 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	57                   	push   %edi
  801d3d:	56                   	push   %esi
  801d3e:	53                   	push   %ebx
  801d3f:	83 ec 1c             	sub    $0x1c,%esp
  801d42:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d45:	89 34 24             	mov    %esi,(%esp)
  801d48:	e8 a3 f6 ff ff       	call   8013f0 <fd2data>
  801d4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d4f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d54:	eb 3c                	jmp    801d92 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d56:	89 da                	mov    %ebx,%edx
  801d58:	89 f0                	mov    %esi,%eax
  801d5a:	e8 6c ff ff ff       	call   801ccb <_pipeisclosed>
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	75 38                	jne    801d9b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d63:	e8 46 f0 ff ff       	call   800dae <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d68:	8b 43 04             	mov    0x4(%ebx),%eax
  801d6b:	8b 13                	mov    (%ebx),%edx
  801d6d:	83 c2 20             	add    $0x20,%edx
  801d70:	39 d0                	cmp    %edx,%eax
  801d72:	73 e2                	jae    801d56 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d77:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d7a:	89 c2                	mov    %eax,%edx
  801d7c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d82:	79 05                	jns    801d89 <devpipe_write+0x50>
  801d84:	4a                   	dec    %edx
  801d85:	83 ca e0             	or     $0xffffffe0,%edx
  801d88:	42                   	inc    %edx
  801d89:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d8d:	40                   	inc    %eax
  801d8e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d91:	47                   	inc    %edi
  801d92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d95:	75 d1                	jne    801d68 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d97:	89 f8                	mov    %edi,%eax
  801d99:	eb 05                	jmp    801da0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801da0:	83 c4 1c             	add    $0x1c,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	57                   	push   %edi
  801dac:	56                   	push   %esi
  801dad:	53                   	push   %ebx
  801dae:	83 ec 1c             	sub    $0x1c,%esp
  801db1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801db4:	89 3c 24             	mov    %edi,(%esp)
  801db7:	e8 34 f6 ff ff       	call   8013f0 <fd2data>
  801dbc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbe:	be 00 00 00 00       	mov    $0x0,%esi
  801dc3:	eb 3a                	jmp    801dff <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dc5:	85 f6                	test   %esi,%esi
  801dc7:	74 04                	je     801dcd <devpipe_read+0x25>
				return i;
  801dc9:	89 f0                	mov    %esi,%eax
  801dcb:	eb 40                	jmp    801e0d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dcd:	89 da                	mov    %ebx,%edx
  801dcf:	89 f8                	mov    %edi,%eax
  801dd1:	e8 f5 fe ff ff       	call   801ccb <_pipeisclosed>
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	75 2e                	jne    801e08 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dda:	e8 cf ef ff ff       	call   800dae <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ddf:	8b 03                	mov    (%ebx),%eax
  801de1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801de4:	74 df                	je     801dc5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801de6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801deb:	79 05                	jns    801df2 <devpipe_read+0x4a>
  801ded:	48                   	dec    %eax
  801dee:	83 c8 e0             	or     $0xffffffe0,%eax
  801df1:	40                   	inc    %eax
  801df2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801df6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dfc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dfe:	46                   	inc    %esi
  801dff:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e02:	75 db                	jne    801ddf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e04:	89 f0                	mov    %esi,%eax
  801e06:	eb 05                	jmp    801e0d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e0d:	83 c4 1c             	add    $0x1c,%esp
  801e10:	5b                   	pop    %ebx
  801e11:	5e                   	pop    %esi
  801e12:	5f                   	pop    %edi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    

00801e15 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	57                   	push   %edi
  801e19:	56                   	push   %esi
  801e1a:	53                   	push   %ebx
  801e1b:	83 ec 3c             	sub    $0x3c,%esp
  801e1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e24:	89 04 24             	mov    %eax,(%esp)
  801e27:	e8 df f5 ff ff       	call   80140b <fd_alloc>
  801e2c:	89 c3                	mov    %eax,%ebx
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	0f 88 45 01 00 00    	js     801f7b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e3d:	00 
  801e3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4c:	e8 7c ef ff ff       	call   800dcd <sys_page_alloc>
  801e51:	89 c3                	mov    %eax,%ebx
  801e53:	85 c0                	test   %eax,%eax
  801e55:	0f 88 20 01 00 00    	js     801f7b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e5b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e5e:	89 04 24             	mov    %eax,(%esp)
  801e61:	e8 a5 f5 ff ff       	call   80140b <fd_alloc>
  801e66:	89 c3                	mov    %eax,%ebx
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	0f 88 f8 00 00 00    	js     801f68 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e70:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e77:	00 
  801e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e86:	e8 42 ef ff ff       	call   800dcd <sys_page_alloc>
  801e8b:	89 c3                	mov    %eax,%ebx
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	0f 88 d3 00 00 00    	js     801f68 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e98:	89 04 24             	mov    %eax,(%esp)
  801e9b:	e8 50 f5 ff ff       	call   8013f0 <fd2data>
  801ea0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ea9:	00 
  801eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb5:	e8 13 ef ff ff       	call   800dcd <sys_page_alloc>
  801eba:	89 c3                	mov    %eax,%ebx
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	0f 88 91 00 00 00    	js     801f55 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec7:	89 04 24             	mov    %eax,(%esp)
  801eca:	e8 21 f5 ff ff       	call   8013f0 <fd2data>
  801ecf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ed6:	00 
  801ed7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801edb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ee2:	00 
  801ee3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eee:	e8 2e ef ff ff       	call   800e21 <sys_page_map>
  801ef3:	89 c3                	mov    %eax,%ebx
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	78 4c                	js     801f45 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ef9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f02:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f0e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f14:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f17:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f19:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f1c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f26:	89 04 24             	mov    %eax,(%esp)
  801f29:	e8 b2 f4 ff ff       	call   8013e0 <fd2num>
  801f2e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f33:	89 04 24             	mov    %eax,(%esp)
  801f36:	e8 a5 f4 ff ff       	call   8013e0 <fd2num>
  801f3b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f43:	eb 36                	jmp    801f7b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f50:	e8 1f ef ff ff       	call   800e74 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f63:	e8 0c ef ff ff       	call   800e74 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f76:	e8 f9 ee ff ff       	call   800e74 <sys_page_unmap>
    err:
	return r;
}
  801f7b:	89 d8                	mov    %ebx,%eax
  801f7d:	83 c4 3c             	add    $0x3c,%esp
  801f80:	5b                   	pop    %ebx
  801f81:	5e                   	pop    %esi
  801f82:	5f                   	pop    %edi
  801f83:	5d                   	pop    %ebp
  801f84:	c3                   	ret    

00801f85 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 c1 f4 ff ff       	call   80145e <fd_lookup>
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 15                	js     801fb6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa4:	89 04 24             	mov    %eax,(%esp)
  801fa7:	e8 44 f4 ff ff       	call   8013f0 <fd2data>
	return _pipeisclosed(fd, p);
  801fac:	89 c2                	mov    %eax,%edx
  801fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb1:	e8 15 fd ff ff       	call   801ccb <_pipeisclosed>
}
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc0:	5d                   	pop    %ebp
  801fc1:	c3                   	ret    

00801fc2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fc8:	c7 44 24 04 97 2b 80 	movl   $0x802b97,0x4(%esp)
  801fcf:	00 
  801fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd3:	89 04 24             	mov    %eax,(%esp)
  801fd6:	e8 00 ea ff ff       	call   8009db <strcpy>
	return 0;
}
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	57                   	push   %edi
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fee:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff9:	eb 30                	jmp    80202b <devcons_write+0x49>
		m = n - tot;
  801ffb:	8b 75 10             	mov    0x10(%ebp),%esi
  801ffe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802000:	83 fe 7f             	cmp    $0x7f,%esi
  802003:	76 05                	jbe    80200a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802005:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80200a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80200e:	03 45 0c             	add    0xc(%ebp),%eax
  802011:	89 44 24 04          	mov    %eax,0x4(%esp)
  802015:	89 3c 24             	mov    %edi,(%esp)
  802018:	e8 37 eb ff ff       	call   800b54 <memmove>
		sys_cputs(buf, m);
  80201d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802021:	89 3c 24             	mov    %edi,(%esp)
  802024:	e8 d7 ec ff ff       	call   800d00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802029:	01 f3                	add    %esi,%ebx
  80202b:	89 d8                	mov    %ebx,%eax
  80202d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802030:	72 c9                	jb     801ffb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802032:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5f                   	pop    %edi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    

0080203d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802043:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802047:	75 07                	jne    802050 <devcons_read+0x13>
  802049:	eb 25                	jmp    802070 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80204b:	e8 5e ed ff ff       	call   800dae <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802050:	e8 c9 ec ff ff       	call   800d1e <sys_cgetc>
  802055:	85 c0                	test   %eax,%eax
  802057:	74 f2                	je     80204b <devcons_read+0xe>
  802059:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80205b:	85 c0                	test   %eax,%eax
  80205d:	78 1d                	js     80207c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80205f:	83 f8 04             	cmp    $0x4,%eax
  802062:	74 13                	je     802077 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802064:	8b 45 0c             	mov    0xc(%ebp),%eax
  802067:	88 10                	mov    %dl,(%eax)
	return 1;
  802069:	b8 01 00 00 00       	mov    $0x1,%eax
  80206e:	eb 0c                	jmp    80207c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802070:	b8 00 00 00 00       	mov    $0x0,%eax
  802075:	eb 05                	jmp    80207c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80207c:	c9                   	leave  
  80207d:	c3                   	ret    

0080207e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802084:	8b 45 08             	mov    0x8(%ebp),%eax
  802087:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80208a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802091:	00 
  802092:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802095:	89 04 24             	mov    %eax,(%esp)
  802098:	e8 63 ec ff ff       	call   800d00 <sys_cputs>
}
  80209d:	c9                   	leave  
  80209e:	c3                   	ret    

0080209f <getchar>:

int
getchar(void)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020ac:	00 
  8020ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020bb:	e8 3a f6 ff ff       	call   8016fa <read>
	if (r < 0)
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	78 0f                	js     8020d3 <getchar+0x34>
		return r;
	if (r < 1)
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	7e 06                	jle    8020ce <getchar+0x2f>
		return -E_EOF;
	return c;
  8020c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020cc:	eb 05                	jmp    8020d3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020d3:	c9                   	leave  
  8020d4:	c3                   	ret    

008020d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 71 f3 ff ff       	call   80145e <fd_lookup>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 11                	js     802102 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020fa:	39 10                	cmp    %edx,(%eax)
  8020fc:	0f 94 c0             	sete   %al
  8020ff:	0f b6 c0             	movzbl %al,%eax
}
  802102:	c9                   	leave  
  802103:	c3                   	ret    

00802104 <opencons>:

int
opencons(void)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80210a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210d:	89 04 24             	mov    %eax,(%esp)
  802110:	e8 f6 f2 ff ff       	call   80140b <fd_alloc>
  802115:	85 c0                	test   %eax,%eax
  802117:	78 3c                	js     802155 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802119:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802120:	00 
  802121:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802124:	89 44 24 04          	mov    %eax,0x4(%esp)
  802128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80212f:	e8 99 ec ff ff       	call   800dcd <sys_page_alloc>
  802134:	85 c0                	test   %eax,%eax
  802136:	78 1d                	js     802155 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802138:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80213e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802141:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802146:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80214d:	89 04 24             	mov    %eax,(%esp)
  802150:	e8 8b f2 ff ff       	call   8013e0 <fd2num>
}
  802155:	c9                   	leave  
  802156:	c3                   	ret    
	...

00802158 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80215e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802165:	75 32                	jne    802199 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802167:	e8 23 ec ff ff       	call   800d8f <sys_getenvid>
  80216c:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  802173:	00 
  802174:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80217b:	ee 
  80217c:	89 04 24             	mov    %eax,(%esp)
  80217f:	e8 49 ec ff ff       	call   800dcd <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  802184:	e8 06 ec ff ff       	call   800d8f <sys_getenvid>
  802189:	c7 44 24 04 a4 21 80 	movl   $0x8021a4,0x4(%esp)
  802190:	00 
  802191:	89 04 24             	mov    %eax,(%esp)
  802194:	e8 d4 ed ff ff       	call   800f6d <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802199:	8b 45 08             	mov    0x8(%ebp),%eax
  80219c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021a1:	c9                   	leave  
  8021a2:	c3                   	ret    
	...

008021a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021a5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021ac:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  8021af:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  8021b3:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  8021b6:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  8021bb:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  8021bf:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  8021c2:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  8021c3:	83 c4 04             	add    $0x4,%esp
	popfl
  8021c6:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  8021c7:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  8021c8:	c3                   	ret    
  8021c9:	00 00                	add    %al,(%eax)
	...

008021cc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	57                   	push   %edi
  8021d0:	56                   	push   %esi
  8021d1:	53                   	push   %ebx
  8021d2:	83 ec 1c             	sub    $0x1c,%esp
  8021d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8021d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8021db:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8021de:	85 db                	test   %ebx,%ebx
  8021e0:	75 05                	jne    8021e7 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8021e2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8021e7:	89 1c 24             	mov    %ebx,(%esp)
  8021ea:	e8 f4 ed ff ff       	call   800fe3 <sys_ipc_recv>
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	79 16                	jns    802209 <ipc_recv+0x3d>
		*from_env_store = 0;
  8021f3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8021f9:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  8021ff:	89 1c 24             	mov    %ebx,(%esp)
  802202:	e8 dc ed ff ff       	call   800fe3 <sys_ipc_recv>
  802207:	eb 24                	jmp    80222d <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  802209:	85 f6                	test   %esi,%esi
  80220b:	74 0a                	je     802217 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  80220d:	a1 04 40 80 00       	mov    0x804004,%eax
  802212:	8b 40 74             	mov    0x74(%eax),%eax
  802215:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802217:	85 ff                	test   %edi,%edi
  802219:	74 0a                	je     802225 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  80221b:	a1 04 40 80 00       	mov    0x804004,%eax
  802220:	8b 40 78             	mov    0x78(%eax),%eax
  802223:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  802225:	a1 04 40 80 00       	mov    0x804004,%eax
  80222a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80222d:	83 c4 1c             	add    $0x1c,%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	57                   	push   %edi
  802239:	56                   	push   %esi
  80223a:	53                   	push   %ebx
  80223b:	83 ec 1c             	sub    $0x1c,%esp
  80223e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802241:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802244:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802247:	85 db                	test   %ebx,%ebx
  802249:	75 05                	jne    802250 <ipc_send+0x1b>
		pg = (void *)-1;
  80224b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802250:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802258:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80225c:	8b 45 08             	mov    0x8(%ebp),%eax
  80225f:	89 04 24             	mov    %eax,(%esp)
  802262:	e8 59 ed ff ff       	call   800fc0 <sys_ipc_try_send>
		if (r == 0) {		
  802267:	85 c0                	test   %eax,%eax
  802269:	74 2c                	je     802297 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80226b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80226e:	75 07                	jne    802277 <ipc_send+0x42>
			sys_yield();
  802270:	e8 39 eb ff ff       	call   800dae <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  802275:	eb d9                	jmp    802250 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  802277:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227b:	c7 44 24 08 a3 2b 80 	movl   $0x802ba3,0x8(%esp)
  802282:	00 
  802283:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80228a:	00 
  80228b:	c7 04 24 b1 2b 80 00 	movl   $0x802bb1,(%esp)
  802292:	e8 a1 e0 ff ff       	call   800338 <_panic>
		}
	}
}
  802297:	83 c4 1c             	add    $0x1c,%esp
  80229a:	5b                   	pop    %ebx
  80229b:	5e                   	pop    %esi
  80229c:	5f                   	pop    %edi
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    

0080229f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	53                   	push   %ebx
  8022a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8022a6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022ab:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8022b2:	89 c2                	mov    %eax,%edx
  8022b4:	c1 e2 07             	shl    $0x7,%edx
  8022b7:	29 ca                	sub    %ecx,%edx
  8022b9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022bf:	8b 52 50             	mov    0x50(%edx),%edx
  8022c2:	39 da                	cmp    %ebx,%edx
  8022c4:	75 0f                	jne    8022d5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8022c6:	c1 e0 07             	shl    $0x7,%eax
  8022c9:	29 c8                	sub    %ecx,%eax
  8022cb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022d0:	8b 40 40             	mov    0x40(%eax),%eax
  8022d3:	eb 0c                	jmp    8022e1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022d5:	40                   	inc    %eax
  8022d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022db:	75 ce                	jne    8022ab <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022dd:	66 b8 00 00          	mov    $0x0,%ax
}
  8022e1:	5b                   	pop    %ebx
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    

008022e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ea:	89 c2                	mov    %eax,%edx
  8022ec:	c1 ea 16             	shr    $0x16,%edx
  8022ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022f6:	f6 c2 01             	test   $0x1,%dl
  8022f9:	74 1e                	je     802319 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022fb:	c1 e8 0c             	shr    $0xc,%eax
  8022fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802305:	a8 01                	test   $0x1,%al
  802307:	74 17                	je     802320 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802309:	c1 e8 0c             	shr    $0xc,%eax
  80230c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802313:	ef 
  802314:	0f b7 c0             	movzwl %ax,%eax
  802317:	eb 0c                	jmp    802325 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802319:	b8 00 00 00 00       	mov    $0x0,%eax
  80231e:	eb 05                	jmp    802325 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802320:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802325:	5d                   	pop    %ebp
  802326:	c3                   	ret    
	...

00802328 <__udivdi3>:
  802328:	55                   	push   %ebp
  802329:	57                   	push   %edi
  80232a:	56                   	push   %esi
  80232b:	83 ec 10             	sub    $0x10,%esp
  80232e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802332:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80233e:	89 cd                	mov    %ecx,%ebp
  802340:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802344:	85 c0                	test   %eax,%eax
  802346:	75 2c                	jne    802374 <__udivdi3+0x4c>
  802348:	39 f9                	cmp    %edi,%ecx
  80234a:	77 68                	ja     8023b4 <__udivdi3+0x8c>
  80234c:	85 c9                	test   %ecx,%ecx
  80234e:	75 0b                	jne    80235b <__udivdi3+0x33>
  802350:	b8 01 00 00 00       	mov    $0x1,%eax
  802355:	31 d2                	xor    %edx,%edx
  802357:	f7 f1                	div    %ecx
  802359:	89 c1                	mov    %eax,%ecx
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	89 f8                	mov    %edi,%eax
  80235f:	f7 f1                	div    %ecx
  802361:	89 c7                	mov    %eax,%edi
  802363:	89 f0                	mov    %esi,%eax
  802365:	f7 f1                	div    %ecx
  802367:	89 c6                	mov    %eax,%esi
  802369:	89 f0                	mov    %esi,%eax
  80236b:	89 fa                	mov    %edi,%edx
  80236d:	83 c4 10             	add    $0x10,%esp
  802370:	5e                   	pop    %esi
  802371:	5f                   	pop    %edi
  802372:	5d                   	pop    %ebp
  802373:	c3                   	ret    
  802374:	39 f8                	cmp    %edi,%eax
  802376:	77 2c                	ja     8023a4 <__udivdi3+0x7c>
  802378:	0f bd f0             	bsr    %eax,%esi
  80237b:	83 f6 1f             	xor    $0x1f,%esi
  80237e:	75 4c                	jne    8023cc <__udivdi3+0xa4>
  802380:	39 f8                	cmp    %edi,%eax
  802382:	bf 00 00 00 00       	mov    $0x0,%edi
  802387:	72 0a                	jb     802393 <__udivdi3+0x6b>
  802389:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80238d:	0f 87 ad 00 00 00    	ja     802440 <__udivdi3+0x118>
  802393:	be 01 00 00 00       	mov    $0x1,%esi
  802398:	89 f0                	mov    %esi,%eax
  80239a:	89 fa                	mov    %edi,%edx
  80239c:	83 c4 10             	add    $0x10,%esp
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    
  8023a3:	90                   	nop
  8023a4:	31 ff                	xor    %edi,%edi
  8023a6:	31 f6                	xor    %esi,%esi
  8023a8:	89 f0                	mov    %esi,%eax
  8023aa:	89 fa                	mov    %edi,%edx
  8023ac:	83 c4 10             	add    $0x10,%esp
  8023af:	5e                   	pop    %esi
  8023b0:	5f                   	pop    %edi
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
  8023b3:	90                   	nop
  8023b4:	89 fa                	mov    %edi,%edx
  8023b6:	89 f0                	mov    %esi,%eax
  8023b8:	f7 f1                	div    %ecx
  8023ba:	89 c6                	mov    %eax,%esi
  8023bc:	31 ff                	xor    %edi,%edi
  8023be:	89 f0                	mov    %esi,%eax
  8023c0:	89 fa                	mov    %edi,%edx
  8023c2:	83 c4 10             	add    $0x10,%esp
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
  8023c9:	8d 76 00             	lea    0x0(%esi),%esi
  8023cc:	89 f1                	mov    %esi,%ecx
  8023ce:	d3 e0                	shl    %cl,%eax
  8023d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8023d9:	29 f0                	sub    %esi,%eax
  8023db:	89 ea                	mov    %ebp,%edx
  8023dd:	88 c1                	mov    %al,%cl
  8023df:	d3 ea                	shr    %cl,%edx
  8023e1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023e5:	09 ca                	or     %ecx,%edx
  8023e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023eb:	89 f1                	mov    %esi,%ecx
  8023ed:	d3 e5                	shl    %cl,%ebp
  8023ef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8023f3:	89 fd                	mov    %edi,%ebp
  8023f5:	88 c1                	mov    %al,%cl
  8023f7:	d3 ed                	shr    %cl,%ebp
  8023f9:	89 fa                	mov    %edi,%edx
  8023fb:	89 f1                	mov    %esi,%ecx
  8023fd:	d3 e2                	shl    %cl,%edx
  8023ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802403:	88 c1                	mov    %al,%cl
  802405:	d3 ef                	shr    %cl,%edi
  802407:	09 d7                	or     %edx,%edi
  802409:	89 f8                	mov    %edi,%eax
  80240b:	89 ea                	mov    %ebp,%edx
  80240d:	f7 74 24 08          	divl   0x8(%esp)
  802411:	89 d1                	mov    %edx,%ecx
  802413:	89 c7                	mov    %eax,%edi
  802415:	f7 64 24 0c          	mull   0xc(%esp)
  802419:	39 d1                	cmp    %edx,%ecx
  80241b:	72 17                	jb     802434 <__udivdi3+0x10c>
  80241d:	74 09                	je     802428 <__udivdi3+0x100>
  80241f:	89 fe                	mov    %edi,%esi
  802421:	31 ff                	xor    %edi,%edi
  802423:	e9 41 ff ff ff       	jmp    802369 <__udivdi3+0x41>
  802428:	8b 54 24 04          	mov    0x4(%esp),%edx
  80242c:	89 f1                	mov    %esi,%ecx
  80242e:	d3 e2                	shl    %cl,%edx
  802430:	39 c2                	cmp    %eax,%edx
  802432:	73 eb                	jae    80241f <__udivdi3+0xf7>
  802434:	8d 77 ff             	lea    -0x1(%edi),%esi
  802437:	31 ff                	xor    %edi,%edi
  802439:	e9 2b ff ff ff       	jmp    802369 <__udivdi3+0x41>
  80243e:	66 90                	xchg   %ax,%ax
  802440:	31 f6                	xor    %esi,%esi
  802442:	e9 22 ff ff ff       	jmp    802369 <__udivdi3+0x41>
	...

00802448 <__umoddi3>:
  802448:	55                   	push   %ebp
  802449:	57                   	push   %edi
  80244a:	56                   	push   %esi
  80244b:	83 ec 20             	sub    $0x20,%esp
  80244e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802452:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802456:	89 44 24 14          	mov    %eax,0x14(%esp)
  80245a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80245e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802462:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802466:	89 c7                	mov    %eax,%edi
  802468:	89 f2                	mov    %esi,%edx
  80246a:	85 ed                	test   %ebp,%ebp
  80246c:	75 16                	jne    802484 <__umoddi3+0x3c>
  80246e:	39 f1                	cmp    %esi,%ecx
  802470:	0f 86 a6 00 00 00    	jbe    80251c <__umoddi3+0xd4>
  802476:	f7 f1                	div    %ecx
  802478:	89 d0                	mov    %edx,%eax
  80247a:	31 d2                	xor    %edx,%edx
  80247c:	83 c4 20             	add    $0x20,%esp
  80247f:	5e                   	pop    %esi
  802480:	5f                   	pop    %edi
  802481:	5d                   	pop    %ebp
  802482:	c3                   	ret    
  802483:	90                   	nop
  802484:	39 f5                	cmp    %esi,%ebp
  802486:	0f 87 ac 00 00 00    	ja     802538 <__umoddi3+0xf0>
  80248c:	0f bd c5             	bsr    %ebp,%eax
  80248f:	83 f0 1f             	xor    $0x1f,%eax
  802492:	89 44 24 10          	mov    %eax,0x10(%esp)
  802496:	0f 84 a8 00 00 00    	je     802544 <__umoddi3+0xfc>
  80249c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024a0:	d3 e5                	shl    %cl,%ebp
  8024a2:	bf 20 00 00 00       	mov    $0x20,%edi
  8024a7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8024ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024af:	89 f9                	mov    %edi,%ecx
  8024b1:	d3 e8                	shr    %cl,%eax
  8024b3:	09 e8                	or     %ebp,%eax
  8024b5:	89 44 24 18          	mov    %eax,0x18(%esp)
  8024b9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024bd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024c1:	d3 e0                	shl    %cl,%eax
  8024c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024c7:	89 f2                	mov    %esi,%edx
  8024c9:	d3 e2                	shl    %cl,%edx
  8024cb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024cf:	d3 e0                	shl    %cl,%eax
  8024d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8024d5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024d9:	89 f9                	mov    %edi,%ecx
  8024db:	d3 e8                	shr    %cl,%eax
  8024dd:	09 d0                	or     %edx,%eax
  8024df:	d3 ee                	shr    %cl,%esi
  8024e1:	89 f2                	mov    %esi,%edx
  8024e3:	f7 74 24 18          	divl   0x18(%esp)
  8024e7:	89 d6                	mov    %edx,%esi
  8024e9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ed:	89 c5                	mov    %eax,%ebp
  8024ef:	89 d1                	mov    %edx,%ecx
  8024f1:	39 d6                	cmp    %edx,%esi
  8024f3:	72 67                	jb     80255c <__umoddi3+0x114>
  8024f5:	74 75                	je     80256c <__umoddi3+0x124>
  8024f7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024fb:	29 e8                	sub    %ebp,%eax
  8024fd:	19 ce                	sbb    %ecx,%esi
  8024ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802503:	d3 e8                	shr    %cl,%eax
  802505:	89 f2                	mov    %esi,%edx
  802507:	89 f9                	mov    %edi,%ecx
  802509:	d3 e2                	shl    %cl,%edx
  80250b:	09 d0                	or     %edx,%eax
  80250d:	89 f2                	mov    %esi,%edx
  80250f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802513:	d3 ea                	shr    %cl,%edx
  802515:	83 c4 20             	add    $0x20,%esp
  802518:	5e                   	pop    %esi
  802519:	5f                   	pop    %edi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    
  80251c:	85 c9                	test   %ecx,%ecx
  80251e:	75 0b                	jne    80252b <__umoddi3+0xe3>
  802520:	b8 01 00 00 00       	mov    $0x1,%eax
  802525:	31 d2                	xor    %edx,%edx
  802527:	f7 f1                	div    %ecx
  802529:	89 c1                	mov    %eax,%ecx
  80252b:	89 f0                	mov    %esi,%eax
  80252d:	31 d2                	xor    %edx,%edx
  80252f:	f7 f1                	div    %ecx
  802531:	89 f8                	mov    %edi,%eax
  802533:	e9 3e ff ff ff       	jmp    802476 <__umoddi3+0x2e>
  802538:	89 f2                	mov    %esi,%edx
  80253a:	83 c4 20             	add    $0x20,%esp
  80253d:	5e                   	pop    %esi
  80253e:	5f                   	pop    %edi
  80253f:	5d                   	pop    %ebp
  802540:	c3                   	ret    
  802541:	8d 76 00             	lea    0x0(%esi),%esi
  802544:	39 f5                	cmp    %esi,%ebp
  802546:	72 04                	jb     80254c <__umoddi3+0x104>
  802548:	39 f9                	cmp    %edi,%ecx
  80254a:	77 06                	ja     802552 <__umoddi3+0x10a>
  80254c:	89 f2                	mov    %esi,%edx
  80254e:	29 cf                	sub    %ecx,%edi
  802550:	19 ea                	sbb    %ebp,%edx
  802552:	89 f8                	mov    %edi,%eax
  802554:	83 c4 20             	add    $0x20,%esp
  802557:	5e                   	pop    %esi
  802558:	5f                   	pop    %edi
  802559:	5d                   	pop    %ebp
  80255a:	c3                   	ret    
  80255b:	90                   	nop
  80255c:	89 d1                	mov    %edx,%ecx
  80255e:	89 c5                	mov    %eax,%ebp
  802560:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802564:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802568:	eb 8d                	jmp    8024f7 <__umoddi3+0xaf>
  80256a:	66 90                	xchg   %ax,%ax
  80256c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802570:	72 ea                	jb     80255c <__umoddi3+0x114>
  802572:	89 f1                	mov    %esi,%ecx
  802574:	eb 81                	jmp    8024f7 <__umoddi3+0xaf>
