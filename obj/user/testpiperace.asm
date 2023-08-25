
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 ff 01 00 00       	call   800230 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003c:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  800043:	e8 50 03 00 00       	call   800398 <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 86 1e 00 00       	call   801ed9 <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 f9 24 80 	movl   $0x8024f9,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  800072:	e8 29 02 00 00       	call   8002a0 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800077:	e8 4b 10 00 00       	call   8010c7 <fork>
  80007c:	89 c6                	mov    %eax,%esi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 16 25 80 	movl   $0x802516,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  80009d:	e8 fe 01 00 00       	call   8002a0 <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 54                	jne    8000fa <umain+0xc6>
		close(p[1]);
  8000a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 65 15 00 00       	call   801616 <close>
  8000b1:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 88 1f 00 00       	call   802049 <pipeisclosed>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	74 11                	je     8000d6 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000c5:	c7 04 24 1f 25 80 00 	movl   $0x80251f,(%esp)
  8000cc:	e8 c7 02 00 00       	call   800398 <cprintf>
				exit();
  8000d1:	e8 ae 01 00 00       	call   800284 <exit>
			}
			sys_yield();
  8000d6:	e8 3b 0c 00 00       	call   800d16 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000db:	4b                   	dec    %ebx
  8000dc:	75 d8                	jne    8000b6 <umain+0x82>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 4e 12 00 00       	call   801348 <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000fe:	c7 04 24 3a 25 80 00 	movl   $0x80253a,(%esp)
  800105:	e8 8e 02 00 00       	call   800398 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  80010a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800110:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800117:	c1 e6 07             	shl    $0x7,%esi
  80011a:	29 c6                	sub    %eax,%esi
	cprintf("kid is %d\n", kid-envs);
  80011c:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800122:	c1 fe 02             	sar    $0x2,%esi
  800125:	89 f2                	mov    %esi,%edx
  800127:	c1 e2 05             	shl    $0x5,%edx
  80012a:	89 f0                	mov    %esi,%eax
  80012c:	c1 e0 0a             	shl    $0xa,%eax
  80012f:	01 d0                	add    %edx,%eax
  800131:	01 f0                	add    %esi,%eax
  800133:	89 c2                	mov    %eax,%edx
  800135:	c1 e2 0f             	shl    $0xf,%edx
  800138:	01 d0                	add    %edx,%eax
  80013a:	c1 e0 05             	shl    $0x5,%eax
  80013d:	01 c6                	add    %eax,%esi
  80013f:	f7 de                	neg    %esi
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	c7 04 24 45 25 80 00 	movl   $0x802545,(%esp)
  80014c:	e8 47 02 00 00       	call   800398 <cprintf>
	dup(p[0], 10);
  800151:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800158:	00 
  800159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 03 15 00 00       	call   801667 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800164:	eb 13                	jmp    800179 <umain+0x145>
		dup(p[0], 10);
  800166:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80016d:	00 
  80016e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 ee 14 00 00       	call   801667 <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800179:	8b 43 54             	mov    0x54(%ebx),%eax
  80017c:	83 f8 02             	cmp    $0x2,%eax
  80017f:	74 e5                	je     800166 <umain+0x132>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800181:	c7 04 24 50 25 80 00 	movl   $0x802550,(%esp)
  800188:	e8 0b 02 00 00       	call   800398 <cprintf>
	if (pipeisclosed(p[0]))
  80018d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 b1 1e 00 00       	call   802049 <pipeisclosed>
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 1c                	je     8001b8 <umain+0x184>
		panic("somehow the other end of p[0] got closed!");
  80019c:	c7 44 24 08 ac 25 80 	movl   $0x8025ac,0x8(%esp)
  8001a3:	00 
  8001a4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8001ab:	00 
  8001ac:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  8001b3:	e8 e8 00 00 00       	call   8002a0 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 14 13 00 00       	call   8014de <fd_lookup>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <umain+0x1ba>
		panic("cannot look up p[0]: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 66 25 80 	movl   $0x802566,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  8001e9:	e8 b2 00 00 00       	call   8002a0 <_panic>
	va = fd2data(fd);
  8001ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 77 12 00 00       	call   801470 <fd2data>
	if (pageref(va) != 3+1)
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 bf 1a 00 00       	call   801cc0 <pageref>
  800201:	83 f8 04             	cmp    $0x4,%eax
  800204:	74 0e                	je     800214 <umain+0x1e0>
		cprintf("\nchild detected race\n");
  800206:	c7 04 24 7e 25 80 00 	movl   $0x80257e,(%esp)
  80020d:	e8 86 01 00 00       	call   800398 <cprintf>
  800212:	eb 14                	jmp    800228 <umain+0x1f4>
	else
		cprintf("\nrace didn't happen\n", max);
  800214:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 94 25 80 00 	movl   $0x802594,(%esp)
  800223:	e8 70 01 00 00       	call   800398 <cprintf>
}
  800228:	83 c4 20             	add    $0x20,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    
	...

00800230 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 10             	sub    $0x10,%esp
  800238:	8b 75 08             	mov    0x8(%ebp),%esi
  80023b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  80023e:	e8 b4 0a 00 00       	call   800cf7 <sys_getenvid>
  800243:	25 ff 03 00 00       	and    $0x3ff,%eax
  800248:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80024f:	c1 e0 07             	shl    $0x7,%eax
  800252:	29 d0                	sub    %edx,%eax
  800254:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800259:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025e:	85 f6                	test   %esi,%esi
  800260:	7e 07                	jle    800269 <libmain+0x39>
		binaryname = argv[0];
  800262:	8b 03                	mov    (%ebx),%eax
  800264:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800269:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	e8 bf fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800275:	e8 0a 00 00 00       	call   800284 <exit>
}
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
  800281:	00 00                	add    %al,(%eax)
	...

00800284 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80028a:	e8 b8 13 00 00       	call   801647 <close_all>
	sys_env_destroy(0);
  80028f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800296:	e8 0a 0a 00 00       	call   800ca5 <sys_env_destroy>
}
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ab:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002b1:	e8 41 0a 00 00       	call   800cf7 <sys_getenvid>
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  8002d3:	e8 c0 00 00 00       	call   800398 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	e8 50 00 00 00       	call   800337 <vcprintf>
	cprintf("\n");
  8002e7:	c7 04 24 f7 24 80 00 	movl   $0x8024f7,(%esp)
  8002ee:	e8 a5 00 00 00       	call   800398 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f3:	cc                   	int3   
  8002f4:	eb fd                	jmp    8002f3 <_panic+0x53>
	...

008002f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 14             	sub    $0x14,%esp
  8002ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800302:	8b 03                	mov    (%ebx),%eax
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030b:	40                   	inc    %eax
  80030c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800313:	75 19                	jne    80032e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800315:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80031c:	00 
  80031d:	8d 43 08             	lea    0x8(%ebx),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	e8 40 09 00 00       	call   800c68 <sys_cputs>
		b->idx = 0;
  800328:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80032e:	ff 43 04             	incl   0x4(%ebx)
}
  800331:	83 c4 14             	add    $0x14,%esp
  800334:	5b                   	pop    %ebx
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800340:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800347:	00 00 00 
	b.cnt = 0;
  80034a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800351:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800362:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036c:	c7 04 24 f8 02 80 00 	movl   $0x8002f8,(%esp)
  800373:	e8 82 01 00 00       	call   8004fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800378:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80037e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800382:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	e8 d8 08 00 00       	call   800c68 <sys_cputs>

	return b.cnt;
}
  800390:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 87 ff ff ff       	call   800337 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    
	...

008003b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 3c             	sub    $0x3c,%esp
  8003bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c0:	89 d7                	mov    %edx,%edi
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	75 08                	jne    8003e0 <printnum+0x2c>
  8003d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003de:	77 57                	ja     800437 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003e4:	4b                   	dec    %ebx
  8003e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ff:	00 
  800400:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800403:	89 04 24             	mov    %eax,(%esp)
  800406:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040d:	e8 7e 1e 00 00       	call   802290 <__udivdi3>
  800412:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800416:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800421:	89 fa                	mov    %edi,%edx
  800423:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800426:	e8 89 ff ff ff       	call   8003b4 <printnum>
  80042b:	eb 0f                	jmp    80043c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80042d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800431:	89 34 24             	mov    %esi,(%esp)
  800434:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800437:	4b                   	dec    %ebx
  800438:	85 db                	test   %ebx,%ebx
  80043a:	7f f1                	jg     80042d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800440:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800444:	8b 45 10             	mov    0x10(%ebp),%eax
  800447:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800452:	00 
  800453:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800456:	89 04 24             	mov    %eax,(%esp)
  800459:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	e8 4b 1f 00 00       	call   8023b0 <__umoddi3>
  800465:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800469:	0f be 80 03 26 80 00 	movsbl 0x802603(%eax),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800476:	83 c4 3c             	add    $0x3c,%esp
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7e 0e                	jle    800494 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800486:	8b 10                	mov    (%eax),%edx
  800488:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048b:	89 08                	mov    %ecx,(%eax)
  80048d:	8b 02                	mov    (%edx),%eax
  80048f:	8b 52 04             	mov    0x4(%edx),%edx
  800492:	eb 22                	jmp    8004b6 <getuint+0x38>
	else if (lflag)
  800494:	85 d2                	test   %edx,%edx
  800496:	74 10                	je     8004a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	eb 0e                	jmp    8004b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004c1:	8b 10                	mov    (%eax),%edx
  8004c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c6:	73 08                	jae    8004d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8004c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cb:	88 0a                	mov    %cl,(%edx)
  8004cd:	42                   	inc    %edx
  8004ce:	89 10                	mov    %edx,(%eax)
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004df:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 02 00 00 00       	call   8004fa <vprintfmt>
	va_end(ap);
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	57                   	push   %edi
  8004fe:	56                   	push   %esi
  8004ff:	53                   	push   %ebx
  800500:	83 ec 4c             	sub    $0x4c,%esp
  800503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800506:	8b 75 10             	mov    0x10(%ebp),%esi
  800509:	eb 12                	jmp    80051d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050b:	85 c0                	test   %eax,%eax
  80050d:	0f 84 6b 03 00 00    	je     80087e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800513:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800517:	89 04 24             	mov    %eax,(%esp)
  80051a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80051d:	0f b6 06             	movzbl (%esi),%eax
  800520:	46                   	inc    %esi
  800521:	83 f8 25             	cmp    $0x25,%eax
  800524:	75 e5                	jne    80050b <vprintfmt+0x11>
  800526:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80052a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800531:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800536:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80053d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800542:	eb 26                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800547:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80054b:	eb 1d                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800550:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800554:	eb 14                	jmp    80056a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800559:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800560:	eb 08                	jmp    80056a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800562:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800565:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	0f b6 06             	movzbl (%esi),%eax
  80056d:	8d 56 01             	lea    0x1(%esi),%edx
  800570:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800573:	8a 16                	mov    (%esi),%dl
  800575:	83 ea 23             	sub    $0x23,%edx
  800578:	80 fa 55             	cmp    $0x55,%dl
  80057b:	0f 87 e1 02 00 00    	ja     800862 <vprintfmt+0x368>
  800581:	0f b6 d2             	movzbl %dl,%edx
  800584:	ff 24 95 40 27 80 00 	jmp    *0x802740(,%edx,4)
  80058b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800593:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800596:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80059a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80059d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005a0:	83 fa 09             	cmp    $0x9,%edx
  8005a3:	77 2a                	ja     8005cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a6:	eb eb                	jmp    800593 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b6:	eb 17                	jmp    8005cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bc:	78 98                	js     800556 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c1:	eb a7                	jmp    80056a <vprintfmt+0x70>
  8005c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005cd:	eb 9b                	jmp    80056a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d3:	79 95                	jns    80056a <vprintfmt+0x70>
  8005d5:	eb 8b                	jmp    800562 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005db:	eb 8d                	jmp    80056a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f5:	e9 23 ff ff ff       	jmp    80051d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	85 c0                	test   %eax,%eax
  800607:	79 02                	jns    80060b <vprintfmt+0x111>
  800609:	f7 d8                	neg    %eax
  80060b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060d:	83 f8 0f             	cmp    $0xf,%eax
  800610:	7f 0b                	jg     80061d <vprintfmt+0x123>
  800612:	8b 04 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%eax
  800619:	85 c0                	test   %eax,%eax
  80061b:	75 23                	jne    800640 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80061d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800621:	c7 44 24 08 1b 26 80 	movl   $0x80261b,0x8(%esp)
  800628:	00 
  800629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 9a fe ff ff       	call   8004d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80063b:	e9 dd fe ff ff       	jmp    80051d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800640:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800644:	c7 44 24 08 26 2b 80 	movl   $0x802b26,0x8(%esp)
  80064b:	00 
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	8b 55 08             	mov    0x8(%ebp),%edx
  800653:	89 14 24             	mov    %edx,(%esp)
  800656:	e8 77 fe ff ff       	call   8004d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065e:	e9 ba fe ff ff       	jmp    80051d <vprintfmt+0x23>
  800663:	89 f9                	mov    %edi,%ecx
  800665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800668:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)
  800674:	8b 30                	mov    (%eax),%esi
  800676:	85 f6                	test   %esi,%esi
  800678:	75 05                	jne    80067f <vprintfmt+0x185>
				p = "(null)";
  80067a:	be 14 26 80 00       	mov    $0x802614,%esi
			if (width > 0 && padc != '-')
  80067f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800683:	0f 8e 84 00 00 00    	jle    80070d <vprintfmt+0x213>
  800689:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80068d:	74 7e                	je     80070d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800693:	89 34 24             	mov    %esi,(%esp)
  800696:	e8 8b 02 00 00       	call   800926 <strnlen>
  80069b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80069e:	29 c2                	sub    %eax,%edx
  8006a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006ad:	89 de                	mov    %ebx,%esi
  8006af:	89 d3                	mov    %edx,%ebx
  8006b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b3:	eb 0b                	jmp    8006c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b9:	89 3c 24             	mov    %edi,(%esp)
  8006bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	4b                   	dec    %ebx
  8006c0:	85 db                	test   %ebx,%ebx
  8006c2:	7f f1                	jg     8006b5 <vprintfmt+0x1bb>
  8006c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006c7:	89 f3                	mov    %esi,%ebx
  8006c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	79 05                	jns    8006d8 <vprintfmt+0x1de>
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006db:	29 c2                	sub    %eax,%edx
  8006dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006e0:	eb 2b                	jmp    80070d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e6:	74 18                	je     800700 <vprintfmt+0x206>
  8006e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006eb:	83 fa 5e             	cmp    $0x5e,%edx
  8006ee:	76 10                	jbe    800700 <vprintfmt+0x206>
					putch('?', putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
  8006fe:	eb 0a                	jmp    80070a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070a:	ff 4d e4             	decl   -0x1c(%ebp)
  80070d:	0f be 06             	movsbl (%esi),%eax
  800710:	46                   	inc    %esi
  800711:	85 c0                	test   %eax,%eax
  800713:	74 21                	je     800736 <vprintfmt+0x23c>
  800715:	85 ff                	test   %edi,%edi
  800717:	78 c9                	js     8006e2 <vprintfmt+0x1e8>
  800719:	4f                   	dec    %edi
  80071a:	79 c6                	jns    8006e2 <vprintfmt+0x1e8>
  80071c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071f:	89 de                	mov    %ebx,%esi
  800721:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800724:	eb 18                	jmp    80073e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800731:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800733:	4b                   	dec    %ebx
  800734:	eb 08                	jmp    80073e <vprintfmt+0x244>
  800736:	8b 7d 08             	mov    0x8(%ebp),%edi
  800739:	89 de                	mov    %ebx,%esi
  80073b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80073e:	85 db                	test   %ebx,%ebx
  800740:	7f e4                	jg     800726 <vprintfmt+0x22c>
  800742:	89 7d 08             	mov    %edi,0x8(%ebp)
  800745:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074a:	e9 ce fd ff ff       	jmp    80051d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074f:	83 f9 01             	cmp    $0x1,%ecx
  800752:	7e 10                	jle    800764 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 08             	lea    0x8(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 30                	mov    (%eax),%esi
  80075f:	8b 78 04             	mov    0x4(%eax),%edi
  800762:	eb 26                	jmp    80078a <vprintfmt+0x290>
	else if (lflag)
  800764:	85 c9                	test   %ecx,%ecx
  800766:	74 12                	je     80077a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 50 04             	lea    0x4(%eax),%edx
  80076e:	89 55 14             	mov    %edx,0x14(%ebp)
  800771:	8b 30                	mov    (%eax),%esi
  800773:	89 f7                	mov    %esi,%edi
  800775:	c1 ff 1f             	sar    $0x1f,%edi
  800778:	eb 10                	jmp    80078a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)
  800783:	8b 30                	mov    (%eax),%esi
  800785:	89 f7                	mov    %esi,%edi
  800787:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078a:	85 ff                	test   %edi,%edi
  80078c:	78 0a                	js     800798 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80078e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800793:	e9 8c 00 00 00       	jmp    800824 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a6:	f7 de                	neg    %esi
  8007a8:	83 d7 00             	adc    $0x0,%edi
  8007ab:	f7 df                	neg    %edi
			}
			base = 10;
  8007ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b2:	eb 70                	jmp    800824 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b4:	89 ca                	mov    %ecx,%edx
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 c0 fc ff ff       	call   80047e <getuint>
  8007be:	89 c6                	mov    %eax,%esi
  8007c0:	89 d7                	mov    %edx,%edi
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007c7:	eb 5b                	jmp    800824 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007c9:	89 ca                	mov    %ecx,%edx
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	e8 ab fc ff ff       	call   80047e <getuint>
  8007d3:	89 c6                	mov    %eax,%esi
  8007d5:	89 d7                	mov    %edx,%edi
			base = 8;
  8007d7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007dc:	eb 46                	jmp    800824 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8007de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800803:	8b 30                	mov    (%eax),%esi
  800805:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80080f:	eb 13                	jmp    800824 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800811:	89 ca                	mov    %ecx,%edx
  800813:	8d 45 14             	lea    0x14(%ebp),%eax
  800816:	e8 63 fc ff ff       	call   80047e <getuint>
  80081b:	89 c6                	mov    %eax,%esi
  80081d:	89 d7                	mov    %edx,%edi
			base = 16;
  80081f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800824:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800828:	89 54 24 10          	mov    %edx,0x10(%esp)
  80082c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80082f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800833:	89 44 24 08          	mov    %eax,0x8(%esp)
  800837:	89 34 24             	mov    %esi,(%esp)
  80083a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80083e:	89 da                	mov    %ebx,%edx
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	e8 6c fb ff ff       	call   8003b4 <printnum>
			break;
  800848:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80084b:	e9 cd fc ff ff       	jmp    80051d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80085d:	e9 bb fc ff ff       	jmp    80051d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800862:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800866:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80086d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800870:	eb 01                	jmp    800873 <vprintfmt+0x379>
  800872:	4e                   	dec    %esi
  800873:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800877:	75 f9                	jne    800872 <vprintfmt+0x378>
  800879:	e9 9f fc ff ff       	jmp    80051d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80087e:	83 c4 4c             	add    $0x4c,%esp
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5f                   	pop    %edi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	83 ec 28             	sub    $0x28,%esp
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800892:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800895:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800899:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a3:	85 c0                	test   %eax,%eax
  8008a5:	74 30                	je     8008d7 <vsnprintf+0x51>
  8008a7:	85 d2                	test   %edx,%edx
  8008a9:	7e 33                	jle    8008de <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c0:	c7 04 24 b8 04 80 00 	movl   $0x8004b8,(%esp)
  8008c7:	e8 2e fc ff ff       	call   8004fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d5:	eb 0c                	jmp    8008e3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008dc:	eb 05                	jmp    8008e3 <vsnprintf+0x5d>
  8008de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	e8 7b ff ff ff       	call   800886 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    
  80090d:	00 00                	add    %al,(%eax)
	...

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 01                	jmp    80091e <strlen+0xe>
		n++;
  80091d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800922:	75 f9                	jne    80091d <strlen+0xd>
		n++;
	return n;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
  800934:	eb 01                	jmp    800937 <strnlen+0x11>
		n++;
  800936:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800937:	39 d0                	cmp    %edx,%eax
  800939:	74 06                	je     800941 <strnlen+0x1b>
  80093b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80093f:	75 f5                	jne    800936 <strnlen+0x10>
		n++;
	return n;
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800955:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800958:	42                   	inc    %edx
  800959:	84 c9                	test   %cl,%cl
  80095b:	75 f5                	jne    800952 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80095d:	5b                   	pop    %ebx
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096a:	89 1c 24             	mov    %ebx,(%esp)
  80096d:	e8 9e ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
  800975:	89 54 24 04          	mov    %edx,0x4(%esp)
  800979:	01 d8                	add    %ebx,%eax
  80097b:	89 04 24             	mov    %eax,(%esp)
  80097e:	e8 c0 ff ff ff       	call   800943 <strcpy>
	return dst;
}
  800983:	89 d8                	mov    %ebx,%eax
  800985:	83 c4 08             	add    $0x8,%esp
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 55 0c             	mov    0xc(%ebp),%edx
  800996:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800999:	b9 00 00 00 00       	mov    $0x0,%ecx
  80099e:	eb 0c                	jmp    8009ac <strncpy+0x21>
		*dst++ = *src;
  8009a0:	8a 1a                	mov    (%edx),%bl
  8009a2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a5:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ab:	41                   	inc    %ecx
  8009ac:	39 f1                	cmp    %esi,%ecx
  8009ae:	75 f0                	jne    8009a0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c2:	85 d2                	test   %edx,%edx
  8009c4:	75 0a                	jne    8009d0 <strlcpy+0x1c>
  8009c6:	89 f0                	mov    %esi,%eax
  8009c8:	eb 1a                	jmp    8009e4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ca:	88 18                	mov    %bl,(%eax)
  8009cc:	40                   	inc    %eax
  8009cd:	41                   	inc    %ecx
  8009ce:	eb 02                	jmp    8009d2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009d2:	4a                   	dec    %edx
  8009d3:	74 0a                	je     8009df <strlcpy+0x2b>
  8009d5:	8a 19                	mov    (%ecx),%bl
  8009d7:	84 db                	test   %bl,%bl
  8009d9:	75 ef                	jne    8009ca <strlcpy+0x16>
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	eb 02                	jmp    8009e1 <strlcpy+0x2d>
  8009df:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009e1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009e4:	29 f0                	sub    %esi,%eax
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f3:	eb 02                	jmp    8009f7 <strcmp+0xd>
		p++, q++;
  8009f5:	41                   	inc    %ecx
  8009f6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f7:	8a 01                	mov    (%ecx),%al
  8009f9:	84 c0                	test   %al,%al
  8009fb:	74 04                	je     800a01 <strcmp+0x17>
  8009fd:	3a 02                	cmp    (%edx),%al
  8009ff:	74 f4                	je     8009f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 12             	movzbl (%edx),%edx
  800a07:	29 d0                	sub    %edx,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a15:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a18:	eb 03                	jmp    800a1d <strncmp+0x12>
		n--, p++, q++;
  800a1a:	4a                   	dec    %edx
  800a1b:	40                   	inc    %eax
  800a1c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a1d:	85 d2                	test   %edx,%edx
  800a1f:	74 14                	je     800a35 <strncmp+0x2a>
  800a21:	8a 18                	mov    (%eax),%bl
  800a23:	84 db                	test   %bl,%bl
  800a25:	74 04                	je     800a2b <strncmp+0x20>
  800a27:	3a 19                	cmp    (%ecx),%bl
  800a29:	74 ef                	je     800a1a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2b:	0f b6 00             	movzbl (%eax),%eax
  800a2e:	0f b6 11             	movzbl (%ecx),%edx
  800a31:	29 d0                	sub    %edx,%eax
  800a33:	eb 05                	jmp    800a3a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a46:	eb 05                	jmp    800a4d <strchr+0x10>
		if (*s == c)
  800a48:	38 ca                	cmp    %cl,%dl
  800a4a:	74 0c                	je     800a58 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4c:	40                   	inc    %eax
  800a4d:	8a 10                	mov    (%eax),%dl
  800a4f:	84 d2                	test   %dl,%dl
  800a51:	75 f5                	jne    800a48 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a63:	eb 05                	jmp    800a6a <strfind+0x10>
		if (*s == c)
  800a65:	38 ca                	cmp    %cl,%dl
  800a67:	74 07                	je     800a70 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a69:	40                   	inc    %eax
  800a6a:	8a 10                	mov    (%eax),%dl
  800a6c:	84 d2                	test   %dl,%dl
  800a6e:	75 f5                	jne    800a65 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 30                	je     800ab5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a85:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8b:	75 25                	jne    800ab2 <memset+0x40>
  800a8d:	f6 c1 03             	test   $0x3,%cl
  800a90:	75 20                	jne    800ab2 <memset+0x40>
		c &= 0xFF;
  800a92:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	c1 e3 08             	shl    $0x8,%ebx
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	c1 e6 18             	shl    $0x18,%esi
  800a9f:	89 d0                	mov    %edx,%eax
  800aa1:	c1 e0 10             	shl    $0x10,%eax
  800aa4:	09 f0                	or     %esi,%eax
  800aa6:	09 d0                	or     %edx,%eax
  800aa8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aaa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aad:	fc                   	cld    
  800aae:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab0:	eb 03                	jmp    800ab5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab2:	fc                   	cld    
  800ab3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab5:	89 f8                	mov    %edi,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aca:	39 c6                	cmp    %eax,%esi
  800acc:	73 34                	jae    800b02 <memmove+0x46>
  800ace:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad1:	39 d0                	cmp    %edx,%eax
  800ad3:	73 2d                	jae    800b02 <memmove+0x46>
		s += n;
		d += n;
  800ad5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad8:	f6 c2 03             	test   $0x3,%dl
  800adb:	75 1b                	jne    800af8 <memmove+0x3c>
  800add:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae3:	75 13                	jne    800af8 <memmove+0x3c>
  800ae5:	f6 c1 03             	test   $0x3,%cl
  800ae8:	75 0e                	jne    800af8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aea:	83 ef 04             	sub    $0x4,%edi
  800aed:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800af3:	fd                   	std    
  800af4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af6:	eb 07                	jmp    800aff <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af8:	4f                   	dec    %edi
  800af9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800afc:	fd                   	std    
  800afd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aff:	fc                   	cld    
  800b00:	eb 20                	jmp    800b22 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b02:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b08:	75 13                	jne    800b1d <memmove+0x61>
  800b0a:	a8 03                	test   $0x3,%al
  800b0c:	75 0f                	jne    800b1d <memmove+0x61>
  800b0e:	f6 c1 03             	test   $0x3,%cl
  800b11:	75 0a                	jne    800b1d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b13:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b16:	89 c7                	mov    %eax,%edi
  800b18:	fc                   	cld    
  800b19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1b:	eb 05                	jmp    800b22 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	fc                   	cld    
  800b20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	89 04 24             	mov    %eax,(%esp)
  800b40:	e8 77 ff ff ff       	call   800abc <memmove>
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	eb 16                	jmp    800b73 <memcmp+0x2c>
		if (*s1 != *s2)
  800b5d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b60:	42                   	inc    %edx
  800b61:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b65:	38 c8                	cmp    %cl,%al
  800b67:	74 0a                	je     800b73 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b69:	0f b6 c0             	movzbl %al,%eax
  800b6c:	0f b6 c9             	movzbl %cl,%ecx
  800b6f:	29 c8                	sub    %ecx,%eax
  800b71:	eb 09                	jmp    800b7c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b73:	39 da                	cmp    %ebx,%edx
  800b75:	75 e6                	jne    800b5d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8f:	eb 05                	jmp    800b96 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b91:	38 08                	cmp    %cl,(%eax)
  800b93:	74 05                	je     800b9a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b95:	40                   	inc    %eax
  800b96:	39 d0                	cmp    %edx,%eax
  800b98:	72 f7                	jb     800b91 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba8:	eb 01                	jmp    800bab <strtol+0xf>
		s++;
  800baa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bab:	8a 02                	mov    (%edx),%al
  800bad:	3c 20                	cmp    $0x20,%al
  800baf:	74 f9                	je     800baa <strtol+0xe>
  800bb1:	3c 09                	cmp    $0x9,%al
  800bb3:	74 f5                	je     800baa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bb5:	3c 2b                	cmp    $0x2b,%al
  800bb7:	75 08                	jne    800bc1 <strtol+0x25>
		s++;
  800bb9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bba:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbf:	eb 13                	jmp    800bd4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bc1:	3c 2d                	cmp    $0x2d,%al
  800bc3:	75 0a                	jne    800bcf <strtol+0x33>
		s++, neg = 1;
  800bc5:	8d 52 01             	lea    0x1(%edx),%edx
  800bc8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bcd:	eb 05                	jmp    800bd4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bcf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd4:	85 db                	test   %ebx,%ebx
  800bd6:	74 05                	je     800bdd <strtol+0x41>
  800bd8:	83 fb 10             	cmp    $0x10,%ebx
  800bdb:	75 28                	jne    800c05 <strtol+0x69>
  800bdd:	8a 02                	mov    (%edx),%al
  800bdf:	3c 30                	cmp    $0x30,%al
  800be1:	75 10                	jne    800bf3 <strtol+0x57>
  800be3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800be7:	75 0a                	jne    800bf3 <strtol+0x57>
		s += 2, base = 16;
  800be9:	83 c2 02             	add    $0x2,%edx
  800bec:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bf1:	eb 12                	jmp    800c05 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	75 0e                	jne    800c05 <strtol+0x69>
  800bf7:	3c 30                	cmp    $0x30,%al
  800bf9:	75 05                	jne    800c00 <strtol+0x64>
		s++, base = 8;
  800bfb:	42                   	inc    %edx
  800bfc:	b3 08                	mov    $0x8,%bl
  800bfe:	eb 05                	jmp    800c05 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c00:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c05:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c0c:	8a 0a                	mov    (%edx),%cl
  800c0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c11:	80 fb 09             	cmp    $0x9,%bl
  800c14:	77 08                	ja     800c1e <strtol+0x82>
			dig = *s - '0';
  800c16:	0f be c9             	movsbl %cl,%ecx
  800c19:	83 e9 30             	sub    $0x30,%ecx
  800c1c:	eb 1e                	jmp    800c3c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c21:	80 fb 19             	cmp    $0x19,%bl
  800c24:	77 08                	ja     800c2e <strtol+0x92>
			dig = *s - 'a' + 10;
  800c26:	0f be c9             	movsbl %cl,%ecx
  800c29:	83 e9 57             	sub    $0x57,%ecx
  800c2c:	eb 0e                	jmp    800c3c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c31:	80 fb 19             	cmp    $0x19,%bl
  800c34:	77 12                	ja     800c48 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c36:	0f be c9             	movsbl %cl,%ecx
  800c39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c3c:	39 f1                	cmp    %esi,%ecx
  800c3e:	7d 0c                	jge    800c4c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c40:	42                   	inc    %edx
  800c41:	0f af c6             	imul   %esi,%eax
  800c44:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c46:	eb c4                	jmp    800c0c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c48:	89 c1                	mov    %eax,%ecx
  800c4a:	eb 02                	jmp    800c4e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c4c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c52:	74 05                	je     800c59 <strtol+0xbd>
		*endptr = (char *) s;
  800c54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c57:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c59:	85 ff                	test   %edi,%edi
  800c5b:	74 04                	je     800c61 <strtol+0xc5>
  800c5d:	89 c8                	mov    %ecx,%eax
  800c5f:	f7 d8                	neg    %eax
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    
	...

00800c68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 c3                	mov    %eax,%ebx
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	89 c6                	mov    %eax,%esi
  800c7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 cb                	mov    %ecx,%ebx
  800cbd:	89 cf                	mov    %ecx,%edi
  800cbf:	89 ce                	mov    %ecx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 28                	jle    800cef <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800cda:	00 
  800cdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce2:	00 
  800ce3:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800cea:	e8 b1 f5 ff ff       	call   8002a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cef:	83 c4 2c             	add    $0x2c,%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 02 00 00 00       	mov    $0x2,%eax
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	89 d3                	mov    %edx,%ebx
  800d0b:	89 d7                	mov    %edx,%edi
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_yield>:

void
sys_yield(void)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d26:	89 d1                	mov    %edx,%ecx
  800d28:	89 d3                	mov    %edx,%ebx
  800d2a:	89 d7                	mov    %edx,%edi
  800d2c:	89 d6                	mov    %edx,%esi
  800d2e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	be 00 00 00 00       	mov    $0x0,%esi
  800d43:	b8 04 00 00 00       	mov    $0x4,%eax
  800d48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 f7                	mov    %esi,%edi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 28                	jle    800d81 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d64:	00 
  800d65:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d6c:	00 
  800d6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d74:	00 
  800d75:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800d7c:	e8 1f f5 ff ff       	call   8002a0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d81:	83 c4 2c             	add    $0x2c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	b8 05 00 00 00       	mov    $0x5,%eax
  800d97:	8b 75 18             	mov    0x18(%ebp),%esi
  800d9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 28                	jle    800dd4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800db7:	00 
  800db8:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc7:	00 
  800dc8:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800dcf:	e8 cc f4 ff ff       	call   8002a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd4:	83 c4 2c             	add    $0x2c,%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dea:	b8 06 00 00 00       	mov    $0x6,%eax
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	89 df                	mov    %ebx,%edi
  800df7:	89 de                	mov    %ebx,%esi
  800df9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7e 28                	jle    800e27 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e03:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e12:	00 
  800e13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1a:	00 
  800e1b:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e22:	e8 79 f4 ff ff       	call   8002a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e27:	83 c4 2c             	add    $0x2c,%esp
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
  800e35:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	89 df                	mov    %ebx,%edi
  800e4a:	89 de                	mov    %ebx,%esi
  800e4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	7e 28                	jle    800e7a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e56:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e65:	00 
  800e66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6d:	00 
  800e6e:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e75:	e8 26 f4 ff ff       	call   8002a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e7a:	83 c4 2c             	add    $0x2c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e90:	b8 09 00 00 00       	mov    $0x9,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	89 df                	mov    %ebx,%edi
  800e9d:	89 de                	mov    %ebx,%esi
  800e9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 28                	jle    800ecd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800ec8:	e8 d3 f3 ff ff       	call   8002a0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ecd:	83 c4 2c             	add    $0x2c,%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	89 df                	mov    %ebx,%edi
  800ef0:	89 de                	mov    %ebx,%esi
  800ef2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	7e 28                	jle    800f20 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f03:	00 
  800f04:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f13:	00 
  800f14:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800f1b:	e8 80 f3 ff ff       	call   8002a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f20:	83 c4 2c             	add    $0x2c,%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	be 00 00 00 00       	mov    $0x0,%esi
  800f33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f61:	89 cb                	mov    %ecx,%ebx
  800f63:	89 cf                	mov    %ecx,%edi
  800f65:	89 ce                	mov    %ecx,%esi
  800f67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 28                	jle    800f95 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f71:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f78:	00 
  800f79:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800f90:	e8 0b f3 ff ff       	call   8002a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f95:	83 c4 2c             	add    $0x2c,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    
  800f9d:	00 00                	add    %al,(%eax)
	...

00800fa0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 24             	sub    $0x24,%esp
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800faa:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  800fac:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fb0:	75 2d                	jne    800fdf <pgfault+0x3f>
  800fb2:	89 d8                	mov    %ebx,%eax
  800fb4:	c1 e8 0c             	shr    $0xc,%eax
  800fb7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbe:	f6 c4 08             	test   $0x8,%ah
  800fc1:	75 1c                	jne    800fdf <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  800fc3:	c7 44 24 08 2c 29 80 	movl   $0x80292c,0x8(%esp)
  800fca:	00 
  800fcb:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800fd2:	00 
  800fd3:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  800fda:	e8 c1 f2 ff ff       	call   8002a0 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fdf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fee:	00 
  800fef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff6:	e8 3a fd ff ff       	call   800d35 <sys_page_alloc>
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	79 20                	jns    80101f <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  800fff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801003:	c7 44 24 08 9b 29 80 	movl   $0x80299b,0x8(%esp)
  80100a:	00 
  80100b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801012:	00 
  801013:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  80101a:	e8 81 f2 ff ff       	call   8002a0 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  80101f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  801025:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80102c:	00 
  80102d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801031:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801038:	e8 e9 fa ff ff       	call   800b26 <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80103d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801044:	00 
  801045:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801049:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801050:	00 
  801051:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801058:	00 
  801059:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801060:	e8 24 fd ff ff       	call   800d89 <sys_page_map>
  801065:	85 c0                	test   %eax,%eax
  801067:	79 20                	jns    801089 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  801069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80106d:	c7 44 24 08 ae 29 80 	movl   $0x8029ae,0x8(%esp)
  801074:	00 
  801075:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80107c:	00 
  80107d:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  801084:	e8 17 f2 ff ff       	call   8002a0 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801089:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801098:	e8 3f fd ff ff       	call   800ddc <sys_page_unmap>
  80109d:	85 c0                	test   %eax,%eax
  80109f:	79 20                	jns    8010c1 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  8010a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a5:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8010b4:	00 
  8010b5:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  8010bc:	e8 df f1 ff ff       	call   8002a0 <_panic>
}
  8010c1:	83 c4 24             	add    $0x24,%esp
  8010c4:	5b                   	pop    %ebx
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    

008010c7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	57                   	push   %edi
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  8010d0:	c7 04 24 a0 0f 80 00 	movl   $0x800fa0,(%esp)
  8010d7:	e8 40 11 00 00       	call   80221c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010dc:	ba 07 00 00 00       	mov    $0x7,%edx
  8010e1:	89 d0                	mov    %edx,%eax
  8010e3:	cd 30                	int    $0x30
  8010e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	79 1c                	jns    80110b <fork+0x44>
		panic("sys_exofork failed\n");
  8010ef:	c7 44 24 08 d2 29 80 	movl   $0x8029d2,0x8(%esp)
  8010f6:	00 
  8010f7:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8010fe:	00 
  8010ff:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  801106:	e8 95 f1 ff ff       	call   8002a0 <_panic>
	if(c_envid == 0){
  80110b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80110f:	75 25                	jne    801136 <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  801111:	e8 e1 fb ff ff       	call   800cf7 <sys_getenvid>
  801116:	25 ff 03 00 00       	and    $0x3ff,%eax
  80111b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801122:	c1 e0 07             	shl    $0x7,%eax
  801125:	29 d0                	sub    %edx,%eax
  801127:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80112c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801131:	e9 e3 01 00 00       	jmp    801319 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  801136:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  80113b:	89 d8                	mov    %ebx,%eax
  80113d:	c1 e8 16             	shr    $0x16,%eax
  801140:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801147:	a8 01                	test   $0x1,%al
  801149:	0f 84 0b 01 00 00    	je     80125a <fork+0x193>
  80114f:	89 de                	mov    %ebx,%esi
  801151:	c1 ee 0c             	shr    $0xc,%esi
  801154:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80115b:	a8 05                	test   $0x5,%al
  80115d:	0f 84 f7 00 00 00    	je     80125a <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  801163:	89 f7                	mov    %esi,%edi
  801165:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  801168:	e8 8a fb ff ff       	call   800cf7 <sys_getenvid>
  80116d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801170:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801177:	a8 02                	test   $0x2,%al
  801179:	75 10                	jne    80118b <fork+0xc4>
  80117b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801182:	f6 c4 08             	test   $0x8,%ah
  801185:	0f 84 89 00 00 00    	je     801214 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  80118b:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801192:	00 
  801193:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801197:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80119a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a5:	89 04 24             	mov    %eax,(%esp)
  8011a8:	e8 dc fb ff ff       	call   800d89 <sys_page_map>
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	79 20                	jns    8011d1 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8011b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b5:	c7 44 24 08 e6 29 80 	movl   $0x8029e6,0x8(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  8011c4:	00 
  8011c5:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  8011cc:	e8 cf f0 ff ff       	call   8002a0 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  8011d1:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011d8:	00 
  8011d9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011e8:	89 04 24             	mov    %eax,(%esp)
  8011eb:	e8 99 fb ff ff       	call   800d89 <sys_page_map>
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	79 66                	jns    80125a <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8011f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f8:	c7 44 24 08 e6 29 80 	movl   $0x8029e6,0x8(%esp)
  8011ff:	00 
  801200:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801207:	00 
  801208:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  80120f:	e8 8c f0 ff ff       	call   8002a0 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  801214:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80121b:	00 
  80121c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801220:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801223:	89 44 24 08          	mov    %eax,0x8(%esp)
  801227:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80122b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80122e:	89 04 24             	mov    %eax,(%esp)
  801231:	e8 53 fb ff ff       	call   800d89 <sys_page_map>
  801236:	85 c0                	test   %eax,%eax
  801238:	79 20                	jns    80125a <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  80123a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123e:	c7 44 24 08 e6 29 80 	movl   $0x8029e6,0x8(%esp)
  801245:	00 
  801246:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80124d:	00 
  80124e:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  801255:	e8 46 f0 ff ff       	call   8002a0 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  80125a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801260:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801266:	0f 85 cf fe ff ff    	jne    80113b <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  80126c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801273:	00 
  801274:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80127b:	ee 
  80127c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 ae fa ff ff       	call   800d35 <sys_page_alloc>
  801287:	85 c0                	test   %eax,%eax
  801289:	79 20                	jns    8012ab <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  80128b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128f:	c7 44 24 08 f8 29 80 	movl   $0x8029f8,0x8(%esp)
  801296:	00 
  801297:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80129e:	00 
  80129f:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  8012a6:	e8 f5 ef ff ff       	call   8002a0 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  8012ab:	c7 44 24 04 68 22 80 	movl   $0x802268,0x4(%esp)
  8012b2:	00 
  8012b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012b6:	89 04 24             	mov    %eax,(%esp)
  8012b9:	e8 17 fc ff ff       	call   800ed5 <sys_env_set_pgfault_upcall>
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	79 20                	jns    8012e2 <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8012c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c6:	c7 44 24 08 70 29 80 	movl   $0x802970,0x8(%esp)
  8012cd:	00 
  8012ce:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8012d5:	00 
  8012d6:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  8012dd:	e8 be ef ff ff       	call   8002a0 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  8012e2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012e9:	00 
  8012ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012ed:	89 04 24             	mov    %eax,(%esp)
  8012f0:	e8 3a fb ff ff       	call   800e2f <sys_env_set_status>
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	79 20                	jns    801319 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  8012f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fd:	c7 44 24 08 0c 2a 80 	movl   $0x802a0c,0x8(%esp)
  801304:	00 
  801305:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  80130c:	00 
  80130d:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  801314:	e8 87 ef ff ff       	call   8002a0 <_panic>
 
	return c_envid;	
}
  801319:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80131c:	83 c4 3c             	add    $0x3c,%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <sfork>:

// Challenge!
int
sfork(void)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80132a:	c7 44 24 08 24 2a 80 	movl   $0x802a24,0x8(%esp)
  801331:	00 
  801332:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801339:	00 
  80133a:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  801341:	e8 5a ef ff ff       	call   8002a0 <_panic>
	...

00801348 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	57                   	push   %edi
  80134c:	56                   	push   %esi
  80134d:	53                   	push   %ebx
  80134e:	83 ec 1c             	sub    $0x1c,%esp
  801351:	8b 75 08             	mov    0x8(%ebp),%esi
  801354:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801357:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  80135a:	85 db                	test   %ebx,%ebx
  80135c:	75 05                	jne    801363 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  80135e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801363:	89 1c 24             	mov    %ebx,(%esp)
  801366:	e8 e0 fb ff ff       	call   800f4b <sys_ipc_recv>
  80136b:	85 c0                	test   %eax,%eax
  80136d:	79 16                	jns    801385 <ipc_recv+0x3d>
		*from_env_store = 0;
  80136f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801375:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  80137b:	89 1c 24             	mov    %ebx,(%esp)
  80137e:	e8 c8 fb ff ff       	call   800f4b <sys_ipc_recv>
  801383:	eb 24                	jmp    8013a9 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801385:	85 f6                	test   %esi,%esi
  801387:	74 0a                	je     801393 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801389:	a1 04 40 80 00       	mov    0x804004,%eax
  80138e:	8b 40 74             	mov    0x74(%eax),%eax
  801391:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801393:	85 ff                	test   %edi,%edi
  801395:	74 0a                	je     8013a1 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801397:	a1 04 40 80 00       	mov    0x804004,%eax
  80139c:	8b 40 78             	mov    0x78(%eax),%eax
  80139f:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8013a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013a9:	83 c4 1c             	add    $0x1c,%esp
  8013ac:	5b                   	pop    %ebx
  8013ad:	5e                   	pop    %esi
  8013ae:	5f                   	pop    %edi
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	57                   	push   %edi
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
  8013b7:	83 ec 1c             	sub    $0x1c,%esp
  8013ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013c0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8013c3:	85 db                	test   %ebx,%ebx
  8013c5:	75 05                	jne    8013cc <ipc_send+0x1b>
		pg = (void *)-1;
  8013c7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8013cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	e8 45 fb ff ff       	call   800f28 <sys_ipc_try_send>
		if (r == 0) {		
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	74 2c                	je     801413 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  8013e7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013ea:	75 07                	jne    8013f3 <ipc_send+0x42>
			sys_yield();
  8013ec:	e8 25 f9 ff ff       	call   800d16 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  8013f1:	eb d9                	jmp    8013cc <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  8013f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f7:	c7 44 24 08 3a 2a 80 	movl   $0x802a3a,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  80140e:	e8 8d ee ff ff       	call   8002a0 <_panic>
		}
	}
}
  801413:	83 c4 1c             	add    $0x1c,%esp
  801416:	5b                   	pop    %ebx
  801417:	5e                   	pop    %esi
  801418:	5f                   	pop    %edi
  801419:	5d                   	pop    %ebp
  80141a:	c3                   	ret    

0080141b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	53                   	push   %ebx
  80141f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801422:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801427:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80142e:	89 c2                	mov    %eax,%edx
  801430:	c1 e2 07             	shl    $0x7,%edx
  801433:	29 ca                	sub    %ecx,%edx
  801435:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80143b:	8b 52 50             	mov    0x50(%edx),%edx
  80143e:	39 da                	cmp    %ebx,%edx
  801440:	75 0f                	jne    801451 <ipc_find_env+0x36>
			return envs[i].env_id;
  801442:	c1 e0 07             	shl    $0x7,%eax
  801445:	29 c8                	sub    %ecx,%eax
  801447:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80144c:	8b 40 40             	mov    0x40(%eax),%eax
  80144f:	eb 0c                	jmp    80145d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801451:	40                   	inc    %eax
  801452:	3d 00 04 00 00       	cmp    $0x400,%eax
  801457:	75 ce                	jne    801427 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801459:	66 b8 00 00          	mov    $0x0,%ax
}
  80145d:	5b                   	pop    %ebx
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	05 00 00 00 30       	add    $0x30000000,%eax
  80146b:	c1 e8 0c             	shr    $0xc,%eax
}
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	89 04 24             	mov    %eax,(%esp)
  80147c:	e8 df ff ff ff       	call   801460 <fd2num>
  801481:	05 20 00 0d 00       	add    $0xd0020,%eax
  801486:	c1 e0 0c             	shl    $0xc,%eax
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801492:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801497:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801499:	89 c2                	mov    %eax,%edx
  80149b:	c1 ea 16             	shr    $0x16,%edx
  80149e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a5:	f6 c2 01             	test   $0x1,%dl
  8014a8:	74 11                	je     8014bb <fd_alloc+0x30>
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	c1 ea 0c             	shr    $0xc,%edx
  8014af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	75 09                	jne    8014c4 <fd_alloc+0x39>
			*fd_store = fd;
  8014bb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c2:	eb 17                	jmp    8014db <fd_alloc+0x50>
  8014c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014ce:	75 c7                	jne    801497 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014db:	5b                   	pop    %ebx
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e4:	83 f8 1f             	cmp    $0x1f,%eax
  8014e7:	77 36                	ja     80151f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014ee:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	c1 ea 16             	shr    $0x16,%edx
  8014f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fd:	f6 c2 01             	test   $0x1,%dl
  801500:	74 24                	je     801526 <fd_lookup+0x48>
  801502:	89 c2                	mov    %eax,%edx
  801504:	c1 ea 0c             	shr    $0xc,%edx
  801507:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150e:	f6 c2 01             	test   $0x1,%dl
  801511:	74 1a                	je     80152d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801513:	8b 55 0c             	mov    0xc(%ebp),%edx
  801516:	89 02                	mov    %eax,(%edx)
	return 0;
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
  80151d:	eb 13                	jmp    801532 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80151f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801524:	eb 0c                	jmp    801532 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152b:	eb 05                	jmp    801532 <fd_lookup+0x54>
  80152d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 14             	sub    $0x14,%esp
  80153b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	eb 0e                	jmp    801556 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801548:	39 08                	cmp    %ecx,(%eax)
  80154a:	75 09                	jne    801555 <dev_lookup+0x21>
			*dev = devtab[i];
  80154c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80154e:	b8 00 00 00 00       	mov    $0x0,%eax
  801553:	eb 33                	jmp    801588 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801555:	42                   	inc    %edx
  801556:	8b 04 95 d4 2a 80 00 	mov    0x802ad4(,%edx,4),%eax
  80155d:	85 c0                	test   %eax,%eax
  80155f:	75 e7                	jne    801548 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801561:	a1 04 40 80 00       	mov    0x804004,%eax
  801566:	8b 40 48             	mov    0x48(%eax),%eax
  801569:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80156d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801571:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  801578:	e8 1b ee ff ff       	call   800398 <cprintf>
	*dev = 0;
  80157d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801583:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801588:	83 c4 14             	add    $0x14,%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	56                   	push   %esi
  801592:	53                   	push   %ebx
  801593:	83 ec 30             	sub    $0x30,%esp
  801596:	8b 75 08             	mov    0x8(%ebp),%esi
  801599:	8a 45 0c             	mov    0xc(%ebp),%al
  80159c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80159f:	89 34 24             	mov    %esi,(%esp)
  8015a2:	e8 b9 fe ff ff       	call   801460 <fd2num>
  8015a7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015ae:	89 04 24             	mov    %eax,(%esp)
  8015b1:	e8 28 ff ff ff       	call   8014de <fd_lookup>
  8015b6:	89 c3                	mov    %eax,%ebx
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 05                	js     8015c1 <fd_close+0x33>
	    || fd != fd2)
  8015bc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015bf:	74 0d                	je     8015ce <fd_close+0x40>
		return (must_exist ? r : 0);
  8015c1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015c5:	75 46                	jne    80160d <fd_close+0x7f>
  8015c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015cc:	eb 3f                	jmp    80160d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d5:	8b 06                	mov    (%esi),%eax
  8015d7:	89 04 24             	mov    %eax,(%esp)
  8015da:	e8 55 ff ff ff       	call   801534 <dev_lookup>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 18                	js     8015fd <fd_close+0x6f>
		if (dev->dev_close)
  8015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e8:	8b 40 10             	mov    0x10(%eax),%eax
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	74 09                	je     8015f8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015ef:	89 34 24             	mov    %esi,(%esp)
  8015f2:	ff d0                	call   *%eax
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	eb 05                	jmp    8015fd <fd_close+0x6f>
		else
			r = 0;
  8015f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801601:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801608:	e8 cf f7 ff ff       	call   800ddc <sys_page_unmap>
	return r;
}
  80160d:	89 d8                	mov    %ebx,%eax
  80160f:	83 c4 30             	add    $0x30,%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    

00801616 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	89 04 24             	mov    %eax,(%esp)
  801629:	e8 b0 fe ff ff       	call   8014de <fd_lookup>
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 13                	js     801645 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801632:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801639:	00 
  80163a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163d:	89 04 24             	mov    %eax,(%esp)
  801640:	e8 49 ff ff ff       	call   80158e <fd_close>
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <close_all>:

void
close_all(void)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80164e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 bb ff ff ff       	call   801616 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80165b:	43                   	inc    %ebx
  80165c:	83 fb 20             	cmp    $0x20,%ebx
  80165f:	75 f2                	jne    801653 <close_all+0xc>
		close(i);
}
  801661:	83 c4 14             	add    $0x14,%esp
  801664:	5b                   	pop    %ebx
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	57                   	push   %edi
  80166b:	56                   	push   %esi
  80166c:	53                   	push   %ebx
  80166d:	83 ec 4c             	sub    $0x4c,%esp
  801670:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801673:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	89 04 24             	mov    %eax,(%esp)
  801680:	e8 59 fe ff ff       	call   8014de <fd_lookup>
  801685:	89 c3                	mov    %eax,%ebx
  801687:	85 c0                	test   %eax,%eax
  801689:	0f 88 e1 00 00 00    	js     801770 <dup+0x109>
		return r;
	close(newfdnum);
  80168f:	89 3c 24             	mov    %edi,(%esp)
  801692:	e8 7f ff ff ff       	call   801616 <close>

	newfd = INDEX2FD(newfdnum);
  801697:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80169d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 c5 fd ff ff       	call   801470 <fd2data>
  8016ab:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016ad:	89 34 24             	mov    %esi,(%esp)
  8016b0:	e8 bb fd ff ff       	call   801470 <fd2data>
  8016b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016b8:	89 d8                	mov    %ebx,%eax
  8016ba:	c1 e8 16             	shr    $0x16,%eax
  8016bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c4:	a8 01                	test   $0x1,%al
  8016c6:	74 46                	je     80170e <dup+0xa7>
  8016c8:	89 d8                	mov    %ebx,%eax
  8016ca:	c1 e8 0c             	shr    $0xc,%eax
  8016cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016d4:	f6 c2 01             	test   $0x1,%dl
  8016d7:	74 35                	je     80170e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016f7:	00 
  8016f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801703:	e8 81 f6 ff ff       	call   800d89 <sys_page_map>
  801708:	89 c3                	mov    %eax,%ebx
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 3b                	js     801749 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80170e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801711:	89 c2                	mov    %eax,%edx
  801713:	c1 ea 0c             	shr    $0xc,%edx
  801716:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80171d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801723:	89 54 24 10          	mov    %edx,0x10(%esp)
  801727:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80172b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801732:	00 
  801733:	89 44 24 04          	mov    %eax,0x4(%esp)
  801737:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173e:	e8 46 f6 ff ff       	call   800d89 <sys_page_map>
  801743:	89 c3                	mov    %eax,%ebx
  801745:	85 c0                	test   %eax,%eax
  801747:	79 25                	jns    80176e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801749:	89 74 24 04          	mov    %esi,0x4(%esp)
  80174d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801754:	e8 83 f6 ff ff       	call   800ddc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801759:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80175c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801760:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801767:	e8 70 f6 ff ff       	call   800ddc <sys_page_unmap>
	return r;
  80176c:	eb 02                	jmp    801770 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80176e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	83 c4 4c             	add    $0x4c,%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	53                   	push   %ebx
  80177e:	83 ec 24             	sub    $0x24,%esp
  801781:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801784:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178b:	89 1c 24             	mov    %ebx,(%esp)
  80178e:	e8 4b fd ff ff       	call   8014de <fd_lookup>
  801793:	85 c0                	test   %eax,%eax
  801795:	78 6d                	js     801804 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801797:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a1:	8b 00                	mov    (%eax),%eax
  8017a3:	89 04 24             	mov    %eax,(%esp)
  8017a6:	e8 89 fd ff ff       	call   801534 <dev_lookup>
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 55                	js     801804 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b2:	8b 50 08             	mov    0x8(%eax),%edx
  8017b5:	83 e2 03             	and    $0x3,%edx
  8017b8:	83 fa 01             	cmp    $0x1,%edx
  8017bb:	75 23                	jne    8017e0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c2:	8b 40 48             	mov    0x48(%eax),%eax
  8017c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	c7 04 24 98 2a 80 00 	movl   $0x802a98,(%esp)
  8017d4:	e8 bf eb ff ff       	call   800398 <cprintf>
		return -E_INVAL;
  8017d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017de:	eb 24                	jmp    801804 <read+0x8a>
	}
	if (!dev->dev_read)
  8017e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e3:	8b 52 08             	mov    0x8(%edx),%edx
  8017e6:	85 d2                	test   %edx,%edx
  8017e8:	74 15                	je     8017ff <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017f8:	89 04 24             	mov    %eax,(%esp)
  8017fb:	ff d2                	call   *%edx
  8017fd:	eb 05                	jmp    801804 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801804:	83 c4 24             	add    $0x24,%esp
  801807:	5b                   	pop    %ebx
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	57                   	push   %edi
  80180e:	56                   	push   %esi
  80180f:	53                   	push   %ebx
  801810:	83 ec 1c             	sub    $0x1c,%esp
  801813:	8b 7d 08             	mov    0x8(%ebp),%edi
  801816:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801819:	bb 00 00 00 00       	mov    $0x0,%ebx
  80181e:	eb 23                	jmp    801843 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801820:	89 f0                	mov    %esi,%eax
  801822:	29 d8                	sub    %ebx,%eax
  801824:	89 44 24 08          	mov    %eax,0x8(%esp)
  801828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182b:	01 d8                	add    %ebx,%eax
  80182d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801831:	89 3c 24             	mov    %edi,(%esp)
  801834:	e8 41 ff ff ff       	call   80177a <read>
		if (m < 0)
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 10                	js     80184d <readn+0x43>
			return m;
		if (m == 0)
  80183d:	85 c0                	test   %eax,%eax
  80183f:	74 0a                	je     80184b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801841:	01 c3                	add    %eax,%ebx
  801843:	39 f3                	cmp    %esi,%ebx
  801845:	72 d9                	jb     801820 <readn+0x16>
  801847:	89 d8                	mov    %ebx,%eax
  801849:	eb 02                	jmp    80184d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80184b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80184d:	83 c4 1c             	add    $0x1c,%esp
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5f                   	pop    %edi
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	53                   	push   %ebx
  801859:	83 ec 24             	sub    $0x24,%esp
  80185c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	89 1c 24             	mov    %ebx,(%esp)
  801869:	e8 70 fc ff ff       	call   8014de <fd_lookup>
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 68                	js     8018da <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187c:	8b 00                	mov    (%eax),%eax
  80187e:	89 04 24             	mov    %eax,(%esp)
  801881:	e8 ae fc ff ff       	call   801534 <dev_lookup>
  801886:	85 c0                	test   %eax,%eax
  801888:	78 50                	js     8018da <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801891:	75 23                	jne    8018b6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801893:	a1 04 40 80 00       	mov    0x804004,%eax
  801898:	8b 40 48             	mov    0x48(%eax),%eax
  80189b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	c7 04 24 b4 2a 80 00 	movl   $0x802ab4,(%esp)
  8018aa:	e8 e9 ea ff ff       	call   800398 <cprintf>
		return -E_INVAL;
  8018af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018b4:	eb 24                	jmp    8018da <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8018bc:	85 d2                	test   %edx,%edx
  8018be:	74 15                	je     8018d5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ce:	89 04 24             	mov    %eax,(%esp)
  8018d1:	ff d2                	call   *%edx
  8018d3:	eb 05                	jmp    8018da <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018da:	83 c4 24             	add    $0x24,%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f0:	89 04 24             	mov    %eax,(%esp)
  8018f3:	e8 e6 fb ff ff       	call   8014de <fd_lookup>
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 0e                	js     80190a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801902:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	53                   	push   %ebx
  801910:	83 ec 24             	sub    $0x24,%esp
  801913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801916:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191d:	89 1c 24             	mov    %ebx,(%esp)
  801920:	e8 b9 fb ff ff       	call   8014de <fd_lookup>
  801925:	85 c0                	test   %eax,%eax
  801927:	78 61                	js     80198a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801930:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801933:	8b 00                	mov    (%eax),%eax
  801935:	89 04 24             	mov    %eax,(%esp)
  801938:	e8 f7 fb ff ff       	call   801534 <dev_lookup>
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 49                	js     80198a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801941:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801944:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801948:	75 23                	jne    80196d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80194a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80194f:	8b 40 48             	mov    0x48(%eax),%eax
  801952:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195a:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  801961:	e8 32 ea ff ff       	call   800398 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801966:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80196b:	eb 1d                	jmp    80198a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80196d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801970:	8b 52 18             	mov    0x18(%edx),%edx
  801973:	85 d2                	test   %edx,%edx
  801975:	74 0e                	je     801985 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80197e:	89 04 24             	mov    %eax,(%esp)
  801981:	ff d2                	call   *%edx
  801983:	eb 05                	jmp    80198a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801985:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80198a:	83 c4 24             	add    $0x24,%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 24             	sub    $0x24,%esp
  801997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80199a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a4:	89 04 24             	mov    %eax,(%esp)
  8019a7:	e8 32 fb ff ff       	call   8014de <fd_lookup>
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 52                	js     801a02 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ba:	8b 00                	mov    (%eax),%eax
  8019bc:	89 04 24             	mov    %eax,(%esp)
  8019bf:	e8 70 fb ff ff       	call   801534 <dev_lookup>
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 3a                	js     801a02 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019cf:	74 2c                	je     8019fd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019db:	00 00 00 
	stat->st_isdir = 0;
  8019de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e5:	00 00 00 
	stat->st_dev = dev;
  8019e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019f5:	89 14 24             	mov    %edx,(%esp)
  8019f8:	ff 50 14             	call   *0x14(%eax)
  8019fb:	eb 05                	jmp    801a02 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a02:	83 c4 24             	add    $0x24,%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a17:	00 
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	89 04 24             	mov    %eax,(%esp)
  801a1e:	e8 fe 01 00 00       	call   801c21 <open>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 1b                	js     801a44 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a30:	89 1c 24             	mov    %ebx,(%esp)
  801a33:	e8 58 ff ff ff       	call   801990 <fstat>
  801a38:	89 c6                	mov    %eax,%esi
	close(fd);
  801a3a:	89 1c 24             	mov    %ebx,(%esp)
  801a3d:	e8 d4 fb ff ff       	call   801616 <close>
	return r;
  801a42:	89 f3                	mov    %esi,%ebx
}
  801a44:	89 d8                	mov    %ebx,%eax
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	5b                   	pop    %ebx
  801a4a:	5e                   	pop    %esi
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    
  801a4d:	00 00                	add    %al,(%eax)
	...

00801a50 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	83 ec 10             	sub    $0x10,%esp
  801a58:	89 c3                	mov    %eax,%ebx
  801a5a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a5c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a63:	75 11                	jne    801a76 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a6c:	e8 aa f9 ff ff       	call   80141b <ipc_find_env>
  801a71:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a76:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a7d:	00 
  801a7e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a85:	00 
  801a86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a8a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 1a f9 ff ff       	call   8013b1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a9e:	00 
  801a9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aaa:	e8 99 f8 ff ff       	call   801348 <ipc_recv>
}
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aca:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801acf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad4:	b8 02 00 00 00       	mov    $0x2,%eax
  801ad9:	e8 72 ff ff ff       	call   801a50 <fsipc>
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae9:	8b 40 0c             	mov    0xc(%eax),%eax
  801aec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801af1:	ba 00 00 00 00       	mov    $0x0,%edx
  801af6:	b8 06 00 00 00       	mov    $0x6,%eax
  801afb:	e8 50 ff ff ff       	call   801a50 <fsipc>
}
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	53                   	push   %ebx
  801b06:	83 ec 14             	sub    $0x14,%esp
  801b09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b12:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b17:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1c:	b8 05 00 00 00       	mov    $0x5,%eax
  801b21:	e8 2a ff ff ff       	call   801a50 <fsipc>
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 2b                	js     801b55 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b2a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b31:	00 
  801b32:	89 1c 24             	mov    %ebx,(%esp)
  801b35:	e8 09 ee ff ff       	call   800943 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b3a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b3f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b45:	a1 84 50 80 00       	mov    0x805084,%eax
  801b4a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b55:	83 c4 14             	add    $0x14,%esp
  801b58:	5b                   	pop    %ebx
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b61:	c7 44 24 08 e4 2a 80 	movl   $0x802ae4,0x8(%esp)
  801b68:	00 
  801b69:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801b70:	00 
  801b71:	c7 04 24 02 2b 80 00 	movl   $0x802b02,(%esp)
  801b78:	e8 23 e7 ff ff       	call   8002a0 <_panic>

00801b7d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 10             	sub    $0x10,%esp
  801b85:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b88:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b93:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b99:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9e:	b8 03 00 00 00       	mov    $0x3,%eax
  801ba3:	e8 a8 fe ff ff       	call   801a50 <fsipc>
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 6a                	js     801c18 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bae:	39 c6                	cmp    %eax,%esi
  801bb0:	73 24                	jae    801bd6 <devfile_read+0x59>
  801bb2:	c7 44 24 0c 0d 2b 80 	movl   $0x802b0d,0xc(%esp)
  801bb9:	00 
  801bba:	c7 44 24 08 14 2b 80 	movl   $0x802b14,0x8(%esp)
  801bc1:	00 
  801bc2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801bc9:	00 
  801bca:	c7 04 24 02 2b 80 00 	movl   $0x802b02,(%esp)
  801bd1:	e8 ca e6 ff ff       	call   8002a0 <_panic>
	assert(r <= PGSIZE);
  801bd6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bdb:	7e 24                	jle    801c01 <devfile_read+0x84>
  801bdd:	c7 44 24 0c 29 2b 80 	movl   $0x802b29,0xc(%esp)
  801be4:	00 
  801be5:	c7 44 24 08 14 2b 80 	movl   $0x802b14,0x8(%esp)
  801bec:	00 
  801bed:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bf4:	00 
  801bf5:	c7 04 24 02 2b 80 00 	movl   $0x802b02,(%esp)
  801bfc:	e8 9f e6 ff ff       	call   8002a0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c01:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c05:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c0c:	00 
  801c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c10:	89 04 24             	mov    %eax,(%esp)
  801c13:	e8 a4 ee ff ff       	call   800abc <memmove>
	return r;
}
  801c18:	89 d8                	mov    %ebx,%eax
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	83 ec 20             	sub    $0x20,%esp
  801c29:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c2c:	89 34 24             	mov    %esi,(%esp)
  801c2f:	e8 dc ec ff ff       	call   800910 <strlen>
  801c34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c39:	7f 60                	jg     801c9b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 45 f8 ff ff       	call   80148b <fd_alloc>
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	78 54                	js     801ca0 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c50:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c57:	e8 e7 ec ff ff       	call   800943 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c67:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6c:	e8 df fd ff ff       	call   801a50 <fsipc>
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	85 c0                	test   %eax,%eax
  801c75:	79 15                	jns    801c8c <open+0x6b>
		fd_close(fd, 0);
  801c77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c7e:	00 
  801c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c82:	89 04 24             	mov    %eax,(%esp)
  801c85:	e8 04 f9 ff ff       	call   80158e <fd_close>
		return r;
  801c8a:	eb 14                	jmp    801ca0 <open+0x7f>
	}

	return fd2num(fd);
  801c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8f:	89 04 24             	mov    %eax,(%esp)
  801c92:	e8 c9 f7 ff ff       	call   801460 <fd2num>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	eb 05                	jmp    801ca0 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c9b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	83 c4 20             	add    $0x20,%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801caf:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb4:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb9:	e8 92 fd ff ff       	call   801a50 <fsipc>
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cc6:	89 c2                	mov    %eax,%edx
  801cc8:	c1 ea 16             	shr    $0x16,%edx
  801ccb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cd2:	f6 c2 01             	test   $0x1,%dl
  801cd5:	74 1e                	je     801cf5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cd7:	c1 e8 0c             	shr    $0xc,%eax
  801cda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ce1:	a8 01                	test   $0x1,%al
  801ce3:	74 17                	je     801cfc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ce5:	c1 e8 0c             	shr    $0xc,%eax
  801ce8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801cef:	ef 
  801cf0:	0f b7 c0             	movzwl %ax,%eax
  801cf3:	eb 0c                	jmp    801d01 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfa:	eb 05                	jmp    801d01 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cfc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
	...

00801d04 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	56                   	push   %esi
  801d08:	53                   	push   %ebx
  801d09:	83 ec 10             	sub    $0x10,%esp
  801d0c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d12:	89 04 24             	mov    %eax,(%esp)
  801d15:	e8 56 f7 ff ff       	call   801470 <fd2data>
  801d1a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d1c:	c7 44 24 04 35 2b 80 	movl   $0x802b35,0x4(%esp)
  801d23:	00 
  801d24:	89 34 24             	mov    %esi,(%esp)
  801d27:	e8 17 ec ff ff       	call   800943 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801d2f:	2b 03                	sub    (%ebx),%eax
  801d31:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d37:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d3e:	00 00 00 
	stat->st_dev = &devpipe;
  801d41:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801d48:	30 80 00 
	return 0;
}
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5e                   	pop    %esi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	53                   	push   %ebx
  801d5b:	83 ec 14             	sub    $0x14,%esp
  801d5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d61:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6c:	e8 6b f0 ff ff       	call   800ddc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d71:	89 1c 24             	mov    %ebx,(%esp)
  801d74:	e8 f7 f6 ff ff       	call   801470 <fd2data>
  801d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d84:	e8 53 f0 ff ff       	call   800ddc <sys_page_unmap>
}
  801d89:	83 c4 14             	add    $0x14,%esp
  801d8c:	5b                   	pop    %ebx
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	57                   	push   %edi
  801d93:	56                   	push   %esi
  801d94:	53                   	push   %ebx
  801d95:	83 ec 2c             	sub    $0x2c,%esp
  801d98:	89 c7                	mov    %eax,%edi
  801d9a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d9d:	a1 04 40 80 00       	mov    0x804004,%eax
  801da2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801da5:	89 3c 24             	mov    %edi,(%esp)
  801da8:	e8 13 ff ff ff       	call   801cc0 <pageref>
  801dad:	89 c6                	mov    %eax,%esi
  801daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db2:	89 04 24             	mov    %eax,(%esp)
  801db5:	e8 06 ff ff ff       	call   801cc0 <pageref>
  801dba:	39 c6                	cmp    %eax,%esi
  801dbc:	0f 94 c0             	sete   %al
  801dbf:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801dc2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dc8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dcb:	39 cb                	cmp    %ecx,%ebx
  801dcd:	75 08                	jne    801dd7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801dcf:	83 c4 2c             	add    $0x2c,%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5f                   	pop    %edi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801dd7:	83 f8 01             	cmp    $0x1,%eax
  801dda:	75 c1                	jne    801d9d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ddc:	8b 42 58             	mov    0x58(%edx),%eax
  801ddf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801de6:	00 
  801de7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801deb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801def:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  801df6:	e8 9d e5 ff ff       	call   800398 <cprintf>
  801dfb:	eb a0                	jmp    801d9d <_pipeisclosed+0xe>

00801dfd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	57                   	push   %edi
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
  801e03:	83 ec 1c             	sub    $0x1c,%esp
  801e06:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e09:	89 34 24             	mov    %esi,(%esp)
  801e0c:	e8 5f f6 ff ff       	call   801470 <fd2data>
  801e11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e13:	bf 00 00 00 00       	mov    $0x0,%edi
  801e18:	eb 3c                	jmp    801e56 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e1a:	89 da                	mov    %ebx,%edx
  801e1c:	89 f0                	mov    %esi,%eax
  801e1e:	e8 6c ff ff ff       	call   801d8f <_pipeisclosed>
  801e23:	85 c0                	test   %eax,%eax
  801e25:	75 38                	jne    801e5f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e27:	e8 ea ee ff ff       	call   800d16 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e2f:	8b 13                	mov    (%ebx),%edx
  801e31:	83 c2 20             	add    $0x20,%edx
  801e34:	39 d0                	cmp    %edx,%eax
  801e36:	73 e2                	jae    801e1a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e3e:	89 c2                	mov    %eax,%edx
  801e40:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e46:	79 05                	jns    801e4d <devpipe_write+0x50>
  801e48:	4a                   	dec    %edx
  801e49:	83 ca e0             	or     $0xffffffe0,%edx
  801e4c:	42                   	inc    %edx
  801e4d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e51:	40                   	inc    %eax
  801e52:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e55:	47                   	inc    %edi
  801e56:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e59:	75 d1                	jne    801e2c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e5b:	89 f8                	mov    %edi,%eax
  801e5d:	eb 05                	jmp    801e64 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e5f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	57                   	push   %edi
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	83 ec 1c             	sub    $0x1c,%esp
  801e75:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e78:	89 3c 24             	mov    %edi,(%esp)
  801e7b:	e8 f0 f5 ff ff       	call   801470 <fd2data>
  801e80:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e82:	be 00 00 00 00       	mov    $0x0,%esi
  801e87:	eb 3a                	jmp    801ec3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e89:	85 f6                	test   %esi,%esi
  801e8b:	74 04                	je     801e91 <devpipe_read+0x25>
				return i;
  801e8d:	89 f0                	mov    %esi,%eax
  801e8f:	eb 40                	jmp    801ed1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e91:	89 da                	mov    %ebx,%edx
  801e93:	89 f8                	mov    %edi,%eax
  801e95:	e8 f5 fe ff ff       	call   801d8f <_pipeisclosed>
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	75 2e                	jne    801ecc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e9e:	e8 73 ee ff ff       	call   800d16 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ea3:	8b 03                	mov    (%ebx),%eax
  801ea5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ea8:	74 df                	je     801e89 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eaa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801eaf:	79 05                	jns    801eb6 <devpipe_read+0x4a>
  801eb1:	48                   	dec    %eax
  801eb2:	83 c8 e0             	or     $0xffffffe0,%eax
  801eb5:	40                   	inc    %eax
  801eb6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801eba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ec0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec2:	46                   	inc    %esi
  801ec3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec6:	75 db                	jne    801ea3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ec8:	89 f0                	mov    %esi,%eax
  801eca:	eb 05                	jmp    801ed1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ecc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ed1:	83 c4 1c             	add    $0x1c,%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	57                   	push   %edi
  801edd:	56                   	push   %esi
  801ede:	53                   	push   %ebx
  801edf:	83 ec 3c             	sub    $0x3c,%esp
  801ee2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ee5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ee8:	89 04 24             	mov    %eax,(%esp)
  801eeb:	e8 9b f5 ff ff       	call   80148b <fd_alloc>
  801ef0:	89 c3                	mov    %eax,%ebx
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	0f 88 45 01 00 00    	js     80203f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f01:	00 
  801f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f10:	e8 20 ee ff ff       	call   800d35 <sys_page_alloc>
  801f15:	89 c3                	mov    %eax,%ebx
  801f17:	85 c0                	test   %eax,%eax
  801f19:	0f 88 20 01 00 00    	js     80203f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f1f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f22:	89 04 24             	mov    %eax,(%esp)
  801f25:	e8 61 f5 ff ff       	call   80148b <fd_alloc>
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	0f 88 f8 00 00 00    	js     80202c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f34:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f3b:	00 
  801f3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4a:	e8 e6 ed ff ff       	call   800d35 <sys_page_alloc>
  801f4f:	89 c3                	mov    %eax,%ebx
  801f51:	85 c0                	test   %eax,%eax
  801f53:	0f 88 d3 00 00 00    	js     80202c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f5c:	89 04 24             	mov    %eax,(%esp)
  801f5f:	e8 0c f5 ff ff       	call   801470 <fd2data>
  801f64:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f6d:	00 
  801f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f79:	e8 b7 ed ff ff       	call   800d35 <sys_page_alloc>
  801f7e:	89 c3                	mov    %eax,%ebx
  801f80:	85 c0                	test   %eax,%eax
  801f82:	0f 88 91 00 00 00    	js     802019 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f8b:	89 04 24             	mov    %eax,(%esp)
  801f8e:	e8 dd f4 ff ff       	call   801470 <fd2data>
  801f93:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f9a:	00 
  801f9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fa6:	00 
  801fa7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb2:	e8 d2 ed ff ff       	call   800d89 <sys_page_map>
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 4c                	js     802009 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fbd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fc6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fcb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fd2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fdb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fe0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fe7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fea:	89 04 24             	mov    %eax,(%esp)
  801fed:	e8 6e f4 ff ff       	call   801460 <fd2num>
  801ff2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ff4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ff7:	89 04 24             	mov    %eax,(%esp)
  801ffa:	e8 61 f4 ff ff       	call   801460 <fd2num>
  801fff:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802002:	bb 00 00 00 00       	mov    $0x0,%ebx
  802007:	eb 36                	jmp    80203f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802009:	89 74 24 04          	mov    %esi,0x4(%esp)
  80200d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802014:	e8 c3 ed ff ff       	call   800ddc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802019:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80201c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802020:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802027:	e8 b0 ed ff ff       	call   800ddc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80202c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80202f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802033:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203a:	e8 9d ed ff ff       	call   800ddc <sys_page_unmap>
    err:
	return r;
}
  80203f:	89 d8                	mov    %ebx,%eax
  802041:	83 c4 3c             	add    $0x3c,%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802052:	89 44 24 04          	mov    %eax,0x4(%esp)
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
  802059:	89 04 24             	mov    %eax,(%esp)
  80205c:	e8 7d f4 ff ff       	call   8014de <fd_lookup>
  802061:	85 c0                	test   %eax,%eax
  802063:	78 15                	js     80207a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802068:	89 04 24             	mov    %eax,(%esp)
  80206b:	e8 00 f4 ff ff       	call   801470 <fd2data>
	return _pipeisclosed(fd, p);
  802070:	89 c2                	mov    %eax,%edx
  802072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802075:	e8 15 fd ff ff       	call   801d8f <_pipeisclosed>
}
  80207a:	c9                   	leave  
  80207b:	c3                   	ret    

0080207c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80208c:	c7 44 24 04 54 2b 80 	movl   $0x802b54,0x4(%esp)
  802093:	00 
  802094:	8b 45 0c             	mov    0xc(%ebp),%eax
  802097:	89 04 24             	mov    %eax,(%esp)
  80209a:	e8 a4 e8 ff ff       	call   800943 <strcpy>
	return 0;
}
  80209f:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	57                   	push   %edi
  8020aa:	56                   	push   %esi
  8020ab:	53                   	push   %ebx
  8020ac:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020bd:	eb 30                	jmp    8020ef <devcons_write+0x49>
		m = n - tot;
  8020bf:	8b 75 10             	mov    0x10(%ebp),%esi
  8020c2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020c4:	83 fe 7f             	cmp    $0x7f,%esi
  8020c7:	76 05                	jbe    8020ce <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8020c9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020d2:	03 45 0c             	add    0xc(%ebp),%eax
  8020d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d9:	89 3c 24             	mov    %edi,(%esp)
  8020dc:	e8 db e9 ff ff       	call   800abc <memmove>
		sys_cputs(buf, m);
  8020e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020e5:	89 3c 24             	mov    %edi,(%esp)
  8020e8:	e8 7b eb ff ff       	call   800c68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020ed:	01 f3                	add    %esi,%ebx
  8020ef:	89 d8                	mov    %ebx,%eax
  8020f1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020f4:	72 c9                	jb     8020bf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020f6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020fc:	5b                   	pop    %ebx
  8020fd:	5e                   	pop    %esi
  8020fe:	5f                   	pop    %edi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    

00802101 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802101:	55                   	push   %ebp
  802102:	89 e5                	mov    %esp,%ebp
  802104:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802107:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80210b:	75 07                	jne    802114 <devcons_read+0x13>
  80210d:	eb 25                	jmp    802134 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80210f:	e8 02 ec ff ff       	call   800d16 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802114:	e8 6d eb ff ff       	call   800c86 <sys_cgetc>
  802119:	85 c0                	test   %eax,%eax
  80211b:	74 f2                	je     80210f <devcons_read+0xe>
  80211d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80211f:	85 c0                	test   %eax,%eax
  802121:	78 1d                	js     802140 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802123:	83 f8 04             	cmp    $0x4,%eax
  802126:	74 13                	je     80213b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802128:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212b:	88 10                	mov    %dl,(%eax)
	return 1;
  80212d:	b8 01 00 00 00       	mov    $0x1,%eax
  802132:	eb 0c                	jmp    802140 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802134:	b8 00 00 00 00       	mov    $0x0,%eax
  802139:	eb 05                	jmp    802140 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802140:	c9                   	leave  
  802141:	c3                   	ret    

00802142 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802148:	8b 45 08             	mov    0x8(%ebp),%eax
  80214b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80214e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802155:	00 
  802156:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802159:	89 04 24             	mov    %eax,(%esp)
  80215c:	e8 07 eb ff ff       	call   800c68 <sys_cputs>
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    

00802163 <getchar>:

int
getchar(void)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802169:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802170:	00 
  802171:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802174:	89 44 24 04          	mov    %eax,0x4(%esp)
  802178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217f:	e8 f6 f5 ff ff       	call   80177a <read>
	if (r < 0)
  802184:	85 c0                	test   %eax,%eax
  802186:	78 0f                	js     802197 <getchar+0x34>
		return r;
	if (r < 1)
  802188:	85 c0                	test   %eax,%eax
  80218a:	7e 06                	jle    802192 <getchar+0x2f>
		return -E_EOF;
	return c;
  80218c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802190:	eb 05                	jmp    802197 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802192:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802197:	c9                   	leave  
  802198:	c3                   	ret    

00802199 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	89 04 24             	mov    %eax,(%esp)
  8021ac:	e8 2d f3 ff ff       	call   8014de <fd_lookup>
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	78 11                	js     8021c6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021be:	39 10                	cmp    %edx,(%eax)
  8021c0:	0f 94 c0             	sete   %al
  8021c3:	0f b6 c0             	movzbl %al,%eax
}
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    

008021c8 <opencons>:

int
opencons(void)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 b2 f2 ff ff       	call   80148b <fd_alloc>
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	78 3c                	js     802219 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021e4:	00 
  8021e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f3:	e8 3d eb ff ff       	call   800d35 <sys_page_alloc>
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	78 1d                	js     802219 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021fc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802202:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802205:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802207:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802211:	89 04 24             	mov    %eax,(%esp)
  802214:	e8 47 f2 ff ff       	call   801460 <fd2num>
}
  802219:	c9                   	leave  
  80221a:	c3                   	ret    
	...

0080221c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802222:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802229:	75 32                	jne    80225d <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80222b:	e8 c7 ea ff ff       	call   800cf7 <sys_getenvid>
  802230:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  802237:	00 
  802238:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80223f:	ee 
  802240:	89 04 24             	mov    %eax,(%esp)
  802243:	e8 ed ea ff ff       	call   800d35 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  802248:	e8 aa ea ff ff       	call   800cf7 <sys_getenvid>
  80224d:	c7 44 24 04 68 22 80 	movl   $0x802268,0x4(%esp)
  802254:	00 
  802255:	89 04 24             	mov    %eax,(%esp)
  802258:	e8 78 ec ff ff       	call   800ed5 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80225d:	8b 45 08             	mov    0x8(%ebp),%eax
  802260:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802265:	c9                   	leave  
  802266:	c3                   	ret    
	...

00802268 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802268:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802269:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80226e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802270:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  802273:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  802277:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  80227a:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  80227f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  802283:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  802286:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  802287:	83 c4 04             	add    $0x4,%esp
	popfl
  80228a:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  80228b:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  80228c:	c3                   	ret    
  80228d:	00 00                	add    %al,(%eax)
	...

00802290 <__udivdi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	83 ec 10             	sub    $0x10,%esp
  802296:	8b 74 24 20          	mov    0x20(%esp),%esi
  80229a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80229e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022a6:	89 cd                	mov    %ecx,%ebp
  8022a8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	75 2c                	jne    8022dc <__udivdi3+0x4c>
  8022b0:	39 f9                	cmp    %edi,%ecx
  8022b2:	77 68                	ja     80231c <__udivdi3+0x8c>
  8022b4:	85 c9                	test   %ecx,%ecx
  8022b6:	75 0b                	jne    8022c3 <__udivdi3+0x33>
  8022b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	f7 f1                	div    %ecx
  8022c1:	89 c1                	mov    %eax,%ecx
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	89 f8                	mov    %edi,%eax
  8022c7:	f7 f1                	div    %ecx
  8022c9:	89 c7                	mov    %eax,%edi
  8022cb:	89 f0                	mov    %esi,%eax
  8022cd:	f7 f1                	div    %ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	89 fa                	mov    %edi,%edx
  8022d5:	83 c4 10             	add    $0x10,%esp
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    
  8022dc:	39 f8                	cmp    %edi,%eax
  8022de:	77 2c                	ja     80230c <__udivdi3+0x7c>
  8022e0:	0f bd f0             	bsr    %eax,%esi
  8022e3:	83 f6 1f             	xor    $0x1f,%esi
  8022e6:	75 4c                	jne    802334 <__udivdi3+0xa4>
  8022e8:	39 f8                	cmp    %edi,%eax
  8022ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ef:	72 0a                	jb     8022fb <__udivdi3+0x6b>
  8022f1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022f5:	0f 87 ad 00 00 00    	ja     8023a8 <__udivdi3+0x118>
  8022fb:	be 01 00 00 00       	mov    $0x1,%esi
  802300:	89 f0                	mov    %esi,%eax
  802302:	89 fa                	mov    %edi,%edx
  802304:	83 c4 10             	add    $0x10,%esp
  802307:	5e                   	pop    %esi
  802308:	5f                   	pop    %edi
  802309:	5d                   	pop    %ebp
  80230a:	c3                   	ret    
  80230b:	90                   	nop
  80230c:	31 ff                	xor    %edi,%edi
  80230e:	31 f6                	xor    %esi,%esi
  802310:	89 f0                	mov    %esi,%eax
  802312:	89 fa                	mov    %edi,%edx
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	5e                   	pop    %esi
  802318:	5f                   	pop    %edi
  802319:	5d                   	pop    %ebp
  80231a:	c3                   	ret    
  80231b:	90                   	nop
  80231c:	89 fa                	mov    %edi,%edx
  80231e:	89 f0                	mov    %esi,%eax
  802320:	f7 f1                	div    %ecx
  802322:	89 c6                	mov    %eax,%esi
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 f0                	mov    %esi,%eax
  802328:	89 fa                	mov    %edi,%edx
  80232a:	83 c4 10             	add    $0x10,%esp
  80232d:	5e                   	pop    %esi
  80232e:	5f                   	pop    %edi
  80232f:	5d                   	pop    %ebp
  802330:	c3                   	ret    
  802331:	8d 76 00             	lea    0x0(%esi),%esi
  802334:	89 f1                	mov    %esi,%ecx
  802336:	d3 e0                	shl    %cl,%eax
  802338:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80233c:	b8 20 00 00 00       	mov    $0x20,%eax
  802341:	29 f0                	sub    %esi,%eax
  802343:	89 ea                	mov    %ebp,%edx
  802345:	88 c1                	mov    %al,%cl
  802347:	d3 ea                	shr    %cl,%edx
  802349:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80234d:	09 ca                	or     %ecx,%edx
  80234f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802353:	89 f1                	mov    %esi,%ecx
  802355:	d3 e5                	shl    %cl,%ebp
  802357:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80235b:	89 fd                	mov    %edi,%ebp
  80235d:	88 c1                	mov    %al,%cl
  80235f:	d3 ed                	shr    %cl,%ebp
  802361:	89 fa                	mov    %edi,%edx
  802363:	89 f1                	mov    %esi,%ecx
  802365:	d3 e2                	shl    %cl,%edx
  802367:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80236b:	88 c1                	mov    %al,%cl
  80236d:	d3 ef                	shr    %cl,%edi
  80236f:	09 d7                	or     %edx,%edi
  802371:	89 f8                	mov    %edi,%eax
  802373:	89 ea                	mov    %ebp,%edx
  802375:	f7 74 24 08          	divl   0x8(%esp)
  802379:	89 d1                	mov    %edx,%ecx
  80237b:	89 c7                	mov    %eax,%edi
  80237d:	f7 64 24 0c          	mull   0xc(%esp)
  802381:	39 d1                	cmp    %edx,%ecx
  802383:	72 17                	jb     80239c <__udivdi3+0x10c>
  802385:	74 09                	je     802390 <__udivdi3+0x100>
  802387:	89 fe                	mov    %edi,%esi
  802389:	31 ff                	xor    %edi,%edi
  80238b:	e9 41 ff ff ff       	jmp    8022d1 <__udivdi3+0x41>
  802390:	8b 54 24 04          	mov    0x4(%esp),%edx
  802394:	89 f1                	mov    %esi,%ecx
  802396:	d3 e2                	shl    %cl,%edx
  802398:	39 c2                	cmp    %eax,%edx
  80239a:	73 eb                	jae    802387 <__udivdi3+0xf7>
  80239c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80239f:	31 ff                	xor    %edi,%edi
  8023a1:	e9 2b ff ff ff       	jmp    8022d1 <__udivdi3+0x41>
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	31 f6                	xor    %esi,%esi
  8023aa:	e9 22 ff ff ff       	jmp    8022d1 <__udivdi3+0x41>
	...

008023b0 <__umoddi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	83 ec 20             	sub    $0x20,%esp
  8023b6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023ba:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8023be:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023c2:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ca:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8023ce:	89 c7                	mov    %eax,%edi
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	85 ed                	test   %ebp,%ebp
  8023d4:	75 16                	jne    8023ec <__umoddi3+0x3c>
  8023d6:	39 f1                	cmp    %esi,%ecx
  8023d8:	0f 86 a6 00 00 00    	jbe    802484 <__umoddi3+0xd4>
  8023de:	f7 f1                	div    %ecx
  8023e0:	89 d0                	mov    %edx,%eax
  8023e2:	31 d2                	xor    %edx,%edx
  8023e4:	83 c4 20             	add    $0x20,%esp
  8023e7:	5e                   	pop    %esi
  8023e8:	5f                   	pop    %edi
  8023e9:	5d                   	pop    %ebp
  8023ea:	c3                   	ret    
  8023eb:	90                   	nop
  8023ec:	39 f5                	cmp    %esi,%ebp
  8023ee:	0f 87 ac 00 00 00    	ja     8024a0 <__umoddi3+0xf0>
  8023f4:	0f bd c5             	bsr    %ebp,%eax
  8023f7:	83 f0 1f             	xor    $0x1f,%eax
  8023fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023fe:	0f 84 a8 00 00 00    	je     8024ac <__umoddi3+0xfc>
  802404:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802408:	d3 e5                	shl    %cl,%ebp
  80240a:	bf 20 00 00 00       	mov    $0x20,%edi
  80240f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802413:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802417:	89 f9                	mov    %edi,%ecx
  802419:	d3 e8                	shr    %cl,%eax
  80241b:	09 e8                	or     %ebp,%eax
  80241d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802421:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802425:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802429:	d3 e0                	shl    %cl,%eax
  80242b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80242f:	89 f2                	mov    %esi,%edx
  802431:	d3 e2                	shl    %cl,%edx
  802433:	8b 44 24 14          	mov    0x14(%esp),%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80243d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802441:	89 f9                	mov    %edi,%ecx
  802443:	d3 e8                	shr    %cl,%eax
  802445:	09 d0                	or     %edx,%eax
  802447:	d3 ee                	shr    %cl,%esi
  802449:	89 f2                	mov    %esi,%edx
  80244b:	f7 74 24 18          	divl   0x18(%esp)
  80244f:	89 d6                	mov    %edx,%esi
  802451:	f7 64 24 0c          	mull   0xc(%esp)
  802455:	89 c5                	mov    %eax,%ebp
  802457:	89 d1                	mov    %edx,%ecx
  802459:	39 d6                	cmp    %edx,%esi
  80245b:	72 67                	jb     8024c4 <__umoddi3+0x114>
  80245d:	74 75                	je     8024d4 <__umoddi3+0x124>
  80245f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802463:	29 e8                	sub    %ebp,%eax
  802465:	19 ce                	sbb    %ecx,%esi
  802467:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	89 f2                	mov    %esi,%edx
  80246f:	89 f9                	mov    %edi,%ecx
  802471:	d3 e2                	shl    %cl,%edx
  802473:	09 d0                	or     %edx,%eax
  802475:	89 f2                	mov    %esi,%edx
  802477:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80247b:	d3 ea                	shr    %cl,%edx
  80247d:	83 c4 20             	add    $0x20,%esp
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	85 c9                	test   %ecx,%ecx
  802486:	75 0b                	jne    802493 <__umoddi3+0xe3>
  802488:	b8 01 00 00 00       	mov    $0x1,%eax
  80248d:	31 d2                	xor    %edx,%edx
  80248f:	f7 f1                	div    %ecx
  802491:	89 c1                	mov    %eax,%ecx
  802493:	89 f0                	mov    %esi,%eax
  802495:	31 d2                	xor    %edx,%edx
  802497:	f7 f1                	div    %ecx
  802499:	89 f8                	mov    %edi,%eax
  80249b:	e9 3e ff ff ff       	jmp    8023de <__umoddi3+0x2e>
  8024a0:	89 f2                	mov    %esi,%edx
  8024a2:	83 c4 20             	add    $0x20,%esp
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d 76 00             	lea    0x0(%esi),%esi
  8024ac:	39 f5                	cmp    %esi,%ebp
  8024ae:	72 04                	jb     8024b4 <__umoddi3+0x104>
  8024b0:	39 f9                	cmp    %edi,%ecx
  8024b2:	77 06                	ja     8024ba <__umoddi3+0x10a>
  8024b4:	89 f2                	mov    %esi,%edx
  8024b6:	29 cf                	sub    %ecx,%edi
  8024b8:	19 ea                	sbb    %ebp,%edx
  8024ba:	89 f8                	mov    %edi,%eax
  8024bc:	83 c4 20             	add    $0x20,%esp
  8024bf:	5e                   	pop    %esi
  8024c0:	5f                   	pop    %edi
  8024c1:	5d                   	pop    %ebp
  8024c2:	c3                   	ret    
  8024c3:	90                   	nop
  8024c4:	89 d1                	mov    %edx,%ecx
  8024c6:	89 c5                	mov    %eax,%ebp
  8024c8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024cc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024d0:	eb 8d                	jmp    80245f <__umoddi3+0xaf>
  8024d2:	66 90                	xchg   %ax,%ax
  8024d4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024d8:	72 ea                	jb     8024c4 <__umoddi3+0x114>
  8024da:	89 f1                	mov    %esi,%ecx
  8024dc:	eb 81                	jmp    80245f <__umoddi3+0xaf>
