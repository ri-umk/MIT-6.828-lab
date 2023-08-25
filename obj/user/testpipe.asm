
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 e7 02 00 00       	call   800318 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003c:	c7 05 04 30 80 00 40 	movl   $0x802640,0x803004
  800043:	26 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 14 1e 00 00       	call   801e65 <pipe>
  800051:	89 c6                	mov    %eax,%esi
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", i);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 4c 26 80 	movl   $0x80264c,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  800072:	e8 11 03 00 00       	call   800388 <_panic>

	if ((pid = fork()) < 0)
  800077:	e8 33 11 00 00       	call   8011af <fork>
  80007c:	89 c3                	mov    %eax,%ebx
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", i);
  800082:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800086:	c7 44 24 08 65 26 80 	movl   $0x802665,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  80009d:	e8 e6 02 00 00       	call   800388 <_panic>

	if (pid == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 85 d5 00 00 00    	jne    80017f <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8000af:	8b 40 48             	mov    0x48(%eax),%eax
  8000b2:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 6e 26 80 00 	movl   $0x80266e,(%esp)
  8000c4:	e8 b7 03 00 00       	call   800480 <cprintf>
		close(p[1]);
  8000c9:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cc:	89 04 24             	mov    %eax,(%esp)
  8000cf:	e8 12 15 00 00       	call   8015e6 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d9:	8b 40 48             	mov    0x48(%eax),%eax
  8000dc:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e7:	c7 04 24 8b 26 80 00 	movl   $0x80268b,(%esp)
  8000ee:	e8 8d 03 00 00       	call   800480 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f3:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000fa:	00 
  8000fb:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 cd 16 00 00       	call   8017da <readn>
  80010d:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	79 20                	jns    800133 <umain+0xff>
			panic("read: %e", i);
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	c7 44 24 08 a8 26 80 	movl   $0x8026a8,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  80012e:	e8 55 02 00 00       	call   800388 <_panic>
		buf[i] = 0;
  800133:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800138:	a1 00 30 80 00       	mov    0x803000,%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 86 09 00 00       	call   800ad2 <strcmp>
  80014c:	85 c0                	test   %eax,%eax
  80014e:	75 0e                	jne    80015e <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  800150:	c7 04 24 b1 26 80 00 	movl   $0x8026b1,(%esp)
  800157:	e8 24 03 00 00       	call   800480 <cprintf>
  80015c:	eb 17                	jmp    800175 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015e:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	89 74 24 04          	mov    %esi,0x4(%esp)
  800169:	c7 04 24 cd 26 80 00 	movl   $0x8026cd,(%esp)
  800170:	e8 0b 03 00 00       	call   800480 <cprintf>
		exit();
  800175:	e8 f2 01 00 00       	call   80036c <exit>
  80017a:	e9 ac 00 00 00       	jmp    80022b <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017f:	a1 04 40 80 00       	mov    0x804004,%eax
  800184:	8b 40 48             	mov    0x48(%eax),%eax
  800187:	8b 55 8c             	mov    -0x74(%ebp),%edx
  80018a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 6e 26 80 00 	movl   $0x80266e,(%esp)
  800199:	e8 e2 02 00 00       	call   800480 <cprintf>
		close(p[0]);
  80019e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 3d 14 00 00       	call   8015e6 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8001ae:	8b 40 48             	mov    0x48(%eax),%eax
  8001b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 e0 26 80 00 	movl   $0x8026e0,(%esp)
  8001c3:	e8 b8 02 00 00       	call   800480 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c8:	a1 00 30 80 00       	mov    0x803000,%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 23 08 00 00       	call   8009f8 <strlen>
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	a1 00 30 80 00       	mov    0x803000,%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 38 16 00 00       	call   801825 <write>
  8001ed:	89 c6                	mov    %eax,%esi
  8001ef:	a1 00 30 80 00       	mov    0x803000,%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 fc 07 00 00       	call   8009f8 <strlen>
  8001fc:	39 c6                	cmp    %eax,%esi
  8001fe:	74 20                	je     800220 <umain+0x1ec>
			panic("write: %e", i);
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	c7 44 24 08 fd 26 80 	movl   $0x8026fd,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  80021b:	e8 68 01 00 00       	call   800388 <_panic>
		close(p[1]);
  800220:	8b 45 90             	mov    -0x70(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	e8 bb 13 00 00       	call   8015e6 <close>
	}
	wait(pid);
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	e8 d5 1d 00 00       	call   802008 <wait>

	binaryname = "pipewriteeof";
  800233:	c7 05 04 30 80 00 07 	movl   $0x802707,0x803004
  80023a:	27 80 00 
	if ((i = pipe(p)) < 0)
  80023d:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 1d 1c 00 00       	call   801e65 <pipe>
  800248:	89 c6                	mov    %eax,%esi
  80024a:	85 c0                	test   %eax,%eax
  80024c:	79 20                	jns    80026e <umain+0x23a>
		panic("pipe: %e", i);
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	c7 44 24 08 4c 26 80 	movl   $0x80264c,0x8(%esp)
  800259:	00 
  80025a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800261:	00 
  800262:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  800269:	e8 1a 01 00 00       	call   800388 <_panic>

	if ((pid = fork()) < 0)
  80026e:	e8 3c 0f 00 00       	call   8011af <fork>
  800273:	89 c3                	mov    %eax,%ebx
  800275:	85 c0                	test   %eax,%eax
  800277:	79 20                	jns    800299 <umain+0x265>
		panic("fork: %e", i);
  800279:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027d:	c7 44 24 08 65 26 80 	movl   $0x802665,0x8(%esp)
  800284:	00 
  800285:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028c:	00 
  80028d:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  800294:	e8 ef 00 00 00       	call   800388 <_panic>

	if (pid == 0) {
  800299:	85 c0                	test   %eax,%eax
  80029b:	75 48                	jne    8002e5 <umain+0x2b1>
		close(p[0]);
  80029d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 3e 13 00 00       	call   8015e6 <close>
		while (1) {
			cprintf(".");
  8002a8:	c7 04 24 14 27 80 00 	movl   $0x802714,(%esp)
  8002af:	e8 cc 01 00 00       	call   800480 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002bb:	00 
  8002bc:	c7 44 24 04 16 27 80 	movl   $0x802716,0x4(%esp)
  8002c3:	00 
  8002c4:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 56 15 00 00       	call   801825 <write>
  8002cf:	83 f8 01             	cmp    $0x1,%eax
  8002d2:	74 d4                	je     8002a8 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d4:	c7 04 24 18 27 80 00 	movl   $0x802718,(%esp)
  8002db:	e8 a0 01 00 00       	call   800480 <cprintf>
		exit();
  8002e0:	e8 87 00 00 00       	call   80036c <exit>
	}
	close(p[0]);
  8002e5:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 f6 12 00 00       	call   8015e6 <close>
	close(p[1]);
  8002f0:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 eb 12 00 00       	call   8015e6 <close>
	wait(pid);
  8002fb:	89 1c 24             	mov    %ebx,(%esp)
  8002fe:	e8 05 1d 00 00       	call   802008 <wait>

	cprintf("pipe tests passed\n");
  800303:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  80030a:	e8 71 01 00 00       	call   800480 <cprintf>
}
  80030f:	83 ec 80             	sub    $0xffffff80,%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    
	...

00800318 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
  80031d:	83 ec 10             	sub    $0x10,%esp
  800320:	8b 75 08             	mov    0x8(%ebp),%esi
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800326:	e8 b4 0a 00 00       	call   800ddf <sys_getenvid>
  80032b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800330:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800337:	c1 e0 07             	shl    $0x7,%eax
  80033a:	29 d0                	sub    %edx,%eax
  80033c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800341:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800346:	85 f6                	test   %esi,%esi
  800348:	7e 07                	jle    800351 <libmain+0x39>
		binaryname = argv[0];
  80034a:	8b 03                	mov    (%ebx),%eax
  80034c:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	89 34 24             	mov    %esi,(%esp)
  800358:	e8 d7 fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80035d:	e8 0a 00 00 00       	call   80036c <exit>
}
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    
  800369:	00 00                	add    %al,(%eax)
	...

0080036c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800372:	e8 a0 12 00 00       	call   801617 <close_all>
	sys_env_destroy(0);
  800377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80037e:	e8 0a 0a 00 00       	call   800d8d <sys_env_destroy>
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    
  800385:	00 00                	add    %al,(%eax)
	...

00800388 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800393:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800399:	e8 41 0a 00 00       	call   800ddf <sys_getenvid>
  80039e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  8003bb:	e8 c0 00 00 00       	call   800480 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	e8 50 00 00 00       	call   80041f <vcprintf>
	cprintf("\n");
  8003cf:	c7 04 24 89 26 80 00 	movl   $0x802689,(%esp)
  8003d6:	e8 a5 00 00 00       	call   800480 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003db:	cc                   	int3   
  8003dc:	eb fd                	jmp    8003db <_panic+0x53>
	...

008003e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 14             	sub    $0x14,%esp
  8003e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ea:	8b 03                	mov    (%ebx),%eax
  8003ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f3:	40                   	inc    %eax
  8003f4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003fb:	75 19                	jne    800416 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003fd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800404:	00 
  800405:	8d 43 08             	lea    0x8(%ebx),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 40 09 00 00       	call   800d50 <sys_cputs>
		b->idx = 0;
  800410:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800416:	ff 43 04             	incl   0x4(%ebx)
}
  800419:	83 c4 14             	add    $0x14,%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800428:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042f:	00 00 00 
	b.cnt = 0;
  800432:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800439:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  80045b:	e8 82 01 00 00       	call   8005e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800460:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 d8 08 00 00       	call   800d50 <sys_cputs>

	return b.cnt;
}
  800478:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800486:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8b 45 08             	mov    0x8(%ebp),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	e8 87 ff ff ff       	call   80041f <vcprintf>
	va_end(ap);

	return cnt;
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    
	...

0080049c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 3c             	sub    $0x3c,%esp
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	89 d7                	mov    %edx,%edi
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	75 08                	jne    8004c8 <printnum+0x2c>
  8004c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004c6:	77 57                	ja     80051f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004cc:	4b                   	dec    %ebx
  8004cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004dc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e7:	00 
  8004e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	e8 ea 1e 00 00       	call   8023e4 <__udivdi3>
  8004fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	89 54 24 04          	mov    %edx,0x4(%esp)
  800509:	89 fa                	mov    %edi,%edx
  80050b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050e:	e8 89 ff ff ff       	call   80049c <printnum>
  800513:	eb 0f                	jmp    800524 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	89 34 24             	mov    %esi,(%esp)
  80051c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80051f:	4b                   	dec    %ebx
  800520:	85 db                	test   %ebx,%ebx
  800522:	7f f1                	jg     800515 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800524:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800528:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80052c:	8b 45 10             	mov    0x10(%ebp),%eax
  80052f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800533:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053a:	00 
  80053b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800544:	89 44 24 04          	mov    %eax,0x4(%esp)
  800548:	e8 b7 1f 00 00       	call   802504 <__umoddi3>
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	0f be 80 bb 27 80 00 	movsbl 0x8027bb(%eax),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80055e:	83 c4 3c             	add    $0x3c,%esp
  800561:	5b                   	pop    %ebx
  800562:	5e                   	pop    %esi
  800563:	5f                   	pop    %edi
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800569:	83 fa 01             	cmp    $0x1,%edx
  80056c:	7e 0e                	jle    80057c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	8d 4a 08             	lea    0x8(%edx),%ecx
  800573:	89 08                	mov    %ecx,(%eax)
  800575:	8b 02                	mov    (%edx),%eax
  800577:	8b 52 04             	mov    0x4(%edx),%edx
  80057a:	eb 22                	jmp    80059e <getuint+0x38>
	else if (lflag)
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 10                	je     800590 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800580:	8b 10                	mov    (%eax),%edx
  800582:	8d 4a 04             	lea    0x4(%edx),%ecx
  800585:	89 08                	mov    %ecx,(%eax)
  800587:	8b 02                	mov    (%edx),%eax
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	eb 0e                	jmp    80059e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ae:	73 08                	jae    8005b8 <sprintputch+0x18>
		*b->buf++ = ch;
  8005b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005b3:	88 0a                	mov    %cl,(%edx)
  8005b5:	42                   	inc    %edx
  8005b6:	89 10                	mov    %edx,(%eax)
}
  8005b8:	5d                   	pop    %ebp
  8005b9:	c3                   	ret    

008005ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	e8 02 00 00 00       	call   8005e2 <vprintfmt>
	va_end(ap);
}
  8005e0:	c9                   	leave  
  8005e1:	c3                   	ret    

008005e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	57                   	push   %edi
  8005e6:	56                   	push   %esi
  8005e7:	53                   	push   %ebx
  8005e8:	83 ec 4c             	sub    $0x4c,%esp
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f1:	eb 12                	jmp    800605 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	0f 84 6b 03 00 00    	je     800966 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800605:	0f b6 06             	movzbl (%esi),%eax
  800608:	46                   	inc    %esi
  800609:	83 f8 25             	cmp    $0x25,%eax
  80060c:	75 e5                	jne    8005f3 <vprintfmt+0x11>
  80060e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800612:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800619:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80061e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062a:	eb 26                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80062f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800633:	eb 1d                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800638:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80063c:	eb 14                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800641:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800648:	eb 08                	jmp    800652 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80064a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80064d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	0f b6 06             	movzbl (%esi),%eax
  800655:	8d 56 01             	lea    0x1(%esi),%edx
  800658:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80065b:	8a 16                	mov    (%esi),%dl
  80065d:	83 ea 23             	sub    $0x23,%edx
  800660:	80 fa 55             	cmp    $0x55,%dl
  800663:	0f 87 e1 02 00 00    	ja     80094a <vprintfmt+0x368>
  800669:	0f b6 d2             	movzbl %dl,%edx
  80066c:	ff 24 95 00 29 80 00 	jmp    *0x802900(,%edx,4)
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80067b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80067e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800682:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800685:	8d 50 d0             	lea    -0x30(%eax),%edx
  800688:	83 fa 09             	cmp    $0x9,%edx
  80068b:	77 2a                	ja     8006b7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80068d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80068e:	eb eb                	jmp    80067b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80069e:	eb 17                	jmp    8006b7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a4:	78 98                	js     80063e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a9:	eb a7                	jmp    800652 <vprintfmt+0x70>
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006ae:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006b5:	eb 9b                	jmp    800652 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bb:	79 95                	jns    800652 <vprintfmt+0x70>
  8006bd:	eb 8b                	jmp    80064a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006bf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c3:	eb 8d                	jmp    800652 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 04             	lea    0x4(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006dd:	e9 23 ff ff ff       	jmp    800605 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 04             	lea    0x4(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	79 02                	jns    8006f3 <vprintfmt+0x111>
  8006f1:	f7 d8                	neg    %eax
  8006f3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f5:	83 f8 0f             	cmp    $0xf,%eax
  8006f8:	7f 0b                	jg     800705 <vprintfmt+0x123>
  8006fa:	8b 04 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%eax
  800701:	85 c0                	test   %eax,%eax
  800703:	75 23                	jne    800728 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800705:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800709:	c7 44 24 08 d3 27 80 	movl   $0x8027d3,0x8(%esp)
  800710:	00 
  800711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	89 04 24             	mov    %eax,(%esp)
  80071b:	e8 9a fe ff ff       	call   8005ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800720:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800723:	e9 dd fe ff ff       	jmp    800605 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800728:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072c:	c7 44 24 08 ce 2c 80 	movl   $0x802cce,0x8(%esp)
  800733:	00 
  800734:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
  80073b:	89 14 24             	mov    %edx,(%esp)
  80073e:	e8 77 fe ff ff       	call   8005ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800746:	e9 ba fe ff ff       	jmp    800605 <vprintfmt+0x23>
  80074b:	89 f9                	mov    %edi,%ecx
  80074d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800750:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 50 04             	lea    0x4(%eax),%edx
  800759:	89 55 14             	mov    %edx,0x14(%ebp)
  80075c:	8b 30                	mov    (%eax),%esi
  80075e:	85 f6                	test   %esi,%esi
  800760:	75 05                	jne    800767 <vprintfmt+0x185>
				p = "(null)";
  800762:	be cc 27 80 00       	mov    $0x8027cc,%esi
			if (width > 0 && padc != '-')
  800767:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80076b:	0f 8e 84 00 00 00    	jle    8007f5 <vprintfmt+0x213>
  800771:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800775:	74 7e                	je     8007f5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800777:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077b:	89 34 24             	mov    %esi,(%esp)
  80077e:	e8 8b 02 00 00       	call   800a0e <strnlen>
  800783:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800786:	29 c2                	sub    %eax,%edx
  800788:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80078b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80078f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800792:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800795:	89 de                	mov    %ebx,%esi
  800797:	89 d3                	mov    %edx,%ebx
  800799:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079b:	eb 0b                	jmp    8007a8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80079d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a1:	89 3c 24             	mov    %edi,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a7:	4b                   	dec    %ebx
  8007a8:	85 db                	test   %ebx,%ebx
  8007aa:	7f f1                	jg     80079d <vprintfmt+0x1bb>
  8007ac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007af:	89 f3                	mov    %esi,%ebx
  8007b1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	79 05                	jns    8007c0 <vprintfmt+0x1de>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c3:	29 c2                	sub    %eax,%edx
  8007c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007c8:	eb 2b                	jmp    8007f5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ce:	74 18                	je     8007e8 <vprintfmt+0x206>
  8007d0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007d3:	83 fa 5e             	cmp    $0x5e,%edx
  8007d6:	76 10                	jbe    8007e8 <vprintfmt+0x206>
					putch('?', putdat);
  8007d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
  8007e6:	eb 0a                	jmp    8007f2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f2:	ff 4d e4             	decl   -0x1c(%ebp)
  8007f5:	0f be 06             	movsbl (%esi),%eax
  8007f8:	46                   	inc    %esi
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	74 21                	je     80081e <vprintfmt+0x23c>
  8007fd:	85 ff                	test   %edi,%edi
  8007ff:	78 c9                	js     8007ca <vprintfmt+0x1e8>
  800801:	4f                   	dec    %edi
  800802:	79 c6                	jns    8007ca <vprintfmt+0x1e8>
  800804:	8b 7d 08             	mov    0x8(%ebp),%edi
  800807:	89 de                	mov    %ebx,%esi
  800809:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80080c:	eb 18                	jmp    800826 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80080e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800812:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800819:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80081b:	4b                   	dec    %ebx
  80081c:	eb 08                	jmp    800826 <vprintfmt+0x244>
  80081e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800821:	89 de                	mov    %ebx,%esi
  800823:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800826:	85 db                	test   %ebx,%ebx
  800828:	7f e4                	jg     80080e <vprintfmt+0x22c>
  80082a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80082d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800832:	e9 ce fd ff ff       	jmp    800605 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800837:	83 f9 01             	cmp    $0x1,%ecx
  80083a:	7e 10                	jle    80084c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 08             	lea    0x8(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 30                	mov    (%eax),%esi
  800847:	8b 78 04             	mov    0x4(%eax),%edi
  80084a:	eb 26                	jmp    800872 <vprintfmt+0x290>
	else if (lflag)
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	74 12                	je     800862 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 30                	mov    (%eax),%esi
  80085b:	89 f7                	mov    %esi,%edi
  80085d:	c1 ff 1f             	sar    $0x1f,%edi
  800860:	eb 10                	jmp    800872 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8d 50 04             	lea    0x4(%eax),%edx
  800868:	89 55 14             	mov    %edx,0x14(%ebp)
  80086b:	8b 30                	mov    (%eax),%esi
  80086d:	89 f7                	mov    %esi,%edi
  80086f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800872:	85 ff                	test   %edi,%edi
  800874:	78 0a                	js     800880 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800876:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087b:	e9 8c 00 00 00       	jmp    80090c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80088e:	f7 de                	neg    %esi
  800890:	83 d7 00             	adc    $0x0,%edi
  800893:	f7 df                	neg    %edi
			}
			base = 10;
  800895:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089a:	eb 70                	jmp    80090c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80089c:	89 ca                	mov    %ecx,%edx
  80089e:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a1:	e8 c0 fc ff ff       	call   800566 <getuint>
  8008a6:	89 c6                	mov    %eax,%esi
  8008a8:	89 d7                	mov    %edx,%edi
			base = 10;
  8008aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008af:	eb 5b                	jmp    80090c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008b1:	89 ca                	mov    %ecx,%edx
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b6:	e8 ab fc ff ff       	call   800566 <getuint>
  8008bb:	89 c6                	mov    %eax,%esi
  8008bd:	89 d7                	mov    %edx,%edi
			base = 8;
  8008bf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008c4:	eb 46                	jmp    80090c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8008c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ca:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008df:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8d 50 04             	lea    0x4(%eax),%edx
  8008e8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008eb:	8b 30                	mov    (%eax),%esi
  8008ed:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008f2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008f7:	eb 13                	jmp    80090c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f9:	89 ca                	mov    %ecx,%edx
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fe:	e8 63 fc ff ff       	call   800566 <getuint>
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d7                	mov    %edx,%edi
			base = 16;
  800907:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80090c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800910:	89 54 24 10          	mov    %edx,0x10(%esp)
  800914:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800917:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80091b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091f:	89 34 24             	mov    %esi,(%esp)
  800922:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800926:	89 da                	mov    %ebx,%edx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	e8 6c fb ff ff       	call   80049c <printnum>
			break;
  800930:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800933:	e9 cd fc ff ff       	jmp    800605 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800938:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093c:	89 04 24             	mov    %eax,(%esp)
  80093f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800942:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800945:	e9 bb fc ff ff       	jmp    800605 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80094a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800955:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800958:	eb 01                	jmp    80095b <vprintfmt+0x379>
  80095a:	4e                   	dec    %esi
  80095b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80095f:	75 f9                	jne    80095a <vprintfmt+0x378>
  800961:	e9 9f fc ff ff       	jmp    800605 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800966:	83 c4 4c             	add    $0x4c,%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 28             	sub    $0x28,%esp
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80097d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800981:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800984:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80098b:	85 c0                	test   %eax,%eax
  80098d:	74 30                	je     8009bf <vsnprintf+0x51>
  80098f:	85 d2                	test   %edx,%edx
  800991:	7e 33                	jle    8009c6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099a:	8b 45 10             	mov    0x10(%ebp),%eax
  80099d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	c7 04 24 a0 05 80 00 	movl   $0x8005a0,(%esp)
  8009af:	e8 2e fc ff ff       	call   8005e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bd:	eb 0c                	jmp    8009cb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c4:	eb 05                	jmp    8009cb <vsnprintf+0x5d>
  8009c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009da:	8b 45 10             	mov    0x10(%ebp),%eax
  8009dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	89 04 24             	mov    %eax,(%esp)
  8009ee:	e8 7b ff ff ff       	call   80096e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    
  8009f5:	00 00                	add    %al,(%eax)
	...

008009f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	eb 01                	jmp    800a06 <strlen+0xe>
		n++;
  800a05:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0a:	75 f9                	jne    800a05 <strlen+0xd>
		n++;
	return n;
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	eb 01                	jmp    800a1f <strnlen+0x11>
		n++;
  800a1e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	74 06                	je     800a29 <strnlen+0x1b>
  800a23:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a27:	75 f5                	jne    800a1e <strnlen+0x10>
		n++;
	return n;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a3d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a40:	42                   	inc    %edx
  800a41:	84 c9                	test   %cl,%cl
  800a43:	75 f5                	jne    800a3a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a45:	5b                   	pop    %ebx
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	53                   	push   %ebx
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a52:	89 1c 24             	mov    %ebx,(%esp)
  800a55:	e8 9e ff ff ff       	call   8009f8 <strlen>
	strcpy(dst + len, src);
  800a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a61:	01 d8                	add    %ebx,%eax
  800a63:	89 04 24             	mov    %eax,(%esp)
  800a66:	e8 c0 ff ff ff       	call   800a2b <strcpy>
	return dst;
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	83 c4 08             	add    $0x8,%esp
  800a70:	5b                   	pop    %ebx
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a86:	eb 0c                	jmp    800a94 <strncpy+0x21>
		*dst++ = *src;
  800a88:	8a 1a                	mov    (%edx),%bl
  800a8a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8d:	80 3a 01             	cmpb   $0x1,(%edx)
  800a90:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a93:	41                   	inc    %ecx
  800a94:	39 f1                	cmp    %esi,%ecx
  800a96:	75 f0                	jne    800a88 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aaa:	85 d2                	test   %edx,%edx
  800aac:	75 0a                	jne    800ab8 <strlcpy+0x1c>
  800aae:	89 f0                	mov    %esi,%eax
  800ab0:	eb 1a                	jmp    800acc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab2:	88 18                	mov    %bl,(%eax)
  800ab4:	40                   	inc    %eax
  800ab5:	41                   	inc    %ecx
  800ab6:	eb 02                	jmp    800aba <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800aba:	4a                   	dec    %edx
  800abb:	74 0a                	je     800ac7 <strlcpy+0x2b>
  800abd:	8a 19                	mov    (%ecx),%bl
  800abf:	84 db                	test   %bl,%bl
  800ac1:	75 ef                	jne    800ab2 <strlcpy+0x16>
  800ac3:	89 c2                	mov    %eax,%edx
  800ac5:	eb 02                	jmp    800ac9 <strlcpy+0x2d>
  800ac7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ac9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800acc:	29 f0                	sub    %esi,%eax
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adb:	eb 02                	jmp    800adf <strcmp+0xd>
		p++, q++;
  800add:	41                   	inc    %ecx
  800ade:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800adf:	8a 01                	mov    (%ecx),%al
  800ae1:	84 c0                	test   %al,%al
  800ae3:	74 04                	je     800ae9 <strcmp+0x17>
  800ae5:	3a 02                	cmp    (%edx),%al
  800ae7:	74 f4                	je     800add <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae9:	0f b6 c0             	movzbl %al,%eax
  800aec:	0f b6 12             	movzbl (%edx),%edx
  800aef:	29 d0                	sub    %edx,%eax
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	53                   	push   %ebx
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b00:	eb 03                	jmp    800b05 <strncmp+0x12>
		n--, p++, q++;
  800b02:	4a                   	dec    %edx
  800b03:	40                   	inc    %eax
  800b04:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b05:	85 d2                	test   %edx,%edx
  800b07:	74 14                	je     800b1d <strncmp+0x2a>
  800b09:	8a 18                	mov    (%eax),%bl
  800b0b:	84 db                	test   %bl,%bl
  800b0d:	74 04                	je     800b13 <strncmp+0x20>
  800b0f:	3a 19                	cmp    (%ecx),%bl
  800b11:	74 ef                	je     800b02 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b13:	0f b6 00             	movzbl (%eax),%eax
  800b16:	0f b6 11             	movzbl (%ecx),%edx
  800b19:	29 d0                	sub    %edx,%eax
  800b1b:	eb 05                	jmp    800b22 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b2e:	eb 05                	jmp    800b35 <strchr+0x10>
		if (*s == c)
  800b30:	38 ca                	cmp    %cl,%dl
  800b32:	74 0c                	je     800b40 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b34:	40                   	inc    %eax
  800b35:	8a 10                	mov    (%eax),%dl
  800b37:	84 d2                	test   %dl,%dl
  800b39:	75 f5                	jne    800b30 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b4b:	eb 05                	jmp    800b52 <strfind+0x10>
		if (*s == c)
  800b4d:	38 ca                	cmp    %cl,%dl
  800b4f:	74 07                	je     800b58 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b51:	40                   	inc    %eax
  800b52:	8a 10                	mov    (%eax),%dl
  800b54:	84 d2                	test   %dl,%dl
  800b56:	75 f5                	jne    800b4d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b69:	85 c9                	test   %ecx,%ecx
  800b6b:	74 30                	je     800b9d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b73:	75 25                	jne    800b9a <memset+0x40>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	75 20                	jne    800b9a <memset+0x40>
		c &= 0xFF;
  800b7a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7d:	89 d3                	mov    %edx,%ebx
  800b7f:	c1 e3 08             	shl    $0x8,%ebx
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	c1 e6 18             	shl    $0x18,%esi
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	c1 e0 10             	shl    $0x10,%eax
  800b8c:	09 f0                	or     %esi,%eax
  800b8e:	09 d0                	or     %edx,%eax
  800b90:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b92:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b95:	fc                   	cld    
  800b96:	f3 ab                	rep stos %eax,%es:(%edi)
  800b98:	eb 03                	jmp    800b9d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9a:	fc                   	cld    
  800b9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b9d:	89 f8                	mov    %edi,%eax
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800baf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb2:	39 c6                	cmp    %eax,%esi
  800bb4:	73 34                	jae    800bea <memmove+0x46>
  800bb6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb9:	39 d0                	cmp    %edx,%eax
  800bbb:	73 2d                	jae    800bea <memmove+0x46>
		s += n;
		d += n;
  800bbd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc0:	f6 c2 03             	test   $0x3,%dl
  800bc3:	75 1b                	jne    800be0 <memmove+0x3c>
  800bc5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcb:	75 13                	jne    800be0 <memmove+0x3c>
  800bcd:	f6 c1 03             	test   $0x3,%cl
  800bd0:	75 0e                	jne    800be0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd2:	83 ef 04             	sub    $0x4,%edi
  800bd5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bdb:	fd                   	std    
  800bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bde:	eb 07                	jmp    800be7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be0:	4f                   	dec    %edi
  800be1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be4:	fd                   	std    
  800be5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800be7:	fc                   	cld    
  800be8:	eb 20                	jmp    800c0a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf0:	75 13                	jne    800c05 <memmove+0x61>
  800bf2:	a8 03                	test   $0x3,%al
  800bf4:	75 0f                	jne    800c05 <memmove+0x61>
  800bf6:	f6 c1 03             	test   $0x3,%cl
  800bf9:	75 0a                	jne    800c05 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bfb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bfe:	89 c7                	mov    %eax,%edi
  800c00:	fc                   	cld    
  800c01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c03:	eb 05                	jmp    800c0a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c05:	89 c7                	mov    %eax,%edi
  800c07:	fc                   	cld    
  800c08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c14:	8b 45 10             	mov    0x10(%ebp),%eax
  800c17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	89 04 24             	mov    %eax,(%esp)
  800c28:	e8 77 ff ff ff       	call   800ba4 <memmove>
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	eb 16                	jmp    800c5b <memcmp+0x2c>
		if (*s1 != *s2)
  800c45:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c48:	42                   	inc    %edx
  800c49:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c4d:	38 c8                	cmp    %cl,%al
  800c4f:	74 0a                	je     800c5b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c51:	0f b6 c0             	movzbl %al,%eax
  800c54:	0f b6 c9             	movzbl %cl,%ecx
  800c57:	29 c8                	sub    %ecx,%eax
  800c59:	eb 09                	jmp    800c64 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5b:	39 da                	cmp    %ebx,%edx
  800c5d:	75 e6                	jne    800c45 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c72:	89 c2                	mov    %eax,%edx
  800c74:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c77:	eb 05                	jmp    800c7e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c79:	38 08                	cmp    %cl,(%eax)
  800c7b:	74 05                	je     800c82 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7d:	40                   	inc    %eax
  800c7e:	39 d0                	cmp    %edx,%eax
  800c80:	72 f7                	jb     800c79 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c90:	eb 01                	jmp    800c93 <strtol+0xf>
		s++;
  800c92:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c93:	8a 02                	mov    (%edx),%al
  800c95:	3c 20                	cmp    $0x20,%al
  800c97:	74 f9                	je     800c92 <strtol+0xe>
  800c99:	3c 09                	cmp    $0x9,%al
  800c9b:	74 f5                	je     800c92 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c9d:	3c 2b                	cmp    $0x2b,%al
  800c9f:	75 08                	jne    800ca9 <strtol+0x25>
		s++;
  800ca1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca7:	eb 13                	jmp    800cbc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ca9:	3c 2d                	cmp    $0x2d,%al
  800cab:	75 0a                	jne    800cb7 <strtol+0x33>
		s++, neg = 1;
  800cad:	8d 52 01             	lea    0x1(%edx),%edx
  800cb0:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb5:	eb 05                	jmp    800cbc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbc:	85 db                	test   %ebx,%ebx
  800cbe:	74 05                	je     800cc5 <strtol+0x41>
  800cc0:	83 fb 10             	cmp    $0x10,%ebx
  800cc3:	75 28                	jne    800ced <strtol+0x69>
  800cc5:	8a 02                	mov    (%edx),%al
  800cc7:	3c 30                	cmp    $0x30,%al
  800cc9:	75 10                	jne    800cdb <strtol+0x57>
  800ccb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ccf:	75 0a                	jne    800cdb <strtol+0x57>
		s += 2, base = 16;
  800cd1:	83 c2 02             	add    $0x2,%edx
  800cd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd9:	eb 12                	jmp    800ced <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cdb:	85 db                	test   %ebx,%ebx
  800cdd:	75 0e                	jne    800ced <strtol+0x69>
  800cdf:	3c 30                	cmp    $0x30,%al
  800ce1:	75 05                	jne    800ce8 <strtol+0x64>
		s++, base = 8;
  800ce3:	42                   	inc    %edx
  800ce4:	b3 08                	mov    $0x8,%bl
  800ce6:	eb 05                	jmp    800ced <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ce8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf4:	8a 0a                	mov    (%edx),%cl
  800cf6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf9:	80 fb 09             	cmp    $0x9,%bl
  800cfc:	77 08                	ja     800d06 <strtol+0x82>
			dig = *s - '0';
  800cfe:	0f be c9             	movsbl %cl,%ecx
  800d01:	83 e9 30             	sub    $0x30,%ecx
  800d04:	eb 1e                	jmp    800d24 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d06:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d09:	80 fb 19             	cmp    $0x19,%bl
  800d0c:	77 08                	ja     800d16 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d0e:	0f be c9             	movsbl %cl,%ecx
  800d11:	83 e9 57             	sub    $0x57,%ecx
  800d14:	eb 0e                	jmp    800d24 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d16:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d19:	80 fb 19             	cmp    $0x19,%bl
  800d1c:	77 12                	ja     800d30 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d1e:	0f be c9             	movsbl %cl,%ecx
  800d21:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d24:	39 f1                	cmp    %esi,%ecx
  800d26:	7d 0c                	jge    800d34 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d28:	42                   	inc    %edx
  800d29:	0f af c6             	imul   %esi,%eax
  800d2c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d2e:	eb c4                	jmp    800cf4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d30:	89 c1                	mov    %eax,%ecx
  800d32:	eb 02                	jmp    800d36 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d34:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d3a:	74 05                	je     800d41 <strtol+0xbd>
		*endptr = (char *) s;
  800d3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d3f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d41:	85 ff                	test   %edi,%edi
  800d43:	74 04                	je     800d49 <strtol+0xc5>
  800d45:	89 c8                	mov    %ecx,%eax
  800d47:	f7 d8                	neg    %eax
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    
	...

00800d50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 c3                	mov    %eax,%ebx
  800d63:	89 c7                	mov    %eax,%edi
  800d65:	89 c6                	mov    %eax,%esi
  800d67:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	ba 00 00 00 00       	mov    $0x0,%edx
  800d79:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7e:	89 d1                	mov    %edx,%ecx
  800d80:	89 d3                	mov    %edx,%ebx
  800d82:	89 d7                	mov    %edx,%edi
  800d84:	89 d6                	mov    %edx,%esi
  800d86:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 cb                	mov    %ecx,%ebx
  800da5:	89 cf                	mov    %ecx,%edi
  800da7:	89 ce                	mov    %ecx,%esi
  800da9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 28                	jle    800dd7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dba:	00 
  800dbb:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dca:	00 
  800dcb:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800dd2:	e8 b1 f5 ff ff       	call   800388 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dd7:	83 c4 2c             	add    $0x2c,%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dea:	b8 02 00 00 00       	mov    $0x2,%eax
  800def:	89 d1                	mov    %edx,%ecx
  800df1:	89 d3                	mov    %edx,%ebx
  800df3:	89 d7                	mov    %edx,%edi
  800df5:	89 d6                	mov    %edx,%esi
  800df7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <sys_yield>:

void
sys_yield(void)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
  800e09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e0e:	89 d1                	mov    %edx,%ecx
  800e10:	89 d3                	mov    %edx,%ebx
  800e12:	89 d7                	mov    %edx,%edi
  800e14:	89 d6                	mov    %edx,%esi
  800e16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	be 00 00 00 00       	mov    $0x0,%esi
  800e2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 f7                	mov    %esi,%edi
  800e3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	7e 28                	jle    800e69 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e45:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800e54:	00 
  800e55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5c:	00 
  800e5d:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800e64:	e8 1f f5 ff ff       	call   800388 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e69:	83 c4 2c             	add    $0x2c,%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e7f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e90:	85 c0                	test   %eax,%eax
  800e92:	7e 28                	jle    800ebc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e98:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eaf:	00 
  800eb0:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800eb7:	e8 cc f4 ff ff       	call   800388 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ebc:	83 c4 2c             	add    $0x2c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
  800eca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 df                	mov    %ebx,%edi
  800edf:	89 de                	mov    %ebx,%esi
  800ee1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 28                	jle    800f0f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eeb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800f0a:	e8 79 f4 ff ff       	call   800388 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f0f:	83 c4 2c             	add    $0x2c,%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f25:	b8 08 00 00 00       	mov    $0x8,%eax
  800f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	89 df                	mov    %ebx,%edi
  800f32:	89 de                	mov    %ebx,%esi
  800f34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f36:	85 c0                	test   %eax,%eax
  800f38:	7e 28                	jle    800f62 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f45:	00 
  800f46:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f55:	00 
  800f56:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800f5d:	e8 26 f4 ff ff       	call   800388 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f62:	83 c4 2c             	add    $0x2c,%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f78:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 df                	mov    %ebx,%edi
  800f85:	89 de                	mov    %ebx,%esi
  800f87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 28                	jle    800fb5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f91:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f98:	00 
  800f99:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  800fb0:	e8 d3 f3 ff ff       	call   800388 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fb5:	83 c4 2c             	add    $0x2c,%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 df                	mov    %ebx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 28                	jle    801008 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801003:	e8 80 f3 ff ff       	call   800388 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801008:	83 c4 2c             	add    $0x2c,%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	be 00 00 00 00       	mov    $0x0,%esi
  80101b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801020:	8b 7d 14             	mov    0x14(%ebp),%edi
  801023:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801041:	b8 0d 00 00 00       	mov    $0xd,%eax
  801046:	8b 55 08             	mov    0x8(%ebp),%edx
  801049:	89 cb                	mov    %ecx,%ebx
  80104b:	89 cf                	mov    %ecx,%edi
  80104d:	89 ce                	mov    %ecx,%esi
  80104f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801051:	85 c0                	test   %eax,%eax
  801053:	7e 28                	jle    80107d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801055:	89 44 24 10          	mov    %eax,0x10(%esp)
  801059:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801060:	00 
  801061:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801078:	e8 0b f3 ff ff       	call   800388 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80107d:	83 c4 2c             	add    $0x2c,%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    
  801085:	00 00                	add    %al,(%eax)
	...

00801088 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	53                   	push   %ebx
  80108c:	83 ec 24             	sub    $0x24,%esp
  80108f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801092:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  801094:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801098:	75 2d                	jne    8010c7 <pgfault+0x3f>
  80109a:	89 d8                	mov    %ebx,%eax
  80109c:	c1 e8 0c             	shr    $0xc,%eax
  80109f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a6:	f6 c4 08             	test   $0x8,%ah
  8010a9:	75 1c                	jne    8010c7 <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  8010ab:	c7 44 24 08 ec 2a 80 	movl   $0x802aec,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8010c2:	e8 c1 f2 ff ff       	call   800388 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8010c7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010ce:	00 
  8010cf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010d6:	00 
  8010d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010de:	e8 3a fd ff ff       	call   800e1d <sys_page_alloc>
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	79 20                	jns    801107 <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  8010e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010eb:	c7 44 24 08 5b 2b 80 	movl   $0x802b5b,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010fa:	00 
  8010fb:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  801102:	e8 81 f2 ff ff       	call   800388 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  801107:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  80110d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801114:	00 
  801115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801119:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801120:	e8 e9 fa ff ff       	call   800c0e <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801125:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80112c:	00 
  80112d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801131:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801138:	00 
  801139:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801140:	00 
  801141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801148:	e8 24 fd ff ff       	call   800e71 <sys_page_map>
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 20                	jns    801171 <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  801151:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801155:	c7 44 24 08 6e 2b 80 	movl   $0x802b6e,0x8(%esp)
  80115c:	00 
  80115d:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801164:	00 
  801165:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  80116c:	e8 17 f2 ff ff       	call   800388 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801171:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801178:	00 
  801179:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801180:	e8 3f fd ff ff       	call   800ec4 <sys_page_unmap>
  801185:	85 c0                	test   %eax,%eax
  801187:	79 20                	jns    8011a9 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  801189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118d:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  801194:	00 
  801195:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80119c:	00 
  80119d:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8011a4:	e8 df f1 ff ff       	call   800388 <_panic>
}
  8011a9:	83 c4 24             	add    $0x24,%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  8011b8:	c7 04 24 88 10 80 00 	movl   $0x801088,(%esp)
  8011bf:	e8 50 10 00 00       	call   802214 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011c4:	ba 07 00 00 00       	mov    $0x7,%edx
  8011c9:	89 d0                	mov    %edx,%eax
  8011cb:	cd 30                	int    $0x30
  8011cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	79 1c                	jns    8011f3 <fork+0x44>
		panic("sys_exofork failed\n");
  8011d7:	c7 44 24 08 92 2b 80 	movl   $0x802b92,0x8(%esp)
  8011de:	00 
  8011df:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8011e6:	00 
  8011e7:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8011ee:	e8 95 f1 ff ff       	call   800388 <_panic>
	if(c_envid == 0){
  8011f3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011f7:	75 25                	jne    80121e <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011f9:	e8 e1 fb ff ff       	call   800ddf <sys_getenvid>
  8011fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  801203:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80120a:	c1 e0 07             	shl    $0x7,%eax
  80120d:	29 d0                	sub    %edx,%eax
  80120f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801214:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801219:	e9 e3 01 00 00       	jmp    801401 <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  80121e:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  801223:	89 d8                	mov    %ebx,%eax
  801225:	c1 e8 16             	shr    $0x16,%eax
  801228:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80122f:	a8 01                	test   $0x1,%al
  801231:	0f 84 0b 01 00 00    	je     801342 <fork+0x193>
  801237:	89 de                	mov    %ebx,%esi
  801239:	c1 ee 0c             	shr    $0xc,%esi
  80123c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801243:	a8 05                	test   $0x5,%al
  801245:	0f 84 f7 00 00 00    	je     801342 <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  80124b:	89 f7                	mov    %esi,%edi
  80124d:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  801250:	e8 8a fb ff ff       	call   800ddf <sys_getenvid>
  801255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801258:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80125f:	a8 02                	test   $0x2,%al
  801261:	75 10                	jne    801273 <fork+0xc4>
  801263:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80126a:	f6 c4 08             	test   $0x8,%ah
  80126d:	0f 84 89 00 00 00    	je     8012fc <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  801273:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80127a:	00 
  80127b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80127f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801282:	89 44 24 08          	mov    %eax,0x8(%esp)
  801286:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80128d:	89 04 24             	mov    %eax,(%esp)
  801290:	e8 dc fb ff ff       	call   800e71 <sys_page_map>
  801295:	85 c0                	test   %eax,%eax
  801297:	79 20                	jns    8012b9 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80129d:	c7 44 24 08 a6 2b 80 	movl   $0x802ba6,0x8(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  8012ac:	00 
  8012ad:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8012b4:	e8 cf f0 ff ff       	call   800388 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  8012b9:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8012c0:	00 
  8012c1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	e8 99 fb ff ff       	call   800e71 <sys_page_map>
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	79 66                	jns    801342 <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8012dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e0:	c7 44 24 08 a6 2b 80 	movl   $0x802ba6,0x8(%esp)
  8012e7:	00 
  8012e8:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8012ef:	00 
  8012f0:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8012f7:	e8 8c f0 ff ff       	call   800388 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  8012fc:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801303:	00 
  801304:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801308:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801313:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801316:	89 04 24             	mov    %eax,(%esp)
  801319:	e8 53 fb ff ff       	call   800e71 <sys_page_map>
  80131e:	85 c0                	test   %eax,%eax
  801320:	79 20                	jns    801342 <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  801322:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801326:	c7 44 24 08 a6 2b 80 	movl   $0x802ba6,0x8(%esp)
  80132d:	00 
  80132e:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801335:	00 
  801336:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  80133d:	e8 46 f0 ff ff       	call   800388 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  801342:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801348:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80134e:	0f 85 cf fe ff ff    	jne    801223 <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801354:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80135b:	00 
  80135c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801363:	ee 
  801364:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801367:	89 04 24             	mov    %eax,(%esp)
  80136a:	e8 ae fa ff ff       	call   800e1d <sys_page_alloc>
  80136f:	85 c0                	test   %eax,%eax
  801371:	79 20                	jns    801393 <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  801373:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801377:	c7 44 24 08 b8 2b 80 	movl   $0x802bb8,0x8(%esp)
  80137e:	00 
  80137f:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801386:	00 
  801387:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  80138e:	e8 f5 ef ff ff       	call   800388 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801393:	c7 44 24 04 60 22 80 	movl   $0x802260,0x4(%esp)
  80139a:	00 
  80139b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80139e:	89 04 24             	mov    %eax,(%esp)
  8013a1:	e8 17 fc ff ff       	call   800fbd <sys_env_set_pgfault_upcall>
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	79 20                	jns    8013ca <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8013aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ae:	c7 44 24 08 30 2b 80 	movl   $0x802b30,0x8(%esp)
  8013b5:	00 
  8013b6:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8013bd:	00 
  8013be:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8013c5:	e8 be ef ff ff       	call   800388 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  8013ca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013d1:	00 
  8013d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013d5:	89 04 24             	mov    %eax,(%esp)
  8013d8:	e8 3a fb ff ff       	call   800f17 <sys_env_set_status>
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	79 20                	jns    801401 <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  8013e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e5:	c7 44 24 08 cc 2b 80 	movl   $0x802bcc,0x8(%esp)
  8013ec:	00 
  8013ed:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8013f4:	00 
  8013f5:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8013fc:	e8 87 ef ff ff       	call   800388 <_panic>
 
	return c_envid;	
}
  801401:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801404:	83 c4 3c             	add    $0x3c,%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5f                   	pop    %edi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <sfork>:

// Challenge!
int
sfork(void)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801412:	c7 44 24 08 e4 2b 80 	movl   $0x802be4,0x8(%esp)
  801419:	00 
  80141a:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801421:	00 
  801422:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  801429:	e8 5a ef ff ff       	call   800388 <_panic>
	...

00801430 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	05 00 00 00 30       	add    $0x30000000,%eax
  80143b:	c1 e8 0c             	shr    $0xc,%eax
}
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801446:	8b 45 08             	mov    0x8(%ebp),%eax
  801449:	89 04 24             	mov    %eax,(%esp)
  80144c:	e8 df ff ff ff       	call   801430 <fd2num>
  801451:	05 20 00 0d 00       	add    $0xd0020,%eax
  801456:	c1 e0 0c             	shl    $0xc,%eax
}
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	53                   	push   %ebx
  80145f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801462:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801467:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801469:	89 c2                	mov    %eax,%edx
  80146b:	c1 ea 16             	shr    $0x16,%edx
  80146e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801475:	f6 c2 01             	test   $0x1,%dl
  801478:	74 11                	je     80148b <fd_alloc+0x30>
  80147a:	89 c2                	mov    %eax,%edx
  80147c:	c1 ea 0c             	shr    $0xc,%edx
  80147f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801486:	f6 c2 01             	test   $0x1,%dl
  801489:	75 09                	jne    801494 <fd_alloc+0x39>
			*fd_store = fd;
  80148b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80148d:	b8 00 00 00 00       	mov    $0x0,%eax
  801492:	eb 17                	jmp    8014ab <fd_alloc+0x50>
  801494:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801499:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80149e:	75 c7                	jne    801467 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014a6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014ab:	5b                   	pop    %ebx
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014b4:	83 f8 1f             	cmp    $0x1f,%eax
  8014b7:	77 36                	ja     8014ef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014b9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014be:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	c1 ea 16             	shr    $0x16,%edx
  8014c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014cd:	f6 c2 01             	test   $0x1,%dl
  8014d0:	74 24                	je     8014f6 <fd_lookup+0x48>
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	c1 ea 0c             	shr    $0xc,%edx
  8014d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014de:	f6 c2 01             	test   $0x1,%dl
  8014e1:	74 1a                	je     8014fd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e6:	89 02                	mov    %eax,(%edx)
	return 0;
  8014e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ed:	eb 13                	jmp    801502 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f4:	eb 0c                	jmp    801502 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fb:	eb 05                	jmp    801502 <fd_lookup+0x54>
  8014fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	53                   	push   %ebx
  801508:	83 ec 14             	sub    $0x14,%esp
  80150b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	eb 0e                	jmp    801526 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801518:	39 08                	cmp    %ecx,(%eax)
  80151a:	75 09                	jne    801525 <dev_lookup+0x21>
			*dev = devtab[i];
  80151c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
  801523:	eb 33                	jmp    801558 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801525:	42                   	inc    %edx
  801526:	8b 04 95 7c 2c 80 00 	mov    0x802c7c(,%edx,4),%eax
  80152d:	85 c0                	test   %eax,%eax
  80152f:	75 e7                	jne    801518 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801531:	a1 04 40 80 00       	mov    0x804004,%eax
  801536:	8b 40 48             	mov    0x48(%eax),%eax
  801539:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80153d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801541:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  801548:	e8 33 ef ff ff       	call   800480 <cprintf>
	*dev = 0;
  80154d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801553:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801558:	83 c4 14             	add    $0x14,%esp
  80155b:	5b                   	pop    %ebx
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	56                   	push   %esi
  801562:	53                   	push   %ebx
  801563:	83 ec 30             	sub    $0x30,%esp
  801566:	8b 75 08             	mov    0x8(%ebp),%esi
  801569:	8a 45 0c             	mov    0xc(%ebp),%al
  80156c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80156f:	89 34 24             	mov    %esi,(%esp)
  801572:	e8 b9 fe ff ff       	call   801430 <fd2num>
  801577:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80157a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80157e:	89 04 24             	mov    %eax,(%esp)
  801581:	e8 28 ff ff ff       	call   8014ae <fd_lookup>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 05                	js     801591 <fd_close+0x33>
	    || fd != fd2)
  80158c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80158f:	74 0d                	je     80159e <fd_close+0x40>
		return (must_exist ? r : 0);
  801591:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801595:	75 46                	jne    8015dd <fd_close+0x7f>
  801597:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159c:	eb 3f                	jmp    8015dd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80159e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a5:	8b 06                	mov    (%esi),%eax
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	e8 55 ff ff ff       	call   801504 <dev_lookup>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 18                	js     8015cd <fd_close+0x6f>
		if (dev->dev_close)
  8015b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b8:	8b 40 10             	mov    0x10(%eax),%eax
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	74 09                	je     8015c8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015bf:	89 34 24             	mov    %esi,(%esp)
  8015c2:	ff d0                	call   *%eax
  8015c4:	89 c3                	mov    %eax,%ebx
  8015c6:	eb 05                	jmp    8015cd <fd_close+0x6f>
		else
			r = 0;
  8015c8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d8:	e8 e7 f8 ff ff       	call   800ec4 <sys_page_unmap>
	return r;
}
  8015dd:	89 d8                	mov    %ebx,%eax
  8015df:	83 c4 30             	add    $0x30,%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	89 04 24             	mov    %eax,(%esp)
  8015f9:	e8 b0 fe ff ff       	call   8014ae <fd_lookup>
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 13                	js     801615 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801602:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801609:	00 
  80160a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160d:	89 04 24             	mov    %eax,(%esp)
  801610:	e8 49 ff ff ff       	call   80155e <fd_close>
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <close_all>:

void
close_all(void)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	53                   	push   %ebx
  80161b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80161e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801623:	89 1c 24             	mov    %ebx,(%esp)
  801626:	e8 bb ff ff ff       	call   8015e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80162b:	43                   	inc    %ebx
  80162c:	83 fb 20             	cmp    $0x20,%ebx
  80162f:	75 f2                	jne    801623 <close_all+0xc>
		close(i);
}
  801631:	83 c4 14             	add    $0x14,%esp
  801634:	5b                   	pop    %ebx
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	57                   	push   %edi
  80163b:	56                   	push   %esi
  80163c:	53                   	push   %ebx
  80163d:	83 ec 4c             	sub    $0x4c,%esp
  801640:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801643:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	89 04 24             	mov    %eax,(%esp)
  801650:	e8 59 fe ff ff       	call   8014ae <fd_lookup>
  801655:	89 c3                	mov    %eax,%ebx
  801657:	85 c0                	test   %eax,%eax
  801659:	0f 88 e1 00 00 00    	js     801740 <dup+0x109>
		return r;
	close(newfdnum);
  80165f:	89 3c 24             	mov    %edi,(%esp)
  801662:	e8 7f ff ff ff       	call   8015e6 <close>

	newfd = INDEX2FD(newfdnum);
  801667:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80166d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801673:	89 04 24             	mov    %eax,(%esp)
  801676:	e8 c5 fd ff ff       	call   801440 <fd2data>
  80167b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80167d:	89 34 24             	mov    %esi,(%esp)
  801680:	e8 bb fd ff ff       	call   801440 <fd2data>
  801685:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801688:	89 d8                	mov    %ebx,%eax
  80168a:	c1 e8 16             	shr    $0x16,%eax
  80168d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801694:	a8 01                	test   $0x1,%al
  801696:	74 46                	je     8016de <dup+0xa7>
  801698:	89 d8                	mov    %ebx,%eax
  80169a:	c1 e8 0c             	shr    $0xc,%eax
  80169d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016a4:	f6 c2 01             	test   $0x1,%dl
  8016a7:	74 35                	je     8016de <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016c7:	00 
  8016c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d3:	e8 99 f7 ff ff       	call   800e71 <sys_page_map>
  8016d8:	89 c3                	mov    %eax,%ebx
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 3b                	js     801719 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	c1 ea 0c             	shr    $0xc,%edx
  8016e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ed:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016f3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801702:	00 
  801703:	89 44 24 04          	mov    %eax,0x4(%esp)
  801707:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80170e:	e8 5e f7 ff ff       	call   800e71 <sys_page_map>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	85 c0                	test   %eax,%eax
  801717:	79 25                	jns    80173e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801719:	89 74 24 04          	mov    %esi,0x4(%esp)
  80171d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801724:	e8 9b f7 ff ff       	call   800ec4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801729:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80172c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801730:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801737:	e8 88 f7 ff ff       	call   800ec4 <sys_page_unmap>
	return r;
  80173c:	eb 02                	jmp    801740 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80173e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801740:	89 d8                	mov    %ebx,%eax
  801742:	83 c4 4c             	add    $0x4c,%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5f                   	pop    %edi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	53                   	push   %ebx
  80174e:	83 ec 24             	sub    $0x24,%esp
  801751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801754:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175b:	89 1c 24             	mov    %ebx,(%esp)
  80175e:	e8 4b fd ff ff       	call   8014ae <fd_lookup>
  801763:	85 c0                	test   %eax,%eax
  801765:	78 6d                	js     8017d4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801767:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801771:	8b 00                	mov    (%eax),%eax
  801773:	89 04 24             	mov    %eax,(%esp)
  801776:	e8 89 fd ff ff       	call   801504 <dev_lookup>
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 55                	js     8017d4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80177f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801782:	8b 50 08             	mov    0x8(%eax),%edx
  801785:	83 e2 03             	and    $0x3,%edx
  801788:	83 fa 01             	cmp    $0x1,%edx
  80178b:	75 23                	jne    8017b0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80178d:	a1 04 40 80 00       	mov    0x804004,%eax
  801792:	8b 40 48             	mov    0x48(%eax),%eax
  801795:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801799:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179d:	c7 04 24 40 2c 80 00 	movl   $0x802c40,(%esp)
  8017a4:	e8 d7 ec ff ff       	call   800480 <cprintf>
		return -E_INVAL;
  8017a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ae:	eb 24                	jmp    8017d4 <read+0x8a>
	}
	if (!dev->dev_read)
  8017b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b3:	8b 52 08             	mov    0x8(%edx),%edx
  8017b6:	85 d2                	test   %edx,%edx
  8017b8:	74 15                	je     8017cf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017c8:	89 04 24             	mov    %eax,(%esp)
  8017cb:	ff d2                	call   *%edx
  8017cd:	eb 05                	jmp    8017d4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017d4:	83 c4 24             	add    $0x24,%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	57                   	push   %edi
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 1c             	sub    $0x1c,%esp
  8017e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ee:	eb 23                	jmp    801813 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f0:	89 f0                	mov    %esi,%eax
  8017f2:	29 d8                	sub    %ebx,%eax
  8017f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fb:	01 d8                	add    %ebx,%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	89 3c 24             	mov    %edi,(%esp)
  801804:	e8 41 ff ff ff       	call   80174a <read>
		if (m < 0)
  801809:	85 c0                	test   %eax,%eax
  80180b:	78 10                	js     80181d <readn+0x43>
			return m;
		if (m == 0)
  80180d:	85 c0                	test   %eax,%eax
  80180f:	74 0a                	je     80181b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801811:	01 c3                	add    %eax,%ebx
  801813:	39 f3                	cmp    %esi,%ebx
  801815:	72 d9                	jb     8017f0 <readn+0x16>
  801817:	89 d8                	mov    %ebx,%eax
  801819:	eb 02                	jmp    80181d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80181b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80181d:	83 c4 1c             	add    $0x1c,%esp
  801820:	5b                   	pop    %ebx
  801821:	5e                   	pop    %esi
  801822:	5f                   	pop    %edi
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	53                   	push   %ebx
  801829:	83 ec 24             	sub    $0x24,%esp
  80182c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801832:	89 44 24 04          	mov    %eax,0x4(%esp)
  801836:	89 1c 24             	mov    %ebx,(%esp)
  801839:	e8 70 fc ff ff       	call   8014ae <fd_lookup>
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 68                	js     8018aa <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801842:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801845:	89 44 24 04          	mov    %eax,0x4(%esp)
  801849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184c:	8b 00                	mov    (%eax),%eax
  80184e:	89 04 24             	mov    %eax,(%esp)
  801851:	e8 ae fc ff ff       	call   801504 <dev_lookup>
  801856:	85 c0                	test   %eax,%eax
  801858:	78 50                	js     8018aa <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801861:	75 23                	jne    801886 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801863:	a1 04 40 80 00       	mov    0x804004,%eax
  801868:	8b 40 48             	mov    0x48(%eax),%eax
  80186b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801873:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  80187a:	e8 01 ec ff ff       	call   800480 <cprintf>
		return -E_INVAL;
  80187f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801884:	eb 24                	jmp    8018aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801886:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801889:	8b 52 0c             	mov    0xc(%edx),%edx
  80188c:	85 d2                	test   %edx,%edx
  80188e:	74 15                	je     8018a5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801890:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801893:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	ff d2                	call   *%edx
  8018a3:	eb 05                	jmp    8018aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018aa:	83 c4 24             	add    $0x24,%esp
  8018ad:	5b                   	pop    %ebx
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    

008018b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	89 04 24             	mov    %eax,(%esp)
  8018c3:	e8 e6 fb ff ff       	call   8014ae <fd_lookup>
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 0e                	js     8018da <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 24             	sub    $0x24,%esp
  8018e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ed:	89 1c 24             	mov    %ebx,(%esp)
  8018f0:	e8 b9 fb ff ff       	call   8014ae <fd_lookup>
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 61                	js     80195a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801900:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801903:	8b 00                	mov    (%eax),%eax
  801905:	89 04 24             	mov    %eax,(%esp)
  801908:	e8 f7 fb ff ff       	call   801504 <dev_lookup>
  80190d:	85 c0                	test   %eax,%eax
  80190f:	78 49                	js     80195a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801911:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801914:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801918:	75 23                	jne    80193d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80191a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80191f:	8b 40 48             	mov    0x48(%eax),%eax
  801922:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192a:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  801931:	e8 4a eb ff ff       	call   800480 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801936:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80193b:	eb 1d                	jmp    80195a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80193d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801940:	8b 52 18             	mov    0x18(%edx),%edx
  801943:	85 d2                	test   %edx,%edx
  801945:	74 0e                	je     801955 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	ff d2                	call   *%edx
  801953:	eb 05                	jmp    80195a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801955:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80195a:	83 c4 24             	add    $0x24,%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	53                   	push   %ebx
  801964:	83 ec 24             	sub    $0x24,%esp
  801967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	89 04 24             	mov    %eax,(%esp)
  801977:	e8 32 fb ff ff       	call   8014ae <fd_lookup>
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 52                	js     8019d2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801980:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801983:	89 44 24 04          	mov    %eax,0x4(%esp)
  801987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198a:	8b 00                	mov    (%eax),%eax
  80198c:	89 04 24             	mov    %eax,(%esp)
  80198f:	e8 70 fb ff ff       	call   801504 <dev_lookup>
  801994:	85 c0                	test   %eax,%eax
  801996:	78 3a                	js     8019d2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80199f:	74 2c                	je     8019cd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019ab:	00 00 00 
	stat->st_isdir = 0;
  8019ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b5:	00 00 00 
	stat->st_dev = dev;
  8019b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019c5:	89 14 24             	mov    %edx,(%esp)
  8019c8:	ff 50 14             	call   *0x14(%eax)
  8019cb:	eb 05                	jmp    8019d2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019d2:	83 c4 24             	add    $0x24,%esp
  8019d5:	5b                   	pop    %ebx
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019e7:	00 
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	89 04 24             	mov    %eax,(%esp)
  8019ee:	e8 fe 01 00 00       	call   801bf1 <open>
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 1b                	js     801a14 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a00:	89 1c 24             	mov    %ebx,(%esp)
  801a03:	e8 58 ff ff ff       	call   801960 <fstat>
  801a08:	89 c6                	mov    %eax,%esi
	close(fd);
  801a0a:	89 1c 24             	mov    %ebx,(%esp)
  801a0d:	e8 d4 fb ff ff       	call   8015e6 <close>
	return r;
  801a12:	89 f3                	mov    %esi,%ebx
}
  801a14:	89 d8                	mov    %ebx,%eax
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    
  801a1d:	00 00                	add    %al,(%eax)
	...

00801a20 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	83 ec 10             	sub    $0x10,%esp
  801a28:	89 c3                	mov    %eax,%ebx
  801a2a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a2c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a33:	75 11                	jne    801a46 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a35:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a3c:	e8 1a 09 00 00       	call   80235b <ipc_find_env>
  801a41:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a46:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a4d:	00 
  801a4e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a55:	00 
  801a56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a5a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a5f:	89 04 24             	mov    %eax,(%esp)
  801a62:	e8 8a 08 00 00       	call   8022f1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a6e:	00 
  801a6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7a:	e8 09 08 00 00       	call   802288 <ipc_recv>
}
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    

00801a86 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a92:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa4:	b8 02 00 00 00       	mov    $0x2,%eax
  801aa9:	e8 72 ff ff ff       	call   801a20 <fsipc>
}
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	8b 40 0c             	mov    0xc(%eax),%eax
  801abc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac6:	b8 06 00 00 00       	mov    $0x6,%eax
  801acb:	e8 50 ff ff ff       	call   801a20 <fsipc>
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 14             	sub    $0x14,%esp
  801ad9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801adc:	8b 45 08             	mov    0x8(%ebp),%eax
  801adf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aec:	b8 05 00 00 00       	mov    $0x5,%eax
  801af1:	e8 2a ff ff ff       	call   801a20 <fsipc>
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 2b                	js     801b25 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801afa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b01:	00 
  801b02:	89 1c 24             	mov    %ebx,(%esp)
  801b05:	e8 21 ef ff ff       	call   800a2b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b0a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b15:	a1 84 50 80 00       	mov    0x805084,%eax
  801b1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b25:	83 c4 14             	add    $0x14,%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b31:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  801b38:	00 
  801b39:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801b40:	00 
  801b41:	c7 04 24 aa 2c 80 00 	movl   $0x802caa,(%esp)
  801b48:	e8 3b e8 ff ff       	call   800388 <_panic>

00801b4d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	83 ec 10             	sub    $0x10,%esp
  801b55:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b58:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b63:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b69:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b73:	e8 a8 fe ff ff       	call   801a20 <fsipc>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 6a                	js     801be8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b7e:	39 c6                	cmp    %eax,%esi
  801b80:	73 24                	jae    801ba6 <devfile_read+0x59>
  801b82:	c7 44 24 0c b5 2c 80 	movl   $0x802cb5,0xc(%esp)
  801b89:	00 
  801b8a:	c7 44 24 08 bc 2c 80 	movl   $0x802cbc,0x8(%esp)
  801b91:	00 
  801b92:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b99:	00 
  801b9a:	c7 04 24 aa 2c 80 00 	movl   $0x802caa,(%esp)
  801ba1:	e8 e2 e7 ff ff       	call   800388 <_panic>
	assert(r <= PGSIZE);
  801ba6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bab:	7e 24                	jle    801bd1 <devfile_read+0x84>
  801bad:	c7 44 24 0c d1 2c 80 	movl   $0x802cd1,0xc(%esp)
  801bb4:	00 
  801bb5:	c7 44 24 08 bc 2c 80 	movl   $0x802cbc,0x8(%esp)
  801bbc:	00 
  801bbd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bc4:	00 
  801bc5:	c7 04 24 aa 2c 80 00 	movl   $0x802caa,(%esp)
  801bcc:	e8 b7 e7 ff ff       	call   800388 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bdc:	00 
  801bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be0:	89 04 24             	mov    %eax,(%esp)
  801be3:	e8 bc ef ff ff       	call   800ba4 <memmove>
	return r;
}
  801be8:	89 d8                	mov    %ebx,%eax
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 20             	sub    $0x20,%esp
  801bf9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bfc:	89 34 24             	mov    %esi,(%esp)
  801bff:	e8 f4 ed ff ff       	call   8009f8 <strlen>
  801c04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c09:	7f 60                	jg     801c6b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0e:	89 04 24             	mov    %eax,(%esp)
  801c11:	e8 45 f8 ff ff       	call   80145b <fd_alloc>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	78 54                	js     801c70 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c20:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c27:	e8 ff ed ff ff       	call   800a2b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c37:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3c:	e8 df fd ff ff       	call   801a20 <fsipc>
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	85 c0                	test   %eax,%eax
  801c45:	79 15                	jns    801c5c <open+0x6b>
		fd_close(fd, 0);
  801c47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c4e:	00 
  801c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c52:	89 04 24             	mov    %eax,(%esp)
  801c55:	e8 04 f9 ff ff       	call   80155e <fd_close>
		return r;
  801c5a:	eb 14                	jmp    801c70 <open+0x7f>
	}

	return fd2num(fd);
  801c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5f:	89 04 24             	mov    %eax,(%esp)
  801c62:	e8 c9 f7 ff ff       	call   801430 <fd2num>
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	eb 05                	jmp    801c70 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c6b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	83 c4 20             	add    $0x20,%esp
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c84:	b8 08 00 00 00       	mov    $0x8,%eax
  801c89:	e8 92 fd ff ff       	call   801a20 <fsipc>
}
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	83 ec 10             	sub    $0x10,%esp
  801c98:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	89 04 24             	mov    %eax,(%esp)
  801ca1:	e8 9a f7 ff ff       	call   801440 <fd2data>
  801ca6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ca8:	c7 44 24 04 dd 2c 80 	movl   $0x802cdd,0x4(%esp)
  801caf:	00 
  801cb0:	89 34 24             	mov    %esi,(%esp)
  801cb3:	e8 73 ed ff ff       	call   800a2b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cb8:	8b 43 04             	mov    0x4(%ebx),%eax
  801cbb:	2b 03                	sub    (%ebx),%eax
  801cbd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801cc3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801cca:	00 00 00 
	stat->st_dev = &devpipe;
  801ccd:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801cd4:	30 80 00 
	return 0;
}
  801cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	53                   	push   %ebx
  801ce7:	83 ec 14             	sub    $0x14,%esp
  801cea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ced:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf8:	e8 c7 f1 ff ff       	call   800ec4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cfd:	89 1c 24             	mov    %ebx,(%esp)
  801d00:	e8 3b f7 ff ff       	call   801440 <fd2data>
  801d05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d10:	e8 af f1 ff ff       	call   800ec4 <sys_page_unmap>
}
  801d15:	83 c4 14             	add    $0x14,%esp
  801d18:	5b                   	pop    %ebx
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	57                   	push   %edi
  801d1f:	56                   	push   %esi
  801d20:	53                   	push   %ebx
  801d21:	83 ec 2c             	sub    $0x2c,%esp
  801d24:	89 c7                	mov    %eax,%edi
  801d26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d29:	a1 04 40 80 00       	mov    0x804004,%eax
  801d2e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d31:	89 3c 24             	mov    %edi,(%esp)
  801d34:	e8 67 06 00 00       	call   8023a0 <pageref>
  801d39:	89 c6                	mov    %eax,%esi
  801d3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3e:	89 04 24             	mov    %eax,(%esp)
  801d41:	e8 5a 06 00 00       	call   8023a0 <pageref>
  801d46:	39 c6                	cmp    %eax,%esi
  801d48:	0f 94 c0             	sete   %al
  801d4b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d4e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d54:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d57:	39 cb                	cmp    %ecx,%ebx
  801d59:	75 08                	jne    801d63 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d5b:	83 c4 2c             	add    $0x2c,%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5e                   	pop    %esi
  801d60:	5f                   	pop    %edi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d63:	83 f8 01             	cmp    $0x1,%eax
  801d66:	75 c1                	jne    801d29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d68:	8b 42 58             	mov    0x58(%edx),%eax
  801d6b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d72:	00 
  801d73:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d7b:	c7 04 24 e4 2c 80 00 	movl   $0x802ce4,(%esp)
  801d82:	e8 f9 e6 ff ff       	call   800480 <cprintf>
  801d87:	eb a0                	jmp    801d29 <_pipeisclosed+0xe>

00801d89 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	57                   	push   %edi
  801d8d:	56                   	push   %esi
  801d8e:	53                   	push   %ebx
  801d8f:	83 ec 1c             	sub    $0x1c,%esp
  801d92:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d95:	89 34 24             	mov    %esi,(%esp)
  801d98:	e8 a3 f6 ff ff       	call   801440 <fd2data>
  801d9d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9f:	bf 00 00 00 00       	mov    $0x0,%edi
  801da4:	eb 3c                	jmp    801de2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801da6:	89 da                	mov    %ebx,%edx
  801da8:	89 f0                	mov    %esi,%eax
  801daa:	e8 6c ff ff ff       	call   801d1b <_pipeisclosed>
  801daf:	85 c0                	test   %eax,%eax
  801db1:	75 38                	jne    801deb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801db3:	e8 46 f0 ff ff       	call   800dfe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801db8:	8b 43 04             	mov    0x4(%ebx),%eax
  801dbb:	8b 13                	mov    (%ebx),%edx
  801dbd:	83 c2 20             	add    $0x20,%edx
  801dc0:	39 d0                	cmp    %edx,%eax
  801dc2:	73 e2                	jae    801da6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801dca:	89 c2                	mov    %eax,%edx
  801dcc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801dd2:	79 05                	jns    801dd9 <devpipe_write+0x50>
  801dd4:	4a                   	dec    %edx
  801dd5:	83 ca e0             	or     $0xffffffe0,%edx
  801dd8:	42                   	inc    %edx
  801dd9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ddd:	40                   	inc    %eax
  801dde:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de1:	47                   	inc    %edi
  801de2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801de5:	75 d1                	jne    801db8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801de7:	89 f8                	mov    %edi,%eax
  801de9:	eb 05                	jmp    801df0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801df0:	83 c4 1c             	add    $0x1c,%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	57                   	push   %edi
  801dfc:	56                   	push   %esi
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 1c             	sub    $0x1c,%esp
  801e01:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e04:	89 3c 24             	mov    %edi,(%esp)
  801e07:	e8 34 f6 ff ff       	call   801440 <fd2data>
  801e0c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0e:	be 00 00 00 00       	mov    $0x0,%esi
  801e13:	eb 3a                	jmp    801e4f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e15:	85 f6                	test   %esi,%esi
  801e17:	74 04                	je     801e1d <devpipe_read+0x25>
				return i;
  801e19:	89 f0                	mov    %esi,%eax
  801e1b:	eb 40                	jmp    801e5d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e1d:	89 da                	mov    %ebx,%edx
  801e1f:	89 f8                	mov    %edi,%eax
  801e21:	e8 f5 fe ff ff       	call   801d1b <_pipeisclosed>
  801e26:	85 c0                	test   %eax,%eax
  801e28:	75 2e                	jne    801e58 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e2a:	e8 cf ef ff ff       	call   800dfe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e2f:	8b 03                	mov    (%ebx),%eax
  801e31:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e34:	74 df                	je     801e15 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e36:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e3b:	79 05                	jns    801e42 <devpipe_read+0x4a>
  801e3d:	48                   	dec    %eax
  801e3e:	83 c8 e0             	or     $0xffffffe0,%eax
  801e41:	40                   	inc    %eax
  801e42:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e49:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e4c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e4e:	46                   	inc    %esi
  801e4f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e52:	75 db                	jne    801e2f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e54:	89 f0                	mov    %esi,%eax
  801e56:	eb 05                	jmp    801e5d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e58:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e5d:	83 c4 1c             	add    $0x1c,%esp
  801e60:	5b                   	pop    %ebx
  801e61:	5e                   	pop    %esi
  801e62:	5f                   	pop    %edi
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    

00801e65 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	57                   	push   %edi
  801e69:	56                   	push   %esi
  801e6a:	53                   	push   %ebx
  801e6b:	83 ec 3c             	sub    $0x3c,%esp
  801e6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e74:	89 04 24             	mov    %eax,(%esp)
  801e77:	e8 df f5 ff ff       	call   80145b <fd_alloc>
  801e7c:	89 c3                	mov    %eax,%ebx
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	0f 88 45 01 00 00    	js     801fcb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e86:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e8d:	00 
  801e8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9c:	e8 7c ef ff ff       	call   800e1d <sys_page_alloc>
  801ea1:	89 c3                	mov    %eax,%ebx
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	0f 88 20 01 00 00    	js     801fcb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eab:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801eae:	89 04 24             	mov    %eax,(%esp)
  801eb1:	e8 a5 f5 ff ff       	call   80145b <fd_alloc>
  801eb6:	89 c3                	mov    %eax,%ebx
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	0f 88 f8 00 00 00    	js     801fb8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec7:	00 
  801ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed6:	e8 42 ef ff ff       	call   800e1d <sys_page_alloc>
  801edb:	89 c3                	mov    %eax,%ebx
  801edd:	85 c0                	test   %eax,%eax
  801edf:	0f 88 d3 00 00 00    	js     801fb8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ee5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ee8:	89 04 24             	mov    %eax,(%esp)
  801eeb:	e8 50 f5 ff ff       	call   801440 <fd2data>
  801ef0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ef9:	00 
  801efa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f05:	e8 13 ef ff ff       	call   800e1d <sys_page_alloc>
  801f0a:	89 c3                	mov    %eax,%ebx
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	0f 88 91 00 00 00    	js     801fa5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f14:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f17:	89 04 24             	mov    %eax,(%esp)
  801f1a:	e8 21 f5 ff ff       	call   801440 <fd2data>
  801f1f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f26:	00 
  801f27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f32:	00 
  801f33:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3e:	e8 2e ef ff ff       	call   800e71 <sys_page_map>
  801f43:	89 c3                	mov    %eax,%ebx
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 4c                	js     801f95 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f49:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f52:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f5e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f64:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f67:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f76:	89 04 24             	mov    %eax,(%esp)
  801f79:	e8 b2 f4 ff ff       	call   801430 <fd2num>
  801f7e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f83:	89 04 24             	mov    %eax,(%esp)
  801f86:	e8 a5 f4 ff ff       	call   801430 <fd2num>
  801f8b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f93:	eb 36                	jmp    801fcb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f95:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa0:	e8 1f ef ff ff       	call   800ec4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb3:	e8 0c ef ff ff       	call   800ec4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc6:	e8 f9 ee ff ff       	call   800ec4 <sys_page_unmap>
    err:
	return r;
}
  801fcb:	89 d8                	mov    %ebx,%eax
  801fcd:	83 c4 3c             	add    $0x3c,%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fde:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 c1 f4 ff ff       	call   8014ae <fd_lookup>
  801fed:	85 c0                	test   %eax,%eax
  801fef:	78 15                	js     802006 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff4:	89 04 24             	mov    %eax,(%esp)
  801ff7:	e8 44 f4 ff ff       	call   801440 <fd2data>
	return _pipeisclosed(fd, p);
  801ffc:	89 c2                	mov    %eax,%edx
  801ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802001:	e8 15 fd ff ff       	call   801d1b <_pipeisclosed>
}
  802006:	c9                   	leave  
  802007:	c3                   	ret    

00802008 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	56                   	push   %esi
  80200c:	53                   	push   %ebx
  80200d:	83 ec 10             	sub    $0x10,%esp
  802010:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802013:	85 f6                	test   %esi,%esi
  802015:	75 24                	jne    80203b <wait+0x33>
  802017:	c7 44 24 0c fc 2c 80 	movl   $0x802cfc,0xc(%esp)
  80201e:	00 
  80201f:	c7 44 24 08 bc 2c 80 	movl   $0x802cbc,0x8(%esp)
  802026:	00 
  802027:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80202e:	00 
  80202f:	c7 04 24 07 2d 80 00 	movl   $0x802d07,(%esp)
  802036:	e8 4d e3 ff ff       	call   800388 <_panic>
	e = &envs[ENVX(envid)];
  80203b:	89 f3                	mov    %esi,%ebx
  80203d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802043:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  80204a:	c1 e3 07             	shl    $0x7,%ebx
  80204d:	29 c3                	sub    %eax,%ebx
  80204f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802055:	eb 05                	jmp    80205c <wait+0x54>
		sys_yield();
  802057:	e8 a2 ed ff ff       	call   800dfe <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80205c:	8b 43 48             	mov    0x48(%ebx),%eax
  80205f:	39 f0                	cmp    %esi,%eax
  802061:	75 07                	jne    80206a <wait+0x62>
  802063:	8b 43 54             	mov    0x54(%ebx),%eax
  802066:	85 c0                	test   %eax,%eax
  802068:	75 ed                	jne    802057 <wait+0x4f>
		sys_yield();
}
  80206a:	83 c4 10             	add    $0x10,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    
  802071:	00 00                	add    %al,(%eax)
	...

00802074 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    

0080207e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802084:	c7 44 24 04 12 2d 80 	movl   $0x802d12,0x4(%esp)
  80208b:	00 
  80208c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208f:	89 04 24             	mov    %eax,(%esp)
  802092:	e8 94 e9 ff ff       	call   800a2b <strcpy>
	return 0;
}
  802097:	b8 00 00 00 00       	mov    $0x0,%eax
  80209c:	c9                   	leave  
  80209d:	c3                   	ret    

0080209e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020af:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b5:	eb 30                	jmp    8020e7 <devcons_write+0x49>
		m = n - tot;
  8020b7:	8b 75 10             	mov    0x10(%ebp),%esi
  8020ba:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020bc:	83 fe 7f             	cmp    $0x7f,%esi
  8020bf:	76 05                	jbe    8020c6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8020c1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020c6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020ca:	03 45 0c             	add    0xc(%ebp),%eax
  8020cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d1:	89 3c 24             	mov    %edi,(%esp)
  8020d4:	e8 cb ea ff ff       	call   800ba4 <memmove>
		sys_cputs(buf, m);
  8020d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020dd:	89 3c 24             	mov    %edi,(%esp)
  8020e0:	e8 6b ec ff ff       	call   800d50 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020e5:	01 f3                	add    %esi,%ebx
  8020e7:	89 d8                	mov    %ebx,%eax
  8020e9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020ec:	72 c9                	jb     8020b7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020ee:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5f                   	pop    %edi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    

008020f9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8020ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802103:	75 07                	jne    80210c <devcons_read+0x13>
  802105:	eb 25                	jmp    80212c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802107:	e8 f2 ec ff ff       	call   800dfe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80210c:	e8 5d ec ff ff       	call   800d6e <sys_cgetc>
  802111:	85 c0                	test   %eax,%eax
  802113:	74 f2                	je     802107 <devcons_read+0xe>
  802115:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802117:	85 c0                	test   %eax,%eax
  802119:	78 1d                	js     802138 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80211b:	83 f8 04             	cmp    $0x4,%eax
  80211e:	74 13                	je     802133 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802120:	8b 45 0c             	mov    0xc(%ebp),%eax
  802123:	88 10                	mov    %dl,(%eax)
	return 1;
  802125:	b8 01 00 00 00       	mov    $0x1,%eax
  80212a:	eb 0c                	jmp    802138 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80212c:	b8 00 00 00 00       	mov    $0x0,%eax
  802131:	eb 05                	jmp    802138 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802133:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802138:	c9                   	leave  
  802139:	c3                   	ret    

0080213a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802140:	8b 45 08             	mov    0x8(%ebp),%eax
  802143:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802146:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80214d:	00 
  80214e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802151:	89 04 24             	mov    %eax,(%esp)
  802154:	e8 f7 eb ff ff       	call   800d50 <sys_cputs>
}
  802159:	c9                   	leave  
  80215a:	c3                   	ret    

0080215b <getchar>:

int
getchar(void)
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802161:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802168:	00 
  802169:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80216c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802177:	e8 ce f5 ff ff       	call   80174a <read>
	if (r < 0)
  80217c:	85 c0                	test   %eax,%eax
  80217e:	78 0f                	js     80218f <getchar+0x34>
		return r;
	if (r < 1)
  802180:	85 c0                	test   %eax,%eax
  802182:	7e 06                	jle    80218a <getchar+0x2f>
		return -E_EOF;
	return c;
  802184:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802188:	eb 05                	jmp    80218f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80218a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80218f:	c9                   	leave  
  802190:	c3                   	ret    

00802191 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802191:	55                   	push   %ebp
  802192:	89 e5                	mov    %esp,%ebp
  802194:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802197:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80219a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219e:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a1:	89 04 24             	mov    %eax,(%esp)
  8021a4:	e8 05 f3 ff ff       	call   8014ae <fd_lookup>
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	78 11                	js     8021be <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021b6:	39 10                	cmp    %edx,(%eax)
  8021b8:	0f 94 c0             	sete   %al
  8021bb:	0f b6 c0             	movzbl %al,%eax
}
  8021be:	c9                   	leave  
  8021bf:	c3                   	ret    

008021c0 <opencons>:

int
opencons(void)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c9:	89 04 24             	mov    %eax,(%esp)
  8021cc:	e8 8a f2 ff ff       	call   80145b <fd_alloc>
  8021d1:	85 c0                	test   %eax,%eax
  8021d3:	78 3c                	js     802211 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021dc:	00 
  8021dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021eb:	e8 2d ec ff ff       	call   800e1d <sys_page_alloc>
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	78 1d                	js     802211 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021f4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802202:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802209:	89 04 24             	mov    %eax,(%esp)
  80220c:	e8 1f f2 ff ff       	call   801430 <fd2num>
}
  802211:	c9                   	leave  
  802212:	c3                   	ret    
	...

00802214 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80221a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802221:	75 32                	jne    802255 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802223:	e8 b7 eb ff ff       	call   800ddf <sys_getenvid>
  802228:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  80222f:	00 
  802230:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802237:	ee 
  802238:	89 04 24             	mov    %eax,(%esp)
  80223b:	e8 dd eb ff ff       	call   800e1d <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  802240:	e8 9a eb ff ff       	call   800ddf <sys_getenvid>
  802245:	c7 44 24 04 60 22 80 	movl   $0x802260,0x4(%esp)
  80224c:	00 
  80224d:	89 04 24             	mov    %eax,(%esp)
  802250:	e8 68 ed ff ff       	call   800fbd <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802255:	8b 45 08             	mov    0x8(%ebp),%eax
  802258:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80225d:	c9                   	leave  
  80225e:	c3                   	ret    
	...

00802260 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802260:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802261:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802266:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802268:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  80226b:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  80226f:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  802272:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  802277:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  80227b:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  80227e:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  80227f:	83 c4 04             	add    $0x4,%esp
	popfl
  802282:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  802283:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  802284:	c3                   	ret    
  802285:	00 00                	add    %al,(%eax)
	...

00802288 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	57                   	push   %edi
  80228c:	56                   	push   %esi
  80228d:	53                   	push   %ebx
  80228e:	83 ec 1c             	sub    $0x1c,%esp
  802291:	8b 75 08             	mov    0x8(%ebp),%esi
  802294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802297:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  80229a:	85 db                	test   %ebx,%ebx
  80229c:	75 05                	jne    8022a3 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  80229e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8022a3:	89 1c 24             	mov    %ebx,(%esp)
  8022a6:	e8 88 ed ff ff       	call   801033 <sys_ipc_recv>
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	79 16                	jns    8022c5 <ipc_recv+0x3d>
		*from_env_store = 0;
  8022af:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8022b5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  8022bb:	89 1c 24             	mov    %ebx,(%esp)
  8022be:	e8 70 ed ff ff       	call   801033 <sys_ipc_recv>
  8022c3:	eb 24                	jmp    8022e9 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  8022c5:	85 f6                	test   %esi,%esi
  8022c7:	74 0a                	je     8022d3 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8022c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8022ce:	8b 40 74             	mov    0x74(%eax),%eax
  8022d1:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8022d3:	85 ff                	test   %edi,%edi
  8022d5:	74 0a                	je     8022e1 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8022d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8022dc:	8b 40 78             	mov    0x78(%eax),%eax
  8022df:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8022e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8022e6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022e9:	83 c4 1c             	add    $0x1c,%esp
  8022ec:	5b                   	pop    %ebx
  8022ed:	5e                   	pop    %esi
  8022ee:	5f                   	pop    %edi
  8022ef:	5d                   	pop    %ebp
  8022f0:	c3                   	ret    

008022f1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022f1:	55                   	push   %ebp
  8022f2:	89 e5                	mov    %esp,%ebp
  8022f4:	57                   	push   %edi
  8022f5:	56                   	push   %esi
  8022f6:	53                   	push   %ebx
  8022f7:	83 ec 1c             	sub    $0x1c,%esp
  8022fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802300:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802303:	85 db                	test   %ebx,%ebx
  802305:	75 05                	jne    80230c <ipc_send+0x1b>
		pg = (void *)-1;
  802307:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80230c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802310:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802314:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802318:	8b 45 08             	mov    0x8(%ebp),%eax
  80231b:	89 04 24             	mov    %eax,(%esp)
  80231e:	e8 ed ec ff ff       	call   801010 <sys_ipc_try_send>
		if (r == 0) {		
  802323:	85 c0                	test   %eax,%eax
  802325:	74 2c                	je     802353 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  802327:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80232a:	75 07                	jne    802333 <ipc_send+0x42>
			sys_yield();
  80232c:	e8 cd ea ff ff       	call   800dfe <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  802331:	eb d9                	jmp    80230c <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  802333:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802337:	c7 44 24 08 1e 2d 80 	movl   $0x802d1e,0x8(%esp)
  80233e:	00 
  80233f:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  802346:	00 
  802347:	c7 04 24 2c 2d 80 00 	movl   $0x802d2c,(%esp)
  80234e:	e8 35 e0 ff ff       	call   800388 <_panic>
		}
	}
}
  802353:	83 c4 1c             	add    $0x1c,%esp
  802356:	5b                   	pop    %ebx
  802357:	5e                   	pop    %esi
  802358:	5f                   	pop    %edi
  802359:	5d                   	pop    %ebp
  80235a:	c3                   	ret    

0080235b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80235b:	55                   	push   %ebp
  80235c:	89 e5                	mov    %esp,%ebp
  80235e:	53                   	push   %ebx
  80235f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802362:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802367:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80236e:	89 c2                	mov    %eax,%edx
  802370:	c1 e2 07             	shl    $0x7,%edx
  802373:	29 ca                	sub    %ecx,%edx
  802375:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80237b:	8b 52 50             	mov    0x50(%edx),%edx
  80237e:	39 da                	cmp    %ebx,%edx
  802380:	75 0f                	jne    802391 <ipc_find_env+0x36>
			return envs[i].env_id;
  802382:	c1 e0 07             	shl    $0x7,%eax
  802385:	29 c8                	sub    %ecx,%eax
  802387:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80238c:	8b 40 40             	mov    0x40(%eax),%eax
  80238f:	eb 0c                	jmp    80239d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802391:	40                   	inc    %eax
  802392:	3d 00 04 00 00       	cmp    $0x400,%eax
  802397:	75 ce                	jne    802367 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802399:	66 b8 00 00          	mov    $0x0,%ax
}
  80239d:	5b                   	pop    %ebx
  80239e:	5d                   	pop    %ebp
  80239f:	c3                   	ret    

008023a0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023a6:	89 c2                	mov    %eax,%edx
  8023a8:	c1 ea 16             	shr    $0x16,%edx
  8023ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023b2:	f6 c2 01             	test   $0x1,%dl
  8023b5:	74 1e                	je     8023d5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023b7:	c1 e8 0c             	shr    $0xc,%eax
  8023ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023c1:	a8 01                	test   $0x1,%al
  8023c3:	74 17                	je     8023dc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023c5:	c1 e8 0c             	shr    $0xc,%eax
  8023c8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023cf:	ef 
  8023d0:	0f b7 c0             	movzwl %ax,%eax
  8023d3:	eb 0c                	jmp    8023e1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023da:	eb 05                	jmp    8023e1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023dc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023e1:	5d                   	pop    %ebp
  8023e2:	c3                   	ret    
	...

008023e4 <__udivdi3>:
  8023e4:	55                   	push   %ebp
  8023e5:	57                   	push   %edi
  8023e6:	56                   	push   %esi
  8023e7:	83 ec 10             	sub    $0x10,%esp
  8023ea:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023ee:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8023f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8023fa:	89 cd                	mov    %ecx,%ebp
  8023fc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802400:	85 c0                	test   %eax,%eax
  802402:	75 2c                	jne    802430 <__udivdi3+0x4c>
  802404:	39 f9                	cmp    %edi,%ecx
  802406:	77 68                	ja     802470 <__udivdi3+0x8c>
  802408:	85 c9                	test   %ecx,%ecx
  80240a:	75 0b                	jne    802417 <__udivdi3+0x33>
  80240c:	b8 01 00 00 00       	mov    $0x1,%eax
  802411:	31 d2                	xor    %edx,%edx
  802413:	f7 f1                	div    %ecx
  802415:	89 c1                	mov    %eax,%ecx
  802417:	31 d2                	xor    %edx,%edx
  802419:	89 f8                	mov    %edi,%eax
  80241b:	f7 f1                	div    %ecx
  80241d:	89 c7                	mov    %eax,%edi
  80241f:	89 f0                	mov    %esi,%eax
  802421:	f7 f1                	div    %ecx
  802423:	89 c6                	mov    %eax,%esi
  802425:	89 f0                	mov    %esi,%eax
  802427:	89 fa                	mov    %edi,%edx
  802429:	83 c4 10             	add    $0x10,%esp
  80242c:	5e                   	pop    %esi
  80242d:	5f                   	pop    %edi
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    
  802430:	39 f8                	cmp    %edi,%eax
  802432:	77 2c                	ja     802460 <__udivdi3+0x7c>
  802434:	0f bd f0             	bsr    %eax,%esi
  802437:	83 f6 1f             	xor    $0x1f,%esi
  80243a:	75 4c                	jne    802488 <__udivdi3+0xa4>
  80243c:	39 f8                	cmp    %edi,%eax
  80243e:	bf 00 00 00 00       	mov    $0x0,%edi
  802443:	72 0a                	jb     80244f <__udivdi3+0x6b>
  802445:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802449:	0f 87 ad 00 00 00    	ja     8024fc <__udivdi3+0x118>
  80244f:	be 01 00 00 00       	mov    $0x1,%esi
  802454:	89 f0                	mov    %esi,%eax
  802456:	89 fa                	mov    %edi,%edx
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	5e                   	pop    %esi
  80245c:	5f                   	pop    %edi
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    
  80245f:	90                   	nop
  802460:	31 ff                	xor    %edi,%edi
  802462:	31 f6                	xor    %esi,%esi
  802464:	89 f0                	mov    %esi,%eax
  802466:	89 fa                	mov    %edi,%edx
  802468:	83 c4 10             	add    $0x10,%esp
  80246b:	5e                   	pop    %esi
  80246c:	5f                   	pop    %edi
  80246d:	5d                   	pop    %ebp
  80246e:	c3                   	ret    
  80246f:	90                   	nop
  802470:	89 fa                	mov    %edi,%edx
  802472:	89 f0                	mov    %esi,%eax
  802474:	f7 f1                	div    %ecx
  802476:	89 c6                	mov    %eax,%esi
  802478:	31 ff                	xor    %edi,%edi
  80247a:	89 f0                	mov    %esi,%eax
  80247c:	89 fa                	mov    %edi,%edx
  80247e:	83 c4 10             	add    $0x10,%esp
  802481:	5e                   	pop    %esi
  802482:	5f                   	pop    %edi
  802483:	5d                   	pop    %ebp
  802484:	c3                   	ret    
  802485:	8d 76 00             	lea    0x0(%esi),%esi
  802488:	89 f1                	mov    %esi,%ecx
  80248a:	d3 e0                	shl    %cl,%eax
  80248c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802490:	b8 20 00 00 00       	mov    $0x20,%eax
  802495:	29 f0                	sub    %esi,%eax
  802497:	89 ea                	mov    %ebp,%edx
  802499:	88 c1                	mov    %al,%cl
  80249b:	d3 ea                	shr    %cl,%edx
  80249d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8024a1:	09 ca                	or     %ecx,%edx
  8024a3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024a7:	89 f1                	mov    %esi,%ecx
  8024a9:	d3 e5                	shl    %cl,%ebp
  8024ab:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8024af:	89 fd                	mov    %edi,%ebp
  8024b1:	88 c1                	mov    %al,%cl
  8024b3:	d3 ed                	shr    %cl,%ebp
  8024b5:	89 fa                	mov    %edi,%edx
  8024b7:	89 f1                	mov    %esi,%ecx
  8024b9:	d3 e2                	shl    %cl,%edx
  8024bb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024bf:	88 c1                	mov    %al,%cl
  8024c1:	d3 ef                	shr    %cl,%edi
  8024c3:	09 d7                	or     %edx,%edi
  8024c5:	89 f8                	mov    %edi,%eax
  8024c7:	89 ea                	mov    %ebp,%edx
  8024c9:	f7 74 24 08          	divl   0x8(%esp)
  8024cd:	89 d1                	mov    %edx,%ecx
  8024cf:	89 c7                	mov    %eax,%edi
  8024d1:	f7 64 24 0c          	mull   0xc(%esp)
  8024d5:	39 d1                	cmp    %edx,%ecx
  8024d7:	72 17                	jb     8024f0 <__udivdi3+0x10c>
  8024d9:	74 09                	je     8024e4 <__udivdi3+0x100>
  8024db:	89 fe                	mov    %edi,%esi
  8024dd:	31 ff                	xor    %edi,%edi
  8024df:	e9 41 ff ff ff       	jmp    802425 <__udivdi3+0x41>
  8024e4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024e8:	89 f1                	mov    %esi,%ecx
  8024ea:	d3 e2                	shl    %cl,%edx
  8024ec:	39 c2                	cmp    %eax,%edx
  8024ee:	73 eb                	jae    8024db <__udivdi3+0xf7>
  8024f0:	8d 77 ff             	lea    -0x1(%edi),%esi
  8024f3:	31 ff                	xor    %edi,%edi
  8024f5:	e9 2b ff ff ff       	jmp    802425 <__udivdi3+0x41>
  8024fa:	66 90                	xchg   %ax,%ax
  8024fc:	31 f6                	xor    %esi,%esi
  8024fe:	e9 22 ff ff ff       	jmp    802425 <__udivdi3+0x41>
	...

00802504 <__umoddi3>:
  802504:	55                   	push   %ebp
  802505:	57                   	push   %edi
  802506:	56                   	push   %esi
  802507:	83 ec 20             	sub    $0x20,%esp
  80250a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80250e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802512:	89 44 24 14          	mov    %eax,0x14(%esp)
  802516:	8b 74 24 34          	mov    0x34(%esp),%esi
  80251a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80251e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802522:	89 c7                	mov    %eax,%edi
  802524:	89 f2                	mov    %esi,%edx
  802526:	85 ed                	test   %ebp,%ebp
  802528:	75 16                	jne    802540 <__umoddi3+0x3c>
  80252a:	39 f1                	cmp    %esi,%ecx
  80252c:	0f 86 a6 00 00 00    	jbe    8025d8 <__umoddi3+0xd4>
  802532:	f7 f1                	div    %ecx
  802534:	89 d0                	mov    %edx,%eax
  802536:	31 d2                	xor    %edx,%edx
  802538:	83 c4 20             	add    $0x20,%esp
  80253b:	5e                   	pop    %esi
  80253c:	5f                   	pop    %edi
  80253d:	5d                   	pop    %ebp
  80253e:	c3                   	ret    
  80253f:	90                   	nop
  802540:	39 f5                	cmp    %esi,%ebp
  802542:	0f 87 ac 00 00 00    	ja     8025f4 <__umoddi3+0xf0>
  802548:	0f bd c5             	bsr    %ebp,%eax
  80254b:	83 f0 1f             	xor    $0x1f,%eax
  80254e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802552:	0f 84 a8 00 00 00    	je     802600 <__umoddi3+0xfc>
  802558:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80255c:	d3 e5                	shl    %cl,%ebp
  80255e:	bf 20 00 00 00       	mov    $0x20,%edi
  802563:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802567:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80256b:	89 f9                	mov    %edi,%ecx
  80256d:	d3 e8                	shr    %cl,%eax
  80256f:	09 e8                	or     %ebp,%eax
  802571:	89 44 24 18          	mov    %eax,0x18(%esp)
  802575:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802579:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80257d:	d3 e0                	shl    %cl,%eax
  80257f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802583:	89 f2                	mov    %esi,%edx
  802585:	d3 e2                	shl    %cl,%edx
  802587:	8b 44 24 14          	mov    0x14(%esp),%eax
  80258b:	d3 e0                	shl    %cl,%eax
  80258d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802591:	8b 44 24 14          	mov    0x14(%esp),%eax
  802595:	89 f9                	mov    %edi,%ecx
  802597:	d3 e8                	shr    %cl,%eax
  802599:	09 d0                	or     %edx,%eax
  80259b:	d3 ee                	shr    %cl,%esi
  80259d:	89 f2                	mov    %esi,%edx
  80259f:	f7 74 24 18          	divl   0x18(%esp)
  8025a3:	89 d6                	mov    %edx,%esi
  8025a5:	f7 64 24 0c          	mull   0xc(%esp)
  8025a9:	89 c5                	mov    %eax,%ebp
  8025ab:	89 d1                	mov    %edx,%ecx
  8025ad:	39 d6                	cmp    %edx,%esi
  8025af:	72 67                	jb     802618 <__umoddi3+0x114>
  8025b1:	74 75                	je     802628 <__umoddi3+0x124>
  8025b3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025b7:	29 e8                	sub    %ebp,%eax
  8025b9:	19 ce                	sbb    %ecx,%esi
  8025bb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025bf:	d3 e8                	shr    %cl,%eax
  8025c1:	89 f2                	mov    %esi,%edx
  8025c3:	89 f9                	mov    %edi,%ecx
  8025c5:	d3 e2                	shl    %cl,%edx
  8025c7:	09 d0                	or     %edx,%eax
  8025c9:	89 f2                	mov    %esi,%edx
  8025cb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025cf:	d3 ea                	shr    %cl,%edx
  8025d1:	83 c4 20             	add    $0x20,%esp
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    
  8025d8:	85 c9                	test   %ecx,%ecx
  8025da:	75 0b                	jne    8025e7 <__umoddi3+0xe3>
  8025dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e1:	31 d2                	xor    %edx,%edx
  8025e3:	f7 f1                	div    %ecx
  8025e5:	89 c1                	mov    %eax,%ecx
  8025e7:	89 f0                	mov    %esi,%eax
  8025e9:	31 d2                	xor    %edx,%edx
  8025eb:	f7 f1                	div    %ecx
  8025ed:	89 f8                	mov    %edi,%eax
  8025ef:	e9 3e ff ff ff       	jmp    802532 <__umoddi3+0x2e>
  8025f4:	89 f2                	mov    %esi,%edx
  8025f6:	83 c4 20             	add    $0x20,%esp
  8025f9:	5e                   	pop    %esi
  8025fa:	5f                   	pop    %edi
  8025fb:	5d                   	pop    %ebp
  8025fc:	c3                   	ret    
  8025fd:	8d 76 00             	lea    0x0(%esi),%esi
  802600:	39 f5                	cmp    %esi,%ebp
  802602:	72 04                	jb     802608 <__umoddi3+0x104>
  802604:	39 f9                	cmp    %edi,%ecx
  802606:	77 06                	ja     80260e <__umoddi3+0x10a>
  802608:	89 f2                	mov    %esi,%edx
  80260a:	29 cf                	sub    %ecx,%edi
  80260c:	19 ea                	sbb    %ebp,%edx
  80260e:	89 f8                	mov    %edi,%eax
  802610:	83 c4 20             	add    $0x20,%esp
  802613:	5e                   	pop    %esi
  802614:	5f                   	pop    %edi
  802615:	5d                   	pop    %ebp
  802616:	c3                   	ret    
  802617:	90                   	nop
  802618:	89 d1                	mov    %edx,%ecx
  80261a:	89 c5                	mov    %eax,%ebp
  80261c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802620:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802624:	eb 8d                	jmp    8025b3 <__umoddi3+0xaf>
  802626:	66 90                	xchg   %ax,%ax
  802628:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80262c:	72 ea                	jb     802618 <__umoddi3+0x114>
  80262e:	89 f1                	mov    %esi,%ecx
  802630:	eb 81                	jmp    8025b3 <__umoddi3+0xaf>
